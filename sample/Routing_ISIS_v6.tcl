######################################################################
# �ű�����:����ISISЭ����湦��
#
# ����˵��:
#     Ixia��1���˿ڷ�������ISIS·���������ISIS��ַ��·�ɣ����ISIS����·������
#     ����·��ͨ�棻����·�ɳأ�����·���𵴲��ֵĲ��ԣ����ISIS�������ˣ�
#     ����·��ͨ�棻���ISIS Network������·��ͨ��
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
        after 1000
        set input [gets stdin]
    }
}

####################�������������û�������Ҫ�������޸�#################
    #�����ַ
    set chassisAddr 172.16.174.137
    #��λ��
    set islot 1
    #�˿�����
    set portList {1} ;#�˿ڵ�ֵ��port1
###############################��ʼ������##############################

if { [catch {    
    #cd ../Source
    lappend auto_path "C:/Ixia/Workspace/ixia-Capi"
    #����HLAPI Lib
    #source ./pkgIndex.tcl
    package require IxiaCAPI

    SetLogOption -Debug Enable
    
    #step1����ʼ���ӻ���
    TestDevice chassis1 $chassisAddr
    chassis1 Connect  -IpAddr $chassisAddr

    #step2����ʼԤ��1���˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }

    #step3������IsisRouter
    port1 CreateRouter -RouterName IsisRouter1 -RouterType IsisRouter -routerid 10.10.10.10
    IsisRouter1 IsisSetSession \
        -AddressFamily BOTH \
        -macaddr "00:10:94:00:00:02" \
        -Ipv4Addr 1.1.0.3 \
        -gatewayaddr 1.1.0.1 \
        -Ipv6Addr 2000::1 \
        -AreaId 000001 \
        -SystemId 01:01:01:01:01:01 \
        -RoutingLevel L2
    
    #step4������IsisRouter
    port1 CreateRouter -RouterName IsisRouter2 -RouterType IsisRouter -routerid 11.10.10.10
    IsisRouter2 IsisSetSession \
        -AddressFamily BOTH \
        -macaddr "00:10:94:00:00:03" \
        -Ipv4Addr 2.1.0.3 \
        -gatewayaddr 2.1.0.1 \
        -Ipv6Addr 2000::2 \
        -AreaId 000002 \
        -SystemId 01:01:01:01:01:02 \
        -RoutingLevel L2
    IsisRouter1 IsisDisable
    IsisRouter1 IsisEnable  
 SaveConfigAsXML "C:/isis.xml"     
    puts "Isis Router configuration:[IsisRouter1 IsisRetrieveRouter]"
    puts "Isis Router status:[IsisRouter1 IsisRetrieveRouterStatus]"
    puts "Isis Router statistic:[IsisRouter1 IsisRetrieveRouterStats]"
   
   
    #step5������RouteBlock
    IsisRouter1 IsisCreateRouteBlock -BlockName IsisBlock1 -SystemId 01:01:01:01:01:01 -FlagFlap TRUE -Number 20 
    IsisRouter1 IsisSetRouteBlock -BlockName IsisBlock1 -FirstAddress 100.0.0.0
    IsisRouter1 IsisRetrieveRouteBlock -BlockName IsisBlock1    
    IsisRouter1 IsisListRouteBlock -blocknamelist blocklist
    puts "existing RouteBlock: $blocklist"    
    
    #step6������Topology router   
    IsisRouter1 IsisCreateTopRouter -RouterName rtr1 -systemid 00:00:00:00:00:11      
    IsisRouter1 IsisCreateTopRouter -RouterName rtr2 -systemid 00:00:00:00:00:22
    IsisRouter1 IsisSetTopRouter -RouterName rtr2 -systemid 00:00:00:00:00:33     
    IsisRouter1 IsisCreateTopRouterLink -RouterName rtr1 -connectedname rtr2 -LinkName link1 -NbrRouterName rtr2 -NarrowMetric 1 -WideMetric 1 

    
    puts "Starting router..."
    puts "Wait 10 seconds..."
    port1 StartRouter
    
    after 10000

    puts "Isis Router status:[IsisRouter1 IsisRetrieveRouterStatus]"
    puts "Isis Router statistic:[IsisRouter1 IsisRetrieveRouterStats]"
 
    #step7����ʼ·��ͨ�泷������
    IsisRouter1 IsisAdvertiseRouteBlock 
    after 10000

    puts "Isis Router status:[IsisRouter1 IsisRetrieveRouterStatus]"   
    puts "Isis Router statistic:[IsisRouter1 IsisRetrieveRouterStats]"

   #��ͣ���Ա��ܹ���GUI�ϲ쿴ISIS·�ɵ�״̬
#    WaitKeyboardInput 
    
    IsisRouter1 IsisWithdrawRouteBlock -BlockName IsisBlock1
    after 10000

   #��ͣ���Ա��ܹ���GUI�ϲ쿴ISIS·�ɵ�״̬
#    WaitKeyboardInput 

    #step8����ʼ·���𵴲��ֵĲ���
    IsisRouter1 IsisSetFlapRouteBlock -AWDTimer 10 -WADTimer 10
    IsisRouter1 IsisStartFlapRouteBlock

    after 10000

   #��ͣ���Ա��ܹ���GUI�ϲ쿴ISIS·�ɵ�״̬
#    WaitKeyboardInput 
   
    IsisRouter1 IsisStopFlapRouteBlock

    after 10000

    IsisRouter1 IsisDeleteTopRouterLink -RouterName rtr1 -LinkName link1 -NbrRouterName rtr2
    IsisRouter1 IsisDeleteTopRouter -RouterName rtr2     
    IsisRouter1 IsisDeleteTopRouter -RouterName rtr1
    IsisRouter1 IsisDeleteRouteBlock -BlockName IsisBlock1
    IsisRouter1 IsisListRouteBlock -blocknamelist blocklist
    puts "existing RouteBlock: $blocklist" 
    
    puts "Add Grid"
    IsisRouter1 IsisCreateTopGrid -GridName IsisGrid1 -GridRows 2 -GridCols 2 -StartingSystemId 20:00:00:00:00:01
    IsisRouter1 IsisSetTopGrid -GridName IsisGrid1 -StartingRouterId 192.0.0.1

    #step9����ʼ·��ͨ��
    IsisRouter1 IsisAdvertiseRouteBlock 
    after 10000
    puts "Isis Router statistic:[IsisRouter1 IsisRetrieveRouterStats]"

   #��ͣ���Ա��ܹ���GUI�ϲ쿴ISIS·�ɵ�״̬
#    WaitKeyboardInput

    
    IsisRouter1 IsisDeleteTopGrid -GridName IsisGrid1  


    #step10������ISIS Network
    IsisRouter1 IsisCreateTopNetwork -NetworkName Network1 \
        -ConnectedRouterIDList {rtr1 rtr2} \
        -ConnectedSysID 01:01:01:01:01:01
    IsisRouter1 IsisSetTopNetwork -NetworkName Network1 \
        -ConnectedRouterIDList {rtr1 rtr2} \
        -ConnectedSysID 01:01:01:01:01:01
        
    #step11����ʼ·��ͨ��
    IsisRouter1 IsisAdvertiseRouteBlock 
    after 10000
    puts "Isis Router statistic:[IsisRouter1 IsisRetrieveRouterStats]"

   #��ͣ���Ա��ܹ���GUI�ϲ쿴ISIS·�ɵ�״̬
#    WaitKeyboardInput         
  
    IsisRouter1 IsisDeleteTopNetwork -NetworkName Network1
    
    #step12��������ò��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest      


}  err ] } {
    #���ؽ��"�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 
    #������ò��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                  
}