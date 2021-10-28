<#

.SYNOPSIS
ODT stands for OS Discovery Toolset.
This is a simple ODT script to Discover ESX OS Inventory and TAG Servers managed by Cisco Intersight.
It can be run via the Windows Task Scheduler to ensure regular refresh and is powered by Windows Powershell 7.1+

.DESCRIPTION
This tool needs to have generateSecureCredentials.ps1 to be run beforehand.

You need the following files generated:
1. Encrypted vCenter Credentials in a PSCredential XML file
2. Encrypted Intersight Secret Key file

It also needs the path to a config file (discovery_config_esx.json).

.EXAMPLE
>  .\getEsxOsInvToIntersight.ps1 $env:USERPROFILE\Documents\discovery_config_esx.json

.NOTES
This script can be run via the Windows Task scheduler OR SCOM

.LINK
https://github.com/CiscoDevNet/intersight-powershell-utils

#>

Param (
    [Parameter(Mandatory=$true)]
    [string]$configfile,
    [Parameter(Mandatory=$false)]
    [bool]$session
)

$mypath = (Resolve-Path .)

Function CheckVMWarePowerCLI
{
  Param([object]$pkg)
  if (Get-Module -ListAvailable -Name $pkg){
    # if module is found, import that module
    Import-Module -Name $pkg
    return $true
  }
  else{
    Write-Host -ForegroundColor Red "Check if VMWare PowerCLI is installed. Missing module:" $pkg
    return $false
  }
}

Function CheckPowerShellVersion
{
    # powershell version should be 7.1 and above
    if (-not (($PSVersionTable.PSVersion.Major -ge 7) -and ($PSVersionTable.PSVersion.Minor -ge 1))){
         throw "PowerShell version less than 7.1, please upgrade to Powershell 7.1 or higher."
    }
}

Function CheckPowerCLIVersion
{
    $powercliversion = (Get-Module -ListAvailable -Name VMware.PowerCLI | Select-Object Version)
    if ($powercliversion -ne $null) {
        # supported powercli version is 12.0.0.15947286 and above
        if (-not ($powercliversion.Version.ToString() -ge "12.0.0.15947286")) {
            throw "PowerCLI version is older, please upgrade to PowerCLI version greater than 12.0.0.15947286 "
        }
    }
    else{
        throw "PowerCLI Module is not installed"
    }
}

try {
    Import-Module Intersight.PowerShell -ErrorAction Stop
    CheckPowerShellVersion
    CheckPowerCLIVersion

    #If PowerCLI is not installed, then throw exception
    if (-not ((CheckVMWarePowerCLI("VMware.VimAutomation.Cis.Core")) -and
        (CheckVMWarePowerCLI("VMware.VimAutomation.Common")) -and
        (CheckVMWarePowerCLI("VMware.VimAutomation.Core")) -and
        (CheckVMWarePowerCLI("VMware.VimAutomation.Storage")) -and
        (CheckVMWarePowerCLI("VMware.VimAutomation.Sdk")) -and
        (CheckVMWarePowerCLI("VMware.VimAutomation.Vds")))) {
            throw "PowerCLI module is missing"
        }
} catch [System.Exception] {
    Write-Host -ForeGroundColor Red "Dependent Libraries not installed. Please check that the Cisco Intersight Powershell SDK and VMware PowerCLI packages are installed, $_"
    exit
}

Set-Location -Path $mypath
$datestring = (get-date).toUniversalTime().ToFileTimeUtc()

Function WriteLog
{
    Param ([object]$env, [string]$loglevel, [string]$logstring)
    $logfile = $env.config.logfile_path+"\discovery_"+$datestring+".log"
	$stamp=(get-date)
	$logline = "["+$stamp+"]"+$loglevel+"::"+$logstring
	Add-content $logfile -value $logline
}

Function GetEnvironment
{
    Return (Get-Content -Raw -Path (Resolve-Path $configfile) | ConvertFrom-Json)   
}

Function StartLogging {
    Param([object]$env)
    $outfile = $env.config.logfile_path+"\discovery_"+$datestring+".out"
    Start-transcript -append -path $outfile
}

Function ConnectvCenter {
    Param([object]$env)
    $vCenter_creds_file_path=$env:USERPROFILE+"\"+$env.config.vCenter_creds_file
    $vcenterCredentials = Import-Clixml -Path $vCenter_creds_file_path
    try {
        # Skip the Certificate Check and suppress any console output
        Invoke-WebRequest $env.config.intersight_url -SkipCertificateCheck | Out-Null
        if(!$session) {
            Connect-VIServer -Server $env.config.vCenter -Credential $vcenterCredentials | Out-Null
        }
        else {
            Connect-VIServer -Server $env.config.vCenter | Out-Null
        }
    } catch [System.Exception] {
        Write-Host -ForeGroundColor Red "Could not connect to vCenter: " $env.config.vCenter "Aborting..."
        WriteLog $env "INFO" "Could not connect to vCenter: "$env.config.vCenter", Aborting..."
        StopLogging
        exit
    }
}

