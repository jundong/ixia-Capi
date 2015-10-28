namespace eval IxiaCapi {
    
    class IGMPClient {
        inherit ProtocolConvertObject
        #public variable newargs
        #public variable argslist
        public variable objName
        public variable className
		public variable groupName
        constructor { Port { hostname null }  } {
            set tag "body IGMPClient::ctor [info script]"
Deputs "----- TAG: $tag -----"
            set className IgmpHost
			set groupName ""
			if { $hostname != "null" } {
			    set inttype [$hostname cget -topStack]
			    set intfhandle [ $hostname cget -topHandle]
				puts $intfhandle
Deputs "-----intfhandle: $intfhandle -----"
                IgmpHost ${this}_c  $Port $intfhandle $inttype
			} else {
			    IgmpHost ${this}_c  $Port 
			}
            
            
            
            set objName ${this}_c
            
            set argslist(-protocoltype)                  -version
            set argslist(-sendgrouprate)                -rate
            set argslist(-active)                       -active
            set argslist(-v1routerpresenttimeout)       -v1_router_present_timeout
            set argslist(-forcerobustjoin)              -force_robust_join
            set argslist(-unsolicitedreportinterval)    -unsolicited_report_interval
            set argslist(-insertchecksumerrors)         -insert_checksum_errors 
            set argslist(-insertlengtherrors)           -insert_length_errors
            set argslist(-ipv4dontfragment)             -ipv4_dont_fragment
            
            set argslist(-grouppoolname)                    -group_name
            set argslist(-groupcnt)                         -group_num  
            set argslist(-srcstartip)                       -source_ip
            set argslist(-filtermode)                       -filter_mode
            set argslist(-startip)                          -group_ip
			set argslist(-groupincrement)                   -group_step
            set argslist(-srcincrement)                     -source_step			
            
        }
        
        method ConfigRouter { args } {
            set tag "body IGMPClient::ConfigRouter [info script]"
Deputs "----- TAG: $tag -----"
            eval ProtocolConvertObject::convert $args
            eval $objName config $newargs
            #eval $objName join_group $newargs
        
        }
        
        method Enable {} {
            set tag "body IGMPClient::Enable [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName start
            
        }
        method Disable {} {
            set tag "body IGMPClient::Disable [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName stop
        }
        
        method CreateGroupPool { args } {
            set tag "body IGMPClient::CreateGroupPool [info script]"
Deputs "----- TAG: $tag -----"
            
            eval ConfigGroupPool $args
        }
        
        method ConfigGroupPool { args } {
            set tag "body IGMPClient::ConfigGroupPool [info script]"
Deputs "----- TAG: $tag -----"
           eval ProtocolConvertObject::convert $args
           foreach { key value } $args {
                set key [string tolower $key]
                switch -exact -- $key {
                    -grouppoolname {
                        set gName $value
                    }
                }
            }
			if { [GetObject $gName ] == "" } {
			
				uplevel #0 "MulticastGroup $gName" 
				lappend groupName $gName
			}
			eval $gName config $newargs
			
			eval $objName join_group -group $gName 

            
        }
		
		method DeleteGroupPool { args } {
            set tag "body IGMPClient::DeleteGroupPool [info script]"
Deputs "----- TAG: $tag -----"
			foreach { key value } $args {
				set key [string tolower $key]
				switch -exact -- $key {
					-grouppoollist {
						set grouppoolname $value
					}
				}
			}
			
			foreach poolname $grouppoolname {
			    set index [lsearch $groupName $poolname]
				if { $index >= 0} {
				   lreplace $groupName $index $index
				}
 			}
           
        }
        
        method SendReport { args } {
            set tag "body IGMPClient::SendReport [info script]"
Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
                switch -exact -- $key {
                    -grouppoollist {
                        set grouppoolname $value
                    }
                }
            }
			

            if {[ info exists grouppoolname ]} {
                eval $objName join_group $grouppoolname
			} else {
			    eval $objName join_group
			}
        }
        method SendLeave { args} {
            set tag "body IGMPClient::SendLeave [info script]"
Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
                switch -exact -- $key {
                    -grouppoollist {
                        set grouppoolname $value
                    }
                }
            }

            if {[ info exists grouppoolname ]} {
                eval $objName leave_group $grouppoolname
			} else {
			    eval $objName leave_group
			}
        }
       
        method GetRouterStats {} {
            set tag "body DHCPv6Client::GetRouterStats [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName get_detailed_stats
        }
        method GetHostResults {} {
            set tag "body DHCPv6Client::GetHostResults [info script]"
Deputs "----- TAG: $tag -----"
            eval $objName get_host_stats
        }
        destructor {}
        
      
    }
    
   
}