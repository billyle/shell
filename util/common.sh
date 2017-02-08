# 公用的工具方法

# 输出红色
function echo_red()
{
    echo -e "\033[0;31m[ERROR] $1\033[0m"
}

# 输出绿色
function echo_green()
{
    echo -e "\033[0;32m[INFO] $1\033[0m"
}


# 判断文件是否存在，如果不存在则下载 $1:文件名 $2:下载链接
function downloadWhileNotExist()
{
	if [ -a $1 ]; then
		echo_green "存在文件 $1，不需要下载"
	else
		wget $2
	fi
}
