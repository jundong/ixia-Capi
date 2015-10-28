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

  #���캯������Ĭ������ospf·����
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
    
    #����ospf·��������ز���
    set m_ixRouterId [ixNet add $m_vportId/protocols/ospf router]
    ixNet setAttribute $m_ixRouterId -discardLearnedLsa $m_ospfArgsArray(flaglasdiscardmode)  
    ixNet setAttribute $m_ixRouterId -enabled $m_ospfArgsArray(active)
    ixNet setAttribute $m_ixRouterId -routerId $m_routerId
    ixNet setAttribute $m_ixRouterId -supportForRfc3623 True
    ixNet setAttribute $m_ixRouterId -supportReasonSoftRestart True
    ixNet setAttribute $m_ixRouterId -supportReasonSoftReloadUpgrade False
    ixNet setAttribute $m_ixRouterId -supportReasonUnknown False
    ixNet setAttribute $m_ixRouterId -supportReasonSwotchRedundantCntrlProcessor False

	  #����ospf interface�����Ĭ�ϲ���
 	  set m_intfId [ixNet add $m_ixRouterId interface]
		ixNet setMultiAttrs $m_intfId \
		 -areaId $m_ospfArgsArray(area) -authenticationMethods null \
		 -authenticationPassword $m_ospfArgsArray(password) -bBit False \
		 -connectedToDut True -deadInterval $m_ospfArgsArray(deadinterval) \
		 -eBit True -enabled True -helloInterval $m_ospfArgsArray(hellointerval) \
		 -md5AuthenticationKey {} -md5AuthenticationKeyId $m_ospfArgsArray(md5keyid) \
		 -metric $m_ospfArgsArray(interfacecost) -mtu $m_ospfArgsArray(mtu)\
		 -networkType $m_ospfArgsArray(networktype) -options 2 -priority $m_ospfArgsArray(routerpriority) 
	  
	  #����LsaGroup,���LSAʹ�� 
		set m_userLsaGroupId [ixNet add $m_ixRouterId userLsaGroup] 
		ixNet setAttribute $m_userLsaGroupId -enabled True 
		ixNet setAttribute $m_userLsaGroupId -areaId $m_ospfArgsArray(area)
		
    #�鿴�Ƿ���ں�Ĭ��testipһ�µ�interface
    #���������assign��ospf intf������ospf intf Ϊnull
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

  
  #Ŀǰ��֧�ֺ���
  public method StopFlapLinks
  public method StartFlapLinks
  public method WithdrawLinks
  public method AdvertiseLinks
    

}


#====================================================================
# ��������:ConfigRouter by Shawn Li 20091214                                                 
# ����: ����OSPF Router �����п�ѡ��������
# ֧�ֲ�����
# 	Area,NetworkType,RouterID,PduOptionValue,FlagTE,NetworkType,InterfaceCost
#		HelloInterval,DeadInterval,InterfaceCost,MTU,FlagGraceRestart,RouterPriority
#   Active,AuthenticationType,Password,Md5KeyId,FlagLSADiscardMode,RestarReason
# ��֧�ֲ�����FlagGre,GreLocal,GreRemote,FlagGreIncludeChecksum,PollInterval
#		RetransmitInterval,MaxLSAsPerPacket,TransitDelay,GracePeriod,FlagHostRoute
#   
# ע�ͣ�IpAddr��SutIpAddress�Ƚӿ���ز�����hostָ���������ڴ˺�������
#====================================================================
itcl::body OspfRouter::ConfigRouter {args} {
	Deputs "Enter proc OspfRouter::ConfigRouter...\n"
  set args     [IxiaCapi::Regexer::ixConvertAllToLowerCase $args]

  set procname [lindex [info level [info level]] 0]
  
  #��ȡ������������и�ֵ
  #----------------------
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO "$procname: $error."
      return $::FAILURE
  }
  
  #�ж��Ƿ��Ѿ���-ipaddr��host����
  #������ڽ���assign��ospf intf���򱨴�
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
	
  #��ospf router��ospf intf֧�ֵĲ�������
  #Notes: �˴�û�н�ospf�����Ա��������
  #---------------------------------------
  foreach {option value} [array get args_array] {
    switch -- $option {
      #��ospf router���ֵ�����
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
      #��ospf interface���ֵ�����
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
          #����˲�����10������Ϊ���������IxNetwork����ֱ��������Ӧbit
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
		  #��ospf router��ospf intf��֧�ֵĲ�������
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
				
		  #�����ڴ˺��������õĲ���IpAddr/PrefixLen/SutIpAddress/SutPrefixLen		
    };#end of switch option_value
  };#end of foreach
	ixNet commit
  
  return 1 
}

