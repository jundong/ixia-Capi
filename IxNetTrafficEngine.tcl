# TrafficEngine.tcl --
#   This file implements the TrafficEngine class for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1 
# 10.14. add configstream -insertfcserror  

namespace eval IxiaCapi {
    
    class TrafficEngine {
        constructor { portHnadle } {}
        method CreateProfile { args } {}
        method ConfigProfile { args } {}
        method DestroyProfile { args } {}
        method CreateStream { args } {}
        method DestroyStream { args } {}
        method ConfigStream { args } {}
        destructor {}
        
        private variable hPort
        private variable vport
        private variable hTrafficItem
        private variable ProfileList
		public variable  m_trafficProfileList
        private variable StreamList
		public variable m_streamNameList
        private variable StreamLevel
        private variable ProfileLevel
		public variable PortObj
		
		method SetPortObj { portname } {
		    set PortObj $portname
			puts "PortObj:$PortObj"
		}
        
        method AddStream { streamname } {
            lappend StreamList $streamname
			lappend m_streamNameList $streamname
        }
        method ListProfiles {} {
            puts $ProfileList            
        }
        method GetProfileList {} {
            return $ProfileList
        }
        method ListStreams {} {
            puts $StreamList
        }
        method GetStreamList {} {
            return $StreamList
        }
    }

    body TrafficEngine::constructor { portHnadle } {
        global errorInfo IxiaCapi::TrafficManager
        set tag "body TrafficEngine::ctor [info script]"
        Deputs "----- TAG: $tag -----"
        set hPort $portHnadle
        set ProfileList [ list ]
        set StreamList [ list ]
        set StreamLevel 1
        set ProfileLevel 2
        # Get port name to create default profile
        set vport $portHnadle
        #CreateProfile -name ${this}_Profile1
        set ProfileLevel 1 
    }
    
