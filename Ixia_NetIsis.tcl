
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.1
#===============================================================================
# Change made
# Version 1.0 
#       1. Create
# Version 1.1.14.58
#		2. Add ipv4_addr ipv4_gw ipv4_prefix_len ipv6_addr ipv6_gw ipv6_prefix_len in config
#		3. Add SimulatedRoute class

class IsisSession {
    inherit RouterEmulationObject
		
    constructor { port } {}
    method reborn {} {}
    method config { args } {}
	method set_route { args } {}
	method advertise_route { args } {}
	method withdraw_route { args } {}
    method get_route_info { args } {}
    method get_route_block {} {}
    method set_top_route { args } {}
    
	public variable mac_addr
	public variable routeBlock
    public variable addressfamily
}

body IsisSession::reborn {} {
    set tag "body IsisSession::reborn [info script]"
    Deputs "----- TAG: $tag -----"
	#-- add isis protocol
	Deputs "hPort:$hPort"
	set handle [ ixNet add $hPort/protocols/isis router ]
	ixNet setA $handle -name $this
	ixNet commit
	set handle [ ixNet remapIds $handle ]
	Deputs "handle:$handle"

	#-- add router interface
	set intList [ ixNet getL $hPort interface ]
	if { [ llength $intList ] } {
		set interface [ lindex $intList 0 ]
	} else {
		set interface [ ixNet add $hPort interface ]
		ixNet setA $interface -enabled True
		ixNet commit
		set interface [ ixNet remapIds $interface ]
        Deputs "port interface:$interface"
	}
    
	ixNet setA $hPort/protocols/isis -enabled True
	ixNet setA $handle -enabled True
	ixNet commit
	#-- add vlan
	set vlan [ ixNet add $interface vlan ]
	ixNet commit
	
	#-- port/protocols/isis/router/interface
	set rb_interface  [ ixNet add $handle interface ]
	ixNet setM $rb_interface \
	    -interfaceId $interface \
	    -enableConnectedToDut True \
	    -enabled True
	ixNet commit
	set rb_interface [ ixNet remapIds $rb_interface ]
	Deputs "rb_interface:$rb_interface"
    
    #-- add ipv4 and ipv6 interfaces
    if { ![ llength [ ixNet getL $interface ipv4 ] ] } {
        ixNet add $interface ipv4
        ixNet commit
    }
    if { ![ llength [ ixNet getL $interface ipv6 ] ] } {
        ixNet add $interface ipv6
        ixNet commit
    }
}

body IsisSession::constructor { port } {
    set tag "body IsisSession::constructor [info script]"
    Deputs "----- TAG: $tag -----"
	
    set addressfamily ipv4
    
    global errNumber
    
    #-- enable protocol
    set portObj [ GetObject $port ]
	Deputs "port:$portObj"
    if { [ catch {
	    set hPort   [ $portObj cget -handle ]
		Deputs "port handle: $hPort"
    } ] } {
	    error "$errNumber(1) Port Object in IsisSession ctor"
    }
	Deputs "initial port..."
	reborn
	Deputs "Step10"
}

