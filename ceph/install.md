## 参考文档
    http://www.cnblogs.com/pycode/p/6494853.html
    http://blog.csdn.net/je930502/article/details/50812014
## Install ceph
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#### vim /etc/yum.repos.d/ceph.repo
    [Ceph]
    name=Ceph packages for $basearch
    baseurl=http://download.ceph.com/rpm-jewel/el7/$basearch
    enabled=1
    gpgcheck=1
    type=rpm-md
    gpgkey=https://download.ceph.com/keys/release.asc
    priority=1

    [Ceph-noarch]
    name=Ceph noarch packages
    baseurl=http://download.ceph.com/rpm-jewel/el7/noarch
    enabled=1
    gpgcheck=1
    type=rpm-md
    gpgkey=https://download.ceph.com/keys/release.asc
    priority=1

    [ceph-source]
    name=Ceph source packages
    baseurl=http://download.ceph.com/rpm-jewel/el7/SRPMS
    enabled=1
    gpgcheck=1
    type=rpm-md
    gpgkey=https://download.ceph.com/keys/release.asc
    priority=1
#### 安装ceph
    yum update
    yum info ceph
    yum -y install ceph-10.2.7-0.el7.x86_64
    mkdir /data/ceph/osd0  其他主机目录为/data/ceph/osd1
    chown -R ceph:ceph /data/ceph
#### 管理节点安装ceph-deploy
    yum install -y ceph-deploy
    mkdir /root/ceph && cd /root/ceph 创建工作目录
    ceph-deploy new csv-dcos36 csv-dcos37 csv-dcos38
    
#### vi /root/ceph.conf
    [global]
    fsid = c5836faa-1dca-4de5-8671-9a7a49559571
    mon_initial_members = csv-dcos36, csv-dcos37, csv-dcos38
    mon_host = 20.26.25.114,20.26.25.115,20.26.25.116
    auth_cluster_required = cephx
    auth_service_required = cephx
    auth_client_required = cephx
    [osd]
    filestore_xattr_use_omap = true
    osd_max_object_name_len = 256
    osd_max_object_namespace_len = 64
#### 同步配置
    ceph-deploy mon create-initial
    ceph-deploy admin csv-dcos36  csv-dcos37 csv-dcos38 
    ceph-deploy osd prepare csv-dcos36:/data/ceph/osd0 csv-dcos37:/data/ceph/osd1 csv-dcos38:/data/ceph/osd2
    ceph-deploy osd activate csv-dcos36:/data/ceph/osd0 csv-dcos37:/data/ceph/osd1 csv-dcos38:/data/ceph/osd2
    ceph -w  有active+clean字段可说明是正常
        2017-07-07 15:44:20.789556 mon.0 [INF] pgmap v1289: 64 pgs: 64 active+clean; 0 bytes data, 37190 MB used, 48471 MB / 90317 MB avail
#### 
## Insatll Inkscope
