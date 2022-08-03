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
.SYNOPSIS
    Example configuration of a UCS Domain Profile

.DESCRIPTION
    Example configuration of a UCS Domain Profile

.PARAMETER <Action>
    Action to perform on the profile (Deploy, Unassign, or Delete). Default Action is Deploy.   

.EXAMPLE
    domain-profile.ps1
    domain-profile.ps1 -Action Unassign
    domain-profile.ps1 -Action Delete
#>

param(
    [string]$Action = 'Deploy'
)
# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$org = Get-IntersightOrganizationOrganization -Name dsoper-DevNet

switch ($Action) {
    { $Action -eq 'Deploy' } {
        # Create the UCS Domain Profile
        $profile = New-IntersightFabricSwitchClusterProfile -Name emulator -Organization $org
        Write-Host $profile.Name, $profile.Moid

        # Assign FI A to Switch Profile
        $switchA = Get-IntersightNetworkElement -Serial FDO23021WJ6
        $switchProfileA = New-IntersightFabricSwitchProfile -Name emulator-A `
            -SwitchClusterProfile $profile -AssignedSwitch $switchA
        Write-Host $switchProfileA.Name, $switchProfileA.Moid
        $AMoRef = Get-IntersightMoMoRef -ManagedObject $switchProfileA

        # Assign FI B to Switch Profile
        $switchB = Get-IntersightNetworkElement -Serial FDO23070UA2
        $switchProfileB = New-IntersightFabricSwitchProfile -Name emulator-B `
            -SwitchClusterProfile $profile -AssignedSwitch $switchB
        Write-Host $switchProfileB.Name, $switchProfileB.Moid
        $BMoRef = Get-IntersightMoMoRef -ManagedObject $switchProfileB

        # Add Switch Profiles to Policies (Policy Buckets not supported yet)
        $portPolicy = Get-IntersightFabricPortPolicy -Name server-1-6 -Organization $org
        $portPolicy = $portPolicy | Set-IntersightFabricPortPolicy -Profiles @($AMoRef, $BMoRef)
        $qosPolicy = Get-IntersightFabricSystemQosPolicy -Name required-qos -Organization $org
        $qosPolicy = $qosPolicy | Set-IntersightFabricSystemQosPolicy -Profiles @($AMoRef, $BMoRef)
    }
    { $Action -eq 'Unassign' } {
        $switchProfileA = Get-IntersightFabricSwitchProfile -Name emulator-A
        Write-Host $switchProfileA.Name $switchProfileA.Moid
        $switchProfileB = Get-IntersightFabricSwitchProfile -Name emulator-B
        Write-Host $switchProfileB.Name $switchProfileB.Moid
    }
    { $Action -eq 'Delete' } {
        $profile = Get-IntersightFabricSwitchClusterProfile -Name emulator -Organization $org
        Write-Host $profile.Name, $profile.Moid
        $mo = Remove-IntersightFabricSwitchClusterProfile -Moid $profile.Moid
    }
}
if ( ($Action -eq 'Deploy') -or ($Action -eq 'Unassign') ) {
    # Perform Action on profile
    $moid = $switchProfileA.Moid
    $jsonpayload = "{`"ObjectType`": `"fabric.SwitchProfile`", `"Moid`": `"$moid`", `"Action`": `"$Action`"}"
    $mo1 = Set-IntersightManagedObject -JsonRequestBody $jsonpayload
    # $switchProfileB = $switchProfileB | Set-IntersightFabricSwitchProfile -Action $Action
    $moid = $switchProfileB.Moid
    $jsonpayload = "{`"ObjectType`": `"fabric.SwitchProfile`", `"Moid`": `"$moid`", `"Action`": `"$Action`"}"
    $mo2 = Set-IntersightManagedObject -JsonRequestBody $jsonpayload
}