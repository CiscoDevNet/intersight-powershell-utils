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

# =============================================================================
# Create policy
# -----------------------------------------------------------------------------

# Get the Moid of the organization in which to place the policy

$my_org = Get-IntersightOrganizationOrganization -Name default 

# create the policy
$result = New-IntersightKvmPolicy `
    -Description 'created by PowerShell' `
    -Name KVMpowershell `
    -EnableLocalServerVideo $true `
    -EnableVideoEncryption $true `
    -Enabled $true `
    -MaximumSessions 4 `
    -Organization $my_org

Write-Host $result

# =============================================================================
# Update policy
# -----------------------------------------------------------------------------

# create the data structure representing updates to the policy
$tags = Initialize-IntersightMoTag -Key "location" -Value "houston" 

# update the policy by adding a tag and modifying the description
$result | Set-IntersightKvmPolicy -EnableLocalServerVideo $false -Tags @($tags)

# =============================================================================
# Remove policy
# -----------------------------------------------------------------------------

$result | Remove-IntersightKvmPolicy
