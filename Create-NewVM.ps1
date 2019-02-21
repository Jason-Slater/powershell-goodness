
<#PSScriptInfo

.VERSION 4.0

.GUID 0ffc1821-f868-453d-86b6-6cb4faa054e5

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.COPYRIGHT 2018

.EXTERNALSCRIPTDEPENDENCIES 
Syspreped VM staged in a default location

.RELEASENOTES
Developed internally to be used by My Company of Awesome Engineers

#>

<# 

.DESCRIPTION 
 Custom VM creation based on customer name and Compute resource requirements 

#> 


 
Function Create-Regular {
        $VMCopyPathReg = "G:\Hyper-V\Virtual HDs"
        $VMConfigReg   = "G:\Hyper-V\Virtual Machines"

        # Copy Sysprep image to data store
        Copy-Item -Path "$VMSourcePath\Template_VM2016.vhdx" -Destination $VMCopyPathReg\$VMName.vhdx

        # Create new VM from image
        New-VM -Name $VMName -MemoryStartupBytes $Mem -BootDevice VHD -VHDPath $VMCopyPathReg\$VMName.vhdx -Path $VMConfigReg -Generation 1 -Switch "Hyper-V Network"

        # Create Data Path Name
        $VMDataPathReg = "$VMCopyPathReg\$VMName" + "_Data.vhdx"

        # Create Data Disk
        New-VHD -Path $VMDataPathReg -BlockSizeBytes 128MB -LogicalSectorSizeBytes 4KB -SizeBytes 1TB

        # Add Data Disk
        Add-VMHardDiskDrive -vmname $VMName -path $VMDataPathReg

        # Set VM CPU Number
        Set-VMProcessor -VMname $VMName -count $CPUCount
        }

Function Create-Fast {
        $VMCopyPathLg   = "F:\Hyper-V\Virtual HDs"
        $VMConfigLg     = "F:\Hyper-V\Virtual Machines"
        Copy-Item -Path "$VMSourcePath\Template_VM2016.vhdx" -Destination $VMCopyPathLg\$VMName.vhdx
        New-VM -Name $VMName -MemoryStartupBytes $Mem -BootDevice VHD -VHDPath $VMCopyPathLg\$VMName.vhdx -Path $VMConfigLg -Generation 1 -Switch "Hyper-V Network"
        $VMDataPathLg = "$VMCopyPathLg\$VMName" + "_Data.vhdx"
        New-VHD -Path $VMDataPathLg -BlockSizeBytes 128MB -LogicalSectorSizeBytes 4KB -SizeBytes 1TB
        Add-VMHardDiskDrive -vmname $VMName -path $VMDataPathLg
        Set-VMProcessor -VMname $VMName -count $CPUCount
        }

Function Create-Slow {
        $VMCopyPathSl   = "H:\Hyper-V\Virtual HDs"
        $VMConfigSl     = "H:\Hyper-V\Virtual Machines"
        Copy-Item -Path "$VMSourcePath\Template_VM2016.vhdx" -Destination $VMCopyPathSl\$VMName.vhdx
        New-VM -Name $VMName -MemoryStartupBytes $Mem -BootDevice VHD -VHDPath $VMCopyPathSl\$VMName.vhdx -Path $VMConfigSl -Generation 1 -Switch "Hyper-V Network"
        $VMDataPathSl = "$VMCopyPathSl\$VMName" + "_Data.vhdx"
        New-VHD -Path $VMDataPathSl -BlockSizeBytes 128MB -LogicalSectorSizeBytes 4KB -SizeBytes 1TB
        Add-VMHardDiskDrive -vmname $VMName -path $VMDataPathSl
        Set-VMProcessor -VMname $VMName -count $CPUCount
        }


# Prompt for Server name
$VMName = Read-Host 'Enter Server Name in all CAPS'

# Prompt for VM Memory Allocation
$MemPlaceHolder = Read-Host 'Enter Amount of Memory for the VM Example: 12GB(Small) or 16GB(Large)'

# Prompt for CPU Count
$CPUCount = Read-Host 'Enter Number of CPUs for the VM'

# Prompt for VM size
$VMSize = Read-Host "Enter VM Disk speed, only 3 values accepted: Regular, Fast, or Slow"

#  Conversion
$Mem = [int64]$MemPlaceHolder.Replace('GB','') * 1GB

$VMSourcePath    = "H:\Hyper-V\Virtual Machines\New Virtual Machine\Virtual Hard Disks"

If ($VmSize -eq 'Regular')
 {Create-Regular} 
Elseif ($VmSize -eq 'Fast')
 {Create-Fast}
Elseif ($VmSize -eq 'Slow')
{Create-Slow}

Write-Host ========================
Write-Host -ForegroundColor Green "Windows Server 2016 Template found and copied to production Virtal Disk folder" 
Write-Host ========================
Write-Host
Write-Host ========================
Write-Host -ForegroundColor Green "Creating New VM for $VMName"
Write-Host ========================
Write-Host
Write-Host ========================
Write-Host -ForegroundColor Green "Adding SCSI Controller and Data disk to $VMName"
Write-Host ========================
Write-Host
Write-Host ========================
Write-Host -ForegroundColor Green "Adding 1TB Dynamic Data Disk to $VMName"
Write-Host ========================
Write-Host
Write-Host ========================
Write-Host -ForegroundColor Green "Adding Data disk to $VMName"
Write-Host ========================
Write-Host
Write-Host ========================
Write-Host -ForegroundColor Green "Starting New VM $VMName YEA!!!"
Write-Host ========================
Write-Host
Start-VM $VMName
