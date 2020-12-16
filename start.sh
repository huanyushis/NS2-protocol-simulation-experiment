##########################################################################
# File Name: start.sh
# Author: huanyushi
# mail: 1174601344@qq.com
# Created Time: 2020年12月17日 星期四 01时17分46秒
#########################################################################
#!/bin/zsh
PATH=/home/edison/bin:/home/edison/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/work/tools/gcc-3.4.5-glibc-2.3.6/bin
export PATH

ns a.tcl

conda activate base

python ns2.py out.tr
