# IxNetHost.tcl --
#   This file implements the Host class for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1

namespace eval IxiaCapi {
    
    class Host {
        constructor { } {}
        method Config { args } {}
        method SendArpRequest { args } {}
        method Ping { args } {}
        destructor {}
        
        method SetMacAddr {value} {
            set MacAddr $value
        }
        method SetSutMac {value} {
            set SutMac $value
        }
        method SetArpd {value} {
            set Arpd $value
        }
        method SetUniqueMac {value} {
            set UniqueMac $value
        }
        private variable hv4AddPool
        private variable hv6AddPool
        method GetPoolv4 {} {
            return $hv4AddPool
        }
        method GetPoolv6 {} {
            return $hv6AddPool
        }
        method SethPoolv4 {value} {
            set hv4AddPool $value
        }
        method SethPoolv6 {value} {
            set hv6AddPool $value
        }
		method SettopStack {value} {
		    set topStack $value
		}
		method SettopHandle {value { ipversion ipv4 }} {
		    set topHandle $value
            if {$ipversion == "ipv4"} {
                set topv4Handle $value
            } else {
                set topv6Handle $value
            }
		}
        public variable Ipv4Addr
        public variable Ipv4Mask
        public variable Ipv4SutAddr
        public variable Ipv6Addr
        public variable Ipv6Mask
        public variable Ipv6SutAddr
        public variable Ipv4Step
        public variable Ipv6Step
        public variable Arpd
        public variable MacAddr
        public variable SutMac
        public variable UniqueMac
        
        public variable hPort
        public variable interface
        public variable ipv4Int
        public variable ipv6Int
		public variable UpperLayer 
        public variable handle
        #public variable ethInt
		public variable hostNum
		public variable hostInfo
		public variable topStack
		public variable topHandle
        public variable topv4Handle
        public variable topv6Handle
        
        public variable flagPing
    }
        
    body Host::constructor { } {

        set tag "body Host::Ctor [info script]"
Deputs "----- TAG: $tag -----"
        set handle ""
		set topHandle ""
		set hostNum 1
		set topStack "Protocol Interface"
		#set hostInfo $args
        #eval Config $args
                
    }
    
    
    
    
    
