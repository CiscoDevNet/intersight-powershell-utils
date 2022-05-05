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

[cmdletbinding()]
param(
    # .csv file where results will be written
    [string]$CsvFile = "dimm_serial_summary.csv"
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$FilePath = "$PSScriptRoot\$CsvFile"
New-Item $FilePath -ItemType file -Force

try {
    # Find the count of dimms
    $Dimms = Get-IntersightMemoryUnit -Count $true -filter "Presence eq 'equipped'"

    $SelectStr = 'Location,Presence,Serial,RegisteredDevice'
    # Intersight limits the number of items returned.  Page through returned results and select Name, Model, Serial
    $PerPage = 1000
    Write-Host $Dimms.Count
    for ($i = 0; $i -lt $Dimms.Count; $i += $PerPage) {
        # API filter to only what will be written to the .csv file
        $Response = (Get-IntersightMemoryUnit -top $PerPage -skip $i -filter "Presence eq 'equipped'" -Select $SelectStr -Expand RegisteredDevice).Results
        Write-Host $Status $Response.count
        $HostnameExp = @{
            label      = 'Hostname'
            # Serial is supported in upcoming SDKs, for now DN is used
            expression = { $_.RegisteredDevice.ActualInstance.DeviceHostname }
        }
        $OutResponse = $Response | Select-Object Location, Presence, Serial, $HostnameExp
        $OutResponse | Export-Csv -Path $FilePath -Append
    }
}
catch {
    Write-Host $Status $Error[0].Exception
}
