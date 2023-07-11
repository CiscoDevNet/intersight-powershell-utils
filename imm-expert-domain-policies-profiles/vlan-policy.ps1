# This script was auto-generated following the VLAN Policy video at https://www.youtube.com/watch?v=M3Yo86f-ksk

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$VlanPolicy = New-IntersightFabricEthNetworkPolicy -Name "DevNet-VLAN-Fabric-A" -Organization $Organization1 -Tags @()

New-IntersightFabricVlan -AutoAllowOnUplinks $true -EthNetworkPolicy $VlanPolicy -IsNative $true -Name "default" -VlanId 1

$McastPolicy = Get-IntersightFabricMulticastPolicy -Name "default-mcast"

for ($vlan = 100; $vlan -le 110; $vlan++)
{
    New-IntersightFabricVlan -AutoAllowOnUplinks $true -EthNetworkPolicy $VlanPolicy -IsNative $false -MulticastPolicy $McastPolicy -Name "VLAN_$vlan" -VlanId $vlan
}