<#
Copyright (c) 2023 Cisco and/or its affiliates.
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
    [string]$CsvFile = "avg-network-utilization.csv"
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$FilePath = "$PSScriptRoot\$CsvFile"
New-Item $FilePath -ItemType file -Force

$query = @"
  {
    "queryType": "groupBy",
    "dataSource": "NetworkInterfaces",
    "granularity": {
      "type": "period",
      "period": "PT1H",
      "timeZone": "America/Chicago",
      "origin": "2023-09-20T21:14:00.000Z"
    },
    "intervals": [
      "2023-09-20T21:14:00.000Z/2023-09-27T21:14:00.000Z"
    ],
    "dimensions": [
      "host.name"
    ],
    "filter": {
      "type": "and",
      "fields": [
        {
          "type": "selector",
          "dimension": "instrument.name",
          "value": "hw.network"
        }
      ]
    },
    "aggregations": [
      {
        "type": "longSum",
        "name": "count",
        "fieldName": "hw.network.bandwidth.utilization_all_count"
      },
      {
        "type": "doubleSum",
        "name": "hw.network.bandwidth.utilization_all-Sum",
        "fieldName": "hw.network.bandwidth.utilization_all"
      }
    ],
    "postAggregations": [
      {
        "type": "expression",
        "name": "hw-network-bandwidth-utilization_all-Avg",
        "expression": "(\"hw.network.bandwidth.utilization_all-Sum\" / \"count\")"
      }
    ]
  }
"@

$query = $query | ConvertFrom-Json -AsHashTable

$results = (New-IntersightManagedObject -ObjectType telemetry.TimeSerie -AdditionalProperties $query | ConvertFrom-Json)

foreach ($result in $results) {
    $result | ForEach-Object {
        $row = [PSCustomObject]@{
            "timestamp" = $_.timestamp
            "host.name" = $_.event."host.name"
            "hw-network-bandwidth-utilization_all-Avg" = $_.event."hw-network-bandwidth-utilization_all-Avg"
        }
        $row | Export-Csv -Path $FilePath -Append
    }
}
