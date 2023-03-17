#Get default organization
$defaultorg = Get-IntersightOrganizationOrganization -Name 'default'

#Get chassis profile to modify
$chassisprofile = Get-IntersightChassisProfile -Name 'MyChassisProfile' -Organization $defaultorg

#Get existing SNMP policy to add to chassis profile and create a reference
$snmppolicy = Get-IntersightSnmpPolicy -Name 'MySnmpPolicy' -Organization $defaultorg
$snmppolicyMoRef = Initialize-IntersightMoMoRef -Moid $snmppolicy.Moid -Objecttype ($snmppolicy.ObjectType | Out-String)

#Create policybucket array
$policybucket = @()

#Ignore null values and add existing policy buckets into the array except for any existing SNMP policy in the chassis profile
if($chassisprofile.PolicyBucket.ActualInstance)
{
    $policybucket += $chassisprofile.PolicyBucket.ActualInstance | Where-Object { $_.ObjectType –ne "SnmpPolicy" }
}

#Add SNMP policy reference to policybucket array
$policybucket += $snmppolicyMoRef

#Attach policy bucket to chassis profile
$chassisprofile | Set-IntersightChassisProfile -PolicyBucket $policybucket

#Deploy changes on chassis profile
$chassisprofile | Set-IntersightChassisProfile -Action 'Deploy' 
