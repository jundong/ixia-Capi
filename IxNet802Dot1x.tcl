namespace eval IxiaCapi {
    
    class 802Dot1xClient {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
        constructor { Port } {
            set tag "body 802Dot1xClient::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Dot1xHost
            Dot1xHost ${this}_c  $Port
            
            
            set objName ${this}_c
            
            set argslist(-eapauthenticationmethod)         -auth_type        
            set argslist(-username)                        -user_name
            set argslist(-password)                        -password            
            # set argslist(-authenticaltormac)               -router_solicitation_retries
            # set argslist(-useauthenticatormacforalltx)       -router_solicitation_retrans_timer
            # set argslist(-usepaegroupmac)                                  -enabled
            set argslist(-packeyfile)                                 -key_path
            # set argslist(-supplicantcertificate)                                  -enabled
            # set argslist(-packetretransmitcount)                                  -enabled
            # set argslist(-packetretransmitinterval)                                  -enabled
            # set argslist(-authencationretrycount)                                  -enabled
            # set argslist(-authencationretryinterval)                                  -enabled
            set argslist(-active)                          -enabled
			set argslist(-authenticatormac)                -mac_addr
			set argslist(-vlanid1)                         -vlan_id
            
           
            
        }
        
        method ConfigRouter { args } {
            set tag "body 802Dot1xClient::ConfigRouter [info script]"
Deputs "----- TAG: $tag -----"
            eval ProtocolConvertObject::convert $args
            eval $objName config $newargs
        
        }
        
        method Start {} {
            set tag "body 802Dot1xClient::Start [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName start
            
        }
        method Logout {} {
            set tag "body 802Dot1xClient::Logout [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName stop
        }
		method Abort {} {
            set tag "body 802Dot1xClient::Abort [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName abort
        }
		method Download { args } {
            set tag "body 802Dot1xClient::Download [info script]"
Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
            set key [string tolower $key]
				switch -exact -- $key {
					-dirpath {
					    eval $objName config -ca_path $value
						
					}
				}
			}
            eval $objName start
        }
        
        method Delete {} {
            set tag "body 802Dot1xClient::Delete [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName stop
        }
        
        method GetRouterStats {} {
            set tag "body 802Dot1xClient::GetRouterStats [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        method GetHostResults {} {
            set tag "body 802Dot1xClient::GetHostResults [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        destructor {}
        
      
    }
}