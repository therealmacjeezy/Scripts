## LAPS for macOS

#### This script will randomize the Local Administrator account password. It uses an Extension Attribute to store the randomized password and script parameters to store the following items:
  - API Username
  - API Password
  - Local Administrator Username
  - Local Administrator Password *(Used when the script is ran for the first time)*
  
#### Requirements
  - Extension Attribute
    Used to store the randomized password
  - Policy
    Used to run the script and store the variables
    
## Display Local Admin Password - Self Service Policy

#### Allows the Local Admin Password to be displayed through a Self Service policy.
This script pulls the LAPS for macOS EA for the computer it is being run on and if found, displays it via an AppleScript prompt. There is also an option to copy the password from the AppleScript prompt. 

If the EA doesn't contain the password, another AppleScript prompt will appear stating that it is unable to find the password in jamf and will exit
