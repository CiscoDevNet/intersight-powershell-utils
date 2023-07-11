# This script was auto-generated following the VSAN Policy video at https://www.youtube.com/watch?v=fwmRweCfip4

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$VsanPolicy = New-IntersightFabricFcNetworkPolicy -Name "DevNet-VSAN-Fabric-A" -Organization $Organization1 -Tags @()

New-IntersightFabricVsan -FcNetworkPolicy $VsanPolicy -FcoeVlan 4092 -Name "VSAN-12-A" -VsanId 12 -VsanScope "Uplink"
