$CompList = (Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'} -Properties Name | select-object -ExpandProperty name)

foreach($Computer in $CompList){

if (Test-Connection -ComputerName $computer -Quiet -count 1) 
{
$Compinfo = Get-WmiObject win32_operatingsystem -ComputerName  $Computer | select CSName, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
$userinfo = Get-WmiObject win32_ComputerSystem -ComputerName $Computer | select username
Write-Output $compinfo $Userinfo

}
else
{Write-Output "$computer Offline"
}

}
