# IxNetHeaderCreator.tcl --
#   This file implements the HeaderCreator class for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1

namespace eval IxiaCapi {
    class HeaderCreator {
        constructor { } {
            set pduList [ list ]
			return $this
        }
        method CreateHeader { args } {}
		method CreateCustomHeader { args } {}
		method ConfigCustomHeader { args } {}
        method CreateEthHeader { args } {}
        method ConfigEthHeader { args } {}
        method CreateVlanHeader { args } {}
        method ConfigVlanHeader { args } {}
        method CreateIPV4Header { args } {}
        method ConfigIPV4Header { args } {}
        method CreateTCPHeader { args } {}
        method ConfigTCPHeader { args } {}
        method CreateUDPHeader { args } {}
        method ConfigUDPHeader { args } {}
        method CreateMPLSHeader { args } {}
        method ConfigMPLSHeader { args } {}
        method CreateIPV6Header { args } {}
        method ConfigIPV6Header { args } {}
        method CreateIPV6ExtHeader { args } {}
        method ConfigIPV6ExtHeader { args } {}
        destructor { DestroyPdu }
        method DestroyPdu { args } {}
        protected variable pduList
    }
    
    
    body HeaderCreator::CreateHeader { args } {
        global IxiaCapi::fail IxiaCapi::success
        global errorInfo
        global IxiaCapi::TrafficManager
		
        set tag "body HeaderCreator::CreateHeader [info script]"
		Deputs "----- TAG: $tag -----"
		
        set level 2
        set type APP
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    #if { [ IxiaCapi::Regexer::ObjectExist \
                    #      $IxiaCapi::ObjectNamespace$value ] == 0 } {
                        #set name $value
					set name [::IxiaCapi::NamespaceDefine $value]
                    #} else {
                    #    IxiaCapi::Logger::LogIn -type err -message \
                    #    "$IxiaCapi::s_HeaderCreatorCreateheader1 $value" -tag $tag
                    #    return $fail                 
                    #}
                }
                -protocol  -
                -pro {
                    set pro $value
                }
                -type {
                    set type $value
                }
            }
        }

		Deputs "Args: $args"
        # if {$pro == "custom" } {
		    # set type "raw"
		# }
        if { [ info exists name ] } {
            if { [ catch {
                set command "IxiaCapi::Pdu $name $pro $type"
				Deputs "CMD:$command"
                #namespace inscope $IxiaCapi::ObjectNamespace $command
                set relpdu [uplevel $level " eval $command "]
				Deputs "relpdu: $relpdu"
            } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
            } else {
                TrafficManager AddPdu $relpdu
                lappend pduList $relpdu
            }
        } else {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_common1 $IxiaCapi::s_HeaderCreatorCreateheader2"\
            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
        }
        IxiaCapi::Logger::LogIn -message \
       "$IxiaCapi::s_HeaderCreatorCreateheader3 $pro $name"

        return $IxiaCapi::errorcode(0)                        
    }
    
    body HeaderCreator::DestroyPdu { args } {
        global IxiaCapi::fail IxiaCapi::success
        global errorInfo
        global IxiaCapi::TrafficManager

        set tag "body HeaderCreator::DestroyPdu [info script]"
Deputs "----- TAG: $tag -----"
        set level 1
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
                    #set name $value
					#set name [ IxiaCapi::NamespaceConvert $value $pduList ]
					set name [::IxiaCapi::NamespaceDefine $value]
                }
            }
        }
        if { [ info exists name ] == 0 } {
            set name $pduList
        }
        set exist 0
        foreach pdu $name {
            if { [ catch {
                uplevel $level "$pdu isa Pdu"
            } ] } {
#Deputs "$errorInfo"
                continue
            }
            set index [ lsearch -exact $pduList $pdu ]
Deputs "Index: $index"
            if { $index < 0 } {
        IxiaCapi::Logger::LogIn -type err -message \
       "$IxiaCapi::s_HeaderCreatorDestroyPdu1 $pdu"
                return $IxiaCapi::errorcode(6)                    
            }
            set pduList [ lreplace $pduList $index $index ]
            if { [ catch {
Deputs "Pdu list: $pduList "
                TrafficManager DeletePdu $name
            } ] } {
#Deputs "$errorInfo"
                continue
            } else {
                set exist 1
            }
        }
        if { $exist } {
            return $IxiaCapi::errorcode(0)
        } else {
Deputs "No pdu deleted..."
            return $IxiaCapi::errorcode(4)
        }
    }
	
	body HeaderCreator::CreateCustomHeader { args } {
        global IxiaCapi::fail IxiaCapi::success
        set resultCreate    [ eval {CreateHeader -pro custom -type APP} $args ]
Deputs "Result of Creation : $resultCreate"
        set resultConfig    [ eval ConfigCustomHeader $args ]
Deputs "Result of Config : $resultConfig"
        if { $resultCreate == $success \
            && $resultConfig <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
	
	body HeaderCreator::ConfigCustomHeader { args } {
        global errorInfo
        set tag "body HeaderCreator::ConfigCustomHeader [info script]"
Deputs "----- TAG: $tag -----"
        
       

        set level 2
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
                -pattern -
                -hexstring {
                   set pattern $value
                    
                }               
            }
        }
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
        set pdu "$name"
#        $pdu Clear
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        set pro [ string tolower $pro ]
        if { $pro != "custom" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol custom "
		
		if { [ info exists pattern ] } {
			# if { [ string first 0x $pattern  ] >= 0 } {
				# string replace $pattern 0 1
			# }
			if { [ regexp -nocase {(0x)?([a-f0-9]+)} $pattern match x hex ] == 0 } {
                        unset hex                    
					} 
			set pduLen [expr [string length $pattern] * 4]
			$pdu AddField length
			$pdu AddFieldMode Fixed
			$pdu AddFieldConfig $pduLen
			$pdu AddField data
			$pdu AddFieldMode Fixed
			$pdu AddFieldConfig $hex
			$pdu SetRaw $hex
	   }

        
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
                        return $IxiaCapi::errorcode(1)                        
        }
    }
	
    body HeaderCreator::CreateEthHeader { args } {
        global IxiaCapi::fail IxiaCapi::success
		
        set resultCreate    [ eval {CreateHeader -pro Ethernet -type SET} $args ]
		Deputs "Result of Creation : $resultCreate"
        set resultConfig    [ eval ConfigEthHeader $args ]
		Deputs "Result of Config : $resultConfig"
        if { $resultCreate == $success \
            && $resultConfig <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    
    body HeaderCreator::ConfigEthHeader { args } {
        global errorInfo
        set tag "body HeaderCreator::ConfigEthHeader [info script]"
Deputs "----- TAG: $tag -----"
        
        set EType [ list Fixed Random Incrementing Decrementing ]
        set EEthType [ list ipv4 ipv6 arp mplsunicast mplsmulticast rarp ]
        set EEthTypeVal [ list 0x0800 0x86dd 0x0806 0x8847 0x8848 0x8035 ]
        set offset 0 ;#obsolete
        set daoffset 0
        set saoffset 0
        set daReCnt Fixed
        set saReCnt Fixed
        set daStep 1
        set saStep 1
        #set ether_type "auto"
        set sa "00:00:00:00:00:01"
        set EtherTypeMode Fixed
        set level 2
# param collection        
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -name -
                -pduname {
				    set value [::IxiaCapi::NamespaceDefine $value]
				    #set value [ IxiaCapi::NamespaceConvert $value $pduList ]
                    if { [ IxiaCapi::TrafficManager GetPduIndex $value ] < 0 } {
                        continue
                    } else {
                        set name $value
						
Deputs "name:$name"
                    }
                }
                -da -
                -ethdst -
                -ethdstmac {
                    set value [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set da $value
                    } else {
Deputs "wrong mac addr: $value"
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader1 $value" -tag $tag                        
                    }
                }
                -damode -
                -darepeatcounter -
                -ethdstmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader4 $EType" -tag $tag                        
                    } else {
                        set daReCnt $trans
                    }
                }
                -numda -
                -darepeatcount -
                -ethdstcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set daNum $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader6 $value" -tag $tag                        
                    }
                }
                -dstoffset -
                -ethdstoffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 48 } {
                        set daoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader9 $value" -tag $tag                        
                    }                    
                }
                -dastep -
                -ethdststep {
                    set value [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set daStep $value
                    } else {
                        set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                        if { [ string is integer $trans ] } {
                            set daStep $trans
                            set daStep [ IxiaCapi::Regexer::GetMacStep $daoffset $daStep ]
Deputs "daStep:$daStep"
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigEthheader5 $value" -tag $tag                        
                        }
                    }
                }
                -sa -
                -ethsrc -
                -ethsrcmac {
                    set value [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set sa $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader2 $value" -tag $tag                        
                    }
                }
                -sarepeatcounter -
                -samode -
                -ethsrcmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader4 $EType" -tag $tag                        
                    } else {
                        set saReCnt $trans
                    }
                }
                -sarepeatcount -
                -numsa -
                -ethsrccount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set saNum $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader6 $value" -tag $tag                        
                    }
                }
                -srcoffset -
                -ethsrcoffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 48 } {
                        set saoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader9 $value" -tag $tag                        
                    }                    
                }
                -sastep -
                -ethsrcstep {
                    set value [ IxiaCapi::Regexer::MacTrans $value ]
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                            set saStep $value
                    } else {
                        set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                        if { [ string is integer $trans ] } {
                            set saStep $trans
                            set saStep [ IxiaCapi::Regexer::GetMacStep $saoffset $saStep ]
Deputs "saStep:$saStep"
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigEthheader5 $value" -tag $tag                        
                        }
                    }
                }
                -offset -
                -infieldoffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 48 } {
                        set offset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader9 $value" -tag $tag                        
                    }                    
                }
                -minda -
                -ethdstmacmin {
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set minda $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader10 $value" -tag $tag                        
                    }
                }
                -maxda -
                -ethdstmacmax {
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set maxda $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader11 $value" -tag $tag                        
                    }
                }
                -minsa -
                -ethsrcmacmin {
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set minsa $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader12 $value" -tag $tag                        
                    }
                }
                -maxsa -
                -ethsrcmacmax {
                    if { [ IxiaCapi::Regexer::IsMacAddress $value ] } {
                        set maxsa $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader13 $value" -tag $tag                        
                    }
                }               
                -ethtype -
                -ethertype {

                    if { [ string tolower $value ] == "auto" } {

                        set ether_type "auto"
                    } else {
                        set ether_type $value
                        
                    }
					Deputs "ether_type: $value"
                }
                -ethertypemode -
                -ethtypemode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader4 $EType" -tag $tag                        
                    } else {
                        set EtherTypeMode $trans
                    }
                }
                -ethertypestep -
                -ethtypestep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set EtherTypeStep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader5 $value" -tag $tag                        
                    }
                }
                -ethertypecount -
                -ethtypecount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set EtherTypeCount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigEthheader6 $value" -tag $tag                        
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
        if { $pro != "ethernet" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }
        uplevel $level " $pdu SetProtocol Ethernet "

        if { [ info exists da ] } {

            if { [ info exists daReCnt ] } {

                switch -exact $daReCnt {
                    Fixed {

            uplevel $level "
                        $pdu AddFieldMode $daReCnt
                        $pdu AddField destinationAddress
                        $pdu AddFieldConfig $da
                        "
Deputs "Mode:$daReCnt\tValue:$da"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists daNum ] && [ info exists daStep ] } {

                        uplevel $level "
                            $pdu AddFieldMode $daReCnt
                            $pdu AddField destinationAddress
                            $pdu AddFieldConfig \
                            [ list $daoffset $da $daNum $daStep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 ethdstcount and ethdststep"\
                            -tag $tag
                    return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            }
        }
        if { [ info exists sa ] } {

            if { [ info exists saReCnt ] } {

                switch -exact $saReCnt {
                    Fixed {
                uplevel $level "
                        $pdu AddFieldMode $saReCnt
                        $pdu AddField sourceAddress
                        $pdu AddFieldConfig $sa
                        "
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists saNum ] && [ info exists saStep ] } {
                uplevel $level "
                            $pdu AddFieldMode $saReCnt
                            $pdu AddField sourceAddress
                            $pdu AddFieldConfig [ list $saoffset $sa $saNum $saStep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 ethsrccount and ethsrcstep"\
                            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        if { [ info exists ether_type ] } {

            if { $ether_type == "auto" } {
            uplevel $level "
                $pdu AddField etherType 0 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"                
            } else {
                if { [ info exists EtherTypeMode ] } {

                    switch -exact $EtherTypeMode {
                        Fixed {
                    uplevel $level "
                            $pdu AddFieldMode $EtherTypeMode
                            $pdu AddField etherType
                            $pdu AddFieldConfig $ether_type
                            "
                        }
                        Decrementing -
                        Incrementing {
                            if { [ info exists EtherTypeCount ] && [ info exists EtherTypeStep ] } {
                    uplevel $level "
                                $pdu AddFieldMode $EtherTypeMode
                                $pdu AddField etherType
                                $pdu AddFieldConfig [ list 0 $ether_type $EtherTypeCount $EtherTypeStep ]
                                "
                            } else {
                                IxiaCapi::Logger::LogIn -type err -message \
                                "$IxiaCapi::s_common2 EtherTypeCount and EtherTypeStep"\
                                -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                            }
                        }
                    }
                } else {
                    uplevel $level "
                            $pdu AddFieldMode Fixed
                            $pdu AddField etherType
                            $pdu AddFieldConfig $ether_type"
                }
            }
        }
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
Deputs "No configuration..."
            return $IxiaCapi::errorcode(1)
        }
    }

    body HeaderCreator::CreateVlanHeader { args } {
        global IxiaCapi::fail IxiaCapi::success
        set resultCreate [ eval {CreateHeader -pro vlan -type APP} $args ]
        set resultConfigVlan    [ eval ConfigVlanHeader $args ]
        if { $resultCreate == $success \
            && $resultConfigVlan <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    
    body HeaderCreator::ConfigVlanHeader { args } {
        global errorInfo
        set tag "body HeaderCreator::ConfigVlanHeader [info script]"
Deputs "----- TAG: $tag -----"
        
        set EType [ list Fixed Incrementing Decrementing ]
        set EVlanType [ list 0x8100 0x9100 0x88a8 0x9200 ]
        set offset 0
        set vlanMode Fixed
        set vlanStep 1

        set level 2
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
                -id -
                -vlanid {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set vlanId $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader2 $trans" -tag $tag                                                
                    }
                }
                -vlanmode -
                -mode -
                -vlanidmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader5 $EType" -tag $tag                        
                    } else {
                        set vlanMode $trans
                    }
                }
                -minid -
                -vlanidmin {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set minId $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader2 $trans" -tag $tag                                                
                    }
                }
                -maxid -
                -vlanidmax {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set maxId $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader2 $trans" -tag $tag                                                
                    }
                }
                -repeat -
                -vlanrepeat -
                -vlanidcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set vlanRepeat $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader6 $trans" -tag $tag                                                
                    }                   
                }
                -vlanstep -
                -step -
                -vlanidstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set vlanStep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader7 $trans" -tag $tag                                                
                    }                   
                    
                }
                -userpriority -
                -userprior -
                -vlanuserpriority {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 8 } {
                        set userPrior $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader3 $trans" -tag $tag                                                
                    }
                }
                -cfi -
                -vlancfi {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 2 } {
                        set cfi $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader4 $trans" -tag $tag                                                
                    }
                }
                -protocoltagid -
                -vlantypeid -
                -vlantype {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set vlanprotocol $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigVlanheader8 $EVlanType"\
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
#        $pdu Clear
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "vlan" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol Vlan "

        #-----Config Vlan ID ------
        if { [ info exists vlanId ] } {
            if { [ info exists vlanMode ] } {
Deputs Step10
                switch -exact $vlanMode {
                    Fix -
                    Fixed {
            uplevel $level "
                        $pdu AddField vlanID
                        $pdu AddFieldMode $vlanMode
                        $pdu AddFieldConfig $vlanId
                        "
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists vlanRepeat ] && [ info exists vlanStep ] } {
            uplevel $level "
                            $pdu AddField vlanID
                            $pdu AddFieldMode $vlanMode
                            $pdu AddFieldConfig \
                            [ list $offset $vlanId $vlanRepeat $vlanStep ]
                            "
                        }
                    }
                }
            }
        }
        #--------------------------
        #-----Config Vlan User Priority-----
        if { [ info exists userPrior ] } {
            uplevel $level "
            $pdu AddField vlanUserPriority
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $userPrior"
        }
        #--------------------------
        #-----Config Protocol ID-----
        if { [ info exists vlanprotocol ] } {
            uplevel $level "
            $pdu AddField protocolID
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $vlanprotocol"
        }
        #--------------------------
        #-----Config Vlan CFI-----
        if { [ info exists cfi ] } {
            uplevel $level "
            $pdu AddField cfi
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $cfi"
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
    body HeaderCreator::CreateIPV4Header { args } {
	    set tag "body HeaderCreator::CreateIPV4Header [info script]"
Deputs "----- TAG: $tag -----"
        global IxiaCapi::fail IxiaCapi::success
        set resultCreate    [ eval {CreateHeader -pro IPv4} $args ]
        set resultConfig    [ eval ConfigIPV4Header $args ]
        if { $resultCreate == $success \
            && $resultConfig <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    
    body HeaderCreator::ConfigIPV4Header { args } {
        global errorInfo
        set tag "body HeaderCreator::ConfigIPV4Header [info script]"
Deputs "----- TAG: $tag -----"
        
        set EType [ list Fixed Random Incrementing Decrementing ]
        set EPrecedence [ list routine priority immediate flash \
                         "flash_override" "critical" "internetwork_control"\
                         "network_control" ]
        set EDelay [ list normaldelay lowdelay ]
        set EThru [ list normalthruput highthruput ]
        set ERely [ list normalreliability highreliability ]
        set ECost [ list normalcost lowcost ]
        set EFrag [ list may donot ]
        set ELastFrag [ list last more ]
        set EQos [ list tos dscp ]
        
        set tcp 6
        set udp 17
        set icmp 1
        
        set offset 0 ;#obsolete
        set saoffset 0
        set daoffset 0
        set samode Fixed
        set damode Fixed
        set saStep 1
        set daStep 1
        set ipprotocol "auto"
        set ipprotocolmode Fixed
        
        set level 2

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
                -precedence -
                -ipprecedence {
                    if { [ string is integer $value ] && $value < 8 } {
                        set precedence $value
                    } elseif { [ catch { format %x $value } ] == 0 } {
Deputs "precedence:$value"
                        set precedence $value
                    } else {
                        set index [ lsearch -exact $EPrecedence [ string tolower $value ] ]
                        if { $index < 0 } {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header2 $EPrecedence" -tag $tag                        
                        } else {
                            set precedence $index
                        }
                    }
                }
                -delay -
                -ipdelay {
                    if { $value == 0 || $value == 1 } {
                        set delay $value
                    } else {
                        set index [ lsearch -exact $EDelay [ string tolower $value ] ]
                        if { $index < 0 } {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header3 $EDelay" -tag $tag                        
                        } else {
                            set delay $index
                        }
                    }
                }
                -throughput -
                -ipthroughput {
                    if { $value == 0 || $value == 1 } {
                        set throughput $value
                    } else {
                        set index [ lsearch -exact $EThru [ string tolower $value ] ]
                        if { $index < 0 } {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header4 $EThru" -tag $tag                        
                        } else {
                            set throughput $index
                        }
                    }
                }
                -reliability -
                -ipreliability {
                    if { $value == 0 || $value == 1 } {
                        set rely $value
                    } else {
                        set index [ lsearch -exact $ERely [ string tolower $value ] ]
                        if { $index < 0 } {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header5 $ERely" -tag $tag                        
                        } else {
                            set rely $index
                        }
                    }
                }
                -cost -
                -ipcost {
                    if { $value == 0 || $value == 1 } {
                        set cost $value
                    } else {
                        set index [ lsearch -exact $ECost [ string tolower $value ] ]
                        if { $index < 0 } {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header22 $ERely" -tag $tag                        
                        } else {
                            set cost $index
                        }
                    }
                }
                -identifier -
                -ipidentifier {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set identifier $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header10 $trans" -tag $tag                        
                    }                    
                }
                -reserved -
                -ipreserved {
                    if { [ string is boolean $value ] && $value != "" } {
                        set reserved $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header19 $trans" -tag $tag                        
                    }                    
                }
                -totallength -
                -iptotallength {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set totallen $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header9 $trans" -tag $tag                        
                    }
                }
                -lengthoverride -
                -iplengthoverride {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set lencover $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header8 $trans" -tag $tag                        
                    }
                }
                -fragment -
                -ipfragment {
                    if { $value == 0 || $value == 1 } {
                        set frag $value
                    } else {
                        set index [ lsearch -exact $EFrag [ string tolower $value ] ]
                        if { $index < 0 } {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header6 $EFrag" -tag $tag                        
                        } else {
                            set frag $index
                        }                        
                    }                    
                }
                -lastfragment -
                -iplastfragment {
                    if { $value == 0 || $value == "false" } {
                        set lastfrag 0
                    } elseif { $value == 1 || $value == "true" } {
					    set lastfrag 1
					} else {
                        set index [ lsearch -exact $ELastFrag [ string tolower $value ] ]
                        if { $index < 0 } {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header7 $ELastFrag" -tag $tag                        
                        } else {
                            set lastfrag $index
                        }                        
                    }                    
                }
                -fragmentoffset -
                -ipfragmentoffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set fragoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header11 $trans" -tag $tag                        
                    }
                }
                -ttl -
                -ipttl {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set ttl $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header12 $trans" -tag $tag                        
                    }
                }
                -ipprotocol -
                -ipprotocoltype {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set ipprotocol $trans
                    } else {
                        if { [ info exists [ string tolower $value ] ] } {
                            eval set trans $[ string tolower $value ]
                            if { [ string is integer $trans ] } {
                                set ipprotocol $trans
                            } else {
                                IxiaCapi::Logger::LogIn -type warn -message \
                                "$IxiaCapi::s_HeaderCreatorConfigIPV4header13 $trans"\
                                -tag $tag
                            }
                        } else {
                                IxiaCapi::Logger::LogIn -type warn -message \
                                "$IxiaCapi::s_HeaderCreatorConfigIPV4header13 $trans"\
                                -tag $tag
                        }
                    }
                }
                -ipprotocolmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header28 $EType" -tag $tag                        
                    } else {
                        set ipprotocolmode $trans
                    }                    
                }
                -ipprotocolcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set ipprotocolcount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header29 $value" -tag $tag                        
                    }
                }
                -ipprotocolstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set ipprotocolstep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header30 $value" -tag $tag                        
                    }
                }
                -autocrc -
                -flagvalidchecksum -
                -ipflagvalidchecksum -
                -ipusevalidchecksum {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set autocrc $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header14 $trans" -tag $tag                        
                    }
                }
                -checksum -
                -ipchecksum {
                    if { [ catch { format %x $value } ] == 0 } {
                        set checksum $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header15 $trans" -tag $tag                        
                    }
                }
                -sourceipaddr -
                -sa -
                -ipsrcaddr {
Deputs "set ip address...$value"
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set sa $value
Deputs "sa:$sa"
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header16 $value" -tag $tag                        
                    }
                }
                -sourceipaddrmode -
                -samode -
                -ipsrcaddrmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header17 $EType" -tag $tag                        
                    } else {
                        set samode $trans
                    }                    
                }
                -sourceipaddrrepeatcount -
                -sarepeat -
                -ipsrcaddrcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set sarepeat $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header18 $value" -tag $tag                        
                    }
                }
                -sourceipaddrstep -
                -ipsrcaddrstep {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set saStep $value
                    } else {
                        set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                        if { [ string is integer $trans ] } {
                            set saStep $trans
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header20 $value" -tag $tag                        
                        }
                    }
                }
                -sourceipaddroffset -
                -ipsrcaddroffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 32 } {
                        set saoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header21 $value" -tag $tag                        
                    }                    
                }
                -da -
                -destipaddr -
                -ipdstaddr -
                -dstipaddr {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set da $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header16 $value" -tag $tag                        
                    }
                }
                -damode -
                -destipaddrmode -
                -ipdstaddrmode -
                -dstipaddrmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header17 $EType" -tag $tag                        
                    } else {
                        set damode $trans
                    }                    
                }
                -darepeat -
                -destipaddrrepeatcount -
                -ipdstaddrcount -
                -dstipaddrrepeatcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set darepeat $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header18 $value" -tag $tag                        
                    }
                }
                -ipdstaddrstep -
                -destipaddrstep -
                -ipdstaddrstep -
                -dstipaddrstep {
                    if { [ IxiaCapi::Regexer::IsIPv4Address $value ] } {
                        set daStep $value
                    } else {
                        set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                        if { [ string is integer $trans ] } {
                            set daStep $trans
                        } else {
                            IxiaCapi::Logger::LogIn -type warn -message \
                            "$IxiaCapi::s_HeaderCreatorConfigIPV4header20 $value" -tag $tag                        
                        }
                    }
                }
                -destipaddroffset -
                -ipdstaddroffset -
                -dstipaddroffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 32 } {
                        set daoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header21 $value" -tag $tag                        
                    }                    
                }
                -offset -
                -infieldoffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 32 } {
                        set offset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header21 $value" -tag $tag                        
                    }                    
                }
                -version -
                -ipversion {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 16 } {
                        set version $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header23 $value" -tag $tag                        
                    }                    
                }
                -ihl -
                -ipihl {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 16 } {
                        set hlen $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header24 $value" -tag $tag                        
                    }                    
                }
                -qosmode -
                -ipqosmode {
                    set index [ lsearch -exact $EQos [ string tolower $value ] ]
                    if { $index < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header25 $EQos" -tag $tag                        
                    } else {
                        set qosmode [ string tolower $value ]
                    }
                }
                -qosvalue -
                -ipqosvalue {
                    if { [ catch { format %x $value } ] == 0 } {
                        set qosval $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header26 $trans" -tag $tag                        
                    }                    
                }
           }
        }

        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
