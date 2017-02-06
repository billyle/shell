#!/bin/sh
# 高亮关键字tail(tail_light = tail -f with height light)

RUN_CMD="tail -f $1 | perl -pe 's/($2)/\e[1;31m$2\e[0m/g'"

#  下面这个命令暂时不能使用,由于第一个管道缓存的原因,会等缓冲取满了才给想下一个管道输出,我想到的解决办法是让替换变成行级的,读一行输出一行,这个以后再找具体的办法
# RUN_CMD="tail -f $1 | perl -pe 's/($2)/\e[1;31m$2\e[0m/g' | perl -pe 's/(ERR)/\e[1;31m\$1\e[0m/g' |perl -pe 's/(DEB)/\e[1;32m\$1\e[0m/g'"

if [ -n '$3' ];	then
	RUN_CMD="tail -f $1 $3 | perl -pe 's/($2)/\e[1;31m$2\e[0m/g'"
fi

echo -e '\e[1;32m实际的命令是:\e[0m\c'
echo $RUN_CMD
eval $RUN_CMD
