# 部署在主机
## 1)安装
    wget https://github.com/mesosphere/marathon/archive/v1.1.1.tar.gz
    tar zxvf v1.1.1.tar.gz -C /opt/ && mv /opt/marathon-1.1.1 /opt/marathon
## 2)启动
    /opt/marathon/bin/start --framework_name dcos --http_realm ZJ-DCOS --master zk://20.26.25.11:2181,20.26.25.12:2181,20.26.25.13:2181/mesos --http_credentials dcosadmin:zjdcos01 --event_subscriber http_callback --zk zk://20.26.25.11:2181,20.26.25.12:2181,20.26.25.13:2181/dcos --http_port 8081
## 3)测试
    ps -axf|grep marathon
    http://ip:8081

# 安装在docker
## 1)制作镜像
    docker run -d --net=host centos:latest tail -f /etc/hosts
    运行完毕会打印出 容器id
    docker exec -ti 3cb45c16e92f（容器id） bash
    进入容器完毕
    wget https://github.com/mesosphere/marathon/archive/v1.1.1.tar.gz
    tar zxvf v1.1.1.tar.gz -C /opt/ && mv /opt/marathon-1.1.1 /opt/marathon
    mkdir -p /app/logs /app/bin && cd /app/bin/ && wget --ftp-user=joy --ftp-password=go2hell 10.70.41.126:/Temp/yls/tools/cronolog && chmod 755 cronolog
    vi startMarathon.sh
    exit
    退出容器完毕
    docker commit 3cb45c16e92f（容器id） 20.26.25.10:5000/marathon_dcos:5.1
### 编辑/app/bin/startMarathon.sh文件
    /opt/marathon/bin/start --framework_name dcos --http_realm ZJ-DCOS --master zk://20.26.25.11:2181,20.26.25.12:2181,20.26.25.13:2181/mesos --http_credentials dcosadmin:zjdcos01 --event_subscriber http_callback --zk zk://20.26.25.11:2181,20.26.25.12:2181,20.26.25.13:2181/dcos --http_port 8081 | /app/bin/cronolog -k 7 /app/logs/${APPNAME}-%Y%m%d.log &
    tail -f /etc/hosts
## 2)启动marathon容器
    docker run -d --restart=always --name=dcos-8081 -e APPNAME=dcosmarathon --net=host -v /data/logs/marathon:/app/logs:rw 20.26.25.10:5000/marathon_dcos:5.1 sh /app/bin/startMarathon.sh
## 3)测试
    ps -axf|grep marathon
    http://ip:8081