    body Host::Config { args } {

        set tag "body Host::Config [info script]"
Deputs "----- TAG: $tag -----"
        set hPort   -1
		set UpperLayer ipv4
        set count 1
        #set Ipv4Addr "192.168.1.2"
        set Ipv4Mask 16
		set ipv4_addr_step 0.0.0.0
		set ipv4_gw_step 0.0.0.0
        #set Ipv4SutAddr [ list 192.168.1.1 ]
        #set Ipv6Addr "2000:201::1:2"
        set Ipv6Mask 64
		set ipv6_addr_step 	"::0"
		set ipv6_gw_step "::0"
        #set Ipv6SutAddr [ list 2000:201::1:1 ]
        set Arpd 1
        set Ipv4Step 1
        set Ipv6Step 1
        #set MacAddr 00:00:00:00:00:01
		set src_mac_step 00:00:00:00:00:01
        set SutMac [ list 00:00:00:00:00:00 ]
        set UniqueMac 0
        set hv4AddPool -1
        set hv6AddPool -1
        set enabled True
        set hostInfo $args
		set ETag [ list 0x8100 0x88a8 0x9100 0x9200 ]
Deputs "Args:$args"
        foreach { key value } $args {
            set key [string tolower $key]
Deputs "Key :$key \tValue :$value"
            switch -exact -- $key {
                -hport {
                    set hPort   $value
                }
                -active {
				    set value [string tolower $value]
				    if { $value == "enable" } {
                       set enabled "True"
					} else {
					   set enabled "False"
					}
                }
                -hostnum {
                    set count $value
					set hostNum $value
                }
				-upperlayer {
                    set UpperLayer  [string tolower $value]
					
                }
                -macaddr {
                    set src_mac [ IxiaCapi::Regexer::MacTrans $value ]
                }
                -sourcemacmodifier {
                    set src_mac_step  [ IxiaCapi::Regexer::MacTrans $value ]
                }
                -srcip -
                -ipv4addr {
                    if {[IxiaCapi::Regexer::IsIPv4Address $value]} {
                        set ipv4_addr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostCtor1 $value" -tag $tag
                    }
                }
                -ipv4mask {
                    if { [ string is integer $value ] && $value <= 32 } {
                        set Ipv4Mask $value
                    } else {
                        if { ![ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostCtor2 $value"
                        } else {
                            set Ipv4Mask [ IxiaCapi::Regexer::SubnetToPrefixlenV4 $value ]
Deputs "IPV4 Mask:$ Ipv4Mask"
                        }
                    }
                }
                -ipv4gatewayaddr {
                    set ipv4_gw $value
                }                
                -ipv4sutaddr {
                    
                    set Ipv4SutAddr [ list ]
Deputs "SUT list: $value"
                    foreach addr $value {
Deputs "SUT: $addr"
                        if {[IxiaCapi::Regexer::IsIPv4Address $addr]} {
                            lappend Ipv4SutAddr $addr
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostCtor10 $addr"                               
                        }
                    }
                    if { [ llength $Ipv4SutAddr ] == 0 } {
                        lappend Ipv4SutAddr 192.168.1.1
                    }
                }
                -ipv4gatewaymodifier {
                    set ipv4_gw_step $value
                }
                -ipv4addrsteptohost {
                    set ipv4_addr_step $value
                }
                -srcipv6 -
                -ipv6addr {
                    if {[IxiaCapi::Regexer::IsIPv6Address $value]} {
                        set ipv6_addr [ ::ip::normalize $value ]
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostCtor3 $value"                               
                    }
                }
                -ipv6addrsteptohost {
                    set ipv6_addr_step [ ::ip::normalize $value ]
                }
                -ipv6mask {
                    if { [ string is integer $value ] && $value <= 128 } {
                        set Ipv6Mask $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostCtor4 $value"                               
                    }
                }
                -ipv6gatewayaddr {
                    set ipv6_gw [ ::ip::normalize $value ]
                }
                -ipv6sutaddr {
                    set Ipv6SutAddr [ list ]
                    foreach addr $value {
                        if {[IxiaCapi::Regexer::IsIPv6Address $addr]} {
                            lappend Ipv6SutAddr $addr
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostCtor11 $addr"                               
                        }
                    }
                    if { [ llength $Ipv6SutAddr ] == 0 } {
                        lappend Ipv6SutAddr 2000:201::1:1
                    }
                }
				-ipv6gatewaymodifier {
                    set ipv6_gw_step [ ::ip::normalize $value ]
                }
				-tag -
                -vlantag -
                -vlantype1 {
                    if { [ lsearch -exact $ETag $value ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_VlanSubIntConfigPort3 $ETag" -tag $tag
                        set err 1
                    } else {
                        set VlanTag $value
                    }
                }
                -prior -
                -vlanpriority1 {
                    if { [ string is integer $value ] } {
                        set VlanPrior $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_VlanSubIntConfigPort1 $value" -tag $tag
                        set err 1
                    }
                }
                -vlanid1 {
                    if { [ string is integer $value ] } {
                        set VlanId $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_VlanSubIntConfigPort2 $value" -tag $tag
                        set err 1
                    }
                }
                -flagping {
                    set flagPing [ IxiaCapi::Regexer::BoolTrans $value ]
                }
            }
        }
        
        if { [ info exists flagPing ] } {
		
            if { $flagPing } {
                ixNet setA $hPort/protocols/ping -enabled True
            } else {
                ixNet setA $hPort/protocols/ping -enabled False
            }
        }
		
		if { $ipv4_addr_step != "0.0.0.0" } {
			set pfxIncr 	[ IxiaCapi::Regexer::GetStepPrefixlen $ipv4_addr_step ]
		} else {
			set pfxIncr 0
		}
		puts "pfxIncr: $pfxIncr"
		if { $ipv4_gw_step != "0.0.0.0" } {
	   
			set gwPfxIncr	[ IxiaCapi::Regexer::GetStepPrefixlen $ipv4_gw_step ]
			
		} else {
			set gwPfxIncr 0
		}
		puts "gwPfxIncr: $gwPfxIncr"
		
		if { $ipv6_addr_step != "::0" } {
		
			set v6pfxIncr 	[ IxiaCapi::Regexer::GetStepv6Prefixlen $ipv6_addr_step ]
		} else {
	
			set v6pfxIncr 0
		}
	
		puts "v6pfxIncr: $v6pfxIncr"
		if { $ipv6_gw_step != "::0" } {
	    puts $ipv6_gw_step
			set v6gwPfxIncr	[ IxiaCapi::Regexer::GetStepv6Prefixlen $ipv6_gw_step ]
			
		} else {
			set v6gwPfxIncr 0
		}
		puts "v6gwPfxIncr:$v6gwPfxIncr"
        
        for { set index 0 } { $index < $count } { incr index } {
    
            set interface [ ixNet add $hPort interface ]
			puts $interface
            ixNet setA $interface -description ${this}_${index}
            ixNet commit 
            set interface [ ixNet remapIds $interface ]
			lappend handle $interface
			set topHandle $interface
       		
            if { [ info exists src_mac ] } {
		
               ixNet setA $interface/ethernet -macAddress $src_mac
			Deputs $src_mac
               ixNet commit
			
			   set src_mac [ IxiaCapi::Regexer::IncrMacAddr $src_mac $src_mac_step ]
			
			   
            }
			
			ixNet setA $interface -enabled $enabled
			if {![ info exists ipv4_addr ]} {
                set UpperLayer "ipv6"
            }
		    
            if { $UpperLayer == "ipv4" || $UpperLayer == "dualstack" } {
		
			   
                if { [ info exists ipv4_addr ] } {
			
                    set ipv4Int   [ ixNet add $interface ipv4 ]
					puts $ipv4Int
                    ixNet setMultiAttr $ipv4Int \
                        -ip $ipv4_addr \
                        -maskWidth $Ipv4Mask
                    puts $ipv4Int
                    if { [ info exists Ipv4SutAddr ] } {
                        ixNet setA $ipv4Int \
                          -gateway $Ipv4SutAddr 
                    }
					if { [ info exists ipv4_gw ] } {
                        ixNet setA $ipv4Int \
                          -gateway $ipv4_gw 
                    }
                    ixNet commit
                }
                if { $pfxIncr > 0 } {
					set ipv4_addr [ IxiaCapi::Regexer::IncrementIPAddr $ipv4_addr $pfxIncr 1 ]
					
				}
				if { [ info exists gwPfxIncr ] && $gwPfxIncr > 0 } {
					set ipv4_gw [ IxiaCapi::Regexer::IncrementIPAddr $ipv4_gw $gwPfxIncr 1 ]
					
				}
                set ipv4Int   [ixNet remapIds $ipv4Int]
				SettopHandle $ipv4Int
				
            }
            if { $UpperLayer == "ipv6" || $UpperLayer == "dualstack" } {
		
            
                if { [ info exists ipv6_addr ] } {
				   
                    set ipv6Int   [ ixNet add $interface ipv6 ]
                    ixNet setMultiAttr $ipv6Int \
                        -ip $ipv6_addr \
                        -maskWidth $Ipv6Mask
                  
                    if { [ info exists Ipv6SutAddr ] } {
                        ixNet setA $ipv6Int \
                          -gateway $Ipv6SutAddr 
                    }
					
					if { [ info exists ipv6_gw ] } {
                        ixNet setA $ipv6Int \
                          -gateway $ipv6_gw 
                    }
                }
                ixNet commit
				
                if { $v6pfxIncr != 0 } {
					set ipv6_addr [ IxiaCapi::Regexer::IncrementIPv6Addr $ipv6_addr  $v6pfxIncr 1 ]
				}
				if { $v6gwPfxIncr != 0 } {
					set ipv6_gw   [ IxiaCapi::Regexer::IncrementIPv6Addr $ipv6_gw  $v6gwPfxIncr 1 ]
				}
                set ipv6Int   [ixNet remapIds $ipv6Int]
				SettopHandle $ipv6Int "ipv6"
            }
		
		
		
            if { [ info exists VlanId ] } {
                set vlanInt   [ ixNet add $interface vlan ]
                ixNet setMultiAttrs $vlanInt  \
                    -vlanEnable True    \
                    -vlanId $VlanId
                if { [ info exists VlanTag ] } {
                    ixNet setA $vlanInt -tpid $VlanTag
                }
                if { [ info exists VlanPrior ] } {
                    ixNet setA $vlanInt -vlanPriority $VlanPrior
				
                }
				set e [ixNet getA $interface/ethernet -macAddress]
			   puts "e:$e"
            }
			ixNet commit
        }
		
        
        
      
    }
    
    
    body Host::destructor {} {
        global errorInfo
        if { [
        catch {
            #ixNet remove $interface
			ixNet remove $handle
			
            ixNet commit
        } ] } {
Deputs $errorInfo
        }
    }
    
    body Host::SendArpRequest { args } {

        set tag "body Host::SendArpRequest [info script]"
Deputs "----- TAG: $tag -----"
Deputs "----- args: $args -----"
        set retries 3
        set timer   1
        foreach { key value } $args {
           set key [string tolower $key]
           switch -exact -- $key {
              -host {
                 set host $value
              }
              -retries {
                 set retries $value
              }
              -timer {
                 set timer $value
              }		  
           }
        }
# Param collection --
        
        for { set index 0 } { $index < $retries } { incr index } {
            ixNet exec sendArp $interface
            after [ expr $timer * 1000 ]
        }
        return $IxiaCapi::errorcode(0)
    }
    
    
    
    body Host::Ping { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::true IxiaCapi::false IxiaCapi::enable IxiaCapi::disable
        global errorInfo
        set tag "body Host::Ping [info script]"
Deputs "----- TAG: $tag -----"
        set interval 3
        set count    4
# Param collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -host {
                    if { [ IxiaCapi::Regexer::IsIPv4Address  $value ] && ![ IxiaCapi::Regexer::IsIPv4MulticastAddress $value ] } {
                        set address $value
                    } else {
                        set hostname $value
                    }
                }
                -count {
                    if {[string is integer $value] && ($value > 0)} {
                            set count $value
                    } else {
                            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostPing2 $value" -tag $tag 
                            return $IxiaCapi::errorcode(1)
                    }
                }
                -interval {
                    if {[string is integer $value] && ($value > 0)} {
                            set interval $value
                    } else {
                            IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostPing3 $value" -tag $tag 
                            return $IxiaCapi::errorcode(1)
                    }
                }
                -source {
                    if { [ IxiaCapi::Regexer::IsIPv4Address  $value ] && ![ IxiaCapi::Regexer::IsIPv4MulticastAddress $value ] } {
                        set srcIp $value
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_HostPing1 $value" -tag $tag
                        return $IxiaCapi::errorcode(1)
                    }
                }
                -tx {
                    set tx  $value
                }
                -rx {
                    set rx $value
                }
                -max {
                    set max $value
                }
                -min {
                    set min $value
                }
                -avg {
                    set avg $value
                }
                -pct_loss {
                    set pct_loss $value
                }
                -result {
                    set result $value
                }
                -pad -
                -size -
                -ttl -
                -timeout -
                -tos {}
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_common1 $key\n\t\
                    $IxiaCapi::s_common4 -Host\t-Count\t-Interval\t\
                    -Source\t-Tx\t-Rx\t-Max\t-Min\tAvg\tPct_loss\t-Result" -tag $tag
                    return $IxiaCapi::errorcode(1)
                }
            }
        }
        if { [ info exists hostname ] } {
            if { [ catch {
                set dstIp [ uplevel "$hostname cget -Ipv4SutAddr" ]
            } ] } {
                IxiaCapi::Logger::LogIn -type err -message "$IxiaCapi::s_HostPing4 $value" -tag $tag 
                return $IxiaCapi::errorcode(4)
            } 
        } else {
            if { [ info exists address ] } {
                set dstIp   $address
            } else {
                set dstIp   $Ipv4SutAddr
            }
        }
Deputs "DstIp:$dstIp"
        if { [ catch {
# Ping emulation configuration
            set rx 0
            for { set index 1 } { $index <= $count } { incr index } {
                set pingResult [ ixNet exec sendPing $interface $dstIp ]
Deputs "pingResult:$pingResult"
                if { [ regexp {fail} $pingResult ] == 0 } {
                    incr rx
                }
            }
            set ret [list -tx $count -rx $rx]
Deputs "result:$ret"
            uplevel "set $result \{$ret\}"
        } ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag 
                return $IxiaCapi::errorcode(7)
        }
                return $IxiaCapi::errorcode(0)
    }
    
    
    
    
}

