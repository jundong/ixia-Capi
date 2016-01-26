####################变量配置区，用户根据需要可自行修改#################
#机框地址
set chassisAddr 172.16.174.137
#槽位号
set islot {1}
set portList {1} ;#端口的值是port1
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
    #port1 DeleteAllStream
    port1 ConfigPort -MediaType fiber

    #step3：创建路由对象         
    port1 CreateRouter -RouterName ospfv3Router1  -RouterType ospfv3Router  -routerid 192.1.0.1 -FlagPing enable

    #step4：配置路由
    ospfv3Router1 Ospfv3SetSession -ipaddr 2000::3 -SutIpAddress 2000::11 -abr true -networktype broadcast    
    ospfv3Router1 Ospfv3CreateTopRouter -RouterId 1.0.0.1 -RouterTypeValue EBIT -RouterLsaName RouterLsa11 -RouterName ospfv3Rtr1
    ospfv3Router1 Ospfv3CreateTopRouterLink -RouterName ospfv3Rtr1 -LinkName link1 -LinkType p2p -LinkInterfaceId 11 \
                                    -LinkInterfaceAddress 2000::100 -LinkMetric 1 -NeighborInterfaceId 12\
                                    -NeighborRouterId  1.0.0.2
    ospfv3Router1 Ospfv3CreateTopExternalPrefixRouteBlock -blockname block1 -StartingAddress  2000::1 -prefix 64 -number 10 \
                                                -AdvertisingRouterId 1.0.0.1 -metric 2 -metrictype True 

    #step5：使能OSPFV3
    ospfv3Router1 Ospfv3Enable

    #step6：启动路由
    port1 StartRouter

    #step7：等待5秒
    after 5000

    #step8：停止路由
    port1 StopRouter
    
    #step9：清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                                   
}  err ] } {
    #返回结果"脚本运行中出现错误: $err"
    puts "脚本运行中出现错误: $err" 

    #清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                     
}
