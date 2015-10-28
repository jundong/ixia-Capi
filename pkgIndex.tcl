#===================================================================================
# 版本号：1.0
#   
# 文件名：pkgIndex.tcl
# 
# 文件描述：库索引文件
# 
# 作者：李霄石(Shawn Li)
#
# 创建时间: 2008.03.25
#
# 修改记录： 
#   
# 版权所有：Ixia
#====================================================================================

if {$::tcl_platform(platform) != "unix"} {
    #如果IxiaCapi库已经加载过，则返回
    if {[lsearch [package names] IxiaCapi] != -1} {
        return
    }
} 
package ifneeded IxiaCAPI 3.3 [list source [file join $dir IxiaCapi.tcl]]

