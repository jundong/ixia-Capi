# Stream.tcl --
#   This file implements the Stream class for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1


namespace eval IxiaCapi {
    
    class Stream {
        constructor { portHandle portname  args } {}
        method Config { args } {}
        method AddPdu { args } {}
        method ConfigField { pro args } {}
        method ClearPdu {} {}
        method DestroyPdu { args } {}
        method GetProtocolTemp { pro } {}
        method GetField { stack field } {}
        method SetProfileParam {} {}
		method SetPortObj { portname } {
		    set PortObj $portname
			puts "PortObj: $PortObj"
		}
        destructor {}
                
        public variable hStream
        public variable hPort
		public variable hTrafficItem
        public variable ProfileName
        public variable endPoint
		public variable PortObj
        
        public variable stackLevel
        private variable PduList
        public variable statsIndex
        public variable flagCommit
    }
    
    
    class Pdu {
        constructor { pduPro { pduType "APP" } } {
            set EMode [ list Incrementing Decremeting Fixed Random ]
            set fieldModes [ list ]
            set fields [ list ]
            set fieldConfigs [ list ]
            set optionals [ list ]
            set autos [ list ]
            set valid 0
            set type $pduType
            set protocol $pduPro
            Deputs "type:$type\tprotocol:$protocol"
            return $this
        }
        method ConfigPdu { args } {}
        destructor {}
        public variable protocol
        # SET - set | APP - append | MOD - modify | RAW - raw data
        public variable type
        public variable fields
        public variable fieldModes
        public variable fieldConfigs
        public variable optionals
        public variable autos
        public variable raw
        private variable valid
        method ChangeType { chtype } { set type $chtype }
        method SetProtocol { value } { set protocol $value }
        method SetRaw { value } { set raw $value }
        method AddField { value { optional 0 } { auto 0 } } {
            lappend fields $value
            lappend optionals $optional
            lappend autos $auto
            set valid 1
            Deputs "fields:$fields optionals:$optionals autos:$autos"
        }
        # Fixed | List | Segment ( set a segment of bits from the beginning of certain field )
        # | Incrementing | Decrementing | Reserved ( for option and auto now )
        method AddFieldMode { value } {
            lappend fieldModes $value
            set valid 1
        }
        method AddFieldConfig { args } {
            lappend fieldConfigs $args
            set valid 1
        }
        method Clear {} {
            set fields [ list ]
            set fieldModes [ list ]
            set fieldConfigs [ list ]
            set optionals [ list ]
            set valid 0
        }
        method IsValid {} {
            return $valid
        }
    }
    
