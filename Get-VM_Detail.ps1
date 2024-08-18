<#

PSScriptInfo

.README
    This PS has been created to obtain attribues of a VM on a Hyper-V server

.VERSION 1.0

.GUID 6a728858-565a-404f-8a61-9c67f0e56ebd

.AUTHOR Jason-Slater

.REPO  https://github.com/Jason-Slater/powershell-goodness

.DEPENDENCIES  
    None

.COMPANYNAME Me 

#>



# Get all VMs on the Hyper-V server
$vms = Get-VM

# Loop through each VM and get detailed configuration
foreach ($vm in $vms) {
    # Display the VM name with an underline in green
    $vmName = $vm.Name
    Write-Host "$vmName" -ForegroundColor Green
    Write-Host ("=" * $vmName.Length) -ForegroundColor Green

    # Display VM details
    $vmDetails = [PSCustomObject]@{
        'State'          = $vm.State
        'CPU Usage (%)'  = $vm.CPUUsage
        'Memory Assigned (MB)' = $vm.MemoryAssigned
        'Uptime'         = $vm.Uptime
        'Status'         = $vm.Status
        'Version'        = $vm.Version
        'vCPU Count'     = $vm.ProcessorCount
    }
    $vmDetails | Format-Table -AutoSize

    # Get network adapter and IP configuration details
    $vmAdapters = $vm | Get-VMNetworkAdapter
    foreach ($adapter in $vmAdapters) {
        $adapterDetails = [PSCustomObject]@{
            'Network Adapter Name' = $adapter.Name
            'Switch Name'          = $adapter.SwitchName
            'IP Addresses'         = $adapter.IPAddresses -join ', '
        }
        $adapterDetails | Format-Table -AutoSize
    }

    # Get information about the hard disk drives attached to the VM
    $vmDisks = $vm | Get-VMHardDiskDrive
    foreach ($disk in $vmDisks) {
        $diskDetails = [PSCustomObject]@{
            'Hard Drive Path'   = $disk.Path
            'Controller Type'   = $disk.ControllerType
            'Controller Number' = $disk.ControllerNumber
        }
        $diskDetails | Format-Table -AutoSize
    }

    # Get information about DVD drives attached to the VM (if any)
    $vmDvds = $vm | Get-VMDvdDrive
    foreach ($dvd in $vmDvds) {
        $dvdDetails = [PSCustomObject]@{
            'DVD Drive Path'    = $dvd.Path
            'Controller Type'   = $dvd.ControllerType
            'Controller Number' = $dvd.ControllerNumber
        }
        $dvdDetails | Format-Table -AutoSize
    }

    # Get snapshot information (if any)
    $vmSnapshots = $vm | Get-VMSnapshot
    foreach ($snapshot in $vmSnapshots) {
        $snapshotDetails = [PSCustomObject]@{
            'Snapshot Name'  = $snapshot.Name
            'Creation Time'  = $snapshot.CreationTime
            'Snapshot State' = $snapshot.State
        }
        $snapshotDetails | Format-Table -AutoSize
    }

    Write-Host ""  # Add a blank line between VMs for readability
}
