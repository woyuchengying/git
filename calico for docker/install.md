## 对docker.service配置文件添加配置
    --cluster-store=etcd://20.26.25.11:2379
## 下载镜像并启动
    docker pull quay.io/calico/node:latest && docker tag quay.io/calico/node:latest 20.26.25.188:80/calico/node:latest
    cat > /etc/calico/calicoctl.cfg << EOF
    apiVersion: v1
    kind: calicoApiConfig
    metadata:
    spec:
    datastoreType: "etcdv2"
    etcdEndpoints: "http://192.168.5.21:2379"
    EOF
    ETCD_ENDPOINTS=http://20.26.25.11:2379 calicoctl node run --ip 20.26.25.114 --node-image=20.26.25.188:80/calico/node:latest
    ETCD_ENDPOINTS=http://20.26.25.11:2379 calicoctl node status
    cat << EOF | ETCD_ENDPOINTS=http://20.26.25.11:2379 calicoctl create -f -
    apiVersion: v1
    kind: ipPool
    metadata:
        cidr: 10.20.10.0/24
    spec:
        ipip:
            enabled: true
        nat-outgoing: true
        disabled: false
    EOF
    cat << EOF | ETCD_ENDPOINTS=http://20.26.25.11:2379 calicoctl create -f -
    apiVersion: v1
    kind: ipPool
    metadata:
        cidr: 10.20.20.0/24
    spec:
        ipip:
            enabled: true
        nat-outgoing: true
        disabled: false
    EOF
    ETCD_ENDPOINTS=http://192.168.5.21:2379 calicoctl get ipPool  -o yaml
## 创建网络并查看
    docker network create --driver calico --ipam-driver calico-ipam  --subnet 10.20.10.0/24 10_net1
    docker network create --driver calico --ipam-driver calico-ipam  --subnet 10.20.10.0/24 10_net2
    docker network create --driver calico --ipam-driver calico-ipam  --subnet 10.20.20.0/24 20_net1
    docker network create --driver calico --ipam-driver calico-ipam  --subnet 10.20.20.0/24 20_net2
    docker network ls
    calicoctl get profile -o yaml
## 配置calico profile,vi profile.yaml
    - apiVersion: v1
    kind: profile
    metadata:
        name: 10_net1
        tags:
        - 10_net1
    spec:
        egress:
        - action: allow
        destination: {}
        source: {}
        ingress:
        - action: allow
        destination: {}
        source:
            tag: 10_net1
        - action: allow
        destination: {}
        source:
            tag: 10_net2
        - action: allow
        destination: {}
        source:
            tag: 20_net1
        - action: allow
        destination: {}
        source:
            tag: 20_net2
    - apiVersion: v1
    kind: profile
    metadata:
        name: 10_net2
        tags:
        - 10_net2
    spec:
        egress:
        - action: allow
        destination: {}
        source: {}
        ingress:
        - action: allow
        destination: {}
        source:
            tag: 10_net2
        - action: allow
        destination: {}
        source:
            tag: 10_net1
        - action: allow
        destination: {}
        source:
            tag: 20_net2
        - action: allow
        destination: {}
        source:
            tag: 20_net1
    - apiVersion: v1
    kind: profile
    metadata:
        name: 20_net1
        tags:
        - 20_net1
    spec:
        egress:
        - action: allow
        destination: {}
        source: {}
        ingress:
        - action: allow
        destination: {}
        source:
            tag: 20_net1
        - action: allow
        destination: {}
        source:
            tag: 20_net2
        - action: allow
        destination: {}
        source:
            tag: 10_net1
        - action: allow
        destination: {}
        source:
            tag: 10_net2
    - apiVersion: v1
    kind: profile
    metadata:
        name: 20_net2
        tags:
        - 20_net2
    spec:
        egress:
        - action: allow
        destination: {}
        source: {}
        ingress:
        - action: allow
        destination: {}
        source:
            tag: 20_net2
        - action: allow
        destination: {}
        source:
            tag: 20_net1
        - action: allow
        destination: {}
        source:
            tag: 10_net2
        - action: allow
        destination: {}
        source:
            tag: 10_net1
## 启动容器
    calicoctl create -f profile.yaml
    calicoctl get profile  -o yaml
    docker run -itd --net=10_net1 --ip=10.20.10.51 --name=centos-1  centos
    docker run -itd --net=10_net2 --ip=10.20.10.52 --name=centos-2  centos
    docker run -itd --net=20_net1 --ip=10.20.20.51 --name=centos-3  centos
    docker run -itd --net=20_net2 --ip=10.20.20.52 --name=centos-4  centos
## 测试容器之间网络是否互联互通
    经测试,容器之间网络是互联互通的