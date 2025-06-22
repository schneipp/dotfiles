#!/bin/bash
osascript -e 'tell application "iTerm2"
  tell current window
    create tab with default profile
    tell current session
      write text "lowfi"
    end tell
  end tell
end tell'
