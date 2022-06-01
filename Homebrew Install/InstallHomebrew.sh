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
xcodeCLITrigger="installXcodeCLI"
## currentUser: Grabs the username of the current logged in user **DO NOT CHANGE**
currentUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')
## installHomebrewLog: Location of the installHomebrew script log **DO NOT CHANGE**
installHomebrewLog="/private/var/log/InstallHomebrew.log"
## homebrewLog: Location of the Homebrew log **DO NOT CHANGE**
homebrewLog="/private/var/log/Homebrew.log"
## currentTime: Gets the time for the log **DO NOT CHANGE**
currentTime=$(date +%H:%M)
###################################################

## Logging Function
cliLog () {
    if [[ ! -z "$1" && -z "$2" ]]; then
        cliLogIcon="INFO"
        logMessage="$1"
    elif [[ "$1" == "warning" ]]; then
        cliLogIcon="WARN"
        logMessage="$2"
    elif [[ "$1" == "success" ]]; then
        cliLogIcon="SUCCESS"
        logMessage="$2"
    elif [[ "$1" == "error" ]]; then
        cliLogIcon="ERROR"
        logMessage="$2"
    fi

    if [[ ! -z "$cliLogIcon" ]]; then
        echo ">>[InstallHomebrew.sh] :: $cliLogIcon [$(date +%H:%M)] :: $logMessage"
        echo ">>[InstallHomebrew.sh] :: $cliLogIcon [$(date +%H:%M)] :: $logMessage" >> "$installHomebrewLog"
    fi
}

requirements_check () {
    ## Xcode CLI Check
    xcodeCLIPath=$(/usr/bin/xcode-select --print-path 2>&1)

    if [[ "$xcodeCLIPath" == "/Library/Developer/CommandLineTools" ]]; then
        xcodeCLI="Installed"
        xcodeCLIVersion=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep "version:" | sed 's/[version: ]//g')
        if [[ ! -z "$xcodeCLIVersion" ]]; then
            cliLog "success" "Xcode Command Line Tools (Version: $xcodeCLIVersion) is installed."
            echo "$xcodeCLIVersion" > "/Users/Shared/xcodecliversion"
        fi
    else
        cliLog "Xcode Command Line Tools are not installed.. Lets install them now!"
        /usr/local/bin/jamf policy -event $xcodeCLITrigger
        xcodeCLIVersion=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep "version:" | sed 's/[version: ]//g')
        if [[ ! -z "$xcodeCLIVersion" ]]; then
            cliLog "success" "Xcode Command Line Tools (Version: $xcodeCLIVersion) was successfully installed."
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
        cliLog "success" "Added $currentUser to the _developer group."
    else
        cliLog "$currentUser is already a member of the _developer group."
    fi
}


install_homebrew () {
    ## Lets see what architecture the system is..
    macOSArch=$(/usr/bin/uname -m)

    if [[ "$macOSArch" == "x86_64" ]]; then
        cliLog "System Architecture: Intel (64-Bit)"
        homebrewPath="/usr/local/bin/brew"
        homebrewDir="/usr/local/Homebrew"
        # cliLog "Setting Homebrew Directory to: $homebrewDir"
    elif [[ "$macOSArch" == "arm64" ]]; then
        cliLog "System Architecture: Apple Silicon 64-Bit"
        homebrewPath="/opt/homebrew/bin/brew"
        homebrewDir="/opt/homebrew"
        # cliLog "Setting Homebrew Directory to: $homebrewDir"
    fi


    if [[ ! -e "$homebrewPath" ]]; then
        cliLog "Starting Homebrew installation.."

        mkdir -p "$homebrewDir"
        ## Curl down the latest tarball and install to "$homebrewDir"
        curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $homebrewDir && cliLog "Homebrew downloaded successfully."

        if [[ ! -e $homebrewDir ]]; then
            cliLog "error" "Homebrew failed to download."
            exit 1
        fi

        ## Manually make all the appropriate directories and set permissions
        cliLog "Creating Homebrew directories and setting permissions for user $currentUser"

        if [[ "$macOSArch" == "x86_64" ]]; then
            cliLog "System Architecture: Intel (64-Bit)"
            mkdir -p /usr/local/Cellar /usr/local/Homebrew mkdir /usr/local/Caskroom /usr/local/Frameworks /usr/local/bin
            mkdir -p /usr/local/include /usr/local/lib /usr/local/opt /usr/local/etc /usr/local/sbin
            mkdir -p /usr/local/share/zsh/site-functions /usr/local/var
            mkdir -p /usr/local/share/doc /usr/local/man/man1 /usr/local/share/man/man1
            chown -R "$currentUser:_developer" /usr/local/*
            chmod -R g+rwx /usr/local/*
            chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions
            ln -s /usr/local/Homebrew/bin/brew /usr/local/bin/brew
        elif [[ "$macOSArch" == "arm64" ]]; then
            cliLog "System Architecture: Apple Silicon 64-Bit"
            mkdir -p /opt/homebrew/Cellar mkdir /opt/homebrew/Caskroom /opt/homebrew/Frameworks /opt/homebrew/bin
            mkdir -p /opt/homebrew/include /opt/homebrew/lib /opt/homebrew/opt /opt/homebrew/etc /opt/homebrew/sbin
            mkdir -p /opt/homebrew/share/zsh/site-functions /opt/homebrew/var
            mkdir -p /opt/homebrew/share/doc /opt/homebrew/man/man1 /opt/homebrew/share/man/man1
            chown -R "$currentUser:_developer" /opt/homebrew
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        cliLog "Creating system wide cache folder."
        # Create a system wide cache folder  
        mkdir -p /Library/Caches/Homebrew
        chmod g+rwx /Library/Caches/Homebrew
        chown "$currentUser:_developer" /Library/Caches/Homebrew

        cliLog "Installing the MD5 Checker for Homebrew."
        # Install the MD5 checker or the recipes will fail
        su -l "$currentUser" -c "$homebrewPath install md5sha1sum"
        echo 'export PATH="/usr/local/opt/openssl/bin:$PATH"' | 
        tee -a /Users/"$currentUser"/.bash_profile /Users/"$currentUser"/.zshrc
        chown "$currentUser" /Users/"$currentUser"/.bash_profile /Users/"$currentUser"/.zshrc

        cliLog "Setting permissions."
        # Fix the permissions
        chown -R root:wheel /private/tmp
        chmod 777 /private/tmp
        chmod +t /private/tmp
        
        cliLog "success" "Homebrew was successfully installed! Lets double check there aren't any updates available!"
        su -l "$currentUser" -c "$homebrewPath update" 2>&1 | tee -a "$homebrewLog"
    else
        cliLog "success" "Homebrew is already installed. Checking for any updates now.."
        su -l "$currentUser" -c "$homebrewPath update" 2>&1 | tee -a "$homebrewLog"
    fi
}

if [[ -z "$xcodeCLITrigger" ]]; then
    cliLog "error" "The xcodeCLITrigger variable is empty. Make sure you put the trigger of the policy that's installing Xcode Command Line Tools in the xcodeCLITrigger variable on Line 42, then try running the script again."
    exit 1
else
    cliLog "Starting the requirements check to see if Xcode CLI is installed and $currentUser is a member of the correct group."
    requirements_check
    if [[ "$xcodeCLI" == "Installed" ]]; then
        install_homebrew
    else
        cliLog "error" "Unable to install Homebrew due to Xcode Command Line Tools not being found. Please verify that Xcode Command Line Tools is installed then try running this script again."
        exit 1
    fi
fi
    
