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
#    port1 CreateRouter -RouterName bgpRouter1 -RouterType BgpV4Router \
#                       -routerid 1.1.1.1                                        
#====================================================================

namespace eval IxiaCapi {
    
itcl::class Router {
    namespace import ::IxiaCapi::*
    
    public variable m_portObjectId      ""
    public variable m_chassisId         ""
    public variable m_slotId            ""
    public variable m_portId            ""
    public variable m_routerType        ""
    public variable m_routerId          ""
    
    public variable m_this              ""
    public variable m_namespace         ""
    
    constructor {portobj routertype {routerid 192.168.1.1}} {
        set m_portObjectId $portobj
        # set m_chassisId [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_chassisId]
        # set m_slotId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_slotId]
        # set m_portId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_portId]        
        set m_routerType $routertype
        set m_routerId   $routerid
        set m_this      [namespace tail $this]
        set m_namespace [namespace qualifiers $this]
        #set IxiaCapi::namespaceArray($m_this,namespace) $m_namespace
        
    }
    
    destructor {
    }
}

}