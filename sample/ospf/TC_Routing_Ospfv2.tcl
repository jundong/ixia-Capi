######################################################################
# ����Ŀ�ģ�����Ospfv2 API�Ĺ���
#
# ����˵��:
#     ����������STC��һ���˿���ģ��һ��·��������ѯospfv2 router���ھ�״ֱ̬��
#     Ϊfull���ڸ�·���������12������·�������ֱ����Ospfv2 Topo Link��Top Router
#     �������������summary route block������Route block���ӵ�Topo Router��
#     ͨ�泷��ȫ��������Topo Router��Topo Link��ͨ���鿴��Ļ��ӡ��Ϣ��GUI Port��
#     ģ���·������·�ɱ�������API���ܵ���ȷ��
#
# ����ʱ��: 2010.3.17
#
# �����ˣ�yuanfen
#
# �޸�˵����
#                                                                               
######################################################################

#�ú������ڵȴ���������'a',Ȼ�������������
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
#�ú������ڴ�����־�ļ�
proc CreateFile {fileName} {
  set fileId [open $fileName "w"]
  close $fileId
}
#�ú������ڽ���־��Ϣд����־�ļ��ʹ�ӡ����Ļ
proc PutFile {fileName msg} {
  set fileId [open $fileName "a"]
  
  puts $fileId $msg
  puts "$msg"
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
set slotId 11
#�˿�id
set portList {7 8}
set debug 0
set fileName d:/log.txt
###############################��ʼ������##############################
if { [catch {  
    CreateFile $fileName

    #����STC API Lib
    
    cd ../Source
    #����HLAPI Lib
    source ./pkgIndex.tcl

    SetLogOption -Debug Enable -LogTo stdout -FileName d:/log2.txt

    # step1��ʵ�����豸�����TestDevice
    PutFile $fileName " ʵ�����豸����� "
    TestDevice chassis1 $chassisAddr
    # step2�������˿������TestPort
    PutFile $fileName "�����˿������ "
       for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $slotId/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
        
    }

    #step3������Router�����ospf2 Router
    PutFile $fileName "����Router����� "
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
    
    #step4����ѯOspf�ھ�״̬��ֱ��Ϊfull  
    PutFile $fileName "��ѯOspf�ھ�״̬��ֱ��Ϊfull "
  # while {$state !="FULL"} {
      PutFile $fileName "==============="
      PutFile $fileName "state=$state"
      after 2000
      ospfRouter1 Ospfv2RetrieveRouter -state state
   #}

    PutFile $fileName "============================================="
    PutFile $fileName "���Ospfv2 Topo Router "
    #step5������Topo Router
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
   
    #step6������Link����֮ǰ������Topo Router ��������
    PutFile $fileName "============================================="
    PutFile $fileName "���Ospfv2 Topo Link����Top Router "
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
    PutFile $fileName "���Ospfv2 Topo Link����Top Router "
    ospfRouter1 Ospfv2CreateTopNetwork -NetworkName network1 -Subnetwork  100.0.0.0 -Prefix  24 -DrRouterName rtr9
    ospfRouter1 Ospfv2CreateTopRouterLink  -routername  rtr9  -LinkName  link9   -LinkType  nbma  -LinkConnectedName  network1  -LinkMetric  4  
    ospfRouter1 Ospfv2CreateTopRouterLink  -routername  rtr10  -LinkName  link10   -LinkType  nbma  -LinkConnectedName  network1  -LinkMetric  4 
    ospfRouter1 Ospfv2CreateTopRouterLink  -routername  rtr11  -LinkName  link11   -LinkType  nbma  -LinkConnectedName  network1  -LinkMetric  4 
    ospfRouter1 Ospfv2CreateTopRouterLink  -routername  rtr12  -LinkName  link12   -LinkType  nbma  -LinkConnectedName  network1  -LinkMetric  4 

    WaitKeyboardInput
  
    #step7������summary route block
    PutFile $fileName "============================================="
    PutFile $fileName "���Ospfv2 Topo Routes Block"

    ospfRouter1 Ospfv2CreateTopSummaryRouteBlock -blockname block1 -startingaddress 200.0.0.1 -prefix 25 -number 10 -modifier 3 
    ospfRouter1 Ospfv2SetTopSummaryRouteBlock -blockname block1 -startingaddress 200.0.0.1 -prefix 25 -number 10 -modifier 3 

    ospfRouter1 Ospfv2CreateTopExternalRouteBlock -blockname block2 -startingaddress 201.0.0.1 -prefix 23 -number 10 -modifier 3 
    WaitKeyboardInput
    #step8������Link����Route block���ӵ�Topo Router
    PutFile $fileName "��Routes Block���ӵ�Top Router"
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr4 -LinkName link13  -LinkConnectedName block1 -LinkMetric  10   
    ospfRouter1 Ospfv2CreateTopRouterLink -routername rtr8 -LinkName link14  -LinkConnectedName block2 -LinkMetric  10
    WaitKeyboardInput

    PutFile $fileName "============================================="
    PutFile $fileName "ͨ�� ȫ��Topo Router"
    #step9��ͨ��֮ǰ������Topo Router
    ospfRouter1 Ospfv2AdvertiseRouters -RouterNameList {ospfRouter1 rtr1 rtr2 rtr3 rtr4 rtr5 rtr6 rtr7 rtr8 rtr9 rtr10 rtr11 rtr12}

    PutFile $fileName "�������� Topo Router"
    WaitKeyboardInput
    #step10���������� Topo Router
    ospfRouter1 Ospfv2WithdrawRouters -RouterNameList {rtr1 rtr2 rtr3}
    PutFile $fileName "ͨ�� ����Topo Router"
    WaitKeyboardInput
    #step11��ͨ�沿��Topo Router
    ospfRouter1 Ospfv2AdvertiseRouters -RouterNameList {rtr1 rtr2 rtr3}
    WaitKeyboardInput

    PutFile $fileName "============================================="
    PutFile $fileName "ͨ�� ȫ��Topo Link"
    #step12��ͨ��ȫ��Topo Link
    ospfRouter1 Ospfv2AdvertiseLinks -LinkNameList {link1 link2 link3 link4 link5 link6 link7 link8 link9 link10 link11 link12 link13 link14 }
    WaitKeyboardInput
    PutFile $fileName "��������Topo Link"
    #step13����������Topo Link
    ospfRouter1 Ospfv2WithdrawLinks  -LinkNameList { link6 link7 link8 }
    WaitKeyboardInput
    PutFile $fileName "ͨ�� ����Topo Link"
    #step14��ͨ�沿��Topo Link
    ospfRouter1 Ospfv2AdvertiseLinks  -LinkNameList { link6 link7 link8 } 
    
    #step15��������ò��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest      
}  err ] } {   
    #��� "�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 
    # ������ò��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                  
}                  