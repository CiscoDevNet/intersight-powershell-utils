# Intersight HCL (Hardware Compatibility List) and Advisories Examples

## Authorization

Example scripts use api-config.ps1 to set Intersight API configuration parameters.  More information on using the `Set-IntersightConfiguration` cmdlet is described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.

## Examples

---

### `hcl-status.ps1`

This script uses the HclStatus resource in Intersight's API to collect information on server hardware, firmware, and software (OS/driver) compatibility.
Details are exported to a .csv file specified by the -CsvFile command line argument (default is hcl_summary.csv).

---

### `advisory-export.ps1`

This script uses the AdvisoryInstance resource in Intersight's API to collect advisory (Security Advisory and Field Notice) information and affected devices.
Details are exported to a .csv file specified by the -CsvFile command line argument (default is advisory_export.csv).

---

### `contract-status.ps1`

This script uses the ContractInformation resource in Intersight's API to collect Contract Coverage Status.
Details are exported to a .csv file specified by the -CsvFile command line argument (default is contract_status_summary.csv).

---

### `dimm-serials.ps1`

This script collects DIMM Serial Number, Location, and Device Hostname information from Intersight's MemoryUnit API resource.
The information can be used in Field Notice affected device lookup.
Details are exported to a .csv file specified by the -CsvFile command line argument (default is dimm_serial_summary.csv).
