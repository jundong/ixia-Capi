######################################################################
# 测试目的：测试BGP协议仿真功能
#
# 功能说明:
#     STC的2个端口各仿真一个BGP路由器，添加路由池，进行路由宣告、撤销和震荡测试，
#     创建Mpls VPN，配置带VPN路由等
#     
# 创建时间: 2010.3.17
#
# 责任人：yuanfen
#
# 修改说明：
#                                      
#######################################################################

####################变量配置区，用户根据需要可自行修改#################
#机框地址
set chassisAddr 10.61.34.249
#zqset islot 12
#zqset portList {3 4} ;#端口的排列顺序是port1, port2
#槽位号
set islot 11
#端口链表
set portList {1 2} ;#端口的排列顺序是port1, port2
###############################初始化配置##############################

if { [catch {
     #加载STC API Lib    
     cd ../Source
    #加载HLAPI Lib
    source ./pkgIndex.tcl

   SetLogOption -Debug Enable

    #step1：开始连接机器
    TestDevice chassis1 $chassisAddr

    #step2：开始预留两个端口
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
    
    # 创建vlan子接口
    port1 CreateSubInt -SubIntName vlan1
    port2 CreateSubInt -SubIntName vlan2

    # 配置vlan子接口
    vlan1 ConfigVlanIf -VlanTag 300
    vlan2 ConfigVlanIf -VlanTag 300
    
    #step3：创建路由对象         
    vlan1 CreateRouter -RouterName bgproute1 -RouterType BgpV4Router -routerid 192.1.0.1
    vlan2 CreateRouter -RouterName bgproute2 -RouterType BgpV4Router -routerid 192.1.0.2
    
    #step4：配置路由
    bgproute1 BgpV4SetSession -PeerType IBGP -TesterIp 192.85.1.3 -PrefixLen 24 -TesterAs 1001 -SutIp 192.85.1.11 -SutAs 1001 -FlagMd5 true  \
             -Md5 0xA9 -HoldTimer 30 -KeepaliveTimer 10 -ConnectRetryTimer 20 -ConnectRetryCount 10 -GateWay 192.85.1.1 -RoutesPerUpdate 100 -InterUpdateDelay 10 -Active true  \
             -StartingLabel 16 -LocalMac "00:00:00:11:01:2" -LocalMacModifier "00:00:00:00:00:02"
     
    SaveConfigAsXML "C:/bgp.xml" 
     
    #step5：获取路由信息         
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
    
    #step6：进行路由宣告与撤销
    bgproute1 BgpV4AdvertiseRouteBlock -BlockName block1
    bgproute1 BgpV4WithdrawRouteBlock -BlockName block1
    bgproute1 BgpV4AdvertiseRouteBlock -BlockName block1
    bgproute1 BgpV4WithdrawRouteBlock -BlockName block1

    #step7：设置Flap    
    bgproute1 BgpV4SetFlapRouteBlock -AWDTimer 3 -WADTimer 3
    bgproute1 BgpV4StartFlapRouteBlock -BlockName block1
    bgproute1 BgpV4StopFlapRouteBlock -BlockName block1
    
    #step8：获取当前路由状态信息
    bgproute1 BgpV4RetrieveRouteStats -NumKeepAlivesSent NumKeepAlivesSent -NumKeepAlivesReceived NumKeepAlivesReceived
    puts "NumKeepAlivesSent:$NumKeepAlivesSent,NumKeepAlivesReceived:$NumKeepAlivesReceived"
    
    #step11：启动路由
    chassis1 StartRouter

    #step12：等待5秒
    after 5000

    #step13：停止路由
    chassis1 StopRouter
    
    #step14：清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                                   
}  err ] } {
    #返回结果"脚本运行中出现错误: $err"
    puts "脚本运行中出现错误: $err" 

    #清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                     
}