Function GetVMHosts {
    Param([object]$env)
    $filter = $env.config.location_filter
    Return (Get-VMHost -Location $filter)
}

Function GetVMHostSerial {
    Param([object]$esxcli)
    Return (($esxcli.hardware.platform.get.Invoke() | select SerialNumber).SerialNumber)
}

Function GetComputeType {
    Param([object]$esxcli)
    $model = ($esxcli.hardware.platform.get.Invoke() | select ProductName).ProductName
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
	 Return ((Get-Date).ToUniversalTime().ToString( "yyyy-MM-ddTHH:mm:ss.fffZ" ))
}

Function GetTAGPrefix {
	Return "intersight.server."
}

#Os Details
Function GetOSDetails{
    Param([object]$env, [object]$VMHost, [object]$esxcli)
    Write-Host "GetOSDetails: $VMHost"  
    $updateTS = GetISO8601Time
    $prefix = GetTAGPrefix
    $osInvCollection = New-Object System.Collections.ArrayList
    $osdetails = $esxcli.system.version.Get.Invoke()	
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.updateTimestamp"
    $osInv | Add-Member -type NoteProperty -name Value -Value $updateTS
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $vendor, $osname = $osdetails.Product.Split(' ')
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.vendor"
    $osInv | Add-Member -type NoteProperty -name Value -Value $osdetails.Product
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.name"
    $osInv | Add-Member -type NoteProperty -name Value -Value $osname
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.arch"
    $osInv | Add-Member -type NoteProperty -name Value -Value "x86_64"
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.type"
    $osInv | Add-Member -type NoteProperty -name Value -Value "VMkernel"
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.kernelVersionString"
    $osInv | Add-Member -type NoteProperty -name Value -Value $osdetails.Version
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.releaseVersionString"
    $osInv | Add-Member -type NoteProperty -name Value -Value $osdetails.Build
    $count = $osInvCollection.Add($osInv)
    Clear-Variable -Name osInv
    $osInv = New-Object System.Object
    $osInv | Add-Member -type NoteProperty -name Key -Value $prefix"os.updateVersionString"

    if($osdetails.Update -ne "0") {
        $updatestring = "U"+$osdetails.Update
        $osInv | Add-Member -type NoteProperty -name Value -Value $osdetails.Update
    }
    else {
        $osInv | Add-Member -type NoteProperty -name Value -Value ""
    }
    $count = $osInvCollection.Add($osInv)
    Return $osInvCollection
}

