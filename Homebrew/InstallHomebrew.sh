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
#   Last Modified: 06/01/2022
#   Version: 0.1
#
#   Description: This script will check to see if you have Xcode Command Line Tools installed 
#   (it will install it if not found) then attempt to install Homebrew on your system.
#
####################################################################################################

################# VARIABLES ######################
## xcodeCLITrigger: The name of the trigger on the policy that installs Xcode Command Line Tools **REQUIRED**
xcodeCLITrigger="$4"
## currentUser: Grabs the username of the current logged in user **DO NOT CHANGE**
currentUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')
## installHomebrewLog: Location of the installHomebrew script log **DO NOT CHANGE**
installHomebrewLog="/private/var/log/InstallHomebrew.log"
## homebrewLog: Location of the Homebrew log **DO NOT CHANGE**
homebrewLog="/private/var/log/Homebrew.log"
## currentTime: Gets the time for the log **DO NOT CHANGE**
currentTime=$(date +%H:%M)

### swiftDialog Variables
dialogLogFile="/var/tmp/dialog.log"
dialogPath="/usr/local/bin/dialog"
dialogTitle="Homebrew Setup"
dialogIcon="https://upload.wikimedia.org/wikipedia/commons/3/34/Homebrew_logo.png"
theSteps=(
    "\"Install Xcode Command Line Tools\""
    "\"Install Homebrew\""
    "\"Install md5sha1sum (Homebrew)\""
    "\"Apply Permissions\""
    "\"Check for Updates\"" 
)
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
        echo ">>[InstallHomebrew.sh] :: $logEvent [$(date +%H:%M)] :: $logMessage"
        echo ">>[InstallHomebrew.sh] :: $logEvent [$(date +%H:%M)] :: $logMessage" >> "$installHomebrewLog"
    fi
}

update_dialog () {
    log_it "DIALOG: $1"
    echo "$1" >> "$dialogLogFile"
}

finish_dialog () {
    update_dialog "progresstext: Homebrew Setup Complete"
    sleep 1
    update_dialog "quit:"
    exit 0
}

if [[ -z "$xcodeCLITrigger" ]]; then
    log_it "error" "Missing Xcode Command Line Tools Trigger in Script Parameter #4."
    exit 1
fi

rm "$dialogLogFile"
eval "$dialogPath" "${dialogConfig[*]}" & sleep 1

for (( i=0; i<theStepsLength; i++ )); do
    update_dialog "listitem: index: $i, status: pending"
done

requirements_check () {
    if [[ ! -f "$dialogPath" ]]; then
        log_it "swiftDialog not installed"
        dialogDownload=$( curl -sL https://api.github.com/repos/bartreardon/swiftDialog/releases/latest )
        dialogURL=$(get_json_value "$dialogDownload" 'assets[0].browser_dialogURL')
        curl -L --output "dialog.pkg" --create-dirs --output-dir "/var/tmp" "$dialogURL"
        installer -pkg "/var/tmp/dialog.pkg" -target /
    fi

    ## Xcode CLI Check
    xcodeCLIPath="/Library/Developer/CommandLineTools"

    if [[ -e "/Library/Developer/CommandLineTools" ]]; then
        xcodeCLI="Installed"
        xcodeCLIVersion=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep "version:" | sed 's/[version: ]//g')
        if [[ ! -z "$xcodeCLIVersion" ]]; then
            log_it "success" "Xcode Command Line Tools (Version: $xcodeCLIVersion) is installed."
            update_dialog "listitem: index: $((currentStep++)), status: success"
            echo "$xcodeCLIVersion" > "/Users/Shared/xcodecliversion"
        fi
    else
        log_it "Xcode Command Line Tools are not installed.. Lets install them now!"
        update_dialog "listitem: index: $((currentStep)), status: wait"
        /usr/local/bin/jamf policy -event $xcodeCLITrigger
        xcodeCLIVersion=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep "version:" | sed 's/[version: ]//g')
        if [[ ! -z "$xcodeCLIVersion" ]]; then
            log_it "success" "Xcode Command Line Tools (Version: $xcodeCLIVersion) was successfully installed."
            update_dialog "listitem: index: $((currentStep++)), status: success"
            echo "$xcodeCLIVersion" > "/Users/Shared/xcodecliversion"
            xcodeCLI="Installed"
        else
            xcodeCLI="Missing"
        fi
    fi

    ## User Group Check
    devGroupCheck=$(groups "$currentUser" | grep -o '_developer')
    if [[ -z "$devGroupCheck" ]]; then
        /usr/sbin/dseditgroup -o edit -a "$currentUser" -t user _developer
        log_it "success" "Added $currentUser to the _developer group."
    else
        log_it "$currentUser is already a member of the _developer group."
    fi
}


