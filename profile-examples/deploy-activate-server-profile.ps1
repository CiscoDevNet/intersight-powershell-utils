# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$getMo1 = Get-IntersightServerProfile -Name "SJC07-R14" -Organization $Organization1
$ScheduledActions11 = Initialize-IntersightPolicyScheduledAction -Action "Deploy"
$ScheduledActions21 = Initialize-IntersightPolicyScheduledAction -Action "Activate" -ProceedOnReboot $true

$mo1 = $getMo1 | Set-IntersightServerProfile -ScheduledActions @($ScheduledActions11,$ScheduledActions21) -Action "Deploy"

$mo1
