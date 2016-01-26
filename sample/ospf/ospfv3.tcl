####################�������������û�������Ҫ�������޸�#################
#�����ַ
set chassisAddr 172.16.174.137
#��λ��
set islot {1}
set portList {1} ;#�˿ڵ�ֵ��port1
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
    #port1 DeleteAllStream
    port1 ConfigPort -MediaType fiber

    #step3������·�ɶ���         
    port1 CreateRouter -RouterName ospfv3Router1  -RouterType ospfv3Router  -routerid 192.1.0.1 -FlagPing enable

    #step4������·��
    ospfv3Router1 Ospfv3SetSession -ipaddr 2000::3 -SutIpAddress 2000::11 -abr true -networktype broadcast    
    ospfv3Router1 Ospfv3CreateTopRouter -RouterId 1.0.0.1 -RouterTypeValue EBIT -RouterLsaName RouterLsa11 -RouterName ospfv3Rtr1
    ospfv3Router1 Ospfv3CreateTopRouterLink -RouterName ospfv3Rtr1 -LinkName link1 -LinkType p2p -LinkInterfaceId 11 \
                                    -LinkInterfaceAddress 2000::100 -LinkMetric 1 -NeighborInterfaceId 12\
                                    -NeighborRouterId  1.0.0.2
    ospfv3Router1 Ospfv3CreateTopExternalPrefixRouteBlock -blockname block1 -StartingAddress  2000::1 -prefix 64 -number 10 \
                                                -AdvertisingRouterId 1.0.0.1 -metric 2 -metrictype True 

    #step5��ʹ��OSPFV3
    ospfv3Router1 Ospfv3Enable

    #step6������·��
    port1 StartRouter

    #step7���ȴ�5��
    after 5000

    #step8��ֹͣ·��
    port1 StopRouter
    
    #step9��������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                                   
}  err ] } {
    #���ؽ��"�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 

    #������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                     
}
