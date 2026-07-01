package main

import (
	"encoding/json"
	"flag"
	"log"
	"os"
	"time"

	"kyverno-cron/config"
	"kyverno-cron/mail"
	"kyverno-cron/violations"
	"kyverno-cron/webhook"
)

func main() {
	// Parse flags
	configFile := flag.String("config", "./config.yaml", "Path to config YAML file")
	dryRun := flag.Bool("dry-run", false, "Run without sending notifications (just print violations)")
	mode := flag.String("mode", "cron", "Run mode: 'cron' (batch all clusters) or 'event' (single report from event)")
	reportType := flag.String("report-type", "", "Report type for event mode: policyreport, admissionreport, clusterpolicyreport, clusteradmissionreport")
	flag.Parse()

	log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds)
	log.Printf("Starting Kyverno Policy Violations Notifier (mode: %s)", *mode)

	startTime := time.Now()

	// Load application config
	appConfig, err := config.LoadConfig(*configFile)
	if err != nil {
		log.Fatalf("FATAL: Failed to load config: %v", err)
	}

	switch *mode {
	case "event":
		runEventMode(appConfig, *reportType, *dryRun)
	case "cron":
		runCronMode(appConfig, *dryRun)
	default:
		log.Fatalf("FATAL: Unknown mode '%s'. Use 'cron' or 'event'", *mode)
	}

	log.Printf("Completed successfully in %v", time.Since(startTime))
}

// runEventMode handles a single PolicyReport or Kubernetes Event from Argo Events
func runEventMode(appConfig *config.AppConfig, reportType string, dryRun bool) {
	log.Println("Running in EVENT mode - processing event")

	// Get event data from environment variable
	eventData := os.Getenv("EVENT_DATA")
	if eventData == "" {
		log.Fatalf("FATAL: EVENT_DATA environment variable is required in event mode")
	}

	var violationsList []violations.Violation
	var err error

	// Try to detect event type from the data
	var rawData map[string]interface{}
	if jsonErr := json.Unmarshal([]byte(eventData), &rawData); jsonErr != nil {
		log.Fatalf("FATAL: Failed to parse event data as JSON: %v", jsonErr)
	}

	// Get max event age from config
	maxEventAge := appConfig.GetMaxEventAge()

	// Check if this is a Kubernetes Event (has 'reason' field)
	if reason, ok := rawData["reason"].(string); ok && reason == "PolicyViolation" {
		log.Println("Detected Kubernetes Event (PolicyViolation)")

		// Check event age - skip old events to prevent duplicate notifications
		if maxEventAge > 0 && isEventTooOld(rawData, maxEventAge) {
			log.Printf("Event is too old (>%v), skipping to prevent duplicate notification", maxEventAge)
			return
		}

		violationsList, err = violations.ParseKubernetesEvent(eventData)
		if err != nil {
			log.Fatalf("FATAL: Failed to parse Kubernetes Event: %v", err)
		}
	} else if reportType != "" {
		// Legacy: parse as PolicyReport/AdmissionReport
		log.Printf("Parsing as %s report", reportType)
		report, parseErr := violations.ParseReportFromEvent(eventData, reportType)
		if parseErr != nil {
			log.Fatalf("FATAL: Failed to parse event data: %v", parseErr)
		}
		violationsList = violations.ExtractViolationsFromReport(report, reportType)
	} else {
		// Try to auto-detect report type from kind field
		if kind, ok := rawData["kind"].(string); ok {
			switch kind {
			case "PolicyReport":
				reportType = "policyreport"
			case "AdmissionReport":
				reportType = "admissionreport"
			case "ClusterPolicyReport":
				reportType = "clusterpolicyreport"
			case "ClusterAdmissionReport":
				reportType = "clusteradmissionreport"
			default:
				log.Fatalf("FATAL: Unknown event kind: %s. Provide --report-type flag or ensure event has 'reason: PolicyViolation'", kind)
			}
			log.Printf("Auto-detected report type: %s", reportType)
			report, parseErr := violations.ParseReportFromEvent(eventData, reportType)
			if parseErr != nil {
				log.Fatalf("FATAL: Failed to parse event data: %v", parseErr)
			}
			violationsList = violations.ExtractViolationsFromReport(report, reportType)
		} else {
			log.Fatalf("FATAL: Cannot determine event type. Provide --report-type flag or ensure event has 'reason: PolicyViolation' or 'kind' field")
		}
	}

	if len(violationsList) == 0 {
		log.Println("No violations found in event, skipping notification")
		return
	}

	log.Printf("Found %d violation(s)", len(violationsList))

	// Get cluster name from config or use default
	clusterName := appConfig.GetClusterName()

	// Build violations map (single cluster for event mode)
	violationsMap := map[string][]violations.Violation{
		clusterName: violationsList,
	}

	// If dry-run, print and exit
	if dryRun {
		log.Println("\n=== DRY RUN MODE ===")
		printViolations(violationsMap)
		return
	}

	// Send notifications
	sendNotifications(appConfig, violationsMap)
}

