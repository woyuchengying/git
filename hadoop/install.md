## 参考文档
    https://linux.cn/article-8695-1.html
    http://hadoop.apache.org/docs/r1.0.4/cn/
## 节点机器配置,并配置好hadoop用户ssh互信
    20.26.25.114 centos7.0 csv-dcos36(namenode)
    20.26.25.115 centos7.0 csv-dcos37(datanode1)
    20.26.25.116 centos7.0 csv-dcos38(datanode2)
## 软件版本
    hadoop  2.8.1
    jdk     Oracle JDK 1.8.0_131(非OpenJDK)
## Install jdk
    mkdir -p /usr/local/java && cd /usr/local/java
    wget http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
    tar -xvzf jdk-8u131-linux-x64.tar.gz
    echo "export JAVA_HOME=/usr/local/java/jdk1.8.0_131/" >> /etc/profile
    echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
    source /etc/profile
## 创建 hadoop 用户以及 hadoop 用户组
    groupadd hadoop
    useradd -m -g hadoop hadoop
    passwd hadoop
## 磁盘挂载(可选)
    mkdir /home/hadoop/hdfs
    mount /dev/sdb1 /home/hadoop/hdfs/
    chown -R  hadoop:hadoop /home/hadoop/hdfs/
    echo "/dev/sdb1 /home/hadoop/hdfs ext4 defaults 0 0" >> /etc/fstab
## Install hadoop
    cd /data
    wget https://mirrors.ustc.edu.cn/apache/hadoop/common/hadoop-2.8.1/hadoop-2.8.1.tar.gz
    tar -xvzf hadoop-2.8.1.tar.gz
    chown -R hadoop:hadoop hadoop-2.8.1
    su - hadoop 进入hadoop用户
    mkdir ~/config/
    cp -r /data/hadoop-2.8.1/etc/hadoop/ ~/config/
    vi ~/config/hadoop/hadoop-env.sh
        export JAVA_HOME=/usr/local/java/jdk1.8.0_131/
        export HADOOP_CONF_DIR=/home/hadoop/config/hadoop/
    exit 退出hadoop用户
    echo "export HADOOP_CONF_DIR=/home/hadoop/config/hadoop/" >> /etc/profile
## 配置配置文件
    su - hadoop
    echo "export HADOOP_LOG_DIR=~/log/hadoop" >> ~/config/hadoop/hadoop-env.sh
#### vi ~/config/hadoop/yarn-env.sh
    YARN_LOG_DIR="/home/hadoop/log/yarn/"
#### vi ~/config/hadoop/core-site.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <!-- Put site-specific property overrides in this file. -->
    <configuration>
        <property>
            <description>默认文件系统及端口</description> 
            <name>fs.defaultFS</name>
            <value>hdfs://csv-dcos36/</value>
            <final>true</final>
        </property>
    </configuration>
#### vi ~/config/hadoop/hdfs-site.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <!-- Put site-specific property overrides in this file. -->
    <configuration>
        <property>
            <description>namedoe 存储永久性的元数据目录列表</description> 
            <name>dfs.namenode.name.dir</name>
            <value>file:///home/hadoop/hdfs/name/</value>
            <final>true</final>
        </property>
        <property>
            <description>datanode 存放数据块的目录列表</description> 
            <name>dfs.datanode.data.dir</name>
            <value>file:///home/hadoop/hdfs/data/</value>
            <final>true</final>
        </property>
    </configuration>
#### vi ~/config/hadoop/mapred-site.xml
    <?xml version="1.0"?>
    <configuration>
        <property> 
            <description>MapReduce 执行框架设为 Hadoop YARN. </description> 
            <name>mapreduce.framework.name</name> 
            <value>yarn</value> 
        </property>
        <property> 
            <description>Map 和 Reduce 执行的比例，Map 执行到百分之几后开始 Reduce 作业</description> 
            <!-- 此处设为1.0 即为 完成 Map 作业后才开始 Reduce 作业，内存情况不够的可设为 1.0 默认值为 0.05 -->
            <name>mapreduce.job.reduce.slowstart.completedmaps</name> 
            <value>1.0</value> 
        </property>
    </configuration>
#### ~/config/hadoop/yarn-site.xml
    <?xml version="1.0"?>
    <configuration>
    <!-- Site specific YARN configuration properties -->
        <property> 
            <description>The address of the applications manager interface in the RM.</description> 
            <name>yarn.resourcemanager.address</name> 
            <value>csv-dcos36:8032</value> 
        </property> 
        <property> 
            <name>yarn.nodemanager.aux-services</name> 
            <value>mapreduce_shuffle</value> 
        </property> 
        <property> 
            <description>存储中间数据的本地目录</description>
            <name>yarn.nodemanager.local-dirs</name> 
            <value>/home/hadoop/nm-local-dir</value> 
            <final>true</final>
        </property> 
        <property> 
            <description>每个容器可在 RM 申请的最大内存</description>
            <name>yarn.scheduler.maximum-allocation-mb</name> 
            <value>2048</value> 
            <final>true</final>
        </property> 
        <property> 
            <description>每个容器可在 RM 申请的最小内存</description>
            <name>yarn.scheduler.minimum-allocation-mb</name> 
            <value>300</value> 
            <final>true</final>
        </property> 
        <property>
            <description>自动检测节点 CPU 与 Mem</description> 
            <name>yarn.nodemanager.resource.detect-hardware-capabilities</name> 
            <value>true</value> 
        </property> 
        <property> 
            <description>The address of the scheduler interface.</description> 
            <name>yarn.resourcemanager.scheduler.address</name> 
            <value>csv-dcos36:8030</value> 
        </property> 
        <property> 
            <description>The address of the RM web application.</description> 
            <name>yarn.resourcemanager.webapp.address</name> 
            <value>csv-dcos36:8088</value> 
        </property> 
        <property> 
            <description>The address of the resource tracker interface.</description> 
            <name>yarn.resourcemanager.resource-tracker.address</name> 
            <value>csv-dcos36:8031</value> 
        </property>
        <property>  
            <description>The hostname of the RM.</description>  
            <name>yarn.resourcemanager.hostname</name>  
            <value>csv-dcos36</value>  
        </property>
    </configuration>
#### vi ~/config/hadoop/slaves  
    csv-dcos36
    csv-dcos37
    csv-dcos38
## 优化 namenode 节点命令使用
    echo "export PATH=$PATH:/data/hadoop-2.8.1/bin/:/data/hadoop-2.8.1/sbin/" >> ~/.bash_profile
    source ~/.bash_profile
## 拷贝/home/hadoop/config/hadoop配置目录到其他节点对应目录下
    scp /home/hadoop/config/hadoop/ csv-dcos37:/home/hadoop/config/
    scp /home/hadoop/config/hadoop/ csv-dcos38:/home/hadoop/config/
## 启动集群及测试
    hadoop namenode -format
    start-dfs.sh 
    start-yarn.sh
## 集群总览
#### csv-dcos36
    http://20.26.25.114:50070
    http://20.26.25.114:8088
    http://20.26.25.114:8042
#### csv-dcos37
    http://20.26.25.115:50075
    http://20.26.25.115:8042
#### csv-dcos38
    http://20.26.25.116:50075
    http://20.26.25.116:8042
## 测试用例
    yarn jar /data/hadoop-2.8.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.1.jar randomwriter random-data
    访问http://20.26.25.114:8088,查看任务状态信息,如出现一下信息说明正常
    YarnApplicationState:	RUNNING: AM has registered with RM and started running.