#  TO DO: 
#  Add Newton Admin to every Group
#  make the Test User account unique
#  Fix $NEWUSER output


<#

$N9CloudDC = "192.168.253.160"

New-PSDrive -Name N9CLOUD -PSProvider ActiveDirectory -Server $N9CloudDC -Credential (Get-Credential) -Root "//RootDSE/" -Scope Global

#>

# Prompt for Customer Name to Create the AD OU
$OUName = Read-Host 'Enter Customer Name to Create the Active Directory OU'
Write-Host ========================
Write-Host -ForegroundColor Green "Creating connection to the N9Cloud domain"
Write-Host ========================
Write-Host
# CD N9Cloud:

# Create The Domain Users and Domain Group OUs For the Customer
Write-Host ========================
Write-Host -ForegroundColor Green "$OUName un Domain Groups and $OUName under Domain Users is being created"
Write-Host ========================
Write-Host
New-ADOrganizationalUnit `
    -Name $OUName `
    -DisplayName $OUName `
    -Path "OU=Domain Users,DC=N9CLOUD,DC=com" `
    -Description "Domain Users for $OUName" 

New-ADOrganizationalUnit `
    -Name $OUName `
    -DisplayName $OUName `
    -Path "OU=Domain Groups,DC=N9CLOUD,DC=com" `
    -Description "Domain Groups for $OUName" 

# Create new AD Group
Write-Host ========================
Write-Host -ForegroundColor Green "$OUName is being created"
Write-Host ========================
Write-Host
New-ADGroup `
    -Name $OUName `
    -SamAccountName $OUName `
    -GroupCategory Security `
    -GroupScope Global `
    -DisplayName $OUName `
    -Path "OU=$OUName,OU=Domain Groups,DC=N9CLOUD,DC=com" `
    -Description "Members of this group have access to RDWEB"

<#
# Create Test User
Write-Host ========================
Write-Host -ForegroundColor Green "$NewUser is being created"
Write-Host ========================
Write-Host
$SetPSWD = Read-Host 'Enter Password for Test Account must be 8 Characters complexity' | ConvertTo-SecureString -AsPlainText -Force
New-Aduser `
    -Name "TestUser" `
    -GivenName Test `
    -Surname User `
    -Path "OU=$OUName,OU=Domain Users,DC=N9CLOUD,DC=com" `
    -AccountPassword $SetPSWD `
    -ChangePasswordAtLogon $False `
    -Enabled $True 

#Add Test User to Group
Write-Host ========================
Write-Host -ForegroundColor Green "$NewUser is being added to $NewOU"
Write-Host ========================
Write-Host
$NewUser = Get-ADUser -Identity "CN=TestUser,OU=$OUName,OU=Domain Users,DC=N9CLOUD,DC=com"
$NewOU   = Get-ADGroup -Identity "CN=$OUName,OU=$OUName,OU=Domain Groups,DC=N9CLOUD,DC=com"
Add-ADGroupMember `
    -Identity $NewOU `
    -Members $NewUser 

#>