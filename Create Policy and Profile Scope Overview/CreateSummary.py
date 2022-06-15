##########################################
# CreateSummary.py
# Created: 2022-05-11
# Modified: 2022-06-15
# josh.harvey[at]jamf.com
# https://github.com/therealmacjeezy
##########################################

import json, requests, os, jamfAuth
from jamfAuth import *
from datetime import datetime
import pandas as pd

### Policy Section
def get_and_count_policies(apiToken, jamfURL):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/policies"
    try:
        r = requests.get(apiURL, headers=headers)
        policyListJSON = r.json()
        return policyListJSON
    except Exception as errorMessage:
        print(f"get_and_count_policies [error]:\nmsg: {errorMessage}")

def check_policy_packages(apiToken, jamfURL, policyID):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/policies/id/{policyID}/subset/Packages"
    try:
        r = requests.get(apiURL, headers=headers)
        policyPackagesJSON = r.json()
        return policyPackagesJSON
    except Exception as errorMessage:
        print(f"check_policy_packages [error]:\nmsg: {errorMessage}")

def check_policy_scripts(apiToken, jamfURL, policyID):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/policies/id/{policyID}/subset/Scripts"
    try:
        r = requests.get(apiURL, headers=headers)
        policyScriptsJSON = r.json()
        return policyScriptsJSON
    except Exception as errorMessage:
        print(f"check_policy_scripts [error]:\nmsg: {errorMessage}")
        
def check_policy_scope(apiToken, jamfURL, policyID):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/policies/id/{policyID}/subset/Scope"
    try:
        r = requests.get(apiURL, headers=headers)
        policyScopeJSON = r.json()
        return policyScopeJSON
    except Exception as errorMessage:
        print(f"check_policy_scope [error]:\nmsg: {errorMessage}")

def check_policy_status(apiToken, jamfURL, policyID):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/policies/id/{policyID}/subset/General"
    try:
        r = requests.get(apiURL, headers=headers)
        policyStatusJSON = r.json()
        return policyStatusJSON
    except Exception as errorMessage:
        print(f"check_policy_status [error]:\nmsg: {errorMessage}")

