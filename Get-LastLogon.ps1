
<#PSScriptInfo

.VERSION 1.0

.GUID c0876cde-1ea2-469a-a814-5f34d016ef95

.AUTHOR Jason S.

.COMPANYNAME My Company of Awesome

.DESCRIPTION 

 Powershell script to identify User accounts that have not been logged into for 90 days or more

.Dependencies
Active Directory Powershell Module
C:\Temp Folder

#> 

#Import Active Directory PowerShell Module
Import-module ActiveDirectory

#Getting users who haven't logged in in over 90 days
$Date     = (Get-Date).AddDays(-90)

#Getting date for file name ouput
$FileDate = (Get-Date -Format MM.dd.yyyy)

#Obtain Domain NetBiosName for file name output
$NetBio   = (Get-ADDomain -Identity (Get-WmiObject Win32_ComputerSystem).Domain).NetBIOSName
 
#Filtering All enabled users who haven't logged in.
$Report  = Get-ADUser -Filter {((Enabled -eq $true) -and (LastLogonDate -lt $date))} -Properties LastLogonDate | select samaccountname, Name, LastLogonDate | Sort-Object LastLogonDate

#Export Report
$Report | Export-CSV C:\temp\LastLogonReport_"$NetBio"_"$FileDate".csv -NoTypeInformation
