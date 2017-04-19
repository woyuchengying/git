# **实验**
本实验的目的是要在一台vmware虚拟机上搭建一套容器云. 容器云架构为zookeeper+mesos+marathon+docker+haproxy. 看完这篇文章之后,你会发现在一台虚拟上做集群实验是如此的简单.  
给我一台虚拟机, 我能把你公司全部架构给你模拟出来.
## 实验环境
vmware虚拟机一台, 虚拟机ip为192.168.5.21  
docker版本1.12及以上  
容器的ip地址分配如下：

| ip            | port          |name    |function|other|
| :-----------: |:-------------:|:------:|:-------:|:--:|
| 172.18.1.1, 172.18.1.2, 172.18.1.3| 2181|zk1, zk2, zk3|zookeeper集群|
| 172.18.1.4, 172.18.1.5, 172.18.1.6| 5050|master1, master2, master3|mesos_master集群|
| 172.18.1.7, 172.18.1.8| 8080|marathon1, marathon2|marathon冗余|
| 172.18.1.9   |5050|mesos_proxy|mesos代理|7层代理|
| 172.18.1.10  |8080|marathon_proxy|marathon代理|7层代理|
| 172.18.1.11  |2181|zk_proxy|zookeeper代理|4层代理|
| 172.18.1.12, 172.18.1.13|5051|slave1, slave2|mesos_slave主机|

## 创建docker网络
    docker network create --driver bridge --subnet 172.18.1.0/24 --gateway 172.18.1.254 zookeeper
## zookeeper
    docker pull mesoscloud/zookeeper:3.4.8-centos-7
    docker run -d --restart always --name zk1 --network zookeeper --ip 172.18.1.1 -e MYID=1 -e SERVERS=172.18.1.1,172.18.1.2,172.18.1.3 mesoscloud/zookeeper:3.4.8-centos-7
    docker run -d --restart always --name zk2 --network zookeeper --ip 172.18.1.2 -e MYID=2 -e SERVERS=172.18.1.1,172.18.1.2,172.18.1.3 mesoscloud/zookeeper:3.4.8-centos-7
    docker run -d --restart always --name zk3 --network zookeeper --ip 172.18.1.3 -e MYID=3 -e SERVERS=172.18.1.1,172.18.1.2,172.18.1.3 mesoscloud/zookeeper:3.4.8-centos-7
## mesos_master zk节点:/mesos/my_mesos
    docker pull mesoscloud/mesos-master:0.28.1-centos-7

    docker run -d --restart always --name master1 --network zookeeper --ip 172.18.1.4 \
    -e MESOS_HOSTNAME=172.18.1.4 \
    -e MESOS_IP=172.18.1.4 \
    -e MESOS_QUORUM=2 \
    -e MESOS_ZK=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/mesos/my_mesos \
    mesoscloud/mesos-master:0.28.1-centos-7

    docker run -d --restart always --name master2 --network zookeeper --ip 172.18.1.5 \
    -e MESOS_HOSTNAME=172.18.1.5 \
    -e MESOS_IP=172.18.1.5 \
    -e MESOS_QUORUM=2 \
    -e MESOS_ZK=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/mesos/my_mesos \
    mesoscloud/mesos-master:0.28.1-centos-7

    docker run -d --restart always --name master3 --network zookeeper --ip 172.18.1.6 \
    -e MESOS_HOSTNAME=172.18.1.6 \
    -e MESOS_IP=172.18.1.6 \
    -e MESOS_QUORUM=2 \
    -e MESOS_ZK=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/mesos/my_mesos \
    mesoscloud/mesos-master:0.28.1-centos-7

## marathon zk节点:/marathon/my_marathon
    docker pull mesoscloud/marathon:1.1.1-centos-7

    docker run -d --restart always --name marathon1 --network zookeeper --ip 172.18.1.7 \
    -e MARATHON_HOSTNAME=172.18.1.7 \
    -e MARATHON_HTTPS_ADDRESS=172.18.1.7 \
    -e MARATHON_HTTP_ADDRESS=172.18.1.7 \
    -e MARATHON_MASTER=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/mesos/my_mesos \
    -e MARATHON_ZK=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/marathon/my_marathon \
    mesoscloud/marathon:1.1.1-centos-7

    docker run -d --restart always --name marathon2 --network zookeeper --ip 172.18.1.8 \
    -e MARATHON_HOSTNAME=172.18.1.8 \
    -e MARATHON_HTTPS_ADDRESS=172.18.1.8 \
    -e MARATHON_HTTP_ADDRESS=172.18.1.8 \
    -e MARATHON_MASTER=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/mesos/my_mesos \
    -e MARATHON_ZK=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/marathon/my_marathon \
    mesoscloud/marathon:1.1.1-centos-7
