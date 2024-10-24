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

# these lines required to enable Verbose output
[cmdletbinding()]
param(
    [parameter(Mandatory = $true)]
    [string]$Key,

    [parameter(Mandatory = $true)]
    [string]$Value
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# This filter will find locator LEDs that are on and belong to servers (there
# are locator LEDs on disks, too, and we don't the API to return those).
$myfilter = "Parent.ObjectType eq compute.RackUnit and OperState eq on"

# Using our filter and -Expand to return the ComputeRackUnit will give us the
# Moid and the existing Tags for the server so we don't have to do an
# additional get operation. 
$results = (Get-IntersightEquipmentLocatorLed -Filter $myfilter -Select ComputeRackUnit -Expand ComputeRackUnit).Results

foreach ($server in $results) {
    # Create a new list of tags containing all of the existing tags. If the tag
    # key requested by the user already exists, leave it out of the list so we
    # can add the value specified by the user.
    $new_tags = @()
    foreach ($t in $server.ComputeRackUnit.Tags) {
        if ($t.Key -notmatch $Key) { $new_tags += $t }
    }
    $new_tags += Initialize-IntersightMoTag -Key $Key -Value $Value
    
    # apply the new tags to the server, overwriting all existing tags
    $moid = $server.ComputeRackUnit.Moid
    (Set-IntersightComputeRackUnit -Moid $moid -Tags $new_tags).Serial
    Write-Verbose "$($new_tags.Count) tags now exist for this server"
}

Write-Verbose "$($results.Count) servers found with locator LED on"