body IsisSession::config { args } {
    set tag "body IsisSession::config [info script]"
	Deputs "----- TAG: $tag -----"

	# In case the handle was removed
    if { $handle == "" } {
	    reborn
    }

    Deputs "Args:$args "
    foreach { key value } $args {
		set key [string tolower $key]
		switch -exact -- $key {
			-sys_id - 
			-system_id {
				set sys_id $value
			}
			-areaid {
				set areaid $value
			}
			-areaid2 {
				set areaid2 $value
			}
			-areaid3 {
				set areaid3 $value
			}
			-router_id {
				set router_id $value
			}
			-network_type {
				set value [string tolower $value]
					switch $value {
					p2p {
						set value pointToPoint
					}
					p2mp {
						set value pointToMultipoint
					}
					default {
						set value broadcast
					}
				}
				set network_type $value
			}
            -discard_lsp {
            	set discard_lsp $value
            }
            -interface_metric -
            -metric {
            	set metric $value
            }
            -hello_interval {
            	set hello_interval $value  	    	
            }
            -dead_interval {
            	set dead_interval $value  	    	
            }
            -vlan_id {
            	set vlan_id $value
            }
            -lsp_refreshtime {
            	set lsp_refreshtime $value
            }
            -lsp_lifetime {
            	set lsp_lifetime $value
            }
			-mac_addr {
                set value [ MacTrans $value ]
                if { [ IsMacAddress $value ] } {
                    set mac_addr $value
                } else {
					Deputs "wrong mac addr: $value"
                    error "$errNumber(1) key:$key value:$value"
                }
			}
			-ipv6_addr {
				set ipv6_addr $value
			}
			-ipv6_gw {
				set ipv6_gw $value
			}
			-ipv6_prefix_len {
				set ipv6_prefix_len $value
			}
			-ip_version {
				set ip_version $value
                set addressfamily $value
			}
			-level {
				set level $value
			}
			-ipv4_addr {
				set ipv4_addr $value
			}
			-ipv4_prefix_len {
				set ipv4_prefix_len $value
			}
			-ipv4_gw {
				set ipv4_gw $value
			}
			-flag_restart_helper {
				set flag_restart_helper $value
			}
			-flag_wide_metric {
				set flag_wide_metric $value
			}
			-hold_timer {
				set hold_timer $value
			}
			-iih_interval {
				set iih_interval $value
			}
			-metric_mode {
				set metric_mode $value
			}
			-psnp_interval {
				set psnp_interval $value
			}
			-active {
				set active $value
			}
			-l1_router_priority {
				set l1_router_priority $value
			}
			-l2_router_priority {
				set l2_router_priority $value
			}
			-local_mac {
				set local_mac $value
			}
			-local_mac_modifier {
				set local_mac_modifier $value
			}
		}
    }
	
	if { [ info exists flag_wide_metric ] } {
        ixNet setA $rb_interface -enableWideMetric $flag_wide_metric
	}

	if { [ info exists flag_restart_helper ] } {
        if { $flag_restart_helper == "true" } {
            ixNet setAttribute $rb_interface -enableHitlessRestart True
            ixNet setAttribute $rb_interface -restartMode helperRouter 
            ixNet setAttribute $rb_interface -restartTime 30 
            ixNet setAttribute $rb_interface -restartVersion version4
        }
	}

	if { [ info exists hold_timer ] } {
        ixNet setA $rb_interface -configuredHoldTime $hold_timer
	}

	if { [ info exists iih_interval ] } {
        ixNet setA $rb_interface -level1HelloTime $iih_interval
	}

	if { [ info exists active ] } {
        ixNet setA $rb_interface -enabled $active
	}

	if { [ info exists ip_version ] } {
		if { [ string tolower $ip_version ] == "ipv6" } {
			if { [ llength [ ixNet getL $interface ipv4 ] ] } {
				ixNet remove [ ixNet getL $interface ipv4 ]
				ixNet commit
			}
		} elseif { [ string tolower $ip_version ] == "ipv4" } {
			if { [ llength [ ixNet getL $interface ipv6 ] ] } {
				ixNet remove [ ixNet getL $interface ipv6 ]
				ixNet commit
			}
        }
	}
    
    if { [ llength [ ixNet getL $interface ipv4 ] ] } {
        if { [ info exists ipv4_addr ] } {
            ixNet setA [ ixNet getL $interface ipv4 ] \
                -ip $ipv4_addr
        }
    
        if { [ info exists ipv4_prefix_len ] } {
            ixNet setA [ ixNet getL $interface ipv4 ] \
                -maskWidth $ipv4_prefix_len
        }
    
        if { [ info exists ipv4_gw ] } {
            ixNet setA [ ixNet getL $interface ipv4 ] \
                -gateway $ipv4_gw
        }
    }
    
    if { [ llength [ ixNet getL $interface ipv6 ] ] } {
        if { [ info exists ipv6_addr ] } {
            ixNet setA [ ixNet getL $interface ipv6 ] \
                -ip $ipv6_addr
        }
    
        if { [ info exists ipv6_prefix_len ] } {
            ixNet setA [ ixNet getL $interface ipv6 ] \
                -prefixLength $ipv6_prefix_len
        }
    
        if { [ info exists ipv6_gw ] } {
            ixNet setA [ ixNet getL $interface ipv6 ] \
                -gateway $ipv6_gw
        }
    }
    
	if { [ info exists level ] } {
		switch [ string tolower $level ] {
			l1 {
				set level level1
			}
			l2 {
				set level level2
			}
			l12 {
				set level level1Level2
			}
			l1l2 -
			{l1/l2} {
				set level level1Level2
			}
		}
		ixNet setA $rb_interface -level $level
	}

    if { [ info exists sys_id ] } {
		while { [ ixNet getF $hPort/protocols/isis router -systemId "[ split $sys_id : ]"  ] != "" } {	
			set sys_id [ IncrMacAddr $sys_id "00:00:00:00:00:01" ]
		}
	    ixNet setA $handle -systemId $sys_id
        ixNet commit
    }

    if { [ info exists network_type ] } {
	    ixNet setA $rb_interface -networkType $network_type
        ixNet commit
    }

    if { [ info exists discard_lsp ] } {
    	ixNet setA $handle -enableDiscardLearnedLsps $discard_lsp
        ixNet commit
    }

    if { [ info exists metric ] } {
	    ixNet setA $rb_interface -metric $metric
        ixNet commit
    }

    if { [ info exists hello_interval ] } {
	    ixNet setA $rb_interface -level1HelloTime $hello_interval
        ixNet commit
    }

    if { [ info exists dead_interval ] } {
	    ixNet setA $rb_interface -level1DeadTime $dead_interval
        ixNet commit
    }

    if { [ info exists vlan_id ] } {
	    set vlan [ixNet getL $interface vlan]
	    ixNet setA $vlan -vlanId $vlan_id
        ixNet commit
    }

    if { [ info exists lsp_refreshtime ] } {
    	ixNet setA $handle -lspRefreshRate $lsp_refreshtime
        ixNet commit
    }

    if { [ info exists lsp_lifetime ] } {
    	ixNet setA $handle -lspLifeTime $lsp_lifetime
        ixNet commit
    }

	if { [ info exists router_id ] } {
    	ixNet setM $handle -teEnable true \
			-teRouterId $router_id
        ixNet commit
    }

	if { [ info exists areaid ] } {
	    if { [ info exists areaid2 ] } {
		    if { [ info exists areaid3 ] } {
			    ixNet setA $handle -areaAddressList [list $areaid $areaid2 $areaid3]
                ixNet commit
			} else {
			    ixNet setA $handle -areaAddressList [list $areaid $areaid2 ]
                ixNet commit
			}
		} else {
		    ixNet setA $handle -areaAddressList [list $areaid ]
            ixNet commit
		}			
    }

	if { [ info exists mac_addr ] } {
		Deputs "interface:$interface mac_addr:$mac_addr"
		ixNet setA $interface/ethernet -macAddress $mac_addr
        ixNet commit
	}
    ixNet commit
    
	return [GetStandardReturnHeader]
}

