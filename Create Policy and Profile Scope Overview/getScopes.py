##########################################
# getScopes.py
# Created: 2022-05-11
# Modified: N/A
# josh.harvey[at]jamf.com
# https://github.com/therealmacjeezy
##########################################

import json, requests, os, jamfAuth
from jamfAuth import *
import pandas as pd

def get_and_count_policies(apiToken, jamfURL):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/policies"
    try:
        r = requests.get(apiURL, headers=headers)
        policyListJSON = r.json()
        return policyListJSON
    except Exception as errorMessage:
        print(f"oops..\n{errorMessage}")

def check_policy_scope(apiToken, jamfURL, policyID):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/policies/id/{policyID}/subset/Scope"
    try:
        r = requests.get(apiURL, headers=headers)
        policyScopeJSON = r.json()
        return policyScopeJSON
    except Exception as errorMessage:
        print(f"oops..\n{errorMessage}")

def start_policy_check(apiToken, jamfURL):
    policyCSVHeaders = ['Policy Name', 'Policy ID', 'Policy Scope', 'Scope: Computers', 'Scope: Computer Groups']
    data = []
    computersScope = ""
    computerGroupsScope = ""
    policyList = get_and_count_policies(apiToken, jamfURL)

    print(f"\n>> Total Policies: {len(policyList['policies'])}")

    print("----------------------------")

    for policy in policyList['policies']:
        computerGroupsScope = "N/A"
        computersScope = "N/A"
        policyID = policy['id']
        policyName = policy['name']
        try:
            getPolicyInfo = check_policy_scope(apiToken, jamfURL, policyID)
            theScope = ''
            print(f"- Policy Name: {policyName} (ID: {policyID})")
            policyScope = getPolicyInfo['policy']['scope']['all_computers']
            if policyScope == False:
                theScope = "Custom"
                computersScope = getPolicyInfo['policy']['scope']['computers']
                computerGroupsScope = getPolicyInfo['policy']['scope']['computer_groups']
                if computersScope:
                    if len(computersScope) == 1:
                        computersScope = computersScope[0]['name']
                    else:
                        computersScope_tmp = ''
                        for i in computersScope:
                            computersScope_tmp += i['name'] + ", "
                        computersScope_tmp = computersScope_tmp.strip(', ')
                        computersScope = computersScope_tmp
                else:
                    computersScope = "N/A"
                if computerGroupsScope:
                    if len(computerGroupsScope) == 1:
                        computerGroupsScope = computerGroupsScope[0]['name']
                    else:
                        computerGroupsScope_tmp = ''
                        for i in computerGroupsScope:
                            computerGroupsScope_tmp += i['name'] + ", "
                        computerGroupsScope_tmp = computerGroupsScope_tmp.strip(', ')
                        computerGroupsScope = computerGroupsScope_tmp 
                else:
                    computerGroupsScope = "N/A"
            else:
                theScope = "All Computers"
            policyData = [f'=HYPERLINK(\"https://{jamfURL}/policies.html?id={policyID}&o=r", \"{policyName}\")', policyID, theScope, computersScope, computerGroupsScope]
            data.append(policyData)
        except Exception as errorMessage:
            print(f"oops..2\n{errorMessage}")
    
    if data:
        df = pd.DataFrame(data)
        try:
            pwd = os.getcwd()
            df.to_csv('JamfPro_PolicyScope_Overview.csv', index=False, header=policyCSVHeaders, encoding='utf-8')
            print(f"\nThe Profile Scope Overview has been saved at:\n\t=> {pwd}/JamfPro_PolicyScope_Overview.csv")
        except Exception as errorMessage:
            print(f"policy error: {errorMessage}")

#### Configuration Profile Section
def get_and_count_config_profiles(apiToken, jamfURL):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/osxconfigurationprofiles"
    try:
        r = requests.get(apiURL, headers=headers)
        profileListJSON = r.json()
        return profileListJSON
    except Exception as errorMessage:
        print(f"oops..\n{errorMessage}")

