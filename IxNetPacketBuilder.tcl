# PacketBuilder.tcl --
#   This file implements the PacketBuilder class for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1

namespace eval IxiaCapi {
    class PacketBuilder {
        inherit HeaderCreator
        constructor { } {
            set pduList [ list ]
        }
        method CreateDHCPPkt { args } {}
        method ConfigDHCPPkt { args } {}
        method CreateDHCPv6Pkt { args } {}
        method ConfigDHCPv6Pkt { args } {}
        method CreateDHCPv6CSPkt { args } {}
        method CreateDHCPv6RSPkt { args } {}
        method CreateDVMRPPkt { args } {}
        method ConfigDVMRPPkt { args } {}
        method CreateDVMRPv1Pkt { args } {}
        method CreateDVMRPv3Pkt { args } {}
        method CreateGMRPPkt { args } {}
        method ConfigGMRPPkt { args } {}
        method CreateGVRPPkt { args } {}
        method ConfigGVRPPkt { args } {}
        method CreateHSRPPkt { args } {}
        method ConfigHSRPPkt { args } {}
        method CreateIGRPPkt { args } {}
        method ConfigIGRPPkt { args } {}
        method CreateISISPkt { args } {}
        method ConfigISISPkt { args } {}
        method CreateL2TPPkt { args } {}
        method ConfigL2TPPkt { args } {}
        method CreateLDPPkt { args } {}
        method ConfigLDPPkt { args } {}
        method CreateMSDPPkt { args } {}
        method ConfigMSDPPkt { args } {}
        method CreateOSPFv2Pkt { args } {}
        method ConfigOSPFv2Pkt { args } {}
        method CreateOSPFv3Pkt { args } {}
        method ConfigOSPFv3Pkt { args } {}
        method CreatePIMPkt { args } {}
        method ConfigPIMPkt { args } {}
        method CreatePPPoEPkt { args } {}
        method ConfigPPPoEPkt { args } {}
        method CreateRIPPkt { args } {}
        method ConfigRIPPkt { args } {}
        method CreateRIPngPkt { args } {}
        method ConfigRIPngPkt { args } {}
        method CreateRSVPPkt { args } {}
        method ConfigRSVPPkt { args } {}
        method CreateVRRPPkt { args } {}
        method ConfigVRRPPkt { args } {}
        method CreateEAPPkt { args } {}
        method ConfigEAPPkt { args } {}
        method CreateEAPOLPkt { args } {}
        method ConfigEAPOLPkt { args } {}
        method CreateARPPkt { args } {}
        method ConfigARPPkt { args } {}
        method CreateBPDUPkt { args } {}
        method ConfigBPDUPkt { args } {}
        method CreateCustomPkt { args } {}
        method ConfigCustomPkt { args } {}
        method CreateICMPPkt { args } {}
        method ConfigICMPPkt { args } {}
        method CreateICMPv6Pkt { args } {}
        method ConfigICMPv6Pkt { args } {}
        method CreateIGMPPkt { args } {}
        method ConfigIGMPPkt { args } {}
        method CreateBGP4Pkt { args } {}
        method ConfigBGP4Pkt { args } {}
        method CreateGREPkt { args } {}
        method ConfigGREPkt { args } {}
        destructor { DestroyPdu }
    }
    
    