Deputs "name:$name"
        set pdu "$name"
#        $pdu Clear
        if { [ catch {

            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {

            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "ipv4" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }

        uplevel $level "
        $pdu SetProtocol IPv4"
        #--------------------------
        #-----Config TOS ------
        if { [ info exists precedence ] } {
            uplevel $level "
            $pdu AddField precedence
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $precedence"          
        }
        if { [ info exists delay ] } {
            uplevel $level "
            $pdu AddField delay
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $delay"      
        }
        if { [ info exists throughput ] } {
Deputs "throughput: $throughput"
            uplevel $level "
            $pdu AddField throughput
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $throughput"          
        }
        if { [ info exists rely ] } {
            uplevel $level "
            $pdu AddField reliability
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $rely"     
        }
        if { [ info exists cost ] } {
Deputs "cost: $cost"
            uplevel $level "
            $pdu AddField monetary
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $cost"  
        }
        if { [ info exists qosval ] } {
            if { [ info exists qosmode ] } {
                if { $qosmode == "dscp" } {
                    if { $qosval >= 64 } {
                        IxiaCapi::Logger::LogIn -type err -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV4header27 $qosval" -tag $tag                                                
                    } else {
                        set qosval  [ expr $qosval * 4 ]
						
                    }
                }
            }
			set qosval [format %x $qosval]
            uplevel $level "
            $pdu AddField raw 1
            $pdu AddFieldMode Reserved
            $pdu AddFieldConfig 0           
            $pdu AddField raw
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $qosval"  
        }
        #--------------------------
        #-----Config Flags-----
        if { [ info exists frag ] } {
            uplevel $level "
            $pdu AddField fragment
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $frag"
        }
        if { [ info exists lastfrag ] } {
            uplevel $level "
            $pdu AddField lastFragment
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $lastfrag"
        }
        #--------------------------
        #-----Config Total Length-----
        set manTOT 1
        if { [ info exists lencover ] } {
            if { $lencover == 0 } {
            uplevel $level "
                $pdu AddField totalLength 0 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
                set manTOT 0
            } 
        }
        if { [ info exists totallen ] } {
            if { $manTOT } {
            uplevel $level "
                $pdu AddField totalLength
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $totallen "  
            }
        }
        #--------------------------
        #-----Config Checksum-----
        set manCRC 1
        if { [ info exists autocrc ] } {
            if { $autocrc } {
            uplevel $level "
                $pdu AddField checksum 0 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
                set manCRC 0
            } 
        } else {
            set manCRC 0
        }
        if { [ info exists checksum ] } {
            if { $manCRC } {
            uplevel $level "
                $pdu AddField checksum
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $checksum"
            }
        }
        #--------------------------
        #-----Config Common-----
        if { [ info exists identifier ] } {
            uplevel $level "
            $pdu AddField identification
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $identifier"
        }
        if { [ info exists fragoffset ] } {
            uplevel $level "
            $pdu AddField fragmentOffset
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $fragoffset"
        }
        if { [ info exists ttl ] } {
            uplevel $level "
            $pdu AddField ttl
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $ttl"
        }
        if { [ info exists ipprotocol ] } {
            if { [ info exists ipprotocolmode ] } {
                switch -exact $ipprotocolmode {
                    Fixed {
                        if {$ipprotocol != "auto"} {
                            uplevel $level "
                                $pdu AddFieldMode $ipprotocolmode
                                $pdu AddField protocol
                                $pdu AddFieldConfig $ipprotocol"
                        } else {
                            uplevel $level "
                                $pdu AddFieldMode $ipprotocolmode
                                $pdu AddField protocol 0 1
                                $pdu AddFieldConfig 0"
                        }
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists ipprotocolcount ] && [ info exists ipprotocolstep ] } {
            uplevel $level "
                            $pdu AddFieldMode $ipprotocolmode
                            $pdu AddField protocol
                            $pdu AddFieldConfig [ list 0 $ipprotocol $ipprotocolcount $ipprotocolstep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 ipsrcipaddrcount and ipsrcipaddrstep"\
                            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        
        if { [ info exists version ] } {
            uplevel $level "
            $pdu AddField version
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $version"
        }
        
        if { [ info exists hlen ] } {
            uplevel $level "
            $pdu AddField headerLength
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hlen"
        }
        if { [ info exists reserved ] } {
            uplevel $level "
            $pdu AddField reserved
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $reserved"
        }
        #--------------------------
        #-----Config IP Address-----
Deputs Step100
        if { [ info exists sa ] } {
Deputs Step110
            if { [ info exists samode ] } {
                switch -exact $samode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $samode
                        $pdu AddField srcIp
                        $pdu AddFieldConfig $sa"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists sarepeat ] && [ info exists saStep ] } {
                            if { [ IxiaCapi::Regexer::IsIPv4Address $saStep ] == 0 } {
                                set saStep [IxiaCapi::Regexer::GetIpStep $saoffset $saStep]
                            }
Deputs "saStep:$saStep"
            uplevel $level "
                            $pdu AddFieldMode $samode
                            $pdu AddField srcIp
                            $pdu AddFieldConfig [ list $saoffset $sa $sarepeat $saStep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 ipsrcipaddrcount and ipsrcipaddrstep"\
                            -tag $tag
                            return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }

        if { [ info exists da ] } {
            if { [ info exists damode ] } {
                switch -exact $damode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $damode
                        $pdu AddField dstIp
                        $pdu AddFieldConfig $da"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists darepeat ] && [ info exists daStep ] } {
                            if { [ IxiaCapi::Regexer::IsIPv4Address $daStep ] == 0 } {
                                set daStep [IxiaCapi::Regexer::GetIpStep $daoffset $daStep]
                            }
Deputs "daStep:$daStep"
            uplevel $level "
                            $pdu AddFieldMode $damode
                            $pdu AddField dstIp
                            $pdu AddFieldConfig [ list $daoffset $da $darepeat $daStep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 ipdstaddrcount and ipdstaddrstep"\
                            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        #--------------------------
        
        #--------------------------
        if { [ uplevel $level "$pdu IsValid" ] } {
            return $IxiaCapi::errorcode(0) 
        } else {
            IxiaCapi::Logger::LogIn -type warn -message \
                "$IxiaCapi::s_common3" -tag $tag
                        return $IxiaCapi::errorcode(1)                        
        }
    }
    body HeaderCreator::CreateTCPHeader { args } {
        global IxiaCapi::fail IxiaCapi::success
        set resultCreate    [ eval {CreateHeader -pro TCP} $args ]
        set resultConfig    [ eval ConfigTCPHeader $args ]
        if { $resultCreate == $success \
            && $resultConfig <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }        
    }
    
    body HeaderCreator::ConfigTCPHeader { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::enable IxiaCapi::disable
        global errorInfo
        set tag "body HeaderCreator::ConfigTCPHheader [info script]"
Deputs "----- TAG: $tag -----"
                
        set EType [ list Fixed Random Incrementing Decrementing ]
        set spmode Fixed
        set dpmode Fixed
        set spstep 1
        set dpstep 1
        set spcount 1
        set dpcount 1
        set level 2
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
                -offset {
                    if { [ string is integer $value ] && $value < 16 } {
                        set offset $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader2 $value" -tag $tag                        
                    }
                }
                -sp -
                -sourceport -
                -tcpsrcport {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set source_port $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader3 $trans" -tag $tag                        
                    }
                }
                -tcpsrcportmode -
                -srcportmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader18 $EType" -tag $tag                        
                    } else {
                        set spmode $trans
                    }                    
                }
                -tcpsrcportcount -
                -srcportcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set spcount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader19 $value" -tag $tag                        
                    }
                }
                -tcpsrcportstep -
                -srcportstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set spstep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader20 $value" -tag $tag                        
                    }
                }
                -dp -
                -destport -
                -dstport -
                -tcpdstport {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set destination_port $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader4 $trans" -tag $tag                        
                    }
                }
                -tcpdstportmode -
                -dstportmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader18 $EType" -tag $tag                        
                    } else {
                        set dpmode $trans
Deputs "dst port mode:$dpmode"
                    }                    
                }
                -tcpdstportcount -
                -dstportcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set dpcount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader19 $value" -tag $tag                        
                    }
                }
                -tcpdstportstep -
                -dstportstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set dpstep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader20 $value" -tag $tag                        
                    }
                }
                -seqnum -
                -sequencenumber -
                -tcpsequencenumber {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set sequence_number $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader5 $trans" -tag $tag                        
                    }
                }
                -acknum -
                -acknowledgementnumber -
                -tcpacknowledgementnumber {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set ack_number $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader6 $trans" -tag $tag                        
                    }
                }
                -window -
                -tcpwindow {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set window_size $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader7 $trans" -tag $tag                        
                    }
                }
                -up -
                -urgentpointer -
                -tcpurgentpointer {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set urgent_pointer $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader8 $trans" -tag $tag                        
                    }
                }
                -urg -
                -urgentpointervalid -
                -tcpflagurg {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set urg $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader9 $trans" -tag $tag                        
                    }
                }
                -ack -
                -acknowledgevalid -
                -tcpflagack {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set ack $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader10 $trans" -tag $tag                        
                    }
                }
                -psh -
                -pushfunctionvalid -
                -tcpflagpsh {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set psh $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader11 $trans" -tag $tag                        
                    }
                }
                -rst -
                -resetconnection -
                -tcpflagrst {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set rst $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader12 $trans" -tag $tag                        
                    }
                }
                -syn -
                -synchronize -
                -tcpflagsyc {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set syn $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader13 $trans" -tag $tag                        
                    }
                }
                -fin -
                -finished -
                -tcpflagfin {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set fin $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader14 $trans" -tag $tag                        
                    }
                }
                -autocrc -
                -usevalidchecksum -
                -tcpflagchecksum {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set autocrc $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader15 $trans" -tag $tag                        
                    }
                }
                -checksum -
                -tcpchecksum {
                    if { [ catch { format %x $value } ] == 0 } {
                        set checksum $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader16 $trans" -tag $tag                        
                    }
                }
                -autoport -
                -tcpautodstport {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set autoport $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader17 $value" -tag $tag                        
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
#        $pdu Clear
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "tcp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol TCP"
        #-----set Code Bits-----
        if { [ info exists urg ] } {
            uplevel $level "
            $pdu AddField urgBit
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $urg"
        }
        if { [ info exists ack ] } {
            uplevel $level "
            $pdu AddField ackBit
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $ack"
        }
        if { [ info exists psh ] } {
            uplevel $level "
            $pdu AddField pshBit
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $psh"
        }
        if { [ info exists rst ] } {
            uplevel $level "
            $pdu AddField rstBit
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $rst"
        }
        if { [ info exists syn ] } {
            uplevel $level "
            $pdu AddField synBit
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $syn"
        }
        if { [ info exists fin ] } {
            uplevel $level "
            $pdu AddField finBit
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $fin"
        }
        #--------------------------
        #-----Config Checksum-----
        set manCRC 1
        if { [ info exists autocrc ] } {
            if { $autocrc } {
            uplevel $level "
                $pdu AddField checksum 0 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
                set manCRC 0
            } 
        }
        if { [ info exists checksum ] } {
            if { $manCRC } {
            uplevel $level "
                $pdu AddField checksum
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $checksum"
            }
        }
        #--------------------------
        #-----Config Common-----
        if { [ info exists offset ] } {
Deputs "offset:$offset"
            uplevel $level "
            $pdu AddField dataOffset 0 1
            $pdu AddFieldMode Reserved
            $pdu AddFieldConfig 0
            $pdu AddField dataOffset
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $offset"
        }
        if { [ info exists sequence_number ] } {
            uplevel $level "
            $pdu AddField sequenceNumber
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $sequence_number"
        }
        if { [ info exists ack_number ] } {
            uplevel $level "
            $pdu AddField acknowledgementNumber
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $ack_number"
        }
        if { [ info exists window_size ] } {
            uplevel $level "
            $pdu AddField window
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $window_size"
        }
        if { [ info exists urgent_pointer ] } {
            uplevel $level "
            $pdu AddField urgentPtr
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $urgent_pointer"
        }
        #--------------------------
        #-----Config Port-----
        if { [ info exists destination_port ] } {
Deputs Step110
            if { [ info exists dpmode ] } {
Deputs Step120
                switch -exact $dpmode {
                    Fixed {
        uplevel $level "
                        $pdu AddFieldMode $dpmode
                        $pdu AddField dstPort
                        $pdu AddFieldConfig $destination_port"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists dpcount ] && [ info exists dpstep ] } {
        uplevel $level "
                            $pdu AddFieldMode $dpmode
                            $pdu AddField dstPort
                            $pdu AddFieldConfig \
                            [ list 0 $destination_port $dpcount $dpstep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 tcpdstportcount and tcpdstportstep"\
                            -tag $tag
                    return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        if { [ info exists source_port ] } {
            if { [ info exists spmode ] } {
                switch -exact $spmode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $spmode
                        $pdu AddField srcPort
                        $pdu AddFieldConfig $source_port"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists spcount ] && [ info exists spstep ] } {
            uplevel $level "
                            $pdu AddFieldMode $spmode
                            $pdu AddField srcPort
                            $pdu AddFieldConfig \
                            [ list 0 $source_port $spcount $spstep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 tcpsrcportcount and tcpsrcportstep"\
                            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
                        }
                    }
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
    body HeaderCreator::CreateUDPHeader { args } {
        global IxiaCapi::fail IxiaCapi::success
        set resultCreate        [ eval {CreateHeader -pro UDP} $args ]
        set resultConfig        [ eval ConfigUDPHeader $args ]
        if { $resultCreate == $success \
            && $resultConfig <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }        
    }
    body HeaderCreator::ConfigUDPHeader { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::enable IxiaCapi::disable
        global errorInfo
        set tag "body HeaderCreator::ConfigUDPHeader [info script]"
Deputs "----- TAG: $tag -----"
        set spmode Fixed
        set dpmode Fixed
        set spstep 1
        set dpstep 1
        set dpcount 1
        set dpstep 1
        set spcount 1
        set spstep 1
        set level 2
        set EType [ list Fixed Random Incrementing Decrementing ]
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
                -sp -
                -sourceport -
                -udpsrcport {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set source_port $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader2 $trans" -tag $tag                        
                    }
                }
                -udpsrcportmode -
                -srcportmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader10 $EType" -tag $tag                        
                    } else {
                        set spmode $trans
                    }                    
                }
                -udpsrcportcount -
                -srcportcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set spcount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader11 $value" -tag $tag                        
                    }
                }
                -udpsrcportstep -
                -srcportstep -
                -udpsrcstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set spstep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader12 $value" -tag $tag                        
                    }
                }
                -autoport {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set autoport $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader3 $trans" -tag $tag                        
                    }                    
                }
                -dp -
                -destport -
                -dstport -
                -udpdstport {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set destination_port $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader4 $trans" -tag $tag                        
                    }
                }
                -udpdstportmode -
                -dstportmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader10 $EType" -tag $tag                        
                    } else {
                        set dpmode $trans
                    }                    
                }
                -udpdstportcount -
                -dstportcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set dpcount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader11 $value" -tag $tag                        
                    }
                }
                -udpdstportstep -
                -dstportstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set dpstep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigTCPheader12 $value" -tag $tag                        
                    }
                }
                -checksum -
                -udpchecksum {
Deputs "udp checksum: $value"
                    if { [ catch { format %x $value } ] == 0 } {
                        set checksum $value
Deputs "udp checksum: $checksum"
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader5 $value" -tag $tag                        
                    }
                }
                -enablechecksum -
                -udpenablechecksum {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set enablechecksum $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader6 $value" -tag $tag                        
                    }
                }
                -totallength -
                -udplength -
                -length {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set totallen $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader7 $trans" -tag $tag                        
                    }
                }
                -lengthoverride -
                -udplengthoverride {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set lencover $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader8 $trans" -tag $tag                        
                    }
                }
                -crcoverride -
                -enablechecksumoverride -
                -udpflagchecksum {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set crcoverride $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigUDPheader9 $trans" -tag $tag                        
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
#        $pdu Clear
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "udp" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }
        uplevel $level "
            $pdu SetProtocol UDP"
        #-----Config Total Length-----
        set manTOT 1
        if { [ info exists lencover ] } {
            if { $lencover == 0 } {
            uplevel $level "
                $pdu AddField length 0 1
                $pdu AddFieldMode Reserved
                $pdu AddFieldConfig 0"
                set manTOT 0
            } 
        }
        if { [ info exists totallen ] } {
            if { $manTOT } {
            uplevel $level "
                $pdu AddField length
                $pdu AddFieldMode Fixed
                $pdu AddFieldConfig $totallen"
            }
        }
        #--------------------------
        #-----Config Checksum-----
        set nochecksum 0
        if { [ info exists enablechecksum ] } {
            if { $enablechecksum } {
                if { [ info exists crcoverride ] } {
                    if { $crcoverride == 0 } {
            uplevel $level "
                        $pdu AddField checksum 1 1
                        $pdu AddFieldMode Reserved
                        $pdu AddFieldConfig 0"
                    } else {
                        if { [ info exists checksum ] } {
            uplevel $level "
                            $pdu AddField checksum 1 
                            $pdu AddFieldMode Reserved
                            $pdu AddFieldConfig 0                       
                            $pdu AddField checksum
                            $pdu AddFieldMode Fixed
                            $pdu AddFieldConfig $checksum"
                        }
                    }
                }
            }
        }
        #--------------------------
        #-----Config Port-----
        if { [ info exists destination_port ] } {
            if { [ info exists dpmode ] } {
                switch -exact $dpmode {
                    Fixed {
        uplevel $level "
                        $pdu AddFieldMode $dpmode
                        $pdu AddField dstPort
                        $pdu AddFieldConfig $destination_port"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists dpcount ] && [ info exists dpstep ] } {
        uplevel $level "
                            $pdu AddFieldMode $dpmode
                            $pdu AddField dstPort
                            $pdu AddFieldConfig \
                            [ list 0 $destination_port $dpcount $dpstep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 dstportcount and dstportstep"\
                            -tag $tag
                        }
                    }
                }
            } 
        }
        if { [ info exists source_port ] } {
            if { [ info exists spmode ] } {
                switch -exact $spmode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $spmode
                        $pdu AddField srcPort
                        $pdu AddFieldConfig $source_port"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists spcount ] && [ info exists spstep ] } {
            uplevel $level "
                            $pdu AddFieldMode $spmode
                            $pdu AddField srcPort
                            $pdu AddFieldConfig \
                            [ list 0 $source_port $spcount $spstep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 tcpsrcportcount and tcpsrcportstep"\
                            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
                        }
                    }
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
    body HeaderCreator::CreateMPLSHeader { args } {
        global IxiaCapi::fail IxiaCapi::success
        set index [ lsearch -regexp $args {-[tT][yY][pP][eE]} ]
        if { $index >= 0 } {
            set args    [ lreplace $args $index [ expr $index + 1 ] ]
        }
        set resultCreate        [ eval {CreateHeader -pro MPLS} $args ]
        set resultConfig        [ eval ConfigMPLSHeader $args ]
        if { $resultCreate == $success \
            && $resultConfig <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }        
    }
    body HeaderCreator::ConfigMPLSHeader { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::enable IxiaCapi::disable
        global errorInfo
        set tag "body HeaderCreator::ConfigMPLSHeader [info script]"
Deputs "----- TAG: $tag -----"
        set EType [ list Fixed Random Incrementing Decrementing ]
        set level 2
        set labelmode Fixed
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
                -label -
                -mplslabel {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set label1 $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigMPLSheader2 $trans" -tag $tag                        
                    }
                }
                -labelcount -
                -mplslabelcount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set labelcount $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigMPLSheader6 $value" -tag $tag                        
                    }
                }
                -labelmode -
                -mplslabelmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigMPLSheader8 $EType" -tag $tag                        
                    } else {
                        set labelmode $trans
                    }                    
                }
                -labelstep -
                -mplslabelstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set labelstep $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigMPLSheader7 $value" -tag $tag                        
                    }
                }
                -experimental -
                -mplsexperimental -
                -mplsexperimentaluse -
                -experimentaluse -
                -mplsexp -
                -exp {
                    if { [ string is integer $value ] && $value < 8 } {
                        set exp1 $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigMPLSheader3 $value" -tag $tag                        
                    }
                }
                -ttl -
                -timetolive -
                -mplsttl {
                    if { [ string is integer $value ] && $value < 256 } {
                        set ttl1 $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigMPLSheader4 $value" -tag $tag                        
                    }
                }
                -mplsbottomofstack -
                -bottomofstack {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set s1 $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigMPLSheader5 $trans" -tag $tag                        
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
#        $pdu Clear
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "mpls" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }
            uplevel $level "
        $pdu SetProtocol MPLS"
        #-----Config-----
        if { [ info exists label1 ] } {
            if { [ info exists labelmode ] } {
                switch -exact $labelmode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $labelmode
                        $pdu AddField value
                        $pdu AddFieldConfig $label1"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists labelcount ] && [ info exists labelstep ] } {
            uplevel $level "
                            $pdu AddFieldMode $labelmode
                            $pdu AddField value
                            $pdu AddFieldConfig [ list 0 $label1 $labelcount $labelstep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 labelcount and labelstep"\
                            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        if { [ info exists exp1 ] } {
            uplevel $level "
            $pdu AddField experimental
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $exp1"
        }
        if { [ info exists ttl1 ] } {
            uplevel $level "
            $pdu AddField ttl
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $ttl1"
        }
        if { [ info exists s1 ] } {
            uplevel $level "
            $pdu AddField bottomOfStack
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $s1"
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
    body HeaderCreator::CreateIPV6Header { args } {
        global IxiaCapi::fail IxiaCapi::success
        set resultCreate    [ eval {CreateHeader -pro IPv6} $args ]
        set resultConfig    [ eval ConfigIPV6Header $args ]
        if { $resultCreate == $success \
            && $resultConfig <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body HeaderCreator::ConfigIPV6Header { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::enable IxiaCapi::disable
        global errorInfo
        set tag "body HeaderCreator::ConfigIPV6Header [info script]"
Deputs "----- TAG: $tag -----"
        set offset 0 ;#obsolete
        set saoffset 0
        set daoffset 0
        set samode Fixed
        set damode Fixed
        set saStep 0000:0000:0000:0000:0000:0000:0000:0001
        set daStep 0000:0000:0000:0000:0000:0000:0000:0001
        set level 2
        set EType [ list Fixed Random Incrementing Decrementing ]

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
                -trafficclass -
                -ipv6trafficclass {
                    if { [ string is integer $value ] && $value < 256 } {
                        set traffic_class $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header2 $value" -tag $tag                        
                    }
                }
                -differentservice -
                -ipv6differentservice {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set ds $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header3 $trans" -tag $tag                        
                    }                    
                }
                -flowlabel -
                -ipv6flowlabel {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set flow_label $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header4 $trans" -tag $tag                        
                    }
                }
                -payloadlen -
                -ipv6payloadlen {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set payload_length $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header5 $trans" -tag $tag                        
                    }
                }
                -nextheader -
                -ipv6nextheader {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set next_header $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header6 $trans" -tag $tag                        
                    }
                }
                -hoplimit -
                -ipv6hoplimit {
                    if { [ string is integer $value ] && $value < 256 } {
                        set hop_limit $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header7 $value" -tag $tag                        
                    }
                }
                -sourceaddress -
                -ipv6srcaddr -
                -sourceaddr -
                -ipv6srcaddress {
                    set sourceAddress $value
                }
                -ipv6srcaddressmode -
                -sourceaddrmode -
                -sourceaddressmode -
                -ipv6srcaddrmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header11 $EType" -tag $tag                        
                    } else {
                        set samode $trans
                    }                    
                }
                -ipv6srcaddresscount -
                -ipv6srcaddrcount -
                -sourceaddrnum -
                -sourceaddresscount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set sarepeat $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header12 $value" -tag $tag                        
                    }
                }
                -ipv6srcaddressstep -
                -ipv6srcaddrstep -
                -sourceaddressstep -
                -sourceaddrstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
