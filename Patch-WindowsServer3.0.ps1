
<#PSScriptInfo

.VERSION 3.0

.GUID 9aff0b48-441f-4111-a9a6-0f1a1a7bf3f

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.DESCRIPTION 

 Powershell script to execute Windows Update across all servers in a domain, leveraging the PSWindowsUpdate module from PowerShell Gallery 
 Minimum version of Powershell required is version 5.1
 Access to the internet is required to pull module from Powershell gallery
 NuGet will be updated if version found to be older
 PSEXEC.exe is leveraged and must be staged in C:\pstools on the system executing the script

#> 

#Variables
$FilePath = c:\temp\
$Date     = (get-date -format dd/mm/yyyy_hh:mm:ss).ToString() 
$PSV      = 5
$NGV      = 2

# Parameters
Parameters (
[WindowsServer (WindowsServer)]
[default]
[PSVersionCheck (PSVersionCheck)]
[PSUpdate (PSUpdate)]
[NugetCheck (NugetCheck)]
[NugetUpdate (NugetUpdate)]
[PatchAll (PatchAll)]
)




<#
=============================
Function to pull all Windws Servers
from Active Directory and place 
them in an Array
=============================
#>

function WindowsServer {

        $CompList = Get-ADComputer -Filter { OperatingSystem -Like '*Server*' } -Properties * | select-object -ExpandProperty nam
        
        foreach ($Comp in $CompList) {

                $CompTest = (Test-NetConnection -ComputerName $Comp -CommonTCPPort WINRM -Informationlevel Quiet)
            
                if ($CompList -eq $False) {
                    
                    Out-File -Filepath "$FilePath\No_Ping_Servers($Date).txt" -NoClobber

                    else {
                            $Runlist = $Comp

                    }

                }

        }

}


<#
=============================
Function to check Powershell version
=============================
#>

function PSVersionCheck {

        foreach ($Comp in $CompList) {

                $PSVersion = (Invoke-Command -ComputerName $Comp -ScriptBlock {($PSVersionTable).PSVersion.Major}) 

                Write-Host "$($Comp) has PowerShell version $PSVersion"

        }
                
}

<#
=============================
Function to update PowerShell version to 5.1
=============================
#>

<#
function PSVersion {

        foreach ($Comp in $CompList) {

                $PSVersion = (Invoke-Command -ComputerName $Comp -ScriptBlock {($PSVersionTable).PSVersion.Major})

                Write-Host "$($Comp) has PowerShell version $PSVersion"
                    
                        if ($PSVersion -lt $PSV ) {
        
                        #getosversion

                        Do someting depending on OS version

        }
                
}
#>

<#
=============================
Check Nuget version
=============================
#>

function NugetCheck {

        foreach ($Comp in $CompList) {

                Invoke-Command -ComputerName $Comp -ScriptBlock {Get-PackageProvider -Name Nuget -ForceBootStrap}

                $PkgVerCheck = (Invoke-Command -ComputerName $Comp -ScriptBlock {(Get-PackageProvider -Name Nuget).version.major})

                        if ($PkgVerCheck -ne 2) {
    
                                Write-Output "$($Comp) needs to have NuGet Package Updated"

                        }

                }

        }




<#
=============================
Updates Nuget Version
=============================
#>

function NugetUpdate {

        foreach ($Comp in $CompList) {

                # Invoke-Command -ComputerName $Comp -ScriptBlock {Get-PackageProvider -Name Nuget -ForceBootStrap}

                $PkgVerCheck = (Invoke-Command -ComputerName $Comp -ScriptBlock {(Get-PackageProvider -Name Nuget).version.major})

                        if ($PkgVerCheck -ne $NGV) {
    
                                Invoke-command -ComputerName $Comp -ScriptBlock {Install-PackageProvider -Name NuGet -Force ; Install-Module -Name PSWindowsUpdate -Force}

                        }

                }

        }




<#
=============================
Patches servers and reboots
Leveraging PSexec to run remote command locally
=============================
#>

function PatchAll {

        foreach ($Comp in $CompList) {

                Write-Host "$Comp" -ForegroundColor Yellow

                c:\pstools\psexec.exe -accepteula  \\$Comp -s C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -c Install-WindowsUpdate -MicrosoftUpdate -Download -Install -AcceptAll -AutoReboot -IgnoreUserInput

                Write-Host "==========================================" -ForegroundColor Cyan

        }
        
}

<#
=============================
Get a list of Windows Servers
=============================
#>

WindowsServer

<#
=============================
Script end
=============================
#>