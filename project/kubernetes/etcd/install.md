#### 制作etcd镜像
    wget https://github.com/coreos/etcd/archive/v3.2.2.tar.gz && tar zxvf v3.2.2.tar.gz && cd etcd-3.2.2
    docker build -t 192.168.25.188:80/dcos/etcd:v3.2.2 .
#### 同步3台节点主机的时间,以免etcd集群节点不断出现以下告警
    rafthttp: the clock difference against peer xxxxxx
#### vi start_etcd.sh (my-etcd-1节点配置,其余俩节点参照此配置)
    -d \
    --net=host \
    -p 2379:2379 \
    -p 2380:2380 \
    --name etcd-v3.2.2 \
    --volume=/data/etcd-data:/etcd-data \
    -e TZ=Asia/Shanghai \
    192.168.25.188:80/dcos/etcd:v3.2.2  \
    --name my-etcd-1 \
    --data-dir /etcd-data \
    --listen-client-urls http://192.168.25.114:2379 \
    --advertise-client-urls http://192.168.25.114:2379 \
    --listen-peer-urls http://192.168.25.114:2380 \
    --initial-advertise-peer-urls http://192.168.25.114:2380 \
    --initial-cluster my-etcd-1=http://192.168.25.114:2380,my-etcd-2=http://192.168.25.115:2380,my-etcd-3=http://192.168.25.116:2380 \
    --initial-cluster-token my-etcd-token \
    --initial-cluster-state new \
    --auto-compaction-retention 1
#### 下载客户端etcdctl二进制文件
    wget https://github.com/coreos/etcd/releases/download/v3.2.2/etcd-v3.2.2-linux-amd64.tar.gz && tar zxvf etcd-v3.2.2-linux-amd64.tar.gz && cd etcd-v3.2.2-linux-amd64
#### 测试
    ./etcdctl --endpoints http://192.168.25.114:2379,http://192.168.25.115:2379,http://192.168.25.116:2379 set /test/etcd/name yaolisong
    ./etcdctl --endpoints http://192.168.25.114:2379,http://192.168.25.115:2379,http://192.168.25.116:2379 ls /test/etcd
    /test/etcd/name
    ./etcdctl --endpoints http://192.168.25.114:2379,http://192.168.25.115:2379,http://192.168.25.116:2379 get /test/etcd/name
    yaolisong
    curl http://192.168.25.114:2379/v2/keys/test/etcd/name
    {"action":"get","node":{"key":"/test/etcd/name","value":"yaolisong","modifiedIndex":12,"createdIndex":12}}