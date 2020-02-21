
<#PSScriptInfo
.VERSION 2.1
.GUID G4994e41b-db9e-4526-8167-0d63e4be4731
.AUTHOR Jason S.
.COMPANYNAME My Company of Awesome
.COPYRIGHT 2020
.EXTERNALSCRIPTDEPENDENCIES
  Active Directory Powershell modules installed
.RELEASENOTES
  Developed internally to be used by My Company of Awesome Engineers
.DESCRIPTION 
  Pulls uptime from a list of Windows server objects found in AD
#> 

# Gathers all server objects from the domain the script is executed in
$Computers = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'}).Name
 
# Loop through every computer with a TRY/CATCH the IF/ELSE to find last boot time
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
        $Item1 = (Get-ADComputer $Computer -Properties * |
            select-object OperatingSystem |
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
            
         Write-Host "$Item1 " -ForegroundColor Green -NoNewline;
         Write-Host "$Item3 " -ForegroundColor Cyan -NoNewline;   
         Write-Host $Item2 -ForegroundColor Gray                           
    }
} 

