# NS2协议分析与仿真

## 一、NS2安装

ns2需要的环境较为复杂，gcc版本不易过高，以免无法编译成功，推荐使用gcc-4.8、g++-4.8

```bash
# 安装依赖
sudo apt-get install build-essential    
sudo apt-get install tcl8.5 tcl8.5-dev tk8.5 tk8.5-dev
sudo apt-get install libxmu-dev libxmu-headers

# 解压并且移到根目录
tar -xvzf  ns-allinone-2.35.tar.gz 
mv ns-allinone-2.35 ~

sudo apt-get install -y gcc-4.8
sudo apt-get install -y g++-4.8

cd /usr/bin    #进入/usr/bin文件夹下
sudo rm -r gcc  #移除之前的软连接
sudo ln -sf gcc-4.8 gcc #建立gcc4.7的软连接
sudo rm -r g++  #同gcc
sudo ln -sf g++-4.8 g++

cd ~/ns-allinone-2.35

# 修改文件
将 ns-allinone-2.35/ns-2.35/linkstate/ls.h中的137行void eraseAll() { erase(baseMap::begin(), baseMap::end()); }改为 void eraseAll() { this->erase(baseMap::begin(), baseMap::end()); }

#安装
sudo ./install

#如果安装成功，则添加环境变量
#修改我的地址为你们自己的地址
export PATH=$PATH:/home/huanyushi/ns-allinone-2.35/bin:/home/huanyushi/ns-allinone-2.35/tcl8.5.10/unix:/home/huanyushi/ns-allinone-2.35/tk8.5.10/unix
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/huanyushi/ns-allinone-2.35/otcl-1.14:/home/huanyushi/ns-allinone-2.35/lib
export TCL_LIBRARY=$TCL_LIBRARY:/home/huanyushi/ns-allinone-2.35/tcl8.5.10/library

#激活环境变量
source  ~/.bashrc

#理论上这里就安装成功了
#输入ns进行测试
ns
```

# 二、仿真内容

代码没看懂，明早再更

```tcl
#创建模拟器对象
#模拟器对象赋值给变量ns
set ns [new Simulator]       

#给NAM定义不同的数据流，颜色的选择随意，易于区分就可以
$ns color 1 Blue
$ns color 2 Red       

#打开out.nam文件，一般都是在执行程序时自动生成
set nf [open out.nam w]
$ns namtrace-all $nf    

#打开out.tr文件，也是自动生成
set tf [open out.tr w]
$ns trace-all $tf  
#两个文件主要都是用来记录封包传输过程的   

#定义finish程序，在后面执行时可以用到
proc finish {} {
global ns nf tf
$ns flush-trace
#关闭nam文件
close $nf
#关闭trace文件在后面调用的时候，是在程序结束的时候所以前面生成的两个文件必须要关       
close $tf       
exec nam out.nam &    
exit 0
}

#创建8个节点    
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]



#基于题目要求的基础之上，创建结点之间的链路 
$ns duplex-link $n2 $n6 1.5Mb 10ms DropTail
$ns duplex-link $n0 $n2 1.5Mb 10ms DropTail
$ns duplex-link $n0 $n4 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n3 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n5 1.5Mb 10ms DropTail
$ns duplex-link $n5 $n7 1.5Mb 10ms DropTail
$ns duplex-link $n1 $n0 2Mb 20ms DropTail



#给NAM创建节点位置
$ns duplex-link-op $n6 $n2 orient down
$ns duplex-link-op $n2 $n0 orient right-down  
$ns duplex-link-op $n4 $n0 orient right-up  
$ns duplex-link-op $n0 $n1 orient right  
$ns duplex-link-op $n0 $n1 orient right  
$ns duplex-link-op $n1 $n3 orient right-up  
$ns duplex-link-op $n1 $n5 orient right-down
$ns duplex-link-op $n5 $n7 orient down


#设置n0到n1之间的列长度
$ns queue-limit $n1 $n0 10

# TCP与UDP的建立中，agent是一个代理，用来作为网络层的传输与接收
#建立TCP连接   
set tcp [new Agent/TCP]  
$tcp set class_ 2  
$ns attach-agent $n6 $tcp  
set sink [new Agent/TCPSink]  
$ns attach-agent $n3 $sink  
$ns connect $tcp $sink  
$tcp set fid_ 1     
#TCP的连接用红色的数据流表示 

 
#建立UDP连接    
set udp [new Agent/UDP]  
$ns attach-agent $n4 $udp  
set null [new Agent/Null]  
$ns attach-agent $n3 $null  
set null [new Agent/Null]  
$ns attach-agent $n7 $null  
$ns connect $udp $null  
$udp set fid_ 2 
#NAM中，UDP的连接用黄色的数据流表示
   



#在TCP连接上建立FTP  
set ftp [new Application/FTP]  
$ftp attach-agent $tcp  
$ftp set type_ FTP 

 
#在UDP连接上建立CBR
#设置了cbr流量的包类型，字节大小，以及传输速率 
set cbr [new Application/Traffic/CBR]  
$cbr attach-agent $udp  
$cbr set type_ CBR  
$cbr set packet_size_ 2000  
$cbr set rate_ 1mb  
$cbr set random_ false   

 
#设置FTP和CBR起止时间
#0.1秒产生cbr流量
$ns at 0.1 "$cbr start" 
#1.0秒发送ftp流量
$ns at 1.0 "$ftp start" 
#8.0秒ftp流量结束
$ns at 8.0 "$ftp stop"  
#12.0秒cbr流量结束
$ns at 12.0 "$cbr stop" 
#13秒后调用前面写出的finish程序   
$ns at 13.0 "finish" 
 
#执行模拟器程序
$ns run 
```

# Python解析脚本

```python
import sys
import numpy as np
import pandas as pd
import matplotlib as mpl
import seaborn as sns
from matplotlib import pyplot as plt

# 读入文件内容并将字符串内容分割到列表
f = open(sys.argv[1], 'r')
allth = f.read()
f.close()
li = allth.split('\n')
# 定义变量
start = -0.5
i = 0
tmp = [[] for _ in range(26)]
res = []
pkt = []
# 按照每1s分割
while i < 26:
    start += 0.5
    end = start + 0.5
    for j in li:
        j = j.split(' ')
        try:
            if start <= float(j[1]) < end:
                tmp[i].append(j)
            else:
                continue
        except:
            continue
    i += 1
# 计算每一组第六列的和
for k in tmp:
    su_m1 = 0.0
    su_m2 = 0.0
    z = ['0', '1']
    for l in k:
        if l[0] == 'r' and l[2] in z and l[3] in z:
            su_m1 += int(l[5])
            su_m2 += 1
    res.append(su_m1)
    pkt.append(su_m2)

# 输出结果

start = 0.0

index = []
data = []
for i in range(26):
    fir = start + 0.5 * i
    las = fir + 0.5
    print(fir, '~', las, '\t\t'"%d" % pkt[i], '\t\t'"%d" % res[i])
```

github地址:https://github.com/huanyushis/NS2-protocol-simulation-experiment.git