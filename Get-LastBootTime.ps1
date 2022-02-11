
<#PSScriptInfo

.VERSION 2.1

.GUID ccac5b8b-807f-407b-aee0-06d41b675ce3

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.DESCRIPTION

 Pulls all Server objects from AD then interrogates them for OS version & last boot time
 Displays output in a colorful display :-) 

#> 



$Computers = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'}).Name
 
Foreach ($Computer in $Computers) {

    TRY { $Foo = Get-WmiObject -Class Win32_OperatingSystem -Namespace root/cimv2 -ComputerName $computer -erroraction stop

    } CATCH {

        Write-Host "$Computer Can't check server, likely RPC server unavailable" -ForegroundColor Yellow 
        Continue 
        # Move to next computer


    }
    IF((Test-netconnection -ComputerName $Computer.name -CommonTCPPort RDP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TcpTestSucceeded -eq $False)
        { Write-Host "$Computer is no bueno" -ForegroundColor Red  
   

    } ELSE {
        
    $Item1 = (Get-ADComputer $Computer -Properties * |
            select-object Name |
                Format-Table -HideTableHeaders |
                    Out-String).trim() 
    $Item2 = (Get-WmiObject -computername $Computer win32_operatingsystem |
            select-object @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} |
                Format-Table -HideTableHeaders |
                    Out-String).trim()
    $Item3 = (Get-ADComputer $Computer -Properties * |
            select-object OperatingSystem |
                Format-Table -HideTableHeaders |
                    Out-String).trim()
            
         Write-Host "$Item1"`t -ForegroundColor Green -NoNewline;
         Write-Host "$Item3"`t -ForegroundColor Cyan -NoNewline;   
         Write-Host "$Item2"`t -ForegroundColor White
                            
    }
} 