    body PacketBuilder::CreateDHCPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro DHCP} $args ] == $success \
            && [ eval ConfigDHCPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateDHCPv6Pkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro DHCPv6} $args ]= = $success \
            && [ eval ConfigDHCPv6Pkt $args ] == $success } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateDHCPv6CSPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro DHCPv6} $args ] == $success \
            && [ eval {ConfigDHCPv6Pkt -cs 1} $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateDHCPv6RSPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro DHCPv6} $args ] == $success \
            && [ eval {ConfigDHCPv6Pkt -rs 1} $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateDVMRPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro DVMRP} $args ] == $success \
            && [ eval ConfigDVMRPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateDVMRPv1Pkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro DVMRP} $args ] == $success \
            && [ eval {ConfigDVMRPPkt -v1 1} $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateDVMRPv3Pkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro DVMRP} $args ] == $success \
            && [ eval {ConfigDVMRPPkt -v3 1} $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateGMRPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro GMRP} $args ] == $success \
            && [ eval ConfigGMRPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateGVRPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro GVRP} $args ] == $success \
            && [ eval ConfigGVRPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateHSRPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro HSRP} $args ] == $success \
            && [ eval ConfigHSRPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateIGRPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro IGRP} $args ] == $success \
            && [ eval ConfigIGRPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateISISPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro IS-IS} $args ] == $success \
            && [ eval ConfigISISPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateL2TPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro L2TPv2} $args ] == $success \
            && [ eval ConfigL2TPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateLDPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro LDP} $args ] == $success \
            && [ eval ConfigLDPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateMSDPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro MSDP} $args ] == $success \
            && [ eval ConfigMSDPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateOSPFv2Pkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro OSPFv2} $args ] == $success \
            && [ eval ConfigOSPFv2Pkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateOSPFv3Pkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro OSPFv3} $args ] == $success \
            && [ eval ConfigOSPFv3Pkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreatePIMPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro PIM} $args ] == $success \
            && [ eval ConfigPIMPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreatePPPoEPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro PPPoE} $args ] == $success \
            && [ eval ConfigPPPoEPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateRIPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro RIP} $args ] == $success \
            && [ eval ConfigRIPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateRIPngPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro RIPng} $args ] == $success \
            && [ eval ConfigRIPngPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateRSVPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro RSVP} $args ] == $success \
            && [ eval ConfigRSVPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateVRRPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro VRRP} $args ] == $success \
            && [ eval ConfigVRRPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateEAPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro EAP} $args ] == $success \
            && [ eval ConfigEAPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateEAPOLPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro EAPOL} $args ] == $success \
            && [ eval ConfigEAPOLPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateARPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro ethernetARP} $args ] == $success \
            && [ eval ConfigARPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateBPDUPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro BPDU} $args ] == $success \
            && [ eval ConfigBPDUPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateICMPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro ICMP} $args ] == $success \
            && [ eval ConfigICMPPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateICMPv6Pkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro ICMP_v6} $args ] == $success \
            && [ eval ConfigICMPv6Pkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateIGMPPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro IGMP} $args ] == $success \
            && [ eval ConfigIGMPPkt -protocolver IGMPv2 $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateBGP4Pkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro BGP4} $args ] == $success \
            && [ eval ConfigBGP4Pkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body PacketBuilder::CreateGREPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateHeader -pro GRE} $args ] == $success \
            && [ eval ConfigGREPkt $args ] <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }


    body PacketBuilder::CreateCustomPkt { args } {
        global IxiaCapi::fail IxiaCapi::success
        if { [ eval {CreateCustomHeader -pro custom} $args ] == $success } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
# Config Pkt --
    body PacketBuilder::ConfigDHCPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigDHCPPkt [info script]"
        set EOpType [ list client server ]
Deputs "----- TAG: $tag -----"
        set level 2        
        set enOp 0
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -op -
                -dhcpop {
                    set index [ lsearch -exact $EOpType [ string tolower $value ] ]
                    if { $index < 0 } {
                        if { $value == 1 || $value == 2 } {
                            set op $value
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigDHCPPkt2 $value" -tag $tag                        
                        }
                    } else {
                        set op [ incr index ]
                    }
                }
                -htype -
                -dhcphtype {
                    if { [ string is integer $value ] && $value < 256 } {
                        set htype $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt3 $value" -tag $tag                        
                    }
                }
                -hlen -
                -dhcphlen {
                    if { [ string is integer $value ] && $value < 256 } {
                        set hlen $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt4 $value" -tag $tag                        
                    }
                }
                -hops -
                -dhcphops {
                    if { [ string is integer $value ] && $value < 256 } {
                        set hops $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt5 $value" -tag $tag                        
                    }
                }
                -xid -
                -dhcpxid {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set xid $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt6 $trans" -tag $tag                        
                    }
                }
                -secs -
                -dhcpsecs {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set secs $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt7 $trans" -tag $tag                        
                    }
                }
                -bflag -
                -dhcpbflag {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set bflag $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt8 $trans" -tag $tag                        
                    }                    
                }
                -dhcpmbz15 -
                -mbz15 {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set mbz15 $hex
                            } else {
                                set mbz15 $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigDHCPPkt9 $value" -tag $tag                        
                        }
                }
                -dhcpciaddr -
                -ciaddr {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set ciaddr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt16 $value" -tag $tag                        
                    }                                      
                }
                -yiaddr -
                -dhcpyiaddr {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set yiaddr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt10 $value" -tag $tag                        
                    }                    
                }
                -dhcpsiaddr -
                -siaddr {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set siaddr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt11 $value" -tag $tag                        
                    }                    
                }
                -giaddr -
                -dhcpgiaddr {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set giaddr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt12 $value" -tag $tag                        
                    }                    
                }
                -chaddr -
                -dhcpchaddr {
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set trans [ IxiaCapi::Regexer::MacTrans $value ]
                        set hex ""
                        for { set index 0 } { $index < [ string length $trans ] } \
                        { incr index } {
                            set char [ string index $trans $index ]
                            if { $char != ":" } {
                                set hex ${hex}$char
                            }
                        }
Deputs "HEX of hardware address: $hex "
                        set chaddr 0x$hex
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPPkt13 $value" -tag $tag                        
                    }
                }
                -sname -
                -dhcpsname {
                    #set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    #if { [ string is integer $trans ] } {
                    #    set sname $trans
                    #} else {
                    #    IxiaCapi::Logger::LogIn -type warn -message \
                    #    "$IxiaCapi::s_PacketBuilderConfigDHCPPkt14 $trans" -tag $tag                        
                    #}
                    set sname $value
                }
                -file -
                -dhcpfile {
                    #set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    #if { [ string is integer $trans ] } {
                    #    set File $trans
                    #} else {
                    #    IxiaCapi::Logger::LogIn -type warn -message \
                    #    "$IxiaCapi::s_PacketBuilderConfigDHCPPkt15 $trans" -tag $tag                        
                    #}
                    set File $value
                }
                -option -
                -options -
                -dhcpoption -
                -dhcpoptions {
                    set enOp 1
                    foreach { opkey opvalue } $value {
                        set opkey [string tolower $opkey]
                        switch -exact -- $opkey {
                            -messagetype {
                                set msgType $opvalue
                            }
                            -message {
                                set msg $opvalue
                            }
                            -endofoptions {
                                set endOp $opvalue
                            }
                        }
                    }
                }
                default {}
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "dhcp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol DHCP"
        #-----Config common-----
        if { [ info exists op ] } {
            uplevel $level "
            $pdu AddField opCode
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $op"
        }
        if { [ info exists htype ] } {
            uplevel $level "
            $pdu AddField hwType 
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $htype"
        }
        if { [ info exists hlen ] } {
            uplevel $level "
            $pdu AddField hwAddressLen
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hlen"
        }
        if { [ info exists hops ] } {
            uplevel $level "
            $pdu AddField hops
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hops"
        }
        if { [ info exists xid ] } {
            uplevel $level "
            $pdu AddField transactionId
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $xid"
        }
        if { [ info exists secs ] } {
            uplevel $level "
            $pdu AddField secondsElapsed
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $secs"
        }
        if { [ info exists bflag ] } {
            uplevel $level "
            $pdu AddField broadcastFlag
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $bflag"
        }
        if { [ info exists mbz15 ] } {
        }
        if { [ info exists ciaddr ] } {
            uplevel $level "
            $pdu AddField clientIP
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $ciaddr"
        }
        if { [ info exists yiaddr ] } {
            uplevel $level "
            $pdu AddField yourIP
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $yiaddr"
        }
        if { [ info exists siaddr ] } {
            uplevel $level "
            $pdu AddField serverIP
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $siaddr"
        }
        if { [ info exists giaddr ] } {
            uplevel $level "
            $pdu AddField relayAgentIP
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $giaddr"
        }
        if { [ info exists chaddr ] } {
            uplevel $level "
            $pdu AddField clientHwAddress
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $chaddr"
        }
        if { [ info exists sname ] } {
            uplevel $level "
            $pdu AddField optionalServerName
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $sname"
        }
        if { [ info exists File ] } {
            uplevel $level "
            $pdu AddField bootFile
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $File"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }

    }
    
    body PacketBuilder::ConfigDHCPv6Pkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigDHCPPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -cs {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set cs $trans
                    }                   
                }
                -rs {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set rs $trans
                    }                   
                }
                -mp {
                    if { [ string is integer $value ] && $value < 256 } {
                        set mp $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPv6Pkt2 $value" -tag $tag                        
                    }
                    
                }
                -xid {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set xid $hex
                            } else {
                                set xid $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigDHCPv6Pkt3 $value" -tag $tag                        
                        }
                }
                -hop {
                    if { [ string is integer $value ] && $value < 256 } {
                        set hop $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPv6Pkt4 $value" -tag $tag                        
                    }
                }
                -lkad {
                    if { [ IxiaCapi::Regexer::IsIPv6Address $value] } {
                        set lkad $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPv6Pkt5 $value" -tag $tag                        
                    }
                }
                -prad {
                    if { [ IxiaCapi::Regexer::IsIPv6Address $value] } {
                        set prad $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDHCPv6Pkt6 $value" -tag $tag                        
                    }
                }
                -option {
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "dhcpv6" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
        #-----Config common-----
        if { [ info exists cs ] } {
            uplevel $level "
        $pdu SetProtocol dhcpv6ClientServer"
        }
        if { [ info exists rs ] } {
            uplevel $level "
        $pdu SetProtocol dhcpv6Relay"
        }
        if { [ info exists mp ] } {
            uplevel $level "
                $pdu AddField messageType
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $mp"
        }
        if { [ info exists xid ] } {
            uplevel $level "
            $pdu AddField transactionId
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $xid"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
        
    }
    body PacketBuilder::ConfigDVMRPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigDVMRPPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -v1 {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set v1 $trans
                    }                   
                }
                -v3 {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set v3 $trans
                    }                   
                }
                -type {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set type $hex
                            } else {
                                set type $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigDVMRPPkt2 $value" -tag $tag                        
                        }
                }
                -subtype {
                    if { [ regexp {[0-9]+} match v1_subtype ] == 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigDVMRPPkt3 $value" -tag $tag                        
                    }
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "dvmrp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol DVMRP"
        #-----Config common-----
        if { [ info exists v1 ] } {
            uplevel $level "
            $pdu AddField dvmrp_v1 1
            $pdu AddFieldMode Reserved
            $pdu AddFieldConfig 0"
        }
        if { [ info exists v3 ] } {
            uplevel $level "
            $pdu AddField dvmrp_v3 1
            $pdu AddFieldMode Reserved
            $pdu AddFieldConfig 0"
        }
        if { [ info exists type ] } {
            if { [ info exists v1 ] } {
            uplevel $level "
                $pdu AddField v1_type
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $type"
            } else {
            uplevel $level "
                $pdu AddField dvmrp_type
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $type"
            }
        }
        if { [ info exists v1_subtype ] } {
            uplevel $level "
            $pdu AddField v1_subtype
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $v1_subtype"
        }

        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }
    body PacketBuilder::ConfigGMRPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigGMRPPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -prot_id {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set prot_id $hex
                            } else {
                                set prot_id $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigGMRPPkt2 $value" -tag $tag                        
                        }
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "gmrp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol GMRP"
        #-----Config common-----
        if { [ info exists prot_id ] } {
            uplevel $level "
            $pdu AddField prot_id
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $prot_id"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
        
    }
    body PacketBuilder::ConfigGVRPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigGVRPPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -prot_id {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set prot_id $hex
                            } else {
                                set prot_id $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigGVRPPkt2 $value" -tag $tag                        
                        }
                }
                -atttype {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set attribute_type $hex
                            } else {
                                set attribute_type $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigGVRPPkt3 $value" -tag $tag                        
                        }
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "gvrp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol GVRP"
        #-----Config common-----
        if { [ info exists prot_id ] } {
            uplevel $level "
            $pdu AddField prot_id
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $prot_id"
        }
        if { [ info exists attribute_type ] } {
            uplevel $level "
            $pdu AddField attribute_type
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $attribute_type"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }

    
    body PacketBuilder::ConfigHSRPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigHSRPPkt [info script]"
Deputs "----- TAG: $tag -----"
        
        set EState [ list 0 1 2 4 8 16 ]
        set level 2
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -ver {
                    if { [ string is integer $value ] } {
                        set version $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigHSRPPkt2 $value"\
                        -tag $tag                                                
                    }
                }
                -opcode {
                    if { [ string is integer $value ] } {
                        set opcode $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigHSRPPkt3 $value"\
                        -tag $tag                                                
                    }
                }
                -state {
                    set index [ lsearch -exact $EState $value ]
                    if { $index > 0 } {
                        set state [ lindex $EState $index ]
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigHSRPPkt4 $EState"\
                        -tag $tag                                                
                    }
                }
                -hellotime {
                    if { [ string is integer $value ] } {
                        set hello_time $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigHSRPPkt5 $value"\
                        -tag $tag                                                
                    }
                }
                -holdtime {
                    if { [ string is integer $value ] } {
                        set hold_time $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigHSRPPkt6 $value"\
                        -tag $tag                                                
                    }
                }
                -prior -
                -priority {
                    if { [ string is integer $value ] } {
                        set priority $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigHSRPPkt7 $value"\
                        -tag $tag                                                
                    }
                }
                -group {
                    if { [ string is integer $value ] } {
                        set group $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigHSRPPkt8 $value"\
                        -tag $tag                                                
                    }
                }
                -resv {
                    if { [ string is integer $value ] } {
                        set resv $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigHSRPPkt9 $value"\
                        -tag $tag                                                
                    }
                }
                -auth_data {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set auth_data $hex
                            } else {
                                set auth_data $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigGVRPPkt10 $value" -tag $tag                        
                        }                    
                }
                -virtual_ip {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set virtual_ip $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigGVRPPkt10 $value" -tag $tag                        
                    }
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "hsrp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol HSRP"
        #-----Config common-----
        if { [ info exists version ] } {
            uplevel $level "
            $pdu AddField version
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $version"
        }
        if { [ info exists opcode ] } {
            uplevel $level "
            $pdu AddField opcode
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $opcode"
        }
        if { [ info exists state ] } {
            uplevel $level "
            $pdu AddField state
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $state"
        }
        if { [ info exists hello_time ] } {
            uplevel $level "
            $pdu AddField hello_time
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hello_time"
        }
        if { [ info exists hold_time ] } {
            uplevel $level "
            $pdu AddField hold_time
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hold_time"
        }
        if { [ info exists priority ] } {
            uplevel $level "
            $pdu AddField priority
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $priority"
        }
        if { [ info exists group ] } {
            uplevel $level "
            $pdu AddField group
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $group"
        }
        if { [ info exists resv ] } {
            uplevel $level "
            $pdu AddField resv
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $resv"
        }
        if { [ info exists auth_data ] } {
            uplevel $level "
            $pdu AddField auth_data
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $auth_data"
        }
        if { [ info exists virtual_ip ] } {
            uplevel $level "
            $pdu AddField virtual_ip
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $virtual_ip"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }

    
    body PacketBuilder::ConfigIGRPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigIGRPPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -ver {
                    if { [ string is integer $value ] } {
                        set version $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt2 $value"\
                        -tag $tag                                                
                    }
                }
                -opcode {
                    if { [ string is integer $value ] } {
                        set opcode $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt3 $value"\
                        -tag $tag                                                
                    }
                }
                -edition {
                    if { [ string is integer $value ] } {
                        set edition $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt4 $value"\
                        -tag $tag                                                
                    }
                }
                -as_number {
                    if { [ string is integer $value ] } {
                        set as_number $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt5 $value"\
                        -tag $tag                                                
                    }
                }
                -inter_route {
                    if { [ string is integer $value ] } {
                        set num_interior_routes $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt6 $value"\
                        -tag $tag                                                
                    }
                }
                -sys_route {
                    if { [ string is integer $value ] } {
                        set num_system_routes $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt7 $value"\
                        -tag $tag                                                
                    }
                }
                -exter_route {
                    if { [ string is integer $value ] } {
                        set num_exterior_routes $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt8 $value"\
                        -tag $tag                                                
                    }
                }
                -dest {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set destination $hex
                            } else {
                                set destination $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigIGRPPkt9 $value" -tag $tag                        
                        }                    
                }
                -delay {
                    if { [ string is integer $value ] } {
                        set delay $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt10 $value"\
                        -tag $tag                                                
                    }
                }
                -band {
                    if { [ string is integer $value ] } {
                        set bandwidth $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt11 $value"\
                        -tag $tag                                                
                    }
                }
                -mtu {
                    if { [ string is integer $value ] } {
                        set mtu $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt12 $value"\
                        -tag $tag                                                
                    }
                }
                -relia {
                    if { [ string is integer $value ] } {
                        set reliability $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt13 $value"\
                        -tag $tag                                                
                    }
                }
                -load {
                    if { [ string is integer $value ] } {
                        set _load $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt14 $value"\
                        -tag $tag                                                
                    }
                }
                -hop {
                    if { [ string is integer $value ] } {
                        set hop_count $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGRPPkt15 $value"\
                        -tag $tag                                                
                    }
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "igrp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol IGRP"
        #-----Config common-----
        if { [ info exists version ] } {
            uplevel $level "
            $pdu AddField version
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $version"
        }
        if { [ info exists opcode ] } {
            uplevel $level "
            $pdu AddField opcode
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $opcode"
        }
        if { [ info exists edition ] } {
            uplevel $level "
            $pdu AddField edition
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $edition"
        }
        if { [ info exists as_number ] } {
            uplevel $level "
            $pdu AddField as_number
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $as_number"
        }
        if { [ info exists num_interior_routes ] } {
            uplevel $level "
            $pdu AddField num_interior_routes
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $num_interior_routes"
        }
        if { [ info exists num_system_routes ] } {
            uplevel $level "
            $pdu AddField num_system_routes
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $num_system_routes"
        }
        if { [ info exists num_exterior_routes ] } {
            uplevel $level "
            $pdu AddField num_exterior_routes
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $num_exterior_routes"
        }
        if { [ info exists destination ] } {
            uplevel $level "
            $pdu AddField destination
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $destination"
        }
        if { [ info exists delay ] } {
            uplevel $level "
            $pdu AddField delay
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $delay"
        }
        if { [ info exists bandwidth ] } {
            uplevel $level "
            $pdu AddField bandwidth
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $bandwidth"
        }
        if { [ info exists mtu ] } {
            uplevel $level "
            $pdu AddField mtu
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $mtu"
        }
        if { [ info exists reliability ] } {
            uplevel $level "
            $pdu AddField reliability
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $reliability"
        }
        if { [ info exists _load ] } {
            uplevel $level "
            $pdu AddField load
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $_load"
        }
        if { [ info exists hop_count ] } {
            uplevel $level "
            $pdu AddField hop_count
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hop_count"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }
    body PacketBuilder::ConfigISISPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigISISPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -intradomain_routing_protocol_discriminator {
                    if { [ string is integer $value ] ||
                        [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                            if { [ info exists hex ] } {
                                set intradomain_routing_protocol_discriminator $hex
                            } else {
                                set intradomain_routing_protocol_discriminator $value
                            }
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigIGRPPkt9 $value" -tag $tag                        
                        }                    
                }
                -length_indicator {
                    if { [ string is integer $value ] } {
                        set length_indicator $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigISISPkt3 $value"\
                        -tag $tag                                                
                    }
                }
                -version_protocol_ID {
                    if { [ string is integer $value ] } {
                        set version_protocol_ID $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigISISPkt4 $value"\
                        -tag $tag                                                
                    }
                }
                -id_length {
                    if { [ string is integer $value ] } {
                        set id_length $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigISISPkt5 $value"\
                        -tag $tag                                                
                    }
                }
                -r_bit {
                    if { [ regexp -exact {[01][01][01]} $value match r_bit ] == 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigISISPkt6 $value"\
                        -tag $tag                                                
                    }
                }
                -version {
                    if { [ string is integer $value ] } {
                        set version $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigISISPkt7 $value"\
                        -tag $tag                                                
                    }
                }
                -reserved {
                    if { [ regexp -exact {[01][01][01][01][01][01][01][01]}\
                        $value match r_bit ] == 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigISISPkt8 $value"\
                        -tag $tag                                                
                    }
                }
                -max_area_addresses {
                    if { [ string is integer $value ] } {
                        set max_area_addresses $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigISISPkt9 $value"\
                        -tag $tag                                                
                    }
                }
                -variable_header {
                    set value [string tolower $value]
                    switch -exact $value {
                        l1hello {
                            set variable_header "IS-IS_L1_Hello"
                        }
                        l2hello {
                            set variable_header "IS-IS_L2_Hello"
                        }
                        ptphello {
                            set variable_header "IS-IS_PTP_Hello"
                        }
                        l1lsp {
                            set variable_header "IS-IS_L1_Link_State"
                        }
                        l2lsp {
                            set variable_header "IS-IS_L2_Link_State"
                        }
                        l1csnp {
                            set variable_header "IS-IS_L1_Complete_SeqNums"
                        }
                        l2csnp {
                            set variable_header "IS-IS_L2_Complete_SeqNums"
                        }
                        l1psnp {
                            set variable_header "IS-IS_L1_Partial_SeqNums"
                        }
                        l2psnp {
                            set variable_header "IS-IS_L2_Partial_SeqNums"
                        }
                    }
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "is-is" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol IS-IS"
        #-----Config common-----
        if { [ info exists intradomain_routing_protocol_discriminator ] } {
            uplevel $level "
            $pdu AddField intradomain_routing_protocol_discriminator
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $intradomain_routing_protocol_discriminator"
        }
        if { [ info exists length_indicator ] } {
            uplevel $level "
            $pdu AddField length_indicator
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $length_indicator"
        }
        if { [ info exists version_protocol_ID ] } {
            uplevel $level "
            $pdu AddField version_protocol_ID
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $version_protocol_ID"
        }
        if { [ info exists id_length ] } {
            uplevel $level "
            $pdu AddField id_length
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $id_length"
        }
        if { [ info exists r_bit ] } {
            uplevel $level "
            $pdu AddField r_bit
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $r_bit"
        }
        if { [ info exists version ] } {
            uplevel $level "
            $pdu AddField version
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $version"
        }
        if { [ info exists reserved ] } {
            uplevel $level "
            $pdu AddField reserved
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $reserved"
        }
        if { [ info exists max_area_addresses ] } {
            uplevel $level "
            $pdu AddField max_area_addresses
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $max_area_addresses"
        }
        if { [ info exists variable_header ] } {
            uplevel $level "
            $pdu AddField $variable_header 1
            $pdu AddFieldMode Reserved
            $pdu AddFieldConfig 0"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }

    body PacketBuilder::ConfigL2TPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigL2TPPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -mp {
                    set value [string tolower $value]
                    switch -exact $value {
                        control {
                            set mp control_message
                        }
                        data {
                            set mp data_message
                        }
                    }
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "l2tpv2" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol L2TPv2"
        #-----Config common-----
        if { [ info exists mp ] } {
            uplevel $level "
            $pdu AddField $mp 1
            $pdu AddFieldMode Reserved
            $pdu AddFieldConfig 0"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }

    body PacketBuilder::ConfigLDPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigLDPPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -version {
                    if { [ string is integer $value ] && ( $value < 65536 ) } {
                        set version $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigLDPPkt2 $value"\
                        -tag $tag                                                
                    }
                }
                -pdu_length {
                    if { [ string is integer $value ] && ( $value < 65536 ) } {
                        set pdu_length $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigLDPPkt3 $value"\
                        -tag $tag                                                
                    }
                }
                -lsr_id {
                    if { [ IxiaCapi::Regexer::IsIPv4Address  $value ] && ![ IxiaCapi::Regexer::IsIPv4MulticastAddress $value ] } {
                        set lsrId    $value
                    } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigLDPPkt4 $value"\
                            -tag $tag                                                
                    }
                }
                -label_space {
                    if { [ string is integer $value ] && ( $value <= 65535 ) } {
                        set label_space   $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigLDPPkt5 $value"\
                        -tag $tag                                                
                    }
                }
                -messages {
                    if { [ regexp -nocase {0x[a-f0-9]+} match hex ] } {
                        set messages    $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigLDPPkt5 $value"\
                        -tag $tag                                                                      
                    }
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "ldp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol LDP"
        #-----Config common-----
        if { [ info exists version ] } {
            uplevel $level "
            $pdu AddField version
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $version"
        }
        if { [ info exists pdu_length ] } {
            uplevel $level "
            $pdu AddField pdu_length
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $pdu_length"
        }
        if { [ info exists lsrId ] } {
            uplevel $level "
            $pdu AddField lsr_id
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $lsrId"
        }
        if { [ info exists label_space ] } {
            uplevel $level "
            $pdu AddField label_space
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $label_space"
        }
        if { [ info exists messages ] } {
            uplevel $level "
            $pdu AddField messages
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $messages"
        }
        #--------------------------
        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }


    body PacketBuilder::ConfigARPPkt { args } {
        global errorInfo
        set tag "body PacketBuilder::ConfigARPPkt [info script]"
Deputs "----- TAG: $tag -----"
        
        set EType [ list Fixed Random Incrementing Decrementing ]
        set EHwType [ list \
                     ETHERNET_10MB \
                     IEEE_802_NETWORKS \
                     FRAME_RELAY \
                     ATM_16 \
                     HDLC \
                     FIBRE_CHANNEL \
                     ATM_19 \
                     SERIAL_LINE \
                     ATM_21 \
                     ARP_SEC \
                     IPSEC_TUNNEL \
                     INFINIBAND_TM \
        ]
        array set HwTypeArray [ list \
                     ETHERNET_10MB          1  \
                     IEEE_802_NETWORKS      6  \
                     FRAME_RELAY            15 \
                     ATM_16                 16 \
                     HDLC                   17 \
                     FIBRE_CHANNEL          18 \
                     ATM_19                 19 \
                     SERIAL_LINE            20 \
                     ATM_21                 21 \
                     ARP_SEC                30 \
                     IPSEC_TUNNEL           31 \
                     INFINIBAND_TM          32 \
        ]
        set EOperation [ list arprequest arpreply ]
        set offset 0 ;#obsolete
        set saoffset 0
        set daoffset 0
        set spoffset 0
        set dpoffset 0
        set daReCnt Fixed
        set saReCnt Fixed
        set daStep 0000.0000.0001
        set saStep 0000.0000.0001
        set dstProAddrMode Fixed
        set srcProAddrMode Fixed
        set dstProAddrStep 0.0.0.1
        set srcProAddrStep 0.0.0.1
        set level 2
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    set name [::IxiaCapi::NamespaceDefine $value]
                    # if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        # continue
                    # } else {
                        # set name [::IxiaCapi::NamespaceDefine $value]
# Deputs "name:$name"
                    # }
                }
                -desthardwareaddr -
                -arpdsthwaddr {
                    set trans [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $trans ] } {
                        set da $trans
Deputs "dha:$da"
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt2 $value" -tag $tag                        
                    }
                }
                -desthardwareaddrmode -
                -arpdsthwaddrmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt3 $EType" -tag $tag                        
                    } else {
                        set daReCnt $trans
                    }
                }
                -desthardwareaddrcount -
                -desthardwareaddrrepeatcount -
                -arpdsthwaddrcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set daNum $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt4 $value" -tag $tag                        
                    }
                }
                -desthardwareaddrstep -
                -desthardwareaddrrepeatstep -
                -arpdsthwaddrstep {
                    set trans [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $trans ] } {
                        set daStep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt5 $value" -tag $tag                        
                    }
                }
                -arpdsthwaddroffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 48 } {
                        set daoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt10 $value" -tag $tag                        
                    }                    
                }
                -sourcehardwareaddr -
                -arpsrchwaddr {
                    set trans [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $trans ] } {
                        set sa $trans
Deputs "sha:$sa"
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt6 $value" -tag $tag                        
                    }
                }
                -sourcehardwareaddrmode -
                -arpsrchwaddrmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt7 $EType" -tag $tag                        
                    } else {
                        set saReCnt $trans
                    }
                }
                -sourcehardwareaddrstep -
                -sourcehardwareaddrrepeatstep -
                -arpsrchwaddrstep {
                    set trans [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $trans ] } {
                        set saStep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt9 $value" -tag $tag                        
                    }
                }
                -sourcehardwareaddrrepeatcount -
                -sourcehardwareaddrcount -
                -arpsrchwaddrcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set saNum $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt8 $value" -tag $tag                        
                    }
                }
                -arpsrchwaddroffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 48 } {
                        set saoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt10 $value" -tag $tag                        
                    }                    
                }
                -offset -
                -infieldoffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 48 } {
                        set offset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt10 $value" -tag $tag                        
                    }                    
                }
                -operation -
                -arpoperation {
                    set trans [ string tolower $value ] 
                    set index [ lsearch -exact $EOperation $trans ]
Deputs "arp operation index: $index"
                    if { $index < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader4 $EOperation" -tag $tag                        
                    } else {
                        set operation [ incr index ]
                    }
                }
                -sourceprotocoladdr -
                -arpsrcprotocoladdr {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set srcProAddr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt12 $value" -tag $tag                        
                    }
                }
                -sourceprotocoladdrmode -
                -arpsrcprotocoladdrmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt13 $EType" -tag $tag                        
                    } else {
                        set srcProAddrMode $trans
                    }
                }
                -sourceprotocoladdrrepeatcount -
                -arpsrcprotocoladdrcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set srcProAddrCount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt14 $value" -tag $tag                        
                    }
                }
                -sourceprotocoladdrstep -
                -sourceprotocoladdrrepeatstep -
                -arpsrcprotocoladdrstep {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set srcProAddrStep $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt15 $value" -tag $tag                        
                    }
                }
                -arpsrcprotocoladdroffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 32 } {
                        set spoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt10 $value" -tag $tag                        
                    }                    
                }
                -destprotocoladdr -
                -arpdstprotocoladdr {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set dstProAddr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt16 $value" -tag $tag                        
                    }
                }
                -destprotocoladdrmode -
                -arpdstprotocoladdrmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt17 $EType" -tag $tag                        
                    } else {
                        set dstProAddrMode $trans
                    }
                }
                -destprotocoladdrstep -
                -destprotocoladdrrepeatstep -
                -arpdstprotocoladdrstep {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set dstProAddrStep $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt18 $value" -tag $tag                        
                    }
                }
                -destprotocoladdrrepeatcount -
                -arpdstprotocoladdrcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set dstProAddrCount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt19 $value" -tag $tag                        
                    }
                }
                -arpdstprotocoladdroffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 32 } {
                        set dpoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigARPPkt10 $value" -tag $tag                        
                    }                    
                }
                -hardwaretype -
                -hardwarecode {
                    if { [ lsearch -exact $EHwType [ string toupper $value ] ] < 0 } {
                        if { ![string is integer $value] } {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_DhcpClientConfigRouter14 $EEncapType" -tag $tag
                            return  $IxiaCapi::errorcode(1)
                        } else {
                            set hardwarecode $value
                        }
                    } else {
                        set hardwarecode $HwTypeArray([ string toupper $value])
Deputs "HardwareCode: $hardwarecode"
                    }                    
                }
            }
        }
