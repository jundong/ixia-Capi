######################################################################
# ����Ŀ�ģ�����OspfЭ������ʱ��
#
# ����˵��:
#     STC��2���˿ڸ�����һ��Ospf�����·�ɳأ�����·�����桢�������𵴲��ԣ�����һ���˿ڷ���
#
#     
# ����ʱ��: 2011.07.10
#
# �����ˣ�caimuyong
#
# �޸�˵����
#                                      
#######################################################################

####################�������������û�������Ҫ�������޸�#################
#�����ַ
set chassisAddr 10.61.34.249
#zqset islot 12
#zqset portList {3 4} ;#�˿ڵ�����˳����port1, port2
#��λ��
set islot 12
set islot2 12
#�˿�����
set portList {1 2} ;#�˿ڵ�����˳����port1, port2, port3
set portList2 {3} ;#�˿ڵ�����˳����port1, port2, port3
set resolution 0.995
set routerWaitTime 10 ;#�ȴ�·����������·��ѧϰʵ��ʱ��
set beforeSwtichTime 10 ;#�ȴ�
set routeNum 100
set routeStart 2.3.0.1
set maxSwitchTime 20
###############################��ʼ������##############################

if { [catch {

    #����HLAPI Lib
    cd ../Source
    source ./pkgIndex.tcl

   SetLogOption -Debug Enable

    #step1����ʼ���ӻ���
    TestDevice chassis1 $chassisAddr

    #step2����ʼԤ�������˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
    for {set i 0} {$i <[llength $portList2]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot2/[lindex $portList2 $i] -PortName port[expr $i+3] -PortType Ethernet
    }
    
    #����host ����
    port1 CreateHost -HostName host1 -IpVersion ipv4 -Ipv4Addr 1.1.1.5 -Ipv4AddrGateway 1.1.1.1  \
          -Ipv4AddrPrefixLen 24 -FlagPing enable
    
    #step3������·�ɶ���         
    port2 CreateRouter -RouterName ospfRouter1 -routertype Ospfv2Router -routerId 2.1.0.2
    ospfRouter1 Ospfv2SetSession -ipaddr 2.2.2.5 -SutIpAddress 2.2.2.1 -abr true -networktype native
    
    #step4������·��
    ospfRouter1 Ospfv2CreateSummaryLsa -LsaName lsasum -AdvertisingRouter 2.2.2.5 -PrefixLen 24 -FirstAddress 1.3.1.0 -NumAddress 100

    ospfRouter1 Ospfv2Enable
    
    #step5������·�ɶ���         
    port3 CreateRouter -RouterName ospfRouter2 -routertype Ospfv2Router -routerId 192.1.0.1
    ospfRouter2 Ospfv2SetSession -ipaddr 3.3.3.5 -SutIpAddress 3.3.3.1 -abr true -networktype native
    
    #step6������·��
    ospfRouter2 Ospfv2CreateSummaryLsa -LsaName lsasum -AdvertisingRouter 3.3.3.5 -PrefixLen 24 -FirstAddress 1.3.1.0 -NumAddress 100 -metric 10

    ospfRouter2 Ospfv2Enable
    
    #��������
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 1 -TrafficLoadUnit percent  
    traffic1 CreateStream -StreamName stream1 -FrameLen 256 -srcPoolName host1 -dstPoolName lsasum -streamType ospfv2

    #step11������Statistics1,Statistics2,Analysis2����
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    port3 CreateStaEngine -StaEngineName Statistics3 -StaType Statistics
    Statistics1 SetWorkingMode -PortStreamLevel FALSE
    puts "Start statistics engine"
    port1 StartStaEngine
    stc::perform saveasxml -filename "d:/temp/1.xml"
    
    #step11������·��
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
        error "������������Ϊ0,��������"
    }
    set startTime [clock seconds]
    while {[expr $rate2(-RxRateFrames)/$rate1(-TxRateFrames)] < $resolution} {
        after 1000
        set nowTime [clock seconds]
        if {[expr [expr $nowTime-$startTime] > $maxSwitchTime]} {
            error "�����ȴ�ʱ�䳬������л�ʱ��û��Ԥ��״̬,��������"
        }
    }
     
    #�Ͽ��˿�2����,�������л����˿�3
    port2 BreakLink
    
    #�����л�ʱ��
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
        puts "����ʱ��Ϊ $converTime ��"
    } else {
        puts "����ʱ�䳬������л�ʱ��"
    }
     
    port1 StopTraffic
     
    #step13��ֹͣ·��
    port2 StopRouter
    
    #step14��������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                                   
}  err ] } {
    #���ؽ��"�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 

    #������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                     
}
