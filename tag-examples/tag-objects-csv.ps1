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

[cmdletbinding()]
param(
    [parameter(Mandatory = $true)]
    [string]$CsvFile
)

<#
.SYNOPSIS
Updates the existing tags of an Intersight object from a single CSV row.
.DESCRIPTION
Returns Intersight MoTags when given an object's current tags and a list of new or updated tags. Also returns a boolean indicating if the returned tags differ from the ExistingTags.
.PARAMETER ExistingTags
The current tags for the Intersight object.
.PARAMETER AdditionalTags
An object containing key:value pairs to use for updating tags. This is normally a single row of a CSV file.
#>
function UpdateTags {
    param(
        [Parameter(ValueFromPipeline, Mandatory = $true)]
        [AllowEmptyCollection()]
        [PSCustomObject[]]$ExistingTags,
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$AdditionalTags
    )
    begin {
        # initialize an empty hash for existing tags
        $mo_tags = @{}
        $flag = $false
    }
    process {
        # Build a dictionary of existing tags. This code will add all
        # existing tags to a hash.
        foreach ($t in $ExistingTags) {
            Write-Debug "Processing $($t.Key)"
            $mo_tags.Add($t.Key, $t.Value)
        }
    }
    end {
        foreach($i in $AdditionalTags.PSObject.Properties) {
            if ([string]::IsNullOrEmpty($i.Value)) { 
                continue 
            }
            if ( ! $mo_tags.ContainsKey($i.Name) ) {
                $flag = $true
            }
            elseif ( $mo_tags[$i.Name] -ne $i.Value ) {
                $flag = $true
            }
            $mo_tags[$i.Name] = $i.Value
        }
        # build the tag structure required by Intersight from this dictionary
        $local_new_tags = @()
        foreach ($k in $mo_tags.Keys) {
            $local_new_tags += Initialize-IntersightMoTag -Key $k -Value $mo_tags[$k]
        }
        return $flag, $local_new_tags
    }
}

# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

foreach ($csv_row in (Import-Csv $CsvFile)) {
    # get the object Moid by searching for the object by serial number
    $serial = $csv_row.serial
    $myfilter = "Serial eq '$($serial)'"
    $response = (Get-IntersightSearchSearchItem -Filter $myfilter -Select Tags).Results

    # remove serial number because we don't want it applied as a tag
    $csv_row.PSObject.Properties.Remove('serial')

    foreach ($object in $response) {

        
        switch ($object.ClassId) {
            NetworkElement {
                $update, $new_tags = UpdateTags -ExistingTags $object.Tags -AdditionalTags $csv_row
                if ($update) {
                    Set-IntersightNetworkElement -Moid $object.Moid -Tags $new_tags | Out-Null
                    Write-Host "$($serial): $($object.ClassId)"
                }
            }
            ComputeRackUnit {
                $update, $new_tags = UpdateTags -ExistingTags $object.Tags -AdditionalTags $csv_row
                if ($update) {
                    Set-IntersightComputeRackUnit -Moid $object.Moid -Tags $new_tags | Out-Null
                    Write-Host "$($serial): $($object.ClassId)"
                }
            }
            ComputeBlade {
                $update, $new_tags = UpdateTags -ExistingTags $object.Tags -AdditionalTags $csv_row
                if ($update) {
                    Set-IntersightComputeBlade -Moid $object.Moid -Tags $new_tags | Out-Null
                    Write-Host "$($serial): $($object.ClassId)"
                }
            }
            EquipmentChassis {
                $update, $new_tags = UpdateTags -ExistingTags $object.Tags -AdditionalTags $csv_row
                if ($update) {
                    Set-IntersightEquipmentChassis -Moid $object.Moid -Tags $new_tags | Out-Null
                    Write-Host "$($serial): $($object.ClassId)"
                }
            }
            Default { 
                # Write-Host $object.ClassId 
            }
        }
    }
}