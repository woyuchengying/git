1.下载ncat
ansible center-slave -m get_url -a "url=https://nmap.org/dist/ncat-7.40-1.x86_64.rpm use_proxy=yes dest=/root/package_dir/"
2.卸载nc
ansible center-slave -m yum -a "name=nc  state=absent"
3.安装ncat，查看状态, 测试端口连通性
ansible center-slave -m yum -a "name=/root/package_dir/ncat-7.40-1.x86_64.rpm state=present"
ansible center-slave -m shell -a "ncat --version"
ansible center-slave -m shell -a "ncat -z -v 192.168.25.187 80"