Deputs Step10
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "ethernetarp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol ethernetARP"
        if { [ info exists da ] } {
            if { [ info exists daReCnt ] } {
                switch -exact $daReCnt {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $daReCnt
                        $pdu AddField dstHardwareAddress
                        $pdu AddFieldConfig $da"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists daNum ] && [ info exists daStep ] } {
            uplevel $level "
                            $pdu AddFieldMode $daReCnt
                            $pdu AddField dstHardwareAddress
                            $pdu AddFieldConfig \
                            [ list $daoffset $da $daNum $daStep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 arpdsthwaddrcount and arpdsthwaddrstep"\
                            -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            }
        }
    
        if { [ info exists sa ] } {
Deputs Step100
            if { [ info exists saReCnt ] } {
Deputs Step110
                switch -exact $saReCnt {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $saReCnt
                        $pdu AddField srcHardwareAddress
                        $pdu AddFieldConfig $sa"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists saNum ] && [ info exists saStep ] } {
            uplevel $level "
                            $pdu AddFieldMode $saReCnt
                            $pdu AddField srcHardwareAddress
                            $pdu AddFieldConfig [ list $saoffset $sa $saNum $saStep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 arpsrchwaddrcount and arpsrchwaddrstep"\
                            -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        if { [ info exists operation ] } {
            uplevel $level "
            $pdu AddField opCode
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $operation"
        }
        if { [ info exists srcProAddr ] } {
            if { [ info exists srcProAddrMode ] } {
                switch -exact $srcProAddrMode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $srcProAddrMode
                        $pdu AddField srcIP
                        $pdu AddFieldConfig $srcProAddr"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists srcProAddrCount ] && [ info exists srcProAddrStep ] } {
            uplevel $level "
                            $pdu AddFieldMode $srcProAddrMode
                            $pdu AddField srcIP
                            $pdu AddFieldConfig \
                            [ list $spoffset $srcProAddr $srcProAddrCount $srcProAddrStep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 arpsrcprotocoladdrcount and arpsrcprotocoladdrstep"\
                            -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            }
        }
    
        if { [ info exists dstProAddr ] } {
Deputs Step100
            if { [ info exists dstProAddrMode ] } {
Deputs Step110
                switch -exact $dstProAddrMode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $dstProAddrMode
                        $pdu AddField dstIP
                        $pdu AddFieldConfig $dstProAddr"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists dstProAddrCount ] && [ info exists dstProAddrStep ] } {
            uplevel $level "
                            $pdu AddFieldMode $dstProAddrMode
                            $pdu AddField dstIP
                            $pdu AddFieldConfig [ list $dpoffset $dstProAddr $dstProAddrCount $dstProAddrStep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 arpdstprotocoladdrcount and arpdstprotocoladdrstep"\
                            -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        if { [ info exists hardwarecode ] } {
            uplevel $level "
            $pdu AddField hardwareType
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hardwarecode"            
        }
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }


    body PacketBuilder::ConfigICMPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigICMPPkt [info script]"
Deputs "----- TAG: $tag -----"
        
        set EType [ list Fixed Random Incrementing Decrementing ]
        set EICMP [ list echo_request echo_reply destination_unreachable \
                   source_quench redirect time_exceeded parameter_problem \
                   timestamp_request timestamp_reply information_request \
                   information_reply router_advertisement router_solicitation \
                   addr_mask ]
        set EICMPNo [ list 8 0 3 4 5 11 12 13 14 15 16 9 10 17 ]
        set offset 0
        set idmode Fixed
        set idstep 1
        set seqmode Fixed
        set seqstep 1
        set level 2
        set typeNo 0
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -type -
                -icmptype {
                    set value [ string tolower $value ]
                    if { [ string is integer $value ] } {
                        set index [ lsearch -exact $EICMPNo $value ]
Deputs StepType
Deputs "index:$index\tval:$value"
                        if { $index < 0 } {
                            set typeoverride $value
                            #IxiaCapi::Logger::LogIn -type warn -message \
                            #"$IxiaCapi::s_PacketBuilderConfigICMPPkt2 $EICMPNo" -tag $tag                        
                        } else {
                            set type [ lindex $EICMP $index ]
                        }
                    } else {
                        set index [ lsearch -exact $EICMP $value ]
                        if { $index < 0 } {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigICMPPkt2 $EICMP" -tag $tag                        
                        } else {
                            set type [ lindex $EICMP $index ]
                        }
                    }
                    set typeNo [ lindex $EICMPNo $index ]
                }
                -code -
                -icmpcode {
                    if { [ catch { format %x $value } ] } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt3 $EType" -tag $tag                        
                    } else {
                        set code $value
                    }
                }
                -id -
                -icmpid -
                -identifier {
                    if { [ catch { format %x $value } ] } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt4 $EType" -tag $tag                        
                    } else {
                        set id $value
                    }
                }
                -idmode -
                -icmpidmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt5 $EType" -tag $tag                        
                    } else {
                        set idmode $trans
                    }
                }
                -idstep -
                -icmpidstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set idstep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt6 $value" -tag $tag                        
                    }
                }
                -idcount -
                -icmpidcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set idcount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt7 $value" -tag $tag                        
                    }
                }
                -offset -
                -infieldoffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 48 } {
                        set offset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt12 $value" -tag $tag                        
                    }                    
                }
                -seq -
                -icmpseq -
                -sequnum {
                    if { [ catch { format %x $value } ] } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt8 " -tag $tag                        
                    } else {
                        set seq [ format %i $value ]
                    }
                }
                -seqmode -
                -icmpseqmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt9 $EType" -tag $tag                        
                    } else {
                        set seqmode $trans
                    }
                }
                -seqstep -
                -icmpseqstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set seqstep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt10 $value" -tag $tag                        
                    }
                }
                -seqcount -
                -icmpseqcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set seqcount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt11 $value" -tag $tag                        
                    }
                }
                -autocrc -
                -flagchecksum -
                -icmpflagchecksum {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set autocrc $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt13 $trans" -tag $tag                        
                    }
                }
                -checksum -
                -icmpchecksum {
                    if { [ catch { format %x $value } ] == 0 } {
                        set checksum $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigICMPPkt14 $trans" -tag $tag                        
                    }
                }
            }
        }
