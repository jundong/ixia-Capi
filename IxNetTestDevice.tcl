# IxNetTestDevice.tcl --
#   This file implements the TestDevice class for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made

namespace eval IxiaCapi {
    class TestDevice {
        namespace export *
        constructor { {ipaddress null} {sessionlabel SYSTEM} } {}
        method Connect { args } {}
        method Disconnect { } {}
        method StartTraffic { { args all } } {}
        method StopTraffic { { args all } } {}
        method StartTest { args } {}
        method StopTest { args } {}
        method CreateTestPort { args } {}
        method DestroyTestPort { args } {}
        method GetTestState { args } {}
        method WaitUntilTestStops { args } {}
        method ResetSession {} {}
        method CleanupTest {} {}
        method ForceReleasePort { args } {}
        destructor {}
        
        private variable chassis
        private variable PortList
        method ListPorts {} {
            puts $PortList            
        }
        method GetPortList {} {
            return $PortList
        }
    }

    body TestDevice::ResetSession {} {
	    set tag "body TestDevice::ResetSession [info script]"
Deputs "----- TAG: $tag -----"
        global errorInfo
   		
		foreach portObj $PortList {           
Deputs "port obj:$portObj reset"
            $portObj Reset
        }
		#IxiaCapi::PortManager Reset
        IxiaCapi::TrafficManager Reset
        set objects [ find objects ]
Deputs "obj:$objects"
        #how to avoid deleting itself...
        foreach obj $objects {
#Deputs "Judge Objects:$obj"
            # if { [ lsearch -exact [ find objects ] $obj ] < 0 } {
# #Deputs "deleted continue...$obj"
                # continue
            # }
            # avoid to deleting the object out of the IxiaCapi
#Deputs "Filter the object which is not created by IxiaCapi"
            set outObject   1
#Deputs "Class:[$obj info class]"
            foreach class $IxiaCapi::ResetSessionClass {
#Deputs "regexp result:$class [regexp $class [ $obj info class ]]"
                if { [ regexp $class [ $obj info class ] ] } {
                    set outObject 0
                    break
                }
            }
            if { $outObject } {
                continue
            }
            
            set isTD [ $obj isa IxiaCapi::TestDevice ]
            if { $isTD > 0 } {
Deputs "TestDevice continue...$obj"
                continue
            }
                       
			
			if { [ regexp "DeviceManager" $obj ] ||
                [ regexp "PortManager" $obj ] ||
                [ regexp "TrafficManager" $obj ] ||
                [ regexp "StatsManager" $obj ]  || 
				([ $obj isa IxiaCapi::TestPort ] &&![$obj isa IxiaCapi::VlanSubInt])
                 }   {
Deputs "Manager continue...$obj"
                continue
            } else {

Deputs "delete:$obj"
                if { [ lsearch -exact [find objects] $obj ] >=0 } {
                    catch {
                        delete object $obj
						set objects [ find objects ]
#Deputs "obj:$objects"
                    }
                }
            }
        }
        
    }
    body TestDevice::CleanupTest {} {
       
Deputs "----- TAG: CleanupTest -----"
        global errorInfo
        ResetPCFlag
        if { [ catch {			
			IxiaCapi::TrafficManager Reset
            set objects [ find objects ]
Deputs "obj:$objects"
        #how to avoid deleting itself...
            foreach obj $objects {
#Deputs "Judge Objects:$obj"
                if { [ lsearch -exact [ find objects ] $obj ] < 0 } {
#Deputs "deleted continue...$obj"
                    continue
                }
                # avoid to deleting the object out of the IxiaCapi
#Deputs "Filter the object which is not created by IxiaCapi"
                set outObject   1
#Deputs "Class:[$obj info class]"
                foreach class $IxiaCapi::ResetSessionClass {
#Deputs "regexp result:$class [regexp $class [ $obj info class ]]"
                    if { [ regexp $class [ $obj info class ] ] } {
                        set outObject 0
                        break
                    }
                }
                if { $outObject } {
                    continue
                }
                
                    
                if { [ regexp "DeviceManager" $obj ] ||
                    [ regexp "PortManager" $obj ] ||
                    [ regexp "TrafficManager" $obj ] ||
                    [ regexp "StatsManager" $obj ] }   {    
    Deputs "Manager continue...$obj"
                    continue
                } else {
    Deputs "delete:$obj"
                    if { [ lsearch -exact [find objects] $obj ] >=0 } {
                        catch {
                            delete object $obj
                        }
                    }
                }
            }
		    IxiaCapi::PortManager Reset
		    ixNet exec newConfig ;# execute a new configuration
        } result ] } {
            return 1
        }
        return 0
    }


