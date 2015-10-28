# Regexer.tcl --
#   This file implements the Regular expression method for the highlevel CAPI of IxNetwork device.
#
# Copyright (c) Ixia technologies, Inc.

# Change made
# Version 1.1

namespace eval IxiaCapi::Lib {
    namespace export *

    proc TrafficStopped {} {
        global errorInfo
        if { [ catch {
            set root    [ixNet getRoot]
Deputs "root:$root"
            set state [ ixNet getA $root/traffic -state ]
        } ] == 0 } {
            if { ($state == "stopped") || ($state == "unapplied") } {
                return 1
            } else {
                return 0
            }
        } else {
Deputs "Get traffic state fail...$errorInfo"
            return 1
        }
    }



}