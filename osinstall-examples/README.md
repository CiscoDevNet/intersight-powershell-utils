# Intersight OS Install examples

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.

## Examples

---

### `osinstall-san.ps1`

This script demonstrates the cmdlets used to install an operating system on a blade via Powershell

Pre-requisities:

-It requires the blade be associated to a server profile with vHBAs and a SAN Boot Policy

-It requires a software repository be defined in Intersight with links to the OS Installation ISO and SCU ISO

Variables to update the script:

$serial = Serial number of the blade

$osImageName = Name of the OS Install ISO in the Intersight Software Repository

$scuName = Name of the SCU ISO in the Intersight Software Repository

$osConfigFile = Built-in template config file in intersight for ESXi 7, use Get-IntersightOsConfigurationFile to see what other versions are available

$hostname = Hostname set by OS installer

$ipType = Static or DHCP for operating system IP

$password = Password set by OS installer

$nameServer = DNS Server set by OS installer

$os_ipv4_addr = OS IP Address

$os_ipv4_netmask = OS Netmask

$os_ipv4_gateway = OS Gateway

$targetWWPN = Installation Target WWPN (must match boot policy)

$lunID = Installation Target Lun (must match boot policy)

---

