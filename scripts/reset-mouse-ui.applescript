-- reset-mouse-ui.applescript
-- Forgets all not-connected "Logi M650" pairings in System Settings >
-- Bluetooth, then connects the nearby "Logi M650" (mouse in pairing mode),
-- then forgets any bond that went stale during the run.
-- Run from a terminal that has Accessibility permission:
--   osascript ~/.dotfiles/scripts/reset-mouse-ui.applescript
--
-- macOS 26 findings (probed live):
--   * device row = static text <name> / static text <status> / unnamed info button
--   * info button opens a SHEET; buttons unlabeled: bottom-left =
--     "Forget This Device...", bottom-right = "Done"
--   * forget confirm = vertical stack: "Forget Device" on top, "Cancel" below
--   * nearby rows are bare static texts; the Connect button only exists
--     while the row is HOVERED -> click at row to hover, rescan, click Connect
--
-- Perf: device sections are queried with batched "every static text/button"
-- calls on the content scroll area (a few Apple events) instead of walking
-- the whole window; the slow full-window walk remains as a fallback.

property deviceName : "Logi M650"
property logPath : "/Users/sujal.ja/.cache/reset-mouse.log"

on logLine(t)
	log (t as string) -- live progress on stderr
	do shell script "echo " & quoted form of (t as string) & " >> " & quoted form of logPath
end logLine

