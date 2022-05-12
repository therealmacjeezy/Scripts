# Create Policy and Profile Scope Overview

> This script uses [jamfAuth](https://github.com/therealmacjeezy/JamfAuth) to perform the API authentication. Looking to setup **jamfAuth**? [Click here..](https://github.com/therealmacjeezy/JamfAuth#installation)

Looking for an easy way to get the scopes for all of your Policies and Configuration Profiles? Look no further.. The `CreateScopeSummary.py` does just that. 

This script reaches out to your Jamf Pro Server and gets a list of the Policies and Configuration Profiles you are using within your Jamf Pro Server. It then loops through each of the Policies and Configuration Profiles to get the following information:

 - Policy / Configuration Profile Name
    - When this gets saved to the `.csv`, a hyperlink gets created to take you to that policy within Jamf Pro when clicked on.
 - Policy / Configuration Profile ID
 - Policy Status *(Is it enabled?)*
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

>> Total Policies: 8
----------------------------
Elevate Account (ID: 8)
Install Jamf Connect (ID: 6)
Install jamfAuth (ID: 4)
Install Mooncheese Resources (ID: 5)
Setup Jamf Connect (ID: 2)
Submit Computer Inventory (ID: 7)
Test Sound (ID: 3)
Update Inventory (ID: 1)

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


#### Example 2: `JamfPro_ConfigurationProfile_ScopeOverview-05122022.csv`
| **Configuration Profile Name**            | **Configuration Profile ID** | **Configuration Profile Scope** | **Scope: Computers** | **Scope: Computer Groups**                              | **Scope: Excluded Computers**  | **Scope: Excluded Computer Groups** |
|-------------------------------------------|------------------------------|---------------------------------|----------------------|---------------------------------------------------------|--------------------------------|-------------------------------------|
| Default Plan - Jamf Protect Configuration | 1                            | All Computers                   | N/A                  | N/A                                                     | N/A                            | N/A                                 |
| Jamf Connect - Login                      | 3                            | All Computers                   | N/A                  | N/A                                                     | N/A                            | Remove Jamf Connect (ID: 3)         |
| Jamf Connect - Menu                       | 4                            | All Computers                   | N/A                  | N/A                                                     | N/A                            | Remove Jamf Connect (ID: 3)         |
| Jamf Connect License                      | 5                            | All Computers                   | N/A                  | N/A                                                     | N/A                            | Remove Jamf Connect (ID: 3)         |
| Loading... Network Profile                | 8                            | All Computers                   | N/A                  | N/A                                                     | N/A                            | N/A                                 |
| Jamf Connect Login Window (Self Service)  | 10                           | Custom                          | N/A                  | Remove Jamf Connect (ID: 3)                             | N/A                            | N/A                                 |
| Jamf Connect Menu (Self Service)          | 11                           | Custom                          | N/A                  | macOS Update Ready (ID: 4), Remove Jamf Connect (ID: 3) | N/A                            | N/A                                 |
| Jamf Connect License (Self Service)       | 12                           | Custom                          | N/A                  | Remove Jamf Connect (ID: 3)                             | N/A                            | N/A                                 |
| Disable Displays Prefrence Pane           | 13                           | All Computers                   | N/A                  | N/A                                                     | N/A                            | N/A                                 |
| Jamf Connect - Menu Keychain Test         | 14                           | All Computers                   | N/A                  | N/A                                                     | N/A                            | N/A                                 |
| Keychain Test                             | 15                           | All Computers                   | N/A                  | N/A                                                     | ladmin‚Äôs MacBook Pro (ID: 1) | Bound Systems (ID: 5)               |


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
