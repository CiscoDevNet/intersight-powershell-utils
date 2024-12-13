# Description: This script demonstrates how to query the Intersight API using OAuth2 client credentials.
# Usage: Run the script in a PowerShell environment with the required environment variables set,
# or specify your Client ID and Secret below.

$clientID = $env:INTERSIGHT_OAUTH2_CLIENT_ID
$clientSecret = $env:INTERSIGHT_OAUTH2_CLIENT_SECRET
$tokenEndpoint = "https://intersight.com/iam/token"

$body = @{
    grant_type = "client_credentials"
    client_id = $clientID
    client_secret = $clientSecret
}

$tokenResponse = Invoke-WebRequest -Uri $tokenEndpoint -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
$token = ($tokenResponse.Content | ConvertFrom-Json).access_token

$apiEndpoint = "https://intersight.com/api/v1/iam/Users"

$headers = @{
    Authorization = "Bearer $($token)"
}

$response = Invoke-WebRequest -Uri $apiEndpoint -Headers $headers
$response
