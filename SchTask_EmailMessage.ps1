<#

PSScriptInfo

.README
    This PS has been written to be used as a "triggered" script used with a local scheduled
    task, executed in the event a condition has been satisfied, in this scenario it is related
    to the appearance of an event within a specific event log

.VERSION 1.0

.GUID 1474c41d-3a5a-4a6f-8c8a-8e789f48f0af

.AUTHOR Jason-Slater

.REPO  https://github.com/Jason-Slater/powershell-goodness

.DEPENDENCIES  
    C:\Temp\TaskSch-EmailAlert folder created on c:\ where the PS file and output log file live
    O365 SMTP 

.COMPANYNAME Me 

#>

param (
    [int]$EventID = 700,
    [string]$SMTPServer = "smtp.office365.com",
    [int]$SMTPPort = 587,
    [string]$From = "xxxx@yyyyy.zzz",
    [string]$To = "xxxx@yyyyy.zzz",
    [string]$Subject = "Event ID Report",
    [string]$MessageBody = "Event ID 700 has been found, this has happened {0} times in the past 24 hours.",
    [string]$LogFile = "C:\Temp\TaskSch-EmailAlert\log.txt",
    [string]$SMTPUser = "xxxx@yyyyy.zzz",
    [string][ValidateNotNullOrEmpty()]$SMTPPassword = "something_really_long_here"
)
# Function to write a log message
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$Timestamp - $Message"
    $LogMessage | Add-Content -Path $LogFile
}
# Log the start of the script
Write-Log "Script started."

try {
    # Get the current date and time
    $EndTime = Get-Date

    # Get the date and time 24 hours ago
    $StartTime = $EndTime.AddHours(-24)

    # Get the number of event ID occurrences in the last 24 hours
    $Events = Get-WinEvent -FilterHashTable @{LogName='Microsoft-Windows-TerminalServices-Gateway/Admin'; Id='700'; StartTime=$StartTime}
    $EventCount = $Events.Count
    
    # Log the event count
    Write-Log "Event ID $EventID found $EventCount times in the past 24 hours in $LogName."
    
    # Prepare the email body
    $EmailBody = $MessageBody -f $EventCount
 
    #Selt TLS to 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Send the email
    $SecurePassword = ConvertTo-SecureString -String $SMTPPassword -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($SMTPUser, $SecurePassword)
    $mailMessageParameters = @{
        From       = $From
        To         = $To
        Subject    = $Subject
        Body       = $EmailBody
        SmtpServer = $SMTPServer
        Port       = $SMTPPort
        UseSsl     = $True
        Credential = $Credential
    }
    Send-MailMessage @mailMessageParameters
 
    # Log the email sending action
    Write-Log "Email sent to $To with subject '$Subject'."

} catch {

    # Log any errors
    Write-Log "Error: $_"
}

# Log the end of the script 
Write-Log "Script finished."