Deputs Step10
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "icmp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
        #-----Config Type-----
        if { [ info exists typeNo ] } {
            switch $typeNo {
                3 -
                4 -
                5 -
                11 -
                12 {
                        uplevel $level "
                    $pdu SetProtocol icmpv1
                    $pdu ChangeType APP" ;# To add change type because the param 'type' is conflict with pdu ctor
                }
                0 -
                8 -
                13 -
                14 -
                15 -
                16 {
                        uplevel $level "
                    $pdu SetProtocol icmpv2
                    $pdu ChangeType APP" ;# To add change type because the param 'type' is conflict with pdu ctor
                }
                9 {
                        uplevel $level "
                    $pdu SetProtocol icmpv9
                    $pdu ChangeType APP" ;# To add change type because the param 'type' is conflict with pdu ctor                    
                }
            }
            uplevel $level "
            $pdu AddField messageType
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $typeNo"            
        }
        #--------------------------
        #-----Config Checksum-----
        set manCRC 1
        if { [ info exists autocrc ] } {
            if { $autocrc } {
            uplevel $level "
                $pdu AddField icmpChecksum 0 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
                set manCRC 0
            } 
        }
        if { [ info exists checksum ] } {
            if { $manCRC } {
            uplevel $level "
                $pdu AddField icmpChecksum
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $checksum"
            }
        }
        #--------------------------
        #-----Config ID-----
        if { [ info exists id ] } {
            if { [ info exists idmode ] } {
                switch -exact $idmode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $idmode
                        $pdu AddField identifier
                        $pdu AddFieldConfig $id"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists idcount ] && [ info exists idstep ] } {
            uplevel $level "
                            $pdu AddFieldMode $idmode
                            $pdu AddField identifier
                            $pdu AddFieldConfig [ list $offset $id $idcount $idstep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 icmpidcount and icmpidstep"\
                            -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        #--------------------------
        #-----Config Sequence-----
        if { [ info exists seq ] } {
            if { [ info exists seqmode ] } {
                switch -exact $seqmode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $seqmode
                        $pdu AddField sequenceNumber
                        $pdu AddFieldConfig $seq"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists seqcount ] && [ info exists seqstep ] } {
            uplevel $level "
                            $pdu AddFieldMode $seqmode
                            $pdu AddField sequenceNumber
                            $pdu AddFieldConfig [ list $offset $seq $seqcount $seqstep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 icmpseqcount and icmpseqstep"\
                            -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        #--------------------------
        #-----Config Code-----
        if { [ info exists code ] } {
            if { $typeNo == 3 } {
            uplevel $level "
                $pdu AddField destUnreachableCodeOptions
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $code"
            } else {
            uplevel $level "
                $pdu AddField codeValue
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $code"
            }
        }
        #--------------------------
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }


    body PacketBuilder::ConfigIGMPPkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigIGMPPkt [info script]"
Deputs "----- TAG: $tag -----"
Deputs "Args: $args"
        set EVersion [ list igmpv1 igmpv2 igmpv3 ]
        set EProType [ list \
            membershipreport \
            membershipquery \
            leavegroup \
         ]
        set EType [ list Fixed Random Incrementing Decrementing ]
        set ERecordType [ list MODE_IS_INCLUDE MODE_IS_EXCLUDE CHANGE_TO_INCLUDE_MODE\
                         CHANGE_TO_EXCLUDE_MODE ALLOW_NEW_SOURCES BLOCK_OLD_SOURCES ]

        set gastep 0.0.0.1
        set gamode Incrementing
		set gacount 1 
		set gastep 0.0.0.1

        set level 2
        set offset 0

        set version igmpv2
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
				    set value [::IxiaCapi::NamespaceDefine $value]
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
					
                        continue
                    } else {
                        set name $value
Deputs "name:$name"
                    }
                }
                -protocolver {
                    set trans [ string tolower $value ]
Deputs "igmp version: $trans"
                    if { [ lsearch -exact $EVersion $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt3 $EVersion" -tag $tag                        
                    } else {
                        set protocolver $trans
Deputs "version: $protocolver"
                    }
                }
                -protocoltype {
                    set trans [ string tolower $value ]
                    if { [ lsearch -exact $EProType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt3 $EProType" -tag $tag                        
                    } else {
                        set proType $trans
                    }
                }
                -groupaddr -
                -igmpgroupaddr -
                -groupstartip {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set ga $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt5 $value" -tag $tag                        
                    }
                }
                -groupaddressmode -
                -igmpgroupaddrmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt6 $EType" -tag $tag                        
                    } else {
                        set gamode $trans
                    }                    
                }
                -groupcount -
                -groupaddresscount -
                -igmpgroupaddrcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set gacount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt7 $value" -tag $tag                        
                    }                    
                }
                -groupaddrstep -
                -igmpgroupaddrstep -
                -increasestep {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set gastep $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt8 $value" -tag $tag                        
                    }
                }
                -checksum -
                -igmpchecksum {
                    if { [ catch { format %x $value } ] == 0 } {
                        set checksum $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt9 $trans" -tag $tag                        
                    }
                }
                -maxresponsetime -
                -igmpmaxresponsetime {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set responsetime $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt10 $value" -tag $tag                        
                    }                    
                }
                -sflag -
                -igmpsuppressflag -
                -suppressflag {
                    if { [ string is boolean $value ] && $value != "" } {
                        set sflag $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt11 $trans" -tag $tag                        
                    }                    
                }
                -qrv -
                -igmpqrv {
                    if { [ string is integer $value ] && $value < 8 } {
                        set rqv $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt12 $trans" -tag $tag                        
                    }                    
                }
                -qqic -
                -igmpqqic {
                    if { [ catch { format %x $value } ] == 0 } {
                        set qqic $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt13 $trans" -tag $tag                        
                    }
                }
                -igmpsourcenum -
                -sourcenum -
                -srcnum {
                    if { [ string is integer $value ] } {
                        set srcnum $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt14 $trans" -tag $tag                        
                    }                    
                }
                -groupnum -
                -igmpgroupnum {
                    if { [ string is integer $value ] } {
                        set groupnum $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt15 $trans" -tag $tag                        
                    }                    
                }
                -groupip -
                -multicastaddr -
                -igmpmulticastaddr {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set multicastaddr $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt16 $value" -tag $tag                        
                    }
                }
                -recordtype -
                -igmprecordtype {
                    set trans [ string toupper $value ]
                    set index [ lsearch -exact $ERecordType $trans ]
                    if { $index < 0 } {
                        if { [ string is integer $value ] && $value < 7 && $value > 0 } {
                            set recordtype $trans
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigIGMPPkt17 $ERecordType" -tag $tag
                        }
                    } else {
                        set recordtype [incr $index]
                    }
                }
                -auxiliarydatalen -
                -auxdatalen -
                -igmpauxdatalen -
                -igmpauxiliarydatalen -
                -auxlen {
                    if { [ string is integer $value ] } {
                        set auxlen $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt18 $trans" -tag $tag                        
                    }                    
                }
                -auxdata -
                -igmpauxdata {
                    if { [ catch { format %x $value } ] == 0 } {
                        set auxdata $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt19 $trans" -tag $tag                        
                    }
                }
                -sourceaddr -
                -igmpsourceaddr -
                -srcip1 {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set sa $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt20 $value" -tag $tag                        
                    }
                }
            }
        }
