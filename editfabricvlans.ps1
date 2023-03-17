#Get Default Organization
$defaultorg = Get-IntersightOrganizationOrganization -Name 'default'

#Get EthernetNetwork Policy
$vlanpolicy = Get-IntersightFabricEthNetworkPolicy -Name 'MyEthNetworkVlan_Policy' -Organization $defaultorg

$filter = "EthNetworkPolicy.Moid eq '" + $vlanpolicy.Moid + "'"

#Get FabricVlans attached to FabricEthernetNetwork Policy
$vlans = Get-IntersightFabricVlan -Filter $filter -Top 1000

#Loop through the VLANS attached to that policy and change AutoAllowOnUplinks to True on all vlans
foreach($vlan in $vlans.Results)
{
    if($vlan.VlanId -gt 1)
    {
            $json = Get-IntersightManagedObject -Moid $vlan.Moid -ObjectType "FabricVlan"
            $json = $json | ConvertFrom-Json
            $json.AutoAllowOnUplinks = $true
            Set-IntersightManagedObject -JsonRequestBody ($json | ConvertTo-Json)
    }
} 
