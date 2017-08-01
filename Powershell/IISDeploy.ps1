. "c:\temp\userenv.ps1"
$domain =$args[0]
$password=$args[1] | ConvertTo-SecureString -asPlainText -Force

$username = "$domain\UCSD-UCS-Admin"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)

##Disable IEESC 
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

##Install SNMP 
Add-WindowsFeature SNMP-Service
Add-WindowsFeature SNMP-WMI-Provider

#Install IIS
Import-Module ServerManager
Add-WindowsFeature Web-Server
Install-WindowsFeature Web-Server
Install-WindowsFeature Web-App-Dev
Install-WindowsFeature Web-Asp-Net
Install-WindowsFeature Web-Asp-Net45
Install-WindowsFeature NET-Framework-45-ASPNET

& 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe' /iru

# Grant permission to the folder c:\temp
# New-Item -type directory -path C:\temp

$Acl = Get-Acl "C:\temp"
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("IIS_IUSRS","FullControl","ContainerInherit, ObjectInherit", "None","Allow")

$Acl.SetAccessRule($Ar)
Set-Acl "C:\temp" $Acl

#rm -Force c:\temp\*

#Add server to AD in proper Container
$DepEnv = $env:CliqrDepEnvName.split('-')

if ($env:Cloud_Setting_cloud -Match "CLOUD_CLUS-IRVINE") {
echo "nothing to do, the sysprep will take care of this for us"
}
elseif ($DepEnv[0] -Match "SAP"){
Set-DNSClientServerAddress –interfaceIndex 12 –ServerAddresses (“10.16.128.128”,"10.16.128.130",”10.16.140.128”)
Add-Computer -DomainName $domain -Credential $credential -newname $env:cliqrNodeHostname -OUpath "OU=SAP,OU=Servers,OU=Information Technology,DC=corp,DC=irvineco,DC=com" -restart
echo "SAP"
}
elseif ($DepEnv[1] -Match "Prod"){
Set-DNSClientServerAddress –interfaceIndex 12 –ServerAddresses (“10.16.128.128”,"10.16.128.130",”10.16.140.128”)
Add-Computer -DomainName $domain -Credential $credential -newname $env:cliqrNodeHostname -OUpath "OU=Production,OU=Servers,OU=Information Technology,DC=corp,DC=irvineco,DC=com" -restart
echo "prod"
}
elseif ($DepEnv[1] -Match "Dev" -Or "Test"){
Set-DNSClientServerAddress –interfaceIndex 12 –ServerAddresses (“10.16.128.128”,"10.16.128.130",”10.16.140.128”)
Add-Computer -DomainName $domain -Credential $credential -newname $env:cliqrNodeHostname -OUpath "OU=Dev-Test,OU=Servers,OU=Information Technology,DC=corp,DC=irvineco,DC=com" -restart
echo "Test or Dev"
}



