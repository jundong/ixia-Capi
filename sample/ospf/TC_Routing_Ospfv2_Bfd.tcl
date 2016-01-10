######################################################################
# 测试目的：测试Ospf协议收敛时间
#
# 功能说明: 
#     OSPF路由收敛测试
#测试步骤:
#1、根据测试拓扑连接被测设备DUT与测试仪表
#2、测试仪和设备1、2、3口分别构建OSPF路由协议
#3、测试仪B和C分别向2和3发送相同数量、相同内容的路由，其中2为主链路
#4、测试仪发送恒速V pps流量，目的地为B和C发布的路由，流量优先从2口发送
#5、待流量发送稳定后，确认B口可以接收到所有的流量，此时断开C口的链路（在Testcenter上不要shutdown端口，只是模拟链路down），流量会切换到3口发送到C，直到T时刻，C口收到报文的速率也为V pps流量，路由收敛时间即为T
#     
# 创建时间: 2011.10.17
#
# 责任人：caimuyong
#
# 修改说明：
#                                      
#######################################################################

####################变量配置区，用户根据需要可自行修改#################
#机框地址
set chassisAddr 10.61.32.92
#zqset islot 12
#zqset portList {3 4} ;#端口的排列顺序是port1, port2
#槽位号
set islot 2
#端口链表
set portList {1 2} ;#端口的排列顺序是port1, port2, port3
set resolution 0.995
set routerWaitTime 10 ;#等待路由器交互和路由学习实践时间
set beforeSwtichTime 10 ;#等待
set routeNum 100
set routeStart 2.3.0.1
set maxSwitchTime 20
set gSTCVersion 4.15
###############################初始化配置##############################

if { [catch {

    #加载HLAPI Lib
    source ./pkgIndex.tcl

    SetLogOption -Debug Enable

    #step1：开始连接机器
    TestDevice chassis1 $chassisAddr
    chassis1 ConfigResultOptions  -ResultViewMode JITTER

    #step2：开始预留两个端口
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType ethernet
    }
    
    #step3：创建host 对象
    port1 CreateHost -HostName host1 -IpVersion ipv4 -Ipv4Addr 1.1.1.5 -Ipv4AddrGateway 1.1.1.1  \
          -Ipv4AddrPrefixLen 24 -FlagPing enable
    
    #step4：创建路由对象         
    port2 CreateRouter -RouterName ospfRouter1 -routertype Ospfv2Router -routerId 2.1.0.2
    ospfRouter1 Ospfv2SetSession -ipaddr 2.2.2.5 -SutIpAddress 2.2.2.1 -abr true -networktype native
    ospfRouter1 Ospfv2SetBfd -RouterRole active -authentication none
    #step5：配置路由
    ospfRouter1 Ospfv2CreateSummaryLsa -LsaName lsasum -AdvertisingRouter 2.2.2.5 -PrefixLen 24 -FirstAddress 1.3.1.0 -NumAddress 100

    ospfRouter1 Ospfv2Enable
    
    #step6：创建流量
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 1 -TrafficLoadUnit percent  
    traffic1 CreateStream -StreamName stream1 -FrameLen 256 -srcPoolName host1 -dstPoolName lsasum -streamType ospfv2

    #step7：创建Statistics1,Statistics2,Analysis2对象
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    puts "Start statistics engine"
    port1 StartStaEngine
    SaveConfigAsXML "d:/temp/1.xml"
    
    #step8：启动路由
    port2 StartRouter
    after [expr 1000*$routerWaitTime]
    
    #step9：启动流量
    puts "Start stream transmission"
    port1 StartTraffic -FlagArp true
    after [expr 1000*$beforeSwtichTime]
    
    #step10：停止流量
    port1 StopTraffic
    
    array set rate1 [Statistics1 GetPortStats]
    array set rate2 [Statistics2 GetPortStats]
    
    puts $rate1(-TxFrames)
    puts $rate2(-RxFrames)
    if {$rate1(-TxFrames) != $rate2(-RxFrames)} {
        error "流量有丢包，请检查!"
    }
    
    #step11：停止路由
    port2 StopRouter
    
    #step12：清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                                   
}  err ] } {
    #返回结果"脚本运行中出现错误: $err"
    puts "脚本运行中出现错误: $err" 

    #清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                     
}
