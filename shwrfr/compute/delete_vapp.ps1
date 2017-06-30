#Delete vApp
#bdereims@vmware.com

$Vc = "###VCENTER###"
$vcUser = "###VCENTER_ADMIN###"
$vcPass = '###VCENTER_PASSWD###'
$Datacenter = "###VCENTER_DATACENTER###"
$Cluster = "###VCENTER_CLUSTER###"
$cPodName = "###CPOD_NAME###"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass

$VApp = Get-VApp -Name cPod-$cPodName -Location ( Get-Cluster -Name $Cluster ) 
Stop-VApp -VApp $VApp -Confirm:$false 
Remove-VApp -VApp $VApp -Confirm:$false -DeletePermanently:$true
