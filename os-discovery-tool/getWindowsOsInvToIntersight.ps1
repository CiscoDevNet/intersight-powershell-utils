<#

.SYNOPSIS
ODT stands for OS Discovery Toolset.
This is a simple ODT script to Discover Windows OS Inventory and TAG Servers managed by Cisco Intersight.
It can be run via the Windows Task Scheduler to ensure regular refresh and is powered by Windows Powershell 7.0+

.DESCRIPTION
This tool needs to have generateSecureCredentials.ps1 to be run beforehand.
It uses Windows (Powershell) session credentials for Active Directory Lookups.

You need the following files generated:
1. Encrypted Intersight Secret Key file

It also needs the path to a config file (discovery_config_windows.json).

.EXAMPLE
>  .\getWindowsOsInvToIntersight.ps1 $env:USERPROFILE\Documents\discovery_config_windows.json

.NOTES
This script can be run via the Windows Task scheduler OR SCOM

.LINK
https://github.com/CiscoDevNet/intersight-powershell-utils

#>

Param (
    [Parameter(Mandatory=$true)]
    [string]$configfile
)

function CheckAndInstallModule {
    param (
        [string] $ModuleName  
        )
    # Check for latest available Intersight PowerShell module 
    $latestModule = Find-Module -Name $ModuleName 

    # check the Intersight.PowerShell module
    $psModule = Get-Module -Name $ModuleName -ListAvailable
    if($psModule -ne $null -and $psModule.Length -gt 0){
        $latestInstallModule = $psModule[0].Version
    }
    if(-not [string]::IsNullOrEmpty($latestInstallModule)){
        
        if($latestModule.Version -ne $latestInstallModule){
            Write-Host "Updating the $ModuleName module to the latest version : $($latestModule.Version)"
            Update-Module -Name $ModuleName 
        }
        else{
            Write-Host "Latest $ModuleName module version : $latestInstallModule is already installed."
        }
    }
    else{
        write-host "$ModuleName module not found, installing the latest $ModuleName module : version $($latestModule.Version)"
        Install-Module -Name $ModuleName
    }
    
}
Function CheckPowerShellVersion
{
    # powershell version should be 7.3.3 and above
    if (-not (($PSVersionTable.PSVersion.Major -ge 7) -and ($PSVersionTable.PSVersion.Minor -ge 3))){
         throw "The PowerShell version is less than 7.3.3, please upgrade to PowerShell 7.3.3 or higher."
    }
}

# check the required PowerShell version
CheckPowerShellVersion

CheckAndInstallModule -ModuleName "Intersight.PowerShell"

try {
    Import-Module Intersight.PowerShell -ErrorAction Stop
    Import-Module ActiveDirectory -WarningAction silentlyContinue
} catch [System.Exception] {
    Write-Host -ForeGroundColor Red "Dependent Libraries not installed. Please check that the Cisco Intersight Powershell SDK and Active Directory packages are installed, $_"
    exit
}

$storage_device_map = @{
    "SWRAID"         = "RAID";
    "MEGARAID"       = "SAS RAID";
    "AHCI"           = "ahci";
    "Modular Raid"   = "SAS RAID";
    "SAS HBA"        = "SAS HBA";
    "NVMe"           = "Flash";
    "LOM"            = "LOM";
    "Inter(R) i350"  = "LOM";
}

$datestring = (get-date).toUniversalTime().ToFileTimeUtc()

Function WriteLog
{
    Param ([object]$env, [string]$loglevel, [string]$logstring)
    $logfile = $env.config.logfile_path +"\discovery_"+$datestring+".log"
    $stamp=(get-date)
    $logline = "["+$stamp+"]"+$loglevel+"::"+$logstring
    Add-content $logfile -value $logline
}

Function GetEnvironment
{
    if(Test-Path -Path $configFile){
        Return (Get-Content -Raw -Path $configfile | ConvertFrom-Json)
    }
    throw "ConfigFile does not exist, Please provide a valid configfile path"
}

