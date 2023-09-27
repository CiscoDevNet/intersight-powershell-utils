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

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$query = @"
  {
    "queryType": "groupBy",
    "dataSource": "PhysicalEntities",
    "granularity": {
      "type": "period",
      "period": "PT1H",
      "timeZone": "America/Chicago",
      "origin": "2023-09-20T14:56:00.000Z"
    },
    "intervals": [
      "2023-09-20T14:56:00.000Z/2023-09-27T14:56:00.000Z"
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
          "value": "system.cpu"
        }
      ]
    },
    "aggregations": [
      {
        "type": "longSum",
        "name": "count",
        "fieldName": "system.cpu.utilization_user_count"
      },
      {
        "type": "doubleSum",
        "name": "system.cpu.utilization_user-Sum",
        "fieldName": "system.cpu.utilization_user"
      }
    ],
    "postAggregations": [
      {
        "type": "expression",
        "name": "system-cpu-utilization_user-Avg",
        "expression": "(\"system.cpu.utilization_user-Sum\" / \"count\")"
      }
    ]
  }
"@

$query = $query | ConvertFrom-Json -AsHashTable

$results = (New-IntersightManagedObject -ObjectType telemetry.TimeSerie -AdditionalProperties $query | ConvertFrom-Json)
foreach ($result in $results) {
  Write-Output $result.timestamp $result.event
}
