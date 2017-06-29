#Set connection Variables
$Vc = "10.1.0.100"
$vcUser = "administrator@vsphere.local"
$vcPass = '###PASSWD###'
$Datacenter = "Showroom"
$Cluster = "Dell"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass

Get-VDPortgroup "vxw-dvs-109-virtualwire-25-sid-5009-cpod-brice" | Get-VDSecurityPolicy | Set-VDSecurityPolicy -ForgedTransmits $true -AllowPromiscuous $true
