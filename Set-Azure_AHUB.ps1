 <#
.SYNOPSIS
     RunBook Enforces AHUB Licensing on Windows Servers 
.DESCRIPTION
     RunBook Checks for Azure Hybrid Benifit Licencing set on Windows Server VMs, if not set then it it will be set
.NOTES
     Author     : Jason
 
#>

　
　
$ConnectionName = "AzureRunAsConnection"
try {
    $ServicePrincipalConnection=Get-AutomationConnection -Name $ConnectionName

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantID $ServicePrincipalConnection.TenantID `
        -ApplicationId $ServicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint
}
Catch {
    if (!$ServicePrincipalConnection)
    {
        $ErrorMessage = "Connection $ConnectionName not found."
        throw $ErrorMessage 
    }else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
        

 
Select-AzureRmSubscription $_
    Get-AzureRMVM | ForEach-Object {
        if ($_.StorageProfile.OSDisk.OSType -match "Windows") {
            $_.LicenseType
                if ($_.LicenseType -notmatch "Windows_Server") {
                $_.LicenseType = "Windows_Server"
                    Update-AzureRmVM -ResourceGroupName $_.ResourceGroupName -VM $_
        }
           
    }
}

　
 
