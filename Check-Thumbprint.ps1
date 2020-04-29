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
