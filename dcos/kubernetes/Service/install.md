# 部署在主机
## 1)下载
### 下载kubernetes,etcd,flannel软件包
    wget https://github.com/kubernetes/kubernetes/releases/download/v1.3.0/kubernetes.tar.gz
    tar zxvf kubernetes.tar.gz && tar zxvf kubernetes/server/kubernetes-server-linux-amd64.tar.gz && cp -r kubernetes/server/kubernetes/server/ /opt/kubernetes
    wget https://github.com/coreos/etcd/releases/download/v2.3.7/etcd-v2.3.7-linux-amd64.tar.gz
    tar zxvf etcd-v2.3.7-linux-amd64.tar.gz && cp etcd-v2.3.7-linux-amd64/etcd /opt/kubernetes/bin/etcd-v2.3.7 && cp etcd-v2.3.7-linux-amd64/etcdctl /opt/kubernetes/bin/etcdctl-v2.3.7
    wget https://github.com/coreos/flannel/releases/download/v0.5.5/flannel-0.5.5-linux-amd64.tar.gz
    tar zxvf flannel-0.5.5-linux-amd64.tar.gz && cp flannel-0.5.5/flanneld /opt/kubernetes/bin/flanneld-0.5.5
### 下载kubernetes/pause镜像
    docker pull kubernetes/pause
    docker tag docker.io/kubernetes/pause 20.26.25.187:5000/google_containers/pause:latest
### 下载registry镜像
    docker pull registry:2.2.0
    docker run -d -p 5000:5000 -v /data/registry_v2:/tmp/registry:rw registry:2.2.0
    docker push 20.26.25.187:5000/google_containers/pause:latest
### 下载dashboard镜像   
    1)docker pull index.tenxcloud.com/google_containers/kubernetes-dashboard-amd64:v1.1.0
    2)相关goole镜像下载地址 https://hub.tenxcloud.com/repos/
## 2)编辑启动文件
### 编辑etcd启动文件 /usr/lib/systemd/system/etcd.service 
    [Unit]
    Description=Etcd Server
    After=network.target
    [Service]
    Type=simple
    WorkingDirectory=
    # set GOMAXPROCS to number of processors
    ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /opt/kubernetes/bin/etcd-v2.3.7 -name kubernetes-master --listen-client-urls http://0.0.0.0:4001 --advertise-client-urls http://127.0.0.1:4001"
    [Install]
    WantedBy=multi-user.target
### 编辑apiserver启动文件 /usr/lib/systemd/system/kube-apiserver.service 
    [Unit]
    Description=Kubernetes API Server
    Documentation=https://github.com/kubernetes/kubernetes
    After=etcd.service
    Requires=etcd.service
    [Service]
    ExecStart=/opt/kubernetes/bin/kube-apiserver --logtostderr=true --insecure-bind-address=20.26.25.187 --insecure-port=8080 --bind-address=20.26.25.187 --secure-port=6443 --cors-allowed-origins=.* --etcd-servers=http://127.0.0.1:4001 --service-cluster-ip-range=10.168.0.0/16
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target
### 编辑scheduler启动文件 /usr/lib/systemd/system/kube-scheduler.service 
    [Unit]
    Description=Kubernetes Scheduler
    Documentation=https://github.com/kubernetes/kubernetes
    After=etcd.service
    Requires=etcd.service kube-apiserver.service
    [Service]
    ExecStart=/opt/kubernetes/bin/kube-scheduler --logtostderr=true --master=20.26.25.187:8080
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target
### 编辑controller-manager启动文件 /usr/lib/systemd/system/kube-controller-manager.service 
    [Unit]
    Description=Kubernetes Controller Manager
    Documentation=https://github.com/kubernetes/kubernetes
    After=etcd.service 
    Requires=etcd.service kube-apiserver.service
    [Service]
    ExecStart=/opt/kubernetes/bin/kube-controller-manager --logtostderr=true --master=20.26.25.187:8080 --cluster-name=dnt-k8s
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target
### 编辑proxy启动文件 /usr/lib/systemd/system/kube-proxy.service
    [Unit]
    Description=Kubernetes Proxy
    After=network.target
    [Service]
    ExecStart=/opt/kubernetes/bin/kube-proxy --logtostderr=true --master=http://20.26.25.187:8080
    Restart=on-failure
    [Install]
    WantedBy=multi-user.target
### 编辑kubelet启动文件 /usr/lib/systemd/system/kubelet.service
    [Unit]
    Description=Kubernetes Kubelet
    After=docker.service
    Requires=docker.service
    [Service]
    ExecStart=/opt/kubernetes/bin/kubelet --logtostderr=true --address=0.0.0.0 --port=10250  --cluster-dns=223.5.5.5 --cluster-domain=cluster.local --pod-infra-container-image=20.26.25.187:5000/google_containers/pause:latest --runtime-cgroups=/docker-daemon --api-servers=http://20.26.25.187:8080
    Restart=on-failure
    KillMode=process
    [Install]
    WantedBy=multi-user.target
### 编辑flannel启动文件 /usr/lib/systemd/system/flannel.service
    [Unit]
    Description=Flanneld overlay address etcd agent
    After=network.target
    Before=docker.service
    [Service]
    ExecStart=/opt/kubernetes/bin/flannel-0.5.5 --iface=eno16777984 --ip-masq --etcd-endpoints=http://20.26.25.187:4001 --etcd-prefix=/dnt/network
    Type=notify
    [Install]
    WantedBy=multi-user.target
    RequiredBy=docker.service
### 编辑docker启动文件 /usr/lib/systemd/system/docker.service
    添加 --bip 172.16.20.1/24 --ip-masq=false --mtu=1450 --insecure-registry="0.0.0.0/0"
## 3)启动
### 启动master
    systemctl start etcd
    systemctl start kube-apiserver
    systemctl start kube-scheduler
    systemctl start kube-controller-manager
### 启动slave
    systemctl start kube-proxy
    systemctl start kubelet
    systemctl start flannel
## 4)