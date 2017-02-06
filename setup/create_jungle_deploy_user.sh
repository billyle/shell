#!/bin/bash
GROUP_NAME=jungle
USER_NAME=jungle_deployer

function echo_red()
{
    echo -e "\033[0;31m[ERROR] $1\033[0m"
}

function echo_green()
{
    echo -e "\033[0;32m[INFO] $1\033[0m"
}

# 创建用户组
groupadd -f $GROUP_NAME
echo_green "用户组创建成功：$GROUP_NAME "
# 检查是否存在部署用户
if id -u $USER_NAME >/dev/null 2>&1; then
        echo_red "部署用户: $USER_NAME 已经存在，退出创建脚本"
	exit 0
else
        echo_green "部署用户: $USER_NAME 不存在，开始创建"
fi
# 创建用户
useradd -c "部署用户" -g $GROUP_NAME $USER_NAME
# 修改新创建用户的密码
python change_jungle_deploy_user_pwd.py

if [ -d "/opt/cgi" ];then
        echo_green "/opt/cgi存在"
else
        echo_green "不存在/opt/cgi目录,创建它"
        mkdir -p "/opt/cgi"
fi

if [ -d "/opt/workers" ];then
        echo_green "/opt/workers存在"
else
        echo_green "不存在/opt/workers目录,创建它"
        mkdir -p "/opt/workers"
fi

# 给用户添加文件修改权限
chown -hR root:$GROUP_NAME /opt/workers
chown -hR root:$GROUP_NAME /opt/cgi
chmod -R 775 /opt/workers
chmod -R 775 /opt/cgi

echo_green "创建部署用户成功"



