#====================================================================
# �汾�ţ�1.0
#   
# �ļ�����Ixia_CRipRouter.tcl
# 
# �ļ�������IxiaCapi����Ripv4·����
# 
# ���ߣ�����ʯ(Shawn Li)
#
# ����ʱ��: 2009.02.06
#
# �޸ļ�¼�� 
#   
# ��Ȩ���У�Ixia
#====================================================================

#====================================================================
# ������:                                                           
#    ::RipRouter    by Shawn Li                                               
# ����:                                                               
#    ����Ϊ���࣬�������о���˿ڵĹ�ͬ���� 
#    ���ࣺ��                                                       
#    ���ࣺ����Ķ˿��࣬������̫���˿��ࡢ������·�˿����                                                      
#    ����ࣺЭ������ࡢ���������������ͳ�Ʒ���������                                         
# �﷨����:                                                         
#    TestDevice ipaddress                                           
#    �磺TestDevice Tester1 192.168.0.100                           
#====================================================================

#====================================================================
# �汾�ţ�1.0
#   
# �ļ�����Ixia_CRouter.tcl
# 
# �ļ�������IxiaCapi����·����
# 
# ���ߣ�����ʯ(Shawn Li)
#
# ����ʱ��: 2009.02.06
#
# �޸ļ�¼�� 
#   
# ��Ȩ���У�Ixia
#====================================================================

#====================================================================
# ������:                                                           
#    ::Router    by Shawn Li                                               
# ����:                                                               
#    ·��Э����,���� 
#    ���ࣺ��                                                       
#    ���ࣺ�����·��Э���࣬���Rip��OSPF��BGP��ISIS��                                                      
#    ����ࣺ                                         
# �﷨����:                                                         
#    port1 CreateRouter -RouterName riprouter1 -RouterType RipRouter \
#                       -routerid 1.1.1.1                                        
#====================================================================

namespace eval IxiaCapi {
    
itcl::class RipRouter {
    namespace import ::IxiaCapi::*

    public variable m_portObjectId  ""    
    public variable m_chassisId     ""
    public variable m_slotId        ""
    public variable m_portId        ""
    public variable m_vportId       ""
    public variable m_intfId        ""
    public variable m_intfIpv4Id    ""
    public variable m_routerType    ""
    public variable m_routerId      ""
    public variable m_this          ""
    public variable m_namespace     ""
    public variable m_ixRouterId    ""
    
    public common   m_ripArgsArray
    set m_ripArgsArray(expirationinterval) 180
    set m_ripArgsArray(garbageinterval) 240
    set m_ripArgsArray(updateinterval) 30
    set m_ripArgsArray(triggeredinterval) 5
    set m_ripArgsArray(updatecontrol) poisonReverse
    set m_ripArgsArray(active) False
    set m_ripArgsArray(testip)   "192.85.1.1"
    set m_ripArgsArray(routerid) "192.85.1.1"
    set m_ripArgsArray(sutip) "192.85.1.2"
    set m_ripArgsArray(metric) 1
    
    public common m_ripFlapArgsArray
    set m_ripFlapArgsArray(interval) 10
    set m_ripFlapArgsArray(number)   2
    set m_ripFlapArgsArray(awdtimer) 5000
    set m_ripFlapArgsArray(wadtimer) 5000
    
    inherit Router
    constructor {portobj routertype routerid} \
    {Router::constructor $portobj $routertype $routerid} {
        set m_portObjectId $portobj
        set m_chassisId [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_chassisId]
        set m_slotId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_slotId]
        set m_portId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_portId]
        set m_vportId   [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_vportId]
        set m_routerType $routertype
        set m_routerId  $routerid
        set m_this      [namespace tail $this]
        set m_namespace [namespace qualifiers $this]
        set IxiaCapi::namespaceArray($m_this,namespace) $m_namespace

        #����rip·����
        #-------------
        ixNet setAttribute $m_vportId/protocols/rip -enabled 1
        set m_ixRouterId [ixNet add $m_vportId/protocols/rip router]
        ixNet setMultiAttrs $m_ixRouterId -enabled $m_ripArgsArray(active) \
        -responseMode $m_ripArgsArray(updatecontrol) -sendType broadcastV2 \
        -updateInterval $m_ripArgsArray(updateinterval)

