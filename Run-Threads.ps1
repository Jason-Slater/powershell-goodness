<#PSScriptInfo

.VERSION 4.0

.GUID e235346f-528a-41a1-95a8-645313dbe792

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.COPYRIGHT 2019

.EXTERNALSCRIPTDEPENDENCIES 
c:\scripts folder created, this is also where scripts are executed from

.RELEASENOTES
Developed internally to be used by My Company of Awesome Engineers

.DESCRIPTION 
 Run-Threads will deliver a another script "payload" in a parellel fashion across mutlple servers simultaneously 

#> 


[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False,Position=1)]
    [string]$scriptFile = "c:\Scripts\Get-RolesFeatures.ps1",
    [Parameter(Mandatory=$False,Position=2)]
    [string]$computerList = "c:\Scripts\serverlist.txt",
    [Parameter(Mandatory=$False,Position=3)]
    [int]$maxThreads = 50,
    [Parameter(Mandatory=$False,Position=4)]
    [int]$checkInterval = 2,
    [Parameter(Mandatory=$False,Position=5)]
    [int]$threadTimeout = 360,
    [Parameter(Mandatory=$False,Position=6)]
    [bool] $useAD = $true,
    [Parameter(Mandatory=$False,Position=7)]
    [int] $testLimit = 0
)
 
$starttime = Get-Date
$guid = [guid]::NewGuid()
#set this to false if you want to use an input file
 
 
#=======================================
#     Get a list of targets
#=======================================
 
#edit to use an input file or AD for a computerlist
if ($useAD)
{
    $Computers = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'} -Properties OperatingSystem | Select-Object Name)
    #$Computers = (Get-ADGroupMember -Identity AZ_systems_admine | Select-Object Name)
 
} else {
    $Computers = Get-Content $computerList
}
 
$k = 0
# make an array of objects out of the computer list
$aObjectList = @()
foreach ($computer in $Computers)
{
    $tempinfo = @{}
    if ($useAD)
    {
        $tempinfo.computer = $computer.Name
    } else {
        $tempinfo.computer = $computer
    }
    $tempinfo.status = "Not Run"
    $tempObject = New-Object –TypeName PSObject –Prop $tempinfo
    $aObjectList += $tempObject
    $k++
    if($testLimit)
    {
        if($k -ge $testLimit){break}
    }
}
 
#Set some variables and make a work folder
$totalCount = $aObjectlist.count
If ($totalCount)
{
    $scriptName = (Get-ItemProperty -Path $scriptFile).BaseName
    $jobtitle = "$scriptname" + "_$totalCount"
    $outputpath = "c:\Scripts\output\" + "$jobtitle" + "_$guid"
    New-Item -ItemType directory -Path $outputpath
    Invoke-Item $outputpath
} else {    
    "No targets, Exiting"
    exit
}
 
#=======================================
#     Create and manage jobs
#=======================================
 
$completeCount = 0
$running = $true
$firstrun = $true
while ($running)
{
    $aCompleted = @()
    $aRunning = @()
    $aTimeOut = @()
 
    $perc = ($completeCount / $totalCount * 100)
    Write-Progress  -Activity "Checking Jobs" -Status "$completeCount complete out of $totalcount" -PercentComplete $perc
    
    #get completed jobs
    foreach ($job in get-job)
    {
        $jobname = $job.name
        if ($jobname -like "*$guid")
        {
            $state = $job.state
            $begin = $job.PSBeginTime
            $timediff = New-timespan -Start $begin -End (Get-Date)
            $timediff.seconds
            if ($state -eq "Completed")
            {
                $aCompleted += $jobname
            } elseif ($timediff.TotalSeconds -ge $threadTimeout) {
                $aTimeOut += $jobname
            } else {
                $aRunning += $jobname
            }
        }
    }
 
    
    foreach ($tempobject in $aObjectList)
    {
        $computer = $tempobject.computer
        $jobname = $tempobject.computer + "_$guid"
        if ($aCompleted -contains $jobname)
        {
            $result = (receive-job -Name $jobname)
            $outfile = $outputpath + "\$computer.xml"
            out-file -FilePath $outfile -InputObject $result
            #close the job
            Remove-Job -Name $jobname
            #set completed jobs to complete in the object
            $tempobject.status = "Complete"
        }
        if ($aTimeOut -contains $jobname)
        {
            $result = "<server><Server_Name>$computer</Server_Name><Server_Error>Error: Thread Timout $threadTimeout seconds</Server_Error></server>"
            $outfile = $outputpath + "\$computer.xml"
            out-file -FilePath $outfile -InputObject $result
            #close the job
            Stop-job -name $jobname
            start-sleep -Milliseconds 500
            Remove-Job -Name $jobname -force
            #set completed jobs to complete in the object
            $tempobject.status = "Complete"
        }
    }
    
    $tempcompleteCount = 0
    $i = 0
    foreach ($tempobject in $aObjectList)
    {
        $computer = $tempobject.computer
        $status = $tempobject.status
        $jobname = $computer + "_$guid"
        #check for computers that have not started
        if ($status -ne "Complete" -and $status -ne "Running")
        {
            #check if we have any open threads to start them
 
            if ($maxthreads -ge  ($aRunning.count + $i))
            {
                $i++
                Start-Job -FilePath $scriptFile -ArgumentList $Computer -Name $jobname | Out-Null
                if ($firstrun){sleep -Milliseconds 750} else {sleep -Milliseconds 30}
                $tempobject.status = "Running"
                $stillrunning = $true
                Write-Progress  -Activity "Adding Thread for $Computer" -Status "$completeCount complete out of $totalcount"  -PercentComplete $perc
                #$jobname
            }
        } elseif ($status -eq "Complete") {++$tempcompleteCount}
    
    }
    
    $completeCount = $tempcompleteCount
    $perc = ($completeCount / $totalCount * 100)
    "$perc percent complete, $completeCount complete out of $totalcount"
    
    if($completeCount -eq $totalCount){break}
    get-job | select-object name,state | ft
 
    For ($i=1; $i -le $checkInterval; $i++)
    {
        $countdown = $checkInterval - $i
        Write-Progress  -Activity "Checking jobs in $countdown seconds" -Status "$completeCount complete out of $totalcount" -PercentComplete $perc
        sleep -Seconds 1
    }
    $firstrun = $false
}
 
#=======================================
#     Post Processing
#=======================================
 
$postprocess = $true
if ($postprocess)
{
    $outmasterdir = "$outputpath" + "\master"
    New-Item -ItemType directory -Path $outmasterdir
    $outmaster = $outmasterdir + "\$jobtitle.xml"
    Out-File -append ascii -InputObject "<list>" -filepath $outmaster
    $resultList = Get-ChildItem $outputpath -Filter "*.xml"
    foreach ($resultfile in $resultList)
    {
        $result = Get-Content $resultfile.Fullname
        Out-File -append ascii -InputObject $result -filepath $outmaster
    }
    Out-File -append ascii -InputObject "</list>" -filepath $outmaster
}
Invoke-Item $outmasterdir
 
#=======================================
#     After Action Output
#=======================================
 
Write-Progress  -Activity "Complete!" -Status "$completeCount complete out of $totalcount" -PercentComplete $perc
$endtime = (Get-Date)
$TimespanS = ($endtime - $starttime).TotalSeconds
" "
"============================="
"Complete!"
"Start Time: $starttime"
"End Time: $endtime"
"Time Elapsed: $timespanS seconds"
"$totalCount nodes processed"
sleep -seconds 5 