## haproxy
    docker pull haproxy:1.6

    docker run -d --restart always -p 5050:5050 --name mesos_proxy --network zookeeper --ip 172.18.1.9 \
    -v /usr/etc/haproxy/haproxy3.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:1.6
    
    docker run -d --restart always -p 8080:8080 --name marathon_proxy --network zookeeper --ip 172.18.1.10 \
    -v /usr/etc/haproxy/haproxy4.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:1.6   
    
    docker run -d --restart always -p 2181:2181 --name zk_proxy --network zookeeper --ip 172.18.1.11 \
    -v /usr/etc/haproxy/haproxy2.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro haproxy:1.6

## mesos_slave
    docker pull mesoscloud/mesos-slave:0.28.1-centos-7

    docker run -d --restart always --name slave1 --privileged --network zookeeper --ip 172.18.1.12 \
    -e MESOS_HOSTNAME=172.18.1.12 \
    -e MESOS_IP=172.18.1.12 \
    -e MESOS_MASTER=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/mesos/my_mesos \
    -v /sys/fs/cgroup:/sys/fs/cgroup \
    -v /var/run/docker.sock:/var/run/docker.sock \
    mesoscloud/mesos-slave:0.28.1-centos-7

    docker run -d --restart always --name slave2 --privileged --network zookeeper --ip 172.18.1.13 \
    -e MESOS_HOSTNAME=172.18.1.13 \
    -e MESOS_IP=172.18.1.13 \
    -e MESOS_MASTER=zk://172.18.1.1:2181,172.18.1.2:2181,172.18.1.3:2181/mesos/my_mesos \
    -v /sys/fs/cgroup:/sys/fs/cgroup \
    -v /var/run/docker.sock:/var/run/docker.sock \
    mesoscloud/mesos-slave:0.28.1-centos-7
# **测试**
以下测试不全面, 只提供参考

## 测试zookeeper
* 进去每个容器内, 使用echo stat|nc ip:2181获取zookeeper状态信息, 都有正确的信息返回, 说明集群正常
* 在vmware内使用zookeeper的客户端访问zk_proxy, 比如用./zkCli.sh -verser 192.168.5.21:2181连接zookeeper, 连接之后能正常操作命令表明一切正常. 命令无法操作表明zookeeper有2个或者全部down了. 命令操作有一定概率卡顿表明zookeeper有一个down了.

## 测试mesos
* 进入每个容器内, 使用cul http://ip:5050命令, 都有网页信息返回, 说明集群正常
* mesos_proxy中的haproxy.cfg文件配置中的服务，只能是mesos集群中的leader. 然后在windows上用浏览器访问192.168.5.21:5050, 有mesos界面出来表明代理正常

## 测试marathon
* 进入每个容器内, 使用cul http://ip:8080命令, 都有网页信息返回, 说明集群正常
* 在windows上用浏览器访问192.168.5.21:8080, 有marathon界面出来表明代理正常

# **故障排查**
* 外网访问mesos的代理不通  
理论上轮询访问后端服务是没有问题的, 但是master有自己的leader, 只将master中的leader提供用户访问。解决方法: (1)做个服务发现,调用master接口以便获取到leader的ip和port,然后配置到haproxy的配置文件中; (2)手动将leader的ip和port配置到haproxy中.
* 主机与容器的网络不通  
创建docke网络和容器之后,发现主机与容器的网络不通,从返回的信息来看,是我创建的网络网关172.18.1.254到容器ip不通.删除网络重新创建,问题依旧.再次删除网络,使用ip addr发现以前的网桥还在,可是docker network ls查看已经不存在了.没办法重启主机试试看，重启之后恢复正常.
* slave容器起不起来   
有个库文件不存在,从其他主机上拷贝过来就ok了
* marathon启动的应用,健康检查不通过   
marathon健康检查检测的是 主机名+端口,其中主机名就是slave向marathon注册的MESOS_HOSTNAME参数,端口是docker代理的端口,因此这里marathon检查的是(172.18.1.12:端口).
实际上slave调用主机docke.sock启动容器时,做docker代理是用的主机ip,而主机的ip是192.168.5.21,因此正确的代理是(192.168.5.21:端口).明显与marathon检测的不一样,将slave里的MESOS_HOSTNAME参数改成主机ip地址192.168.5.21,就ok了.
