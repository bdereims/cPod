#Set connection Variables
$Vc = "172.18.4.30"
$vcUser = "administrator@vsphere.local"
$vcPass = 'VMware1!'
$Datacenter = "cPod-vR"
$Cluster = "Management"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass

$location = Get-Folder -Name Datacenters -NoRecursion
New-DataCenter -Location $location -Name $Datacenter

New-Cluster -Name $Cluster -Location $Datacenter
Add-VMHost -Server $Vc -Name esx-mgmt-01.cpod-vr.shwrfr.mooo.com -Location (Get-Cluster -Name $Cluster ) -User root -Password VMware1! -force:$true
Get-VMHost | Set-VMHostSysLogServer -SysLogServer $VI_SERVER
Add-VMHost -Server $Vc -Name esx-mgmt-02.cpod-vr.shwrfr.mooo.com -Location (Get-Cluster -Name $Cluster ) -User root -Password VMware1! -force:$true
Get-VMHost | Set-VMHostSysLogServer -SysLogServer $VI_SERVER
Add-VMHost -Server $Vc -Name esx-mgmt-03.cpod-vr.shwrfr.mooo.com -Location (Get-Cluster -Name $Cluster ) -User root -Password VMware1! -force:$true
Get-VMHost | Set-VMHostSysLogServer -SysLogServer $VI_SERVER

$VCVM = Get-VM -Name "VCSA"
$vmstartpolicy = Get-VMStartPolicy -VM $VCVM
Set-VMHostStartPolicy (Get-VMHost esx-mgmt-01.cpod-vr.shwrfr.mooo.com | Get-VMHostStartPolicy) -Enabled:$true
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

$Cluster = "Compute-01"
New-Cluster -Name $Cluster -Location $Datacenter
Add-VMHost -Server $Vc -Name esx-comp-01.cpod-vr.shwrfr.mooo.com -Location (Get-Cluster -Name $Cluster ) -User root -Password VMware1! -force:$true
Get-VMHost | Set-VMHostSysLogServer -SysLogServer $VI_SERVER
Add-VMHost -Server $Vc -Name esx-comp-02.cpod-vr.shwrfr.mooo.com -Location (Get-Cluster -Name $Cluster ) -User root -Password VMware1! -force:$true
Get-VMHost | Set-VMHostSysLogServer -SysLogServer $VI_SERVER
Add-VMHost -Server $Vc -Name esx-comp-03.cpod-vr.shwrfr.mooo.com -Location (Get-Cluster -Name $Cluster ) -User root -Password VMware1! -force:$true
Get-VMHost | Set-VMHostSysLogServer -SysLogServer $VI_SERVER

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

Disconnect-VIServer * -confirm:$false
