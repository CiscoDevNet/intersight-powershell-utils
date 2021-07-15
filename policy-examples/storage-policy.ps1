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

# create a prefix for the name for both policies that will be created
$base_name = ("$($vDisk)_Raid$($Raid)_" + ($Disks -join ""))

# =============================================================================
# Create disk group policy
# -----------------------------------------------------------------------------

# Get the Moid of the organization in which to place the policy
$my_org = Get-IntersightOrganizationOrganization -Name default

# Ensure the right number of disks is specified. They must be able to split
# evenly into the number of specified span groups. For example, if the user
# requests 3 span groups, there must be 3, 6, 9, etc. drives declared.
if($Disks.Count % $SpanGroups) {
    throw "Number of disks $($Disks.Count) cannot be split evenly between $($SpanGroups) groups."
}

# Divide the disks into the specified number of span groups.
$groups = @()
$disks_per_group = $Disks.Count / $SpanGroups
$disk_index = 0
for($g=1; $g -le $SpanGroups; $g++)
{
    $local_disks = @()
    for($i=0; $i -lt $disks_per_group; $i++)
    {
        # create each disk and put it in an array
        $local_disks += Initialize-IntersightStorageLocalDisk -SlotNumber $Disks[$disk_index]
        $disk_index++
    }
    # add a span group using the group of disks initialized above
    $groups += Initialize-IntersightStorageSpanGroup -Disks $local_disks
}

# create the StorageDiskGroup policy
$dg_policy = New-IntersightStorageDiskGroupPolicy `
    -Description 'created by PowerShell' `
    -Name "$($base_name)_group" `
    -RaidLevel "Raid$($Raid)" `
    -SpanGroups $groups `
    -Organization $my_org

Write-Host "Created Disk Group policy '$($dg_policy.Name)' with Moid $($dg_policy.Moid)"

# =============================================================================
# Create storage policy
# -----------------------------------------------------------------------------

# This script only creates a single virtual drive, but Intersight allows for
# multiple virtual drives, each using a different disk group policy.
$virtual_drives = @(
    Initialize-IntersightStorageVirtualDriveConfig `
        -BootDrive $true `
        -DiskGroupPolicy $dg_policy.Moid `
        -ExpandToAvailable $true `
        -Name $vDisk `
        -Size 0
)

# create storage policy
$storagepolicy = New-IntersightStorageStoragePolicy `
    -Description 'created by PowerShell' `
    -Name "$($base_name)_storage" `
    -VirtualDrives $virtual_drives `
    -Organization $my_org

Write-Host "Created Disk Group policy '$($storagepolicy.Name)' with Moid $($storagepolicy.Moid)"