        #�鿴�Ƿ���ں�Ĭ��testipһ�µ�interface
        #---------------------------------------
        set intfList [ixNet getList $m_vportId interface]
        foreach intf $intfList {
            set ipaddr [ixNet getAttribute $intf/ipv4 -ip]
             if {$ipaddr == $m_ripArgsArray(testip)} {
                set m_intfId $intf
                ixNet setAttribute $m_ixRouterId -interfaceId $m_intfId
                ixNet commit
                break
            }
        }        
        set m_ixRouterId [ixNet remapIds $m_ixRouterId]
        ixNet commit
    }
    
    
    destructor {
    }

    public method ConfigRouter
    public method GetRouter
    public method Enable
    public method Disable
    public method CreateRouterBlock    
    public method ConfigRouterBlock
    public method DeleteRouterBlock
    public method ListRouterBlock
    public method GetRouteBlock
	public method ixConvertToLowerCase
    
    public method AdvertiseRouteBlock
    public method WithdrawRouteBlock
    public method StopFlapRouteBlock
    public method StartFlapRouteBlock    
    public method ConfigFlapRouterBlock
    public method GetRouterStats
    
}

itcl::body RipRouter::ixConvertToLowerCase {value} {
	    set  key [string tolower $value]
		return $key
	}

#====================================================================
# ��������:ConfigRouter by Shawn Li 2009.2.9                                                  
# ����:����Rip Router�Ĺ���ģʽ
# ����:
# -SutIp:�����豸Rip Router��IP��ַ,��ѡ
# -TestIp:�����Ƿ����Rip Router��IP��ַ,��ѡ
# -Metric:·�ɻ���ֵ,��ѡ,1
# -ExpirationInterval:Expiration��ʱ��,��λ:ms,��ѡ,10
# -GarbageInterval:Garbage��ʱ��,��λ:ms,��ѡ
# -UpdateInterval:Update��ʱ��,��λ:ms,��ѡ,10
# -TriggeredInterval:�������¼�ʱ��,��λ:ms,��ѡ
# -UpdateControl:PoisonedReverse����SplitHorizon����None
# -Active:ʹ�ܱ�־,TRUE/FALSE,��ѡ
# -RouterID
# �﷨����:                                                         
#    rip1 ConfigRouter �CSutIp 1.1.1.1 -TestIp 1.1.1.2 -Active true                                     
# ����ֵ��                                                          
#    �ɹ�0��ʧ��1��                         
#====================================================================
itcl::body RipRouter::ConfigRouter {args} {
    ixDebugPuts "Enter proc RipRouter::ConfigRouter...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    if {![info exists args_array(-sutip)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -SutIp."
        return $::FAILURE      
    } else {
        set m_ripArgsArray(sutip) $args_array(-sutip)
    }
    if {![info exists args_array(-testip)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -TestIp."
        return $::FAILURE      
    } else {
        #��testip������interface��ip���бȽ�
        #��ipһ������Ϊrouter��ģ��ӿ�
        #-----------------------------------
        set m_ripArgsArray(testip) $args_array(-testip)
        set intfList [ixNet getList $m_vportId interface]
        foreach intf $intfList {
            set ipaddr [ixNet getAttribute $intf/ipv4 -ip]
            if {$ipaddr == $args_array(-testip)} {
                set m_intfId $intf
                ixNet setAttribute $m_ixRouterId -interfaceId $m_intfId
                ixNet commit
                break
            }             
        }
        if {$m_intfId == ""} {
            set ::ERRINFO "$procname: No such interface with ip address $args_array(-testip) defined."
            return $::FAILURE     
        }
    }
    if {[info exists args_array(-metric)]} {
        set m_ripArgsArray(metric) $args_array(-metric)
    }    
    if {[info exists args_array(-expirationinterval)]} {
        set m_ripArgsArray(expirationinterval) $args_array(-expirationinterval)
    }
    if {[info exists args_array(-garbageinterval)]} {
        set m_ripArgsArray(garbageinterval) $args_array(-garbageinterval)
    }
    if {[info exists args_array(-updateinterval)]} {
        set m_ripArgsArray(updateinterval) $args_array(-updateinterval)
    }
    if {[info exists args_array(-triggeredinterval)]} {
        set m_ripArgsArray(triggeredinterval) $args_array(-triggeredinterval)
    }
    
    #comments by shawn 20090401
    #�˴���Ҫ���updatecontrol������ֵ�����޸�
    #-----------------------------------------
    if {[info exists args_array(-updatecontrol)]} {
        set m_ripArgsArray(updatecontrol) $args_array(-updatecontrol)
    }
    if {[info exists args_array(-active)]} {
        set active [string tolower $args_array(-active)]     
        set m_ripArgsArray(active) [string map {true 1 enable 1 on 1 false 0 disable 0 off 0} $active]
    }
    if {[info exists args_array(-routerid)]} {
        set m_ripArgsArray(routerid) $args_array(-routerid)
    }     
    ixNet setMultiAttrs $m_ixRouterId \
        -enabled $m_ripArgsArray(active)\
        -responseMode $m_ripArgsArray(updatecontrol) \
        -sendType broadcastV2 \
        -updateInterval $m_ripArgsArray(updateinterval) 
    ixNet commit    
    set m_ixRouterId [ixNet remapIds $m_ixRouterId]
        
    return $::SUCCESS     
}


