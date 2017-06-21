#!/bin/sh

ovftool --acceptAllEulas --allowExtraConfig \
-dm=thin -ds=Datastore -n=lab-cPod-vra-iaas --network="VM Network" ./IAAS.ova \
vi://bdereims%40showroom.local@p-vc-paris01.showroom.local/Showroom/host/ClusterDell/d-esx04.showroom.local/