def check_config_profile_scope(apiToken, jamfURL, profileID):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/osxconfigurationprofiles/id/{profileID}/subset/Scope"
    try:
        r = requests.get(apiURL, headers=headers)
        profileListJSON = r.json()
        return profileListJSON
    except Exception as errorMessage:
        print(f"oops..\n{errorMessage}")      

def start_profile_check(apiToken, jamfURL):
    profileCSVHeaders = ['Configuration Profile Name', 'Configuration Profile ID', 'Configuration Profile Scope', 'Scope: Computers', 'Scope: Computer Groups']
    data = []
    computersScope = ""
    computerGroupsScope = ""

    profileList = get_and_count_config_profiles(apiToken, jamfURL)

    print(f"\n>> Total Configuration Profiles: {len(profileList['os_x_configuration_profiles'])}")

    print("----------------------------")

    for profile in profileList['os_x_configuration_profiles']:
        computerGroupsScope = "N/A"
        computersScope = "N/A"
        profileID = profile['id']
        profileName = profile['name']
        try:
            getPolicyInfo = check_config_profile_scope(apiToken, jamfURL, profileID)
            theScope = ''
            print(f"- Configuration Profile Name: {profileName} (ID: {profileID})")
            policyScope = getPolicyInfo['os_x_configuration_profile']['scope']['all_computers']
            if policyScope == False:
                theScope = "Custom"
                computersScope = getPolicyInfo['os_x_configuration_profile']['scope']['computers']
                computerGroupsScope = getPolicyInfo['os_x_configuration_profile']['scope']['computer_groups']
                if computersScope:
                    if len(computersScope) == 1:
                        computersScope = computersScope[0]['name']
                    else:
                        computersScope_tmp = ''
                        for i in computersScope:
                            computersScope_tmp += i['name'] + ", "
                        computersScope_tmp = computersScope_tmp.strip(', ')
                        computersScope = computersScope_tmp
                else:
                    computersScope = "N/A"
                if computerGroupsScope:
                    if len(computerGroupsScope) == 1:
                        computerGroupsScope = computerGroupsScope[0]['name']
                    else:
                        computerGroupsScope_tmp = ''
                        for i in computerGroupsScope:
                            computerGroupsScope_tmp += i['name'] + ", "
                        computerGroupsScope_tmp = computerGroupsScope_tmp.strip(', ')
                        computerGroupsScope = computerGroupsScope_tmp 
                else:
                    computerGroupsScope = "N/A"
            else:
                theScope = "All Computers"
            profileData = [f'=HYPERLINK(\"https://{jamfURL}/OSXConfigurationProfiles.html?id={profileID}&o=r", \"{profileName}\")', profileID, theScope, computersScope, computerGroupsScope]
            data.append(profileData)
        except Exception as errorMessage:
            print(f"oops..\n{errorMessage}")

    if data:
        df = pd.DataFrame(data)
        try:
            pwd = os.getcwd()   
            df.to_csv('JamfPro_ConfigurationProfile_ScopeOverview.csv', index=False, header=profileCSVHeaders, encoding='utf-8')
            print(f"\nThe Configuration Profile Scope Overview has been saved at:\n\t=> {pwd}/JamfPro_ConfigurationProfile_ScopeOverview.csv")
        except Exception as errorMessage:
            print(f"policy error: {errorMessage}")

if __name__ == '__main__':
    ### Config Section
    jamfAuthPath = os.path.dirname(jamfAuth.__file__)
    jamfAuthConfig = f"{jamfAuthPath}/support/.jamfauth.json"

    f = open(jamfAuthConfig)

    jamfAuthJSON = json.load(f)

    jamfURL = jamfAuthJSON['jamfHostName']

    ### Get API Token with jamfAuth
    apiToken = startAuth()

    print(f"\n==== Jamf Pro Policies ====")
    start_policy_check(apiToken, jamfURL)

    print(f"\n==== Jamf Pro Configuration Profiles ====")
    start_profile_check(apiToken, jamfURL)

        


