# TestPort.tcl --
#   This file implements the TestPort class for the highlevel CAPI of N2X device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1
# Version 1.2

namespace eval IxiaCapi {
    class TestPort {
        constructor {{chassis 0}  { moduleNo 0 } { portNo 0 } { porthandle 0 }  } { }
        method StartTraffic {  args  } {}
        method StopTraffic {  args  } {}
        method StartStaEngine { args } {}
        method StopStaEngine { args } {}
        method CreateTraffic {  args } {}
        method DestroyTraffic  { args } {}
        method CreateHost { args } {}
        method DestroyHost { args } {}
        method CreateAccessHost { args } {}
        method CreateStaEngine { args } {}
        method DestroyStaEngine { args } {}
        method CreateFilter { args } {}
        method ConfigFilter { args } {}
        method DestroyFilter { args } {}
        method GetPortState { args } {}
        method ConfigPort { args } {}
        method CreateRouter { args } {}
        method DestroyRouter { args } {}
        method StartRouter { args } {}
        method StopRouter { args } {}
		method SendArpRequest {} {}
        destructor {}
                
        method GetRealPort { chassis card port } {
            set root    [ixNet getRoot]
#Deputs "chassis:$chassis"         
            set realCard $chassis/card:$card
#Deputs "card:$realCard"
            set cardList [ixNet getList $chassis card]
#Deputs "cardList:$cardList"
            set findCard 0
            foreach ca $cardList {
                eval set ca $ca
                if { $ca == $realCard } {
                    set findCard 1
                    break
                }
            }
            if { $findCard == 0} {
                return [ixNet getNull]
            }
            set realPort $chassis/card:$card/port:$port
#Deputs "port:$realPort"
            set portList [ ixNet getList $chassis/card:$card port ]
#Deputs "portList:$portList"
            set findPort 0
            foreach po $portList {
                eval set po $po
                if { $po == $realPort } {
                    set findPort 1
                    break
                }
            }
#Deputs "findPort:$findPort"
            if { $findPort } {
			    ixNet exec clearOwnership $chassis/card:$card/port:$port
                return $chassis/card:$card/port:$port
            } else {
                return [ixNet getNull]
            }
        }
        
        method ConnectedTo { chassis card port } {
            set realPort    [GetRealPort $chassis $card $port]
            ixNet setA $hPort -connectedTo $realPort
            ixNet commit
            set hPort [ixNet reampIds $hPort]
            set handle $hPort 
        }
        
        public variable HostLevel
        public variable HostList
        public variable RouterList
        public variable FilterList
        public variable StaEngine
        public variable AnaEngine
        public variable RtEngine
        public variable Traffic
        public variable ModuleNo
        public variable PortNo
        public variable hPort
        public variable ospfRouterIdList
        public variable handle
	public variable m_staEngineList
	public variable m_trafficNameList
	public variable m_filterNameList
        #public variable hostargs
        
        private variable MTU
        
        method Reset {} {
            global errorInfo
            if { [ info exists HostList ] } {
                set HostList [ list ]
            }
            if { [ info exists StaEngine ] } {
                unset StaEngine
            }
            if { [ info exists AnaEngine ] } {
                unset AnaEngine
            }
            if { [ info exists FilterList ] } {
                set FilterList [ list ]
                set m_filterNameList [ list ]
            }
            if { [ info exists Traffic ] } {
                unset Traffic
            }
            if { [ info exists RouterList ] } {
                set RouterList [ list ]
            }
            if { [ catch {
Deputs "port handle to reset: $hPort"
                set ethernetLayer [ixNet getL $hPort/l1Config ethernet ]
				if {$ethernetLayer != "" } {
                    set mediaType [ixNet getA $hPort/l1Config/ethernet -media ]
                }
                ixNet exec setFactoryDefaults $hPort
				after 1000
				if { $ethernetLayer != "" } {
                    ixNet setA $hPort/l1Config/ethernet -media $mediaType
                    ixNet commit
                    after 2000
                }
            } ] } {
                Deputs "Reset port:$errorInfo"
            }
        }
        
        method ListHosts {} {
            puts $HostList            
        }
        method GetHostList {} {
            return $HostList
        }
        method ListFilter {} {
            puts $FilterList
        }
        method GetFilterList {} {
            return $FilterList
        }
        method StaExist {} {
            return [ info exists StaEngine ]
        }
    }
    

    class ETHPort {
        inherit TestPort
        constructor { {chassis 0}  { slot 0 } { portNo 0 } { porthandle 0 }  } {
            chain $chassis $slot $portNo $porthandle } {
        set tag "body ETHPort::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set VlanIntList [ list ]
            set ArpList [ list ]
            set NdpList [ list ]
            set ospfRouterIdList    [ list ]
            #set DefaultHost 1
            DestroyArpd
            set SubHost 0
            if { $porthandle != 0 } {
                ixNet setMultiAttr $porthandle \
                    -type ethernet
                ixNet commit
            }
        }
        method CreateSubInt { args } {}
        method DestroySubInt { args } {}
        method CreateHost { args } {}
        method CreateAccessHost { args } {}
        method GetPortState { args } {}
        method ConfigPort { args } {}
        method CreateArpd { args } {}
        method DestroyArpd {} {}
        method ConfigArpEntry { args } {}
        method DeleteArpEntry { args } {}
        method StartArpd { args } {}
        method StartRouter { args } {}
        
        protected variable SubHost
        protected variable DefaultHost
        public variable VlanIntList
        private variable ArpList
        private variable NdpList
#        private variable Arp_ReplyWithUniqueMacAddr

        method Reset {} {
            chain
            set VlanIntList [ list ]
            set ArpList [ list ]
            set NdpList [ list ]
            #set DefaultHost 1
        }

        method ListVlan {} {
            puts $VlanIntList
        }
        method GetVlansList {} {
            return $VlanIntList
        }
        method ListArp {} {
            puts $ArpList
        }
    }
    

    class VlanSubInt {
        inherit ETHPort
        constructor { porthandle } { chain 0 0 0 $porthandle } { }
        method ConfigPort { args } {}
        method CreateHost { args } {}
		method CreateAccessHost { args } {}
		method CreateRouter { args } {}
		method SetPortName { name } {
		    set PortName $name
		}
        destructor {}
        public variable hPort
		public variable PortName
        public variable VlanId
        public variable VlanTag
        public variable VlanPrior
        public variable QinQList
    }
    

    body TestPort::constructor { {chassis 0}  { moduleNo 0 } { portNo 0 } { porthandle 0 } } {
        global errorInfo
        global gOffline
        set ModuleNo $moduleNo
        set PortNo $portNo
        set tag "body TestPort::ctor [info script]"
Deputs "----- TAG: $tag -----"
        #-type (readOnly=False, type=kEnumValue=atm,ethernet,ethernetFcoe,ethernetImpairment,ethernetvm,
        #fc,fortyGigLan,fortyGigLanFcoe,hundredGigLan,hundredGigLanFcoe,pos,tenFortyHundredGigLan,
        #tenFortyHundredGigLanFcoe,tenGigLan,tenGigLanFcoe,tenGigWan,tenGigWanFcoe)

        if { $moduleNo == 0 && $portNo == 0 } {
            if { $porthandle != 0} {
                set hPort $porthandle
                return
            }
        }
        set HostList    [ list ]
        set FilterList  [ list ]
        set m_filterNameList [ list ]
        set RouterList  [ list ]
        set ArpList     [ list ]
        set ospfRouterIdList    [ list ]
        set HostLevel 2
        set start [ clock seconds ]
        set root    [ixNet getRoot]
        set vport   [ixNet add $root vport]
        if { $gOffline == 0 } {
            set realPort    [ GetRealPort $chassis $ModuleNo $PortNo ]
    Deputs "Real Port:$realPort"
            ixNet setMultiAttrs $vport \
                                -name $this \
                                -connectedTo $realPort
        }
        ixNet commit
        set vport [ixNet remapIds $vport]
        set hPort $vport
        set handle $hPort 
        return $this		
    }
    
    body TestPort::destructor {} {
        global errorInfo
        global IxiaCapi::PortManager
        set tag "body TestPort::destructor [info script]"
Deputs "----- TAG: $tag -----"
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            ixTclNet::StopTraffic
        } 
# Donot do anything when destroy subinterface
        if { $ModuleNo == 0 && $PortNo == 0 } {
            return
        }
# Remove port which is selected
        catch {
            PortManager DeleteTestPort -handle $hPort
        }
        catch {
            ixNet remove $hPort
            ixNet commit
# Remove the TrafficEngine created by the port
            if { [ info exists Traffic ] } {
                DestroyTraffic
            }
# Remove the StatisticEngine created by the port
            DestroyStaEngine
# Remove the Filter created by the port
            DestroyFilter
# Remove the Host created by the port
            DestroyHost
# Remove the Router created by the port
            DestroyRouter
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortDector1 $hPort"            
        }        
    }
    body TestPort::CreateHost { args } {
        global errorInfo

        set tag "body TestPort::CreateHost [info script]"
Deputs "----- TAG: $tag -----"
#param collection
Deputs "Args:$args "
        eval " CreateAccessHost $args "
    }
   
    body TestPort::CreateAccessHost { args } {
        global errorInfo

        set tag "body TestPort::CreateAccessHost [info script]"
Deputs "----- TAG: $tag -----"
#param collection
Deputs "Args:$args "
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -hostname {
				    set value [::IxiaCapi::NamespaceDefine $value]
                    if { [ lsearch -exact $HostList $value ] < 0 } {
                        set name $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestPortCreateHost2 $value" -tag $tag
                        return $IxiaCapi::errorcode(4)                
                    }
                }
            }
        }
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
            return $IxiaCapi::errorcode(8)
        }