def start_policy_check(apiToken, jamfURL):
    policyCSVHeaders = ['Policy Name', 'Policy ID', 'Policy Enabled?', 'Packages', 'Scripts', 'Policy Scope', 'Scope: Computers', 'Scope: Computer Groups', 'Scope: Excluded Computers', 'Scope: Excluded Computer Groups']
    data = []
    computersScope = ""
    computerGroupsScope = ""
    excludedComputers = ""
    excludedComputerGroups = ""
    policyList = get_and_count_policies(apiToken, jamfURL)

    print(f"\n>> Total Policies: {len(policyList['policies'])}")

    print("----------------------------")

    for policy in policyList['policies']:
        computerGroupsScope = "N/A"
        computersScope = "N/A"
        excludedComputers = "N/A"
        excludedComputerGroups = "N/A"
        policyID = policy['id']
        policyName = policy['name']
        try:
            getPolicyScopeInfo = check_policy_scope(apiToken, jamfURL, policyID)
            getPolicyStatusInfo = check_policy_status(apiToken, jamfURL, policyID)
            getPolicyPackageInfo = check_policy_packages(apiToken, jamfURL, policyID)
            getPolicyScriptInfo = check_policy_scripts(apiToken, jamfURL, policyID)
            theScope = ''
            print(f"{policyName} (ID: {policyID})")
            policyScope = getPolicyScopeInfo['policy']['scope']['all_computers']
            
            # policyExclusions = getPolicyScopeInfo['policy']['scope']['exclusions']

            policyComputersExclusions = getPolicyScopeInfo['policy']['scope']['exclusions']['computers']
            policyComputerGroupsExclusions = getPolicyScopeInfo['policy']['scope']['exclusions']['computer_groups']
            
            policyPackageInfo = getPolicyPackageInfo['policy']['package_configuration']['packages']
            policyScriptInfo = getPolicyScriptInfo['policy']['scripts']

            if policyPackageInfo:
                # print(policyPackageInfo)
                if len(policyPackageInfo) == 1:
                    policyPackages = f"{policyPackageInfo[0]['name']} (ID: {policyPackageInfo[0]['id']})"
                else:
                    policyPackages_tmp = ''
                    for i in policyPackageInfo:
                        # print(f"i: {i}")
                        policyPackages_tmp += f"{i['name']} (ID: {i['id']})" + ", "
                    policyPackages_tmp = policyPackages_tmp.strip(', ')
                    policyPackages = policyPackages_tmp
                print(f"\tPackages: {policyPackages}")
            else:
                policyPackages = ''

            if policyScriptInfo:
                if len(policyScriptInfo) == 1:
                    policyScripts = f"{policyScriptInfo[0]['name']} (ID: {policyScriptInfo[0]['id']})"
                else:
                    policyScripts_tmp = ''
                    for i in policyScriptInfo:
                        # print(f"i: {i}")
                        policyScripts_tmp += f"{i['name']} (ID: {i['id']})" + ", "
                    policyScripts_tmp = policyScripts_tmp.strip(', ')
                    policyScripts = policyScripts_tmp
                print(f"\tScripts: {policyScripts}")
            else:
                policyScripts = ''

            if policyComputersExclusions:
                if len(policyComputersExclusions) == 1:
                    excludedComputers = f"{policyComputersExclusions[0]['name']} (ID: {policyComputersExclusions[0]['id']})"
                else:
                    excludedComputers_tmp = ''
                    for i in policyComputersExclusions:
                        excludedComputers_tmp += f"{i['name']} (ID: {i['id']})" + ", "
                    excludedComputers_tmp = excludedComputers_tmp.strip(', ')
                    excludedComputers = excludedComputers_tmp
            else:
                excludedComputers = "N/A"

            if policyComputerGroupsExclusions:
                if len(policyComputerGroupsExclusions) == 1:
                    excludedComputerGroups = f"{policyComputerGroupsExclusions[0]['name']} (ID: {policyComputerGroupsExclusions[0]['id']})"
                else:
                    excludedComputerGroups_tmp = ''
                    for i in policyComputerGroupsExclusions:
                        excludedComputerGroups_tmp += f"{i['name']} (ID: {i['id']})" + ", "
                    excludedComputerGroups_tmp = excludedComputerGroups_tmp.strip(', ')
                    excludedComputerGroups = excludedComputerGroups_tmp
            else:
                excludedComputerGroups = "N/A"
    
            
            policyStatus = getPolicyStatusInfo['policy']['general']['enabled']
            if policyScope == False:
                theScope = "Custom"
                computersScope = getPolicyScopeInfo['policy']['scope']['computers']
                computerGroupsScope = getPolicyScopeInfo['policy']['scope']['computer_groups']
                if computersScope:
                    if len(computersScope) == 1:
                        computersScope = f"{computersScope[0]['name']} (ID: {computersScope[0]['id']})"
                    else:
                        computersScope_tmp = ''
                        for i in computersScope:
                            computersScope_tmp += f"{i['name']} (ID: {i['id']})" + ", "
                        computersScope_tmp = computersScope_tmp.strip(', ')
                        computersScope = computersScope_tmp
                else:
                    computersScope = "N/A"
                if computerGroupsScope:
                    if len(computerGroupsScope) == 1:
                        computerGroupsScope = f"{computerGroupsScope[0]['name']} (ID: {computerGroupsScope[0]['id']})"
                    else:
                        computerGroupsScope_tmp = ''
                        for i in computerGroupsScope:
                            computerGroupsScope_tmp += f"{i['name']} (ID: {i['id']})" + ", "
                        computerGroupsScope_tmp = computerGroupsScope_tmp.strip(', ')
                        computerGroupsScope = computerGroupsScope_tmp 
                else:
                    computerGroupsScope = "N/A"
            else:
                theScope = "All Computers"
            policyData = [f'=HYPERLINK(\"https://{jamfURL}/policies.html?id={policyID}&o=r", \"{policyName}\")', policyID, policyStatus, policyPackages, policyScripts, theScope, computersScope, computerGroupsScope, excludedComputers, excludedComputerGroups]
            data.append(policyData)
        except Exception as errorMessage:
            print(f"start_policy_check [error]:\nmsg: {errorMessage}")
    
    if data:
        df = pd.DataFrame(data)
        try:
            pwd = os.getcwd()
            today = datetime.now()
            date = today.strftime("%m%d%Y")
            df.to_csv(f'JamfPro_PolicyScope_Overview-{date}.csv', index=False, header=policyCSVHeaders, encoding='utf-8')
            print(f"\nThe Profile Scope Overview has been saved at:\n\t=> {pwd}/JamfPro_PolicyScope_Overview-{date}.csv")
        except Exception as errorMessage:
            print(f"saving data to csv [error]:\nmsg: {errorMessage}")

#### Configuration Profile Section
def get_and_count_config_profiles(apiToken, jamfURL):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/osxconfigurationprofiles"
    try:
        r = requests.get(apiURL, headers=headers)
        profileListJSON = r.json()
        return profileListJSON
    except Exception as errorMessage:
        print(f"get_and_count_config_profiles [error]:\nmsg:{errorMessage}")

def check_config_profile_scope(apiToken, jamfURL, profileID):
    headers = {'accept': 'application/json', 'Authorization': f'Bearer {apiToken}'}
    apiURL = f"https://{jamfURL}/JSSResource/osxconfigurationprofiles/id/{profileID}/subset/Scope"
    try:
        r = requests.get(apiURL, headers=headers)
        profileListJSON = r.json()
        return profileListJSON
    except Exception as errorMessage:
        print(f"check_config_profile_scope [error]:\nmsg:{errorMessage}")      

