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
    port1 CreateRouter -RouterName bgproute1 -RouterType BgpV6Router -routerid 192.1.0.1 -FlagPing enable 
    port2 CreateRouter -RouterName bgproute2 -RouterType BgpV6Router -routerid 192.1.0.2 -FlagPing enable

    #step4：配置路由
    bgproute1 BgpV6SetSession -TesterIp 2000::1 -TesterAs 1001 -SutIp 2000::111 -SutAs 1001 -GateWay 2000::111
    bgproute2 BgpV6SetSession -TesterIp 2000::111 -TesterAs 1001 -SutIp 2000::1 -SutAs 1001 -GateWay 2000::1
    
    bgproute1 BgpV6CreateRouteBlock -BlockName block1 -AddressFamily ipv6 -FirstRoute 3000::1 -PrefixLen 64 -RouteNum 2 \
              -NEXTHOP 2000::1 -AS_PATH {1 2}
    
    #step5：使能BGP进程Active                                                                                       
    bgproute1 BgpV6Enable
    bgproute2 BgpV6Enable

    #step6：启动路由
    port1 StartRouter
    port2 StartRouter
    after 30000
    
    #step7：进行路由宣告与撤销
    set repeatNum 2
    for {set i 0} {$i < $repeatNum} {incr i} {
        bgproute1 BgpV6AdvertiseRouteBlock -BlockName block1
        bgproute1 BgpV6WithdrawRouteBlock -BlockName block1
        bgproute1 BgpV6AdvertiseRouteBlock -BlockName block1
    }
    bgproute1 BgpV6WithdrawRouteBlock -BlockName block1
    bgproute1 BgpV6DeleteRouteBlock -BlockName block1
    
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