Function StartLogging {
    Param([object]$env)
    $outfile = $env.config.logfile_path+"\discovery_"+$datestring+".out"
    start-transcript -append -path $outfile
}

Function GetWindowsHosts {
    Param([object]$env)
    $filter = $env.config.filter
    Write-Host "Filter: "$filter
    Return (Get-ADComputer -Filter $filter).Name
}

Function GetWindowHostSerial {
    Param([string]$hostname)
    Return (Get-CimInstance -ClassName Win32_BIOS -ComputerName $hostname | Select-Object SerialNumber).SerialNumber.ToString()
}

Function GetComputeType {
    Param([object]$hostname)
    $model = (Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $hostname | select Model).Model
    Write-Host "Host Model: " $model
    WriteLog $env "INFO" "Host model: $model"
    # colusa servers PID are UCSC-C3K-M4SRB and UCS-S3260-M5 for M4 and M5 servers respectively
    # colusa is stored as compute.blade mo on intersight, so return blade compute type
    if($model -like "*UCSB*" -or $model -like "*UCSX*" -or $model -like "UCS-S3260*" -or $model -like "UCSC-C3K*") {
        Return "blade"
    }
    else {
        if($model -like "*UCSC*" -or $model -like "*HX*") {
            Return "rack"
        }
        else {
            Return "unknown"
        }
    }
}

