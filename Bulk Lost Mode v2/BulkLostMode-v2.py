#!/usr/bin/python3

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
#   Last Modified: 05/26/2022
#   Version: 1.00
#
#   Description: This script pulls serial numbers from a CSV and can either enable or disable Lost Mode on those devices.
#
#   File Format
#       Serial Number
#   
#   Authentication Notes:
#   This script uses jamfAuth [https://github.com/therealmacjeezy/JamfAuth] to authenticate with the Jamf Pro API. Please 
#   configure that before using this script. 
#
#   Usage: python3 BulkLostMode-v2.py
#
#
####################################################################################################


import json, requests, sys, jamfAuth
from jamfAuth import *
from csv import reader

################# VARIABLES ######################
## lostModeMsg: What message do you want to be displayed **REQUIRED**
lostModeMsg = 'This device has been reported lost or stolen. Please call the owner at the number below.'
## lostModePhone: What number can you be reached at. **REQUIRED**
lostModePhone = '281-330-8004'
## lostModeSound: Do you want sound to play from the device? Set this value to either 'true' or 'false' **Optional** (Default: false)
lostModeSound = 'false'
## lostModeDisable: Do you want to turn off lost mode on the devices? true/false **Optional** (Default: false)
lostModeDisable = ''
## lostModeFootnote: Do you want a footnote message to be displayed? **Optional**
lostModeFootnote = 'Thank you!'
## deviceList: CSV file containing all of the serial numbers to activate lost mode on. **REQUIRED**
deviceList = 'DeviceList.csv'
###################################################

def read_device_list(deviceList):
    global devices
    devices = []
    try:
        with open(deviceList, 'r') as d:
            csv_reader = reader(d)
            for i in csv_reader:
                devices.append(*i)
        return devices
    except Exception as errorMessage:
        print(f"read_device_list ERROR:\n{errorMessage}")
            
def get_device_id(apiToken, jamfURL, devices):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    try:
        for d in devices:
            apiURL = f"https://{jamfURL}/JSSResource/mobiledevices/serialnumber/{d}"
            r = requests.get(apiURL, headers=headers)
            getDeviceIDJSON = r.json()
            deviceID = getDeviceIDJSON['mobile_device']['general']['id']
            displayName = getDeviceIDJSON['mobile_device']['general']['display_name']
            if lostModeDisable == 'true':
                disable_lost_mode(apiToken, jamfURL, deviceID, displayName)
            else:
                set_lost_mode(apiToken, jamfURL, deviceID, displayName)
    except Exception as errorMessage:
        print(f"\tcheck_policy_status [error]:\nmsg: {errorMessage}")

def play_lost_mode_sound(apiToken, jamfURL, deviceID, displayName):
    xmlData = f'''<mobile_device_command>
	<general>
		<command>PlayLostModeSound</command>
	</general>
	<mobile_devices>
		<mobile_device>
			<id>{deviceID}</id>
		</mobile_device>
	</mobile_devices>
</mobile_device_command>'''

    try:
        headers = {'Content-Type': 'application/xml', 'Authorization': f'Bearer {apiToken}'}
        apiURL = f"https://{jamfURL}/JSSResource/mobiledevicecommands/command/PlayLostModeSound/id/{deviceID}"
        r = requests.post(apiURL, headers=headers)
        if r.status_code == 200:
            print(f"\tLost Mode Sound Command Successfully Sent to {displayName}")
        elif r.status_code == 201:
            print(f"\tLost Mode Sound Command Successfully Sent to {displayName}")
    except Exception as errorMessage:
        print(f"\tplay_lost_mode_sound ERROR:\n {errorMessage}")

