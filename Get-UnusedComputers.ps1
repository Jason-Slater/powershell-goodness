
<#PSScriptInfo

.VERSION 1.0

.GUID 14ac71e0-f6a2-4d5e-9eb3-5eb7a311ecf0

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 Powershell script to find unused computer objects 90 days or more 

#> 
Function Disable-ComputerObjects {
    [CmdletBinding(DefaultParameterSetName = "Default")]

Param(
    [Parameter(
        ParameterSetName = "Default",    
        Mandatory = $false,
        ValueFromPipeline = $false,
        Position=0
    )]
    [Parameter(
        ParameterSetName = "Disable",
        Mandatory = $false,
        ValueFromPipeline = $true,
        Position=1
    )]
)
}

$DaysInactive = 90
$Time         = (Get-Date).Adddays(-($DaysInactive))
$Date         = Get-Date

Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -Properties *|`
Select-object Name, OperatingSystem |`
Format-Table -auto |`
Out-File -FilePath c:\ComputerDeletions_$((Get-Date).ToString('MM-dd-yyyy')).txt
