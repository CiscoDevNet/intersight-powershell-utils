<#
Copyright (c) 2021 Cisco and/or its affiliates.
This software is licensed to you under the terms of the Cisco Sample
Code License, Version 1.0 (the "License"). You may obtain a copy of the
License at
               https://developer.cisco.com/docs/licenses
All use of the material herein must be in accordance with the terms of
the License. All rights not expressly granted by the License are
reserved. Unless required by applicable law or agreed to separately in
writing, software distributed under the License is distributed on an "AS
IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied.
#>

# these lines required to enable Verbose output
[cmdletbinding()]
param()

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

# each line in the CSV file enumerates a different class and the cmdlet
# required to update the tags for objects of that class
foreach ($class in Import-Csv classes.csv) {

    # use the search API to find all objects of the given class, returning
    # only the Tags for each object to minimize payload size
    $searchItems = (Get-IntersightSearchSearchItem -Filter "ClassId eq $($class.classid)" -Select Tags).Results 
    foreach ($p in $searchItems) {

        # create a new array of Tags and copy all of the existing tags
        $update_needed = $true
        $new_tags = @()
        foreach ($t in $p.Tags) {
            # add the existing tag
            $new_tags += $t
            if ($t.Key -like 'owner') {
                # owner tag is already set, so there is no need to push
                # an update to the existing managed object
                $update_needed = $false
            }
        }

        # get the email of the author and write the owner tag if no owner tag exists
        if ($update_needed) {
            # retrieve the email address of the person who created the object
            # from the audit log
            try {
                $email = (Get-IntersightAaaAuditRecord -Filter "ObjectMoid eq '$($p.Moid)' and Event eq Created" -Select Email).Results.Email
            }
            catch {
                $email = ""
                Write-Error "Error auditing $($class.classid) with moid $($p.Moid)"
            }
            # if the audit record does not exist, set the author to "unknown"
            $author = $null -eq $email ? "unknown" : ($email -split '@')[0] 

            # add the owner to the list of tags
            $new_tags += Initialize-IntersightMoTag -Key "owner"  -Value $author
            $moid = $p.Moid
            try {
                # the "set" command for the class is pulled from the CSV file
                $command = $class.setcmd + ' -Moid $moid -Tags $new_tags'
                Write-Host (Invoke-Expression -Command $command).Name " owner: $($author)"
            }
            catch {
                Write-Error "Error updating tags for $($class.classid) with moid $($moid) with owner=$($author)"
            }
            Write-Verbose "$($class.classid):$($moid) --> author tag set to $($author)"
        }
    }
}