itcl::body RipRouter::GetRouter {args} {
    ixDebugPuts "Enter proc RipRouter::GetRouter...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }    
    foreach {option value} [array get args_array] {
        switch -- $option {
            "-sutip" {
                upvar $value arg
                set arg $m_ripArgsArray(sutip)}
            "-testip" {
                upvar $value arg
                set arg [ixNet getAttribute $m_intfId/ipv4 -ip]}
            "-prefixlen" {
                upvar $value arg
                set arg [ixNet getAttribute $m_intfId/ipv4 -maskWidth]}
            "-metric" {
                upvar $value arg
                set arg $m_ripArgsArray(metric)}
            "-expirationinterval" {
                upvar $value arg
                set arg $m_ripArgsArray(expirationinterval)}
            "-garbageinterval" {
                upvar $value arg
                set arg $m_ripArgsArray(garbageinterval)}
            "-updateinterval" {
                upvar $value arg
                set arg [ixNet getAttribute $m_ixRouterId -updateInterval]}
            "-triggeredinterval" {
                upvar $value arg
                set arg $m_ripArgsArray(triggeredinterval)}
            "-updatecontrol" {
                upvar $value arg
                set arg [ixNet getAttribute $m_ixRouterId -responseMode]}
            "-version" {
                upvar $value arg
                set arg [ixNet getAttribute $m_ixRouterId -sendType]}
            "-state" {
                upvar $value arg
                set arg [ixNet getAttribute $m_vportId/protocols/rip -runningState]}
            "-active" {
                upvar $value arg
                set arg [ixNet getAttribute $m_ixRouterId -enabled]}
            "-routerid" {
                upvar $value arg
                set arg $m_ripArgsArray(routerid)}
            default {
                set ::ERRINFO "$procname: No such args supported."
            }
        }
    }
    return $::SUCCESS
}    

itcl::body RipRouter::Enable {args} {
    ixDebugPuts "Enter proc RipRouter::Enable...\n"
    ixNet setAttribute $m_ixRouterId -enabled True
    ixNet commit
    set m_ixRouterId [ixNet remapIds $m_ixRouterId]
    return $::SUCCESS 
}


itcl::body RipRouter::Disable {args} {
    ixDebugPuts "Enter proc RipRouter::Disable...\n"
    ixNet setAttribute $m_ixRouterId -enabled False
    ixNet commit
    set m_ixRouterId [ixNet remapIds $m_ixRouterId]
    return $::SUCCESS     
}

