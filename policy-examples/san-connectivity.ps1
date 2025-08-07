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

# This script creates a new san connectivity policy and vhba then deletes it

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# =============================================================================
# Create policy
# -----------------------------------------------------------------------------
# Get the Moid of the organization in which to place the policy
$Organization1 = Get-IntersightOrganizationOrganization -Name dsoper-DevNet
# create the policy and vhba

$SanConnectivityPolicy1 = New-IntersightVnicSanConnectivityPolicy `
    -Name "static-vhbas" `
    -Organization $Organization1 `
    -PlacementMode "Auto" `
    -WwnnAddressType "STATIC" `
    -StaticWwnnAddress "20:00:00:25:B5:07:14:00" `
    -TargetPlatform "FIAttached" `
    -WwnnPool $null
Write-Host $SanConnectivityPolicy1

$FcAdapterPolicy1 = Get-IntersightVnicFcAdapterPolicy -Name default-fc-adapter
$FcNetworkPolicy1 = Get-IntersightVnicFcNetworkPolicy -Name default-fc-network
$FcQosPolicy1 = Get-IntersightVnicFcQosPolicy -Name default-fc-qos
$SanConnectivityRef1 = $SanConnectivityPolicy1 | Get-IntersightMoMoRef
$Placement1 = Initialize-IntersightVnicPlacementSettings -SwitchId "A" -ObjectType "VnicPlacementSettings" -ClassId "VnicPlacementSettings"

$vHBA0 = New-IntersightVnicFcIf `
    -SanConnectivityPolicy $SanConnectivityRef1 `
    -FcAdapterPolicy $FcAdapterPolicy1 `
    -FcNetworkPolicy $FcNetworkPolicy1 `
    -FcQosPolicy $FcQosPolicy1 `
    -Name "vhba0" `
    -Placement $Placement1 `
    -WwpnAddressType "STATIC" `
    -StaticWwpnAddress "20:00:00:25:B5:07:14:00" `
    -WwpnPool $null
Write-Host $vHBA0

# =============================================================================
# Remove policy
# -----------------------------------------------------------------------------
$SanConnectivityPolicy1 | Remove-IntersightVnicSanConnectivityPolicy
Write-Host $?
