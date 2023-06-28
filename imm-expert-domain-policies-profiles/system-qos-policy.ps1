# This script was auto-generated following the System QoS Policy video at https://www.youtube.com/watch?v=mn9Uqn6mZoA

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$mo1 = New-IntersightFabricSystemQosPolicy -Name "DevNet-SystemQoS" -Organization $Organization1 -Tags @()

$mo1
