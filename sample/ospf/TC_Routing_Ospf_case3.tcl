######################################################################
# 测试目的：测试Ospf协议收敛时间
#
# 功能说明:
#     STC的2个端口各仿真一个Ospf，添加路由池，进行路由宣告、撤销和震荡测试，另外一个端口发流
#
#     
# 创建时间: 2011.07.10
#
# 责任人：caimuyong
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
set islot 12
set islot2 12
#端口链表
set portList {1 2} ;#端口的排列顺序是port1, port2, port3
set portList2 {3} ;#端口的排列顺序是port1, port2, port3
set resolution 0.995
set routerWaitTime 10 ;#等待路由器交互和路由学习实践时间
set beforeSwtichTime 10 ;#等待
set routeNum 100
set routeStart 2.3.0.1
set maxSwitchTime 20
###############################初始化配置##############################

if { [catch {

    #加载HLAPI Lib
    cd ../Source
    source ./pkgIndex.tcl

   SetLogOption -Debug Enable

    #step1：开始连接机器
    TestDevice chassis1 $chassisAddr

    #step2：开始预留两个端口
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
    for {set i 0} {$i <[llength $portList2]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot2/[lindex $portList2 $i] -PortName port[expr $i+3] -PortType Ethernet
    }
    
    #创建host 对象
    port1 CreateHost -HostName host1 -IpVersion ipv4 -Ipv4Addr 1.1.1.5 -Ipv4AddrGateway 1.1.1.1  \
          -Ipv4AddrPrefixLen 24 -FlagPing enable
    
    #step3：创建路由对象         
    port2 CreateRouter -RouterName ospfRouter1 -routertype Ospfv2Router -routerId 2.1.0.2
    ospfRouter1 Ospfv2SetSession -ipaddr 2.2.2.5 -SutIpAddress 2.2.2.1 -abr true -networktype native
    
    #step4：配置路由
    ospfRouter1 Ospfv2CreateSummaryLsa -LsaName lsasum -AdvertisingRouter 2.2.2.5 -PrefixLen 24 -FirstAddress 1.3.1.0 -NumAddress 100

    ospfRouter1 Ospfv2Enable
    
    #step5：创建路由对象         
    port3 CreateRouter -RouterName ospfRouter2 -routertype Ospfv2Router -routerId 192.1.0.1
    ospfRouter2 Ospfv2SetSession -ipaddr 3.3.3.5 -SutIpAddress 3.3.3.1 -abr true -networktype native
    
    #step6：配置路由
    ospfRouter2 Ospfv2CreateSummaryLsa -LsaName lsasum -AdvertisingRouter 3.3.3.5 -PrefixLen 24 -FirstAddress 1.3.1.0 -NumAddress 100 -metric 10

    ospfRouter2 Ospfv2Enable
    
    #创建流量
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 1 -TrafficLoadUnit percent  
    traffic1 CreateStream -StreamName stream1 -FrameLen 256 -srcPoolName host1 -dstPoolName lsasum -streamType ospfv2

    #step11：创建Statistics1,Statistics2,Analysis2对象
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    port3 CreateStaEngine -StaEngineName Statistics3 -StaType Statistics
    Statistics1 SetWorkingMode -PortStreamLevel FALSE
    puts "Start statistics engine"
    port1 StartStaEngine
    stc::perform saveasxml -filename "d:/temp/1.xml"
    
    #step11：启动路由
    port2 StartRouter
    port3 StartRouter
    after [expr 1000*$routerWaitTime]
     
    port1 StartStaEngine
    puts "Start stream transmission"
    port1 StartTraffic -FlagArp true
     
    after [expr 1000*$beforeSwtichTime]
    array set rate1 [Statistics1 GetPortStats]
    array set rate2 [Statistics2 GetPortStats]
    parray rate1
    parray rate2
    if {$rate1(-TxRateFrames) == 0} {
        error "流量发送速率为0,请检查配置"
    }
    set startTime [clock seconds]
    while {[expr $rate2(-RxRateFrames)/$rate1(-TxRateFrames)] < $resolution} {
        after 1000
        set nowTime [clock seconds]
        if {[expr [expr $nowTime-$startTime] > $maxSwitchTime]} {
            error "流量等待时间超过最大切换时间没有预期状态,请检查配置"
        }
    }
     
    #断开端口2连接,流量会切换到端口3
    port2 BreakLink
    
    #计算切换时间
    set startTime [clock seconds]
    array set rate1 [Statistics1 GetPortStats]
    array set rate3 [Statistics3 GetPortStats]
    set times 0
    while {$times <3 } {
        after 1000
        array set rate1 [Statistics1 GetPortStats]
        array set rate3 [Statistics3 GetPortStats]
        if {[expr $rate3(-RxRateFrames)/$rate1(-TxRateFrames)] >= $resolution} {
            incr times
        } else {
            set times 0
        }
        set nowTime [clock seconds]
        set converTime [expr wide(wide($nowTime)-wide($startTime))]
        if {$converTime>$maxSwitchTime} {
            break
        }
    }
    if {$converTime <= $maxSwitchTime} {
        puts "收敛时间为 $converTime 秒"
    } else {
        puts "收敛时间超过最大切换时间"
    }
     
    port1 StopTraffic
     
    #step13：停止路由
    port2 StopRouter
    
    #step14：清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                                   
}  err ] } {
    #返回结果"脚本运行中出现错误: $err"
    puts "脚本运行中出现错误: $err" 

    #清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                     
}
