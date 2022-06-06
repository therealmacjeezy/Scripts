#!/bin/bash

XCODE_VERSION="$4"
XCODE_TRIGGER="$5"
XCODE_NAME="Xcode_${XCODE_VERSION}"
XCODE_XIP_CACHE="/Library/Application Support/JAMF/Waiting Room/${XCODE_NAME}.xip.pkg"
XCODE_XIP_PATH="/Library/Mooncheese/${XCODE_NAME}.xip"
UNXIP="/Library/Mooncheese/Tools/unxip"

LOG_FOLDER="/private/var/log"
LOG_NAME="InstallXcode.log"
JAMF_BINARY="/usr/local/bin/jamf"
DIALOG_APP="/usr/local/bin/dialog"
DIALOG_COMMAND_FILE="/var/tmp/dialog.log"
DIALOG_ICON="https://developer.apple.com/assets/elements/icons/xcode-12/xcode-12-256x256.png"
DIALOG_INITIAL_TITLE="Installing Xcode"

DIALOG_STEPS=(
    "\"Downloading Xcode\""
    "\"Unpacking Xcode\""
    "\"Moving Xcode into Place\""
    "\"Setting Permissions\""
    "\"Installing Xcode Packages\""
)
DIALOG_STEP_LENGTH="${#DIALOG_STEPS[@]}"
DIALOG_STEP=0

DIALOG_CMD=(
    "--title \"$DIALOG_INITIAL_TITLE\""
    "--icon \"$DIALOG_ICON\""
    "--position topleft"
    "--message \" \""
    "--messagefont \"size=16\""
    # "--small"
    "--ontop"
    "--moveable"
    # "--position centre"
    "${DIALOG_STEPS[@]/#/--listitem }"
)

echo_logger() {
    LOG_FOLDER="${LOG_FOLDER:=/private/var/log}"
    LOG_NAME="${LOG_NAME:=log.log}"

    mkdir -p $LOG_FOLDER

    echo -e "$(date) - $1" | tee -a $LOG_FOLDER/$LOG_NAME
}

dialog_update() {
    echo_logger "DIALOG: $1"
    # shellcheck disable=2001
    echo "$1" >> "$DIALOG_COMMAND_FILE"
}

dialog_finalise() {
    dialog_update "progresstext: Xcode Install Complete"
    sleep 1
    dialog_update "quit:"
    exit 0
}

get_json_value() {
    JSON="$1" osascript -l 'JavaScript' \
        -e 'const env = $.NSProcessInfo.processInfo.environment.objectForKey("JSON").js' \
        -e "JSON.parse(env).$2"
}

if [ ! -f "$DIALOG_APP" ]; then
    echo_logger "swiftDialog not installed"
    dialog_latest=$( curl -sL https://api.github.com/repos/bartreardon/swiftDialog/releases/latest )
    dialog_url=$(get_json_value "$dialog_latest" 'assets[0].browser_download_url')
    curl -L --output "dialog.pkg" --create-dirs --output-dir "/var/tmp" "$dialog_url"
    installer -pkg "/var/tmp/dialog.pkg" -target /
fi

rm "$DIALOG_COMMAND_FILE"
eval "$DIALOG_APP" "${DIALOG_CMD[*]}" & sleep 1

for (( i=0; i<DIALOG_STEP_LENGTH; i++ )); do
    dialog_update "listitem: index: $i, status: pending"
done

#########################################################################################
# Downloading Xcode
#########################################################################################

if [ -f "${XCODE_XIP_CACHE}" ]; then
    mv "${XCODE_XIP_CACHE}" "${XCODE_XIP_PATH}"
    rm "${XCODE_XIP_CACHE}.cache.xml"
    dialog_update "listitem: index: $((DIALOG_STEP++)), status: success"
else
    dialog_update "listitem: index: $((DIALOG_STEP)), status: wait"
	  echo_logger "${XCODE_NAME}.xip is not cached in waiting room, caching now"

    "$JAMF_BINARY" policy -event "${XCODE_TRIGGER}"
    mv "${XCODE_XIP_CACHE}" "${XCODE_XIP_PATH}"
    rm "${XCODE_XIP_CACHE}.cache.xml"
    dialog_update "listitem: index: $((DIALOG_STEP++)), status: success"
fi

#########################################################################################
# Unpacking Xcode
#########################################################################################
dialog_update "listitem: index: $((DIALOG_STEP)), status: wait"

echo_logger "Expanding ${XCODE_XIP_PATH}"
if [[ ! -e "/Library/Mooncheese" ]]; then
    mkdir -p "/Library/Mooncheese"
fi
$UNXIP "${XCODE_XIP_PATH}" "/Library/Mooncheese"

echo_logger "Removing ${XCODE_XIP_PATH}"
rm "${XCODE_XIP_PATH}"

dialog_update "listitem: index: $((DIALOG_STEP++)), status: success"

#########################################################################################
# Moving Xcode into Place
#########################################################################################
dialog_update "listitem: index: $((DIALOG_STEP)), status: wait"

echo_logger "Moving Xcode into Applications..."
mv "/Library/Mooncheese/Xcode.app" "/Applications/${XCODE_NAME}.app"

echo_logger "Removing Quarantine Attribute.."
xattr -rd com.apple.quarantine "/Applications/${XCODE_NAME}.app"

dialog_update "listitem: index: $((DIALOG_STEP++)), status: success"

#########################################################################################
# Setting Permissions
#########################################################################################
dialog_update "listitem: index: $((DIALOG_STEP)), status: wait"

echo_logger "Ensure everyone is a member of 'developer' group"
/usr/sbin/dseditgroup -o edit -a everyone -t group _developer

echo_logger "Enable Developer Mode"
/usr/sbin/DevToolsSecurity -enable

echo_logger "Removing Quarantine Attribute.."
xattr -rd com.apple.quarantine "/Applications/${XCODE_NAME}.app"

echo_logger "Switch to new Xcode Version"
/usr/bin/xcode-select -s "/Applications/${XCODE_NAME}.app"

echo_logger "Accept the license"
"/Applications/${XCODE_NAME}.app/Contents/Developer/usr/bin/xcodebuild" -license accept
dialog_update "listitem: index: $((DIALOG_STEP++)), status: success"

#########################################################################################
# Installing Xcode Packages
#########################################################################################
dialog_update "listitem: index: $((DIALOG_STEP)), status: wait"

for PKG in $(/bin/ls /Applications/"${XCODE_NAME}".app/Contents/Resources/Packages/*.pkg); do
    /usr/sbin/installer -pkg "$PKG" -target /
done
dialog_update "listitem: index: $((DIALOG_STEP++)), status: success"
sleep 2
dialog_finalise

exit 0