Deputs Step10
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        uplevel $level "
        $pdu ChangeType APP" ;# To add change type because the param 'type' is conflict with pdu ctor

        #-----Config ProtocolVer-----
Deputs Step15
        if { [ info exists protocolver ] } {
Deputs Step16
            switch $protocolver {
                igmpv1 -
                igmpv2 {
Deputs Step17
                        uplevel $level "
                    $pdu SetProtocol $protocolver"
                }
                igmpv3 {
                    if { [ info exists proType ] } {
                        switch $proType {
                            membershipreport {
                                uplevel $level "
                            $pdu SetProtocol igmpv3MembershipReport"                                
                            }
                            membershipquery {
                                uplevel $level "
                            $pdu SetProtocol igmpv3MembershipQuery"                                
                            }
                        }
                    } else {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_PacketBuilderConfigIGMPPkt2" -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                    }
                }
                default {
                    IxiaCapi::Logger::LogIn -type err -message \
                    "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                    return $IxiaCapi::errorcode(6)                        
                }
            }
        } else {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_PacketBuilderConfigIGMPPkt2" -tag $tag
                return $IxiaCapi::errorcode(3)                        
        }
Deputs Step20
        #--------------------------
        #-----Config ProtocolType-----
        if { [ info exists proType ] } {
            if { $protocolver != "igmpv3" } {
                if { $protocolver == "igmpv2" } {
                    switch $proType {
                        membershipreport {
                            set typeVal 22
                        }
                        membershipquery {
                            set typeVal 17
                        }
                        leavegroup {
                            set typeVal 23
                        }
                    }
                } else {
                        membershipreport {
                            set typeVal 18
                        }
                        membershipquery {
                            set typeVal 17
                        }
                }
                uplevel $level "
                    $pdu AddField type
                    $pdu AddFieldMode Fixed
                    $pdu AddFieldConfig $typeVal"
            }
        } else {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_PacketBuilderConfigIGMPPkt2" -tag $tag
                return $IxiaCapi::errorcode(3)                        
        }
Deputs Step30
        #--------------------------
        #-----Config Group Address-----
        if { [ info exists ga ] } {
            if { [ info exists gamode ] } {
                switch -exact $gamode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $gamode
                        $pdu AddField groupAddress 
                        $pdu AddFieldConfig $ga"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists gacount ] && [ info exists gastep ] } {
            uplevel $level "
                            $pdu AddFieldMode $gamode
                            $pdu AddField groupAddress 
                            $pdu AddFieldConfig [ list $offset $ga $gacount $gastep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 igmpgacount and igmpgastep"\
                            -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        #--------------------------
        #-----Config Checksum-----
        if { [ info exists checksum ] } {
            uplevel $level "
                $pdu AddField checksum
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $checksum"
        }
        #--------------------------
        #-----Config Max response time-----
        if { [ info exists responsetime ] } {
            uplevel $level "
                $pdu AddField maximumResponseTimeunits110Second 
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $responsetime"
        }
        #--------------------------
        #-----Config SFlag-----
        if { [ info exists sflag ] } {
            uplevel $level "
                $pdu AddField suppressRoutersideProcessingSflag 
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $sflag"
        }
        #--------------------------
        #-----Config RQV-----
        if { [ info exists rqv ] } {
            uplevel $level "
                $pdu AddField qrv 
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $rqv"
        }
        #--------------------------
        #-----Config QQIC-----
        if { [ info exists qqic ] } {
            uplevel $level "
                $pdu AddField qqic 
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $qqic"
        }
        #--------------------------
        #-----Config SrcNum-----
        if { [ info exists srcnum ] } {
            uplevel $level "
                $pdu AddField numberOfSources  
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $srcnum"
        }
        #--------------------------
        #-----Config Source Address-----
        if { [ info exists sa ] } {
            uplevel $level "
                $pdu AddField multicastSource  
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $sa"
        }
        #--------------------------
        #-----Config GroupReportNum-----
        if { [ info exists groupnum ] } {
            uplevel $level "
                $pdu AddField num_groups  
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $groupnum"
        }
        #--------------------------
        #-----Config Multicast Address-----
        if { [ info exists multicastaddr ] } {
            uplevel $level "
                $pdu AddField multicastAddress   
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $multicastaddr"
        }
        #--------------------------
        #-----Config Record Type-----
        if { [ info exists recordtype ] } {
            uplevel $level "
                $pdu AddField recordType   
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $recordtype"
        }
        #--------------------------
        #-----Config Aux data length-----
        if { [ info exists auxlen ] } {
            uplevel $level "
                $pdu AddField auxiliaryData.length   
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $auxlen"
        }
        #--------------------------
        #-----Config Aux data-----
        if { [ info exists auxdata ] } {
            uplevel $level "
                $pdu AddField auxiliaryData.data 
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $auxdata"
        }
        #--------------------------
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }


    body PacketBuilder::ConfigOSPFv2Pkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigOSPFv2Pkt [info script]"
Deputs "----- TAG: $tag -----"
        set EPktType [ list hellopkt ddpkt lsrequestpacket lsupdatepacket lsackpacket ]
        set level 2
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -packettype -
                -ospfv2packettype {
                    set trans [ string tolower $value ]
                    set index [ lsearch -exact $EPktType $trans ]
                    if { $index < 0 } {
                        if { [ string is integer $value ] && $value < 6 && $value > 0 } {
                            set pkttype $value
                        } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigOSPFPkt1 $EPktType" -tag $tag
                        }
                    } else {
                        set pkttype [incr $index]
                    }
                }
            }
        }
