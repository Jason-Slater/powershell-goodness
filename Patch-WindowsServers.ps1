
<#PSScriptInfo

.VERSION 2.0

.GUID 9aff0b48-441f-4111-a9a6-0f1a1a7bf38e

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.DESCRIPTION 

 Powershell script to execute Windows Update across all servers in a domain, leveraging the PSWindowsUpdate module from PowerShell Gallery 

#> 

#Variables



$CompList = Get-ADComputer -Filter { OperatingSystem -Like '*Server*' } -Properties * | select-object -ExpandProperty name 

foreach ($Comp in $CompList) {

    # $Comp

    $PSTestResults = (Test-NetConnection -ComputerName $Comp -CommonTCPPort WINRM -Informationlevel Quiet)

    if ($PSTestResults -eq $False) {
        
        Write-Host "*** $($Comp) *** needs to have WINRM opened and/or configured" -ForegroundColor Red 
    
    } else { 

        Write-Host "==========================================" -ForegroundColor Cyan
        
        Write-Host "$($Comp) is bueno" -ForegroundColor Green

        $PSVersion = (Invoke-Command -ComputerName $Comp -ScriptBlock {($PSVersionTable).PSVersion.Major})

        Write-Host "$($Comp) has PowerShell version $PSVersion"
            
                if ($PSVersion -lt 5 ) {

                Write-Output "$($Comp) needs to have PowerShell Updated"

                } else {

                Invoke-Command -ComputerName $Comp -ScriptBlock {Get-PackageProvider -Name Nuget -ForceBootStrap}

                $PkgVerCheck = (Invoke-Command -ComputerName $Comp -ScriptBlock {(Get-PackageProvider -Name Nuget).version.major})

                        if ($PkgVerCheck -ne 2) {
                    
                        Write-Output "$($Comp) needs to have NuGet Package Updated"

                        } else {

                        Invoke-command -ComputerName $Comp -ScriptBlock {Install-PackageProvider -Name NuGet -Force ; Install-Module -Name PSWindowsUpdate -Force}

                        c:\pstools\psexec.exe -accepteula  \\$Comp -s C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -c Install-WindowsUpdate -MicrosoftUpdate -Download -Install -AcceptAll -AutoReboot -IgnoreUserInput}

                }
               

        Write-Host "==========================================" -ForegroundColor Cyan

        Write-Host

        

        }

}



