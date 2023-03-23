<#
Copyright (c) 2021 Cisco and/or its affiliates.
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

# This script creates a new policy, updates it, and destroys it.

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

#Get Default organization
$defaultorg = Get-IntersightOrganizationOrganization -Name 'default'

#Get chassis profile to modify
$chassisprofile = Get-IntersightChassisProfile -Name 'MyChassisProfile' -Organization $defaultorg

#Get existing SNMP policy to add to chassis profile and create a reference
$snmppolicy = Get-IntersightSnmpPolicy -Name 'MySnmpPolicy' -Organization $defaultorg
$snmppolicyMoRef = Initialize-IntersightMoMoRef -Moid $snmppolicy.Moid -Objecttype ($snmppolicy.ObjectType | Out-String)

#Create policybucket array
$policybucket = @()

#Ignore null values and add existing policy buckets into the array except for any existing SNMP policy in the chassis profile
if($chassisprofile.PolicyBucket.ActualInstance)
{
    $policybucket += $chassisprofile.PolicyBucket.ActualInstance | Where-Object { $_.ObjectType –ne "SnmpPolicy" }
}

#Add SNMP policy reference to policybucket array
$policybucket += $snmppolicyMoRef

#Attach policy bucket to chassis profile
$chassisprofile | Set-IntersightChassisProfile -PolicyBucket $policybucket

#Deploy changes on chassis profile
$chassisprofile | Set-IntersightChassisProfile -Action 'Deploy' 
