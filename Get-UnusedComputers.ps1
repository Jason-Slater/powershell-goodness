
<#PSScriptInfo

.VERSION 1.0

.GUID 14ac71e0-f6a2-4d5e-9eb3-5eb7a311ecf0

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.DESCRIPTION 
 Powershell script to find unused computer objects 90 days or more 

#> 


Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet ('Identify','Disable','Delete')]
    [string] $ScriptAction
)

Function Identify-Computers {
    $DaysInactive = 90
    $Time         = (Get-Date).Adddays(-($DaysInactive))
    $Date         = Get-Date
    Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -Properties *|`
    Select-object Name, OperatingSystem PasswordLastSet|`
    Format-Table -auto |`
    Out-File -FilePath c:\temp\ComputerDeletions_$(($Date).ToString('MM-dd-yyyy-hh-mm')).txt
}

Function Identify-Users {
    $DaysInactive = 90
    $Time         = (Get-Date).Adddays(-($DaysInactive))
    $Date         = Get-Date
    Get-ADUser -Filter {LastLogonTimeStamp -lt $Time} -Properties *|`
    Select-object DisplayName, PasswordLastSet |`
    Format-Table -auto |`
    Out-File -FilePath c:\temp\UserDeletions_$(($Date).ToString('MM-dd-yyyy-hh-mm')).txt
}

Function Disable-Computers {
    $ListOfComputers = Get-Content -path c:\temp\ComputerDeletions*.txt
    $ListOfUComputers | Get-ADComputer | Set-ADComputer -Enabled $false
}

Function Delete-Computers {
    $ListOfComputers = Get-Content -path c:\temp\ComputerDeletions*.txt
    $ListOfUComputers | Get-ADComputer | Remove-ADComputer
}

If ($ScriptAction -eq 'Identify')
    {Identify-Computers} 
Elseif ($ScriptAction -eq 'Disable')
    {Disable-Computers}
Elseif ($ScriptAction -eq 'Delete')
    {Delete-Computers}
