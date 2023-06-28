# This script was auto-generated following the Network Connectivity Policy video at https://youtu.be/bPxvcf5PM0U

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$mo1 = New-IntersightNetworkconfigPolicy -AlternateIpv4dnsServer "171.70.168.183" -EnableDynamicDns $false -EnableIpv4dnsFromDhcp $false -EnableIpv6 $false -Name "DevNet-NetConnectivity" -Organization $Organization1 -PreferredIpv4dnsServer "172.28.225.2" -Tags @()

$mo1
