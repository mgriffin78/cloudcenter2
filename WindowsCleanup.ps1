. "c:\temp\userenv.ps1"
$domain =$args[0]
$password=$args[1] | ConvertTo-SecureString -asPlainText -Force
$username = "$domain\admin"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
add-windowsfeature AD-Domain-Services
remove-Computer  -UnjoinDomaincredential $credential
remove-ADComputer -identity $env:cliqrNodeHostname -Credential $credential -confirm:$false
Restart-Computer

