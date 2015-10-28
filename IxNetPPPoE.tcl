namespace eval IxiaCapi {
    
    class PPPoEClient {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
        constructor { } {
            set tag "body PPPoEClient::ctor [info script]"
Deputs "----- TAG: $tag -----"
           
        }
        
        method ConfigRouter { args } {
            set tag "body PPPoEClient::ConfigRouter [info script]"
Deputs "----- TAG: $tag -----"
Deputs "----- args: $args -----"
			
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
			Deputs $objName 
			Deputs $newargs
            eval $objName config $newargs
			set pppoxhandle [ $objName cget -handle ]
			if { [ info exists poolname ] } {
			    $poolname configHandle $pppoxhandle
			}
		
        
        }
        
        method Open {} {
            set tag "body PPPoEClient::Open [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName connect
			after 3000
            
        }
        method Close {} {
            set tag "body PPPoEClient::Close [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName disconnect
			after 3000
        }
        method Retry {} {
            set tag "body PPPoEClient::Retry [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName retry
			after 3000
        }
        method Pause {} {
            set tag "body PPPoEClient::Pause [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName pause
        }
        method Resume {} {
            set tag "body PPPoEClient::Resume [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName resume
        }
        method CancelAttempt {} {
            set tag "body PPPoEClient::CancelAttempt [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName cancel
        }
        method Abort {} {
            set tag "body PPPoEClient::Abort [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName abort
			after 3000
        }
        method Disable {} {
            set tag "body PPPoEClient::Disable [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName disable
        }
        method Enable {} {
            set tag "body PPPoEClient::Enable [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName enable
        }
		method RetryFailedPeer {} {
            set tag "body PPPoEClient::RetryFailedPeer [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName retry
			after 3000
        }
		method GetHostState { args } {
            set tag "body PPPoEClient::GetHostState [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName get_summary_stats
        }
		
        destructor {}
        
    
    }
    
    class PPPoEv4Client {
        inherit PPPoEClient
        #public variable newargs
        #public variable argslist
        
        constructor { Port } {
            set tag "body PPPoEv4Client::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className PppoeHost
            PppoeHost ${this}_c  $Port
            
            
            set objName ${this}_c
            set argslist(-hostnum)                        -count
			#set argslist(-count)                          -count
            set argslist(-active)                         -enabled
            set argslist(-authenticationrole)             -authentication
            set argslist(-username)                       -user_name
            set argslist(-password)                       -password
            set argslist(-authenusername)                  -user_name
            set argslist(-authenpassword)                  -password
            set argslist(-flagenableipcp)                 -ipcp_encap
            
            set argslist(-active)                          -enabled
			set argslist(-localmac)                        -mac_addr
			set argslist(-vlanid1)                         -vlan_id
			
			set argslist(-vlanpriority1)                   -outer_vlan_priority
        }
            
    }
    
    class PPPoEv6Client {
        inherit PPPoEClient
        #public variable newargs
        #public variable argslist
        
        constructor { Port } {
            set tag "body PPPoEv6Client::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Pppoev6Host
            Pppoev6Host ${this}_c  $Port 
            
            
            set objName ${this}_c
            set argslist(-hostnum)                        -count
			#set argslist(-count)                          -count
            set argslist(-active)                         -enabled
            set argslist(-authenticationrole)             -authentication
            set argslist(-username)                       -user_name
            set argslist(-password)                       -password
            set argslist(-authenusername)                  -user_name
            set argslist(-authenpassword)                  -password
            set argslist(-flagenableipcp)                 -ipcp_encap
            set argslist(-pppoeservername)                 -service_name
            
			set argslist(-localmac)                        -mac_addr
			set argslist(-vlanid1)                         -vlan_id
            set argslist(-vlanid2)                         -vlan_id2
			
			set argslist(-vlanpriority1)                   -outer_vlan_priority
        }
            
    }
    
    class PPPoEv4v6Client {
        inherit PPPoEClient
        #public variable newargs
        #public variable argslist
        
        constructor { Port } {
            set tag "body PPPoEv4v6Client::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Pppoev4v6Host
            Pppoev4v6Host ${this}_c  $Port 
            
            
            set objName ${this}_c
            set argslist(-hostnum)                        -count
			#set argslist(-count)                          -count
            set argslist(-active)                         -enabled
            set argslist(-authenticationrole)             -authentication
            set argslist(-username)                       -user_name
            set argslist(-password)                       -password
            set argslist(-authenusername)                  -user_name
            set argslist(-authenpassword)                  -password
            set argslist(-flagenableipcp)                 -ipcp_encap
            
			set argslist(-localmac)                        -mac_addr
			set argslist(-vlanid1)                         -vlan_id
			set argslist(-vlanid2)                         -vlan_id2
			set argslist(-vlanpriority1)                   -outer_vlan_priority
        }
            
    }
    
    class PPPoEv4Server {
        inherit PPPoEClient
        #public variable newargs
        #public variable argslist
        
        constructor { Port } {
            set tag "body PPPoEv4Server::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Pppoev4Server
            Pppoev4Server ${this}_c  $Port 
            
            
            set objName ${this}_c
            set argslist(-hostnum)                        -count
			#set argslist(-count)                          -count
            set argslist(-active)                         -enabled
            set argslist(-authenticationrole)             -authentication
            set argslist(-username)                       -user_name
            set argslist(-password)                       -password
            set argslist(-authenusername)                  -user_name
            set argslist(-authenpassword)                  -password
            set argslist(-flagenableipcp)                 -ipcp_encap
            
			set argslist(-localmac)                        -mac_addr
			set argslist(-vlanid1)                         -vlan_id
			set argslist(-vlanid2)                         -vlan_id2
			set argslist(-vlanpriority1)                   -outer_vlan_priority
        }
		
		method RetryFailedSession {} {
            set tag "body PPPoEv4Server::RetryFailedSession [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName retry
			after 3000
        }
		
            
    }
    
    class PPPoEv6Server {
        inherit PPPoEClient
        #public variable newargs
        #public variable argslist
        
        constructor { Port } {
            set tag "body PPPoEv6Server::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Pppoev6Server
            Pppoev6Server ${this}_c  $Port 
            
            
            set objName ${this}_c
            set argslist(-hostnum)                        -count
			#set argslist(-count)                          -count
            set argslist(-active)                         -enabled
            set argslist(-authenticationrole)             -authentication
            set argslist(-username)                       -user_name
            set argslist(-password)                       -password
            set argslist(-authenusername)                  -user_name
            set argslist(-authenpassword)                  -password
            set argslist(-flagenableipcp)                 -ipcp_encap
            
			set argslist(-localmac)                        -mac_addr
			set argslist(-vlanid1)                         -vlan_id
			set argslist(-vlanid2)                         -vlan_id2
			set argslist(-vlanpriority1)                   -outer_vlan_priority
        }
		
		method RetryFailedSession {} {
            set tag "body PPPoEv6Server::RetryFailedSession [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName retry
			after 3000
        }
            
    }
    
     class PPPoEv4v6Server {
        inherit PPPoEClient
        #public variable newargs
        #public variable argslist
        
        constructor { Port } {
            set tag "body PPPoEv4v6Server::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Pppoev4v6Server
            Pppoev4v6Server ${this}_c  $Port 
            
            
            set objName ${this}_c
            set argslist(-hostnum)                        -count
			#set argslist(-count)                          -count
            set argslist(-active)                         -enabled
            set argslist(-authenticationrole)             -authentication
            set argslist(-username)                       -user_name
            set argslist(-password)                       -password
            set argslist(-authenusername)                  -user_name
            set argslist(-authenpassword)                  -password
            set argslist(-flagenableipcp)                 -ipcp_encap
            
			set argslist(-localmac)                        -mac_addr
			set argslist(-vlanid1)                         -vlan_id
			
			set argslist(-vlanpriority1)                   -outer_vlan_priority
        }
		
		method RetryFailedSession {} {
            set tag "body PPPoEv4v6Server::RetryFailedSession [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName retry
			after 3000
        }
            
    }
}