######################################################################
# 测试目的：检验Ospfv2 API的功能
#
# 功能说明:
#     本测试例在STC的一个端口上模拟一个路由器，轮询ospfv2 router的邻居状态直到
#     为full，在该路由器上添加12个拓扑路由器，分别添加Ospfv2 Topo Link将Top Router
#     连接起来；添加summary route block，并将Route block连接到Topo Router；
#     通告撤销全部及部分Topo Router，Topo Link。通过查看屏幕打印信息和GUI Port上
#     模拟的路由器的路由表来检验API功能的正确性
#
# 创建时间: 2010.3.17
#
# 责任人：yuanfen
#
# 修改说明：
#                                                                               
######################################################################

#该函数用于等待键盘输入'a',然后继续往下运行
proc WaitKeyboardInput {{platform "Spirent"}} {
if {0} {
if {$platform == "Spirent"} {
    puts "please press any 'a' to continue..."
    flush stdout
    set input [gets stdin]
    while {$input != "a"} {
        puts  "please press any 'a' to continue..."
        after 1000
        set input [gets stdin]
    }
} else {
    puts "waiting 5 seconds..."
    after 5000
}   
}

}
#该函数用于创建日志文件
proc CreateFile {fileName} {
  set fileId [open $fileName "w"]
  close $fileId
}
#该函数用于将日志信息写入日志文件和打印到屏幕
proc PutFile {fileName msg} {
  set fileId [open $fileName "a"]
  
  puts $fileId $msg
  puts "$msg"
  close $fileId
}
#该函数用于将数组信息写入日志文件和打印到屏幕
proc PutArray {fileName arg} {
     set fileId [open $fileName "a"]   
     foreach name [array names ::$arg] {
         puts $fileId "[subst $arg]([subst $name]) =  [subst $[subst ::[subst $arg]($name)]]"
         puts "[subst $arg]([subst $name]) =  [subst $[subst ::[subst $arg]($name)]]"
     }
     close $fileId
}       
                 
