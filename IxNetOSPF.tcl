namespace eval IxiaCapi {   
    class Ospfv2Router {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
        constructor { Port { routerId null } } {
            set tag "body Ospfv2Router::ctor [info script]"
            Deputs "----- TAG: $tag -----"

            set className Ospfv2Session
            Ospfv2Session ${this}_c  $Port
            if { $routerId != "null" } {
               ${this}_c config -terouter_id $routerId
            }
            set handle [ ${this}_c cget -handle ]
            set objName ${this}_c
			set argslist(-routerid)                -router_id
            set argslist(-advertisingrouter)                -router_id
            set argslist(-abr)                -abr
            set argslist(-asbr)                -asbr
			set argslist(-macaddr)                  -mac_addr
			set argslist(-ipaddr)                 -ipv4_addr
			set argslist(-prefixlength)            -prefix_len
            set argslist(-firstaddress)            -first_addr
            set argslist(-modifier)            -modifier
            set argslist(-metric)            -metric
            set argslist(-prefixlen)            -ipv4_prefix_len
            set argslist(-numaddress)            -num_addr
            set argslist(-area)                  -area_id
            set argslist(-type)                  -type
			set argslist(-sutipaddress)            -ipv4_gw
			set argslist(-sutprefixlen)            -ipv4_prefix_len			
            #set argslist(-sutrouterid)                  -areaid
			set argslist(-deadinterval)                  -dead_interval
			set argslist(-hellointerval)                -hello_interval
			
			set argslist(-networktype)               -network_type
			#set argslist(-routertype)                 -areaid2
            
            set argslist(-pduoptionvalue)              -options         
            #set argslist(-flaggre)            -level
			#set argslist(-polllinterval)                  -metric
			
			set argslist(-retranssmitinterval)         -retransmit_interval
			#set argslist(-transitdelay)       -FlagRestartHelper
			#set argslist(-maxlsasperpacket)          -FlagDropSutLsp
			set argslist(-interfacecost)     -if_cost
			set argslist(-routerpriority)           -priority
			#set argslist(-mtu)        -L2RouterPriority
			#set argslist(-flaghostroute)        -L1RouterPriority
			#set argslist(-restarreason)            -RoutingLevel
			#set argslist(-active)                -AuthType
			#set argslist(-authenticationtype)         -AuthPasswordIIh
			#set argslist(-password)            -AuthPassword
			#set argslist(-md5keyid)            -AuthPassword                 
        }
        
        method Ospfv2SetSession { args } {
            set tag "body Ospfv2Router::Ospfv2SetSession [info script]"
            Deputs "----- TAG: $tag -----"
           
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            eval $objName config $newargs
        }
        
        method CreateTopSummaryRouteBlock { args } {
            set tag "body Ospfv2Router::CreateTopSummaryRouteBlock [info script]"
            Deputs "----- TAG: $tag -----"
            set prefixlen 16
			set number 1
			set modifier 1
			
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blockname [::IxiaCapi::NamespaceDefine $value]
												
					}
					-startingaddress {
					    set startingaddress $value
												
					}
					-prefixlen {
					    set prefixlen $value
												
					}
					-number {
					    set number $value
												
					}
					-modifier {
					    set modifier $value	
					}
				}
			}
            
            RouteBlock $blockname
            eval $blockname config -start $startingaddress \
			    -step $modifier \
				-prefix_len $prefixlen \
				-num $number
        }
        
        method ConfigRouteBlock { args } {
            set tag "body Ospfv2Router::ConfigRouteBlock [info script]"
            Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blockname [::IxiaCapi::NamespaceDefine $value]
												
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  			
            eval $blocknamename config $newargs
            eval $objName set_route -route_block $blockname
			     
        }
		
		method AddTopRouter { args } {
            set tag "body Ospfv2Router::AddTopRouter [info script]"
            Deputs "----- TAG: $tag -----"
            set routertypevalue "normal"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-routername {
					    set routername [::IxiaCapi::NamespaceDefine $value]
												
					}
					-routerid {
					    set routerid $value
												
					}
					-routertypevalue {
					    set routertypevalue $value	
					}
				}
			}
           SimulatedRouter $routername $objName
		   eval $routername config -id $routerid -type $routertypevalue  
        }
		method CreateTopExternalRouteBlock { args } {
            set tag "body Ospfv2Router::CreateTopExternalRouteBlock [info script]"
            Deputs "----- TAG: $tag -----"
            set prefixlen 16
			set number 1
			set modifier 1
			
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blockname [::IxiaCapi::NamespaceDefine $value]
												
					}
					-startingaddress {
					    set startingaddress $value
												
					}
					-prefixlen {
					    set prefixlen $value
												
					}
					-number {
					    set number $value
												
					}
					-modifier {
					    set modifier $value
												
					}
				}
			}
            
            RouteBlock $blockname
            eval $blockname config -start $startingaddress \
			    -step $modifier \
				-prefix_len $prefixlen \
				-num $number
           
            
        }
		
		method AddTopRouterLink { args } {
            set tag "body Ospfv2Router::AddTopRouterLink [info script]"
            Deputs "----- TAG: $tag -----"
            set linkmetric 1

            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-routername {
					    set routername [::IxiaCapi::NamespaceDefine $value]
												
					}
					-linkname {
					    set linkname [::IxiaCapi::NamespaceDefine $value]
												
					}
					-linkconnectedname {
					    set linkconnectedname [::IxiaCapi::NamespaceDefine $value]
												
					}
					-linkmetric {
					    set linkmetric $value
												
					}
				}
			}
           #SimulatedRouter $routername $this
		   Deputs "routername:$routername"
		   SimulatedLink $linkname $objName
		   eval $linkname config -metric $linkmetric -route_block $linkconnectedname
            
        }
        
        method StartRouter {} {
            set tag "body Ospfv2Router::StartRouter [info script]"
            Deputs "----- TAG: $tag -----"
            eval $objName start          
        }
        method StopRouter {} {
            set tag "body Ospfv2Router::StopRouter [info script]"
            Deputs "----- TAG: $tag -----"
            eval $objName stop
        }
        method AdvertiseLinks { args } {
            set tag "body Ospfv2Router::AdvertiseLinks [info script]"
            Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-linknamelist {
					    set linknamelist [::IxiaCapi::NamespaceDefine $value]
												
					}
				}
			}
			if { [info exists linknamelist ] } {
			    foreach link $linknamelist {
				    set hlink [$link cget -handle]
					ixNet setA $hlink -enabled True
				}
                ixNet commit
			} else {
			    eval $objName advertise_topo
			}
        }
        method WithdrawLinks { args } {
            set tag "body Ospfv2Router::WithdrawLinks [info script]"
            Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-linknamelist {
					    set linknamelist [::IxiaCapi::NamespaceDefine $value]
												
					}
				}
			}
			if { [info exists linknamelist ] } {
			    foreach link $linknamelist {
				    set hlink [$link cget -handle]
					ixNet setA $hlink -enabled False
				}
                ixNet commit
			} else {
			    eval $objName withdraw_topo
			}
        
        }
       
        method GetRouterStats {} {
            set tag "body Ospfv2Router::GetRouterStats [info script]"
            Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        method GetHostResults {} {
            set tag "body Ospfv2Router::GetHostResults [info script]"
            Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        method Ospfv2CreateSummaryLsa { args } {
            set tag "body Ospfv2Router::Ospfv2CreateSummaryLsa [info script]"
            Deputs "----- TAG: $tag -----"
           
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-lsaname {
					    set lsaname [::IxiaCapi::NamespaceDefine $value]						
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  			
            SimulatedSummaryRoute $lsaname $objName
            eval $lsaname config $newargs
        }
        method Ospfv2Enable {} {
            set tag "body Ospfv2Router::Ospfv2Enable [info script]"
			Deputs "----- TAG: $tag -----"
            eval "$objName enable"
        }
        method Ospfv2Disable {} {
            set tag "body Ospfv2Router::Ospfv2Disable [info script]"
			Deputs "----- TAG: $tag -----"
            eval "$objName disable" 
        }
        destructor {}    
    }
    
    class Ospfv3Router {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
        constructor { Port { routerId null } } {
            set tag "body Ospfv3Router::ctor [info script]"
            Deputs "----- TAG: $tag -----"

            set className Ospfv3Session
            Ospfv3Session ${this}_c  $Port
            if { $routerId != "null" } {
               ${this}_c config -router_id $routerId
            }   
            set handle [ ${this}_c cget -handle ]
            set objName ${this}_c
			set argslist(-routerid)               -router_id
			set argslist(-macaddr)                -mac_addr
			set argslist(-ipaddr)                 -ipv6_addr
			set argslist(-prefixlen)              -ipv6_prefix_len			
            set argslist(-area)                   -area_id
			set argslist(-networktype)            -network_type
			set argslist(-optionvalue)             -options
            set argslist(-sutipaddress)            -ipv6_gw
			set argslist(-routertypevalue)         -router_type_value			
            set argslist(-routerlsaname)           -router_lsa_name
            #set argslist(-flagneighbordr)        -L1RouterPriority
            set argslist(-hellointerval)                -hello_interval
			set argslist(-deadinterval)                  -dead_interval
			#set argslist(-polllinterval)                  -metric
            set argslist(-retranssmitinterval)         -retransmit_interval
            #set argslist(-transitdelay)       -FlagRestartHelper
			#set argslist(-maxlsasperpacket)          -FlagDropSutLsp
            set argslist(-interfacecost)     -if_cost
			set argslist(-routerpriority)           -priority
            #set argslist(-mtu)        -L2RouterPriority
			#set argslist(-flaglsadiscardmode)        -L1RouterPriority           
            set argslist(-instanceid)              -instance_id
            
            set argslist(-startingaddress)            -start
			set argslist(-prefix)                -prefix_len
            set argslist(-number)                -num
            set argslist(-advertisingrouterid)   -router_id
            set argslist(-metric)                -metric
            set argslist(-metrictype)                -metric_type
            
            set argslist(-flagasbr)                -asbr
            set argslist(-flagnubit)                -nubit
            set argslist(-flaglabit)                -labit
            set argslist(-flagnssa)                -nssa
            set argslist(-flagpbit)                -pbit
            set argslist(-flagfbit)     -fbit

            set argslist(-linkmetric)                -metric
            set argslist(-linktype)                -link_type
            set argslist(-linkinterfaceid)         -link_int_id
            set argslist(-neighborinterfaceid)     -nei_int_id
            set argslist(-flagadvertise)            -flag_adv
            set argslist(-neighborinterfaceid)     -nei_int_id
            set argslist(-neighborrouterid)         -nei_router_id
            set argslist(-linkinterfaceaddress)     -link_int_addr
            
            set argslist(-routername)     -router_name
            set argslist(-modifier)     -modifier
            set argslist(-forwardingaddress)     -fw_addr
        }
        
        method Ospfv3SetSession { args } {
            set tag "body Ospfv3Router::Ospfv3SetSession [info script]"
            Deputs "----- TAG: $tag -----"
           
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            eval $objName config $newargs
        }
        method Ospfv3CreateSummaryLsa { args } {
            set tag "body Ospfv3Router::Ospfv3CreateSummaryLsa [info script]"
            Deputs "----- TAG: $tag -----"
           
            set routertypevalue "normal"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-lsaname {
					    set lsaname [::IxiaCapi::NamespaceDefine $value]						
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  			
            SimulatedSummaryRoute $lsaname $objName
            eval $lsaname config $newargs
        }
        method CreateTopInterAreaPrefixRouteBlock { args } {
            set tag "body Ospfv3Router::CreateTopInterAreaPrefixRouteBlock [info script]"
            Deputs "----- TAG: $tag -----"
            set prefixlen 80
			set number 1
			set modifier 1
			
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blockname [::IxiaCapi::NamespaceDefine $value]
												
					}
					-startingaddress {
					    set startingaddress $value
												
					}
					-prefixlen {
					    set prefixlen $value
												
					}
					-number {
					    set number $value
												
					}
					-modifier {
					    set modifier $value
												
					}
				}
			}
            
            RouteBlock $blockname
            eval $blockname config -start $startingaddress \
			    -step $modifier \
				-prefix_len $prefixlen \
				-num $number
			     
        }
        
        method ConfigRouteBlock { args } {
            set tag "body Ospfv3Router::ConfigRouteBlock [info script]"
            Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blockname [::IxiaCapi::NamespaceDefine $value]
												
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  			
            eval $blocknamename config $newargs
            eval $objName set_route -route_block $blockname
        }
		
		method Ospfv3CreateTopRouter { args } {
            set tag "body Ospfv3Router::Ospfv3CreateTopRouter [info script]"
            Deputs "----- TAG: $tag -----"
            set routertypevalue "normal"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-routername {
					    set routername [::IxiaCapi::NamespaceDefine $value]
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  		
            SimulatedRouter $routername $objName
            eval $routername config $$newargs
        }
		
		method Ospfv3CreateTopExternalPrefixRouteBlock { args } {
            set tag "body Ospfv3Router::Ospfv3CreateTopExternalPrefixRouteBlock [info script]"
            Deputs "----- TAG: $tag -----"
            set prefixlen 80
			set number 1
			set modifier 1
			
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blockname [::IxiaCapi::NamespaceDefine $value]	
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  		
            SimulatedExternalRoute $blockname $objName
            eval $blockname config $newargs
        }
		
		method Ospfv3CreateTopRouterLink { args } {
            set tag "body Ospfv3Router::Ospfv3CreateTopRouterLink [info script]"
            Deputs "----- TAG: $tag -----"
            set linkmetric 1

            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-linkname {
					    set linkname [::IxiaCapi::NamespaceDefine $value]		
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  	
            SimulatedLinkRoute $linkname $objName
            eval $linkname config $newargs 
        }
        
        method StartRouter {} {
            set tag "body Ospfv3Router::StartRouter [info script]"
            Deputs "----- TAG: $tag -----"
            eval $objName start           
        }
        method StopRouter {} {
            set tag "body Ospfv3Router::StopRouter [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName stop
        }
        method AdvertiseLinks { args } {
            set tag "body Ospfv3Router::AdvertiseLinks [info script]"
            Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-linknamelist {
					    set linknamelist [::IxiaCapi::NamespaceDefine $value]
												
					}
				}
			}
			if { [info exists linknamelist ] } {
			    foreach link $linknamelist {
				    set hlink [$link cget -handle]
					ixNet setA $hlink -enabled True
				}
                ixNet commit
			} else {
			    eval $objName advertise_topo
			}
        }
        method WithdrawLinks { args } {
            set tag "body Ospfv3Router::WithdrawLinks [info script]"
            Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-linknamelist {
					    set linknamelist [::IxiaCapi::NamespaceDefine $value]
												
					}
				}
			}
			if { [info exists linknamelist ] } {
			    foreach link $linknamelist {
				    set hlink [$link cget -handle]
					ixNet setA $hlink -enabled False
				}
                ixNet commit
			} else {
			    eval $objName withdraw_topo
			}
        
        }
       
        method GetRouterStats {} {
            set tag "body Ospfv3Router::GetRouterStats [info script]"
            Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        method GetHostResults {} {
            set tag "body Ospfv3Router::GetHostResults [info script]"
            Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        method Ospfv3Enable {} {
            set tag "body Ospfv3Router::Ospfv3Enable [info script]"
			Deputs "----- TAG: $tag -----"
            eval "$objName enable"
        }
        method Ospfv3Disable {} {
            set tag "body Ospfv3Router::Ospfv3Disable [info script]"
			Deputs "----- TAG: $tag -----"
            eval "$objName disable" 
        }
        destructor {}     
    } 
}