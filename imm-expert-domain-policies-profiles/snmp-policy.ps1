# This script was auto-generated following the SNMP Policy video at https://www.youtube.com/watch?v=ZNF-3kZA2ZY

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$SnmpTraps11 = Initialize-IntersightSnmpTrap -Destination "10.10.10.1" -Enabled $true -Port 162 -Type "Trap" -User "guest" -Version "V3" -ObjectType "SnmpTrap" -ClassId "SnmpTrap"
$SnmpUsers11 = Initialize-IntersightSnmpUser -AuthPassword "password" -AuthType "SHA" -Name "guest" -PrivacyPassword "password" -PrivacyType "AES" -SecurityLevel "AuthPriv" -ObjectType "SnmpUser" -ClassId "SnmpUser"

$mo1 = New-IntersightSnmpPolicy -AccessCommunityString "AccessString" -CommunityAccess "Disabled" -Enabled $true -Name "DevNet-Domain-SNMP" -Organization $Organization1 -SnmpPort 161 -SnmpTraps @($SnmpTraps11) -SnmpUsers @($SnmpUsers11) -SysContact "user@example.com" -SysLocation "SJC07" -Tags @() -V2Enabled $false -V3Enabled $false
$mo1
