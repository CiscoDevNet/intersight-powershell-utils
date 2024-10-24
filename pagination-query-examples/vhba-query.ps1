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

# Query adapter HostFcInterfaces and print Ancestor information
$Vhbas = Get-IntersightAdapterHostFcInterface -Top 1000 -InlineCount allpages -Select "Ancestors,Name,Wwnn,Wwpn" -Expand 'Ancestors'
foreach ($Vhba in $Vhbas.Results) {
    foreach ($Ancestor in $Vhba.Ancestors) {
        Write-Host "Ancestor Class, Moid: $($Ancestor.ActualInstance.ClassId), $($Ancestor.ActualInstance.Moid)"
    }
    Write-Host "VHBA Name: $($Vhba.Name)"
    Write-Host "WWNN: $($Vhba.Wwnn)"
    Write-Host "WWPN: $($Vhba.Wwpn)"
    Write-Host ""
}

# Query adapter HostFcInterface for specific blade server name
$ServerName = "B26-6454-Matt-1-1"
$ServerMoid = (Get-IntersightComputeBlade -Name $ServerName).Moid
$Vhbas = Get-IntersightAdapterHostFcInterface -Filter "Ancestors.Moid eq '$ServerMoid'" -Select "Name,Wwnn,Wwpn"
Write-Host "VHBA information for server: $ServerName"
foreach ($Vhba in $Vhbas.Results) {
    Write-Host "  VHBA Name: $($Vhba.Name)"
    Write-Host "  WWNN: $($Vhba.Wwnn)"
    Write-Host "  WWPN: $($Vhba.Wwpn)"
    Write-Host ""
}