Deputs Step10
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "ospfv2" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol OSPFv2"
        #-----Config Packet Type-----
        if { [ info exists pkttype ] } {
            switch -exact -- $pkttype {
                1 {
                    uplevel $level "
                    $pdu AddField hello_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
                2 {
                    uplevel $level "
                    $pdu AddField dd_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
                3 {
                    uplevel $level "
                    $pdu AddField ls_request_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
                4 {
                    uplevel $level "
                    $pdu AddField ls_update_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
                5 {
                    uplevel $level "
                    $pdu AddField ls_ack_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
            }
        } else {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_PacketBuilderConfigOSPFPkt2" -tag $tag
                return $IxiaCapi::errorcode(3)                        
        }
        #--------------------------

        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }


    body PacketBuilder::ConfigOSPFv3Pkt { args } {
        
        global errorInfo
        set tag "body PacketBuilder::ConfigOSPFv3Pkt [info script]"
Deputs "----- TAG: $tag -----"
        set EPktType [ list hellopkt ddpkt lsrequestpacket lsupdatepacket lsackpacket ]
        set level 2
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -packettype -
                -ospfv3packettype {
                    set trans [ string tolower $value ]
                    set index [ lsearch -exact $EPktType $trans ]
                    if { $index < 0 } {
                        if { [ string is integer $value ] && $value < 6 && $value > 0 } {
                            set pkttype $value
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_PacketBuilderConfigOSPFPkt1 $EPktType" -tag $tag
                        }
                    } else {
                        set pkttype [incr $index]
                    }
                }
            }
        }
Deputs Step10
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "ospfv3" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol OSPFv3"
        #-----Config Packet Type-----
        if { [ info exists pkttype ] } {
            switch -exact -- $pkttype {
                1 {
                    uplevel $level "
                    $pdu AddField hello_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
                2 {
                    uplevel $level "
                    $pdu AddField dd_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
                3 {
                    uplevel $level "
                    $pdu AddField ls_request_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
                4 {
                    uplevel $level "
                    $pdu AddField ls_update_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
                5 {
                    uplevel $level "
                    $pdu AddField ls_ack_packet 1
                    $pdu AddFieldMode Reserved
                    $pdu AddFieldConfig 0"
                }
            }
        } else {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_PacketBuilderConfigOSPFPkt2" -tag $tag
                return $IxiaCapi::errorcode(3)                        
        }
        #--------------------------

        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }


    body PacketBuilder::ConfigGREPkt { args } {
         global errorInfo
        set tag "body PacketBuilder::ConfigGREPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -version -
                -greversion {
                    if { [ string is integer $value ] && $value < 8 } {
                        set version $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigGREPkt1" -tag $tag
                    }
                }
                -protocoltype -
                -greprotocoltype {
                    if { [ catch { format %x $value } ] == 0 } {
                        set type $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigGREPkt2 $trans" -tag $tag                        
                    }
                }
                -checksumpresent -
                -grechecksumpresent {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set checksump $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigGREPkt3 $trans" -tag $tag                        
                    }
                }
                -keypresent -
                -grekeypresent {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set keyp $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigGREPkt4 $trans" -tag $tag                        
                    }
                }
                -sequencepresent -
                -gresequencepresent {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set seqp $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigGREPkt5 $trans" -tag $tag                        
                    }
                }
                -checksum -
                -grechecksum {
                    foreach { reserved checksum } $value {
                        set cs_reserved $reserved
                        set cs_value $checksum
                    }
                }
                -key -
                -grekey {
                    if { [ catch { format %x $value } ] == 0 } {
                        set keyValue $value
Deputs "Key : $key "
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigGREPkt6 $trans" -tag $tag                        
                    }
                }
                -sequence -
                -gresequence {
                    if { [ catch { format %x $value } ] == 0 } {
                        set seq $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigGREPkt7 $trans" -tag $tag                        
                    }
                }
            }
        }
Deputs Step10
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "gre" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol GRE"
        #-----Config Version-----
        if { [ info exists version ] } {
            uplevel $level "
                $pdu AddField ver
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $version"
        }        
        #--------------------------
        #-----Config Protocol Type-----
        if { [ info exists type ] } {
            uplevel $level "
                $pdu AddField protocol_type
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $type"
        }        
        #--------------------------
        #-----Config Present-----
        if { [ info exists checksump ] } {
            uplevel $level "
                $pdu AddField checksum 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
        }        
        if { [ info exists keyp ] } {
            uplevel $level "
                $pdu AddField key 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
        }        
        if { [ info exists seqp ] } {
            uplevel $level "
                $pdu AddField sequence_number 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
        }        
        #--------------------------
        #-----Config Checksum-----
        if { [ info exists cs_reserved ] } {
            uplevel $level "
                $pdu AddField reserved1
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $cs_reserved"
        }
        if { [ info exists cs_value ] } {
            uplevel $level "
                $pdu AddField checksum_value
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $cs_value"
        }
        #--------------------------
        #-----Config Key-----
        if { [ info exists keyValue ] } {
            uplevel $level "
                $pdu AddField key
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $keyValue"
        }        
        #--------------------------
        #-----Config Sequence Number-----
        if { [ info exists seq ] } {
            uplevel $level "
                $pdu AddField sequence_number
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $seq"
        }        
        #--------------------------

        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }
    body PacketBuilder::ConfigPIMPkt { args } {
        global errorInfo
        set tag "body PacketBuilder::ConfigPIMPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2
        set EType [ list hello register register_stop join_prune \
                   bootstrap assert graft graft_ack candidate_rp  ]
        set OpType [ list ]
        set OpLen  [ list ]
        set OpValue [ list ]
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -type -
                -pimtype {
                    set trans [ string tolower $value ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigPIMPkt1 $EType" -tag $tag                        
                    } else {
                        set type $trans
                    }                    
                }
                -version -
                -pimversion {
                    if { [ string is integer $value ] && $value < 16 } {
                        set version $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigPIMPkt2" -tag $tag                        
                    }
                }
                -reserved -
                -pimreserved {
                    if { [ catch { format %x $value } ] == 0 } {
                        set reserved $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_PacketBuilderConfigPIMPkt3 $trans" -tag $tag                        
                    }
                }
                -pimoptiontype -
                -optiontype {
                    lappend OpType $value
                }
                -pimoptionlength -
                -optionlength {
                    lappend OpLen $value
                }
                -pimoptionvalue -
                -optionvalue {
                    lappend OpValue $value
                }
            }
        }
