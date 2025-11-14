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

[cmdletbinding()]
param(
    # .csv file where results will be written
    [string]$CsvFile = "compute_summaries_export.csv"
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$FilePath = "$PSScriptRoot\$CsvFile"
New-Item $FilePath -ItemType file -Force

# write csv header
"Name,Model,Serial,UserLabel,ManagementMode,ServerProfile" | Out-File -FilePath $FilePath -Encoding utf8 -Append

# page through all compute physical summaries and write to csv
$recordCount = Get-IntersightComputePhysicalSummary -Count $true
$top=1000
$pages = [Math]::Ceiling($recordCount.Count/$top)
Write-Output ("Total Matching Records:" + $recordCount.Count)
for ($x=0; $x -lt $pages; $x++) {
    $results = Get-IntersightComputePhysicalSummary -Top $top -Skip ($x*$top) -Select "Name,Model,Serial,UserLabel,Moid,ManagementMode" | Select-Object -Expand Results
    foreach ($item in $results) {
        $name = $item.Name
        $model = $item.Model
        $serial = $item.Serial
        $userlabel = $item.UserLabel
        $moid = $item.Moid
        $managementmode = if ($item.ManagementMode) { $item.ManagementMode } else { "N/A" }
        # get server profile from associated server moid
        $profile = Get-IntersightServerProfile -Filter "AssociatedServer.Moid eq '$($item.Moid)'" -Select Name | Select-Object -Expand Results
        $serverprofile = if ($profile) { $profile.Name } else { "Unassigned" }
        "$name,$model,$serial,$userlabel,$managementmode,$serverprofile" | Out-File -FilePath $FilePath -Encoding utf8 -Append
    }
}
Write-Output ("Export complete. File saved to " + $FilePath)