Function GetISO8601Time {
    return ((Get-Date).ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ss.fffZ" ))
}

Function GetTAGPrefix {
    Return "intersight.server."
}

#Os Details
Function GetOSDetails{
    Param([string]$hostname)
    Write-Host "GetOSDetails: $hostname"
    $prefix = GetTAGPrefix
    $updateTS = GetISO8601Time

    $osClass = Get-CimInstance -ClassName Win32_OperatingSystem -Computer $hostname
    $osString = $osClass.caption
    $sp = $osClass.ServicePackMajorVersion
    $arch = $osClass.osarchitecture

    $vendor, $name, $type, $version, $release, $level = $osString.split(' ')
    $osInvCollection = New-Object System.Collections.ArrayList
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.updateTimestamp"
    $osInv | Add-Member -type NoteProperty -name Value -Value $updateTS
    $count = $osInvCollection.Add($osInv)

    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.vendor"
    $osInv | Add-Member -type NoteProperty -name Value -Value $vendor
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.name"
    $osInv | Add-Member -type NoteProperty -name Value -Value $name
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.arch"
    $osInv | Add-Member -type NoteProperty -name Value -Value $arch
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.type"
    $osInv | Add-Member -type NoteProperty -name Value -Value $type
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.kernelVersionString"
    if($release -ne "") {
        $osInv | Add-Member -type NoteProperty -name Value -Value $name" "$type" "$version" "$release
    }
    else
    {
        $osInv | Add-Member -type NoteProperty -name Value -Value $name" "$type" "$version
    }
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.releaseVersionString"
    $osInv | Add-Member -type NoteProperty -name Value -Value $release
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.updateVersionString"
    if($sp -ne "0") {
        $osInv | Add-Member -type NoteProperty -name Value -Value "SP"$sp.ToString()
    }
    else
    {
        $osInv | Add-Member -type NoteProperty -name Value -Value ""
    }
    $count = $osInvCollection.Add($osInv)

    Return $osInvCollection
}

#Driver details
Function GetDriverDetails {
    Param([string]$hostname)
    Write-Host "GetDriverDetails: $hostname"
    $prefix = GetTAGPrefix
    $osInvCollection = New-Object System.Collections.ArrayList
    $driverList = New-Object Collections.Generic.List[string]
    #vNIC details
    Write-host "[$hostname]: Retrieving Network Driver Inventory..."
    $netDevList = Get-CimInstance Win32_PnPSignedDriver -Computer $hostname | select DeviceName, FriendlyName,DriverVersion, Description |
                    where {
                        $_.Devicename -like "*Ethernet*" -or
                        $_.Devicename -like "*FCoE*" -or
                        $_.Devicename -like "*LOM*" -or
                        $_.Devicename -like "*Intel(R) i350*" -or
                        $_.Devicename -like "*Nvidia*"
                    }
    $devcount = 0

    foreach ($netdev in $netDevList) {
        $key = $prefix+"os.driver."+$devcount+".name"
        $osInv = New-Object System.Object
        $osInv | Add-Member -type NoteProperty -name Key -Value $key
        if($netdev.DeviceName -like "*Ethernet*") {
            $netdrivername = (Get-CimInstance -class "Win32_NetworkAdapter" -namespace "root\CIMV2" -ComputerName $hostname) | select Name, MACAddress, ServiceName |
                    where { $_.Name -eq $netdev.FriendlyName -and $_.MACAddress}

            if($netdrivername.ServiceName -eq "ENIC") {
                $osInv | Add-Member -type NoteProperty -name Value -Value "enic"
            }
            elseif($netdrivername.ServiceName -eq "NENIC")
            {
                $osInv | Add-Member -type NoteProperty -name Value -Value "nenic"
            }
            elseif($netdrivername.ServiceName)
            {
                $osInv | Add-Member -type NoteProperty -name Value -Value $netdrivername.ServiceName
            }
            else
            {
                continue
            }
        }
        elseif($netdev.DeviceName -like "*FCoE*")
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value "fnic"
        }
        elseif($netdev.DeviceName -like "*LOM*")
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value "Ethernet"
        }
        elseif($netdev.DeviceName -like "*Intel(R) i350*")
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value "Ethernet"
        }
        elseif($netdev.DeviceName -like "*Nvidia*")
        {
            Write-host "[$hostname]: NVIDIA GPU Detected, retrieving GPU inventory..."

            # Nvidia-smi will be installed either under 'Program Files' folder or the 'System32' folder in C drive
            $nvidiasmi =  Invoke-Command -ComputerName $hostname -ScriptBlock{Get-ChildItem -Path 'C:\Program Files\', 'C:\Windows\System32\DriverStore\' -Recurse -Include nvidia-smi.exe}

            if($nvidiasmi)
            {
                foreach($cmd in $nvidiasmi)
                {
                    # Determine if Graphics driver or compute driver is installed
                    $command = "'$cmd' --query-gpu=driver_model.current --format=csv,no header"
                    $mode = Invoke-Command -ComputerName $hostname -ScriptBlock ([ScriptBlock]::Create("& $command"))

                    if($mode -contains "WDDM")
                    {
                        Write-host "[$hostname]: NVIDIA Graphics Driver is installed"
                        $osInv | Add-Member -type NoteProperty -name Value -Value "nvidia(graphics)"
                    }
                    elseif($mode -contains "TCC")
                    {
                        Write-host "[$hostname]: NVIDIA Compute Driver is installed"
                        $osInv | Add-Member -type NoteProperty -name Value -Value "nvidia(compute)"
                    }
                    else
                    {
                        Write-Host -ForegroundColor Yellow "[$hostname]: NVIDIA GPU mode is unidentified. Skipping adding the driver information."
                    }

                    # avoid traversing multiple paths of nvidia-smi.exe
                    break
                }
            }
            else
            {
                Write-Host -ForegroundColor Yellow "[$hostname]: No NVIDIA GPU driver found"
            }

        }
        else
        {
            continue
        }
        if(!$driverList.contains($osInv.Value)) {
            $driverList.Add($osInv.Value)
            $count = $osInvCollection.Add($osInv)
            Clear-Variable -Name osInv
            $osInv = New-Object System.Object
            $key = $prefix+"os.driver."+$devcount+".description"
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $osInv | Add-Member -type NoteProperty -name Value -Value $netdev.Description
            $count = $osInvCollection.Add($osInv)
            Clear-Variable -Name osInv
            $osInv = New-Object System.Object
            $key = $prefix+"os.driver."+$devcount+".version"

            # Nvidia GPU driver version needs special reformatting
            if($netdev.DeviceName -like "*Nvidia*")
            {
                $osInv | Add-Member -type NoteProperty -name Key -Value $key

                # Last five digits in DriverVersion value is the actual Nvidia GPU Driver Version
                $nvidiaDriverVersion = $netdev.DriverVersion -replace '\.', ''
                $nvidiaDriverVersion = $nvidiaDriverVersion.Substring($nvidiaDriverVersion.Length - 5).Insert(3,".")

                $osInv | Add-Member -type NoteProperty -name Value -Value $nvidiaDriverVersion
            }
            else
            {
                $osInv | Add-Member -type NoteProperty -name Key -Value $key
                $osInv | Add-Member -type NoteProperty -name Value -Value $netdev.DriverVersion
            }

            $count = $osInvCollection.Add($osInv)
            $devcount = $devcount + 1
        }
    }

    #storage controller details:
    Write-host "[$hostname]: Retrieving Storage Driver Inventory..."
    $storageControllerList = Get-CimInstance Win32_PnPSignedDriver -Computer $hostname | select DeviceName, DriverVersion |
                    where {
                        $_.devicename -like "*RAID SAS*" -or
                        $_.devicename -like "*SAS RAID*" -or
                        $_.devicename -like "*SWRAID*" -or
                        $_.devicename -like "*AHCI*" -or
                        $_.devicename -like "*Modular Raid*" -or
                        $_.devicename -like "*NVMe*" -or
                        $_.devicename -like "*NVM Express*" -or
                        $_.devicename -like "*U.2*" -or
                        $_.devicename -like "*LOM*" -or
                        $_.devicename -like "*SAS HBA*" -or
                        $_.devicename -like "*S3260 Dual Raid*" -or
                        $_.devicename -like "*S3260 Dual Pass Through*"
                    }

    foreach ($storageController in $storageControllerList) {
        $stdrivername = (Get-CimInstance -class "Win32_SCSIController" -namespace "root\CIMV2" -ComputerName $hostname) | select Name, DriverName |
                where { $_.Name -like $storageController.DeviceName }

        $key = $prefix+"os.driver."+$devcount+".name"
        Clear-Variable -Name osInv
        $osInv = New-Object System.Object
        $osInv | Add-Member -type NoteProperty -name Key -Value $key
        if(($storageController.DeviceName -like "*LSI*" -and
                $storageController.DeviceName -like "*Mega*") -or
                $storageController.DeviceName -like "*SAS RAID*" -or
                $storageController.DeviceName -like "*RAID SAS*")
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value $storage_device_map["MEGARAID"]
        }
        elseif($storageController.DeviceName -like "*AHCI*")
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value $storage_device_map["AHCI"]
        }
        elseif(($storageController.DeviceName -like "*Modular Raid*") -or
               ($storageController.DeviceName -like "*S3260 Dual Raid*"))
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value $storage_device_map["Modular Raid"]
        }
        elseif(($storageController.DeviceName -like "*SAS HBA*") -or
               ($storageController.DeviceName -like "*S3260 Dual Pass Through*"))
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value $storage_device_map["SAS HBA"]
        }
        elseif(($storageController.DeviceName -like "*NVMe*") -or
               ($storageController.DeviceName -like "*U.2*") -or ($storageController.DeviceName -like "*NVM Express*"))
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value $storage_device_map["NVMe"]
        }
        elseif($storageController.DeviceName -like "*LOM*")
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value $storage_device_map["LOM"]
        }
        elseif($storageController.DeviceName -like "*i350*")
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value $storage_device_map["LOM"]
        }
        elseif($storageController.DeviceName -like "*SWRAID*")
        {
            $osInv | Add-Member -type NoteProperty -name Value -Value $storage_device_map["SWRAID"]
        }
        else
        {
            continue
        }


        if(!$driverList.Contains($osInv.Value)) {
            $driverList.Add($osInv.Value)
            $count = $osInvCollection.Add($osInv)
            Clear-Variable -Name osInv
            $osInv = New-Object System.Object
            $key = $prefix+"os.driver."+$devcount+".description"
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $osInv | Add-Member -type NoteProperty -name Value -Value $storageController.DeviceName
            $count = $osInvCollection.Add($osInv)
            Clear-Variable -Name osInv
            $osInv = New-Object System.Object
            $key = $prefix+"os.driver."+$devcount+".version"
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $driverversion = $storageController.DriverVersion
            $major, $minor, $version, $suffix = $driverversion.split(".")

            $driverversion = $major+"."+$minor+"."+$version+"."+$suffix
            $osInv | Add-Member -type NoteProperty -name Value -Value $driverversion

            $count = $osInvCollection.Add($osInv)
            $devcount = $devcount + 1
        }
    }

    Return $OsInvCollection
}

