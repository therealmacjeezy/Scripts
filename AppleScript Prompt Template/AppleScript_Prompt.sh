#!/bin/bash

#################################################
# AppleScript Prompt Template
# Joshua Harvey | March 2019
# josh[at]macjeezy.com
# GitHub - github.com/therealmacjeezy    
# JAMFnation - therealmacjeezy
#################################################

############## Script Variables #################
PROMPT_TITLE="Sample Title"
PROMPT_MESSAGE="Here is a Sample Message. Go Phillies"
PROMPT_BUTTON_ONE="No"
PROMPT_BUTTON_TWO="Go Phillies"
# Must be a url that doesn't have authentication and is in the format of .png, .jpeg or .ico
PROMPT_ICON_URL="https://upload.wikimedia.org/wikipedia/en/4/47/New_Phillies_logo.png"

## Output variables above to a temporary location for use in the AppleScript prompt
if [[ ! -z "$PROMPT_TITLE" ]]; then
	echo "$PROMPT_TITLE" > /tmp/PROMPT_TITLE
else
	echo "Missing Prompt Title Variable"
	exit 1
fi

if [[ ! -z "$PROMPT_MESSAGE" ]]; then
	echo "$PROMPT_MESSAGE" > /tmp/PROMPT_MESSAGE
else
	echo "Missing Prompt Message Variable"
	exit 1
fi

if [[ ! -z "$PROMPT_BUTTON_ONE" ]]; then
	echo "$PROMPT_BUTTON_ONE" > /tmp/PROMPT_BUTTON_ONE
else
	echo "No" > /tmp/PROMPT_BUTTON_ONE
fi

if [[ ! -z "$PROMPT_BUTTON_TWO" ]]; then
	echo "$PROMPT_BUTTON_TWO" > /tmp/PROMPT_BUTTON_TWO
else
	echo "Continue" > /tmp/PROMPT_BUTTON_TWO
fi

if [[ ! -z "$PROMPT_BUTTON_TWO" ]]; then
	echo "$PROMPT_BUTTON_TWO" > /tmp/PROMPT_BUTTON_TWO
else
	echo "Continue" > /tmp/PROMPT_BUTTON_TWO
fi

if [[ ! -z "$PROMPT_BUTTON_TWO" ]]; then
	curl "$PROMPT_ICON_URL" -o /tmp/PROMPT_ICON.png
fi

displayPrompt() {
currUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk -F': ' '/[[:space:]]+Name[[:space:]]:/ { if ( $2 != "loginwindow" ) { print $2 }}')
currUserUID=$(id -u "$currUser")

/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
-- Sets AppleScript Variables to pull the contents of the files created by the bash variables in the beginning
set promptTitle to do shell script "cat /tmp/PROMPT_TITLE"
set promptMessage to do shell script "cat /tmp/PROMPT_MESSAGE"
set promptButtonOne to do shell script "cat /tmp/PROMPT_BUTTON_ONE"
set promptButtonTwo to do shell script "cat /tmp/PROMPT_BUTTON_TWO"
set promptIcon to "tmp:PROMPT_ICON.png"

display dialog promptMessage with title promptTitle buttons {promptButtonOne, promptButtonTwo} with icon file promptIcon

-- Performs an action based on the result of the button selected
if button returned of result is promptButtonTwo then
		do shell script "open https://www.mlb.com/phillies"
else if button returned of result is promptButtonOne then
		do shell script "say \"boo! Phillies Rock\""
end if
APPLESCRIPT
}

displayPrompt
