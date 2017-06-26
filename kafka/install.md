## 参考文档
    http://www.cnblogs.com/wangyangliuping/p/5546465.html
    http://blog.csdn.net/lizhitao/article/details/25667831
## Install zookeeper
    docker run -d --restart always --name zk1  --net=host -e ZOO_MY_ID=1 -e ZOO_SERVERS="server.1=192.168.25.114:2888:3888 server.2=192.168.25.115:2888:3888 server.3=192.168.25.116:2888:3888" 192.168.25.188:80/dcos/zookeeper
    docker run -d --restart always --name zk1  --net=host -e ZOO_MY_ID=2 -e ZOO_SERVERS="server.1=192.168.25.114:2888:3888 server.2=192.168.25.115:2888:3888 server.3=192.168.25.116:2888:3888" 192.168.25.188:80/dcos/zookeeper
    docker run -d --restart always --name zk1  --net=host -e ZOO_MY_ID=3 -e ZOO_SERVERS="server.1=192.168.25.114:2888:3888 server.2=192.168.25.115:2888:3888 server.3=192.168.25.116:2888:3888" 192.168.25.188:80/dcos/zookeeper
## Install kafka
    yum -y install java-1.8.0
    wget https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/0.10.0.1/kafka_2.10-0.10.0.1.tgz && tar zxvf kafka_2.10-0.10.0.1.tgz -C /usr/local && mv /usr/local/kafka_2.10-0.10.0.1 /usr/local
#### vi /usr/local/kafka/config/server.properties 修改,其他两台分别为broker.id=2,broker.id=3
    broker.id=1
    zookeeper.connect=192.168.25.114:2181,192.168.25.115:2181,192.168.25.116:2181/kafka01
#### 启动服务
    /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &
#### 测试
    /usr/local/kafka/bin/kafka-console-producer.sh --broker-list 192.168.25.115:9092 --topic test
    /usr/local/kafka/bin/kafka-console-consumer.sh --zookeeper 192.168.25.115:2181/kafka01 --topic test --from-beginning
    /usr/local/kafka/bin/kafka-topics.sh --create --topic topic_1 --partitions 1 --replication-factor 3  --zookeeper 192.168.25.115:2181/kafka01
    /usr/local/kafka/bin/kafka-topics.sh --create --topic topic_2 --partitions 1 --replication-factor 3  --zookeeper 192.168.25.116:2181/kafka01
    /usr/local/kafka/bin/kafka-topics.sh --create --topic topic_3 --partitions 1 --replication-factor 3  --zookeeper 192.168.25.114:2181/kafka01
    /usr/local/kafka/bin/kafka-topics.sh --describe --zookeeper localhost:2181/kafka01
## Install kafka-manager
    wget https://github.com/yahoo/kafka-manager/archive/1.3.3.7.tar.gz && tar zxvf 1.3.3.7.tar.gz -C /root
    wget http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz && tar zxvf jdk-8u131-linux-x64.tar.gz -C /opt
    /root/kafka-manager-1.3.3.7/sbt -java-home /opt/jdk1.8.0_131 clean dist
    cd /root/kafka-manager-1.3.3.7/target/universal && unzip kafka-manager-1.3.3.7.zip && mv kafka-manager-1.3.3.7 /usr/local/kafka-manager
    nohup /usr/local/kafka-manager/bin/kafka-manager -Dconfig.file=/usr/local/kafka-manager/conf/application.conf -Dhttp.port=9090 &
#### 访问
    http://ip:9090