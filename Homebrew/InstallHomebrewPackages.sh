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
#   Last Modified: 06/02/2022
#   Version: 0.1
#
#   Description: This script will verify that Homebrew is installed and then installs any Homebrew 
#   Packages that you need for your environment.
#
####################################################################################################

################# VARIABLES ######################
## homebrewPackages: The list of packages you want to install via Homebrew, seperated by commas **REQUIRED**
homebrewPackages="$4"
## currentUser: Grabs the username of the current logged in user **DO NOT CHANGE**
currentUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')
## InstallHomebrewPackages: Location of the InstallHomebrewPackages script log **DO NOT CHANGE**
InstallHomebrewPackages="/private/var/log/InstallHomebrewPackages.log"
## homebrewLog: Location of the Homebrew log **DO NOT CHANGE**
homebrewLog="/private/var/log/Homebrew.log"
## currentTime: Gets the time for the log **DO NOT CHANGE**
currentTime=$(date +%H:%M)

### swiftDialog Variables
dialogLogFile="/var/tmp/dialog.log"
dialogPath="/usr/local/bin/dialog"
dialogTitle="Homebrew Package Installs"
dialogIcon="https://upload.wikimedia.org/wikipedia/commons/3/34/Homebrew_logo.png"
declare -a theSteps
theSteps=(
    "\"Getting List of Packages\""  
)

for s in ${homebrewPackages//,/ }; do
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
        echo ">>[InstallHomebrewPackages.sh] :: $logEvent [$(date +%H:%M)] :: $logMessage"
        echo ">>[InstallHomebrewPackages.sh] :: $logEvent [$(date +%H:%M)] :: $logMessage" >> "$InstallHomebrewPackages"
    fi
}

update_dialog () {
    log_it "DIALOG: $1"
    echo "$1" >> "$dialogLogFile"
}

finish_dialog () {
    update_dialog "progresstext: Homebrew Package Installs Complete"
    sleep 1
    update_dialog "quit:"
    exit 0
}

rm "$dialogLogFile"
eval "$dialogPath" "${dialogConfig[*]}" & sleep 1

for (( i=0; i<theStepsLength; i++ )); do
    update_dialog "listitem: index: $i, status: pending"
done


if [[ ! -z "$4" ]]; then
    brew_packages="$4"
    update_dialog "listitem: index: $((currentStep++)), status: success"
else
    log_it "error" "Missing list of Homebrew Packages (Script Parameter #4)"
    update_dialog "listitem: index: $((currentStep++)), status: fail"
    exit 1
fi

if [[ ! -f "$dialogPath" ]]; then
    log_it "swiftDialog not installed"
    dialogDownload=$( curl -sL https://api.github.com/repos/bartreardon/swiftDialog/releases/latest )
    dialogURL=$(get_json_value "$dialogDownload" 'assets[0].browser_dialogURL')
    curl -L --output "dialog.pkg" --create-dirs --output-dir "/var/tmp" "$dialogURL"
    installer -pkg "/var/tmp/dialog.pkg" -target /
fi

homebrew_check () {
    # update_dialog "listitem: title: \"Updating Homebrew\", status: wait"
    macOSArch=$(/usr/bin/uname -m)

    if [[ "$macOSArch" == "x86_64" ]]; then
        log_it "System Architecture: Intel (64-Bit)"
        homebrewPath="/usr/local/bin/brew"
    elif [[ "$macOSArch" == "arm64" ]]; then
        log_it "System Architecture: Apple Silicon 64-Bit"
        homebrewPath="/opt/homebrew/bin/brew"
    fi

    if [[ ! -e $homebrewPath ]]; then
        log_it "error" "Unable to find Homebrew.. Is it installed?"
        # update_dialog "listitem: index: $((currentStep++)), status: fail"
        exit 1
    else
        log_it "Homebrew installation found.. Lets make sure its up to date before we start!"
        log_it "success" "Homebrew is already installed. Checking for any updates now.."
        su -l "$currentUser" -c "$homebrewPath update" 2>&1 | tee -a "$homebrewLog"
        # update_dialog "listitem: title: \"Updating Homebrew\", status: success"
    fi
}

install_packages () {
    # brew_packages="jq,wget,git,python,mint,carthage,watchman,chargepoint/xcparse/xcparse,danger/tap/danger-swift,nvm,saucectl"
    
    for p in ${brew_packages//,/ }; do
        log_it "Installing $p.."
        update_dialog "listitem: title: $p, status: wait"
        su -l "$currentUser" -c "$homebrewPath install $p" 2>&1 | tee -a "$homebrewLog"
        checkInstall=$(su -l "$currentUser" -c "$homebrewPath list $p" | grep "Error:")
        if [[ -z "$checkInstall" ]]; then
            log_it "success" "$p was installed successfully."
            update_dialog "listitem: title: $p, status: success"
        else
            log_it "error" "$p was unable to be installed. View Homebrew.log for details."
            update_dialog "listitem: title: $p, status: error"
        fi
    done
}

homebrew_check
install_packages
finish_dialog