# Intersight Policy examples

## Authorization

Authorization is performed by every Intersight cmdlet. You must properly configure the Intersight PowerShell module parameters using the `Set-IntersightConfiguration` cmdlet as described in the [Getting Started](https://github.com/CiscoDevNet/intersight-powershell/blob/master/GettingStarted.md) page of the Intersight module code.

## Examples

---

### `storage-policy.ps1`

This script creates both a "Disk Group" policy and a "Storage" policy that function together to combine some number of physical disks into a single virtual disk that will be configured on a server. Intersight actually allows multiple virtual disks to be attached to a storage policy, but the script just serves the purpose of providing an example.

The **disk group** policy groups some number of physical disks at specific physical slot numbers into one particular RAID level.

The **storage** policy uses the disk group policy created above to create a virtual disk with a specific name.

The following command will put physical disks 1 and 2 into a RAID 1 array and create the virtual drive `vd0` from that array:

```powershell
storage-policy.ps1 -Raid 1 -vDisk vd0 -Disks 1, 2
```

Creating a Raid10 array requires two *groups* of drives, which are called span groups. In order to implement multiple span groups, use the optional `SpanGroups` parameter as shown below.

```powershell
storage-policy.ps1 -Raid 10 -vDisk vd0 -Disks 3, 4, 7, 8 -SpanGroups 2
```

### `kvm-policy.ps1`

This example will create, update, and delete a KVM policy. It shows how to create a policy using the SDK's `initialize` cmdlet; how to *update* a policy with a simple PowerShell object; and how to delete a policy using the `Moid` of that policy.

### `ntp-policy.ps1`

This example will create, update, and delete an NTP policy. It shows how to create a policy using the SDK's `initialize` cmdlet; how to *update* a policy with a simple PowerShell object; and how to delete a policy using the `Moid` of that policy.

### `lan-connectivity.ps1`

This example will create and delete a LAN Connectivity policy with a vNIC. It shows how to create the policy and lookup other required ethernet policies using the SDK.


### `chassis-snmppolicy.ps1`

This example will update an existing Chassis Profile with a reference to a new SNMP policy and deploy the changes to the Chassis Profile


### `edit-vlans-in-fabricethpolicy.ps1`

This example will update all the vlans in a Fabric Ethernet Network Policy to AutoAllowOnUplinks to True
