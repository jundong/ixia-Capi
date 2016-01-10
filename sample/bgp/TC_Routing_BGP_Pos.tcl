######################################################################
# ����Ŀ�ģ�����BGPЭ����湦��
#
# ����˵��:
#     STC��2���˿ڸ�����һ��BGP·���������·�ɳأ�����·�����桢�������𵴲��ԣ�
#     ����Mpls VPN�����ô�VPN·�ɵ�
#     
# ����ʱ��: 2010.3.17
#
# �����ˣ�yuanfen
#
# �޸�˵����
#                                      
#######################################################################

####################�������������û�������Ҫ�������޸�#################
#�����ַ
set chassisAddr 10.98.3.12
#��λ��
set islot 2
#�˿�����
set portList {1 2} ;#�˿ڵ�����˳����port1, port2
###############################��ʼ������##############################

if { [catch {
     #����STC API Lib    
     cd ../Source
     set gSTCVersion "3.76"
    #����HLAPI Lib
    source ./pkgIndex.tcl
    
   SetLogOption -Debug Enable

    #step1����ʼ���ӻ���
    TestDevice chassis1 $chassisAddr

    #step2����ʼԤ�������˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType wan
    }
    
    port1 ConfigPort -PayloadType ppp -framingmode "OC192"
    port1 ConfigPPP -Gateway 20.0.0.3
  
    port2 ConfigPort -PayloadType ppp -framingmode "OC192"
    port2 ConfigPPP -Gateway 10.0.0.3   
    
    port1 ConnectPPP
    port2 ConnectPPP
    
    after 5000
    port1 GetPPPState -LCPState lcpstate
    puts $lcpstate
    
    port2 GetPPPState -LCPState lcpstate
    puts $lcpstate
    SaveConfigAsXML "C:/bgp.xml" 
 
    #step3������·�ɶ���         
    port1 CreateRouter -RouterName bgproute1 -RouterType BgpV4Router -routerid 192.1.0.1
    port2 CreateRouter -RouterName bgproute2 -RouterType BgpV4Router -routerid 192.1.0.2
    
    #step4������·��
    bgproute1 BgpV4SetSession -PeerType IBGP -TesterIp 192.85.1.3 -PrefixLen 24 -TesterAs 1001 -SutIp 192.85.1.11 -SutAs 1001 -FlagMd5 true  \
             -Md5 0xA9 -HoldTimer 30 -KeepaliveTimer 10 -ConnectRetryTimer 20 -ConnectRetryCount 10 -GateWay 192.85.1.1 -RoutesPerUpdate 100 -InterUpdateDelay 10 -Active true  \
             -StartingLabel 16 -LocalMac "00:00:00:11:01:2" -LocalMacModifier "00:00:00:00:00:02"
     
    SaveConfigAsXML "C:/bgp.xml" 
     
    #step5����ȡ·����Ϣ         
    bgproute1 BgpV4RetrieveRouter -PeerType PeerType -TesterIp TesterIp -PrefixLen PrefixLen -State State
  
    bgproute1 BgpV4CreateRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.0 -PrefixLen 24 -RouteNum 2 -Modifer 1 -Active enable \
              -AS_SEQUENCE yes -ORIGIN 1 -NEXTHOP 192.85.1.3 -MED 1 -AGGREGATOR_AS 2 -AGGRGATOR_IPADDRESS 192.85.2.1 -ORIGINATOR_ID 192.85.3.1 \
              -CLUSTER_LIST 192.86.1.1 -COMMUNITIES 1:1 -LabelMode FIXED -AS_PATH {2 89}
    bgproute1 BgpV4CreateRouteBlock -BlockName block2 -AddressFamily ipv4 -FirstRoute 193.2.1.0 -PrefixLen 24 -RouteNum 2 -Modifer 1 -Active enable \
              -AS_SEQUENCE yes -ORIGIN 1 -NEXTHOP 192.85.1.3 -MED 1 -AGGREGATOR_AS 2 -AGGRGATOR_IPADDRESS 192.85.2.1 -ORIGINATOR_ID 192.85.3.1 \
              -CLUSTER_LIST 192.86.1.1 -COMMUNITIES 1:1 -LabelMode FIXED
    
    bgproute1 BgpV4DeleteRouteBlock -BlockName block2
    
    bgproute1 BgpV4ListRouteBlock -BlockNameList BlockNameList
    
    puts "BlockNameList:$BlockNameList"
    
    bgproute1 BgpV4SetRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.2 -PrefixLen 24 -RouteNum 2 -RouteStep 1 -Active enable \
              -AS_SEQUENCE yes -ORIGIN 1 -NEXTHOP 192.85.1.3 -MED 1 -AGGREGATOR_AS 2 -AGGRGATOR_IPADDRESS 192.85.2.1 -ORIGINATOR_ID 192.85.3.1 \
              -CLUSTER_LIST 192.86.1.1 -COMMUNITIES 1:1 -LabelMode FIXED -AS_PATH {2 89}
              
    bgproute1 BgpV4RetrieveRouteBlock -BlockName block1 -AddressFamily AddressFamily -AS_PATH AS_PATH
    
    puts "AddressFamily:$AddressFamily"
    #puts "BlockName:$BlockName"
    puts "AS_PATH:$AS_PATH"
    
    #step6������·�������볷��
    bgproute1 BgpV4AdvertiseRouteBlock -BlockName block1
    bgproute1 BgpV4WithdrawRouteBlock -BlockName block1
    bgproute1 BgpV4AdvertiseRouteBlock -BlockName block1
    bgproute1 BgpV4WithdrawRouteBlock -BlockName block1

    #step7������Flap    
    bgproute1 BgpV4SetFlapRouteBlock -AWDTimer 3 -WADTimer 3
    bgproute1 BgpV4StartFlapRouteBlock -BlockName block1
    bgproute1 BgpV4StopFlapRouteBlock -BlockName block1
    
    #step8����ȡ��ǰ·��״̬��Ϣ
    bgproute1 BgpV4RetrieveRouteStats -NumKeepAlivesSent NumKeepAlivesSent -NumKeepAlivesReceived NumKeepAlivesReceived
    puts "NumKeepAlivesSent:$NumKeepAlivesSent,NumKeepAlivesReceived:$NumKeepAlivesReceived"
    
    #step11������·��
    port1 StartRouter

    #step12���ȴ�5��
    after 5000

    #step13��ֹͣ·��
    port1 StopRouter
    
    #step14��������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                                   
}  err ] } {
    #���ؽ��"�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 

    #������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                     
}
