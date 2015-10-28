#Created by Shawn Li 20091209

namespace eval IxiaCapi {

    

itcl::class OspfRouter {
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
  public variable m_userLsaGroupId ""

  
  public common   m_ospfArgsArray
  set m_ospfArgsArray(testip) "192.85.1.1"
  set m_ospfArgsArray(testipprefix) "24"
  set m_ospfArgsArray(routerid) "192.85.1.1"
  set m_ospfArgsArray(area) "0"
  set m_ospfArgsArray(networktype) "broadcast"
  set m_ospfArgsArray(pduoptvalue) "ebit"
  set m_ospfArgsArray(sutip) "192.85.1.2"
  set m_ospfArgsArray(sutprefix) "24"
  set m_ospfArgsArray(sutrouterid) "192.85.1.2"
  set m_ospfArgsArray(flaggre) "false"
  set m_ospfArgsArray(grelocal) "false"
  set m_ospfArgsArray(greremote) "false"
  set m_ospfArgsArray(flaggreincludechecksum) "false"
  set m_ospfArgsArray(hellointerval) "10"
  set m_ospfArgsArray(deadinterval) "60"
  set m_ospfArgsArray(pollinterval) "40"
  set m_ospfArgsArray(retransmitinterval) "5"
  set m_ospfArgsArray(transitdelay) "1"
  set m_ospfArgsArray(interfacecost) "1"
  set m_ospfArgsArray(routerpriority) "0"
  set m_ospfArgsArray(mtu) "1500"
  set m_ospfArgsArray(maxlsasperpacket) "100"
  set m_ospfArgsArray(flaglasdiscardmode) "true"
  set m_ospfArgsArray(flaghostroute) "true"
  set m_ospfArgsArray(graceperiod) "120"
  set m_ospfArgsArray(restartinterval) "0"
  set m_ospfArgsArray(restartreason) "softrestart"
  set m_ospfArgsArray(active) "yes"
  set m_ospfArgsArray(authenicationtype) "none"
  set m_ospfArgsArray(password) "zte"
  set m_ospfArgsArray(md5keyid) "1"

  public common m_ospfNetElementArray 
  set m_ospfNetElementArray(namelist) ""
  
  public common m_ospfFlapArgsArray
  set m_ospfFlapArgsArray(number)   2
  set m_ospfFlapArgsArray(lsanumber) 2
  set m_ospfFlapArgsArray(awdtimer) 5000
  set m_ospfFlapArgsArray(wadtimer) 5000	

  #构造函数生成默认配置ospf路由器
  inherit Router
  constructor {portobj routertype  routerid} \
  {Router::constructor $portobj $routertype $routerid} {
    set m_portObjectId $portobj
    # set m_chassisId [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_chassisId]
    # set m_slotId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_slotId]
    # set m_portId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_portId]
    # set m_vportId   [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_vportId]
	set m_vportId [$portobj cget -hPort]
    set m_routerType $routertype
    set m_routerId  $routerid
    set m_this      [namespace tail $this]
    set m_namespace [namespace qualifiers $this]
    #set IxiaCapi::namespaceArray($m_this,namespace) $m_namespace
    
    ixNet setAttribute $m_vportId/protocols/ping -enabled True
    ixNet setAttribute $m_vportId/protocols/ospf -enabled True
    ixNet setAttribute $m_vportId/protocols/arp -enabled True
    
    #创建ospf路由器及相关参数
    set m_ixRouterId [ixNet add $m_vportId/protocols/ospf router]
    ixNet setAttribute $m_ixRouterId -discardLearnedLsa $m_ospfArgsArray(flaglasdiscardmode)  
    ixNet setAttribute $m_ixRouterId -enabled $m_ospfArgsArray(active)
    ixNet setAttribute $m_ixRouterId -routerId $m_routerId
    ixNet setAttribute $m_ixRouterId -supportForRfc3623 True
    ixNet setAttribute $m_ixRouterId -supportReasonSoftRestart True
    ixNet setAttribute $m_ixRouterId -supportReasonSoftReloadUpgrade False
    ixNet setAttribute $m_ixRouterId -supportReasonUnknown False
    ixNet setAttribute $m_ixRouterId -supportReasonSwotchRedundantCntrlProcessor False

	  #创建ospf interface及相关默认参数
 	  set m_intfId [ixNet add $m_ixRouterId interface]
		ixNet setMultiAttrs $m_intfId \
		 -areaId $m_ospfArgsArray(area) -authenticationMethods null \
		 -authenticationPassword $m_ospfArgsArray(password) -bBit False \
		 -connectedToDut True -deadInterval $m_ospfArgsArray(deadinterval) \
		 -eBit True -enabled True -helloInterval $m_ospfArgsArray(hellointerval) \
		 -md5AuthenticationKey {} -md5AuthenticationKeyId $m_ospfArgsArray(md5keyid) \
		 -metric $m_ospfArgsArray(interfacecost) -mtu $m_ospfArgsArray(mtu)\
		 -networkType $m_ospfArgsArray(networktype) -options 2 -priority $m_ospfArgsArray(routerpriority) 
	  
	  #创建LsaGroup,添加LSA使用 
		set m_userLsaGroupId [ixNet add $m_ixRouterId userLsaGroup] 
		ixNet setAttribute $m_userLsaGroupId -enabled True 
		ixNet setAttribute $m_userLsaGroupId -areaId $m_ospfArgsArray(area)
		
    #查看是否存在和默认testip一致的interface
    #如果存在则assign给ospf intf，否则ospf intf 为null
    set intfList [ixNet getList $m_vportId interface]
    foreach intf $intfList {
    	set ipaddr [ixNet getAttribute $intf/ipv4 -ip]
      if {$ipaddr == $m_ospfArgsArray(testip)} {
				ixNet setAttribute $m_intfId -protocolInterface $intf 
	      break
      } else {
      	Deputs "Warning:No interface with default ip:$m_ospfArgsArray(testip) created, please choose one using ConfigRouter method!"	
      } ;# end of if_else
    } ;#end of foreach_intf 
    ixNet commit       
    set m_ixRouterId [ixNet remapIds $m_ixRouterId]
    set m_intfId [ixNet remapIds $m_intfId]
    set m_userLsaGroupId [ixNet remapIds $m_userLsaGroupId]     
  }
  
  destructor {
  }

  public method ConfigRouter
  public method GetRouter
  public method Enable
  public method Disable
  
  public method AddTopGrid
  public method GetTopGrid
  public method GetTopGridRouter
  public method RemoveTopGrid
  
  public method AddTopRouter
  public method GetTopRouter
  public method ConfigTopRouter
  public method RemoveTopRouter
  
  public method AddTopNetwork
  public method ConfigTopNetwork
  public method RemoveTopNetwork
  
  public method AddTopRouterLink
  public method ConfigTopRouterLink
  public method RemoveTopRouterLink
  
  public method CreateTopSummaryRouteBlock
  public method ConfigTopSummaryRouteBlock
  public method GetTopSummaryRouteBlock
  public method DeleteTopSummaryRouteBlock
  
  public method CreateTopExternalRouteBlock
  public method ConfigTopExternalRouteBlock
  public method GetTopExternalRouteBlock
  public method DeleteTopExternalRouteBlock  
    
  public method AddRouterLsa
  public method AddRouterLsaLink
  public method RemoveRouterLsa
  public method AddNetworkLsa
  public method AddNetworkLsaRouter
  public method RemoveNetworkLsa
  public method AddAsExtLsa
  public method RemoveAsExtLsa
  public method AddSummaryLsa
  public method RemoveSummaryLsa
  
  public method AdvertiseLsas
  public method WithdrawLsas
  
  public method WithdrawRouters
  public method AdvertiseRouters
  
  public method ConfigFlap
  public method StartFlapRouters
  public method StopFlapRouters
  public method StartFlapLsas
  public method StopFlapLsas
  
  public method GraceRestartAction
  public method GetRouterStats 

  
  #目前不支持函数
  public method StopFlapLinks
  public method StartFlapLinks
  public method WithdrawLinks
  public method AdvertiseLinks
    

}


#====================================================================
# 函数名称:ConfigRouter by Shawn Li 20091214                                                 
# 描述: 配置OSPF Router 的所有可选配置属性
# 支持参数：
# 	Area,NetworkType,RouterID,PduOptionValue,FlagTE,NetworkType,InterfaceCost
#		HelloInterval,DeadInterval,InterfaceCost,MTU,FlagGraceRestart,RouterPriority
#   Active,AuthenticationType,Password,Md5KeyId,FlagLSADiscardMode,RestarReason
# 不支持参数：FlagGre,GreLocal,GreRemote,FlagGreIncludeChecksum,PollInterval
#		RetransmitInterval,MaxLSAsPerPacket,TransitDelay,GracePeriod,FlagHostRoute
#   
# 注释：IpAddr，SutIpAddress等接口相关参数由host指定，不需在此函数配置
#====================================================================
itcl::body OspfRouter::ConfigRouter {args} {
	Deputs "Enter proc OspfRouter::ConfigRouter...\n"
  set args     [IxiaCapi::Regexer::ixConvertAllToLowerCase $args]

  set procname [lindex [info level [info level]] 0]
  
  #读取输入参数并进行赋值
  #----------------------
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO "$procname: $error."
      return $::FAILURE
  }
  
  #判断是否已经有-ipaddr的host存在
  #如果存在将其assign给ospf intf否则报错
  if {[info exists args_array(-ipaddr)]} {
	  set intfList [ixNet getList $m_vportId interface]
	  foreach intf $intfList {
      set ipaddr [ixNet getAttribute $intf/ipv4 -ip]
      if {$ipaddr == $args_array(-ipaddr)} {
        ixNet setAttribute $m_intfId -protocolInterface $intf
        ixNet commit
        break
      } else {
        set ::ERRINFO "$procname: No host with ip:$args_array(-ipaddr) is created."
        return $::FAILURE
      } ;#end of if-else             
	  } ;#end of foreach
  } ;#end of if  
	
  #对ospf router和ospf intf支持的参数处理
  #Notes: 此处没有将ospf对象成员变量更新
  #---------------------------------------
  foreach {option value} [array get args_array] {
    switch -- $option {
      #对ospf router部分的配置
      "-active" {
      	set m_ospfArgsArray(active) $value
      	ixNet setAttribute $m_ixRouterId -enabled [IxiaCapi::Regexer::ixConvertBool $value]}
      "-discardlearnedlsa" {
      	set m_ospfArgsArray(flaglasdiscardmode) $value
      	ixNet setAttribute $m_ixRouterId -discardLearnedLsa [IxiaCapi::Regexer::ixConvertBool $value]}
      "-routerid" {
      	set m_ospfArgsArray(routerid) $value
      	ixNet setAttribute $m_ixRouterId -routerId $value}
      "-flaggracerestart" {      	
      	ixNet setAttribute $m_ixRouterId -supportForRfc3623 [IxiaCapi::Regexer::ixConvertBool $value]}
      "-restarreason" {
        switch -- $value {
          "unknown" {ixNet setAttribute $m_ixRouterId -supportReasonUnknown True}
      	  "softwarerestart" {ixNet setAttribute $m_ixRouterId -supportReasonSoftRestart True}
      	  "softreloadupgrade" {ixNet setAttribute $m_ixRouterId -supportReasonSoftReloadUpgrade True}
      	  "switchtoredundantcontrolprocessor" {ixNet setAttribute $m_ixRouterId -supportReasonSwotchRedundantCntrlProcessor True}	
      	} ;#end of swith restart_reason
      }
      #对ospf interface部分的配置
      "-area" {
      	if {[regexp {\d+.\d+.\d+.\d+} $value]} {
      		set value [split $value .]
      		set value [expr [expr [lindex $value 0]<<24] + \
           [expr [lindex $value 1]<<16] +[expr [lindex $value 2]<<8] +[lindex $value 3]]
      	}
      	set m_ospfArgsArray(area) $value
      	ixNet setAttribute $m_intfId -areaId $value
      	ixNet setAttribute $m_userLsaGroupId -areaId $value
      }
      "-networktype" { 
      	switch -- $value {
      		"broadcast" {ixNet setAttribute $m_intfId -networkType broadcast}
      		"nbma" {Deputs "Warning: No support for NBMA type."}
      		"p2mp" {ixNet setAttribute $m_intfId -networkType pointToMultipoint}
      		"p2p" {ixNet setAttribute $m_intfId -networkType pointToPoint}
      	} ;#end of switch networktype
      }
      "-pduoptionvalue" {
      	switch -- $value) {
      		"tbit" {ixNet setAttribute $m_intfId -options 1}
      		"ebit" {ixNet setAttribute $m_intfId -options 2}
      		"mcbit" {ixNet setAttribute $m_intfId -options 4}
      		"npbit" {ixNet setAttribute $m_intfId -options 80}
      		"eabit" {ixNet setAttribute $m_intfId -options 10}
      		"dcbit" {ixNet setAttribute $m_intfId -options 20}
      		"obit" {ixNet setAttribute $m_intfId -options 40}
          #建议此参数以10进制作为输入参数，IxNetwork可以直接批判相应bit
      	} ;#end of switch pduoption
      }
      "-flagte" {ixNet setAttribute $m_intfId -teEnable [IxiaCapi::Regexer::ixConvertBool $value]}
      "-hellointerval" {ixNet setAttribute $m_intfId -helloInterval $value}
      "-deadinterval" {ixNet setAttribute $m_intfId -deadInterval $value}
      "-interfacecost" {ixNet setAttribute $m_intfId -metric $value} 
      "-routerpriority" {ixNet setAttribute $m_intfId -priority $value}
      "-mtu" {ixNet setAttribute $m_intfId -mtu $value}
      "-active" {ixNet setAttribute $m_intfId -enabled [IxiaCapi::Regexer::ixConvertBool $value]}
      "-authenticationtype" {
      	switch -- $value {
      		"md5" {ixNet setAttribute $m_intfId -authenticationMethods md5}
      		"cleartext" {ixNet setAttribute $m_intfId -authenticationMethods password}
      		"noauthentication" {ixNet setAttribute $m_intfId -authenticationMethods null}
      	} 
      } ;#end of switch authen
      "-password" {ixNet setAttribute $m_intfId -authenticationPassword $value}
			"-md5keyid" {ixNet setAttribute $m_intfId -md5AuthenticationKeyId $value}
			"-sutrouterid" {ixNet setAttribute $m_intfId -neighborRouterId $value}
			"-sutipaddress" {ixNet setAttribute $m_intfId -neighborIpAddress $value}
		  #对ospf router和ospf intf不支持的参数处理
			"-flaggre" {set m_ospfArgsArray(flaggre) $value}
			"-grelocal" {set m_ospfArgsArray(grelocal) $value}
			"-greremote" {set m_ospfArgsArray(greremote) $value}
			"-flaggreincludechecksum" {set m_ospfArgsArray(flaggreincludechecksum) $value}
			"-pollinterval" {set m_ospfArgsArray(pollinterval) $value}
			"-retransmitinterval" {set m_ospfArgsArray(retransmitinterval) $value}
			"-maxlsasperpacket" {set m_ospfArgsArray(maxlsasperpacket) $value}
			"-transitdelay" {set m_ospfArgsArray(transitdelay) $value}
			"-graceperiod" {set m_ospfArgsArray(graceperiod) $value}
			"-flaghostroute" {set m_ospfArgsArray(flaghostroute) $value}
				
		  #不需在此函数里配置的参数IpAddr/PrefixLen/SutIpAddress/SutPrefixLen		
    };#end of switch option_value
  };#end of foreach
	ixNet commit
  
  return 1 
}

