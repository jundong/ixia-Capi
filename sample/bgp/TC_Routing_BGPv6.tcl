
#设置Chassis的基本参数，包括IP地址，端口的数量等等
set chassisAddr 10.61.34.249
set islot 11
set portList {7 8} ;#端口的排列顺序是port1, port2


if { [catch {
     
     cd ../Source
    #加载HLAPI Lib
    source ./pkgIndex.tcl

     SetLogOption -Debug Enable

    # 开始连接机器
    TestDevice chassis1 $chassisAddr

    # 开始预留两个端口
    for {set i 0} {$i <[llength $portList]} {incr i} {
        chassis1 CreateTestPort -PortLocation $islot/[lindex $portList $i] -PortName port[expr $i+1] -PortType Ethernet
    }
 
    # 创建路由对象         
    port1 CreateRouter -RouterName bgproute1 -RouterType BgpV6Router -routerid 192.1.0.1
    port2 CreateRouter -RouterName bgproute2 -RouterType BgpV6Router -routerid 192.1.0.2
    
    # 配置路由
    
    bgproute1 BgpV6SetSession -PeerType IBGP -TesterIp 2000::1 -PrefixLen 24 -TesterAs 1001 -SutIp 2000::2 -SutAs 1001 -FlagMd5 TRUE \
             -Md5 0xA9 -HoldTimer 30 -KeepaliveTimer 10 -ConnectRetryTimer  20 -RoutesPerUpdate 100 -InterUpdateDelay 10 -Active Enable
    
    #for test 
    bgproute2 BgpV6SetSession -GateWay 2000::1
     
    # 获取路由信息         
   bgproute1 BgpV6RetrieveRouter \
        -PeerType                    PeerType                  \
        -RouterID                    RouterID                  \
        -TestIp                      TestIp                    \
        -PrefixLen                   PrefixLen                 \
        -TestAs                      TestAs                    \
        -SutIp                       SutIp                     \
        -SutAs                       SutAs                     \
        -FlagMd5                     FlagMd5                   \
        -Md5                         Md5                       \
        -FlagLdp                     FlagLdp                   \
        -ErrorCode                   Code                 \
        -ErrorSubcode                ErrorSubcode              \
        -HoldTimer                   HoldTimer                 \
        -KeepaliveTimer              KeepaliveTimer            \
        -ConnectRetryTimer           ConnectRetryTimer         \
        -RoutesPerUpdate             RoutesPerUpdate           \
        -InterUpdateDelay            InterUpdateDelay          \
        -FlagEndOfRib                FlagEndOfRib              \
        -FlagLabelRouteCapture       FlagLabelRouteCapture     \
        -Active                      Active                    \
        -State                       State                
    catch {puts "-PeerType                    $PeerType                "}                             
    catch {puts "-RouterID                    $RouterID                "}  
    catch {puts "-TestIp                      $TestIp                  "}  
    catch {puts "-PrefixLen                   $PrefixLen               "}  
    catch {puts "-TestAs                      $TestAs                  "}  
    catch {puts "-SutIp                       $SutIp                   "}  
    catch {puts "-SutAs                       $SutAs                   "}  
    catch {puts "-FlagMd5                     $FlagMd5                 "}  
    catch {puts "-Md5                         $Md5                     "}  
    catch {puts "-FlagLdp                     $FlagLdp                 "}  
    catch {puts "-ErrorCode                   $Code                    "}  
    catch {puts "-ErrorSubcode                $ErrorSubcode            "}  
    catch {puts "-HoldTimer                   $HoldTimer               "}  
    catch {puts "-KeepaliveTimer              $KeepaliveTimer          "}  
    catch {puts "-ConnectRetryTimer           $ConnectRetryTimer       "}  
    catch {puts "-RoutesPerUpdate             $RoutesPerUpdate         "}  
    catch {puts "-InterUpdateDelay            $InterUpdateDelay        "}  
    catch {puts "-FlagEndOfRib                $FlagEndOfRib            "}  
    catch {puts "-FlagLabelRouteCapture       $FlagLabelRouteCapture   "}  
    catch {puts "-Active                      $Active                  "}  
    catch {puts "-State                       $State                   "}
     
 bgproute1 BgpV6CreateRouteBlock -BlockName block11 -AddressFamily ipv6 -FirstRoute 2008::1 -PrefixLen 64 -RouteNum 10 -Modifer 1 -Active enable \
              -AS_SEQUENCE yes -ORIGIN 1 -NEXTHOP 2009::2 -MED 1 -AGGREGATOR_AS 2 -AGGGRGATOR_IPADDRESS 10.1.2.3 -ORIGINATOR_ID 10.1.2.3 \
              -CLUSTER_LIST 10.1.2.3 -COMMUNITIES 1:1 -LabelMode FIXED  
    bgproute1 BgpV6Enable
    bgproute1 BgpV6AdvertiseRouteBlock -BlockName block11
  bgproute1 BgpV6ListRouteBlock -BlockNameList block111    
    puts "blockList $block111"     
    bgproute1 BgpV6SetCapability -IPv4 Enable -LabeledIPv4 Disable
    bgproute1 BgpV6RetrieveCapability -IPv4 IPv4 -LabeledIPv4 LabeledIPv4
    
    #puts "IPv4:$IPv4,LabeledIPv4:$LabeledIPv4"
    
    bgproute1 BgpV6Enable
    #bgproute1 Disable
    
    bgproute1 BgpV6CreateRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.0 -PrefixLen 24 -RouteNum 2 -Modifer 1 -Active enable \
              -AS_SEQUENCE yes -ORIGIN 1 -NEXTHOP 192.85.1.3 -MED 1 -AGGREGATOR_AS 2 -AGGGRGATOR_IPADDRESS 192.85.2.1 -ORIGINATOR_ID 192.85.3.1 \
              -CLUSTER_LIST 192.86.1.1 -COMMUNITIES 1:1 -LabelMode FIXED
    bgproute1 BgpV6CreateRouteBlock -BlockName block2 -AddressFamily ipv4 -FirstRoute 192.2.1.0 -PrefixLen 24 -RouteNum 2 -Modifer 1 -Active enable \
              -AS_SEQUENCE yes -ORIGIN 1 -NEXTHOP 192.85.1.3 -MED 1 -AGGREGATOR_AS 2 -AGGGRGATOR_IPADDRESS 192.85.2.1 -ORIGINATOR_ID 192.85.3.1 \
              -CLUSTER_LIST 192.86.1.1 -COMMUNITIES 1:1 -LabelMode FIXED
    
    bgproute1 BgpV6DeleteRouteBlock -BlockName block2
    
    bgproute1 BgpV6ListRouteBlock -BlockNameList BlockNameList
    
    puts "BlockNameList:$BlockNameList"
    
    bgproute1 BgpV6SetRouteBlock -BlockName block1 -AddressFamily ipv4 -FirstRoute 192.1.1.2 -PrefixLen 24 -RouteNum 2 -RouteStep 1 -Active enable \
              -AS_SEQUENCE yes -ORIGIN 1 -NEXTHOP 192.85.1.3 -MED 1 -AGGREGATOR_AS 2 -AGGGRGATOR_IPADDRESS 192.85.2.1 -ORIGINATOR_ID 192.85.3.1 \
              -CLUSTER_LIST 192.86.1.1 -COMMUNITIES 1:1 -LabelMode FIXED
              
    bgproute1 BgpV6RetrieveRouteBlock -BlockName block1 -AddressFamily AddressFamily
    #puts "AddressFamily:$AddressFamily"
    
    # 进行路由宣告与撤销
    bgproute1 BgpV6AdvertiseRouteBlock -BlockName block1
    bgproute1 BgpV6WithdrawRouteBlock -BlockName block1
    bgproute1 BgpV6AdvertiseRouteBlock -BlockName block1
    
    #设置Flap    
    bgproute1 BgpV6SetFlapRouteBlock -AWDTimer 3 -WADTimer 3
    bgproute1 BgpV6StartFlapRouteBlock -BlockName block1
    bgproute1 BgpV6StopFlapRouteBlock -BlockName block1
    
    # 获取当前路由状态信息
    bgproute1 BgpV6RetrieveRouteStats -NumKeepAlivesSent NumKeepAlivesSent -NumKeepAlivesReceived NumKeepAlivesReceived
    puts "NumKeepAlivesSent:$NumKeepAlivesSent,NumKeepAlivesReceived:$NumKeepAlivesReceived"
    
    #创建Mpls VPN
    bgproute1 BgpV6CreateMplsVpn -VpnName vpn1 -RouteTargetType IP -RouteTarget 100:1
    bgproute2 BgpV6CreateMplsVpn -VpnName vpn2 -RouteTargetType IP -RouteTarget 1001:1
    bgproute1 BgpV6SetMplsVpn -VpnName vpn1 -RouteTargetType IP -RouteTarget 1001:1
    bgproute2 BgpV6DeleteMplsVpn -VpnName vpn2
    bgproute1 BgpV6CreateMplsVpnSite -VpnSiteName site1 -VpnNameList vpn1  -peIpv4Address 192.85.1.1
    bgproute1 BgpV6CreateVpnToSite -VpnSiteName site1 -VpnName vpn1
    bgproute1 BgpV6DeleteVpnFromSite -VpnSiteName site1 -VpnName vpn1
    bgproute1 BgpV6SetMplsVpnSite -VpnName vpn1 -VPNSiteName site1 -RouteTarget 1001:2
    bgproute1 BgpV6ListMplsVpnSite -VpnSiteName VpnSiteName
    
    #puts "VpnSiteName:$VpnSiteName"
    
    bgproute1 BgpV6DeleteMplsVpnSite -VpnSiteName site1
    
    #配置带VPN路由
    bgproute1 BgpV6CreateVpnRouteBlock -VpnSiteName site1 -BlockName block1 -AddressFamily ipv6 -FirstRoute 3000::1
    bgproute1 BgpV6SetVpnRouteBlock -VpnSiteName site1 -BlockName block1 -AddressFamily ipv6
    bgproute1 BgpV6RetrieveVpnRouteBlock  -BlockName block1
    
    # 启动路由
    port1 StartRouter

    # 等待5秒
    after 5000

    # 停止路由
    port1 StopRouter
    
    #清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                    
}  err ] } {
    puts "脚本运行中出现错误: $err" 

    #清除测试过程中所作的所有配置和释放测试过程中占用的所有资源
    chassis1 CleanupTest                     
}
