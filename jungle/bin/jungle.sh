#!/bin/bash

# *****************************
# 脚本全局参数定义开始
# *****************************

# 调试模式(0=关闭,1=开启)
DEBUG_MODE=0


# *****************************
# 脚本辅助方法开始
# 包括输出各种颜色日志的方法等
# *****************************
function echo_red()
{
    echo -e "\033[0;31m[ERROR] $1\033[0m"
}

function echo_green()
{
    echo -e "\033[0;32m[INFO] $1\033[0m"
}


function echo_red_multi()
{
        echo "$*" | while read line
        do
                echo_red "$line"
        done
}

function echo_green_multi()
{
        echo "$*" | while read line
        do
                echo_green "$line"
        done
}

function debug()
{
        if [ $DEBUG_MODE -eq 1 ];then
                echo "$*" | while read line
                do
                        echo "[DEBUG] $line"
                done
        fi
}

# **************************
# 脚本辅助方法结束
# **************************


#创建一个属于jungle组的文件夹
function mkdirForJungle()
{
	local dir_path=$1;
	# 如果文件夹不存在,创建它
	if [ -d $dir_path ];then
		debug "$dir_path already exist!";
	else
		mkdir -p $dir_path;
	fi
	# 更改文件夹权限
	chown -hR root:jungle $dir_path;
	chmod -R 775 $dir_path;
}

# 脚本主方法
function main()
{
	debug "输入的参数为:$*";
	mkdirForJungle $1;
}
# 脚本的主入口
main $*
