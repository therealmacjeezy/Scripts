#!/bin/bash

# Set Console Height and Width to 100x40
printf '\033[8;40;110t'

# Clear Console Window
clear

# Script Header and Title Section
setHeader() {
echo "      _   _                       __                 __                     ";
echo "     | |_| |--.----.---.----.--.-|  .-----.--.-.----|__.----.----.----.--.-.";
echo "     |  _|    |  -_|  _|  -_|  _ |  |     | _  |  __|  |  -_|  -_|-- _|  | |";
echo "     |___|_|__|____|_| |____|__._|__|_|_|_|__._|____|  |____|____|____|___ |";
echo "     josh[at]macjeezy.com                          |___|              |____|";
echo "                                                                   	      ";



cat <<'EOF'
    *************************************************************************
    > Remote Connection Script | Version 1.0								
    > Created By: Josh Harvey | March 2018
								
    > JamfNation: therealmacjeezy
    > Github: github.com/therealmacjeezy 
    *************************************************************************

EOF
}

setHeader

setMenu() {
while [[ -z "$optionSelected" ]]; do
# Menu Section
echo "Select an option from the menu:"

# Menu Options
cat <<'EOF'
	1) SSH
	2) VNC (Screen Sharing)
	3) Host Lookup
	4) Quit
EOF

printf 'Selection: '
read selectedOption

# Clears the input from the above line
tput cuu1; tput cr; tput el;
echo " "
	# Handles the user selection
	case $selectedOption in
		1|SSH|ssh|Ssh)
			echo "SSH Selected"
			optionSelected=ssh
			;;
		2|VNC|vnc|"Screen Sharing"|"screen sharing"|Vnc)
			echo "VNC (Screen Sharing) Selected"
			optionSelected=vnc
			;;
		3|"Host Lookup"|"host lookup")
			echo "Host Lookup Selected"
			optionSelected=lookup
			;;
		4|Q|q|Quit|quit)
			clear
			exit 0
			;;
		*)
			echo "Invalid Option.. Try Again"
			clear
			setHeader
			;;
	esac
done
echo "$optionSelected"
}

setMenu

until [[ "$exitScript" == yes ]]; do
# Remote Connection Section
if [[ "$optionSelected" == "ssh" ]]; then
	echo " "
	
	echo "Would you like to copy the command to enable VNC to the clipboard? [y,n]"
	
	printf 'Copy Command?: '
	read copyVNC
	
	tput cuu1; tput cr; tput el;
	tput cuu1; tput cr; tput el;
	
	case $copyVNC in
		y|Y|yes|Yes)
			echo 'sudo  /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw mypasswd -restart -agent -privs -all' | pbcopy
			echo "Command to enable VNC has been copied to the clipboard"
			;;
		n|N|no|No)
			echo "Command to enable VNC has NOT been copied to the clipboard"
			tput cuu1; tput cr; tput el;
			;;
		*)
			echo "Invalid Option.. Continuting without copying command"
			tput cuu1; tput cr; tput el;
			;;
	esac
	
	echo "Please type the host you are connecting to: (IP Address or FQDN) "
	printf 'Host: '
	read sshHost
	checkHost=yes
		while [[ "$checkHost" == yes ]]; do
			echo "Verify: You entered $sshHost.. Is this correct? [y,n]"
			read hostAnswer
			
			tput cuu1; tput cr; tput el;
			case "$hostAnswer" in
				y|yes|Yes|Y)
					tput cuu1; tput cr; tput el;
					checkHost=done
					;;
				n|no|No|N)
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					echo "Please type the IP Address or FQDN you are connecting to: "
					printf 'Host: '
					read sshHost
					checkUser=done
					;;
				*)
					echo "Invalid Answer.. using $checkHost"
					checkUser=done
					;;
			esac	
		done

	echo "Please enter the username to use for connecting: "
	read sshUser
	checkUser=yes
		while [[ "$checkUser" == yes ]]; do
			echo "You entered $sshUser.. Is this correct? [y,n]"
			read userAnswer
			
			tput cuu1; tput cr; tput el;
			case "$userAnswer" in
				y|yes|Yes|Y)
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					checkUser=done
					;;
				n|no|No|N)
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					echo "Please enter the username to use for connecting: "
					read sshUser
					checkUser=done
					;;
				*)
					echo "Invalid Answer.. using $checkUser"
					checkUser=done
					;;
			esac	
		done
	
	clear
	
	echo "Starting SSH Connection to $sshHost as $sshUser ..."
	echo " "
	echo "****************************** Note ******************************"
	echo "You will be prompted to enter the password once the connection has been established."
	echo "You may also be prompted to add the fingerprint to your ssh hosts file if this is your first time connecting to this host"
	echo "******************************************************************"
	echo " "
	ssh "$sshUser"@"$sshHost"
	exitScript=yes
