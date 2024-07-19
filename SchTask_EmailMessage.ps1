<#PSScriptInfo

.VERSION 1.0

.GUID 1474c41d-3a5a-4a6f-8c8a-8e789f48f0af

.AUTHOR Jason-Slater

.REPO  https://github.com/Jason-Slater/powershell-goodness

.COMPANYNAME Me #>

param (
    [int]$EventID = 700,
    [string]$LogSource = "System",
    [string]$SMTPServer = "smtp.example.com",
    [string]$From = "sender@example.com",
    [string]$To = "group@example.com",
    [string]$Subject = "Event ID Report",
    [string]$MessageBody = "Event ID 6009 has been found, this has happened {0} amount of times in the past 24 hours."
)

# Get the current date and time
$EndTime = Get-Date

# Get the date and time 24 hours ago
$StartTime = $EndTime.AddHours(-24)

# Get the number of event ID occurrences in the last 24 hours
$EventCount = Get-EventLog -LogName $LogSource -InstanceId $EventID -After $StartTime -Before $EndTime | Measure-Object | Select-Object -ExpandProperty Count

# Prepare the email body
$EmailBody = $MessageBody -f $EventCount

# Send the email
$mailMessage = @{
    From       = $From
    To         = $To
    Subject    = $Subject
    Body       = $EmailBody
    SmtpServer = $SMTPServer
}
Send-MailMessage @mailMessage

# Log the action to the event log
Write-EventLog -LogName Application -Source "PowerShell Script" -EventId 1000 -EntryType Information -Message "Email sent with event ID $EventID count: $EventCount"

