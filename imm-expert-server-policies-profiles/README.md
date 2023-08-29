# Intersight Server Profile and Policy examples based on the IMM Expert video series at https://www.youtube.com/playlist?list=PLIlKAL_0d4EyjLS_chD-BecRc3NrT8O6X

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.  Scripts in this directory use the ..\api-config.ps1 script to set the config.

## Policy Examples

---

### `bios-policy.ps1`

This script creates a BIOS Policy for Servers based on the video overview at https://www.youtube.com/watch?v=yGobMGzuNS8 .  The code is auto-generated from UI actions using Intersight's API Interceptor Chrome extension.

```powershell
bios-policy.ps1
```
