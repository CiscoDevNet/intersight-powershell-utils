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

[cmdletbinding()]
param(
    # .csv file where results will be written
    [string]$CsvFile = "contract_status_summary.csv"
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$FilePath = "$PSScriptRoot\$CsvFile"
New-Item $FilePath -ItemType file -Force

# get contract status by endpoint and write results to .csv file
try {
    # select only what will be written to the .csv file
    $SelectStr = 'ContractStatus,DeviceId,DeviceType,PlatformType,ServiceEndDate'
    $Response = (Get-IntersightAssetDeviceContractInformation -Select $SelectStr -Top 1000).Results
    Write-Host $Status $Response.count
    $OutResponse = $Response | Select-Object PlatformType, DeviceType, DeviceId, ContractStatus, ServiceEndDate
    $OutResponse | Export-Csv -Path $FilePath -Append
}
catch {
    Write-Host $Status $Error[0].Exception
}