    # The hostname should be case sensitive 
    body TestDevice::constructor { {ipaddress null} {sessionlabel SYSTEM} } {
        set tag "body TestDevice::Ctor [info script]"
Deputs "----- TAG: $tag -----"
        global gOffline
        set hConnect -1
        set PortList [ list ]
        
        if { $ipaddress == "null" } {
            IxiaCapi::Logger::LogIn -type warn -message $IxiaCapi::s_TestDeviceCtor1 -tag $tag 
        } else {
            Connect -ipaddr $ipaddress -label $sessionlabel 
        }                    
    }
    
    body TestDevice::destructor { } {
        global errorInfo
        set tag "body TestDevice::destructor [info script]"
Deputs "----- TAG: $tag -----"
        catch {
            DestroyTestPort
        }
        catch {
            Disconnect
        }
    }
    
    body TestDevice::Connect { args } {
        
        # to see more infomation about the following global params, see DefaultConfigue.tcl        
        global IxiaCapi::TRUE IxiaCapi::FALSE IxiaCapi::success IxiaCapi::fail IxiaCapi::on IxiaCapi::off
        global IxiaCapi::ConnectDefaultSession IxiaCapi::ConnectRetries \
        IxiaCapi::CheckUserPermit IxiaCapi::RetryConnection IxiaCapi::DefaultHost
        
        global errorInfo 
        global gOffline
        
        set ipCheck $FALSE
        set sessionLabel SYSTEM
        set ipaddress 127.0.0.1
        set offline 0
        set port 8009
        set localhost localhost
        set tag "body TestDevice::Connect [info script]"
Deputs "----- TAG: $tag -----"
        
        # To fix case TestDevice_009
        #Disconnect
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -ipaddr {
                    set ipaddress $value
                    set ipCheck $TRUE
                    IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceConnect1 $ipaddress"
                    
                }
                -label {
                    set sessionLabel $value
                }
                -port {
                    set port $value
                }
                -localhost {
                    set localhost $value
                }                               
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -ipaddr\t-label" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        
# set hostname
Deputs "Connect $localhost ixNetwork Tcl Server "
        ixNet connect $localhost -version [ixNet getVersion] -port 8009;# connect to tclserver
Deputs "Create a new Config"
        ixNet exec newConfig ;# execute a new configuration

        if { $gOffline == 1 } {
		    set chassis 0
        } else {
            set root  [ixNet getRoot]
            set chassis [ixNet add $root/availableHardware chassis]
Deputs "chassis:$chassis"
Deputs "$ipCheck == $TRUE"
            if { $ipCheck == $TRUE } {
                ixNet setAttribute $chassis -hostname $ipaddress ;#connect to chsssis
                
                if { [ catch { ixNet commit } result ] } {
                    IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                    return $IxiaCapi::errorcode(7)
                }
                set chassis [ixNet remapIds $chassis]

            } else {
    #Deputs "off:$off"
                if {$ConnectDefaultSession == $off} {
                    IxiaCapi::Logger::LogIn -type warn -message "$IxiaCapi::s_TestDeviceConnect2 $IxiaCapi::s_TestDeviceConnect4"
                    return $IxiaCapi::errorcode(3)
                } else {
                    ixNet setAttribute $chassis -hostname $DefaultHost
                    if { [ catch { ixNet commit } result ] } {
                        IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                        return $IxiaCapi::errorcode(7)
                    }                
                    set chassis [ixNet remapIds $chassis]
                }
            }
            
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceConnect3 \n address:$ipaddress \n chassis: $chassis"
            return $IxiaCapi::errorcode(0)
        }
    }
      
