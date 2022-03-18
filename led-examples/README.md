# Intersight LED examples

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.

## Examples

---

### `toggle-server-led.ps1`

This script toggles a server's Locator LED. The server is specified at the command line by `serial` number. 

This script demonstrates the use of the API's `expand` operator to avoid performing a second API call to the server's Locator LED endpoint in order to retrieve its current state.

This script demonstrates the use of the `ServerSetting` object to affect a server. Tasks like change the server's power state or Locator LED state are performed this way.

---

### `get-active-leds.ps1`

This script returns details about the objects whose locator LEDs are turned on. These objects could be blades, rack servers, chassis, or even disks. This output is a table like the one shown below but the script could be easily modified to create a CSV file instead.

| ObjectType | Name | Model | Serial | Moid |
|----|----|----|----|----|
| ComputeBlade | dev-02 | UCSB-B200-M5 | FLM2348022F | 61450d466f72612d337e607e |
| ComputeRackUnit | HV23 | UCSC-C220-M4S | FCH2114V31M | 5fd968f76f72612d337ceabb |
| ComputeRackUnit | HV29 | UCSC-C220-M4S | FCH2115V368 | 5fd968d36f72612d337ce593 |
| EquipmentChassis | prod2 | N20-C6508 | FOX1403GJ41 | 61450c346f72612d337e324a |