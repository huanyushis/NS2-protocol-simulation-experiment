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
