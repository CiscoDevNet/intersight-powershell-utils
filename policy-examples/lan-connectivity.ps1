<#
Copyright (c) 2022 Cisco and/or its affiliates.
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

# This script creates a new lan connectivity policy and vnic then deletes it

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# =============================================================================
# Create policy
# -----------------------------------------------------------------------------
# Get the Moid of the organization in which to place the policy
$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet
# create the policy and vnics
$mo1 = New-IntersightVnicLanConnectivityPolicy `
    -Name "cldemo-lanc" `
    -Organization $Organization1 `
    -PlacementMode "Auto" `
    -TargetPlatform "FIAttached"
Write-Host $mo1

$Cdn1 = Initialize-IntersightVnicCdn -Source "Vnic" -ObjectType "VnicCdn" -ClassId "VnicCdn"
$EthAdapterPolicy1 = Get-IntersightVnicEthAdapterPolicy -Name da-compute-ethernet-adapter
$EthQosPolicy1 = Get-IntersightVnicEthQosPolicy -Name da-compute-qos
$FabricEthNetworkControlPolicy1 = Get-IntersightFabricEthNetworkControlPolicy -Name da-compute-network-control
$FabricEthNetworkGroupPolicy1 = Get-IntersightFabricEthNetworkGroupPolicy -Name da-compute-network-vlan-settings
$LanConnectivityPolicy1 = $mo1 | Get-IntersightMoMoRef
$MacPool1 = Get-IntersightMacpoolPool -Name da-compute-mac-address-pool-a
$Placement1 = Initialize-IntersightVnicPlacementSettings -SwitchId "A" -ObjectType "VnicPlacementSettings" -ClassId "VnicPlacementSettings"

$mo2 = New-IntersightVnicEthIf `
    -Cdn $Cdn1 `
    -EthAdapterPolicy $EthAdapterPolicy1 `
    -EthQosPolicy $EthQosPolicy1 `
    -FabricEthNetworkControlPolicy $FabricEthNetworkControlPolicy1 `
    -FabricEthNetworkGroupPolicy @($FabricEthNetworkGroupPolicy1) `
    -FailoverEnabled $false `
    -LanConnectivityPolicy $LanConnectivityPolicy1 `
    -MacAddressType "POOL" `
    -MacPool $MacPool1 `
    -Moid "" `
    -Name "eth0" `
    -Placement $Placement1 `
    -StaticMacAddress ""
Write-Host $mo2

# =============================================================================
# Remove policy
# -----------------------------------------------------------------------------
$mo1 | Remove-IntersightVnicLanConnectivityPolicy
Write-Host $?