    body TrafficEngine::CreateProfile { args } {
        global errorInfo
        global IxiaCapi::TrafficManager

        set tag "body TrafficEngine::CreateProfile [info script]"
        Deputs "----- TAG: $tag -----"

        set EType [ list CONSTANT BURST CUSTOM ]
        set Type  $IxiaCapi::DefaultTrafficType
        set level $ProfileLevel
        # Param collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -profilename {
                    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
                }
                -type -
                -profiletype {
                    set Type $value
                }
            }
        }
        # Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
                    return $IxiaCapi::errorcode(8)
        }
        # Make sure the necessary param has been assigned --
        if { [info exists name] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 \n\t $IxiaCapi::s_TrafficEngineCreateProfile1" -tag $tag
                    return $IxiaCapi::errorcode(3)
        }
        # Check whether the profile with same name has been existed.
        # If so an error will occured --
        if { [ lsearch -exact $ProfileList $name ] >= 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_TrafficEngineCreateProfile2 $value" -tag $tag
                    return $IxiaCapi::errorcode(4)
        }
        # Create the new object --
        if { [ catch {
            set command " IxiaCapi::Profile $name -hPort $hPort -type $Type"
            Deputs "CMD:$command"
            #namespace inscope $IxiaCapi::ObjectNamespace $command
            #eval ${IxiaCapi::ObjectNamespace}$name Config $args
            Deputs "level:$level"
            #uplevel " eval $command "
            set relprofile [ uplevel $level " eval $command " ]
			Deputs "relprofile: $relprofile"
            Deputs "create profile done...configuration started"
            uplevel $level " $relprofile Config $args "
            } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                    return $IxiaCapi::errorcode(7)
        }
        #lappend ProfileList $name
		lappend ProfileList $relprofile
		lappend m_trafficProfileList $relprofile
		
        #TrafficManager AddProfile $name [ ${IxiaCapi::ObjectNamespace}$name cget -hProfile ]
        TrafficManager AddProfile $relprofile [ uplevel $level " $relprofile cget -hProfile " ]
        IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TrafficEngineCreateProfile3 $name"
                    return $IxiaCapi::errorcode(0)
    }
    
    body TrafficEngine::DestroyProfile { args } {
        global errorInfo
        global IxiaCapi::TrafficManager
        set tag "body TrafficEngine::CreateProfile [info script]"
        set level 1
        Deputs "----- TAG: $tag -----"
        # Param collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -list -
                -profile -
                -profilelist -
                -profilename {
                    #set delList $value
					set delList [::IxiaCapi::NamespaceDefine $value]
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -ProfileName" -tag $tag
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
        # Check whether the name is assigned
        # If negative destroy the all profiles on current port
        if { [ info exists name ] == 0 } {
            set delList $ProfileList
        }
        # or else destroy certain ones
        foreach delPro $delList {
            set delIndex [ lsearch $ProfileList $delPro ]
            if { $delIndex < 0 } {
                IxiaCapi::Logger::LogIn -type warn -message "$IxiaCapi::s_common1 \n\t \
                $IxiaCapi::s_TrafficEngineDestroyProfile1 $delStream" -tag $tag                            
                continue
            } 
            if { [ catch {
                set ProfileList [ lreplace $ProfileList $delIndex $delIndex ]
                TrafficManager DeleteProfile $delPro
                uplevel $level " delete object $delPro "
                } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                continue
            } else {
                IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TrafficEngineDestroyProfile2 \n\t \
                Stream List : $ProfileList"
            }
        }
                    return $IxiaCapi::errorcode(0)
    }
    
    body TrafficEngine::ConfigProfile { args } {
        global errorInfo
        set tag "body TrafficEngine::ConfigProfile [info script]"
        set level $ProfileLevel
        Deputs "----- TAG: $tag -----"
        # Param collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -profilename {
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
# Check the necessary param has been assigned
        if { [ info exists name ] == 0 } {
            #IxiaCapi::Logger::LogIn -type err -message \
            #"$IxiaCapi::s_common1 \n\t $IxiaCapi::s_TrafficEngineConfigProfile1" -tag $tag
            #        return $IxiaCapi::errorcode(3)
            
            # Get port name to create default profile
			set name ${this}_Profile1
            # set port [ IxiaCapi::PortManager GetPortName $hPort ]
            # if { $port != -1 } {
                # set name ${port}_Profile1
            # } else {
                    # return $IxiaCapi::errorcode(7)
            # }
        }
# Check whether the profile to be configed exists
        if { [ lsearch -exact $ProfileList $name ] < 0 } {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_TrafficEngineConfigProfile2 $name" -tag $tag
                    return $IxiaCapi::errorcode(4)
        } else {
# Invoke Config method of object
            if { [ catch {
                uplevel $level "eval { $name Config } $args" } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                    return $IxiaCapi::errorcode(7)
            } else {
                IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TrafficEngineConfigProfile3 $name"
                    return $IxiaCapi::errorcode(0)
            }
        }
    }
    
    body TrafficEngine::CreateStream { args } {
        global IxiaCapi::s_common1
        global errorInfo errorCode
        global IxiaCapi::TrafficManager IxiaCapi::PortManager
        set tag "body TrafficEngine::CreateStream [info script]"

        set frameLen $IxiaCapi::DefaultFrameLen
        set level 1
        Deputs "----- TAG: $tag -----"
        Deputs " args: $args "
        set EType   [ list NORMAL DHCPV4 DHCPV6 PPPOXV4 PPPOXV6 802DOT1XV4 802DOT1XV6 PPPOX  ]
        set Type NORMAL
        # Param collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -streamname {
				    set name [::IxiaCapi::NamespaceDefine $value]
                    #set name $value
                }
                -profile -
                -profilename {
                    #set profileName $value
					set profileName [::IxiaCapi::NamespaceDefine $value]
                }
                -streamtype {
                    if { [ lsearch -exact $EType [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TrafficEngineCreateStream11 $EType" -tag $tag
                        return  $IxiaCapi::errorcode(1)
                    } else {
                        set Type [ string toupper $value ]
                    }
                }
                -vpnpoolname -
                -vpnname -
                -vpn -
                -vpnpool {
                    if { [ catch {
                        if { [ uplevel "$value isa IxiaCapi::MplsVpn" ] } {
                            set vpnObj  $value
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_TrafficEngineCreateStream12 $value" -tag $tag
                            return $IxiaCapi::errorcode(4)
                        }
                    } ] } {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_TrafficEngineCreateStream12 $value" -tag $tag
                            return $IxiaCapi::errorcode(4)                        
                    }
                }
                -routeblockname -
                -routeblock {
                    if { [ uplevel "$value isa IxiaCapi::VpnRouteBlock" ] } {
                        set blkObj  $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TrafficEngineCreateStream13 $value" -tag $tag
                        return $IxiaCapi::errorcode(4)
                    }
                }
                -dstpoolname {
                    set dstPoolName $value
                }
                -srcpoolname {
                    set srcPoolName $value
                }
                -dstports {
                    set dstPortName $value
                }
            }
        }
        # Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
                    return $IxiaCapi::errorcode(8)
        }
        # Check the type of stream to create
        
        Deputs "Stream Type:$Type"
        # if { [$srcPoolName isa IxiaCapi::TestPort ] ||  [$dstPoolName isa IxiaCapi::TestPort ]} {
		    # set Type NORMAL
			# Deputs "Stream Type:$Type"
		# }

         if { [ info exists dstPortName ] && [ info exists dstPoolName ] } {
             IxiaCapi::Logger::LogIn -type err -message \
             "$IxiaCapi::s_TrafficEngineCreateStream20" -tag $tag
                     return $IxiaCapi::errorcode(2)            
         }
        switch -exact -- $Type {
            NORMAL {
                # Make sure the necessary variable has been assigned --
                if { [ info exists name ] } {
                    # Check the existence of the stream to be created
                    # If posotive an error will be occured
		            ListStreams 
                    if { [ lsearch -regexp $StreamList .*$name ] >= 0 } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TrafficEngineCreateStream8" -tag $tag
                            return $IxiaCapi::errorcode(4)
                    }
                    # Check the existence of the input profile name
                    # If negative a default profile will be created
                    if { [ catch {
                        if { [ info exists profileName ] } {
                            if { [ lsearch -exact $ProfileList $profileName ] < 0 } {
                                IxiaCapi::Logger::LogIn -type err -message \
                                "$IxiaCapi::s_TrafficEngineCreateStream3 $profileName" -tag $tag
                            return $IxiaCapi::errorcode(4)
                            }
                            #set command " IxiaCapi::Stream $name $hPort $hTrafficItem $profileName "
							set command " IxiaCapi::Stream $name $hPort $PortObj -profileName $profileName "
                        } else {
                            #set command " IxiaCapi::Stream $name $hPort $hTrafficItem"
							set command " IxiaCapi::Stream $name $hPort $PortObj "
                        }
                        
                    } result ] } {
                        IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                            return $IxiaCapi::errorcode(7)
                    }
                    # Invoke the Ctor of Stream class
                    #namespace inscope $IxiaCapi::ObjectNamespace $command
                    #uplevel $level " eval $command "
					set relstreamname [  eval $command  ]					
					Deputs "relstreamname: $relstreamname"
		
					$relstreamname configure -flagCommit 0
                    # To config the stream obj
                    if { [ catch {                      
						set hStreamGroup [ $relstreamname cget -hStream  ]
						AddStream $relstreamname
                        #lappend StreamList $relstreamname
                        Deputs "Config Stream..."
                        set StreamLevel 2   
						
                        eval { ConfigStream } $args -encaptype APP
                        #Deputs "StreamLevel:$StreamLevel"
                       
                        set StreamLevel 1
                        #Deputs "Config Stream success."
                    } result ] } {
                        IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                            return $IxiaCapi::errorcode(7)
                        catch { DestroyStream -name $name }
                    } else {
                        # Add to Surpervisor
                        TrafficManager AddStreamGroup $relstreamname $hStreamGroup
                        Deputs "name:$name\tstream handle:$hStreamGroup"
                    }
                } else {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $IxiaCapi::s_TrafficEngineCreateStream6"\
                    -tag $tag
                            return $IxiaCapi::errorcode(3)
                }
            }
			802DOT1XV4 -
            DHCPV4 -
            PPPOXV4 {
                # Make sure the necessary variable has been assigned --
                if { [ info exists name ] } {
                    # Check the existence of the stream to be created
                    # If posotive an error will be occured
		            ListStreams 
                    if { [ lsearch -regexp $StreamList .*$name ] >= 0 } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TrafficEngineCreateStream8" -tag $tag
                            return $IxiaCapi::errorcode(4)
                    }
                    # Check the existence of the input profile name
                    # If negative a default profile will be created
                    if { [ catch {
                        if { [ info exists profileName ] } {
                            if { [ lsearch -exact $ProfileList $profileName ] < 0 } {
                                IxiaCapi::Logger::LogIn -type err -message \
                                "$IxiaCapi::s_TrafficEngineCreateStream3 $profileName" -tag $tag
                                
                                return $IxiaCapi::errorcode(4)
                            }
                            #set command " IxiaCapi::Stream $name $hPort $hTrafficItem $profileName "
							set command " IxiaCapi::Stream $name $hPort $PortObj -profileName $profileName "
                        } else {
                            #set command " IxiaCapi::Stream $name $hPort $hTrafficItem"
							set command " IxiaCapi::Stream $name $hPort $PortObj "
                        }
                        if {[ info exists srcPoolName ] && [ info exists dstPoolName ]} {
                            set command "$command -streamtype ipv4 -srcpoolname $srcPoolName -dstpoolname $dstPoolName"
                        }
                    } result ] } {
                        IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                            return $IxiaCapi::errorcode(7)
                    }
                    # Invoke the Ctor of Stream class                 
					set relstreamname [  eval $command  ]
					
					Deputs "relstreamname: $relstreamname"					
					$relstreamname configure -flagCommit 0
                    # To config the stream obj
                    if { [ catch {
                        #set hStreamGroup [ uplevel $level " $name cget -hStream " ]
						set hStreamGroup [ $relstreamname cget -hStream  ]
						AddStream $relstreamname
                        #lappend StreamList $relstreamname
                        Deputs "Config Stream..."                        
                        set StreamLevel 1
                        Deputs "Config Stream success."
                    } result ] } {
                        IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                            return $IxiaCapi::errorcode(7)
                        catch { DestroyStream -name $name }
                    } else {
                        # Add to Surpervisor
                        TrafficManager AddStreamGroup $relstreamname $hStreamGroup
                        Deputs "name:$name\tstream handle:$hStreamGroup"
                    }
                } else {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $IxiaCapi::s_TrafficEngineCreateStream6"\
                    -tag $tag
                            return $IxiaCapi::errorcode(3)
                }
            }
			802DOT1XV6 -
            DHCPV6 -
            PPPOXV6 -
			PPPOX {
                # Make sure the necessary variable has been assigned --
                if { [ info exists name ] } {
                    # Check the existence of the stream to be created
                    # If posotive an error will be occured
		            ListStreams 
                    if { [ lsearch -regexp $StreamList .*$name ] >= 0 } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TrafficEngineCreateStream8" -tag $tag
                            return $IxiaCapi::errorcode(4)
                    }
                    # Check the existence of the input profile name
                    # If negative a default profile will be created
                    if { [ catch {
                        if { [ info exists profileName ] } {
                            if { [ lsearch -exact $ProfileList $profileName ] < 0 } {
                                IxiaCapi::Logger::LogIn -type err -message \
                                "$IxiaCapi::s_TrafficEngineCreateStream3 $profileName" -tag $tag
                            return $IxiaCapi::errorcode(4)
                            }
                            #set command " IxiaCapi::Stream $name $hPort $hTrafficItem $profileName "
							set command " IxiaCapi::Stream $name $hPort $PortObj -profileName $profileName "
                        } else {
                            #set command " IxiaCapi::Stream $name $hPort $hTrafficItem"
							set command " IxiaCapi::Stream $name $hPort $PortObj "
                        }
                        if {[ info exists srcPoolName ] && [ info exists dstPoolName ]} {
                            set command "$command -streamtype ipv6 -srcpoolname $srcPoolName -dstpoolname $dstPoolName"
                        }
                    } result ] } {
                        IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                            return $IxiaCapi::errorcode(7)
                    }
                    # Invoke the Ctor of Stream class                 
					set relstreamname [  eval $command  ]
					
					Deputs "relstreamname: $relstreamname"					
					$relstreamname configure -flagCommit 0
                    # To config the stream obj
                    if { [ catch {
                        #set hStreamGroup [ uplevel $level " $name cget -hStream " ]
						set hStreamGroup [ $relstreamname cget -hStream  ]
						AddStream $relstreamname
                        #lappend StreamList $relstreamname
                        #Deputs "Config Stream..."                        
                        set StreamLevel 1
                        #Deputs "Config Stream success."
                    } result ] } {
                        IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                            return $IxiaCapi::errorcode(7)
                        catch { DestroyStream -name $name }
                    } else {
                        # Add to Surpervisor
                        TrafficManager AddStreamGroup $relstreamname $hStreamGroup
                        Deputs "name:$name\tstream handle:$hStreamGroup"
                    }
                } else {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $IxiaCapi::s_TrafficEngineCreateStream6"\
                    -tag $tag
                            return $IxiaCapi::errorcode(3)
                }
            }
        }
        
        return $IxiaCapi::errorcode(0)
    }
    
    body TrafficEngine::DestroyStream { args } {
        global errorInfo
        
        set tag "body TrafficEngine::DestroyStream [info script]"
        set level 1
Deputs "----- TAG: $tag -----"
# Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
                    return $IxiaCapi::errorcode(8)
        }
