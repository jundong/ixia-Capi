
namespace eval IxiaCapi {

    proc GetStandardReturnHeader {} {
#    set statFormat "%10s : %10s"    
#    set ret "[ format $statFormat "Status" "true" ]\n"
#    set ret "$ret[ format $statFormat "Log" "" ]\n"
	    set ret "Status:true\nLog:\n"
        return $ret
    }
	
	
    proc GetErrorReturnHeader { log } {
#    set statFormat "%10s : %10s"    
#    set ret "[ format $statFormat "Status" "false" ]\n"
#    set ret "$ret[ format $statFormat "Log" "$log" ]\n"
	    set ret "Status:false\nLog:$log\n"
        return $ret
    }
	
	proc GetStandardReturnBody { key value } {
#    set statFormat "%10s : %10s"    
#    set ret "[ format $statFormat "$key" "$value" ]\n"
	    set ret "$key:$value\n"
        return $ret
    }
	
	proc NamespaceConvert { namelist templist } {
	    set newlist ""
	    foreach name $namelist {   
Deputs Step30            
            if { [ lsearch -regexp $templist .*$name ] < 0 } {               
Deputs Step40
                IxiaCapi::Logger::LogIn -type warn -message "$IxiaCapi::s_common1 \n\t \
                $name is not exist" -tag $tag
                set warn 1
                continue
            }
    # If positive to destroy it
            if { [ catch {
                set nameIndex [ lsearch -regexp $templist .*$name ]
                lappend newlist [lindex $templist $nameIndex]

            } result ] } {
                IxiaCapi::Logger::LogIn -type err -message "$errorInfo" -tag $tag
                return $fail
            } 
            
        }
        return $newlist
    }
	
	proc NamespaceDefine { namelist } {
	    set newlist ""
	    foreach name $namelist { 
            set predef [namespace parent ::IxiaCapi]
            #Deputs "predef:$predef"	
            if {$predef == "::" } {
                set predef ""
            }
			#Deputs "predef:$predef"
            #lappend newlist ::IxiaCapi::$name
            if { [regexp {^:+([0-9a-zA-Z_]+)$} $name n newname] == 1 } {
			   Deputs "newname: $newname"
                lappend newlist ${predef}::${newname} 
				Deputs "newlist: $newlist"
            } else {
			    lappend newlist ${predef}::${name}
				Deputs "newlist: $newlist"
            }
            
        }
        return $newlist
    }
   
    
    class ProtocolConvertObject {
        inherit NetObject
        public variable argslist
        #public variable objname
        #public variable classname
        public variable newargs
        constructor {} { }
        method convert { args } {
            set newargs {}
            foreach { key value } $args {
                set key [string tolower $key]
				if { [info exists argslist($key) ] } {
			Deputs $key
			Deputs $argslist($key)
			Deputs $value
					lappend newargs $argslist($key)
					lappend newargs $value
				}
                
            }
        }
    }
	
	class PoolNameObject {
        inherit NetObject       
        constructor {} {
		Deputs "-------PoolNameObject-----"
		}
		method configHandle { Handle } {
		Deputs "-------PoolNameObject:configHandle $Handle-----"
		    set handle $Handle
		}
        
    }
}

