

[System.Collections.ArrayList]$CompList = Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'} | Select-Object -ExcludeProperty Name
[System.Collections.ArrayList]$CompListPre  = $Complist.name
$CompListPre.Remove("$env:COMPUTERNAME")

 
foreach ($Computer in $CompListPre) {
$Computer
Restart-Computer -ComputerName $Computer -Force
    }