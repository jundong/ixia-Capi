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
    port1 CreateRouter -RouterName bgproute1 -RouterType BgpV6Router -routerid 192.1.0.1 -FlagPing enable 
    port2 CreateRouter -RouterName bgproute2 -RouterType BgpV6Router -routerid 192.1.0.2 -FlagPing enable

    #step4������·��
    bgproute1 BgpV6SetSession -TesterIp 2000::1 -TesterAs 1001 -SutIp 2000::111 -SutAs 1001 -GateWay 2000::111
    bgproute2 BgpV6SetSession -TesterIp 2000::111 -TesterAs 1001 -SutIp 2000::1 -SutAs 1001 -GateWay 2000::1
    
    bgproute1 BgpV6CreateRouteBlock -BlockName block1 -AddressFamily ipv6 -FirstRoute 3000::1 -PrefixLen 64 -RouteNum 2 \
              -NEXTHOP 2000::1 -AS_PATH {1 2}
    
    #step5��ʹ��BGP����Active                                                                                       
    bgproute1 BgpV6Enable
    bgproute2 BgpV6Enable

    #step6������·��
    port1 StartRouter
    port2 StartRouter
    after 30000
    
    #step7������·�������볷��
    set repeatNum 2
    for {set i 0} {$i < $repeatNum} {incr i} {
        bgproute1 BgpV6AdvertiseRouteBlock -BlockName block1
        bgproute1 BgpV6WithdrawRouteBlock -BlockName block1
        bgproute1 BgpV6AdvertiseRouteBlock -BlockName block1
    }
    bgproute1 BgpV6WithdrawRouteBlock -BlockName block1
    bgproute1 BgpV6DeleteRouteBlock -BlockName block1
    
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
