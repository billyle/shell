#!/bin/bash

function echo_red()
{
    echo -e "\033[0;31m[ERROR] $1\033[0m"
}


function echo_green()
{
    echo -e "\033[0;32m[INFO] $1\033[0m"
}

TOM_VERSION=7.0.75
JUNGLE_TOM_DIR=/opt/cgi/jungle-tomcat-$TOM_VERSION
PROTOCOL=nio

echo_green "Tomcat version $TOM_VERSION"
echo_green "开始"

if [ -d ${JUNGLE_TOM_DIR} ]; then
        read -p "检测到已经存在为jungle定制的tomcat，是否覆盖(y覆盖，其他任意键退出安装):" flag;
        if [ ${flag}x = "y"x ]; then
		rm -rf /opt/cgi/jungle-tomcat-$TOM_VERSION;
                echo_green "删除旧的重装";
        else
                echo_red "不覆盖，退出安装";
		exit 0
        fi
fi

read -p "tomcat使用什么io模式(bio/nio/apr)默认nio:" protocol;
if [ ${protocol}x = "bio"x ]; then
	PROTOCOL=bio
elif [ ${protocol}x = "apr"x ]; then
        PROTOCOL=apr  
fi
echo_green "tomcat将使用 $PROTOCOL"

# 下载
mkdir /opt/down
TOMCATDOWNPATH=/opt/down
cd $TOMCATDOWNPATH

# 删除之前下载的
rm -rf apache-tomcat-$TOM_VERSION.tar.gz
# 下载安装包
wget http://mirrors.aliyun.com/apache/tomcat/tomcat-7/v$TOM_VERSION/bin/apache-tomcat-$TOM_VERSION.tar.gz

# 当使用apr协议是安装apr相关的组件
if [ ${PROTOCOL}x = "apr"x ];then
	rm -rf apr-1.5.2.tar.gz apr-util-1.5.4.tar.gz
	wget http://mirrors.aliyun.com/apache/apr/apr-1.5.2.tar.gz
	wget http://mirrors.aliyun.com/apache/apr/apr-util-1.5.4.tar.gz
	echo_green "使用apr模式,下载apr相关组件完成"
fi
echo_green "下载结束 download Tomcat done"
sleep 2

if [ ! -d "/opt/cgi" ]; then
	mkdir -p /opt/cgi	
fi

tar xf apache-tomcat-$TOM_VERSION.tar.gz -C /opt/cgi/
tar xf jdk-7u75-linux-x64.tar.gz -C /usr/local/
if [ ${PROTOCOL}x = "apr"x ];then
	tar xf apr-1.5.2.tar.gz
	tar xf apr-util-1.5.4.tar.gz
fi
echo_green "解压结束 tar done"
sleep 2

if [ ${PROTOCOL}x = "apr"x ];then
	if [ -d "/usr/local/apr-1.5.2" ]; then
		echo_green "apr已存在"
	else
		echo_green "apr不存在，安装apr"
		cd $TOMCATDOWNPATH
		cd apr-1.5.2
		./configure --prefix=/usr/local/apr-1.5.2 > /dev/null 2>&1
		make > /dev/null 2>&1
		make install > /dev/null 2>&1
	fi


	if [ -d "/usr/local/apr-util-1.5.4" ]; then
		echo_green "apr-util已存在"
	else
		echo_green "apr-util不存在，安装apr-util"
		cd $TOMCATDOWNPATH
		cd apr-util-1.5.4
		./configure --prefix=/usr/local/apr-util-1.5.4/ --with-apr=/usr/local/apr-1.5.2 > /dev/null 2>&1
		make > /dev/null 2>&1
		make install > /dev/null 2>&1
	fi

	cd /opt/cgi/apache-tomcat-$TOM_VERSION/bin
	tar xf tomcat-native.tar.gz
	tomcat_native_dir=`ls  | grep tomcat-native-*-src`
	cd $tomcat_native_dir/jni/native
	./configure --with-apr=/usr/local/apr-1.5.2 --with-java-home=$JAVA_HOME -prefix=/opt/cgi/apache-tomcat-$TOM_VERSION > /dev/null 2>&1
	make > /dev/null 2>&1
	make install > /dev/null 2>&1
	echo_green "安装apr结束 make done"
	sleep 2
fi

mv /opt/cgi/apache-tomcat-$TOM_VERSION ${JUNGLE_TOM_DIR}