def set_lost_mode(apiToken, jamfURL, deviceID, displayName):
    xmlData = f'''<mobile_device_command>
	<general>
		<command>EnableLostMode</command>
        <lost_mode_message>{lostModeMsg}</lost_mode_message>
        <lost_mode_phone>{lostModePhone}</lost_mode_phone>
        <lost_mode_footnote>{lostModeFootnote}</lost_mode_footnote>
	</general>
	<mobile_devices>
		<mobile_device>
			<id>{deviceID}</id>
		</mobile_device>
	</mobile_devices>
</mobile_device_command>'''

    try:
        headers = {'Content-Type': 'application/xml', 'Authorization': f'Bearer {apiToken}'}
        apiURL = f"https://{jamfURL}/JSSResource/mobiledevicecommands/command/EnableLostMode/id/{deviceID}"
        r = requests.post(apiURL, data=xmlData, headers=headers)
        if r.status_code == 200:
            # print(f"Lost Mode Command Successfully Sent to {displayName}.")
            if lostModeSound == 'true':
                play_lost_mode_sound(apiToken, jamfURL, deviceID, displayName)
        elif r.status_code == 201:
            print(f"Lost Mode Command Successfully Sent to {displayName}.")
            if lostModeSound == 'true':
                play_lost_mode_sound(apiToken, jamfURL, deviceID, displayName)
        elif r.status_code == 401:
            print("Your account is unauthorized to perform this action.")
        else:
            print(f"Lost Mode Command Failed for {displayName}\n")
    except Exception as errorMessage:
        print(f"\tset_lost_mode ERROR:\n{errorMessage}")        

def disable_lost_mode(apiToken, jamfURL, deviceID, displayName):
    xmlData = f'''<mobile_device_command>
	<general>
		<command>DisableLostMode</command>
	</general>
	<mobile_devices>
		<mobile_device>
			<id>{deviceID}</id>
		</mobile_device>
	</mobile_devices>
</mobile_device_command>'''

    try:
        headers = {'Content-Type': 'application/xml', 'Authorization': f'Bearer {apiToken}'}
        apiURL = f"https://{jamfURL}/JSSResource/mobiledevicecommands/command/EnableLostMode/id/{deviceID}"
        r = requests.post(apiURL, data=xmlData, headers=headers)
        if r.status_code == 200:
            print(f"Disable Lost Mode Command Successfully Sent to {displayName}.")
            if lostModeSound == 'true':
                play_lost_mode_sound(apiToken, jamfURL, deviceID, displayName)
        elif r.status_code == 201:
            print(f"Disable Lost Mode Command Successfully Sent to {displayName}.")
            if lostModeSound == 'true':
                play_lost_mode_sound(apiToken, jamfURL, deviceID, displayName)
        elif r.status_code == 401:
            print("Your account is unauthorized to perform this action.")
        else:
            print(f"Disable Lost Mode Command Failed for {displayName}\n")
    except Exception as errorMessage:
        print(f"\tdisable_lost_mode ERROR:\n{errorMessage}")   

if __name__ == '__main__':
    ### Config Section
    jamfAuthPath = os.path.dirname(jamfAuth.__file__)
    jamfAuthConfig = f"{jamfAuthPath}/support/.jamfauth.json"
    
    f = open(jamfAuthConfig)

    jamfAuthJSON = json.load(f)

    jamfURL = jamfAuthJSON['jamfHostName']

    ### Get API Token with jamfAuth
    apiToken = startAuth()

    if len(sys.argv) > 1:
        print(sys.argv[1])
        if sys.argv[1] == 'enable':
            lostModeDisable = 'false'
        if sys.argv[1] == 'disable':
            lostModeDisable = 'true'
        if sys.argv[1] == 'config':
            print(f">> jamfAuth config:\n\t{jamfAuthJSON}")
            print(f">> bulkLostMode settings:\n\tDevice List: {deviceList}\n\tLost Mode Message: {lostModeMsg}\n\tLost Mode Number:{lostModePhone}\n\tPlay Lost Mode Sound: {lostModeSound}\n\tLost Mode Footnote: {lostModeFootnote}")
            sys.exit()
        if sys.argv[1] == 'help':
            print(f">> BulkLostMode-v2.py Usage:\n\tpython3 BulkLostMode-v2.py\n>> Options:\n\t- enable: enables lost mode\n\t- disable: disables lost mode\n\t- config: shows the current authentication and BulkLostMode-v2 variables\n\t- help: usage and available options")
            sys.exit()

    read_device_list(deviceList)
    get_device_id(apiToken, jamfURL, devices)
    