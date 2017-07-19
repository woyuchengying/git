### 环境信息
    host:20.26.25.188(主),20.26.25.187(从)
    docker版本:1.12.5
    harbor:harbor-offline-installer-v1.1.0.tgz

### 安装部署
#### harbor:
    1.tar zxvf harbor-offline-installer-v1.1.0.tgz
    2.解压之后修改harbor.cfg文件：hostname = 20.26.25.187,db_password = 1qaz@WSX
    3.执行sh install.sh,安装之后/data/下有以下文件：ca_download  config  database  job_logs  logs  registry  secretkey
    4.登入http://20.26.25.187:80,账号/密码：admin/Harbor12345
### 主从复制策略
    主:20.26.25.188
    1.系统管理-->复制管理-->目标-->+目标,目标名配置成images_copy,目标URL配置成http://20.26.25.187,用户名配置成admin,密码配置成xxx.
    2.项目-->xxx(项目名)-->复制-->+复制规则,名称配置成xxx,描述配置成xxx,启用配置成开启
### 停止或启动
    docker-compose -f docker-compose.yml stop
    docker-compose -f docker-compose.yml up -d