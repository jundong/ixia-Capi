######################################################################
# �ű�����:����LDPЭ����湦��
#
# ���ʱ��: 2007.6.19
#
#
# ��������:
#
#       �˿�a                                               �˿� b       
#    router1(10.10.10.10)--------------------------------> port2(10.10.10.20) 
#                                                   
#
# ���鲽��:
# 1.���ӻ���,Ԥ���忨��
# 2.����port
# 3.����router
# 4.����LDP router
# 5.����LspPool 
# 7.ʹ��LDP Router
# 8.���router״̬
#
# ��ע: ���ű�����API��ConfigRouter,GetRouter, GetRouterStats, GetRouterStatus, 
# Enable,Disable,                           
######################################################################
proc WaitKeyboardInput {} {
    puts "please press any 'a' to continue..."
    flush stdout
    set input [gets stdin]
    while {$input != "a"} {
        puts "please press any 'a' to continue..."
        after 10000
        set input [gets stdin]
    }
}

    #����Chassis�Ļ�������������IP��ַ���˿ڵ������ȵ�
set chassisAddr 10.98.3.12
set islot 7
set portList {1 2} ;#�˿ڵ�����˳����port1, port2

if { [catch {    
    
    cd ../Source
    #����HLAPI Lib
   source ./pkgIndex.tcl
    puts "START TESTING...."
 
    SetLogOption -Debug Enable

    # ��ʼ���ӻ���
    TestDevice chassis1 $chassisAddr
    chassis1 Connect  -IpAddr $chassisAddr

    # ��ʼԤ���˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
    
    port1 ConfigPort -LinkSpeed 10G -PortMode LAN  -DuplexMode FULL 
    port2 ConfigPort -LinkSpeed 10G -PortMode LAN -DuplexMode FULL 
    
    after 10000
    
    set port1linkspeed ""
    port1 GetPortState -LinkSpeed port1linkspeed   -linkState linkState_TC1 
    set port2linkspeed ""
    port2 GetPortState -LinkSpeed port2linkspeed  -linkState linkState_TC2 
    
    puts "port1linkspeed=$port1linkspeed port2linkspeed=$port2linkspeed, $linkState_TC1, $linkState_TC2"  
     #step4�����������������traffic1������traffic1���ԣ�����������stream1��stream2��stream3
    port1 CreateTraffic -TrafficName traffic1
    traffic1 CreateProfile -Name profile1 -TrafficLoad 10 -TrafficLoadUnit percent  
    traffic1 CreateStream -StreamName stream1 -FrameLen 256 -ProfileName profile1 \
        -L2 ethernet -EthDst 00:00:10:E1:00:08 -EthSrc 00:00:10:E1:00:09
    traffic1 CreateStream -StreamName stream2 -FrameLen 500 -ProfileName profile1 \
        -L2 ethernet -L3 IPv4 -L4 Udp -IpSrcIpAddr 192.168.0.1 -IpDstIpAddr 192.168.5.7 -udpsrcport 2000 -udpdstport 3000
    traffic1 ConfigStream -StreamName stream1 -L2 ethernet -L3 IPv4 -EthDst 00:00:10:E1:01:08 -EthSrc 00:00:11:E1:00:09
    traffic1 CreateStream -StreamName stream3 -FrameLen 500 -ProfileName profile1 \
        -L2 ethernet -L3 IPv4 -L4 Tcp -IpSrcIpAddr 192.168.0.1 -IpDstIpAddr 192.168.5.7 -tcpsrcport 2000 -tcpdstport 3000
        
    #step5������Statistics1,Statistics2,Analysis2����
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics
   
    port1 StartStaEngine
    port2 StartStaEngine

    #step6��������������
    port1 StartTraffic  -StreamNameList {stream1 stream2 stream3} 

    #step7���ȴ�5s��ʱ��
    after 5000
    
    #step8�����stream1��stream2����ͳ������
    array set stats31 [Statistics2 GetStreamStats -StreamName stream1] 
    parray  stats31
    array set stats41 [Statistics2 GetStreamStats -StreamName stream2] 
    parray  stats41
    
    after 1000 
    #step9��ֹͣ��������
    port1 StopTraffic
 
    #step10����ö˿�ͳ������
    array set stats1 [Statistics1 GetPortStats ]
    parray stats1
    
    array set stats2 [Statistics2 GetPortStats ]
    parray stats2
  
    chassis1 CleanupTest      
 }  err ] } {
    puts "�ű������г��ִ���: $err" 
    # ������ò��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                  
}