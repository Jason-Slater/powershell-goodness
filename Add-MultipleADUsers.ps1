

<#PSScriptInfo

.VERSION 
    1.0

.GUID 
    335908a0-f839-41db-881a-5c4c3f776dfb

.AUTHOR 
    Jason S.

.COMPANYNAME
    Me

.SYNOPSIS
    Creates multiple User accounts in Active Directory

.DESCRIPTION
    Powershell script to import a precreated CSV file with user Attribute Data to be used when creating multiple accounts at one time

.DEPENDENCIES
    PowerShell version 4 or Greater
#> 

Write-Host "MUST OPEN POWERSHELL AS ADMINISTRATOR AND HAVE PERMISSIONS TO CREATE OBJECTS IN ACTIVE DIRECTORY" -ForegroundColor Red

#########################################
##           Dependency Checks         ##
#########################################

# Powershell Version Check
$PS = ($PSVersiontable).PSVersion
Write-Host "PowerShell version is $PS" "`t" -NoNewline; 
Write-Host "NOTE: Script requires PS 4.0 or greater" 


# AD Commandlet Check and Install
if (Get-Module -ListAvailable -Name ActiveDirectory) {
  Write-Host "Module exists" -ForegroundColor Green
}
else {
  Write-Host "Module does not exist, this script will add it" -ForegroundColor Yellow
    Install-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
    Install-Module -Name WindowsCompatibility
    Import-Module -Name ActiveDirectory
  }



# File Check
$FILE = 'C:\Temp\Users.csv'
IF (-not (Test-Path -Path $FILE)) {
    write-Host "Files does not exist, please create it" -ForegroundColor Red
}
else
{
    Write-Host "File exists..YEA!" -ForegroundColor Green
}



#########################################
##             USER CREATION           ##
#########################################

# Input "temporary" user password 
$PSWD = Read-Host "Enter 14 character complex password to be used as temporary user password"  

Import-Csv $FILE | 
    ForEach-Object{New-ADUser -Name $_.name -Surname $_.surname -GivenName $_.givenname -UserPrincipalName $_.UserPrincipalName -AccountPassword (ConvertTo-SecureString -AsPlainText "$PSWD" -Force) -Enabled $true -Verbose}
