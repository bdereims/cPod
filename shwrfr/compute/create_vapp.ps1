#Mdofity Portgroup
#bdereims@vmware.com

$Vc = "###VCENTER###"
$vcUser = "###VCENTER_ADMIN###"
$vcPass = '###VCENTER_PASSWD###'
$Datacenter = "###VCENTER_DATACENTER###"
$Cluster = "###VCENTER_CLUSTER###"
$Portgroup = "###PORTGTOUP###"
$oldNet = "50-EDGE"
$cPodName = "###CPOD_NAME###"
$templateVM = "###TEMPLATE_VM###"
$IP = "###IP###"
$rootPasswd = "###ROOT_PASSWD###"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass

$Vapp = New-VApp -Name cPod-$cPodName -Location ( Get-Cluster -Name $Cluster ) 
$CpodRouter = New-VM -Name cPodRouter-$cPodName -VM $templateVM -ResourcePool $Vapp
Get-VM $CpodRouter | Get-NetworkAdapter | Where {$_.NetworkName -eq $oldNet } | Set-NetworkAdapter -NetworkName $Portgroup -Confirm:$false
Start-VM -VM cPodRouter-$cPodName -Confirm:$false 
invoke-vmscript -VM $CpodRouter -ScriptText "cd update ; ./update.sh $cPodName $IP ; reboot" -GuestUser root -GuestPassword $rootPasswd -scripttype Bash
