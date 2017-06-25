## 参考文档
    https://segmentfault.com/a/1190000009550668
    http://udn.yyuap.com/doc/logstash-best-practice-cn/get_start/install.html
## Prerequisites
    yum -y install java-1.8.0-openjdk-headless.x86_64
## Install MongoDB
vi /etc/yum.repos.d/mongodb-org-3.2.repo  
    [mongodb-org-3.2]
    name=MongoDB Repository
    baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/
    gpgcheck=1
    enabled=1
    gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
开机自起
    chkconfig --add mongod
    systemctl daemon-reload
    systemctl enable mongod.service
    systemctl start mongod.service
## Install Elasticsearch
vi /etc/yum.repos.d/elasticsearch.repo  
    [elasticsearch-2.x]
    name=Elasticsearch repository for 2.x packages
    baseurl=https://packages.elastic.co/elasticsearch/2.x/centos
    gpgcheck=1
    gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
    enabled=1

开机自起
    chkconfig --add elasticsearch
    systemctl daemon-reload
    systemctl enable elasticsearch.service
    systemctl restart elasticsearch.service
## Install Graylog
    rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-2.2-repository_latest.rpm
    yum -y install graylog-server
开机自起
    chkconfig --add graylog-server
    systemctl daemon-reload
    systemctl enable graylog-server.service
    systemctl start graylog-server.service
## 配置
vi /etc/mongod.conf  
    bindIp: 127.0.0.1 改成 bindIp: 0.0.0.0
vi /etc/elasticsearch/elasticsearch.yml 其他2台只需修改node.name,network.host  
    cluster.name: zmcc
    node.name: node1
    bootstrap.memory_lock: true
    network.host: 20.26.25.114
    discovery.zen.ping.unicast.hosts: ["20.26.25.114", "20.26.25.115","20.26.25.116"]
    discovery.zen.minimum_master_nodes: 1
测试elasticsearch
    http://20.26.25.114:9200/_cluster/health?pretty=true
#### 创建root_password_sha2
    yum install pwgen -y
    pwgen -N 1 -s 96
        O7EgvdkiwBA1GpSmtBoXH2d1kbXeYS5uNatihwG1t3kzo5PlBy97riywua6Q2SHIJwhGL5uV7gK8ovLTx76izLKvftNJjWSh
    echo -n admin | sha256sum
        8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918 -
vi /etc/graylog/server/server.conf 其他主机server.conf中is_master = false  
    is_master = true
    node_id_file = /etc/graylog/server/node-id
    password_secret = VfjfxoqopSIKGq5kdcp5uSsDaUKEkIlfz82s96XjCeD9K8H0vamK2dZiPU9Kke7L
    root_password_sha2 = 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
    root_timezone = Asia/Shanghai 
    plugin_dir = /usr/share/graylog-server/plugin
    rest_listen_uri = http://20.26.25.114:12900/
    rest_transport_uri = http://20.26.25.114:12900/
    web_enable = true
    web_listen_uri = http://0.0.0.0:8080
    web_enable_cors = true
    web_thread_pool_size = 32
    elasticsearch_max_docs_per_index = 20000000
    elasticsearch_max_size_per_index = 1073741824
    elasticsearch_max_time_per_index = 20d
    elasticsearch_max_time_per_index = 20d
    elasticsearch_max_number_of_indices = 200
    elasticsearch_max_number_of_indices = 200
    retention_strategy = delete
    elasticsearch_shards = 10
    elasticsearch_replicas = 0
    elasticsearch_index_prefix = graylog
    allow_leading_wildcard_searches = false
    allow_highlighting = true
    elasticsearch_cluster_name = zmcc
    elasticsearch_discovery_zen_ping_multicast_enabled = false
    elasticsearch_discovery_zen_ping_unicast_hosts = 20.26.25.114:9300,20.26.25.115:9300,20.26.25.116:9300
    elasticsearch_node_master = false
    elasticsearch_node_data = false
    elasticsearch_transport_tcp_port = 9350
    elasticsearch_http_enabled = false
    elasticsearch_discovery_zen_ping_multicast_enabled = false
    elasticsearch_network_host = 20.26.25.114
    elasticsearch_analyzer = standard
    output_batch_size = 500
    output_flush_interval = 1
    output_fault_count_threshold = 10
    output_fault_penalty_seconds = 30
    processbuffer_processors = 12
    outputbuffer_processors = 12
    outputbuffer_processor_keep_alive_time = 6000
    outputbuffer_processor_threads_core_pool_size = 10
    outputbuffer_processor_threads_max_pool_size = 30
    processor_wait_strategy = blocking
    ring_size = 131072
    inputbuffer_ring_size = 131072
    inputbuffer_processors = 6
    inputbuffer_wait_strategy = blocking
    message_journal_enabled = false
    message_journal_dir = /var/lib/graylog-server/journal
    message_journal_max_age = 12h
    message_journal_max_size = 100gb
    lb_recognition_period_seconds = 3
    stream_processing_timeout = 20000
    stream_processing_max_faults = 6
    mongodb_uri = mongodb://20.26.25.114:27017/graylog
    mongodb_max_connections = 1000
    mongodb_threads_allowed_to_block_multiplier =50
    http_connect_timeout = 50s
    http_read_timeout = 50s
    http_write_timeout = 50s
    content_packs_dir = /usr/share/graylog-server/contentpacks
    content_packs_auto_load = grok-patterns.json

## 访问
    http://20.26.25.114:8080/
    graylogweb界面配置input,选择udp
## 配置主机logstash
    wget https://download.elasticsearch.org/logstash/logstash/logstash-2.1.0.tar.gz && tar zxvf logstash-2.1.0.tar.gz -C /opt/
vi /etc/logstash/conf.d/devops.conf  
    input {
        heartbeat {
            interval => 10
            type => "heartbeat"
        }

        file {
            type => "devops"
            path => ["/data/logs/*/*.log","/data/logs/*/*.out"]
            sincedb_path => "/opt/logstash/.devops.sincedb"
            codec => multiline {
                pattern => "^\[|^\(|^\<"
                negate => true
                what => previous
                charset => "GB18030"
            }
        }
    }

    output {
        gelf {
            host => "20.26.25.114"
            port => "12201"
            facility => "%{type}"
        }
    }
vi start_logstash.sh  
    nohup /opt/logstash/bin/logstash -f /etc/logstash/conf.d/devops.conf  &>/dev/null &
    nohup /opt/logstash/bin/logstash -f /etc/logstash/conf.d/  &>/dev/null &