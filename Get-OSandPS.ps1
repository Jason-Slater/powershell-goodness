 $Complist = 
 
 foreach ($Comp in $CompList) {

    # Testing if the computer is available via WINRM as a simple test before moving forward
    $PSTestResults = (Test-NetConnection -ComputerName $Comp -CommonTCPPort WINRM -Informationlevel Quiet -WarningAction SilentlyContinue)

    if ($PSTestResults -eq $False) {
        
        Write-Host "*** $($Comp) *** is no bueno" -ForegroundColor Red 
    
    } else { 
  
         # If computer is online this will check for the build number, if it is W2K8 (build 7601) the scrip will continue   
         $OSVersion = (Invoke-Command -ComputerName $Comp -ScriptBlock {([environment]::OSVersion.Version.build)})

            Write-Host "$($Comp) has build number $OSVersion"
    
            if ($OSVersion -eq 7601) {
 
                $PSVersion = (Invoke-Command -ComputerName $Comp -ScriptBlock {($PSVersionTable).PSVersion.Major})

                    Write-Host "$($Comp) has PowerShell version $PSVersion"
                               
            } else {

               # Checks computer for PS version (Major)            
               if ($PSVersion -lt 5 ) {

                    Write-Output "$($Comp) needs to have PowerShell Updated"

                }
            }

     }

}
