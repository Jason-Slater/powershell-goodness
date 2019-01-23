
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

$Cred     = Get-Credential

# Script Body

foreach ($Comp in $CompList) {

    $Comp

    $PSTestResults = (Test-NetConnection -ComputerName $Comp -CommonTCPPort WINRM).TcpTestSucceeded 

    if ($PSTestResults -eq $False) {
        
        Write-Output "$Comp needs to have WINRM opened and/or configured"
    
    } else {
            
        Enter-pssession -ComputerName $Comp

        start-sleep -Seconds 5

        $PSVersion = ($PSVersionTable).PSVersion.Major

        Write-Output "$Comp has PowerShell version $PSVersion"

        Exit-PSSession

            }

            if ($PSVersion -lt 5 ) {

                Write-Output "$Comp needs to have PowerShell Updated"

            } else {

                 Enter-pssession -ComputerName $Comp

                 Start-sleep -Seconds 5

                 $PkgVerCheck = (get-packageprovider Nuget).version.major 

                 Write-Output "$Comp has NuGet major version $PkgVerCheck"
                
                 if ($PkgVerCheck -ne 2) {
                    
                    Write-Output "$Comp needs to have NuGet Package Updated"

                    Exit-PSSession

                 } else {

                    Exit-PSSession

                    Invoke-command -ComputerName $Comp -credential $Cred -script {Install-PackageProvider -Name NuGet} 

                    c:\pstools\psexec.exe \\$Comp -s C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -c Install-WindowsUpdate -MicrosoftUpdate -Download -Install -AcceptAll -AutoReboot -IgnoreUserInput}          

                               
                 }

            }

 



