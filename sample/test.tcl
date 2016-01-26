package require IxTclNetwork
ixNet connect localhost -port 8009 -version 7.50
set root [ixNet getRoot]
set port [ixNet getL $root vport]
set port1 ::ixNet::OBJ-/vport:1
set int [ixNet getL $port1 interface]
set ipv6 [ixNet getL $int ipv6]