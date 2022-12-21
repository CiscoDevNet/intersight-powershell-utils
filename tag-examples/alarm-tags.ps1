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

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$alarms = (Get-IntersightCondAlarm `
        -Filter "Severity ne Cleared and Severity ne Info and Acknowledge eq None"
).Results

foreach ($alarm in $alarms) {
    $moid = $alarm.AncestorMoId
    # $tags = (Get-IntersightSearchTagItem -Moid $moid).Results
    # resources like computePhysSummary and computeBlade use the same Moid, so only get the 1st result
    $tags = (Get-IntersightSearchSearchItem -Filter "Moid eq '$moid'" -Select "Tags").Results[0]
    Write-Host "AffectedMoid $moid, $($alarm | Select-Object Name, Code, LastTransitionTime)"
    Write-Host ($tags | Select-Object Tags | ConvertTo-Json -Depth 5)
}
