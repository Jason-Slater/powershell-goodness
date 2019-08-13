$VMCol = GWMI -class "MSVM_ComputerSystem" -namespace "root\virtualization" -computername "."
foreach ($VM in $VMCol)
{
      if ($VM.Caption -match "Virtual Machine")
      {
          write-host "=================================="
          write-host "VM Name:  " $VM.ElementName
          write-host "VM GUID:  " $VM.Name
          write-host "VM State: " $VM.EnabledState
      }
}
