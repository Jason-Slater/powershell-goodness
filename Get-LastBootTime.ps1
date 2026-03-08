
<#PSScriptInfo

.VERSION 2.1

.GUID ccac5b8b-807f-407b-aee0-06d41b675ce3

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.DESCRIPTION

 Pulls all Server objects from AD then interrogates them for OS version & last boot time
 Displays output in a colorful display :-) 

#> 



# 1. Get all server names and OS info in one call
$Computers = Get-ADComputer -Filter "OperatingSystem -like '*Windows Server*'" -Properties OperatingSystem

$Results = Foreach ($Computer in $Computers) {
    $ComputerName = $Computer.Name
    $Report = [PSCustomObject]@{
        Name            = $ComputerName
        OperatingSystem = $Computer.OperatingSystem
        LastBootUpTime  = $null
        Status          = "Success"
    }

    # 2. Connection Check (Optional but helpful)
    if (-not (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet)) {
        $Report.Status = "Offline/No Ping"
        $Report
        continue
    }

    try {
        # 3. Get Uptime using modern CIM
        $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
        $Report.LastBootUpTime = $OS.LastBootUpTime
    } 
    catch {
        $Report.Status = "RPC/CIM Unavailable"
    }

    # Output the object to the collection
    $Report
}

# 4. Sort by Boot Date (Oldest to Newest) and Display
$Results | Sort-Object LastBootUpTime | Select-Object Name, Status, LastBootUpTime, OperatingSystem | Out-GridView


