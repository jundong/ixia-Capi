# Regexer.tcl --
#   This file implements the Regular expression method for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1
# Version 1.2

namespace eval IxiaCapi::Regexer {
    namespace export *
    # IsIPv4Address --
    #   Error codes : TRUE(1)     success
    #                 FALSE (0)    no match
    #   Error condition :
    #               1.Doesnot match A.B.C.D
    #               2.{ A B C D }'s element is not an Integer between 0 and 255
    proc IsIPv4Address { value } {
Deputs "Judgement: ipv4 address format"
       if { [ regexp -nocase {(\d+)\.(\d+)\.(\d+)\.(\d+)} $value ip a b c d ] } {
Deputs "Is Ipv4 address..."
            if { ( $a > 255 ) || ( $b > 255 ) || ( $c > 255 ) || ( $d > 255 ) } {
                return 0
            }
            return 1
        } else {
Deputs "Invalid ipv4 format"
            return 0
        }
    }
    
    proc IsIPv4Mask { value } {
        if { [ ixIsValidNetMask $value ] } {
            return 1
        } else {
            return 0
        }
    }

    proc IsIPv4MulticastAddress { value } {
        if { [ IsIPv4Address $value ] } {
            regexp {(\d+)} $value match A
            if { ( $A >= 224 ) && ( $A < 240 ) } {
                return 1
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    # parameter sequence is: ipaddr prefix number modifer
    proc Ipv4ScopeValidate { args } {
        set tmpparameterlist {}
        foreach tmppara $args {
            set tmpparameterlist [concat $tmpparameterlist $tmppara]
        }
        set parameterlist $tmpparameterlist
        if {[llength $parameterlist] != 4} {
            return 0
        } else {
            foreach {Ipv4Addr Prefix Number Modifier} $parameterlist {
                set IpList [split $Ipv4Addr .]
                set Ipv4Addr 0
                for {set Loopi 0} {$Loopi < 4} {incr Loopi} {
                    set Ipv4Addr [expr $Ipv4Addr+[expr [lindex $IpList $Loopi]*[expr pow(256, [expr 3-$Loopi])]]]
                }
                set Ipv4Addr [string range $Ipv4Addr 0 [expr [string first . $Ipv4Addr] - 1]]
                return [expr ([expr [expr $Ipv4Addr>>[expr 32-$Prefix]]+[expr [expr $Number-1]*$Modifier]] < [expr pow(2, $Prefix)])?1:0]
            }
        }
    }
    # IsIPv6Address --
    #   Error codes : TRUE(1)     success
    #                 FALSE (0)    no match
    #   Error condition :
    #               1.Doesnot match A:B:C:D:E:F
    #               2.{ A B C D }'s element is not an sign which in the set [0-9a-f]   
    proc IsIPv6Address { value } {
	   set flag 1
	   set hexList [ split $value ":" ]
	   if { [ llength $hexList ] == 8 } {
		  foreach hex $hexList {
			 if { [ IsHex $hex ] == 0 } {
				set flag 0
				break
			 }
		  }
	   } else {
		  set index [ string first "::" $value ]
		  if { $index < 0 } {
			 return 0
		  }
		  
		  set hexList [ split $value ":" ]
		  foreach hex $hexList {
			 if { $hex == "" } {
				continue
			 }
			 if { [ IsHex $hex ] == 0 } {
				set flag 0
				break
			 }
		  }

	   }
	   return $flag

	}
	
	# GetPrefixV4Step 32 1 => 1
	# GetPrefixV4Step 24 1 => 256
	proc GetPrefixV4Step { pfx { step 1 } } {
		
		return [ IntTrans [ expr pow(2, 32 - $pfx) * $step ] ]
		
	}

    
    proc IsMacAddress { value } {

        if { [  regexp -nocase {[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]} $value ] } {
            return 1
        } else {
            return 0
        }
    }
	
	proc List2Str { value } {
        set retStr ""
        foreach item $value {
	        set retStr $retStr$item
        }
        return $retStr
    }

    proc MacTrans { mac } {
        set value $mac
        set len [ string length $value ]
        for { set index 0 } { $index < $len } { incr index } {
            if { [ string index $value $index ] == " " || \
                [ string index $value $index ] == "-" ||
                [ string index $value $index ] == "." } {
                set value [ string replace $value $index $index ":" ] 
            }
        }
        set needtrans 1
        while { $needtrans } {
            set needtrans 0
            if { [ regexp -nocase {([0-9|a-f][0-9|a-f][0-9|a-f][0-9|a-f]:??)} \
                $value match specmac ] } {
                set needtrans 1
                set index [ string first $specmac $value ]
                set len [ string length $specmac ]
                set newmac \
                "[string range $specmac 0 1]:[string range $specmac 2 end]"
                set value [ string replace $value $index \
                           [expr $index + $len -1] $newmac ]
            }
        }
        return $value
    }
    proc UnitTrans { value } {
        global IxiaCapi::k IxiaCapi::K IxiaCapi::m IxiaCapi::M IxiaCapi::g IxiaCapi::G
        if { [ string is integer $value ] || [ string is double $value ] } {
            return $value
        }
        if { [regexp {^([0-9]+(\.[0-9]+)?)([kKmMgG])$} $value match digit round unit ] } {
            if {$unit == ""} {
                return $value
            }
            return [eval expr $digit$$unit ]
        } else {
            return NAN
        }
    }
    
    proc BoolTrans { value } {
        set value [ string tolower $value ]
        if { ( $value == "enable" ) || ( $value == "success" ) || ( $value == "true" )  } {
            set value 1
        }
        if { ( $value == "disable" ) || ( $value == "fail" ) || ( $value == "false" )  } {
            set value 0
        }
        if { $value == 1 || $value == 0 } {
            return $value
        } else {
            if { [ info exists [string tolower $value] ] == 0 } {
                return $value
            }
            eval { set trans } $[string tolower $value]
            if { $trans == 1 || $trans == 0 } {
                return $trans
            } else {
                return $value
            }
        }
    }
    
    proc TimeTrans { value } {
        global IxiaCapi::sec IxiaCapi::min IxiaCapi::hour IxiaCapi::ms
        if { [ string is integer $value ] } {
            return $value
        }
        if { [ regexp -nocase {^([0-9]+)(sec|min|hour|s|m|h|ms)$} $value match digit unit ] } {
            if { $unit == "" } {
                return $value
            } else {
                if { $unit == "s" } { set unit sec }
                if { ($unit == "m") || ($unit == "min") } { set unit min }
                if { ($unit == "h") || ($unit == "hour") } { set unit hour }
                if { $unit == "ms" } { set unit ms }
            }
            return [eval expr $digit$$unit ]
        } else {
            return NAN
        }
    }
    

    proc IntTrans { value } {
        set index [ string first "." $value ]
        if { $index >= 0 } {
            string replace $value $index end
        } else {
            return $value
        }
    }
    proc ObjectExist { value } {

        set objectList [ find objects ]
        if { [ lsearch -exact $objectList $value ] < 0 } {
            return 0
        } else {
            return 1
        }
    }
    
    proc IsInt {value} {
        if {[regexp {^( )*(\d)+( )*$} $value]} {
                return 1
        } else {
                return 0
        }
    }
    
    proc IsHex {value} {
        if { [ regexp -nocase {^0x} $value ] } {
            set value [ string range $value 2 end ]
        }
        set strLen  [ string length $value ]
        for { set index 0 } { $index < $strLen } { incr index } {
            set checkChar   [ string index $value $index ]
            if { [ regexp -nocase {[0-9a-f]} $checkChar ] } {
                continue
            } else {
                return 0
            }
        }
        return 1
    }
    
    proc PrefixlenToSubnetV4 {value} {
        if {$value >= 0 && $value <=8} {
                set first	[expr 256 - [expr int([expr {pow(2,[expr 8 - $value])}]) ]  ]
                return $first.0.0.0
        } elseif {$value >8 && $value <=16} {
                set second	[expr 256 - [expr int([expr {pow(2,[expr 16 - $value])}]) ]  ]
                return 255.$second.0.0 
        } elseif {$value > 16 && $value <=24} {
                set third	[expr 256 - [expr int([expr {pow(2,[expr 24 - $value])}]) ]  ]
                return 255.255.$third.0 
        } elseif {$value > 24 && $value <=32} {
                set fourth	[expr 256 - [expr int([expr {pow(2,[expr 32 - $value])}]) ]  ]
                return 255.255.255.$fourth 
        } else {
                return "NAN"
        }            
    }
    
    proc SubnetToPrefixlenV4 {value} {
        for {set c 0 } {$c <=32} {incr c} {
                if {[PrefixlenToSubnetV4 $c] ==  "$value"} {
                        return $c
                }
        }
        return -1
    }
    #-- Transfer the ip address to hex
    #   -- prefix should be the valid length of result string like the length of
    #       1c231223 is 1c23 when prefix is 16
    #       the enumation of prefix should be one of 8 16 32
    proc IP2Hex { ipv4 { prefix 32 } } {
        if { [ regexp {(\d+)\.(\d+)\.(\d+)\.(\d+)} $ipv4 match A B C D ] } {
            set ipHex [ Int2Hex $A ][ Int2Hex $B ][ Int2Hex $C ][ Int2Hex $D ]
            return [ string range $ipHex 0 [ expr $prefix / 4 - 1 ] ]
        } else {
            return 00000000
        }
    }
	

	
	proc Mac2Hex { mac } {
        set value $mac
        set len [ string length $value ]
        for { set index 0 } { $index < $len } { incr index } {
            if { [ string index $value $index ] == " " || \
                [ string index $value $index ] == "-" ||
                [ string index $value $index ] == "." ||
			    [ string index $value $index ] == ":" } {

			    set value [ string replace $value $index $index " " ] 

            }
        }

        return $value
	
    }
    #-- Transfer the integer to hex
    #   -- len should be the length of result string like the length of 'abcd' is 4
    proc Int2Hex { byte { len 2 } } {
        set hex [ format %x $byte ]
        set hexlen [ string length $hex ]
        if { $hexlen < $len } {
            set hex [ string repeat 0 [ expr $len - $hexlen ] ]$hex
        } elseif { $hexlen > $len } {
            set hex [ string range $hex [ expr $hexlen - $len ] end ]
        }
        return $hex
    }
	
	proc Hex2Int { byte  } {
       
		set hex [format %s $byte]
		puts $hex
        set hexlen [ string length $hex ]
		puts $hexlen
		set newInt 0
		for { set i 0 } {$i < $hexlen} { incr i } {
		    set elenum [string index $hex $i]
			
		    switch $elenum {
			a { set elenum 10}
			b { set elenum 11}
			c { set elenum 12}
			d { set elenum 13}
			e { set elenum 14}
			f { set elenum 15}
			}
			set intele [format %d $elenum]
		    set newInt [expr $newInt *16 + $intele]
		
        }
        return $newInt
    }
	
    proc IncrementIPAddr { IP prefixLen { num 1 } } {
        set Increament_len [ expr 32 - $prefixLen ]
        set Increament_pow [ expr pow(2,$Increament_len) ]
        set Increament_int [ expr round($Increament_pow*$num) ]
        set IP_hex       0x[ IP2Hex $IP ]
        set IP_next_int    [ expr $IP_hex + $Increament_int ]
        if { $IP_next_int > [ format %u 0xffffffff ] } {
            error "Out of address bound"
        }
        set IP_next_hex    [ format %x $IP_next_int ]
        if { [ string length $IP_next_hex ] < 8 } {
            set IP_next_hex [ string repeat 0 [ expr 8 - [ string length $IP_next_hex ] ] ]$IP_next_hex
        } elseif { [ string length $IP_next_hex ] > 8 } {
            #...
            #error ""
        }
        set index_end  0
        set A [ string range $IP_next_hex $index_end [ expr $index_end + 1 ] ]
        incr index_end 2
        set B [ string range $IP_next_hex $index_end [ expr $index_end + 1 ] ]
        incr index_end 2
        set C [ string range $IP_next_hex $index_end [ expr $index_end + 1 ] ]
        incr index_end 2
        set D [ string range $IP_next_hex $index_end [ expr $index_end + 1 ] ]
        return [format %u 0x$A].[format %u 0x$B].[format %u 0x$C].[format %u 0x$D]
    }
	
	proc IncrementIPv6Addr { IP prefixLen { num 1 } } {
	Deputs "pfx len:$prefixLen IP:$IP num:$num"
		set segList [ split $IP ":" ]
		set seg [ expr $prefixLen / 16 - 1 ]
	Deputs "set:$seg"
		set offset [ expr fmod($prefixLen,16) ]
	Deputs "offset:$offset"
		if { $offset  > 0 } {
			incr seg
		}
	Deputs "set:$seg"
		set segValue [ lindex $segList $seg ]
	Deputs "segValue:$segValue"
		set segInt 	 [ format %i 0x$segValue ]
	Deputs "segInt:$segInt"
		if { $offset } {
			incr segInt  [ expr round(pow(2, 16 - $offset)*$num )]
		} else {
			incr segInt $num
		}
	Deputs "segInt:$segInt"
		if { $segInt > 65535 } {
			incr segInt -65536
			set segHex [format %x $segInt]
	Deputs "segHex:$segHex"
			set segList [lreplace $segList $seg $seg $segHex]
			set newIp ""
			foreach segment $segList {
				set newIp ${newIp}:$segment
			}
			set IP [ string range $newIp 1 end ]
	Deputs "IP:$IP"
			return [ IncrementIPv6Addr $IP [ expr $seg * 16 ] ]
		} else {
			set segHex [format %x $segInt]
			set segList [lreplace $segList $seg $seg $segHex]
			set newIp ""
			foreach segment $segList {
				set newIp ${newIp}:$segment
			}
			set IP [ string range $newIp 1 end ]
			return [ string tolower $IP ]

		}
	}

    proc GetMatchedMask { tester_ip sut_ip } {
        set classAddressTester  [ split $tester_ip "." ]
        set classAddressSut     [ split $sut_ip "." ]
        set mask 0
        foreach testerAddr $classAddressTester sutAddr $classAddressSut {
            if { $testerAddr == $sutAddr } {
                incr mask 8
            } else {
                break
            }
        }
        return $mask
    }
	proc IncrMacAddr { mac1 { mac2 00:00:00:00:00:01 } } {
		set mac1List [ split $mac1 ":" ]
		set mac2List [ split $mac2 ":" ]
		set macLen [ llength $mac1List ]
		
		set macResult 	""
		set flagAdd		0
		for { set index $macLen } { $index > 0 } { incr index -1 } {
	#Deputs "loop index:$index"
			set eleIndex  	[ expr $index -1 ]
	#Deputs "index:$eleIndex"
			set mac1Ele 	[ lindex $mac1List $eleIndex ]
			set mac2Ele		[ lindex $mac2List $eleIndex ]
	#Deputs "mac element:$mac1Ele $mac2Ele"
			set macAdd 		[ format %x [ expr 0x$mac1Ele + 0x$mac2Ele ] ]
	#Deputs "mac plus addr:$macAdd"
			if { $flagAdd } {
				scan $macAdd %x macAddD
				incr macAddD $flagAdd
				set macAdd [ format %x $macAddD ]
			}
	#Deputs "incr flag:$macAdd"
			if { [ string length $macAdd ] > 2 } {
				set flagAdd	1
				set macAdd [ string range $macAdd [ expr [ string length $macAdd ] - 2 ] end ]
			} else {
				set flagAdd 0
			}
	#Deputs "flag add:$flagAdd"
			# set macTrans [ expr round(fmod($macAdd,16)) ]
	# Deputs "macTrans:$macTrans"
			# set macTrans [ format %x $macTrans ]
	# Deputs "macTrans hex:$macTrans"
			if { [ string length $macAdd ] == 1 } {
				set macAdd "0$macAdd"
			}
	#Deputs "macTrans after add zero:$macAdd"
			set macResult ":$macAdd$macResult"
	#Deputs "macResult:$macResult"
			}
		return [ string range $macResult 1 end ]
	}
	
	

    proc GetObject { name } {
        foreach obj [ find objects ] {
		    if { $name == $obj || $name == "::$obj" } {
			    return $obj
			}
            if { [ regexp $name $obj ] && ![ regexp ${name}. $obj ] && ![ regexp "\[^:\]$name" $obj ] } {
                return $obj
            }
        }
        return ""
    }

    proc GetMacStep { offset val } {
        set macStep ""
        set segment [ expr $offset / 8 ]
        set remain  [ expr fmod($offset,8)]
Deputs "segment:$segment remain:$remain"
        for { set index 0 } { $index < 6 } { incr index } {
            if { $segment == $index } {
                set step [expr round(pow(2,$remain)*$val)]
                set stepHex [format %x $step]
                if { [ string length $stepHex ] < 2 } {
                    set stepHex "0$stepHex"
                }
Deputs "step:$step stepHex:$stepHex"
                if { $index > 0 } {
                    set macStep ${stepHex}:$macStep
                } else {
                    set macStep ${stepHex}$macStep
                }
            } else {
                if { $index > 0 } {
                    set macStep 00:$macStep
                } else {
                    set macStep 00$macStep
                }
            }
Deputs "macStep:$macStep"
        }
        return $macStep
    }
    
    proc GetIpStep { offset val } {
        set ipStep ""
        set segment [ expr $offset / 8 ]
        set remain  [ expr fmod($offset,8)]
Deputs "segment:$segment remain:$remain"
        for { set index 0 } { $index < 4 } { incr index } {
            if { $segment == $index } {
                set step [expr round(pow(2,$remain)*$val)]
                if { $step > 255 } {
                    set step 0
                }
Deputs "step:$step"
                if { $index > 0 } {
                    set ipStep ${step}.$ipStep
                } else {
                    set ipStep ${step}$ipStep
                }
            } else {
                if { $index > 0 } {
                    set ipStep 0.$ipStep
                } else {
                    set ipStep 0$ipStep
                }
            }
Deputs "ipStep:$ipStep"
        }
        return $ipStep
    }
	
	proc GetIpv6Step { offset val } {
		if { [ catch {
			set ipStep [IncrementIPv6Addr 0000:0000:0000:0000:0000:0000:0000:0000 $offset $val ]
			puts $ipStep
		} err ] } {
	Deputs "ERR:$err"	
			set ipStep 0000:0000:0000:0000:0000:0000:0000:0000
		}

		return $ipStep
	}
	
	proc GetStepPrefixlen { ip } {
	    for { set index 0 } { $index < 32 } { incr index } {
		  
		    if { [ GetIpStep $index 1 ] == $ip } {
			    return [ expr 32 - $index ]
		    }
	    }
	    return -1
	}
	
	proc GetStepv6Prefixlen { ip } {
	    for { set index 1 } { $index <= 128 } { incr index } {
		  
		    if { [::ip::normalize [ GetIpv6Step $index 1 ] ] == $ip } {
			   #return [ expr 128 - $index ]
               return $index
		    }
	    }
	    return -1
	}
	 
	proc SaveConfigAsXML { path } {
		# Convert xml file to ixncfg file
		if { [file extension $path] == ".xml" } {
			set path [string replace $path [expr [string length $path] - 4] end ".ixncfg"]
		}
		Tester::save_config $path
	}
	
	proc ixConvertAllToLowerCase {args} {
	   set args [eval subst $args]
	   set ixargs ""
	   if {[expr {[llength $args] % 2}] != 0} {
		  puts "ERROR--Parameters must be a list of pair, such as -Attr Value."    
	   } else {
		  foreach {attr val} $args {
			 set attr [string tolower $attr]
			 set val  [string tolower $val]
			 lappend ixargs $attr $val
		  }
	   }
	   return $ixargs
	}
	
	proc ixConvertBool { value } {
    set value [ string tolower $value ]
    if { ( $value == "enable" ) || ( $value == "success" ) || ( $value == "true" )  } {
        set value "true"
    }
    if { ( $value == "disable" ) || ( $value == "fail" ) || ( $value == "false" )  } {
        set value "false"
    }
    if { $value == 1 || $value == 0 } {
        return $value
    } else {
        if { [ info exists [string tolower $value] ] == 0 } {
            return $value
        }
        eval { set trans } $[string tolower $value]
        if { $trans == "true" || $trans == "false" } {
            return $trans
        } else {
            return $value
        }
    }
}

}