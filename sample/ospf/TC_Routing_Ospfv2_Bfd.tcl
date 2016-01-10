######################################################################
# ����Ŀ�ģ�����OspfЭ������ʱ��
#
# ����˵��: 
#     OSPF·����������
#���Բ���:
#1�����ݲ����������ӱ����豸DUT������Ǳ�
#2�������Ǻ��豸1��2��3�ڷֱ𹹽�OSPF·��Э��
#3��������B��C�ֱ���2��3������ͬ��������ͬ���ݵ�·�ɣ�����2Ϊ����·
#4�������Ƿ��ͺ���V pps������Ŀ�ĵ�ΪB��C������·�ɣ��������ȴ�2�ڷ���
#5�������������ȶ���ȷ��B�ڿ��Խ��յ����е���������ʱ�Ͽ�C�ڵ���·����Testcenter�ϲ�Ҫshutdown�˿ڣ�ֻ��ģ����·down�����������л���3�ڷ��͵�C��ֱ��Tʱ�̣�C���յ����ĵ�����ҲΪV pps������·������ʱ�伴ΪT
#     
# ����ʱ��: 2011.10.17
#
# �����ˣ�caimuyong
#
# �޸�˵����
#                                      
#######################################################################

####################�������������û�������Ҫ�������޸�#################
#�����ַ
set chassisAddr 10.61.32.92
#zqset islot 12
#zqset portList {3 4} ;#�˿ڵ�����˳����port1, port2
#��λ��
set islot 2
#�˿�����
set portList {1 2} ;#�˿ڵ�����˳����port1, port2, port3
set resolution 0.995
set routerWaitTime 10 ;#�ȴ�·����������·��ѧϰʵ��ʱ��
set beforeSwtichTime 10 ;#�ȴ�
set routeNum 100
set routeStart 2.3.0.1
set maxSwitchTime 20
set gSTCVersion 4.15
###############################��ʼ������##############################

if { [catch {

    #����HLAPI Lib
    source ./pkgIndex.tcl

    SetLogOption -Debug Enable

    #step1����ʼ���ӻ���
    TestDevice chassis1 $chassisAddr
    chassis1 ConfigResultOptions  -ResultViewMode JITTER

    #step2����ʼԤ�������˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType ethernet
    }
    
    #step3������host ����
    port1 CreateHost -HostName host1 -IpVersion ipv4 -Ipv4Addr 1.1.1.5 -Ipv4AddrGateway 1.1.1.1  \
          -Ipv4AddrPrefixLen 24 -FlagPing enable
    
    #step4������·�ɶ���         
    port2 CreateRouter -RouterName ospfRouter1 -routertype Ospfv2Router -routerId 2.1.0.2
    ospfRouter1 Ospfv2SetSession -ipaddr 2.2.2.5 -SutIpAddress 2.2.2.1 -abr true -networktype native
    ospfRouter1 Ospfv2SetBfd -RouterRole active -authentication none
    #step5������·��
    ospfRouter1 Ospfv2CreateSummaryLsa -LsaName lsasum -AdvertisingRouter 2.2.2.5 -PrefixLen 24 -FirstAddress 1.3.1.0 -NumAddress 100

    ospfRouter1 Ospfv2Enable
    
    #step6����������
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 1 -TrafficLoadUnit percent  
    traffic1 CreateStream -StreamName stream1 -FrameLen 256 -srcPoolName host1 -dstPoolName lsasum -streamType ospfv2

    #step7������Statistics1,Statistics2,Analysis2����
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
    puts "Start statistics engine"
    port1 StartStaEngine
    SaveConfigAsXML "d:/temp/1.xml"
    
    #step8������·��
    port2 StartRouter
    after [expr 1000*$routerWaitTime]
    
    #step9����������
    puts "Start stream transmission"
    port1 StartTraffic -FlagArp true
    after [expr 1000*$beforeSwtichTime]
    
    #step10��ֹͣ����
    port1 StopTraffic
    
    array set rate1 [Statistics1 GetPortStats]
    array set rate2 [Statistics2 GetPortStats]
    
    puts $rate1(-TxFrames)
    puts $rate2(-RxFrames)
    if {$rate1(-TxFrames) != $rate2(-RxFrames)} {
        error "�����ж���������!"
    }
    
    #step11��ֹͣ·��
    port2 StopRouter
    
    #step12��������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                                   
}  err ] } {
    #���ؽ��"�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 

    #������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                     
}
