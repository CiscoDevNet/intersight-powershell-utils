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

# This script creates a new lan connectivity policy and vnic with VXLAN and VMQ enabled

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# =============================================================================
# Create policy
# -----------------------------------------------------------------------------
# Get the Moid of the organization in which to place the policy
$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet

$mo1 = New-IntersightVnicLanConnectivityPolicy -AzureQosEnabled $false -IqnAllocationType "None" -IqnPool $null -Name "vxlan-vmq" -Organization $Organization1 -PlacementMode "Custom" -StaticIqnName "" -Tags @() -TargetPlatform "FIAttached"

$EthAdapterPolicy1 = Get-IntersightVnicEthAdapterPolicy -Name DevNet-Eth-Adapter-VXLAN
$EthQosPolicy1 = Get-IntersightVnicEthQosPolicy -Name DevNet-Eth-QoS
$FabricEthNetworkControlPolicy1 = Get-IntersightFabricEthNetworkControlPolicy -Name DevNet-Eth-Net-Control
$FabricEthNetworkGroupPolicy1 = Get-IntersightFabricEthNetworkGroupPolicy -Name DevNet-Eth-Net-Group
$LanConnectivityPolicy1 = $mo1 | Get-IntersightMoMoRef
$MacPool1 = Get-IntersightMacpoolPool -Name DevNet-MACPool

$AdditionalProps = @"
{
    "Cdn":{"Source":"vnic"},
    "EthAdapterPolicy":"$($EthAdapterPolicy1.Moid)",
    "EthQosPolicy":"$($EthQosPolicy1.Moid)",
    "FabricEthNetworkControlPolicy":"$($FabricEthNetworkControlPolicy1.Moid)",
    "FabricEthNetworkGroupPolicy":["$($FabricEthNetworkGroupPolicy1.Moid)"],
    "FailoverEnabled":false,
    "LanConnectivityPolicy":"$($LanConnectivityPolicy1.Moid)",
    "MacAddressType":"POOL",
    "MacPool":"$($MacPool1.Moid)",
    "Name":"eth-test",
    "Order":0,
    "Placement":{"AutoPciLink":true,"AutoSlotId":true,"SwitchId":"A"},
    "VmqSettings":{"Enabled":true,"MultiQueueSupport":true,"NumSubVnics":64,"VmmqAdapterPolicy":"$($EthAdapterPolicy1.Moid)"}
}
"@

$AdditionalProps = $AdditionalProps | ConvertFrom-Json -AsHashTable
$AdditionalPropsObj = New-Object System.Collections.Generic.Dictionary"[String,Object]"
$AdditionalPropsObj.Add("Body",$AdditionalProps)
$Request = Initialize-IntersightBulkSubRequest -Verb "POST" -Uri "/v1/vnic/EthIfs" -AdditionalProperties $AdditionalPropsObj
$mo2 = New-IntersightBulkRequest -Requests $Request
$mo2
