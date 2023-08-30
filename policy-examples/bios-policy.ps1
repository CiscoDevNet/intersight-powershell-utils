# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

# Create a new BIOS policy object with the desired settings:
$policyName = 'NewBIOSPolicy'
$policyDescription = 'A new BIOS policy created via PowerShell'

try {
    # Create the BIOS policy on Cisco Intersight:
    $policy = New-IntersightBiosPolicy -Name $policyName -Description $policyDescription -Organization $Organization1

    # Modify BIOS settings as needed
    $policy.CpuPerformance = 'Custom'
    $policy.CoreMultiProcessing = 'All'

    # Add any other desired BIOS settings
    # $policy.<SettingName> = <SettingValue>

    $policy = $policy | Set-IntersightBiosPolicy
}
catch {
    <#Do this if a terminating exception happens#>
    Write-Host "BIOS policy $policyName was not created."
    Write-Host $_.Exception.Message
    exit
}

Write-Host "BIOS policy $policyName was successfully created."
# Verify that the BIOS policy was created successfully:
Get-IntersightBiosPolicy -Name $policyName | Select-Object Name,Description,CpuPerformance,CoreMultiProcessing