def start_profile_check(apiToken, jamfURL):
    profileCSVHeaders = ['Configuration Profile Name', 'Configuration Profile ID', 'Configuration Profile Scope', 'Scope: Computers', 'Scope: Computer Groups', 'Scope: Excluded Computers', 'Scope: Excluded Computer Groups']
    data = []
    computersScope = ""
    computerGroupsScope = ""
    excludedComputers = ""
    excludedComputerGroups = ""

    profileList = get_and_count_config_profiles(apiToken, jamfURL)

    print(f"\n>> Total Configuration Profiles: {len(profileList['os_x_configuration_profiles'])}")

    print("----------------------------")

    for profile in profileList['os_x_configuration_profiles']:
        computerGroupsScope = "N/A"
        computersScope = "N/A"
        excludedComputers = "N/A"
        excludedComputerGroups = "N/A"
        profileID = profile['id']
        profileName = profile['name']
        try:
            getProfileScopeInfo = check_config_profile_scope(apiToken, jamfURL, profileID)
            theScope = ''
            print(f"{profileName} (ID: {profileID})")
            profileScope = getProfileScopeInfo['os_x_configuration_profile']['scope']['all_computers']

            # profileExclusions = getProfileScopeInfo['policy']['scope']['exclusions']

            profileComputersExclusions = getProfileScopeInfo['os_x_configuration_profile']['scope']['exclusions']['computers']
            profileComputerGroupsExclusions = getProfileScopeInfo['os_x_configuration_profile']['scope']['exclusions']['computer_groups']

            if profileComputersExclusions:
                # print(f"profileComputersExclusions: {profileComputersExclusions}")
                if len(profileComputersExclusions) == 1:
                    excludedComputers = f"{profileComputersExclusions[0]['name']} (ID: {profileComputersExclusions[0]['id']})"
                else:
                    excludedComputers_tmp = ''
                    for i in profileComputersExclusions:
                        excludedComputers_tmp += f"{i['name']} (ID: {profileComputersExclusions[0]['id']})" + ", "
                    excludedComputers_tmp = excludedComputers_tmp.strip(', ')
                    excludedComputers = excludedComputers_tmp
            else:
                excludedComputers = "N/A"

            if profileComputerGroupsExclusions:
                # print(f"profileComputerGroupsExclusions: {profileComputerGroupsExclusions}")
                if len(profileComputerGroupsExclusions) == 1:
                    # print(f"only one exclusion")
                    excludedComputerGroups = f"{profileComputerGroupsExclusions[0]['name']} (ID: {profileComputerGroupsExclusions[0]['id']})"
                else:
                    excludedComputerGroups_tmp = ''
                    for i in profileComputerGroupsExclusions:
                        # print(f"excludedComputerGroups_tmp: {excludedComputerGroups_tmp}")
                        excludedComputerGroups_tmp += f"{i['name']} (ID: {profileComputerGroupsExclusions[0]['id']})" + ", "
                    excludedComputerGroups_tmp = excludedComputerGroups_tmp.strip(', ')
                    excludedComputerGroups = excludedComputerGroups_tmp
            else:
                # print(f"no exclusions")
                excludedComputerGroups = "N/A"

            if profileScope == False:
                theScope = "Custom"
                computersScope = getProfileScopeInfo['os_x_configuration_profile']['scope']['computers']
                computerGroupsScope = getProfileScopeInfo['os_x_configuration_profile']['scope']['computer_groups']
                if computersScope:
                    if len(computersScope) == 1:
                        computersScope = f"{computersScope[0]['name']} (ID: {computersScope[0]['id']})"
                    else:
                        computersScope_tmp = ''
                        for i in computersScope:
                            computersScope_tmp += f"{i['name']} (ID: {i['id']})" + ", "
                        computersScope_tmp = computersScope_tmp.strip(', ')
                        computersScope = computersScope_tmp
                else:
                    computersScope = "N/A"
                if computerGroupsScope:
                    if len(computerGroupsScope) == 1:
                        computerGroupsScope = f"{computerGroupsScope[0]['name']} (ID: {computerGroupsScope[0]['id']})"
                    else:
                        computerGroupsScope_tmp = ''
                        for i in computerGroupsScope:
                            computerGroupsScope_tmp += f"{i['name']} (ID: {i['id']})" + ", "
                        computerGroupsScope_tmp = computerGroupsScope_tmp.strip(', ')
                        computerGroupsScope = computerGroupsScope_tmp 
                else:
                    computerGroupsScope = "N/A"
            else:
                theScope = "All Computers"
            profileData = [f'=HYPERLINK(\"https://{jamfURL}/OSXConfigurationProfiles.html?id={profileID}&o=r", \"{profileName}\")', profileID, theScope, computersScope, computerGroupsScope, excludedComputers, excludedComputerGroups]
            data.append(profileData)
        except Exception as errorMessage:
            print(f"start_profile_check [error]:\nmsg:{errorMessage}")

    if data:
        df = pd.DataFrame(data)
        try:
            pwd = os.getcwd()
            today = datetime.now()
            date = today.strftime("%m%d%Y")   
            df.to_csv(f'JamfPro_ConfigurationProfile_ScopeOverview-{date}.csv', index=False, header=profileCSVHeaders, encoding='utf-8')
            print(f"\nThe Configuration Profile Scope Overview has been saved at:\n\t=> {pwd}/JamfPro_ConfigurationProfile_ScopeOverview-{date}.csv")
        except Exception as errorMessage:
            print(f"saving data to csv [error]:\nmsg: {errorMessage}")

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

        


