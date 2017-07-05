# 部署在主机
## 1)安装
    rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
    yum -y install mesos-0.28.2
## 2)启动
### 启动master
    /usr/sbin/mesos-master --zk=zk://192.168.25.11:2181,192.168.25.12:2181,192.168.25.13:2181/mesos --port=5050 --log_dir=/var/log/mesos --cluster=zj-dcos01 --quorum=1 --work_dir=/var/lib/mesos
### 启动slave    
    /usr/sbin/mesos-slave --no-hostname_lookup --master=zk://192.168.25.11:2181,192.168.25.12:2181,192.168.25.13:2181/mesos --log_dir=/var/log/mesos --attributes=dcos:slave --containerizers=docker --docker_remove_delay=1days --port=5051 --work_dir=/var/lib/mesos
## 3)测试
    ps -axf|grep mesos
    http://master_ip:5050

# 部署在docker
## 1)制作镜像
    docker run -d --net=host centos:latest tail -f /etc/hosts
    运行完毕会打印出 容器id
    docker exec -ti 3cb45c16e92f（容器id） bash
    进入容器完毕
    rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
    yum -y install mesos-0.28.2
    cd /etc/mesos-master/ && echo "zj-dcos01" > cluster && echo "1" > quorum && echo "/var/lib/mesos" > work_dir
    cd /etc/mesos_slave/ && echo "docker" > containerizers && echo "1days" > docker_remove_delay && echo "5051" > port && echo "/var/lib/mesos" > work_dir
    cd /etc/mesos/ && echo "zk://192.168.25.11:2181,192.168.25.12:2181,192.168.25.13:2181/mesos" > zk
    vi /usr/bin/mesos-init-wrapper
    exit
    退出容器完毕
    docker commit 3cb45c16e92f（容器id） 192.168.25.10:5000/mesos:1.4
## 2)启动mesos容器
### 启动master
    docker run -d --net=host -v /data/logs/mesos:/var/log/mesos:rw 192.168.25.10:5000/mesos:1.4 /usr/bin/mesos-init-wrapper master
### 启动slave
    docker run -d --restart=on-failure:10 -e MESOS_CLS=dcos:slave -v /lib64/libdevmapper.so.1.02:/lib64/libdevmapper.so.1.02:ro -v /lib64/libdevmapper-event.so.1.02:/lib64/libdevmapper-event.so.1.02:ro -v /usr/bin/docker:/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock --net=host 192.168.25.10:5000/mesos:1.4 /usr/bin/mesos-init-wrapper slave
#### 文件映射,安装doker时会添加或更新以下文件
    /lib64/libdevmapper.so.1.02            可选
    /lib64/libdevmapper-event.so.1.02      可选
    /usr/bin/docker                        必需
    /var/run/docker.sock                   必需
## 3)测试
    ps -axf|grep mesos
    http://master_ip:5050