#====================================================================
# 函数名称:GetRouter by Shawn Li 20091218                                                 
# 描述: 获取OSPF Router 的所有可选配置属性
# 支持参数：
# 	Area,NetworkType,RouterID,PduOptionValue,FlagTE,NetworkType,InterfaceCost
#		HelloInterval,DeadInterval,InterfaceCost,MTU,FlagGraceRestart,RouterPriority
#   Active,AuthenticationType,Password,Md5KeyId,FlagLSADiscardMode,RestarReason
#   IpAddr/PrefixLen/SutIpAddress/SutPrefixLen/SutRouterID
# 不支持参数：FlagGre,GreLocal,GreRemote,FlagGreIncludeChecksum,PollInterval
#		RetransmitInterval,MaxLSAsPerPacket,TransitDelay,GracePeriod,FlagHostRoute
#====================================================================
itcl::body OspfRouter::GetRouter {args} {
	Deputs "Enter proc OspfRouter::GetRouter...\n"
  set args     [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #读取输入参数并进行赋值
  #----------------------
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO "$procname: $error."
      return $::FAILURE
  }
  foreach {option value} [array get args_array] {
  	upvar $value arg
    switch -- $option {
    #对ospf router部分的配置
      "-active" {set arg [ixNet getAttribute $m_ixRouterId -enabled]}
			"-flaglsadiscardmode" {set arg [ixNet getAttribute $m_ixRouterId -discardLearnedLsa]}
      "-routerid" {set arg [ixNet getAttribute $m_ixRouterId -routerId]}	
      "-flaggracerestart" {set arg [ixNet getAttribute $m_ixRouterId -supportForRfc3623]}
      "-restartreason" {
        if {[ixNet getAttribute $m_ixRouterId -supportReasonUnknown]} {lappend arg "supportReasonUnknown"}
        if {[ixNet getAttribute $m_ixRouterId -supportReasonSoftRestart]} {lappend arg "supportReasonSoftRestart"}
        if {[ixNet getAttribute $m_ixRouterId -supportReasonSoftReloadUpgrade]} {lappend arg "supportReasonSoftReloadUpgrade"}
        if {[ixNet getAttribute $m_ixRouterId -supportReasonSwotchRedundantCntrlProcessor]} {lappend arg "supportReasonSwotchRedundantCntrlProcessor"}	
      }
			"-ipaddr" {set arg [ixNet getAttribute $m_intfId -interfaceIpAddress]}
      "-prefixlen" {set arg [ixNet getAttribute $m_intfId -interfaceIpMaskAddress]}
      "-sutipaddress" {set arg [ixNet getAttribute $m_intfId -neighborIpAddress]}
      "-sutrouterid" {set arg [ixNet getAttribute $m_intfId -neighborRouterId]}
      "-area" {set arg [ixNet getAttribute $m_intfId -areaId]}          		
      "-networktype" {set arg [ixNet getAttribute $m_intfId -networkType]}
      "-pduoptionvalue" {set arg [ixNet getAttribute $m_intfId -options]}
      "-flagte" {set arg [ixNet getAttribute $m_intfId -teEnable]}
      "-hellointerval" {set arg [ixNet getAttribute $m_intfId -helloInterval]}
      "-deadinterval" {set arg [ixNet getAttribute $m_intfId -deadInterval]}
      "-interfacecost" {set arg [ixNet getAttribute $m_intfId -metric]}
      "-routerpriority" {set arg [ixNet getAttribute $m_intfId -priority]}
      "-mtu" {set arg [ixNet getAttribute $m_intfId -mtu]}
      "-authenticationtype" {set arg [ixNet getAttribute $m_intfId -authenticationMethods]}
      "-password" {set arg [ixNet getAttribute $m_intfId -authenticationPassword]}
			"-md5keyid" {set arg [ixNet getAttribute $m_intfId -md5AuthenticationKeyId]} 
			"-flaggre" {set arg $m_ospfArgsArray(flaggre)}
			"-grelocal" {set arg $m_ospfArgsArray(grelocal)}
			"-greremote" {set arg $m_ospfArgsArray(greremote)}
			"-flaggreincludechecksum" {set arg $m_ospfArgsArray(flaggreincludechecksum)}
			"-pollinterval"	{set arg $m_ospfArgsArray(pollinterval)}
			"-retransmitinterval" {set arg $m_ospfArgsArray(retransmitinterval)}
			"-maxlsasperpacket" {set arg $m_ospfArgsArray(maxlsasperpacket)}
			"-transitdelay" {set arg $m_ospfArgsArray(transitdelay)}
			"-graceperiod" {set arg $m_ospfArgsArray(graceperiod)}
			"-flaghostroute" {set arg $m_ospfArgsArray(flaghostroute)}
			"-sutprefixlen" {set arg $m_ospfArgsArray(sutprefix)}  
			"-restartinterval" {set arg $m_ospfArgsArray(restartinterval)}      
     
		} ;#end of switch option
	} ;#end of foreach option_value	
	
	return 1 
}

#========================================                           
# 描述: 使能指定的ospf Router 
# 参数:
# 语法描述:                                                         
#    <obj> Enable
# 返回值： 
#   成功启动返回0 
#=========================================
itcl::body OspfRouter::Enable {args} {
	Deputs "Enter proc OspfRouter::Enable...\n"
	ixNet setAttribute $m_ixRouterId -enabled true
	ixNet commit
	return 1
}
#函数名称:Disable by Shawn Li 2009.12.21  
itcl::body OspfRouter::Disable {args} {
	Deputs "Enter proc OspfRouter::Disable...\n"
	ixNet setAttribute $m_ixRouterId -enabled false
	ixNet commit
	return 1
}

#=======================================================
# 函数名称:AddTopGrid by Shawn Li 2009.12.21                                                 
# 描述: 添加ospf grid拓扑
# 参数:
# 	支持参数:StartingRouterID(固定从1.1.x.y开始,Ixia实现由x.x.x.x实现递增）
# 	GridRows(行数)/GridColumns(列数)/GridName(名称)/GridLinkType(broadcast,pointTopoint)
# 	Flagadvertise(是否通告)/FlagTe(支持TE)/FlagAutoConnect(是否连接SR，Ixia默认连接) 
# 	不支持参数:StartingGmplsInterface/StartingTeInterface
# 语法描述:                                                         
#    AddTopGrid -gridname xx -GridRows 50 -GridColumns 100
# 返回值： 
#    成功返回0，否则返回1
#=======================================================
itcl::body OspfRouter::AddTopGrid {args} {
	Deputs "Enter proc OspfRouter::AddTopGrid...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0] 
	
  #检查参数是否合法
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  set man_arg_list {-gridname}
  set opt_arg_list {-startingrouterid -gridrows -gridcolumns -gridlinktype\
  			-flagadvertise -flagte -flagautoconnect -startinggmplsinterface -startingteinterface} 
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #判断gridname是否已经存在,并对初始化参数
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-gridname)]!=-1} {
  	Deputs "$procname: Error-Grid $args_array(-gridname) alreay created."
  	return $::FAILURE		
  } else {
  	lappend m_ospfNetElementArray(namelist) $args_array(-gridname)
  	set gridname $args_array(-gridname)
  	set m_ospfNetElementArray($gridname,type) grid
  	set m_ospfNetElementArray($gridname,gridrows) 1
  	set m_ospfNetElementArray($gridname,gridcolumns) 1
  	set m_ospfNetElementArray($gridname,startingrouterid) 1.1.1.1	
  	set m_ospfNetElementArray($gridname,gridlinktype) broadcast
  	set m_ospfNetElementArray($gridname,flagadvertise) True
  	set m_ospfNetElementArray($gridname,flagte) False
  	set m_ospfNetElementArray($gridname,flagautoconnect) True
  	set m_ospfNetElementArray($gridname,startinggmplsinterface) "No_support"
  	set m_ospfNetElementArray($gridname,startingteinterface) "No_support"
  } ;#end of if_else
  #对可选参数进行赋值
  set gridname $args_array(-gridname)
  foreach {option value} [array get args_array] {
    switch -- $option {
      "-gridrows" {set m_ospfNetElementArray($gridname,gridrows) $value}
			"-gridcolumns" {set m_ospfNetElementArray($gridname,gridcolumns) $value}
      "-gridlinktype" {set m_ospfNetElementArray($gridname,gridlinktype) $value}	
      "-flagadvertise" {set m_ospfNetElementArray($gridname,flagadvertise) $value}  
      "-flagte" {set m_ospfNetElementArray($gridname,flagte) $value}
      "-startingrouterid" {set m_ospfNetElementArray($gridname,startingrouterid) $value}
    }
  } ;#end of foreach option_value
  set m_ospfNetElementArray($gridname,intf) [ixNet add $m_ixRouterId interface]
  set grid_intf $m_ospfNetElementArray($gridname,intf)
  ixNet setAttribute $grid_intf -advertiseNetworkRange $m_ospfNetElementArray($gridname,flagadvertise)
  ixNet setAttribute $grid_intf -enabled True
  ixNet setAttribute $grid_intf -noOfRows $m_ospfNetElementArray($gridname,gridrows)
  ixNet setAttribute $grid_intf -noOfCols $m_ospfNetElementArray($gridname,gridcolumns)
  ixNet setAttribute $grid_intf -networkRangeLinkType $m_ospfNetElementArray($gridname,gridlinktype)
  ixNet setAttribute $grid_intf -teEnable $m_ospfNetElementArray($gridname,flagte)
  ixNet setAttribute $grid_intf -connectedToDut False
  ixNet setAttribute $grid_intf -interfaceIpAddress 10.10.10.1
  ixNet setAttribute $grid_intf -areaId [ixNet getAttribute $m_intfId -areaId]
  ixNet setAttribute $grid_intf -networkRangeRouterId $m_ospfNetElementArray($gridname,startingrouterid)
  ixNet setAttribute $grid_intf -networkRangeRouterIdIncrementBy 0.0.0.1
  ixNet setAttribute $grid_intf -networkRangeIpByMask True
  ixNet setAttribute $grid_intf -networkRangeIpMask 24
  ixNet commit
  set m_ospfNetElementArray($gridname,intf) [ixNet remapIds $grid_intf]
  return 1  

}

#=======================================================
# 函数名称: GetTopGrid by Shawn Li 2009.12.21                                                 
# 描述: 获取ospf grid拓扑参数
# 参数:
# 	支持参数:StartingRouterID(固定从1.1.x.y开始,Ixia实现由x.x.x.x实现递增）
# 	GridRows(行数)/GridColumns(列数)/GridName(名称)/GridLinkType(broadcast,pointTopoint)
# 	Flagadvertise(是否通告)/FlagTe(支持TE)/FlagAutoConnect(是否连接SR，Ixia默认连接) 
# 	不支持参数:StartingGmplsInterface/StartingTeInterface
# 语法描述:                                                         
#    GetTopGrid -gridname grid1 -GridRows row -GridColumns col
# 返回值： 
#    成功返回0，否则返回1
#=======================================================
itcl::body OspfRouter::GetTopGrid {args} {
  Deputs "Enter proc OspfRouter::GetTopGrid...\n"
  set procname [lindex [info level [info level]] 0]
  set args [ixConvertToLowerCase $args]
  if {[catch {array set args_array $args} error]} {
	  set ::ERRINFO  "$procname: $error."
	  return $::FAILURE
  }
  #检查参数是否合法
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  set man_arg_list {-gridname}
  set opt_arg_list {-startingrouterid -gridrows -gridcolumns -gridlinktype\
  			-flagadvertise -flagte -flagautoconnect -startinggmplsinterface -startingteinterface} 
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
    
  #判断gridname是否已经存在,并对初始化参数
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-gridname)]<0} {
  	Deputs "$procname: Error-Grid $args_array(-gridname) not created."
  	return $::FAILURE		
  } else {
  	set gridname $args_array(-gridname)  
	  foreach {option value} [array get args_array] {
	  	upvar $value arg
	    switch -- $option {
	      "-startingrouterid" {set arg [ixNet getAttribute $m_ospfNetElementArray($gridname,intf) -networkRangeRouterId]}
				"-gridrows" {set arg [ixNet getAttribute $m_ospfNetElementArray($gridname,intf) -noOfRows]}
	      "-gridcolumns" {set arg [ixNet getAttribute $m_ospfNetElementArray($gridname,intf) -noOfCols]}	
	      "-gridlinktype" {set arg [ixNet getAttribute $m_ospfNetElementArray($gridname,intf) -networkRangeLinkType]}		
	      "-flagadvertise" {set arg [ixNet getAttribute $m_ospfNetElementArray($gridname,intf) -advertiseNetworkRange]}
	      "-flagte" {set arg [ixNet getAttribute $m_ospfNetElementArray($gridname,intf) -teEnable]}
	      "-flagautoconnect" {set arg $m_ospfNetElementArray($gridname,flagautoconnect)}
	      "-startinggmplsinterface" {set arg $m_ospfNetElementArray($gridname,startinggmplsinterface)}
	      "-startingteinterface" {set arg $m_ospfNetElementArray($gridname,startingteinterface)}
		  } ;#end of switch
		} ;#end of foreach
	} ;#end of if_else
	return 1 
}
#================================================================
# 函数名称:GetTopGridRouter by Shawn Li 2009.12.22
# 描述: 获取ospfRotuer相应的Gridrouter的属性信息
# 参数: 
#		支持参数：GridName/RouterName/Column/Row(必选)
# 语法描述:           
#   GetTopGridRouter -GridName grid1 -Column 2 -Row 2 -RouterName name   
# 返回值：                                                                  
#    返回对应的值并赋值给指定参数           
#================================================================         
itcl::body OspfRouter::GetTopGridRouter {args} {
  Deputs "Enter proc OspfRouter::GetTopGridRouter...\n"
  set procname [lindex [info level [info level]] 0]
  set args [ixConvertToLowerCase $args]
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO  "$procname: $error."
       return $::FAILURE
  }
  #检查参数是否合法
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  set man_arg_list {-gridname -column -row -routername}
  set opt_arg_list {} 
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #判断gridname是否已经存在
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-gridname)]<0} {
  	Deputs "$procname: Error-Grid $args_array(-gridname) not created."
  	return $::FAILURE		
  } else {  
		upvar $args_array(-routername) rt_name
		set rt_name rt.$args_array(-gridname).$args_array(-row).$args_array(-column)
		lappend m_ospfNetElementArray(namelist) $rt_name
		set m_ospfNetElementArray($rt_name,type) gridrouter
	}
	return 1
}

