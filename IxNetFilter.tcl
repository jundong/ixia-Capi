# Filter.tcl --
#   This file implements the Filter class for "TestPort CreateFilter" method in TestPort.tcl.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.0
# Version 2.0

namespace eval IxiaCapi {
    class Filter {
        constructor { portHandle type {filtervalue null}} {
		    set tag "body Filter::constructor [info script]"
Deputs "----- TAG: $tag -----"
            set cap_filter [list]
            set hPort $portHandle
            set Type $type
		    set handle $hPort/capture
            if { $filtervalue != "null" } {
                Config $type $filtervalue
		    }
		}
        method Config { type filtervalue } {}
		method CleanFilter {} {}
		public variable handle
		public variable cap_filter
        public variable hPort
        public variable Type
        destructor {}
    }  
	
         
    
    body Filter::CleanFilter {} {
	    set tag "body Filter::CleanFilter [info script]"
Deputs "----- TAG: $tag -----"
    if { [ catch {
			ixNet setM $handle/filter \
				-captureFilterDA anyAddr \
				-captureFilterSA anyAddr \
				-captureFilterPattern anyPattern \
				-captureFilterFrameSizeEnable false
				
			ixNet commit
					
			ixNet setMultiAttrs $handle/filterPallette \
			 -DA1 {00 00 00 00 00 00} -DAMask1 {00 00 00 00 00 00} \
			 -SA1 {00 00 00 00 00 00} -SAMask1 {00 00 00 00 00 00} \
			 -pattern1 0 \
			 -patternMask1 0 \
			 -patternOffset1 0 \
			 -pattern2 0 \
			 -patternMask2 0 \
			 -patternOffset2 0 

			ixNet commit
		} err ] } {
Deputs "err:$err"
		}
		
		set handle ""
		set cap_filter ""

    }

    body Filter::Config { type filtervalue  } {
        global errorInfo
        set tag "body Filter::Config [info script]"
Deputs "----- TAG: $tag -----"
        foreach filterel $cap_filter {
		    set level 1
            if { [ catch { uplevel $level " delete object $filterel " } ] } {
                incr level
                catch { uplevel $level " delete object $filterel " } 
            }
		}
		set cap_filter [list]
        set index 1
		foreach filterexpr $filtervalue {
		    FilterElement $this\_$index
			$this\_$index config $type $filterexpr
		    lappend cap_filter  $this\_$index 
			incr index
		}
		
		
		#add filter to port
		ixNet setA $handle   -hardwareEnabled True
	    ixNet commit
			
		ixNet setM $handle \
			-afterTriggerFilter captureAfterTriggerAll \
			-beforeTriggerFilter captureBeforeTriggerAll \
			-captureMode captureContinuousMode \
			-continuousFilters captureContinuousFilter \
			-displayFiltersDataCapture {} \
			-hardwareEnabled True \
			-sliceSize 0 \
			-softwareEnabled False \
			-triggerPosition 1
		ixNet commit
			
		ixNet setM $handle/filter -captureFilterEnable True \
			-captureFilterError errAnyFrame \
			-captureFilterFrameSizeEnable False \
			-captureFilterFrameSizeFrom 64 \
			-captureFilterFrameSizeTo 1518 \
		ixNet commit
			
		set index 1
		foreach filter $cap_filter {
		    set value $filter
			set filter [ GetObject $filter ]
			if { $filter == "" } {
			    IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_FilterCtor8 $value" -tag $tag
				#return [ GetErrorReturnHeader "Wrong value of filter, which is not a valid CaptureFilter Object" ]
			    return $IxiaCapi::s_FilterCtor8
			}
			if { $index == 3 } {
			    IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_FilterCtor13 $value" -tag $tag
				#return [ GetErrorReturnHeader "Out of bound for supported filter count" ]
				return $IxiaCapi::s_FilterCtor13
			}
			set field_value [ $filter cget -field_value ]
			set ip_offset 	[ $filter cget -ip_offset ]
			set vlan_offset [ $filter cget -vlan_offset ]
			set tcp_offset	[ $filter cget -tcp_offset ]
			set udp_offset	[ $filter cget -udp_offset ]
			set any_offset	[ $filter cget -any_offset ]
			set field_offset [ $filter cget -field_offset ]
			set field_mask [ $filter cget -field_mask ]
			set eth_dst		[ $filter cget -eth_dst ]
			set eth_src		[ $filter cget -eth_src ]
# IxDebugOn
Deputs "field_value:$field_value ip_offset:$ip_offset vlan_offset:$vlan_offset  tcp_offset:$tcp_offset udp_offset:$udp_offset any_offset:$any_offset field_offset:$field_offset field_mask:$field_mask eth_dst:$eth_dst eth_src:$eth_src"
Deputs Step100
			if { [ info exists eth_dst ] && ( $eth_dst != "" ) } {
Deputs Step200
Deputs "dst:$eth_dst"
				ixNet setMultiAttrs $hPort/capture/filterPallette \
				 -DA$index $eth_dst \
				 -DAMask$index {00 00 00 00 00 00}
				 
				ixNet setA $hPort/capture/filter -captureFilterDA addr$index
			} else {
Deputs Step300
			
				ixNet setA $hPort/capture/filter -captureFilterDA anyAddr
				
			}
			ixNet commit
			if { [ info exists eth_src ] && ( $eth_src != "" ) } {
Deputs Step400						
				ixNet setMultiAttrs $hPort/capture/filterPallette \
				 -SA$index  $eth_src \
				 -SAMask$index {00 00 00 00 00 00}
				 
				ixNet setA $hPort/capture/filter -captureFilterSA addr$index
			} else {
			
				ixNet setA $hPort/capture/filter -captureFilterSA anyAddr
			
			}
#IxDebugOff			
			ixNet commit

			if { ( $field_value != "" ) && ( $field_offset >= 0 ) } {
Deputs Step500			
				ixNet setMultiAttrs $hPort/capture/filterPallette \
				 -pattern$index $field_value \
				 -patternMask$index $field_mask \
				 -patternOffset$index $field_offset \
				 -patternOffsetType$index filterPalletteOffsetStartOfFrame
				ixNet commit
				
				#ixNet setM $hPort/capture/filter -captureFilterFrameSizeFrom $field_offset -captureFilterFrameSizeEnable True
				#ixNet commit
				if { $index == 1 } {
Deputs "index:$index"
				ixNet setA $hPort/capture/filter \
						-captureFilterPattern pattern$index
				} else {
					ixNet setA $hPort/capture/filter \
						-captureFilterPattern pattern1AndPattern2
				}
				ixNet commit
			} else {
Deputs "index:$index"
Deputs Step600				
				ixNet setM $hPort/capture/filter \
					-captureFilterPattern anyPattern
				ixNet commit
			}
			
			incr index
		}
	
	ixNet commit

        
    return $IxiaCapi::errorcode(0)
    }

