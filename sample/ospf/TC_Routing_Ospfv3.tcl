######################################################################
# ����Ŀ�ģ�����Ospfv3 API�Ĺ���
#
# ����˵��:
#     ����������STC��һ���˿���ģ��һ��·�������ڸ�·�������������·��������
#     ��Ӳ�ͬ��Ospfv3 Topo Link�������ͽ�Top Router��������������5������·������
#     ���Ospfv3TopNetwork������5��·��������һ�����磻��������ɾ��Ospfv3
#     InterAreaRouteBlock��Ospfv3 ExternalRouteBlock������ɾ��TopGrid��ͨ���鿴
#     ��Ļ��ӡ��Ϣ��GUI Port��ģ���·������·�ɱ�������API���ܵ���ȷ�ԡ�
#
# ����ʱ��: 2010.3.17
#
# �����ˣ�yuanfen
#
# �޸�˵����
#                                                                               
###################################################################### 

#�ú������ڵȴ���������'a',Ȼ�������������
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
#�ú������ڴ�����־�ļ�
proc CreateFile {fileName} {
  set fileId [open $fileName "w"]
  close $fileId
}
#�ú������ڽ���־��Ϣд����־�ļ��ʹ�ӡ����Ļ
proc PutFile {fileName msg} {
  set fileId [open $fileName "a"]
  
  puts $fileId $msg
  puts $msg
  close $fileId
}
#�ú������ڽ�������Ϣд����־�ļ��ʹ�ӡ����Ļ
proc PutArray {fileName arg} {
     set fileId [open $fileName "a"]   
     foreach name [array names ::$arg] {
         puts $fileId "[subst $arg]([subst $name]) =  [subst $[subst ::[subst $arg]($name)]]"
         puts "[subst $arg]([subst $name]) =  [subst $[subst ::[subst $arg]($name)]]"
     }
     close $fileId
}       
                 
####################�������������û�������Ҫ�������޸�#################
#�����ַ
set chassisAddr 10.61.34.249
#zqset slotId 3
#��λ��
set slotId 12
#�˿�id
set portId 1
set debug 0
set fileName d:/Ospv3_log.txt
###############################��ʼ������############################## 

