<#

.SYNOPSIS
ODT stands for OS Discovery Toolset.
This is a simple ODT script to encrypt Cisco Intersight (TM) and vCenter credentials
It is powered by Powershell (TM) 4.0+

.DESCRIPTION
This tool needs the following inputs:

For the ESX platform:
1. vCenter Credentials
2. Location of encrypted Cisco Intersight Secret key

For the Windows platform:
1. Powershell Session Credentials for Active Directory Lookups
2. Location of encrypted Cisco Intersight (TM) Secret key

.EXAMPLE
>.\generateSecureCredentials.ps1 -platform ESX
>.\generateSecureCredentials.ps1 -platform Windows

.NOTES
This script can be run only on a Windows Powershell platform

.LINK
https://github.com/CiscoUcs/intersight-powershell

#>

Param (
    [Parameter(Mandatory=$true)]
    [string]$platform
)

Write-Host -ForegroundColor Cyan "Encrypt Cisco Intersight Private Credentials in Windows Powershell 4.0+"
Write-Host -ForegroundColor Cyan "==========================================================================="
#Get User Private key location

try {
    $PEMPath = Read-Host "Enter the Full Path of the Cisco Intersight Private Key File (.pem)" 

    if(Test-Path $PEMPath) {
        #Encrypt it
        (Get-Item -Path $PEMPath).Encrypt()
    }
    else
    {
        Write-Warning "File at path $PEMPath does not exist, cannot proceed!"
        exit
    }

    #Get vCenter Credentials
    if($platform -eq "esx") {
        Write-Host -ForegroundColor Yellow "Please enter vCenter Credentials: "
        Get-Credential | Export-Clixml -Path $env:USERPROFILE\Documents\vCenter-creds.xml
        (Get-Item -Path $env:USERPROFILE\Documents\vCenter-creds.xml).Encrypt()
    }
    elseif($platform -eq "windows") {
        Write-Host -ForegroundColor Yellow "[Warning]: Your Windows Session credentials will be used for Active Directory lookups, make sure you have atleast read-only access."
    }
}
catch [System.Exception] {
    Write-Host -ForegroundColor Red "[ERROR]: Credential generation failed: $_"
    exit
}
Write-Host -ForegroundColor Green "Credentials generated and encrypted!"
Write-Host -ForegroundColor Green "____________________________________"