#!/bin/bash
export PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
var_sh="/usr/local/myshell/auto_del_30days_ago_file.sh";
#echo $var_sh;
ps -ef|grep $var_sh |grep -v "grep $var_sh";
#判断磁盘清理脚本auto_del_30days_ago_file.sh是否已经在运行了，如果没运行，这调用执行，反正退出
if [ $? -eq 0 ]
  then
   echo "$var_sh  is running!!";
 else
   echo "$var_sh is not running";
   $var_sh;
fi
