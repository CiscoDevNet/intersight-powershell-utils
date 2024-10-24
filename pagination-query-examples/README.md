# Intersight Policy examples

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.

## Examples

---

### `auditlog-pagination.ps1`

This script provides a basic example of paginating the results of the aaa.AuditRecord endpoint as this can easily have 1000's of entries which cannot be retrieved in a single call.
