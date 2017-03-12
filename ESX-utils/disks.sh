esxcfg-advcfg -s 0 /LSOM/lsomSlowDeviceUnmount
esxcfg-advcfg -s 180 /VSAN/ClomRepairDelay
esxcfg-advcfg -s 1 /VSAN/SwapThickProvisionDisabled
esxcfg-advcfg -s 1 /VSAN/FakeSCSIReservations
esxcfg-advcfg -s 110000 /LSOM/diskIoTimeout
esxcfg-advcfg -s 5 /LSOM/diskIoRetryFactor