body IsisSession::set_top_route { args } {
    global errorInfo
    global errNumber
	
    set tag "body IsisSession::set_top_route [info script]"
	Deputs "----- TAG: $tag -----"

	#param collection
	Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_name {
            	set route_name $value
            }
            -flag_te {
            	set flag_te $value
            }
            -flag_multi_topology {
            	set flag_multi_topology $value
            }
            -flag_advetisted {
            	set flag_advetisted $value
            }
            -flag_attached_bit {
            	set flag_attached_bit $value
            }
            -flag_overload_bit {
            	set flag_overload_bit $value
            }
            -pseudonode_number {
            	set pseudonode_number $value
            }
            -flag_tag {
            	set flag_tag $value
            }
            -connected_name {
            	set connected_name $value
            }
            -link_name {
            	set link_name $value
            }
            -narrow_metric {
            	set narrow_metric $value
            }
            -wide_metric {
            	set wide_metric $value
            }
            -nei_ipv4_addr {
            	set nei_ipv4_addr $value
                puts "**********nei_ipv4_addr: $nei_ipv4_addr"
            }
            -nei_ipv6_addr {
            	set nei_ipv6_addr $value
            }
            -ipv4_addr {
            	set ipv4_addr $value
            }
            -ipv6_addr {
            	set ipv6_addr $value
            }
            -router_id {
                set router_id $value
            }
            -ip_version {
                set ip_version $value
            }
            -network_type {
                set network_type $value
            }
            default {
            }
        }
    }

	if { [ info exists route_name ] } {
		foreach rb $route_name {
            if { [ info exists connected_name ] } {
                set prefix_len 	[ $connected_name cget -prefix_len ]
                set start 		[ $connected_name cget -start ] 
                set type 		[ $connected_name cget -type ]
                set num 		[ $connected_name cget -num ]
            } else {
                set prefix_len 	[ $rb cget -prefix_len ]
                set start 		[ $rb cget -start ] 
                set type 		[ $rb cget -type ]
                set num 		[ $rb cget -num ]
            }
            
            set sys_id 		    [ $rb cget -sys_id ]
            ixNet setA $handle -systemId $sys_id
            
            if { [ info exists routeBlock($rb,handle) ] } {
                set hNetworkRange $routeBlock($rb,handle)
            } else {
                set hNetworkRange [ ixNet add $handle networkRange ]
                ixNet commit
                set hNetworkRange [ ixNet remapIds $hNetworkRange ]
                set routeBlock($rb,handle) $hNetworkRange
                lappend routeBlock(obj) $rb
            }
            
            if { [ info exists link_name ] } {
                set routeBlock($link_name,handle) $hNetworkRange
            } 
            
            if { [ info exists flag_advetisted ] } {
                ixNet setAttribute $hNetworkRange -enabled $flag_advetisted
            }
            
            ixNet setAttribute $hNetworkRange -entryCol 1 
            ixNet setAttribute $hNetworkRange -entryRow 1
            ixNet setAttribute $hNetworkRange -gridNodeRoutes  {  }
            ixNet setAttribute $hNetworkRange -gridOutsideLinks  {  }
            ixNet setAttribute $hNetworkRange -interfaceMetric 1
            ixNet setAttribute $hNetworkRange -linkType broadcast ;#pointToPoint
            ixNet setAttribute $hNetworkRange -noOfCols 1
            ixNet setAttribute $hNetworkRange -noOfRows 1            
            ixNet setAttribute $hNetworkRange -routerIdIncrement {00 00 00 00 00 01 }
            ixNet setAttribute $hNetworkRange -tePaths  {  }
            
            if { [ info exists network_type ] } {
                if { $network_type == "router" } {
                    if { [ info exists nei_ipv4_addr ] } {
                        ixNet setAttribute $hNetworkRange -interfaceIps  [list [list $type $nei_ipv4_addr $prefix_len] ]
                    } elseif { [ info exists nei_ipv6_addr ] } {
                        ixNet setAttribute $hNetworkRange -interfaceIps  [list [list $type $nei_ipv6_addr $prefix_len] ]
                    }
                } else {
                    ixNet setAttribute $hNetworkRange -noOfCols $num
                    ixNet setAttribute $hNetworkRange -interfaceIps  [list [list $type $start $prefix_len] ]
                }
            } else {
                if { [ info exists nei_ipv4_addr ] } {
                    ixNet setAttribute $hNetworkRange -interfaceIps  [list [list $type $nei_ipv4_addr $prefix_len] ]
                } elseif { [ info exists nei_ipv6_addr ] } {
                    ixNet setAttribute $hNetworkRange -interfaceIps  [list [list $type $nei_ipv6_addr $prefix_len] ]
                }
            }
            
            if { [ info exists router_id ] } {
               ixNet setAttribute $hNetworkRange -routerId $router_id
            }
            
            if { [ info exists wide_metric ] } {
               ixNet setAttribute $hNetworkRange -useWideMetric $wide_metric
            }
             
            if { [ info exists flag_te ] } {
                if { $flag_te == "true" } {
                    ixNet setMultiAttrs $sg_networkRange/entryTe \
                        -enableEntryTe True \
                        -eteAdmGroup {00 00 00 00} \
                        -eteLinkMetric 0 \
                        -eteMaxBandWidth 0 \
                        -eteMaxReserveBandWidth 0 \
                        -eteRouterId 0.0.0.1 \
                        -eteRouterIdIncrement 0.0.0.1 \
                        -eteUnreservedBandWidth {0 0 0 0 0 0 0 0}
                    
                    ixNet setMultiAttrs $sg_networkRange/rangeTe \
                        -enableRangeTe True \
                        -teAdmGroup {00 00 00 00} \
                        -teLinkMetric 0 \
                        -teMaxBandWidth 0 \
                        -teMaxReserveBandWidth 0 \
                        -teRouterId 0.0.0.1 \
                        -teRouterIdIncrement 0.0.0.1 \
                        -teUnreservedBandWidth {0 0 0 0 0 0 0 0}          
                }
            }
            
            ixNet commit
		}
	}
	
    return [GetStandardReturnHeader]
}

