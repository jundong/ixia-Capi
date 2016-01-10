######################################################################
# 测试目的：测试BGP协议仿真功能
#
# 功能说明:
#     STC的2个端口各仿真一个BGP路由器，添加路由池，进行路由宣告、撤销和震荡测试，另外一个端口发流
#     创建Mpls VPN，配置带VPN路由等
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
#端口链表
set portList {1 2} ;#端口的排列顺序是port1, port2, port3
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
    
    #创建host 对象
    port1 CreateHost -HostName host1 -IpVersion ipv4 -Ipv4Addr 1.1.1.5 -Ipv4AddrGateway 1.1.1.1  \
          -Ipv4AddrPrefixLen 24 -FlagPing enable
    
    #step3：创建路由对象         
    port2 CreateRouter -RouterName bgproute1 -RouterType BgpV4Router -routerid 192.1.0.2
    
    #step4：配置路由
    bgproute1 BgpV4SetSession -PeerType EBGP -TesterIp 2.2.2.5 -PrefixLen 24 -TesterAs 1000 -SutIp 2.2.2.1 -SutAs 1001 -Active Enable
     
    #step5：获取路由信息         
    bgproute1 BgpV4RetrieveRouter -PeerType PeerType -TesterIp TesterIp -PrefixLen PrefixLen -State State
    
    puts "PeerType:$PeerType,TesterIp:$TesterIp,PrefixLen:$PrefixLen,State:$State"
    
    bgproute1 BgpV4Enable
    #bgproute1 Disable
    
    bgproute1 BgpV4CreateRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.0 -PrefixLen 24 -RouteNum 1000 -Active enable \
              -AS_SEQUENCE yes  -NEXTHOP 2.2.2.5 -AS_PATH 1000
        
    #创建流量
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 1 -TrafficLoadUnit percent  
    traffic1 CreateStream -StreamName stream1 -FrameLen 256 -srcPoolName host1 -dstPoolName block1 -streamtype bgp

    #step11：创建Statistics1,Statistics2,Analysis2对象
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    Statistics1 SetWorkingMode -PortStreamLevel FALSE
    puts "Start statistics engine"
    port1 StartStaEngine
    stc::perform saveasxml -filename "d:/temp/1.xml"
    #step11：启动路由
    port2 StartRouter
    after 10000
    
    set flag 1
    set resolution 10
    set maxNum 1000
    set nowNum 800
    set minNum 0
    set minflag 1
    set maxflag 1
    while {$flag} {
        puts "nowNum=$nowNum"
        bgproute1 BgpV4SetRouteBlock -BlockName block1 -RouteNum $nowNum
        bgproute1 BgpV4AdvertiseRouteBlock -BlockName block1
        #等待10s
        after 10000
        
        port1 StartStaEngine
        puts "Start stream transmission"
        port1 StartTraffic -FlagArp true
        
        after 10000
        puts "Stop traffic transmission on sender port"
        port1 StopTraffic
        after 1000
        #bgproute1 BgpV4WithdrawRouteBlock -BlockName block1
        array set stats [Statistics1 GetStreamStats -StreamName stream1]
        parray stats
        if {$stats(-TxSigFrames) <= $stats(-RxSigFrames)} {
            if {($nowNum >= $maxNum) || ([expr 100*abs($nowNum-$maxNum)/$nowNum] < $resolution)} {
                set flag 0
            } else {
                if {$minflag} {
                    set minflag 0
                    set minNum $nowNum
                    set nowNum $maxNum
                } else {
                    set minNum $nowNum
                    set nowNum [expr ($nowNum+$maxNum)/2]
                }
            }
        } else {
            if {($nowNum <= $minNum) || ([expr 100*abs($nowNum-$minNum)/$nowNum] < $resolution)} {
                set flag 0
            } else {
                if {$minflag} {
                    set minflag 0
                    set maxNum $nowNum
                    set nowNum $minNum
                } else {
                    set maxNum $nowNum
                    set nowNum [expr ($nowNum+$minNum)/2]
                }
            }
        }
    }

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
