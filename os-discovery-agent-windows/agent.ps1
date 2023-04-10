#dot-source reference existing OS Discovery Tool classes to gather inventory
. ./functions.ps1

if(-not $args[0])
{
	Write-Host "Please specify a location to ipmiutil.exe when launching this script, eg agent.ps1 c:\ipmiutil\ipmiutil.exe"
	break
}

$ipmiutilpath=$args[0]

if (-not(Test-Path -Path $ipmiutilpath -PathType Leaf)) {
     try {
         $null = New-Item -ItemType File -Path $file -Force -ErrorAction Stop
     }
     catch {
         Write-Host "Error! IPMIutil binary not found at" $ipmiutilpath
		 break
     }
 }

$file = "host-inv.yaml"
$templog = "temp.log"

#Gather inventory using existing OS Discovery Tool class and write it to a file
$inventory = ProcessHostOsInventory("","localhost")

Write-Output "annotations:" | Out-File -FilePath $file
foreach ($x in $inventory)
{
	Write-Output " -kv:" | Out-File -FilePath $file -Append
	Write-Output "  key: $($x.Key.substring(18))" | Out-File -FilePath $file -Append
	Write-Output "  value: $($x.Value)" | Out-File -FilePath $file -Append
}

#Remove Windows EOL characters and make inventory file *nix compliant
((Get-Content $file) -join "`n") + "`n" | Set-Content -NoNewline $file

#Script tested with max file size of 65535
if ((Get-Item $file).Length -ge 65535) {
	Write-Host "Error!  host-inv.yaml filesize is too large, exiting.."
	break
}

#Send IPMI command to delete host-inv.yaml off IMC
$cmd = "cmd -d 0x36 0x77 0x03 0x68 0x6f 0x73 0x74 0x2d 0x69 0x6e 0x76 0x2e 0x79 0x61 0x6d 0x6c"
Start-Process -FilePath $ipmiutilpath -ArgumentList $cmd -Wait -WindowStyle hidden

#Send IPMI command to get a file descriptor for host-inv.yaml from CIMC and save it to a file
Start-Process -FilePath $ipmiutilpath -ArgumentList "cmd -d 0x36 0x77 0x00 0x68 0x6f 0x73 0x74 0x2d 0x69 0x6e 0x76 0x2e 0x79 0x61 0x6d 0x6c" -Wait -RedirectStandardOutput $templog -WindowStyle hidden
$filedescriptor = Get-Content $templog | Select -Index 4

try{
	[int]$filedescriptor.Substring($filedescriptor.Length - 3) -ge 0
}
catch {
	Write-Host "Error! Cannot get file descriptor from IMC via IPMI, exiting.."
	break
}

$filedescriptor = "0x" + $filedescriptor.Substring($filedescriptor.Length - 3)
Remove-Item $templog

#Read in the inventory file created by OS Discovery Tool classes
$content = Get-Content $file -AsByteStream

#Convert file to hex and break into 40 byte chunks to send via IPMI, (add error handling in future to break on failure)
$counter = 0 
$payload = ""
$filelocationcounter = 0
$payloadlength = "0x28"

foreach ($byte in $content)
{ 
	$counter += 1
	if ($counter -le 39){
		$payload += "0x" + '{0:X}' -f $byte + " "
	}
	else
	{
		$payload += "0x" + '{0:X}' -f $byte
        $filepointer = '{0:X8}' -f $filelocationcounter
        $filepointer = "0x" + $filepointer.tostring().substring(6,2) + " 0x" + $filepointer.tostring().substring(4,2) + " 0x" + $filepointer.tostring().substring(2,2) + " 0x" + $filepointer.tostring().substring(0,2)
		$cmd = "cmd -d 0x36 0x77 0x02" + " " + $filedescriptor +  $payloadlength + " " +  $filepointer + " " + $payload
		Write-Host "Writing host inventory file chunk to IMC"
		Start-Process -FilePath $ipmiutilpath -ArgumentList $cmd -Wait -WindowStyle hidden
		$filelocationcounter += 40
		$counter = 0
		$payload = ""
	}
}

Write-Host "Writing host inventory file last chunk to IMC"
$filepointer = '{0:X8}' -f $filelocationcounter
$filepointer = "0x" + $filepointer.tostring().substring(6,2) + " 0x" + $filepointer.tostring().substring(4,2) + " 0x" + $filepointer.tostring().substring(2,2) + " 0x" + $filepointer.tostring().substring(0,2)
$cmd = "cmd -d 0x36 0x77 0x02" + " " + $filedescriptor +  "0x" + '{0:X}' -f $counter + " " +  $filepointer + " " + $payload
Start-Process -FilePath $ipmiutilpath -ArgumentList $cmd -Wait -WindowStyle hidden

Write-Host "Closing IMC host-inv.yaml file descriptor"
$cmd = "cmd -d 0x36 0x77 0x01 " + $filedescriptor
Start-Process -FilePath $ipmiutilpath -ArgumentList $cmd -Wait -WindowStyle hidden