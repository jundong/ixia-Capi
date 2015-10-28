# IxNetTrafficMgr.tcl --
#   This file implements the AgtTrafficEngine class, which is the supervisor of
#    the traffic-engine-related objects, for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1

namespace eval IxiaCapi::Supervisor {
    
    namespace export *
    class IxNetTrafficMgr {
        
        common Exist
        set Exist 0
        private variable ProfileList
        private variable ProfileHandleList
        private variable StreamGroupList
        private variable StreamGroupHandleList
        private variable PduList

        
        constructor {} {
            if { $Exist } {
                error "TrafficMgr instance has existed, this class should be singleton."
            }
            set PduList [ list ]
            set ProfileList [ list ]
            set ProfileHandleList [ list ]
            set StreamGroupList [ list ]
            set StreamGroupHandleList [ list ]
            set Exist 1
        }
        method Reset {} {
            set PduList [ list ]
            set ProfileList [ list ]
            set ProfileHandleList [ list ]
            set StreamGroupList [ list ]
            set StreamGroupHandleList [ list ]
        }
        method AddProfile { name handle } {
            set index  [ lsearch -exact $ProfileList $name ]
            if { $index < 0 } {
                lappend ProfileList $name 
                lappend ProfileList $handle
            } else {
                set handleIndex [ lsearch -exact $ProfileHandleList [ lindex $ProfileList [expr $index+1] ] ]
                set ProfileHandleList [ lreplace $ProfileHandleList $handleIndex $handleIndex ]
                lset $ProfileList [ expr $index+1 ] $handle
            }
            AddProfileHandle $handle
        }
        
        method AddProfileHandle { handle} {
            lappend ProfileHandleList $handle
        }
        
        method AddStreamGroup { name handle } {
            set index [ lsearch -exact $StreamGroupList $name ]
            if {$index<0} {
                lappend StreamGroupList $name
                lappend StreamGroupList $handle
            } else {
                set handleIndex [lsearch -exact $StreamGroupHandleList [ lindex $StreamGroupList [expr $index+1]]]
                set StreamGroupHandleList [ lreplace $StreamGroupHandleList $handleIndex $handleIndex ]
                lset $StreamGroupList [expr $index+1] $handle
            }
            AddStreamGroupHandle $handle
        }
        method AddStreamGroupHandle { streamgrphandle } {
            lappend StreamGroupHandleList $streamgrphandle
        }
        
        method AddPdu { name } {
            set index  [ lsearch -exact $PduList $name ]
            if { $index < 0 } {
                lappend PduList $name 
            }
        }
        method GetPduIndex { pduname } {
            return [ lsearch -exact $PduList $pduname ]
        }
        method GetStreamGroupHandle { streamname } {
            foreach { name handle } $StreamGroupList {
                if { $name == $streamname } {
                    return $handle
                }
            }
            return -1
        }
        
        method GetProfileHandle { profilename } {
            foreach { name handle } $ProfileList {
                if { $name == $profilename } {
                    return $handle
                }
            }
            return -1            
        }
        method GetProfileHandleIndex { profilehandle } {
            return [ lsearch -exact $ProfileHandleList $profilehandle ] 
        }
        method GetProfileListLength { } {
            return [ llength $ProfileList ]
        }
        method GetProfileByIndex { index } {
            return [ lindex $ProfileList $index ]
        }
        method GetProfileName { profilehandle } {
            foreach { name handle } $ProfileList {
                if { $handle == $profilehandle } {
                    return $name
                }
            }
            return ""            
        }
        method GetStreamGroupIndex { streamname } {
		    puts $StreamGroupList
            return [ lsearch -exact $StreamGroupList $streamname ]
        }
        method GetProfileIndex { profilename } {
            return [ lsearch -exact $ProfileList $profilename ]
        }
        method DeleteProfile { profilename } {
            set index [ GetProfileIndex $profilename ]
            if { $index >= 0 } {
                set handleIndex [ lsearch -exact $ProfileHandleList\
                                [ lindex $ProfileList [expr $index+1] ] ]
                set ProfileHandleList \
                [ lreplace $ProfileHandleList $handleIndex $handleIndex ]
                set ProfileList [ lreplace $ProfileList $index [expr $index+1] ]
            }
        }
        
        method DeleteStream { streamname } {
            set index [ GetStreamGroupIndex $streamname ]
			puts $index
            if { $index >= 0 } {
                set handleIndex [ lsearch -exact $StreamGroupHandleList\
                                [ lindex $StreamGroupList [expr $index+1] ] ]
                set StreamGroupHandleList \
                [ lreplace $StreamGroupHandleList $handleIndex $handleIndex ]
                set StreamGroupList [ lreplace $StreamGroupList $index [expr $index+1] ]
            }
        }
        
        method DeletePdu { pduname } {
            set index [ GetPduIndex $pduname ]
Deputs "Index: $index "
            if { $index >= 0 } {
                set PduList [ lreplace $PduList $index $index ]
            }
            catch {
                set obj [ IxiaCapi::Regexer::GetObject $pduname ]
                delete object $obj
            }
        }
        method DeleteAllPdu { } {
Deputs "pdu list:$PduList"            
            foreach pdu $PduList {
                set index [ GetPduIndex $pdu ]
                if { $index >= 0 } {
                    set PduList [ lreplace $PduList $index $index ]
                }
                # special ? not unite with other delete method
                #delete object ${IxiaCapi::ObjectNamespace}::$pduname
                catch {
                    set obj [ IxiaCapi::Regexer::GetObject $pdu ]
                    delete object $obj
                }
            }
        }

        method GetStreamHandleList {} {
            return $StreamGroupHandleList
        }
    }
}

namespace eval IxiaCapi {
    # initialize object supervisor
    IxiaCapi::Supervisor::IxNetTrafficMgr TrafficManager
}