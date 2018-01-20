#!/bin/bash

#这边编辑要设置的阈值
CRITICAL=90;
#编辑要删除的文件格式，我这边就写*.loglog格式，如果是写*要注意会删除系统文件，很危险
dele_info="*.loglog";
#编辑要保存的log文件名
log="log";

echo "">$log;
#添加发邮件通知功能，这边要引入邮件格式
source  /usr/local/myshell/mail.sh;

ip=`ip a|grep "scope global"|awk '{print $2}'`;
ip2=${ip%%/*};

#如果是根目录使用率>阈值，在删除文件的时候，要排除挂载在根目录下的其他磁盘
function DISK_FILTER
{
disk_filter="";
for exclude_disk in `df -h |awk '{print $6}'|grep  -v '/$'|grep -v "Mounted"|grep -v "挂载点" ` ;
do
   disk_filter="$disk_filter -path $exclude_disk -prune -o ";
done;

}


#执行磁盘文件删除操作
function DISK_CLEAR
{
 ddd=$(echo $x |grep -v  '/$' );
if [ "$ddd" != "" ]
  then
  echo "=========$title_info: $x is used  >90%==========">>$log;
 #在执行删除前，记录被删除文件的日志 
  find  $x  -type f -name "$dele_info" -mtime +30 -exec ls -l {} \;>>$log;
 #执行删除操作
  find $x  -type f -name "$dele_info" -mtime +30 -exec rm -rf {} \;
  #删除一分钟前的
  #find $x  -type f -name "$dele_info" -mmin +1 -exec rm -rf {} \;

   #echo $?;
  #如果上述删除命令执行成功，则发邮件，告知清除完毕，否则发清除失败
   if [ $? -eq 0 ]
      then
         echo "=========$critical_info and cleanup completed!=========">>$log;
         maill_Cleanup_ok;
   else
      echo "==========$critical_info and cleanup error!=========">>$log;
      maill_Cleanup_error;
   fi

else
   #根目录处理
  DISK_FILTER;
  echo "=========$title_info: $x is used  >90%==========">>$log;
   #在执行删除前，记录被删除文件的日志
   find /  $disk_filter  -type f -name "$dele_info" -mtime +30 -exec ls -l {} \;>>$log;
   #执行删除操作
   find /  $disk_filter  -type f -name "$dele_info" -mtime +30 -exec rm -rf {} \;
   #echo $?;
   #如果上述删除命令执行成功，则发邮件，告知清除完毕，否则发清除失败
   if [ $? -eq 0 ]
      then
         echo "=========$critical_info and cleanup completed!=========">>$log;
         maill_Cleanup_ok;
   else
      echo "==========$critical_info and cleanup error!=========">>$log;
      maill_Cleanup_error;
   fi

fi

}

#判断磁盘使用空间是否超过阈值
function IF_CRITICA
{
  var=${y%%%*};
 # echo "$x:$var";
  if [ $var -gt $CRITICAL ]
   then
  # echo "$x:$var%";
  #如果超过阈值，则执行清理操作
   maill_Cleanup_start;
    DISK_CLEAR;
  fi 

}

#=================================================start =========================================================
#判断磁盘空间是否超出阈值
for x in  `df -h  |awk '{print $6}'|grep -v "挂载"|grep -v "Mounted"`;
do
  if [ "$(echo $x |grep -v  '/$' )"  !=  "" ]
  then
   for y in `df -h  |grep -v "Use%"|grep -v "已用%"|grep "$x"|awk '{print $5}'` ;
    do
     critical_info="the space of disk:$x is used $y";
     title_info="the space of disk ";
     IF_CRITICA;
   done;
  else
   #disk=/
   for y in `df -h  |grep -v "Use%"|grep -v "已用%"|grep '/$'|awk '{print $5}'`;
   do
   critical_info="the space of disk:$x is used $y";
     title_info="the space of disk ";
     IF_CRITICA;
   done;
  fi;
done



#判断磁盘inode使用是否超出阈值
for x in  `df -h  |awk '{print $6}'|grep -v "挂载点"|grep -v "Mounted"`;
do
  if [ "$(echo $x |grep -v  '/$' )"  !=  "" ]
  then
   for y in `df -ih  |grep -v "IUse%"|grep "$x"|awk '{print $5}'` ;
    do
   critical_info="the inode of disk:$x is used $y";
   title_info="the inode of disk";
     IF_CRITICA;
   done;
  else
   #disk=/
   for y in `df -ih  |grep -v "IUse%"|grep -v "已用(I)%"|grep '/$'|awk '{print $5}'`;
   do
    critical_info="the inode of disk:$x is used $y";
   title_info="the inode of disk";
     IF_CRITICA;
   done;
  fi;
done

