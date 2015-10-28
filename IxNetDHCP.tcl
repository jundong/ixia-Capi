namespace eval IxiaCapi {
    
    class DHCPClient {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
        constructor {} {
            set tag "body DHCPClient::ctor [info script]"
Deputs "----- TAG: $tag -----"
                                  
        }
        
        method ConfigRouter { args } {
            set tag "body DHCPv6Client::ConfigRouter [info script]"
Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
            set key [string tolower $key]
				switch -exact -- $key {
					-poolname {
					    set poolname $value
						PoolNameObject $value
						
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            eval $objName config $newargs
			set dhcphandle [ $objName cget -handle ]
			if { [ info exists poolname ] } {
			    $poolname configHandle $dhcphandle
			}
			
			
        
        }
        
        method Enable {} {
            set tag "body DHCPv6Client::Enable [info script]"
Deputs "----- TAG: $tag -----"
            #eval $objName enable
            eval $objName request
            
        }
        method Disable {} {
            set tag "body DHCPv6Client::Disable [info script]"
Deputs "----- TAG: $tag -----"
            #eval $objName disable
            eval $objName release
        }
        method Bind {} {
            set tag "body DHCPv6Client::Bind [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName request
        }
        method Rebind {} {
            set tag "body DHCPv6Client::Rebind [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName rebind
        }
        method Release {} {
            set tag "body DHCPv6Client::Release [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName release
        }
        method Renew {} {
            set tag "body DHCPv6Client::Renew [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName renew
        }
        method Confirm {} {
            set tag "body DHCPv6Client::Confirm [info script]"
Deputs "----- TAG: $tag -----"
        }
        method InfoRequest {} {
            set tag "body DHCPv6Client::InfoRequest [info script]"
Deputs "----- TAG: $tag -----"
        }
        method Abort {} {
            set tag "body DHCPv6Client::Abort [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName abort
        }
        method Request {} {
            set tag "body DHCPv6Client::Request [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName request
        }
        method Decline {} {
            set tag "body DHCPv6Client::Decline [info script]"
Deputs "----- TAG: $tag -----"
        }
        method GetRouterStats {} {
            set tag "body DHCPv6Client::GetRouterStats [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        method GetHostResults {} {
            set tag "body DHCPv6Client::GetHostResults [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        destructor {}
        
      
    }
	
	class DHCPv6Client {
	    inherit DHCPClient
        
        constructor { Port } {
            set tag "body DHCPv6Client::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Dhcpv6Host
            Dhcpv6Host ${this}_c  $Port
            
            
            set objName ${this}_c
            set argslist(-hostnum)                        -count
            set argslist(-emulationmode)                  -ia_type
            #set argslist(enablerenewmassages)
            #set argslist(enablerebindmessages)
            #set argslist(enabelreconfigureaccept)
            set argslist(-t1timer)                        -t1_timer
            set argslist(-t2timer)                        -t2_timer
			set argslist(-poolname)                       -poolname
            #set argslist(prelifitime)
            #set argslist(validlifitime)
            #set argslist(rapidcommitoperationmode)
            set argslist(-duidtype)                       -duid_type
            set argslist(-duidenterpricenum)              -duid_enterprise
            set argslist(-duidstartvalue)                 -duid_start
            set argslist(-duidstepvalue)                  -duid_step  
            #set argslist(duidcustomvalue)
            #set argslist(enablelightweightdra)
            set argslist(-enablerelayagent)               -enable_relay_agent
            set argslist(-relayagentserverip)             -relay_server_ipv4_addr
            set argslist(-relayagentserveripstep)         -relay_server_ipv4_addr_step
            #set argslist(requestedprefixlength)
            #set argslist(requestedstartingaddr)
            #set argslist(dhcpv6cpsipv6addr)
            #set argslist(enableauthentication)
            #set argslist(authenticationprotocol)
            #set argslist(dhcprealm)
            #set argslist(authenticationleys)
            #set argslist(enabledad)
            #set argslist(dadtimeout)
            #set argslist(dadtrasmits)
            #set argslist(customoptionsnum)
            #set argslist(optionvalue)
            #set argslist(includeinmessage)
            #set argslist(wildcards)
            #set argslist(stringhex)
            #set argslist(optionpayload)
            #set argslist(removeoption)
            set argslist(-active)                          -enabled
			set argslist(-localmac)                        -mac_addr
			set argslist(-vlanid1)                           -vlan_id
			
			set argslist(-vlanpriority1)                        -outer_vlan_priority
            
        }
		
		
	}
    
    class DHCPv4Client {
        inherit DHCPClient
        
        constructor { Port } {
            set tag "body DHCPv4Client::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Dhcpv4Host
            Dhcpv4Host ${this}_c  $Port          
            set objName ${this}_c
            
            set argslist(-emulationmode)                  -ia_type
            #set argslist(enablerenewmassages)
            #set argslist(enablerebindmessages)
            #set argslist(enabelreconfigureaccept)
            set argslist(-t1timer)                        -t1_timer
            set argslist(-t2timer)                        -t2_timer
            #set argslist(prelifitime)
            #set argslist(validlifitime)
            #set argslist(rapidcommitoperationmode)
            set argslist(-duidtype)                       -duid_type
            set argslist(-duidenterpricenum)              -duid_enterprise
            set argslist(-duidstartvalue)                 -duid_start
            set argslist(-duidstepvalue)                  -duid_step  
            #set argslist(duidcustomvalue)
            #set argslist(enablelightweightdra)
            set argslist(-enablerelayagent)               -enable_relay_agent
            set argslist(-relayagentserverip)             -relay_server_ipv4_addr
            set argslist(-relayagentserveripstep)         -relay_server_ipv4_addr_step
            #set argslist(requestedprefixlength)
            #set argslist(requestedstartingaddr)
            #set argslist(dhcpv6cpsipv6addr)
            #set argslist(enableauthentication)
            #set argslist(authenticationprotocol)
            #set argslist(dhcprealm)
            #set argslist(authenticationleys)
            #set argslist(enabledad)
            #set argslist(dadtimeout)
            #set argslist(dadtrasmits)
            #set argslist(customoptionsnum)
            #set argslist(optionvalue)
            #set argslist(includeinmessage)
            #set argslist(wildcards)
            #set argslist(stringhex)
            #set argslist(optionpayload)
            #set argslist(removeoption)
            set argslist(-active)                          -enabled
			set argslist(-localmac)                        -mac_addr
            
        }
							
		
    }
    
    class DHCPServer {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
        constructor {} {
            set tag "body DHCPServer::ctor [info script]"
Deputs "----- TAG: $tag -----"
                                  
        }
        
        method ConfigRouter { args } {
            set tag "body DHCPCServer::ConfigRouter [info script]"
Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
            set key [string tolower $key]
				switch -exact -- $key {
					-poolname {
					    set poolname $value
						PoolNameObject $value
						
					}
				}
			}
            eval ProtocolConvertObject::convert $args
			puts $objName 
			puts $newargs
            eval $objName config $newargs
			set dhcphandle [ $objName cget -handle ]
			if { [ info exists poolname ] } {
			    $poolname configHandle $dhcphandle
			}
			
			
        
        }
        
        method Enable {} {
            set tag "body DHCPCServer::Enable [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName start
            
        }
        method Disable {} {
            set tag "body DHCPCServer::Disable [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName stop
        }
        method ForceRenew {} {
            set tag "body DHCPCServer::ForceRenew [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName request
        }
        method Reboot {} {
            set tag "body DHCPCServer::Reboot [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName rebind
        }
        method ClearStats {} {
            set tag "body DHCPCServer::ClearStats [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName release
        }
      
        method GetRouterStats {} {
            set tag "body DHCPCServer::GetRouterStats [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName get_stats
        }
        
        destructor {}
        
      
    }
    
    class DHCPv4Server {
        inherit DHCPServer
        
        constructor { Port } {
            set tag "body DHCPv4Server::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Dhcpv4Server
            Dhcpv4Server ${this}_c  $Port          
            set objName ${this}_c
            
            
            #set argslist(-active)
            set argslist(-leasetime)             -lease_time
            set argslist(-poolstart)             -pool_ip_start
            set argslist(-poolnum)                 -pool_ip_count
            set argslist(-poolmodifier)            -pool_ip_pfx
            #set argslist(-poolformacpattern)
            set argslist(-poolformacstart)        -mac_addr
            set argslist(-poolformacmodifier)     -mac_addr_step
            # set argslist(-dhcpofferoption)            
            # set argslist(-dhcpackoption)              
            # set argslist(-ignoremask)                 
            # set argslist(-ignorepattern)                   
            # set argslist(-nakmask)
            # set argslist(-nakpattern)
          
            
        }
									
    }
    
    class DHCPv6Server {
        inherit DHCPServer
        
        constructor { Port } {
            set tag "body DHCPv6Server::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Dhcpv6Server
            Dhcpv6Server ${this}_c  $Port          
            set objName ${this}_c
            
            
            #set argslist(-active)
            set argslist(-leasetime)             -lease_time
            set argslist(-poolstart)             -pool_ip_start
            set argslist(-poolnum)                 -pool_ip_count
            set argslist(-poolmodifier)            -pool_ip_pfx
            #set argslist(-poolformacpattern)
            set argslist(-poolformacstart)        -mac_addr
            set argslist(-poolformacmodifier)     -mac_addr_step
            # set argslist(-dhcpofferoption)            
            # set argslist(-dhcpackoption)              
            # set argslist(-ignoremask)                 
            # set argslist(-ignorepattern)                   
            # set argslist(-nakmask)
            # set argslist(-nakpattern)
          
            
        }
									
    }
}