. "c:\temp\userenv.ps1"
$domain =$args[0]
$password=$args[1] | ConvertTo-SecureString -asPlainText -Force

$username = "$domain\admin"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)

#install cylance and splunk
wget "http://<REPO IP>/apps/Cylance/InstallCylancePROTECT.bat" -outfile "InstallCylancePROTECT.bat"
wget "http://<REPO IP>/apps/Cylance/CylanceProtect_x64.msi" -outfile "CylanceProtect_x64.msi"

& .\InstallCylancePROTECT.bat

wget "http://<REPO IP>/apps/Splunk/splunkforwarder.msi" -outfile "splunkforwarder.msi"
msiexec.exe /i "splunkforwarder.msi" DEPLOYMENT_SERVER="10.16.187.91:8089" SERVICESTARTTYPE=auto AGREETOLICENSE=yes LAUNCHSPLUNK=1 /quiet

Remove-Item –path CylanceProtect_x64.msi
Remove-Item –path InstallCylancePROTECT.bat
Remove-Item –path splunkforwarder.msi

function Disable-IEESC
{
    $AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
    Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
    $UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
    Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
    Stop-Process -Name Explorer
    Write-Host “IE Enhanced Security Configuration (ESC) has been disabled.” -ForegroundColor Green
}
Disable-IEESC


##Disable Sharing Wizard
function Disable-ShareWiz
{
    $ShareKey = “HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\”
    Set-ItemProperty -Path $ShareKey -Name “SharingWizardOn” -Value 0
    Write-Host “Share Wizard is disabled.” -ForegroundColor Green
}
Disable-ShareWiz

Set-ExecutionPolicy –ExecutionPolicy Bypass -Force
Add-WindowsFeature SNMP-Service
Add-WindowsFeature SNMP-WMI-Provider

##Figure out what the interface name is for the system
$myvar = get-wmiobject win32_networkadapter -filter "netconnectionstatus = 2" | select netconnectionid, name, InterfaceIndex, netconnectionstatus | select netconnectionid |  select-string "^(?!Name$)"
echo $myvar 
if ($myvar -match "@{netconnectionid=Ethernet}") {
$WININT = "Ethernet"
echo $WININT
}
elseif ($myvar -match "@{netconnectionid=Ethernet 2}") { 
$WININT = "Ethernet 2"
Echo $WININT
}
elseif ($myvar -match "@{netconnectionid=Local Area Connection}") { 
$WININT = "Local Area Connection"
Echo $WININT
}

if ($env:imageName -eq "Windows Server 2012" -or "Windows2012withSQL2014") { 
##Disable Windows FW
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
##Set Interface Options 2012
Disable-NetAdapterBinding -Name $WININT -ComponentID ms_rspndr
Disable-NetAdapterBinding -Name $WININT -ComponentID ms_lltdio
Disable-NetAdapterBinding -Name $WININT -ComponentID ms_pacer
Disable-NetAdapterBinding -Name $WININT -ComponentID ms_tcpip6
}
else {
Echo "Not a 2012 System" 
}

#add DNS Server
netsh interface ip add dnsserver $WININT <DNS IP>
netsh interface ip add dnsserver $WININT <DNS IP>
netsh interface ip add dnsserver $WININT <DNS IP>

#Add host into the AD Domain. Please note there are differences in each cloud. GCP for example does not change the hostname in the VM. AWS does this however. 

$DepEnv = $env:CliqrDepEnvName.split('-')


if (($DepEnv[0] -Match "SAP") -and ($env:Cloud_Setting_cloud -eq "CLOUD_CLUS")) {
add-windowsfeature AD-Domain-Services
Get-AdComputer $env:cliqrNodeHostname -Credential $credential | Move-ADObject -TargetPath 'OU=SAP,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com'
Restart-Computer
}
elseif (($DepEnv[1] -Match "Prod") -and ($env:Cloud_Setting_cloud -eq "CLOUD_CLUS")) {
add-windowsfeature AD-Domain-Services
Get-AdComputer $env:cliqrNodeHostname -Credential $credential | Move-ADObject -TargetPath 'OU=Production,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com'
Restart-Computer
}
elseif (($DepEnv[1] -Match "Dev" -Or "Test") -and ($env:Cloud_Setting_cloud -eq "CLOUD_CLUS")) {
add-windowsfeature AD-Domain-Services
Get-AdComputer $env:cliqrNodeHostname -Credential $credential | Move-ADObject -TargetPath 'OU=Dev-Test,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com'
Restart-Computer
}
elseif (($DepEnv[0] -Match "SAP") -and ($env:Cloud_Setting_cloud -eq "GCP-us-central1")){
Add-Computer -DomainName $domain -Credential $credential -newname $env:cliqrNodeHostname -OUpath "OU=SAP,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com" -restart
}
elseif (($DepEnv[1] -Match "Prod") -and ($env:Cloud_Setting_cloud -eq "GCP-us-central1")){
Add-Computer -DomainName $domain -Credential $credential -newname $env:cliqrNodeHostname -OUpath "OU=Production,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com" -restart
}
elseif (($DepEnv[1] -Match "Dev" -Or "Test") -and ($env:Cloud_Setting_cloud -eq "GCP-us-central1")){
Add-Computer -DomainName $domain -Credential $credential -newname $env:cliqrNodeHostname -OUpath "OU=Dev-Test,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com" -restart
}
elseif (($DepEnv[0] -Match "SAP") -and ($env:Cloud_Setting_cloud -eq "AWS-us-west-2")){
Add-Computer -DomainName $domain -Credential $credential -OUpath "OU=SAP,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com" -restart
}
elseif (($DepEnv[1] -Match "Prod") -and ($env:Cloud_Setting_cloud -eq "AWS-us-west-2")){
Add-Computer -DomainName $domain -Credential $credential -OUpath "OU=Production,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com" -restart
}
elseif (($DepEnv[1] -Match "Dev" -Or "Test") -and ($env:Cloud_Setting_cloud -eq "AWS-us-west-2")){
Add-Computer -DomainName $domain -Credential $credential -OUpath "OU=Dev-Test,OU=Servers,OU=Information Technology,DC=corp,DC=localdomain,DC=com" -restart
}

