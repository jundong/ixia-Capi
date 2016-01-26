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
    port1 CreateRouter -RouterName bgproute1 -RouterType BgpV4Router -routerid 192.1.0.1 -FlagPing enable 
    port2 CreateRouter -RouterName bgproute2 -RouterType BgpV4Router -routerid 192.1.0.2 -FlagPing enable

    #step4������·��
    bgproute1 BgpV4SetSession -TesterIp 192.85.1.3 -TesterAs 1001 -SutIp 192.85.1.11 -SutAs 1001 -GateWay 192.85.1.11
    bgproute2 BgpV4SetSession -TesterIp 192.85.1.11 -TesterAs 1001 -SutIp 192.85.1.3 -SutAs 1001 -GateWay 192.85.1.3
    
    bgproute1 BgpV4CreateRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.0 -PrefixLen 32 -RouteNum 2 \
              -NEXTHOP 192.85.1.3 -AS_PATH {1 2}
    
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 10 -TrafficLoadUnit fps  
    traffic1 CreateStream -StreamName stream3 -FrameLen 64 -srcPoolName bgproute2 -dstPoolName block1 -streamType bgp -ProfileName profile1      
    #����Ӧ��profile
    traffic1 ApplyProfileToPort profile1 profile
    
    #����Statistics1-Statistics4ͳ�ƶ���
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics

    #step5��ʹ��BGP����Active                                                                                       
    bgproute1 BgpV4Enable
    bgproute2 BgpV4Enable

    #step6������·��
    port1 StartRouter
    port2 StartRouter
    after 30000
    
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
    
    #step7������·�������볷��
    set repeatNum 2
    for {set i 0} {$i < $repeatNum} {incr i} {
        bgproute1 BgpV4AdvertiseRouteBlock -BlockName block1
        bgproute1 BgpV4WithdrawRouteBlock -BlockName block1
        bgproute1 BgpV4AdvertiseRouteBlock -BlockName block1
    }
    bgproute1 BgpV4WithdrawRouteBlock -BlockName block1
    bgproute1 BgpV4DeleteRouteBlock -BlockName block1
    
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
