# Intersight Profile examples

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.  Scripts in this directory use the ..\api-config.ps1 script to set the config.

## Examples

---

### `domain-profile.ps1`

This script creates a UCS Domain Profile and supports actions to deploy, unassign, or delete the profile.

```powershell
domain-profile.ps1
```

### `deploy-activate-server-profile.ps1`

This example will deploy and activate an existing Server Profile using the ScheduledActions parameter.

```powershell
deploy-activate-server-profile.ps1
```

### `change-template.ps1`

This example will change the template linked to a server profile using the options specified in the parameters.

```powershell
change-template.ps1
```
