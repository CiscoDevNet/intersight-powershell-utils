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

$Organization1 = Get-IntersightOrganizationOrganization -Name "Demo-DevNet" | Get-IntersightMoMoRef

$getMo1 = Get-IntersightFabricEthNetworkGroupPolicy -Name "DevNet-Eth-Net-Group" -Organization $Organization1
$VlanSettings1 = Initialize-IntersightFabricVlanSettings -AllowedVlans "248,300-310" -NativeVlan 1 -QinqEnabled $false -ObjectType "FabricVlanSettings" -ClassId "FabricVlanSettings"

$mo1 = $getMo1 | Set-IntersightFabricEthNetworkGroupPolicy -Organization $Organization1 -VlanSettings $VlanSettings1
$mo1
