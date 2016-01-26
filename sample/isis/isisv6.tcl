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
    ISISv6Router1 IsisCreateRouteBlock -blockname block3 -routepooltype ipv6 -routinglevel L2 -firstaddress \
                                       3000::10 -prefixlen 128 -numaddress 10  -systemid 77:00:00:00:00:22
    
    ISISv6Router2 IsisSetSession -addressfamily ipv6 -ipv6addr 2000::30 -ipv6prefixlen 64 \
                               -ipv6gatewayaddr 2000::3 -TestLinkLocalAddr FE80::33 \
                               -routinglevel L2 -systemid 88:00:00:00:00:33 -areaid 470001 -macaddr 00:00:00:00:00:33 
    
    #step5：使能BGP进程Active                                                                                       
    ISISv6Router1 IsisEnable
    ISISv6Router2 IsisEnable

    #step6：启动路由
    port1 StartRouter
    port2 StartRouter
    after 30000
    
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
