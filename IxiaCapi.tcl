#=========================================================================
# 版本号：1.0
#   
# 文件名：IxiaCapi.tcl
# 
# 文件描述：IxiaCapi库初始化文件，当用户输入 "package require IxiaCapi" 调用此文件
# 
# 作者：李霄石(Shawn Li)
#
# 创建时间: 2008.03.25
#
# 修改记录： 
#   
# 版权所有：Ixia
#====================================================================================
# Change made by Eric on v2.0
#        1.fix the multiversion loading package problem
#        2.add ixNetwork TrafficEngine
#        3.add ixNetwork Profile
#        4.add ixNetwork Stream
#        5.add ixNetwork HeaderCreator
#        6.add ixNetwork PacketBuilder
# Change made by Cathy on v2.7
#        1.add ixNetwork TestAnalysis in TestStatistics
#        2.add ixNetwork Filter
#        3.remove ixOS package 


package require Itcl
package req ip
namespace import itcl::*

proc GetEnvTcl { product } {
   set productKey     "HKEY_LOCAL_MACHINE\\SOFTWARE\\Ixia Communications\\$product"
   set versionKey     [ registry keys $productKey ]
   set latestKey      [ lindex $versionKey end ]
   if { $latestKey == "Multiversion" } {
      set latestKey   [ lindex $versionKey [ expr [ llength $versionKey ] - 2 ] ]
   }
   set installInfo    [ append productKey \\ $latestKey \\ InstallInfo ]            
   return             [ registry get $installInfo  HOMEDIR ]
}

set ixN_tcl_v "6.0"
puts "connect to ixNetwork Tcl Server version $ixN_tcl_v"
if { $::tcl_platform(platform) == "windows" } {
   puts "windows platform..."
   package require registry

   if { [ catch {
      lappend auto_path  "[ GetEnvTcl IxNetwork ]/TclScripts/lib/IxTclNetwork"
   } err ] } {
      puts "Failed to invoke IxNetwork environment...$err"
   }

   puts "load package IxTclNetwork..."
   package require IxTclNetwork
   
   # catch {	
   # puts "load package IxTclHal..."	
      # source [ GetEnvTcl IxOS ]/TclScripts/bin/ixiawish.tcl
      # package require IxTclHal
   # }
}

set gOffline 0

namespace eval IxiaCapi {
   namespace export *
   
} ;# end of namespace eval ixia


#modified by shawn 2009.3.18
#comments:添加Host类和Router/Rip类tcl文件
#-----------------------------------------
set currDir [file dirname [info script]]
 #source [file join $currDir Ixia_CRouter.tcl]
 #source [file join $currDir Ixia_CRipRouter.tcl]
# source [file join $currDir Ixia_CBgpRouter.tcl]
 #source [file join $currDir Ixia_COspfRouter.tcl]
# source [file join $currDir Ixia_CIsisRouter.tcl]
# source [file join $currDir Ixia_COspfV3Router.tcl]

source [file join $currDir config.tcl]
source [file join $currDir Logger.tcl]
source [file join $currDir String.tcl]
source [file join $currDir Regexer.tcl]
source [file join $currDir IxNetLib.tcl]
source [file join $currDir IxNetTestDevice.tcl]
source [file join $currDir IxNetTestPort.tcl]
source [file join $currDir IxNetHost.tcl]
source [file join $currDir IxNetTestPortMgr.tcl]
source [file join $currDir IxNetTrafficMgr.tcl]
source [file join $currDir IxNetProfile.tcl]
source [file join $currDir IxNetStream.tcl]
source [file join $currDir IxNetHeaderCreator.tcl]
source [file join $currDir IxNetPacketBuilder.tcl]
source [file join $currDir IxNetTrafficEngine.tcl]
source [file join $currDir IxNetTestStatistic.tcl]
source [file join $currDir IxNetFilter.tcl]
#source [file join $currDir Ixia_Util.tcl]
source [file join $currDir Ixia_NetTester.tcl]
source [file join $currDir Ixia_NetObj.tcl]
source [file join $currDir Ixia_NetFlow.tcl]
source [file join $currDir Ixia_NetTraffic.tcl]
source [file join $currDir Ixia_NetDhcp.tcl]
source [file join $currDir Ixia_NetPPPoX.tcl]
source [file join $currDir Ixia_convert.tcl]
source [file join $currDir IxNetDHCP.tcl]
source [file join $currDir IxNetPPPoE.tcl]
source [file join $currDir IxNet802Dot1x.tcl]
source [file join $currDir IxNetIPv6SLAAC.tcl]
source [file join $currDir Ixia_NetIgmp.tcl]
source [file join $currDir IxNetMld.tcl]
source [file join $currDir IxNetIGMP.tcl]
source [file join $currDir Ixia_NetBgp.tcl]
source [file join $currDir IxNetBGP.tcl]
source [file join $currDir Ixia_NetOspf.tcl]
source [file join $currDir Ixia_NetIsis.tcl]
source [file join $currDir IxNetISIS.tcl]
source [file join $currDir IxNetOSPF.tcl]

set errNumber(1)    "Bad argument value or out of range..."
set errNumber(2)    "Madatory argument missed..."
set errNumber(3)    "Unsupported parameter..."
set errNumber(4)    "Confilct argument..."

#namespace import ::IxiaCapi::*
namespace import ::IxiaCapi::Regexer::*
namespace import ::IxiaCapi::Logger::*
namespace import ::IxiaCapi::Lib::*

set ixCapiVersion 3.3
package provide IxiaCAPI $ixCapiVersion
namespace import IxiaCapi::*