install_homebrew () {
    update_dialog "listitem: index: $((currentStep)), status: wait"
    ## Lets see what architecture the system is..
    macOSArch=$(/usr/bin/uname -m)

    if [[ "$macOSArch" == "x86_64" ]]; then
        log_it "System Architecture: Intel (64-Bit)"
        homebrewPath="/usr/local/bin/brew"
        homebrewDir="/usr/local/Homebrew"
        # log_it "Setting Homebrew Directory to: $homebrewDir"
    elif [[ "$macOSArch" == "arm64" ]]; then
        log_it "System Architecture: Apple Silicon 64-Bit"
        homebrewPath="/opt/homebrew/bin/brew"
        homebrewDir="/opt/homebrew"
        # log_it "Setting Homebrew Directory to: $homebrewDir"
    fi


    if [[ ! -e "$homebrewPath" ]]; then
        log_it "Starting Homebrew installation.."

        mkdir -p "$homebrewDir"
        ## Curl down the latest tarball and install to "$homebrewDir"
        curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $homebrewDir && log_it "Homebrew downloaded successfully."

        if [[ ! -e $homebrewDir ]]; then
            log_it "error" "Homebrew failed to download."
            exit 1
        fi

        ## Manually make all the appropriate directories and set permissions
        log_it "Creating Homebrew directories and setting permissions for user $currentUser"

        if [[ "$macOSArch" == "x86_64" ]]; then
            log_it "System Architecture: Intel (64-Bit)"
            mkdir -p /usr/local/Cellar /usr/local/Homebrew mkdir /usr/local/Caskroom /usr/local/Frameworks /usr/local/bin
            mkdir -p /usr/local/include /usr/local/lib /usr/local/opt /usr/local/etc /usr/local/sbin
            mkdir -p /usr/local/share/zsh/site-functions /usr/local/var
            mkdir -p /usr/local/share/doc /usr/local/man/man1 /usr/local/share/man/man1
            chown -R "$currentUser:_developer" /usr/local/*
            chmod -R g+rwx /usr/local/*
            chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions
            ln -s /usr/local/Homebrew/bin/brew /usr/local/bin/brew
        elif [[ "$macOSArch" == "arm64" ]]; then
            log_it "System Architecture: Apple Silicon 64-Bit"
            mkdir -p /opt/homebrew/Cellar mkdir /opt/homebrew/Caskroom /opt/homebrew/Frameworks /opt/homebrew/bin
            mkdir -p /opt/homebrew/include /opt/homebrew/lib /opt/homebrew/opt /opt/homebrew/etc /opt/homebrew/sbin
            mkdir -p /opt/homebrew/share/zsh/site-functions /opt/homebrew/var
            mkdir -p /opt/homebrew/share/doc /opt/homebrew/man/man1 /opt/homebrew/share/man/man1
            chown -R "$currentUser:_developer" /opt/homebrew
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        update_dialog "listitem: index: $((currentStep++)), status: success"

        log_it "Creating system wide cache folder."
        # Create a system wide cache folder  
        mkdir -p /Library/Caches/Homebrew
        chmod g+rwx /Library/Caches/Homebrew
        chown "$currentUser:_developer" /Library/Caches/Homebrew

        log_it "Installing the MD5 Checker for Homebrew."
        update_dialog "listitem: index: $((currentStep)), status: wait"
        # Install the MD5 checker or the recipes will fail
        su -l "$currentUser" -c "$homebrewPath install md5sha1sum"
        echo 'export PATH="/usr/local/opt/openssl/bin:$PATH"' | 
        tee -a /Users/"$currentUser"/.bash_profile /Users/"$currentUser"/.zshrc
        chown "$currentUser" /Users/"$currentUser"/.bash_profile /Users/"$currentUser"/.zshrc
        update_dialog "listitem: index: $((currentStep++)), status: success"

        log_it "Setting permissions."
        update_dialog "listitem: index: $((currentStep)), status: wait"
        # Fix the permissions
        chown -R root:wheel /private/tmp
        chmod 777 /private/tmp
        chmod +t /private/tmp
        update_dialog "listitem: index: $((currentStep++)), status: success"
        
        log_it "success" "Homebrew was successfully installed! Lets double check there aren't any updates available!"
        update_dialog "listitem: index: $((currentStep)), status: wait"
        su -l "$currentUser" -c "$homebrewPath update" 2>&1 | tee -a "$homebrewLog"
        update_dialog "listitem: index: $((currentStep++)), status: success"
    else
        log_it "success" "Homebrew is already installed. Checking for any updates now.."
        update_dialog "listitem: index: $((currentStep++)), status: success"
        update_dialog "listitem: index: $((currentStep++)), status: success"
        update_dialog "listitem: index: $((currentStep++)), status: success"
        update_dialog "listitem: index: $((currentStep++)), status: success"
        update_dialog "listitem: index: $((currentStep)), status: wait"
        su -l "$currentUser" -c "$homebrewPath update" 2>&1 | tee -a "$homebrewLog"
        update_dialog "listitem: index: $((currentStep++)), status: success"
    fi
}

if [[ -z "$xcodeCLITrigger" ]]; then
    log_it "error" "The xcodeCLITrigger variable is empty. Make sure you put the trigger of the policy that's installing Xcode Command Line Tools in the xcodeCLITrigger variable on Line 42, then try running the script again."
    exit 1
else
    log_it "Starting the requirements check to see if Xcode CLI is installed and $currentUser is a member of the correct group."
    requirements_check
    if [[ "$xcodeCLI" == "Installed" ]]; then
        install_homebrew
        finish_dialog
    else
        log_it "error" "Unable to install Homebrew due to Xcode Command Line Tools not being found. Please verify that Xcode Command Line Tools is installed then try running this script again."
        update_dialog "listitem: index: $((currentStep++)), status: fail"
        update_dialog "listitem: index: $((currentStep++)), status: fail"
        update_dialog "listitem: index: $((currentStep++)), status: fail"
        update_dialog "listitem: index: $((currentStep++)), status: fail"
        update_dialog "listitem: index: $((currentStep++)), status: fail"
        exit 1
    fi
fi
    
