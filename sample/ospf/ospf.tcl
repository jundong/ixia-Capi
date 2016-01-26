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
    port1 CreateRouter -RouterName ospfv2Router1  -RouterType ospfv2Router  -routerid 192.1.0.1 -FlagPing enable

    #step4������·��
    ospfv2Router1 Ospfv2SetSession -ipaddr 192.85.1.3 -SutIpAddress 192.85.1.11 -abr true -networktype native    
    ospfv2Router1 Ospfv2CreateSummaryLsa -LsaName test -advertisingrouter 192.85.1.3 -FirstAddress 1.1.1.1 -prefixlength 24 -NumAddress 2

    #step5��ʹ��BGP����Active                                                                                       
    ospfv2Router1 Ospfv2Enable

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
