#===================================================================================
# �汾�ţ�1.0
#   
# �ļ�����pkgIndex.tcl
# 
# �ļ��������������ļ�
# 
# ���ߣ�����ʯ(Shawn Li)
#
# ����ʱ��: 2008.03.25
#
# �޸ļ�¼�� 
#   
# ��Ȩ���У�Ixia
#====================================================================================

if {$::tcl_platform(platform) != "unix"} {
    #���IxiaCapi���Ѿ����ع����򷵻�
    if {[lsearch [package names] IxiaCapi] != -1} {
        return
    }
} 
package ifneeded IxiaCAPI 3.3 [list source [file join $dir IxiaCapi.tcl]]

