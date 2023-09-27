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
[
  {
    "queryType": "groupBy",
    "dataSource": "PhysicalEntities",
    "granularity": {
      "type": "duration",
      "duration": 604800000,
      "origin": "2023-09-20T16:18:00.000Z"
    },
    "intervals": [
      "2023-09-20T16:18:00.000Z/2023-09-27T16:18:00.000Z"
    ],
    "limitSpec": {
      "type": "default",
      "limit": 5,
      "columns": [
        {
          "dimension": "system-memory-utilization-Avg",
          "direction": "descending",
          "dimensionOrder": "numeric"
        }
      ]
    },
    "dimensions": [
      "host.name"
    ],
    "filter": {
      "type": "and",
      "fields": [
        {
          "type": "selector",
          "dimension": "instrument.name",
          "value": "system.memory"
        }
      ]
    },
    "aggregations": [
      {
        "type": "longSum",
        "name": "count",
        "fieldName": "system.memory.utilization_count"
      },
      {
        "type": "doubleSum",
        "name": "system.memory.utilization-Sum",
        "fieldName": "system.memory.utilization"
      }
    ],
    "postAggregations": [
      {
        "type": "expression",
        "name": "system-memory-utilization-Avg",
        "expression": "(\"system.memory.utilization-Sum\" / \"count\")"
      }
    ]
  },
  {
    "queryType": "groupBy",
    "dataSource": "PhysicalEntities",
    "granularity": {
      "type": "period",
      "period": "PT1H",
      "timeZone": "America/Chicago",
      "origin": "2023-09-20T16:18:00.000Z"
    },
    "intervals": [
      "2023-09-20T16:18:00.000Z/2023-09-27T16:18:00.000Z"
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
          "value": "system.memory"
        },
        {
          "type": "or",
          "fields": [
            {
              "type": "and",
              "fields": [
                {
                  "type": "selector",
                  "dimension": "host.name",
                  "value": "int-tme-ucs-3 FI-B"
                }
              ]
            },
            {
              "type": "and",
              "fields": [
                {
                  "type": "selector",
                  "dimension": "host.name",
                  "value": "int-tme-ucs-3 FI-A"
                }
              ]
            },
            {
              "type": "and",
              "fields": [
                {
                  "type": "selector",
                  "dimension": "host.name",
                  "value": "int-ucs-1 FI-A"
                }
              ]
            },
            {
              "type": "and",
              "fields": [
                {
                  "type": "selector",
                  "dimension": "host.name",
                  "value": "int-ucs-1 FI-B"
                }
              ]
            },
            {
              "type": "and",
              "fields": [
                {
                  "type": "selector",
                  "dimension": "host.name",
                  "value": "B26-Matt-FI FI-B"
                }
              ]
            }
          ]
        }
      ]
    },
    "aggregations": [
      {
        "type": "longSum",
        "name": "count",
        "fieldName": "system.memory.utilization_count"
      },
      {
        "type": "doubleSum",
        "name": "system.memory.utilization-Sum",
        "fieldName": "system.memory.utilization"
      }
    ],
    "postAggregations": [
      {
        "type": "expression",
        "name": "system-memory-utilization-Avg",
        "expression": "(\"system.memory.utilization-Sum\" / \"count\")"
      }
    ]
  }
]
"@

$queryArray = $query | ConvertFrom-Json

foreach ($query in $queryArray) {
  $query = $query | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashTable
  $results = (New-IntersightManagedObject -ObjectType telemetry.TimeSerie -AdditionalProperties $query | ConvertFrom-Json)
  foreach ($result in $results) {
    Write-Output $result.timestamp $result.event
  }
}
