. "c:\temp\userenv.ps1"
$domain =$args[0]
$password=$args[1] | ConvertTo-SecureString -asPlainText -Force

$username = "$domain\admin"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
if ($env:Cloud_Setting_cloud -Match "CLOUD_CLUS-IRVINE") {
echo "nothing to do, the sysprep will take care of this for us"
}
else {
Set-DNSClientServerAddress –interfaceIndex 12 –ServerAddresses (“10.16.128.128”,"10.16.128.130",”10.16.140.128”)
Add-Computer -DomainName $domain -Credential $credential -newname $env:cliqrNodeHostname -restart
}
