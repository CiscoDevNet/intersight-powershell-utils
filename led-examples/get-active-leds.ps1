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

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# get the "parent" details of every locator LED that is on
$parent = (Get-IntersightEquipmentLocatorLed `
    -Filter "OperState eq on" `
    -Expand Parent). `
    Results.Parent.ActualInstance

# can't just display $parent as a table because some properties are
# under "AdditionalProperties" as a key:value dictionary
$my_output = @()
foreach($p in $parent)
{
    $item = [PSCustomObject]@{
        ObjectType = $p.ObjectType
        Name = $p.AdditionalProperties['Name']
        Model = $p.AdditionalProperties['Model']
        Serial = $p.AdditionalProperties['Serial']
        Moid = $p.AdditionalProperties['DeviceMoId']
    }
    $my_output += $item
}

# display as a table
$my_output | Sort-Object -Property ObjectType,Name | ft -AutoSize