Deputs "Unit trans result for IPv6 Header SourceAddressStep: $trans"
                    if { [ string is integer $trans ] } {
                        set saStep $trans
                    } else {
                        set saStep $value
                    }
Deputs "saStep:$saStep"
                }
                -ipv6srcaddroffset -
                -ipv6srcaddressoffset -
                -sourceaddressoffset -
                -sourceaddroffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 128 } {
                        set saoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header14 $value" -tag $tag                        
                    }                    
                }               
                -ipv6dstaddress -
                -destinationaddress -
                -ipv6dstaddr -
                -destinationaddr -
                -destaddress {
                    set destinationAddress $value
                }
                -ipv6dstaddressmode -
                -destinationaddrmode -
                -destaddressmode {
                    if { "increment" == [ string tolower $value ] || \
                        "decrement" == [ string tolower $value ] } {
                        set value ${value}ing
                    }
                    set trans [ string totitle [ string tolower $value ] 0 ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header11 $EType" -tag $tag                        
                    } else {
                        set damode $trans
                    }                    
                }
                -ipv6dstaddresscount -
                -destinationaddrnum -
                -destaddresscount {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
Deputs "Dst addr num: $trans"
                        set darepeat $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header12 $value" -tag $tag                        
                    }
                }
                -ipv6dstaddressstep -
                -destinationaddrstep -
                -destaddressstep {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] } {
                        set daStep $trans
                    } else {
                        set daStep $value
                    }
                }
                -ipv6dstaddroffset -
                -ipv6dstaddressoffset -
                -destinationaddroffset -
                -destaddressoffset {
                    set trans [ IxiaCapi::Regexer::UnitTrans $value ]
                    if { [ string is integer $trans ] && $trans < 128 } {
                        set daoffset $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header14 $value" -tag $tag                        
                    }                    
                }
                -autopayload -
                -ipv6autopayload {
                    set trans [ IxiaCapi::Regexer::BoolTrans $value ]
                    if { $trans == 1 || $trans == 0 } {
                        set autopayload $trans
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6header10 $trans" -tag $tag                        
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
#        $pdu Clear
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "ipv6" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }
        uplevel $level "
        $pdu SetProtocol IPv6"
        #-----Config common-----
        if { [ info exists traffic_class ] } {
            uplevel $level "
            $pdu AddField trafficClass 1
            $pdu AddFieldMode Reserved
            $pdu AddFieldConfig 0
            $pdu AddField trafficClass
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $traffic_class"
        }
        if { [ info exists flow_label ] } {
            uplevel $level "
            $pdu AddField flowLabel
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $flow_label"
        }
        #-----Config payload-----
        if { [ info exists payload_length ] } {
        uplevel $level "
            $pdu AddField payloadLength
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $payload_length"
        }
        #--------------------------
        if { [ info exists next_header ] } {
            uplevel $level "
            $pdu AddField nextHeader
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $next_header"
        }
        if { [ info exists hop_limit ] } {
            uplevel $level "
            $pdu AddField hopLimit
            $pdu AddFieldMode Fixed
            $pdu AddFieldConfig $hop_limit"
        }
        #--------------------------
        #-----Config IP Address-----
        if { [ info exists sourceAddress ] } {
            if { [ info exists samode ] } {
                switch -exact $samode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $samode
                        $pdu AddField srcIP
                        $pdu AddFieldConfig $sourceAddress"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists sarepeat ] && [ info exists saStep ] } {
            uplevel $level "
                            $pdu AddFieldMode $samode
                            $pdu AddField srcIP
                            $pdu AddFieldConfig \
                            [ list $saoffset $sourceAddress $sarepeat $saStep ]"
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 ipv6srcaddrcount and ipv6srcaddrstep"\
                            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
                        }
                    }
                }
            } 
        }
        if { [ info exists destinationAddress ] } {
            if { [ info exists damode ] } {
                switch -exact $damode {
                    Fixed {
            uplevel $level "
                        $pdu AddFieldMode $damode
                        $pdu AddField dstIP
                        $pdu AddFieldConfig $destinationAddress"
                    }
                    Decrementing -
                    Incrementing {
                        if { [ info exists darepeat ] && [ info exists daStep ] } {
            uplevel $level "
                           $pdu AddFieldMode $damode
                            $pdu AddField dstIP
                            $pdu AddFieldConfig \
                            [ list $daoffset $destinationAddress $darepeat $daStep ]
                            "
                        } else {
                            IxiaCapi::Logger::LogIn -type err -message \
                            "$IxiaCapi::s_common2 ipv6dstaddrcount and ipv6dstaddrstep"\
                            -tag $tag
                        return $IxiaCapi::errorcode(3)                        
                        }
                    }
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
    body HeaderCreator::CreateIPV6ExtHeader { args } {
        global IxiaCapi::fail IxiaCapi::success
        set resultCreate    [ eval {CreateHeader -pro IPv6} $args ]
        set resultConfig    [ eval ConfigIPV6ExtHeader $args ]
        if { $resultCreate == $success \
            && $resultConfig <= 1 } {
            return $IxiaCapi::errorcode(0) 
        } else {
            return $IxiaCapi::errorcode(4)                        
        }
    }
    body HeaderCreator::ConfigIPV6ExtHeader { args } {
        global IxiaCapi::fail IxiaCapi::success IxiaCapi::enable IxiaCapi::disable
        global errorInfo
        set tag "body HeaderCreator::ConfigIPV6Header [info script]"
Deputs "----- TAG: $tag -----"
Deputs Step10
        set level 2
        set EType [ list hopbyhop destination routing fragment authentication ]
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
                -type {
Deputs "Type: $value"
                    set trans [ string tolower $value ]
                    if { [ lsearch -exact $EType $trans ] < 0 } {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6Extheader1 $EType" -tag $tag                        
                    } else {
                        set type $trans
                    }
                }
                -value {
Deputs "Value: $value"
                    if { [ string range $value 0 1 ] == "0x" } {
                        set value [ string range $value 2 end ]
                    }
                    if { [ string is xdigit $value ] } {
                        set header_value $value
                    } else {
                        IxiaCapi::Logger::LogIn -type warn -message \
                        "$IxiaCapi::s_HeaderCreatorConfigIPV6Extheader2" -tag $tag                        
                    }
                }
            }
        }
Deputs Step20
        if { [ info exists name ] == 0 } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader2" -tag $tag
                        return $IxiaCapi::errorcode(4)                        
        }
Deputs Step30
        set pdu "$name"
#        $pdu Clear
        if { [ catch {
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        } ] } {
            set level 1
            set pro [ string tolower [ uplevel $level " $pdu cget -protocol " ] ]
        }
Deputs "Pro: $pro"
        if { $pro != "ipv6" } {
            IxiaCapi::Logger::LogIn -type err -message \
            "$IxiaCapi::s_HeaderCreatorConfigHeader1" -tag $tag
                        return $IxiaCapi::errorcode(6)                        
        }
        #-----Config common-----
        if { [ info exists type ] } {
Deputs "Type: $type"
            switch -exact -- $type {
                hopbyhop {
            uplevel $level "
                        $pdu SetProtocol ipv6HopByHopOptions"
                }
                destination {
            uplevel $level "
                        $pdu SetProtocol ipv6DestinationOptions"
                }
                routing {
            uplevel $level "
                        $pdu SetProtocol ipv6Routing"
                }
                fragment {
            uplevel $level "
                        $pdu SetProtocol ipv6Fragment"
                }
                authentication {
            uplevel $level "
                        $pdu SetProtocol ipv6Authentication"
                }
                default {
                    return $IxiaCapi::errorcode(1)                        
                }
            }
        } else {
            return $IxiaCapi::errorcode(1)                        
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
}

