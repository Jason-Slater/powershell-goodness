 $Computers = Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'}

 
foreach ($computer in $Computers) {
    
    If((Test-netconnection -ComputerName $computer.name -CommonTCPPort RDP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TcpTestSucceeded -eq $False) {
           Write-Host "$computer is no bueno" -ForegroundColor Yellow   
    } ELSE {
             (Get-WmiObject -computername $computer.name win32_operatingsystem |
                select-object csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} |
                    Format-Table -HideTableHeaders |
                        Out-String).trim()
                    
    }
} 
