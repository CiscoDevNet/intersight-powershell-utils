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

# This script creates a new policy, updates it, and destroys it.

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# Configure maximum top value and define odata filter, select, and orderby values
$top=1000
$select="Event,Email,CreateTime"
$filter="MoType eq 'iam.User'"
$orderby="CreateTime desc"

# Get the total record count for our matching filter on the aaa.AuditRecord endpoint
$recordCount = Get-IntersightAaaAuditRecord -Select $select -Filter $filter -Count $true

# Divide this by the top value and round up to use as our loop counter
$pages = [Math]::Ceiling($recordCount.Count/$top)

Write-Output ("Total Matching Records:" + $recordCount.Count)

# Loop through the number of times defined by the returned recordcount/top, incrementing the skip counter to get the next X records on each loop
for ($x=0; $x -lt $pages; $x++) {
    Get-IntersightAaaAuditRecord -Select $select -Filter $filter -Top $top -Skip ($x*$top) -OrderBy $orderby | Select-Object -Expand Results | Select Event,Email,CreateTime
}
