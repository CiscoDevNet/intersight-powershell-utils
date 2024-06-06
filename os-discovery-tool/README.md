## **ODT (OS Discovery Toolset) scripts**

## Introduction
#### *This toolset enables Cisco Intersight account holders to push server OS inventory to Intersight in order to evaluate the server's HCL validity as it pertains to http://ucshcltool.cisco.com*
---
## File list
```Powershell
 PS $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool> dir

    Directory: $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool


	Mode                LastWriteTime         Length Name
	----                -------------         ------ ----
	-a---           8/8/2021  2:02 PM            195 discovery_config_esx.json
	-a---           8/8/2021  2:02 PM            141 discovery_config_windows.json
	-a---           8/8/2021  2:02 PM           2147 generateSecureCredentials.ps1
	-a---           8/8/2021  7:02 PM          23664 getEsxOsInvToIntersight.ps1
	-a---           8/8/2021  6:40 PM          26872 getWindowsOsInvToIntersight.ps1
	-a---           8/8/2021  8:22 PM          19549 README.md

```
---
## Setup Steps
---  
  ### I. Ensure prerequisites
  1. This toolset requires that the **server OS is managed** i.e.,  part of an Active Directory domain in case of Windows or managed by a vCenter in case of ESX.
  2. Ensure that Firewall rules on the target windows servers allow incoming traffic for CIM over RPC.
  3. **Claim your servers.** Ensure that the server is claimed in Cisco Intersight. This toolset validates only the claimed servers by their serial numbers and their connectivity to Intersight.
  4. **Generate private and public API keys** with your user account from the Cisco Intersight GUI and use them as described in the next section.
  ---
  ### II. Install dependent components  
  1. A Windows machine (Virtual/Physical) with access to servers on your on-prem network. Check that **Windows Powershell 7.3+** is installed.

  ~~~
  NOTE : The OS Discovery tool requires the latest Intersight.PowerShell module. If the module is not up-to-date or not installed, the OS Discovery tool will prompt you to install it.
  ~~~
  2. **Intersight Powershell Module**: To install Intersight.Powershell module on **Control Node**, use any one of the following:
     - To install form PSGallery
        ```powershell
           Install-Module -Name Intersight.PowerShell
        ```
     - To install from the [GitHub](https://github.com/CiscoDevNet/intersight-powershell), clone the repository and run the following command to build and install the PowerShell module locally:
        ```powershell
           build.ps1
           Import-Module -Name '.\Intersight.PowerShell'
        ```
	 - To update the existing Intersight.PowerShell module with the latest version available on PSGallery.
	   ```powershell
		  Update-Module -Name "Intersight.PowerShell"
	   ```

  3. For VMware vSphere, install the **vSphere PowerCLI package** from:    
     https://my.vmware.com/web/vmware/details?downloadGroup=PCLI650R1&productId=614

  4. For Microsoft Active Directory integration, install the **RSAT package (Remote Server Administration Tools)** as follows:
     https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/deploy/install-active-directory-domain-services--level-100-#BKMK_GUI
  ---
  ### III. Setup configurations
  1. Edit discovery_config_esx.json to include details as described below. Refer to the comments for additional help. NOTE: Comments are not supported in JSON; please don't leave comments in your configuration files.
  ```Powershell
   PS $env:USERPROFILE\Downloads\intersight-powershell\os-discovery-tool> cat ..\..\..\Documents\discovery_config_esx.json
	{
		"config": {
				# vCenter hostname or IP address
				"vCenter": "myvcenter.example.com",
				# location of PSCredential file containing vCenter credentials. 
				# Notice that this is a relative path from the user's profile
				"vCenter_creds_file": "Documents\\vCenter-creds.xml",**
				# Location filter for vCenter location in the hierarchy
				"location_filter": "my_location",
				# Intersight URL for API calls
				"intersight_url": "https://intersight.com",
				# Public API key for intersight API
				"intersight_api_key": "5b4cff386d3376393452476f/5b4cfead6d33763934524747/5b4d0c156d33763934525341",
				# Location of intersight Secret API key file on local filesystem. 
				# Notice that this is a relative path from the user's profile.
				"intersight_secret_file": "Documents\\secret.pem",
				# Absolute path of the directory to save the log file.***
				"logfile_path": "C:\\ProgramData\\Cisco\\SystemDiscovery"
		}
	}

   PS $env:USERPROFILE\Downloads\intersight-powershell\os-discovery-tool> cat ..\..\Documents\discovery_config_windows.json
	{
		"config": {
				# Filter for AD lookup of hosts
				# You could filter on the following attributes (case-insensitive):
				# DistinguishedName : CN=WINCLOUD-1,CN=Computers,DC=lab,DC=savbu,DC=local
				# DNSHostName       : wincloud-1.lab.savbu.local
				# Enabled           : True
				# Name              : WINCLOUD-1
				# ObjectClass       : computer
				# ObjectGUID        : 621a3597-fe63-4a2d-9c24-df4e7414b118
				# SamAccountName    : WINCLOUD-1$
				# SID               : S-1-5-21-4108252877-544740122-1358242708-1137
				"filter": "name -like \"*wincloud*\"",
				# Intersight URL for API calls
				"intersight_url": "https://intersight.com",
				# Public API key for intersight API
				"intersight_api_key": "5b4cff386d3376393452476f/5b4cfead6d33763934524747/5b4d0c156d33763934525341",
				# Location of intersight Secret API key file on local filesystem. 
				# Notice that this is a relative path from the user's profile.
				"intersight_secret_file": "Documents\\secret.pem",
				# Absolute path of the directory to save the log file.***
				"logfile_path": "C:\\ProgramData\\Cisco\\SystemDiscovery\\"
		}
	}
   ```
   NOTES: 
     **  The ```vCenter-creds.xml``` is created under the Documents folder, where the Intersight Private Key File(.pem) is located.
     *** The location of the ```logfile_path``` must be an absolute path and not a file name.  

  ---
  ### IV. Run toolset
  #### i. generateSecureCredentials.ps1
  ```Powershell
   PS $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool> get-help .\generateSecureCredentials.ps1

	NAME
		$env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\generateSecureCredentials.ps1

	SYNOPSIS
		ODT stands for OS Discovery Toolset
		This is a simple ODT script to encrypt Cisco Intersight and VMware vCenter credentials powered by Windows Powershell 4.0+


	SYNTAX
		$env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\generateSecureCredentials.ps1 [-platform] <String> [<CommonParameters>]


	DESCRIPTION
		This tool needs the following inputs:

		For the ESX platform:
		1. vCenter Credentials
		2. Location of encrypted Cisco Intersight Secret key

		For the Windows platform:
		1. Powershell Session Credentials for Active Directory Lookups
		2. Location of encrypted Cisco Intersight Secret key


	RELATED LINKS
		https://github.com/CiscoDevNet/intersight-powershell-utils

	REMARKS
		To see the examples, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\generateSecureCredentials.ps1 -examples".
		For more information, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\generateSecureCredentials.ps1 -detailed".
		For technical information, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\generateSecureCredentials.ps1 -full".
		For online help, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\generateSecureCredentials.ps1 -online"
  ```
  
  #### Example run of generateSecureCredentials
  1. For the ESX Platform: After successfully running "generateSecureCredentials.ps1", an encrypted credential file named "vCenter-creds.xml" is generated in the same directory as the Intersight Private Key File(.pem).
  ```Powershell
   PS $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool> .\generateSecureCredentials.ps1 -platform esx
	Encrypt Cisco Intersight Private Credentials in Windows Powershell 4.0+
	===========================================================================
	Enter the Full Path of the Intersight Private Key File (.pem): C:\full\path\to\secret.pem
	Please enter vCenter Credentials:

	cmdlet Get-Credential at command pipeline position 1
	Supply values for the following parameters:
	Credential
	Credentials generated and encrypted!
  ```
  
  2. For Windows Platform
  ```Powershell
   PS $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool> .\generateSecureCredentials.ps1 -platform windows
	Encrypt Cisco Intersight Private Credentials in Windows Powershell 4.0+
	===========================================================================
	Enter the Full Path of the Cisco Intersight Private Key File (.pem): C:\full\path\to\secret.pem
	[Warning]: Your Windows Session credentials will be used for Active Directory lookups, make sure you have atleast read-only access.
	Credentials generated and encrypted!
	____________________________________
  ```
  #### ii. getEsxOsInvToIntersight.ps1
  ```Powershell		
   PS $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool> get-help .\getEsxOsInvToIntersight.ps1

	NAME   
		$env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getEsxOsInvToIntersight.ps1

	SYNOPSIS
		ODT stands for OS Discovery Toolset.
		This is a simple ODT script to Discover ESX OS Inventory and TAG Servers managed by Cisco Intersight.
		It can be run via the Windows Task Scheduler to ensure regular refresh and is powered by Windows Powershell 4.0+


	SYNTAX
		$env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getEsxOsInvToIntersight.ps1 [-configfile] <Path_to_discovery_config_esx.json> [<CommonParameters>] 


	DESCRIPTION
		This tool needs to have generateSecureCredentials.ps1 to be run beforehand.

		You need the following files generated:
		1. Path to a config file (for eg., discovery_config_esx.json)
		2. Encrypted vCenter Credentials in a PSCredential XML file
		3. Encrypted Intersight Secret Key file


	RELATED LINKS
		https://github.com/CiscoDevNet/intersight-powershell-utils

	REMARKS
		To see the examples, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getEsxOsInvToIntersight.ps1 -examples".
		For more information, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getEsxOsInvToIntersight.ps1 -detailed".
		For technical information, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getEsxOsInvToIntersight.ps1 -full".
		For online help, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getEsxOsInvToIntersight.ps1 -online"
  ```
  NOTE: You can also use ```get-help .\getEsxOsInvToIntersight.ps1 -Full``` for a list of Common Parameters.
  
  #### Example run of getEsxOsInvToIntersight
  ```Powershell
	PS $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool> .\getEsxOsInvToIntersight.ps1 -configfile $env:USERPROFILE\Documents\discovery_config_esx.json
			  Welcome to VMware PowerCLI!

	Log in to a vCenter Server or ESX host:              Connect-VIServer
	To find out what commands are available, type:       Get-VICommand
	To show searchable help for all PowerCLI commands:   Get-PowerCLIHelp
	Once you have connected, display all virtual machines: Get-VM
	If you need more help, visit the PowerCLI community: Get-PowerCLICommunity

		   Copyright (C) VMware, Inc. All rights reserved.


	[INFO]: ODT script for OS Discovery started...
	[INFO]: Configurations in {$env:USERPROFILE\Documents\discovery_config_esx_qa.json}, validation succeeded!
	Transcript started, output file is C:\ProgramData\Cisco\SystemDiscovery\discovery_131768894634013608.out
	WARNING: There were one or more problems with the server certificate for the server myvcenter.example.com:443:

	* The X509 chain could not be built up to the root certificate.

	Certificate: [Subject]
	  C=US, CN=myvcenter.example.com

	[Issuer]
	  O=MYVCENTER, C=US, DC=local, DC=vsphere, CN=CA

	[Serial Number]
	  00DA7416FA1A22644E

	[Not Before]
	  2/2/2016 6:05:02 PM

	[Not After]
	  1/27/2026 6:04:41 PM

	[Thumbprint]
	  3F999517C097C76607C6CB382F8E4A778C3087C3



	The server certificate is not valid.

	WARNING: THE DEFAULT BEHAVIOR UPON INVALID SERVER CERTIFICATE WILL CHANGE IN A FUTURE RELEASE. To ensure scripts are not affected by the change, use Set-PowerCLIConfiguration to set a value for the
	InvalidCertificateAction option.


	Name                           Port  User
	----                           ----  ----
	myvcenter.example.com 443   VSPHERE.LOCAL\Administrator
	Connecting to Cisco Intersight URL with API Keys:  https://intersight.com/api/v1
	------------------------------------------------------------------------------------
	Processing {my-esx-1.example.com} :
	Intersight API GET succeeded for host FCH16277YXW
	GetOSDetails: my-esx-1.example.com
	GetDriverDetails: my-esx-1.example.com
	Server MOID:  5b56cd3a366c6b3976923be4
	Computing changes...
	Changes detected for Server: [FCH16277YXW], PATCHing to Intersight...
	Processing {my-esx-1.example.com} : FCH16277YXW complete.
	====================================================================================
	------------------------------------------------------------------------------------
	Processing {my-esx-2.example.com} : FCH16277YXW
	Intersight API GET succeeded for host FCH17247F8E
	GetOSDetails: my-esx-2.example.com
	GetDriverDetails: my-esx-2.example.com
	Server MOID:  5b56cd3a366c6b3976923be7
	Computing changes...
	Changes detected for Server: [FCH16277YXW], PATCHing to Intersight...
	Processing {my-esx-2.example.com} : FCH17247F8E complete.
	====================================================================================
	------------------------------------------------------------------------------------
	Processing {my-esx-3.example.com} : FCH17247F8E
	Intersight API GET succeeded for host FLM2042P049
	GetOSDetails: my-esx-3.example.com
	GetDriverDetails: my-esx-3.example.com
	Server MOID:  5b56cd3a366c6b3976923bea
	Computing changes...
	No changes detected for Server: [FLM2042P049], skipping...
	Processing {my-esx-3.example.com} : FLM2042P049 complete.
	====================================================================================
	Transcript stopped, output file is C:\ProgramData\Cisco\SystemDiscovery\discovery_131768894634013608.out

  ```
 
  #### iii. getWindowsOsInvToIntersight.ps1
  ```Powershell
   PS $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool> get-help .\getWindowsOsInvToIntersight.ps1

	NAME
		$env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getWindowsOsInvToIntersight.ps1

	SYNOPSIS
		ODT stands for OS Discovery Toolset.
		This is a simple ODT script to Discover Windows OS Inventory and TAG Servers managed by Cisco Intersight (TM).
		It can be run via the Windows Task Scheduler to ensure regular refresh and is powered by Powershell (TM) 4.0+


	SYNTAX
		$env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getWindowsOsInvToIntersight.ps1 [-configfile] <Path_to_discovery_config_windows.json> [<CommonParameters>]


	DESCRIPTION
		This tool needs to have generateSecureCredentials.ps1 to be run beforehand.
		It uses Windows (Powershell) session credentials for Active Directory Lookups.

		You need the following files generated:
		1. Encrypted Intersight Secret Key file

		It also needs the path to a config file (discovery_config_windows.json).


	RELATED LINKS
		https://github.com/CiscoDevNet/intersight-powershell-utils

	REMARKS
		To see the examples, type: "get-help$env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getWindowsOsInvToIntersight.ps1 -examples".
		For more information, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getWindowsOsInvToIntersight.ps1 -detailed".
		For technical information, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getWindowsOsInvToIntersight.ps1 -full".
		For online help, type: "get-help $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool\getWindowsOsInvToIntersight.ps1 -online"
  ``` 
  NOTE: You can also use ```get-help .\getWindowsOsInvToIntersight.ps1 -Full``` for a list of Common Parameters.
  
  #### Example run of getWindowsOsInvToIntersight
  ```Powershell
	PS $env:USERPROFILE\Downloads\intersight-powershell-utils\os-discovery-tool> .\getWindowsOsInvToIntersight.ps1 -configfile $env:USERPROFILE\Documents\discovery_config_windows.json
	[INFO]: ODT script for OS Discovery started...
	[INFO]: Configurations in {{$env:USERPROFILE\Documents\discovery_config_windows.json}, validation succeeded!
	Transcript started, output file is C:\ProgramData\Cisco\SystemDiscovery\\discovery_131854813238026476.out
	Connecting to Cisco Intersight URL with API Keys: https://intersight.com/api/v1
	Filter:  name -like "*wincloud*"
	------------------------------------------------------------------------------------
	Processing {WINCLOUD-4} : FCH17427NSL
	Intersight API GET succeeded for host FCH17427NSL
	GetOSDetails: WINCLOUD-4
	GetDriverDetails: WINCLOUD-4
	[WINCLOUD-4]: Retrieving Network Driver Inventory...
	[WINCLOUD-4]: Retrieving Storage Driver Inventory...
	Server MOID:  5bce7116683663343218ed8b
	Computing changes...
	Changes detected for Server: [FCH17427NSL], PATCHing to Intersight...
	Processing {WINCLOUD-4} : FCH17427NSL complete.
	====================================================================================
	------------------------------------------------------------------------------------
	Processing {WINCLOUD-1} : FCH213271R7
	Intersight API GET succeeded for host FCH213271R7
	GetOSDetails: WINCLOUD-1
	GetDriverDetails: WINCLOUD-1
	[WINCLOUD-1]: Retrieving Network Driver Inventory...
	[WINCLOUD-1]: Retrieving Storage Driver Inventory...
	Server MOID:  5bce7116683663343218ed88
	Computing changes...
	No changes detected for Server: [FCH213271R7], skipping...
	Processing {WINCLOUD-1} : FCH213271R7 complete.
	====================================================================================
	Transcript stopped, output file is C:\ProgramData\Cisco\SystemDiscovery\discovery_131854813238026476.out

  ```
  ---
  ## Other applications
  This toolset can be configured to run periodically to ensure changes are captured and sent to Cisco Intersight for 
  evaluation using the following tools in windows:
  1. Windows Task Scheduler   
  Please refer to corresponding documentation:   
  https://docs.microsoft.com/en-us/windows/desktop/taskschd/task-scheduler-start-page 
  2. SCOM (System Center Operations Manager)   
  Please refer to corresponding documentation:   
  https://docs.microsoft.com/en-us/system-center/scom/manage-running-tasks?view=sc-om-1801   
  