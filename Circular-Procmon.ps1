<#PSScriptInfo

.VERSION
    1.0
 
.GUID 
    b3e98808-cca4-424b-bc68-ef8d78ce6198

.AUTHOR
    Jason S. 

.DESCRIPTION
    Circular Procmon collector

 .DEPENDENCIES
    Requires procmon.exe to be on the local system in the following location C:\Tools\SysInternals\
    Path may need to upadated if not in the standard location

#>

 

 

function CircularProcmon {

 

#Define Params

Param(

# Define log path!!! Make sure you have at least 20GB free

[String]$LogPath = 'c:\temp\procmon',

[Int]$MaxLogs = "15",

[Int]$LogLengthSeconds = "300",

[String]$ProcmonPath = "C:\Tools\SysInternals\Procmon.exe",

[Int]$PMLDriveUnloadTimerMS = "3000"

)

 

 

#Test path for log files, create if not present.

if ( -not (Test-Path $LogPath))

{

   New-Item -ItemType Directory -Path $Logpath

   Write-Output "Created $Logpath"

}

 

$i = 0

#Loop that does the work.

Do{

 

$Date = Get-Date -Format G

$Date = $Date.replace(' ','-')

$Date = $Date.replace(':','-')

$Date = $Date.replace('/','-')

$path = $LogPath + "\Log-" + $Date

new-item $path -type Directory

 

 

$LogFileName = $path + "\" + "Logfile_" + $i + "-" + "$Date" + ".PML"

$BackingFile = $LogFileName

write-Output $BackingFile

Write-Output "Starting Log..."

Start-Process $ProcmonPath -ArgumentList "/BackingFile $BackingFile", "/AcceptEula", "/Minimized", "/Quiet"

Write-output "Capturing for $loglengthseconds Seconds"

Start-Sleep -Seconds $LogLengthSeconds

Write-Output "File Completed $LogFileName"

Start-Process $ProcmonPath -ArgumentList "/Terminate"

 

#Compensate for driver load and unload time, may need to be adjusted depeding on system.

Start-Sleep -Milliseconds $PMLDriveUnloadTimerMS

 

#Added file count guardrail to prevent filling the drive

$Filecount = (Get-ChildItem $LogPath | Measure-Object).count

If ($Filecount -gt 16) {

   Get-ChildItem $LogPath -recurse | Sort-object LastWriteTime | Select-object -Last ($Filecount - 16) | Remove-Item -Force

   }

 

 

#Cleanup loop to remove oldest file.

Get-ChildItem $LogPath | Sort-Object CreationTime | Select-Object

If (($LogCount -gt $MaxLogs) -or ($LogCount -eq $MaxLogs))

    {

    Do

    {

    $logs = Get-ChildItem -Path $LogPath

    $LogCount = (Get-ChildItem -Path $LogPath).Count

    $logs | Sort-Object -Property LastWriteTime -Descending | Select-Object -Last 1 | Remove-Item -Force -Recurse

    Write-Output "Cleanup Performed."

    }

    While ($LogCount -gt $MaxLogs) 

    }

 

$i = $i+1

}

While ($true)

 

}

 

CircularProcmon