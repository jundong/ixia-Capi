# Copyright (c) Ixia technologies 2010-2016, Inc.

# Release Version 1.1
#===============================================================================
# Change made
# Version 1.0 
#       1. ConfigRouter -> IsisSetSession
#		   CreateRouteBlock -> IsisCreateRouteBlock

namespace eval IxiaCapi {
    class IsisRouter {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
       
		constructor { Port { routerId null } } {
            set tag "body IsisRouter::ctor [info script]"
			Deputs "----- TAG: $tag -----"

            set className IsisSession
            IsisSession ${this}_c  $Port
            if { $routerId != "null" } {
               #${this}_c config -router_id $routerId
            }
            
            set objName ${this}_c
            set argslist(-areaid)                  -areaid
			set argslist(-areaid2)                 -areaid2
			set argslist(-areaid3)                 -areaid3
            set argslist(-systemid)                -sys_id          
            set argslist(-routinglevel)            -level
			set argslist(-metric)                  -metric
			
			set argslist(-flagwidemetric)          -flag_wide_metric
			set argslist(-flagrestarthelper)       -flag_restart_helper
			set argslist(-l2routerpriority)        -l2_router_priority
			set argslist(-l1routerpriority)        -l1_router_priority
           
            set argslist(-macaddr)                  -mac_addr
            set argslist(-addressfamily)            -ip_version
            set argslist(-ipv4addr)                 -ipv4_addr
			set argslist(-ipv4address)              -ipv4_addr 
            set argslist(-neiipv4address)           -nei_ipv4_addr 
			set argslist(-ipv4prefixlen)            -ipv4_prefix_len
            set argslist(-gatewayaddr)              -ipv4_gw
			set argslist(-ipv6addr)                 -ipv6_addr
			set argslist(-ipv6address)              -ipv6_addr
			set argslist(-neiipv6address)           -nei_ipv6_addr         
            set argslist(-ipv6prefixlen)            -ipv6_prefix_len
            set argslist(-ipv6gatewayaddr)          -ipv6_gw
			
			set argslist(-routepooltype)            -type  
            set argslist(-firstaddress)             -start   
            set argslist(-numaddress)               -num  
            set argslist(-prefixlen)                -prefix_len   
            set argslist(-modifer)                  -step
			
			set argslist(-routerid)                 -router_id
			set argslist(-holdtimer)                -hold_timer
			set argslist(-iihinterval)              -iih_interval
			set argslist(-metricmode)               -metric_mode
			set argslist(-psnpinterval)             -psnp_interval
			set argslist(-testlinklocaladdr)        -Test_link_local_addr
			set argslist(-active)                	-active
			set argslist(-localmac)                 -local_mac
			set argslist(-localmacmodifier)         -local_mac_modifier
			
			set argslist(-blockname)         		-block_name
			set argslist(-blocknamelist)         	-block_name_list
			set argslist(-flagte)         			-flag_te
			set argslist(-flagmultitopology)        -flag_multi_topology
			set argslist(-flagadvetisted)         	-flag_advetisted
			set argslist(-flagattachedbit)         	-flag_attached_bit
			set argslist(-flagoverloadbit)         	-flag_overload_bit
			set argslist(-pseudonodenumber)         -pseudonode_number
			set argslist(-flagtag)         			-flag_tag
			set argslist(-connectedname)         	-connected_name
			set argslist(-linkname)         		-link_name
			set argslist(-narrowmetric)         	-narrow_metric
			set argslist(-widemetric)         		-wide_metric
        }

        method IsisSetSession { args } {
            set tag "body IsisRouter::IsisSetSession [info script]"
			Deputs "----- TAG: $tag -----"
           
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            eval $objName config $newargs
        }
        
        method IsisCreateRouteBlock { args } {
            set tag "body IsisRouter::IsisCreateRouteBlock [info script]"
			Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blocknamename [::IxiaCapi::NamespaceDefine $value]				
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            RouteBlock $blocknamename
            eval $blocknamename config $newargs
            eval $objName set_route -route_block $blocknamename
        }
        
        method IsisSetRouteBlock { args } {
            set tag "body IsisRouter::IsisSetRouteBlock [info script]"
			Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blocknamename [::IxiaCapi::NamespaceDefine $value]
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  			
            eval $blocknamename config $newargs
            eval $objName set_route -route_block $blocknamename
        }
        
        method StartRouter {} {
            set tag "body IsisRouter::StartRouter [info script]"
			Deputs "----- TAG: $tag -----"
            eval $objName start
        }
		
        method StopRouter {} {
            set tag "body IsisRouter::StopRouter [info script]"
			Deputs "----- TAG: $tag -----"
            eval $objName stop
        }
		
