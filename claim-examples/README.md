# Intersight Policy examples

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.

## Examples

---

### `imc-claim.ps1`

This example will retrieve device id and claim code from an IMC using generic REST cmdlets and then claim the device in Intersight with the Intersight Powershell SDK.

You will need to substitute your IMC IP, username, password as well as your Intersight ApiKeyId and ApiKeyFilePath paramaeters