Deputs Step10
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "pim" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol PIM
        $pdu ChangeType APP" ;# To add change type because the param 'type' is conflict with pdu ctor
        #-----Config Protocol Type-----
        if { [ info exists type ] } {
            uplevel $level "
                $pdu AddField $type 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
        }        
        #--------------------------
        #-----Config Version-----
        if { [ info exists version ] } {
            uplevel $level "
                $pdu AddField pim_version
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $version"
        }        
        #--------------------------
        #-----Config Reserved Byte-----
        if { [ info exists reserved ] } {
            uplevel $level "
                $pdu AddField reserved_byte 
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $reserved"
        }        
        #--------------------------
        #-----Config Hello Option-----
        #if { [ llength $OpType ] > 0 } {
        #    # Check the validity of type list and len list as well as value list
        #    if { [ llength $OpType ] != [ llength $OpLen ] || \
        #        [ llength $OpLen ] != [ llength $OpValue ] } {
        #        IxiaCapi::Logger::LogIn -type err -message \
        #        "$IxiaCapi::s_PacketBuilderConfigPIMPkt4" -tag $tag
        #        return $IxiaCapi::errorcode(3)                        
        #    }
        #    foreach optype $OpType oplen $OpLen opval $OpValue {
        #        if { [ string is integer $optype ] == 0 } {
        #            IxiaCapi::Logger::LogIn -type warn -message \
        #            "$IxiaCapi::s_PacketBuilderConfigPIMPkt5 $optype" -tag $tag                        
        #            continue                           
        #        }
        #        if { [ string is integer $oplen ] == 0 } {
        #            IxiaCapi::Logger::LogIn -type warn -message \
        #            "$IxiaCapi::s_PacketBuilderConfigPIMPkt5 $optype" -tag $tag                        
        #            continue                           
        #        }
        #        if { [ string is integer $opval ] == 0 } {
        #            IxiaCapi::Logger::LogIn -type warn -message \
        #            "$IxiaCapi::s_PacketBuilderConfigPIMPkt5 $optype" -tag $tag                        
        #            continue                           
        #        }
        #    }
        #    uplevel $level "
        #        $pdu AddField reserved_byte 
        #        $pdu AddFieldMode Fixed
        #        $pdu AddFieldConfig $reserved"
        #}        
        #--------------------------

        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }
    body PacketBuilder::ConfigPPPoEPkt { args } {
        global errorInfo
        set tag "body PacketBuilder::ConfigPPPoEPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 2
        set EType [ list pppoe_discovery pppoe_session  ]
        set EDiscoveryCode [ list PADO PADI PADR PADS PADT ]
        set EDiscoveryCodeValue [ list 0x07 0x09 0x19 0x65 0xa7 ]
        set ETag [ list servicename \
                        acname \
                        hostuniq \
                        accookie \
                        relaysessionid \
                        servicenameerror \
                        acsystemerror \
                        genericerror \
                        endoflist \
                         ]
        set tag [ list ]
        set taglen [ list ]
        set tagval [ list ]
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name [::IxiaCapi::NamespaceDefine $value]
Deputs "name:$name"
                    }
                }
                -pppoetype {
                    set trans [ string tolower $value ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigPPPoEheader2 $EType" -tag $tag                        
                    } else {
                        set ppptype $trans
                    }                    
                }
                -version -
                -pppoeversion {
                    if { [ string is integer $value ] && $value < 16 } {
                        set version $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigPPPoEheader3" -tag $tag                        
                    }
                }
                -code -
                -pppoecode {
                    set code $value
                }
                -type {
                    if { [ string is integer $value ] && $value < 16 } {
                        set type $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigPPPoEheader6" -tag $tag                        
                    }                   
                }
                -sessionid -
                -pppoesessionid {
                    if { [ string is integer $value ] } {
                        set sessionid $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigPPPoEheader7" -tag $tag                        
                    }                   
                }
                -length -
                -pppoelength {
                    if { [ string is integer $value ] } {
                        set len $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigPPPoEheader8" -tag $tag                        
                    }                   
                }
                -tag -
                -pppoetag {
                    lappend tag [ string tolower $value ]
                }
                -taglength -
                -pppoetaglength {
                    lappend taglen $value
                }
                -tagvalue -
                -pppoetagvalue {
                    lappend tagval $value
                }
            }
        }
