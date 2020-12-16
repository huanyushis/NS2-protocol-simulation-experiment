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
