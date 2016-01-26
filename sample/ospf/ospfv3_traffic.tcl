####################变量配置区，用户根据需要可自行修改#################
#机框地址
set chassisAddr 172.16.174.137
#槽位号
set islot {1 2}
set portList {1 1} ;#端口的值是port1
###############################初始化配置##############################

if { [catch {    
    #cd ../Source
    lappend auto_path "C:/Ixia/Workspace/ixia-Capi"
    #加载HLAPI Lib
    #source ./pkgIndex.tcl
    package require IxiaCAPI

    SetLogOption -Debug Enable
    
    # step1：开始连接机器
    TestDevice chassis1 $chassisAddr
    chassis1 Connect  -IpAddr $chassisAddr

    #step2：开始预留两个端口
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation [lindex $islot $i]/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
      
    port1 ConfigPort -MediaType fiber
    port2 ConfigPort -MediaType fiber

    #step3：创建路由对象         
    port1 CreateRouter -RouterName ospfv3Router1  -RouterType ospfv3Router  -routerid 192.1.0.1 -FlagPing enable
    port2 CreateRouter -RouterName ospfv3Router2  -RouterType ospfv3Router  -routerid 192.1.0.2 -FlagPing enable

    #step4：配置路由
    ospfv3Router1 Ospfv3SetSession -ipaddr 2000::3 -SutIpAddress 2000::11 -abr true -networktype p2p    
    ospfv3Router1 Ospfv3CreateTopRouter -RouterId 1.0.0.1 -RouterTypeValue EBIT -RouterLsaName RouterLsa11 -RouterName ospfv3Rtr1
    ospfv3Router1 Ospfv3CreateTopRouterLink -RouterName ospfv3Rtr1 -LinkName link1 -LinkType p2p -LinkInterfaceId 11 \
                                    -LinkInterfaceAddress 2000::100 -LinkMetric 1 -NeighborInterfaceId 12\
                                    -NeighborRouterId  1.0.0.2
    ospfv3Router1 Ospfv3CreateTopExternalPrefixRouteBlock -blockname block1 -StartingAddress  2000::1 -prefix 64 -number 10 \
                                    -AdvertisingRouterId 1.0.0.1 -metric 2 -metrictype True

    ospfv3Router2 Ospfv3SetSession -ipaddr 2000::11 -SutIpAddress 2000::3 -abr true -networktype p2p
    
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 10 -TrafficLoadUnit fps  
    traffic1 CreateStream -StreamName stream1 -FrameLen 64 -srcPoolName ospfv3Router2 -dstPoolName block1 -streamType ospf -ProfileName profile1      
    #流量应用profile
    traffic1 ApplyProfileToPort profile1 profile
    
    #创建Statistics1-Statistics4统计对象
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    
    #step5：使能BGP进程Active                                                                                       
    ospfv3Router1 Ospfv3Enable
    ospfv3Router2 Ospfv3Enable

    #step6：启动路由
    port1 StartRouter
    port2 StartRouter

    #step7：等待5秒
    after 10000

    #清除IxNetwork端口计数 
    Statistics1 CleanPortStats  
    Statistics2 CleanPortStats
    
    #启动流量同时使能ARP学习
    port1 StartTraffic -FlagArp true

    #持续打流10秒后停止发送流量
    after 10000
    port1 StopTraffic
     
    #停流5秒后检查端口统计   
    after 5000
    
    #获取端口统计计数
    Statistics1 GetPortStats -RxSignature RxSignature4
    Statistics2 GetPortStats -TxSignature TxSignature3
    
    #step8：停止路由
    port1 StopRouter
    port2 StopRouter
    
    #step9：清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                                   
}  err ] } {
    #返回结果"脚本运行中出现错误: $err"
    puts "脚本运行中出现错误: $err" 

    #清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                     
}
