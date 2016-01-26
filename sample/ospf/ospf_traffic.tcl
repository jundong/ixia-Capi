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
    port1 CreateRouter -RouterName ospfv2Router1  -RouterType ospfv2Router  -routerid 192.1.0.1 -FlagPing enable
    port2 CreateRouter -RouterName ospfv2Router2  -RouterType ospfv2Router  -routerid 192.1.0.2 -FlagPing enable

    #step4������·��
    ospfv2Router1 Ospfv2SetSession -ipaddr 192.85.1.3 -SutIpAddress 192.85.1.11 -abr true -networktype p2p    
    ospfv2Router1 Ospfv2CreateSummaryLsa -LsaName summaryLsa1 -advertisingrouter 192.85.1.3 -FirstAddress 1.1.1.1 -prefixlength 24 -NumAddress 2

    ospfv2Router2 Ospfv2SetSession -ipaddr 192.85.1.11 -SutIpAddress 192.85.1.3 -abr true -networktype p2p
    
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 10 -TrafficLoadUnit fps  
    traffic1 CreateStream -StreamName stream1 -FrameLen 64 -srcPoolName ospfv2Router2 -dstPoolName summaryLsa1 -streamType ospf -ProfileName profile1      
    #����Ӧ��profile
    traffic1 ApplyProfileToPort profile1 profile
    
    #����Statistics1-Statistics4ͳ�ƶ���
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    
    #step5��ʹ��BGP����Active                                                                                       
    ospfv2Router1 Ospfv2Enable
    ospfv2Router2 Ospfv2Enable

    #step6������·��
    port1 StartRouter
    port2 StartRouter

    #step7���ȴ�5��
    after 10000

    #���TestCenter�˿ڼ��� 
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
