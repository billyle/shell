#!/bin/bash
function echo_red()
{
    echo -e "\033[0;31m[ERROR] $1\033[0m"
}

function echo_green()
{
    echo -e "\033[0;32m[INFO] $1\033[0m"
}

DOWN_COMMON_URL="https://r.jufan.tv/setup/nginx/"
# 判断文件是否存在，如果不存在则下载 $1:文件名
function downloadWhileNotExist()
{
	if [ -a $1 ]; then
		echo_green "存在文件 $1，不需要下载"
	else
		wget $DOWN_COMMON_URL$1
	fi
}


echo -e "Nginx version 1.8.0"
echo -e "开始.................."
sleep 1

if [ ! -d "/opt/down" ]; then
	mkdir -p /opt/down	
fi
DOWNLOAD_DIR=/opt/down
PF=/etc/profile


cd $DOWNLOAD_DIR
downloadWhileNotExist nginx-1.8.0.tar.gz
downloadWhileNotExist nginx_upstream_check_module-master.zip
downloadWhileNotExist openssl-1.0.2c.tar.gz
downloadWhileNotExist ngx_cache_purge-2.3.tar.gz
downloadWhileNotExist pcre-8.12.tar.gz
downloadWhileNotExist zlib-1.2.5.tar.gz
echo -e "下载结束"
#sleep 2

tar zxf nginx-1.8.0.tar.gz
#tar zxf nginx_upstream_check_module-master.tar.gz
unzip nginx_upstream_check_module-master.zip
tar zxf openssl-1.0.2c.tar.gz
tar zxf ngx_cache_purge-2.3.tar.gz
tar zxf pcre-8.12.tar.gz
tar zxf zlib-1.2.5.tar.gz
echo -e "解压结束"
sleep 2

cd $DOWNLOAD_DIR/nginx-1.8.0
#patch -p1 < $DOWNLOAD_DIR/nginx_upstream_check_module-master/check_1.2.1.patch
patch -p1 < $DOWNLOAD_DIR/nginx_upstream_check_module-master/check_1.7.5+.patch
./configure --prefix=/usr/local/nginx \
--with-pcre=$DOWNLOAD_DIR/pcre-8.12 \
--with-openssl=$DOWNLOAD_DIR/openssl-1.0.2c \
--with-zlib=$DOWNLOAD_DIR/zlib-1.2.5 \
--add-module=$DOWNLOAD_DIR/ngx_cache_purge-2.3 \
--with-http_realip_module \
--with-http_sub_module \
--with-http_flv_module \
--with-http_dav_module \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--with-http_addition_module \
--with-http_ssl_module \
--add-module=$DOWNLOAD_DIR/nginx_upstream_check_module-master
make && make install
echo -e "安装结束 Nginx is install done"
