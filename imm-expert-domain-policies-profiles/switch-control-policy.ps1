# This script was auto-generated following the Switch Control Policy video at https://www.youtube.com/watch?v=fIh71QJbYco

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$MacAgingSettings1 = Initialize-IntersightFabricMacAgingSettings -MacAgingOption "Custom" -MacAgingTime 14500 -ObjectType "FabricMacAgingSettings" -ClassId "FabricMacAgingSettings"
$UdldSettings1 = Initialize-IntersightFabricUdldGlobalSettings -MessageInterval 15 -RecoveryAction "None" -ObjectType "FabricUdldGlobalSettings" -ClassId "FabricUdldGlobalSettings"
$mo1 = New-IntersightFabricSwitchControlPolicy -EthernetSwitchingMode "EndHost" -FabricPcVhbaReset "Disabled" -FcSwitchingMode "EndHost" -MacAgingSettings $MacAgingSettings1 -Name "DevNet-SwitchControl" -Organization $Organization1 -ReservedVlanStartId 3910 -Tags @() -UdldSettings $UdldSettings1 -VlanPortOptimizationEnabled $false

$mo1
