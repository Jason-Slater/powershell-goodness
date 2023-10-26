Set-ExecutionPolicy Unrestricted -force


# Function to test connection of an array of servers before obtaining uptime
Function Get-UpTime 
{ Param ([string[]]$servers) 
  Foreach ($s in $servers)  
   {  
     if(Test-Connection -cn $s -Quiet -BufferSize 16 -Count 1) 
       { 
        $os = Get-WmiObject -class win32_OperatingSystem -cn $s  
        New-Object psobject -Property @{computer=$s; 
        uptime = (get-date) - $os.converttodatetime($os.lastbootuptime)} } 
      ELSE 
       { New-Object psobject -Property @{computer=$s; uptime = "DOWN"} } 
      } 
    } #end function Get-Uptime 
 
 
# Entry Point *** 
 
[array]$servers = ([adsisearcher]"(&(objectcategory=computer))").findall() | 
      foreach-object {([adsi]$_.path).cn} 
 
$upTime = Get-UpTime -servers $servers |export-csv c:\Uptime_10_7_16.csv