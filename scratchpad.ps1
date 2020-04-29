

New-SelfSignedCertificate -DnsName "servername" -CertStoreLocation Cert:\LocalMachine\My

$LocalHost = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname

$CertThumb = (Get-ChildItem -path Cert:\LocalMachine\My -recurse |
    where-object {$_.subject -like "*MULTI-ALLOWED*" } |
        Select-Object Thumbprint |
            Select-Object -Last 1 -ExpandProperty Thumbprint) 
            
            
$LocalFQDN = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname


$NewThumb = (Get-ChildItem -path Cert:\LocalMachine\My -recurse |
    where-object {$_.subject -like "*MULTI-ALLOWED*" } |
        Select-Object Thumbprint |
            Select-Object -Last 1 -ExpandProperty Thumbprint)            

                          

Set-WSManInstance -ResourceURI winrm/config/Listener `
    -ComputerName $($LocalFQDN) `
    -SelectorSet @{Address="*";Transport="HTTPS"} `
    -ValueSet @{CertificateThumbprint=$($NewThumb)}
            
            
 (Get-Service WinRM).Status
 
 
 
 winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="servername"; CertificateThumbprint="thumbprint"}'
'; Address='*'} -ValueSet @{Hostname="$($LocalHost)";CertificateThumbprint="$($CertThumb)"}
