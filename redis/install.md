## 参考文档
    http://www.cnblogs.com/wuxl360/p/5920330.html
    http://www.cnblogs.com/cndota/p/6113921.html
## Install redis
    wget http://download.redis.io/releases/redis-3.2.9.tar.gz && tar zxvf redis-3.2.9.tar.gz && cd redis-3.2.9
    make 
    make PREFIX=/usr/local/redis install
    cp src/redis-trib.rb /usr/local/redis/bin/
    mkdir /usr/local/redis/conf && cp redis.conf /usr/local/redis/conf
#### 启动redis服务 (7000-7005,一共6个节点)
    cp -r /usr/local/redis /usr/local/redis7000 && mv /usr/local/redis7000 /usr/local/redis && cd /usr/local/redis
    cp -r redis7000 redis7001 && cp -r redis7000 redis7002 && cp -r redis7000 redis7003 && cp -r redis7000 redis7004 && cp -r redis7000 redis7005
#### vi /usr/local/redis/redis7000/conf/redis.conf 修改
    port 7000                               各个节点不相同
    bind 192.168.25.182                       相同
    cluster-enabled yes                     相同
    cluster-config-file nodes-7000.conf     各个节点不相同
    pidfile /var/run/redis_7000.pid         各个节点不相同
    daemonize yes                           相同
#### 启动各个节点redis服务
    chmod 755  /usr/local/redis/redis7000/bin/* && /usr/local/redis/redis7000/bin/redis-server /usr/local/redis/redis7000/conf/redis.conf
    chmod 755  /usr/local/redis/redis7001/bin/* && /usr/local/redis/redis7001/bin/redis-server /usr/local/redis/redis7001/conf/redis.conf
    chmod 755  /usr/local/redis/redis7002/bin/* && /usr/local/redis/redis7002/bin/redis-server /usr/local/redis/redis7002/conf/redis.conf
    chmod 755  /usr/local/redis/redis7003/bin/* && /usr/local/redis/redis7003/bin/redis-server /usr/local/redis/redis7003/conf/redis.conf
    chmod 755  /usr/local/redis/redis7004/bin/* && /usr/local/redis/redis7004/bin/redis-server /usr/local/redis/redis7004/conf/redis.conf
    chmod 755  /usr/local/redis/redis7005/bin/* && /usr/local/redis/redis7005/bin/redis-server /usr/local/redis/redis7005/conf/redis.conf
## Install ruby
    yum -y install ruby rubygems
    gem install redis
#### 启动redis集群    
    /usr/local/redis/bin/redis-trib.rb create --replicas 1 192.168.25.182:7000 192.168.25.182:7001 192.168.25.182:7002 192.168.25.182:7003 192.168.25.182:7004 192.168.25.182:7005
    >>> Creating cluster
    >>> Performing hash slots allocation on 6 nodes...
    Using 3 masters:
    192.168.25.182:7000
    192.168.25.182:7001
    192.168.25.182:7002
    Adding replica 192.168.25.182:7003 to 192.168.25.182:7000
    Adding replica 192.168.25.182:7004 to 192.168.25.182:7001
    Adding replica 192.168.25.182:7005 to 192.168.25.182:7002
    M: 1ba10301e7ec721cc1f408f483b3d30bf581b753 192.168.25.182:7000
    slots:0-5460 (5461 slots) master
    M: 35f8ba2aa437337e8222d610ed5c8e54aeb6816c 192.168.25.182:7001
    slots:5461-10922 (5462 slots) master
    M: 8d10fe0d1f0ad3b8bc0f7a60cc2a0ecf1a06b83a 192.168.25.182:7002
    slots:10923-16383 (5461 slots) master
    S: 771e92d64dbc0aa0f39453c2a04ef4b238a37b88 192.168.25.182:7003
    replicates 1ba10301e7ec721cc1f408f483b3d30bf581b753
    S: 82759bdca311f04cb21d5b43d62b0fcf95f7353b 192.168.25.182:7004
    replicates 35f8ba2aa437337e8222d610ed5c8e54aeb6816c
    S: b0da4b2b80ba9d32cab7c411663d1c93080e471c 192.168.25.182:7005
    replicates 8d10fe0d1f0ad3b8bc0f7a60cc2a0ecf1a06b83a
    Can I set the above configuration? (type 'yes' to accept): yes
    >>> Nodes configuration updated
    >>> Assign a different config epoch to each node
    >>> Sending CLUSTER MEET messages to join the cluster
    Waiting for the cluster to join....
    >>> Performing Cluster Check (using node 192.168.25.182:7000)
    M: 1ba10301e7ec721cc1f408f483b3d30bf581b753 192.168.25.182:7000
    slots:0-5460 (5461 slots) master
    1 additional replica(s)
    M: 8d10fe0d1f0ad3b8bc0f7a60cc2a0ecf1a06b83a 192.168.25.182:7002
    slots:10923-16383 (5461 slots) master
    1 additional replica(s)
    M: 35f8ba2aa437337e8222d610ed5c8e54aeb6816c 192.168.25.182:7001
    slots:5461-10922 (5462 slots) master
    1 additional replica(s)
    S: 771e92d64dbc0aa0f39453c2a04ef4b238a37b88 192.168.25.182:7003
    slots: (0 slots) slave
    replicates 1ba10301e7ec721cc1f408f483b3d30bf581b753
    S: 82759bdca311f04cb21d5b43d62b0fcf95f7353b 192.168.25.182:7004
    slots: (0 slots) slave
    replicates 35f8ba2aa437337e8222d610ed5c8e54aeb6816c
    S: b0da4b2b80ba9d32cab7c411663d1c93080e471c 192.168.25.182:7005
    slots: (0 slots) slave
    replicates 8d10fe0d1f0ad3b8bc0f7a60cc2a0ecf1a06b83a
    [OK] All nodes agree about slots configuration.
    >>> Check for open slots...
    >>> Check slots coverage...
    [OK] All 16384 slots covered.
#### 验证集群是否正常
    /usr/local/redis/bin/redis-cli -h 192.168.25.182 -c -p 7000
    192.168.25.182:7000> CLUSTER INFO
    cluster_state:ok
    cluster_slots_assigned:16384
    cluster_slots_ok:16384
    cluster_slots_pfail:0
    cluster_slots_fail:0
    cluster_known_nodes:6
    cluster_size:3
    cluster_current_epoch:6
    cluster_my_epoch:1
    cluster_stats_messages_sent:2219
    cluster_stats_messages_received:2219
    192.168.25.182:7000> set hello world
    OK
    192.168.25.182:7000> keys *
    1) "hello"
    192.168.25.182:7000> quit
    /usr/local/redis/bin/redis-cli -h 192.168.25.182 -c -p 7005
    192.168.25.182:7005> get hello
    -> Redirected to slot [866] located at 192.168.25.182:7000
    "world"
    192.168.25.182:7000> quit