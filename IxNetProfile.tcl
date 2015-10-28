# Profile.tcl --
#   This file implements the Profile class for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1

namespace eval IxiaCapi {
    
    class Profile {
        
        constructor { args } {}
        method Config { args } {}
        
        public variable Type        
        public variable hPort
        public variable Mode
        public variable TrafficLoad
        public variable TrafficLoadUnit
        public variable BurstSize
        public variable FrameLen
        public variable CustomList
        public variable hProfile
        # New
        public variable Blocking
        public variable StreamList
        
        method AddStreamGroup { stream } {
		set tag "body Profile::AddStreamGroup [info script]"
Deputs "----- TAG: $tag -----"
            lappend StreamList $stream
        }
		method DeleteStreamGruop {stream } {
		set tag "body Profile::DeleteStreamGruop [info script]"
Deputs "----- TAG: $tag -----"
		    set index [ llength $StreamList ]			
            if { $index >= 0 } {
                set handleIndex [ lsearch -exact $StreamList $stream ]
				
                set StreamList [lreplace $StreamList $handleIndex $handleIndex ]             
            }
			puts $StreamList
		}
        method GetStreamCount {} {
            return [ llength $StreamList ]
        }
        method RefreshStreamLoad {} {
            foreach stream $StreamList {
                $stream SetProfileParam
            }
        }
    }
    
    body Profile::constructor { args } {
        global errorInfo
        
        set tag "body Profile::Ctor [info script]"
Deputs "----- TAG: $tag -----"
        set hPort -1
        set EType [ list CONSTANT BURST CUSTOM ]
        set TrafficLoad             $IxiaCapi::DefaultTrafficLoad
        set TrafficLoadUnit         $IxiaCapi::DefaultTrafficLoadUnit
        set Type                    $IxiaCapi::DefaultTrafficType
        set BurstSize               $IxiaCapi::DefaultTrafficBurstSize
        set Blocking    0
        set FrameLen    0
        set StreamList  [list]
Deputs "Collect params..."
# Params collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -type -
                -profiletype {
                    if { [ lsearch -exact $EType [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ProfileCtor2 $EType"                        
                    } else {
                        set Type [string toupper $value]
                    }
                }
                -hport {
                    set hPort $value
                }
                -handle {
                    set handle $value
                }
            }
        }

Deputs "add Profile handle..."
# To add profile to profilelist --
            set hProfile [clock seconds]
            IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_ProfileCtor1"
Deputs "Create Profile object done..."
            return $this
    }

    body Profile::Config { args } {
        
        global errorInfo
        global IxiaCapi::MaxTrafficLoad
        set tag "body Profile::ConfigProfile [info script]"
Deputs "----- TAG: $tag -----"
        
        set EType [ list BURST CONSTANT CUSTOM ]
        set EMode [ list CONTINUOUS ONE_SHOT ]
        set EUnit [ list PPS MBPS PERCENT L3MBPS FPS BPS KBPS]
        
# Params collection --
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -trafficload {
                    set transLoad [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is double -strict $transLoad ] } {
                        if { $value >0 && $value < $MaxTrafficLoad } {
                            set TrafficLoad $transLoad                            
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_ProfileConfigProfile5 0-$MaxTrafficLoad"                                                
                        }
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ProfileConfigProfile4"                                                
                    }
                }
                -trafficloadunit {
                    if { [ lsearch -exact $EUnit [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ProfileConfigProfile8 $EUnit"                        
                    } else {
                        set TrafficLoadUnit [string toupper $value]
                    }
                }
                -burstsize {
                    set transsize [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer -strict $transsize ] } {
                        set BurstSize $transsize
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ProfileConfigProfile9"                                                
                    }
                }
                -mode {
                    if { [ lsearch -exact $EMode [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ProfileConfigProfile6 $EMode"                        
                    } else {
                        set Mode [string toupper $value]
                    }
                }
                -framenum -
                -framelen {
                    set frameLen [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer -strict $frameLen ] } {
                        if { $value > 0  } {
                            set FrameLen $frameLen                            
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_ProfileConfigProfile11 0-$MaxFrameLen"                                                
                        }
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ProfileConfigProfile12 $value"                                                
                    }
                }
                -customlist {
                    if { [ lindex $value 0 ] != "" } {
                        set list0 [ lindex $value 0 ]
                        set check 1
                        foreach idv $list0 {
                            if { [ string is integer $idv ] == 0 } {
                                set check 0
                            }
                        }
                        if { $check } {
                            set idvs $list0
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_ProfileConfigProfile13 $value"                                                
                        }
                    }
                    if { [ lindex $value 1 ] != "" } {
                        set list1 [ lindex $value 1 ]
                        set check 1
                        foreach rp $list1 {
                            if { [ string is integer $rp ] == 0 } {
                                set check 0
                            }
                        }
                        if { $check } {
                            set rps $list1
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_ProfileConfigProfile14 $value"                                                
                        }
                    }
                    set CustomList [ list $idvs $rps ]
                }
                
                -type -
                -profiletype {
                    if { [ lsearch -exact $EType [ string toupper $value ] ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_ProfileConfigProfile15 $EType"                        
                    } else {
                        set newType [string toupper $value]
                        set Type $newType
                    }
                }
                -blocking {
                    set transFlag [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $transFlag == 1 || $transFlag == 0 } {
                        set Blocking $transFlag
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_ProfileConfigProfile16 $value" -tag $tag
                        return $IxiaCapi::errorcode(1)
                    }
                }
            }
        }
        RefreshStreamLoad
        
        IxiaCapi::Logger::LogIn -message "$IxiaCapi::s_ProfileConfigProfile1"
        return 1
    }

}
