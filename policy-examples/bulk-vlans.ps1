<#
Copyright (c) Cisco and/or its affiliates.
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

# Organizations and policies that should be used for the modification
$org = Get-IntersightOrganizationOrganization -Name "Demo-DevNet"
$fabricEthNetworkPolicy = Get-IntersightFabricEthNetworkPolicy -Name "Demo-DevNet-VLAN" -Organization $org | Get-IntersightMoMoRef
$fabricMulticastPolicy = Get-IntersightFabricMulticastPolicy -Name "default-mcast" -Organization $org | Get-IntersightMoMoRef

# Request object, do not modify
$request = New-Object -TypeName "System.Collections.ArrayList"
$request = [System.Collections.ArrayList]@()

# List of vlans to be created - change to reflect your VLANs
$VlanForFabric=1,2,3,4

# Loop to build the request
foreach($vlan in $VlanForFabric){
    # VLAN creation object, change the name to follow your naming schema
    $additionalProps = Initialize-IntersightFabricVlan -Name ("vlan_"+$vlan) -VlanId $vlan -EthNetworkPolicy $fabricEthNetworkPolicy -MulticastPolicy $fabricMulticastPolicy -SharingType None -AutoAllowOnUplinks $true
    $additionalPropsObj = New-Object System.Collections.Generic.Dictionary"[String,Object]"
    $additionalPropsObj.Add("Body",$additionalProps)
    $request += Initialize-IntersightBulkSubRequest -Verb "POST" -Uri "/v1/fabric/Vlans" -AdditionalProperties $additionalPropsObj
}

New-IntersightBulkRequest -Requests $request