itcl::body RipRouter::CreateRouterBlock {args} {
    ixDebugPuts "Enter proc RipRouter::CreateRouterBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    
    #�ж��Ƿ��Ѿ����ڴ�block����
    #---------------------------
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -BlockName."
        return $::FAILURE      
    } else {
        if {[info exists m_ripArgsArray($args_array(-blockname),name)]} {
            set ::ERRINFO "$procname: Block name $args_array(-blockname) already exists."
            return $::FAILURE 
        } else {
            set m_ripArgsArray($args_array(-blockname),name) $args_array(-blockname)
        }
    }
    if {![info exists args_array(-metric)]} {
        set m_ripArgsArray($args_array(-blockname),metric) 1
    } else {
        set m_ripArgsArray($args_array(-blockname),metric) $args_array(-metric)
    }    
    if {![info exists args_array(-routetag)]} {
        set m_ripArgsArray($args_array(-blockname),routetag) 0
    } else {
        set m_ripArgsArray($args_array(-blockname),routetag) $args_array(-routetag)
    }  
    if {![info exists args_array(-nexthop)]} {
        set m_ripArgsArray($args_array(-blockname),nexthop) "192.85.0.1"
    } else {
        set m_ripArgsArray($args_array(-blockname),nexthop) $args_array(-nexthop)
    }  
    if {![info exists args_array(-flagflap)]} {
        set m_ripArgsArray($args_array(-blockname),flagflap) "False"
    } else {
        set arg [string tolower $args_array(-flagflap)]
        set arg [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $arg]           
        set m_ripArgsArray($args_array(-blockname),flagflap) $arg
    }  
    if {![info exists args_array(-startipaddress)]} {
        set m_ripArgsArray($args_array(-blockname),startipaddress) "10.0.0.1"
    } else {
        set m_ripArgsArray($args_array(-blockname),startipaddress) $args_array(-startipaddress)
    }  
   if {![info exists args_array(-number)]} {
        set m_ripArgsArray($args_array(-blockname),number) "1"
    } else {
        set m_ripArgsArray($args_array(-blockname),number) $args_array(-number)
    } 
   if {![info exists args_array(-prefixlength)]} {
        set m_ripArgsArray($args_array(-blockname),prefixlength) "24"
    } else {
        set m_ripArgsArray($args_array(-blockname),prefixlength) $args_array(-prefixlength)
    } 
   if {![info exists args_array(-modifier)]} {
        set m_ripArgsArray($args_array(-blockname),modifier) "1"
    } else {
        set m_ripArgsArray($args_array(-blockname),modifier) $args_array(-modifier)
    } 
   if {![info exists args_array(-active)]} {
        set m_ripArgsArray($args_array(-blockname),active) "True"
    } else {
        set arg [string tolower $args_array(-active)]
        set arg [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $arg]         
        set m_ripArgsArray($args_array(-blockname),active) $arg
    }
   if {![info exists args_array(-flagtrafficdestination)]} {
        set m_ripArgsArray($args_array(-blockname),flagtrafficdestination) "True"
    } else {
        set arg [string tolower $args_array(-flagtrafficdestination)]
        set arg [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $arg]        
        set m_ripArgsArray($args_array(-blockname),flagtrafficdestination) $arg
    }
   if {![info exists args_array(-flagadvertise)]} {
        set m_ripArgsArray($args_array(-blockname),flagadvertise) "True"
    } else {
        set arg [string tolower $args_array(-flagadvertise)]
        set arg [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $arg]
        set m_ripArgsArray($args_array(-blockname),flagadvertise) $arg
    }     
    set m_ripArgsArray($args_array(-blockname),id) [ixNet add $m_ixRouterId routeRange]
    ixNet setMultiAttrs $m_ripArgsArray($args_array(-blockname),id) \
        -enabled $m_ripArgsArray($args_array(-blockname),active) \
        -firstRoute $m_ripArgsArray($args_array(-blockname),startipaddress)\
        -maskWidth $m_ripArgsArray($args_array(-blockname),prefixlength) \
        -metric $m_ripArgsArray($args_array(-blockname),metric) \
        -nextHop $m_ripArgsArray($args_array(-blockname),nexthop) \
        -noOfRoutes $m_ripArgsArray($args_array(-blockname),number) \
        -routeTag $m_ripArgsArray($args_array(-blockname),routetag)
    ixNet commit
    set m_ripArgsArray($args_array(-blockname),id) [ixNet remapIds $m_ripArgsArray($args_array(-blockname),id)]
    return $::SUCCESS     
}

