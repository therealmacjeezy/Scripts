# Bulk Lost Mode v2 Overview

> This script uses [jamfAuth](https://github.com/therealmacjeezy/JamfAuth) to perform the API authentication. Looking to setup **jamfAuth**? [Click here..](https://github.com/therealmacjeezy/JamfAuth#installation)

Looking for an easy way to enable or disable Lost Mode on your Mobile Devices? Look no further.. The `BulkLostMode-v2.py` does just that. 

This script will pull a list of serial numbers from `DeviceList.csv` and for each serial number found, it will get the device ID for that device and then either enable or disable Lost Mode for that device based on the **lostModeDisable** variable.

By default, this script will **enable** Lost Mode **without** sound.

----
## Usage
Before running `BulkLostMode-v2.py` you will need to paste the Serial Numbers into `DeviceList.csv` and save it.

Once you have saved the list of Serial Numbers, you can use the following command to start the script: `python3 BulkLostMode-v2.py`

### Options
There are four options built into `BulkLostMode-v2.py`:
 - `enable`: This will enable Lost Mode on the devices **(Default Action)**
   - **Usage:** `python3 BulkLostMode-v2.py enable`
 - `disable`: This will **disable** Lost Mode on the devices
   - **Usage:** `python3 BulkLostMode-v2.py disable`
 - `config`: This will display the current authentication and BulkLostMode-v2 variables
   - **Usage:** `python3 BulkLostMode-v2.py config`
 - `help`: This will display how to use this script and the available options
   - **Usage:** `python3 BulkLostMode-v2.py help`

----
## Requirements

#### Python Version
 - 3.8.x 
    - Tested with 3.8.13

#### Python Packages
 - requests
   - `pip3 install requests`
 - jamfAuth
   - `pip3 install jamfAuth`
 - json
   - `pip3 install json`
 - csv
   - `pip3 install csv`

----
## Examples
**BulkLostMode-v2.py**
This command will enable Lost Mode on the serial numbers entered in the csv.
```shell
12:11:29 ➜ Scripts/BulkLostMode-v2 git:(master?) python:(3.8.13) python3 bulkLostMode-v2.py
   _                  __   _         _   _
  (_) __ _ _ __ ___  / _| /_\  _   _| |_| |__
  | |/ _` | '_ ` _ \| |_ //_\\| | | | __| '_ \
  | | (_| | | | | | |  _/  _  \ |_| | |_| | | |
 _/ |\__,_|_| |_| |_|_| \_/ \_/\__,_|\__|_| |_|
|__/ ------ jamfAuth.py (v0.3.2)[pip]
----------- josh.harvey@jamf.com
----------- Created: 04/25/22
----------- Modified: 04/28/22

> jamfAuth Config Path: /Users/josh.harvey/Library/Python/3.8/lib/python/site-packages/jamfAuth/support/.jamfauth.json
[Jamf Pro Host Name]: bender.jamfcloud.com
[Jamf Pro API URL]: https://bender.jamfcloud.com/api/v1/
[Jamf Pro API Username]: mcbender
[>jamfAuth] Loaded API Token
[Jamf Pro API Token Status]: Valid
[>jamfAuth] Loaded API Token
Lost Mode Command Successfully Sent to Bender-DNQXDS5ZWD5W
Lost Mode Command Successfully Sent to TEST-DMPDDWD9Q1GC.
Lost Mode Command Successfully Sent to TEST-DLXSDW8YGHKF.
Lost Mode Command Successfully Sent to TEST-DLXQN7YDFK9.
Lost Mode Command Successfully Sent to iPad.
```

**BulkLostMode-v2.py config**
This example shows the `config` option being used to display the current settings being used.

```shell
12:10:20 ➜ Scripts/BulkLostMode-v2 git:(master?) python3 bulkLostMode-v2.py config
   _                  __   _         _   _
  (_) __ _ _ __ ___  / _| /_\  _   _| |_| |__
  | |/ _` | '_ ` _ \| |_ //_\\| | | | __| '_ \
  | | (_| | | | | | |  _/  _  \ |_| | |_| | | |
 _/ |\__,_|_| |_| |_|_| \_/ \_/\__,_|\__|_| |_|
|__/ ------ jamfAuth.py (v0.3.2)[pip]
----------- josh.harvey@jamf.com
----------- Created: 04/25/22
----------- Modified: 04/28/22

> jamfAuth Config Path: /Users/josh.harvey/Library/Python/3.8/lib/python/site-packages/jamfAuth/support/.jamfauth.json
[Jamf Pro Host Name]: bender.jamfcloud.com
[Jamf Pro API URL]: https://bender.jamfcloud.com/api/v1/
[Jamf Pro API Username]: mcbender
[>jamfAuth] Loaded API Token
[Jamf Pro API Token Status]: Valid
[>jamfAuth] Loaded API Token
config
>> jamfAuth config:
	{'apiUserName': 'mcbender', 'jamfHostName': 'bender.jamfcloud.com', 'jamfAPIURL': 'https://bender.jamfcloud.com/api/v1/'}
>> bulkLostMode settings:
	Device List: /Users/josh.harvey/Github/Scripts/BulkLostMode-v2/DeviceList.csv
	Lost Mode Message: This device has been reported lost or stolen. Please call the owner at the number below.
	Lost Mode Number:281-330-8004
	Play Lost Mode Sound: false
	Lost Mode Footnote: Thank you!
```

**BulkLostMode-v2.py disable**
This example shows the `disable` option being used.
```shell
12:14:10 ➜ Scripts/BulkLostMode-v2 git:(master?) python:(3.8.13) python3 bulkLostMode-v2.py disable
   _                  __   _         _   _
  (_) __ _ _ __ ___  / _| /_\  _   _| |_| |__
  | |/ _` | '_ ` _ \| |_ //_\\| | | | __| '_ \
  | | (_| | | | | | |  _/  _  \ |_| | |_| | | |
 _/ |\__,_|_| |_| |_|_| \_/ \_/\__,_|\__|_| |_|
|__/ ------ jamfAuth.py (v0.3.2)[pip]
----------- josh.harvey@jamf.com
----------- Created: 04/25/22
----------- Modified: 04/28/22

> jamfAuth Config Path: /Users/josh.harvey/Library/Python/3.8/lib/python/site-packages/jamfAuth/support/.jamfauth.json
[Jamf Pro Host Name]: bender.jamfcloud.com
[Jamf Pro API URL]: https://bender.jamfcloud.com/api/v1/
[Jamf Pro API Username]: mcbender
[>jamfAuth] Loaded API Token
[Jamf Pro API Token Status]: Valid
[>jamfAuth] Loaded API Token
disable
Disable Lost Mode Command Successfully Sent to Bender-DNQXDS5ZWD5W.
```