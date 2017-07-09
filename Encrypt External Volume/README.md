# Encrypt External Volume

- File List
  1. EncryptExternalVolume.sh
  2. EA_EncryptExternalVolume.sh

This repo contains a script *[EncryptExternalVolume.sh]* that can be used to encrypt an external volume. The script will make any changes
that are needed to the partition map and then prompt the user to create a password for the external volume *(Current requirements for the
password is 7 characters or longer, this can be changed and uses AppleScript to capture the input)*. The script will also allow the user
to rename the external volume, erase it and re-encrypt it again, or change the password *(NOTE: The user must know the current volume
password in order for this function to work)*.

The script also has a section that will encode the passcode and upload it to the JSS to be used in the future if the user forgets their
password or access to the external volume is needed. **Note: This feature requires an Extension Attribute to be created in the JSS in order
for the password to be accessible inside the JSS**
