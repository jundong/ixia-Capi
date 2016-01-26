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
    port1 CreateRouter -RouterName ISISv6Router1 -routertype ISISRouter -routerId 192.168.0.1 -FlagPing enable
    port2 CreateRouter -RouterName ISISv6Router2 -routertype ISISRouter -routerId 192.168.0.2 -FlagPing enable
    ISISv6Router1 IsisSetSession -addressfamily ipv6 -ipv6addr 2000::3 -ipv6prefixlen 64 \
                               -ipv6gatewayaddr 2000::30 -TestLinkLocalAddr FE80::22 \
                               -routinglevel L2 -systemid 77:00:00:00:00:22 -areaid 470001 -macaddr 00:00:00:00:00:22   
    ISISv6Router1 IsisCreateRouteBlock -blockname block1 -routepooltype ipv6 -routinglevel L2 -firstaddress \
                                       3000::10 -prefixlen 128 -numaddress 10  -systemid 77:00:00:00:00:22
    
    ISISv6Router2 IsisSetSession -addressfamily ipv6 -ipv6addr 2000::30 -ipv6prefixlen 64 \
                               -ipv6gatewayaddr 2000::3 -TestLinkLocalAddr FE80::33 \
                               -routinglevel L2 -systemid 88:00:00:00:00:33 -areaid 470001 -macaddr 00:00:00:00:00:33 
    
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 10 -TrafficLoadUnit fps  
    traffic1 CreateStream -StreamName stream1 -FrameLen 64 -srcPoolName ISISv6Router2 -dstPoolName block1 -streamType isis -ProfileName profile1      
    #流量应用profile
    traffic1 ApplyProfileToPort profile1 profile
    
    #创建Statistics1-Statistics4统计对象
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    
    
    #step5：使能BGP进程Active                                                                                       
    ISISv6Router1 IsisEnable
    ISISv6Router2 IsisEnable

    #step6：启动路由
    port1 StartRouter
    port2 StartRouter
    
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