    body Stream::constructor { port portname  args } {
        global errorInfo IxiaCapi::true IxiaCapi::false
        set tag "body Stream::Ctor [info script]"
        set hPort   $port
        set hStream ""
        set stackLevel 1
        set flagCommit 1
        set profileName "null"
		set PortObj $portname
        Deputs "----- TAG: $tag -----"
        Deputs "Args:$args "
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -profile -
                -profilename {
                    set profileName $value
                }
                -dstpoolname {
                    set dst $value
                }
                -srcpoolname {
                    set src $value
                }  
                -streamtype {
                    set trafficType $value
                }                 
            }
        }
        if { ( $profileName == "vpn" ) || ( $profileName == "device" ) } {
            #AgtDebugOn
            Deputs "vpn or device invoking..."
            #AgtDebugOff
            return
        }
        set vport $port
        Deputs "vport:$vport"
        if { [ catch {
            # Create stream at an undefined profile    
            if { $profileName == "null" } {
                Deputs "profileName is null"
                set profileName [TrafficManager GetProfileByIndex 0]
				Deputs "profileName :trafficmanager get $profileName"
            }
            set ProfileName $profileName
			Deputs "profileName : $profileName"
            set proObj [ IxiaCapi::Regexer::GetObject $ProfileName ]
			Deputs "proObj:$proObj"
            $proObj AddStreamGroup $this                    
            
            set root [ixNet getRoot]
            set handle [ixNet add $root/traffic trafficItem]
            ixNet setM $handle \
                -name $this
            ixNet commit
            
            ixNet setA $root/traffic/statistics/l1Rates -enabled True
            ixNet setA $root/traffic \
                    -enableDataIntegrityCheck False \
                    -enableMinFrameSize True
            ixNet commit
            if { [ info exists src ] && [ info exists dst ] } {
                set enable_sig		1                           
                set bidirection 0
                set fullMesh 0
                set selfdst 0
                set tos_tracking 0
                set no_src_dst_mesh 0
                set no_mesh 0
                set to_raw 0
                set pdu_index 1
                
                set srcHandle [ list ]
                Deputs "src list:$src"		
                foreach srcEndpoint $src {
                    # Deputs "src:$srcEndpoint"
                    set srcObj [ GetObject $srcEndpoint ]
                    # Deputs "srcObj:$srcObj"			
                    if { $srcObj == "" } {
                        Deputs "illegal object...$srcObj"
                        set srcObj $portObj
                        # error "$errNumber(1) key:src value:$src (Not an object)"                
                    }
                    
                   if { [ $srcObj isa RouteBlock ] } {
                        Deputs "route block:$srcObj"
                        if { [ $srcObj cget -protocol ] == "bgp" } {
                            set routeBlockHandle [ $srcObj cget -handle ]
                            set hBgp [ ixNet getP $routeBlockHandle ]
                            Deputs "bgp route block:$hBgp"
                            if { [ catch {
                                set rangeCnt [ llength [ ixNet getL $hBgp routeRange ] ]
                            } ] } {
                                set rangeCnt [ llength [ ixNet getL $hBgp vpnRouteRange ] ]
                            }
                            if { $rangeCnt > 0 } {
                                set p [ ixNet getP $routeBlockHandle ]
                                set startIndex [ string first $p $routeBlockHandle ]
                                set endIndex [ expr $startIndex + [ string length $p ] - 1 ]
                                set routeBlockHandle \
                                [ string replace $routeBlockHandle \
                                $startIndex $endIndex $p.0 ]
                                Deputs "route block handle:$routeBlockHandle"		
                            } else {
                                set routeBlockHandle [ $srcObj cget -hPort ]/protocols/bgp
                            }
                            set srcHandle [ concat $srcHandle $routeBlockHandle ]
                        } elseif { [ $dstObj cget -protocol ] == "isis" } {
                            #set routeBlockHandle [ $dstObj cget -handle ]
                            #set hIsis [ ixNet getP $routeBlockHandle ]
                            #Deputs "ISIS route block:$hIsis"
                            #if { [ catch {
                            #    set rangeCnt [ llength [ ixNet getL $hIsis routeRange ] ]
                            #} ] } {
                            #    set rangeCnt [ llength [ ixNet getL $hIsis vpnRouteRange ] ]
                            #}
                            #
                            #if { $rangeCnt > 0 } {
                            #    set p [ ixNet getP $routeBlockHandle ]
                            #    set startIndex [ string first $p $routeBlockHandle ]
                            #    set endIndex [ expr $startIndex + [ string length $p ] - 1 ]
                            #    set routeBlockHandle \
                            #    [ string replace $routeBlockHandle \
                            #    $startIndex $endIndex $p.0 ]
                            #    Deputs "route block handle:$routeBlockHandle"		
                            #} else {
                            #    set routeBlockHandle [ $dstObj cget -hPort ]/protocols/isis
                            #}
                            set routeBlockHandle [ $dstObj cget -hPort ]/protocols/isis
                            set srcHandle [ concat $srcHandle $routeBlockHandle ]
                        } else {
                            set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
                        }
                        #set trafficType [ $srcObj cget -type ]
                    } elseif { [ $srcObj isa IxiaCapi::PoolNameObject ] } {
					    set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
					} elseif { [ $srcObj isa IxiaCapi::Host ] } {
					    set topstack [$srcObj cget -topStack ]
						puts "topstack: $topstack"
					    if { $topstack == "802DOT1X"} {
						     set trafficType "ethernetVlan"
						}
                        
                        #set trafficType [ $srcObj cget -UpperLayer ]
                        if {$trafficType == "ipv4"} {
                            set srcHandle [ concat $srcHandle [ $srcObj cget -topv4Handle ] ]
                        } elseif { $trafficType == "ipv6" } {
                            set srcHandle [ concat $srcHandle [ $srcObj cget -topv6Handle ] ]
                        } else {
                            set srcHandle [ concat $srcHandle [ $srcObj cget -topHandle ] ]
                        }
                    } elseif { [ $srcObj isa MulticastGroup ] } {
                        if { [ $srcObj cget -protocol ] == "mld" } {
                            set trafficType "ipv6"
                        } 
                        set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
                    } elseif { [ $srcObj isa IxiaCapi::BgpRouter ] } {
                        set srcHandle [ concat $srcHandle [ixNet getP [ ixNet getP [ $srcObj cget -handle ]]] ]
                    } elseif { [ $srcObj isa IxiaCapi::Ospfv2Router ] } {
                        set srcHandle [ concat $srcHandle [ixNet getP [ ixNet getP [ $srcObj cget -handle ]]] ]
                    } elseif { [ $srcObj isa IxiaCapi::Ospfv3Router ] } {
                        set srcHandle [ concat $srcHandle [ixNet getP [ ixNet getP [ $srcObj cget -handle ]]] ]
                    } elseif { [ $srcObj isa SimulatedSummaryRoute ] } {
                        #set srcHandle [ concat $srcHandle [ixNet getP [ ixNet getP [ ixNet getP [ $srcObj cget -trafficObj ] ] ] ] ]
                        set srcHandle [ concat $srcHandle [ $srcObj cget -trafficObj ] ]
                    } elseif { [ $srcObj isa SimulatedExternalRoute ] } {
                        #set srcHandle [ concat $srcHandle [ixNet getP [ ixNet getP [ ixNet getP [ $srcObj cget -hUserlsa ] ] ] ] ]
                        set srcHandle [ concat $srcHandle [ $srcObj cget -hUserlsa ] ]
                    } elseif { [ $srcObj isa SimulatedRouter ] } {
                        #set srcHandle [ concat $srcHandle [ixNet getP [ ixNet getP [ ixNet getP [ $srcObj cget -trafficObj ] ] ] ] ]
                        set srcHandle [ concat $srcHandle [ $srcObj cget -trafficObj ] ]
                    } elseif { [ $srcObj isa IxiaCapi::IsisRouter ] } {
                        set srcHandle [ concat $srcHandle [ixNet getP [ ixNet getP [ $srcObj cget -handle ]]] ]
                    } else {
                        set srcHandle [ concat $srcHandle [ $srcObj cget -handle ] ]
                    }
                }
                Deputs "src handle:$srcHandle"

                set dstHandle [ list ]	
                foreach dstEndpoint $dst {
                    # Deputs "dst:$dstEndpoint"
                    set dstObj [ GetObject $dstEndpoint ]
                    # Deputs "dstObj:$dstObj"			
                    if { $dstObj == "" } {
                    Deputs "illegal object...$dstEndpoint"
                        error " key:dst value:$dst"                
                    }
                 
                    if { [ $dstObj isa RouteBlock ] } {
                        if { [ $dstObj cget -protocol ] == "bgp" } {
                            set routeBlockHandle [ $dstObj cget -handle ]
                            set hBgp [ ixNet getP $routeBlockHandle ]
                            Deputs "bgp route block:$hBgp"
                            if { [ catch {
                                set rangeCnt [ llength [ ixNet getL $hBgp routeRange ] ]
                            } ] } {
                                set rangeCnt [ llength [ ixNet getL $hBgp vpnRouteRange ] ]
                            }

                            if { $rangeCnt > 0 } {
                                set p [ ixNet getP $routeBlockHandle ]
                                set startIndex [ string first $p $routeBlockHandle ]
                                set endIndex [ expr $startIndex + [ string length $p ] - 1 ]
                                set routeBlockHandle \
                                [ string replace $routeBlockHandle \
                                $startIndex $endIndex $p.0 ]
                                Deputs "route block handle:$routeBlockHandle"		
                            } else {
                                set routeBlockHandle [ $dstObj cget -hPort ]/protocols/bgp
                            }
                            set dstHandle [ concat $dstHandle $routeBlockHandle ]
                        } elseif { [ $dstObj cget -protocol ] == "isis" } {
                            #set routeBlockHandle [ $dstObj cget -handle ]
                            #set hIsis [ ixNet getP $routeBlockHandle ]
                            #Deputs "ISIS route block:$hIsis"
                            #if { [ catch {
                            #    set rangeCnt [ llength [ ixNet getL $hIsis routeRange ] ]
                            #} ] } {
                            #    set rangeCnt [ llength [ ixNet getL $hIsis vpnRouteRange ] ]
                            #}
                            #
                            #if { $rangeCnt > 0 } {
                            #    set p [ ixNet getP $routeBlockHandle ]
                            #    set startIndex [ string first $p $routeBlockHandle ]
                            #    set endIndex [ expr $startIndex + [ string length $p ] - 1 ]
                            #    set routeBlockHandle \
                            #    [ string replace $routeBlockHandle \
                            #    $startIndex $endIndex $p.0 ]
                            #    Deputs "route block handle:$routeBlockHandle"		
                            #} else {
                            #    set routeBlockHandle [ $dstObj cget -hPort ]/protocols/isis
                            #}
                            set routeBlockHandle [ $dstObj cget -hPort ]/protocols/isis
                            set dstHandle [ concat $dstHandle $routeBlockHandle ]
                        } else {
                            Deputs "dst obj:$dstObj"				
                            Deputs "route block handle:[$dstObj cget -handle]"				
                            set dstHandle [ concat $dstHandle [ $dstObj cget -handle ] ]
                        }
                    } elseif { [ $dstObj isa IxiaCapi::PoolNameObject ] } {
					    set dstHandle [ concat $dstHandle [ $dstObj cget -handle ] ]
					} elseif { [ $dstObj isa IxiaCapi::Host ] } {
                        Deputs " $dstObj isa Host"
                        if {$trafficType == "ipv4"} {
                            #set dstHandle [ concat $srcHandle [ $dstObj cget -topv4Handle ] ]
                            set dstHandle [ $dstObj cget -topv4Handle ] 
                        } elseif { $trafficType == "ipv6" } {
                           # set dstHandle [ concat $srcHandle [ $dstObj cget -topv6Handle ] ]
                            set dstHandle [ $dstObj cget -topv6Handle ] 
							Deputs "dstHandle : $dstHandle"
                        } else {
                            #set dstHandle [ concat $srcHandle [ $dstObj cget -topHandle ] ]
                             set dstHandle [ $dstObj cget -topHandle ] 
                        }
                    } elseif { [ $dstObj isa MulticastGroup ] } {
                        set dstHandle [ concat $dstHandle [ $dstObj cget -handle ] ]
                    } elseif { [ $dstObj isa IxiaCapi::BgpRouter ] } {
                        set dstHandle [ concat $dstHandle [ixNet getP [ ixNet getP [ $dstObj cget -handle ]]] ]
                    } elseif { [ $dstObj isa IxiaCapi::Ospfv2Router ] } {
                        set dstHandle [ concat $dstHandle [ixNet getP [ ixNet getP [ $dstObj cget -handle ]]] ]
                    } elseif { [ $dstObj isa IxiaCapi::Ospfv3Router ] } {
                        set dstHandle [ concat $dstHandle [ixNet getP [ ixNet getP [ $dstObj cget -handle ]]] ]
                    } elseif { [ $dstObj isa SimulatedSummaryRoute ] } {
                        set dstHandle [ concat $dstHandle [ixNet getP [ixNet getP [ ixNet getP [ $dstObj cget -trafficObj ]]]] ]
                        #set srcHandle [ concat $srcHandle [ $srcObj cget -trafficObj ] ]
                    } elseif { [ $dstObj isa SimulatedRouter ] } {
                        set dstHandle [ concat $dstHandle [ixNet getP [ixNet getP [ ixNet getP [ $dstObj cget -trafficObj ]]]] ]
                        #set srcHandle [ concat $srcHandle [ $srcObj cget -trafficObj ] ]
                    } elseif { [ $dstObj isa SimulatedExternalRoute ] } {
                        set dstHandle [ concat $dstHandle [ixNet getP [ixNet getP [ ixNet getP [ $dstObj cget -hUserlsa ]]]] ]
                        #set srcHandle [ concat $srcHandle [ $srcObj cget -hUserlsa ] ]
                    } elseif { [ $dstObj isa IxiaCapi::IsisRouter ] } {
                        set dstHandle [ concat $dstHandle [ixNet getP [ ixNet getP [ $dstObj cget -handle ]]] ]
                    } else {
                        set dstHandle [ concat $dstHandle [ $dstObj cget -handle ] ]
                    }
                }
                Deputs "dst handle:$dstHandle"
                #-- advanced stream Ports/Emulations
                Deputs "Traffic type: advanced stream:$trafficType"
                #-- Create advanced stream
                #-- create trafficItem      
                if { $bidirection } {
                    set bi True
                } else {
                    set bi False
                }
                if { $selfdst } {
                    set sd True
                } else {
                    set sd False
                }
                if { $fullMesh } {
                    Deputs "traffic src/dst type: full mesh"		  
                    ixNet setMultiA $handle \
                         -trafficItemType l2L3 \
                         -routeMesh oneToOne \
                         -srcDestMesh fullMesh \
                         -allowSelfDestined $sd \
                         -trafficType $trafficType ;#can be ipv4 or ipv6 or ethernetVlan

                } else {
                    if { $no_mesh } {
                        Deputs "traffic src/dst type: none"		  		  
                        ixNet setMultiA $handle \
                         -trafficItemType l2L3 \
                         -biDirectional $bi \
                         -routeMesh oneToOne \
                         -srcDestMesh none \
                         -allowSelfDestined $sd \
                         -trafficType $trafficType ;#can be ipv4 or ipv6 or ethernetVlan
                    } else {
                        Deputs "traffic src/dst type: one 2 one"		  		  
                        ixNet setMultiA $handle \
                         -trafficItemType l2L3 \
                         -biDirectional $bi \
                         -routeMesh oneToOne \
                         -srcDestMesh oneToOne \
                         -allowSelfDestined $sd \
                         -trafficType $trafficType ;#can be ipv4 or ipv6 or ethernetVlan
                    }
                }
                if { $enable_sig } {
                    ixNet setA $handle/tracking -trackBy sourceDestPortPair0
                    ixNet commit
                }
                Deputs "add endpointSet..."
                ixNet commit
                #-- add endpointSet
                set endpointSet [ixNet add $handle endpointSet]
                ixNet setA $endpointSet -sources $srcHandle
                ixNet setA $endpointSet -destinations $dstHandle
                ixNet commit
                set handle      [ ixNet remapIds $handle ]
     
                ixNet commit
            } else {                             
                set endPoint [ixNet add $handle endpointSet]
                Deputs "port:$hPort"
                set dests [list]
                set root [ixNet getRoot]
                foreach port [ ixNet getList $root vport ] {
                    Deputs "dest port:$port"
                    if { $port == $hPort } {
                        continue
                    }
                    Deputs "lappend dests..."
                   lappend dests "$port/protocols"
                }
                Deputs "dests: $dests"
                # IxDebugOff
                if { [ llength $dests ] == 0 } {
                    ixNet setMultiA $endPoint -sources "$hPort/protocols" -destinations "$hPort/protocols"
                } else {
                    ixNet setMultiA $endPoint -sources "$hPort/protocols" -destinations $dests
                }
           
                ixNet commit
                set handle      [ ixNet remapIds $handle ]
                set endPoint [ ixNet remapIds $endPoint ]
                ixNet setA $handle/tracking -trackBy sourceDestPortPair0
                ixNet commit
            }
			
        } result ] } {
            IxiaCapi::Logger::LogIn -type exception -message "$errorInfo" -tag $tag
        } else {
            #set hStream [ lindex [ ixNet getList $handle highLevelStream ] end ]
			
			set hStream [ ixNet getList $handle configElement ]
			puts "hStream: $hStream"
            $proObj RefreshStreamLoad
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_StreamCtor2 \n\t\
            Profile name: $ProfileName"
        }
		set hTrafficItem $handle
		Traffic ${this}_item $PortObj $hTrafficItem  
		return $this
    }
    
    body Stream::AddPdu { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::true IxiaCapi::false
        global errorInfo
        
        set tag "body Stream::AddPdu [info script]"
        Deputs "----- TAG: $tag -----"
        Deputs "args: $args"
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -names -
                -pduname {
                    #set nameList $value
					set nameList [::IxiaCapi::NamespaceDefine $value]
                }
            }
        }
        
        if { [ info exists nameList ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_common1 \
            $IxiaCapi::s_StreamAddPdu2" -tag $tag
                        return $IxiaCapi::errorcode(3)                        
        } else {
            Deputs "name list: $nameList"
        }

        set err 0
        set index 0
		set fgindex 0
        foreach name $nameList {
            # Read type protocol message
            if { [ catch {
                set protocol [ uplevel 1 " $name cget -protocol " ]
                Deputs "Pro: $protocol "

                set type [ string toupper [ uplevel 1 " $name cget -type " ] ]
                if { ( $protocol == "custom" ) && ( $fgindex == 0 ) } {
                    set type SET
                }
                Deputs "Type $type "
            } ] } {
                Deputs "Objects:[find obj]"
                IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_common1 \
                $IxiaCapi::s_StreamAddPdu1 $name" -tag $tag
                set err 1
                continue
            } else {
                set proStack [ GetProtocolTemp $protocol ]
                Deputs "protocol stack: $proStack"
            }
            # Set or Append pdu protocols
            if { [ catch {
                set stack  [ lindex [ ixNet getList $hStream stack ] 0 ]
                Deputs "type:$type"
                set needMod 1
                switch -exact -- $type {
                    SET {
                        Deputs "stream:$hStream"
                        set stackList [ ixNet getList $hStream stack ]
                        Deputs "Stack list:$stackList"
                        while { 1 } {
                            set stackList [ ixNet getList $hStream stack ]
                            Deputs "Stack list after removal:$stackList"
                            if { [ llength $stackList ] == 2 } {
                                break
                            }
                            ixNet exec remove [ lindex $stackList [ expr [ llength $stackList ] - 2  ] ]
                        }
                        Deputs "Stack ready to add:$stackList"
                        ixNet exec append [ lindex $stackList 0 ] $proStack
                        ixNet exec remove [ lindex $stackList 0 ]
                        set stack  [ lindex [ ixNet getList $hStream stack ] 0 ]
                        set stackLevel 1
                    }
                    APP {
                        Deputs "stream:$hStream"
                        set stackList [ ixNet getList $hStream stack ]
                        Deputs "Stack list:$stackList"
                        set appendHeader [ lindex $stackList [expr $stackLevel - 1] ]
                        Deputs "appendHeader:$appendHeader"
                        Deputs "stack to be added: $proStack"
                        ixNet exec append $appendHeader $proStack
                        set stack [lindex [ ixNet getList $hStream stack ] $stackLevel]
                        Deputs "stack:$stack"
                        incr stackLevel
                        Deputs "stackLevel:$stackLevel"
                        #set stack ${hStream}/stack:\"[ string tolower $protocol ]-${stackLevel}\"
                    }
                    MOD {
                        set index 0
                        Deputs "protocol:$protocol"
                        foreach pro [ ixNet getList $hStream stack ] {
                            Deputs "pro:$pro"
                            if { [ regexp -nocase $protocol $pro ] } {
                                if { [ regexp -nocase "${pro}\[a-z\]+" $stack ] == 0 } {
                                    break
                                }
                            }
                            incr index
                        }
                        set stack $pro
                    }
                    default { }
                }
                ixNet commit
                catch {
                    set stack [ ixNet remapIds $stack ]
                }
                Deputs "Stack:$stack"
                set appendHeader $stack
                Deputs "Stack list:[ ixNet getList $hStream stack ]"
            } ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                Deputs "error occured..."
                set err 1
                continue
            }
            if { $needMod == 0 } {

                incr index
                continue
            }
            # Modify fields
            if { [ catch {
			    if {$protocol == "custom"} {
				    set raw [ uplevel 1 " $name cget -raw " ]
                    Deputs "raw: $raw"
					set raw [ List2Str $raw ]
                    Deputs "raw: $raw"
					#set customStack [ lindex [ ixNet getList $hStream stack ] 0 ]
					set customStack $stack
                    Deputs "customStack:$customStack"
					set fieldList [ ixNet getList $customStack field ]
                    #Deputs "fieldList: $fieldList"
					set rawLen [expr [string length $raw] * 4]
                    Deputs "rawLen:$rawLen"
					ixNet setA [ lindex $fieldList 0 ] -singleValue $rawLen
					ixNet commit
				    if { [ regexp -nocase {^0x} $raw ] } {
					    ixNet setA [ lindex $fieldList 1 ] -singleValue $raw
				    } else {
					    ixNet setA [ lindex $fieldList 1 ] -singleValue 0x$raw
				    }
					ixNet commit	
				} else {
                    set fieldModes [ uplevel 1 " $name cget -fieldModes " ]
                    set fields [ uplevel 1 " $name cget -fields " ]
                    set fieldConfigs [ uplevel 1 " $name cget -fieldConfigs " ]
                    set optional [ uplevel 1 " $name cget -optionals " ]
                    set autos [ uplevel 1 " $name cget -autos " ]
                    Deputs "name list len: [llength $nameList]"
                    if { [ lsearch -exact $fields "etherType" ] < 0 } {
                        if { [ llength $nameList ] == 1 } {
                            Deputs "protocol:$protocol"
                            if { [ string tolower $protocol ] == "ethernet" } {
                                lappend fieldModes Fixed
                                lappend fields     etherType
                                lappend fieldConfigs 0x88b5
                                lappend autos       0
                                lappend optional    0
                            }
                        } else {
                            if { [ string tolower $protocol ] == "ethernet" } {
                                lappend fieldModes Reservedf
                                lappend fields     etherType
                                lappend fieldConfigs 0
                                lappend autos       1
                                lappend optional    0
                            }
                        }
                    }
                
                    foreach mode $fieldModes field $fields conf $fieldConfigs\
                        opt $optional auto $autos {
                        Deputs "stack:$stack"
                        Deputs "field:$field"
                        set obj [ GetField $stack $field ]
                        Deputs "Field object: $obj"
                        
                        if { $obj == "" } {
                            continue
                        }

                        if { [ info exists opt ] } {
                            if { $opt == "" } { continue }
                            if { $opt } {
							    ixNet setA $obj -activeFieldChoice True
                                ixNet setA $obj -optionalEnabled True
                                continue
                            }
                        } else {
                            continue
                        }
                        if { [ info exists auto ] } {
                            if { $auto == "" } { continue }
                            if { $auto } {
                                ixNet setA $obj -auto True
                                continue
                            } else {                     
                                ixNet setA $obj -auto False
                            }
                        } else {
                            continue
                        }
                        if { [ info exists mode ] == 0 || [ info exists field ] == 0 ||\
                            [ info exists conf ] == 0 } {
                            Deputs "continue"
                            continue
                        }
                        Deputs "Mode:$mode"
                        switch -exact $mode {
                            Fixed {
                                Deputs "Fixed:$protocol\t$field\t$conf"
                                ixNet setMultiAttrs $obj \
                                -valueType singleValue \
                                -singleValue $conf
                            }
                            List {
                                Deputs "List:$protocol\t$field\t$conf"
                                ixNet setMultiAttrs $obj \
                                -valueType valueList
                                -valueList $conf
                            }
                            Segment {
                                #set offset [ AgtInvoke AgtPduHeader GetFieldBitOffset \
                                #   $hPdu $protocol 1 $field ]
                                #Deputs "Offset: $offset"
                                #AgtInvoke AgtRawPdu SetPduBytes $hPdu \
                                #   [ expr $offset / 8 ] [ string length $conf ] $conf
                            }
                            Reserved {
                                Deputs "Reserved...continue"
                                continue
                            }
                            Incrementing -
                            Decrementing {
                                set mode [string range $mode 0 8]
                                set mode [string tolower $mode]
                                Deputs "Mode:$mode\tProtocol:$protocol\tConfig:$conf"
                                set start [lindex $conf 1]
                                set count [lindex $conf 2]
                                set step  [lindex $conf 3]
                                Deputs "obj:$obj mode: $mode start:$start count:$count step:$step"
                                ixNet setMultiAttrs $obj \
                                    -valueType $mode \
                                    -countValue $count \
                                    -stepValue $step \
                                    -startValue $start
                            }
                            Commit {
                                ixNet setMultiAttrs $obj \
                                -valueType singleValue \
                                -singleValue $conf
                                ixNet commit
                            }
                        }
						ixNet commit
                    }
                }
		    }] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                Deputs "error occured..."
                set err 1
                IxiaCapi::Logger::LogIn -type warn -message \
                    "$IxiaCapi::s_StreamAddPdu3 $name" -tag $tag
                continue
            } else {
                IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_StreamAddPdu4 $name"
            }
            incr index
			incr fgindex
        }

        if { [ catch {
            ixNet commit
        } ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
            
            return $IxiaCapi::errorcode(7)
        }
		
		ixNet setA $hTrafficItem/tracking -trackBy sourceDestPortPair0
        ixNet commit
		
		ixNet setM $hStream/framePayload \
			-customRepeat true \
			-type custom \
			-customPattern "00"
		
        if { $err } {
            return $IxiaCapi::errorcode(4)                        
        }
        
        return $IxiaCapi::errorcode(0)                        
    }

    body Stream::ClearPdu {} {
        global IxiaCapi::fail IxiaCapi::success
        if { [ catch {
            AgtInvoke AgtStreamGroup SetPduHeaders $hStream \
            [ AgtInvoke AgtStreamGroup GetDefaultL2Protocol $portObj ]
            } result ] } {
            IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                        return $IxiaCapi::errorcode(7)                        
        } else {
                        return $IxiaCapi::errorcode(0)                        
        }
    }
    body Stream::destructor {} {
        global errorInfo
        if { [
        catch {
            #ixNet setA $hStream -suspend True
			ixNet remove $hTrafficItem
            ixNet commit
			delete object ${this}_item
        }
        ] } {
Deputs $errorInfo
        }
    }
    body Stream::DestroyPdu { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::true IxiaCapi::false
        global errorInfo
        
        set tag "body Stream::DestroyPdu [info script]"
Deputs "----- TAG: $tag -----"
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -names -
                -pduname {
                    set nameList $value
					#set nameList [ IxiaCapi::NamespaceConvert $value $PduList ]
                }
            }
        }
        
        if { [ info exists nameList ] == 0 } {
            #IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_common1 \
            #$IxiaCapi::s_StreamAddPdu2" -tag $tag
            #            return $IxiaCapi::errorcode(3)
            IxiaCapi::TrafficManager DeleteAllPdu
                        return $IxiaCapi::errorcode(0)                        
            
        }
        
        foreach pdu $nameList {
            if { [ catch {
                set obj [ IxiaCapi::Regexer::GetObject $pdu ]
                delete object $obj
                #uplevel 1 "delete object $pdu"
            } ] } {
Deputs "$errorInfo"
            }
        }
                        return $IxiaCapi::errorcode(0)                        
    }
    body Stream::GetProtocolTemp { pro } {
Deputs "Get protocol..."
Deputs "protocol to match:$pro"
        set root [ixNet getRoot]
        set protocolTemplateList [ ixNet getList $root/traffic protocolTemplate ]
        set index 0
        foreach protocol $protocolTemplateList {
            if { [ regexp -nocase $pro $protocol ] } {
                if { [ regexp -nocase "${pro}\[a-z\]+" $protocol ] == 0 } {
                    break
                }
            }
            incr index
        }
        if { $index < [llength $protocolTemplateList] } {
            return [ lindex $protocolTemplateList $index ]
        } else {
            return ""
        }
    }
    
    body Stream::GetField { stack value } {
Deputs "value:$value"
Deputs "stack: $stack"
        set stack [lindex $stack 0]
        set fieldList [ ixNet getL $stack field ] 
		
#Deputs "fieldList:$fieldList"
        set index 0
        foreach field $fieldList {
#Deputs "field:$field"
            if { [ regexp $value $field ] } {
                if { [ regexp "${value}\[a-z\]+" $field ] == 0 } {
                    break
                }
            }
            incr index
        }
        if { $index < [llength $fieldList] } {
            return [ lindex $fieldList $index ]
        } else {
            return ""
        }
    }
    
    body Stream::SetProfileParam {} {
        set tag "body Stream::SetProfileParam [info script]"
Deputs "----- TAG: $tag -----"
        set rateUnit    1

        set proObj [ IxiaCapi::Regexer::GetObject $ProfileName ]
        set type [ uplevel "$proObj cget -Type" ]
        set port [ uplevel "$proObj cget -hPort" ]
        set mode [ uplevel "$proObj cget -Mode" ]
        set load [ uplevel "$proObj cget -TrafficLoad" ]
        set streamCnt [ uplevel "$proObj GetStreamCount" ]
        set load [ expr $load / ${streamCnt}.0 ]
        set unit [ uplevel "$proObj cget -TrafficLoadUnit" ]
        set bSize [ uplevel "$proObj cget -BurstSize" ]
        set frameLen [ uplevel "$proObj cget -FrameLen" ]
Deputs "proObj:$proObj type:$type port:$port mode:$mode load:$load unit:$unit bSize:$bSize frameLen:$frameLen"
Deputs "hStream: $hStream"

        switch $unit {
            PPS -
            FPS -
            L3MBPS {
                ixNet setA $hStream/frameRate -type framesPerSecond
            }
            PERCENT {
                ixNet setA $hStream/frameRate -type percentLineRate
            }
            MBPS -
            BPS -
            KBPS {
                ixNet setA $hStream/frameRate -type bitsPerSecond
            }
        }

        switch $unit {
            MBPS {
                ixNet setA $hStream/frameRate -bitRateUnitsType mbitsPerSec
            }
            L3MBPS {
                set rateUnit    1000000
            }
            BPS {
                ixNet setA $hStream/frameRate -bitRateUnitsType bitsPerSec
            }
            KBPS {
                ixNet setA $hStream/frameRate -bitRateUnitsType kbitsPerSec
            }
        }
        set load [expr $load * $rateUnit]
        ixNet setA $hStream/frameRate -rate $load
        
        if { $type == "CONSTANT" } {
            if { $frameLen > 0 } {
                ixNet setA $hStream/transmissionControl -type fixedFrameCount
                ixNet setA $hStream/transmissionControl -frameCount $frameLen
            } else {
                ixNet setA $hStream/transmissionControl -type continuous
            }
        } else {
            ixNet setA $hStream/transmissionControl -type custom
        }

        ixNet setA $hStream/transmissionControl -burstPacketCount $bSize
        
        ixNet commit
    }
}


