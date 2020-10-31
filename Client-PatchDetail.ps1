
<#PSScriptInfo

.VERSION 1.0

.GUID 778d67e5-5655-41fa-9502-37f76eb859d8

.AUTHOR Jason S.

.COMPANYNAME Me

.DESCRIPTION 

 Powershell script to pull all client machines in the domaing and evaluate
 If it still an existing client on the domain, if so evaluate for latest Microsoft patches

#> 


$Clients = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows 10*'}).Name

Foreach ($Client in $Clients) {

if ((Test-netconnection -ComputerName $Client -CommonTCPPort RDP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TcpTestSucceeded  -eq $False)
    {Get-ADComputer $Client -Properties PasswordLastSet | 
        select  Name, PasswordLastSet | 
            Out-File -FilePath c:\temp\Test_Connection_Fail_$(($Date).ToString('MM-dd-yyyy_hh-mm')).txt -Append
    }
elseif
    ((Test-netconnection -ComputerName $Client -CommonTCPPort RDP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TcpTestSucceeded  -eq $True)
    {Get-Hotfix -ComputerName $Client -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
        Sort-object installedon -Descending |
            Select  -First 6 |
                Out-File -FilePath c:\temp\Last6_Updates_for_each_Client_$(($Date).ToString('MM-dd-yyyy_hh-mm')).txt -Append     
    }
}