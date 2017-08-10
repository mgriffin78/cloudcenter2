$Key = 'HKLM:\System\Setup\Status\SysprepStatus'
Set-ItemProperty -Path $Key -Name 'GeneralizationState' -Value 7
if ((Test-Path -path C:/sysprep) -eq "True") {
$sysprep = 'C:\Windows\System32\Sysprep\Sysprep.exe'
$arg = '/generalize /oobe /reboot'
$sysprep += " $arg"
Invoke-Expression $sysprep
}
else {
echo "Sysprep has happened, nothing to do here"
}


