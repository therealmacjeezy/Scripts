# Create Policy and Profile Scope Overview

> This script uses [jamfAuth](https://github.com/therealmacjeezy/JamfAuth) to perform the API authentication. Looking to setup **jamfAuth**? [Click here..](https://github.com/therealmacjeezy/JamfAuth#installation)

**Last Updated:** 06/15/2022 - Added Policy Packages and Policy Scripts functions.

Looking for an easy way to get the scopes for all of your Policies and Configuration Profiles? Look no further.. The `CreateScopeSummary.py` does just that. 

This script reaches out to your Jamf Pro Server and gets a list of the Policies and Configuration Profiles you are using within your Jamf Pro Server. It then loops through each of the Policies and Configuration Profiles to get the following information:

 - Policy / Configuration Profile Name
    - When this gets saved to the `.csv`, a hyperlink gets created to take you to that policy within Jamf Pro when clicked on.
 - Policy / Configuration Profile ID
 - Policy Status *(Is it enabled?)*
 - Policy Packages
 - Policy Scripts
 - Policy / Configuration Profile Scope
 - Policy / Configuration Profile Exclusions

Once it's done, it will then create two `.csv` files containing the above information and display the path to each file inside the Terminal window. There are two sample `.csv` files in this repository to give you an example of what you should expect these files to contain. I've also included markdown table versions of both files in the **Examples** section *(#2 and #3)*.


Below are the categories the script **currently checks for** within `scope` and `exclusions`:
 - Computers
 - Computer Groups


----
### To-Do
- [x] Add Exclusions to the Policy section
- [x] Add Policy Status (enabled/disabled)
- [x] Add Policy Packages (if any are added)
- [x] Add Policy Scripts (if any are added)
- [ ] Add the following categories to the scoped targets and exclusions search:
  - [ ] Users
  - [ ] LDAP User Groups 

----
## Requirements

#### Python Version
 - 3.8.x 
    - Tested with 3.8.13

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
python3 /path/to/CreateScopeSummary.py
```
----
## Examples
#### Example 1: CreateScopeSummary.py Output
```shell
09:43:12 [took 4s] ➜ python:(3.8.13) python3 CreateScopeSummary.py
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
[Jamf Pro Host Name]: mooncheese.jamfcloud.com
[Jamf Pro API URL]: https://mooncheese.jamfcloud.com/api/v1/
[Jamf Pro API Username]: mcapi
[>jamfAuth] Loaded API Token
[Jamf Pro API Token Status]: Valid
[>jamfAuth] Loaded API Token

==== Jamf Pro Policies ====

>> Total Policies: 10
----------------------------
Cache Xcode Package (ID: 13)
	Packages: Xcode_13.4.xip.pkg (ID: 7)
Elevate Account (ID: 8)
	Scripts: Temporary User Account Elevation (ID: 2)
Install Homebrew (ID: 10)
	Scripts: InstallHomebrew.sh (ID: 3)
Install Homebrew Packages (ID: 16)
	Scripts: Install Homebrew Packages (ID: 6)
Install Jamf Connect (ID: 6)
	Packages: Jamf Connect [2.11] (ID: 1)
Install jamfAuth (ID: 4)
	Scripts: Install jamfAuth (ID: 1)
Install Mooncheese Resources (ID: 5)
	Packages: Install Mooncheese Items.pkg (ID: 3), Tux.pkg (ID: 9)
Install Python3 Packages (ID: 18)
	Scripts: Install Python3 Packages (ID: 8)
Install Ruby Gems (ID: 17)
	Scripts: Install Ruby Gems (ID: 7)
Install swiftDialog (ID: 11)
	Packages: dialog-1.10.4-2602.pkg (ID: 5)
	Scripts: Add swiftDialog To Path (ID: 4)

The Profile Scope Overview has been saved at:
	=> /Users/josh.harvey/Github/Scripts/Create Policy and Profile Scope Overview/JamfPro_PolicyScope_Overview-05122022.csv

==== Jamf Pro Configuration Profiles ====

>> Total Configuration Profiles: 11
----------------------------
Default Plan - Jamf Protect Configuration (ID: 1)
Jamf Connect - Login (ID: 3)
Jamf Connect - Menu (ID: 4)
Jamf Connect License (ID: 5)
Loading... Network Profile (ID: 8)
Jamf Connect Login Window (Self Service) (ID: 10)
Jamf Connect Menu (Self Service) (ID: 11)
Jamf Connect License (Self Service) (ID: 12)
Disable Displays Prefrence Pane (ID: 13)
Jamf Connect - Menu Keychain Test (ID: 14)
Keychain Test (ID: 15)

The Configuration Profile Scope Overview has been saved at:
	=> /Users/josh.harvey/Github/Scripts/Create Policy and Profile Scope Overview/JamfPro_ConfigurationProfile_ScopeOverview-05122022.csv
```


#### Example 2: `JamfPro_ConfigurationProfile_ScopeOverview-06152022.csv`
|**Policy Name** | **Policy ID** | **Policy Enabled?** | **Packages** | **Scripts** | **Policy Scope** | **Scope: Computers** | **Scope: Computer Groups** | **Scope: Excluded Computers** | **Scope: Excluded Computer Groups** |
|--------------------------------------------|---------|---------------|-----------------------------------------------------|---------------------------------------------------|-------------|------------------------------|----------------------|-------------------------|---------------------------------------------------------|
|Cache Xcode Package                         |13       |TRUE           |Xcode_13.4.xip.pkg (ID: 7)                           |                                                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Elevate Account                             |8        |TRUE           |                                                     |Temporary User Account Elevation (ID: 2)           |All Computers|N/A                           |N/A                   |N/A                      |Bound Systems (ID: 5), Software Updates Available (ID: 7)|
|Install Homebrew                            |10       |TRUE           |                                                     |InstallHomebrew.sh (ID: 3)                         |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install Homebrew Packages                   |16       |TRUE           |                                                     |Install Homebrew Packages (ID: 6)                  |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install Jamf Connect                        |6        |TRUE           |Jamf Connect [2.11] (ID: 1)                          |                                                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install jamfAuth                            |4        |TRUE           |                                                     |Install jamfAuth (ID: 1)                           |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install Mooncheese Resources                |5        |TRUE           |Install Mooncheese Items.pkg (ID: 3), Tux.pkg (ID: 9)|                                                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install Python3 Packages                    |18       |TRUE           |                                                     |Install Python3 Packages (ID: 8)                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install Ruby Gems                           |17       |TRUE           |                                                     |Install Ruby Gems (ID: 7)                          |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install swiftDialog                         |11       |TRUE           |dialog-1.10.4-2602.pkg (ID: 5)                       |Add swiftDialog To Path (ID: 4)                    |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install unxip                               |12       |TRUE           |Install unxip.pkg (ID: 6)                            |                                                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install Xcode                               |14       |TRUE           |                                                     |Install Xcode (ID: 5)                              |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Install Xcode CLI                           |9        |TRUE           |Command Line Tools.pkg (ID: 4)                       |                                                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Setup Jamf Connect                          |2        |FALSE          |Jamf Connect [2.11] (ID: 1)                          |                                                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Setup Xcode, Homebrew, Ruby Gems and Python3|19       |TRUE           |                                                     |Setup Xcode, Homebrew, Ruby Gems and Python (ID: 9)|All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Submit Computer Inventory                   |7        |TRUE           |                                                     |                                                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |
|Test Sound                                  |3        |TRUE           |                                                     |                                                   |Custom       |ladmin‚Äôs MacBook Pro (ID: 1)|N/A                   |N/A                      |N/A                                                      |
|Test Update                                 |15       |TRUE           |                                                     |                                                   |Custom       |N/A                           |N/A                   |N/A                      |N/A                                                      |
|Update Inventory                            |1        |TRUE           |                                                     |                                                   |All Computers|N/A                           |N/A                   |N/A                      |N/A                                                      |



#### Example 3: `JamfPro_PolicyScope_Overview-05122022.csv`
| **Policy Name**              | **Policy ID** | **Policy Enabled?** | **Policy Scope** | **Scope: Computers**           | **Scope: Computer Groups** | **Scope: Excluded Computers** | **Scope: Excluded Computer Groups**                       |
|------------------------------|---------------|---------------------|------------------|--------------------------------|----------------------------|-------------------------------|-----------------------------------------------------------|
| Elevate Account              | 8             | TRUE                | All Computers    | N/A                            | N/A                        | N/A                           | Bound Systems (ID: 5), Software Updates Available (ID: 7) |
| Install Jamf Connect         | 6             | TRUE                | All Computers    | N/A                            | N/A                        | N/A                           | N/A                                                       |
| Install jamfAuth             | 4             | TRUE                | All Computers    | N/A                            | N/A                        | N/A                           | N/A                                                       |
| Install Mooncheese Resources | 5             | TRUE                | All Computers    | N/A                            | N/A                        | N/A                           | N/A                                                       |
| Setup Jamf Connect           | 2             | FALSE               | All Computers    | N/A                            | N/A                        | N/A                           | N/A                                                       |
| Submit Computer Inventory    | 7             | TRUE                | All Computers    | N/A                            | N/A                        | N/A                           | N/A                                                       |
| Test Sound                   | 3             | TRUE                | Custom           | ladmin‚Äôs MacBook Pro (ID: 1) | N/A                        | N/A                           | N/A                                                       |
| Update Inventory             | 1             | TRUE                | All Computers    | N/A                            | N/A                        | N/A                           | N/A                                                       |
