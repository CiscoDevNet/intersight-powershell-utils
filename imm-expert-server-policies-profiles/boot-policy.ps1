# This script was auto-generated following the Boot Server Policy video at https://youtu.be/nm5gmrx5B1E

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$BootDevices11 = Initialize-IntersightBootLocalDisk -Enabled $true -Name "M2" -ObjectType "BootLocalDisk" -Slot "MSTOR-RAID" -ClassId "BootLocalDisk"
$BootDevices21 = Initialize-IntersightBootVirtualMedia -Enabled $true -Name "DVD" -ObjectType "BootVirtualMedia" -Subtype "CimcMappedDvd" -ClassId "BootVirtualMedia"

$mo1 = New-IntersightBootPrecisionPolicy -BootDevices @($BootDevices11,$BootDevices21) -ConfiguredBootMode "Uefi" -EnforceUefiSecureBoot $false -Name "DevNet-LocalBoot-M2" -Organization $Organization1 -Tags @()
$mo1
