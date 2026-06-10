#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch to Helium Profile
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎈
# @raycast.packageName Browser

tell application "Helium" to activate

-- Increased the delay slightly to ensure the menu bar fully loads
-- delay 0.5 

tell application "System Events"
    tell process "Helium"
        try
            -- Changed the syntax slightly to be more reliable
            click menu item "Office" of menu "Profiles" of menu bar 1
        on error errorMessage
            -- This will force a popup showing the exact error message
            display alert "AppleScript Error" message errorMessage
        end try
    end tell
end tell
