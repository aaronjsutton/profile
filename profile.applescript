#!/usr/bin/osascript
# profile - missing profile tool for macOS Terminal.

on run argv
  set usage to "usage: profile <command>\nAvailable commands:
    list - show all profiles
    set <profile> - set the current profile
  "
  if length of argv is 0 
    log usage 
    return
  end if

  set command to item 1 of argv

  if command is "list"
    listProfiles()
  else if command is "set" 
    if length of argv is not 2 
      log usage
    end if

    setProfile(item 2 of argv)
    return
  else if command is "fadetest"
    fadeBackgroundColor(0)
  end if
end run

# Print out all available profiles
on listProfiles() 
  set terminalPreferencesFilePath to "~/Library/Preferences/com.apple.Terminal.plist"
  tell application "System Events"
    tell property list file terminalPreferencesFilePath
        set windowSettings to property list item "Window Settings"
        log "Available profiles: "
        repeat with profile in property list items of windowSettings
          log name of profile as text
        end repeat
    end tell
  end tell
end listProfiles

# Set the current terminal profile.
# profile - Exact name of the terminal profile
on setProfile(profile)
  tell application "Terminal"
    set current settings of first window to settings set profile
  end tell
end setProfile