# Check the existence of necessary params
        if { [info exists name] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateHost1" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
                
        if { [ catch {
            lappend HostList $name
            set command "IxiaCapi::Host $name "
Deputs "command:$command"
            #namespace inscope $IxiaCapi::ObjectNamespace $command
            uplevel $HostLevel "eval $command"
            set command " $name Config -hPort $hPort  $args "
Deputs "command:$command"
            uplevel $HostLevel "eval $command"
			
            } ] } {
            catch {
                DestroyHost -name $name
            }
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        }
        #lappend HostList $name
        IxiaCapi::Logger::LogIn -message \
        "$IxiaCapi::s_TestPortCreateHost3 $HostList" -tag $tag
        return $IxiaCapi::errorcode(0)
    }

    
    body TestPort::DestroyHost { args } {
        
        global errorInfo
        
        set tag "body TestPort::DestroyHost [info script]"
Deputs "----- TAG: $tag -----"
#param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -hostname {
                    #set delHostList $value 
                    set delHostList [::IxiaCapi::NamespaceDefine $value]					
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -hostname" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
            return $IxiaCapi::errorcode(8)
        }

        if { [info exists delHostList] == 0 } {
            #IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_common1 \n\t $IxiaCapi::s_TestPortDestroyHost1" -tag $tag
            #return $fail
            set delHostList $HostList
        }

        foreach delHost $delHostList {
            if { [lsearch -exact $HostList $delHost] < 0 } {
                IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_common1 \n\t \
                $IxiaCapi::s_TestPortDestroyHost1 $delHost" -tag $tag
                return $IxiaCapi::errorcode(4)
            } else {
                set delIndex [lsearch $HostList $delHost]
            }
            if { [ catch {
                set HostList [ lreplace $HostList $delIndex $delIndex ]
Deputs "Destroy host: $delHost"
                if { [ catch {
                    uplevel 2 " delete object $delHost "
                } ] } {
Deputs "$errorInfo"
                    if { [ catch {
                        uplevel 1 " delete object $delHost "
                    } ] } {
Deputs "$errorInfo"
                        delete object $delHost
                    }
                } else {
Deputs "Destroy host: $delHost success..."
                }
            } ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                return $IxiaCapi::errorcode(7)
            } 
        }
        IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortDestroyHost2 \n\t \
        Host list: $HostList"
        return $IxiaCapi::errorcode(0)
    }

    body TestPort::CreateTraffic { args } {
        
        global errorInfo
        set tag "body TestPort::CreateTraffic [info script]"
Deputs "----- TAG: $tag -----"

        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -trafficname {
                    set trafficName [::IxiaCapi::NamespaceDefine $value]
                    #set trafficName $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -trafficname" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
            return $IxiaCapi::errorcode(8)
        }
        if { [ info exists trafficName ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateTraffic2"\
            -tag $tag
            return $IxiaCapi::errorcode(3)
        }
Deputs "Port:$hPort"        
        if { [ info exists Traffic ] } {
Deputs "Traffic exist: $Traffic"          
                IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TestPortCreateTraffic3" \
                -tag $tag

                return $IxiaCapi::errorcode(9)            
        }
        if { [ catch { 
            set command "IxiaCapi::TrafficEngine $trafficName $hPort"
            #namespace inscope $IxiaCapi::ObjectNamespace $command
            #uplevel 1 " eval $command "
			uplevel 1 " eval $command " 
			set command "$trafficName SetPortObj $this "
			uplevel 1 " eval $command "
            set Traffic $trafficName
	    set m_trafficNameList $trafficName
Deputs "Traffic:$trafficName"
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(8)
        } else {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortCreateTraffic1 $trafficName"
            return $IxiaCapi::errorcode(0)
        }
    }
    body TestPort::DestroyTraffic { args } {
        
        global errorInfo
        set tag "body TestPort::DestroyTraffic [info script]"
Deputs "----- TAG: $tag -----"
Deputs "args: $args"
#param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -trafficname {
                    #set name $value 
                    set name [::IxiaCapi::NamespaceDefine $value]
					#set name [ IxiaCapi::NamespaceConvert $value $Traffic ]
					
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -TrafficName" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# Make sure the traffic engine is stopped
        # if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            # IxiaCapi::Logger::LogIn -type err -message \
            # "$IxiaCapi::s_common5" -tag $tag
            # return $IxiaCapi::errorcode(8)
        # }
# Make sure the traffic to be destroyed exist --
        set exist 1
        if { [ info exists Traffic ] } {
		
		Deputs "Traffic: $Traffic"
            if { [ info exists name ] } { 
                if { $Traffic != $name } {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TestPortDestroyTraffic2" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
            if { [ catch {
			 
                catch { uplevel 1 " delete object $Traffic " }
				
            } ] } {
                catch { uplevel 2 " delete object $Traffic " }
            }
            unset Traffic
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortDestroyTraffic1" -tag $tag
            return $IxiaCapi::errorcode(0)
        } else {
            set exist 0
        }
# If the traffic to be destroyed is not current traffic
# Try to destroy it and return fail --
        if { $exist == 0 } {
            IxiaCapi::Logger::LogIn  -message "Traffic is already deleted" -tag $tag
            return $IxiaCapi::errorcode(4)
        }
        return $IxiaCapi::errorcode(0)
    }
    
    body TestPort::StartTraffic { args } {
        
        global errorInfo
        
        global IxiaCapi::PortManager IxiaCapi::TrafficManager
        
        set tag "body TestPort::StartTraffic [info script]"
Deputs "----- TAG: $tag -----"
        set clearStats 1
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -stream -
                -streams -
                -streamnamelist -
                -streamlist {
                    set streamList [::IxiaCapi::NamespaceDefine $value]
                    #set streamList $value
                }
                -profile -
                -profiles -
                -profilelist {
                    #set profileList $value
                    set profileList [::IxiaCapi::NamespaceDefine $value]
                }
                -clearstatistic {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set clearStats $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_TestPortStartTraffic10" -tag $tag
                    }
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -StreamList\t-ProfileList" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
			
	
# Check the existence of TrafficEngine
        set exist 1
        if { [ info exists Traffic ] == 0 } {
            set exist 0
        }
        if { $exist == 0 } {
            IxiaCapi::Logger::LogIn -type err \
            -message "$IxiaCapi::s_TestPortStartTraffic4"
            return $IxiaCapi::errorcode(4)
        }
        if { [ info exists streamList ] && [ info exists profileList ] } {
            IxiaCapi::Logger::LogIn -type err \
            -message "$IxiaCapi::s_TestPortStartTraffic8"
            return $IxiaCapi::errorcode(2)
        }
		set restartCapture 0
		set restartCaptureJudgement 0
		set root [ixNet getRoot]
		set portList [ ixNet getL $root vport ]
		foreach hport $portList {
			if { [ ixNet getA $hport/capture    -hardwareEnabled  ] } {
				set restartCapture 1
				break
			}
		}
		
		
		set flowList ""
# Check streams, which should stop the traffic engine.
        if { [ info exists streamList ] } {
    # To find how many profiles does stream list have
            # foreach stream  [ IxiaCapi::TrafficManager GetStreamHandleList ] {
# Deputs "disable stream $stream"
                # ixNet setA $stream -suspend True
            # }
            foreach stream $streamList {
                if { [ catch {
                    set stream [ IxiaCapi::Regexer::GetObject $stream ]
                    set strObj [ uplevel 1 " $stream cget -hStream " ]
					set trafficObj [ uplevel 1 " $stream cget -hTrafficItem " ]

                    if {[ ixNet getA $trafficObj -state ] == "unapplied" } {
					   Tester::apply_traffic
					   if { $restartCapture } {
							catch { 
								Deputs "stop capture..."
								ixNet exec stopCapture
								after 1000				
								ixNet exec closeAllTabs		
                                set restartCaptureJudgement 1								
								
							}
						} 
					}
					lappend flowList $trafficObj
					
                    #ixNet setA $strObj -suspend False
                    # identify the stream
                } ] } {
                    IxiaCapi::Logger::LogIn -type warn \
                    -message "$IxiaCapi::s_TestPortStartTraffic6 $stream" -tag $tag
                    continue
                }
            }
        }
# Check profile, which should exist
        if { [ info exists profileList ] } {
            set traObj [ IxiaCapi::Regexer::GetObject $Traffic ]
            set streamList [ $traObj GetStreamList ]
            foreach profile $profileList {
                foreach stream $streamList {
                    set streamObj [ IxiaCapi::Regexer::GetObject $stream ]
                    set ProfileName [ $streamObj cget -ProfileName ]
                    if { $ProfileName == $profile } {
                        #ixNet setA $strObj -suspend False
						set strObj [ uplevel 1 " $streamObj cget -hStream " ]
						set trafficObj [ uplevel 1 " $streamObj cget -hTrafficItem " ]
	
						if {[ ixNet getA $trafficObj -state ] == "unapplied" } {
						   Tester::apply_traffic
						   if { $restartCapture } {
								catch { 
									Deputs "stop capture..."
									ixNet exec stopCapture
									after 1000				
									ixNet exec closeAllTabs		
									set restartCaptureJudgement 1								
									
								}
							} 
						}
						lappend flowList $trafficObj
                    }
                }
            }
        }
# Start all stream --
        if { ( [ info exists streamList ] == 0 ) && ( [ info exists profileList ] == 0 ) } {
            # foreach stream  [ IxiaCapi::TrafficManager GetStreamHandleList ] {
# Deputs "enable stream $stream"
                # ixNet setA $stream -suspend False
            # }
			
			set traObj [ IxiaCapi::Regexer::GetObject $Traffic ]
			Deputs "traObj::$traObj"
            set streamList [ $traObj GetStreamList ]
			Deputs "streamList:$streamList"
			foreach stream $streamList {
				set streamObj [ IxiaCapi::Regexer::GetObject $stream ]
				
				#ixNet setA $strObj -suspend False
				set strObj [ uplevel 1 " $streamObj cget -hStream " ]
				set trafficObj [ uplevel 1 " $streamObj cget -hTrafficItem " ]
				Deputs "strObj::$strObj"
				Deputs "trafficObj::$trafficObj"

				if {[ ixNet getA $trafficObj -state ] == "unapplied" } {
				   Tester::apply_traffic
				   if { $restartCapture } {
						catch { 
							Deputs "stop capture..."
							ixNet exec stopCapture
							after 1000				
							ixNet exec closeAllTabs		
							set restartCaptureJudgement 1								
							
						}
					} 
				}
				lappend flowList $trafficObj
				
			}
			
        }
        
		#ixNet commit
        if { [ info exists clearStats ] } {
            if { $clearStats } {
                ixNet exec clearStats
            }
        }
		
		if { $restartCaptureJudgement } {
			catch { 
				
				Deputs "start capture..."
				ixNet exec startCapture
				after 2000
			}
		}
Deputs "flowList: $flowList"	
        if {$flowList != "" } {
		    ixNet exec startStatelessTraffic $flowList
		}
		set timeout 30
		set stopflag 0
		while { 1 } {
		if { !$timeout } {
			break
		}
		set state [ ixNet getA $root/traffic -state ] 
		if { $state != "started" } {
	Deputs "start state:$state"
			if { [string match startedWaiting* $state ] } {
				set stopflag 1
			} elseif {[string match stopped* $state ] && ($stopflag == 1)} {
				break	
			}	
			after 1000		
		} else {
	Deputs "start state:$state"
			break
		}
		incr timeout -1
	Deputs "start timeout:$timeout state:$state"
		}

        return $IxiaCapi::errorcode(0)
    }
    
    body TestPort::StopTraffic { args } {
        
        global errorInfo
        
        global IxiaCapi::PortManager IxiaCapi::TrafficManager
                
        set tag "body TestPort::StopTraffic [info script]"
Deputs "----- TAG: $tag -----"
        
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -stream -
                -streams -
                -streamlist -
                -streamnamelist {
                #-- the start based on stream is not supported
                    #set streamList $value
                    set streamList [::IxiaCapi::NamespaceDefine $value]
                }
                -profile -
                -profiles -
                -profilelist {
                    set profileList $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -StreamList\t-ProfileList" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        
# Check the existence of TrafficEngine
        if { [ info exists Traffic ] == 0 } {
            IxiaCapi::Logger::LogIn -type err \
            -message "$IxiaCapi::s_TestPortStopTraffic6"
            return $IxiaCapi::errorcode(4)
        } else {
            set traObj [ IxiaCapi::Regexer::GetObject $Traffic ]
        }

        if { [ info exists streamList ] && [ info exists profileList ] } {
            IxiaCapi::Logger::LogIn -type err \
            -message "$IxiaCapi::s_TestPortStopTraffic8"
            return $IxiaCapi::errorcode(2)
        }
		set flowList ""
# Check streams, which should stop the traffic engine.
        if { [ info exists streamList ] } {
    # To find how many profiles does stream list have
            # foreach stream  [ IxiaCapi::TrafficManager GetStreamHandleList ] {
# Deputs "disable stream $stream"
                # ixNet setA $stream -suspend True
            # }
            foreach stream $streamList {
                if { [ catch {
                    set stream [ IxiaCapi::Regexer::GetObject $stream ]
                    set strObj [ uplevel 1 " $stream cget -hStream " ]
					set trafficObj [ uplevel 1 " $stream cget -hTrafficItem " ]

                    # if {[ ixNet getA $trafficObj -state ] == "unapplied" } {
					   # Tester::apply_traffic
					# }
					lappend flowList $trafficObj
					
                    #ixNet setA $strObj -suspend False
                    # identify the stream
                } ] } {
                    IxiaCapi::Logger::LogIn -type warn \
                    -message "$IxiaCapi::s_TestPortStartTraffic6 $stream" -tag $tag
                    continue
                }
            }
        }
# Check profile, which should exist
        if { [ info exists profileList ] } {
            set traObj [ IxiaCapi::Regexer::GetObject $Traffic ]
            set streamList [ $traObj GetStreamList ]
            foreach profile $profileList {
                foreach stream $streamList {
                    set streamObj [ IxiaCapi::Regexer::GetObject $stream ]
#Deputs "streamObj:$streamObj"
                    set ProfileName [ $streamObj cget -ProfileName ]
#Deputs "$ProfileName == $profile"
                    if { $ProfileName == $profile } {
                        #ixNet setA $strObj -suspend False
						set strObj [ uplevel 1 " $streamObj cget -hStream " ]
						set trafficObj [ uplevel 1 " $streamObj cget -hTrafficItem " ]
	#Deputs "enable stream $strObj"
						
						lappend flowList $trafficObj
                    }
                }
            }
        }
# Start all stream --
        if { ( [ info exists streamList ] == 0 ) && ( [ info exists profileList ] == 0 ) } {
            # foreach stream  [ IxiaCapi::TrafficManager GetStreamHandleList ] {
# Deputs "enable stream $stream"
                # ixNet setA $stream -suspend False
            # }
			set traObj [ IxiaCapi::Regexer::GetObject $Traffic ]
            set streamList [ $traObj GetStreamList ]
			foreach stream $streamList {
				set streamObj [ IxiaCapi::Regexer::GetObject $stream ]
#Deputs "streamObj:$streamObj"				
				#ixNet setA $strObj -suspend False
				set strObj [ uplevel 1 " $streamObj cget -hStream " ]
				set trafficObj [ uplevel 1 " $streamObj cget -hTrafficItem " ]
#Deputs "enable stream $strObj"
				# if {[ ixNet getA $trafficObj -state ] == "unapplied" } {
				   # Tester::apply_traffic
				# }
				lappend flowList $trafficObj
				
			}
			
        }
        if {$flowList != "" } {		
		    ixNet exec stopStatelessTraffic $flowList  
        }
		set timeout 10
		set root [ixNet getRoot]
		while { 1 } {
		if { !$timeout } {
			break
		}
		set state [ ixNet getA $root/traffic -state ] 
		if { ( $state != "stopped" ) && ( $state != "unapplied" ) } {
			after 1000
		} else {
			break
		}
		incr timeout -1
	Deputs "stop timeout:$timeout"
		}
		

        return $IxiaCapi::errorcode(0)
    }
    body TestPort::CreateStaEngine { args } {
        
        
        global errorInfo
        set tag "body TestPort::CreateStaEngine [info script]"
Deputs "----- TAG: $tag -----"
        
        set EType [ list STATISTICS ANALYSIS ]
        
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -staenginename {
                    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
                }
                -type -
                -statype {
                   if { [ lsearch -exact $EType [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message "$IxiaCapi::s_TestPortCreateStaEngine1 $EType"
                    } else {
                        set type [ string toupper $value ] 
                    }
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -StaEngineName\t-StaType" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# Make sure the traffic engine is stopped
        #if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
         #   IxiaCapi::Logger::LogIn -type err -message \
         #   "$IxiaCapi::s_common5" -tag $tag
         #   return $IxiaCapi::errorcode(8)
       # }
# Make sure the necessary param has been assigned
    # ----- Name -----

        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_common1 \
            $IxiaCapi::s_TestPortCreateStaEngine2" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
    # ----- Type -----    
        if { [ info exists type ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_common1 \
            $IxiaCapi::s_TestPortCreateStaEngine3" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
# Check the existence of StaEngine
# If positive an error will be occured
               # if { $type == "ANALYSIS" } {
                #    if { [ info exists AnaEngine ] } {
                #        IxiaCapi::Logger::LogIn -type err -message \
                #        "$IxiaCapi::s_TestPortCreateStaEngine6"\
                #        -tag $tag
                #        return $IxiaCapi::errorcode(9)
                #    }
               # } else {
#Deputs Step10
#                    if { [ info exists StaEngine ] } {
#Deputs Step20
#                        IxiaCapi::Logger::LogIn -type err -message \
#                        "$IxiaCapi::s_TestPortCreateStaEngine5"\
#                       -tag $tag
#Deputs Step25
#Deputs [find object]
#                        return $IxiaCapi::errorcode(9)
#                    }
#Deputs Step30
#                }
# Create the object        
        if { [ catch {
            if { $type == "ANALYSIS" } {
                set command "IxiaCapi::TestAnalysis $name $hPort"
                set AnaEngine $name
            } else {
                set command "IxiaCapi::TestStatistic $name $hPort "
                set StaEngine $name
                set m_staEngineList $name
            }
            #namespace inscope $IxiaCapi::ObjectNamespace $command
            uplevel 1 " eval $command "
			uplevel 1 " eval $name SetPortName $this "
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            if { $type == "ANALYSIS" } {
                catch {
                    uplevel 1 " delete object $AnaEngine "
                }
                unset AnaEngine
            } else {
Deputs "Sta engine delete invoked..."
Deputs $errorInfo
                catch {
                    uplevel 1 " delete object $StaEngine "
                }
                unset StaEngine
            }
            return $IxiaCapi::errorcode(7)
        } else {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortCreateStaEngine4"
            return $IxiaCapi::errorcode(0)
        }
    }
    
    body TestPort::DestroyStaEngine { args } {
        
        global errorInfo
        set tag "body TestPort::DestroyStaengine [info script]"
Deputs "----- TAG: $tag -----"

# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -staenginename {
                    #set name $value
                    set name [::IxiaCapi::NamespaceDefine $value]
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -StaEngineName" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# Make sure the traffic engine is stopped
        # if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            # IxiaCapi::Logger::LogIn -type err -message \
            # "$IxiaCapi::s_common5" -tag $tag
            # return $IxiaCapi::errorcode(8)
        # }
# Check the existence of name
# If negative all the engines will be deleted
        set exist 0
        if { [ info exists name ] } {
            if { [ catch {
                if { [ info exists StaEngine ] } {

                    if { $name == $StaEngine } {
                        uplevel 1 "eval delete object $StaEngine "
                        unset StaEngine
                        set exist 1
                    } 
                }
                if { [ info exists AnaEngine ] } {

                    if { $name == $AnaEngine } {
                        uplevel 1 "eval delete object $AnaEngine "
                        unset AnaEngine
                        set exist 1
                    }
                }
            } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                return $IxiaCapi::errorcode(7)
            } else {
                IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortDestroyStaEngine1" -tag $tag
                #return $IxiaCapi::errorcode(0)
            }
        } else {
		
            if { [ catch {
                if { [ info exists StaEngine ] } {
                    catch {
					
                        uplevel 1 "eval delete object $StaEngine "
										
                        unset StaEngine
                        set exist 1
                    }
                }
                if { [ info exists AnaEngine ] } {
                    catch {
					
                        uplevel 1 "eval delete object $AnaEngine "
						
						
                        unset AnaEngine
                        set exist 1
                    }
                }
            } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                return $IxiaCapi::errorcode(7)
            } else {
                IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortDestroyStaEngine1" -tag $tag
                return $IxiaCapi::errorcode(0)
            }
        }
# If positive delete the obj
Deputs "Exist : $exist "
        if { $exist } {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortDestroyStaEngine1" -tag $tag
            return $IxiaCapi::errorcode(0)
        } else {
# Or else an error will be occured
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TestPortDestroyStaEngine2" -tag $tag
            return $IxiaCapi::errorcode(1)
        }
    }

    
    
    body TestPort::CreateFilter { args } {
        
        global errorInfo
        set tag "body TestPort::CreateFilter [info script]"
Deputs "----- TAG: $tag -----"

        set EType [ list UDF STACK ]
        
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -filtername {
                    set value [::IxiaCapi::NamespaceDefine $value]
                    if { [ lsearch -exact $FilterList $value ] < 0 } {
                        set name $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestPortCreateFilter5 $value" -tag $tag
                        return $IxiaCapi::errorcode(4)
                    }
                }
                -type -
                -filtertype {
                    if { [ lsearch -exact $EType [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_TestPortCreateFilter1 $EType" -tag $tag
                    } else {
                        set type [ string toupper $value ]
                    }
                }
                -value -
                -filtervalue {
                    set filtervalue $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -FilterName\t-FilterType\t-FilterValue" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
            return $IxiaCapi::errorcode(8)
        }
# Make sure the necessary params has been assigned
    # ----- Name -----
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateFilter2" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
    # ----- Type -----
        if { [ info exists type ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateFilter3 $EType" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
    # ----- Value -----
        if { [ info exists filtervalue ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateFilter6" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
# Invoke the Filter constructor
        if { [ catch {
Deputs Step00
            set command "IxiaCapi::Filter $name $hPort $type {$filtervalue}"
Deputs "$name $hPort $type $filtervalue"
            #namespace inscope $IxiaCapi::ObjectNamespace $command
            uplevel 1 " eval {$command} "
            #set hMatch [ uplevel 1 "$name cget -hMatch" ]
            #AgtInvoke AgtFrameMatcherList SetName $hMatch $name
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message \
                "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        } else {
            lappend FilterList $name
            lappend m_filterNameList $name
            IxiaCapi::Logger::LogIn -message \
                "$IxiaCapi::s_TestPortCreateFilter4 $name" 
            return $IxiaCapi::errorcode(0)
        }
    }
    
    body TestPort::DestroyFilter { args } {
        
        global errorInfo
        set tag "body TestPort::DestroyFilter [info script]"
Deputs "----- TAG: $tag -----"
        set level 1
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -filtername {
                    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
                }
            }
        }
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
            return $IxiaCapi::errorcode(8)
        }
# Make sure the existence of the Name
    # If positive delete the certain filter
        if { [ catch {
Deputs Step10
        if { [ info exists name ] } {
            set index [ lsearch -exact $FilterList $name ]
Deputs Step20
Deputs "index:$index"
            if { $index < 0 } {
Deputs Step30
                IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TestPortDestroyFilter1 $value" -tag $tag
Deputs Step35
                return $IxiaCapi::errorcode(4)
            } else {
Deputs Step40
                set FilterList [ lreplace $FilterList $index $index ]
Deputs "Filter list:$FilterList"
Deputs Step50
Deputs "objects:[find objects]"
                $name CleanFilter
                if { [ catch { uplevel $level " delete object $name " } ] } {
                    incr level
                    catch { uplevel $level " delete object $name " } 
                } 
Deputs Step60
            }
        } else {
    # Or else delete all filters
            if { [ info exists FilterList ] } {
                foreach filter $FilterList {
                    if { [ catch { uplevel $level " delete object $filter " } ] } {
                        incr level
                        [ catch { uplevel $level " delete object $filter " } ]
                    }
                }
                set FilterList  [ list ]
                set m_filterNameList [ list ]
            }
        }
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        } else {
            IxiaCapi::Logger::LogIn -message \
            "$IxiaCapi::s_TestPortDestroyFilter2" -tag $tag
            return $IxiaCapi::errorcode(0)
        }
    }
    
    body TestPort::ConfigFilter { args } {
        
        global errorInfo
        set tag "body TestPort::ConfigFilter [info script]"
Deputs "----- TAG: $tag -----"
        
        set EType [ list UDF STACK ]
        
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -filtername {
                    set name [::IxiaCapi::NamespaceDefine $value]
                        #set name $value
                }
                -type -
                -filtertype {
                    if { [ lsearch -exact $EType [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_TestPortConfigFilter4 $EType" -tag $tag
                    } else {
                        set type [ string toupper $value ]
                    }
                }                
                -value -
                -filtervalue {
                    set filtervalue $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -FilterName\t-FilterType\t-FilterValue" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
            return $IxiaCapi::errorcode(8)
        }
# Make sure the necessary params has been assigned
    # ----- Name -----
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortConfigFilter1" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
# Make sure the obj to be configed is existed
# If negative an error will be occured
        if { [ lsearch -exact $FilterList $name ] < 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_TestPortConfigFilter2 $name" -tag $tag
            return $IxiaCapi::errorcode(4)
        }
# Check the existence of value
# If negative clear the pattern
        if { [ info exists filtervalue ] == 0 } {
            if { [ catch {
                set handle [ uplevel 1 " $name cget -hPort " ]
                #AgtInvoke AgtPattern ClearPattern $handle
            } ] } {
                IxiaCapi::Logger::LogIn -type err -message \
                "$errorInfo" -tag $tag
                return $IxiaCapi::errorcode(7)
            }
            IxiaCapi::Logger::LogIn -message \
            "$IxiaCapi::s_TestPortConfigFilter3" -tag $tag
            return $IxiaCapi::errorcode(0)
        }
    # To decide the value of type
    # If the type is not assigned the former type will be used
        if { [ info exists type ] == 0 } {
            set type [ uplevel 1 " $name cget -Type " ]
        }
# Or else config the filter
        if { [ catch {
            uplevel 1 " $name Config $type {$filtervalue} "
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        } else {
            IxiaCapi::Logger::LogIn -message \
            "$IxiaCapi::s_TestPortConfigFilter3" -tag $tag
            return $IxiaCapi::errorcode(0)
        }
    }
    
    body TestPort::CreateRouter { args } {
        global errorInfo
		set TRUE 1
        

        set tag "body TestPort::CreateRouter [info script]"
Deputs "----- TAG: $tag -----"
        set EType [ list                \
                        OSPFV2ROUTER    \
                        OSPFV3ROUTER    \
                        ISISROUTER      \
                        RIPROUTER       \
                        BGPV6ROUTER     \
                        BGPV4ROUTER     \
                        LDPROUTER       \
                        RSVPROUTER      \
                        IGMPROUTER      \
                        IGMPHOST        \
                        MLDROUTER       \
						MLDHOST         \
                        PIMROUTER       \
                        DHCPCLIENT      \
						DHCPV4CLIENT      \
                        DHCPV6CLIENT    \
                        DHCPSERVER      \
                        DHCPRELAY       \
                        PPPOESERVER     \
                        PPPOEV4SERVER     \
                        PPPOEV6SERVER     \
                        PPPOEV4V6SERVER     \
                        PPPOECLIENT     \
						PPPOEV4CLIENT     \
                        PPPOEV6CLIENT   \
                        PPPOEV4V6CLIENT   \
                        PPPOL2TPLAC     \
                        PPPOL2TPLNS     \
                        IGMPOPPPOE      \
                        IGMPODHCP       \
                        DHCPV4SERVER    \
                        DHCPV6SERVER    \
                        IPV6SLAAC       \
						802DOT1X        \
                        802DOT1XV4        \
						802DOT1XV6        \
                                            ]
        set defaultRouterId     192.168.1.1
#param collection
Deputs "Args:$args "
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -routername {                    
				    set value [::IxiaCapi::NamespaceDefine $value]
                    if { [ lsearch -exact $RouterList $value ] < 0 } {
Deputs Step10
                        set name $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestPortCreateRouter1 $value" -tag $tag
                        return $IxiaCapi::errorcode(4)                
                    }
                }
                -type -
                -routertype {
Deputs "Type arg: $value"
                    if { [ lsearch -exact $EType [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestPortCreateRouter2 $EType" -tag $tag
                        return $IxiaCapi::errorcode(1)
                    } else {
                        set type [ string toupper $value ]
Deputs "Type: $type"
                    }
                }
                -routerid {
                    if { [ IxiaCapi::Regexer::IsIPv4Address  $value ] == $TRUE } {
                            set routerId $value
Deputs "routerId: $routerId"
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestPortCreateRouter6 $value" -tag $tag
                        return $IxiaCapi::errorcode(1)
                    }
                }
                -hostname {
				    set hostname [::IxiaCapi::NamespaceDefine $value]
					set hostnum  [ $hostname cget -hostNum ]
					set hostinfo [ $hostname cget -hostInfo ]
                    #set hostname $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -RouterName -RouterType -RouterId" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# check the existence of necessary params
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateRouter4" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
        if { [ info exists type ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateRouter5 $EType" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
# Check pre-condition
        #if { ( [ AgtInvoke AgtRoutingEngine GetState ] == "AGT_ROUTING_RUNNING" ) } {
        #    IxiaCapi::Logger::LogIn -type err -message \
        #    "$IxiaCapi::s_common6" -tag $tag
        #    return $IxiaCapi::errorcode(8)
        #}
# Check whether this is a port sub-interface
Deputs "Check sub-interface flag...$this"
        set flagSubInt  [ $this isa IxiaCapi::VlanSubInt ]
        if { $flagSubInt } {
            if { [ catch {
                set vlanTag [ $this cget -VlanTag ]
                set vlanId  [ $this cget -VlanId ]
            } err ] } {
Deputs "Read Vlan info error: $err"
                set vlanTag "<undefined>"
                set vlanId  "<undefined>"
            }
        }
# Create Router...
        if { [ catch {
        switch $type {
            OSPFV2ROUTER {
                uplevel "Ospfv2Router $name $this"
				#uplevel "OspfRouter $name $this $type $routerId"
            }
            OSPFV3ROUTER {
                uplevel "Ospfv3Router $name $this"
            }
            ISISROUTER {
		        uplevel "IsisRouter $name $this"
            }
            RIPROUTER {
                uplevel "RipRouter $name $this"
            }
            RIPNGROUTER {
            }
            BGPV6ROUTER {
                uplevel "BgpV6Router $name $this"
            }
            BGPV4ROUTER {
                uplevel "BgpV4Router $name $this"
            }
            LDPROUTER {
                uplevel "LdpRouter  $name $hPort"
            }
            RSVPROUTER {
                uplevel "RsvpRouter $name $hPort"
            }
            IGMPROUTER {
                uplevel "IgmpRouter $name $this"
            }
            IGMPHOST {
			    if { [info exists hostname] } {
				   uplevel "IGMPClient $name $this $hostname "
				} else {
				   uplevel "IGMPClient $name $this "
				}
                
            }
            MLDROUTER {
            }
			MLDHOST {
			    if { [info exists hostname] } {
				   uplevel "MLDHost $name $this $hostname "
				} else {
				   uplevel "MLDHost $name $this "
				}

            }
            PIMROUTER {
                uplevel "PimRouter $name $hPort"
            }
			IPV6SLAAC {
                
				if { [info exists hostname] } {
				   uplevel "IPv6SLAACClient $name $this  "
				} else {
				   uplevel "IPv6SLAACClient $name $this "
				}
            }			
			DHCPCLIENT -
            DHCPV4CLIENT {
                uplevel "DHCPv4Client $name $this"
                # if { $flagSubInt } {
                    # uplevel "$name ConfigVlan $vlanTag $vlanId"
                # }
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "DHCP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
            DHCPV6CLIENT {
                #uplevel "DHCPv6Client $name $hPort"
                uplevel "DHCPv6Client $name $this "
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "DHCP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle "ipv6"
                # if { $flagSubInt } {
                    # uplevel "$name ConfigVlan $vlanTag $vlanId"
                # }
                # uplevel "$name ConfigRouter -DUIDType llt \
                        # -T1Timer 302400  -T2Timer 483840 \
                        # -EmulationMode iana "
            }
            DHCPV4SERVER -
            DHCPSERVER {
                uplevel "DHCPv4Server $name $this"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "DHCP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
            DHCPV6SERVER {
                uplevel "DHCPv6Server $name $this"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "DHCP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle "ipv6"
            }
            DHCPRELAY {
                uplevel "DhcpRelay  $name $this"
                if { $flagSubInt } {
                    uplevel "$name ConfigVlan $vlanTag $vlanId"
                }
            }
            PPPOEV4SERVER -
            PPPOESERVER {
                uplevel "PPPoEv4Server $name $this"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
			PPPOEV6SERVER {
                uplevel "PPPoEv6Server $name $this"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle "ipv6"
            }
            PPPOEV4V6SERVER {
                uplevel "PPPoEv4v6Server $name $this"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
                $hostname SettopHandle $pHandle "ipv6"
            }
			PPPOEV4CLIENT -
            PPPOECLIENT {
                uplevel "PPPoEv4Client $name $this"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
				$hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
			PPPOEV6CLIENT {
                uplevel "PPPoEv6Client $name $this"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle "ipv6"
            }
            PPPOEV4V6CLIENT {
                uplevel "PPPoEv4v6Client $name $this"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
                $hostname SettopHandle $pHandle "ipv6"
            }
            PPPOL2TPLAC {
                uplevel "PPPoL2TP $name $hPort"
                uplevel "$name ConfigRouter -poolmode master"
            }
            PPPOL2TPLNS {
                uplevel "PPPoL2TP $name $hPort"
                uplevel "$name ConfigRouter -poolmode slave"
            }
            IGMPOPPPOE {
                uplevel "IGMPoPPPoE $name $hPort"
            }
            IGMPODHCP {
                uplevel "IGMPoDHCP $name $hPort"
            }
			802DOT1X -
			802DOT1XV4V6 -
			802DOT1XV4 {
                uplevel "eval 802Dot1xClient $name $this"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "802DOT1X"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
			802DOT1XV6 {
                uplevel "eval 802Dot1xClient $name $this"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "802DOT1X"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle "ipv6"
            }
        }
        } ] } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        }
        # if { [ catch {
            # set sessionHandle [ uplevel "$name cget -hSession" ]
# Deputs "Set name...$sessionHandle"
            # AgtInvoke AgtTestTopology SetSessionName $sessionHandle $name
        # } ] } {
# Deputs $errorInfo
        # }
        if { [ info exists routerId ] } {
Deputs "RouterId:$routerId"
            switch $type {
                OSPFV2ROUTER -
                OSPFV3ROUTER -
                ISISROUTER -
                RIPROUTER -
                PIMROUTER -
                BGPV4ROUTER -
                BGPV6ROUTER {
Deputs "OSPF/ISIS/BGP/RIP/PIM"
                    uplevel "$name ConfigRouter -RouterId $routerId -Active enable"
                }
                default {
Deputs "Other protocol..."
                    uplevel "$name ConfigRouter -Active enable"
                }
            }
        } else {
    # default value of Router ID --
            switch $type {
                OSPFV2ROUTER -
                OSPFV3ROUTER -
                ISISROUTER -
                RIPROUTER -
                PIMROUTER -
                BGPV6ROUTER -
                BGPV4ROUTER {
                   # uplevel "$name ConfigRouter -RouterId $defaultRouterId  -Active enable"
                }
                default {
                    #uplevel "$name ConfigRouter -Active enable"
                }
            }
        }
        # if { [ info exists hostname ] } {
        
            # set hostcfg $hostargs($hostname)
# Deputs "hostargs:$hostcfg"
            # eval uplevel "$name ConfigRouter $hostcfg" 
          
        # }
        lappend RouterList $name
        IxiaCapi::Logger::LogIn -message \
        "$IxiaCapi::s_TestPortCreateRouter3 $RouterList" -tag $tag
        return $IxiaCapi::errorcode(0)        
    }
    
    body TestPort::DestroyRouter { args } {
        
        global errorInfo
        set tag "body TestPort::DestroyRouter [info script]"
Deputs "----- TAG: $tag -----"
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -routername {
				    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
                }
            }
        }
# Check pre-condition
        #if { ( [ AgtInvoke AgtRoutingEngine GetState ] == "AGT_ROUTING_RUNNING" ) } {
        #    IxiaCapi::Logger::LogIn -type err -message \
        #    "$IxiaCapi::s_common6" -tag $tag
        #    return $IxiaCapi::errorcode(8)
        #}
# Make sure the existence of the Name
    # If positive delete the certain filter
        if { [ catch {
        set err 0
        if { [ info exists name ] } {
            foreach router $name {
                set index [ lsearch -exact $RouterList $router ]

Deputs "Router list:$RouterList"
Deputs "index:$index"
                if { $index < 0 } {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_TestPortDestroyRouter1 $value" -tag $tag
                    set err 1
                } else {
                    set RouterList [ lreplace $RouterList $index $index ]
Deputs "Router list:$RouterList"
Deputs "objects:[find objects]"
                    if { [ catch { uplevel " delete object $name " } ] } {
Deputs $errorInfo
                    } else {
                        if { [ catch { uplevel " delete object ${name}_c " } ] } {
Deputs $errorInfo
                    }
                        
                    }
                }
Deputs "objects:[find objects]"
            }
        } else {
    # Or else delete all routers
            if { [ info exists RouterList ] } {
                foreach router $RouterList {
                    if { [ catch { uplevel " delete object $router " } ] } {
Deputs $errorInfo
                    } else {
                         if { [ catch { uplevel " delete object ${router}_c " } ] } {
Deputs $errorInfo
                    }
                    }
                }
                set RouterList  [ list ]
            }
        }
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        } else {
            if { $err } {
                return $IxiaCapi::errorcode(4)
            } else {
                IxiaCapi::Logger::LogIn -message \
                "$IxiaCapi::s_TestPortDestroyRouter2" -tag $tag
                return $IxiaCapi::errorcode(0)
            }
        }
    }
    
    body TestPort::StartRouter { args } {
        
        global errorInfo
        set tag "body TestPort::StartRouter [info script]"
Deputs "----- TAG: $tag -----"
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -routername -
                -routerlist {
                    set routerList [::IxiaCapi::NamespaceDefine $value]
                    #set routerList $value
                }
            }
        }
        set err 0
		ixNet exec startAllProtocols
# Start routing engine --
#       If the routing engine has been started, code will return successfully
        

# Enable router --
#       Those routers that do not belong to this TestPort will exclude from the starting list
        # if {[info exists routerList] == 0} {
            # set routerList $RouterList
        # }
        # foreach router $routerList {
# Deputs "all routers: $RouterList"
            # if { [ lsearch -exact $RouterList $router ] < 0 } {
# Deputs "not belonged router: $router"
                # set err 1
                # IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TestPortStartRouter1 $router" -tag $tag
            # } else {
# Deputs "Router to be enable: $router"
                # if { [ lsearch -exact $routerList $router ] >=0 } {
                    # set level 1
                    # if { [ catch {
                        # uplevel $level "$router Enable"
                        # } ] } {
                        # if { [ catch {
                            # incr level
                            # uplevel $level "$router Enable"
                        # } ] } {
                            # set err 1
                            # IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TestPortStartRouter1 $router" -tag $tag
# Deputs "$router"
# Deputs "$errorInfo"
                        # }
                    # }
                # } 
            # }
        # }
        if { $err } {
            return $IxiaCapi::errorcode(4)
        } else {
            return $IxiaCapi::errorcode(0)
        }
    }
    body TestPort::StopRouter { args } {
        
        global errorInfo
        set tag "body TestPort::StopRouter [info script]"
Deputs "----- TAG: $tag -----"
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -routername -
                -routerlist {
                    #set routerList $value
                    set routerList [::IxiaCapi::NamespaceDefine $value]
                }
            }
        }
        #ixTclNet::StopProtocols
		set err 0
		ixNet exec stopAllProtocols
		after 2000
        # if { [ info exists routerList ] == 0 } {
            # AgtInvoke AgtRoutingEngine Stop
            # set timeStart [ clock seconds ]
            # set state [ AgtInvoke AgtRoutingEngine GetState ]
            # while { $state != "AGT_ROUTING_STOPPED" } {
                # if { [ expr [ clock seconds ] - $timeStart ] > $IxiaCapi::WaitTimeout } {
                    # return $IxiaCapi::errorcode(10)                        
                # }
                # after 500
                # set state [ AgtInvoke AgtRoutingEngine GetState ]
            # }
            # return $IxiaCapi::errorcode(0)
        # }
# # Disable router --
# #       Those routers that do not belong to this TestPort will exclude from the starting list
        # set err 0
        # foreach router $routerList {
            # if { [ lsearch -exact $RouterList $router ] < 0 } {
                # set err 1
                # IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TestPortStartRouter1 $router" -tag $tag
            # } else {
                # if { [ lsearch -exact $routerList $router ] >=0 } {
                    # if { [ catch {
                        # uplevel "$router Disable"
                        # } ] } {
                        # IxiaCapi::Logger::LogIn -type err -message "$s_TestPortStartRouter1 $router" -tag $tag
                        # set err 1
# Deputs "$router"
# Deputs "$errorInfo"
                    # }
                # } 
            # }
        # }
# # Make a judgement that whether to close the Routing Engine
        # set closeFlag 1
        # foreach router $RouterList {
            # if { [ uplevel "$router cget -Active" ] } {
                # set closeFlag 0
# Deputs "Enable state router:$router"
                # break
            # }            
        # }
# # Stop routing engine --
# #       If the routing engine has been started, code will return successfully
# Deputs Step10
        # if { $closeFlag } {
            # set state [ AgtInvoke AgtRoutingEngine GetState ]
# Deputs Step20
            # if { ( $state != "AGT_ROUTING_STOPPED" ) } {
                # if { $state == "AGT_ROUTING_RUNNING" } {
                    # AgtInvoke AgtRoutingEngine Stop
                    # set timeStart [ clock seconds ]
                    # while { $state != "AGT_ROUTING_STOPPED" } {
                        # if { [ expr [ clock seconds ] - $timeStart ] > $IxiaCapi::WaitTimeout } {
                            # return $IxiaCapi::errorcode(10)                        
                        # }
                        # after 500
                        # set state [ AgtInvoke AgtRoutingEngine GetState ]
                    # }
                # } 
                # if { $state == "AGT_ROUTING_STOPPING" } {
                    # set timeStart [ clock seconds ]
                    # while { $state != "AGT_ROUTING_STOPPED" } {
                        # if { [ expr [ clock seconds ] - $timeStart ] > $IxiaCapi::WaitTimeout } {
                            # return $IxiaCapi::errorcode(10)                        
                        # }
                        # after 500
                        # set state [ AgtInvoke AgtRoutingEngine GetState ]
                    # }
                # }                
            # }
# Deputs Step30
        # }
        if { $err } {
            return $IxiaCapi::errorcode(4)
        } else {
            return $IxiaCapi::errorcode(0)
        }
    }
    body ETHPort::GetPortState { args } {
        
        global errorInfo
        set tag "body ETHPort::GetPortState [info script]"
Deputs "----- TAG: $tag -----"
# param collection
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -linkspeed {
                    set linkSpeed $value
                }
                -duplexmode {
                    set duplexMode $value
                }
                -autoneg {
                    set autoNeg $value
                }
                -linkstate -
                -link {
                    set linkState $value
                }
               -phystate -
                -phy {
                    set phyState $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -LinkSpeed\t-DuplexMode\t-AutoNeg\t\
                    -LinkState\t-PhyState" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        
        if { [ catch {
            if { [ info exists autoNeg ] } {
                set result [ ixNet getA $hPort/l1Config/ethernet -autoNegotiate ]
                if { $result == "True" } {
                    set result 1
                } else {
                    set result 0
                }
                uplevel 1 \
                "set $autoNeg $result"
            }
            if { [ info exists linkSpeed ] } {
                set regstr [ ixNet getA $hPort/l1Config/ethernet -speed ]
Deputs "regstr:$regstr"
                if { $regstr == "auto" } {
                    uplevel 1 "set $linkSpeed AUTO"
                } else {
                    regexp {(10|100|1000)} $regstr match ls
                        uplevel 1 "set $linkSpeed $ls"
                }
Deputs "link speed: $linkSpeed"
            }
            if { [ info exists duplexMode ] } {
                set regstr [ ixNet getA $hPort/l1Config/ethernet -speed ]
Deputs "regstr:$regstr"
                if { $regstr == "auto" } {                    
                    uplevel 1 "set $duplexMode AUTO"
                }
                regexp -nocase {(hd|fd)} $regstr  match dm
                if { $dm == "hd" } {
                    uplevel 1 "set $duplexMode HALF"
                } else {
                    uplevel 1 "set $duplexMode FULL"
                }
Deputs "duplex mode: $duplexMode"
            }
            if { [ info exists linkState ] } {
                set stateDescription \
                [ ixNet getA $hPort -state ]
                if { $stateDescription == "up" } {
                    uplevel 1 "set $linkState UP"
                } elseif { $stateDescription == "unassigned" } {
                    uplevel 1 "set $linkState NOLINK"
                } else {
                    uplevel 1 "set $linkState DOWN"
                }
            }
            if { [ info exists phyState ] } {
                uplevel 1 "set $phyState UP"
            }
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        } else {
            return $IxiaCapi::errorcode(0)
        }
        
    }
    
    body ETHPort::ConfigPort { args } {
        
        global errorInfo
        
        set tag "body ETHPort::ConfigPort [info script]"
Deputs "----- TAG: $tag -----"

        #set EMedia [ list RJ45 GBIC SFP DEFAULT ]
        set EMedia [ list COPPER FIBER ]
        set ESpeed [ list 10 100 1000 ]
        set EDuplex [ list HALF FULL ]
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -linkspeed {
                    regexp -nocase {([0-9]+)m?} $value match speed
Deputs "speed:$speed"
                    if { [ lsearch -exact $ESpeed $speed ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ETHPortConfigPort3 $ESpeed" -tag $tag
                    } else {
                        set linkSpeed [ string toupper $speed ] 
                    }
                }
                -duplexmode {
                    if { [ lsearch -exact $EDuplex [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ETHPortConfigPort4 $EDuplex" -tag $tag
                    } else {
                        set duplexMode [ string toupper $value ]
                    }
                }
                -autoneg {
                    set transAuto [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $transAuto == 1 || $transAuto == 0 } {
                        set autoNeg $transAuto
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ETHPortConfigPort1" -tag $tag
                    }
                }
                -mediatype -
                -media {
                    set type [ string toupper $value ]
                    if { [ lsearch -exact $EMedia $type ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ETHPortConfigPort2 $EMedia" -tag $tag 
                    } else {
                        set mediaType [string tolower $value]
                    }
                }
                
                -flowcontrol -
                -flow {
                    set transFlow [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $transFlow == $on || $transFlow == $off } {
                        set flowControl $transFlow
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ETHPortConfigPort4 $value" -tag $tag
                    }
                }
                -mtusize {
                    if { [ string is integer $value ] } {
                        set MTU $value
                    } 
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -LinkSpeed\t-DuplexMode\t-AutoNeg\t\
                    -FlowControl\t-MediaType" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        
        if { [ catch {

            if { [ info exists autoNeg ] } {

                if { $autoNeg } {
                    ixNet setA $hPort/l1Config/ethernet \
                        -autoNegotiate True
                } else {
                    ixNet setA $hPort/l1Config/ethernet \
                        -autoNegotiate False
                }
            }
        } result ] } {

            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            catch { unset autoNeg }
            return $IxiaCapi::errorcode(7)
        }
        if { [ catch {
            if { [ info exists mediaType ] } {

                ixNet setA $hPort/l1Config/ethernet -media $mediaType
                ixNet commit
            }
        } result ] } {

            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            catch { unset mediaType }
            return $IxiaCapi::errorcode(7)
        }
        if { [ catch {
            if { [ info exists flowControl ] } {
                if { $flowControl } {
                    ixNet setA $hPort/l1Config/ethernet -enabledFlowControl True
                } else {
                    ixNet setA $hPort/l1Config/ethernet -enabledFlowControl False
                }
            }
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            catch { unset flowControl }
            return $IxiaCapi::errorcode(7)
        } 
        if { [ catch {
            if { [ info exists autoNeg ] } {
                ixNet setA $hPort/l1Config/ethernet -speed auto
            } else {
                if { [ info exists linkSpeed ] } {
                    set speed [ ixNet getA $hPort/l1Config/ethernet -speed ]
                    if { $linkSpeed == 1000 } {
                        ixNet setA $hPort/l1Config/ethernet -speed speed1000
                    } else {
                        if { ($speed == "auto") || ($speed == "speed1000") } {
                            set duplex fd
                        } else {
                            regexp {\d+([fh]d)} $speed match duplex
                        }
                        ixNet setA $hPort/l1Config/ethernet -speed speed$linSpeed$duplex
                    }
                }
                if { [ info exists duplexMode ] } {
                    set speed [ ixNet getA $hPort/l1Config/ethernet -speed ]
                    if { [ regexp {(\d+)([fh]d)} $speed match speed duplex ] } {
                        ixNet setA $hPort/l1Config/ethernet -speed speed$speed$duplex
                    }
                }
            }
        } result ] } {

            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            catch { unset linkSpeed }
            return $IxiaCapi::errorcode(7)
        }
        return $IxiaCapi::errorcode(0)
    }
    
    body ETHPort::CreateHost { args } {
        global errorInfo

        set tag "body ETHPort::CreateHost [info script]"
Deputs "----- TAG: $tag -----"
        eval " CreateAccessHost $args "
    }
	
	body ETHPort::CreateAccessHost { args } {
        global errorInfo

        set tag "body ETHPort::CreateAccessHost [info script]"
Deputs "----- TAG: $tag -----"
        set level 1
        set UniqueMac 1
Deputs "collect parameters..."
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -hostname -
                -name {
				    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
					
                }
                -arpd {
                    set arpdTrans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $arpdTrans == 1 || $arpdTrans == 0 } {
                        set Arpd $arpdTrans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "IxiaCapi::s_ETHPortCreateHost1 $value" -tag $tag
                    }
                }
                -srcmac -
                -macaddr {
                    set value [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set MacAddr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "IxiaCapi::s_ETHPortCreateHost2 $value" -tag $tag
                    }
                }
                -sutmac {
                    set SutMac [ list ]
Deputs "SutMac List: $value "
                    foreach mac $value {
                        set mac [ IxiaCapi::Regexer::MacTrans $mac ]
Deputs "SutMac : $mac "
                        if { [ IxiaCapi::Regexer::IsMacAddress $mac ] } {
                            lappend SutMac $mac
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "IxiaCapi::s_ETHPortCreateHost3 $value" -tag $tag
                        }
                    }
Deputs "SutMac param : $SutMac "
                }
                -hostnum {
                    if { [ string is integer $value ] } {
                        set hostnum $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ETHPortCreateHost4 $value" -tag $tag
                    }
                }
                -unique -
                -uniqueflag {
                    set uniqueTrans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $uniqueTrans == 1 || $uniqueTrans == 0 } {
                        set UniqueMac $uniqueTrans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "IxiaCapi::s_ETHPortCreateHost6 $value" -tag $tag
                    }
                }
            }
        }
        
        #-----Append new vars to host obj

        if { $SubHost == 0 } {
            set HostLevel 2
        }
Deputs "HostLevel $HostLevel"
Deputs "Args: $args "
    # Collect the ipv4sutaddr list
        foreach { key value } $args {
            set keyNew [ string tolower $key ]
            switch -exact -- $keyNew {
                -sutmac {
                    set index [ lsearch -exact $args $key ]
                    set args [ lreplace $args $index [ incr index ] ]
Deputs "Value:$value\tIndex:$index\tArgs:$args "
                }
            }            
        }
        set chainResult [ eval { chain } $args ]
        if { $chainResult > 0 } {
Deputs "chain result: $chainResult"
            return $chainResult
        }
        if { [ info exists name ] == 0 } {
            return $IxiaCapi::errorcode(3)
        }
#Deputs "[find obj]"
        if { [ lsearch -exact $HostList $name ] >= 0 } {
		Deputs "HostList $HostList"

#Deputs "[find obj]"
            if { [ info exists MacAddr ] } {
                if { [ catch {
                    uplevel $level " $name SetMacAddr $MacAddr "
                } ] } {
                    incr level
                    uplevel $level " $name SetMacAddr $MacAddr "
                }
            }
Deputs "name: $name\tlevel: $level"

            if { [ info exists SutMac ] } {
Deputs "SutMac: $SutMac "
                uplevel $level " $name SetSutMac \{$SutMac\} "
            }

            if { [ info exists Arpd ] } { uplevel $level " $name SetArpd $Arpd " }

        } else {

            return $IxiaCapi::errorcode(4)
        }
        
            #-----Get Host Vars-----
        if { [ catch {
Deputs "[find obj]"

            set sutmac [ uplevel $level " $name cget -SutMac " ] 
            set mac [ IxiaCapi::Regexer::MacTrans \
                       [ uplevel $level " $name cget -MacAddr " ] ]
            set arp [ uplevel $level " $name cget -Arpd " ]
            set unique [ uplevel $level " $name cget -UniqueMac " ]
            set interface [ uplevel $level " $name cget -interface " ]
Deputs "interface:$interface"
            set ethInt $interface/ethernet
Deputs "ethernet interface: $ethInt"
            # if { [ info exists MTU ] } {
                # ixNet setMultiAttr $ethInt -mtu $MTU
            # }
            # set result [ ixNet setA $ethInt -macAddress $mac ]
# Deputs "config mac: $result"
            # ixNet commit
            # set ethInt  [ixNet remapIds $ethInt]
Deputs "ethernet interface: $ethInt"
        } result ] } {
Deputs "result: $result"
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            catch { DestroyHost -name $name }
            return $IxiaCapi::errorcode(7)
        }
        return $IxiaCapi::errorcode(0)
    }
	
	
    
    body ETHPort::CreateArpd { args } {
    }
    
    body ETHPort::DestroyArpd { } {
    }
    
    body ETHPort::ConfigArpEntry { args } {
    }
    body ETHPort::DeleteArpEntry { args } {
    }
    
    body ETHPort::StartArpd { args } {
        global errorInfo
        

        set tag "body ETHPort::StartArp [info script]"
Deputs "----- TAG: $tag -----"
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -hostname {
                    #set name $value
                    set name [::IxiaCapi::NamespaceDefine $value]
                }
                -streamname {}
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -HostName" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        
        set exist 0
        if { [ info exists name ] } {
            if { [ catch {
            foreach host $name {
                if { [ lsearch -exact $HostList $host ] >= 0 } {
                    if { [ catch {
                        set interface [ uplevel 1 " $host cget -interface " ]
                    } ] } {
                        set interface [ uplevel 2 " $host cget -interface " ]
                    }
                    ixNet exec sendArp $interface
                    set exist 1
                } else {
                    IxiaCapi::Logger::LogIn -type warn -message \
                    "$IxiaCapi::s_ETHPortStartArp3" -tag $tag
                    continue
                }
            }
            } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                return $IxiaCapi::errorcode(7)
            } else {
                if { $exist } {
                    IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_ETHPortStartArp2"\
                    -tag $tag
                    return $IxiaCapi::errorcode(0)
                } else {
                    return $IxiaCapi::errorcode(4)
                }
            }
        } else {
            if { [ catch {
                foreach host $HostList {
                    if { [ catch {
                        set interface [ uplevel 1 " $host cget -interface " ]
                    } ] } {
                        set interface [ uplevel 2 " $host cget -interface " ]
                    }
                    ixNet exec sendArp $interface
                    set exist 1
                }
            } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                return $IxiaCapi::errorcode(7)
            } else {
                if { $exist } {
                    IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_ETHPortStartArp2"\
                    -tag $tag
                    return $IxiaCapi::errorcode(0)
                } else {
                    return $IxiaCapi::errorcode(4)
                }
            }
        }
    }
    
    body ETHPort::CreateSubInt { args } {
        global errorInfo
        
        set tag "body ETHPort::CreateSubInt [info script]"
Deputs "----- TAG: $tag -----"
        
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -subintname {
                    #set name $value
					set name [::IxiaCapi::NamespaceDefine $value]
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -SubIntName" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# Check the existence of the name
        if { [info exists name] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_ETHPortCreateSubInt2" -tag $tag
                    return $IxiaCapi::errorcode(3)
        }
        if { [ lsearch -exact $VlanIntList $name ] >= 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_ETHPortCreateSubInt1 $value" -tag $tag
                    return $IxiaCapi::errorcode(4)
        }
        if { [ catch {
            set command "IxiaCapi::VlanSubInt $name $hPort"
            #namespace inscope $IxiaCapi::ObjectNamespace $command
            #eval {$IxiaCapi::ObjectNamespace$name ConfigPort} $args
            uplevel 1 " eval $command "
            uplevel 1 " eval {$name ConfigPort} $args "
			uplevel 1 " eval {$name SetPortName} $this"
            } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                    return $IxiaCapi::errorcode(7)
        }
        
        lappend VlanIntList $name
        IxiaCapi::Logger::LogIn -message \
        "$IxiaCapi::s_ETHPortCreateSubInt3" -tag $tag
                    return $IxiaCapi::errorcode(0)
    }
    body ETHPort::DestroySubInt { args } {
        global errorInfo
        

        set tag "body ETHPort::DestroySubInt [info script]"
Deputs "----- TAG: $tag -----"
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -subintname {
				    set value [::IxiaCapi::NamespaceDefine $value]
                    set index [ lsearch -exact $VlanIntList $value ]
                    if { $index < 0 } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_ETHPortDestroySubInt1 $value" -tag $tag
                        return $fail                 
                    } else {
                        set name $value
                    }
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -SubIntName" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        
        if { [ info exists name ] } {
            if { [ catch {
                set VlanIntList [ lreplace $VlanIntList $index $index ]
                #delete object ${IxiaCapi::ObjectNamespace}$name
                uplevel 1 " delete object $name "
                } result ] } {
                IxiaCapi::Logger::LogIn -type err -message \
                "$errorInfo" -tag $tag
                    return $IxiaCapi::errorcode(7)
            } else {
                IxiaCapi::Logger::LogIn -message \
                "$IxiaCapi::s_ETHPortDestroySubInt3 $name" -tag $tag
                    return $IxiaCapi::errorcode(0)
            }
        } else {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_ETHPortDestroySubInt2 $value" -tag $tag
                    return $IxiaCapi::errorcode(3)
        }
    }
    body ETHPort::StartRouter { args } {
        StartArpd
        return [ eval { chain } $args ]
    }
    body VlanSubInt::constructor { porthandle } {        
        set tag "body VlanSubInt::ctor [info script]"
Deputs "----- TAG: $tag -----"
        set hPort $porthandle
		set PortName ""
        set HostList    [ list ]
        set RouterList  [ list ]
        set ArpList [ list ]
        set VlanId 1
        set VlanTag 0x8100
        set VlanPrior 0
        #set DefaultHost $defaulthost
        #Reset
    }
    body VlanSubInt::ConfigPort { args } {
        global errorInfo
        
        set tag "body VlanSubInt::ConfigPort [info script]"
Deputs "----- TAG: $tag -----"
        set prior 0
        set err 0
        set ETag [ list 0x8100 0x88a8 0x9100 0x9200 ]
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -tag -
                -vlantag -
                -vlantype {
                    if { [ lsearch -exact $ETag $value ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_VlanSubIntConfigPort3 $ETag" -tag $tag
                        set err 1
                    } else {
                        set VlanTag $value
                    }
                }
                -prior -
                -vlanpriority {
                    if { [ string is integer $value ] } {
                        set VlanPrior $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_VlanSubIntConfigPort1 $value" -tag $tag
                        set err 1
                    }
                }
                -vlanid {
                    if { [ string is integer $value ] } {
                        set VlanId $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_VlanSubIntConfigPort2 $value" -tag $tag
                        set err 1
                    }
                }
                -qinq -
                -qinqlist {
                    if { [ catch {
                        foreach q $value {
Deputs "QinQ element: $q " 
                        }
                    }] } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_VlanSubIntConfigPort4 $value" -tag $tag
                        set err 1
                    } else {
                        set QinQList $value
                    }
                }
                -name -
                -subintname {
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -VlanTag\t-VlanPriority\t-VlanId\t-QinQList" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        if { [ llength $HostList ] > 0 } {
            foreach name $HostList {
                if { [ catch {
Deputs "Sub host exist..."
                    set interface [ uplevel 1 " $name cget -interface " ] 
                    if { [ info exists QinQList ] } {
                        set tpidlist ""
                        set vlanidlist ""
                        set priorlist ""
                        foreach QinQ $QinQList {
        Deputs $QinQ
                            foreach { tpid vlanid prior } $QinQ {
        Deputs "$tpid $vlanid $prior"
                                set tpidlist $tpidlist${tpid},
                                set vlanidlist $vlanidlist${vlanid},
                                set priorlist $priorlist${prior},
                            }
                        }
                        if { [ string length $tpidlist ] >= 2 } {
                            set tpidlist [ string range $tpidlist 0 [expr [string length $tpidlist] - 2] ]
                        }
                        if { [ string length $vlanidlist ] >= 2 } {
                            set vlanidlist [ string range $vlanidlist 0 [expr [string length $vlanidlist] - 2] ]
                        }
                        if { [ string length $priorlist ] >= 2 } {
                            set priorlist [ string range $priorlist 0 [expr [string length $priorlist] - 2] ]
                        }
                        ixNet setMultiAttrs $interface/vlan \
                            -vlanCount [llength $QinQList] \
                            -tpid $tpidlist \
                            -vlanEnable True \
                            -vlanId $vlanidlist \
                            -vlanPriority $priorlist
                            
                        catch { unset QinQList }
                    } else {
                        ixNet setMultiA $interface/vlan \
                            -vlanEnable True \
                            -vlanCount  1
                        if { [ info exists VlanTag ] } {
                            ixNet setA $interface/vlan -tpid $VlanTag
                        }
                        if { [ info exists VlanId ] } {
                            ixNet setA $interface/vlan -vlanId $VlanId
                        }
                    }
                    ixNet commit
                } ] } {
Deputs "$errorInfo"
                    set err 1
                    continue
                }
            }
        }
        if { $err } {
            return $IxiaCapi::errorcode(1)
        }
        return $IxiaCapi::errorcode(0)
    }
    
    body VlanSubInt::CreateHost { args } {
         
        global errorInfo
        set tag "body VlanSubInt::CreateHost [info script]"
Deputs "----- TAG: $tag -----"
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -hostname {
				    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
                }
            }
        }
# Check the existence of name
Deputs Step10
        set HostLevel 3
        set SubHost 1
        set chainResult [ eval { chain } $args ]
        if { $chainResult > 0 } {
            return $chainResult
        }
        set SubHost 0
Deputs Step20
        if { [ info exists name ] == 0 } {
                    return $IxiaCapi::errorcode(3)
        }
        if { [ lsearch -exact $HostList $name ] < 0 } {
                    return $IxiaCapi::errorcode(4)
        }
# Enable Vlan
        if { [ catch {
Deputs Step30
Deputs [ find object ]
            set interface [ uplevel " $name cget -interface " ]
            if { [ info exists QinQList ] } {
Deputs Step40
                set tpidlist ""
                set vlanidlist ""
                set priorlist ""
                foreach QinQ $QinQList {
Deputs $QinQ
                    foreach { tpid vlanid prior } $QinQ {
Deputs "$tpid $vlanid $prior"
                        set tpidlist $tpidlist${tpid},
                        set vlanidlist $vlanidlist${vlanid},
                        set priorlist $priorlist${prior},
                    }
                }
                if { [ string length $tpidlist ] >= 2 } {
                    set tpidlist [ string range $tpidlist 0 [expr [string length $tpidlist] - 2] ]
                }
                if { [ string length $vlanidlist ] >= 2 } {
                    set vlanidlist [ string range $vlanidlist 0 [expr [string length $vlanidlist] - 2] ]
                }
                if { [ string length $priorlist ] >= 2 } {
                    set priorlist [ string range $priorlist 0 [expr [string length $priorlist] - 2] ]
                }
Deputs "tpidlist:$tpidlist vlanidlist:$vlanidlist priorlist:$priorlist"
                ixNet setMultiAttrs $interface/vlan \
                    -vlanCount [llength $QinQList] \
                    -tpid $tpidlist \
                    -vlanEnable True \
                    -vlanId $vlanidlist \
                    -vlanPriority $priorlist
                    
                catch { unset QinQList }
            } else {
Deputs Step50
                if { [ info exists VlanId ] == 0 } {
Deputs Step60
                    set VlanId 1
                }
                if { [ info exists VlanTag ] } {
Deputs Step70
                    ixNet setMultiAttrs $interface/vlan \
                        -vlanEnable True \
                        -vlanCount 1 \
                        -tpid $VlanTag \
                        -vlanId $VlanId
                } else {
Deputs Step80
                    ixNet setMultiAttrs $interface/vlan \
                        -vlanEnable True \
                        -vlanCount 1 \
                        -vlanId $VlanId
                }
            }
            ixNet commit
            StartArpd
        } result ] } {
Deputs destroysuccess
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            catch { unset QinQList }
            catch { uplevel 2 "delete object $name" } result
Deputs $result
Deputs destroysuccess
            return $IxiaCapi::errorcode(7)
        }
        return $IxiaCapi::errorcode(0)
    }
	
	body VlanSubInt::CreateAccessHost { args } {
         
        global errorInfo
        set tag "body VlanSubInt::CreateAccessHost [info script]"
Deputs "----- TAG: $tag -----"
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -hostname {
				    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
                }
            }
        }
# Check the existence of name
Deputs Step10
        set HostLevel 3
        set SubHost 1
        set chainResult [ eval { chain } $args ]
        if { $chainResult > 0 } {
            return $chainResult
        }
        set SubHost 0
Deputs Step20
        if { [ info exists name ] == 0 } {
                    return $IxiaCapi::errorcode(3)
        }
        if { [ lsearch -exact $HostList $name ] < 0 } {
                    return $IxiaCapi::errorcode(4)
        }
# Enable Vlan
        if { [ catch {
Deputs Step30
Deputs [ find object ]
            set interface [ uplevel " $name cget -interface " ]
            if { [ info exists QinQList ] } {
Deputs Step40
                set tpidlist ""
                set vlanidlist ""
                set priorlist ""
                foreach QinQ $QinQList {
Deputs $QinQ
                    foreach { tpid vlanid prior } $QinQ {
Deputs "$tpid $vlanid $prior"
                        set tpidlist $tpidlist${tpid},
                        set vlanidlist $vlanidlist${vlanid},
                        set priorlist $priorlist${prior},
                    }
                }
                if { [ string length $tpidlist ] >= 2 } {
                    set tpidlist [ string range $tpidlist 0 [expr [string length $tpidlist] - 2] ]
                }
                if { [ string length $vlanidlist ] >= 2 } {
                    set vlanidlist [ string range $vlanidlist 0 [expr [string length $vlanidlist] - 2] ]
                }
                if { [ string length $priorlist ] >= 2 } {
                    set priorlist [ string range $priorlist 0 [expr [string length $priorlist] - 2] ]
                }
Deputs "tpidlist:$tpidlist vlanidlist:$vlanidlist priorlist:$priorlist"
                ixNet setMultiAttrs $interface/vlan \
                    -vlanCount [llength $QinQList] \
                    -tpid $tpidlist \
                    -vlanEnable True \
                    -vlanId $vlanidlist \
                    -vlanPriority $priorlist
                    
                catch { unset QinQList }
            } else {
Deputs Step50
                if { [ info exists VlanId ] == 0 } {
Deputs Step60
                    set VlanId 1
                }
                if { [ info exists VlanTag ] } {
Deputs Step70
                    ixNet setMultiAttrs $interface/vlan \
                        -vlanEnable True \
                        -vlanCount 1 \
                        -tpid $VlanTag \
                        -vlanId $VlanId
                } else {
Deputs Step80
                    ixNet setMultiAttrs $interface/vlan \
                        -vlanEnable True \
                        -vlanCount 1 \
                        -vlanId $VlanId
                }
            }
            ixNet commit
            StartArpd
        } result ] } {
Deputs destroysuccess
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            catch { unset QinQList }
            catch { uplevel 2 "delete object $name" } result
Deputs $result
Deputs destroysuccess
            return $IxiaCapi::errorcode(7)
        }
        return $IxiaCapi::errorcode(0)
    }
	
	body VlanSubInt::CreateRouter { args } {
        global errorInfo
        set TRUE 1

        set tag "body VlanSubInt::CreateRouter [info script]"
Deputs "----- TAG: $tag -----"
        set EType [ list                \
                        OSPFV2ROUTER    \
                        ISISROUTER      \
                        RIPROUTER       \
                        BGPV6ROUTER     \
                        BGPV4ROUTER     \
                        LDPROUTER       \
                        RSVPROUTER      \
                        IGMPROUTER      \
                        IGMPHOST        \
                        MLDROUTER       \
						MLDHOST         \
                        PIMROUTER       \
                        DHCPV4CLIENT      \
						DHCPCLIENT      \
                        DHCPV4SERVER    \
                        DHCPSERVER      \
                        DHCPRELAY       \
                        PPPOESERVER     \
						PPPOEV4SERVER   \
						PPPOEV6SERVER   \
                        PPPOEV4V6SERVER   \
                        PPPOECLIENT     \
						PPPOEV4CLIENT     \
                        PPPOEV6CLIENT   \
                        PPPOEV4V6CLIENT   \
                        PPPOL2TPLAC     \
                        PPPOL2TPLNS     \
                        IGMPOPPPOE      \
                        IGMPODHCP       \
                        DHCPV6CLIENT    \
                        DHCPV6SERVER    \
                        IPV6SLAAC       \
                        802DOT1X        \
						802DOT1XV4        \
						802DOT1XV6        \
                                            ]
        set defaultRouterId     192.168.1.1
#param collection
Deputs "Args:$args "
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -routername {                    
				    set value [::IxiaCapi::NamespaceDefine $value]
                    if { [ lsearch -exact $RouterList $value ] < 0 } {
Deputs Step10
                        set name $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestPortCreateRouter1 $value" -tag $tag
                        return $IxiaCapi::errorcode(4)                
                    }
                }
                -type -
                -routertype {
Deputs "Type arg: $value"
                    if { [ lsearch -exact $EType [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestPortCreateRouter2 $EType" -tag $tag
                        return $IxiaCapi::errorcode(1)
                    } else {
                        set type [ string toupper $value ]
Deputs "Type: $value"
                    }
                }
                -routerid {
                    if { [ IxiaCapi::Regexer::IsIPv4Address  $value ] == $TRUE } {
                            set routerId $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestPortCreateRouter6 $value" -tag $tag
                        return $IxiaCapi::errorcode(1)
                    }
                }
                -hostname {
				    set hostname [::IxiaCapi::NamespaceDefine $value]
					set hostnum  [ $hostname cget -hostNum ]
					set hostinfo [ $hostname cget -hostInfo ]
                    #set hostname $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -RouterName -RouterType -RouterId" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# check the existence of necessary params
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateRouter4" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
        if { [ info exists type ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_common1 $IxiaCapi::s_TestPortCreateRouter5 $EType" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
# Check pre-condition
        #if { ( [ AgtInvoke AgtRoutingEngine GetState ] == "AGT_ROUTING_RUNNING" ) } {
        #    IxiaCapi::Logger::LogIn -type err -message \
        #    "$IxiaCapi::s_common6" -tag $tag
        #    return $IxiaCapi::errorcode(8)
        #}
# Check whether this is a port sub-interface
Deputs "Check sub-interface flag...$this"
        set flagSubInt  [ $this isa IxiaCapi::VlanSubInt ]
        if { $flagSubInt } {
            if { [ catch {
                set vlanTag [ $this cget -VlanTag ]
                set vlanId  [ $this cget -VlanId ]
            } err ] } {
Deputs "Read Vlan info error: $err"
                set vlanTag "<undefined>"
                set vlanId  "<undefined>"
            }
        }
# Create Router...
        if { [ catch {
        switch $type {
            IGMPROUTER {
                uplevel "IgmpRouter $name $PortName"
            }
            IGMPHOST {
                uplevel "IGMPClient $name $PortName"
            }
            MLDROUTER {
            }
			MLDHOST {
			    if { [info exists hostname] } {
				   uplevel "MLDHost $name $PortName $hostname "
				} else {
				   uplevel "MLDHost $name $PortName "
				}

            }
			BGPV4ROUTER {
			    uplevel "BgpV4Router $name $PortName"
			}
			ISISROUTER {
		        uplevel "IsisRouter $name $PortName"
            }
			OSPFV2ROUTER {
			    uplevel "Ospfv2Router $name $PortName"
			}
            PIMROUTER {
                uplevel "PimRouter $name $PortName"
            }
            DHCPV4CLIENT {
                uplevel "DHCPv4Client $name $PortName "
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "DHCP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
            DHCPV6CLIENT {
                #uplevel "DHCPv6Client $name $hPort"
                uplevel "DHCPv6Client $name $PortName "
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "DHCP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
                # if { $flagSubInt } {
                    # uplevel "$name ConfigVlan $vlanTag $vlanId"
                # }
                # uplevel "$name ConfigRouter -DUIDType llt \
                        # -T1Timer 302400  -T2Timer 483840 \
                        # -EmulationMode iana "
            }
			DHCPV4SERVER -
            DHCPSERVER {
                uplevel "DHCPv4Server $name $PortName"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "DHCP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
            DHCPV6SERVER {
                uplevel "DHCPv6Server $name $PortName"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "DHCP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
            DHCPRELAY {
                uplevel "DhcpRelay  $name $PortName"
                if { $flagSubInt } {
                    uplevel "$name ConfigVlan $vlanTag $vlanId"
                }
            }
			PPPOEV4SERVER -
            PPPOESERVER {
                uplevel "PPPoEv4Server $name $PortName"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
			PPPOEV6SERVER {
                uplevel "PPPoEv6Server $name $PortName"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
            PPPOEV4V6SERVER {
                uplevel "PPPoEv4v6Server $name $PortName"
                Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
			PPPOEV4CLIENT -
            PPPOECLIENT {
                uplevel "PPPoEv4Client $name $PortName"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
			PPPOEV6CLIENT {
                uplevel "PPPoEv6Client $name $PortName"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
            PPPOEV4V6CLIENT {
                uplevel "PPPoEv4v6Client $name $PortName"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo " 
                $hostname SettopStack "PPP"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
            PPPOL2TPLAC {
                uplevel "PPPoL2TP $name $PortName"
                uplevel "$name ConfigRouter -poolmode master"
            }
            PPPOL2TPLNS {
                uplevel "PPPoL2TP $name $PortName"
                uplevel "$name ConfigRouter -poolmode slave"
            }
            IGMPOPPPOE {
                uplevel "IGMPoPPPoE $name $PortName"
            }
            IGMPODHCP {
                uplevel "IGMPoDHCP $name $PortName"
            }
			802DOT1X -
			802DOT1XV4 -
			802DOT1XV4V6  {             
				uplevel "eval 802Dot1xClient $name $PortName"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "802DOT1X"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle
            }
			802DOT1XV6 {
                uplevel "eval 802Dot1xClient $name $PortName"
				Deputs "-----------hostinfo : $hostinfo"
				uplevel "eval $name ConfigRouter $hostinfo "
				$hostname SettopStack "802DOT1X"
				set pName [$name cget -objName]
				set pHandle [$pName cget -handle]
				puts "pHandle $pHandle"
				$hostname SettopHandle $pHandle "ipv6"
            }
        }
        } ] } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        }
        # if { [ catch {
            # set sessionHandle [ uplevel "$name cget -hSession" ]
# Deputs "Set name...$sessionHandle"
            # AgtInvoke AgtTestTopology SetSessionName $sessionHandle $name
        # } ] } {
# Deputs $errorInfo
        # }
        if { [ info exists routerId ] } {
Deputs "RouterId:$routerId"
            switch $type {
                OSPFV2ROUTER -
                ISISROUTER -
                RIPROUTER -
                PIMROUTER -
                BGPV4ROUTER {
Deputs "OSPF/ISIS/BGP/RIP/PIM"
                    uplevel "$name ConfigRouter -RouterId $routerId -Active enable"
                }
                default {
Deputs "Other protocol..."
                    uplevel "$name ConfigRouter -Active enable"
                }
            }
        } else {
    # default value of Router ID --
            switch $type {
                OSPFV2ROUTER -
                ISISROUTER -
                RIPROUTER -
                PIMROUTER -
                BGPV4ROUTER {
                    uplevel "$name ConfigRouter -RouterId $defaultRouterId  -Active enable"
                }
                default {
                    uplevel "$name ConfigRouter -Active enable"
                }
            }
        }
        # if { [ info exists hostname ] } {
        
            # set hostcfg $hostargs($hostname)
# Deputs "hostargs:$hostcfg"
            # eval uplevel "$name ConfigRouter $hostcfg" 
          
        # }
        lappend RouterList $name
        IxiaCapi::Logger::LogIn -message \
        "$IxiaCapi::s_TestPortCreateRouter3 $RouterList" -tag $tag
        return $IxiaCapi::errorcode(0)        
    }
	
	
	
    body VlanSubInt::destructor {} {
        global errorInfo
        set tag "body VlanSubInt::destructor [info script]"
Deputs "----- TAG: $tag -----"
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
            return $IxiaCapi::errorcode(8)
        }
        # catch {
            # foreach host $HostList {
                # DestroyHost -name $host
            # }
            # IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortDector1 $hPort"            
        # }
    }
    proc RefreshCapture {} {
        set testPortList [ IxiaCapi::PortManager cget -TestPortList ]
Deputs "testPortList:$testPortList"
        foreach {port hPort} $testPortList {
            set portObj [ IxiaCapi::Regexer::GetObject $port ]
Deputs "port obj:$portObj"
            set AnaEngine [ $portObj cget -AnaEngine ]
Deputs "anaEngine:$AnaEngine"
                if { [ info exists AnaEngine ] && ( $AnaEngine != "" ) && ( $AnaEngine != "<undefined>" ) } {

                    set anaObj [IxiaCapi::Regexer::GetObject $AnaEngine]
Deputs "anaObj:$anaObj"
                    set anaState [ $anaObj cget -state ]
Deputs "state:$anaState"
                    if { $anaState } {
Deputs "capture restart..."
                        ixNet exec stop $hPort/capture
						ixNet exec closeAllTabs
                        ixNet exec start $hPort/capture
                        break
                    }
                }
        }
    }
}