// runCronMode handles batch checking of all clusters (original behavior)
func runCronMode(appConfig *config.AppConfig, dryRun bool) {
	log.Println("Running in CRON mode - checking all clusters")
	log.Println("Using GCP Workload Identity for cluster authentication")

	// Get cluster configurations
	clusters := config.GetClusters()
	log.Printf("Checking %d clusters", len(clusters))

	// Create violation checker (uses Workload Identity)
	checker := violations.NewChecker()

	// Check all clusters concurrently
	log.Println("Fetching violations from all clusters...")
	result, err := checker.CheckAllClusters(clusters)
	if err != nil {
		log.Fatalf("FATAL: %v", err)
	}

	// Print summary
	log.Printf("Clusters checked successfully: %d/%d", result.SuccessCount, len(clusters))
	if result.FailureCount > 0 {
		log.Printf("WARNING: %d cluster(s) failed: %v", result.FailureCount, result.FailedClusters)
	}

	totalViolations := 0
	for cluster, v := range result.Violations {
		log.Printf("Cluster %s: %d violations", cluster, len(v))
		totalViolations += len(v)
	}
	log.Printf("Total violations found: %d", totalViolations)

	// If dry-run, print violations and exit
	if dryRun {
		log.Println("\n=== DRY RUN MODE ===")
		printViolations(result.Violations)
		if result.FailureCount > 0 {
			log.Printf("FATAL: Exiting with error due to %d cluster failure(s)", result.FailureCount)
			os.Exit(1)
		}
		return
	}

	// Send notifications if there are violations
	if len(result.Violations) > 0 {
		sendNotifications(appConfig, result.Violations)
	} else {
		log.Println("No violations found, skipping notifications")
	}

	// Exit with error if there were cluster failures
	if result.FailureCount > 0 {
		log.Fatalf("FATAL: Completed with %d cluster failure(s): %v", result.FailureCount, result.FailedClusters)
	}
}

// sendNotifications sends violations to all configured notification channels
func sendNotifications(appConfig *config.AppConfig, violationsMap map[string][]violations.Violation) {
	// Send email if enabled
	if appConfig.Recipients.Mail.Enabled {
		log.Println("Sending violations email...")
		password := config.GetSMTPPassword()
		if password == "" {
			log.Printf("WARNING: SMTP_PASSWORD environment variable is not set, skipping email")
		} else {
			emailSender := mail.NewSender(appConfig, password)
			if err := emailSender.SendViolationsEmail(violationsMap); err != nil {
				log.Printf("WARNING: Failed to send email: %v", err)
			} else {
				log.Println("Email sent successfully")
			}
		}
	} else {
		log.Println("Mail disabled, skipping email")
	}

	// Send to all enabled webhooks
	for i := range appConfig.Recipients.Webhooks {
		wh := &appConfig.Recipients.Webhooks[i]
		if !wh.Enabled {
			continue
		}
		log.Printf("Sending violations to webhook '%s' (format: %s)...", wh.Name, wh.Format)
		webhookSender := webhook.NewSender(wh)
		if err := webhookSender.SendViolations(violationsMap); err != nil {
			log.Printf("WARNING: Failed to send webhook '%s': %v", wh.Name, err)
		} else {
			log.Printf("Webhook '%s' sent successfully", wh.Name)
		}
	}
}

// isEventTooOld checks if a Kubernetes Event is older than maxEventAge
func isEventTooOld(rawData map[string]interface{}, maxEventAge time.Duration) bool {
	now := time.Now()

	// Try different timestamp fields (Kubernetes Events have multiple)
	timestampFields := []string{"lastTimestamp", "eventTime", "firstTimestamp"}

	for _, field := range timestampFields {
		if ts, ok := rawData[field].(string); ok && ts != "" {
			// Parse RFC3339 timestamp
			eventTime, err := time.Parse(time.RFC3339, ts)
			if err != nil {
				// Try alternate format
				eventTime, err = time.Parse("2006-01-02T15:04:05Z", ts)
			}
			if err == nil {
				age := now.Sub(eventTime)
				log.Printf("Event %s: %s (age: %v)", field, ts, age)
				if age > maxEventAge {
					return true
				}
				return false
			}
		}
	}

	// Also check metadata.creationTimestamp
	if metadata, ok := rawData["metadata"].(map[string]interface{}); ok {
		if ts, ok := metadata["creationTimestamp"].(string); ok && ts != "" {
			eventTime, err := time.Parse(time.RFC3339, ts)
			if err == nil {
				age := now.Sub(eventTime)
				log.Printf("Event metadata.creationTimestamp: %s (age: %v)", ts, age)
				if age > maxEventAge {
					return true
				}
				return false
			}
		}
	}

	// If we can't determine age, process the event (don't skip)
	log.Println("Could not determine event age, processing anyway")
	return false
}

// printViolations prints violations in a readable format
func printViolations(allViolations map[string][]violations.Violation) {
	if len(allViolations) == 0 {
		log.Println("No violations found!")
		return
	}

	for cluster, clusterViolations := range allViolations {
		log.Printf("\n========================================")
		log.Printf("Cluster: %s", cluster)
		log.Printf("Total violations: %d", len(clusterViolations))
		log.Printf("========================================")

		for i, v := range clusterViolations {
			log.Printf("\n[%d] %s", i+1, v.Type)
			log.Printf("    Namespace:     %s", v.Namespace)
			log.Printf("    Resource Name: %s", v.ResourceName)
			log.Printf("    Message:       %s", v.Message)
		}
	}

	// Print raw JSON
	log.Println("\n========================================")
	log.Println("RAW DATA (JSON)")
	log.Println("========================================")
	jsonData, _ := json.MarshalIndent(allViolations, "", "  ")
	log.Println(string(jsonData))
}
