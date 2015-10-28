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
			set argslist(-areaid1)                 -areaid1
			set argslist(-areaid2)                 -areaid2
            #set argslist(-routerid)                
            set argslist(-systemid)                -sys_id          
            set argslist(-routinglevel)            -level
			set argslist(-metric)                  -metric
			
			set argslist(-flagwidemetric)          -flagwidemetric
			set argslist(-FlagRestartHelper)       -FlagRestartHelper
			set argslist(-FlagDropSutLsp)          -FlagDropSutLsp
			set argslist(-FlagMultiTopology)       -FlagMultiTopology
			set argslist(-MaxPacketSize)           -MaxPacketSize
			set argslist(-L2RouterPriority)        -L2RouterPriority
			set argslist(-L1RouterPriority)        -L1RouterPriority
			set argslist(-RoutingLevel)            -RoutingLevel
			set argslist(-AuthType)                -AuthType
			set argslist(-AuthPasswordIIh)         -AuthPasswordIIh
			set argslist(-AuthPassword)            -AuthPassword
           

            set argslist(-macaddr)                  -mac_addr
            set argslist(-addressfamily)            -ip_version
            set argslist(-ipv4addr)                 -ipv4_addr           
            set argslist(-ipv4prefixlen)            -ipv4_prefix_len
            set argslist(-gatewayaddr)              -ipv4_gw
			set argslist(-ipv6addr)                 -ipv6_addr          
            set argslist(-ipv6prefixlen)            -ipv6_prefix_len
            set argslist(-ipv6gatewayaddr)          -ipv6_gw
			
			set argslist(-routepooltype)             -address_family  
            set argslist(-firstaddress)              -start   
            set argslist(-numaddress)                -num  
            set argslist(-prefixlen)                 -prefix_len   
            set argslist(-modifer)                   -step  
           		
                                  
        }
                   
        
        method ConfigRouter { args } {
            set tag "body IsisRouter::ConfigRouter [info script]"
Deputs "----- TAG: $tag -----"
           
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            eval $objName config $newargs
			     
        }
        
        method CreateRouteBlock { args } {
            set tag "body IsisRouter::CreateRouteBlock [info script]"
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
            eval $objName set_route -route_block  $blocknamename
			     
        }
        
        method ConfigRouteBlock { args } {
            set tag "body IsisRouter::ConfigRouteBlock [info script]"
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
        method AdvertiseRouteBlock { args } {
            set tag "body IsisRouter::AdvertiseRouteBlock [info script]"
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
        method WithdrawRouteBlock { args } {
            set tag "body BgpRouter::WithdrawRouteBlock [info script]"
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
        destructor {}
        
      
    }
	
	
    
    
}