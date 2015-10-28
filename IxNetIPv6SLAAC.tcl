namespace eval IxiaCapi {
    
    class IPv6SLAACClient {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
        constructor { Port } {
            set tag "body IPv6SLAACClient::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className Ipv6AutoConfigHost
            Ipv6AutoConfigHost ${this}_c  $Port
            
            
            set objName ${this}_c
            
            set argslist(-duplicateaddrdetection)                  -dup_addr_detection        
            set argslist(-dadtransmitcount)                        -dup_addr_detect_transmits
            set argslist(-dadretransmitdelay)                      -retrans_timer            
            set argslist(-routersolicitationretries)               -router_solicitation_retries
            set argslist(-routersolicitationretransmitdelay)       -router_solicitation_retrans_timer
            set argslist(-active)                                  -enabled
           
            
        }
        
        method ConfigRouter { args } {
            set tag "body DHCPv6Client::ConfigRouter [info script]"
Deputs "----- TAG: $tag -----"
            eval ProtocolConvertObject::convert $args
            eval $objName config $newargs
        
        }
        
        method Enable {} {
            set tag "body DHCPv6Client::Enable [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName start
            
        }
        method Disable {} {
            set tag "body DHCPv6Client::Disable [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName stop
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
}