Deputs Step10
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "pppoe" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu ChangeType APP" ;# To add change type because the param 'type' is conflict with pdu ctor
        #-----Config Protocol Type-----
        if { [ info exists ppptype ] } {
            if { $ppptype == "pppoe_discovery" } {
                    uplevel $level "
                $pdu SetProtocol PPPoE_Discovery"
            } else {
                    uplevel $level "
                $pdu SetProtocol PPPoE_Session"
            }
        } else {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigPPPoEheader1" -tag $tag
            return $IxiaCapi::errorcode(3)                        
        }
        #--------------------------
        #-----Config Version-----
        if { [ info exists version ] } {
            uplevel $level "
                $pdu AddField version
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $version"
        }        
        #--------------------------
        #-----Config Code-----
        if { [ info exists code ] } {
            if { $ppptype == "pppoe_discovery" } {
                set index [ lsearch -exact $EDiscoveryCode $code ] 
                if { $index >= 0 } {
                    set code [ lindex $EDiscoveryCodeValue $index ]
                    uplevel $level "
                        $pdu AddField code 
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $code"
                } else {
                    IxiaCapi::Logger::LogIn -type warn -message \
                    "$IxiaCapi::s_HeaderCreatorConfigPPPoEheader4 $EDiscoveryCode" -tag $tag
                }
            } else {
                if { [ string is integer $code ] } {
                    uplevel $level "
                        $pdu AddField code0
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $code"
                } else {
                    IxiaCapi::Logger::LogIn -type warn -message \
                    "$IxiaCapi::s_HeaderCreatorConfigPPPoEheader5" -tag $tag
                }
            }
        }        
        #--------------------------
        #-----Config Type-----
        if { [ info exists type ] } {
            uplevel $level "
                $pdu AddField type
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $type"
        }        
        #--------------------------
        #-----Config Session ID-----
        if { [ info exists sessionid ] } {
            uplevel $level "
                $pdu AddField sessionid
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $sessionid"
        }        
        #--------------------------
        #-----Config Length-----
        if { [ info exists len ] } {
            uplevel $level "
                $pdu AddField ppp_length
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $len"
        }        
        #--------------------------
        #-----Config TAG-----
        foreach tag0 $tag {
            switch -exact -- $tag0 {
                servicename {
                    # sn_type tag_length ascii_tag_value
                    uplevel $level "
                        $pdu AddField Service-Name 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                }
                acname {
                    uplevel $level "
                        $pdu AddField AC-Name 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                }
                hostuniq {
                    uplevel $level "
                        $pdu AddField Host-Uniq 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                } 
                accookie {
                    uplevel $level "
                        $pdu AddField AC-Cookie 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                }
                relaysessionid {
                    uplevel $level "
                        $pdu AddField Relay-Session-Id 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                }
                servicenameerror {
                    uplevel $level "
                        $pdu AddField Service-Name-Error 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                }
                acsystemerror {
                    uplevel $level "
                        $pdu AddField AC-System-Error 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                }
                genericerror {
                    uplevel $level "
                        $pdu AddField Generic-Error 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                }
                endoflist {
                    uplevel $level "
                        $pdu AddField End-Of-List 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        "
                }
            }
        }
        foreach tag0 $tag taglen0 $taglen tagval0 $tagval {
Deputs "Tag: $tag0\tLength: $taglen\tValue: $tagval"
            switch -exact -- $tag0 {
                servicename {
                    # sn_type tag_length ascii_tag_value
                    uplevel $level "
                        $pdu AddField sn_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0
                        $pdu AddField ascii_tag_value
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $tagval0"
                }
                acname {
                    uplevel $level "
                        $pdu AddField acn_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0
                        $pdu AddField ascii_tag_value
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $tagval0"
                }
                hostuniq {
                    uplevel $level "
                        $pdu AddField hu_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0
                        $pdu AddField tag_value
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $tagval0"
                } 
                accookie {
                    uplevel $level "
                        $pdu AddField acc_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0
                        $pdu AddField tag_value
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $tagval0"
                }
                relaysessionid {
                    uplevel $level "
                        $pdu AddField rsi_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0
                        $pdu AddField tag_value
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $tagval0"
                }
                servicenameerror {
                    uplevel $level "
                        $pdu AddField sne_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0
                        $pdu AddField ascii_tag_value
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $tagval0"
                }
                acsystemerror {
                    uplevel $level "
                        $pdu AddField acse_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0
                        $pdu AddField ascii_tag_value
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $tagval0"
                }
                genericerror {
                    uplevel $level "
                        $pdu AddField ge_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0
                        $pdu AddField ascii_tag_value
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $tagval0"
                }
                endoflist {
                    uplevel $level "
                        $pdu AddField eol_type 0 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0
                        $pdu AddField tag_length
                        $pdu AddFieldMode Fixed
                        $pdu AddFieldConfig $taglen0"
                }
            }
        }
        #--------------------------

        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
            return $IxiaCapi::errorcode(1)                        
        }
    }
    body PacketBuilder::ConfigCustomPkt { args } {
        global errorInfo
        set tag "body PacketBuilder::ConfigCustomPkt [info script]"
Deputs "----- TAG: $tag -----"
        set level 1
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
					    set name [::IxiaCapi::NamespaceDefine $value]
                        
Deputs "name:$name"
                    }
                }
                -hexstring {
                    if { [ regexp -nocase {(0x)?([a-f0-9]+)} $value match x hex ] == 0 } {
                        unset hex                    
					} 
                }
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        if { [ info exists hex ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_PacketBuilderConfigCustomPkt1" -tag $tag
                        return $IxiaCapi::errorcode(3)                        
        }
        set pdu "$name"
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "custom" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
            return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol custom"
        if { [ info exists hex ] } {
            uplevel $level "
            $pdu AddField length
            $pdu AddFieldMode Commit
            $pdu AddFieldConfig [expr [string length $hex] * 4]
            $pdu AddField data
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hex"
        }
		$pdu SetRaw $hex
        return $IxiaCapi::errorcode(0)                        
    }
}

