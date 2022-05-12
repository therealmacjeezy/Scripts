# Create Policy and Profile Scope Overview

> This script uses [jamfAuth](https://github.com/therealmacjeezy/JamfAuth) to perform the API authentication. Looking to setup **jamfAuth**? [Click here..](https://github.com/therealmacjeezy/JamfAuth#installation)

This script gets the list of all of Policies and Configuration Profiles used in your Jamf Pro server and creates two .csv files (`Jamf Pro Policy Scope Overview.csv` and `Jamf Pro Configuration Profile Scope Overview.csv`) that contain the following:

 - Policy / Configuration Profile Name
    - Hyperlinked to the Policy / Configuration Profile in Jamf Pro
 - Policy / Configuration Profile ID
 - Policy Scope
 - Policy Scope: Computers
 - Policy Scope: Smart Groups

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
	=> /Users/josh.harvey/Desktop/Jamf Pro Policy Scope Overview.csv

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
	=> /Users/josh.harvey/Desktop/Jamf Pro Configuration Profile Scope Overview.csv
```