# Create Policy and Profile Scope Overview

> This script uses [jamfAuth](https://github.com/therealmacjeezy/JamfAuth) to perform the API authentication. Looking to setup **jamfAuth**? [Click here..](https://github.com/therealmacjeezy/JamfAuth#installation)

Looking for an easy way to get the scopes for all of your Policies and Configuration Profiles? Look no further.. The `getScopes.py` does just that. 

This script gets the list of all of Policies and Configuration Profiles used in your Jamf Pro server and creates two **.csv** files (`JamfPro_ProfileScope_Overview.csv` and `JamfPro_ConfigurationProfileScope_Overview.csv`) that contain the following:

  - Policy / Configuration Profile Name
     - Hyperlinked to the Policy / Configuration Profile in Jamf Pro
  - Policy / Configuration Profile ID
  - Policy Scope
    - Policy Scope: Computers
    - Policy Scope: Smart Groups

----
### To-Do
- [ ] Add Exclusions to the Policy section
- [ ] Add Policy Status (enabled/disabled) 

----
## Requirements

#### Python Version
3.8.13+

#### Python Packages
 - requests
   - `pip3 install requests`
 - pandas
   - `pip3 install pandas`
 - jamfAuth
   - `pip3 install jamfAuth`
 - json
   - `pip3 install json`

----
## Usage
```shell
python3 /path/to/getScopes.py
```
----
## Example

```shell
22:26:15 [took 3s] ➜ desktop python:(3.8.13) python3 getScopes.py
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
[Jamf Pro Host Name]: planetexpress.jamfcloud.com
[Jamf Pro API URL]: https://planetexpress.jamfcloud.com/api/v1/
[Jamf Pro API Username]: bender42
[>jamfAuth] Loaded API Token
[Jamf Pro API Token Status]: Valid
[>jamfAuth] Loaded API Token

==== Jamf Pro Policies ====

>> Total Policies: 8
----------------------------
- Policy Name: Elevate Account (ID: 8)
- Policy Name: Install Jamf Connect (ID: 6)
- Policy Name: Install jamfAuth (ID: 4)
- Policy Name: Install Mooncheese Resources (ID: 5)
- Policy Name: Setup Jamf Connect (ID: 2)
- Policy Name: Submit Computer Inventory (ID: 7)
- Policy Name: Test Sound (ID: 3)
- Policy Name: Update Inventory (ID: 1)

The Profile Scope Overview has been saved at:
	=> /Users/josh.harvey/Desktop/JamfPro_PolicyScope_Overview.csv

==== Jamf Pro Configuration Profiles ====

>> Total Configuration Profiles: 11
----------------------------
- Configuration Profile Name: Default Plan - Jamf Protect Configuration (ID: 1)
- Configuration Profile Name: Jamf Connect - Login (ID: 3)
- Configuration Profile Name: Jamf Connect - Menu (ID: 4)
- Configuration Profile Name: Jamf Connect License (ID: 5)
- Configuration Profile Name: Loading... Network Profile (ID: 8)
- Configuration Profile Name: Jamf Connect Login Window (Self Service) (ID: 10)
- Configuration Profile Name: Jamf Connect Menu (Self Service) (ID: 11)
- Configuration Profile Name: Jamf Connect License (Self Service) (ID: 12)
- Configuration Profile Name: Disable Displays Prefrence Pane (ID: 13)
- Configuration Profile Name: Jamf Connect - Menu Keychain Test (ID: 14)
- Configuration Profile Name: Keychain Test (ID: 15)

The Configuration Profile Scope Overview has been saved at:
	=> /Users/josh.harvey/Desktop/JamfPro_ConfigurationProfileScope_Overview.csv
```

**Example JamfPro_ConfigurationProfileScope_Overview.csv**
| Configuration Profile Name                | Configuration Profile ID | Configuration Profile Scope | Scope: Computers | Scope: Computer Groups                  |
|-------------------------------------------|--------------------------|-----------------------------|------------------|-----------------------------------------|
| Default Plan - Jamf Protect Configuration | 1                        | All Computers               | N/A              | N/A                                     |
| Jamf Connect - Login                      | 3                        | All Computers               | N/A              | N/A                                     |
| Jamf Connect - Menu                       | 4                        | All Computers               | N/A              | N/A                                     |
| Jamf Connect License                      | 5                        | All Computers               | N/A              | N/A                                     |
| Loading... Network Profile                | 8                        | All Computers               | N/A              | N/A                                     |
| Jamf Connect Login Window (Self Service)  | 10                       | Custom                      | N/A              | Remove Jamf Connect                     |
| Jamf Connect Menu (Self Service)          | 11                       | Custom                      | N/A              | macOS Update Ready, Remove Jamf Connect |
| Jamf Connect License (Self Service)       | 12                       | Custom                      | N/A              | Remove Jamf Connect                     |
| Disable Displays Prefrence Pane           | 13                       | All Computers               | N/A              | N/A                                     |
| Jamf Connect - Menu Keychain Test         | 14                       | All Computers               | N/A              | N/A                                     |
| Keychain Test                             | 15                       | All Computers               | N/A              | N/A                                     |
