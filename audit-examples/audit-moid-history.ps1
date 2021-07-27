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

# This script captures the entire audit history of a managed object specified
# by its Moid (managed object ID).

# the only required parameter is $Moid
[cmdletbinding()]
param(
    [parameter(Mandatory = $true)]
    [string]$Moid
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# retrieve all entries from the Intersight audit log where the object
# matches the specified Moid
$moid_filter = "ObjectMoid eq '$($Moid)'"

$data = (Get-IntersightAaaAuditRecord `
        -Filter $moid_filter `
        -Select 'Email,CreateTime,Event,Request' `
        -Orderby CreateTime `
).Results

# Write each audit log entry to its own file in JSON format with the date of
# the event as the filename.
foreach ($item in $data) {
    $datestring = $item.CreateTime.ToString("yyyy-MM-dd:hhmmss.fff")
    $path = '.\' + $datestring + '.json'
    $item | Select-Object -ExcludeProperty ClassId, Moid, ObjectType `
    | ConvertTo-Json -Depth 5 | Set-Content -Path $path
}

# display a summary of the audit history to the screen
$data | Select-Object CreateTime, Email, Event | Format-Table
Write-Host $data.Count " JSON files created, one for each of the above events.`n"