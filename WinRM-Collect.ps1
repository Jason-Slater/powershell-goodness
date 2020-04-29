# WinRM Data Collection
# Requires ADMIN Rights.

#PARAM IS ONLY TO RUN WINRM ID -R:COMPUTERNAME, DOES NOT COLLECT LOGS AGAINST REMOTE MACHINE.
Param ([String]$RemoteMachine)

#Configure Vars
$LogDir = "$Env:USERPROFILE\Desktop\WinRM-Collect-$ENV:COMPUTERNAME"

#============================================================================================================
#Setup DIR to store logs
#============================================================================================================

If (!(Test-Path -Path $LogDir))
    {
       $datapath = New-Item -ItemType Directory -Path $LogDir
    }
Else
    {
    Write-Output "Path already exists, please remove or rename WinRM-Collect Folder on the Desktop"
    Break
    }

#============================================================================================================
# Configure Transcript
#============================================================================================================
#Start Transcript
Start-Transcript -Path "$LogDir\Transcript.log"

#============================================================================================================
# Turn on event logs if not enabled.
#============================================================================================================

    Write-Output "[0] Enabling Event Logs"
    $Analytic = Get-WinEvent -ListLog 'Microsoft-Windows-WinRM/Analytic' | select -ExpandProperty IsEnabled
        If (($Analytic) -ne "True")
        {
            Wevtutil.exe SL /E:True Microsoft-Windows-WinRM/Analytic /quiet:True
        }

    $Debug = Get-WinEvent -ListLog 'Microsoft-Windows-WinRM/Debug' | select -ExpandProperty IsEnabled
        If (($Debug) -ne "True")
            {
            Wevtutil.exe SL /E:True Microsoft-Windows-WinRM/Debug /quiet:True
            }

    $Operational = Get-WinEvent -ListLog 'Microsoft-Windows-WinRM/Operational' | select -ExpandProperty IsEnabled
        If (($Debug) -ne "True")
        {
        Wevtutil.exe SL /E:True Microsoft-Windows-WinRM/Operational /quiet:True
        }

#============================================================================================================
# Configure AND start WINRM-WINHTTP ETL Trace, and NETWORK trace.
#============================================================================================================
Write-Output "[1] Configuring and Starting ETL Trace"
Write-Output ""

cmd.exe /c 'logman create trace "winrm_winhttp" -ow -o C:\WinRM-WinHTTP.etl -p "Microsoft-Windows-WinRM" 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 4096 -ets'
cmd.exe /c 'logman update trace "winrm_winhttp" -p {04C6E16D-B99F-4A3A-9B3E-B8325BBC781E} 0xffffffffffffffff 0xff -ets'
cmd.exe /c 'logman update trace "winrm_winhttp" -p "Microsoft-Windows-WinHttp" 0xffffffffffffffff 0xff -ets'
cmd.exe /c 'logman update trace "winrm_winhttp" -p {72B18662-744E-4A68-B816-8D562289A850} 0xffffffffffffffff 0xff -ets'
cmd.exe /c 'logman update trace "winrm_winhttp" -p {B3A7698A-0C45-44DA-B73D-E181C9B5C8E6} 0xffffffffffffffff 0xff -ets'
#Only Needed on Mobile cmd.exe /c 'logman update trace "winrm_winhttp" -p "Microsoft-WindowsPhone-WinhttpPalWp" 0xffffffffffffffff 0xff -ets'
Write-Output ""

Write-Output "[2] Configuring and Starting Network Trace"
Write-Output ""

netsh trace start scenario=netconnection capture=yes tracefile=C:\NetworkTrace.etl
Write-Output ""


#============================================================================================================
# Repro Here
#============================================================================================================

read-host "Reproduce Your Issue Now, when done press ENTER here"

Write-Output "[3] Stopping WinRM ETL"

cmd.exe /c 'logman stop "winrm_winhttp" -ets'

Write-Output ""
Write-Output "[4] Stopping Network Trace"
netsh trace stop

Write-Output ""
Write-Output "[5] Moving Trace Files to LogDir"
Move-Item -Path "C:\WinRM-WinHTTP.etl" -Destination $LogDir
Move-Item -Path "C:\NetworkTrace.etl" -Destination $LogDir
Move-Item -Path "C:\NetworkTrace.cab" -Destination $LogDir

Write-Output "[6] ETL Data Collected, moving to Static Log Collection..."
Write-Output ""