Function ProcessHostOsInventory {
    Param([object]$env, [string]$hostname)

    WriteLog $env "INFO" "[$hostname]:Retrieving OS Inventory..."
    $osInvCollection = GetOSDetails $hostname

    WriteLog $env "INFO" "[$hostname]:Retrieving Device Driver Inventory..."
    $driverInvCollection = GetDriverDetails $hostname

    $combinedCollection = New-Object System.Collections.ArrayList
    $combinedCollection += $osInvCollection
    $combinedCollection += $driverInvCollection

    $osInvJson = ConvertTo-Json -Depth 2 @{ "Tags"=foreach ($item in $combinedCollection) {@{Key=$item.Key; Value=$item.Value}}}

    WriteLog $env "INFO" "Formulated Tags for OS and Driver Inventory: -->"
    WriteLog $env "INFO" $osInvJson

    Return $combinedCollection
}

Function IntersightConnectionSettings {
    Param([object]$env, [string]$secret_file_path)

    # setting up connection to intersight cloud
    $connection = @{
        BasePath = $env.config.intersight_url
        ApiKeyId = $env.config.intersight_api_key
        ApiKeyFilePath = $secret_file_path
        HttpSigningHeader =  @("(request-target)", "Host", "Date", "Digest")
    }
    Set-IntersightConfiguration @connection
    Write-Host "Successfully configured to Intersight"
}

