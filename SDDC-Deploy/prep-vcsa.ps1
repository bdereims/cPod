#Set connection Variables
$Vc = "172.18.1.30"
$vcUser = "administrator@vsphere.local"
$vcPass = 'VMware1!'
$Datacenter = "cPod-VIC"
$Cluster = "Management"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -DefaultVIServerMode multiple
Connect-VIServer -Server $Vc -User $vcUser -Password $vcPass
$location = Get-Folder -Name Datacenters -NoRecursion
New-DataCenter -Location $location -Name $Datacenter
New-Cluster -Name $Cluster -Location $Datacenter
$myServer = Connect-VIServer -Server 172.18.1.11 -User root -Password $vcPass
Add-VMHost -Server $myServer -Name esx-01 -Location (Get-Cluster $Cluster ) -User root -Password VMware1! -force:$true
