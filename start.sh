#!/bin/bash
#这边添加50台服务器的ip，以空格分割 
ip_list="192.168.58.248 192.168.58.242 192.168.1.2";
for i in $ip_list;
do
  echo "==========$i=============";
  #目标服务器免密码登入，后创建目录，并上传脚本
  ssh $i "mkdir -p /usr/local/myshell/"
 scp mail.sh auto_del_30days_ago_file.sh  disk_check.sh  $i:/usr/local/myshell/;
 #判断上传脚本是否成功，如果成功输出提示，如果失败也输出日志
 if [ $? -eq 0 ]
  then
   echo "$i copy file is ok!";
   #给脚本赋执行权限，并创建计划任务，每个一分钟执行一次
   ssh $i "chmod a+x /usr/local/myshell/*.sh";
   ssh $i "echo '*/1 * * * * root /usr/local/myshell/disk_check.sh>/dev/null 2>&1'>>/etc/crontab";
   #判断是否是linux 7版本
   ssh $i "cat /etc/redhat-release |grep 'release 7';";
   if [ $? -eq 0 ]
    then
	#重启计划任务
      ssh $i "/bin/systemctl restart crond.service";
   else
      ssh $i " service crond restart";
   fi
 else
   echo "$i copy file is error!";
fi

done;

