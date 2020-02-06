$Computers = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'}).Name
 
Foreach ($Computer in $Computers) {

    TRY { $Foo = Get-WmiObject -Class Win32_OperatingSystem -Namespace root/cimv2 -ComputerName $computer -erroraction stop

    } CATCH {

        Write-Host "$Computer Can't check server, likely RPC server unavailable" -ForegroundColor Yellow 
        Continue 
        # Move to next computer
    }
    
    IF((Test-netconnection -ComputerName $computer.name -CommonTCPPort RDP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TcpTestSucceeded -eq $False)
        { Write-Host "$Computer is no bueno" -ForegroundColor Yellow    

    } ELSE {
        (Get-WmiObject -computername $computer win32_operatingsystem |
            select-object csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} |
                Format-Table -HideTableHeaders |
                    Out-String).trim()                        
    }
} 

