#!/bin/bash

####################################################################################################
#
# Copyright (c) 2022, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#   Author: Josh Harvey
#   Last Modified: 06/07/2022
#   Version: 0.2
#
#   Description: This script will install Ruby Gems on macOS systems via Jamf Pro
#
####################################################################################################

################# VARIABLES ######################
## rubyGems: The list of packages you want to install via Ruby, seperated by commas **REQUIRED**
rubyGems="$4"
## currentUser: Grabs the username of the current logged in user **DO NOT CHANGE**
currentUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')
## installRubyGemsLog: Location of the installRubyGems script log **DO NOT CHANGE**
installRubyGemsLog="/private/var/log/installRubyGemsLog.log"
## currentTime: Gets the time for the log **DO NOT CHANGE**
currentTime=$(date +%H:%M)

### swiftDialog Variables
dialogLogFile="/var/tmp/dialog.log"
dialogPath="/usr/local/bin/dialog"
dialogTitle="Ruby Gem Installs"
dialogIcon="https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Ruby_logo.svg/128px-Ruby_logo.svg.png"
declare -a theSteps
theSteps=(
    "\"Getting List of Ruby Gems\""  
)

for s in ${rubyGems//,/ }; do
    echo "$s"
    theSteps+=("\"$s\"")
done

theStepsLength="${#theSteps[@]}"
currentStep=0
dialogConfig=(
    "--title \"$dialogTitle\""
    "--icon \"$dialogIcon\""
    "--position topleft"
    "--message \" \""
    "--messagefont \"size=16\""
    # "--small"
    "--ontop"
    "--moveable"
    # "--position centre"
    "${theSteps[@]/#/--listitem }"
)
###################################################

## Logging Function
log_it () {
    if [[ ! -z "$1" && -z "$2" ]]; then
        logEvent="INFO"
        logMessage="$1"
    elif [[ "$1" == "warning" ]]; then
        logEvent="WARN"
        logMessage="$2"
    elif [[ "$1" == "success" ]]; then
        logEvent="SUCCESS"
        logMessage="$2"
    elif [[ "$1" == "error" ]]; then
        logEvent="ERROR"
        logMessage="$2"
    fi

    if [[ ! -z "$logEvent" ]]; then
        echo ">>[installRubyGemsLog.sh] :: $logEvent [$(date +%H:%M)] :: $logMessage"
        echo ">>[installRubyGemsLog.sh] :: $logEvent [$(date +%H:%M)] :: $logMessage" >> "$installRubyGemsLog"
    fi
}

update_dialog () {
    log_it "DIALOG: $1"
    echo "$1" >> "$dialogLogFile"
}

finish_dialog () {
    update_dialog "progresstext: Ruby Gem Installs Complete"
    sleep 1
    update_dialog "quit:"
    exit 0
}

if [[ ! -f "$dialogPath" ]]; then
    log_it "swiftDialog not installed"
    dialogDownload=$( curl -sL https://api.github.com/repos/bartreardon/swiftDialog/releases/latest )
    dialogURL=$(get_json_value "$dialogDownload" 'assets[0].browser_dialogURL')
    curl -L --output "dialog.pkg" --create-dirs --output-dir "/var/tmp" "$dialogURL"
    installer -pkg "/var/tmp/dialog.pkg" -target /
fi

rm "$dialogLogFile"
eval "$dialogPath" "${dialogConfig[*]}" & sleep 1

for (( i=0; i<theStepsLength; i++ )); do
    update_dialog "listitem: index: $i, status: pending"
done


if [[ ! -z "$4" ]]; then
    ruby_gems="$4"
    update_dialog "listitem: index: $((currentStep++)), status: success"
else
    log_it "error" "Missing list of Ruby Gems to Install (Script Parameter #4)"
    update_dialog "listitem: index: $((currentStep++)), status: fail"
    exit 1
fi

install_gems () {
    
    for p in ${ruby_gems//,/ }; do
        log_it "Installing $p.."
        update_dialog "listitem: title: $p, status: wait"
        gem install $p 2>&1 | tee -a "$installRubyGemsLog"
        checkInstall=$(which $p | grep "not found")
        if [[ -z "$checkInstall" ]]; then
            log_it "success" "$p was installed successfully."
            update_dialog "listitem: title: $p, status: success"
        else
            log_it "error" "$p was unable to be installed. View installRubyGemsLog.log for details."
            update_dialog "listitem: title: $p, status: error"
        fi
    done
}

install_gems
finish_dialog