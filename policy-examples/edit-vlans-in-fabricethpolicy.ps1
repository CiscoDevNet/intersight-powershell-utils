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

#Get Default Organization
$defaultorg = Get-IntersightOrganizationOrganization -Name 'default'

#Get EthernetNetwork Policy
$vlanpolicy = Get-IntersightFabricEthNetworkPolicy -Name 'MyEthNetworkVlan_Policy' -Organization $defaultorg

$filter = "EthNetworkPolicy.Moid eq '" + $vlanpolicy.Moid + "'"

#Get FabricVlans attached to FabricEthernetNetwork Policy
$vlans = Get-IntersightFabricVlan -Filter $filter -Top 1000

#Loop through the VLANS attached to that policy and change AutoAllowOnUplinks to True on all vlans
foreach($vlan in $vlans.Results)
{
    if($vlan.VlanId -gt 1)
    {
            $json = Get-IntersightManagedObject -Moid $vlan.Moid -ObjectType "FabricVlan"
            $json = $json | ConvertFrom-Json
            $json.AutoAllowOnUplinks = $true
            Set-IntersightManagedObject -JsonRequestBody ($json | ConvertTo-Json)
    }
} 
