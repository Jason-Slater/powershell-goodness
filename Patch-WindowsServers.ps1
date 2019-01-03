
<#PSScriptInfo

.VERSION 1.0

.GUID 9aff0b48-441f-4111-a9a6-0f1a1a7bf38e

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome


#>

<# 

.DESCRIPTION 
 Powershell script to execute Windows Update across all servers in a domain, leveraging the PSWindowsUpdate module from PowerShell Gallery 

#> 
#Param()

#Variables
$ADDS     = (Get-ADDomain).name
$ModVer   = "2.1.0.1"
$PkgVer   = "2.8.5.201"
$CompList = Get-ADComputer -Filter { OperatingSystem -Like '*Server*' } -Properties *


# Check PowerShell Version
function PSVersionCheck {
    Invoke-Command -ComputerName $Comp -ScriptBlock {$PSVersionTable.PSVersion.Major} 
}

# Script Body
foreach ($Comp in $CompList) {
    if ( PSVersionCheck -ge 5 ) {
        Install-PackageProvider -Name NuGet -Minimumversion $PkgVer -Force
        Install-Module -Name PSWindowsUpdate -MinimumVersion $ModVer -Force
        Start-Sleep -Seconds 60
        Install-WindowsUpdate -ComputerName $Comp -IgnoreUserInput -AcceptAll -Download -Install -AutoReboot -Verbose

    }
    else {
        Write-Output "$Comp needs to have PSVersion Updated"
        
    }
}


