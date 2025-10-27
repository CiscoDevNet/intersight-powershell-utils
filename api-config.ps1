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

# This script sets API configuration parameters for use in other scripts.
# All params are optional.  If not set, environment variables are used.
[cmdletbinding()]
param(
    <#
    The Intersight root URL for the API endpoint. The default is https://intersight.com
    Note : If your account is provisioned on the EMEA cluster, you must use the https://eu-central-1.intersight.com URL instead of intersight.com.
    #>
    [string]$BasePath = "https://intersight.com",
    
    [string]$ApiKeyId = $env:INTERSIGHT_API_KEY_ID,
    [string]$ApiKeyFilePath = $env:INTERSIGHT_API_PRIVATE_KEY
)

if (!$ApiKeyId) {
    $ApiKeyId = read-host -Prompt "Please supply a value for the ApiKeyId parameter: "
}
if (!$ApiKeyFilePath) {
    $ApiKeyFilePath = read-host -Prompt "Please supply a value for the ApiKeyFilePath parameter: "
}

# Configure Intersight API signing
$ApiParams = @{                       
    BasePath          = $BasePath
    ApiKeyId          = $ApiKeyId
    ApiKeyFilePath    = $ApiKeyFilePath
    HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}
Set-IntersightConfiguration @ApiParams
