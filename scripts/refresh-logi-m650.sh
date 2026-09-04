#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Refresh Logi M650
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🖱️
# @raycast.packageName Bluetooth

# refresh-logi-m650.sh — forget all stale "Logi M650" pairings and connect the
# live one (after pressing the mouse's reset button, put it in pairing mode).
#
# The M650 is a BLE device: blueutil cannot unpair or discover it, so this
# drives System Settings > Bluetooth via AppleScript UI automation.
# Don't touch the mouse/keyboard while it runs.
#
# One-time setup: System Settings > Privacy & Security > Accessibility
#   -> enable your terminal app (Ghostty / Alacritty).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# progress lines stream on stderr; summary prints at the end
if ! osascript "$SCRIPT_DIR/reset-mouse-ui.applescript"; then
    echo "failed — see ~/.cache/reset-mouse.log"
    echo "if the error mentions 'assistive access': System Settings > Privacy & Security > Accessibility -> enable your terminal"
    exit 1
fi
