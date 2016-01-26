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
    port1 CreateRouter -RouterName ISISv4Router1 -routertype ISISRouter -routerId 192.168.0.1 -FlagPing enable
    port2 CreateRouter -RouterName ISISv4Router2 -routertype ISISRouter -routerId 192.168.0.2 -FlagPing enable
    ISISv4Router1 IsisSetSession -addressfamily ipv4 -ipv4addr 192.168.0.10 -ipv4prefixlen 24 \
                               -gatewayaddr 192.168.0.100 -routinglevel L2 -systemid 77:00:00:00:00:22 -areaid 470001 -macaddr 00:00:00:00:00:22   
    ISISv4Router1 IsisCreateRouteBlock -blockname block1 -routepooltype ipv4 -routinglevel L2 -firstaddress \
                                       192.168.100.1 -prefixlen 128 -numaddress 10  -systemid 77:00:00:00:00:22
    
    ISISv4Router2 IsisSetSession -addressfamily ipv4 -ipv4addr 192.168.0.100 -ipv6prefixlen 24 \
                               -gatewayaddr 192.168.0.10 -routinglevel L2 -systemid 88:00:00:00:00:33 -areaid 470001 -macaddr 00:00:00:00:00:33 
    
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 10 -TrafficLoadUnit fps  
    traffic1 CreateStream -StreamName stream1 -FrameLen 64 -srcPoolName ISISv4Router2 -dstPoolName block1 -streamType isis -ProfileName profile1      
    #����Ӧ��profile
    traffic1 ApplyProfileToPort profile1 profile
    
    #����Statistics1-Statistics4ͳ�ƶ���
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    
    
    #step5��ʹ��BGP����Active                                                                                       
    ISISv4Router1 IsisEnable
    ISISv4Router2 IsisEnable

    #step6������·��
    port1 StartRouter
    port2 StartRouter
    
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
