
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

Function Identify {

$DaysInactive = 90
$Time         = (Get-Date).Adddays(-($DaysInactive))
$Date         = Get-Date

Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -Properties *|`
Select-object Name, OperatingSystem |`
Format-Table -auto |`
Out-File -FilePath c:\ComputerDeletions_$(($Date).ToString('MM-dd-yyyy')).txt
}