# Param collection --        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -stream -
                -streamname -
                -list -
                -streamlist {
				    set delList [ IxiaCapi::NamespaceDefine $value ]
                    #set delList $value
                }
            }
        }
# Check whether the delete list is assigned
# If negative delete all the streams on current port
        if { [info exists delList] == 0 } {
Deputs "Destroy all stream"
Deputs "$StreamList "
            set delList $StreamList
        }
# If positive delete the certain streams
        set exist 0
        foreach delStream $delList {
		Deputs "delStream $delStream"
            set delIndex [ lsearch $StreamList $delStream ]
            if { $delIndex < 0 } {
                IxiaCapi::Logger::LogIn -type warn -message "$IxiaCapi::s_common1 \n\t \
                $IxiaCapi::s_TrafficEngineDestroyStream1 $delStream" -tag $tag                            
                continue
            } 
            if { [ catch {
                set StreamList [ lreplace $StreamList $delIndex $delIndex ]
                TrafficManager DeleteStream $delStream
                uplevel $level " delete object $delStream "
                } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                continue
            } else {
                set exist 1
                IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TrafficEngineDestroyStream2 \n\t \
                Stream List : $StreamList"
            }
			foreach profilename $ProfileList {
			    $profilename DeleteStreamGruop $delStream 
			}
        }
        if { $exist } {
                    return $IxiaCapi::errorcode(0)
        } else {
                    return $IxiaCapi::errorcode(4)
        }
    }
    body TrafficEngine::ConfigStream { args } {
        global errorInfo
        global IxiaCapi::MaxFrameLen IxiaCapi::DefaultFrameLen
        set tag "body TrafficEngine::ConfigStream [info script]"
        set level $StreamLevel
        set encapType MOD
        set l2 "ethernet"
        Deputs "----- TAG: $tag -----"
        Deputs "args: $args"
        # Param collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -streamname {
                    #set name $value
					set name [ IxiaCapi::NamespaceConvert $value $StreamList ]
					
					Deputs "streamname: $name" 
					Deputs "StreamList:$StreamList"
                }
                -framelen {
                    set transLen [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [string is integer -strict $transLen ] } {
                        if { $value > 0 && $value < $MaxFrameLen } {
                            set frameLen $value
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                                "$IxiaCapi::s_TrafficEngineCreateStream2 0-$MaxFrameLen" \
                                -tag $tag
                        }
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_TrafficEngineCreateStream1 $value"
                    }
                }
                -expecteddes -
                -des -
                -dstports -
                -dstport {
                    #set des $value
					set des [ IxiaCapi::NamespaceConvert $value $StreamList ]
                }
                -l2 -
                -l2_encap {
                    set l2 [ string tolower $value ]
                }
                -l3 -
                -l3_protocol {
                    set l3 [ string tolower $value ]
                }
                -l4 -
                -l4_protocol {
                    set l4 [ string tolower $value ]
                }
                -encaptype {
                    set encapType   $value
                }
                -vlanid {
                    set l2 "ethernet_vlan"
                }
                -insertfcserror {
                    set insertfcserror [ string tolower $value ]
                }
                -ipprotocol {
                    set ipprotocol [ string tolower $value ]
                }
            }
        }
        # Make sure the traffic engine is stopped
        if { [ IxiaCapi::Lib::TrafficStopped ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common5" -tag $tag
                    return $IxiaCapi::errorcode(8)
        }
       
        # Make sure the necessary variable has been assigned --
        if { [ info exists name ] } {
            # Check the existence of the stream to be created
            # If negative an error will be occured
            if { [ lsearch -exact $StreamList $name ] < 0 } {
                IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TrafficEngineConfigStream5" -tag $tag
                    return $IxiaCapi::errorcode(4)
            }
            # To config the stream obj

            if { [ catch { 
			    
                #set hStreamGroup [ uplevel $level " $name cget -hStream " ]
				set hStreamGroup [ $name cget -hStream  ]
				Deputs "hStreamGroup:$hStreamGroup"
                #set endpointSet  [ uplevel $level " $name cget -endPoint" ]
				set endpointSet  [ $name cget -endPoint ]
				Deputs "endpointSet:$endpointSet"
            } ] } {
                Deputs "$errorInfo"
                IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TrafficEngineConfigStream5" -tag $tag
                    return $IxiaCapi::errorcode(4)
            }
            Deputs "stream handle:$hStreamGroup"
            if { $hStreamGroup == -1 } {
                IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_TrafficEngineConfigStream5" -tag $tag
                    return $IxiaCapi::errorcode(4)
            }
            # ----- FrameLen -----
            if { [ info exists frameLen ] } {
                Deputs "Frame length:$frameLen"
                ixNet setA $hStreamGroup/frameSize -fixedSize $frameLen
            }
            if { [ info exists insertfcserror ] } {
                Deputs "Frame length:$frameLen"
                if { $insertfcserror == "true" || $insertfcserror == "1" } {
					ixNet setA $hStreamGroup -crc badCrc
					ixNet commit
				}
            }
            # ----- Destination -----
            if { [ info exists des ] } {
                set desList [ list ]
                foreach dename $des {
                    set dename [ IxiaCapi::Regexer::GetObject $dename ]
                    if { [ catch {
                    lappend desList [ uplevel $level " $dename cget -hPort " ]/protocols
                    } ] } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_TrafficEngineCreateStream10" -tag $tag                          
                        continue
                    }
                }

                if { [ llength $desList ] > 0 } {
                    Deputs "des list:$desList"
                    ixNet setA $endpointSet -destinations $desList
                } else {                        
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_TrafficEngineCreateStream10" -tag $tag
                    #uplevel $level " delete object $name "
                    return $IxiaCapi::errorcode(4)
                }
            } else {
                # Deputs Step22.8
                # set desList [ list ]
                # set root [ixNet getRoot]
                # set portList [ixNet getList $root vport]
                # foreach port $portList {
                    # Deputs "dst expect:$port == hPort:$hPort"
                    # #if { $hPort == $port } {
                    # #    continue
                    # #}
                    # lappend desList $port/protocols
                # }
                # ixNet setA $endpointSet -destinations $desList
            }
        # ----- Modify fields -----
        Deputs Modify
	    if { [ catch {
            uplevel $level {
                IxiaCapi::HeaderCreator IxHead
                IxiaCapi::PacketBuilder IxPkt 
            }
            # ----- Encapsulation -----
            Deputs [find object]
            # To reomve -option form parameters from args in case
            # mis-translated the "" in later command like
            # -option { -XX abcd } -> -option -XX abcd
            foreach { key value } $args {
                set keyNew [string tolower $key]
                switch -exact -- $keyNew {
                    -option -
                    -dhcpoption {
                        set OpValue $value
                        set index [ lsearch -exact $args $key ]
                        set args [ lreplace $args $index [ incr index ] ]
                    }
                    -grechecksum {
                        set ChecksumList $value
                        set index [ lsearch -exact $args $key ]
                        set args [ lreplace $args $index [ incr index ] ]
                    }
                }
            }
            # Create header and AddPdu

                if { [ info exists l2 ] } {
                    switch -exact -- $l2 {
                        ethernet {
                            uplevel $level "
                            eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2"
                            #uplevel $level "eval $name AddPdu -name ::IXIA::test::pdul2 "
							$name AddPdu -name ::IxiaCapi::pdul2

                        }
                        ethernet_vlan {
                            set vlan2   0
                            set vlan2Arg    [list]
                            foreach { key value } $args {
                                set key [string tolower $key]
                                switch -exact -- $key {
                                    -vlanid2 {
                                        set vlanid2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanid $value"
                                    }
                                    -vlanuserpriority2 {
                                        set vlanuserpriority2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanuserpriority $value"
                                    }
                                    -vlancfi2 {
                                        set vlancfi2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlancfi $value"
                                    }
                                    -vlanidmode2 {
                                        set vlanidmode2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanidmode $value"
                                    }
                                    -vlanidcount2 {
                                        set vlanidcount2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanidcount $value"
                                    }
                                    -vlanidstep2 {
                                        set vlanidstep2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanidstep $value"
                                    }
                                    -vlantype2 {
                                        set vlantype2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlantype $value"
                                    }
                                }
                            }
                            if { $vlan2 } {
                                uplevel $level "
                                eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2 
                                eval IxHead CreateVlanHeader $args -name ::IxiaCapi::pdul2_1
                                eval IxHead CreateVlanHeader $vlan2Arg -name ::IxiaCapi::pdul2_2
                                ::IxiaCapi::pdul2_1 ChangeType $encapType"                            
                                $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul2_1 ::IxiaCapi::pdul2_2 } 
                            } else {
                                uplevel $level "
                                eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2 
                                eval IxHead CreateVlanHeader $args -name ::IxiaCapi::pdul2_1 
                                ::IxiaCapi::pdul2_1 ChangeType $encapType "                           
                                $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul2_1 } 
                            }
                        }
                        ethernet_vlan_mpls {
                            #uplevel $level "
                            #eval IxHead CreateEthHeader $args -name pdul2 
                            #eval IxHead CreateVlanHeader $args -name pdul2_1
                            #eval IxHead CreateMPLSHeader $args -name pdul2_2
                            #pdul2_1 ChangeType $encapType                            
                            #pdul2_2 ChangeType $encapType
                            # $name AddPdu -name { pdul2 pdul2_1 pdul2_2 } "
                            uplevel $level "
                            eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2
                            eval IxHead CreateVlanHeader $args -name ::IxiaCapi::pdul2_1
                            eval IxHead CreateMPLSHeader $args -name ::IxiaCapi::pdul2_2
                            ::IxiaCapi::pdul2_1 ChangeType $encapType
                            ::IxiaCapi::pdul2_2 ChangeType $encapType
                            "
                            lappend pduList ::IxiaCapi::pdul2
                            lappend pduList ::IxiaCapi::pdul2_1
                            set vlan2   0
                            set vlan2Arg    [list]
                            set mpls2   0
                            set mpls2Arg    [list]
                            set mpls3   0
                            set mpls3Arg    [list]
                            set mpls4   0
                            set mpls4Arg    [list]
                            foreach { key value } $args {
                                set key [string tolower $key]
                                switch -exact -- $key {
                                    -mplslabel2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplslabel $value"
                                    }
                                    -mplslabelcount2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplslabelcount $value"
                                    }
                                    -mplslabelmode2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplslabelmode $value"
                                    }
                                    -mplslabelstep2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplslabelstep $value"
                                    }
                                    -mplsexp2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplsexp $value"
                                    }
                                    -mplsttl2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplsttl $value"
                                    }
                                    -mplsbottomofstack2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplsbottomofstack $value"
                                    }
                                    -mplslabel3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplslabel $value"
                                    }
                                    -mplslabelcount3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplslabelcount $value"
                                    }
                                    -mplslabelmode3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplslabelmode $value"
                                    }
                                    -mplslabelstep3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplslabelstep $value"
                                    }
                                    -mplsexp3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplsexp $value"
                                    }
                                    -mplsttl3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplsttl $value"
                                    }
                                    -mplsbottomofstack3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplsbottomofstack $value"
                                    }
                                    -mplslabel4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplslabel $value"
                                    }
                                    -mplslabelcount4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplslabelcount $value"
                                    }
                                    -mplslabelmode4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplslabelmode $value"
                                    }
                                    -mplslabelstep4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplslabelstep $value"
                                    }
                                    -mplsexp4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplsexp $value"
                                    }
                                    -mplsttl4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplsttl $value"
                                    }
                                    -mplsbottomofstack4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplsbottomofstack $value"
                                    }
                                    -vlanid2 {
                                        set vlanid2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanid $value"
                                    }
                                    -vlanuserpriority2 {
                                        set vlanuserpriority2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanuserpriority $value"
                                    }
                                    -vlancfi2 {
                                        set vlancfi2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlancfi $value"
                                    }
                                    -vlanidmode2 {
                                        set vlanidmode2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanidmode $value"
                                    }
                                    -vlanidcount2 {
                                        set vlanidcount2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanidcount $value"
                                    }
                                    -vlanidstep2 {
                                        set vlanidstep2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlanidstep $value"
                                    }
                                    -vlantype2 {
                                        set vlantype2 $value
                                        set vlan2   1
                                        lappend vlan2Arg "-vlantype $value"
                                    }
                                }
                            }
                            if { $vlan2 } {
                                uplevel $level "
                                eval IxHead CreateVlanHeader $vlan2Arg -name ::IxiaCapi::pdul2_1_1
                                ::IxiaCapi::pdul2_1_1 ChangeType $encapType"
                                lappend pduList ::IxiaCapi::pdul2_1_1
                            }
                            lappend pduList ::IxiaCapi::pdul2_2
                            if { $mpls2 } {
                                uplevel $level "
                                eval IxHead CreateMPLSHeader $mpls2Arg -name ::IxiaCapi::pdul2_2_1
                                ::IxiaCapi::pdul2_2_1 ChangeType $encapType"
                                lappend pduList ::IxiaCapi::pdul2_2_1
                            } 
                            if { $mpls3 } {
                                uplevel $level "
                                eval IxHead CreateMPLSHeader $mpls3Arg -name ::IxiaCapi::pdul2_2_2
                                ::IxiaCapi::pdul2_2_2 ChangeType $encapType"
                                lappend pduList ::IxiaCapi::pdul2_2_2
                            } 
                            if { $mpls4 } {
                                uplevel $level "
                                eval IxHead CreateMPLSHeader $mpls4Arg -name ::IxiaCapi::pdul2_2_3
                                ::IxiaCapi::pdul2_2_3 ChangeType $encapType"
                                lappend pduList ::IxiaCapi::pdul2_2_3
                            } 
                            Deputs "pdulist:$pduList"
                            uplevel $level "
                            $name AddPdu -name \{$pduList\} "
                        }
                        ethernet_mpls {
                            uplevel $level "
                            eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2
                            eval IxHead CreateMPLSHeader $args -name ::IxiaCapi::pdul2_1
                            ::IxiaCapi::pdul2_1 ChangeType $encapType                            
                            "
                            lappend pduList ::IxiaCapi::pdul2
                            lappend pduList ::IxiaCapi::pdul2_1
                            set mpls2   0
                            set mpls2Arg    [list]
                            set mpls3   0
                            set mpls3Arg    [list]
                            set mpls4   0
                            set mpls4Arg    [list]
                            foreach { key value } $args {
                                set key [string tolower $key]
                                switch -exact -- $key {
                                    -mplslabel2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplslabel $value"
                                    }
                                    -mplslabelcount2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplslabelcount $value"
                                    }
                                    -mplslabelmode2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplslabelmode $value"
                                    }
                                    -mplslabelstep2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplslabelstep $value"
                                    }
                                    -mplsexp2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplsexp $value"
                                    }
                                    -mplsttl2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplsttl $value"
                                    }
                                    -mplsbottomofstack2 {
                                        set mpls2   1
                                        lappend mpls2Arg "-mplsbottomofstack $value"
                                    }
                                    -mplslabel3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplslabel $value"
                                    }
                                    -mplslabelcount3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplslabelcount $value"
                                    }
                                    -mplslabelmode3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplslabelmode $value"
                                    }
                                    -mplslabelstep3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplslabelstep $value"
                                    }
                                    -mplsexp3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplsexp $value"
                                    }
                                    -mplsttl3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplsttl $value"
                                    }
                                    -mplsbottomofstack3 {
                                        set mpls3   1
                                        lappend mpls3Arg "-mplsbottomofstack $value"
                                    }
                                    -mplslabel4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplslabel $value"
                                    }
                                    -mplslabelcount4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplslabelcount $value"
                                    }
                                    -mplslabelmode4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplslabelmode $value"
                                    }
                                    -mplslabelstep4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplslabelstep $value"
                                    }
                                    -mplsexp4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplsexp $value"
                                    }
                                    -mplsttl4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplsttl $value"
                                    }
                                    -mplsbottomofstack4 {
                                        set mpls4   1
                                        lappend mpls4Arg "-mplsbottomofstack $value"
                                    }
                                }
                            }
                            if { $mpls2 } {
                                uplevel $level "
                                eval IxHead CreateMPLSHeader $mpls2Arg -name ::IxiaCapi::pdul2_2
                                ::IxiaCapi::pdul2_2 ChangeType $encapType"
                                lappend pduList ::IxiaCapi::pdul2_2
                            } 
                            if { $mpls3 } {
                                uplevel $level "
                                eval IxHead CreateMPLSHeader $mpls3Arg -name ::IxiaCapi::pdul2_3
                                ::IxiaCapi::pdul2_3 ChangeType $encapType"
                                lappend pduList ::IxiaCapi::pdul2_3
                            } 
                            if { $mpls4 } {
                                uplevel $level "
                                eval IxHead CreateMPLSHeader $mpls4Arg -name ::IxiaCapi::pdul2_4
                                ::IxiaCapi::pdul2_4 ChangeType $encapType"
                                lappend pduList ::IxiaCapi::pdul2_4
                            } 
                            Deputs "pdulist:$pduList"
                            uplevel $level "
                            $name AddPdu -name \{$pduList\} "
                        }
                        default {
                            if { $defaultl2 == 0 } {
                                IxiaCapi::Logger::LogIn -type err -message \
                                "$IxiaCapi::s_common1 \
                                $IxiaCapi::s_TrafficEngineConfigStream1 $l2" -tag $tag
                                return $IxiaCapi::errorcode(1)
                            }
                        }
                    }
                }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2 } }

                if { [ info exists l3 ] } {
                    switch -exact -- $l3 {
                        ipv4 {
                            if { [ info exists l2 ] && ( $l2 == "ethernet" ) } {
                                Deputs "l3:ipv4 args:$args"
                                uplevel $level "
                                eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2 
                                eval IxHead CreateIPV4Header -IpSrcAddr 1.1.1.1 -IpDstAddr 2.2.2.2 $args -name ::IxiaCapi::pdul3 
                                ::IxiaCapi::pdul3 ChangeType $encapType"
								if {[info exists ipprotocol] } {
								    # set ipprotocol [string tolower $ipprotocol]
									# puts "$ipprotocol"
								    # switch -exact -- $ipprotocol {
										# icmp -
										# 1 -
                                   		# "1" {
										# puts "icmp"
											# IcmpHdr ::IxiaCapi::pdul4
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
										# }
										# igmp -
										# 2 -
                                   		# "2" {
										# puts "igmp"
											# Igmpv2Hdr ::IxiaCapi::pdul4
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
										# }
										# gre -
										# 47 -
                                   		# "47" {
										# puts "gre"
											# GreHdr ::IxiaCapi::pdul4
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }

											
										# }
										# tcp -
										# 6 -
                                   		# "6" {
										
											# TcpHdr ::IxiaCapi::pdul4
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
											
										# }
										# udp -
										# 17 -
                                   		# "17" {
										
											# UdpHdr ::IxiaCapi::pdul4
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
											
										# }
										
									# }
									
								} else {
								    $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 }
								}
                               
                            } else {
                                uplevel $level "
                                eval IxHead CreateIPV4Header -IpSrcAddr 1.1.1.1 -IpDstAddr 2.2.2.2 $args -name ::IxiaCapi::pdul3 "
                                uplevel $level "::IxiaCapi::pdul3 ChangeType $encapType"
								# set allobj [find object]
								# Deputs $allobj
								# set nameIndex [ lsearch -regexp $allobj .*pdul3 ]
								# set temppdu [lindex $allobj $nameIndex]
                                $name AddPdu -name ::IxiaCapi::pdul3
								# if {[info exists ipprotocol] } {
								    # set ipprotocol [string tolower $ipprotocol]
								    # switch -exact -- $ipprotocol {
										# icmp -
										# 1 -
                                   		# "1" {
											# IcmpHdr ::IxiaCapi::pdul4
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
										# }
										# igmp -
										# 2 -
                                   		# "2" {
											# Igmpv2Hdr ::IxiaCapi::pdul4
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
										# }
										# gre -
										# 47 -
                                   		# "47" {
											# GreHdr ::IxiaCapi::pdul4
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
											
										# }
										# tcp -
										# 6 -
                                   		# "6" {
										
											# TcpHdr ::IxiaCapi::pdul4 
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
										# }
										# udp -
										# 17 -
                                   		# "17" {
										
											# UdpHdr ::IxiaCapi::pdul4 
											# $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 ::IxiaCapi::pdul4 }
										# }
									# }
									
								# }
								
                            }
                            Deputs "l3 header create success..."
                        }
                        ipv6 {
                            if { [ info exists l2 ] && ( $l2 == "ethernet" ) } {
                                uplevel $level "
                                eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2 
                                eval IxHead CreateIPV6Header $args -name ::IxiaCapi::pdul3
                                ::IxiaCapi::pdul3 ChangeType $encapType                            
                                $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 }"
                            } else {
                                uplevel $level "
                                eval IxHead CreateIPV6Header $args -name ::IxiaCapi::pdul3
                                ::IxiaCapi::pdul3 ChangeType $encapType "                           
                                $name AddPdu -name ::IxiaCapi::pdul3
                            }
                        }
                        arp {
                            if { [ info exists l2 ] && ( $l2 == "ethernet" ) } {
                                uplevel $level "
                                eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2 
                                eval IxPkt CreateARPPkt $args -name ::IxiaCapi::pdul3
                                ::IxiaCapi::pdul3 ChangeType $encapType "                           
                                $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 }
                            } else {
                                uplevel $level "
                                eval IxPkt CreateARPPkt $args -name ::IxiaCapi::pdul3
                                ::IxiaCapi::pdul3 ChangeType $encapType  "                          
                                $name AddPdu -name ::IxiaCapi::pdul3
                            }
                        }
                        gre {
                            if { [ info exists ChecksumList ] } {
                                uplevel $level "
                                eval IxPkt CreateGREPkt $args {-name ::IxiaCapi::pdul3 -checksum \{$ChecksumList\}}
                                ::IxiaCapi::pdul3 ChangeType $encapType "                               
                                $name AddPdu -name ::IxiaCapi::pdul3
                            } else {
                                uplevel $level "
                                eval IxPkt CreateGREPkt $args -name ::IxiaCapi::pdul3
                                ::IxiaCapi::pdul3 ChangeType $encapType "                               
                                $name AddPdu -name ::IxiaCapi::pdul3
                            }
                        }
                        pppoe {
                            if { [ info exists l2 ] && ( $l2 == "ethernet" ) } {
                                uplevel $level "
                                eval IxHead CreateEthHeader $args -name ::IxiaCapi::pdul2 
                                eval IxPkt CreatePPPoEPkt $args -name ::IxiaCapi::pdul3
                                ::IxiaCapi::pdul3 ChangeType $encapType "                           
                                $name AddPdu -name { ::IxiaCapi::pdul2 ::IxiaCapi::pdul3 }
                            } else {
                                uplevel $level "
                                eval IxPkt CreatePPPoEPkt $args -name ::IxiaCapi::pdul3
                                ::IxiaCapi::pdul3 ChangeType $encapType "                           
                                $name AddPdu -name ::IxiaCapi::pdul3
                            }
                        }
                        none {}
                        default {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common1 \
                            $IxiaCapi::s_TrafficEngineConfigStream2 $l3" -tag $tag
                            return $IxiaCapi::errorcode(1)
                        }
                    }
                }
                Deputs Step40
                if { [ info exists l4 ] } {
                    switch -exact -- $l4 {
                        igmp {
                            uplevel $level "
                            eval IxPkt CreateIGMPPkt $args -name ::IxiaCapi::pdul4
                            ::IxiaCapi::pdul4 ChangeType $encapType "                           
                            $name AddPdu -name ::IxiaCapi::pdul4 
                        }
                        icmp {
                            uplevel $level "
                            eval IxPkt CreateICMPPkt $args -name ::IxiaCapi::pdul4
                            ::IxiaCapi::pdul4 ChangeType $encapType "                                                       
                            $name AddPdu -name :::IxiaCapi::pdul4 
                        }
                        tcp {
                            Deputs "l4:tcp"
                            Deputs "$name"
                            uplevel $level "
                            eval IxHead CreateTCPHeader $args -name ::IxiaCapi::pdul4 
                            ::IxiaCapi::pdul4 ChangeType $encapType "
                            Deputs [find object]							
                            $name AddPdu -name ::IxiaCapi::pdul4
                            Deputs "tcp header create success..."
                        }
                        udp {
                            uplevel $level "
                            eval IxHead CreateUDPHeader $args -name ::IxiaCapi::pdul4
                            ::IxiaCapi::pdul4 ChangeType $encapType "                                                       
                            $name AddPdu -name ::IxiaCapi::pdul4 
                        }
                        rip {
                            uplevel $level "
                            eval IxPkt CreateRIPPkt $args -name ::IxiaCapi::pdul4
                            ::IxiaCapi::pdul4 ChangeType $encapType"                                                        
                            $name AddPdu -name ::IxiaCapi::pdul4 
                        }
                        dhcp {
                            if { [ info exists OpValue ] } {
                                Deputs "OpValue exist..."
                                uplevel $level "eval IxPkt CreateDHCPPkt $args {-name ::IxiaCapi::pdul4 -option \{$OpValue\}} ::IxiaCapi::pdul4 ChangeType $encapType"                                                           
                                $name AddPdu -name :::IxiaCapi::pdul4
                            } else {
                                Deputs "OpValue not exist..."
                                uplevel $level "eval IxPkt CreateDHCPPkt $args -name ::IxiaCapi::pdul4 ::IxiaCapi::pdul4ChangeType $encapType "                                                           
                                $name AddPdu -name ::IxiaCapi::pdul4 
                            }
                        }
                        ospfv2 {
                            uplevel $level "
                            eval IxPkt CreateOSPFv2Pkt $args -name ::IxiaCapi::pdul4
                            ::IxiaCapi::pdul4 ChangeType $encapType "                                                       
                            $name AddPdu -name ::IxiaCapi::pdul4 
                        }
                        ospfv3 {
                            uplevel $level "
                            eval IxPkt CreateOSPFv3Pkt $args -name ::IxiaCapi::pdul4
                            ::IxiaCapi::pdul4 ChangeType $encapType "                                                       
                            $name AddPdu -name ::IxiaCapi::pdul4 
                        }
                        none {}
                        default {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common1 \
                            $IxiaCapi::s_TrafficEngineConfigStream3 $l4" -tag $tag
                            return $IxiaCapi::errorcode(1)
                        }
                    }
                }

                ixNet commit
            } result ] } {

                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                catch { uplevel $level { delete object IxHead } }
                catch { uplevel $level { delete object IxPkt } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_1 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_1_1 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_2 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_2_1 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_2_2 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_2_3 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_3 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_4 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul3 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul4 } }
                return $IxiaCapi::errorcode(7)
            } else {

                catch { uplevel $level { delete object IxHead } }
                catch { uplevel $level { delete object IxPkt } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_1 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_1_1 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_2 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_2_1 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_2_2 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_2_3 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_3 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul2_4 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul3 } }
                catch { uplevel $level { delete object ::IxiaCapi::pdul4 } }
                IxiaCapi::Logger::LogIn -message \
                "$IxiaCapi::s_TrafficEngineCreateStream4 $name"            
                
                return $IxiaCapi::errorcode(0)
            }
            Deputs "commit modification..."
        } else {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_TrafficEngineCreateStream6"\
            -tag $tag
            
            return $IxiaCapi::errorcode(3)
        }
        
    }
    
    body TrafficEngine::destructor {} {
        global errorInfo IxiaCapi::TrafficManager
        set tag "body TrafficEngine::destructor [info script]"
        set level 1
Deputs "----- TAG: $tag -----"
        TrafficManager Reset
        if { [
        catch {
# Remove the profiles created by the traffic engine
            if { [ llength $ProfileList ] > 0 } {
Deputs "profile list:$ProfileList"
                foreach profile $ProfileList {
                    #set profile [IxiaCapi::Regexer::GetObject $profile]
                    #TrafficManager DeleteProfile $profile
                    catch {
                        uplevel $level " delete object $profile "
                    }
                }
            }
# Remove the streams created by the traffic engine
            if { [ llength $StreamList ] > 0 } {
Deputs "stream list:$StreamList"
                TrafficManager Reset
                foreach stream $StreamList {
                    #set stream [IxiaCapi::Regexer::GetObject $stream]
					puts $stream
					#puts $StreamList					
					#set stream [ IxiaCapi::NamespaceDefine $stream ]
                    #TrafficManager Reset
                    catch {
                        uplevel $level " eval delete object $stream "
                    }
                }
            }
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_TestPortDector1 $hPort"   
			# set trafficList [ixNet getL ::ixNet::OBJ-/traffic trafficItem]
			# foreach trafficItem $trafficList {
			    # ixNet remove $trafficItem
				# ixNet commit
			# }
            # puts "hTrafficItem:$hTrafficItem"			
            # eval "ixNet remove $hTrafficItem"
            # ixNet commit
        } ] } {
            Deputs $errorInfo
        }
    }

}
