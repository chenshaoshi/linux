#!/bin/bash
#这边添加50台服务器的ip，以空格分割 
ip_list="192.168.58.248 192.168.58.242 192.168.1.2";
for i in $ip_list;
do
   ssh $i "/usr/local/myshell/disk_check.sh";
   if [ $? -eq 0 ]
    then
      echo "==========ip:$i ok =============";
   else
      echo "==========ip:$i error =============";
   fi
done;

