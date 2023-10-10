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
.SYNOPSIS
    Example unbind and rebind of a profile to an existing template

.DESCRIPTION
    Example unbind and rebind of a profile to an existing template

.PARAMETER <ProfileName>
    Profile to perform the action on 

.PARAMETER <DestinationTemplateName>
    Template to bind profile to   

.EXAMPLE
    change-template.ps1
    change-template.ps1 -ProfileName my_service_profile -DestinationTemplateName new_template
#>

param(
    [string]$ProfileName="my_service_profile",
    [string]$DestinationTemplateName="new_template"
)

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$org = Get-IntersightOrganizationOrganization -Name default

$profile = Get-intersightserverprofile -Name $ProfileName -Organization $org 

$destTemplate = Get-IntersightServerProfileTemplate -Name $DestinationTemplateName -Organization $org
$destTemplateMoRef = Initialize-IntersightMoMoRef -Moid $destTemplate.Moid -Objecttype ($destTemplate.ObjectType | Out-String)

#unbind template from server profile
$profile | Set-IntersightServerProfile -SrcTemplate $null

#bulkmomerger of template to profile to mimic UI
$source = Initialize-IntersightMoBaseMo -Moid $destTemplate.Moid -ClassId $destTemplate.ClassId -Objecttype ($destTemplate.ObjectType | Out-String)
$target = Initialize-IntersightMoBaseMo -Moid $profile.Moid -ClassId $profile.ClassId -ObjectType ($profile.ObjectType | Out-String)

New-IntersightBulkMoMerger -MergeAction Replace -Sources $source -Targets $target

#bind to new template
Get-IntersightServerProfile -Name $ProfileName | Set-IntersightServerProfile -SrcTemplate $destTemplateMoRef  
