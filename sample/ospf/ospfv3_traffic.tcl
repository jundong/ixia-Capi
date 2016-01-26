####################�������������û�������Ҫ�������޸�#################
#�����ַ
set chassisAddr 172.16.174.137
#��λ��
set islot {1 2}
set portList {1 1} ;#�˿ڵ�ֵ��port1
###############################��ʼ������##############################

if { [catch {    
    #cd ../Source
    lappend auto_path "C:/Ixia/Workspace/ixia-Capi"
    #����HLAPI Lib
    #source ./pkgIndex.tcl
    package require IxiaCAPI

    SetLogOption -Debug Enable
    
    # step1����ʼ���ӻ���
    TestDevice chassis1 $chassisAddr
    chassis1 Connect  -IpAddr $chassisAddr

    #step2����ʼԤ�������˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation [lindex $islot $i]/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
      
    port1 ConfigPort -MediaType fiber
    port2 ConfigPort -MediaType fiber

    #step3������·�ɶ���         
    port1 CreateRouter -RouterName ospfv3Router1  -RouterType ospfv3Router  -routerid 192.1.0.1 -FlagPing enable
    port2 CreateRouter -RouterName ospfv3Router2  -RouterType ospfv3Router  -routerid 192.1.0.2 -FlagPing enable

    #step4������·��
    ospfv3Router1 Ospfv3SetSession -ipaddr 2000::3 -SutIpAddress 2000::11 -abr true -networktype p2p    
    ospfv3Router1 Ospfv3CreateTopRouter -RouterId 1.0.0.1 -RouterTypeValue EBIT -RouterLsaName RouterLsa11 -RouterName ospfv3Rtr1
    ospfv3Router1 Ospfv3CreateTopRouterLink -RouterName ospfv3Rtr1 -LinkName link1 -LinkType p2p -LinkInterfaceId 11 \
                                    -LinkInterfaceAddress 2000::100 -LinkMetric 1 -NeighborInterfaceId 12\
                                    -NeighborRouterId  1.0.0.2
    ospfv3Router1 Ospfv3CreateTopExternalPrefixRouteBlock -blockname block1 -StartingAddress  2000::1 -prefix 64 -number 10 \
                                    -AdvertisingRouterId 1.0.0.1 -metric 2 -metrictype True

    ospfv3Router2 Ospfv3SetSession -ipaddr 2000::11 -SutIpAddress 2000::3 -abr true -networktype p2p
    
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 10 -TrafficLoadUnit fps  
    traffic1 CreateStream -StreamName stream1 -FrameLen 64 -srcPoolName ospfv3Router2 -dstPoolName block1 -streamType ospf -ProfileName profile1      
    #����Ӧ��profile
    traffic1 ApplyProfileToPort profile1 profile
    
    #����Statistics1-Statistics4ͳ�ƶ���
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    
    #step5��ʹ��BGP����Active                                                                                       
    ospfv3Router1 Ospfv3Enable
    ospfv3Router2 Ospfv3Enable

    #step6������·��
    port1 StartRouter
    port2 StartRouter

    #step7���ȴ�5��
    after 10000

    #���IxNetwork�˿ڼ��� 
    Statistics1 CleanPortStats  
    Statistics2 CleanPortStats
    
    #��������ͬʱʹ��ARPѧϰ
    port1 StartTraffic -FlagArp true

    #��������10���ֹͣ��������
    after 10000
    port1 StopTraffic
     
    #ͣ��5�����˿�ͳ��   
    after 5000
    
    #��ȡ�˿�ͳ�Ƽ���
    Statistics1 GetPortStats -RxSignature RxSignature4
    Statistics2 GetPortStats -TxSignature TxSignature3
    
    #step8��ֹͣ·��
    port1 StopRouter
    port2 StopRouter
    
    #step9��������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                                   
}  err ] } {
    #���ؽ��"�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 

    #������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                     
}
