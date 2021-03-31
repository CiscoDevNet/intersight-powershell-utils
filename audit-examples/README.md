# Intersight Audit log examples

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfigurationHttpSigning` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.

## Examples

---

### `tag-object-owner.ps1`

This script is actually in the [tag-examples](..\tag-examples) folder. It uses the audit log to discover the email of the person who created an object and applies that email address as the `owner` tag for that object.

---

### `audit-moid-history.ps1`

This script retrieves the entire history for an object within Intersight using the device `moid`. The moid for an object is found by browsing to that object (such as a policy or a profile) in the Intersight GUI. The moid will be a part of the URL and be in the format `5f9301c26275722d309cb1c8`.

The script will display to the screen a summary of every event in the audit log associated with that object, but it will also create a separate JSON file for each of those events. The JSON file contains the date of the event and the user that initiated the event, but it also includes the payload for the operation so that it can be examined or even recreated. Here is a sample from an event that modified an object by adding two tags:

```json
{
  "CreateTime": "2021-01-31T19:12:09.784Z",
  "Email": "user@example.com",
  "Event": "Modified",
  "Request": {
    "Tags": [
      {
        "Key": "owner",
        "Value": "admin_team"
      },
      {
        "Key": "location",
        "Value": "austin"
      }
    ]
  }
}
```
The `Request` portion of the audit record contains the payload.

The script is invoked like this:

```powershell
audit-moid-history.ps1 -Moid 5f9301c26275722d309cb1c8
```

---

### `audit-user-summary.ps1`

This very simple script employs displays the date of the most recent audit log entry for each managed object type for a specified user. It can be used to quickly determine what types of elements a user has been created, modifying, or deleting. A few examples of managed object types are:
* compute.RackUnit
* hyperflex.VcenterConfigPolicy
* ntp.Policy
* iam.ApiKey

It uses the `contains` keyword to match email address, so part of a user's email address can be used as the filter as shown below.
```powershell
audit-user-summary.ps1 -Email doron@example
```
---
### `audit-deleted-objects.ps1`
This script will display a summary of all objects *deleted* from Intersight within the last X days (number of days is specified at run time).

The script can be executed like this where `Days` is a required parameter:
```
audit-deleted-objects.ps1 -Days 7
```
Sample output is shown below.
|CreateTime|Email|Name|
|----|----|----|
|3/24/2021 2:10:19 PM|user1@cisco.com|sevt-ntp-policy
|3/24/2021 2:38:31 PM|user1@cisco.com|sevt2021-snmp
|3/24/2021 2:38:31 PM|user1@cisco.com|sevt2021-ntp
|3/24/2021 2:38:35 PM|user1@cisco.com|sevt-profile
|3/24/2021 3:53:03 PM|user2@cisco.com|sevt-ntp-policy
|3/24/2021 3:53:07 PM|user3@cisco.com|sevt-profile
|3/30/2021 11:31:33 PM|user2@cisco.com|iks-workshop-pool