itcl::body RipRouter::ConfigRouterBlock {args} {
    ixDebugPuts "Enter proc RipRouter::ConfigRouterBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    
    #��������ڴ�block�����򱨴�
    #-----------------------------
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -BlockName."
        return $::FAILURE      
    } else {
        if {![info exists m_ripArgsArray($args_array(-blockname),name)]} {
            set ::ERRINFO "$procname: Block name $args_array(-blockname) does not exist."
            return $::FAILURE 
        }
    }
    foreach {option value} [array get args_array] {
        switch -- $option {
            "-blockname" {}
            "-metric" {
                set m_ripArgsArray($args_array(-blockname),metric) $value}
            "-routetag" {
                set m_ripArgsArray($args_array(-blockname),routetag) $value}
            "-nexthop" {
                set m_ripArgsArray($args_array(-blockname),nexthop) $value}
            "-flagflap" {
                set value [string tolower $value]
                set value [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $value]                  
                set m_ripArgsArray($args_array(-blockname),flagflap) $value}
            "-startipaddress" {
                set m_ripArgsArray($args_array(-blockname),startipaddress) $value}
            "-number" {
                set m_ripArgsArray($args_array(-blockname),number) $value}
            "-prefixlength" {
                set m_ripArgsArray($args_array(-blockname),prefixlength) $value}
            "-modifier" {
                set m_ripArgsArray($args_array(-blockname),modifier) $value}
            "-active" {
                set value [string tolower $value]
                set value [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $value]                  
                set m_ripArgsArray($args_array(-blockname),active) $value}
            "-flagtrafficdestination" {
                set value [string tolower $value]
                set value [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $value]                   
                set m_ripArgsArray($args_array(-blockname),flagtrafficdestination) $value}
            "-flagadvertise" {
                set m_ripArgsArray($args_array(-blockname),flagadvertise) $value}
            default {
                set ::ERRINFO "$procname: No such args $option supported."
                ixDebugPuts $::ERRINFO
            }
        }
    }    
    ixNet setMultiAttrs $m_ripArgsArray($args_array(-blockname),id) \
        -enabled $m_ripArgsArray($args_array(-blockname),active) \
        -firstRoute $m_ripArgsArray($args_array(-blockname),startipaddress)\
        -maskWidth $m_ripArgsArray($args_array(-blockname),prefixlength) \
        -metric $m_ripArgsArray($args_array(-blockname),metric) \
        -nextHop $m_ripArgsArray($args_array(-blockname),nexthop) \
        -noOfRoutes $m_ripArgsArray($args_array(-blockname),number) \
        -routeTag $m_ripArgsArray($args_array(-blockname),routetag)
    ixNet commit
    set m_ripArgsArray($args_array(-blockname),id) [ixNet remapIds $m_ripArgsArray($args_array(-blockname),id)]
    return $::SUCCESS     
}

itcl::body RipRouter::DeleteRouterBlock {args} {
    ixDebugPuts "Enter proc RipRouter::DeleteRouterBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    if {![info exists args_array(-routeblockname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouteBlockName."
        return $::FAILURE      
    } else {
        if {![info exists m_ripArgsArray($args_array(-routeblockname),name)]} {
            set ::ERRINFO "$procname: Block name $args_array(-routeblockname) does not exist."
            return $::FAILURE 
        } else {
            ixNet remove  $m_ripArgsArray($args_array(-routeblockname),id)
            ixNet commit
            array unset m_ripArgsArray "$args_array(-routeblockname),*"
        }
    } 
    return $::SUCCESS    
}

