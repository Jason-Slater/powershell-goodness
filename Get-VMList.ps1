GWMI MSVM_ComputerSystem -namespace "root\virtualization" -computername "." | 
where {$_.Caption -eq "Virtual Machine"} | 
Format-List ElementName, Name, EnabledState