#=============================================================
# 函数名称:AddTopRouterLink by Shanw Li 2009.12.22
# 描述: 在某个router下添加Link
# 参数: 
#   支持参数: RouterName/linkconnectedname/LinkName(必选)
#		LinkType/FlagTe(Grid支持)/FlagAdvertise/LinkMetric(LSA支持)/
#		Linkinterface(LSA支持)/TeMetric(Grid支持)/TeMaxBandwith(Grid支持)
#   TeReserveBandwith(Grid支持)/LinkLsaName(扩展用)
#   不支持参数：FlagGmpls/LinkTeLsaName/TelinkID/LinkTeInstance
#			TeLocalAddress/TeRemoteAddress/TeLinkType/FlagTelinkNumber
#			TeInstance/TeUnReserveBandwith/TeResourceClass
# 语法描述:
#   AddTopRouterLink -RouterName ospf1 -linkconnectedname grid1 -LinkName link1 
# 返回值：                                                          
#    返回FAILURE或SUCCESS
#==============================================================
itcl::body OspfRouter::AddTopRouterLink {args} {
  Deputs "Enter proc OspfRouter::AddTopRouterLink...\n"
  set procname [lindex [info level [info level]] 0]
  set args [ixConvertToLowerCase $args]

  #1)对args_array赋初始值2)添加修改数组成员变量3)检查参数是否合法有效
  #1)
  array set args_array {-linktype pointToPoint -flagte False -flagadvertise True\
  	-linkmetric 1 -linkinterface 12.0.4.1 -temetric 1 -temaxbandwith 1000\
  	-tereservebandwith 1000 -teresourceclass "No_Support" -linklsaname "Reserved"\
  	-flaggmpls "No_Support" -linktelsaname "No_Support" -telinkid "No_Support"\
  	-linkteinstance "No_Support" -telocaladdress "No_Support" -teremoteaddress "No_Support"\
  	-telinktype "No_Support" -flagtelinknumber "No_Support"	-teinstance "No_Support"\
  	-teunreservebandwith "No_Support" -teresourceclass "No_Support"}
  #2)
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #3)
  set man_arg_list {-routername -linkname -linkconnectedname}
  set opt_arg_list {-linktype -flagte -flagadvertise -linkmetric -linkinterface -temetric\
				-temaxbandwith -tereservebandwith \
				-teresourceclass -linklsaname -flaggmpls -linktelsaname	-telinkid -linkteinstance\
				-telocaladdress -teremoteaddress -telinktype -flagtelinknumber -teinstance \
				-teunreservebandwith -teresourceclass}
  set flag [ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set link_cnt_name  $args_array(-linkconnectedname)
  set link_name $args_array(-linkname)
 
  #判断router连接的对象是否存在
  if {[lsearch $m_ospfNetElementArray(namelist) $link_cnt_name]<0} {
  	Deputs "$procname: Error-LinkConnectedName $link_cnt_name not created."
  	return $::FAILURE		
  }
  #判断link对象是否存在 
  if {[lsearch $m_ospfNetElementArray(namelist) $link_name]>=0} {
  	Deputs "$procname: Error-LinkName $link_name already created."
  	return $::FAILURE		  	
  } else {
  	lappend m_ospfNetElementArray(namelist) $link_name
  } ;#end of if_else
   
  #AddTopRouterLink分为几种情况，1)连接Grid中的router 2)连接TopRouter等，即LSA
  set net_element_type $m_ospfNetElementArray($link_cnt_name,type) 
  switch -- $net_element_type {
  	"gridrouter" {
  	  #保存link类型以及link连接的对象
  	  set m_ospfNetElementArray($link_name,type) "gridlink"
  	  set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  	  set gridname [lindex [split $link_cnt_name "."] 1]
  		set entryrow [lindex [split $link_cnt_name "."] 2]
  		set entrycol [lindex [split $link_cnt_name "."] 3]
  		set grid_intf $m_ospfNetElementArray($gridname,intf)
  		ixNet setAttribute $grid_intf -entryRow $entryrow
      ixNet setAttribute $grid_intf -entryRow $entryrow
      ixNet setAttribute $grid_intf -interfaceIpAddress $args_array(-linkinterface)
		  foreach {option value} [array get args_array] {
		    switch -- $option {
		      "-flagte" {ixNet setAttribute $grid_intf -teEnable $value}
					"-temetric" {ixNet setAttribute $grid_intf -teMetricLevel $value}
		      "-temaxbandwith" {ixNet setAttribute $grid_intf -teMaxBandwidth $value}	
		      "-tereservebandwith" {ixNet setAttribute $grid_intf -teResMaxBandwidth $value}		
		      "-flagadvertise" {ixNet setAttribute $grid_intf -advertiseNetworkRange $value}
			  } ;#end of switch_option
			} ;#end of foreach_option_value      
      ixNet commit
  	} ;#end of gridrouter branch
  	"routerlsa" {
  	  set m_ospfNetElementArray($link_name,type) "routerlsalink"
  	  set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  		set rt_name $link_cnt_name
  		set rt_lsa_rtid $m_ospfNetElementArray($rt_name,rtid)
  		set link_type [string tolower $args_array(-linktype)]
  	  switch -- $link_type {
  			"point_to_point" -
  			"point" {
  				set link_type "pointToPoint"
	  			set link_intf_id $m_ospfArgsArray(routerid)
	  			set link_intf_data $args_array(-linkinterface)  				
  			}
  			"transit_network" -
  			"transit" {
	  			set link_type "transit"
	  			set link_intf_id [ixIncrIpaddr $args_array(-linkinterface)]
	  			set link_intf_data $args_array(-linkinterface)
   			}
  			"stub_network" -
  			"stub" {
  				set link_type "stub"
	  			set link_intf_id $args_array(-linkinterface)
	  			set link_intf_data 255.255.255.0 			
  			}
  			"vlink" {
  				set link_type "virtual"
	  			set link_intf_id $m_ospfArgsArray(routerid)
	  			set link_intf_data ""  				
  			}
  			default {
  				set link_type "pointToPoint"
	  			set link_intf_id $m_ospfArgsArray(routerid)
	  			set link_intf_data $args_array(-linkinterface)  
  			}
  		}
  		set link_intf_list [list "$link_intf_id $link_intf_data $link_type $args_array(-linkmetric)"]
  		set m_ospfNetElementArray($link_name,intflist) $link_intf_list
  		ixNet setAttribute $rt_lsa_rtid -interfaces $link_intf_list
    	ixNet commit
  	}
  	"networklsa" {
  	  set m_ospfNetElementArray($link_name,type) "networklsalink"
  	  set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  	  set netlsa_subnet_id $m_ospfNetElementArray($link_cnt_name,netid)
  	  #根据RouterName的不同，分别对应不同的RouterID
  	  #此处暂时没有添加TopRouter连接Network的代码，即在RouterLSA中添加到Network的link
  	  if {$args_array(-routername)==$m_this} {
  	    lappend m_ospfNetElementArray($link_name,attchedrtlist) $m_ospfArgsArray(routerid)	
  	  } else {
  	  	lappend m_ospfNetElementArray($link_name,attchedrtlist) \
  	  	$m_ospfNetElementArray($args_array(-routername),routerid)
  	  }
  	  set attched_rt_list $m_ospfNetElementArray($link_name,attchedrtlist)
  	  ixNet setAttribute $netlsa_subnet_id -neighborRouterIds	$attched_rt_list
  	  ixNet commit
  	}
  	"summarylsa" {
  	  set m_ospfNetElementArray($link_name,type) "summarylsalink"
  	  set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  	  set sumlsa_id $m_ospfNetElementArray($link_cnt_name,id)
  	  set sumlsa_ip_id $sumlsa_id/summaryIp 
  	  #根据RouterName的不同，分别对应不同的AdvRouterID
  	  if {$args_array(-routername)==$m_this} {
  	  	ixNet setAttribute $sumlsa_id -advertisingRouterId $m_ospfArgsArray(routerid)
  	  } else {
				ixNet setAttribute $sumlsa_id -advertisingRouterId \
					$m_ospfNetElementArray($args_array(-routername),routerid)
  	  }
  	  ixNet commit  	  
  	}
  	"externallsa" {
  	  set m_ospfNetElementArray($link_name,type) "externallsalink"
  	  set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  	  set extlsa_id $m_ospfNetElementArray($link_cnt_name,id)
  	  set extlsa_ip_id $m_ospfNetElementArray($link_cnt_name,extid)
  	  #根据RouterName的不同，分别对应不同的AdvRouterID
  	  if {$args_array(-routername)==$m_this} {
  	  	ixNet setAttribute $extlsa_id -advertisingRouterId $m_ospfArgsArray(routerid)
  	  } else {
				ixNet setAttribute $extlsa_id -advertisingRouterId \
					$m_ospfNetElementArray($args_array(-routername),routerid)
  	  }
  	  ixNet commit    	  
  	}   	
  } ;#end of switch net_elem_type
	return 1
}
#=================================================================
# 函数名称:ConfigTopRouterLink by Shawn Li 2009.12.24
# 描述: 配置Link
# 参数:
#   支持参数: RouterName/linkconnectedname/LinkName(必选)
#		LinkType/FlagTe(Grid支持)/FlagAdvertise/LinkMetric(LSA支持)/
#		Linkinterface(LSA支持)/TeMetric(Grid支持)/TeMaxBandwith(Grid支持)
#   TeReserveBandwith(Grid支持)/LinkLsaName(扩展用)
#   不支持参数：FlagGmpls/LinkTeLsaName/TelinkID/LinkTeInstance
#			TeLocalAddress/TeRemoteAddress/TeLinkType/FlagTelinkNumber
#			TeInstance/TeUnReserveBandwith/TeResourceClass
# 语法描述:
#   ConfigTopRouterLink -LinkName lk1 -FlagAdvertise true
# 返回值：                                                          
#    0 or 1
#====================================================================
itcl::body OspfRouter::ConfigTopRouterLink {args} {
  Deputs "Enter proc OspfRouter::ConfigTopRouterLink...\n"
  set procname [lindex [info level [info level]] 0]
  set args [ixConvertToLowerCase $args]
  array set args_array {-linktype pointToPoint -flagte False -flagadvertise True\
  	-linkmetric 1 -linkinterface 12.0.4.1 -temetric 1 -temaxbandwith 1000 \
  	-tereservebandwith 1000 -teresourceclass "No_Support" -linklsaname "Reserved"\
  	-flaggmpls "No_Support" -linktelsaname "No_Support" -telinkid "No_Support" \
  	-linkteinstance "No_Support" -telocaladdress "No_Support" -teremoteaddress "No_Support"\
  	-telinktype "No_Support" -flagtelinknumber "No_Support"	-teinstance "No_Support"\
  	-teunreservebandwith "No_Support" -teresourceclass "No_Support"}  
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  set man_arg_list {-routername -linkname -linkconnectedname}
  set opt_arg_list {-linktype -flagte -flagadvertise -linkmetric -linkinterface -temetric\
				-temaxbandwith -tereservebandwith \
				-teresourceclass -linklsaname -flaggmpls -linktelsaname	-telinkid -linkteinstance\
				-telocaladdress -teremoteaddress -telinktype -flagtelinknumber -teinstance \
				-teunreservebandwith -teresourceclass}
  set flag [ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set link_cnt_name  $args_array(-linkconnectedname)
  set link_name $args_array(-linkname)
  #判断router连接的对象是否存在
  if {[lsearch $m_ospfNetElementArray(namelist) $link_cnt_name]<0} {
  	Deputs "$procname: Error-LinkConnectedName $link_cnt_name not created."
  	return $::FAILURE		
  }   
  #判断link对象是否存在 
  if {[lsearch $m_ospfNetElementArray(namelist) $link_name]<0} {
  	Deputs "$procname: Error-LinkName $link_name not created."
  	return $::FAILURE		  	
  }
  #ConfigTopRouterLink分为几种情况，1)连接Grid中的router 2)连接TopRouter等，即LSA
  set net_element_type $m_ospfNetElementArray($link_cnt_name,type) 
  switch -- $net_element_type { 
  	"gridrouter" {
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  		set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
		  set gridname [lindex [split $link_cnt_name "."] 1]
			set entryrow [lindex [split $link_cnt_name "."] 2]
			set entrycol [lindex [split $link_cnt_name "."] 3]
			set grid_intf $m_ospfNetElementArray($gridname,intf)
			ixNet setAttribute $grid_intf -entryRow $entryrow
	    ixNet setAttribute $grid_intf -entryRow $entryrow
	    ixNet setAttribute $grid_intf -interfaceIpAddress $args_array(-linkinterface)
		  foreach {option value} [array get args_array] {
		    switch -- $option {
		      "-flagte" {ixNet setAttribute $grid_intf -teEnable $value}
					"-temetric" {ixNet setAttribute $grid_intf -teMetricLevel $value}
		      "-temaxbandwith" {ixNet setAttribute $grid_intf -teMaxBandwidth $value}	
		      "-tereservebandwith" {ixNet setAttribute $grid_intf -teResMaxBandwidth $value}		
		      "-flagadvertise" {ixNet setAttribute $grid_intf -advertiseNetworkRange $value}
			  } ;#end of switch_option
			} ;#end of foreach_option_value      
      ixNet commit	      
	  }
  	"routerlsa" {
  		set rt_name $link_cnt_name
  		set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  		set $m_ospfNetElementArray($link_name,linkcntname) $rt_name
  		set rt_lsa_rtid $m_ospfNetElementArray($rt_name,rtid)
  		set link_type [string tolower $args_array(-linktype)]
  	  switch -- $link_type {
  			"point_to_point" -
  			"point" {
  				set link_type "pointToPoint"
	  			set link_intf_id $m_ospfArgsArray(routerid)
	  			set link_intf_data $args_array(-linkinterface)  				
  			}
  			"transit_network" -
  			"transit" {
	  			set link_type "transit"
	  			set link_intf_id [ixIncrIpaddr $args_array(-linkinterface)]
	  			set link_intf_data $args_array(-linkinterface)
   			}
  			"stub_network" -
  			"stub" {
  				set link_type "stub"
	  			set link_intf_id $args_array(-linkinterface)
	  			set link_intf_data 255.255.255.0 			
  			}
  			"vlink" {
  				set link_type "virtual"
	  			set link_intf_id $m_ospfArgsArray(routerid)
	  			set link_intf_data ""  				
  			}
  			default {
  				set link_type "pointToPoint"
	  			set link_intf_id $m_ospfArgsArray(routerid)
	  			set link_intf_data $args_array(-linkinterface)  
  			}
  		}
  		set link_intf_list [list "$link_intf_id $link_intf_data $link_type $args_array(-linkmetric)"]
  		set m_ospfNetElementArray($link_name,intflist) $link_intf_list
  		ixNet setAttribute $rt_lsa_rtid -interfaces $link_intf_list
    	ixNet commit
  	}
  	"networklsa" {
  	  set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)  	
  	  set netlsa_subnet_id $m_ospfNetElementArray($link_cnt_name,netid)
  	  #根据RouterName的不同，分别对应不同的RouterID
  	  #此处暂时没有添加TopRouter连接Network的代码，即在RouterLSA中添加到Network的link
  	  if {$args_array(-routername)==$m_this} {
  	    lappend m_ospfNetElementArray($link_name,attchedrtlist) $m_ospfArgsArray(routerid)	
  	  } else {
  	    lappend m_ospfNetElementArray($link_name,attchedrtlist) \
  	  	$m_ospfNetElementArray($args_array(-routername),routerid)
  	  }
  	  set attched_rt_list $m_ospfNetElementArray($link_name,attchedrtlist)
  	  ixNet setAttribute $netlsa_subnet_id -neighborRouterIds	$attched_rt_list
  	  ixNet commit  	
  	}
  	"summarylsa" {
  	  set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  	  set sumlsa_id $m_ospfNetElementArray($link_cnt_name,id)
  	  #根据RouterName的不同，分别对应不同的AdvRouterID
  	  if {$args_array(-routername)==$m_this} {
  	  	ixNet setAttribute $sumlsa_id -advertisingRouterId $m_ospfArgsArray(routerid)
  	  } else {
				ixNet setAttribute $sumlsa_id -advertisingRouterId\
					$m_ospfNetElementArray($args_array(-routername),routerid)
  	  }
  	  ixNet commit  	  
  	}
  	"externallsa" {
  	  set m_ospfNetElementArray($link_name,linkcntname) $link_cnt_name
  	  set m_ospfNetElementArray($link_name,rtname) $args_array(-routername)
  	  set extlsa_id $m_ospfNetElementArray($link_cnt_name,id)
  	  if {$args_array(-routername)==$m_this} {
  	  	ixNet setAttribute $extlsa_id -advertisingRouterId $m_ospfArgsArray(routerid)
  	  } else {
				ixNet setAttribute $extlsa_id -advertisingRouterId\
					$m_ospfNetElementArray($args_array(-routername),routerid)
  	  }
  	  ixNet commit 	
  	} 	  	
  } ;#end of switch_net_element_type
  return 1
}
#==========================================================
# 函数名称:RemoveTopRouterLink by Shawn Li 2009.12.25
# 描述: 删除某个router下的Link
# 参数:
# 	LinkName(必选)
# 语法描述:
#   RemoveTopRouterLink -LinkName link1
# 返回值：                                                          
#    1 or 0
#===========================================================
itcl::body OspfRouter::RemoveTopRouterLink {args} {
  Deputs "Enter proc OspfRouter::RemoveTopRouterLink...\n"
  set procname [lindex [info level [info level]] 0]
  set args [ixConvertToLowerCase $args]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  set man_arg_list {-linkname}
  set opt_arg_list {}
  set flag [ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
    return $::FAILURE
  }
  set link_name $args_array(-linkname)
  set link_cnt_name $m_ospfNetElementArray($link_name,linkcntname)    
  #判断link对象是否存在 
  if {[lsearch $m_ospfNetElementArray(namelist) $link_name]<0} {
  	Deputs "$procname: Error-LinkName $link_name not created."
    return $::FAILURE		  	
  }
  
  set link_type $m_ospfNetElementArray($link_name,type) 
  switch -- $link_type { 
  	"gridlink" {
  	  set grid_rt_name $link_cnt_name
  	  set grid_name [lindex [split $grid_rt_name "."] 1]
  	  set grid_intf $m_ospfNetElementArray($grid_name,intf)
  	  ixNet setAttribute $grid_intf -advertiseNetworkRange False
  	  ixNet commit
  	  #删除link在数组中相关变量
		  set index [lsearch $m_ospfNetElementArray(namelist) $link_name]
		  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
		  array unset m_ospfNetElementArray "$link_name,*"
  	}
  	"routerlsalink" {
  		set rt_name $link_cnt_name
  		set rt_lsa_rtid $m_ospfNetElementArray($rt_name,rtid)
  		ixNet setAttribute $rt_lsa_rtid -interfaces [list]
    	ixNet commit
  	  #删除link在数组中相关变量
		  set index [lsearch $m_ospfNetElementArray(namelist) $link_name]
		  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
		  array unset m_ospfNetElementArray "$link_name,*"    	
  	}
  	"networklsalink" {
  		set rt_name $m_ospfNetElementArray($link_name,rtname)
  		set network_name $link_cnt_name
  		set netlsa_id $m_ospfNetElementArray($network_name,id)
  	  set netlsa_subnet_id $m_ospfNetElementArray($network_name,netid)
  	  #此处暂时没有添加对TopRouter连接Network处理的代码，即在RouterLSA中处理到Network的link
  	  if {$rt_name==$m_this} {
  	  	set index [lsearch $m_ospfNetElementArray($link_name,attchedrtlist) \
  	  	$m_ospfArgsArray(routerid)]  
  	  } else {
  	  	set index [lsearch $m_ospfNetElementArray($link_name,attchedrtlist) \
  	  		$m_ospfNetElementArray($rt_name,routerid)]
  	  } 
  	  set m_ospfNetElementArray($link_name,attchedrtlist) \
  	  	[lreplace $m_ospfNetElementArray($link_name,attchedrtlist) $index $index]
  	  set attched_rt_list $m_ospfNetElementArray($link_name,attchedrtlist)
  	  #将连接的router删除，同时将此Network disable
  	  ixNet setAttribute $netlsa_subnet_id -neighborRouterIds	$attched_rt_list 
  	  ixNet setAttribute $netlsa_id -enabled False
  	  ixNet commit
		  set index [lsearch $m_ospfNetElementArray(namelist) $link_name]
		  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
		  array unset m_ospfNetElementArray "$link_name,*"    	    	
  	}
  	"summarylsalink" {
  	  set rt_name $m_ospfNetElementArray($link_name,rtname)
  	  set block_name $m_ospfNetElementArray($link_name,linkcntname)
  	  set sumlsa_id $m_ospfNetElementArray($block_name,id)
  	  #block只能同一个Router相连接，一旦删除link，则AdvRouter为空
  	  #同时将block设置为False
  	  ixNet setAttribute $sumlsa_id -advertisingRouterId 0.0.0.0
  	  ixNet setAttribute $sumlsa_id -enabled False
  	  ixNet commit 
		  set index [lsearch $m_ospfNetElementArray(namelist) $link_name]
		  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
		  array unset m_ospfNetElementArray "$link_name,*"    	   	  
  	}
  	"externallsalink" {
  	  set rt_name $m_ospfNetElementArray($link_name,rtname) 
  	  set block_name $m_ospfNetElementArray($link_name,linkcntname)
  	  set extlsa_id $m_ospfNetElementArray($block_name,id)
  	  #block只能同一个Router相连接，一旦删除link，则AdvRouter为空
  	  #同时将block设置为False
  	  ixNet setAttribute $extlsa_id -advertisingRouterId 0.0.0.0
  	  ixNet setAttribute $extlsa_id -enabled False
  	  ixNet commit 
		  set index [lsearch $m_ospfNetElementArray(namelist) $link_name]
		  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
		  array unset m_ospfNetElementArray "$link_name,*" 
  	  ixNet commit 	
  	}   	   	  	
  } ;#end of switch_link_type
  return 1    
     
}
#================================================
# 函数名称:RemoveTopGrid by Shawn Li 2009.12.23
# 描述: 删除ospfRotuer相应的Grid
# 参数:
# 	支持参数：GridName(必选)
# 语法描述:
#    RemoveTopGrid -GridName grid1
# 返回值：                                                          
#    0 or 1
#=================================================
itcl::body OspfRouter::RemoveTopGrid {args} {
  Deputs "Enter proc OspfRouter::RemoveTopGrid...\n"
  set procname [lindex [info level [info level]] 0]
	set args [ixConvertToLowerCase $args]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-gridname}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #判断grid对象是否存在
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-gridname)]<0} {
  	Deputs "$procname: Error-GridName $args_array(-gridname) not created."
  	return $::FAILURE		
  }
  #删除IxNetwork中grid
	ixNet remove $m_ospfNetElementArray($args_array(-gridname),intf)
	ixNet commit  
  #删除grid在数组中相关变量
  set index [lsearch $m_ospfNetElementArray(namelist) $args_array(-gridname)]
  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
  array unset m_ospfNetElementArray "$args_array(-gridname),*"
  
  return 1  
}
#==================================================================
# 函数名称:AddTopRouter by Shawn Li 2009.12.23
# 描述: 创建Ospf Router拓扑
# 参数:
# 	支持参数: RouterID/RouterTypeValue/RouterName(必选)
#			FlagAdertise/FlagAutoConnect
#   不支持参数：FlagTE/TeRouterLsaName/RouterLsaName(后期扩展)
# 语法描述:
#    AddTopRouter -RouterTypeValue BIT_B -RouterName rt1 -RouterID 1.1.1.1
# 返回值：                                                          
#    1 or 0
#==================================================================
itcl::body OspfRouter::AddTopRouter {args} {
  Deputs "Enter proc OspfRouter::AddTopRouter...\n"
  set procname [lindex [info level [info level]] 0]
	set args [ixConvertToLowerCase $args]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-routerid -routertypevalue -routername}
  set opt_arg_list {-flagadvertise -flagautoconnect -flagte -routerlsaname -terouterlsaname}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #判断router对象是否已经创建
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-routername)]>=0} {
  	Deputs "$procname: Error-RouterName $args_array(-routername) already created."
  	return $::FAILURE		
  } else {
  	set rt_name $args_array(-routername)
  	set rt_type_val [string tolower $args_array(-routertypevalue)]
  	lappend m_ospfNetElementArray(namelist) $rt_name
    #初始化routerlsa对象的参数
  	set m_ospfNetElementArray($rt_name,type) routerlsa
  	set m_ospfNetElementArray($rt_name,flagadvertise) True
  	set m_ospfNetElementArray($rt_name,terouterlsaname) "No_Support"
  	set m_ospfNetElementArray($rt_name,routerlsaname) "To_be_defined"
  	set m_ospfNetElementArray($rt_name,flagte) "No_Support"
    if {![info exists args_array(-flagadvertise)]} {
      set m_ospfNetElementArray($rt_name,flagautoconnect) True
    } else {
      set m_ospfNetElementArray($rt_name,flagautoconnect) $args_array(-flagadvertise)
    }  	
  	set m_ospfNetElementArray($rt_name,id) [ixNet add $m_userLsaGroupId userLsa]
    #下面对象作用：描述RouterLSA ospf intf属性(bBit/eBit/interfaces/vBit)
  	set m_ospfNetElementArray($rt_name,rtid) $m_ospfNetElementArray($rt_name,id)/router
    ixNet commit
    set m_ospfNetElementArray($rt_name,id) [ixNet remapIds $m_ospfNetElementArray($rt_name,id) ]
    #设置routerlsa对象的参数
    set m_ospfNetElementArray($rt_name,routerid) $args_array(-routerid) 
    ixNet setAttribute $m_ospfNetElementArray($rt_name,id) -lsaType router
    ixNet setAttribute $m_ospfNetElementArray($rt_name,id) -enabled $args_array(-flagadvertise)
    ixNet setAttribute $m_ospfNetElementArray($rt_name,id) -linkStateId $args_array(-routerid) 
    ixNet setAttribute $m_ospfNetElementArray($rt_name,id) -advertisingRouterId $args_array(-routerid) 
    switch -- $rt_type_val {
    	"0x01" - 
    	"bit_b" {ixNet setAttribute $m_ospfNetElementArray($rt_name,rtid) -bBit True}
    	"0x02" - 
    	"bit_e" {ixNet setAttribute $m_ospfNetElementArray($rt_name,rtid) -eBit True}
    	"0x04" - 
    	"bit_v" {ixNet setAttribute $m_ospfNetElementArray($rt_name,rtid) -vBit True}    	
    } ;#end of switch_router_type_value  
    ixNet commit
  } ;#end of if_else
  
  return 1
}
#================================================================
# 函数名称:ConfigTopRouter by Shawn Li 2009.12.23
# 描述: 配置TopRouter的属性
# 参数:
# 	支持参数: RouterID/RouterTypeValue/FlagAdertise/FlagAutoConnect
#   不支持参数：FlagTE/TeRouterLsaName/RouterLsaName(后期扩展)
# 语法描述:
#    ConfigTopRouter -RouterTypeValue BIT_B -RouterName rt1 -RouterID 1.1.1.1
# 返回值：                                                          
#    1 or 0
#================================================================
itcl::body OspfRouter::ConfigTopRouter {args} {
  Deputs "Enter proc OspfRouter::ConfigTopRouter...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-routerid -routertypevalue -routername}
  set opt_arg_list {-flagadvertise -flagautoconnect -flagte -routerlsaname -terouterlsaname}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #判断router对象是否已经创建
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-routername)]<0} {
  	Deputs "$procname: Error-RouterName $args_array(-routername) not created."
  	return $::FAILURE		
  } else {
  	set rt_name $args_array(-routername)
    set rt_lsa_id $m_ospfNetElementArray($rt_name,id)   
	  foreach {option value} [array get args_array] {
	    switch -- $option {
	      "-flagadvertise" {ixNet setAttribute $rt_lsa_id -enabled $value}
				"-routerid" {
				  set m_ospfNetElementArray($rt_name,routerid) $value
			    ixNet setAttribute $rt_lsa_id -linkStateId $value 
			    ixNet setAttribute $rt_lsa_id -advertisingRouterId $value}
	      "-flagautoconnect" {set m_ospfNetElementArray($rt_name,flagautoconnect) $value}	
	      "-routertypevalue" {
			    switch -- [string tolower $value] {
			    	"0x01" - 
			    	"bit_b" {ixNet setAttribute $m_ospfNetElementArray($rt_name,rtid) -bBit True}
			    	"0x02" - 
			    	"bit_e" {ixNet setAttribute $m_ospfNetElementArray($rt_name,rtid) -eBit True}
			    	"0x04" - 
			    	"bit_v" {ixNet setAttribute $m_ospfNetElementArray($rt_name,rtid) -vBit True} 
			    	default {Deputs "Error:No such router type $value."}   	
			    }
			  } 
	      "-flagte" {set m_ospfNetElementArray($rt_name,flagte) "$value,no_support"}
	      "-terouterlsaname" {set m_ospfNetElementArray($rt_name,terouterlsaname) "$value,no_support"}
	      "-routerlsaname" {set m_ospfNetElementArray($rt_name,routerlsaname) "$value,to_be_defined"}
		  } ;#end of switch_option
		} ;#end of foreach_option_value    
		ixNet commit  
  } ;#end of if_else 
  
  return 1 
}
#================================================================
# 函数名称:GetTopRouter by Shawn Li 2009.12.23
# 描述: TopRouter的属性信息
# 参数:
# 	支持参数: RouterName(必选)/RouterID/RouterTypeValue/FlagAdertise
#			FlagAutoConnect/LinkNum
#   不支持参数：FlagTE/TeRouterLsaName/RouterLsaName(后期扩展)
# 语法描述:
#    GetTopRouter -RouterName rt1 -RouterID rid -FlagAdertise flag 
# 返回值：                                                          
#    1 or 0
#================================================================
itcl::body OspfRouter::GetTopRouter {args} {
  Deputs "Enter proc OspfRouter::GetTopRouter...\n" 
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-routername}
  set opt_arg_list {-flagadvertise -flagautoconnect -flagte -routerlsaname \
  	-terouterlsaname -linknum -routerid -routertypevalue}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  } 
  #判断router对象是否已经创建
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-routername)]<0} {
  	Deputs "$procname: Error-RouterName $args_array(-routername) not created."
  	return $::FAILURE		
  } else {
  	set rt_name $args_array(-routername)
  	set rt_lsa_id $m_ospfNetElementArray($rt_name,id)
  	set rt_lsa_rtid "$rt_lsa_id/router"
	  foreach {option value} [array get args_array] {
	  	upvar $value arg
	    switch -- $option {
	      "-flagadvertise" {set arg [ixNet getAttribute $rt_lsa_id -enabled]}
				"-routerid" {set arg [ixNet getAttribute $rt_lsa_id -advertisingRouterId]}
	      "-linknum" {set arg [llength [ixNet getAttribute $rt_lsa_rtid -interfaces]]}	
	      "-routertypevalue" {
	      	if {[ixNet getAttribute $rt_lsa_rtid -bBit]} {
	      		lappend arg "BIT_B"
	      	}
	      	if {[ixNet getAttribute $rt_lsa_rtid -eBit]} {
	      		lappend arg "BIT_E"
	      	}
 	      	if {[ixNet getAttribute $rt_lsa_rtid -vBit]} {
	      		lappend arg "BIT_V"
	      	}
	      }
        "-flagautoconnect" {set arg $m_ospfNetElementArray($rt_name,flagautoconnect)}
	      "-terouterlsaname" {set arg $m_ospfNetElementArray($rt_name,terouterlsaname)}
	      "-routerlsaname" {set arg $m_ospfNetElementArray($rt_name,routerlsaname)}
	      "-flagte" {set arg $m_ospfNetElementArray($rt_name,flagte)}
		  } ;#end of switch
		} ;#end of foreach  
  } ;#end of if_else  
  return 1 
}    
#========================================================
# 函数名称:AdvertiseRouters by Shawn Li 2009.12.23
# 描述: 通告RouterLSA
# 参数:
# RouterNameLis 可选
# 语法描述:
#   AdvertiseRouters -RouterNameList {rt1 rt2} 
# 返回值：                                                          
#    1 or 0
#=========================================================
itcl::body OspfRouter::AdvertiseRouters {args} {
  Deputs "Enter proc OspfRouter::AdvertiseRouters...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {}
  set opt_arg_list {-routernamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  } 
  #判断是否存在routerNameList变量
  if {![info exists args_array(-routernamelist)]} {
    #通过判断对象的属性类型，来完成对RouterLSA的通告
  	foreach rt_name $args_array(-routernamelist) {
  		if {$m_ospfNetElementArray($rt_name,type) == "routerlsa"} {
  			ixNet setAttribute $m_ospfNetElementArray($rt_name,id) -enabled True
		  	ixNet commit	
  		}
  	}		
  } else {
    #判断给出的router对象是否存在
	  foreach rt_name $args_array(-routernamelist) {
		  if {[lsearch $m_ospfNetElementArray(namelist) $rt_name]<0} {
		  	Deputs "$procname: Error-RouterName $rt_name not created, skips it."
		  } else {
		  	ixNet setAttribute $m_ospfNetElementArray($rt_name,id) -enabled True
		  	ixNet commit	
		  } ;#end of if_else_level2  	
	  } ;#end of foreach_rt_name
	} ;#end of if_else_level1
	
	return 1
}
#==============================================================
# 函数名称:RemoveTopRouter by Shawn Li 2009.12.23
# 描述: 删除TopRouter
# 参数: RouterName(必选)
# 语法描述:
#  RemoveTopRouter -RouterName rt1
# 返回值：                                                          
#  0 or 1
#==============================================================
itcl::body OspfRouter::RemoveTopRouter {args} {
  Deputs "Enter proc OspfRouter::RemoveTopRouter...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-routername}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #判断给出的router对象是否存在
  set rt_name $args_array(-routername)
  if {[lsearch $m_ospfNetElementArray(namelist) $rt_name]<0} {
  	Deputs "$procname: Error-RouterName $rt_name not created."
  } else {
	  #删除IxNetwork中RouterLSA
		ixNet remove $m_ospfNetElementArray($rt_name,id)
		ixNet commit  
	  #删除RouterLSA在数组中相关变量
	  set index [lsearch $m_ospfNetElementArray(namelist) $rt_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$rt_name,*"  	
  }     
	return 1
}

#=============================================================
# 函数名称:AddTopNetwork by Shawn Li 2009.12.25
# 描述: 添加NetworkLsa
# 参数:
#		支持参数：NetworkName(必选)/Subnetwork/PrefixLen/DRRouterName
#   	LsaName(扩展)/FlagAutoConnect 
# 语法描述:
#   AddTopNetwork -DRRouterName rt1 -networkname net1 
#			-subnetwork 2.2.2.0 -prefix 24
# 返回值：                                                          
#    0 or 1
#==============================================================
itcl::body OspfRouter::AddTopNetwork {args} {
  Deputs "Enter proc OspfRouter::AddTopNetwork...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-subnetwork 2.2.2.0 -prefixlen 255.255.255.0 -drroutername "$m_this"\
  	-lsaname "To_be_defined" -flagautoconnect "True"}   
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-networkname}
  set opt_arg_list {-subnetwork -prefixlen -drroutername -lsaname -flagautoconnect}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  } 
  set network_name $args_array(-networkname)
  if {[lsearch $m_ospfNetElementArray(namelist) $network_name]>=0} {
  	Deputs "$procname: Error-NetworkName $network_name already created."
  } else {
    lappend m_ospfNetElementArray(namelist) $network_name
    set m_ospfNetElementArray($network_name,type) networklsa
    set m_ospfNetElementArray($network_name,id) [ixNet add $m_userLsaGroupId userLsa]
    set netlsa_id $m_ospfNetElementArray($network_name,id)
  	ixNet commit
  	set m_ospfNetElementArray($network_name,id) [ixNet remapIds $netlsa_id]     
    
    #下面参数描述NetworkLSA属性(neighborRouterIds-Array networkMask-IPv4)
  	set m_ospfNetElementArray($network_name,netid) $netlsa_id/network
  	set netlsa_subnet_id $netlsa_id/network
    #设置network lsa参数
  	ixNet setAttribute $netlsa_id -lsaType network
  	ixNet setAttribute $netlsa_id -advertisingRouterId $m_ospfArgsArray(routerid)
  	ixNet setAttribute $netlsa_id -enabled True

    #IXIA目前只能将LSA连接到SR上面转发给DUT
    
    foreach {option value} [array get args_array] {
    	switch -- $option {
    		"-subnetwork" {ixNet setAttribute $netlsa_id -linkStateId [ixIncrIpaddr $value]}
    		"-prefixlen" {ixNet setAttribute $netlsa_subnet_id -networkMask [ixNumber2Ipmask $value]}
    		"-drroutername" {set m_ospfNetElementArray($network_name,drroutername) $m_this}
    		"-lsaname" {set m_ospfNetElementArray($network_name,lsaname) "$value,to_be_defined"}
    		"-flagautoconnect" {set m_ospfNetElementArray($network_name,flagautoconnect) True}
    	} 
  	} ;#end of foreach_option_value
    
    #是否需要将SR本身的信息放入到AttachedRouter里面，需要根据RFC确认
 
  	ixNet commit
  } ;#end of if_else
  return 1  
}
#=============================================================
# 函数名称:ConfigTopNetwork by Shawn Li 2009.12.25
# 描述: 添加NetworkLsa
# 参数:
#		支持参数：NetworkName(必选)/Subnetwork/PrefixLen/DRRouterName
#   	LsaName(扩展)/FlagAutoConnect 
# 语法描述:
#   ConfigTopNetwork -DRRouterName rt1 -networkname net1 
#			-subnetwork 2.2.2.0 -prefix 24
# 返回值：                                                          
#    0 or 1
#==============================================================
itcl::body OspfRouter::ConfigTopNetwork {args} {
  Deputs "Enter proc OspfRouter::ConfigTopNetwork...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-networkname}
  set opt_arg_list {-subnetwork -prefixlen -drroutername -lsaname -flagautoconnect}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }   
  set network_name $args_array(-networkname)
  if {[lsearch $m_ospfNetElementArray(namelist) $network_name]<0} {
  	Deputs "$procname: Error-NetworkName network_name not created."
  } else {
    set netlsa_id $m_ospfNetElementArray($network_name,id)
    set netlsa_subnet_id $netlsa_id/network
	  ixNet setAttribute $netlsa_id -enabled False
	  ixNet commit     
  	#只修改如下参数，其他参数保持Create NetworkLSA时即可
    foreach {option value} [array get args_array] {
    	switch -- $option {
    		"-subnetwork" {ixNet setAttribute $netlsa_id -linkStateId [ixIncrIpaddr $value]}
    		"-prefixlen" {ixNet setAttribute $netlsa_subnet_id -networkMask [ixNumber2Ipmask $value]}
    		"-drroutername" {set m_ospfNetElementArray($network_name,drroutername) $m_this}
    		"-lsaname" {set m_ospfNetElementArray($network_name,lsaname) "$value,to_be_defined"}
    		"-flagautoconnect" {set m_ospfNetElementArray($network_name,flagautoconnect) True}
    	} 
  	} ;#end of foreach_option_value  
  }
  #modified by Shawn Li 20100202
  #comments: disable lsa then enable again

  ixNet setAttribute $netlsa_id -enabled True
  ixNet commit 
  return 1  
}  
#============================================================
# 函数名称:RemoveTopNetwork by Shawn Li 2009.12.25
# 描述: 删除某条NetworkLsa
# 参数: NetworkName,Routername(必选)
# 语法描述:
#    RemoveTopRouterLsa -networkName network1 -Routername rt1
# 返回值：                                                          
#    0 or 1
#============================================================
itcl::body OspfRouter::RemoveTopNetwork {args} {
  Deputs "Enter proc OspfRouter::RemoveTopNetwork...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-networkname -routername}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set network_name $args_array(-networkname)
  if {[lsearch $m_ospfNetElementArray(namelist) $network_name]<0} {
  	Deputs "$procname: Error-NetworkName network_name not created."
  } else {
	  #删除IxNetwork中NetworkLSA
		ixNet remove $m_ospfNetElementArray($network_name,id)
		ixNet commit  
	  #删除NetworkLSA在数组中相关变量
	  set index [lsearch $m_ospfNetElementArray(namelist) $network_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$network_name,*"   	
  }
  return 1   
}
#=======================================================================
# 函数名称:CreateTopSummaryRouteBlock by Shawn Li 2009.12.28
# 描述: 创建Summary类型LSA
# 参数:
# 	支持参数:BlockName(必选)/StartingAddress/PrefixLen/Number/Modifier
#   FlagAutoConnect/LsaName
#		不支持参数：FlagTrafficDest
# 语法描述:
# 	CreateTopSummaryRouteBlock -BlockName blk1 -StartingAddress 1.1.1.1
# 返回值：                                                          
#    0 or 1
#========================================================================
itcl::body OspfRouter::CreateTopSummaryRouteBlock {args} {
  Deputs "Enter proc OspfRouter::CreateTopSummaryRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-startingaddress 13.2.0.0 -prefixlen 255.255.255.0 -number "50"\
  	-modifier "1" -flagautoconnect "True" -lsaname "To_be_defined" -flagtrafficdest {No_support}}   
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-blockname}
  set opt_arg_list {-startingaddress -prefixlen -number -modifier -flagautoconnect -lsaname\
  	-flagtrafficdest}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set sum_block_name $args_array(-blockname)
  if {[lsearch $m_ospfNetElementArray(namelist) $sum_block_name]>=0} {
  	Deputs "$procname: Error-BlockName $sum_block_name already created."
  } else { 
    #保存SummaryLSA参数
  	array set m_ospfNetElementArray "$sum_block_name,startingaddress $args_array(-startingaddress)\
  	$sum_block_name,prefixlen $args_array(-prefixlen)	$sum_block_name,number $args_array(-number)\
  	$sum_block_name,modifier $args_array(-modifier)	$sum_block_name,lsaname $args_array(-lsaname)\
  	$sum_block_name,flagautoconnect $args_array(-flagautoconnect)\
    $sum_block_name,flagtrafficdest $args_array(-flagtrafficdest)"
    lappend m_ospfNetElementArray(namelist) $sum_block_name
    set m_ospfNetElementArray($sum_block_name,type) summarylsa
    set m_ospfNetElementArray($sum_block_name,id) [ixNet add $m_userLsaGroupId userLsa]
    set sumlsa_id $m_ospfNetElementArray($sum_block_name,id)
    ixNet commit  
    set m_ospfNetElementArray($sum_block_name,id) [ixNet remapIds $sumlsa_id]     
    #下面参数描述SummaryLSA属性(incrementLinkStateId/metric/networkMask/numberOfLsa)
  	set m_ospfNetElementArray($sum_block_name,sumid) $sumlsa_id/summaryIp
  	set sumlsa_ip_id $sumlsa_id/summaryIp 
    #设置SummayLSA参数
  	ixNet setAttribute $sumlsa_id -lsaType areaSummary
  	ixNet setAttribute $sumlsa_id -advertisingRouterId $m_ospfArgsArray(routerid)
  	ixNet setAttribute $sumlsa_id -enabled True
  	#ixNet setAttribute $sumlsa_id -linkStateId $args_array(-startingaddress)

    foreach {option value} [array get args_array] {
    	switch -- $option {
    		"-startingaddress" {ixNet setAttribute $sumlsa_id -linkStateId $value}
    		"-prefixlen" {ixNet setAttribute $sumlsa_ip_id -networkMask [ixNumber2Ipmask $value]}
    		"-number" {ixNet setAttribute $sumlsa_ip_id -numberOfLsa $value}
    		"-modifier" {ixNet setAttribute $sumlsa_ip_id -incrementLinkStateIdBy 0.0.0.$value}
    		"-lsaname" {set m_ospfNetElementArray($sum_block_name,lsaname) "$value,to_be_defined"}
    		"-flagautoconnect" {set m_ospfNetElementArray($sum_block_name,flagautoconnect) True}
    		"-flagtrafficdest" {set m_ospfNetElementArray($sum_block_name,flagtrafficdest) "$value,no_support"}
    	} 
  	} ;#end of foreach_option_value 
  	ixNet commit      	
  } ;#end of if_else
  return 1
}
#=======================================================================
# 函数名称:ConfigTopSummaryRouteBlock by Shawn Li 2009.12.28
# 描述:配置Summary类型LSA
# 参数:
# 	支持参数:BlockName(必选)/StartingAddress/PrefixLen/Number/Modifier
#   FlagAutoConnect/LsaName
#		不支持参数：FlagTrafficDest
# 语法描述:
# 	ConfigTopSummaryRouteBlock -BlockName blk1 -StartingAddress 1.1.1.1
# 返回值：                                                          
#    0 or 1
#========================================================================
itcl::body OspfRouter::ConfigTopSummaryRouteBlock {args} {
  Deputs "Enter proc OspfRouter::ConfigTopSummaryRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-blockname}
  set opt_arg_list {-startingaddress -prefixlen -number -modifier -flagautoconnect -lsaname\
  	-flagtrafficdest}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set sum_block_name $args_array(-blockname)
  if {[lsearch $m_ospfNetElementArray(namelist) $sum_block_name]<0} {
  	Deputs "$procname: Error-BlockName $sum_block_name not created."
  } else {
    set sumlsa_id $m_ospfNetElementArray($sum_block_name,id)
  	set sumlsa_ip_id $sumlsa_id/summaryIp 
	  ixNet setAttribute $sumlsa_id -enabled False
	  ixNet commit   	
    foreach {option value} [array get args_array] {
    	switch -- $option {
    		"-startingaddress" {
    			set m_ospfNetElementArray($sum_block_name,startingaddress) $value
    			ixNet setAttribute $sumlsa_id -linkStateId $value}
    		"-prefixlen" {
    			set m_ospfNetElementArray($sum_block_name,prefixlen) $value
    			ixNet setAttribute $sumlsa_ip_id -networkMask [ixNumber2Ipmask $value]}
    		"-number" {
    			set m_ospfNetElementArray($sum_block_name,number) $value
    			ixNet setAttribute $sumlsa_ip_id -numberOfLsa $value}
    		"-modifier" {
    			set m_ospfNetElementArray($sum_block_name,modifier) $value
    			ixNet setAttribute $sumlsa_ip_id -incrementLinkStateIdBy 0.0.0.$value}
    		"-lsaname" {set m_ospfNetElementArray($sum_block_name,lsaname) "$value,to_be_defined"}
    		"-flagautoconnect" {set m_ospfNetElementArray($sum_block_name,flagautoconnect) True}
    		"-flagtrafficdest" {set m_ospfNetElementArray($sum_block_name,flagtrafficdest) "$value,no_support"}
    	} 
  	} ;#end of foreach_option_value   	  

	  ixNet setAttribute $sumlsa_id -enabled True
	  ixNet commit 
  } ;#end of if_else
  return 1
}
#=======================================================================
# 函数名称:GetTopSummaryRouteBlock by Shawn Li 2009.12.28
# 描述:获取Summary类型LSA参数
# 参数:
# 	支持参数:BlockName(必选)/StartingAddress/PrefixLen/Number/Modifier
#   FlagAutoConnect/LsaName
#		不支持参数：FlagTrafficDest
# 语法描述:
# 	GetTopSummaryRouteBlock -BlockName blk1 -StartingAddress sa
# 返回值：                                                          
#    0 or 1
#========================================================================     
itcl::body OspfRouter::GetTopSummaryRouteBlock {args} {
  Deputs "Enter proc OspfRouter::GetTopSummaryRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-blockname}
  set opt_arg_list {-startingaddress -prefixlen -number -modifier -flagautoconnect -lsaname\
  	-flagtrafficdest}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set sum_block_name $args_array(-blockname)
  if {[lsearch $m_ospfNetElementArray(namelist) $sum_block_name]<0} {
  	Deputs "$procname: Error-BlockName $sum_block_name not created."
  } else {
    set sumlsa_id $m_ospfNetElementArray($sum_block_name,id)
  	set sumlsa_ip_id $sumlsa_id/summaryIp 
	  foreach {option value} [array get args_array] {
	  	upvar $value arg
	    switch -- $option {
    		"-startingaddress" {set arg [ixNet getAttribute $sumlsa_id -linkStateId]}
    		"-prefixlen" {set arg [ixNet getAttribute $sumlsa_ip_id -networkMask]}
    		"-number" {set arg [ixNet getAttribute $sumlsa_ip_id -numberOfLsa]}
    		"-modifier" {set arg [ixNet getAttribute $sumlsa_ip_id -incrementLinkStateIdBy]}
    		"-lsaname" {set arg $m_ospfNetElementArray($sum_block_name,lsaname)}
    		"-flagautoconnect" {set arg $m_ospfNetElementArray($sum_block_name,flagautoconnect)}
    		"-flagtrafficdest" {set arg $m_ospfNetElementArray($sum_block_name,flagtrafficdest)}	      
	    }
	  } ;#end of foreach      	
  } ;#end of if_else 
  return 1 
}  
#============================================================
# 函数名称:DeleteTopSummaryRouteBlock by Shawn Li 2009.12.28
# 描述: 删除Summary类型RouteRange
# 参数:
# BlockName:要删除的Block名字标识
# 语法描述:
#  DeleteTopSummaryRouteBlock -BlockName blk1
# 返回值：                                                          
#  0 or 1
#=============================================================
itcl::body OspfRouter::DeleteTopSummaryRouteBlock {args} {
  Deputs "Enter proc OspfRouter::DeleteTopSummaryRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-blockname}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set sum_block_name $args_array(-blockname)
  if {[lsearch $m_ospfNetElementArray(namelist) $sum_block_name]<0} {
  	Deputs "$procname: Error-RouterName $sum_block_name not created."
  } else {
	  #删除IxNetwork中SummaryLSA
		ixNet remove $m_ospfNetElementArray($sum_block_name,id)
		ixNet commit  
	  #删除SummaryLSA在数组中相关变量
	  set index [lsearch $m_ospfNetElementArray(namelist) $sum_block_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$sum_block_name,*"    	
  }
  return 1  
}  
#==================================================================
# 函数名称:CreateTopExternalRouteBlock by Shawn Li 2009.12.29
# 描述: 创建External类型LSA
# 参数:
# 	支持参数：BlockName(必选)/StartingAddress/PrefixLen/Number/Modifier
#			Metric/Active/LsaName(tbd)/FlagAutoConnect/FowardingAddress/
#			ExternalTag/FlagNssa(LSA7)/Type/FlagAsbrSummary(汇聚外部路由)/
#			FlagPropagate(LSA5-LSA7转换)
#		不支持参数：FlagTrafficDest/FlagAsbr
#   注释：LSA类型虽然支持NSSA，但是API不生效
# 语法描述:
#   CreateTopExternalRouteBlock -BlockName blk1 -Type Type_1 -Active false
# 返回值：                                                          
#    0 or 1
#=======================================================================
itcl::body OspfRouter::CreateTopExternalRouteBlock {args} {
  Deputs "Enter proc OspfRouter::CreateTopExternalRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-startingaddress 13.2.0.0 -prefixlen 255.255.0.0 -number 50 -modifier 1\
 			-metric 1  -active True -lsaname To_be_defined -flagautoconnect True -fowardingaddress 0.0.0.0\
 			-externaltag 0 -flagnssa False -type Type_2 -flagtrafficdest No_support -flagasbr True\
 			-flagasbrsummary True	-flagpropagate False}   
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-blockname}
  set opt_arg_list {-startingaddress -prefixlen -number  -modifier -metric -active -lsaname \
  	-flagautoconnect -fowardingaddress -externaltag -flagnssa -type -flagtrafficdest -flagasbr\
 		-flagasbrsummary -flagpropagate}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set ext_block_name $args_array(-blockname)
  if {[lsearch $m_ospfNetElementArray(namelist) $ext_block_name]>=0} {
  	Deputs "$procname: Error-BlockName $ext_block_name already created."
  } else {
    #保存External-AS-LSA参数
  	array set m_ospfNetElementArray "$ext_block_name,startingaddress $args_array(-startingaddress)\
  	$ext_block_name,prefixlen $args_array(-prefixlen)	$ext_block_name,number $args_array(-number)\
  	$ext_block_name,modifier $args_array(-modifier)	$ext_block_name,lsaname $args_array(-lsaname)\
  	$ext_block_name,metric $args_array(-metric) $ext_block_name,active $args_array(-active)\
  	$ext_block_name,etype $args_array(-type) $ext_block_name,flagasbr $args_array(-flagasbr)\
  	$ext_block_name,flagautoconnect $args_array(-flagautoconnect)\
    $ext_block_name,flagtrafficdest $args_array(-flagtrafficdest)
    $ext_block_name,fowardingaddress $args_array(-fowardingaddress)\
    $ext_block_name,externaltag $args_array(-externaltag)\
    $ext_block_name,flagnssa $args_array(-flagnssa)\
 		$ext_block_name,flagasbrsummary $args_array(-flagasbrsummary)\
 		$ext_block_name,flagpropagate $args_array(-flagpropagate)"
    lappend m_ospfNetElementArray(namelist) $ext_block_name
    set m_ospfNetElementArray($ext_block_name,type) "externallsa"
    set m_ospfNetElementArray($ext_block_name,id) [ixNet add $m_userLsaGroupId userLsa]
    set extlsa_id $m_ospfNetElementArray($ext_block_name,id) 
    ixNet commit  
    set m_ospfNetElementArray($ext_block_name,id) [ixNet remapIds $extlsa_id]     
    #下面参数描述ExternalLSA属性(incrementLinkStateIdBy/networkMask/numberOfLsa
    #eBit/forwardingAddress/metric/routeTag
    
    #判断是LSA5还是LSA7, 选择LSA-ChildList对象
    if {[string tolower $m_ospfNetElementArray($ext_block_name,flagnssa)]==true} {
	  	set m_ospfNetElementArray($ext_block_name,extid) $extlsa_id/nssa
	  	set extlsa_ip_id $extlsa_id/nssa
    } else {
	    set m_ospfNetElementArray($ext_block_name,extid) $extlsa_id/external
	    set extlsa_ip_id $m_ospfNetElementArray($ext_block_name,extid)  
    }
    #设置ExternalLSA参数
    
    #判断LSA类型
    if {[string tolower $m_ospfNetElementArray($ext_block_name,flagnssa)]==true} {
    	ixNet setAttribute $extlsa_id -lsaType nssa	
    } elseif {[string tolower $m_ospfNetElementArray($ext_block_name,flagasbrsummary)]==true} {
    	ixNet setAttribute $extlsa_id -lsaType externalSummary	
    } else {ixNet setAttribute $extlsa_id -lsaType external}
  	ixNet setAttribute $extlsa_id -advertisingRouterId $m_ospfArgsArray(routerid)
  	ixNet setAttribute $extlsa_id -enabled $m_ospfNetElementArray($ext_block_name,active)
 
    foreach {option value} [array get args_array] {
    	set value [string tolower $value]
      switch -- $option {
    		"-startingaddress" {ixNet setAttribute $extlsa_id -linkStateId $value}
    		"-prefixlen" {ixNet setAttribute $extlsa_ip_id -networkMask [ixNumber2Ipmask $value]}
    		"-number" {ixNet setAttribute $extlsa_ip_id -numberOfLsa $value}
    		"-modifier" {ixNet setAttribute $extlsa_ip_id -incrementLinkStateIdBy 0.0.0.$value}
    		"-type"	{
    		  switch -- $value {
    				"type_1" -
    				"type1" {ixNet setAttribute $extlsa_ip_id -eBit False}
    				"type_2" -
    				"type2" {ixNet setAttribute $extlsa_ip_id -eBit True}
    			}
    		}
    		"-flagpropagate" {
    		  if {$value==true} {ixNet setAttribute $extlsa_id -option 8} 
    		}	
    		"-metric" {ixNet setAttribute $extlsa_ip_id -metric $value}
    		"-externaltag" {ixNet setAttribute $extlsa_ip_id -routeTag 0.0.0.$value}
    		"-fowardingaddress" {ixNet setAttribute $extlsa_ip_id -forwardingAddress $value}
    		"-lsaname" {set m_ospfNetElementArray($ext_block_name,lsaname) "$value,to_be_defined"}
    		"-flagautoconnect" {set m_ospfNetElementArray($ext_block_name,flagautoconnect) True}
    		"-flagtrafficdest" {set m_ospfNetElementArray($ext_block_name,flagtrafficdest) "$value,no_support"}
    		"-flagasbr" {set m_ospfNetElementArray($ext_block_name,flagasbr "$value,no_support"}
    	} ;#end of switch 
  	} ;#end of foreach 
  	ixNet commit      
  } ;#end of if_else 
	return 1
}
#=======================================================================
# 函数名称:ConfigTopExternalRouteBlock by Shawn Li 2009.12.29
# 描述:配置External类型LSA
# 参数:
# 	支持参数：BlockName(必选)/StartingAddress/PrefixLen/Number/Modifier
#			Metric/Active/LsaName(tbd)/FlagAutoConnect/FowardingAddress/
#			ExternalTag/FlagNssa(LSA7)/Type/FlagAsbrSummary(汇聚外部路由)/
#			FlagPropagate(LSA5-LSA7转换)
#		不支持参数：FlagTrafficDest/FlagAsbr
# 语法描述:
# 	ConfigTopExternalRouteBlock -BlockName blk1 -StartingAddress 1.1.1.1
# 返回值：                                                          
#    0 or 1
#========================================================================
itcl::body OspfRouter::ConfigTopExternalRouteBlock {args} {
  Deputs "Enter proc OspfRouter::ConfigTopExternalRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-startingaddress 13.2.0.0 -prefixlen 255.255.0.0 -number 50 -modifier 1\
 			-metric 1  -active True -lsaname To_be_defined -flagautoconnect True -fowardingaddress 0.0.0.0\
 			-externaltag 0 -flagnssa False -type Type_2 -flagtrafficdest No_support -flagasbr True\
 			-flagasbrsummary True	-flagpropagate False} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  
  #检查参数是否合法
  set man_arg_list {-blockname}
  set opt_arg_list {-startingaddress -prefixlen -number  -modifier -metric -active -lsaname \
  	-flagautoconnect -fowardingaddress -externaltag -flagnssa -type -flagtrafficdest -flagasbr\
 		-flagasbrsummary -flagpropagate}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set ext_block_name $args_array(-blockname)
  if {[lsearch $m_ospfNetElementArray(namelist) $ext_block_name]<0} {
  	Deputs "$procname: Error-BlockName $ext_block_name not created."
  } else {
    set extlsa_id $m_ospfNetElementArray($ext_block_name,id)
  	set extlsa_ip_id $m_ospfNetElementArray($ext_block_name,extid)
	  ixNet setAttribute $extlsa_id -enabled False
	  ixNet commit   	
    foreach {option value} [array get args_array] {
      set value [string tolower $value]
      switch -- $option {
    		"-startingaddress" {
    			set m_ospfNetElementArray($ext_block_name,startingaddress) $value
    			ixNet setAttribute $extlsa_id -linkStateId $value}
    		"-prefixlen" {
    			set m_ospfNetElementArray($ext_block_name,prefixlen) $value
    			ixNet setAttribute $extlsa_ip_id -networkMask [ixNumber2Ipmask $value]}
    		"-number" {
    			set m_ospfNetElementArray($ext_block_name,number) $value
    			ixNet setAttribute $extlsa_ip_id -numberOfLsa $value}
    		"-modifier" {
    			set m_ospfNetElementArray($ext_block_name,modifier) $value
    			ixNet setAttribute $extlsa_ip_id -incrementLinkStateIdBy 0.0.0.$value}
    		"-lsaname" {set m_ospfNetElementArray($ext_block_name,lsaname) "$value,to_be_defined"}
    		"-flagautoconnect" {set m_ospfNetElementArray($ext_block_name,flagautoconnect) True}
    		"-flagtrafficdest" {set m_ospfNetElementArray($ext_block_name,flagtrafficdest) "$value,no_support"}
    		"-flagasbr" {set m_ospfNetElementArray($ext_block_name,flagasbr "$value,no_support"}
    		"-metric" {
    			set m_ospfNetElementArray($ext_block_name,metric) $value
    			ixNet setAttribute $extlsa_ip_id -metric $value}
    		"-externaltag" {
    			set m_ospfNetElementArray($ext_block_name,externaltag) $value
    			ixNet setAttribute $extlsa_ip_id -routeTag 0.0.0.$value}
    		"-fowardingaddress" {
    			set m_ospfNetElementArray($ext_block_name,fowardingaddress) $value
    			ixNet setAttribute $extlsa_ip_id -forwardingAddress $value}
    		"-type" {
    			set m_ospfNetElementArray($ext_block_name,etype) $value
    			switch -- $value {
    				"type_1" -
    				"type1" {ixNet setAttribute $extlsa_ip_id -eBit False}
    				"type_2" -
    				"type2" {ixNet setAttribute $extlsa_ip_id -eBit True}
    			}    			
    		}
    		"-active" {
    			set m_ospfNetElementArray($ext_block_name,active) $value
    			ixNet setAttribute $extlsa_id -enabled $value
    		}	
    		"-flagnssa" {
    			set m_ospfNetElementArray($ext_block_name,flagnssa) $value	
			    if {$value==true} {
				  	set m_ospfNetElementArray($ext_block_name,extid) $extlsa_id/nssa
				  	ixNet setAttribute $extlsa_id -lsaType nssa	
			    } else {
				    set m_ospfNetElementArray($ext_block_name,extid) $extlsa_id/external
			    }    			
    		}
    		"-flagasbrsummary" {
    			set m_ospfNetElementArray($ext_block_name,flagasbrsummary) $value	
			    if {$value==true} {
				  	ixNet setAttribute $extlsa_id -lsaType externalSummary	
			    } else {ixNet setAttribute $extlsa_id -lsaType external}     		
    		}
	   	} 
  	} ;#end of foreach   	  

	  ixNet setAttribute $extlsa_id -enabled True
	  ixNet commit 
  } ;#end of if_else
  return 1
}
#=======================================================================
# 函数名称:GetTopExternalRouteBlock by Shawn Li 2009.12.29
# 描述:获取External类型LSA参数
# 参数:
# 	支持参数：BlockName(必选)/StartingAddress/PrefixLen/Number/Modifier
#			Metric/Active/LsaName(tbd)/FlagAutoConnect/FowardingAddress/
#			ExternalTag/FlagNssa(LSA7)/Type/FlagAsbrSummary(汇聚外部路由)/
#			FlagPropagate(LSA5-LSA7转换)
#		不支持参数：FlagTrafficDest/FlagAsbr
# 语法描述:
# 	GetTopExternalRouteBlock -BlockName blk1 -StartingAddress sa
# 返回值：                                                          
#    0 or 1
#========================================================================
itcl::body OspfRouter::GetTopExternalRouteBlock {args} {
  Deputs "Enter proc OspfRouter::GetTopExternalRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-blockname}
  set opt_arg_list {-startingaddress -prefixlen -number  -modifier -metric -active -lsaname \
  	-flagautoconnect -fowardingaddress -externaltag -flagnssa -type -flagtrafficdest -flagasbr\
 		-flagasbrsummary -flagpropagate}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set ext_block_name $args_array(-blockname)
  if {[lsearch $m_ospfNetElementArray(namelist) $ext_block_name]<0} {
  	Deputs "$procname: Error-BlockName $ext_block_name not created."
  } else {
    set extlsa_id $m_ospfNetElementArray($ext_block_name,id)
  	set extlsa_ip_id $m_ospfNetElementArray($ext_block_name,extid)
	  foreach {option value} [array get args_array] {
	  	upvar $value arg
	    switch -- $option {
    		"-startingaddress" {set arg [ixNet getAttribute $extlsa_id -linkStateId]}
    		"-prefixlen" {set arg [ixNet getAttribute $extlsa_ip_id -networkMask]}
    		"-number" {set arg [ixNet getAttribute $extlsa_ip_id -numberOfLsa]}
    		"-modifier" {set arg	[ixNet getAttribute $extlsa_ip_id -incrementLinkStateIdBy]}
    		"-lsaname" {set arg $m_ospfNetElementArray($ext_block_name,lsaname)}
    		"-flagautoconnect" {set arg $m_ospfNetElementArray($ext_block_name,flagautoconnect)}
    		"-flagtrafficdest" {set arg $m_ospfNetElementArray($ext_block_name,flagtrafficdest)}
    		"-metric"	{set arg [ixNet getAttribute $extlsa_ip_id -metric]} 
    		"-active" {set arg [ixNet getAttribute $extlsa_id -enabled]}     
				"-fowardingaddress" {set arg [ixNet getAttribute $extlsa_ip_id -forwardingAddress]}
				"-externaltag" {set arg [ixNet getAttribute $extlsa_ip_id -routeTag]}
				"-flagnssa" {set arg $m_ospfNetElementArray($ext_block_name,flagnssa)}
				"-type" {set arg $m_ospfNetElementArray($ext_block_name,etype)}
				"-flagasbr" {set arg $m_ospfNetElementArray($ext_block_name,flagasbr)}
				"-flagasbrsummary" {set arg $m_ospfNetElementArray($ext_block_name,flagasbrsummary)}
				"-flagpropagate" {set arg $m_ospfNetElementArray($ext_block_name,flagpropagate)}    		
	    }
	  } ;#end of foreach      	
  } ;#end of if_else 
  return 1 
}   
#============================================================
# 函数名称:DeleteTopExternalRouteBlock by Shawn Li 2009.12.29
# 描述: 删除External类型RouteRange
# 参数:
# BlockName:要删除的Block名字标识
# 语法描述:
#  DeleteTopExternalRouteBlock -BlockName blk1
# 返回值：                                                          
#  0 or 1
#=============================================================
itcl::body OspfRouter::DeleteTopExternalRouteBlock {args} {
  Deputs "Enter proc OspfRouter::DeleteTopExternalRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-blockname}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set ext_block_name $args_array(-blockname)
  if {[lsearch $m_ospfNetElementArray(namelist) $ext_block_name]<0} {
  	Deputs "$procname: Error-RouterName $ext_block_name not created."
  } else {
	  #删除IxNetwork中ExternalLSA
		ixNet remove $m_ospfNetElementArray($ext_block_name,id)
		ixNet commit  
	  #删除ExternalLSA在数组中相关变量
	  set index [lsearch $m_ospfNetElementArray(namelist) $ext_block_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$ext_block_name,*"    	
  }
  return 1  
} 
#====================================================
# 函数名称:AddRouterLsa by Shawn Li 2009.12.30
# 描述: 在SessinoRouter上添加RouterLsa
# 参数:
#		支持参数：LsaName(must)/FlagAdvertise/FlagWithdraw
#			AdvertisingRouter/LinkStateID/Numlink
# 语法描述:
#    AddRouterLsa -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::AddRouterLsa {args} {
  Deputs "Enter proc OspfRouter::AddRouterLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-flagadvertise True -flagwithdraw False -advertisingrouter 111.222.1.1\
   			-linkstateid 111.222.1.1 -number 0} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }  
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {-flagadvertise -flagwithdraw -advertisingrouter -linkstateid -number}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]>=0} {
  	Deputs "$procname: Error-RouterName $lsa_name already created."
  } else {  
  	lappend m_ospfNetElementArray(namelist) $lsa_name
  	set m_ospfNetElementArray($lsa_name,type) "lsa"
  	set m_ospfNetElementArray($lsa_name,id) [ixNet add $m_userLsaGroupId userLsa]
    #下面对象作用：描述RouterLSA ospf intf属性(bBit/eBit/interfaces/vBit)
  	set m_ospfNetElementArray($lsa_name,rtid) $m_ospfNetElementArray($lsa_name,id)/router
    ixNet commit
    set m_ospfNetElementArray($lsa_name,id) [ixNet remapIds $m_ospfNetElementArray($lsa_name,id) ]  
		set lsa_id $m_ospfNetElementArray($lsa_name,id)
		ixNet setAttribute $lsa_id -lsaType router
	  ixNet setAttribute $lsa_id -enabled $args_array(-flagadvertise)
    ixNet setAttribute $lsa_id -linkStateId $args_array(-linkstateid) 
    ixNet setAttribute $lsa_id -advertisingRouterId $args_array(-advertisingrouter)
    #Number/FlagWithdraw参数没有意义，暂不实现
    ixNet commit	  
  } 
  return 1 
}
#====================================================
# 函数名称:AddRouterLsaLink by Shawn Li 2009.12.31
# 描述: 在SessinoRouter上添加RouterLsaLink
# 参数:
#		支持参数：LsaName(must)/LinkId/LinkData/Metric/LinksType
# 语法描述:
#    AddRouterLsaLink -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::AddRouterLsaLink {args} {
  Deputs "Enter proc OspfRouter::AddRouterLsaLink...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-linkid 111.222.1.2 -linkdata 111.1.1.1 -metric 1 -linkstype pointToPoint} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }  
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {-linkid -linkdata -metric -linkstype}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
  	Deputs "$procname: Error-RouterName $lsa_name not created."
  } else {  
  	set rt_lsa_rtid $m_ospfNetElementArray($lsa_name,rtid)
 		set link_type [string tolower $args_array(-linkstype)]
	  switch -- $link_type {
			"point_to_point" -
			"point" {
				set link_type "pointToPoint"
  			set link_intf_id $args_array(-linkid)
  			set link_intf_data $args_array(-linkdata)  				
			}
			"transit_network" -
			"transit" {
  			set link_type "transit"
  			set link_intf_id $args_array(-linkid)
  			set link_intf_data $args_array(-linkdata)
 			}
			"stub_network" -
			"stub" {
				set link_type "stub"
  			set link_intf_id $args_array(-linkid)
  			set link_intf_data $args_array(-linkdata)		
			}
			"vlink" {
				set link_type "virtual"
  			set link_intf_id $args_array(-linkid)
  			set link_intf_data $args_array(-linkdata)				
			}
			default {
				set link_type "pointToPoint"
  			set link_intf_id $args_array(-linkid)
  			set link_intf_data $args_array(-linkdata) 
			}
		} ;#end of switch
		set link_intf_list "$link_intf_id $link_intf_data $link_type $args_array(-metric)"
		lappend m_ospfNetElementArray($lsa_name,intflist) $link_intf_list
		ixNet setAttribute $rt_lsa_rtid -interfaces $m_ospfNetElementArray($lsa_name,intflist)
  	ixNet commit     
  } ;#end of if_else 
  return 1 
}
#====================================================
# 函数名称:RemoveRouterLsa by Shawn Li 2009.12.31
# 描述: 删除SessinoRouter上的RouterLsa
# 参数:
#		支持参数：LsaName(must)
# 语法描述:
#    RemoveRouterLsa -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::RemoveRouterLsa {args} {
  Deputs "Enter proc OspfRouter::RemoveRouterLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
  	Deputs "$procname: Error-RouterName $lsa_name not created."
  } else {
	  #删除IxNetwork中RouterLSA
		ixNet remove $m_ospfNetElementArray($lsa_name,id)
		ixNet commit  
	  #删除RouterLSA在数组中相关变量
	  set index [lsearch $m_ospfNetElementArray(namelist) $lsa_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$lsa_name,*"    
  }
  return 1
} 
#===================================================================
# 函数名称:AddNetworkLsa by Shawn Li 2009.12.31
# 描述: 在SessinoRouter上添加NetworkLsa
# 参数:
#		支持参数：LsaName(must)/FlagAdvertise/FlagWithdraw/PrefixLength
#			AdvertisingRouter/LinkStateID/AttachedRouters
# 语法描述:
#    AddNetworkLsa -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#===================================================================
itcl::body OspfRouter::AddNetworkLsa {args} {
  Deputs "Enter proc OspfRouter::AddNetworkLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-flagadvertise True -flagwithdraw False -advertisingrouter 11.1.1.3\
   			-linkstateid 11.4.7.3 -prefixlength 24 -attachedrouters ""} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {-flagadvertise -flagwithdraw -advertisingrouter -linkstateid -prefixlength\
  			-attachedrouters}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]>=0} {
  	Deputs "$procname: Error-RouterName $lsa_name already created."
  } else {  
  	lappend m_ospfNetElementArray(namelist) $lsa_name
  	set m_ospfNetElementArray($lsa_name,type) "lsa"
  	set m_ospfNetElementArray($lsa_name,id) [ixNet add $m_userLsaGroupId userLsa]
    #下面参数描述NetworkLSA属性(neighborRouterIds-Array networkMask-IPv4)
  	set m_ospfNetElementArray($lsa_name,netid) $m_ospfNetElementArray($lsa_name,id)/network
    ixNet commit
    set m_ospfNetElementArray($lsa_name,id) [ixNet remapIds $m_ospfNetElementArray($lsa_name,id) ]  
		set lsa_id $m_ospfNetElementArray($lsa_name,id)
		ixNet setAttribute $lsa_id -lsaType network
	  ixNet setAttribute $lsa_id -enabled $args_array(-flagadvertise)
    ixNet setAttribute $lsa_id -linkStateId $args_array(-linkstateid) 
    ixNet setAttribute $lsa_id -advertisingRouterId $args_array(-advertisingrouter)
    ixNet commit
    set m_ospfNetElementArray($lsa_name,id) [ixNet remapIds $lsa_id]
    ixNet setAttribute $lsa_id/network -networkMask [ixNumber2Ipmask $args_array(-prefixlength)]
    lappend m_ospfNetElementArray($lsa_name,attchedrtlist) $args_array(-attachedrouters)
    ixNet setAttribute $lsa_id/network -neighborRouterIds	$m_ospfNetElementArray($lsa_name,attchedrtlist)	  
    ixNet commit
  } 
  return 1 
}
#====================================================
# 函数名称:AddNetworkLsaRouter by Shawn Li 2009.12.31
# 描述: 在SessinoRouter上添加NetworkLsa Router
# 参数:
#		支持参数：LsaName/Routers (must)
# 语法描述:
#    AddRouterLsaLink -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::AddNetworkLsaRouter {args} {
  Deputs "Enter proc OspfRouter::AddNetworkLsaRouter...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }  
  #检查参数是否合法
  set man_arg_list {-lsaname -routers}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
  	Deputs "$procname: Error-RouterName $lsa_name not created."
  } else {  
  	set lsa_netid $m_ospfNetElementArray($lsa_name,netid)
		lappend m_ospfNetElementArray($lsa_name,attchedrtlist) $args_array(-routers)
    ixNet setAttribute $lsa_netid -neighborRouterIds	$m_ospfNetElementArray($lsa_name,attchedrtlist)	  
    ixNet commit   
  } ;#end of if_else 
  return 1 
}
#====================================================
# 函数名称:RemoveNetworkLsa by Shawn Li 2009.12.31
# 描述: 删除SessinoRouter上的NetworkLsa
# 参数:
#		支持参数：LsaName(must)
# 语法描述:
#    RemoveNetworkLsa -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::RemoveNetworkLsa {args} {
  Deputs "Enter proc OspfRouter::RemoveNetworkLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
  	Deputs "$procname: Error-RouterName $lsa_name not created."
  } else {
	  #删除IxNetwork中NetworkLSA
		ixNet remove $m_ospfNetElementArray($lsa_name,id)
		ixNet commit  
	  #删除RouterLSA在数组中相关变量
	  set index [lsearch $m_ospfNetElementArray(namelist) $lsa_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$lsa_name,*"    
  }
  return 1
}
#===================================================================
# 函数名称:AddSummaryLsa by Shawn Li 2009.12.31
# 描述: 在SessinoRouter上添加Summary-Net-Lsa
# 参数:
#		支持参数：LsaName(must)/FlagAdvertise/FlagWithdraw/PrefixLength
#			AdvertisingRouter/Metric/FirstAddress/NumAddress/Modifier
# 语法描述:
#    AddSummaryLsa -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#===================================================================
itcl::body OspfRouter::AddSummaryLsa {args} {
  Deputs "Enter proc OspfRouter::AddSummaryLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-flagadvertise True -flagwithdraw False -advertisingrouter 111.222.1.1\
   			-firstaddress 11.2.0.0 -prefixlength 16 -metric "1" -modifier 1 -numaddress 50} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {-flagadvertise -flagwithdraw -advertisingrouter -metric -prefixlength\
  			-numaddress -firstaddress -modifier}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]>=0} {
  	Deputs "$procname: Error-RouterName $lsa_name already created."
  } else {  
  	lappend m_ospfNetElementArray(namelist) $lsa_name
  	set m_ospfNetElementArray($lsa_name,type) "lsa"
  	set m_ospfNetElementArray($lsa_name,id) [ixNet add $m_userLsaGroupId userLsa]
    #下面参数描述NetworkLSA属性(neighborRouterIds-Array networkMask-IPv4)
  	set m_ospfNetElementArray($lsa_name,sumid) $m_ospfNetElementArray($lsa_name,id)/summaryIp
    ixNet commit
    set m_ospfNetElementArray($lsa_name,id) [ixNet remapIds $m_ospfNetElementArray($lsa_name,id) ]  
		set lsa_id $m_ospfNetElementArray($lsa_name,id)
		ixNet setAttribute $lsa_id -lsaType areaSummary
	  ixNet setAttribute $lsa_id -enabled $args_array(-flagadvertise)
    ixNet setAttribute $lsa_id -advertisingRouterId $args_array(-advertisingrouter)
    ixNet setAttribute $lsa_id -linkStateId $args_array(-firstaddress)
    ixNet setAttribute $lsa_id/summaryIp -networkMask [ixNumber2Ipmask $args_array(-prefixlength)]
    ixNet setAttribute $lsa_id/summaryIp -numberOfLsa $args_array(-numaddress)
    ixNet setAttribute $lsa_id/summaryIp -incrementLinkStateIdBy 0.0.0.$args_array(-modifier)	
    ixNet setAttribute $lsa_id/summaryIp -metric $args_array(-metric)	  
    ixNet commit
  } 
  return 1 
}

