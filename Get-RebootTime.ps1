<#

.VERSION 2.0

.GUID da5c1f92-fe68-4619-991b-b62325db94d0

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.DESCRIPTION 
 Powershell script to find unused computer objects 90 days or more 

#> 
===============================
#>


$CompList = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'} -Properties Name | select-object -ExpandProperty name)

foreach($Computer in $CompList){

    if (Test-Connection -ComputerName $computer -Quiet -count 1) {

        $Compinfo  = Get-WmiObject win32_operatingsystem -ComputerName $Computer | select CSName, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}

        $OSVersion = Get-WmiObject win32_operatingsystem -ComputerName $Computer

        $userinfo  = Get-WmiObject win32_ComputerSystem -ComputerName $Computer | select username
        
        Write-Output $compinfo $OSVersion $Userinfo

    } else {
        
        Write-Output "$computer Offline"
    }

}
