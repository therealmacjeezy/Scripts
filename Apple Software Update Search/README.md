# Apple Software Update Search

This repo contains a script *[AppleSoftwareUpdateSearch.sh]* that can be used to install Apple Software Updates on computers that are enrolled in your Jamf Pro Server.

## Version 2.0 Update (Feb 2018)
- Added support for multiple updates to used in the script parameters (current limit is 4, version 1.0 only supported one item at a time)
- Rewrote the way updates are handled. Now any update that is found gets added to an array then is downloaded to the default location (/Library/Updates/). Once the update is finished downloading, it gets added to another array
which is then used to install each update after they all have been downloaded.
- Added a section that will check to see if the update requires a restart. If it's required, it will set the "restartRequired" variable to yes. Once all updates have been downloaded and installed, a if statement checks the restart variable and will trigger a policy setup for an delayed authenticated reboot. **NOTE: A policy will have to be created with a matching trigger in order for this feature to work.** This section currently only looks for the "security" label.

- Added a manual inventory update before the restartRequired check to ensure any installed updates are succesfully reflected in the Jamf Pro Server. *(This was written in to work around an issue where inventory updates would fail if the update name exceeded a certain amount of characters.)* 

### Script Parameters
Parameter 4 - Update Selection **(Required)**

Parameter 5 - Update Selection *(Optional)*

Parameter 6 - Update Selection *(Optional)*

Parameter 7 - Update Selection *(Optional)*

- File List
  1. AppleSoftwareUpdateSearch_v2.sh *[Requires SUDO privileges]*
