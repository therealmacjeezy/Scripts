# Disable Smart Card Pairing

- File List
  1. DisableSmartCardPairing.sh
  2. EA_SmartCardPairing.sh

This repo contains a script *[DisableSmartCardPairing.sh]* that can be used to disable the UI for Smart Card Pairing. This script will pull the current logged in user,
since the sc_auth commands cannot be ran as root. There is also an Extension Attribute script *[EA_SmartCardPairing.sh]* that can be uploaded or created in your JSS to pull the Smart Card Pairing Status and use it for
Smart Groups or Computer Searches.