#====================================================================
# ��������:GetRouter by Shawn Li 20091218                                                 
# ����: ��ȡOSPF Router �����п�ѡ��������
# ֧�ֲ�����
# 	Area,NetworkType,RouterID,PduOptionValue,FlagTE,NetworkType,InterfaceCost
#		HelloInterval,DeadInterval,InterfaceCost,MTU,FlagGraceRestart,RouterPriority
#   Active,AuthenticationType,Password,Md5KeyId,FlagLSADiscardMode,RestarReason
#   IpAddr/PrefixLen/SutIpAddress/SutPrefixLen/SutRouterID
# ��֧�ֲ�����FlagGre,GreLocal,GreRemote,FlagGreIncludeChecksum,PollInterval
#		RetransmitInterval,MaxLSAsPerPacket,TransitDelay,GracePeriod,FlagHostRoute
#====================================================================
itcl::body OspfRouter::GetRouter {args} {
	Deputs "Enter proc OspfRouter::GetRouter...\n"
  set args     [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ȡ������������и�ֵ
  #----------------------
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO "$procname: $error."
      return $::FAILURE
  }
  foreach {option value} [array get args_array] {
  	upvar $value arg
    switch -- $option {
    #��ospf router���ֵ�����
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
# ����: ʹ��ָ����ospf Router 
# ����:
# �﷨����:                                                         
#    <obj> Enable
# ����ֵ�� 
#   �ɹ���������0 
#=========================================
itcl::body OspfRouter::Enable {args} {
	Deputs "Enter proc OspfRouter::Enable...\n"
	ixNet setAttribute $m_ixRouterId -enabled true
	ixNet commit
	return 1
}
#��������:Disable by Shawn Li 2009.12.21  
itcl::body OspfRouter::Disable {args} {
	Deputs "Enter proc OspfRouter::Disable...\n"
	ixNet setAttribute $m_ixRouterId -enabled false
	ixNet commit
	return 1
}

#=======================================================
# ��������:AddTopGrid by Shawn Li 2009.12.21                                                 
# ����: ���ospf grid����
# ����:
# 	֧�ֲ���:StartingRouterID(�̶���1.1.x.y��ʼ,Ixiaʵ����x.x.x.xʵ�ֵ�����
# 	GridRows(����)/GridColumns(����)/GridName(����)/GridLinkType(broadcast,pointTopoint)
# 	Flagadvertise(�Ƿ�ͨ��)/FlagTe(֧��TE)/FlagAutoConnect(�Ƿ�����SR��IxiaĬ������) 
# 	��֧�ֲ���:StartingGmplsInterface/StartingTeInterface
# �﷨����:                                                         
#    AddTopGrid -gridname xx -GridRows 50 -GridColumns 100
# ����ֵ�� 
#    �ɹ�����0�����򷵻�1
#=======================================================
itcl::body OspfRouter::AddTopGrid {args} {
	Deputs "Enter proc OspfRouter::AddTopGrid...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0] 
	
  #�������Ƿ�Ϸ�
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
  #�ж�gridname�Ƿ��Ѿ�����,���Գ�ʼ������
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
  #�Կ�ѡ�������и�ֵ
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
# ��������: GetTopGrid by Shawn Li 2009.12.21                                                 
# ����: ��ȡospf grid���˲���
# ����:
# 	֧�ֲ���:StartingRouterID(�̶���1.1.x.y��ʼ,Ixiaʵ����x.x.x.xʵ�ֵ�����
# 	GridRows(����)/GridColumns(����)/GridName(����)/GridLinkType(broadcast,pointTopoint)
# 	Flagadvertise(�Ƿ�ͨ��)/FlagTe(֧��TE)/FlagAutoConnect(�Ƿ�����SR��IxiaĬ������) 
# 	��֧�ֲ���:StartingGmplsInterface/StartingTeInterface
# �﷨����:                                                         
#    GetTopGrid -gridname grid1 -GridRows row -GridColumns col
# ����ֵ�� 
#    �ɹ�����0�����򷵻�1
#=======================================================
itcl::body OspfRouter::GetTopGrid {args} {
  Deputs "Enter proc OspfRouter::GetTopGrid...\n"
  set procname [lindex [info level [info level]] 0]
  set args [ixConvertToLowerCase $args]
  if {[catch {array set args_array $args} error]} {
	  set ::ERRINFO  "$procname: $error."
	  return $::FAILURE
  }
  #�������Ƿ�Ϸ�
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
    
  #�ж�gridname�Ƿ��Ѿ�����,���Գ�ʼ������
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
# ��������:GetTopGridRouter by Shawn Li 2009.12.22
# ����: ��ȡospfRotuer��Ӧ��Gridrouter��������Ϣ
# ����: 
#		֧�ֲ�����GridName/RouterName/Column/Row(��ѡ)
# �﷨����:           
#   GetTopGridRouter -GridName grid1 -Column 2 -Row 2 -RouterName name   
# ����ֵ��                                                                  
#    ���ض�Ӧ��ֵ����ֵ��ָ������           
#================================================================         
itcl::body OspfRouter::GetTopGridRouter {args} {
  Deputs "Enter proc OspfRouter::GetTopGridRouter...\n"
  set procname [lindex [info level [info level]] 0]
  set args [ixConvertToLowerCase $args]
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO  "$procname: $error."
       return $::FAILURE
  }
  #�������Ƿ�Ϸ�
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
  #�ж�gridname�Ƿ��Ѿ�����
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
# ��������:AddTopRouterLink by Shanw Li 2009.12.22
# ����: ��ĳ��router�����Link
# ����: 
#   ֧�ֲ���: RouterName/linkconnectedname/LinkName(��ѡ)
#		LinkType/FlagTe(Grid֧��)/FlagAdvertise/LinkMetric(LSA֧��)/
#		Linkinterface(LSA֧��)/TeMetric(Grid֧��)/TeMaxBandwith(Grid֧��)
#   TeReserveBandwith(Grid֧��)/LinkLsaName(��չ��)
#   ��֧�ֲ�����FlagGmpls/LinkTeLsaName/TelinkID/LinkTeInstance
#			TeLocalAddress/TeRemoteAddress/TeLinkType/FlagTelinkNumber
#			TeInstance/TeUnReserveBandwith/TeResourceClass
# �﷨����:
#   AddTopRouterLink -RouterName ospf1 -linkconnectedname grid1 -LinkName link1 
# ����ֵ��                                                          
#    ����FAILURE��SUCCESS
#==============================================================
itcl::body OspfRouter::AddTopRouterLink {args} {
  Deputs "Enter proc OspfRouter::AddTopRouterLink...\n"
  set procname [lindex [info level [info level]] 0]
  set args [ixConvertToLowerCase $args]

  #1)��args_array����ʼֵ2)����޸������Ա����3)�������Ƿ�Ϸ���Ч
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
 
  #�ж�router���ӵĶ����Ƿ����
  if {[lsearch $m_ospfNetElementArray(namelist) $link_cnt_name]<0} {
  	Deputs "$procname: Error-LinkConnectedName $link_cnt_name not created."
  	return $::FAILURE		
  }
  #�ж�link�����Ƿ���� 
  if {[lsearch $m_ospfNetElementArray(namelist) $link_name]>=0} {
  	Deputs "$procname: Error-LinkName $link_name already created."
  	return $::FAILURE		  	
  } else {
  	lappend m_ospfNetElementArray(namelist) $link_name
  } ;#end of if_else
   
  #AddTopRouterLink��Ϊ���������1)����Grid�е�router 2)����TopRouter�ȣ���LSA
  set net_element_type $m_ospfNetElementArray($link_cnt_name,type) 
  switch -- $net_element_type {
  	"gridrouter" {
  	  #����link�����Լ�link���ӵĶ���
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
  	  #����RouterName�Ĳ�ͬ���ֱ��Ӧ��ͬ��RouterID
  	  #�˴���ʱû�����TopRouter����Network�Ĵ��룬����RouterLSA����ӵ�Network��link
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
  	  #����RouterName�Ĳ�ͬ���ֱ��Ӧ��ͬ��AdvRouterID
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
  	  #����RouterName�Ĳ�ͬ���ֱ��Ӧ��ͬ��AdvRouterID
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
# ��������:ConfigTopRouterLink by Shawn Li 2009.12.24
# ����: ����Link
# ����:
#   ֧�ֲ���: RouterName/linkconnectedname/LinkName(��ѡ)
#		LinkType/FlagTe(Grid֧��)/FlagAdvertise/LinkMetric(LSA֧��)/
#		Linkinterface(LSA֧��)/TeMetric(Grid֧��)/TeMaxBandwith(Grid֧��)
#   TeReserveBandwith(Grid֧��)/LinkLsaName(��չ��)
#   ��֧�ֲ�����FlagGmpls/LinkTeLsaName/TelinkID/LinkTeInstance
#			TeLocalAddress/TeRemoteAddress/TeLinkType/FlagTelinkNumber
#			TeInstance/TeUnReserveBandwith/TeResourceClass
# �﷨����:
#   ConfigTopRouterLink -LinkName lk1 -FlagAdvertise true
# ����ֵ��                                                          
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
  #�ж�router���ӵĶ����Ƿ����
  if {[lsearch $m_ospfNetElementArray(namelist) $link_cnt_name]<0} {
  	Deputs "$procname: Error-LinkConnectedName $link_cnt_name not created."
  	return $::FAILURE		
  }   
  #�ж�link�����Ƿ���� 
  if {[lsearch $m_ospfNetElementArray(namelist) $link_name]<0} {
  	Deputs "$procname: Error-LinkName $link_name not created."
  	return $::FAILURE		  	
  }
  #ConfigTopRouterLink��Ϊ���������1)����Grid�е�router 2)����TopRouter�ȣ���LSA
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
  	  #����RouterName�Ĳ�ͬ���ֱ��Ӧ��ͬ��RouterID
  	  #�˴���ʱû�����TopRouter����Network�Ĵ��룬����RouterLSA����ӵ�Network��link
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
  	  #����RouterName�Ĳ�ͬ���ֱ��Ӧ��ͬ��AdvRouterID
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
# ��������:RemoveTopRouterLink by Shawn Li 2009.12.25
# ����: ɾ��ĳ��router�µ�Link
# ����:
# 	LinkName(��ѡ)
# �﷨����:
#   RemoveTopRouterLink -LinkName link1
# ����ֵ��                                                          
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
  #�ж�link�����Ƿ���� 
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
  	  #ɾ��link����������ر���
		  set index [lsearch $m_ospfNetElementArray(namelist) $link_name]
		  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
		  array unset m_ospfNetElementArray "$link_name,*"
  	}
  	"routerlsalink" {
  		set rt_name $link_cnt_name
  		set rt_lsa_rtid $m_ospfNetElementArray($rt_name,rtid)
  		ixNet setAttribute $rt_lsa_rtid -interfaces [list]
    	ixNet commit
  	  #ɾ��link����������ر���
		  set index [lsearch $m_ospfNetElementArray(namelist) $link_name]
		  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
		  array unset m_ospfNetElementArray "$link_name,*"    	
  	}
  	"networklsalink" {
  		set rt_name $m_ospfNetElementArray($link_name,rtname)
  		set network_name $link_cnt_name
  		set netlsa_id $m_ospfNetElementArray($network_name,id)
  	  set netlsa_subnet_id $m_ospfNetElementArray($network_name,netid)
  	  #�˴���ʱû����Ӷ�TopRouter����Network����Ĵ��룬����RouterLSA�д���Network��link
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
  	  #�����ӵ�routerɾ����ͬʱ����Network disable
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
  	  #blockֻ��ͬһ��Router�����ӣ�һ��ɾ��link����AdvRouterΪ��
  	  #ͬʱ��block����ΪFalse
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
  	  #blockֻ��ͬһ��Router�����ӣ�һ��ɾ��link����AdvRouterΪ��
  	  #ͬʱ��block����ΪFalse
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
# ��������:RemoveTopGrid by Shawn Li 2009.12.23
# ����: ɾ��ospfRotuer��Ӧ��Grid
# ����:
# 	֧�ֲ�����GridName(��ѡ)
# �﷨����:
#    RemoveTopGrid -GridName grid1
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {-gridname}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #�ж�grid�����Ƿ����
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-gridname)]<0} {
  	Deputs "$procname: Error-GridName $args_array(-gridname) not created."
  	return $::FAILURE		
  }
  #ɾ��IxNetwork��grid
	ixNet remove $m_ospfNetElementArray($args_array(-gridname),intf)
	ixNet commit  
  #ɾ��grid����������ر���
  set index [lsearch $m_ospfNetElementArray(namelist) $args_array(-gridname)]
  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
  array unset m_ospfNetElementArray "$args_array(-gridname),*"
  
  return 1  
}
#==================================================================
# ��������:AddTopRouter by Shawn Li 2009.12.23
# ����: ����Ospf Router����
# ����:
# 	֧�ֲ���: RouterID/RouterTypeValue/RouterName(��ѡ)
#			FlagAdertise/FlagAutoConnect
#   ��֧�ֲ�����FlagTE/TeRouterLsaName/RouterLsaName(������չ)
# �﷨����:
#    AddTopRouter -RouterTypeValue BIT_B -RouterName rt1 -RouterID 1.1.1.1
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {-routerid -routertypevalue -routername}
  set opt_arg_list {-flagadvertise -flagautoconnect -flagte -routerlsaname -terouterlsaname}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #�ж�router�����Ƿ��Ѿ�����
  if {[lsearch $m_ospfNetElementArray(namelist) $args_array(-routername)]>=0} {
  	Deputs "$procname: Error-RouterName $args_array(-routername) already created."
  	return $::FAILURE		
  } else {
  	set rt_name $args_array(-routername)
  	set rt_type_val [string tolower $args_array(-routertypevalue)]
  	lappend m_ospfNetElementArray(namelist) $rt_name
    #��ʼ��routerlsa����Ĳ���
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
    #����������ã�����RouterLSA ospf intf����(bBit/eBit/interfaces/vBit)
  	set m_ospfNetElementArray($rt_name,rtid) $m_ospfNetElementArray($rt_name,id)/router
    ixNet commit
    set m_ospfNetElementArray($rt_name,id) [ixNet remapIds $m_ospfNetElementArray($rt_name,id) ]
    #����routerlsa����Ĳ���
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
# ��������:ConfigTopRouter by Shawn Li 2009.12.23
# ����: ����TopRouter������
# ����:
# 	֧�ֲ���: RouterID/RouterTypeValue/FlagAdertise/FlagAutoConnect
#   ��֧�ֲ�����FlagTE/TeRouterLsaName/RouterLsaName(������չ)
# �﷨����:
#    ConfigTopRouter -RouterTypeValue BIT_B -RouterName rt1 -RouterID 1.1.1.1
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {-routerid -routertypevalue -routername}
  set opt_arg_list {-flagadvertise -flagautoconnect -flagte -routerlsaname -terouterlsaname}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #�ж�router�����Ƿ��Ѿ�����
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
# ��������:GetTopRouter by Shawn Li 2009.12.23
# ����: TopRouter��������Ϣ
# ����:
# 	֧�ֲ���: RouterName(��ѡ)/RouterID/RouterTypeValue/FlagAdertise
#			FlagAutoConnect/LinkNum
#   ��֧�ֲ�����FlagTE/TeRouterLsaName/RouterLsaName(������չ)
# �﷨����:
#    GetTopRouter -RouterName rt1 -RouterID rid -FlagAdertise flag 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {-routername}
  set opt_arg_list {-flagadvertise -flagautoconnect -flagte -routerlsaname \
  	-terouterlsaname -linknum -routerid -routertypevalue}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  } 
  #�ж�router�����Ƿ��Ѿ�����
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
# ��������:AdvertiseRouters by Shawn Li 2009.12.23
# ����: ͨ��RouterLSA
# ����:
# RouterNameLis ��ѡ
# �﷨����:
#   AdvertiseRouters -RouterNameList {rt1 rt2} 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {}
  set opt_arg_list {-routernamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  } 
  #�ж��Ƿ����routerNameList����
  if {![info exists args_array(-routernamelist)]} {
    #ͨ���ж϶�����������ͣ�����ɶ�RouterLSA��ͨ��
  	foreach rt_name $args_array(-routernamelist) {
  		if {$m_ospfNetElementArray($rt_name,type) == "routerlsa"} {
  			ixNet setAttribute $m_ospfNetElementArray($rt_name,id) -enabled True
		  	ixNet commit	
  		}
  	}		
  } else {
    #�жϸ�����router�����Ƿ����
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
# ��������:RemoveTopRouter by Shawn Li 2009.12.23
# ����: ɾ��TopRouter
# ����: RouterName(��ѡ)
# �﷨����:
#  RemoveTopRouter -RouterName rt1
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {-routername}
  set opt_arg_list {}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  #�жϸ�����router�����Ƿ����
  set rt_name $args_array(-routername)
  if {[lsearch $m_ospfNetElementArray(namelist) $rt_name]<0} {
  	Deputs "$procname: Error-RouterName $rt_name not created."
  } else {
	  #ɾ��IxNetwork��RouterLSA
		ixNet remove $m_ospfNetElementArray($rt_name,id)
		ixNet commit  
	  #ɾ��RouterLSA����������ر���
	  set index [lsearch $m_ospfNetElementArray(namelist) $rt_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$rt_name,*"  	
  }     
	return 1
}

#=============================================================
# ��������:AddTopNetwork by Shawn Li 2009.12.25
# ����: ���NetworkLsa
# ����:
#		֧�ֲ�����NetworkName(��ѡ)/Subnetwork/PrefixLen/DRRouterName
#   	LsaName(��չ)/FlagAutoConnect 
# �﷨����:
#   AddTopNetwork -DRRouterName rt1 -networkname net1 
#			-subnetwork 2.2.2.0 -prefix 24
# ����ֵ��                                                          
#    0 or 1
#==============================================================
itcl::body OspfRouter::AddTopNetwork {args} {
  Deputs "Enter proc OspfRouter::AddTopNetwork...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-subnetwork 2.2.2.0 -prefixlen 255.255.255.0 -drroutername "$m_this"\
  	-lsaname "To_be_defined" -flagautoconnect "True"}   
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #�������Ƿ�Ϸ�
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
    
    #�����������NetworkLSA����(neighborRouterIds-Array networkMask-IPv4)
  	set m_ospfNetElementArray($network_name,netid) $netlsa_id/network
  	set netlsa_subnet_id $netlsa_id/network
    #����network lsa����
  	ixNet setAttribute $netlsa_id -lsaType network
  	ixNet setAttribute $netlsa_id -advertisingRouterId $m_ospfArgsArray(routerid)
  	ixNet setAttribute $netlsa_id -enabled True

    #IXIAĿǰֻ�ܽ�LSA���ӵ�SR����ת����DUT
    
    foreach {option value} [array get args_array] {
    	switch -- $option {
    		"-subnetwork" {ixNet setAttribute $netlsa_id -linkStateId [ixIncrIpaddr $value]}
    		"-prefixlen" {ixNet setAttribute $netlsa_subnet_id -networkMask [ixNumber2Ipmask $value]}
    		"-drroutername" {set m_ospfNetElementArray($network_name,drroutername) $m_this}
    		"-lsaname" {set m_ospfNetElementArray($network_name,lsaname) "$value,to_be_defined"}
    		"-flagautoconnect" {set m_ospfNetElementArray($network_name,flagautoconnect) True}
    	} 
  	} ;#end of foreach_option_value
    
    #�Ƿ���Ҫ��SR�������Ϣ���뵽AttachedRouter���棬��Ҫ����RFCȷ��
 
  	ixNet commit
  } ;#end of if_else
  return 1  
}
#=============================================================
# ��������:ConfigTopNetwork by Shawn Li 2009.12.25
# ����: ���NetworkLsa
# ����:
#		֧�ֲ�����NetworkName(��ѡ)/Subnetwork/PrefixLen/DRRouterName
#   	LsaName(��չ)/FlagAutoConnect 
# �﷨����:
#   ConfigTopNetwork -DRRouterName rt1 -networkname net1 
#			-subnetwork 2.2.2.0 -prefix 24
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
  	#ֻ�޸����²�����������������Create NetworkLSAʱ����
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
# ��������:RemoveTopNetwork by Shawn Li 2009.12.25
# ����: ɾ��ĳ��NetworkLsa
# ����: NetworkName,Routername(��ѡ)
# �﷨����:
#    RemoveTopRouterLsa -networkName network1 -Routername rt1
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
	  #ɾ��IxNetwork��NetworkLSA
		ixNet remove $m_ospfNetElementArray($network_name,id)
		ixNet commit  
	  #ɾ��NetworkLSA����������ر���
	  set index [lsearch $m_ospfNetElementArray(namelist) $network_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$network_name,*"   	
  }
  return 1   
}
#=======================================================================
# ��������:CreateTopSummaryRouteBlock by Shawn Li 2009.12.28
# ����: ����Summary����LSA
# ����:
# 	֧�ֲ���:BlockName(��ѡ)/StartingAddress/PrefixLen/Number/Modifier
#   FlagAutoConnect/LsaName
#		��֧�ֲ�����FlagTrafficDest
# �﷨����:
# 	CreateTopSummaryRouteBlock -BlockName blk1 -StartingAddress 1.1.1.1
# ����ֵ��                                                          
#    0 or 1
#========================================================================
itcl::body OspfRouter::CreateTopSummaryRouteBlock {args} {
  Deputs "Enter proc OspfRouter::CreateTopSummaryRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-startingaddress 13.2.0.0 -prefixlen 255.255.255.0 -number "50"\
  	-modifier "1" -flagautoconnect "True" -lsaname "To_be_defined" -flagtrafficdest {No_support}}   
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #�������Ƿ�Ϸ�
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
    #����SummaryLSA����
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
    #�����������SummaryLSA����(incrementLinkStateId/metric/networkMask/numberOfLsa)
  	set m_ospfNetElementArray($sum_block_name,sumid) $sumlsa_id/summaryIp
  	set sumlsa_ip_id $sumlsa_id/summaryIp 
    #����SummayLSA����
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
# ��������:ConfigTopSummaryRouteBlock by Shawn Li 2009.12.28
# ����:����Summary����LSA
# ����:
# 	֧�ֲ���:BlockName(��ѡ)/StartingAddress/PrefixLen/Number/Modifier
#   FlagAutoConnect/LsaName
#		��֧�ֲ�����FlagTrafficDest
# �﷨����:
# 	ConfigTopSummaryRouteBlock -BlockName blk1 -StartingAddress 1.1.1.1
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
# ��������:GetTopSummaryRouteBlock by Shawn Li 2009.12.28
# ����:��ȡSummary����LSA����
# ����:
# 	֧�ֲ���:BlockName(��ѡ)/StartingAddress/PrefixLen/Number/Modifier
#   FlagAutoConnect/LsaName
#		��֧�ֲ�����FlagTrafficDest
# �﷨����:
# 	GetTopSummaryRouteBlock -BlockName blk1 -StartingAddress sa
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
# ��������:DeleteTopSummaryRouteBlock by Shawn Li 2009.12.28
# ����: ɾ��Summary����RouteRange
# ����:
# BlockName:Ҫɾ����Block���ֱ�ʶ
# �﷨����:
#  DeleteTopSummaryRouteBlock -BlockName blk1
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
	  #ɾ��IxNetwork��SummaryLSA
		ixNet remove $m_ospfNetElementArray($sum_block_name,id)
		ixNet commit  
	  #ɾ��SummaryLSA����������ر���
	  set index [lsearch $m_ospfNetElementArray(namelist) $sum_block_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$sum_block_name,*"    	
  }
  return 1  
}  
#==================================================================
# ��������:CreateTopExternalRouteBlock by Shawn Li 2009.12.29
# ����: ����External����LSA
# ����:
# 	֧�ֲ�����BlockName(��ѡ)/StartingAddress/PrefixLen/Number/Modifier
#			Metric/Active/LsaName(tbd)/FlagAutoConnect/FowardingAddress/
#			ExternalTag/FlagNssa(LSA7)/Type/FlagAsbrSummary(����ⲿ·��)/
#			FlagPropagate(LSA5-LSA7ת��)
#		��֧�ֲ�����FlagTrafficDest/FlagAsbr
#   ע�ͣ�LSA������Ȼ֧��NSSA������API����Ч
# �﷨����:
#   CreateTopExternalRouteBlock -BlockName blk1 -Type Type_1 -Active false
# ����ֵ��                                                          
#    0 or 1
#=======================================================================
itcl::body OspfRouter::CreateTopExternalRouteBlock {args} {
  Deputs "Enter proc OspfRouter::CreateTopExternalRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-startingaddress 13.2.0.0 -prefixlen 255.255.0.0 -number 50 -modifier 1\
 			-metric 1  -active True -lsaname To_be_defined -flagautoconnect True -fowardingaddress 0.0.0.0\
 			-externaltag 0 -flagnssa False -type Type_2 -flagtrafficdest No_support -flagasbr True\
 			-flagasbrsummary True	-flagpropagate False}   
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #�������Ƿ�Ϸ�
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
    #����External-AS-LSA����
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
    #�����������ExternalLSA����(incrementLinkStateIdBy/networkMask/numberOfLsa
    #eBit/forwardingAddress/metric/routeTag
    
    #�ж���LSA5����LSA7, ѡ��LSA-ChildList����
    if {[string tolower $m_ospfNetElementArray($ext_block_name,flagnssa)]==true} {
	  	set m_ospfNetElementArray($ext_block_name,extid) $extlsa_id/nssa
	  	set extlsa_ip_id $extlsa_id/nssa
    } else {
	    set m_ospfNetElementArray($ext_block_name,extid) $extlsa_id/external
	    set extlsa_ip_id $m_ospfNetElementArray($ext_block_name,extid)  
    }
    #����ExternalLSA����
    
    #�ж�LSA����
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
# ��������:ConfigTopExternalRouteBlock by Shawn Li 2009.12.29
# ����:����External����LSA
# ����:
# 	֧�ֲ�����BlockName(��ѡ)/StartingAddress/PrefixLen/Number/Modifier
#			Metric/Active/LsaName(tbd)/FlagAutoConnect/FowardingAddress/
#			ExternalTag/FlagNssa(LSA7)/Type/FlagAsbrSummary(����ⲿ·��)/
#			FlagPropagate(LSA5-LSA7ת��)
#		��֧�ֲ�����FlagTrafficDest/FlagAsbr
# �﷨����:
# 	ConfigTopExternalRouteBlock -BlockName blk1 -StartingAddress 1.1.1.1
# ����ֵ��                                                          
#    0 or 1
#========================================================================
itcl::body OspfRouter::ConfigTopExternalRouteBlock {args} {
  Deputs "Enter proc OspfRouter::ConfigTopExternalRouteBlock...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-startingaddress 13.2.0.0 -prefixlen 255.255.0.0 -number 50 -modifier 1\
 			-metric 1  -active True -lsaname To_be_defined -flagautoconnect True -fowardingaddress 0.0.0.0\
 			-externaltag 0 -flagnssa False -type Type_2 -flagtrafficdest No_support -flagasbr True\
 			-flagasbrsummary True	-flagpropagate False} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  
  #�������Ƿ�Ϸ�
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
# ��������:GetTopExternalRouteBlock by Shawn Li 2009.12.29
# ����:��ȡExternal����LSA����
# ����:
# 	֧�ֲ�����BlockName(��ѡ)/StartingAddress/PrefixLen/Number/Modifier
#			Metric/Active/LsaName(tbd)/FlagAutoConnect/FowardingAddress/
#			ExternalTag/FlagNssa(LSA7)/Type/FlagAsbrSummary(����ⲿ·��)/
#			FlagPropagate(LSA5-LSA7ת��)
#		��֧�ֲ�����FlagTrafficDest/FlagAsbr
# �﷨����:
# 	GetTopExternalRouteBlock -BlockName blk1 -StartingAddress sa
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
# ��������:DeleteTopExternalRouteBlock by Shawn Li 2009.12.29
# ����: ɾ��External����RouteRange
# ����:
# BlockName:Ҫɾ����Block���ֱ�ʶ
# �﷨����:
#  DeleteTopExternalRouteBlock -BlockName blk1
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
	  #ɾ��IxNetwork��ExternalLSA
		ixNet remove $m_ospfNetElementArray($ext_block_name,id)
		ixNet commit  
	  #ɾ��ExternalLSA����������ر���
	  set index [lsearch $m_ospfNetElementArray(namelist) $ext_block_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$ext_block_name,*"    	
  }
  return 1  
} 
#====================================================
# ��������:AddRouterLsa by Shawn Li 2009.12.30
# ����: ��SessinoRouter�����RouterLsa
# ����:
#		֧�ֲ�����LsaName(must)/FlagAdvertise/FlagWithdraw
#			AdvertisingRouter/LinkStateID/Numlink
# �﷨����:
#    AddRouterLsa -lsaname lsa1 
# ����ֵ��                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::AddRouterLsa {args} {
  Deputs "Enter proc OspfRouter::AddRouterLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-flagadvertise True -flagwithdraw False -advertisingrouter 111.222.1.1\
   			-linkstateid 111.222.1.1 -number 0} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }  
  #�������Ƿ�Ϸ�
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
    #����������ã�����RouterLSA ospf intf����(bBit/eBit/interfaces/vBit)
  	set m_ospfNetElementArray($lsa_name,rtid) $m_ospfNetElementArray($lsa_name,id)/router
    ixNet commit
    set m_ospfNetElementArray($lsa_name,id) [ixNet remapIds $m_ospfNetElementArray($lsa_name,id) ]  
		set lsa_id $m_ospfNetElementArray($lsa_name,id)
		ixNet setAttribute $lsa_id -lsaType router
	  ixNet setAttribute $lsa_id -enabled $args_array(-flagadvertise)
    ixNet setAttribute $lsa_id -linkStateId $args_array(-linkstateid) 
    ixNet setAttribute $lsa_id -advertisingRouterId $args_array(-advertisingrouter)
    #Number/FlagWithdraw����û�����壬�ݲ�ʵ��
    ixNet commit	  
  } 
  return 1 
}
#====================================================
# ��������:AddRouterLsaLink by Shawn Li 2009.12.31
# ����: ��SessinoRouter�����RouterLsaLink
# ����:
#		֧�ֲ�����LsaName(must)/LinkId/LinkData/Metric/LinksType
# �﷨����:
#    AddRouterLsaLink -lsaname lsa1 
# ����ֵ��                                                          
#    0 or 1
#=====================================================
itcl::body OspfRouter::AddRouterLsaLink {args} {
  Deputs "Enter proc OspfRouter::AddRouterLsaLink...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-linkid 111.222.1.2 -linkdata 111.1.1.1 -metric 1 -linkstype pointToPoint} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }  
  #�������Ƿ�Ϸ�
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
# ��������:RemoveRouterLsa by Shawn Li 2009.12.31
# ����: ɾ��SessinoRouter�ϵ�RouterLsa
# ����:
#		֧�ֲ�����LsaName(must)
# �﷨����:
#    RemoveRouterLsa -lsaname lsa1 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
	  #ɾ��IxNetwork��RouterLSA
		ixNet remove $m_ospfNetElementArray($lsa_name,id)
		ixNet commit  
	  #ɾ��RouterLSA����������ر���
	  set index [lsearch $m_ospfNetElementArray(namelist) $lsa_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$lsa_name,*"    
  }
  return 1
} 
#===================================================================
# ��������:AddNetworkLsa by Shawn Li 2009.12.31
# ����: ��SessinoRouter�����NetworkLsa
# ����:
#		֧�ֲ�����LsaName(must)/FlagAdvertise/FlagWithdraw/PrefixLength
#			AdvertisingRouter/LinkStateID/AttachedRouters
# �﷨����:
#    AddNetworkLsa -lsaname lsa1 
# ����ֵ��                                                          
#    0 or 1
#===================================================================
itcl::body OspfRouter::AddNetworkLsa {args} {
  Deputs "Enter proc OspfRouter::AddNetworkLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-flagadvertise True -flagwithdraw False -advertisingrouter 11.1.1.3\
   			-linkstateid 11.4.7.3 -prefixlength 24 -attachedrouters ""} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #�������Ƿ�Ϸ�
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
    #�����������NetworkLSA����(neighborRouterIds-Array networkMask-IPv4)
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
# ��������:AddNetworkLsaRouter by Shawn Li 2009.12.31
# ����: ��SessinoRouter�����NetworkLsa Router
# ����:
#		֧�ֲ�����LsaName/Routers (must)
# �﷨����:
#    AddRouterLsaLink -lsaname lsa1 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
# ��������:RemoveNetworkLsa by Shawn Li 2009.12.31
# ����: ɾ��SessinoRouter�ϵ�NetworkLsa
# ����:
#		֧�ֲ�����LsaName(must)
# �﷨����:
#    RemoveNetworkLsa -lsaname lsa1 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
	  #ɾ��IxNetwork��NetworkLSA
		ixNet remove $m_ospfNetElementArray($lsa_name,id)
		ixNet commit  
	  #ɾ��RouterLSA����������ر���
	  set index [lsearch $m_ospfNetElementArray(namelist) $lsa_name]
	  set m_ospfNetElementArray(namelist) [lreplace $m_ospfNetElementArray(namelist) $index $index]
	  array unset m_ospfNetElementArray "$lsa_name,*"    
  }
  return 1
}
#===================================================================
# ��������:AddSummaryLsa by Shawn Li 2009.12.31
# ����: ��SessinoRouter�����Summary-Net-Lsa
# ����:
#		֧�ֲ�����LsaName(must)/FlagAdvertise/FlagWithdraw/PrefixLength
#			AdvertisingRouter/Metric/FirstAddress/NumAddress/Modifier
# �﷨����:
#    AddSummaryLsa -lsaname lsa1 
# ����ֵ��                                                          
#    0 or 1
#===================================================================
itcl::body OspfRouter::AddSummaryLsa {args} {
  Deputs "Enter proc OspfRouter::AddSummaryLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-flagadvertise True -flagwithdraw False -advertisingrouter 111.222.1.1\
   			-firstaddress 11.2.0.0 -prefixlength 16 -metric "1" -modifier 1 -numaddress 50} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #�������Ƿ�Ϸ�
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
    #�����������NetworkLSA����(neighborRouterIds-Array networkMask-IPv4)
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
# ��������:RemoveSummaryLsa by Shawn Li 2009.12.31
# ����: ɾ��SessinoRouter�ϵ�Lsa
# ����:
#		֧�ֲ�����LsaName(must)
# �﷨����:
#    RemoveSummaryLsa -lsaname lsa1 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
# ��������:AddAsExtLsa by Shawn Li 2009.12.31
# ����: ��SessinoRouter�����Ext-Lsa
# ����:
#		֧�ֲ�����LsaName(must)/FlagAdvertise/FlagWithdraw/PrefixLen
#			AdvertisingRouter/Metric/FirstAddress/NumAddress/Modifier
#			ForwardingAddress/ExternalTag/FlagEbit
# �﷨����:
#    AddAsExtLsa -lsaname lsa1 
# ����ֵ��                                                          
#    0 or 1
#===================================================================
itcl::body OspfRouter::AddAsExtLsa {args} {
  Deputs "Enter proc OspfRouter::AddAsExtLsa...\n"
  set args [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ʼ��args_array����
  array set args_array {-flagadvertise True -flagwithdraw False -advertisingrouter 111.222.1.1\
   			-firstaddress 8.0.0.0 -prefixlen 8 -metric "1" -modifier 1 -numaddress 50\
   			-forwardingaddress 0.0.0.0 -externaltag 0 -flagebit 0} 
  if {[catch {array set args_array $args} error]} {
    set ::ERRINFO  "$procname: $error."
    return $::FAILURE
  }
  #�������Ƿ�Ϸ�
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
# ��������:RemoveAsExtLsa by Shawn Li 2009.12.31
# ����: ɾ��SessinoRouter�ϵ�Lsa
# ����:
#		֧�ֲ�����LsaName(must)
# �﷨����:
#    RemoveAsExtLsa -lsaname lsa1 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
# ��������:AdvertiseLsas by Shawn Li 2009.12.31
# ����: ͨ��OSPF LSA
# ����:
#		֧�ֲ�����LsaNameList
# �﷨����:
#    AdvertiseLsas -LsaNameList {lsa1 lsa2} 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {}
  set opt_arg_list {-lsanamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  if {![info exist args_array(-lsanamelist)]} {
  	#��ȫ��LSA����ͨ��
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
# ��������:WithdrawLsas by Shawn Li 2009.12.31
# ����: ����OSPF LSA
# ����:
#		֧�ֲ�����LsaNameList
# �﷨����:
#    WithdrawLsas -LsaNameList {lsa1 lsa2} 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {}
  set opt_arg_list {-lsanamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  if {![info exist args_array(-lsanamelist)]} {
    #��ȫ��LSA���г���
    foreach lsa_name $m_ospfNetElementArray(namelist) {
      #�ų�ǰ�洴����RouterLsa
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
# ��������:AdvertiseRouters by Shawn Li 2009.12.31
# ����: ͨ��OSPF RouterLSA/Grid
# ����:
#		֧�ֲ�����RouterNameList
# �﷨����:
#    AdvertiseRouters -RouterNameList {rt1 rt2} 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {}
  set opt_arg_list {-routernamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  if {![info exist args_array(-routernamelist)]} {
  	#��ȫ��RouterLSA����ͨ��
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
# ��������:WithdrawRouters by Shawn Li 2009.12.31
# ����: ����OSPF RouterLSA/Grid
# ����:
#		֧�ֲ�����LsaNameList
# �﷨����:
#    WithdrawRouters -RouterNameList {rt1 rt2} 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {}
  set opt_arg_list {-routernamelist}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }
  if {![info exist args_array(-routernamelist)]} {
  	#��ȫ��RouterLSA����ͨ��
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
# ��������:ConfigFlap by Shawn Li 2009.12.31
# ����:����ospfЭ����Ƶ��
# ����:AWDTimer/WADTimer
# �﷨����:
#  ConfigFlap -AWDTimer 1000 -WADTimer 1000
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
  set man_arg_list {}
  set opt_arg_list {-awdtimer -wadtimer}
  set flag [IxiaCapi::ixCheckParas $args $man_arg_list $opt_arg_list]
  if {$flag} {
  	Deputs	$::ERRINFO
  	return $::FAILURE
  }    
  #comments:����ZTE��������interval����ɾ�������number��start����
  if {[info exists args_array(-awdtimer)]} {
     set m_ospfFlapArgsArray(awdtimer) $args_array(-awdtimer)
  }
  if {[info exists args_array(-wadtimer)]} {
      set m_ospfFlapArgsArray(wadtimer) $args_array(-wadtimer)
  }
  return 1   
}
#===========================================================
# ��������:StartFlapRouters by Shawn Li 2009.12.31
# ����:��OSPF����·����
# ����:
# RouterNameList/FlapNum 
# �﷨����:
#  StartFlapRouters -RouterNameList rt1 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
    #��ȫ��RouterLSA����ͨ��
    #Flap����ѭ��
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
  	#Flap����ѭ��
    for {set i 1} {$i<=$m_ospfFlapArgsArray(number)} {incr i} {
    	Deputs "Sum. of flapping $m_ospfFlapArgsArray(number), No.$i times"
		  foreach lsa_name $args_array(-routernamelist) {
		    #����Router��������enabled����		  
				set lsa_type $m_ospfNetElementArray($lsa_name,type)
	      if {$lsa_type=="routerlsa"} {
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
		  	} elseif {$lsa_type=="grid"} {    	
		  		ixNet setAttribute $m_ospfNetElementArray($lsa_name,intf) -enabled True
	  		}
		  }
	  	ixNet commit
	    after $m_ospfFlapArgsArray(awdtimer)
	    #adv��withd�ȴ�ʱ��
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
# ��������:StopFlapRouters by Shawn Li 2009.12.31
# ����:ֹͣ��OSPF����·����
# ����:
# �﷨����:
#   StopFlapRouters 
# ����ֵ��                                                          
#  0 or 1
#======================================================
itcl::body OspfRouter::StopFlapRouters {args} {
  Deputs "Enter proc OspfRouter::StopFlapRouters...\n"
  #����IxNetwork�ص㣬�Լ�HLAPI�淶���˴�����������
  return 1
}
#===========================================================
# ��������:StartFlapLsas by Shawn Li 2009.12.31
# ����:��OSPF����·����
# ����:
# LsaNameList/FlapNum 
# �﷨����:
#  StartFlapLsas -RouterNameList rt1 
# ����ֵ��                                                          
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
  #�������Ƿ�Ϸ�
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
    #��ȫ��RouterLSA����ͨ��
    #Flap����ѭ��
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
  	#Flap����ѭ��
    for {set i 1} {$i<=$m_ospfFlapArgsArray(lsanumber)} {incr i} {
    	Deputs "Sum. of flapping $m_ospfFlapArgsArray(number), No.$i times"
		  foreach lsa_name $args_array(-lsanamelist) {
				ixNet setAttribute $m_ospfNetElementArray($lsa_name,id) -enabled True
	  	}
	  	ixNet commit
	    after $m_ospfFlapArgsArray(awdtimer)
	    #adv��withd�ȴ�ʱ��
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
  #����IxNetwork�ص㣬�Լ�HLAPI�淶���˴�����������
  return 1
} 
#=======================================================
# ��������:GraceRestartAction by Shawn Li 2009.12.31
# ����: ��������Ospf Router ��GR����
# �﷨����:
#   GraceRestartAction
# ����ֵ��                                                          
#    0 or 1
#=======================================================
itcl::body IxiaCapi::OspfRouter::GraceRestartAction {args} {
  Deputs "Enter proc OspfRouter::GraceRestartAction...\n"
  ixNet setAttribute $m_ixRouterId -gracefulRestart true
  ixNet commit
  return 1
}
#=======================================================
# ��������:GetRouterStats by Shawn Li 2010.1.13
# ����: ��ȡOSPF Router��Ϣ
# ������
#		֧�ֲ�����NumHelloReceived/NumDbdReceived/NumRtrLsaReceived
#			NumNetLsaReceived/NumSum4LsaReceived/NumSum3LsaReceived/NumExtLsaReceived
#			NumOpq9LsaReceived/NumOpq10LsaReceived/NumOpq11LsaReceived
#			NumType7LsaReceived/NumHelloSent/NumDbdSent/NumRtrLsaSent
#			NumNetLsaSent/NumSum4LsaSent/NumSum3LsaSent/NumExtLsaSent/NumOpq9LsaSent
#			NumOpq10LsaSent/NumOpq11LsaSent/NumType7LsaSent
#		
# �﷨����:
# ����ֵ��                                                          
#    0 or 1
#=======================================================
itcl::body IxiaCapi::OspfRouter::GetRouterStats {args} {
  Deputs "Enter proc OspfRouter::GetRouterStats...\n"
  set args     [ixConvertToLowerCase $args]
  set procname [lindex [info level [info level]] 0]
  #��ȡ������������и�ֵ
  #----------------------
  if {[catch {array set args_array $args} error]} {
      set ::ERRINFO "$procname: $error."
      return $::FAILURE
  }
  set statViewList [ixNet getList [ixNet getRoot]/statistics statViewBrowser]
  if {$statViewList != ""} {
  	#����OSPFͳ�Ʊ�ǩ
  	foreach statView $statViewList {
  		set statName [ixNet getAttribute $statView -name]
  		if {[string first "OSPF Aggregated Statistics" $statName] >= 0} {
  		  set ospfView $statView
  		  break
  		}
  	}
    ixNet setAttribute $ospfView -enabled True
    ixNet commit
    #�������˿ڵ�Row��ʾ������OSPFͳ������ܴ��ڶ���˿�ʹ��OSPF
    set chassisId [ixNet getList [ixNet getRoot]/availableHardware chassis]
    set chassisIp [ixNet getAttribute $chassisId -hostname]
    set rowId "$chassisIp/Card[format %02s $m_slotId]/Port[format %02s $m_portId]"
    set rowList [ixNet getList $ospfView row]
    #���ұ��˿ڵ�OSPFͳ�Ʊ�ǩ
    foreach rowView $rowList {
    	set rowName [ixNet getAttribute $rowView -name]
  		if {[string first "OSPF Aggregated Statistics" $statName] >= 0} {
  		  set ospfRow $rowView
  		  break
  		}    	
    }
    set cellList [ixNet getList $ospfRow cell]
    
    #�Բ������и�ֵ
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
#IXIA�Ǳ�֧�����Ժ���
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