    body TestDevice::Disconnect { } {
        global errorInfo
        set tag "body TestDevice::Disonnect [info script]"
Deputs "----- TAG: $tag -----"
        if { [ catch {
            ixNet exec newConfig ;# execute a new configuration
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag                            
            return $IxiaCapi::errorcode(7)
        } else {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceDisconnect1 $chassis"            
            return $IxiaCapi::errorcode(0)
        }
    }
    
    body TestDevice::StartTest { args } {
        global IxiaCapi::fail IxiaCapi::success
        global errorInfo
        
        set tag "body TestDevice::StartTest [info script]"        
Deputs "----- TAG: $tag -----"

        if { [ catch {
            eval { StartTraffic } $args
            #...to add router etc.
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        } else {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceStartTest1"
            return $IxiaCapi::errorcode(0)
        }
    }
       
    body TestDevice::StopTest { args } {
        global IxiaCapi::fail IxiaCapi::success
        global errorInfo
        set tag "body TestDevice::StopTest [info script]"        
Deputs "----- TAG: $tag -----"

        if { [ catch {
            eval { StopTraffic } $args
            #...to add router etc.
        } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "errorInfo" -tag $tag
            return $IxiaCapi::errorcode(7)
        } else {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceStopTest1"
            return $IxiaCapi::errorcode(0)
        }
    }
    
    body TestDevice::CreateTestPort { args } {
        # to see more infomation about the following global params, see DefaultConfigue.tcl        
        global IxiaCapi::fail IxiaCapi::success
        global errorInfo
		global gOffline
        
        set tag "body TestDevice::CreateTestPort [info script]"
Deputs "----- TAG: $tag -----"
Deputs "args: $args"
# Param collection
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -portlocation -
                -location -
                -loc {
                    if { [regexp {([0-9]+)/([0-9]+)} $value match moduleNo portNo] } {
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestDeviceCreateTestPort1 $value" -tag $tag
                        return $IxiaCapi::errorcode(1)
                    }
					if { $gOffline == 1 } {
					    set moduleNo 0
						set portNo 0
					}
                }
                -portname -
                -name {
                    #set value [::IxiaCapi::NamespaceDefine $value]
                    if { [ lsearch -exact $PortList $value ] < 0 } {    
                        set name $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestDeviceCreateTestPort5 $value" -tag $tag
                        return $IxiaCapi::errorcode(4)
                    }
                }
                -porttype -
                -type {
                    set type $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -portlocation\t-portname\t-porttype" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# Make sure the necessary params has been assigned
    # ----- Location -----
        if { [ info exist moduleNo ] == 0 || [ info exist portNo ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_TestDeviceCreateTestPort2" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
    # ----- Name -----
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_TestDeviceCreateTestPort3" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
    # ----- Type -----
        if { [ info exists type ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_TestDeviceCreateTestPort4" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
# Type mapping
        set type [string tolower $type]
        switch -exact -- $type {
            ethernet -
            eth {
                set command "IxiaCapi::ETHPort $name $chassis $moduleNo $portNo"
                set type Ethernet
            }
            pos -
            pos3 -
            pos12 -
            pos48 -
            pos192 {
                set command "IxiaCapi::POSPort $name $chassis $moduleNo $portNo"
                if { $type != "pos" } {
                    set subType $type
                }
                set type POS
            }
            atm -
            atm155 -
            atm622 {
                set command "IxiaCapi::ATMPort $name $chassis $moduleNo $portNo"
                if { $type != "atm" } {
                    set subType $type
                }
                set type ATM
            }
            default {
                IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TestDeviceCreateTestPort8" \
                -tag $tag
            }
        }
        if { [ info exists command ] } {
Deputs $command
			eval $command
			
# -- set port configuration when the type of port is pos3, pos12, pos48, pos192, atm155, atm622
            if { [ info exists subType ] } {
Deputs "Type: $subType "
                switch -exact -- $subType {
                    pos3 -
                    atm155 {
                        #uplevel 1 "$name ConfigPort -framingmode OC3"
						$name ConfigPort -framingmode OC3
                    }
                    pos12 -
                    atm622 {
                        #uplevel 1 "$name ConfigPort -framingmode OC12"
						$name ConfigPort -framingmode OC12
                    }
                    pos48 {
                        #uplevel 1 "$name ConfigPort -framingmode OC48"
						$name ConfigPort -framingmode OC48
                    }
                    pos192 {
                        #uplevel 1 "$name ConfigPort -framingmode OC192"
						$name ConfigPort -framingmode OC192
                    }
                }
            }
            
			lappend PortList $name
# -- obsolete: var create on up level
            #IxiaCapi::PortManager AddTestPort $name \
            #[ ${IxiaCapi::ObjectNamespace}$name cget -hPort ]
            #set handle [ uplevel 1 " $name cget -hPort " ]
			set handle [ $name cget -hPort  ]
Deputs "port handle:$handle\tname:$name"
            IxiaCapi::PortManager AddTestPort $name $handle
            IxiaCapi::Logger::LogIn -message \
            "$IxiaCapi::s_TestDeviceCreateTestPort7 $type"
            return $IxiaCapi::errorcode(0)
        } else {
            return $IxiaCapi::errorcode(5)
        }
    }
    
    
    body TestDevice::DestroyTestPort { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::TRUE IxiaCapi::FALSE
        global errorInfo
        
        set tag "body TestDevice::DestroyTestPort [info script]"
Deputs "----- TAG: $tag -----"
        
# Make sure the traffic engine is stopped
#Deputs Step10
#        ixTclNet::StopTraffic
#Deputs Step20
#        ixTclNet::StopProtocols
# Param collection

        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -ports -
                -list -
                -portlist -
                -portname -
                -name {
				    set delList $value
                    #set delList [::IxiaCapi::NamespaceDefine $value]
                    #set delList [ IxiaCapi::NamespaceConvert $value $PortList ]                  
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -portname" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
if { [ info exists delList ] == 0 } {
            set delList $PortList

        }
# Destroy TestPort obj
        set exist 0
        set warn 0
Deputs "remove $delList"
        foreach {delPort} $delList {
    # Check the existence of the obj to be destroyed
    # If negative an error will be occured
            if { [ lsearch -exact $PortList $delPort ] < 0 } {

                IxiaCapi::Logger::LogIn -type warn -message "$IxiaCapi::s_common1 \n\t \
                $IxiaCapi::s_TestDeviceDestroyTestPort1 $delPort" -tag $tag
                set warn 1
                continue
            }
    # If positive to destroy it
            if { [ catch {
                set delIndex [ lsearch -exact $PortList $delPort ]
                if { $delIndex >= 0 } {
                    set PortList [ lreplace $PortList $delIndex $delIndex ]
                }
                catch {
                    IxiaCapi::PortManager DeleteTestPort -name $delPort
                }
#Deputs [IxiaCapi::PortManager cget -TestPortHandleList]
#Deputs [IxiaCapi::PortManager cget -TestPortList]
                if { [ catch { uplevel 1 " delete object $delPort " } ] } {
                    if { [ catch { uplevel 2 " delete object $delPort " } ] } {
                        catch { uplevel 3 " delete object $delPort " }
                    } 
                } 
            } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                return $fail
            } else {
                IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceDestroyTestPort2 \n\t \
                Port List : $PortList"
            }
            set exist 1
        }
        if { $exist == 0 } {
            if { $warn } {
                return $IxiaCapi::errorcode(4)
            }
            return $IxiaCapi::errorcode(3)
        }
        return $success
    }
    
    body TestDevice::StartTraffic { args } {
        global errorInfo
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::TRUE IxiaCapi::FALSE
        global IxiaCapi::PortManager
        set tag "body TestDevice::StartTraffic [info script]"        
Deputs "----- TAG: $tag -----"
Deputs "args: $args"

# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -ports -
                -portlist -
                -list -
                -name -
                -port {
                    #set startList [::IxiaCapi::NamespaceDefine $value]				   
                    set startList $value
Deputs "portlist value $value"
					
                }
				-streamnamelist {
                    set streamstartList [::IxiaCapi::NamespaceDefine $value]
Deputs "streamlist value $streamstartList"
					
                }
                -duration -
                -time {
                }
                -clearstatistics {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == $enable || $trans == $disable } {
                        set clearStats $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_TestDeviceStartTraffic6 $trans" -tag $tag                        
                    }
                }
            }
        }
        if { [ info exists clearStats ] } {
            if { [ catch {
                if { $clearStats } {
                    ixNet exec clearStats
                }
            } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                return $IxiaCapi::errorcode(7)
            }            
        }
# Check the existence of start list
# If negative start all 
        if { [info exists startList] == 0 && [info exists streamstartList] == 0 } {
			Tester::start_traffic
        } else {
# Or else start certain port
            if { [info exists startList] } {
				if { [ catch {
					set exist 0
					foreach port $startList {
						if { [ lsearch -exact $PortList $port ] >= 0 } {
Deputs "Port: $port "
							if { [ catch {
								set tra [ uplevel "[ uplevel "$port cget -Traffic" ] isa TrafficEngine" ]
							} ] } {
Deputs "Error occured:$errorInfo"
								continue
							}
Deputs "Traffic: $tra"
							if { $tra == 0 } { continue }
							#uplevel 1 " $port StartTraffic "
							$port StartTraffic
							set exist 1
						} else {
							IxiaCapi::Logger::LogIn -type warn -message \
							"$IxiaCapi::s_TestDeviceStartTraffic5 $port"
						}
					}
					} result ] } {

					IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
					return $IxiaCapi::errorcode(7)
				} else {
					if { $exist } {
						IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceStartTraffic1 $startList"
						return $IxiaCapi::errorcode(0)
					} else {
						IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceStartTraffic3"
						return $IxiaCapi::errorcode(4)
					}
				}
			}
			if {[ info exists streamstartList ] } {
			    set restartCapture 0
				set restartCaptureJudgement 0
				set root [ixNet getRoot]
				set portList [ ixNet getL $root vport ]
				foreach hPort $portList {
					if { [ ixNet getA $hPort/capture    -hardwareEnabled  ] } {
						set restartCapture 1
						break
					}
				}
			    set flowList ""
			    foreach stream $streamstartList {
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
						lappend flowList $strObj
											
					} ] } {
						IxiaCapi::Logger::LogIn -type warn \
						-message "$IxiaCapi::s_TestPortStartTraffic6 $stream" -tag $tag
						continue
					}
				}
				if { $restartCaptureJudgement } {
					catch { 
						
						Deputs "start capture..."
						ixNet exec startCapture
						after 2000
					}
				}
				ixNet exec startStatelessTraffic $flowList
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
			}
		}
    }
    
    
    body TestDevice::StopTraffic { args } {
        
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::TRUE IxiaCapi::FALSE
        global errorInfo
        global IxiaCapi::PortManager
        
        set tag "body TestDevice::StopTraffic [info script]"        
Deputs "----- TAG: $tag -----"
Deputs "args: $args "
# Param collection --         
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -ports -
                -portlist -
                -list -
                -name -
                -port {
                    set stopList $value
                    #set stopList [::IxiaCapi::NamespaceDefine $value]
					#set stopList [ IxiaCapi::NamespaceConvert $value $PortList ]
                }
				-streamnamelist {
                    set streamstartList [::IxiaCapi::NamespaceDefine $value]
				    #set startList [ IxiaCapi::NamespaceConvert $value $PortList ]
                    
					Deputs "streamlist value $streamstartList"
					
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -port" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }

# Check the existence of stop list
# If negative stop all 
        if { [ info exists stopList ] == 0 && [ info exists streamstartList ] == 0 } {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceStopTraffic3"
            #set stopList $PortList
			Tester::stop_traffic
        } else {
# Or else start certain port
            if { [info exists stopList] } {
				set exist 0
				foreach port $stopList {
		Deputs "Port name: $port"
		#Deputs "Port list: $PortList"
					if { [ lsearch -exact $PortList $port ] >= 0 } {
						if { [ catch {
							set tra [ uplevel 1 "$port cget -Traffic" ] 
							if { [ uplevel 1 "$tra isa TrafficEngine" ] == 0 } {
								continue
							}
						} ] } {
		Deputs "$errorInfo"
							continue
						}
		Deputs "Traffic: $tra"
						if { $tra == 0 } { continue }
						#uplevel 1 " $port StopTraffic "
						$port StopTraffic
						set exist 1
					} else {
						IxiaCapi::Logger::LogIn -type warn -message \
						"$IxiaCapi::s_TestDeviceStopTraffic5 $port"
					}
				}
				if { $exist } {
					IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceStopTraffic1 $stopList"
					return $IxiaCapi::errorcode(0)
				} else {
					IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceStopTraffic4"
					return $IxiaCapi::errorcode(4)
				}
	        }
			
			if {[ info exists streamstartList ] } {
			    set flowList ""
			    foreach stream $streamstartList {
				    if { [ catch {
						set stream [ IxiaCapi::Regexer::GetObject $stream ]
						set strObj [ uplevel 1 " $stream cget -hStream " ]
						set trafficObj [ uplevel 1 " $stream cget -hTrafficItem " ]						
						lappend flowList $strObj
											
					} ] } {
						IxiaCapi::Logger::LogIn -type warn \
						-message "$IxiaCapi::s_TestPortStartTraffic6 $stream" -tag $tag
						continue
					}
				}
				ixNet exec stopStatelessTraffic $flowList
                set timeout 10
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
			}
		}	
    }


    body TestDevice::GetTestState { args } {
        global IxiaCapi::fail IxiaCapi::success
        global errorInfo 
        set tag "body TestDevice::GetTestState [info script]"        
Deputs "----- TAG: $tag -----"
# Param collection --                 
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -route -
                -routeengine {
                    set routeEng $value
                }
                -traffic -
                -trafficengine {
                    set trafficEng $value 
                }
                -elap -
                -elapsedtime {
                    set elapsedTime $value 
                }
                -start -
                -starttime {
                    set startTime $value 
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -routeengine\t-trafficengine\t\
                    -elapsedtime\t-starttime" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        set exist 0
        set root [ixNet getRoot]
        if { [ info exists routeEng ] } {
            uplevel 1 "set $routeEng \
            [ ixNet getA $root/traffic -state]"
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceGetTestState2 $routeEng"
            set exist 1
        }
        if { [ info exists trafficEng ] } {
Deputs "Traffic state: $trafficEng "
            uplevel 1 "set $trafficEng [ ixNet getA $root/traffic -state ]"
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceGetTestState3 $trafficEng"
            set exist 1
        }

        if { [ info exists elapsedTime ] } {
            uplevel 1 "set $elapsedTime [ ixNet getA $root/traffic -waitTime]"
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceGetTestState4 $elapsedTime"
            set exist 1
        }

        if { $exist } {
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestDeviceGetTestState1"
            return $IxiaCapi::errorcode(0)
        } else {
            return $IxiaCapi::errorcode(3)
        }
    }
    
    body TestDevice::WaitUntilTestStops { args } {
        global errorInfo
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::TRUE IxiaCapi::FALSE
        set tag "body TestDevice::WaitUntilTestStops [info script]"        
Deputs "----- TAG: $tag -----"
# param collection
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -time -
                -duration {
                    set trans [ IxiaCapi::Regexer::TimeTrans $value ]
                    if { [ string is integer $trans ] && $trans > 0 } {
                        set duration $trans
Deputs "duration:$duration"
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TestDeviceWiatUntilTestStops1" -tag $tag
                        return $IxiaCapi::errorcode(1)
                    }
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -duration" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
# -- No time limitation
        set root [ixNet getRoot]
        if { [ info exists duration ] == 0 } {
            while { [ ixNet getA $root/traffic -isTrafficRunning ] != "false" } {
                after 500
            }
            #...Routing engine state added
            return $IxiaCapi::errorcode(0)
        } else {
# -- Time limited
            set start [ clock seconds ]
Deputs "start:$start"
            set expired 0
            while { [ ixNet getA $root/traffic -isTrafficRunning ] != "false" } {
                after 500
                set now [ clock seconds ]
Deputs "now:$now\tstart:$start\tduration:$duration"
                if { [ expr $now - $start ] > $duration } {
                    set expired 1
                    break
                }
            }
            #...Routing engine state added
            if { $expired } {
                return $IxiaCapi::errorcode(10)
            } else {
                return $IxiaCapi::errorcode(0)
            }
        }
    }
    body TestDevice::ForceReleasePort { args } {
        global errorInfo 
        set tag "body TestDevice::ForceReleasePort [info script]"        
Deputs "----- TAG: $tag -----"
# Param collection --                 
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -portlocation -
                -port {
                    set location $value
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -routeengine\t-trafficengine\t\
                    -elapsedtime\t-starttime" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        if { [ info exists location ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common2 -PortLocation" -tag $tag
            return $IxiaCapi::errorcode(3)
        }
        set releasePort [list]
        set root [ixNet getRoot]
        set portList [ixNet getList $root vport]
        foreach port $portList {
Deputs "port: $port"
            set connectInfo [ ixNet getA $port -connectionInfo ]
Deputs "connect info: $connectInfo"
            if { [ regexp {card="(\d+)"} $connectInfo match cardNo ] && \
                [ regexp {port="(\d+)"} $connectInfo match portNo ] } {
                set portInfo ${cardNo}/$portNo
Deputs "port info:$portInfo"
Deputs "location:$location"
Deputs "index search:[ lsearch -exact $location $portInfo ]"
                if { [ lsearch -exact $location $portInfo ] >= 0 } {
                    lappend releasePort $port
Deputs "release port:$releasePort"
                }
            }
        }
        
        if { [ llength $releasePort ] > 0 } {
            ixTclNet::ReleasePorts $releasePort
        }
            return $IxiaCapi::errorcode(0)
    }
}

