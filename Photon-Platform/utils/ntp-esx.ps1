Set-PowerCLIConfiguration -InvalidCertificateAction ignore
Connect-VIServer 172.16.66.103
Get-VMHost | Add-VMHostNtpServer cpodrouter.cpod.net
Get-VMHost | Get-VmHostService | Where-Object { Get-VMHost | Add-VMHostNtpServer cpodrouter.cpod.net.key -eq "ntpd"} | Start-VMHostService
Get-VMhost | Get-VmHostService | Where-Object {ntp-esx.ps1.key -eq "ntpd"} | Set-VMHostService -policy "automatic"
