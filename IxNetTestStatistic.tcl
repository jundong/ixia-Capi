package provide IxiaCapi_TestStatistic 1.0

# TestStatistic.tcl --
#   This file implements the TestStatistic class for the highlevel CAPI of N2X device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1
# Version 1.2
#   1. modify TestAnalysis
#   2. modify GetPortStats to adjust H3C API interface

namespace eval IxiaCapi {
    
    class TestStatistic {
        
        constructor { portHandle } {}
        private method GetStats { args } {}
        method GetPortStats { args } {}
        method GetStreamStats_old { args } {}
		method GetStreamStats { args } {}
		method SetPortName { name } {
		    set statPortName $name
		}
        method destructor {}
        
        private variable hPort
		private variable statPortName
        
        public variable portView
        public variable flowView
		public variable ItemView
		public variable dataPortview
		
        
        public variable portStatsList
        public variable streamStatsList
        
    }
    
    body TestStatistic::constructor { portHandle } {
        global errorInfo
        
        set tag "body TestStatistics::Ctor [info script]"
        Deputs "----- TAG: $tag -----"
        
        set strObjList [ list ]
        set hPort $portHandle
        set portView {::ixNet::OBJ-/statistics/view:"Port Statistics"}
		set dataPortview {::ixNet::OBJ-/statistics/view:"Data Plane Port Statistics"}
        set flowView {::ixNet::OBJ-/statistics/view:"Flow Statistics"}
		set ItemView {::ixNet::OBJ-/statistics/view:"Traffic Item Statistics"}
    }
    