Function ConnectIntersight {
    Param([object]$env)
    Write-Host "Connecting to Cisco Intersight URL with API Keys: "$env.config.intersight_url

    WriteLog $env "INFO" "Using the New Intersight SDK"
    WriteLog $env "INFO" "Connecting to Cisco Intersight(TM) URL with API Keys:"
    WriteLog $env "INFO" $env.config.intersight_url
	if($env.config.intersight_secret_file -like "*:*"){
		$secret_file_path = $env.config.intersight_secret_file
		}
	else{
	    $secret_file_path = $env:USERPROFILE+"\"+$env.config.intersight_secret_file
    	}
    WriteLog $env "INFO" $secret_file_path
    WriteLog $env "INFO" $env.config.intersight_api_key
    try {
        IntersightConnectionSettings $env $secret_file_path
    } catch [System.Exception] {
        Write-Host -ForegroundColor Red "Connection to Cisco Intersight(TM) failed, Aborting..."
        WriteLog $env "ERROR" "Connection to Cisco Intersight(TM) failed, Aborting..."
        StopLogging
        exit
    }
}

Function LookupIntersightServerBySerial {
    Param([string]$server_serial, [string]$computeType)
    $obj = $null
    try {
        if($computeType -eq "blade") {
            $obj =  Get-IntersightComputeBlade -Filter "Serial eq '$server_serial'"
        }
        else
        {
            if($computeType -eq "rack") {
                $obj =  Get-IntersightComputeRackUnit -Filter "Serial eq '$server_serial'"
            }
            else
            {
                Write-Host "Unknown Server Type. Host: $server_serial, skipping..."
            }
        }
    }
    Catch [System.Exception]{
        Write-Host -ForegroundColor Red "API GET failed for host $server_serial, $_"
        WriteLog $env "ERROR" "API GET failed for host $server_serial, $_"
    }
    if($obj) {
        Write-Host "Intersight API GET succeeded for host $server_serial"
    }
    Return $obj
}