#Driver details
Function GetDriverDetails {
    Param([object]$env, [object]$VMHost, [object]$esxcli)
    Write-Host "GetDriverDetails: $VMHost"
    $prefix = GetTAGPrefix
    $osInvCollection = New-Object System.Collections.ArrayList
    $driverList = New-Object Collections.Generic.List[string]
    $devcount = 0

    $niclist = $esxcli.network.nic.list.Invoke()
    $hbalist = $esxcli.storage.core.adapter.list.Invoke()
    $gpulist = $esxcli.graphics.device.list.Invoke()

    foreach($nic in $niclist) {
        if(!$driverList.Contains($nic.Driver)) {
            $driverList.Add($nic.Driver)
            $key = $prefix+"os.driver."+$devcount+".name"
            $osInv = New-Object System.Object
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $osInv | Add-Member -type NoteProperty -name Value -Value $nic.Driver
            $count = $osInvCollection.Add($osInv)
            Clear-Variable -Name osInv
            $osInv = New-Object System.Object
            $key = $prefix+"os.driver."+$devcount+".description"
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $osInv | Add-Member -type NoteProperty -name Value -Value $nic.Description
            $count = $osInvCollection.Add($osInv)
            Clear-Variable -Name osInv
            $osInv = New-Object System.Object
            $key = $prefix+"os.driver."+$devcount+".version"
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $driverVersion = $esxcli.system.module.get.Invoke(@{module=$nic.Driver}).Version
            if($driverversion -like "Version*") {
                $driverVersion = $driverversion.split(",")[0].split(" ")[1]
            }
            $osInv | Add-Member -type NoteProperty -name Value -Value $driverVersion
            $count = $osInvCollection.Add($osInv)
            $devcount = $devcount + 1
        }
    }

    foreach($hba in $hbalist) {
        if(!$driverList.Contains($hba.Driver) -and $hba.Driver -notlike "*usb*") {
            $driverList.Add($hba.Driver)
            $key = $prefix+"os.driver."+$devcount+".name"
            $osInv = New-Object System.Object
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $osInv | Add-Member -type NoteProperty -name Value -Value $hba.Driver
            $count = $osInvCollection.Add($osInv)
            Clear-Variable -Name osInv
            $osInv = New-Object System.Object
            $key = $prefix+"os.driver."+$devcount+".description"
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $osInv | Add-Member -type NoteProperty -name Value -Value $hba.Description
            $count = $osInvCollection.Add($osInv)
            Clear-Variable -Name osInv
            $osInv = New-Object System.Object
            $key = $prefix+"os.driver."+$devcount+".version"
            $osInv | Add-Member -type NoteProperty -name Key -Value $key
            $driverVersion = $esxcli.system.module.get.Invoke(@{module=$hba.Driver}).Version
            if($driverversion -like "Version*") {
                $driverVersion = $driverversion.split(",")[0].split(" ")[1]
            }
            $osInv | Add-Member -type NoteProperty -name Value -Value $driverVersion
            $count = $osInvCollection.Add($osInv)
            $devcount = $devcount + 1
        }
    }

    foreach($gpu in $gpulist) {
        if(!$driverList.Contains($gpu.ModuleName)){
            # If Nvidia GPU is in Passthrough mode, don't report any driver
            # Check if GPU is in Non-Passthrough mode
            # GraphicsType is SharedPassthru, vGPU mode is enabled
            if(($gpu.GraphicsType -eq "SharedPassthru")){
                $driverList.Add($gpu.ModuleName)
                Write-Host "GPU detected in Non-Passthrough mode and vGPU enabled. Driver name: " $gpu.ModuleName
                $key = $prefix+"os.driver."+$devcount+".name"
                $osInv = New-Object System.Object
                $osInv | Add-Member -type NoteProperty -name Key -Value $key
                $osInv | Add-Member -type NoteProperty -name Value -Value ($gpu.ModuleName+"(graphics)")
                $count = $osInvCollection.Add($osInv)
                Clear-Variable -Name osInv

                $osInv = New-Object System.Object
                $key = $prefix+"os.driver."+$devcount+".version"
                $osInv | Add-Member -type NoteProperty -name Key -Value $key
                $driverVersion = $esxcli.system.module.get.Invoke(@{module=$gpu.ModuleName}).Version
                if($driverversion -like "Version*") {
                    $driverVersion = $driverversion.split(",")[0].split(" ")[1]
                }
                $osInv | Add-Member -type NoteProperty -name Value -Value $driverVersion
                $count = $osInvCollection.Add($osInv)
                Clear-Variable -Name osInv

                $osInv = New-Object System.Object
                $key = $prefix+"os.driver."+$devcount+".description"
                $osInv | Add-Member -type NoteProperty -name Key -Value $key
                $osInv | Add-Member -type NoteProperty -name Value -Value $gpu.DeviceName
                $count = $osInvCollection.Add($osInv)
                Clear-Variable -Name osInv

                $devcount = $devcount + 1
            }

            # GraphicsType is Shared, so vGPU mode is not enabled, report empty driver version
            elseif(($gpu.GraphicsType -eq "Shared")){
                $driverList.Add($gpu.ModuleName)
                Write-Host "GPU detected in Non-Passthrough mode and vGPU not enabled. Driver name: " $gpu.ModuleName
                $key = $prefix+"os.driver."+$devcount+".name"
                $osInv = New-Object System.Object
                $osInv | Add-Member -type NoteProperty -name Key -Value $key
                $osInv | Add-Member -type NoteProperty -name Value -Value ($gpu.ModuleName+"(graphics)")
                $count = $osInvCollection.Add($osInv)
                Clear-Variable -Name osInv

                $osInv = New-Object System.Object
                $key = $prefix+"os.driver."+$devcount+".version"
                $osInv | Add-Member -type NoteProperty -name Key -Value $key
                $driverVersion = ''
                $osInv | Add-Member -type NoteProperty -name Value -Value $driverVersion
                $count = $osInvCollection.Add($osInv)
                Clear-Variable -Name osInv

                $osInv = New-Object System.Object
                $key = $prefix+"os.driver."+$devcount+".description"
                $osInv | Add-Member -type NoteProperty -name Key -Value $key
                $osInv | Add-Member -type NoteProperty -name Value -Value $gpu.DeviceName
                $count = $osInvCollection.Add($osInv)
                Clear-Variable -Name osInv

                $devcount = $devcount + 1
            }
        }
    }

    Return $OsInvCollection
}

