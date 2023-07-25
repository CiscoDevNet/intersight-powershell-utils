# This script was auto-generated following the UCS Domain Profile video at https://www.youtube.com/watch?v=KpL9a_WFgjI

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$SwitchClusterProfile =New-IntersightFabricSwitchClusterProfile -Name "DevNet-DomainProfile" -Organization $Organization1 | Get-IntersightMoMoRef

$SwitchClusterProfileA = New-IntersightFabricSwitchProfile -Name "DevNet-DomainProfile-A" -SwitchClusterProfile $SwitchClusterProfile
$SwitchClusterProfileB = New-IntersightFabricSwitchProfile -Name "DevNet-DomainProfile-B" -SwitchClusterProfile $SwitchClusterProfile

$PolicyBucketList = @()
$PolicyBucketList += Get-IntersightFabricPortPolicy -Name "DevNet-6536-100-A" | Get-IntersightMoMoRef

$PolicyBucketList +=  Get-IntersightSyslogPolicy -Name "DevNet-Syslog" | Get-IntersightMoMoRef

$PolicyBucketList +=  Get-IntersightNetworkconfigPolicy -Name "DevNet-NetConnectivity" | Get-IntersightMoMoRef

$PolicyBucketList +=  Get-IntersightSnmpPolicy -Name "DevNet-Domain-SNMP" | Get-IntersightMoMoRef

$PolicyBucketList += Get-IntersightFabricSystemQosPolicy -Name "DevNet-SystemQoS" | Get-IntersightMoMoRef

$PolicyBucketList += Get-IntersightFabricSwitchControlPolicy -Name "DevNet-SwitchControl" | Get-IntersightMoMoRef
$moB = $SwitchClusterProfileB | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucketList
$moB

$PolicyBucketList += Get-IntersightFabricEthNetworkPolicy -Name "DevNet-VLAN-Fabric-A" | Get-IntersightMoMoRef

$PolicyBucketList += Get-IntersightFabricFcNetworkPolicy -Name "DevNet-VSAN-Fabric-A" | Get-IntersightMoMoRef
$moA = $SwitchClusterProfileA | Set-IntersightFabricSwitchProfile -PolicyBucket $PolicyBucketList
$moA