    body TestStatistic::GetPortStats { args } {
        global errorInfo
        
        set tag "body TestStatistics::GetPortStats [info script]"
        Deputs "----- TAG: $tag -----"
        
        set retStats [list ]
        # param collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -txframes {
                    set TxFrames $value
                }
                -rxframes {
                    set RxFrames $value
                }
                -txbytes {
                    set TxBytes $value
                }
                -rxbytes {
                    set RxBytes $value
                }
                -txsignature {
                    set TxSignature $value
                }
                -rxsignature {
                    set RxSignature $value
                }
                -txipv4frames {
                    set TxIpv4Frames $value
                }
                -rxipv4frames {
                    set RxIpv4Frames $value
                }
                -txipv6frames {
                    set TxIpv6Frames $value
                }
                -rxipv6frames {
                    set RxIpv6Frames $value
                }
                -rxmplsframes {
                    set RxMplsFrames $value
                }
                -rxmplssignature {
                    set RxMplsSignature $value
                }
                -txvlanframes -
                -txstackframes {
                    set TxStackFrames $value
                }
                -rxvlanframes -
                -rxstackframes {
                    set RxStackFrames $value
                }
                -crcerrors {
                    set CrcErrors $value
                }
                -oversize {
                    set OverSize $value
                }
                -fragorundersize {
                    set FragOrUndersize $value
                }
                -txarpreplies {
                    set TxArpReplies $value
                }
                -rxarpreplies {
                    set RxArpReplies $value
                }
                -txarprequests {
                    set TxArpRequests $value
                }
                -rxarprequests {
                    set RxArpRequests $value
                }
                -rxjumboframes {
                    set RxJumboFrames $value
                }
                -rxicmpv4dstunreachable {
                    set RxIcmpv4DstUnreachable $value
                }
                -rxicmpv6dstunreachable {
                    set RxIcmpv6DstUnreachable $value
                }
                -rxipv4chesumerror {
                    set RxIpv4chesumError $value
                }
                -rxrateframes {
                    set RxRateFrames $value
                }
                -rxratebytes {
                    set RxRateBytes $value
                }
                -txrateframes {
                    set TxRateFrames $value
                }
                -txratebytes {
                    set TxRateBytes $value
                }
                -packetloss {
                    set PacketLoss $value
                }
                -averagelatency {
                    set AverageLantency $value
                }
                -filtername {
                }
                -filteredstream {
                    set FilteredStream $value
                }
            }
        }
        if { $hPort == [ixNet getNull] } {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TestStatisticGetStats5" -tag $tag
            return $IxiaCapi::errorcode(4)
        }
        # Get acuumulated value
        set statistics  [ ixNet getA $portView/page -columnCaptions ]
	
		set datastatistics  [ ixNet getA $dataPortview/page -columnCaptions ]
        Deputs "stats:$statistics"
        Deputs "data stats:$datastatistics"
        # Port Information
        set portInfo [ixNet getA $hPort -connectionInfo]
        regexp {chassis=\"([\d\.]+)\"} $portInfo match chassis
        #Deputs "chassis:$chassis"
        regexp {card=\"([\d]+)\"} $portInfo match card
        #Deputs "card:$card"
        regexp {port=\"([\d]+)\"} $portInfo match port
        #Deputs "port:$port"
        if { [ string length $card ] == 1 } {
            set card 0$card
        }
        if { [ string length $port ] == 1 } {
            set port 0$port
        }
        set portName $chassis/Card$card/Port$port
        # Get port information
        set portInfoIndex [ lsearch -exact $statistics {Stat Name} ]
        Deputs "portInfoIndex:$portInfoIndex"
        set resultList [ ixNet getA $portView/page -rowValues ]
        set resultIndex 0
        set portFound   0
        foreach result $resultList {
            set statName [ eval lindex $result $portInfoIndex ]
            #Deputs "stat name:$statName == $portName"
            if { $statName == $portName } {
                set portFound 1
                break
            }
            incr resultIndex
        }
        if { $portFound } {
            eval set result [lindex $resultList $resultIndex]
        } else {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TestStatisticGetStats6" -tag $tag
            return $IxiaCapi::errorcode(4)            
        }
        Deputs "Accumulated value:$result"
        foreach caption $statistics {
            set index [ lsearch -exact $statistics $caption ]
            set value [ lindex $result $index ]
            
            if { $caption == "Frames Tx." } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -TxFrames
                lappend retStats $value
                
                if { [ info exists TxFrames ] } {
                    uplevel 1 "set $TxFrames $value"
                }
            } elseif { $caption == "Valid Frames Rx." } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                puts "Valid Frames Rx.: $value"
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -RxFrames
                lappend retStats $value
                
                if { [ info exists RxFrames ] } {
                    uplevel 1 "set $RxFrames $value"
                }
            } elseif { $caption == "Bytes Tx." } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -TxBytes
                lappend retStats $value
                
                if { [ info exists TxBytes ] } {
                    uplevel 1 "set $TxBytes $value"
                }
            } elseif { $caption == "Bytes Rx." } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -RxBytes
                lappend retStats $value
                
                if { [ info exists RxBytes ] } {
                    uplevel 1 "set $RxBytes $value"
                }
            } elseif { $caption == "Frames Rx." } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -TxSignature
                lappend retStats $value
                
                if { [ info exists TxSignature ] } {
                    uplevel 1 "set $TxSignature $value"
                }
            } elseif { $caption == "CRC Errors" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -CrcErrors
                lappend retStats $value
                
                if { [ info exists CrcErrors ] } {
                    uplevel 1 "set $CrcErrors $value"
                }
            } elseif { $caption == "Oversize" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -OverSize
                lappend retStats $value
                
                if { [ info exists OverSize ] } {
                    uplevel 1 "set $OverSize $value"
                }
            } elseif { $caption == "Undersize" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -FragOrUndersize
                lappend retStats $value
                
                if { [ info exists FragOrUndersize ] } {
                    uplevel 1 "set $FragOrUndersize $value"
                }
            } elseif { $caption == "Transmit Arp Reply" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -TxArpReplies
                lappend retStats $value
                
                if { [ info exists TxArpReplies ] } {
                    uplevel 1 "set $TxArpReplies $value"
                }
            } elseif { $caption == "Receive Arp Reply" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -RxArpReplies
                lappend retStats $value
                
                if { [ info exists RxArpReplies ] } {
                    uplevel 1 "set $RxArpReplies $value"
                }
            } elseif { $caption == "Transmit Arp Request" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -TxArpRequests
                lappend retStats $value
                
                if { [ info exists TxArpRequests ] } {
                    uplevel 1 "set $TxArpRequests $value"
                }
            } elseif { $caption == "Receive Arp Request" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -RxArpRequests
                lappend retStats $value
                
                if { [ info exists RxArpRequests ] } {
                    uplevel 1 "set $RxArpRequests $value"
                }
            } elseif { $caption == "Undersize" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -RxJumboFrames
                lappend retStats $value
                
                if { [ info exists RxJumboFrames ] } {
                    uplevel 1 "set $RxJumboFrames $value"
                }
            } elseif { $caption == "Valid Frames Rx. Rate" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -RxRateFrames
                lappend retStats $value
                
                if { [ info exists RxRateFrames ] } {
                    uplevel 1 "set $RxRateFrames $value"
                }
            } elseif { $caption == "Bytes Rx. Rate" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -RxRateBytes
                lappend retStats $value
                
                if { [ info exists RxRateBytes ] } {
                    uplevel 1 "set $RxRateBytes $value"
                }
            } elseif { $caption == "Frames Tx. Rate" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -TxRateFrames
                lappend retStats $value
                
                if { [ info exists TxRateFrames ] } {
                    uplevel 1 "set $TxRateFrames $value"
                }
            } elseif { $caption == "Bytes Tx. Rate" } {
                set value [ IxiaCapi::Regexer::IntTrans $value ]
                if { [ string is double $value ] == 0 || $value == ""} {
                    set value 0
                }
                
                lappend retStats -TxRateBytes
                lappend retStats $value
                
                if { [ info exists TxRateBytes ] } {
                    uplevel 1 "set $TxRateBytes $value"
                }
            }
        }
        
        if { [ info exists TxStackFrames ] } {
            uplevel 1 "set $TxStackFrames NAN"
        }
        lappend retStats -TxStackFrames
        lappend retStats "NAN"
        
        if { [ info exists RxStackFrames ] } {
            uplevel 1 "set $RxStackFrames NAN"
        }
        lappend retStats -RxStackFrames
        lappend retStats "NAN"
        
        if { [ info exists PacketLoss ] } {
            uplevel 1 "set $PacketLoss NAN"
        }
        lappend retStats -PacketLoss
        lappend retStats "NAN"
        
        if { [ info exists FilterName1 ] } {
            uplevel 1 "set $FilterName1 NAN"
        }
        lappend retStats -FilterName1
        lappend retStats "NAN"
        
        if { [ info exists FilterName2 ] } {
            uplevel 1 "set $FilterName2 NAN"
        }
        lappend retStats -FilterName2
        lappend retStats "NAN"
        
        if { [ info exists FilterName11 ] } {
            uplevel 1 "set $FilterName11 NAN"
        }
        lappend retStats -FilterName11
        lappend retStats "NAN"
        
        if { [ info exists FilterName22 ] } {
            uplevel 1 "set $FilterName22 NAN"
        }
        lappend retStats -FilterName22
        lappend retStats "NAN"
        
        if { [ info exists AverageLantency ] } {
            uplevel 1 "set $AverageLantency NAN"
        }
        lappend retStats -AverageLantency
        lappend retStats "NAN"
        
        if { [ info exists RxIcmpv4DstUnreachable ] } {
            uplevel 1 "set $RxIcmpv4DstUnreachable NAN"
        }
        lappend retStats -RxIcmpv4DstUnreachable
        lappend retStats "NAN"
        
        if { [ info exists RxIcmpv6DstUnreachable ] } {
            uplevel 1 "set $RxIcmpv6DstUnreachable NAN"
        }
        lappend retStats -RxIcmpv6DstUnreachable
        lappend retStats "NAN"
        
        if { [ info exists RxIpv4chesumError ] } {
            uplevel 1 "set $RxIpv4chesumError NAN"
        }
        lappend retStats -RxIpv4chesumError
        lappend retStats "NAN"
        
        if { [ info exists TxIpv4Frames ] } {
            uplevel 1 "set $TxIpv4Frames NAN"
        }
        lappend retStats -TxIpv4Frames
        lappend retStats "NAN"
        
        if { [ info exists RxIpv4Frames ] } {
            uplevel 1 "set $RxIpv4Frames NAN"
        }
        lappend retStats -RxIpv4Frames
        lappend retStats "NAN"
        
        if { [ info exists TxIpv6Frames ] } {
            uplevel 1 "set $TxIpv6Frames NAN"
        }
        lappend retStats -TxIpv6Frames
        lappend retStats "NAN"
        
        if { [ info exists RxIpv6Frames ] } {
            uplevel 1 "set $RxIpv6Frames NAN"
        }
        lappend retStats -RxIpv6Frames
        lappend retStats "NAN"
        
        if { [ info exists RxMplsFrames ] } {
            uplevel 1 "set $RxMplsFrames NAN"
        }
        lappend retStats -RxMplsFrames
        lappend retStats "NAN"
        
        if { [ info exists RxMplsSignature ] } {
            uplevel 1 "set $RxMplsSignature NAN"
        }
        lappend retStats -RxMplsSignature
        lappend retStats "NAN"
            
		set dataresultList [ ixNet getA $dataPortview/page -rowValues ]
		set rx_port        [ lsearch -exact $datastatistics Port]
		set resultIndex 0
        set portFound   0
        foreach dataresult $dataresultList {
		    eval {set dataresult} $dataresult		    
		    set a [ lindex $dataresult $rx_port ] 
		    if { $statPortName != [ lindex $dataresult $rx_port ] } {
			    continue
		    }
            
            set index [ lsearch -exact $datastatistics {Rx Frames}  ]				
            set value [ lindex $dataresult $index ]
            set value [ IxiaCapi::Regexer::IntTrans $value ]
            if { [ string is double $value ] == 0 || $value == ""} {
                set value 0
            }
            if { [ info exists RxSignature ] } {
				uplevel 1 "set $RxSignature $value"
		    } 
            lappend retStats -RxSignature
            lappend retStats $value	
		}
        
        if { [ info exists FilteredStream ] } {
            return [list $retStats]
        }

        return $retStats
    }

	body TestStatistic::GetStreamStats { args } {
        global errorInfo
        
        set tag "body TestStatistics::GetStreamStats [info script]"
        Deputs "----- TAG: $tag -----"
        
        set retStats [list ]
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -statshandle -
                -stats {
                    set hStats $value
                }
                -name -
                -streamname {
				    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
                }
                -txframes {
                    Deputs "txframes var:$value"
                    set TxFrames $value
                }
                -rxframes {
                    Deputs "rxframes var:$value"
                    set RxFrames $value
                }
                -txbytes {
                    set TxBytes $value
                }
                -rxbytes {
                    set RxBytes $value
                }
                -txsignature {
                    set TxSignature $value
                }
                -rxsignature {
                    set RxSignature $value
                }
                -txipv4frames {
                    set TxIpv4Frames $value
                }
                -rxipv4frames {
                    set RxIpv4Frames $value
                }
                -txipv6frames {
                    set TxIpv6Frames $value
                }
                -rxipv6frames {
                    set RxIpv6Frames $value
                }
                -rxmplsframes {
                    set RxMplsFrames $value
                }
                -rxmplssignature {
                    set RxMplsSignature $value
                }
                -txvlanframes -
                -txstackframes {
                    set TxStackFrames $value
                }
                -rxvlanframes -
                -rxstackframes {
                    set RxStackFrames $value
                }
                -crcerrors {
                    set CrcErrors $value
                }
                -oversize {
                    set OverSize $value
                }
                -fragorundersize {
                    set FragOrUndersize $value
                }
                -txarpreplies {
                    set TxArpReplies $value
                }
                -rxarpreplies {
                    set RxArpReplies $value
                }
                -txarprequests {
                    set TxArpRequests $value
                }
                -rxarprequests {
                    set RxArpRequests $value
                }
                -rxjumboframes {
                    set RxJumboFrames $value
                }
                -rxicmpv4dstunreachable {
                    set RxIcmpv4DstUnreachable $value
                }
                -rxicmpv6dstunreachable {
                    set RxIcmpv6DstUnreachable $value
                }
                -rxipv4chesumerror {
                    set RxIpv4chesumError $value
                }
                -rxrateframes {
                    set RxRateFrames $value
                }
                -rxratebytes {
                    set RxRateBytes $value
                }
                -txrateframes {
                    set TxRateFrames $value
                }
                -txratebytes {
                    set TxRateBytes $value
                }
                -packetloss {
                    set PacketLoss $value
                }
                -averagelatency {
                    set AverageLantency $value
                }
            }
        }

        set statistics [ ixNet getA $flowView/page -columnCaptions ]
		set flowInfoIndex [ lsearch -exact $statistics {Traffic Item} ]
        set RxportInfoIndex [ lsearch -exact $statistics {Rx Port} ]
		set TxportInfoIndex  [ lsearch -exact $statistics {Tx Port} ]
        set resultList [ ixNet getA $flowView/page -rowValues ]
		
        set resultIndex 0
        set flowFound   0
        # Port Information
        #Tx port check
        foreach result $resultList {
            set statName [ eval lindex $result $flowInfoIndex ]
			set txportName [eval lindex $result $TxportInfoIndex ]
            
            if {  $statName == $name && $txportName == $statPortName  } {
                set flowFound 1
                break
            }
            incr resultIndex
        }
        if { $flowFound } {
            eval set result [lindex $resultList $resultIndex]
            Deputs "Accumulated value:$result"
            foreach caption $statistics {
                set index [ lsearch -exact $statistics $caption ]
                set value [ lindex $result $index ]
                if { $caption == "Tx Frames" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }

                    lappend retStats -TxFrames
                    lappend retStats $value
                
                    if { [ info exists TxFrames ] } {
                        uplevel 1 "set $TxFrames $value"
                    }
                    
                    lappend retStats -TxSignature
                    lappend retStats $value
                
                    if { [ info exists TxSignature ] } {
                        uplevel 1 "set $TxSignature $value"
                    }
                } elseif { $caption == "Tx Frame Rate" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }

                    lappend retStats -TxRateFrames
                    lappend retStats $value
                
                    if { [ info exists TxRateFrames ] } {
                        uplevel 1 "set $TxRateFrames $value"
                    }                    
                } elseif { $caption == "Tx Rate (Bps)" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }
s
                    lappend retStats -TxRateBytes
                    lappend retStats $value
                
                    if { [ info exists TxRateBytes ] } {
                        uplevel 1 "set $TxRateBytes $value"
                    }                    
               }
            }
		}
        
        if { [ info exists TxBytes ] } {
            lappend retStats -TxBytes
            lappend retStats $value
        
            if { [ info exists TxBytes ] } {
                uplevel 1 "set $TxBytes NAN"
            }
        }
        
		set resultIndex 0
        set flowFound   0
        # Port Information
        #Rx port check
        foreach result $resultList {
            set statName [ eval lindex $result $flowInfoIndex ]
			set rxportName [eval lindex $result $RxportInfoIndex ]
            
            if {  $statName == $name && $rxportName == $statPortName  } {
                set flowFound 1
                break
            }
            incr resultIndex
        }
        if { $flowFound } {
            eval set result [lindex $resultList $resultIndex]
            Deputs "Accumulated value:$result"
            foreach caption $statistics {
                set index [ lsearch -exact $statistics $caption ]
                set value [ lindex $result $index ]
            
                if { $caption == "Rx Frames" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }
                    
                    lappend retStats -RxFrames
                    lappend retStats $value
                
                    if { [ info exists RxFrames ] } {
                        uplevel 1 "set $RxFrames $value"
                    }
                } elseif { $caption == "Rx Bytes" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }

                    lappend retStats -RxBytes
                    lappend retStats $value
                
                    if { [ info exists RxBytes ] } {
                        uplevel 1 "set $RxBytes $value"
                    }
                } elseif { $caption == "Rx Frames" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }
                    
                    lappend retStats -RxSignature
                    lappend retStats $value
                
                    if { [ info exists RxSignature ] } {
                        uplevel 1 "set $RxSignature $value"
                    }
                } elseif { $caption == "Rx Frame Rate" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }

                    lappend retStats -RxRateFrames
                    lappend retStats $value
                
                    if { [ info exists RxRateFrames ] } {
                        uplevel 1 "set $RxRateFrames $value"
                    }
                } elseif { $caption == "Rx Rate (Bps)" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }

                    lappend retStats -RxRateBytes
                    lappend retStats $value
                
                    if { [ info exists RxRateBytes ] } {
                        uplevel 1 "set $RxRateBytes $value"
                    }
                } elseif { $caption == "Frames Delta" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }

                    lappend retStats -PacketLoss
                    lappend retStats $value
                
                    if { [ info exists PacketLoss ] } {
                        uplevel 1 "set $PacketLoss $value"
                    }
                } elseif { $caption == "Store-Forward Avg Latency (ns)" } {
                    set value [ IxiaCapi::Regexer::IntTrans $value ]
                    if { [ string is double $value ] == 0 || $value == ""} {
                        set value 0
                    }

                    lappend retStats -AverageLantency
                    lappend retStats $value
                
                    if { [ info exists AverageLantency ] } {
                        uplevel 1 "set $AverageLantency $value"
                    }
                }
            }
		}
                
        return $retStats
    }
    
    body TestStatistic::destructor {} {
	    set tag "body TestStatistics::Destructor [info script]"
        Deputs "----- TAG: $tag -----"
    }
    
    class TestAnalysis {
        constructor { portHandle } {}
        destructor {}
        method SetPortName { name } {
		    set statPortName $name
		}        
		
        method StartCapture { args } {}
        method StopCapture { args } {}
        method ConfigCaptureMode { args } {}
        method GetCapturePacket { args } {}
		method GetAllContent {} {
		
		    set tag "body Capture::GetAllContent [info script]"
Deputs "----- TAG: $tag -----"
            
			set hcontent [list]
			
		    set portInfo [ixNet getA $hPort -connectionInfo]
 #--chassis="10.137.144.57" card="9" port="3" portip="10.0.9.3"
		    regexp {chassis=([0-9\.\"]+) card=([\"0-9]+) port=([\"0-9]+)} $portInfo match chas card port
Deputs "chas:$chas card:$card port:$port"
		    set rsConnectToOS [ ixConnectToChassis $chas ]
Deputs "result connecting to OS:$rsConnectToOS"
		    set chasId	[ chassis cget -id ]
Deputs "capture get on $chasId $card $port"
		
		    set readPortRes [ eval port get $chasId $card $port ]
Deputs "read port result:$readPortRes"		
		    set owner [port cget -owner]
Deputs "owner:$owner"		

		# Login before taking ownership
		    ixLogin $owner
		# Take ownership of the ports we’ll use
		    set portList [ list [ eval list $chasId $card $port ] ]
Deputs "portList:$portList"		
		    ixTakeOwnership $portList

		    set rsGetCap [ eval capture get $chasId $card $port ]
Deputs "result get capture: $rsGetCap"
		    set pktCnt [ capture cget -nPackets ]
Deputs "pkt count:$pktCnt"

		    set err ""
		    if { $pktCnt == 0 } {
			    
				IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TestAnalysisGetCapturePacket10" -tag $tag
		    }
			if { $pktCnt > 1000 } {
				set pktCntRange 1000
			} else {
			    set pktCntRange $pktCnt
			}

		    if { $err == "" } {
			    set rsGetBuffer [ eval captureBuffer get $chasId $card $port 1 $pktCntRange ]
	Deputs "result get buffer:$rsGetBuffer"
			    for { set packet_index 1 } { $packet_index <= $pktCntRange } { incr packet_index } {
				    set rsGetFrame [ captureBuffer getframe $packet_index ]
	#Deputs "result get frame:$rsGetFrame"
				    set hex [ captureBuffer cget -frame ]
				    lappend hcontent $hex
	# Deputs "hex:$hex"
			    }
		    }
			return $pktCnt
		    
		}

        private variable hPort
        private variable Mode
        private variable SavePath
        private variable hSave
        private variable hPacketSet
        private variable hPacketIndex
        private variable FilterName
        private variable statPortName
		public variable hcontent 
        public variable state
		
    }
    

    body TestAnalysis::constructor { portHandle } {
        global errorInfo
        
        set tag "body TestAnalysis::Ctor [info script]"
Deputs "----- TAG: $tag -----"
        set CaptureFile ""
		set FilterName  ""
		set hcontent [list]
		set SavePath $IxiaCapi::gSavePath
		
        
        if { [ catch {
            set hPort $portHandle
            ixNet setA $portHandle -rxMode captureAndMeasure
            #ixNet setA $portHandle/capture -softwareEnabled True
            ixNet setA $portHandle/capture -hardwareEnabled True
            ixNet commit
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TestAnalysisCtor2 $errorInfo" -tag $tag
        } else {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestAnalysisCtor1"            
        }
        set state 0
    }
    
    body TestAnalysis::destructor {} {
	    set hcontent [list]
        ixNet setA $hPort/capture -softwareEnabled False
		ixNet setA $hPort/capture -hardwareEnabled False
        ixNet commit
    }
    
    body TestAnalysis::StartCapture {} {
        global errorInfo
        global IxiaCapi::success IxiaCapi::fail
		set hcontent [list]
        set tag "body TestAnalysis::StartCapture [info script]"
Deputs "----- TAG: $tag -----"

        if { [ catch {
Deputs "Port rx mode on $hPort : [ ixNet getA $hPort -rxMode ]"	
            if { [ ixNet getA $hPort -rxMode ] != "captureAndMeasure" } {
			    ixNet setA $hPort -rxMode capture
		        ixNet commit
		    }
			while { [ixNet getA $hPort -state] != "up" } {
			    after 1000
		    }
			ixNet exec closeAllTabs
Deputs "start capture..."
            ixNet exec start $hPort/capture
            set state 1
            } ]
        } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestAnalysisStartCapture2"
                    return $IxiaCapi::errorcode(7)
        } else {
            after 2000
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestAnalysisStartCapture1"
                    return $IxiaCapi::errorcode(0)
        }
    }
    
    body TestAnalysis::StopCapture {} {
        global errorInfo
        set tag "body TestAnalysis::StopCapture [info script]"
Deputs "----- TAG: $tag -----"
# Stop the engine                
        if { [ catch {
            ixNet exec stop $hPort/capture
            after 5000
            set state 0
        } ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestAnalysisStopCapture2"
            return $IxiaCapi::errorcode(7)                        
        }
        if { [ catch {
            if { [ info exists SavePath ] && $SavePath != "" } {
Deputs "path:$SavePath\tporthandle:$hPort"
                set dir     [ file dirname $SavePath ]
                set file    [ file tail $SavePath ]
                catch {
                    #ixNet exec saveCapture $dir
                    
                    set portInfo [ixNet getA $hPort -connectionInfo]
 
		            regexp {chassis=([0-9\.\"]+) card=([\"0-9]+) port=([\"0-9]+)} $portInfo match chas card port
Deputs "chas:$chas card:$card port:$port"

		            set rsConnectToOS [ ixConnectToChassis $chas ]
Deputs "result connecting to OS:$rsConnectToOS"
		            set chasId	[ chassis cget -id ]
Deputs "capture get on $chasId $card $port"
		
		            set readPortRes [ eval port get $chasId $card $port ]	
		            set owner [port cget -owner]

		# Login before taking ownership
		            ixLogin $owner
		# Take ownership of the ports we’ll use
		            set portList [ list [ eval list $chasId $card $port ] ]	
		            ixTakeOwnership $portList
		            set rsGetCap [ eval capture get $chasId $card $port ]
		            set pktCnt [ capture cget -nPackets ]
Deputs "pkt count:$pktCnt"

                    set err ""
                    if { $pktCnt == 0 } {
                        set err "No packet captured"
                    } else {
                        if { $pktCnt > 30000 } {
Deputs "pktCnt:$pktCnt,more than 30000,automation set to 30000"
                            set pktCnt 30000
                        }
                    }

                    if { $err == "" } {
                        set rsGetBuffer [ eval captureBuffer get $chasId $card $port 1 $pktCnt ]
                Deputs "result get buffer:$rsGetBuffer"
                        
                    }
                    eval captureBuffer export $SavePath
                }
			# Deputs "hPort: $hPort"
			# set m [IxiaCapi::PortManager cget -TestPortList]
			# Deputs "$m"
                # set portName [ IxiaCapi::PortManager GetPortName $hPort ]
                # set portName [ namespace tail $portName ]
# Deputs "port name:$portName"

                # cd $dir
				# set len [ string length $portName ]
				# for { set index 0 } { $index < $len } { incr index } {
					# if { [ string index $portName $index ] == "/" } {
						# set portName [ string replace $portName $index $index "-" ] 
					# }
				# }
                # if { [ catch {
                    # set fileCap [ glob *{${portName}_HW}*.cap ]
					# Deputs "dir:$dir"
					# Deputs "file:$file"
					# Deputs "fileCap:$fileCap"
					
                    # file delete -force "$dir/$file"
                    # file rename -force "$dir/$fileCap" "$dir/$file"
                # } ] } {
# Deputs "$errorInfo"                    
                    # IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestAnalysisStopCapture5"
                                # return $IxiaCapi::errorcode(7)                        
                # }
            }
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestAnalysisStopCapture2"
                        return $IxiaCapi::errorcode(7)                        
        } else {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestAnalysisStopCapture1"
            return $IxiaCapi::errorcode(0)                        
        }        
    }
    
    body TestAnalysis::ConfigCaptureMode { args } {
        global errorInfo
        global IxiaCapi::success IxiaCapi::fail
        
        set tag "body TestAnalysis::ConfigCaptureMode [info script]"
Deputs "----- TAG: $tag -----"
        
# Param collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -capturefile -
                -file {
                    set SavePath $value
                }
                -filtername -
                -filter {
                    set FilterName $value
                }
            }
        }
        
       
        return $IxiaCapi::errorcode(0)                        
    }
    
    body TestAnalysis::GetCapturePacket { args } {
        global errorInfo
        
        
        set tag "body TestAnalysis::GetCapturePacket [info script]"
Deputs "----- TAG: $tag -----"
        
       
        foreach { key value } $args {
            set key [string tolower $key]
			Deputs "$key $value"
            switch -exact -- $key {
			    -index -
                -packetindex {
				    if { $value > 1000} {
				        set packet_index [expr $value % 1000 + 1]
				    } else {
                        set packet_index [ expr $value + 1 ]
				    }
				 
					set hPacketIndex $packet_index
                }
                -packethandle {
                    set packethandle $value
                }
				-content -
                -packetcontent {
                    set content $value
                }
		        -protocol {
			       set header $value 
		        }
		        -field {
			        set fields $value
		        }
		        -source {
			        set filesource $value
		        }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1" -tag $tag
		            return $IxiaCapi::errorcode(7)
                }
            }
        }
		
		
		
		set contentProMap(info)            "Frame"
		set contentProMap(info,frame_size) 6
		set contentProMap(info,protocols)  7
		
		#-- header ethernet
		set contentProMap(ethernet_2)        "Ethernet"
		set contentProMap(ethernet_2,destination_address)    0
		set contentProMap(ethernet_2,source_address)         1
		set contentProMap(ethernet_2,ether_type)             4
		
		#-- header vlan
		set contentProMap(ethernet_2_vlan)            "802.1Q Virtual LAN"
		set contentProMap(ethernet_2_vlan,vlan_user_priority)        0
		set contentProMap(ethernet_2_vlan,vlan_cfi)                  1
		set contentProMap(ethernet_2_vlan,vlan_id)                   2
		set contentProMap(ethernet_2_vlan,vlan_tag_type)             3
		
		#-- header ipv4
		set contentProMap(ipv4)            "Internet Protocol"
		set contentProMap(ipv4,version)             0
		set contentProMap(ipv4,hlen)                1
		set contentProMap(ipv4,ds_codepoint)        2
		set contentProMap(ipv4,tos_precedence)      5
		set contentProMap(ipv4,tos_delay)           6
		set contentProMap(ipv4,tos_throughput)      7
		set contentProMap(ipv4,tos_reliability)     8
		set contentProMap(ipv4,tos_unused)          10	
		set contentProMap(ipv4,tot_len)             11 
		set contentProMap(ipv4,identification)      12
		set contentProMap(ipv4,frags)               15
		set contentProMap(ipv4,fragment_offset)     16
		set contentProMap(ipv4,ttl)                 17
		set contentProMap(ipv4,protocol)            18
		set contentProMap(ipv4,header_checksum)     19
		set contentProMap(ipv4,source_address)      20
		set contentProMap(ipv4,destination_address) 24
		
		#-- header udp
		set contentProMap(udp) 				"User Datagram Protocol"
		set contentProMap(udp,source_port)		    0
		set contentProMap(udp,destination_port)		1
		set contentProMap(udp,message_length)       4
		set contentProMap(udp,checksum)             5
		
		#-- header tcp
		set contentProMap(tcp) 			"Transmission Control Protocol"
		set contentProMap(tcp,source_port)		    0
		set contentProMap(tcp,destination_port)		1	
		set contentProMap(tcp,header_length)        5
		set contentProMap(tcp,window)               14
		set contentProMap(tcp,checksum)             15
		set contentProMap(urgent_pointer)           8
		
		
		
      
# Check the necessary param has been assigned
        if { [ info exists filesource ] } {
		    if { [ catch {
                set portInfo [ixNet getA $hPort -connectionInfo]
 #--chassis="10.137.144.57" card="9" port="3" portip="10.0.9.3"
		        regexp {chassis=([0-9\.\"]+) card=([\"0-9]+) port=([\"0-9]+)} $portInfo match chas card port
Deputs "chas:$chas card:$card port:$port"
		        set rsConnectToOS [ ixConnectToChassis $chas ]
Deputs "result connecting to OS:$rsConnectToOS"
		        set chasId	[ chassis cget -id ]
Deputs "capture get on $chasId $card $port"
		
		        set readPortRes [ eval port get $chasId $card $port ]
Deputs "read port result:$readPortRes"		
		        set owner [port cget -owner]
Deputs "owner:$owner"		

		# Login before taking ownership
		        ixLogin $owner
		# Take ownership of the ports we’ll use
		        set portList [ list [ eval list $chasId $card $port ] ]
Deputs "portList:$portList"		
		        ixTakeOwnership $portList

		        set rsGetCap [ eval captureBuffer import $filesource $chasId $card $port ]
			}]} {
			    return $IxiaCapi::errorcode(7)  
			}
			
			# if {  [ info exists header ] || [ info exists fields ] } {
			    # IxiaCapi::Logger::LogIn -type err -message \
                # "$IxiaCapi::s_TestAnalysisGetCapturePacket8" -tag $tag
		        # return $IxiaCapi::errorcode(7)
			
			# }
        } 
        	
		if {[ info exists packet_index ] == 0} {
		    IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_TestAnalysisGetCapturePacket7" -tag $tag
		    return $IxiaCapi::errorcode(7)
		}
		
		if {  [ info exists header ] && [ info exists fields ] } {
		    set status "success"
Deputs "decode process"				
			if { [ info exists contentProMap($header) ] == 0 } {
				set status "failed"
				IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TestAnalysisGetCapturePacket8" -tag $tag
				
			}
			
			
			
			if { $status == "success" } {

				if { [ catch {
					set pkg_count    [ ixNet getA $hPort/capture -dataPacketCounter ]
Deputs "Pkt count:$pkg_count"
					ixNet exec getPacketFromDataCapture $hPort/capture/currentPacket $packet_index
				} ] } {
					set status "failed"
					IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_TestAnalysisGetCapturePacket9" -tag $tag
					        
				}
			
			}
			
			if { $status == "success" } {
Deputs "port handle:$hPort"
				set stackList [ ixNet getList $hPort/capture/currentPacket stack ]
Deputs "stack list:$stackList"				
				set headerFlag  0
				set fieldFlag   0
				set stackIndex  0
				foreach stack $stackList {
					if { [ regexp -nocase  "$contentProMap($header)" $stack ] } {
							set headerFlag 1
							break						
					}
					incr stackIndex
				}
				
				if { $headerFlag == 0 } {
					set status "failed"
					set log "No mapping header in current packet"
				}
			}
			
			
			if { $status == "success"} {
				set stack       [ lindex $stackList $stackIndex ]
Deputs "stack:$stack"
				set fieldList   [ ixNet getList $stack field ]
Deputs "field list:$fieldList"
				foreach field $fields {
					set fieldIndex  $contentProMap($header,$field)
Deputs "fieldIndex:$fieldIndex"
					if { $fieldIndex < 0 } {
						continue
					}
					set field       [ lindex $fieldList $fieldIndex ]
Deputs "field:$field"
					#lappend $content [ ixNet getA $field -fieldValue ]
					set hex [ ixNet getA $field -fieldValue ]
					set command "set $content {$hex}"
			        uplevel 1 "eval {$command}"
					
Deputs "content:$content"
				}
				set log ""
				set status "success"
			}
			
		} else {
		    if { [ llength $hcontent ] == 0 } {
			    if { [ catch {
				    GetAllContent
			    } err ] } {
				    return $IxiaCapi::errorcode(7)
			    }
		    }
Deputs "hcontent count: [ llength $hcontent ]"	
            if { [ llength $hcontent ] < $packet_index } {
			    IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TestAnalysisGetCapturePacket9" -tag $tag
			    return $IxiaCapi::errorcode(7)
		    }
		    set hex [ lindex $hcontent [ expr $packet_index - 1 ] ]
Deputs "hex: $hex"			
		    set command "set $content {$hex}"
Deputs "command: $command"
			uplevel 1 "eval {$command}"
            			
		    if {[info exists packethandle] } {
		        set command "IxiaCapi::Pdu $packethandle custom "
		        uplevel 1 " eval {$command} "
			    $packethandle SetRaw $hex
			
			    set hPacketSet $hex
		    }
		
		
		
		}

		
		return $IxiaCapi::errorcode(0) 
					
    }
    
}
