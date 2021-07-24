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

# the only required parameter is days
[cmdletbinding()]
param(
    [parameter(Mandatory = $true)]
    [string]$Days
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# retrieve the audit log for all delete entries for the last X days
$mydate = (Get-Date).AddDays(-$Days).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$myfilter = "Event eq Deleted and CreateTime gt $mydate"
$data = (Get-IntersightAaaAuditRecord `
        -Filter $myfilter `
        -Orderby CreateTime `
        -Select 'CreateTime,Email,MoDisplayNames'
).Results

# add the name of the deleted object to each "row" of results from the API
foreach ($obj in $data) {
    # it's possible that the object does not have a name
    try {
        $obj_name = $obj.MoDisplayNames.Name[0]
    }
    catch {
        $obj_name = " "
    }
    $obj | Add-Member -MemberType NoteProperty -Name 'Name' -Value $obj_name
}

$data | Select-Object -ExcludeProperty ClassId, Moid, MoDisplayNames, ObjectType `
| Format-Table