#DiffServerTAGS looks accounts for missing TAGs and TAG value differences. It ignores the updateTimeStamp TAG
Function DiffServerTAGs {
    Param ([object]$oldTAGs, [object]$newTAGS)
    $changed = $false
    Write-Host "Computing changes..."
    $oldIntersightTags = $oldTags | where-object {$_.Key -like "intersight.server.os.*"}
    $newIntersightTags = $newTags | where-object {$_.Key -like "intersight.server.os.*"}
    if(($newIntersightTags | measure-object).Count -ne ($oldIntersightTags | measure-object).Count) {
        $changed = $true
    }
    else
    {
        foreach($MoTag in $newIntersightTags) {
            if($MoTag.Key -ne "intersight.server.os.updateTimeStamp") {
                $oldMoTag = $oldIntersightTags | where-object {$_.key -eq $MoTag.key}
                if($oldMoTag -eq $null -or $oldMoTag.Value -ne $MoTag.Value) {
                    $changed = $true
                    break
                }
            }
        }
    }
    Return $changed
}

Function PatchIntersightServerBySerial {
    Param ([object]$env, [string]$server_serial, [string]$computeType, [object]$Server, [object]$osInvCollection)

    WriteLog $env "INFO" "Sending OS and Driver Inventory..."

    $tags = $Server.Results[0].Tags
    $moid = $Server.Results[0].Moid
    $changed = DiffServerTAGs $tags $osInvCollection

    if ($changed)
    {
        $list = @()

        foreach($tag in $tags) {
            # Add tags like Intersight.LicenseTier to the list
            if($tag.Key -notlike "intersight.server.*") {
                $mo = Initialize-IntersightMoTag -Key $tag.Key -Value $tag.Value
                $list += $mo
            }
        }

        #4. Create list from TAGs
        foreach ($item in $osInvCollection){
            $mo = Initialize-IntersightMoTag -Key $item.Key -Value $item.Value
            $list += $mo
        }

        #5. Prep API object for PATCH
        try {
            #6. Call patch API
            Write-Host -ForegroundColor Magenta "Changes detected for Server: [$server_serial], PATCHing to Intersight..."
            WriteLog $env "INFO" "Changes detected for Server: [$server_serial], PATCHing to Intersight..."
            if($computeType -eq "blade") {
                $UpdateResult = Set-IntersightComputeBlade -Moid $moid -Tags $list
            }
            else
            {
                if($computeType -eq "rack") {
                      $UpdateResult = Set-IntersightComputeRackUnit -Moid $moid -Tags $list
                }
                else
                {
                    Write-Host "Unknown Host: $server_serial, skipping..."
                }
            }
        }
        catch [System.Exception]{
            Write-Host -ForegroundColor Red "ERROR: API PATCH failed for host $server_serial, $_"
            WriteLog $env "ERROR" "API PATCH failed for host $server_serial, $_"
        }
    }
    else
    {
        Write-Host -ForegroundColor Yellow "No changes detected for Server: [$server_serial], skipping..."
        WriteLog $env "INFO" "No changes detected for Server: [$server_serial], skipping..."
    }
}

Function StopLogging {
    Stop-transcript
}

