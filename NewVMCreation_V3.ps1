#===============================#
#  Created By:      Jason S.
#  Creation Date:   12/13/17
#  Updated Date:    06/14/18
#  Updated Summary: Updated VMConfig Path
#                   TO DO:
#                   For Data drive create daynamic 1TB but assign 500GB   
#                   Add logic brance between SSD(7K) and (Default) HDD(10K)
#                   Remove Dynamic Memory
#                   Create two sizing 8GB or 16GB
#                   Startup Memory set to 1GB
#===============================#

$VMTempPath   = "H:\Hyper-V\Virtual Machines\New Virtual Machine\Virtual Hard Disks\*"
$VMSourcePath = "H:\Hyper-V\Virtual Machines\New Virtual Machine\Virtual Hard Disks"
$VMTestPath   = (Test-path -Path $VMTempPath -include Template_VM2016.vhdx)
$VMCopyPath   = "G:\Hyper-V\Virtual HDs"
$VMConfig     = "G:\Hyper-V\Virtual Machines"


#  Prompt for Server name
$VMName = Read-Host 'Enter Server Name in all CAPS'

#  Prompt for VM Memory Allocation
$MemPlaceHolder = Read-Host 'Enter Amount of Memory for the VM Example: 12GB(Small) or 16GB(Large)'

#  Prompt for CPU Count
$CPUCount = Read-Host 'Enter Number of CPUs for the VM'


#  Conversion
$Mem = [int64]$MemPlaceHolder.Replace('GB','') * 1GB


#  Set IP Address
# $NewIP = Read-Host 'Enter the IP of the new Server'

# $creds = Get-credential




#  VM Template Test and Copy
if (-not $VMTestPath){
Write-Host -ForegroundColor Red "Windows Server 2016 Template NOT found, Please correct and retry"}
else {
Copy-Item -Path $VMSourcePath\Template_VM2016.vhdx -Destination $VMCopyPath\$VMName.vhdx
Write-Host ========================
Write-Host -ForegroundColor Green "Windows Server 2016 Template found and copied to production Virtal Disk folder" 
Write-Host ========================
Write-Host
}

#  Build VM
Write-Host ========================
Write-Host -ForegroundColor Green "Creating New VM for $VMName"
Write-Host ========================
Write-Host
New-VM -Name $VMName -MemoryStartupBytes $Mem -BootDevice VHD -VHDPath $VMCopyPath\$VMName.vhdx -Path $VMConfig -Generation 1 -Switch "Hyper-V Network"

Write-Host ========================
Write-Host -ForegroundColor Green "Adding SCSI Controller and Data disk to $VMName"
Write-Host ========================
Write-Host
$VMDataPath = "$VMCopyPath\$VMName" + "_Data.vhdx"
New-VHD -Path $VMDataPath -BlockSizeBytes 128MB -LogicalSectorSizeBytes 4KB -SizeBytes 1TB
Add-VMHardDiskDrive -vmname $VMName -path $VMDataPath

Write-Host ========================
Write-Host -ForegroundColor Green "Adding 1TB Dynamic Data Disk to $VMName"
Write-Host ========================
Write-Host
Set-VMProcessor -VMname $VMName -count $CPUCount

Write-Host ========================
Write-Host -ForegroundColor Green "Adding Data disk to $VMName"
Write-Host ========================
Write-Host
# Set-VMMemory $VMName -DynamicMemoryEnabled $False -MinimumBytes 512MB -StartupBytes 512MB -MaximumBytes $Mem -Buffer 25

Write-Host ========================
Write-Host -ForegroundColor Green "Starting New VM $VMName YEA!!!"
Write-Host ========================
Write-Host
Start-VM $VMName

<#
Start-Sleep -Seconds 120
Invoke-Command -VMName $VMName -ScriptBlock { New-NetIPAddress -InterfaceIndex 2 -IPAddress $NewIP -PrefixLength 24 -DefaultGateway 192.168.253.1 }
Invoke-Command -VMName $VMName -ScriptBlock { Set-dnsclientserveraddress -InterfaceIndex 2 -ServerAddresses 192.168.253.160,192.168.253.161 }
Start-Sleep -Seconds 15
Invoke-Command -VMName $VMName -ScriptBlock { Add-Computer -Credential $cred -DomainName n9Cloud.com -NewName $VMName }
Invoke-Command -VMName $VMName -ScriptBlock { Restart-Computer -force }
Start-Sleep -Seconds 20
# does not work Invoke-Command -VMName $VMName -ScriptBlock { wuauclt /a /DetectNow }
#>