if { [catch {  
    CreateFile $fileName
    
    cd ../Source
    #����HLAPI Lib
    source ./pkgIndex.tcl

    if {$debug} {
        set hOptions [::stc::get system1 -children-AutomationOptions]
        stc::config $hOptions -LogTo stdout  -LogLevel INFO 
    }
    SetLogOption -Debug Enable -LogTo stdout -FileName d:/log2.txt

    #step1��ʵ�����豸�����
    PutFile $fileName " ʵ�����豸����� "
    TestDevice chassis1 $chassisAddr
    #step2�������˿������
    PutFile $fileName "�����˿������ "
    chassis1 CreateTestPort -PortLocation $slotId/$portId -PortName port1 -PortType Ethernet    
    #step3������Ospfv3 Router
    PutFile $fileName "����Ospfv3 Router "
    port1 CreateRouter -RouterName ospfRouter1 -routertype Ospfv3Router -routerId 1.1.1.2
    ospfRouter1 Ospfv3SetSession -ipaddr 3000::2  
    #-FlagNeighborDr 1
    #step4������Ospfv3 Э�����
    PutFile $fileName "����Ospfv3 Э����� "
    port1 StartRouter  
    set state ""
    ospfRouter1 Ospfv3RetrieveRouter -state state
   
    PutFile $fileName "================================"
    PutFile $fileName "watching point 1"
    #WaitKeyboardInput

    PutFile $fileName "================================"
    PutFile $fileName "watching point 2"

    #step5�����Ospfv3TopRouter
   if {1} {
    PutFile $fileName "���Ospfv3TopRouter 2"
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 11.0.0.1 -RouterTypeValue BBIT -RouterLsaName RouterLsa2 -RouterName ospfRtr2
    #array set router2Config [ospfRouter1 GetOspfTopRouter -RouterName ospfRtr2]
    PutArray $fileName router2Config
    PutFile $fileName "================================"
    PutFile $fileName "watching point 3"
    #WaitKeyboardInput
   }
   
    #step6�����Ospfv3TopRouter Link
    PutFile $fileName "���Ospfv3TopRouter Link "
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

    #step7��ɾ��Ospfv3TopRouterLink
    PutFile $fileName "ɾ��Ospfv3TopRouterLink "
    ospfRouter1 Ospfv3DeleteTopRouterLink -linkname link1 -RouterName ospfRtr2
    #array set router2Config [ospfRouter1 GetTopRouter -RouterName ospfRtr2]
    PutArray $fileName router2Config    
    PutFile $fileName "================================"
    PutFile $fileName "watching point 5"
    #WaitKeyboardInput
    #ɾ��Ospfv3TopRouter
    PutFile $fileName "ɾ��Ospfv3TopRouter "
    ospfRouter1 Ospfv3DeleteTopRouter -routername ospfRtr2
    PutFile $fileName "================================"
    PutFile $fileName "watching point 6"
    #WaitKeyboardInput

    #step8�����Ospfv3TopRouter
    PutFile $fileName "���Ospfv3TopRouter "
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.1 -RouterTypeValue BBIT  -RouterName ospfRtr1
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.2 -RouterTypeValue EBIT  -RouterName ospfRtr2
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.3 -RouterTypeValue VBIT  -RouterName ospfRtr3
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.4 -RouterTypeValue WBIT  -RouterName ospfRtr4
    ospfRouter1 Ospfv3CreateTopRouter -RouterId 13.0.0.5 -RouterTypeValue BBIT  -RouterName ospfRtr5
    #step9�����Ospfv3TopNetwork
    PutFile $fileName "���Ospfv3TopNetwork "
    ospfRouter1 Ospfv3CreateTopNetwork -networkname network1 -subnetwork 2000::1 -prefix 70 \
                                                   -ddroutername ospfRtr1 -ConnectedRouterNameList {ospfRtr1 ospfRtr2 ospfRtr3 ospfRtr4 ospfRtr5}
    #array set networkConfig [ospfRouter1 GetTopNetwork -networkName network1]
    PutArray $fileName networkConfig    
    PutFile $fileName "================================"
    PutFile $fileName "watching point 7"
    #WaitKeyboardInput
    #step10��ɾ��Opsfv3TopNetwork
    PutFile $fileName "ɾ��Opsfv3TopNetwork "
    ospfRouter1 Ospfv3DeleteTopNetwork -networkname network1
    PutFile $fileName "================================"
    PutFile $fileName "watching point 8"
    #WaitKeyboardInput

    #step11������Ospfv3 InterAreaRouteBlock
    PutFile $fileName "����Ospfv3 InterAreaRouteBlock "
    ospfRouter1 Ospfv3CreateTopInterAreaPrefixRouteBlock -blockname block1 -StartingAddress  3000::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1 -FlagLaBit  1
                                                                                  
    ospfRouter1 Ospfv3CreateTopInterAreaPrefixRouteBlock -blockname block2 -StartingAddress  3100::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1 -FlagLaBit  1                                                                                  

    #array set block1 [ospfRouter1 GetTopInterAreaPrefixRouteBlock -blockname block1]
    PutArray $fileName block1     
    PutFile $fileName "================================"
    PutFile $fileName "watching point 9"
    WaitKeyboardInput
    #step12������Ospfv3 InterAreaRouteBlock
    PutFile $fileName "����Ospfv3 InterAreaRouteBlock "
    ospfRouter1 Ospfv3SetTopInterAreaPrefixRouteBlock -blockname block1 -StartingAddress  4000::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1   
    #array set block1 [ospfRouter1 GetTopInterAreaPrefixRouteBlock -blockname block1]
    PutArray $fileName block1  
    PutFile $fileName "================================"
    PutFile $fileName "watching point 10"
    WaitKeyboardInput
    #step13��ɾ��Ospfv3 InterAreaRouteBlock
    PutFile $fileName "ɾ��Ospfv3 InterAreaRouteBlock "
    ospfRouter1 Ospfv3DeleteTopInterAreaPrefixRouteBlock -blockname block1
    PutFile $fileName "================================"
    PutFile $fileName "watching point "
    WaitKeyboardInput
    #step14������Ospfv3 ExternalRouteBlock
    PutFile $fileName "����Ospfv3 ExternalRouteBlock 11"
    ospfRouter1 Ospfv3CreateTopExternalPrefixRouteBlock -blockname block3 -StartingAddress  5000::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1 -FlagLaBit  1 \
                                                                                  -metric 2 -metrictype True -ForwardingAddress  5100::1\
                                                                                  -flagasbr 1 -ExternalRouteTag 3

    #array set block2 [ospfRouter1 GetTopExternalPrefixRouteBlock -blockname block2]
    PutArray $fileName block3     
    PutFile $fileName "================================"
    PutFile $fileName "watching point 12"
    WaitKeyboardInput
    #step15������Ospfv3 ExternalRouteBlock
    PutFile $fileName "����Ospfv3 ExternalRouteBlock "
    ospfRouter1 Ospfv3SetTopExternalPrefixRouteBlock -blockname block3 -StartingAddress  5200::1 -prefix 80 -number 10 -modifier 3\
                                                                                  -AdvertisingRouterId  14.0.0.1 -FlagPBit  1 -FlagNuBit  1 -FlagLaBit  1 \
                                                                                  -metric 2 -metrictype True -ForwardingAddress  5100::1\
                                                                                  -flagnssa 1 -ExternalRouteTag 5
                                                                                  
    #array set block2 [ospfRouter1 GetTopExternalPrefixRouteBlock -blockname block2]
    PutArray $fileName block3      
    PutFile $fileName "================================"
    PutFile $fileName "watching point 13"
    WaitKeyboardInput
    #step16��ɾ��Ospfv3 ExternalRouteBlock
    PutFile $fileName "ɾ��Ospfv3 ExternalRouteBlock "
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
    #����"�ű����г���:$err"
    puts  "�ű����г���:$err"
    chassis1 CleanupTest
}
   