####################变量配置区，用户根据需要可自行修改#################
#机框地址
set chassisAddr 10.61.34.249
#zqset slotId 3
#槽位号
set slotId 11
#端口id
set portList {7 8}
set debug 0
set fileName d:/log.txt
###############################初始化配置##############################
if { [catch {  
    CreateFile $fileName

    #加载STC API Lib
    
    cd ../Source
    #加载HLAPI Lib
    source ./pkgIndex.tcl

    SetLogOption -Debug Enable -LogTo stdout -FileName d:/log2.txt

    # step1：实例化设备类对象TestDevice
    PutFile $fileName " 实例化设备类对象 "
    TestDevice chassis1 $chassisAddr
    # step2：创建端口类对象TestPort
    PutFile $fileName "创建端口类对象 "
       for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $slotId/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
        
    }

    #step3：创建Router类对象ospf2 Router
    PutFile $fileName "创建Router类对象 "
    port1 CreateRouter -RouterName ospfRouter1 -routertype Ospfv2Router -routerId 2.1.0.2
    ospfRouter1 Ospfv2SetSession -ipaddr 7.1.0.5 -Abr yes -Area 0.0.0.2 -NetworkType P2P -PduOptionValue TBIT -SutIpAddress 192.85.2.2 -SutRouterID 192.85.3.2 -HelloInterval 10 -DeadInterval 40 -RetransmitInterval 6 -TransitDelay 99 -InterfaceCost 5 \
    -routerpriority 10 -MTU 1400 -FlagGraceRestart true -RestartInterval 3 -RestartType RFCSTANDARD -RestartReason Reload -Active true -AuthenticationType simple -Password Spirent -Md5KeyId 1 -FlagNeighborDr true -LocalMac "00:00:00:11:01:05" -LocalMacModifier "00:00:00:00:00:02"
    
    SaveConfigAsXML "C:/ospfv2.xml" 
    
    port1 StartRouter  
    set state ""
    ospfRouter1 Ospfv2RetrieveRouter -state state

    #added by yuanfen 7.6 2011
    port2 CreateRouter -RouterName ospfRouter2 -routertype Ospfv2Router -routerId 2.1.0.3
    ospfRouter2 Ospfv2SetSession -ipaddr 7.1.0.6 -routerpriority 0 
    
    puts "Create streams..."    
    port1 CreateTraffic -TrafficName traffic1 
    traffic1 CreateProfile -Name profile1 -TrafficLoad 2 -TrafficLoadUnit percent -FrameNum 500 -BurstSize 10
    traffic1 CreateStream -StreamName stream1 -FrameLen 256 -ProfileName profile1 -StreamType "ospfv2" -SrcPoolName "ospfRouter1" -DstPoolName "ospfRouter2" -L4 Udp -udpsrcport 2000 -udpdstport 3000
  
    port2 CreateTraffic -TrafficName traffic2 
    traffic2 CreateProfile -Name profile2 -TrafficLoad 2 -TrafficLoadUnit percent -FrameNum 500 -BurstSize 10
    traffic2 CreateStream -StreamName stream2 -FrameLen 512 -ProfileName profile2 -StreamType "ospfv2" -SrcPoolName "ospfRouter2" -DstPoolName "ospfRouter1"
    
    #step4：轮询Ospf邻居状态，直到为full  
    PutFile $fileName "轮询Ospf邻居状态，直到为full "
  # while {$state !="FULL"} {
      PutFile $fileName "==============="
      PutFile $fileName "state=$state"
      after 2000
      ospfRouter1 Ospfv2RetrieveRouter -state state
   #}

    PutFile $fileName "============================================="
    PutFile $fileName "添加Ospfv2 Topo Router "
    #step5：创建Topo Router
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr1 -routerid 3.0.0.1 
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr2 -routerid 3.0.0.2 
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr3 -routerid 3.0.0.3 
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr4 -routerid 3.0.0.4  -RouterTypeValue  BIT_B
   
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr5 -routerid 3.0.0.5 
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr6 -routerid 3.0.0.6 
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr7 -routerid 3.0.0.7 
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr8 -routerid 3.0.0.8 -RouterTypeValue  BIT_E
   
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr9 -routerid 3.0.0.9 
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr10 -routerid 3.0.0.10 
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr11 -routerid 3.0.0.11
    ospfRouter1 Ospfv2CreateTopRouter -routername rtr12 -routerid 3.0.0.12    
    WaitKeyboardInput
   
    #step6：创建Link，将之前创建的Topo Router 连接起来
    PutFile $fileName "============================================="
    PutFile $fileName "添加Ospfv2 Topo Link连接Top Router "
    ospfRouter1 Ospfv2CreateTopRouterLink -routername ospfRouter1 -LinkName link1  -LinkType ptp -LinkConnectedName rtr1 -LinkMetric  2
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr1 -LinkName link2  -LinkType ptp -LinkConnectedName rtr2 -LinkMetric  2
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr2 -LinkName link3  -LinkType ptp -LinkConnectedName rtr3 -LinkMetric  2
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr3 -LinkName link4  -LinkType ptp -LinkConnectedName rtr4 -LinkMetric  2

    ospfRouter1 Ospfv2CreateTopRouterLink -routername ospfRouter1 -LinkName link5  -LinkType ptp -LinkConnectedName rtr5 -LinkMetric  3
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr5 -LinkName link6  -LinkType ptp -LinkConnectedName rtr6 -LinkMetric  3
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr6 -LinkName link7  -LinkType ptp -LinkConnectedName rtr7 -LinkMetric  3
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr7 -LinkName link8  -LinkType ptp -LinkConnectedName rtr8 -LinkMetric  3   
    WaitKeyboardInput

    PutFile $fileName "============================================="
    PutFile $fileName "添加Ospfv2 Topo Link连接Top Router "
    ospfRouter1 Ospfv2CreateTopNetwork -NetworkName network1 -Subnetwork  100.0.0.0 -Prefix  24 -DrRouterName rtr9
    ospfRouter1 Ospfv2CreateTopRouterLink  -routername  rtr9  -LinkName  link9   -LinkType  nbma  -LinkConnectedName  network1  -LinkMetric  4  
    ospfRouter1 Ospfv2CreateTopRouterLink  -routername  rtr10  -LinkName  link10   -LinkType  nbma  -LinkConnectedName  network1  -LinkMetric  4 
    ospfRouter1 Ospfv2CreateTopRouterLink  -routername  rtr11  -LinkName  link11   -LinkType  nbma  -LinkConnectedName  network1  -LinkMetric  4 
    ospfRouter1 Ospfv2CreateTopRouterLink  -routername  rtr12  -LinkName  link12   -LinkType  nbma  -LinkConnectedName  network1  -LinkMetric  4 

    WaitKeyboardInput
  
    #step7：创建summary route block
    PutFile $fileName "============================================="
    PutFile $fileName "添加Ospfv2 Topo Routes Block"

    ospfRouter1 Ospfv2CreateTopSummaryRouteBlock -blockname block1 -startingaddress 200.0.0.1 -prefix 25 -number 10 -modifier 3 
    ospfRouter1 Ospfv2SetTopSummaryRouteBlock -blockname block1 -startingaddress 200.0.0.1 -prefix 25 -number 10 -modifier 3 

    ospfRouter1 Ospfv2CreateTopExternalRouteBlock -blockname block2 -startingaddress 201.0.0.1 -prefix 23 -number 10 -modifier 3 
    WaitKeyboardInput
    #step8：创建Link，将Route block连接到Topo Router
    PutFile $fileName "将Routes Block连接到Top Router"
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr4 -LinkName link13  -LinkConnectedName block1 -LinkMetric  10   
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr8 -LinkName link14  -LinkConnectedName block2 -LinkMetric  10
    WaitKeyboardInput

    PutFile $fileName "============================================="
    PutFile $fileName "通告 全部Topo Router"
    #step9：通告之前创建的Topo Router
    ospfRouter1 Ospfv2AdvertiseRouters -RouterNameList {ospfRouter1 rtr1 rtr2 rtr3 rtr4 rtr5 rtr6 rtr7 rtr8 rtr9 rtr10 rtr11 rtr12}

    PutFile $fileName "撤销部分 Topo Router"
    WaitKeyboardInput
    #step10：撤销部分 Topo Router
    ospfRouter1 Ospfv2WithdrawRouters -RouterNameList {rtr1 rtr2 rtr3}
    PutFile $fileName "通告 部分Topo Router"
    WaitKeyboardInput
    #step11：通告部分Topo Router
    ospfRouter1 Ospfv2AdvertiseRouters -RouterNameList {rtr1 rtr2 rtr3}
    WaitKeyboardInput

    PutFile $fileName "============================================="
    PutFile $fileName "通告 全部Topo Link"
    #step12：通告全部Topo Link
    ospfRouter1 Ospfv2AdvertiseLinks -LinkNameList {link1 link2 link3 link4 link5 link6 link7 link8 link9 link10 link11 link12 link13 link14 }
    WaitKeyboardInput
    PutFile $fileName "撤销部分Topo Link"
    #step13：撤销部分Topo Link
    ospfRouter1 Ospfv2WithdrawLinks  -LinkNameList { link6 link7 link8 }
    WaitKeyboardInput
    PutFile $fileName "通告 部分Topo Link"
    #step14：通告部分Topo Link
    ospfRouter1 Ospfv2AdvertiseLinks  -LinkNameList { link6 link7 link8 } 
    
    #step15：清除配置并释放测试过程中占用的所有资源
    chassis1 CleanupTest      
}  err ] } {   
    #输出 "脚本运行中出现错误: $err"
    puts "脚本运行中出现错误: $err" 
    # 清除配置并释放测试过程中占用的所有资源
    chassis1 CleanupTest                  
}                  