rm -rf ${JUNGLE_TOM_DIR}/bin/*.bat
echo_green "移除无用windows脚本 remove bat done"
echo "精简一下jungle的tomcat"
# jungle 不使用这两个脚本启动停止服务器了，为了避免误用，在此删除
rm -rf ${JUNGLE_TOM_DIR}/bin/startup.sh
rm -rf ${JUNGLE_TOM_DIR}/bin/shutdown.sh
rm -rf ${JUNGLE_TOM_DIR}/webapps
rm -rf ${JUNGLE_TOM_DIR}/LICENSE
rm -rf ${JUNGLE_TOM_DIR}/NOTICE
rm -rf ${JUNGLE_TOM_DIR}/RELEASE-NOTES
rm -rf ${JUNGLE_TOM_DIR}/RUNNING.txt

# 修改下配置文件
cp -f ${JUNGLE_TOM_DIR}/conf/server.xml ${JUNGLE_TOM_DIR}/conf/server.xml.beforejungle.bak

# 修改协议
if [ ${PROTOCOL}x = "nio"x ];then
	sed -i 's/<Connector port="8080" protocol="HTTP\/1.1"/<Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol"/g' ${JUNGLE_TOM_DIR}/conf/server.xml
elif [ ${PROTOCOL}x = "apr"x ];then
	echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$CATALINA_HOME/lib" > ${JUNGLE_TOM_DIR}/bin/setenv.sh
	sed -i 's/<Connector port="8080" protocol="HTTP\/1.1"/<Connector port="8080" protocol="org.apache.coyote.http11.Http11AprProtocol"/g' ${JUNGLE_TOM_DIR}/conf/server.xml
fi

# 添加URL中文支持
sed -i 's/8080" protocol/8080" URIEncoding="UTF-8" protocol/g' ${JUNGLE_TOM_DIR}/conf/server.xml
# 更改Host标签
sed -i 's/<Host name="localhost"  appBase="webapps"/<Host name="localhost"  appBase="\/opt\/cgi\/{update me}\/webapps"/g' ${JUNGLE_TOM_DIR}/conf/server.xml
sed -i 's/unpackWARs="true" autoDeploy="true">/unpackWARs="false" autoDeploy="false">/g' ${JUNGLE_TOM_DIR}/conf/server.xml
# 关闭流水日志
sed -i 's/<Valve className="org.apache.catalina.valves.AccessLogValve"/<!-- Valve className="org.apache.catalina.valves.AccessLogValve"/g' ${JUNGLE_TOM_DIR}/conf/server.xml
sed -i 's/%s %b" \/>/%s %b" \/ -->/g' ${JUNGLE_TOM_DIR}/conf/server.xml
cp -f ${JUNGLE_TOM_DIR}/bin/catalina.sh ${JUNGLE_TOM_DIR}/bin/catalina.sh.beforejungle.bak
# 嵌入初始化脚本
# sed -i 's/#!\/bin\/sh/#!\/bin\/sh\npath=`dirname $0`\n# 嵌入初始化参数\n. $path\/..\/..\/bin\/init.sh/g' ${JUNGLE_TOM_DIR}/bin/catalina.sh
sed -i 's/# Lic/# 嵌入初始化参数\npath=\`dirname $0\`\ninitfile=$path\/..\/..\/bin\/init.sh\nif [ -e ${initfile} ]; then\n\t. ${initfile}\nelse\n\techo -e "\\033[0;31m[ERROR] 未找到初始化参数!!!在\\\$PROJECT_DIR\\\\" "\\bbin目录下\\033[0m"\nfi\n#  Lic/g' ${JUNGLE_TOM_DIR}/bin/catalina.sh

echo_green "精简tomcat，修改配置文件完成"
sleep 2

cp /etc/profile /etc/profile.tomcat.bak


if [ ${PROTOCOL}x = "apr"x ];then
	tmp="`grep "LD_LIBRARY_PATH=/usr/local/apr-1.5.2/lib" /etc/profile`"
	if [ $? -eq 1 ];then
	        echo -e "export LD_LIBRARY_PATH=/usr/local/apr-1.5.2/lib:\$LD_LIBRARY_PATH" >> /etc/profile
		echo_green "配置tomcat apr环境变量ok"
	fi
fi

source /etc/profile
echo_green "更新配置文件 /etc/profile 完成"
echo_green "\n安装tomcat完成,开始检验一下"
java -version
sh ${JUNGLE_TOM_DIR}/bin/version.sh