	class FilterElement {
        constructor {} {
		    set field_value ""
		    set ip_offset 	0
		    set vlan_offset 0   
		    set udp_offset	0
		    set any_offset	0
			set tcp_offset  0
		    set field_offset -1
		    set field_mask {00}
		    set eth_dst		""
		    set eth_src		""
		}
        method config { type filterexpr } {}
		method unconfig {} {}
		
        public variable hPort
		public variable field_value
	    public variable ip_offset
	    public variable vlan_offset
	    public variable udp_offset
	    public variable tcp_offset
		public variable any_offset
	    public variable field_offset
	    public variable field_mask

	    public variable eth_dst
	    public variable eth_src
        
        
        
        
    } 

	body FilterElement::config { type filterexpr  } {
        global errorInfo
        set tag "body FilterElement::Config [info script]"
Deputs "----- TAG: $tag -----"
        set type [string toupper $type]
        if {$type == "UDF" } {
		    foreach { key value } $filterexpr {
                set key [string tolower $key]
                switch -exact -- $key {
                    -pattern {
                        set pattern $value
                    }
			        -offset {
				        set filter_start $value
			        }
			
			        -mask {
			            if {[regsub -all "f" $value "0" newvalue]} {
				            set filter_mask $newvalue
				        } else {
				            set filter_mask $value
			            }		
			        }
					
		        }
	        }
			
			if { [info exists pattern] == 0 } {
			    IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_FilterCtor5" -tag $tag
            return $IxiaCapi::errorcode(8)
			}
			if { [info exists filter_start] == 0 } {
			    IxiaCapi::Logger::LogIn -type err -message \
                "$IxiaCapi::s_FilterCtor5" -tag $tag
            return $IxiaCapi::errorcode(8)
			}
			
							
		    set field_offset	$filter_start
Deputs "field_offset:$field_offset"
			set field_value 	[ Mac2Hex $pattern ]
Deputs "field_value:$field_value"
			#set field_mask 		$filter_mask
			if { [ info exists filter_mask ] } {
				set field_mask 		$filter_mask
			} else {
				set field_mask ""
				for { set index 0 } { $index < [ string length $field_value ] } { incr index } {
					if { [ string index $field_value $index ] != " " } {
						set field_mask "${field_mask}0"
					}
				}
Deputs "field_mask:$field_mask"
			}

			   							
		}
		
		if {$type == "STACK" } {
		    foreach { key value } $filterexpr {
                set key [string tolower $key]
                switch -exact -- $key {
                    -protocolfield {
                        set ProtocolField $value
                    }
			        -min {
				        set min $value
			        }
					-max {
				        set max $value
			        }
			
			        -mask {
			            if {[regsub -all "f" $value "0" newvalue]} {
				            set filter_mask $newvalue
				        } else {
				            set filter_mask $value
			            }		
			        }
		        }
	        }
		
		
		    if { [ info exists ProtocolField ] } {
		        set ProtocolField [ string tolower $ProtocolField ]
Deputs "protocolfield $ProtocolField"
			    set fieldlist [split $ProtocolField .]
			    set protocolheader [lindex $fieldlist 0]
Deputs "protocolheader $protocolheader"
			    set headerfield [lindex $fieldlist 1]
Deputs "headerfield $headerfield"
		        switch $protocolheader { 
			        eth:vlan {
				        set vlan_offset 14
			        }
			        eth:ipv4 {
				        set ip_offset 	14
                    }
			        eth:vlan:ipv4 {
				        set ip_offset 	18
				        set vlan_offset 14
			        }
			        eth:ipv4:tcp {
				        set ip_offset 	14
				        set tcp_offset  34
						set any_offset	34
			        }
			        eth:ipv4:udp {
				        set ip_offset 	14
				        set udp_offset  34
						set any_offset	34
			        }
			        eth:ipv4:any {
				        set ip_offset 	14
				        set any_offset	34
			        }
			        eth:vlan:ipv4:tcp {
				        set ip_offset 	18
				        set vlan_offset 14
				        set tcp_offset	38
						set any_offset	38
			        }
			        eth:vlan:ipv4:udp {
				        set ip_offset 	18
				        set vlan_offset 14
				        set udp_offset	38
                        set any_offset	38						
			        }
			        eth:vlan:ipv4:any {
				        set ip_offset 	18
				        set vlan_offset 14
				        set any_offset	38				
			        }
		        }
	    
		        switch -exact -- $headerfield { 
                    -dstMac {
                        set eth_dst [ Mac2Hex $min ]
						set field_mask {00 00 00 00 00 00}
                    }
                    -srcMac {
                        set eth_src [ Mac2Hex $min ]
						set field_mask {00 00 00 00 00 00}
                    }
                    -srcIp {
				        set field_mask {00 00 00 00}
				        set field_offset	12
				        incr field_offset	$ip_offset
				        set field_value 	[ IP2Hex $min ]
                    }
			        -dstIp {
				        set field_mask {00 00 00 00}
				        set field_offset	16
				        incr field_offset	$ip_offset
				        set field_value 	[ IP2Hex $min ]
			        }
					-id {
				        set field_mask {F000}
				        set field_offset	0
				        incr field_offset	$vlan_offset
				        set field_value 	$min
				        while { [ string length $field_value ] < [ string length $field_mask ] } {
					        set field_value 	"0$field_value"
				        }
			        }
                    -pri {
				        set field_mask {1F}
				        set field_offset	0
				        incr field_offset	$vlan_offset
				        set field_value 	[ format %x [ expr round($min * pow(2,5)) ] ]
				        while { [ string length $field_value ] < [ string length $field_mask ] } {
					        set field_value 	"0$field_value"
				        }
			        }
                    -tos {
				        set field_mask {E1}
				        set field_offset	1
				        incr field_offset	$ip_offset
				        set field_value 	[expr 0x$min<<1]
				        set field_value         [format %X $field_value]
				        while { [ string length $field_value ] < [ string length $field_mask ] } {
					        set field_value 	"0$field_value"
				        }
			        }					
			        -pro {
				        set field_mask {00}
				        set field_offset	9
				        incr field_offset	$ip_offset
				        set field_value 	$min
				        while { [ string length $field_value ] < [ string length $field_mask ] } {
					        set field_value 	"0$field_value"
				        }
			        }
			        -srcPort {
				        set field_mask {0000}
				        set field_offset	0
				        incr field_offset	$any_offset
				        set field_value 	$min
				        while { [ string length $field_value ] < [ string length $field_mask ] } {
					        set field_value 	"0$field_value"
				        }
			        }
			        -dstPort {
				        set field_mask {0000}
				        set field_offset	2
				        incr field_offset	$any_offset
				        set field_value 	$min
				        while { [ string length $field_value ] < [ string length $field_mask ] } {
					    set field_value 	"0$field_value"
				        }
			        }
			
                }
	        }
		}    
        return $IxiaCapi::errorcode(0)
    }
	
}

