# Logger.tcl --
#   This file implements the Logger class for the highlevel CAPI of IxNetwork device.
#   The Logger class is mainly in charge of writing of the error or warning informations. 
# Copyright (c) Ixia technologies, Inc.

# Version 1.0

namespace eval IxiaCapi::Logger {
    namespace export *    
    class Logger {
        private variable IOhandle
        private variable loggerType
        private method Initiate {} {}
        private method SetEnum {} {}
        
        constructor { { filePath default } } {
            if {$filePath == {default} } {
                set filePath $IxiaCapi::logPath
            }
            Initiate
            if { [catch {
                if { [ file exists $filePath ]} {
                    set IOhandle [ open $filePath a ]
                } else {
                    set IOhandle [ open $filePath {RDWR CREAT} ]
                } } code] } {
                puts stderr $code
            }
        }
        destructor {
            close $IOhandle
        }
        method LogIn { args } {}
    }
    
    body Logger::Initiate {} {
        SetEnum
    }

    # Logger::LogIn --
    #       Write in the log
    # Optional args: -type -message
    #       -Type should be { ERROR WARN INFO EXCEPTION }
    body Logger::LogIn { args } {
        set type INFO
        set now [clock format [ clock seconds ] -format {%D %I:%M:%S %p}  ]
        set infos "No message"
        set tag ""
        foreach { key value } $args {
            set key [string tolower $key]
            switch -exact -- $key {
                -type {
                    if {[lsearch $loggerType [string toupper $value]] != -1} {
                        set type [string toupper $value]
                    } else {
#                        IxiaCapi::Exception::throw -type ExParamsNull \
#                            -module {body Logger::LogIn} -params $key -info $loggerType
                        puts stderr "Bad LogIn type:$value, the type could be $loggerType"
                    }
                } 
                -message {
                    set infos $value
                }
                -tag {
                    set tag $value
                }
                default {
                    puts stderr "Bad command \"LogIn\": \"$key\"\"$value\" Command should be \"-Type\", \"-Message\""
                }
            }
        }
        set tips_info "This is an infomation."
        set tips_err  "This is a serious error."
        set tips_warn "This is a warning, there occured some unexpected issues which may cause error."
        set tips_exce "This is a fatal error, which invoke such exceptions."        
        switch -exact -- $type {
            ERR {
                puts $IOhandle "$now $type: $tips_err \n $infos \n $tag \n"
                if { $IxiaCapi::ErrOutPut } {
                    puts stderr "$type: $tips_err \n $infos \n $tag \n"
                }
            }
            WARN { puts $IOhandle "$now $type: $tips_warn \n $infos \n $tag \n" }
            INFO {
                #puts $IOhandle "$now $type: $tips_info \n $infos \n $tag \n"
                puts $IOhandle "$now $type: $infos "
            }
            EXCEPTION {
                puts $IOhandle "$now $type: $tips_exce \n $infos \n $tag \n"
                error "$now $type: $tips_exce \n $infos \n $tag \n"
            }
        }
    }
    
    body Logger::SetEnum {} {
        # Usually,
        # INFO is used to represent informations like :
        #   Connect to host by IP address... 192.168.1.1
        # WARN is used to make focus on some obsolete or unappropriate usage :
        #   This method has been obsolete, please use "..." instead...
        # ERR is used to type the error to user screen but no error is invoked,
        #   when the err is selected no error will be invoked, distinguished with EXCEPTION.
        # EXCEPTION is used to terminate the programe and the error message will type to
        #   user's screen.
        set loggerType { INFO WARN ERR EXCEPTION }
    }
    
    # LogIn --
    # static procedure : To use this one will help programmer to debug step by step with
    #                   help of log.
    proc LogIn { args } {
        Logger log
        if { [ catch {
            eval {log LogIn} $args
        } result ] } {
            delete object log
            error $result
        }
        delete object log
    }
    
}