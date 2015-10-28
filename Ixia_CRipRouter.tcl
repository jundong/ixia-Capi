#====================================================================
# 版本号：1.0
#   
# 文件名：Ixia_CRipRouter.tcl
# 
# 文件描述：IxiaCapi库中Ripv4路由类
# 
# 作者：李霄石(Shawn Li)
#
# 创建时间: 2009.02.06
#
# 修改记录： 
#   
# 版权所有：Ixia
#====================================================================

#====================================================================
# 类名称:                                                           
#    ::RipRouter    by Shawn Li                                               
# 描述:                                                               
#    该类为虚类，抽象所有具体端口的共同特征 
#    父类：无                                                       
#    子类：具体的端口类，比如以太网端口类、低速链路端口类等                                                      
#    相关类：协议仿真类、流量发送引擎类和统计分析引擎类                                         
# 语法描述:                                                         
#    TestDevice ipaddress                                           
#    如：TestDevice Tester1 192.168.0.100                           
#====================================================================

#====================================================================
# 版本号：1.0
#   
# 文件名：Ixia_CRouter.tcl
# 
# 文件描述：IxiaCapi库中路由类
# 
# 作者：李霄石(Shawn Li)
#
# 创建时间: 2009.02.06
#
# 修改记录： 
#   
# 版权所有：Ixia
#====================================================================

#====================================================================
# 类名称:                                                           
#    ::Router    by Shawn Li                                               
# 描述:                                                               
#    路由协议类,虚类 
#    父类：无                                                       
#    子类：具体的路由协议类，如果Rip，OSPF，BGP，ISIS等                                                      
#    相关类：                                         
# 语法描述:                                                         
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

        #创建rip路由器
        #-------------
        ixNet setAttribute $m_vportId/protocols/rip -enabled 1
        set m_ixRouterId [ixNet add $m_vportId/protocols/rip router]
        ixNet setMultiAttrs $m_ixRouterId -enabled $m_ripArgsArray(active) \
        -responseMode $m_ripArgsArray(updatecontrol) -sendType broadcastV2 \
        -updateInterval $m_ripArgsArray(updateinterval)

        #查看是否存在和默认testip一致的interface
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
# 函数名称:ConfigRouter by Shawn Li 2009.2.9                                                  
# 描述:配置Rip Router的工作模式
# 参数:
# -SutIp:被测设备Rip Router的IP地址,必选
# -TestIp:测试仪仿真的Rip Router的IP地址,必选
# -Metric:路由花费值,可选,1
# -ExpirationInterval:Expiration计时器,单位:ms,可选,10
# -GarbageInterval:Garbage计时器,单位:ms,可选
# -UpdateInterval:Update计时器,单位:ms,可选,10
# -TriggeredInterval:触发更新计时器,单位:ms,可选
# -UpdateControl:PoisonedReverse或者SplitHorizon或者None
# -Active:使能标志,TRUE/FALSE,可选
# -RouterID
# 语法描述:                                                         
#    rip1 ConfigRouter –SutIp 1.1.1.1 -TestIp 1.1.1.2 -Active true                                     
# 返回值：                                                          
#    成功0，失败1；                         
#====================================================================
itcl::body RipRouter::ConfigRouter {args} {
    ixDebugPuts "Enter proc RipRouter::ConfigRouter...\n"
    set args     [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    
    #读取输入参数并进行赋值
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
        #将testip与所有interface的ip进行比较
        #将ip一样的设为router的模拟接口
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
    #此处需要针对updatecontrol的输入值进行修改
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
    
    #判断是否已经存在此block对象
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
    
    #如果不存在此block对象，则报错
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
    #创建的routeblock初始状态都为disable
    #这样通过设置routeblock的状态来实现发送，撤销路由
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
    #对必选参数blockname的判断
    #-------------------------
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -BlockName."
        return $::FAILURE      
    } else {
        #如果输入的blockname错误，则报提示错误信息
        #-----------------------------------------
        if {![info exists m_ripArgsArray($args_array(-blockname),name)]} {
            set ::ERRINFO "$procname: Block name $args_array(-blockname) does not exist."
            return $::FAILURE 
        } else {
            #设置block的属性为disabled
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
    #如果存在blockname，则只修改此block的状态
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
        #否则修改所有使能震荡的block的状态
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
    
    #如果存在blockname，则设置此block的状态为disable
    #-----------------------------------------------
    if {[info exists args_array(-blockname)]} {
        ixNet setAttribute $m_ripArgsArray($args_array(-blockname),id) -enabled 0
        ixNet commit
    } else {
        #否则修改所有带有flapflag标识的block的状态为0
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
    #如果输入awdtimer和wadtimer参数，则赋值；否则采用默认值
    #-------------------------------------------------------
    if {[info exists args_array(-awdtimer)]} {
        set m_ripFlapArgsArray(awdtimer) $args_array(-awdtimer)    
    }
    if {[info exists args_array(-wadtimer)]} {
        set m_ripFlapArgsArray(wadtimer) $args_array(-wadtimer)    
    }
    
    #===========================================================
    #modified by shawn 20090707
    #comments: 根据ZTE最新要求，去掉interval参数，number放到startFlap函数里面
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



