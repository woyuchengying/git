        global  
    chroot /usr/local/etc/haproxy  
    daemon  
    nbproc 1  
    group root  
    user root  
    pidfile /opt/haproxy/logs/haproxy.pid  
    ulimit-n 65536  
    #spread-checks 5m   
    #stats timeout 5m  
    #stats maxconn 100  
    
    ########默认配置############  
    defaults  
    mode tcp               #默认的模式mode { tcp|http|health }，tcp是4层，http是7层，health只会返回OK  
    retries 3              #两次连接失败就认为是服务器不可用，也可以通过后面设置  
    option redispatch      #当serverId对应的服务器挂掉后，强制定向到其他健康的服务器  
    option abortonclose    #当服务器负载很高的时候，自动结束掉当前队列处理比较久的链接  
    maxconn 32000          #默认的最大连接数  
    timeout connect 5000ms #连接超时  
    timeout client 30000ms #客户端超时  
    timeout server 30000ms #服务器超时  
    #timeout check 2000    #心跳检测超时  
    log 127.0.0.1 local0 err #[err warning info debug]  
    
    ########test1配置#################  
    listen zookeeper  
    bind 172.18.1.11:2181  
    mode tcp  
    balance roundrobin  
    server s1 172.18.1.1:2181 weight 1 maxconn 10000 check inter 10s  
    server s2 172.18.1.2:2181 weight 1 maxconn 10000 check inter 10s  
    server s3 172.18.1.3:2181 weight 1 maxconn 10000 check inter 10s  
    
    ########统计页面配置########  
    listen admin_stats  
    bind 172.18.1.11:8099 #监听端口  
    mode http         #http的7层模式  
    option httplog    #采用http日志格式  
    #log 127.0.0.1 local0 err  
    maxconn 10  
    stats refresh 30s #统计页面自动刷新时间  
    stats uri /stats  
