#!/bin/bash
echo -e "美化"
echo -e "开始.................."
sleep 3
cp /etc/profile /etc/profile.beautify.bak

echo -e "grep 搜索带颜色"
#alias grep='grep --color=auto'
echo -e "\n\n#alias\nalias grep='grep --color=auto'" >> /etc/profile


echo -e "dstat 状态查看器"
#alias dstat='dstat -cdlmnpsy'
echo -e "alias dstat='dstat -cdlmnpsy'" >> /etc/profile
source /etc/profile
echo -e "美化结束"

sleep 1
ps -ef | grep 'grep'

dstat





	



