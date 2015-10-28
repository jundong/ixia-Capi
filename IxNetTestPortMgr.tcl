# IxNetTestPortMgr.tcl --
#   This file implements the supervisor of TestPort class for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1

namespace eval IxiaCapi::Supervisor {
    namespace export *
    
    class IxNetTestPortMgr {
        
        common Exist
        set Exist 0
        public variable Chassis
        public variable TestPortList
        public variable TestPortHandleList
        public variable HostHandleList
        #public variable VlantagList
        constructor {} {
            if { $Exist } {
                error "IxNetTestPortMgr instance has existed, this class should be singleton."
            }
            set TestPortList [ list ]
            set TestPortHandleList [ list ]
            set VlantagList [ list ]
            set Exist 1
            set Chassis ""
        }
        method Reset {} {
		set tag "body TestPortMgr::Reset [info script]"
Deputs "----- TAG: $tag -----"
            set TestPortList [ list ]
            set TestPortHandleList [ list ]
            #set VlantagList [ list ]
            set HostHandleList [ list ]
        }
        method AddTestPort { portname porthandle } {
		set tag "body TestPortMgr::AddTestPort [info script]"
Deputs "----- TAG: $tag -----"

            set index [ lsearch -exact $TestPortList $portname ]

            if { $index < 0 } {

                lappend TestPortList $portname
                lappend TestPortList $porthandle
            } else {

                set handleIndex [ lsearch -exact $TestPortHandleList [ lindex $TestPortList [expr $index+1] ] ]

                set TestPortHandleList [ lreplace $TestPortHandleList $handleIndex $handleIndex ]

                lset $TestPortList [expr $index+1] $porthandle 

            }
            AddTestPortHandle $porthandle
			puts "$TestPortList"

        }
        
        method AddTestPortHandle { porthandle } {
            lappend TestPortHandleList $porthandle
        }
        method AddHostHandle { hosthandle } {
            lappend HostHandleList  $hosthandle
        }
        method GetHostHandles {} {
            return $HostHandleList
        }
        method DeleteTestPort { args } {
		set tag "body TestPortMgr::DeleteTestPort [info script]"
Deputs "----- TAG: $tag -----"
            foreach { key value } $args {
                set key [string tolower $key]
                switch -exact -- $key {
                    -portname -
                    -name {
                        set handle [ GetPortHandle $value ]                        
                    }
                    -porthandle -
                    -handle {
                        set handle $value
                    }
                }
            }
            if { [ info exists handle ] == 0 } {
                IxiaCapi::Logger::LogIn -message "Delete port fail..."
                return
            }
            set handleIndex [ lsearch -exact $TestPortHandleList $handle ]
            if { $handleIndex > -1 } {
                set TestPortHandleList [ lreplace $TestPortHandleList $handleIndex $handleIndex ]
            }
            set portIndex [ expr [ lsearch -exact $TestPortList $handle ] - 1 ]
            if { $portIndex > -1 } {
                set TestPortList [ lreplace $TestPortList $portIndex [ expr $portIndex + 1 ] ]
            }
        }
        
        method GetPortHandle { portname } {
		set tag "body TestPortMgr::GetPortHandle [info script]"
Deputs "----- TAG: $tag -----"
            foreach { name handle } $TestPortList {
                if { $name == $portname } {
                    return $handle
                }
            }
            return -1
        }
        method GetPortName { porthandle } {
		set tag "body TestPortMgr::GetPortName [info script]"
Deputs "----- TAG: $tag -----"
Deputs StepGetPortName
Deputs "$TestPortList"
            foreach { name handle } $TestPortList {
Deputs "name:$name\thandle:$handle"
Deputs "${handle}==${porthandle}?"
                if { $handle == $porthandle } {
Deputs "Name found"
                    return $name
                }
            }
            return -1
        }
        method GetPortObj { porthandle } {
		set tag "body TestPortMgr::GetPortObj [info script]"
Deputs "----- TAG: $tag -----"
            set retObj  [ list ]
            foreach obj [ find objects ] {
#Deputs "Obj:$obj"
                if { [ $obj isa IxiaCapi::TestPort ] == 0 } {
#Deputs "Obj is not a TestPort instance"
                    continue
                } 
                set handle [ $obj cget -hPort ]
Deputs "Handle:$handle"
Deputs "Match handle:$porthandle"
                if { $handle == $porthandle } {
Deputs "Port Match!"
                    lappend retObj $obj
                }
            }
            return $retObj
        }
    }
}

namespace eval IxiaCapi {
    # initialize object supervisor
    IxiaCapi::Supervisor::IxNetTestPortMgr PortManager
}

