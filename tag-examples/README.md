# Intersight Tagging examples

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.

## Examples

---

### `tag-object-owner.ps1`

This script utilizes the search API and the audit log to find the person who created each object within an Intersight account. It then applies the tag `owner: emailaddress` to that object to make it easier to track the owner of a pool, policy, or profile in the UI. 

The script will **not** overwrite an object's existing `owner` tag, but that can easily be changed in the code. The philosophy behind this behavior is that people change roles within an organization and the person who originally created an object may no longer be the person who owns it.

This script depends on the file `classes.csv` and will only update those object types defined within the CSV. The command to perform the update is contained within the CSV, which keeps the script itself simple. It uses PowerShell `Invoke-Expression` to execute the command detailed in the CSV. Add rows to the CSV to be able to tag additional classes of objects.

---

### `tag-servers-csv.ps1`

This script **overwrites** a server's tags with the tags specified in a CSV file. 

```powershell
tag-servers-csv.ps1 -CsvFile servers.csv
```

**Caution**: a server's assigned license level is maintained as a tag, so be sure to include that in the CSV. The CSV should follow the format shown below. Every column (except serial number) represents the *key* for a tag that will be applied to a given server. License tier should follow the syntax shown here.

|serial|tag_key1|tag_key2|Intersight.LicenseTier|
|----|----|----|----|
|server1 serial|tag_value|tag_value|server1 license tier|
|server 2 serial|tag_value|tag_value|server1 license tier|
|server 3 serial|tag_value|tag_value|server1 license tier|



Here is an example with sample values in it. To add more tags, simply add more columns. The order of the columns does not matter.

|serial|function|rack|Intersight.LicenseTier|datacenter|
|----|----|----|----|----|
|FCH2009VRRJ|development|5|Advantage|austin|
|FCH2009VDDX|testing|6|Essentials|austin|
|FCH2009VVEB|development|2|Premier|houston|

---

### `tag-servers-locator.ps1`

This script adds the specified tag to every server in your Intersight account whose locator LED is turned on. This preserves all existing tags. The tag key and value are specified when calling the script as shown below.

```powershell
tag-servers-locator.ps1 -Key location -Value austin
```
