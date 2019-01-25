#!/bin/bash

#################################################
# LAPS for MAC
#################################################

########### Parameters (Required) ###############
# 4 - API Username String
# 5 - API Password String
# 6 - Local Admin Username
# 7 - Old Password (Required for first usage)

# HARDCODED VALUES
jssURL="<JSSURLHERE>"
udid=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID:/ { print $3 }')
extAttName="\"<EXTENSIONATTRIBUTENAMEHERE>\""
newPass=$(env LC_CTYPE=C tr -dc "A-Za-z0-9#$^_+=" < /dev/urandom | head -c 12 > /tmp/pwlaps)
getPass=$(cat /tmp/pwlaps)

# Decrypt String
DecryptString() {
	# Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
	echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

# Account Information
if [[ -z "$4" ]]; then 
    echo "Error: API USER MISSING"
    exit 1
else
	apiUser=$(DecryptString "$4" '<SALTHERE>' '<PASSPHRASEHERE>')        
fi

if [[ -z "$5" ]]; then
	echo "Error: API PASS MISSING"
    exit 1        
else
	apiPass=$(DecryptString "$5" '<SALTHERE>' '<PASSPHRASEHERE>')
fi

if [[ -z "$6" ]]; then
    echo "ERROR: ADMIN NAME MISSING"
    exit 1
else
    adminUser="$6"
fi

# Verify local admin
checkUser=$(dseditgroup -o checkmember -m $adminUser localaccounts | awk '{ print $1 }')
 
if [[ "$checkUser" = "yes" ]];then
    echo "$adminUser is a local user"
else
    echo "ERROR: $adminUser is not a local user! :( Exiting."
    exit 1
fi

# Magic Below
passwordCheck() {
    passCheck=$(/usr/bin/dscl /Local/Default -authonly "$adminUser" "$oldPass")
    if [[ -z "$passCheck" ]]; then
        echo "Continue"
    else
        echo "ERROR: Password is either old or unknown, checking EA"
        oldPass=$(curl -s -f -u $apiUser:$apiPass -H "Accept: application/xml" $jssURL/JSSResource/computers/udid/$udid/subset/extension_attributes | xpath "//extension_attribute[name=$extAttName]" 2>&1 | awk -F'<value>|</value>' '{print $2}' | tail -1)
        passCheck2=$(/usr/bin/dscl /Local/Default -authonly "$adminUser" "$oldPass")
            if [[ ! -z "$passCheck2" ]]; then
                echo "ERROR: Password is unknown. Exiting"
                exit 1
            fi
    fi
}

if [[ ! -z "$7" ]]; then
	echo "$7"
    oldPass="$7"
    passwordCheck
else
    oldPass=$(curl -s -f -u $apiUser:$apiPass -H "Accept: application/xml" $jssURL/JSSResource/computers/udid/$udid/subset/extension_attributes | xpath "//extension_attribute[name=$extAttName]" 2>&1 | awk -F'<value>|</value>' '{print $2}')
    passwordCheck
fi

genLAPS() {
    /usr/sbin/sysadminctl -adminUser $adminUser -adminPassword $oldPass -resetPasswordFor $adminUser -newPassword $getPass
}

resetCheck() {
    /usr/bin/dscl /Local/Default -authonly "$adminUser" "$getPass"
    echo "New Password works as: $getPass"    
}

setEAStatus() {
  
curl -s -u $apiUser:"$apiPass" -X "PUT" "$jssURL/JSSResource/computers/udid/$udid/subset/extension_attributes" \
		-H "Content-Type: application/xml" \
		-H "Accept: application/xml" \
		-d "<computer><extension_attributes><extension_attribute><name>testLAPS</name><type>String</type><input_type><type>Text Field</type></input_type><value>$getPass</value></extension_attribute></extension_attributes></computer>" \
	2>&1 > /dev/null
    
rm -f /tmp/pwlaps
}

genLAPS
resetCheck
setEAStatus