#============================================================================================================
# Collect all needed logs after Repro
#============================================================================================================

    Write-Output "[7] Capturing Win32_OperatingSystem"
    Get-WmiObject -class Win32_OperatingSystem | fl * | Out-File "$LogDir\OS Info.txt"

    Write-Output "[8] Capturing Windows Update List"
    Get-Hotfix | Out-File "$LogDir\Updates.txt"

    Write-Output "[9] Capturing IPConfig"
    IPCONFIG /ALL | Out-File "$LogDir\IPConfig.txt"

    Write-Output "[10] Capturing Services"
    $Services = Get-Service -Name * | Out-File "$LogDir\Services.txt"

    Write-Output "[11] Capturing WinRM Config"
    $WinRMConfig = WinRM Get WinRM/Config | Out-File -FilePath "$LogDir\WinRM Config.txt"

    Write-Output "[12] Capturing WinRM Listener"
    $WinRMConfig = WinRM Enumerate WinRM/Config/Listener | Out-File -FilePath "$LogDir\WinRM Listener.txt"

    Write-Output "[13] Capturing Firewall rules for WinRM"
    $FirewallRules = Get-NetFirewallRule *winrm* | Out-File -FilePath "$LogDir\Firewall Rules.txt"

    Write-Output "[14] Capturing WinRM Registry"
    Reg Export HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN "$LogDir\WinRM Reg.reg"

    Write-Output "[15] Capturing WinRM GPO Registry"
    Reg Export HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM "$LogDir\WinRM GPO Reg.reg"

    Write-Output "[16] Capturing WSMAN Schema"
    Copy-Item -Path "C:\Windows\System32\wsmanconfig_schema.xml" -Destination $LogDir

    Write-Output "[17] Performing WinRM Ping - Local and Remote"
    WinRM id | Out-File  "$LogDir\WinRM ID Local.txt"
    WinRM id -R:$RemoteMachine | Out-File  "$LogDir\WinRM ID -R.txt"

    If ($RemoteMachine -ne $null)
    {
    WinRM id -R:$RemoteMachine | Out-File  "$LogDir\WinRM ID RemoteMachine.txt"
    }

    Write-Output "[18] Capturing Proxy Settings"
    Netsh winhttp show proxy | Out-File  "$LogDir\Proxy Settings.txt"

    Write-Output "[19] Capturing WINHTTP Listeners"
    Netsh http show iplisten | Out-File  "$LogDir\HTTP Listeners.txt"

    Write-Output "[21] Exporting Windows-WinRM/Analytic"
    Wevtutil.exe epl Microsoft-Windows-WinRM/Analytic "$LogDir\WinRM-Analytic.evtx"
    Write-Output "[22] Exporting Windows-WinRM/Debug"
    Wevtutil.exe epl Microsoft-Windows-WinRM/Debug "$LogDir\WinRM-Debug.evtx"
    Write-Output "[23] Exporting Windows-WinRM/Operational"
    Wevtutil.exe epl Microsoft-Windows-WinRM/Operational "$LogDir\WinRM-Operational.evtx"

    Write-Output "[24] Exporting Application Event Log"
    Wevtutil.exe epl Application "$LogDir\Application.evtx"

    Write-Output "[25] Exporting System Event Log"
    Wevtutil.exe epl System "$LogDir\System.evtx"

    Write-Output "[26] Capturing GPRESULT"
    GPRESULT /H "$LogDir\GPresult.html"

    Write-Output "[27] Capturing SPN Config - This step may take a while."
    cmd.exe /c "setspn.exe -Q */$ENV:COMPUTERNAME > $LogDir\SPNs.txt & EXIT"

    Write-Output "[28] Capturing NETSTAT"
    netstat -anob | Out-File  "$LogDir\NETSTAT.txt"

    Write-Output "[29] Exporting Kerberos Config Registry"
    Reg Export HKLM\SYSTEM\CurrentControlSet\Control\LSA\Kerberos\Parameters "$LogDir\Kerberos.reg"

    Write-Output "[30] Exporting HTTP Registry"
    Reg Export HKLM\System\CurrentControlSet\Services\HTTP\Parameters "$LogDir\HTTP.reg"

#============================================================================================================
# Compress data and cleanup.
#============================================================================================================
Stop-Transcript

If ((Test-Path -Path "$env:userprofile\Desktop\WinRM-Collect-$env:computername.zip") -eq $False)
    {
       Compress-Archive -Path $LogDir -DestinationPath "$env:userprofile\Desktop\WinRM-Collect-$env:computername"
    }
Else 
    {
    Rename-Item "$env:userprofile\Desktop\WinRM-Collect-$env:computername.zip" -NewName "$env:userprofile\Desktop\WinRM-Collect-$env:computername.Zip.Old"
    Compress-Archive -Path $LogDir -DestinationPath "$env:userprofile\Desktop\WinRM-Collect-$env:computername"
    }

Write-Output ""
Write-Output "Please Collect the WinRM-Collect-ComputerName.zip file on your desktop and upload to your Support Engineer"
