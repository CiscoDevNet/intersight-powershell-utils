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

# This script creates a new policy, updates it, and destroys it.

# =============================================================================
# Create policy
# -----------------------------------------------------------------------------

# Get the Moid of the organization in which to place the policy

$my_org = (Get-IntersightOrganizationOrganizationList `
        -VarFilter 'Name eq default' `
        -Select Moid).ActualInstance.Results | Select-Object -First 1

# create the data structure that represents the policy 

$policy = Initialize-IntersightKvmPolicy `
    -Description 'created by PowerShell' `
    -Name KVMpowershell `
    -EnableLocalServerVideo $true `
    -EnableVideoEncryption $true `
    -Enabled $true `
    -MaximumSessions 4 `
    -Organization @{Moid = $my_org.Moid }

# this is a temporary workaround for a bug that incorrectly adds an
# unnecessary property to this policy
$policy.PSObject.Properties.Remove('_0_ClusterReplicationNetworkPolicy')

# create the policy
$result = New-IntersightKvmPolicy -KvmPolicy $policy
Write-Host $result

# =============================================================================
# Update policy
# -----------------------------------------------------------------------------

# create the data structure representing updates to the policy
$tags = New-Object PSObject -Property @{Key = "location"; Value = "houston" }
$policy = New-Object PSObject -Property @{
    Tags                   = @($tags)
    EnableLocalServerVideo = $false
}

# update the policy by adding a tag and modifying the description
Update-IntersightKvmPolicy -Moid $result.Moid -KvmPolicy $policy

# =============================================================================
# Remove policy
# -----------------------------------------------------------------------------

Remove-IntersightKvmPolicy -Moid $result.Moid