        method IsisAdvertiseRouteBlock { args } {
            set tag "body IsisRouter::IsisAdvertiseRouteBlock [info script]"
			Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blocknamename [::IxiaCapi::NamespaceDefine $value]
					}
				}
			}
			if { [info exists blockname ] } {
                eval $objName advertise_route -route_block $blocknamename
			} else {
			    eval $objName advertise_route
			}
        }
		
        method IsisWithdrawRouteBlock { args } {
            set tag "body BgpRouter::IsisWithdrawRouteBlock [info script]"
			Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blocknamename [::IxiaCapi::NamespaceDefine $value]
					}
				}
			}
			if { [info exists blockname ] } {
               eval $objName withdraw_route -route_block $blocknamename
			} else {
			   eval $objName withdraw_route
			}
        }
       
        method GetRouterStats {} {
            set tag "body IsisRouter::GetRouterStats [info script]"
			Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
		
        method GetHostResults {} {
            set tag "body BgpRouter::GetHostResults [info script]"
			Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
		
        method IsisRetrieveRouteBlock {args} {
            set tag "body IsisRouter::IsisRetrieveRouteBlock [info script]"
			Deputs "----- TAG: $tag -----"
			
			set retStats [list ]
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blockname {
					    set blocknamename [::IxiaCapi::NamespaceDefine $value]
					}
					-active {
						set active $value
					}
					-type {
						set type $value
					}
					-start {
						set start $value
					}
					-prefix_len {
						set prefix_len $value
					}
					-num {
						set num $value
					}
					-step {
						set step $value
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  			
            array set block_info [ $objName get_route_info -route_block $blocknamename ]
			if { [ info exists active ] } {
				uplevel 1 "set $active $block_info(-active)"
			}
			if { [ info exists type ] } {
				uplevel 1 "set $type $block_info(-type)"
			}
			if { [ info exists start ] } {
				uplevel 1 "set $start $block_info(-start)"
			}
			if { [ info exists prefix_len ] } {
				uplevel 1 "set $prefix_len $block_info(-prefix_len)"
			}
			if { [ info exists num ] } {
				uplevel 1 "set $num $block_info(-num)"
			}
			if { [ info exists step ] } {
				uplevel 1 "set $step $block_info(-step)"
			}
			
			return [ array get block_info ]
		}
		
        method IsisListRouteBlock {args} {
            set tag "body IsisRouter::IsisListRouteBlock [info script]"
			Deputs "----- TAG: $tag -----"
			
			set retStats [list ]
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-blocknamelist {
					    set blocknamelist $value
					}
					default {}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs  			
            set block_list [ $objName get_route_block ]
			if { [ info exists blocknamelist ] } {
				uplevel 1 "set $blocknamelist $block_list"
			}
		}
		
		method IsisCreateTopRouter {args} {
            set tag "body IsisRouter::IsisCreateTopRouter [info script]"
			Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-routername {
					    set blocknamename [::IxiaCapi::NamespaceDefine $value]				
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            RouteBlock $blocknamename
            eval $blocknamename config $newargs
            eval $objName set_top_route -route_name $blocknamename -network_type router $newargs 
		}
		
		method IsisCreateTopRouterLink {args} {
            set tag "body IsisRouter::IsisCreateTopRouterLink [info script]"
			Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-routername {
					    set blocknamename [::IxiaCapi::NamespaceDefine $value]		
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            eval $blocknamename config $newargs
            eval $objName set_top_route -route_name $blocknamename -network_type router $newargs
		}
        
        ############################################################################
        #APIName: IsisAdvertiseLinks
        #
        #Description: 
        #
        #Input:          (1) -LinkNameList LinkNameList:Mandatory parameters
        #
        #Output: 0/1
        #
        #Coded by: Judo Xu
        ############################################################################
        method IsisAdvertiseLinks {args} { 
            set tag "body IsisRouter::IsisAdvertiseLinks [info script]"
			Deputs "----- TAG: $tag -----"
            
            set linknamelist [list]
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-linknamelist {
                        foreach linkname $value {
                            lappend linknamelist [::IxiaCapi::NamespaceDefine $linkname]
                        }
					}
				}
			}
			if { [ llength $linknamelist ] } {
                eval $objName advertise_route -link_name_list $linknamelist
			} 
        }
        
        ############################################################################
        #APIName: IsisWithdrawLinks
        #
        #Description: 
        #
        #Input:          (1) -LinkNameList LinkNameList:Mandatory parameters
        #
        #Output: 0/1
        #
        #Coded by: Judo Xu
        ############################################################################
        method IsisWithdrawLinks {args} { 
            set tag "body IsisRouter::IsisWithdrawLinks [info script]"
			Deputs "----- TAG: $tag -----"
            
            set linknamelist [list]
            foreach { key value } $args {
                set key [string tolower $key]
				switch -exact -- $key {
					-linknamelist {
                        foreach linkname $value {
                            lappend linknamelist [::IxiaCapi::NamespaceDefine $linkname]
                        }
					}
				}
			}
			if { [ llength $linknamelist ] } {
                eval $objName withdraw_route -link_name_list $linknamelist
			} 
        }

		destructor {}
    } 
}