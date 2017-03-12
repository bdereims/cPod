#Value of lsomSlowDeviceUnmount is 1
#Value of ClomRepairDelay is 60
#Value of SwapThickProvisionDisabled is 0
#Value of FakeSCSIReservations is 0
#Value of diskIoTimeout is 100000
#Value of diskIoRetryFactor is 4

esxcfg-advcfg -g /LSOM/lsomSlowDeviceUnmount
esxcfg-advcfg -g /VSAN/ClomRepairDelay
esxcfg-advcfg -g /VSAN/SwapThickProvisionDisabled
esxcfg-advcfg -g /VSAN/FakeSCSIReservations
esxcfg-advcfg -g /LSOM/diskIoTimeout
esxcfg-advcfg -g /LSOM/diskIoRetryFactor

