Function Identify-Computers {
    $DaysInactive = 90
    $Time         = (Get-Date).Adddays(-($DaysInactive))
    $Date         = Get-Date

    # Temp folder check / create if not present
    If ((Test-Path -Path 'c:\Temp') -eq $False)
        {New-Item -Path 'c:\Temp' -ItemType Directory}
    
    # Get all computer objects that have not coomumicatd with the date stated in the variable then writes it out to file
    Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -Properties *|`
    Select-object Name, OperatingSystem, PasswordLastSet, Enabled |`
    Format-Table -auto |`
    Out-File -FilePath c:\temp\ComputerDeletions_$(($Date).ToString('MM-dd-yyyy-hh-mm')).txt
}

Identify-Computers


Function Test-ServConnection {
    
    [DateTime]$Time = (Get-Date).Adddays(-(90))
    $CompList = @(Get-ADComputer -Filter 'LastLogonTimeStamp -lt $Time' -Properties Name).name

    Foreach ($Comp in $CompList){
        If((Test-NetConnection -ComputerName $Comp -CommonTCPPort RDP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TCPTestSucceeded -eq $True)
            {echo "$Comp"}
    }
}

Test-ServConnection

#### Caution ~~~ This will not pick up any accounts used for mailboxes so it is possible to disable an unused mailbox user account
Function Identify-Users {
    $DaysInactive = 90
    $Time         = (Get-Date).Adddays(-($DaysInactive))
    $Date         = Get-Date
    Get-ADUser -Filter {LastLogonTimeStamp -lt $Time} -Properties *|`
    Select-object CN, DisplayName, PasswordLastSet, Enabled |`
    Format-Table -auto |`
    Out-File -FilePath c:\temp\UserDeletions_$(($Date).ToString('MM-dd-yyyy-hh-mm')).txt
}

Identify-Users


