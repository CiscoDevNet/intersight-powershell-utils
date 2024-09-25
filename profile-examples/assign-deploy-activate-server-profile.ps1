# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$getMo1 = Get-IntersightServerProfile -Name "SJC07-R14" -Organization $Organization1

# Unassign the server from the server profile (only used in testing)
$mo1 = $getMo1 | Set-IntersightServerProfile -Action "Unassign"

# Assign the server to the server profile and deploy the server profile
$server = Get-IntersightComputeBlade -Name "SJC07-R14-FI-1-1-4" | Get-IntersightMoMoRef

$ScheduledActions11 = Initialize-IntersightPolicyScheduledAction -Action "Assign"
$ScheduledActions21 = Initialize-IntersightPolicyScheduledAction -Action "Deploy"
$ScheduledActions31 = Initialize-IntersightPolicyScheduledAction -Action "Activate" -ProceedOnReboot $true

$mo2 = $mo1 | Set-IntersightServerProfile -ScheduledActions @($ScheduledActions11,$ScheduledActions21,$ScheduledActions31) -Action "Deploy" -AssignedServer $server

$mo1