body IsisSession::set_route { args } {
    global errorInfo
    global errNumber
	
    set tag "body IsisSession::set_route [info script]"
	Deputs "----- TAG: $tag -----"

	#param collection
	Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set route_block $value
            }
        }
    }
	
	if { [ info exists route_block ] } {
		foreach rb $route_block {
			set num 		[ $rb cget -num ]
			set step 		[ $rb cget -step ]
			set prefix_len 	[ $rb cget -prefix_len ]
			set start 		[ $rb cget -start ]
			set type 		[ $rb cget -type ]
            set sys_id 		[ $rb cget -sys_id ]

            if { [ info exists routeBlock($rb,handle) ] } {
                set hRouteBlock $routeBlock($rb,handle)
            } else {
                set hRouteBlock [ ixNet add $handle routeRange ]
                ixNet commit
                set hRouteBlock [ ixNet remapIds $hRouteBlock ]
                set routeBlock($rb,handle) $hRouteBlock
                lappend routeBlock(obj) $rb
            }
			
			ixNet setM $hRouteBlock \
				-numberOfRoutes $num \
				-type $type \
				-firstRoute $start \
				-maskWidth $prefix_len 
			ixNet commit
            
            if { $sys_id != "" } {
                ixNet setA $handle -systemId $sys_id
                ixNet commit
            }
            
			$rb configure -handle $hRouteBlock
			$rb configure -portObj $portObj
			$rb configure -hPort $hPort
			$rb configure -protocol "isis"
			$rb enable
		}
	}
	
    return [GetStandardReturnHeader]
}
body IsisSession::advertise_route { args } {
    global errorInfo
    global errNumber
    set tag "body IsisSession::advertise_route [info script]"
	Deputs "----- TAG: $tag -----"
	#param collection
	Deputs "Args:$args "

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set route_block $value
            }
            -link_name_list {
            	set link_name_list $value
            }
        }
    }
            
	if { [ info exists route_block ] } {
		ixNet setA $routeBlock($route_block,handle) \
			-enabled True
	} elseif { [ info exists link_name_list ] } {
        foreach ln $link_name_list {
            if { [ info exists $routeBlock($ln,handle) ] } {
                ixNet setAttribute $routeBlock($ln,handle) -enabled True
            }
        }
	} else {
		foreach hRouteBlock $routeBlock(obj) {
			Deputs "hRouteBlock : $hRouteBlock"		
			ixNet setA $routeBlock($hRouteBlock,handle) -enabled True
		}
    }
	ixNet commit
    
	return [GetStandardReturnHeader]
}

