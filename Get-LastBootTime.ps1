 $Computers = Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'}
 
foreach ($computer in $Computers) {
    
    If((Test-netconnection -ComputerName $computer.name -CommonTCPPort RDP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TcpTestSucceeded -eq $False) {
           Write-Host "$computer.name is no bueno" -ForegroundColor Red
    
    } ELSE {
           Get-WmiObject -computername $computer.name win32_operatingsystem | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} | ft -HideTableHeaders
           Write-Host "=============================" -ForegroundColor Cyan
    }
} 