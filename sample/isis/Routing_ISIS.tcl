######################################################################
# �ű�����:����ISISЭ����湦��
# ����˵��:
#     Ixia��1���˿ڷ�������ISIS·���������ISIS��ַ��·�ɣ����ISIS����·��������
#     �������ӣ�����topo routerͨ�泷�����ԡ�topo linkͨ�泷�����ԡ�·���𵴲���
#     �Ĳ��ԡ�����ISIS Router��GR���ܣ���������
#     
# ����ʱ��: 2015.12.14
#
# �޸�˵����
#                       
######################################################################
proc WaitKeyboardInput {} {
    puts "please press any 'a' to continue..."
    flush stdout
    set input [gets stdin]
    while {$input != "a"} {
        puts "please press any 'a' to continue..."
        after 10000
        set input [gets stdin]
    }
}

####################�������������û�������Ҫ�������޸�#################
set chassisAddr 172.16.174.137
#��λ��
set islot 1
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

    #step2����ʼԤ��1���˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }

    #step3������IsisRouter
    port1 CreateRouter -RouterName IsisRouter1 -RouterType IsisRouter -routerid 10.10.10.10
    port1 CreateRouter -RouterName IsisRouter2 -RouterType IsisRouter -routerid 11.11.11.11
    IsisRouter1 IsisSetSession \
        -AddressFamily IPV4 \
        -Ipv4Addr 1.1.1.1 \
        -gatewayaddr 1.1.1.2 \
        -AreaId 000001 \
        -SystemId 00:00:01:00:00:03 \
        -MacAddr 00:00:01:00:00:02 \
        -RoutingLevel L2 \
        -Ipv4PrefixLen 24 \
        -Ipv6Addr 2000::2 \
        -Ipv6PrefixLen 64 \
        -Ipv6GatewayAddr 2000::11 \
        -AreaId2 000002 \
        -AreaId3 000003 \
        -RouterId 1.2.1.1 \
        -FlagWideMetric true \
        -FlagRestartHelper true \
        -HoldTimer 20 \
        -IihInterval 5 \
        -MetricMode "NARROW_AND_WIDE" \
        -PsnpInterval 17 \
        -TestLinkLocalAddr 2000::4 \
        -MaxPacketSize 1490 \
        -L2RouterPriority 3 \
        -L1RouterPriority 4 \
        -Active true \
        -Metric 7 \
        -LocalMac "00:00:00:11:01:10" \
        -LocalMacModifier "00:00:00:00:00:03"
         
    SaveConfigAsXML "C:/Tmp/isis.xml" 
    
    IsisRouter2 IsisSetSession \
        -AddressFamily IPV4 \
        -Ipv4Addr 1.1.1.2 \
        -gatewayaddr 1.1.1.1 \
        -AreaId 000001 \
        -SystemId 00:00:01:00:00:02 \
        -MacAddr 00:00:01:00:00:02 \
        -RoutingLevel L2

    #step4������RouteBlock
    IsisRouter1 IsisCreateRouteBlock -BlockName IsisBlock1 -SystemId 01:01:01:01:01:01 -FlagFlap TRUE -NumAddress 20 
    IsisRouter1 IsisSetRouteBlock -BlockName IsisBlock1 -FirstAddress 200.0.0.100
    array set routeBlock [IsisRouter1 IsisRetrieveRouteBlock -BlockName IsisBlock1]
    parray routeBlock

    set routerNameList ""
    IsisRouter1 IsisListRouteBlock -BlockNameList routerNameList 
    puts $routerNameList
  
    set activeFlag ""
    IsisRouter1 IsisRetrieveRouteBlock -BlockName IsisBlock1 -Active activeFlag
    puts "The active flag is:$activeFlag"
   
    #step5������Topology router   
    IsisRouter1 IsisCreateTopRouter -RouterName rtr1 -systemid 00:00:00:00:00:11 -RoutingLevel L2      
    IsisRouter1 IsisCreateTopRouter -RouterName rtr2 -systemid 00:00:00:00:00:22 -RoutingLevel L2
    IsisRouter1 IsisCreateTopRouter -RouterName rtr3 -systemid 00:00:00:00:00:33 -RoutingLevel L2
     
    #step6������Topology link        
    IsisRouter1 IsisCreateTopRouterLink -RouterName rtr1 -LinkName link1 \
                -ConnectedName rtr2 -NarrowMetric 2 -WideMetric 5 \
                -NeiIpv4Address "1.1.1.1"
    IsisRouter1 IsisCreateTopRouterLink -RouterName rtr1 -LinkName link2 -ConnectedName rtr3 -NarrowMetric 1 -WideMetric 1
        
    puts "Starting router..."
    puts "Wait 10 seconds..."
    port1 StartRouter
    puts "Wait 10 seconds..."
    after 10000
    
    IsisRouter1 IsisAdvertiseRouteBlock 
    after 10000
    IsisRouter1 IsisWithdrawRouteBlock -BlockName IsisBlock1
    
    puts "Stopping router..."
    port1 StopRouter

    #step11��������ò��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest      
}  err ] } {   
    #��� "�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 
    # ������ò��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                  
}