body IsisSession::withdraw_route { args } {
    global errorInfo
    global errNumber
    set tag "body IsisSession::withdraw_route [info script]"
	Deputs "----- TAG: $tag -----"

	#param collection
	Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set route_block $value
            }
            -link_name_list {
            	set link_name_list $value
            }
        }
    }
	
	if { [ info exists route_block ] } {
		ixNet setA $routeBlock($route_block,handle) \
			-enabled False
	}  elseif { [ info exists link_name_list ] } {
        foreach ln $link_name_list {
            if { [ info exists $routeBlock($ln,handle) ] } {
                ixNet setAttribute $routeBlock($ln,handle) -enabled True
            }
        }
	} else {
		foreach hRouteBlock $routeBlock(obj) {
			Deputs "hRouteBlock : $hRouteBlock"		
			ixNet setA $routeBlock($hRouteBlock,handle) -enabled True
		}
    }
	ixNet commit
	
	return [GetStandardReturnHeader]
}

body IsisSession::get_route_info { args } {
    global errorInfo
    global errNumber
	
    set tag "body IsisSession::get_route_info [info script]"
	Deputs "----- TAG: $tag -----"

	#param collection
	Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -route_block {
            	set rb $value
            }
        }
    }

    set retStats [list ]
    if { [ info exists routeBlock($rb,handle) ] } {
        lappend retStats -num
        lappend retStats [ ixNet getA $routeBlock($rb,handle) -numberOfRoutes ]

        lappend retStats -type
        lappend retStats [ ixNet getA $routeBlock($rb,handle) -type ]
        
        lappend retStats -start
        lappend retStats [ ixNet getA $routeBlock($rb,handle) -firstRoute ]
        
        lappend retStats -prefix_len 
        lappend retStats [ ixNet getA $routeBlock($rb,handle) -maskWidth ]
        
        lappend retStats -active 
        lappend retStats [ ixNet getA $routeBlock($rb,handle) -enabled ]
        
        lappend retStats -metric 
        lappend retStats [ ixNet getA $routeBlock($rb,handle) -metric ]
    }

    return $retStats
}
  
body IsisSession::get_route_block { } {
    global errorInfo
    global errNumber
	
    set tag "body IsisSession::get_route_block [info script]"
	Deputs "----- TAG: $tag -----"

    if { [ info exists routeBlock(obj) ] } {
        return $routeBlock(obj)
    }

    return [list]
}

class SimulatedRoute {
	inherit SimulatedSummaryRoute
	
	constructor { router } { chain $router } {}
	method config { args } {}
}

body SimulatedRoute::config { args } {
	global errorInfo
    global errNumber
    set tag "body SimulatedRoute::config [info script]"
	Deputs "----- TAG: $tag -----"

	eval chain $args

	foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            
			-route_type {
				set route_type $value
			}
        }
    }
	
	if { [ info exists $route_type ] } {
		if { [ string to lower $route_type ] == "internal" } {
			set route_origin false
		} else {
			set route_origin true
		}
		ixNet setA $handle -routeOrigin $route_origin
	}
	
	ixNet commit
}