-- Content scroll area of the Bluetooth pane (missing value if not found).
-- Discovered dynamically: walk the splitter group's child groups (content
-- side last), find a scroll area at depth 1-2 that is NOT the sidebar
-- (sidebar's scroll area contains an outline).
on contentArea()
	tell application "System Events"
		tell process "System Settings"
			try
				set sg to splitter group 1 of group 1 of window 1
				set gs to every group of sg
				repeat with gi from (count of gs) to 1 by -1
					set g to item gi of gs
					try
						if exists scroll area 1 of g then
							if not (exists outline 1 of scroll area 1 of g) then return scroll area 1 of g
						end if
					end try
					try
						repeat with g2 in (every group of g)
							if exists scroll area 1 of g2 then
								if not (exists outline 1 of scroll area 1 of g2) then return scroll area 1 of g2
							end if
						end repeat
					end try
				end repeat
			end try
		end tell
	end tell
	return missing value
end contentArea

-- Fast scan via batched queries;
-- returns {staleInfoButtons, connectedFlag, nearbyTextElems, nearbyGroup}
on scanDevices()
	set cont to my contentArea()
	if cont is missing value then return my scanDevicesSlow()
	set staleBtns to {}
	set nearbyTexts to {}
	set nearbyGroup to missing value
	set connectedFlag to false
	tell application "System Events"
		set secGroups to {}
		try
			set secGroups to every group of cont
		end try
		repeat with g in secGroups
			set tvals to {}
			try
				set tvals to value of every static text of g
			end try
			set gBtns to {}
			try
				set gBtns to every button of g
			end try
			-- split texts into row names and their statuses
			set nameList to {}
			set statusList to {}
			repeat with tv in tvals
				set v to tv as string
				if v starts with "Not Connected" or v starts with "Connected" then
					if (count of nameList) > 0 then set item (count of nameList) of statusList to v
				else
					set end of nameList to v
					set end of statusList to ""
				end if
			end repeat
			set hasStatus to false
			repeat with s in statusList
				if (s as string) is not "" then set hasStatus to true
			end repeat
			if hasStatus then
				-- paired-devices section: k-th name row <-> k-th info button
				if (count of nameList) is (count of gBtns) then
					repeat with k from 1 to count of nameList
						if (item k of nameList) is deviceName then
							set s to (item k of statusList) as string
							if s starts with "Not Connected" then
								set end of staleBtns to item k of gBtns
							else if s starts with "Connected" then
								set connectedFlag to true
							end if
						end if
					end repeat
				else
					return my scanDevicesSlow() -- unexpected layout
				end if
			else
				-- nearby-devices (or header) section
				if nameList contains deviceName then
					try
						set nrefs to (every static text of g whose value is deviceName)
						repeat with r in nrefs
							set end of nearbyTexts to contents of r
						end repeat
						set nearbyGroup to contents of g
					end try
				end if
			end if
		end repeat
	end tell
	return {staleBtns, connectedFlag, nearbyTexts, nearbyGroup}
end scanDevices

-- Fallback: walk every element of the window (slow but layout-agnostic)
on scanDevicesSlow()
	logLine("  (using slow full-window scan)")
	tell application "System Events"
		tell process "System Settings"
			set elems to entire contents of window 1
			set staleBtns to {}
			set nearbyTexts to {}
			set connectedFlag to false
			set sawName to false
			set pendingForget to false
			set lastNameElem to missing value
			repeat with elem in elems
				set c to missing value
				try
					set c to class of elem
				end try
				if c is static text then
					set v to ""
					try
						set v to (value of elem) as string
					end try
					if sawName then
						if v starts with "Connected" then
							set connectedFlag to true
						else if v starts with "Not Connected" then
							set pendingForget to true
						else
							set end of nearbyTexts to lastNameElem
						end if
					end if
					if v is deviceName then
						set sawName to true
						set lastNameElem to contents of elem
					else
						set sawName to false
					end if
				else if c is button then
					if pendingForget then set end of staleBtns to contents of elem
					if sawName then set end of nearbyTexts to lastNameElem
					set sawName to false
					set pendingForget to false
				else
					if sawName then set end of nearbyTexts to lastNameElem
					set sawName to false
					set pendingForget to false
				end if
			end repeat
			if sawName then set end of nearbyTexts to lastNameElem
			return {staleBtns, connectedFlag, nearbyTexts, missing value}
		end tell
	end tell
end scanDevicesSlow

-- Physically move the pointer (CGEvent mouseMoved) — SwiftUI hover overlays
-- (like the nearby-row Connect button) only appear on real pointer motion;
-- System Events' "click at" does not move the cursor.
on moveMouse(mx, myy)
	set jxa to "ObjC.import('CoreGraphics'); var e=$.CGEventCreateMouseEvent($(), 5, {x:" & mx & ", y:" & myy & "}, 0); $.CGEventPost(0, e);"
	do shell script "osascript -l JavaScript -e " & quoted form of jxa
end moveMouse

on buttonsOf(cont)
	set btns to {}
	tell application "System Events"
		set elems to entire contents of cont
		repeat with e in elems
			try
				if class of e is button then set end of btns to (contents of e)
			end try
		end repeat
	end tell
	return btns
end buttonsOf

on clickNamed(btns, needle)
	tell application "System Events"
		repeat with b in btns
			try
				set bn to (name of b) as string
				if bn contains needle then
					click b
					return true
				end if
			end try
		end repeat
	end tell
	return false
end clickNamed

on leftmost(btns)
	tell application "System Events"
		set best to missing value
		set bestX to 999999
		repeat with b in btns
			try
				set p to position of b
				if (item 1 of p) < bestX then
					set bestX to item 1 of p
					set best to contents of b
				end if
			end try
		end repeat
		return best
	end tell
end leftmost

-- Open a stale row's info sheet, click "Forget This Device...", confirm.
on forgetOne(infoBtn)
	tell application "System Events" to tell process "System Settings"
		try
			click infoBtn
		on error errMsg
			my logLine("  info button click failed: " & errMsg)
			return false
		end try
	end tell

	set sheetOpen to false
	repeat 12 times
		tell application "System Events" to tell process "System Settings"
			try
				if exists sheet 1 of window 1 then set sheetOpen to true
			end try
		end tell
		if sheetOpen then exit repeat
		delay 0.2
	end repeat
	if not sheetOpen then
		logLine("  sheet never opened; skipping")
		return false
	end if

	delay 0.25
	tell application "System Events" to tell process "System Settings"
		set sheetBtns to my buttonsOf(sheet 1 of window 1)
	end tell
	-- "Forget This Device..." is the bottom-LEFT unlabeled button
	if not my clickNamed(sheetBtns, "Forget") then
		set fb to my leftmost(sheetBtns)
		if fb is missing value then
			logLine("  no buttons in sheet?! skipping")
			tell application "System Events" to key code 53
			return false
		end if
		tell application "System Events" to click fb
	end if
	delay 0.6

	-- confirmation dialog
	tell application "System Events" to tell process "System Settings"
		set confBtns to {}
		try
			if exists sheet 1 of sheet 1 of window 1 then
				set confBtns to my buttonsOf(sheet 1 of sheet 1 of window 1)
			else if exists sheet 1 of window 1 then
				set confBtns to my buttonsOf(sheet 1 of window 1)
			else if exists window 2 then
				set confBtns to my buttonsOf(window 2)
			end if
		end try
	end tell
	if my clickNamed(confBtns, "Forget") then
		logLine("  confirmed (named button)")
	else if (count of confBtns) > 0 then
		-- unlabeled confirm buttons: destructive action is top (vertical
		-- stack) or right (horizontal row)
		tell application "System Events"
			set b1 to item 1 of confBtns
			set tgt to b1
			if (count of confBtns) ≥ 2 then
				set b2 to item 2 of confBtns
				set p1 to position of b1
				set p2 to position of b2
				set dx to (item 1 of p2) - (item 1 of p1)
				set dy to (item 2 of p2) - (item 2 of p1)
				if dx < 0 then set dx to -dx
				if dy < 0 then set dy to -dy
				if dy > dx then
					if (item 2 of p2) < (item 2 of p1) then set tgt to b2
				else
					if (item 1 of p2) > (item 1 of p1) then set tgt to b2
				end if
			end if
			click tgt
		end tell
		logLine("  confirmed (position heuristic)")
	else
		logLine("  no confirm dialog appeared")
	end if
	delay 0.7
	return true
end forgetOne

-- Forget all stale entries (bottom-up). Returns number forgotten.
on forgetAllStale()
	set {staleBtns, connectedFlag, nearbyTexts} to my scanDevices()
	set n to count of staleBtns
	if n is 0 then return 0
	logLine("forgetting " & n & " stale " & deviceName & " entries...")
	set done to 0
	repeat with i from n to 1 by -1
		logLine("forgetting stale entry " & i & "...")
		if my forgetOne(item i of staleBtns) then set done to done + 1
	end repeat
	return done
end forgetAllStale

-- ============================ main ============================
do shell script "mkdir -p ~/.cache && : > " & quoted form of logPath
logLine("run start: " & deviceName)

do shell script "open 'x-apple.systempreferences:com.apple.BluetoothSettings'"
-- wait until the pane is actually loaded instead of a fixed sleep
repeat 20 times
	if my contentArea() is not missing value then exit repeat
	delay 0.3
end repeat
tell application "System Events" to tell process "System Settings"
	set frontmost to true
	delay 0.3
	-- close any leftover sheets from a previous run (may be nested)
	repeat 3 times
		try
			if exists sheet 1 of window 1 then
				key code 53
				delay 0.6
			else
				exit repeat
			end if
		end try
	end repeat
end tell

-- ---------- phase 1: forget stale entries ----------
logLine("scanning device list...")
set forgotten to my forgetAllStale()
logLine("phase 1 done: forgot " & forgotten)

-- ---------- phase 2: connect nearby device ----------
-- Hover over the nearby row (click at its coords) so the hidden Connect
-- button appears, then click it.
set {staleBtns, connectedFlag, nearbyTexts, nearbyGroup} to my scanDevices()
if connectedFlag then
	logLine(deviceName & " is already connected")
else
	repeat with attempt from 1 to 6
		if (count of nearbyTexts) > 0 then
			logLine("hovering nearby " & deviceName & " row...")
			set rowX to 0
			set rowY to 0
			set rowH to 0
			tell application "System Events" to tell process "System Settings"
				try
					set t to item 1 of nearbyTexts
					set {px, py} to position of t
					set {sw, sh} to size of t
					set rowX to px
					set rowY to py
					set rowH to sh
				on error errMsg
					my logLine("  hover failed: " & errMsg)
				end try
			end tell
			-- real pointer motion (two moves so a hover event definitely fires)
			my moveMouse(rowX + (rowH div 2), rowY + (rowH div 2))
			delay 0.15
			my moveMouse(rowX + (rowH div 2) + 5, rowY + (rowH div 2) + 1)
			delay 0.5
			-- find the Connect button that appeared in the hovered row's band.
			-- SwiftUI attaches the hover overlay outside the nearby group, so
			-- escalate: nearby group -> content area -> whole window (slow)
			set clickedConnect to false
			repeat with lvl from 1 to 3
				set bandBtns to {}
				if lvl is 1 then
					if nearbyGroup is not missing value then set bandBtns to my buttonsOf(nearbyGroup)
				else if lvl is 2 then
					set cont to my contentArea()
					if cont is not missing value then
						tell application "System Events"
							try
								set bandBtns to every button of cont
							end try
							try
								set bls to every button of every group of cont
								repeat with bl in bls
									repeat with b in bl
										set end of bandBtns to contents of b
									end repeat
								end repeat
							end try
						end tell
					end if
				else
					tell application "System Events" to tell process "System Settings"
						set bandBtns to my buttonsOf(window 1)
					end tell
				end if
				tell application "System Events"
					repeat with b in bandBtns
						try
							set bp to position of b
							set bYpos to item 2 of bp
							if bYpos ≥ (rowY - 15) and bYpos ≤ (rowY + rowH + 15) and (item 1 of bp) > rowX then
								click b
								set clickedConnect to true
								exit repeat
							end if
						end try
					end repeat
				end tell
				if clickedConnect then
					logLine("  found Connect at search level " & lvl)
					exit repeat
				end if
				if lvl is 3 then
					-- diagnostics: where is everything relative to the row?
					logLine("  row band: x>" & rowX & " y=" & (rowY - 15) & ".." & (rowY + rowH + 15))
					tell application "System Events"
						repeat with b in bandBtns
							try
								set bp to position of b
								set bn to ""
								try
									set bn to (name of b) as string
								end try
								my logLine("  window button: name=" & bn & " pos=" & (item 1 of bp) & "," & (item 2 of bp))
							end try
						end repeat
					end tell
				end if
			end repeat
			if clickedConnect then
				logLine("  clicked Connect; waiting for pairing...")
				-- poll until the paired list shows it connected
				repeat 8 times
					delay 1
					set {staleBtns, connectedFlag, nearbyTexts, nearbyGroup} to my scanDevices()
					if connectedFlag then exit repeat
				end repeat
			else
				logLine("  no Connect button appeared in row band")
				delay 1
				set {staleBtns, connectedFlag, nearbyTexts, nearbyGroup} to my scanDevices()
			end if
		else
			logLine("attempt " & attempt & ": no nearby " & deviceName & " (pairing mode?)...")
			delay 1.5
			set {staleBtns, connectedFlag, nearbyTexts, nearbyGroup} to my scanDevices()
		end if
		if connectedFlag then exit repeat
	end repeat
end if

-- ---------- phase 3: clean up any bond that went stale mid-run ----------
set forgotten2 to my forgetAllStale()
if forgotten2 > 0 then logLine("phase 3: forgot " & forgotten2 & " leftover stale entries")

set {staleBtns, finalConnected, nearbyTexts} to my scanDevices()

tell application "System Settings" to quit

set summary to "forgot " & (forgotten + forgotten2) & " stale entries (" & (count of staleBtns) & " remain); "
if finalConnected then
	set summary to summary & deviceName & " connected"
else
	set summary to summary & deviceName & " NOT connected - put it in pairing mode and rerun"
end if
logLine("done: " & summary)
return summary
