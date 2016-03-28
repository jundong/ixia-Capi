# Change made
# Version 1.0

class CSTCPort {
    method GetPortLocation {  args  } {}
    method GetPortType {  args  } {}
    method GetChassisHandle {  args  } {}
}

body TestPort::GetPortLocation { args } {
    set list [split $m_portLocation /]
    set slotId [lindex $list 1]
    set portId [lindex $list 2]   
    return $slotId/$portId;
}

body TestPort::GetPortType { args } {
    # iTCϵͳ�е������˿ڣ�����ΪTen-GigabitEthernet��GigabitEthernet��ʹ��HLAPI�ӿ�ʱ���ᴴ���˿�ʧ�� 
    if {[regexp -nocase "ethernet" $m_PortType]} {
        return "ethernet"
    } else {
        return $m_PortType
    }
}

body TestPort::GetChassisHandle { args } {
    if {[catch { 
        if {$pFlag} {
            eval "uplevel #0 \{TestDevice $hChassisName $_host \}"    
        } else {
            eval "uplevel #0 \{TestDevice $hChassisName $_host \}"                       
        }
    } err]} {   
        puts "GetChassisHandle Fail: $err"
        return $::CIxia::gIxia_ERR
    }
   
    return $::CIxia::gIxia_OK
}