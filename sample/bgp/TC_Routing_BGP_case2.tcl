######################################################################
# ����Ŀ�ģ�����BGPЭ����湦��
#
# ����˵��:
#     STC��2���˿ڸ�����һ��BGP·���������·�ɳأ�����·�����桢�������𵴲��ԣ�����һ���˿ڷ���
#     ����Mpls VPN�����ô�VPN·�ɵ�
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
#�˿�����
set portList {1 2} ;#�˿ڵ�����˳����port1, port2, port3
###############################��ʼ������##############################

if { [catch {
     #����STC API Lib    
     cd ../Source
    #����HLAPI Lib
    source ./pkgIndex.tcl

   SetLogOption -Debug Enable

    #step1����ʼ���ӻ���
    TestDevice chassis1 $chassisAddr

    #step2����ʼԤ�������˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
    
    #����host ����
    port1 CreateHost -HostName host1 -IpVersion ipv4 -Ipv4Addr 1.1.1.5 -Ipv4AddrGateway 1.1.1.1  \
          -Ipv4AddrPrefixLen 24 -FlagPing enable
    
    #step3������·�ɶ���         
    port2 CreateRouter -RouterName bgproute1 -RouterType BgpV4Router -routerid 192.1.0.2
    
    #step4������·��
    bgproute1 BgpV4SetSession -PeerType EBGP -TesterIp 2.2.2.5 -PrefixLen 24 -TesterAs 1000 -SutIp 2.2.2.1 -SutAs 1001 -Active Enable
     
    #step5����ȡ·����Ϣ         
    bgproute1 BgpV4RetrieveRouter -PeerType PeerType -TesterIp TesterIp -PrefixLen PrefixLen -State State
    
    puts "PeerType:$PeerType,TesterIp:$TesterIp,PrefixLen:$PrefixLen,State:$State"
    
    bgproute1 BgpV4Enable
    #bgproute1 Disable
    
    bgproute1 BgpV4CreateRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.0 -PrefixLen 24 -RouteNum 1000 -Active enable \
              -AS_SEQUENCE yes  -NEXTHOP 2.2.2.5 -AS_PATH 1000
        
    #��������
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 1 -TrafficLoadUnit percent  
    traffic1 CreateStream -StreamName stream1 -FrameLen 256 -srcPoolName host1 -dstPoolName block1 -streamtype bgp

    #step11������Statistics1,Statistics2,Analysis2����
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    Statistics1 SetWorkingMode -PortStreamLevel FALSE
    puts "Start statistics engine"
    port1 StartStaEngine
    stc::perform saveasxml -filename "d:/temp/1.xml"
    #step11������·��
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
        #�ȴ�10s
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
