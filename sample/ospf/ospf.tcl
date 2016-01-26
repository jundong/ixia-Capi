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
      
    port1 ConfigPort -MediaType fiber

    #step3：创建路由对象         
    port1 CreateRouter -RouterName ospfv2Router1  -RouterType ospfv2Router  -routerid 192.1.0.1 -FlagPing enable

    #step4：配置路由
    ospfv2Router1 Ospfv2SetSession -ipaddr 192.85.1.3 -SutIpAddress 192.85.1.11 -abr true -networktype native    
    ospfv2Router1 Ospfv2CreateSummaryLsa -LsaName test -advertisingrouter 192.85.1.3 -FirstAddress 1.1.1.1 -prefixlength 24 -NumAddress 2

    #step5：使能BGP进程Active                                                                                       
    ospfv2Router1 Ospfv2Enable

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
