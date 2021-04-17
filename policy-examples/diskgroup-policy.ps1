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

# This script creates a new local storage policy.

[cmdletbinding()]
param(
    $SpanGroups = 1,
    
    [parameter(Mandatory = $true)]
    [string]$Raid,

    [parameter(Mandatory = $true)]
    [string[]]$Disks,
    
    [parameter(Mandatory = $true)]
    [string]$vDisk
)

# =============================================================================
# Create disk group policy
# -----------------------------------------------------------------------------

# Get the Moid of the organization in which to place the policy

$my_org = (Get-IntersightOrganizationOrganizationList `
        -VarFilter 'Name eq default' `
        -Select Moid).ActualInstance.Results | Select-Object -First 1


# create each disk and put it in an array
$local_disks = @()
$Disks | ForEach-Object {
    $local_disks += Initialize-IntersightStorageLocalDisk -SlotNumber $_
}
# initialize the span groups using the above array of disks
$span_groups = Initialize-IntersightStorageSpanGroup -Disks $local_disks

$policy = Initialize-IntersightStorageDiskGroupPolicy `
    -Description 'created by PowerShell' `
    -Name ("$($vDisk)_Raid$($Raid)_" + ($Disks -join "")) `
    -RaidLevel "Raid$($Raid)" `
    -SpanGroups $span_groups `
    -Organization @{Moid = $my_org.Moid }

# this is a temporary workaround for a bug that incorrectly adds an
# unnecessary property to this policy
$policy.PSObject.Properties.Remove('_0_ClusterReplicationNetworkPolicy')

# create the policy
$dg_policy = New-IntersightStorageDiskGroupPolicy -StorageDiskGroupPolicy $policy
Write-Host $dg_policy.Moid

# =============================================================================
# Create storage policy
# -----------------------------------------------------------------------------

$virtual_drives = @(
    Initialize-IntersightStorageVirtualDriveConfig `
        -BootDrive $true `
        -DiskGroupPolicy $dg_policy.Moid `
        -ExpandToAvailable $true `
        -Name $vDisk `
        -Size 0
)

$diskgrouppolicy = New-Object PSObject -Property @{
    Moid       = $dg_policy.Moid
    ObjectType = $dg_policy.ObjectType
    ClassId    = 'mo.MoRef'
}

# -DiskGroupPolicies @($diskgrouppolicy) `
$policy = Initialize-IntersightStorageStoragePolicy `
    -DiskGroupPolicies $diskgrouppolicy `
    -Description 'created by PowerShell' `
    -Name "storage_$($vDisk)" `
    -VirtualDrives $virtual_drives `
    -Organization @{Moid = $my_org.Moid }

# this is a temporary workaround for a bug that incorrectly adds an
# unnecessary property to this policy
$policy.PSObject.Properties.Remove('_0_ClusterReplicationNetworkPolicy')

$storagepolicy = New-IntersightStorageStoragePolicy -StorageStoragePolicy $policy
Write-Host $storagepolicy.Moid