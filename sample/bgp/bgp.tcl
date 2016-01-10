######################################################################
# ����Ŀ�ģ�����BGPЭ����湦��
#
# ����˵��:
#     STC��2���˿ڸ�����һ��BGP·���������·�ɳأ�����·�����桢�������𵴲��ԣ�
#     ����Mpls VPN�����ô�VPN·�ɵ�
#     
# ����ʱ��: 2010.3.17
#
# �����ˣ�yuanfen
#
# �޸�˵����
#                                      
#######################################################################

####################�������������û�������Ҫ�������޸�#################
#�����ַ
set chassisAddr 172.16.174.137
#��λ��
set islot {1}
set portList {1} ;#�˿ڵ�ֵ��port1
###############################��ʼ������##############################

if { [catch {    
    #cd ../Source
    lappend auto_path "C:/Ixia/Workspace/ixia-Capi"
    #����HLAPI Lib
    #source ./pkgIndex.tcl
    package require IxiaCAPI

    SetLogOption -Debug Enable
    
    # step1����ʼ���ӻ���
    TestDevice chassis1 $chassisAddr
    chassis1 Connect  -IpAddr $chassisAddr

    #step2����ʼԤ�������˿�
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation [lindex $islot $i]/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
      
    port1 ConfigPort -MediaType fiber

    #step3������·�ɶ���         
    port1 CreateRouter -RouterName bgproute1 -RouterType BgpV4Router -routerid 192.1.0.1 -FlagPing enable

    #step4������·��
    bgproute1 BgpV4SetSession -TesterIp 192.85.1.3 -TesterAs 1001 -SutIp 192.85.1.11 -SutAs 1001
     
    bgproute1 BgpV4CreateRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.0 -PrefixLen 32 -RouteNum 2 \
              -NEXTHOP 192.85.1.3 -AS_PATH {2 89}
    
    #step5��ʹ��BGP����Active                                                                                       
    bgproute1 BgpV4Enable

    #step6������·��
    port1 StartRouter

    #step7���ȴ�5��
    after 5000

    #step8��ֹͣ·��
    port1 StopRouter
    
    #step9��������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                                   
}  err ] } {
    #���ؽ��"�ű������г��ִ���: $err"
    puts "�ű������г��ִ���: $err" 

    #������Թ������������������ú��ͷŲ��Թ�����ռ�õ�������Դ
    chassis1 CleanupTest                     
}
