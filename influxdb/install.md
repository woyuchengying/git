## 参考文档
    https://github.com/xwisen/ltw/issues/26
    https://github.com/xwisen/ltw/issues/30
## 安装influxdb
    下载页面:https://portal.influxdata.com/downloads
    tar zxvf influxdb-1.2.4_linux_amd64.tar.gz -C /usr/local/ && mv /usr/local/influxdb-1.2.4-1 /usr/local/influxdb
#### vi /usr/local/influxdb/etc/influxdb/influxdb.conf
    [meta]
    dir = "/var/lib/influxdb/meta"
    [data]
    dir = "/var/lib/influxdb/data"
    wal-dir = "/var/lib/influxdb/wal"
    trace-logging-enabled = true
    query-log-enabled = true
    max-series-per-database = 0
    max-values-per-tag = 0
    [coordinator]
    [retention]
    [shard-precreation]
    [monitor]
    [admin]
    enabled = true
    bind-address = ":8083"
    https-enabled = false
    [http]
    log-enabled = true
    write-tracing = false
    [subscriber]
    [[graphite]]
    [[collectd]]
    [[opentsdb]]
    [[udp]]
    [continuous_queries]
    log-enabled = true
#### vi start_influxdb.sh
    nohup /usr/local/influxdb/usr/bin/influxd run -config /usr/local/influxdb/etc/influxdb/influxdb.conf &
#### 测试,两台主机配置一样
    sh start_influxdb.sh    启动
    访问并且创建数据库test:
    http://20.26.25.115:8083/  
    http://20.26.25.116:8083/   
## 安装influxdb-relay
    yum -y install go
    export GOPATH=/usr/local/go
    go get -u -v github.com/influxdata/influxdb-relay
    cp  $GOPATH/bin/influxdb-relay /usr/local/influxdb/
    cp  $GOPATH/src/github.com/influxdata/influxdb-relay/sample.toml /usr/local/influxdb/relay.toml
#### vi /usr/local/influxdb/relay.toml
    [[http]]
    name = "example-http"
    bind-addr = "0.0.0.0:9096"
    output = [
        { name="influxdb1", location = "http://20.26.25.115:8086/write",timeout="10s",buffer-size-mb=256,max-batch-kb=256,max-delay-interval="500ms" },
        { name="influxdb2", location = "http://20.26.25.116:8086/write",timeout="10s",buffer-size-mb=256,max-batch-kb=256,max-delay-interval="500ms" },
    ]

    [[udp]]
    name = "example-udp"
    bind-addr = "0.0.0.0:9096"
    read-buffer = 0 # default
    output = [
        { name="influxdb1", location="20.26.25.115:8089", mtu=512 },
        { name="influxdb2", location="20.26.25.116:8089", mtu=1024 },
    ]
#### vi start_influxdb_relay.sh
    nohup /usr/local/influxdb/influxdb-relay -config /usr/local/influxdb/relay.toml &
#### 测试,两台主机配置一样
    sh start_influxdb_relay.sh
    curl -i -XPOST 'http://20.26.25.115:9096/write?db=test' --data-binary 'cpu_load_short,host=server11,region=us-west value=0.64'
    curl -i -XPOST 'http://20.26.25.116:9096/write?db=test' --data-binary 'cpu_load_short,host=influxdb11,region=yaolisong value=0.55'
    访问influxdb页面,查询两个influxdb数据库相关数据是否一致:
    http://20.26.25.115:8083/ 以及 http://20.26.25.116:8086/ 
    select * from cpu_load_short
## 安装配置keepalived
    yum install -y keepalived
    echo "curl http://20.26.25.115:8086/ping" >> /etc/keepalived/chk_influxd115.sh
    echo "curl http://20.26.25.116:8086/ping" >> /etc/keepalived/chk_influxd116.sh
### 配置节点一
#### vi /etc/keepalived/keepalived.conf
    vrrp_script chk_influxd115 {
            script "/etc/keepalived/chk_influxd115.sh"    #服务探测，返回0说明服务是正常的
            interval 1    #每隔1秒探测一次
            weight -2      #权重
    }
    vrrp_script chk_influxd116 {
            script "/etc/keepalived/chk_influxd116.sh"    #服务探测，返回0说明服务是正常的
            interval 1    #每隔1秒探测一次
            weight -2      #权重
    }
    # 第一个实例
    vrrp_instance VI_1 {
        state MASTER
        interface eno16777984	#使用的网卡名称
        virtual_router_id 100    #虚拟路由id，处于同一keepalived必须保证一致
        garp_master_delay 1
        priority 100	#优先级，越大越优先
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 123456
        }
    #
        virtual_ipaddress {
        20.26.25.240/24 dev eno16777984    #虚IP
        }
        track_interface {
            eno16777984
        }
    #
        track_script {        #脚本追踪
            chk_influxd115
        }
    }

    #第二个实例
    vrrp_instance VI_2 {
        state BACKUP
        interface eno16777984	#使用的网卡名称
        virtual_router_id 200    #虚拟路由id，处于同一keepalived必须保证一致
        garp_master_delay 1
        priority 99	#优先级，越大越优先
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 123456
        }
    #
        virtual_ipaddress {
            20.26.25.241/24 dev eno16777984    #虚IP
        }
        track_interface {
            eno16777984
        }
    #
        track_script {        #脚本追踪
            chk_influxd115
        }
    }
### 配置节点二
#### vi /etc/keepalived/keepalived.conf
    vrrp_script chk_influxd115 {
            script "/etc/keepalived/chk_influxd115.sh"    #服务探测，返回0说明服务是正常的
            interval 1    #每隔1秒探测一次
            weight -2      #权重
    }
    vrrp_script chk_influxd116 {
            script "/etc/keepalived/chk_influxd116.sh"    #服务探测，返回0说明服务是正常的
            interval 1    #每隔1秒探测一次
            weight -2      #权重
    }
    # 第一个实例
    vrrp_instance VI_1 {
        state BACKUP
        interface eno16777984	#使用的网卡名称
        virtual_router_id 100    #虚拟路由id，处于同一keepalived必须保证一致
        garp_master_delay 1
        priority 99	#优先级，越大越优先
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 123456
        }
    #
        virtual_ipaddress {
            20.26.25.240/24 dev eno16777984    #虚IP
        }
        track_interface {
            eno16777984
        }
    #
        track_script {        #脚本追踪
            chk_influxd116
        }
    }

    #第二个实例
    vrrp_instance VI_2 {
        state MASTER
        interface eno16777984	#使用的网卡名称
        virtual_router_id 200    #虚拟路由id，处于同一keepalived必须保证一致
        garp_master_delay 1
        priority 100	#优先级，越大越优先
        advert_int 1
        authentication {
            auth_type PASS
            auth_pass 123456
        }
    #
        virtual_ipaddress {
            20.26.25.241/24 dev eno16777984    #虚IP
        }
        track_interface {
            eno16777984
        }
    #
        track_script {        #脚本追踪
            chk_influxd116
        }
    }