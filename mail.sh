export PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
mail_addr="576464043@qq.com"

function maill_Cleanup_start
{
echo "Server name:`hostname`($ip2)
Monitor items:Disk Space:$x
Detection time:`date "+%Y-%m-%d %H:%M:%S"`
Current state:CRITICAL,$critical_info
---------------df -h---------------
`df -h | head -1`  
`df -h|grep "$x"`    
---------------df -ih---------------
`df -h | head -1`  
`df -ih|grep "$x"`   
------------------------------------

"|/bin/mail -s "`hostname`($ip2) $title_info:$x is CRITICAL"   $mail_addr;
}

function maill_Cleanup_ok
{
echo "Server name:`hostname`($ip2)
Monitor items:Disk Space:$x
Detection time:`date "+%Y-%m-%d %H:%M:%S"`
Current state:Cleanup completed,$critical_info
---------------df -h---------------
`df -h | head -1`   
`df -h|grep "$x"`   
---------------df -ih---------------
`df -h | head -1`   
`df -ih|grep "$x"`   
------------------------------------

"|/bin/mail -s "`hostname`($ip2)  $title_info:$x is Cleanup  completed"   $mail_addr;
}

function maill_Cleanup_error
{
echo "Server name:`hostname`($ip2)
Monitor items:Disk Space:$x
Detection time:`date "+%Y-%m-%d %H:%M:%S"`
Current state:$critical_info,Cleanup  failed
---------------df -h---------------
`df -h | head -1`  
`df -h|grep "$x"`   
---------------df -ih---------------
`df -h | head -1`   
`df -ih|grep "$x"`  
------------------------------------

"|/bin/mail -s "`hostname`($ip2)  $title_info:$x Cleanup   failed "   $mail_addr;
}