elif [[ "$optionSelected" == "vnc" ]]; then
	echo " "
	
	echo "Please type the IP Address or FQDN you are connecting to: "
	read vncHost

	checkHost=yes
		while [[ "$checkHost" == yes ]]; do
			echo "You entered $vncHost.. Is this correct? [y,n]"
			read hostAnswer
			
			tput cuu1; tput cr; tput el;
			case "$hostAnswer" in
				y|yes|Yes|Y)
					tput cuu1; tput cr; tput el;
					checkHost=done
					;;
				n|no|No|N)
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					echo "Please type the IP Address or FQDN you are connecting to: "
					read vncHost
					checkUser=done
					;;
				*)
					echo "Invalid Answer.. using $checkHost"
					checkUser=done
					;;
			esac	
		done

	echo "Please enter the username to user for connecting: "
	read vncUser

	checkUser=yes
		while [[ "$checkUser" == yes ]]; do
			echo "You entered $vncUser.. Is this correct? [y,n]"
			read userAnswer
			
			tput cuu1; tput cr; tput el;
			case "$userAnswer" in
				y|yes|Yes|Y)
					tput cuu1; tput cr; tput el;
					checkUser=done
					;;
				n|no|No|N)
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					tput cuu1; tput cr; tput el;
					echo "Please enter the username to user for connecting: "
					read vncUser
					checkUser=done
					;;
				*)
					echo "Invalid Answer.. using $checkUser"
					checkUser=done
					;;
			esac	
		done
	
	clear
		
	echo "Starting VNC (Screen Sharing) Connection to $vncHost as $vncUser ..."
	echo " "
	echo "****************************** Note ******************************"
	echo "You will be prompted to enter the password once the connection has been established."
	echo " "
	echo "If a prompt stating Screen Sharing is not enabled, you can rerun this script using -e flag and selecting ssh as the Remote Connection option. This will copy the command to enable Screen Sharing to your clipboard, which can then be pasted into the SSH session once it has been established."
	echo "******************************************************************"
	echo " "
	open "vnc://"$vncUser"@"$vncHost""
	exit 0
elif [[ "$optionSelected" == "lookup" ]]; then
	echo " "
	
	echo "Which type of host are you looking up?"
cat <<'EOF'
	1) FQDN
	2) IP Address
EOF
	printf 'Selection:'
	read hostType

	tput cuu1; tput cr; tput el;
	
	case $hostType in
		1|fqdn|FQDN)
			printf 'Enter the FQDN to lookup: '
			read theHost
			
			hostName=$(nslookup "$theHost" | grep Address | awk '{print $2}'| tail -1)

				if [[ "$hostName" =~ "#" ]]; then
					echo "No Host Found. Exiting"
					sleep 1
					echo "Returning to Main Menu"
					clear
					optionSelected=""
					setHeader
					setMenu
				else
					echo "$hostName" | pbcopy
					echo "The IP Address has been copied to the clipboard"
					sleep 2
					echo "Returning to Main Menu"
					clear
					optionSelected=""
					setHeader
					setMenu
				fi
			;;
		2|IP|ip|"IP Address"|"ip address")
			printf 'Enter the IP Address to lookup: '
			read theHost
			
			ipAddress=$(nslookup "$theHost" | grep name | awk '{print $4}' | cut -b1-)

				if [[ -z "$ipAddress" ]]; then
					echo "No IP Address Found. Exiting"
					sleep 1
					echo "Returning to Main Menu"
					clear
					optionSelected=""
					setHeader
					setMenu
				else
					echo "${ipAddress%?}" | pbcopy
					echo "The Hostname has been copied to the clipboard"
					sleep 2
					echo "Returning to Main Menu"
					clear
					optionSelected=""
					setHeader
					setMenu
				fi
			;;
		*)
			echo "Invalid Option.. Returning to Main Menu"
			sleep 1
			clear
			optionSelected=""
			setHeader
			setMenu
			;;
	esac		
fi
done





