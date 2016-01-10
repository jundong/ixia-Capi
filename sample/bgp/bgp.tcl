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
    port1 CreateRouter -RouterName bgproute1 -RouterType BgpV4Router -routerid 192.1.0.1 -FlagPing enable

    #step4：配置路由
    bgproute1 BgpV4SetSession -TesterIp 192.85.1.3 -TesterAs 1001 -SutIp 192.85.1.11 -SutAs 1001
     
    bgproute1 BgpV4CreateRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.0 -PrefixLen 32 -RouteNum 2 \
              -NEXTHOP 192.85.1.3 -AS_PATH {2 89}
    
    #step5：使能BGP进程Active                                                                                       
    bgproute1 BgpV4Enable

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
