#Set connection Variables
$Vc = 10.1.0.100"
$vcUser = "administrator@vsphere.local"
$vcPass = 'VMware1!'
$Datacenter = "Showroom"
$Cluster = "Dell"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass

Get-VDPortgroup "MyVDPortgroup" | Get-VDSecurityPolicy | Set-VDSecurityPolicy -ForgedTransmitsInherited $true
