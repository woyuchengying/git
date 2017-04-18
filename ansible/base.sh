1.配置代理
ansible center-slave -m shell -a "echo 'export http_proxy=http://proxy.zj.chinamobile.com:8080
export https_proxy=http://proxy.zj.chinamobile.com:8080
export ftp_proxy=http://proxy.zj.chinamobile.com:8080' >> /root/.bashrc"

ansible center-slave -m shell -a "source /root/.bashrc"
2.下载ncat
ansible center-slave -m get_url -a "url=https://nmap.org/dist/ncat-7.40-1.x86_64.rpm use_proxy=yes dest=/root/package_dir/"
3.卸载nc
ansible center-slave -m yum -a "name=nc  state=absent"
4.安装ncat，查看状态, 测试端口连通性
ansible center-slave -m yum -a "name=/root/package_dir/ncat-7.40-1.x86_64.rpm state=present"
ansible center-slave -m shell -a "ncat --version"
ansible center-slave -m shell -a "ncat -z -v 20.26.25.187 80"
