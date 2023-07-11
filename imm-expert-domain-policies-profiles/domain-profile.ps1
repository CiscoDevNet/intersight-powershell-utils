# This script was auto-generated following the UCS Domain Profile video at https://www.youtube.com/watch?v=KpL9a_WFgjI

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$SwitchClusterProfile =New-IntersightFabricSwitchClusterProfile -Name "DevNet-DomainProfile" -Organization $Organization1 | Get-IntersightMoMoRef

$SwitchClusterProfileA = New-IntersightFabricSwitchProfile -Name "DevNet-DomainProfile-A" -SwitchClusterProfile $SwitchClusterProfile
$SwitchClusterProfileB = New-IntersightFabricSwitchProfile -Name "DevNet-DomainProfile-B" -SwitchClusterProfile $SwitchClusterProfile

$PolicyBucket33 = Get-IntersightFabricEthNetworkPolicy -Name "DevNet-VLAN-Fabric-A" | Get-IntersightMoMoRef
$moA = $SwitchClusterProfileA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket33
$moB = $SwitchClusterProfileB | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket33

$PolicyBucket44 = Get-IntersightFabricFcNetworkPolicy -Name "DevNet-VSAN-Fabric-A" | Get-IntersightMoMoRef
$moA = $moA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket44
$moB = $moB | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket44

$PolicyBucket55 = Get-IntersightFabricPortPolicy -Name "DevNet-6536-100-A" | Get-IntersightMoMoRef
$moA = $moA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket55

$PolicyBucket66 = Get-IntersightSyslogPolicy -Name "DevNet-Syslog" | Get-IntersightMoMoRef
$moA = $moA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket66
$moB = $moB | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket66

$PolicyBucket77 = Get-IntersightNetworkconfigPolicy -Name "DevNet-NetConnectivity" | Get-IntersightMoMoRef
$moA = $moA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket77
$moB = $moB | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket77

$PolicyBucket88 = Get-IntersightSnmpPolicy -Name "DevNet-Domain-SNMP" | Get-IntersightMoMoRef
$moA = $moA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket88
$moB = $moB | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket88

$PolicyBucket99 = Get-IntersightFabricSystemQosPolicy -Name "DevNet-SystemQoS" | Get-IntersightMoMoRef
$moA = $moA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket99
$moB = $moB | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket99

$PolicyBucket1010 = Get-IntersightFabricSwitchControlPolicy -Name "DevNet-SwitchControl" | Get-IntersightMoMoRef
$moA = $moA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket1010
$moB = $moB | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucket1010
