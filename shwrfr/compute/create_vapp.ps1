#Create vApp
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
$Datastore = "###DATASTORE###"
$numberESX = 6 

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass

#####
Write-Host "Create vApp."
$Vapp = New-VApp -Name cPod-$cPodName -Location ( Get-Cluster -Name $Cluster ) 

Write-Host "Add cPodRouter VM."
$CpodRouter = New-VM -Name cPodRouter-$cPodName -VM $templateVM -ResourcePool $Vapp -Datastore $Datastore

Write-Host "Add Disk for /data in cPodRouter."
$CpodRouter | New-HardDisk -ThinProvisioned -CapacityKB 4096000000 

Write-Host "Modify cPodRouter vNIC."
Get-NetworkAdapter -VM $CpodRouter | Where {$_.NetworkName -eq $oldNet } | Set-NetworkAdapter -NetworkName $Portgroup -Confirm:$false
Start-VM -VM $CpodRouter -Confirm:$false 

Write-Host "Launch Update script in the cPod context."
Invoke-VMScript -VM $CpodRouter -ScriptText "cd update ; ./update.sh $cPodName $IP ; reboot" -GuestUser root -GuestPassword $rootPasswd -scripttype Bash -ToolsWaitSecs 45 -RunAsync

#$ESX = New-VM -Name cPod-$cPodName-esx -VM "template-ESX" -ResourcePool $Vapp -Datastore $Datastore 
#Get-VM $ESX | Get-NetworkAdapter | Where {$_.NetworkName -eq $oldNet } | Set-NetworkAdapter -NetworkName $Portgroup -Confirm:$false
#Start-VM -VM cPod-$cPodName-esx -Confirm:$false -RunAsync

#####
Write-Host "Add ESX VMs."
For ($i=1; $i -le $numberESX; $i++) {
	Write-Host "-> cPod-$cPodName-esx-$i"
	New-VM -Name cPod-$cPodName-esx-$i -VM "template-ESX65U1" -ResourcePool $Vapp -Datastore $Datastore | Get-NetworkAdapter | Where {$_.NetworkName -eq $oldNet } | Set-NetworkAdapter -NetworkName $Portgroup -Confirm:$false
	Start-VM -VM cPod-$cPodName-esx-$i -Confirm:$false -RunAsync 
}

#####
Write-Host "Modify vApp for shutdown."
$VAppView = $Vapp | Get-View
ForEach ($Entity in $VAppView.VAppConfig.EntityConfig) {
	If ($Entity.StopAction -ne "guestShutdown") {
		$VAppConfigSpec = New-Object VMware.Vim.VAppConfigSpec
		$EntityConfig = New-Object VMware.Vim.VAppEntityConfigInfo
		$EntityConfig.Key = (Get-View $Entity.Key).MoRef
		$EntityConfig.StopAction = "guestShutdown"
		$VAppConfigSpec.EntityConfig = $EntityConfig
 
		$VAppView.UpdateVAppConfig($VAppConfigSpec)
	}
}

Disconnect-VIServer -Confirm:$false
