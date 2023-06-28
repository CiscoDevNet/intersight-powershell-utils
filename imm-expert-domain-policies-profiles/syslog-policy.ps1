# This script was auto-generated following the Syslog Policy video at https://www.youtube.com/watch?v=BpkZko3xuCg

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization1 = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

$LocalClients11 = Initialize-IntersightSyslogLocalFileLoggingClient -MinSeverity "Warning" -ObjectType "SyslogLocalFileLoggingClient" -ClassId "SyslogLocalFileLoggingClient"
$RemoteClients11 = Initialize-IntersightSyslogRemoteLoggingClient -Enabled $true -Hostname "10.10.10.1" -MinSeverity "Warning" -ObjectType "SyslogRemoteLoggingClient" -Port 514 -Protocol "Udp" -ClassId "SyslogRemoteLoggingClient"
$RemoteClients21 = Initialize-IntersightSyslogRemoteLoggingClient -Enabled $false -Hostname "0.0.0.0" -MinSeverity "Warning" -ObjectType "SyslogRemoteLoggingClient" -Port 514 -Protocol "Udp" -ClassId "SyslogRemoteLoggingClient"

$mo1 = New-IntersightSyslogPolicy -LocalClients @($LocalClients11) -Name "DevNet-Syslog" -Organization $Organization1 -RemoteClients @($RemoteClients11,$RemoteClients21) -Tags @()

$mo1
