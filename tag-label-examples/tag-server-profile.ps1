# configure api signing params
. "$PSScriptRoot\..\api-config.ps1"

$Organization = Get-IntersightOrganizationOrganization -Name Demo-DevNet | Get-IntersightMoMoRef

# Add tags to the server profile named SJC07-R14 to set the location to SJC07
$ServerProfile = Get-IntersightServerProfile -Name SJC07-R14 -Organization $Organization

# Create a new list of tags containing all of the existing tags. If the tag
# key requested by the user already exists, leave it out of the list so we
# can add the value specified by the user.
$NewTags = @()
foreach ($Tag in $ServerProfile.Tags) {
    if ($Tag.Key -notmatch "Location") { $NewTags += $Tag }
}
$NewTags += Initialize-IntersightMoTag -Key "Location" -Value "SJC07"

$ServerProfile = $ServerProfile | Set-IntersightServerProfile -Tags $NewTags
$ServerProfile.Tags
