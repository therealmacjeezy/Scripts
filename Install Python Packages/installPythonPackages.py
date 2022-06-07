#!/usr/bin/env python3

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
#   Github: https://github.com/therealmacjeezy
#   Last Modified: 06/07/2022
#   Version: 0.1
#
#   Description: This script will update pip3 then bulk install pip3 packages using 
#   Jamf Pro Script Parameters
#
####################################################################################################

import logging, sys, subprocess

logging.basicConfig(
    ## Logging Levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
    ## Usage: logging.LEVEL('message')
    filename = '/private/var/log/installPythonPackages.log',
    level = logging.DEBUG,
    format = '>>[%(filename)s] :: %(levelname)s [%(asctime)s] :: %(message)s'
)

## Function to install the python3 package
def install(package):
    try:
        __import__(package)
        logging.info(f'{package} is already installed! Lets make sure it is up to date!')
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "-q", "-q", "install", "--upgrade", package])
            logging.info(f'{package} is up to date.')
        except Exception as errorMessage:
            logging.error(errorMessage)
    except:
        logging.info(f'Looks like {package} isnt installed..installing now')
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "-q", "-q", "install", package])
            logging.info(f'Successfully installed {package}!')
        except Exception as errorMessage:
            logging.error(errorMessage)

## Check to see if Script Parameter #4 contains the list of python3 packages to install, if not exit.
if sys.argv[4]:
    logging.info('Found python3 packages to install.')
    packages = sys.argv[4]
    packages = packages.split(',')
else:
    logging.error('Missing list of python3 packages to install. Check Script Parameter #4.')
    sys.exit(1)

## Check to see if pip3 is up to date and if not, install the latest version
try:
    logging.info('Making sure pip3 is up to date.')
    subprocess.check_call([sys.executable, "-m", "pip", "-q", "-q", "install", "--upgrade", "pip"])
    logging.info('pip3 update check complete.')
except Exception as errorMessage:
    logging.error(errorMessage)

## Start the package installs
for p in packages:
    p = p.strip()
    logging.info(f'Checking to see if {p} is installed..')
    install(p)