Function ProcessHostOsInventory {
    Param([object]$env, [object]$VMHost, [object]$esxcli)
    
    WriteLog $env "INFO" "[$VMHost]:Retrieving OS Inventory..."  
    $osInvCollection = GetOSDetails $env $VMHost $esxcli
    
    WriteLog $env "INFO" "[$VMHost]:Retrieving Device Driver Inventory..."
    $driverInvCollection = GetDriverDetails $env $VMHost $esxcli
    
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
    $secret_file_path = $env:USERPROFILE+"\"+$env.config.intersight_secret_file
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
        $obj =  Get-IntersightComputePhysicalSummary -Filter "Serial eq '$server_serial'"
    } catch [System.Exception]{
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

    $list = @()

    #4. Create list from TAGs preserving non-JET TAGs
    $tags = $Server.Results[0].Tags
    $moid = $Server.Results[0].Moid

    $changed = DiffServerTAGs $tags $osInvCollection

    if ($changed) {
        foreach($tag in $tags) {
            #5. Add tags like Intersight.LicenseTier to the list
            if($tag.Key -notlike "intersight.server.*") {
                $mo = Initialize-IntersightMoTag -Key $tag.Key -Value $tag.Value
                $list += $mo
            }
        }

        #6. Create list from TAGs
        foreach ($item in $osInvCollection){
            $mo = Initialize-IntersightMoTag -Key $item.Key -Value $item.Value
            $list += $mo
        }

        #7. Prep API object for PATCH
        try {
            #8. Call patch API
            Write-Host -ForegroundColor Magenta "Changes detected for Server: [$server_serial], PATCHing to Intersight..."
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
        } catch [System.Exception]{
            WriteLog $env "ERROR" "API PATCH failed for host $server_serial, $_"
            Write-Host -ForegroundColor Red "ERROR: API PATCH failed for host $server_serial, $_"
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
        if(!(Test-Connection $env.config.vCenter -Quiet)) {
            Write-Host -ForegroundColor Red "[ERROR]: vCenter not reachable (please use a valid hostname or IP address that's reachable)! Cannot Proceed..."
            exit
        }

        if($env.config.location_filter -eq "" -or $env.config.location_filter -eq $null) {
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

        if(!$session) {
            $vCenter_creds_file_path=$env:USERPROFILE+"\"+$env.config.vCenter_creds_file
        }
        else {
            $vCenter_creds_file_path=$configfile
        }
        $secret_file_path = $env:USERPROFILE+"\"+$env.config.intersight_secret_file
        if(!(Test-Path -PathType Leaf $vCenter_creds_file_path) -or !(Test-Path -PathType Leaf $secret_file_path) -or !(Test-Path -PathType Container $env.config.logfile_path)) {
            Write-Host -ForegroundColor Red "[ERROR]: vCenter_creds_file, intersight_secret_file, and logfile_path must exist! Cannot Proceed..."
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
    Write-Host -ForegroundColor Cyan "[INFO]: ODT script for OS Discovery started..."
    $env = GetEnvironment
    ValidateEnv $env
    StartLogging $env
    WriteLog $env "[INFO]" "ODT script for OS Discovery started..."
    ConnectvCenter $env
    ConnectIntersight $env
    $VMHosts = GetVMHosts $env
    foreach ($VMHost in $VMHosts) {
        WriteLog $env "INFO" "[$VMHost]: Retrieving OS Inventory..."
        Write-Host -ForegroundColor Cyan "------------------------------------------------------------------------------------"   
        Write-Host -ForegroundColor Cyan "Processing {$VMHost}"
        try {
            $esxcli = ($VMHost | Get-EsxCli -V2)
        }
        catch {
            Write-Host -ForegroundColor Red "[ERROR]: Server Unreachable {$VMHost), $_"
            continue
        }
        $server_serial = GetVMHostSerial $esxcli
        
        $computeType = GetComputeType $esxcli
        $obj = LookupIntersightServerBySerial $server_serial $computeType
        if($obj) {
            if($obj.Results.Count -gt 0)
            {
                $osInvCollection = ProcessHostOsInventory $env $VMHost $esxcli
                $ServerMoid = $obj.Results[0].Moid
                $ServerName = $obj.Results[0].Name
                Write-Host "Server MOID: " $ServerMoid
                PatchIntersightServerBySerial $env $server_serial $computeType $obj $osInvCollection
                Write-Host -ForegroundColor Green "Processing [$ServerName] {$VMHost} :"$server_serial" complete."
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
        
        Write-Host -ForegroundColor Green "===================================================================================="
    }
    WriteLog $env "[INFO]" "ODT Discovery complete!"
    StopLogging
}

# Startup the ODT
DoDiscovery