itcl::body RipRouter::ListRouterBlock {args} {
    ixDebugPuts "Enter proc RipRouter::ListRouterBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    set rbnamelist ""
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    if {![info exists args_array(-routeblocknamelist)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouteBlockNameList."
        return $::FAILURE      
    } else {
        upvar $args_array(-routeblocknamelist) arg
        set namelist [array names m_ripArgsArray "*,name"]
        foreach name $namelist {
            lappend rbnamelist $m_ripArgsArray($name)
            set arg $rbnamelist
        }
    }
    return $::SUCCESS 
}


itcl::body RipRouter::GetRouteBlock {args} {
    ixDebugPuts "Enter proc RipRouter::GetRouteBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -BlockName."
        return $::FAILURE      
    } else {
        if {![info exists m_ripArgsArray($args_array(-blockname),name)]} {
            set ::ERRINFO "$procname: Block name $args_array(-blockname) does not exist."
            return $::FAILURE 
        } else {
            foreach {option value} [array get args_array] {
                switch -- $option {
                    "-blockname" {}
                    "-metric" {
                        upvar $value arg
                        set arg [ixNet getAttribute $m_ripArgsArray($args_array(-blockname),id) -metric]}
                    "-routetag" {
                        upvar $value arg
                        set arg [ixNet getAttribute $m_ripArgsArray($args_array(-blockname),id) -routeTag]}
                    "-nexthop" {
                        upvar $value arg
                        set arg [ixNet getAttribute $m_ripArgsArray($args_array(-blockname),id) -nextHop]}
                    "-startipaddress" {
                        upvar $value arg
                        set arg [ixNet getAttribute $m_ripArgsArray($args_array(-blockname),id) -firstRoute]}
                    "-prefixlength" {
                        upvar $value arg
                        set arg [ixNet getAttribute $m_ripArgsArray($args_array(-blockname),id) -maskWidth]}
                    "-number" {
                        upvar $value arg
                        set arg [ixNet getAttribute $m_ripArgsArray($args_array(-blockname),id) -noOfRoutes]}
                    "-active" {
                        upvar $value arg
                        set arg [ixNet getAttribute $m_ripArgsArray($args_array(-blockname),id) -enabled]}
                    "-flagflap" {
                        upvar $value arg
                        set arg $m_ripArgsArray($args_array(-blockname),flagflap)}
                    "-modify" {
                        upvar $value arg
                        set arg $m_ripArgsArray($args_array(-blockname),modifier)}
                    "-flagtrafficdestination" {
                        upvar $value arg
                        set arg $m_ripArgsArray($args_array(-blockname),flagtrafficdestination)}
                    "-advertise" {
                        upvar $value arg
                        set arg $m_ripArgsArray($args_array(-blockname),flagadvertise)}
                    default {
                        set ::ERRINFO "$procname: No such args $option supported."
                    }                        
                }
            }
        }
    }
    return $::SUCCESS 
}

itcl::body RipRouter::AdvertiseRouteBlock {args} {
    ixDebugPuts "Enter proc RipRouter::AdvertiseRouteBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    #������routeblock��ʼ״̬��Ϊdisable
    #����ͨ������routeblock��״̬��ʵ�ַ��ͣ�����·��
    #------------------------------------------------
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -BlockName."
        return $::FAILURE      
    } else {
        if {![info exists m_ripArgsArray($args_array(-blockname),name)]} {
            set ::ERRINFO "$procname: Block name $args_array(-blockname) does not exist."
            return $::FAILURE 
        } else {
            ixNet setAttribute $m_ripArgsArray($args_array(-blockname),id) -enabled 1
            ixNet commit            
        }
    }
    return $::SUCCESS 
}

itcl::body RipRouter::WithdrawRouteBlock {args} {
    ixDebugPuts "Enter proc RipRouter::WithdrawRouteBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    #�Ա�ѡ����blockname���ж�
    #-------------------------
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -BlockName."
        return $::FAILURE      
    } else {
        #��������blockname��������ʾ������Ϣ
        #-----------------------------------------
        if {![info exists m_ripArgsArray($args_array(-blockname),name)]} {
            set ::ERRINFO "$procname: Block name $args_array(-blockname) does not exist."
            return $::FAILURE 
        } else {
            #����block������Ϊdisabled
            #--------------------------
            ixNet setAttribute $m_ripArgsArray($args_array(-blockname),id) -enabled 0
            ixNet commit            
        }
    }
    return $::SUCCESS 
}