#====================================================
# 函数名称:RemoveSummaryLsa by Shawn Li 2009.12.31
# 描述: 删除SessinoRouter上的Lsa
# 参数:
#		支持参数：LsaName(must)
# 语法描述:
#    RemoveSummaryLsa -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::RemoveSummaryLsa {args} {
  Deputs "Enter proc OspfRouter::RemoveSummaryLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
  	Deputs "$procname: Error-LSAName $lsa_name not created."
  } else {
		ixNet remove $m_ospfNetElementArray($lsa_name,id)
		ixNet commit  
	  set index [lsearch $m_ospfNetElementArray(namelist) $lsa_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$lsa_name,*"    
  }
  return 1
}
#===================================================================
# 函数名称:AddAsExtLsa by Shawn Li 2009.12.31
# 描述: 在SessinoRouter上添加Ext-Lsa
# 参数:
#		支持参数：LsaName(must)/FlagAdvertise/FlagWithdraw/PrefixLen
#			AdvertisingRouter/Metric/FirstAddress/NumAddress/Modifier
#			ForwardingAddress/ExternalTag/FlagEbit
# 语法描述:
#    AddAsExtLsa -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#===================================================================
itcl::body OspfRouter::AddAsExtLsa {args} {
  Deputs "Enter proc OspfRouter::AddAsExtLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #初始化args_array数组
  array set args_array {-flagadvertise True -flagwithdraw False -advertisingrouter 111.222.1.1\
   			-firstaddress 8.0.0.0 -prefixlen 8 -metric "1" -modifier 1 -numaddress 50\
   			-forwardingaddress 0.0.0.0 -externaltag 0 -flagebit 0} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {-flagadvertise -flagwithdraw -advertisingrouter -metric -prefixlen\
  			-numaddress -firstaddress -modifier -forwardingaddress -externaltag -flagebit}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]>=0} {
  	Deputs "$procname: Error-RouterName $lsa_name already created."
  } else {  
  	lappend m_ospfNetElementArray(namelist) $lsa_name
  	set m_ospfNetElementArray($lsa_name,type) "lsa"
  	set m_ospfNetElementArray($lsa_name,id) [ixNet add $m_userLsaGroupId userLsa]
  	set m_ospfNetElementArray($lsa_name,extid) $m_ospfNetElementArray($lsa_name,id)/external
    ixNet commit
    set m_ospfNetElementArray($lsa_name,id) [ixNet remapIds $m_ospfNetElementArray($lsa_name,id) ]  
		set lsa_id $m_ospfNetElementArray($lsa_name,id)
		ixNet setAttribute $lsa_id -lsaType external
	  ixNet setAttribute $lsa_id -enabled $args_array(-flagadvertise)
    ixNet setAttribute $lsa_id -advertisingRouterId $args_array(-advertisingrouter)
    ixNet setAttribute $lsa_id -linkStateId $args_array(-firstaddress)
    
    ixNet setAttribute $lsa_id/external -networkMask [ixNumber2Ipmask $args_array(-prefixlen)]
    ixNet setAttribute $lsa_id/external -numberOfLsa $args_array(-numaddress)
    ixNet setAttribute $lsa_id/external -incrementLinkStateIdBy 0.0.0.$args_array(-modifier)	
    ixNet setAttribute $lsa_id/external -metric $args_array(-metric)
    ixNet setAttribute $lsa_id/external -eBit $args_array(-flagebit)
    ixNet setAttribute $lsa_id/external -routeTag 0.0.0.$args_array(-externaltag) 
    ixNet setAttribute $lsa_id/external -forwardingAddress $args_array(-forwardingaddress) 
    ixNet commit
  } 
  return 1 
} 
#====================================================
# 函数名称:RemoveAsExtLsa by Shawn Li 2009.12.31
# 描述: 删除SessinoRouter上的Lsa
# 参数:
#		支持参数：LsaName(must)
# 语法描述:
#    RemoveAsExtLsa -lsaname lsa1 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::RemoveAsExtLsa {args} {
  Deputs "Enter proc OspfRouter::RemoveAsExtLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {-lsaname}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  set lsa_name $args_array(-lsaname)
  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
  	Deputs "$procname: Error-LSAName $lsa_name not created."
  } else {
		ixNet remove $m_ospfNetElementArray($lsa_name,id)
		ixNet commit  
	  set index [lsearch $m_ospfNetElementArray(namelist) $lsa_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$lsa_name,*"    
  }
  return 1
}
#====================================================
# 函数名称:AdvertiseLsas by Shawn Li 2009.12.31
# 描述: 通告OSPF LSA
# 参数:
#		支持参数：LsaNameList
# 语法描述:
#    AdvertiseLsas -LsaNameList {lsa1 lsa2} 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body IxiaCapi::OspfRouter::AdvertiseLsas {args} {
  Deputs "Enter proc OspfRouter::AdvertiseLsas...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {}
  set opt_arg_list {-lsanamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  if {![info exist args_array(-lsanamelist)]} {
  	#对全部LSA进行通告
    foreach lsa_name $m_ospfNetElementArray(namelist) {
    	if {$m_ospfNetElementArray($lsa_name,type)=="lsa"} {
				ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
			}
  	}
  	ixNet commit
  } else {
    foreach lsa_name $args_array(-lsanamelist) {
		  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
		  	Deputs "$procname: Error-LSAName $lsa_name not created."
		    return $::FAILURE
		  } else {
	  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
   	  }
		}
		ixNet commit  
	} ;#end of if_else
	return 1
}  
#====================================================
# 函数名称:WithdrawLsas by Shawn Li 2009.12.31
# 描述: 撤销OSPF LSA
# 参数:
#		支持参数：LsaNameList
# 语法描述:
#    WithdrawLsas -LsaNameList {lsa1 lsa2} 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body IxiaCapi::OspfRouter::WithdrawLsas {args} {
  Deputs "Enter proc OspfRouter::WithdrawLsas...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {}
  set opt_arg_list {-lsanamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  if {![info exist args_array(-lsanamelist)]} {
    #对全部LSA进行撤销
    foreach lsa_name $m_ospfNetElementArray(namelist) {
      #排除前面创建的RouterLsa
    	if {$m_ospfNetElementArray($lsa_name,type)=="lsa"} {
				ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled False
			}
  	}
  	ixNet commit
  } else {
    foreach lsa_name $args_array(-lsanamelist) {
		  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
		  	Deputs "$procname: Error-LSAName $lsa_name not created."
		    return $::FAILURE
		  } else {
	  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled False
		  }
		} ;#end of foreach 
		ixNet commit 
	} ;#end of if_else
	return 1
} 
#====================================================
# 函数名称:AdvertiseRouters by Shawn Li 2009.12.31
# 描述: 通告OSPF RouterLSA/Grid
# 参数:
#		支持参数：RouterNameList
# 语法描述:
#    AdvertiseRouters -RouterNameList {rt1 rt2} 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body IxiaCapi::OspfRouter::AdvertiseRouters {args} {
  Deputs "Enter proc OspfRouter::AdvertiseRouters...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {}
  set opt_arg_list {-routernamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  if {![info exist args_array(-routernamelist)]} {
  	#对全部RouterLSA进行通告
		foreach lsa_name $m_ospfNetElementArray(namelist) {
			set lsa_type $m_ospfNetElementArray($lsa_name,type)
    	if {$lsa_type=="routerlsa"} {
	  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
	  	} elseif {$lsa_type=="grid"} {    	
	  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled True
  		}
  		ixNet commit
  	}
  } else {
    foreach lsa_name $args_array(-routernamelist) {
		  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
		  	Deputs "$procname: Error-LSAName $lsa_name not created."
		    return $::FAILURE
		  } else {
				set lsa_type $m_ospfNetElementArray($lsa_name,type)
	    	if {$lsa_type=="routerlsa"} {
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
		  	} elseif {$lsa_type=="grid"} {    	
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled True
	  		}
	  		ixNet commit	  
		  }
		} ;#end of foreach 
	} ;#end of if_else
	return 1
}  
#====================================================
# 函数名称:WithdrawRouters by Shawn Li 2009.12.31
# 描述: 撤销OSPF RouterLSA/Grid
# 参数:
#		支持参数：LsaNameList
# 语法描述:
#    WithdrawRouters -RouterNameList {rt1 rt2} 
# 返回值：                                                          
#    0 or 1
#=====================================================
itcl::body IxiaCapi::OspfRouter::WithdrawRouters {args} {
  Deputs "Enter proc OspfRouter::WithdrawRouters...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {}
  set opt_arg_list {-routernamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  if {![info exist args_array(-routernamelist)]} {
  	#对全部RouterLSA进行通告
		foreach lsa_name $m_ospfNetElementArray(namelist) {
			set lsa_type $m_ospfNetElementArray($lsa_name,type)
    	if {$lsa_type=="routerlsa"} {
	  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled False
	  	} elseif {$lsa_type=="grid"} {    	
	  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled False
  		}
  		ixNet commit
  	} ;#end of foreach
  } else {
    foreach lsa_name $args_array(-routernamelist) {
		  if {[lsearch $m_ospfNetElementArray(namelist) $lsa_name]<0} {
		  	Deputs "$procname: Error-LSAName $lsa_name not created."
		    return $::FAILURE
		  } else {
				set lsa_type $m_ospfNetElementArray($lsa_name,type)
	    	if {$lsa_type=="routerlsa"} {
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled False
		  	} elseif {$lsa_type=="grid"} {    	
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled False
	  		}
	  		ixNet commit	  
		  }
		} ;#end of foreach 
	} ;#end of if_else
	return 1
}
#=====================================================
# 函数名称:ConfigFlap by Shawn Li 2009.12.31
# 描述:配置ospf协议震荡频率
# 参数:AWDTimer/WADTimer
# 语法描述:
#  ConfigFlap -AWDTimer 1000 -WADTimer 1000
# 返回值：                                                          
#  0 or 1
#=====================================================
itcl::body OspfRouter::ConfigFlap {args} {
  Deputs "Enter proc OspfRouter::ConfigFlap...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]    
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO  "$procname: $error."
      puts "arg error!"
      return $::FAILURE
  }
  #检查参数是否合法
  set man_arg_list {}
  set opt_arg_list {-awdtimer -wadtimer}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }    
  #comments:根据ZTE最新需求，interval参数删除，添加number到start函数
  if {[info exists args_array(-awdtimer)]} {
     set m_ospfFlapArgsArray(awdtimer) $args_array(-awdtimer)
  }
  if {[info exists args_array(-wadtimer)]} {
      set m_ospfFlapArgsArray(wadtimer) $args_array(-wadtimer)
  }
  return 1   
}
#===========================================================
# 函数名称:StartFlapRouters by Shawn Li 2009.12.31
# 描述:振荡OSPF拓扑路由器
# 参数:
# RouterNameList/FlapNum 
# 语法描述:
#  StartFlapRouters -RouterNameList rt1 
# 返回值：                                                          
#  0 or 1
#===========================================================
itcl::body IxiaCapi::OspfRouter::StartFlapRouters {args} {
  Deputs "Enter proc OspfRouter::StartFlapRouters...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO  "$procname: $error."
      puts "arg error!"
      return $::FAILURE
  }      
  #检查参数是否合法
  set man_arg_list {}
  set opt_arg_list {-routernamelist -flapnum}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  } 
  if {[info exists args_array(-flapnum)]} {
     set m_ospfFlapArgsArray(number) $args_array(-flapnum)
  }  
  if {![info exist args_array(-routernamelist)]} {
    #对全部RouterLSA进行通告
    #Flap次数循环
  	for {set i 1} {$i<=$m_ospfFlapArgsArray(number)} {incr i} {
  		Deputs "Sum. of flapping $m_ospfFlapArgsArray(number), No.$i times"
			foreach lsa_name $m_ospfNetElementArray(namelist) {
				set lsa_type $m_ospfNetElementArray($lsa_name,type)
	      if {$lsa_type=="routerlsa"} {
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
		  	} elseif {$lsa_type=="grid"} {    	
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled True
	  		}
	  	}
	  	ixNet commit
	    after $m_ospfFlapArgsArray(awdtimer)
		  foreach lsa_name $m_ospfNetElementArray(namelist) {
			  set lsa_type $m_ospfNetElementArray($lsa_name,type)
	      if {$lsa_type=="routerlsa"} {
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled False
		  	} elseif {$lsa_type=="grid"} {    	
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled False
	  		}
	  	}
	  	ixNet commit	  	
	    after $m_ospfFlapArgsArray(wadtimer)	
  	} ;#end of for_loop
  } else {
  	#Flap次数循环
    for {set i 1} {$i<=$m_ospfFlapArgsArray(number)} {incr i} {
    	Deputs "Sum. of flapping $m_ospfFlapArgsArray(number), No.$i times"
		  foreach lsa_name $args_array(-routernamelist) {
		    #根据Router类型设置enabled属性		  
				set lsa_type $m_ospfNetElementArray($lsa_name,type)
	      if {$lsa_type=="routerlsa"} {
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
		  	} elseif {$lsa_type=="grid"} {    	
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled True
	  		}
		  }
	  	ixNet commit
	    after $m_ospfFlapArgsArray(awdtimer)
	    #adv到withd等待时间
		  foreach lsa_name $args_array(-routernamelist) {
			  set lsa_type $m_ospfNetElementArray($lsa_name,type)
	      if {$lsa_type=="routerlsa"} {
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled False
		  	} elseif {$lsa_type=="grid"} {    	
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled False
	  		}
	  	}	
	  	ixNet commit  	
	    after $m_ospfFlapArgsArray(wadtimer)	
  	} ;#end of for_loop
  } ;#end of if_else
  return 1 
}
#======================================================
# 函数名称:StopFlapRouters by Shawn Li 2009.12.31
# 描述:停止振荡OSPF拓扑路由器
# 参数:
# 语法描述:
#   StopFlapRouters 
# 返回值：                                                          
#  0 or 1
#======================================================
itcl::body OspfRouter::StopFlapRouters {args} {
  Deputs "Enter proc OspfRouter::StopFlapRouters...\n"
  #根据IxNetwork特点，以及HLAPI规范，此处不需做处理
  return 1
}
#===========================================================
# 函数名称:StartFlapLsas by Shawn Li 2009.12.31
# 描述:振荡OSPF拓扑路由器
# 参数:
# LsaNameList/FlapNum 
# 语法描述:
#  StartFlapLsas -RouterNameList rt1 
# 返回值：                                                          
#  0 or 1
#=========================================================== 
itcl::body IxiaCapi::OspfRouter::StartFlapLsas {args} {
  Deputs "Enter proc OspfRouter::StartFlapLsas...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0] 
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO  "$procname: $error."
      puts "arg error!"
      return $::FAILURE
  }    
  #检查参数是否合法
  set man_arg_list {}
  set opt_arg_list {-lsanamelist -flapnum}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  } 
  if {[info exists args_array(-flapnum)]} {
     set m_ospfFlapArgsArray(lsanumber) $args_array(-flapnum)
  }    
  if {![info exist args_array(-lsanamelist)]} {
    #对全部RouterLSA进行通告
    #Flap次数循环
  	for {set i 1} {$i<=$m_ospfFlapArgsArray(lsanumber)} {incr i} {
  		Deputs "Sum. of flapping $m_ospfFlapArgsArray(number), No.$i times"
	    foreach lsa_name $m_ospfNetElementArray(namelist) {
	    	if {$m_ospfNetElementArray($lsa_name,type)=="lsa"} {
					ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
				}
	  	}  		
	  	ixNet commit
	    after $m_ospfFlapArgsArray(awdtimer)
	    foreach lsa_name $m_ospfNetElementArray(namelist) {
	    	if {$m_ospfNetElementArray($lsa_name,type)=="lsa"} {
					ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled False
				}
	  	}
	  	ixNet commit	  	
	    after $m_ospfFlapArgsArray(wadtimer)	
  	} ;#end of for_loop
  } else {
  	#Flap次数循环
    for {set i 1} {$i<=$m_ospfFlapArgsArray(lsanumber)} {incr i} {
    	Deputs "Sum. of flapping $m_ospfFlapArgsArray(number), No.$i times"
		  foreach lsa_name $args_array(-lsanamelist) {
				ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
	  	}
	  	ixNet commit
	    after $m_ospfFlapArgsArray(awdtimer)
	    #adv到withd等待时间
		  foreach lsa_name $args_array(-lsanamelist) {
				ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled False
	  	}	
	  	ixNet commit  	
	    after $m_ospfFlapArgsArray(wadtimer)	
  	} ;#end of for_loop
  }
  return 1 
}
itcl::body OspfRouter::StopFlapLsas {args} {
  Deputs "Enter proc OspfRouter::StopFlapLsas...\n"
  #根据IxNetwork特点，以及HLAPI规范，此处不需做处理
  return 1
} 
#=======================================================
# 函数名称:GraceRestartAction by Shawn Li 2009.12.31
# 描述: 启动所有Ospf Router 的GR功能
# 语法描述:
#   GraceRestartAction
# 返回值：                                                          
#    0 or 1
#=======================================================
itcl::body IxiaCapi::OspfRouter::GraceRestartAction {args} {
  Deputs "Enter proc OspfRouter::GraceRestartAction...\n"
  ixNet setAttribute $m_ixRouterId -gracefulRestart true
  ixNet commit
  return 1
}
#=======================================================
# 函数名称:GetRouterStats by Shawn Li 2010.1.13
# 描述: 获取OSPF Router信息
# 参数：
#		支持参数：NumHelloReceived/NumDbdReceived/NumRtrLsaReceived
#			NumNetLsaReceived/NumSum4LsaReceived/NumSum3LsaReceived/NumExtLsaReceived
#			NumOpq9LsaReceived/NumOpq10LsaReceived/NumOpq11LsaReceived
#			NumType7LsaReceived/NumHelloSent/NumDbdSent/NumRtrLsaSent
#			NumNetLsaSent/NumSum4LsaSent/NumSum3LsaSent/NumExtLsaSent/NumOpq9LsaSent
#			NumOpq10LsaSent/NumOpq11LsaSent/NumType7LsaSent
#		
# 语法描述:
# 返回值：                                                          
#    0 or 1
#=======================================================
itcl::body IxiaCapi::OspfRouter::GetRouterStats {args} {
  Deputs "Enter proc OspfRouter::GetRouterStats...\n"
  set args     [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #读取输入参数并进行赋值
  #----------------------
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO "$procname: $error."
      return $::FAILURE
  }
  set statViewList [ixNet getList [ixNet getRoot]/statistics statViewBrowser]
  if {$statViewList != ""} {
  	#查找OSPF统计标签
  	foreach statView $statViewList {
  		set statName [ixNet getAttribute $statView -name]
  		if {[string first "OSPF Aggregated Statistics" $statName] >= 0} {
  		  set ospfView $statView
  		  break
  		}
  	}
    ixNet setAttribute $ospfView -enabled True
    ixNet commit
    #建立本端口的Row标示，由于OSPF统计项可能存在多个端口使能OSPF
    set chassisId [ixNet getList [ixNet getRoot]/availableHardware chassis]
    set chassisIp [ixNet getAttribute $chassisId -hostname]
    set rowId "$chassisIp/Card[format %02s $m_slotId]/Port[format %02s $m_portId]"
    set rowList [ixNet getList $ospfView row]
    #查找本端口的OSPF统计标签
    foreach rowView $rowList {
    	set rowName [ixNet getAttribute $rowView -name]
  		if {[string first "OSPF Aggregated Statistics" $statName] >= 0} {
  		  set ospfRow $rowView
  		  break
  		}    	
    }
    set cellList [ixNet getList $ospfRow cell]
    
    #对参数进行赋值
	  foreach {option value} [array get args_array] {
	    upvar $value arg
	    switch -- $option {
	    	"-during" {set arg "Not_Support"}
	      "-numhelloreceived" {set cell [lindex $cellList 11]
	      set arg [ixNet getAttribute $cell -statValue]}
	      "-numhellosent" {set cell [lindex $cellList 12]
	      set arg [ixNet getAttribute $cell -statValue]}
        "-numdbdreceived" {set cell [lindex $cellList 1]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numdbdsent" {set cell [lindex $cellList 2]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numrtrlsareceived" {set cell [lindex $cellList 37]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numrtrlsasent" {set cell [lindex $cellList 38]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numnetlsareceived" {set cell [lindex $cellList 29]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numnetlsasent" {set cell [lindex $cellList 30]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numsum3lsareceived" {set cell [lindex $cellList 42]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numsum3lsasent" {set cell [lindex $cellList 43]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numsum4lsareceived" {set arg "Not_Support"}
        "-numsum4lsasent" {set arg "Not_Support"}
        "-numextlsareceived" {set cell [lindex $cellList 40]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numextlsasent" {set cell [lindex $cellList 41]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numtype7lsareceived" {set cell [lindex $cellList 27]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numtype7lsasent" {set cell [lindex $cellList 28]
        set arg [ixNet getAttribute $cell -statValue]}  
        "-numopq9lsareceived" {set cell [lindex $cellList 35]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numopq9lsasent" {set cell [lindex $cellList 36]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numopq10lsareceived" {set cell [lindex $cellList 31]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numopq10lsasent" {set cell [lindex $cellList 32]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numopq11lsareceived" {set cell [lindex $cellList 33]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numopq11lsasent" {set cell [lindex $cellList 34]
        set arg [ixNet getAttribute $cell -statValue]}
        "-numotherlsasent" {set arg "Not_Support"}
        "-numotherlsareceived" {set arg "Not_Support"}
        "-numdblsainserted" {set arg "Not_Support"}
        "-numdbssaremoved" {set arg "Not_Support"}
	    }
    } ;#end of foreach_switch     
  } ;#end of if_else
 
  return 1
}

#===========================================
#IXIA仪表不支持特性函数
#===========================================
itcl::body OspfRouter::AdvertiseLinks {args} {
}
itcl::body OspfRouter::WithdrawLinks {args} {
}
itcl::body OspfRouter::StartFlapLinks {args} {
}	
itcl::body OspfRouter::StopFlapLinks {args} {
}
} ;#end of namespace eval IxiaCapi