#!/bin/bash

Down_dir=/home/jifan/tools
Install_Dir=/application/mysql-5.6.11
function Download(){
. /etc/init.d/functions
[ ! -d  $Down_dir  ] && mkdir $Down_dir -p
Down_check=$(find $Down_dir -type f -name mysql-5.6.11.tar.gz|wc -l )

if [ $Down_check -eq 0  ] 
  then 
	echo "Downloading the mysql source code,please wait"
	wget -P /home/jifan/tools/  http://cdn.mysql.com/archives/mysql-5.6/mysql-5.6.11.tar.gz &> /dev/null
	#wget -P /home/jifan/tools/  http://172.16.1.20/tools/mysql-5.6.11.tar.gz &> /dev/null
	[ $? -eq 0 ]  && action "downloading ..." /bin/true  || action "downloading ..." /bin/false
fi

}
function Ncurses_compile(){
Ncureses_check=$(find $Down_dir -type f -name ncurses-5.8.tar.gz|wc -l)
Tar_Ncureses_check=$(find $Down_dir -type d -name ncurses-5.8|wc -l)
if [  $Ncureses_check -eq 0  ]  
  then 
	wget http://ftp.gnu.org/gnu/ncurses/ncurses-5.8.tar.gz &> /dev/null
	[ $? -ne 0  ] && (echo "download ncurses error,exit";exit 1)
fi

if [ $Tar_Ncureses_check -eq 0  ]
  then
	cd $Down_dir 
	tar xf ncurses-5.8.tar.gz
	cd ncurses-5.8
	./configure > /dev/null
	[ $? -ne 0  ] && exit 3
	make &> /dev/null
	make install &> /dev/null
	[ $? -ne 0  ] && exit 3
fi
}

function Install_tools(){
  cd /home/jifan/tools 
if [ $(find /home/jifan/tools/  -name ncurses-base-5.7-4.20090207.el6.x86_64.rpm |wc -l ) -eq 0   ]
  then
  	wget http://172.16.1.20/tools/ncurses-base-5.7-4.20090207.el6.x86_64.rpm	
  	wget http://172.16.1.20/tools/ncurses-devel-5.7-4.20090207.el6.x86_64.rpm
  	wget http://172.16.1.20/tools/ncurses-libs-5.7-4.20090207.el6.x86_64.rpm
  	yum localinstall  ncurses-base-5.7-4.20090207.el6.x86_64.rpm ncurses-devel-5.7-4.20090207.el6.x86_64.rpm tools/ncurses-libs-5.7-4.20090207.el6.x86_64.rpm  -y	
  	wget http://172.16.1.20/tools/bison-devel-2.4.1-5.el6.x86_64.rpm 
  	yum localinstall bison-devel-2.4.1-5.el6.x86_64.rpm -y 
fi
}
function Compile_tools(){

Package_check=$(rpm -q make gcc-c++ cmake bison-devel ncurses-devel | awk '/not installed/{ print $2}' |tr '\n' ' ')
if [ -n "$Package_check"  ]
  then  
 	echo "installing compile tools,please wait"
        for i in $Package_check
	do
	    yum install $i -y &> /dev/null 
	    if [ $? -ne 0   ] 
	      then
       		 echo "install $i failed,exit "
   	         exit 1
   	    fi
	done
  else 
	echo "all compile tools haved installed "
fi
}

function Make(){
Tar_dir=$(find $Down_dir -type d -name mysql-5.6.11|wc -l )

id mysql &> /dev/null
[ $? -ne 0  ] && useradd -s /sbin/nologin -r mysql 
[ ! -d $Install_Dir  ] && mkdir $Install_Dir -p

if [  $Tar_dir -eq  0  ]
  then 
	echo "compling mysql source code ,please wiat"
        cd /home/jifan/tools	
	tar xf mysql-5.6.11.tar.gz
 	cd  mysql-5.6.11 
	cmake -DCMAKE_INSTALL_PREFIX=$Install_Dir \
 -DMYSQL_DATADIR=$Install_Dir/data \
 -DMYSQL_UNIX_ADDR=$Install_Dir/tmp/mysql.sock \
 -DWITH_EXTRA_CHARSETS:STRING=utf8,gbk \
 -DWITH_MYISAM_STORAGE_ENGINE=1 \
 -DWITH_INNOBASE_STORAGE_ENGINE=1 \
 -DWITH_MEMORY_STORAGE_ENGINE=1 \
 -DWITH_READLINE=1 \
 -DENABLED_LOCAL_INFILE=1 \
 -DMYSQL_USER=mysql > /dev/null 
	[ $? -ne 0  ] && exit 3
	make && action "make ..." /bin/true  || action "make ..." /bin/false
	make install && action "make installing ..." /bin/true || action "make installing ..." /bin/false

fi
}

function Initialization(){

[ $(find /etc -name my.cnf |wc -l )  -eq 1 ] &&  mv /etc/my.cnf /etc/my.cnf.bak
cat > /etc/my.cnf <<EOF
[mysqld]
basedir = $Install_Dir
datadir = $Install_Dir/data
port = 3306
server_id =  2
socket =  $Install_Dir/tmp/mysql.sock
pid-file = $Install_Dir/data/mysql.pid
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
EOF

[  $(find /application/ -type l -name mysql  |wc -l )  -eq  0  ] &&  ln -s  /application/mysql-5.6.11 /application/mysql
[ $(grep "PATH=/application/mysql/bin/:" /etc/profile |wc -l)  -eq 0 ]  && echo  -e 'PATH=/application/mysql/bin/:$PATH\nexport PATH' >> /etc/profile
source /etc/profile
[ $(ll /application/mysql/data |wc -l) -lt 5 ] && \
/application/mysql/scripts/mysql_install_db  --user=mysql --basedir=$Install_Dir  --datadir=$Install_Dir/data/
[ $(find /etc/init.d/ -type f -name mysqld  |wc -l )  -eq  0  ] && cp /application/mysql/support-files/mysql.server /etc/init.d/mysqld
[ -z "$(lsof -i :3306)"   ] && /etc/init.d/mysqld start

}


Download
#Install_tools
Compile_tools
Make
Initialization


