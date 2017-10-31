$Vc = "###VCENTER###"
$vcUser = "###VCENTER_ADMIN###"
$vcPass = '###VCENTER_PASSWD###'
$Datacenter = "###VCENTER_DATACENTER###"
$Cluster = "###VCENTER_CLUSTER###"
$Domain = "###DOMAIN###"
$vCenterESX = "esx-01."+${DOMAIN}
$numberESX = ###NUMESX### 

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass

$location = Get-Folder -Name Datacenters -NoRecursion
New-DataCenter -Location $location -Name $Datacenter
New-Cluster -Name $Cluster -Location $Datacenter

Write-Host "Add ESX VMs."
For ($i=1; $i -le $numberESX; $i++) {
        Write-Host "-> esx-$i"
	Add-VMHost -Server $Vc -Name esx-0${i}.${DOMAIN} -Location (Get-Cluster -Name $Cluster ) -User root -Password VMware1! -force:$true
	Get-VMHost | Set-VMHostSysLogServer -SysLogServer $VI_SERVER
}

$VCVM = Get-VM -Name "VCSA"
$vmstartpolicy = Get-VMStartPolicy -VM $VCVM
Set-VMHostStartPolicy (Get-VMHost $vCenterESX | Get-VMHostStartPolicy) -Enabled:$true
Set-VMStartPolicy -StartPolicy $vmstartpolicy -StartAction PowerOn -StartDelay 0

$alarmMgr = Get-View AlarmManager
Get-Cluster | Where-Object {$_.ExtensionData.TriggeredAlarmState} | ForEach-Object{
    $cluster = $_
    $entity_moref = $cluster.ExtensionData.MoRef

    $cluster.ExtensionData.TriggeredAlarmState | ForEach-Object{
        $alarm_moref = $_.Alarm.value

        "Ack'ing $alarm_moref ..." | Out-File -Append -LiteralPath $DeployLogFile
        $alarmMgr.AcknowledgeAlarm($alarm_moref,$entity_moref) | Out-File -Append -LiteralPath $DeployLogFile
    }
}

$thisDataStore = Get-datastore Datastore
get-vmhost | foreach {$_ | get-advancedsetting -name "Syslog.global.logDir" | set-advancedsetting -Value "[Datastore] scratch/log" -confirm:$false}

Disconnect-VIServer * -confirm:$false
