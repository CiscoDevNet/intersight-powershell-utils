<#
Copyright (c) 2018 Cisco and/or its affiliates.
This software is licensed to you under the terms of the Cisco Sample
Code License, Version 1.0 (the "License"). You may obtain a copy of the
License at
               https://developer.cisco.com/docs/licenses
All use of the material herein must be in accordance with the terms of
the License. All rights not expressly granted by the License are
reserved. Unless required by applicable law or agreed to separately in
writing, software distributed under the License is distributed on an "AS
IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied.
#>

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

#Specify Serial Number of the Blade to Install the Operating System On
#Blade must be associated to Server Profile with SAN Boot Policy and vHBAs defined
$serial = "FCHXXXXXXXXXX"

#Specify the Names of the OS Image and SCU that were pre-created in the Intersight Software Repository
$osImageName = "ESXi7.0"
$scuName = "SCU6.23b"

#Specify the built-in template config file in Intersight for ESXi 7
#Use Get-IntersightOsConfigurationFile to determine the template names for other OS types/versions
$osConfigFile = "ESXi7.0ConfigFile"

#Specify the organization
$orgName = "default"

#Specify OS Configuration Options
$hostname = "server1.local"
$ipType = "static"
$password = "change_me"
$nameServer = "8.8.8.8"

#Specify OS IP Info
$os_ipv4_addr = "192.168.1.100"
$os_ipv4_netmask = "255.255.255.0"
$os_ipv4_gateway = "192.168.1.1"

$ipConfiguration = @{
    IpV4Config = @{
        IpAddress = $os_ipv4_addr
        Netmask   = $os_ipv4_netmask
        Gateway   = $os_ipv4_gateway
    }
}

#Specify Target information for SAN install (needs to match the target in the boot policy)
$targetWWPN = "50:00:00:00:c9:b0:55:2e"
$lunID = 1

#Get references to the organization
$org = Get-IntersightOrganizationOrganization -Name $orgName

#Get references to the OS Image, SCU, and Template info
$osImage = Get-IntersightSoftwarerepositoryOperatingSystemFile -Name $osImageName
$scuImage = Get-IntersightFirmwareServerConfigurationUtilityDistributable -Name $scuName
$osConfig = Get-IntersightOsConfigurationFile -Name $osConfigFile

#Get references on the server we are installing to
$server = Get-IntersightComputeBlade -Serial $serial
$serverRef = Initialize-IntersightMoMoRef -Moid $server.Moid -Objecttype ($server.ObjectType | Out-String)

#Get the associated profile and retrieve the first vhba wwpn which we will use as the install initiatior
$filter = "AssociatedServer.Moid eq '"+$server.Moid+"'"
$serverProfile = Get-IntersightServerProfile -Filter $filter
$MORef = $serverProfile.Results | Get-IntersightMoMoRef
$vHBAs = Get-IntersightVnicFcIf -Profile $MORef | Select Name,Wwpn

#Setup OS Configuration answers
$commIpV4Interface = Initialize-IntersightCommIpV4Interface -IPAddress $os_ipv4_addr -Netmask $os_ipv4_netmask -Gateway $os_ipv4_gateway
$osIpv4config = Initialize-IntersightOsIpv4Configuration -IpV4Config $commIpV4Interface
$answers = Initialize-IntersightOsAnswers -Hostname $hostname -IpConfigType $ipType -IpConfiguration $osIpv4config -RootPassword $password -Source Template -NameServer $nameServer

#Define Install Target
$installTarget = Initialize-IntersightOsFibreChannelTarget -InitiatorWwpn $vHBAs[0].Wwpn -TargetWwpn $targetWWPN -LunID $lunID

#Kickoff OS install
$results = New-IntersightOsInstall -Name "OS Install" -Answers $answers -Image $osImage -OsduImage $scuImage -Server $serverRef -InstallMethod "vMedia" -Organization $org -InstallTarget $installTarget -ConfigurationFile $osConfig 

#Check on submission status of OS install (OperState and ErrorMsg)
Get-IntersightOsInstall -Moid $results.Moid