Function ValidateEnv {
    Param ([object] $env)
    try {
        if($env.config.filter -eq "" -or $env.config.filter -eq $null) {
            Write-Host -ForegroundColor Red "[ERROR]: Filter cannot be empty (try *)! Cannot Proceed..."
            exit
        }

        if($env.config.intersight_url -eq "" -or $env.config.intersight_url -eq $null) {
            Write-Host -ForegroundColor Red "[ERROR]: Intersight URL cannot be empty (try https://intersight.com/api/v1)! Cannot Proceed..."
            exit
        }

        if($env.config.intersight_api_key -eq "" -or $env.config.intersight_api_key -eq $null) {
            Write-Host -ForegroundColor Red "[ERROR]: Intersight API key cannot be empty! Cannot Proceed..."
            exit
        }

        if($env.config.intersight_secret_file -like "*:*"){
            $secret_file_path = $env.config.intersight_secret_file
            }
        else{
            $secret_file_path = $env:USERPROFILE+"\"+$env.config.intersight_secret_file
            }

        if(!(Test-Path -PathType Leaf $secret_file_path)) {
            Write-Host -ForegroundColor Red "[ERROR]: intersight_secret_file must exist! Cannot Proceed..."
            exit
        }
        if(!(Test-Path -PathType Container $env.config.logfile_path)) {
            Write-Host -ForegroundColor Red "[ERROR]: logfile_path must exist! Cannot Proceed..."
            exit
        }
        Write-Host -ForegroundColor Green "[INFO]: Configurations in {$configfile}, validation succeeded!"
    }
    catch [System.Exception] {
        Write-Host -ForegroundColor Red "[ERROR]: Discovery config validation failed, please ensure credential files and log files exist: $_"
        exit
    }
}

# doDiscovery does ODT Discovery for HCL
Function DoDiscovery {
    $env = GetEnvironment
    Write-Host -ForegroundColor Cyan "[INFO]: ODT script for OS Discovery started..."
    ValidateEnv $env
    StartLogging $env
    WriteLog $env "INFO" "ODT script for OS Discovery started..."
    ConnectIntersight $env
    $WindowsHosts = GetWindowsHosts $env

    foreach ($hostname in $WindowsHosts) {
        WriteLog $env "INFO" "[$hostname]: Retrieving OS Inventory..."

        $server_serial = GetWindowHostSerial $hostname
        if($server_serial.contains("VMware"))
        {
            Write-Host -ForegroundColor DarkGreen "{$hostname}: Skipping Virtual Machine Host:" $server_serial
            Write-Host -ForegroundColor DarkGreen "[$hostname]: ...Done"
            Continue
        }

        Write-Host -ForegroundColor Cyan "------------------------------------------------------------------------------------"
        Write-Host -ForegroundColor Cyan "Processing {$hostname} :"$server_serial
        $computeType = GetComputeType $hostname

        $obj = LookupIntersightServerBySerial $server_serial $computeType

        if($obj) {
            if($obj.Results.Count -gt 0)
            {
                $osInvCollection = ProcessHostOsInventory $env $hostname
                $ServerMoid = $obj.Results[0].Moid
                Write-Host "Server MOID: " $ServerMoid
                PatchIntersightServerBySerial $env $server_serial $computeType $obj $osInvCollection
            }
            else
            {
                Write-Host -ForegroundColor Yellow "No results for {$VMHost}:$sever_serial from intersight, skipping..."
                WriteLog $env "WARNING" "No results for {$VMHost}:$sever_serial from intersight"
            }
        }
        else
        {
            Write-Host -ForegroundColor Yellow "No results for {$VMHost}:$sever_serial from intersight, skipping..."
            WriteLog $env "WARNING" "No results for {$VMHost}:$sever_serial from intersight"
        }
        Write-Host -ForegroundColor Green "Processing {$hostname} :"$server_serial" complete."
        Write-Host -ForegroundColor Green "===================================================================================="
    }
    WriteLog $env "INFO" "ODT Discovery complete!"
    StopLogging
}

# Startup the ODT
DoDiscovery
