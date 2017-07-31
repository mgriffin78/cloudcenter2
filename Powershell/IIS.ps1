$domain =$args[0]
$password=$args[1] | ConvertTo-SecureString -asPlainText -Force
$NAME=$args[2]

#Install IIS
# Install web server role
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

#Add to AD

$username = "$domain\UCSD-UCS-Admin"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Set-DNSClientServerAddress –interfaceIndex 12 –ServerAddresses (“10.16.128.128”,"10.16.128.130",”10.16.140.128”)
Add-Computer -DomainName $domain -Credential $credential -newname $NAME -restart

