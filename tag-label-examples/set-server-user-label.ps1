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

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# Get the compute/ServerSetting for SJC07-R14-FI-1-1-7
$ServerName = "SJC07-R14-FI-1-1-7"
$ServerSetting = Get-IntersightComputeServerSetting -Name $ServerName

# Set the user label for the server
$UserLabel = "DevNet-Demo"
$ServerConfig = Initialize-IntersightComputeServerConfig -UserLabel $UserLabel
$Mo1 = $ServerSetting | Set-IntersightComputeServerSetting -ServerConfig $ServerConfig
$Mo1.ServerConfig
