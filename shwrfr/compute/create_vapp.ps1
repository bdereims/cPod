$Vc = "172.18.3.30"
$vcUser = "administrator@vsphere.local"
$vcPass = 'VMware1!'
$Datacenter = "cPod-Common"
$Cluster = "Management"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass
