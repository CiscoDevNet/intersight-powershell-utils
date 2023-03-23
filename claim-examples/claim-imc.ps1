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

# This example gets Intersight claim code information from the IMC and claims the device in Intersight
# Additional error handling may be needed

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$imc_ip = "198.19.1.1"
$username = "admin"
$password = "YourIMCPassword"

$aaa_url= "https://$imc_ip/nuova"
$systems_url= "https://$imc_ip/connector/Systems"
$deviceconnections_url= "https://$imc_ip/connector/DeviceConnections"
$deviceidentifiers_url= "https://$imc_ip/connector/DeviceIdentifiers"
$securitytokens_url= "https://$imc_ip/connector/SecurityTokens"

#Login to IMC and get session cookie
$body = '<aaaLogin inName="' + $username + '" inPassword="' + $password + '" />'
$aaa = Invoke-RestMethod -Method 'Post' -Uri $aaa_url -Body $body -SkipCertificateCheck

#Set session cookie from login response
$headers = @{'Ucsmcookie' = 'ucsm-cookie=' + $aaa.aaaLogin.outCookie}

#Get device connector information
$systems = Invoke-RestMethod -Method 'GET' -Uri $systems_url -Headers $headers -SkipCertificateCheck
$deviceconnections = Invoke-RestMethod -Method 'GET' -Uri $deviceconnections_url -Headers $headers -SkipCertificateCheck
$deviceidentifiers = Invoke-RestMethod -Method 'GET' -Uri $deviceidentifiers_url -Headers $headers -SkipCertificateCheck
$securitytokens = Invoke-RestMethod -Method 'GET' -Uri $securitytokens_url -Headers $headers -SkipCertificateCheck

#Connect to Intersight and claim device, remember to specify your ApiKeyId and ApiKeyFilePath

$ApiParams = @{
BasePath = "https://intersight.com"
ApiKeyId = "your/api/key"
ApiKeyFilePath = $pwd.Path + "\SecretKey.txt"
HttpSigningHeader = @("(request-target)", "Host", "Date", "Digest")
}

Set-IntersightConfiguration @ApiParams

New-IntersightAssetDeviceClaim -SecurityToken $securitytokens.token -SerialNumber $deviceidentifiers.id
