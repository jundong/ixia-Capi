######################################################################
# Functionality: Test Layer 2 stream sending and analysis
#
# Create Time: 2010.3.17
#
#
# Topology:
#
#    Sending port                                                Receiving port        
#    port1<-------------------------------------------------------> port2  
#
# Description:
# Port1£¬Port2 of Spirent TestCenter connect 2 ports of DUT separately, and send the packets from port1
#                      £¨forward the packets using MAC address£©
# Requirements£ºCreate ETH type stream using CreatStream method
#       User-defined MAC address
#       
#       Frame 1£ºETHII +Customer £¨4Byte£©
#            frame length: 128
#       Frame2£ºETHII +IP Header
#            Frame Length:128 with user-defined IP address
#       Statistics£º
#       1.Get statistics on port basis
#       2.Get filtered statistics using Custom fields(should use filter functionality)
# 
# Test steps:
# 1.Create TestDevice object
# 2.Create TestPort object
# 3.Create TrafficEngine object
# 4.Config TrafficEngine parameters
# 5.Create Stream object
# 6.Create HeaderCreator object
# 7.Create pdu using the methods of HeaderCreator
# 8 Add pdu into stream
# 9.Configure analyze filter using CreateFilter
# 10.Start traffic transimission
# 11.Wait some period
# 12.Get the statistics result matching the filter
# 13.End the test
######################################################################

#Parameter configuration
set chassisAddr 172.16.174.137
set slotList {1 2}
set portList {1 1} ;#The port list is port1, port2
set ipList {10.0.0.3 20.0.0.3} 
set macList {00-00-00-00-00-01 00-00-00-00-00-02}

if { [catch {
    #cd "C:/Ixia/Workspace/ixia-Capi"
    lappend auto_path "C:/Ixia/Workspace/ixia-Capi"
    #Loading HLAPI Lib
    puts "Loading HLAPI Lib"
    #source ./pkgIndex.tcl
    package require IxiaCAPI

    SetLogOption -Debug Enable
    
    #Connect the chassis
    puts "Create TestDevice object"
    TestDevice chassis1 $chassisAddr

    #Reserve 2 ports
    puts "Reserve 2 ports"
    for {set i 0} {$i < [llength $slotList]} {incr i} {
        chassis1 CreateTestPort -PortLocation [lindex $slotList $i]/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }

    #Create stream on sender port
    puts "Create stream on sender port"
    port1 CreateTraffic -TrafficName traffic1
    #Configure traffic profile attribute
    puts "Configure traffic profile attribute"
    traffic1 CreateProfile -Name profile1 -TrafficLoad 50 -TrafficLoadUnit percent -FrameNum 1000 -BurstSize 10

    #Create stream1£¬and configure traffic profile
    puts "Create stream1£¬and configure traffic profile"
    traffic1 CreateStream -StreamName stream1 -FrameLen 128 -ProfileName profile1 
    #Create stream2£¬and configure traffic profile
    puts "Create stream2£¬and configure traffic profile"
    traffic1 CreateStream -StreamName stream2 -FrameLen 128 -ProfileName profile1 

    #Create HeaderCreator object
    puts "Create a HeaderCreator object"
    HeaderCreator Header1

    #Create Eth header
    puts "Create Eth header"
    Header1 CreateEthHeader -PduName  eth1 -DA [lindex $macList 1] -SA [lindex $macList 0] 
    #Create Ipv4 header
    puts "Create Ipv4 header"
    Header1 CreateIPV4Header -PduName ip -sourceIpAddr [lindex $ipList 0] -destIpAddr [lindex $ipList 1] -sourceIpMask 255.0.0.0 \
            -destIpMask 255.0.0.0 -destIpAddrMode fixed -sourceIpAddrMode fixed -qosMode tos -dscpMode default -precedence routine \
            -delay low  -throughput high -reliability high -identifier 0 -lastFragment last 

    #Create PacketBuilder object
    puts "Create PacketBuilder object"
    PacketBuilder pkt1
    #Create CustomPkt pdu
    puts "Create CustomPkt pdu"
    pkt1  CreateCustomPkt -PduName pduCustom -HexString "000aabb0"

    #Create Stream, and add pdu into the stream
    puts "Create Stream, and add pdu into the stream"
    stream1 AddPdu -PduName {eth1 ip}
    stream2 AddPdu -PduName {eth1 pduCustom}

    #Configure the filter on the receiver port
    puts "Configure the filter on the receiver port" 
    port2 CreateFilter -FilterName filter1 -FilterType UDF -FilterValue "{-pattern 0x000aabb0 -offset 14 -mask 0xFFFFFFFF}"
    
    #Create Statistics1 and Statistics2
    port1 CreateStaEngine -StaEngineName Statistics1 -StaType Statistics
    port2 CreateStaEngine -StaEngineName Statistics2 -StaType Statistics

    SaveConfigAsXML "C:/Tmp/test_stream.xml"

    #Start statistics engine
    puts "Start statistics engine"
    port1 StartStaEngine
    port2 StartStaEngine

    chassis1 BreakLinks -PortName port1
    chassis1 RestoreLinks -PortName port1
    #Start stream transmission
    puts "Start stream transmission"
    port1 StartTraffic  -StreamNameList {stream1 stream2} 

    #Wait 5 seconds
    puts "Wait 5s"
    after 1000

    #Stop traffic transmission on sender port
    puts "Stop traffic transmission on sender port"
    port1 StopTraffic

    #Get port statistics
    puts "Get port statistics"
    set stats1 [Statistics1 GetPortStats ]
    puts $stats1  
    set index [lsearch $stats1 -TxFrames]
    set txFrameNum [lindex $stats1 [expr $index + 1]]
    
    set stats2 [Statistics2 GetPortStats ]
    puts $stats2
    set index [lsearch $stats2 -RxFrames]
    set rxFrameNum1 [lindex $stats2 [expr $index + 1]]
   
    #Get filterd traffic statistics
    puts "Get filterd traffic statistics"
    set fiterStreamStats  [Statistics2 GetPortStats -FilteredStream]
    puts $fiterStreamStats
    set rxList [lindex $fiterStreamStats 0]
    set rxIndex [lsearch $rxList -RxFrames]
    if {$rxIndex != -1} {
        set rxFrameNum2 [lindex $rxList [expr $rxIndex + 1]]
    }
    puts "Filtered Received packets: $rxFrameNum2"

    if {$txFrameNum == $rxFrameNum1 && $txFrameNum == $rxFrameNum2} {
        puts "Test PASS"
    } {
        puts "Test FAIL"
    }
           
    #Clean up the test, and free associated resources
    puts "Test end"
    chassis1 CleanupTest                     
}  err ] } {
    puts "There is something error during the test: $err" 

    #Clean up the test, and free associated resources
    chassis1 CleanupTest                     
}
