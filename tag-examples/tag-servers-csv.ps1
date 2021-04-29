<#
Copyright (c) 2018 Cisco and/or its affiliates.
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
    [parameter(Mandatory=$true)]
    [string]$CsvFile
)

foreach($csv_row in (Import-Csv $CsvFile)) {
    # get the server Moid by searching for the server by serial number
    $myfilter = "Serial eq $($csv_row.serial)"
    $response = (Get-IntersightComputeRackUnitList -VarFilter $myfilter -Select Tags).ActualInstance.Results
    $moid = $response.moid

    if($response.count -eq 0) 
    {
        Write-Host $csv_row.serial + " is not a rack server. Skipping..."
        continue
    }

    # remove serial number because we don't need it anymore and don't want
    # it applied as a tag
    $csv_row.PSObject.Properties.Remove('serial')

    # create tags based on column headings in the CSV file
    $tags = @()
    $csv_row.PSObject.Properties | ForEach-Object {
        $temp = New-Object PSObject -Property @{Key="$($_.Name)"; Value="$($_.Value)"}
        if($_.Value -ne "") { $tags += $temp }
    }
    
    # apply the new tags to the server, overwriting all existing tags and
    # display the serial number on the screen for feedback
    $settings = @{Tags=$tags}
    (Set-IntersightComputeRackUnit -Moid $moid -ComputeRackUnit $settings).Serial
}