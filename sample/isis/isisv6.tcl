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
    port1 CreateRouter -RouterName ISISv6Router1 -routertype ISISRouter -routerId 192.168.0.1 -FlagPing enable
    port2 CreateRouter -RouterName ISISv6Router2 -routertype ISISRouter -routerId 192.168.0.2 -FlagPing enable
    ISISv6Router1 IsisSetSession -addressfamily ipv6 -ipv6addr 2000::3 -ipv6prefixlen 64 \
                               -ipv6gatewayaddr 2000::30 -TestLinkLocalAddr FE80::22 \
                               -routinglevel L2 -systemid 77:00:00:00:00:22 -areaid 470001 -macaddr 00:00:00:00:00:22   
    ISISv6Router1 IsisCreateRouteBlock -blockname block3 -routepooltype ipv6 -routinglevel L2 -firstaddress \
                                       3000::10 -prefixlen 128 -numaddress 10  -systemid 77:00:00:00:00:22
    
    ISISv6Router2 IsisSetSession -addressfamily ipv6 -ipv6addr 2000::30 -ipv6prefixlen 64 \
                               -ipv6gatewayaddr 2000::3 -TestLinkLocalAddr FE80::33 \
                               -routinglevel L2 -systemid 88:00:00:00:00:33 -areaid 470001 -macaddr 00:00:00:00:00:33 
    
    #step5��ʹ��BGP����Active                                                                                       
    ISISv6Router1 IsisEnable
    ISISv6Router2 IsisEnable

    #step6������·��
    port1 StartRouter
    port2 StartRouter
    after 30000
    
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
