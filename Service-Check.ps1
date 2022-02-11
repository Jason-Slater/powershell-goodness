
<#PSScriptInfo

.VERSION 1.0

.GUID 29a3a034-1eb1-432c-af0e-653d4b8c6d52

.AUTHOR Jason-Slater

.COMPANYNAME Me



#>

<# 

.DESCRIPTION 
 Service Check with email Notification and local logging 

#> 



# Set Script Variables
$Date          = (Get-Date -Uformat "%m-%d-%y_%R").tostring()
$Comp          = $Env:COMPUTERNAME
$SMTPServ      = "SMTP IP or Name"
$SMTPTo        = "Who get it"
$SMTPFrom      = "Who sends it"
$Start         = "Service started on $($Comp)"
$Started       = "Service on $($Comp) is already running"


$ServiceName   = "MSSQLSERVER" 
$ServiceState  = (Get-Service -Name $ServiceName).Status

if ($ServiceState -eq 'Running'){
    Write-Host "Running"
    ($Date + " - " + $ServiceName + " " + $Started) | Out-file "C:\Temp\$($ServiceName)_Service_State.txt" -append
    }
    

elseif ($ServiceState -ne 'Running') {
    Write-Host "Not running"
    Start-Service "SQLSERVERAGENT" 
    Start-Sleep -Seconds 10
    Start-Service $ServiceName
        ($Date + " - " + $ServiceName + " " + $Start) | Out-file "C:\Temp\$($ServiceName)_Service_State.txt" -append
    Send-MailMessage -From $SMTPFrom -To $SMTPTo -Subject "$($ServiceName) Status" -SmtpServer $SMTPServ -Body "$($ServiceName) found not to be running, a service start command has been sent to start the service"
    }

else {
    Write-Host "complete task"
}


 
