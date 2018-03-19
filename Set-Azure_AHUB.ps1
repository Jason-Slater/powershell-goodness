<#
.SYNOPSIS
     RunBook Enforces AHUB Licensing on Windows Servers 
.DESCRIPTION
     RunBook Checks for Azure Hybrid Benifit Licencing set on Windows Server VMs, if not set then it it will be set
.NOTES
     Author     : Jason
 
#>


$AzureSub = @("Visual Studio Enterprise","Visual Studio Professional with MSDN")

$AzureSub | ForEach-Object { 
    Select-AzureRmSubscription $_
        Get-AzureRMVM | ForEach-Object {
            if ($_.StorageProfile.OSDisk.OSType -match "Windows") {
                $_.LicenseType
                    if ($_.LicenseType -notmatch "Windows_Server") {
                    $_.Name
                    $_.ResourceGroupName
                    $_.LicenseType = "Windows_Server"
                        Update-AzureRmVM -ResourceGroupName $_.ResourceGroupName -VM $_
                          
            }

        }
           
    }
}


