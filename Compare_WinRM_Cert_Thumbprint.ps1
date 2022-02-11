<#PSScriptInfo

.VERSION 
    1.0

.GUID 
    1fc76354-5c3a-47f7-a894-6247346b66cb

.AUTHOR 
    Jason S.

.COMPANYNAME
    Me

.SYNOPSIS
    Checks to see if the certificate being used for WinRM HTTPS matches the Certificate in the certificate store
    
.NOTE
    In PowerShell 5.1 the output returned for a certificate thumbprint is not always correct, Microsoft has stated this has been
    corrected in later versions of PowerShell

.DEPENDENCIES
    PowerShell version 4 or Greater
#> 




# Confirm there is a listener
dir WSMan:\localhost\Listener | Where Keys -like *https* | select -expand Name
 
 
# If there is a WinRM listener on the server then execute the following to obtian certificate thumbprint and WinRM listener thumbprint
$CertThumb = (get-childitem -path Cert:\LocalMachine\My -recurse |
    where-object {$_.subject -like "*MULTI-ALLOWED*" } |
        Select-Object Thumbprint |
            Format-Table -HideTableHeaders |
                Out-String).trim()
 
# Obtain Certificate expiration
$CertExp = (get-childitem -path Cert:\LocalMachine\My -recurse |
    where-object {$_.subject -like "*MULTI-ALLOWED*" } |
        Select-Object NotAfter |
            Format-Table -HideTableHeaders |
                Out-String).trim()
 
 $WinRMThumb = ((Get-WSManInstance -ResourceURI winrm/config/listener -SelectorSet @{Address="*";Transport="https"}).CertificateThumbprint -replace ' ').ToUpper()
 
# Perform comparison operation
 If ($CertThumb -eq $WinRMThumb)
    {Write-Host "Thumbprints Match" -ForegroundColor Green
     Write-Host "Certificate Expiration date $($CertExp)"
     Write-Host "CertificateThumbPrint   = $($CertThumb)"
     Write-Host "WinRMListenerThumbPrint = $($WinRMThumb)"
    }
 Else
    {Write-Host "Thumbprints DO NOT Match" -ForegroundColor Red
     Write-Host "Certificate Expiration date $($CertExp)"
     Write-Host "CertificateThumbPrint   = $($CertThumb)"
     Write-Host "WinRMListenerThumbPrint = $($WinRMThumb)"
    }
