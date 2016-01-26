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
      
    port1 ConfigPort -MediaType fiber

    #step3������·�ɶ���         
    port1 CreateRouter -RouterName ISISv4Router1 -routertype ISISRouter -routerId 192.168.0.1 -FlagPing enable
    port2 CreateRouter -RouterName ISISv4Router2 -routertype ISISRouter -routerId 192.168.0.2 -FlagPing enable
    ISISv4Router1 IsisSetSession -addressfamily ipv4 -ipv4addr 192.168.0.10 -ipv4prefixlen 24 \
                               -gatewayaddr 192.168.0.100 -routinglevel L2 -systemid 77:00:00:00:00:22 -areaid 470001 -macaddr 00:00:00:00:00:22   
    ISISv4Router1 IsisCreateRouteBlock -blockname block1 -routepooltype ipv4 -routinglevel L2 -firstaddress \
                                       192.168.100.1 -prefixlen 128 -numaddress 10  -systemid 77:00:00:00:00:22
    #step5��ʹ��BGP����Active                                                                                       
    ISISv4Router1 IsisEnable

    #step6������·��
    port1 StartRouter
    after 30000
    
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
