<#
Copyright (c) 2018 Cisco and/or its affiliates.
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

# these lines required to enable Verbose output
[cmdletbinding()]
param(
    [parameter(Mandatory = $true)]
    [string]$Serial
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"


# use -Expand to retrieve the LED status while retrieving the server
$server = (Get-IntersightComputeRackUnit `
    -Filter "Serial eq $($Serial)" `
    -Select LocatorLed `
    -Expand LocatorLed `
    ).Results

# the settings for the server are represented as an object
$setting_moid = (Get-IntersightComputeServerSetting `
    -Filter "Server.Moid eq '$($server.Moid)'" `
    ).Results.Moid

# toggle LED state
$led_state = $server.LocatorLed.ActualInstance.OperState
if($led_state -like 'on') {  
    $led_state = "Off"
} else {  
    $led_state = "On"
}
Write-Host "Toggling locator LED status to $($led_state)..."
Set-IntersightComputeServerSetting -Moid $setting_moid `
    -AdminLocatorLedState $led_state | Out-Null

# wait for application of new settings to complete
while( (Get-IntersightComputeServerSetting -Moid $setting_moid).ConfigState -like 'applying' )
{
    Write-Host '  waiting...'
    Start-Sleep -Seconds 1
}

# display current LED state
Write-Host "Done. The LED is now " -NoNewline
(Get-IntersightEquipmentLocatorLed -Moid $server.LocatorLed.ActualInstance.Moid).OperState
