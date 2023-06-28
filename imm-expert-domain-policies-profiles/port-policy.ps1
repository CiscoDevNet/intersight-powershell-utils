# This script was auto-generated following the Port Policy video at https://www.youtube.com/watch?v=C7td33tmkmw

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

# 6536 Port Policy
$PortPolicy = New-IntersightFabricPortPolicy -DeviceModel UCSFI6536 -Name "DevNet-6536-100-A" -Organization $Organization1 -Tags @()

# 16G FC breakout
New-IntersightFabricPortMode -CustomMode "BreakoutFibreChannel16G" -PortIdEnd 36 -PortIdStart 35 -PortPolicy $PortPolicy -SlotId 1

# FC Uplink PC config
$FcPorts = @()
for($agg=35; $agg -le 36; $agg++)
{
    for($port=1; $port -le 4; $port++)
    {
        $PcPort = Initialize-IntersightFabricPortIdentifier -AggregatePortId $agg -PortId $port -SlotId 1
        $FcPorts += $PcPort
    }
}
New-IntersightFabricFcUplinkPcRole -AdminSpeed _16Gbps -PcId 10 -PortPolicy $PortPolicy -Ports $FcPorts -VsanId 100

# Eth Uplink PC config
$FlowControl = New-IntersightFabricFlowControlPolicy -Name "DevNet-FlowControl" -Organization $Organization1 -Tags @()
$LinkAggregation = New-IntersightFabricLinkAggregationPolicy -Name "DevNet-LinkAggregation" -Organization $Organization1 -Tags @()
$LinkControl = New-IntersightFabricLinkControlPolicy -Name "DevNet-LinkControl" -Organization $Organization1 -Tags @()
$PcPort31 = Initialize-IntersightFabricPortIdentifier -PortId 31 -SlotId 1
$PcPort32 = Initialize-IntersightFabricPortIdentifier -PortId 32 -SlotId 1
New-IntersightFabricUplinkPcRole -AdminSpeed "Auto" -FlowControlPolicy $FlowControl -LinkAggregationPolicy $LinkAggregation -LinkControlPolicy $LinkControl -PcId 2 -PortPolicy $PortPolicy -Ports @($PcPort31,$PcPort32)

# Server Port config
for($port=1; $port -le 8; $port++)
{
    New-IntersightFabricServerRole -AutoNegotiationDisabled $false -Fec "Auto" -PortId $port -PortPolicy $PortPolicy -PreferredDeviceId 1 -PreferredDeviceType "Chassis" -SlotId 1
}
for($port=9; $port -le 16; $port++)
{
    New-IntersightFabricServerRole -AutoNegotiationDisabled $false -Fec "Auto" -PortId $port -PortPolicy $PortPolicy -PreferredDeviceId 2 -PreferredDeviceType "Chassis" -SlotId 1
}
