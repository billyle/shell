#!/bin/bash

# 引入工具方法
. `dirname $0`/../util/common.sh


REDIS_VERSION="2.8.19"


echo_green "Redis version $REDIS_VERSION"
echo_green "开始"
sleep 1

mkdir /opt/down
DOWNPATH=/opt/down
cd $DOWNPATH

downloadWhileNotExist redis-$REDIS_VERSION.tar.gz http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz

echo_green "下载结束 Redis done"
sleep 2

tar zxf redis-$REDIS_VERSION.tar.gz -C /usr/local

echo_green "解压结束 tar done"
sleep 2

cd /usr/local
cd redis-$REDIS_VERSION


# 编译依赖 $1:依赖目录名
function makeDep(){
	echo_green "编译依赖:$1"
	cd deps/$1/
	if [ -a configure ]; then
		./configure
	fi
	make
	cd -
}

#makeDep hiredis
#makeDep lua
#makeDep jemalloc

# 编译redis 
make && make install

echo_green "安装结束 make done"
sleep 2

mkdir -p /usr/local/redis/conf
mkdir -p /usr/local/redis/log
mkdir -p /usr/local/redis/data
cp redis.conf /usr/local/redis/conf
cp sentinel.conf /usr/local/redis/conf

echo_green "复制配置文件结束 copy conf to /usr/local/redis/conf done"

# cd $DOWNPATH
# cp redis-server /etc/init.d/
# chmod +x /etc/init.d/redis-server
# echo_green "复制安装服务结束 copy service script to /etc/init.d/redis-server"
# sleep 2

echo_green "配置内核分配内存策略 = 1"
cp /etc/sysctl.conf /etc/sysctl.redis.conf.bak
echo -e "\n\n#redis\nvm.overcommit_memory = 1" >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1

echo 1 > /proc/sys/vm/overcommit_memory

echo_green "设置redis运行方式为守护模式"
sed -i 's/daemonize no/daemonize yes\n#守护进程模式/g' /usr/local/redis/conf/redis.conf

echo_green "设置redis运行pid"
sed -i 's/pidfile \/var\/run\/redis.pid/pidfile \/var\/run\/redis.pid\n#守护进程模式 运行pid/g' /usr/local/redis/conf/redis.conf

echo_green "设置redis端口"
sed -i 's/port 6379/port 6379\n#端口/g' /usr/local/redis/conf/redis.conf

echo_green "设置redis最大内存数为2G,如需更改请手动修改配置"
sed -i 's/# maxmemory <bytes>/# maxmemory <bytes>\n#maxmemory 2gb\n#分配2GB内存/g' /usr/local/redis/conf/redis.conf

echo_green "设置redis最大连接数为20000,如需更改请手动修改配置"
sed -i 's/# maxclients 10000/maxclients 20000\n#最大连接数2w/g' /usr/local/redis/conf/redis.conf

echo_green "设置redis存储文件名"
sed -i 's/dbfilename dump.rdb/dbfilename dump.rdb\n#文件名/g' /usr/local/redis/conf/redis.conf

echo_green "设置redis文件存储位置"
sed -i 's/dir .\//#dir .\/\ndir \/usr\/local\/redis\/data\/\n#文件存储位置/g' /usr/local/redis/conf/redis.conf


echo_green "优化结束 optimalize finish(youhua)"
