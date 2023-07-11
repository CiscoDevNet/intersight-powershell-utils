# Intersight Domain Profile and Policy examples based on the IMM Expert video series at https://www.youtube.com/playlist?list=PLIlKAL_0d4EyjLS_chD-BecRc3NrT8O6X

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.  Scripts in this directory use the ..\api-config.ps1 script to set the config.

## Policy Examples

---

### `port-policy.ps1`

This script creates a Port Policy for UCS Domains based on the video overview at https://www.youtube.com/watch?v=C7td33tmkmw .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
port-policy.ps1
```

### `vlan-policy.ps1`

This script creates a VLAN Policy for UCS Domains based on the video overview at https://www.youtube.com/watch?v=M3Yo86f-ksk .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
vlan-policy.ps1
```

### `vsan-policy.ps1`

This script creates a VSAN Policy for UCS Domains based on the video overview at https://www.youtube.com/watch?v=fwmRweCfip4 .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
vsan-policy.ps1
```

### `syslog-policy.ps1`

This script creates a Syslog Policy for UCS Domains based on the video overview at https://www.youtube.com/watch?v=BpkZko3xuCg .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
syslog-policy.ps1
```

### `net-connectivity-policy.ps1`

This script creates a Network Connectivity Policy for UCS Domains based on the video overview at https://youtu.be/bPxvcf5PM0U .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
net-connectivity-policy.ps1
```

### `snmp-policy.ps1`

This script creates a SNMP Policy for UCS Domains based on the video overview at https://www.youtube.com/watch?v=ZNF-3kZA2ZY .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
snmp-policy.ps1
```

### `system-qos-policy.ps1`

This script creates a System QoS Policy for UCS Domains based on the video overview at https://www.youtube.com/watch?v=mn9Uqn6mZoA .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
system-qos-policy.ps1
```

### `switch-control-policy.ps1`

This script creates a Switch Control Policy for UCS Domains based on the video overview at https://www.youtube.com/watch?v=fIh71QJbYco .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
switch-control-policy.ps1
```

## Profile Examples

---

### `domain-profile.ps1`

This script creates a Domain Profile for UCS Domains based on the video overview at https://www.youtube.com/watch?v=KpL9a_WFgjI .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
domain-profile.ps1
```
