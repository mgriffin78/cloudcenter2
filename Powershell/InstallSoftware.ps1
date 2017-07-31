wget "http://10.16.128.104/apps/Cylance/InstallCylancePROTECT.bat" -outfile "InstallCylancePROTECT.bat"
wget "http://10.16.128.104/apps/Cylance/CylanceProtect_x64.msi" -outfile "CylanceProtect_x64.msi"

& .\InstallCylancePROTECT.bat

wget "http://10.16.128.104/apps/Splunk/splunkforwarder-6.5.2-67571ef4b87d-x64-release.msi" -outfile "splunkforwarder-6.5.2-67571ef4b87d-x64-release.msi"
wget "http://10.16.128.104/apps/Splunk/install_x64.bat" -outfile "install_x64.bat"

 & .\install_x64.bat
 
Remove-Item –path CylanceProtect_x64.msi
Remove-Item –path InstallCylancePROTECT.bat
Remove-Item –path splunkforwarder-6.5.2-67571ef4b87d-x64-release.msi
Remove-Item –path install_x64.bat