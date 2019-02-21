 <#PSScriptInfo

.VERSION 4.0

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.COPYRIGHT 2018

.RELEASENOTES
Developed internally to be used by My Company of Awesome Engineers

#>

<# 

.DESCRIPTION 
 Finds domain joined systems and renames vssadmin.exe to vssadmin.exe*

#> 
 
 
 function Rename-FilesMatchingPattern
{
    param(
        [string]$UNCPath,

        [string]$filePattern,

        [string]$newName,

        [switch]$apply
    )

    $ScanPath = Join-Path -Path $UNCPath -ChildPath $filePattern
    $dirFiles = get-childitem  $ScanPath

    if ($dirFiles.Count -le 1)
    {
        foreach ($file in $dirFiles)
        {
            $Destination = Join-Path -Path $UNCPath -ChildPath $newName
            If ($apply)
            {
                Move-Item -Path $file.FullName -Destination $Destination -Force
                Get-item $destination
            }
            else 
            {
                $file
            }
        }
    }
    else
    {
        Write-Host  "Multiple Files matching pattern found."
    }
}


$hosts = Get-ADComputer -filter {OperatingSystem -like "Windows Server*"}
Foreach ($item in $hosts)
{
    $item.dnshostname
     Rename-FilesMatchingPattern  -UNCPath "\\$($item.dnshostname)\C$\windows\system32" -filePattern  "vssadmin.exe*" -newName  "vssadmin.exe" -apply
} 
