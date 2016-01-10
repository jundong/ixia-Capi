######################################################################
# 测试目的：检验Ospfv3 API的功能
#
# 功能说明:
#     本测试例在STC的一个端口上模拟一个路由器，在该路由器上添加拓扑路由器，再
#     添加不同的Ospfv3 Topo Link连接类型将Top Router连接起来；创建5个拓扑路由器，
#     添加Ospfv3TopNetwork将上述5个路由器连成一个网络；创建配置删除Ospfv3
#     InterAreaRouteBlock、Ospfv3 ExternalRouteBlock。创建删除TopGrid。通过查看
#     屏幕打印信息和GUI Port上模拟的路由器的路由表来检验API功能的正确性。
#
# 创建时间: 2010.3.17
#
# 责任人：yuanfen
#
# 修改说明：
#                                                                               
###################################################################### 

#该函数用于等待键盘输入'a',然后继续往下运行
proc WaitKeyboardInput {} {
    puts "please press any 'a' to continue..."
    flush stdout
    set input [gets stdin]
    while {$input != "a"} {
        puts "please press any 'a' to continue..."
        after 1000
        set input [gets stdin]
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
  puts $msg
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
set slotId 12
#端口id
set portId 1
set debug 0
set fileName d:/Ospv3_log.txt
###############################初始化配置############################## 

if { [catch {  
    CreateFile $fileName
    
    cd ../Source
    #加载HLAPI Lib
    source ./pkgIndex.tcl

    if {$debug} {
        set hOptions [::stc::get system1 -children-AutomationOptions]
        stc::config $hOptions -LogTo stdout  -LogLevel INFO 
    }
    SetLogOption -Debug Enable -LogTo stdout -FileName d:/log2.txt

    #step1：实例化设备类对象
    PutFile $fileName " 实例化设备类对象 "
    TestDevice chassis1 $chassisAddr
    #step2：创建端口类对象
    PutFile $fileName "创建端口类对象 "
    chassis1 CreateTestPort -PortLocation $slotId/$portId -PortName port1 -PortType Ethernet    
    #step3：创建Ospfv3 Router
    PutFile $fileName "创建Ospfv3 Router "
    port1 CreateRouter -RouterName ospfRouter1 -routertype Ospfv3Router -routerId 1.1.1.2
    ospfRouter1 Ospfv3SetSession -ipaddr 3000::2  
    #-FlagNeighborDr 1
    #step4：开启Ospfv3 协议仿真
    PutFile $fileName "开启Ospfv3 协议仿真 "
    port1 StartRouter  
    set state ""
    ospfRouter1 Ospfv3RetrieveRouter -state state
   
    PutFile $fileName "================================"
    PutFile $fileName "watching point 1"
    #WaitKeyboardInput

    PutFile $fileName "================================"
    PutFile $fileName "watching point 2"

    #step5：添加Ospfv3TopRouter
   if {1} {
    PutFile $fileName "添加Ospfv3TopRouter 2"
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 11.0.0.1 -RouterTypeValue BBIT -RouterLsaName RouterLsa2 -RouterName ospfRtr2
    #array set router2Config [ospfRouter1 GetOspfTopRouter -RouterName ospfRtr2]
    PutArray $fileName router2Config
    PutFile $fileName "================================"
    PutFile $fileName "watching point 3"
    #WaitKeyboardInput
   }
   
    #step6：添加Ospfv3TopRouter Link
    PutFile $fileName "添加Ospfv3TopRouter Link "
    ospfRouter1 Ospfv3CreateTopRouterLink -RouterName ospfRtr2 -LinkName link1 -LinkType  p2p  -LinkInterfaceId  11 \
                                                       -LinkInterfaceAddress 1000::2  -LinkMetric 2 -NeighborInterfaceId  12\
                                                       -NeighborRouterId  12.0.0.1
    ospfRouter1 Ospfv3CreateTopRouterLink -RouterName ospfRtr2 -LinkName link2 -LinkType  TRANSIT  -LinkInterfaceId  13 \
                                                       -LinkInterfaceAddress 1000::12  -LinkMetric 3 -NeighborInterfaceId  14\
                                                       -NeighborRouterId  12.0.0.2
    ospfRouter1 Ospfv3CreateTopRouterLink -RouterName ospfRtr2 -LinkName link3 -LinkType  vl  -LinkInterfaceId  15 \
                                                       -LinkInterfaceAddress 1000::3  -LinkMetric 3 -NeighborInterfaceId  16\
                                                       -NeighborRouterId  12.0.0.3  
    #array set router2Config [ospfRouter1 GetTopRouter -RouterName ospfRtr2]
    PutArray $fileName router2Config    

    #array set linkConfig [ospfRouter1 GetTopRouterLink -linkname link1 -RouterName ospfRtr2]
    PutArray $fileName linkConfig
    PutFile $fileName "================================"
    PutFile $fileName "watching point 4"
    #WaitKeyboardInput

    #step7：删除Ospfv3TopRouterLink
    PutFile $fileName "删除Ospfv3TopRouterLink "
    ospfRouter1 Ospfv3DeleteTopRouterLink -linkname link1 -RouterName ospfRtr2
    #array set router2Config [ospfRouter1 GetTopRouter -RouterName ospfRtr2]
    PutArray $fileName router2Config    
    PutFile $fileName "================================"
    PutFile $fileName "watching point 5"
    #WaitKeyboardInput
    #删除Ospfv3TopRouter
    PutFile $fileName "删除Ospfv3TopRouter "
    ospfRouter1 Ospfv3DeleteTopRouter -routername ospfRtr2
    PutFile $fileName "================================"
    PutFile $fileName "watching point 6"
    #WaitKeyboardInput

    #step8：添加Ospfv3TopRouter
    PutFile $fileName "添加Ospfv3TopRouter "
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.1 -RouterTypeValue BBIT  -RouterName ospfRtr1
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.2 -RouterTypeValue EBIT  -RouterName ospfRtr2
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.3 -RouterTypeValue VBIT  -RouterName ospfRtr3
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.4 -RouterTypeValue WBIT  -RouterName ospfRtr4
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.5 -RouterTypeValue BBIT  -RouterName ospfRtr5
    #step9：添加Ospfv3TopNetwork
    PutFile $fileName "添加Ospfv3TopNetwork "
    ospfRouter1 Ospfv3CreateTopNetwork -networkname network1 -subnetwork 2000::1 -prefix 70 \
                                                   -ddroutername ospfRtr1 -ConnectedRouterNameList {ospfRtr1 ospfRtr2 ospfRtr3 ospfRtr4 ospfRtr5}
    #array set networkConfig [ospfRouter1 GetTopNetwork -networkName network1]
    PutArray $fileName networkConfig    
    PutFile $fileName "================================"
    PutFile $fileName "watching point 7"
    #WaitKeyboardInput
    #step10：删除Opsfv3TopNetwork
    PutFile $fileName "删除Opsfv3TopNetwork "
    ospfRouter1 Ospfv3DeleteTopNetwork -networkname network1
    PutFile $fileName "================================"
    PutFile $fileName "watching point 8"
    #WaitKeyboardInput

    #step11：创建Ospfv3 InterAreaRouteBlock
    PutFile $fileName "创建Ospfv3 InterAreaRouteBlock "
    ospfRouter1 Ospfv3CreateTopInterAreaPrefixRouteBlock -blockname block1 -StartingAddress  3000::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1 -FlagLaBit  1
                                                                                  
    ospfRouter1 Ospfv3CreateTopInterAreaPrefixRouteBlock -blockname block2 -StartingAddress  3100::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1 -FlagLaBit  1                                                                                  

    #array set block1 [ospfRouter1 GetTopInterAreaPrefixRouteBlock -blockname block1]
    PutArray $fileName block1     
    PutFile $fileName "================================"
    PutFile $fileName "watching point 9"
    WaitKeyboardInput
    #step12：配置Ospfv3 InterAreaRouteBlock
    PutFile $fileName "配置Ospfv3 InterAreaRouteBlock "
    ospfRouter1 Ospfv3SetTopInterAreaPrefixRouteBlock -blockname block1 -StartingAddress  4000::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1   
    #array set block1 [ospfRouter1 GetTopInterAreaPrefixRouteBlock -blockname block1]
    PutArray $fileName block1  
    PutFile $fileName "================================"
    PutFile $fileName "watching point 10"
    WaitKeyboardInput
    #step13：删除Ospfv3 InterAreaRouteBlock
    PutFile $fileName "删除Ospfv3 InterAreaRouteBlock "
    ospfRouter1 Ospfv3DeleteTopInterAreaPrefixRouteBlock -blockname block1
    PutFile $fileName "================================"
    PutFile $fileName "watching point "
    WaitKeyboardInput
    #step14：创建Ospfv3 ExternalRouteBlock
    PutFile $fileName "创建Ospfv3 ExternalRouteBlock 11"
    ospfRouter1 Ospfv3CreateTopExternalPrefixRouteBlock -blockname block3 -StartingAddress  5000::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1 -FlagLaBit  1 \
                                                                                  -metric 2 -metrictype True -ForwardingAddress  5100::1\
                                                                                  -flagasbr 1 -ExternalRouteTag 3

    #array set block2 [ospfRouter1 GetTopExternalPrefixRouteBlock -blockname block2]
    PutArray $fileName block3     
    PutFile $fileName "================================"
    PutFile $fileName "watching point 12"
    WaitKeyboardInput
    #step15：配置Ospfv3 ExternalRouteBlock
    PutFile $fileName "配置Ospfv3 ExternalRouteBlock "
    ospfRouter1 Ospfv3SetTopExternalPrefixRouteBlock -blockname block3 -StartingAddress  5200::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1 -FlagLaBit  1 \
                                                                                  -metric 2 -metrictype True -ForwardingAddress  5100::1\
                                                                                  -flagnssa 1 -ExternalRouteTag 5
                                                                                  
    #array set block2 [ospfRouter1 GetTopExternalPrefixRouteBlock -blockname block2]
    PutArray $fileName block3      
    PutFile $fileName "================================"
    PutFile $fileName "watching point 13"
    WaitKeyboardInput
    #step16：删除Ospfv3 ExternalRouteBlock
    PutFile $fileName "删除Ospfv3 ExternalRouteBlock "
    ospfRouter1 Ospfv3DeleteTopExternalPrefixRouteBlock -blockname block3   
    #array set stats [ospfRouter1 GetRouterStats]
    PutArray $fileName stats 
    PutFile $fileName "================================"
    PutFile $fileName "watching point 14"
    WaitKeyboardInput
    ospfRouter1 Ospfv3CreateTopGrid -StartingRouterID 133.1.1.1\
                                             -GridName  OspfGrid1 \
                                             -GridRows 4 \
                                             -GridColumns 4 \
                                             -ConnectedGridRows 2\
                                             -ConnectedGridColumns 3
    #array set GridConfig [ospfRouter1 GetTopGrid -gridname OspfGrid1]         
    PutArray $fileName GridConfig
    PutFile $fileName "================================"
    PutFile $fileName "watching point 15"
    WaitKeyboardInput
    ospfRouter1 Ospfv3DeleteTopGrid -gridname OspfGrid1
    PutFile $fileName "================================"
    PutFile $fileName "watching point 16"
    WaitKeyboardInput
    port1 StopRouter
    
    chassis1 CleanupTest
}  err ] } {
    #返回"脚本运行出错:$err"
    puts  "脚本运行出错:$err"
    chassis1 CleanupTest
}
   