itcl::body RipRouter::StartFlapRouteBlock {args} {
    ixDebugPuts "Enter proc RipRouter::StartFlapRouteBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    if {[info exists args_array(-number)]} {
        set m_ripFlapArgsArray(number) $args_array(-number)    
    }
    #�������blockname����ֻ�޸Ĵ�block��״̬
    #----------------------------------------
    if {[info exists args_array(-blockname)]} {
        for {set i 1} {$i <= $m_ripFlapArgsArray(number)} {incr i} {
            ixDebugPuts "------Number of flapping: $i time-----"
            ixDebugPuts "Advertising"
            ixNet setAttribute $m_ripArgsArray($args_array(-blockname),id) -enabled 1
            ixNet commit
            ixDebugPuts "wait for $m_ripFlapArgsArray(awdtimer) ms"
            after $m_ripFlapArgsArray(awdtimer)
            ixDebugPuts "WithDraw"
            ixNet setAttribute $m_ripArgsArray($args_array(-blockname),id) -enabled 0
            ixNet commit
            ixDebugPuts "wait for $m_ripFlapArgsArray(wadtimer) ms"
            after $m_ripFlapArgsArray(wadtimer)
        }  
    } else {
        #�����޸�����ʹ���𵴵�block��״̬
        #---------------------------------
        foreach rbname [array names m_ripArgsArray "*,name"] {
            set flagflap [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $m_ripArgsArray($rbname,flagflap)]
            if {$flagflap == 1} {
                for {set i 1} {$i <= $m_ripFlapArgsArray(number)} {incr i} {
                    ixNet setAttribute $m_ripArgsArray($nbname,id) -enabled 1
                    ixNet commit
                    after $m_ripFlapArgsArray(awdtimer)
                    ixNet setAttribute $m_ripArgsArray($nbname,id) -enabled 0
                    ixNet commit
                    after $m_ripFlapArgsArray(wadtimer)
                }
            }
        }        
    }

    return $::SUCCESS 
}

itcl::body RipRouter::StopFlapRouteBlock {args} {
    ixDebugPuts "Enter proc RipRouter::StopFlapRouteBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    
    #�������blockname�������ô�block��״̬Ϊdisable
    #-----------------------------------------------
    if {[info exists args_array(-blockname)]} {
        ixNet setAttribute $m_ripArgsArray($args_array(-blockname),id) -enabled 0
        ixNet commit
    } else {
        #�����޸����д���flapflag��ʶ��block��״̬Ϊ0
        #--------------------------------------------
        foreach rbname [array names m_ripArgsArray "*,name"] {
            set flagflap [string map {true 1 enable 1 on 1 yes 1 false 0 disable 0 off 0 no 0} $m_ripArgsArray($rbname,flagflap)]
            if {$flagflap == 1} {
                ixNet setAttribute $m_ripArgsArray($nbname,id) -enabled 0
                ixNet commit
            }
        }        
    }    
    return $::SUCCESS 
}

itcl::body RipRouter::ConfigFlapRouterBlock {args} {
    ixDebugPuts "Enter proc RipRouter::ConfigFlapRotuerBlock...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO "$procname: $error."
        return $::FAILURE
    }
    #�������awdtimer��wadtimer��������ֵ���������Ĭ��ֵ
    #-------------------------------------------------------
    if {[info exists args_array(-awdtimer)]} {
        set m_ripFlapArgsArray(awdtimer) $args_array(-awdtimer)    
    }
    if {[info exists args_array(-wadtimer)]} {
        set m_ripFlapArgsArray(wadtimer) $args_array(-wadtimer)    
    }
    
    #===========================================================
    #modified by shawn 20090707
    #comments: ����ZTE����Ҫ��ȥ��interval������number�ŵ�startFlap��������
    #if {[info exists args_array(-interval)]} {
    #    set m_ripFlapArgsArray(interval) $args_array(-interval)    
    #}
    #if {[info exists args_array(-number)]} {
    #    set m_ripFlapArgsArray(number) $args_array(-number)    
    #}    
    return $::SUCCESS 
}


itcl::body RipRouter::GetRouterStats {args} {
    ixDebugPuts "Enter proc RipRouter::GetRouterStats...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]


    return $::SUCCESS 
}

    
}



