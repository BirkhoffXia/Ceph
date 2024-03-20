##1、【规划配置服务器】
#实验配置
root@ceph-mon1:~# vim /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific bionic main

#Ubuntu 20.04配置源 但是本地实验使用 Ubuntu：18.04.5 也配置这个 - 实验配置
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
#deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
#deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
#deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
#deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific/ focal main

192.168.40.151 ceph-mon1.sheca.com ceph-mon1
192.168.40.152 ceph-mon2.sheca.com ceph-mon2
192.168.40.153 ceph-mon3.sheca.com ceph-mon3
192.168.40.154 ceph-mgr1.sheca.com ceph-mgr1
192.168.40.155 ceph-mgr2.sheca.com ceph-mgr2
192.168.40.156 ceph-node1.sheca.com ceph-node1
192.168.40.157 ceph-node2.sheca.com ceph-node2
192.168.40.158 ceph-node3.sheca.com ceph-node3
192.168.40.159 ceph-deploy.sheca.com ceph-deploy

Ubuntu 18.04.5
ceph-deploy：2.0.1
Ceph：16.2.15-pacific
##2、【配置时间同步-每个节点都要安装】
#vim /etc/ntp/ntp.conf
#server cn.pool.ntp.org iburst
timedatectl set-timezone Asia/Shanghai
##3、【安装软件-每个节点都要安装】
apt install -y apt-transport-https ca-certificates curl software-properties-common
##4、【添加清华源-每个节点都要安装】

#这个版本比较新 先不用 用下面的配置
#wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add -
#apt-add-repository 'deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-octopus/ buster main'
#apt update
wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add -
#echo "deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific/ bionic main" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific/ focal main" >> /etc/apt/sources.list	
apt update 
##5、【创建Ceph集群部署用户】
#为了安装考虑不要使用root-创建cephadm-并赋予sudo权限无密码登录
groupadd -r -g 2088 cephadmin && useradd -r -m -s /bin/bash -u 2088 -g 2088 cephadmin && echo cephadmin:sheca | chpasswd
echo "cephadmin ALL=(ALL)   NOPASSWD:ALL" >> /etc/sudoers
##6、【配置hosts-每台都要配置】
vim /etc/hosts
127.0.0.1       localhost
127.0.1.1       ceph-deploy.sheca.com   ceph-deploy

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
192.168.40.151 ceph-mon1.sheca.com ceph-mon1
192.168.40.152 ceph-mon2.sheca.com ceph-mon2
192.168.40.153 ceph-mon3.sheca.com ceph-mon3
192.168.40.154 ceph-mgr1.sheca.com ceph-mgr1
192.168.40.155 ceph-mgr2.sheca.com ceph-mgr2
192.168.40.156 ceph-node1.sheca.com ceph-node1
192.168.40.157 ceph-node2.sheca.com ceph-node2
192.168.40.158 ceph-node3.sheca.com ceph-node3
192.168.40.159 ceph-deploy.sheca.com ceph-deploy
##7、【配置互信-ceph-deploy节点】
root@ceph-deploy:~# su - cephadmin
cephadmin@ceph-deploy:~$ ssh-keygen
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-deploy.sheca.com
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-mon1.sheca.com
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-mon2.sheca.com
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-mon3.sheca.com
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-mgr1.sheca.com
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-mgr2.sheca.com
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-node1.sheca.com
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-node2.sheca.com
cephadmin@ceph-deploy:~$ ssh-copy-id ceph-node3.sheca.com
##8、【部署ceph-deploy工具】
cephadmin@ceph-deploy:~$ sudo apt-cache madison ceph-deploy
ceph-deploy | 2.0.1-0ubuntu1.1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-updates/universe amd64 Packages
ceph-deploy | 2.0.1-0ubuntu1.1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-updates/universe i386 Packages
ceph-deploy | 2.0.1-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal/universe amd64 Packages
ceph-deploy | 2.0.1-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal/universe i386 Packages
ceph-deploy | 2.0.1-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal/universe Sources
ceph-deploy | 2.0.1-0ubuntu1.1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-updates/universe Sources

root@ceph-deploy:~# apt-cache madison ceph-deploy
ceph-deploy | 2.0.1-0ubuntu1.1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-updates/universe amd64 Packages
ceph-deploy | 2.0.1-0ubuntu1.1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-updates/universe i386 Packages
ceph-deploy | 2.0.1-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal/universe amd64 Packages
ceph-deploy | 2.0.1-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal/universe i386 Packages

cephadmin@ceph-deploy:~$ sudo apt install -y ceph-deploy
cephadmin@ceph-deploy:~$ ceph-deploy --version
2.0.1
 ##9、【每个节点都要安装python2.7】
sudo apt install python2.7 -y
sudo ln -sv /usr/bin/python2.7 /usr/bin/python2
 ##10、【使用ceph-deploy 初始化Ceph集群配置】
root@ceph-deploy:~$ su - cephadmin
cephadmin@ceph-deploy:~$ mkdir ceph-cluster && cd ceph-cluster/
#如果初始化报错 请查看[报错1]注释解决办法-2024-03-08实验 可以成功生成不报错
#如果想要一下子将所有mon节点部署出来，我们可以执行
#ceph-deploy new --cluster-network 172.31.40.0/24 --public-network 192.168.40.0/24 mon01:ceph-mon1.sheca.com mon02:ceph-mon2.sheca.com mon03:ceph-mon3.sheca.com 
cephadmin@ceph-deploy:~$ ceph-deploy new --cluster-network 172.31.40.0/24 --public-network 192.168.40.0/24 ceph-mon1.sheca.com
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephadmin/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy new --cluster-network 172.31.40.0/24 --public-network 192.168.40.0/24 ceph-mon1.sheca.com
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  mon                           : ['ceph-mon1.sheca.com']
[ceph_deploy.cli][INFO  ]  ssh_copykey                   : True
[ceph_deploy.cli][INFO  ]  fsid                          : None
[ceph_deploy.cli][INFO  ]  cluster_network               : 172.31.40.0/24
[ceph_deploy.cli][INFO  ]  public_network                : 192.168.40.0/24
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7fbc057b9700>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  func                          : <function new at 0x7fbc057425e0>
[ceph_deploy.new][DEBUG ] Creating new cluster named ceph
[ceph_deploy.new][INFO  ] making sure passwordless SSH succeeds
[ceph-mon1.sheca.com][DEBUG ] connected to host: ceph-deploy.sheca.com
[ceph-mon1.sheca.com][INFO  ] Running command: ssh -CT -o BatchMode=yes ceph-mon1.sheca.com
[ceph-mon1.sheca.com][DEBUG ] connection detected need for sudo
[ceph-mon1.sheca.com][DEBUG ] connected to host: ceph-mon1.sheca.com
[ceph-mon1.sheca.com][INFO  ] Running command: sudo /bin/ip link show
[ceph-mon1.sheca.com][INFO  ] Running command: sudo /bin/ip addr show
[ceph-mon1.sheca.com][DEBUG ] IP addresses found: ['172.31.40.151', '192.168.40.151']
[ceph_deploy.new][DEBUG ] Resolving host ceph-mon1.sheca.com
[ceph_deploy.new][DEBUG ] Monitor ceph-mon1 at 192.168.40.151
[ceph_deploy.new][DEBUG ] Monitor initial members are ['ceph-mon1']
[ceph_deploy.new][DEBUG ] Monitor addrs are ['192.168.40.151']
[ceph_deploy.new][DEBUG ] Creating a random mon key...
[ceph_deploy.new][DEBUG ] Writing monitor keyring to ceph.mon.keyring...
[ceph_deploy.new][DEBUG ] Writing initial config to ceph.conf...

cephadmin@ceph-deploy:~/ceph-cluster$ ll
total 20
drwxrwxr-x 2 cephadmin cephadmin 4096 Mar  8 15:09 ./
drwxr-xr-x 6 cephadmin cephadmin 4096 Mar  8 15:09 ../
-rw-rw-r-- 1 cephadmin cephadmin  267 Mar  8 15:09 ceph.conf
-rw-rw-r-- 1 cephadmin cephadmin 3231 Mar  8 15:09 ceph-deploy-ceph.log
-rw------- 1 cephadmin cephadmin   73 Mar  8 15:09 ceph.mon.keyring

#ceph.conf 文件
cephadmin@ceph-deploy:~/ceph-cluster$ cat ceph.conf
[global]
fsid = f3cabe3c-8185-4331-bc57-0f98da896dea
public_network = 192.168.40.0/24
cluster_network = 172.31.40.0/24
mon_initial_members = ceph-mon1
mon_host = 192.168.40.151
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

#初始化node节点---no-adjust-repos #不修改已有的 apt 仓库源(默认会使用官方仓库) --nogpgcheck #不进行校验
#此过程会在指定的 ceph node 节点按照串行的方式逐个服务器安装 ceph-base,ceph-common 等组件包:
#ceph-mon、ceph-mds、ceph-osd、ceph-mgr、ceph-crash、ceph-radosgw、rbdmap、ceph等service
#时间会有点久
cephadmin@ceph-deploy:~/ceph-cluster$ ceph-deploy install --no-adjust-repos --nogpgcheck ceph-node1.sheca.com ceph-node2.sheca.com ceph-node3.sheca.com
 ##11、【初始化配置ceph-mon服务-先ceph-mon1】
#1.查询版本
cephadmin@ceph-mon1:~$ sudo apt-cache madison ceph-mon
  ceph-mon | 16.2.15-1focal | https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific focal/main amd64 Packages
  ceph-mon | 15.2.17-0ubuntu0.20.04.6 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-updates/main amd64 Packages
  ceph-mon | 15.2.17-0ubuntu0.20.04.6 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-security/main amd64 Packages
  ceph-mon | 15.2.1-0ubuntu1 | https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal/main amd64 Packages
#2.安装16.2.15 版本
cephadmin@ceph-mon1:~$ sudo apt install ceph-mon -y
cephadmin@ceph-mon1:~$ ceph-mon --version
ceph version 16.2.15 (618f440892089921c3e944a991122ddc44e60516) pacific (stable)
#3.使用ceph-deploy工具注册-将ceph-mon服务添加到Ceph集群,同时向所有节点同步配置
#为了避免因为认证方面导致通信失败，推荐使用 ceph-deploy --overwrite-conf mon create-initial
#ceph-deploy --overwrite-conf config push ceph-mon1 ceph-mon2 ceph-mon3
cephadmin@ceph-deploy:~$ cd ceph-cluster/
cephadmin@ceph-deploy:~$ ceph-deploy mon create-initial
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephadmin/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy mon create-initial
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  subcommand                    : create-initial
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7f9d3d80c850>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  func                          : <function mon at 0x7f9d3d7feee0>
[ceph_deploy.cli][INFO  ]  keyrings                      : None
[ceph_deploy.mon][DEBUG ] Deploying mon, cluster ceph hosts ceph-mon1
[ceph_deploy.mon][DEBUG ] detecting platform for host ceph-mon1 ...
[ceph_deploy.mon][INFO  ] distro info: ubuntu 18.04 bionic
[ceph-mon1][DEBUG ] determining if provided host has same hostname in remote
[ceph-mon1][DEBUG ] deploying mon to ceph-mon1
[ceph-mon1][DEBUG ] remote hostname: ceph-mon1
[ceph-mon1][DEBUG ] checking for done path: /var/lib/ceph/mon/ceph-ceph-mon1/done
[ceph-mon1][DEBUG ] done path does not exist: /var/lib/ceph/mon/ceph-ceph-mon1/done
[ceph-mon1][INFO  ] creating keyring file: /var/lib/ceph/tmp/ceph-ceph-mon1.mon.keyring
[ceph-mon1][INFO  ] Running command: sudo ceph-mon --cluster ceph --mkfs -i ceph-mon1 --keyring /var/lib/ceph/tmp/ceph-ceph-mon1.mon.keyring --setuser 64045 --setgroup 64045
[ceph-mon1][INFO  ] unlinking keyring file /var/lib/ceph/tmp/ceph-ceph-mon1.mon.keyring
[ceph-mon1][INFO  ] Running command: sudo systemctl enable ceph.target
[ceph-mon1][INFO  ] Running command: sudo systemctl enable ceph-mon@ceph-mon1
[ceph-mon1][WARNIN] Created symlink /etc/systemd/system/ceph-mon.target.wants/ceph-mon@ceph-mon1.service → /lib/systemd/system/ceph-mon@.service.
[ceph-mon1][INFO  ] Running command: sudo systemctl start ceph-mon@ceph-mon1
[ceph-mon1][INFO  ] Running command: sudo ceph --cluster=ceph --admin-daemon /var/run/ceph/ceph-mon.ceph-mon1.asok mon_status
[ceph-mon1][DEBUG ] ********************************************************************************
[ceph-mon1][DEBUG ] status for monitor: mon.ceph-mon1
[ceph-mon1][DEBUG ] {
[ceph-mon1][DEBUG ]   "election_epoch": 3,
[ceph-mon1][DEBUG ]   "extra_probe_peers": [],
[ceph-mon1][DEBUG ]   "feature_map": {
[ceph-mon1][DEBUG ]     "mon": [
[ceph-mon1][DEBUG ]       {
[ceph-mon1][DEBUG ]         "features": "0x3f01cfbdfffdffff",
[ceph-mon1][DEBUG ]         "num": 1,
[ceph-mon1][DEBUG ]         "release": "luminous"
[ceph-mon1][DEBUG ]       }
[ceph-mon1][DEBUG ]     ]
[ceph-mon1][DEBUG ]   },
[ceph-mon1][DEBUG ]   "features": {
[ceph-mon1][DEBUG ]     "quorum_con": "4540138314316775423",
[ceph-mon1][DEBUG ]     "quorum_mon": [
[ceph-mon1][DEBUG ]       "kraken",
[ceph-mon1][DEBUG ]       "luminous",
[ceph-mon1][DEBUG ]       "mimic",
[ceph-mon1][DEBUG ]       "osdmap-prune",
[ceph-mon1][DEBUG ]       "nautilus",
[ceph-mon1][DEBUG ]       "octopus",
[ceph-mon1][DEBUG ]       "pacific",
[ceph-mon1][DEBUG ]       "elector-pinging"
[ceph-mon1][DEBUG ]     ],
[ceph-mon1][DEBUG ]     "required_con": "2449958747317026820",
[ceph-mon1][DEBUG ]     "required_mon": [
[ceph-mon1][DEBUG ]       "kraken",
[ceph-mon1][DEBUG ]       "luminous",
[ceph-mon1][DEBUG ]       "mimic",
[ceph-mon1][DEBUG ]       "osdmap-prune",
[ceph-mon1][DEBUG ]       "nautilus",
[ceph-mon1][DEBUG ]       "octopus",
[ceph-mon1][DEBUG ]       "pacific",
[ceph-mon1][DEBUG ]       "elector-pinging"
[ceph-mon1][DEBUG ]     ]
[ceph-mon1][DEBUG ]   },
[ceph-mon1][DEBUG ]   "monmap": {
[ceph-mon1][DEBUG ]     "created": "2024-03-08T08:59:43.135997Z",
[ceph-mon1][DEBUG ]     "disallowed_leaders: ": "",
[ceph-mon1][DEBUG ]     "election_strategy": 1,
[ceph-mon1][DEBUG ]     "epoch": 1,
[ceph-mon1][DEBUG ]     "features": {
[ceph-mon1][DEBUG ]       "optional": [],
[ceph-mon1][DEBUG ]       "persistent": [
[ceph-mon1][DEBUG ]         "kraken",
[ceph-mon1][DEBUG ]         "luminous",
[ceph-mon1][DEBUG ]         "mimic",
[ceph-mon1][DEBUG ]         "osdmap-prune",
[ceph-mon1][DEBUG ]         "nautilus",
[ceph-mon1][DEBUG ]         "octopus",
[ceph-mon1][DEBUG ]         "pacific",
[ceph-mon1][DEBUG ]         "elector-pinging"
[ceph-mon1][DEBUG ]       ]
[ceph-mon1][DEBUG ]     },
[ceph-mon1][DEBUG ]     "fsid": "0d8fb726-ee6d-4aaf-aeca-54c68e2584af",
[ceph-mon1][DEBUG ]     "min_mon_release": 16,
[ceph-mon1][DEBUG ]     "min_mon_release_name": "pacific",
[ceph-mon1][DEBUG ]     "modified": "2024-03-08T08:59:43.135997Z",
[ceph-mon1][DEBUG ]     "mons": [
[ceph-mon1][DEBUG ]       {
[ceph-mon1][DEBUG ]         "addr": "192.168.40.151:6789/0",
[ceph-mon1][DEBUG ]         "crush_location": "{}",
[ceph-mon1][DEBUG ]         "name": "ceph-mon1",
[ceph-mon1][DEBUG ]         "priority": 0,
[ceph-mon1][DEBUG ]         "public_addr": "192.168.40.151:6789/0",
[ceph-mon1][DEBUG ]         "public_addrs": {
[ceph-mon1][DEBUG ]           "addrvec": [
[ceph-mon1][DEBUG ]             {
[ceph-mon1][DEBUG ]               "addr": "192.168.40.151:3300",
[ceph-mon1][DEBUG ]               "nonce": 0,
[ceph-mon1][DEBUG ]               "type": "v2"
[ceph-mon1][DEBUG ]             },
[ceph-mon1][DEBUG ]             {
[ceph-mon1][DEBUG ]               "addr": "192.168.40.151:6789",
[ceph-mon1][DEBUG ]               "nonce": 0,
[ceph-mon1][DEBUG ]               "type": "v1"
[ceph-mon1][DEBUG ]             }
[ceph-mon1][DEBUG ]           ]
[ceph-mon1][DEBUG ]         },
[ceph-mon1][DEBUG ]         "rank": 0,
[ceph-mon1][DEBUG ]         "weight": 0
[ceph-mon1][DEBUG ]       }
[ceph-mon1][DEBUG ]     ],
[ceph-mon1][DEBUG ]     "removed_ranks: ": "",
[ceph-mon1][DEBUG ]     "stretch_mode": false,
[ceph-mon1][DEBUG ]     "tiebreaker_mon": ""
[ceph-mon1][DEBUG ]   },
[ceph-mon1][DEBUG ]   "name": "ceph-mon1",
[ceph-mon1][DEBUG ]   "outside_quorum": [],
[ceph-mon1][DEBUG ]   "quorum": [
[ceph-mon1][DEBUG ]     0
[ceph-mon1][DEBUG ]   ],
[ceph-mon1][DEBUG ]   "quorum_age": 1,
[ceph-mon1][DEBUG ]   "rank": 0,
[ceph-mon1][DEBUG ]   "state": "leader",
[ceph-mon1][DEBUG ]   "stretch_mode": false,
[ceph-mon1][DEBUG ]   "sync_provider": []
[ceph-mon1][DEBUG ] }
[ceph-mon1][DEBUG ] ********************************************************************************
[ceph-mon1][INFO  ] monitor: mon.ceph-mon1 is running
[ceph-mon1][INFO  ] Running command: sudo ceph --cluster=ceph --admin-daemon /var/run/ceph/ceph-mon.ceph-mon1.asok mon_status
[ceph_deploy.mon][INFO  ] processing monitor mon.ceph-mon1
[ceph-mon1][DEBUG ] connection detected need for sudo
[ceph-mon1][DEBUG ] connected to host: ceph-mon1
[ceph-mon1][INFO  ] Running command: sudo ceph --cluster=ceph --admin-daemon /var/run/ceph/ceph-mon.ceph-mon1.asok mon_status
[ceph_deploy.mon][INFO  ] mon.ceph-mon1 monitor has reached quorum!
[ceph_deploy.mon][INFO  ] all initial monitors are running and have formed quorum
[ceph_deploy.mon][INFO  ] Running gatherkeys...
[ceph_deploy.gatherkeys][INFO  ] Storing keys in temp directory /tmp/tmpkaxgmvfi
[ceph-mon1][DEBUG ] connection detected need for sudo
[ceph-mon1][DEBUG ] connected to host: ceph-mon1
[ceph-mon1][INFO  ] Running command: sudo /usr/bin/ceph --connect-timeout=25 --cluster=ceph --admin-daemon=/var/run/ceph/ceph-mon.ceph-mon1.asok mon_status
[ceph-mon1][INFO  ] Running command: sudo /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-ceph-mon1/keyring auth get client.admin
[ceph-mon1][INFO  ] Running command: sudo /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-ceph-mon1/keyring auth get client.bootstrap-mds
[ceph-mon1][INFO  ] Running command: sudo /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-ceph-mon1/keyring auth get client.bootstrap-mgr
[ceph-mon1][INFO  ] Running command: sudo /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-ceph-mon1/keyring auth get client.bootstrap-osd
[ceph-mon1][INFO  ] Running command: sudo /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-ceph-mon1/keyring auth get client.bootstrap-rgw
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.client.admin.keyring
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.bootstrap-mds.keyring
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.bootstrap-mgr.keyring
[ceph_deploy.gatherkeys][INFO  ] keyring 'ceph.mon.keyring' already exists
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.bootstrap-osd.keyring
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.bootstrap-rgw.keyring
[ceph_deploy.gatherkeys][INFO  ] Destroy temp directory /tmp/tmpkaxgmvfi
#生成的配置文件
-rw------- 1 cephadmin cephadmin    113 Mar  8 16:59 ceph.bootstrap-mds.keyring 引导启动mds
-rw------- 1 cephadmin cephadmin    113 Mar  8 16:59 ceph.bootstrap-mgr.keyring 引导启动mgr
-rw------- 1 cephadmin cephadmin    113 Mar  8 16:59 ceph.bootstrap-osd.keyring 引导启动osd
-rw------- 1 cephadmin cephadmin    113 Mar  8 16:59 ceph.bootstrap-rgw.keyring 引导启动rgw
-rw------- 1 cephadmin cephadmin    151 Mar  8 16:59 ceph.client.admin.keyring  ceph客户端和管理端通信的认证密钥，是最重要的
#4.验证ceph-mon服务
cephadmin@ceph-mon1:~$ ps -ef | grep ceph-mon
ceph       6264      1  0 16:59 ?        00:00:00 /usr/bin/ceph-mon -f --cluster ceph --id ceph-mon1 --setuser ceph --setgroup ceph
cephadm+   6870   5893  0 17:01 pts/0    00:00:00 grep --color=auto ceph-mon
#5.分发admin密钥
#因为要让ceph-deploy使用ceph命令需要安装ceph-common
cephadmin@ceph-deploy:~/ceph-cluster$ sudo apt install -y ceph-common
#6.ceph-deploy  此时还不行因为没有配置认证
cephadmin@ceph-deploy:~$ ceph -s
2024-03-08T17:12:18.182+0800 7fcf10567700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
2024-03-08T17:12:18.182+0800 7fcf10567700 -1 AuthRegistry(0x7fcf0805be98) no keyring found at /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,, disabling cephx
2024-03-08T17:12:18.182+0800 7fcf10567700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
[errno 2] RADOS object not found (error connecting to the cluster)
#7.分发密钥到node上-如果部署节点需要查询ceph -s 也可以加入 部署节点
cephadmin@ceph-deploy:~$ ceph-deploy admin ceph-node1 ceph-node2 ceph-node3 ceph-deploy
#8.到node节点验证key文件
root@ceph-deploy:~# ll /etc/ceph/
root@ceph-node1:~# ll /etc/ceph/
root@ceph-node2:~# ll /etc/ceph/
root@ceph-node3:~# ll /etc/ceph/
total 20
drwxr-xr-x  2 root root 4096 Mar  5 07:42 ./
drwxr-xr-x 82 root root 4096 Mar  5 07:39 ../
-rw-------  1 root root  151 Mar  5 07:42 ceph.client.admin.keyring
-rw-r--r--  1 root root  270 Mar  5 07:42 ceph.conf
-rw-r--r--  1 root root   92 Jan 11 12:26 rbdmap
-rw-------  1 root root    0 Mar  5 07:42 tmpqz_12dix
#9.认证文件的属主和属组为了安全考虑，默认设置为了root 用户和root 组 如果需要 cephadmin 用户也能执行 ceph 命令，那么就需要对 ceph 用户进行授权
#为了让cephadmin普通用户使用ceph 命令需要设置指定参数
ceph-deploy、ceph-node1/2/3: apt-get install -y nfs4-acl-tools acl
root@ceph-deploy:~#  setfacl -m u:cephadmin:rw /etc/ceph/ceph.client.admin.keyring
root@ceph-node1:~# setfacl -m u:cephadmin:rw /etc/ceph/ceph.client.admin.keyring
root@ceph-node2:~# setfacl -m u:cephadmin:rw /etc/ceph/ceph.client.admin.keyring
root@ceph-node3:~# setfacl -m u:cephadmin:rw /etc/ceph/ceph.client.admin.keyring
#10.检验ceph -s
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_WARN
            mon is allowing insecure global_id reclaim

  services:
    mon: 1 daemons, quorum ceph-mon1 (age 22m)
    mgr: no daemons active
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
 ##12、【安装 ceph-mgr 节点】
#查看 ceph-deploy mgr命令
cephadmin@ceph-deploy:~$ ceph-deploy mgr --help
usage: ceph-deploy mgr [-h] {create} ...

Ceph MGR daemon management

positional arguments:
  {create}
    create    Deploy Ceph MGR on remote host(s)

optional arguments:
  -h, --help  show this help message and exit
  
#1.在mgr服务器上安装包
cephadmin@ceph-monmgr1:~/ceph-cluster$ sudo apt install ceph-mgr
root@ceph-mgr1:~# ceph-mgr --version
ceph version 16.2.15 (618f440892089921c3e944a991122ddc44e60516) pacific (stable)
#2.注册添加到ceph-deploy中
cephadmin@ceph-deploy:~$ ceph-deploy mgr create ceph-mgr1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephadmin/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy mgr create ceph-mgr1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  subcommand                    : create
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7efdb2a14a00>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  func                          : <function mgr at 0x7efdb2a44430>
[ceph_deploy.cli][INFO  ]  mgr                           : [('ceph-mgr1', 'ceph-mgr1')]
[ceph_deploy.mgr][DEBUG ] Deploying mgr, cluster ceph hosts ceph-mgr1:ceph-mgr1
[ceph-mgr1][DEBUG ] connection detected need for sudo
[ceph-mgr1][DEBUG ] connected to host: ceph-mgr1
[ceph_deploy.mgr][INFO  ] Distro info: ubuntu 18.04 bionic
[ceph_deploy.mgr][DEBUG ] remote host will use systemd
[ceph_deploy.mgr][DEBUG ] deploying mgr bootstrap to ceph-mgr1
[ceph-mgr1][WARNIN] mgr keyring does not exist yet, creating one
[ceph-mgr1][INFO  ] Running command: sudo ceph --cluster ceph --name client.bootstrap-mgr --keyring /var/lib/ceph/bootstrap-mgr/ceph.keyring auth get-or-create mgr.ceph-mgr1 mon allow profile mgr osd allow * mds allow * -o /var/lib/ceph/mgr/ceph-ceph-mgr1/keyring
[ceph-mgr1][INFO  ] Running command: sudo systemctl enable ceph-mgr@ceph-mgr1
[ceph-mgr1][WARNIN] Created symlink /etc/systemd/system/ceph-mgr.target.wants/ceph-mgr@ceph-mgr1.service → /lib/systemd/system/ceph-mgr@.service.
[ceph-mgr1][INFO  ] Running command: sudo systemctl start ceph-mgr@ceph-mgr1
[ceph-mgr1][INFO  ] Running command: sudo systemctl enable ceph.target
#验证是否起来ceph-mgr
root@ceph-mgr1:~# ps -ef | grep ceph-mgr
ceph      11657      1  8 09:20 ?        00:00:04 /usr/bin/ceph-mgr -f --cluster ceph --id ceph-mgr1 --setuser ceph --setgroup ceph
root      11831   1472  0 09:21 pts/0    00:00:00 grep --color=auto ceph-mgr
#此时mon mgr都有了
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_WARN
            mon is allowing insecure global_id reclaim
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 1 daemons, quorum ceph-mon1 (age 11m)
    mgr: ceph-mgr1(active, since 60s)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
#ceph versions
cephadmin@ceph-deploy:~$ ceph versions
{
    "mon": {
        "ceph version 16.2.15 (618f440892089921c3e944a991122ddc44e60516) pacific (stable)": 1
    },
    "mgr": {
        "ceph version 16.2.15 (618f440892089921c3e944a991122ddc44e60516) pacific (stable)": 1
    },
    "osd": {},
    "mds": {},
    "overall": {
        "ceph version 16.2.15 (618f440892089921c3e944a991122ddc44e60516) pacific (stable)": 2
    }
}
#ceph -s 有个警告：           mon is allowing insecure global_id reclaim 去掉这个警告
cephadmin@ceph-deploy:~$ ceph config set mon auth_allow_insecure_global_id_reclaim false
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_WARN
            mon is allowing insecure global_id reclaim
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 1 daemons, quorum ceph-mon1 (age 12m)
    mgr: ceph-mgr1(active, since 116s)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
 ##13、【初始化node存储节点】
#1.擦除磁盘之前通过 deploy 节点对 node 节点执行安装 ceph 基本运行环境
cephadmin@ceph-deploy:~$ ceph-deploy install --release pacific ceph-node1
cephadmin@ceph-deploy:~$ ceph-deploy install --release pacific ceph-node2
cephadmin@ceph-deploy:~$ ceph-deploy install --release pacific ceph-node3
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephadmin/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy install --release pacific ceph-node3
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  stable                        : None
[ceph_deploy.cli][INFO  ]  release                       : pacific
[ceph_deploy.cli][INFO  ]  testing                       : None
[ceph_deploy.cli][INFO  ]  dev                           : master
[ceph_deploy.cli][INFO  ]  dev_commit                    : None
[ceph_deploy.cli][INFO  ]  install_mon                   : False
[ceph_deploy.cli][INFO  ]  install_mgr                   : False
[ceph_deploy.cli][INFO  ]  install_mds                   : False
[ceph_deploy.cli][INFO  ]  install_rgw                   : False
[ceph_deploy.cli][INFO  ]  install_osd                   : False
[ceph_deploy.cli][INFO  ]  install_tests                 : False
[ceph_deploy.cli][INFO  ]  install_common                : False
[ceph_deploy.cli][INFO  ]  install_all                   : False
[ceph_deploy.cli][INFO  ]  adjust_repos                  : False
[ceph_deploy.cli][INFO  ]  repo                          : False
[ceph_deploy.cli][INFO  ]  host                          : ['ceph-node3']
[ceph_deploy.cli][INFO  ]  local_mirror                  : None
[ceph_deploy.cli][INFO  ]  repo_url                      : None
[ceph_deploy.cli][INFO  ]  gpg_url                       : None
[ceph_deploy.cli][INFO  ]  nogpgcheck                    : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7fcd7c843580>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  version_kind                  : stable
[ceph_deploy.cli][INFO  ]  func                          : <function install at 0x7fcd7c878430>
[ceph_deploy.install][DEBUG ] Installing stable version pacific on cluster ceph hosts ceph-node3
[ceph_deploy.install][DEBUG ] Detecting platform for host ceph-node3 ...
[ceph-node3][DEBUG ] connection detected need for sudo
[ceph-node3][DEBUG ] connected to host: ceph-node3
[ceph_deploy.install][INFO  ] Distro info: ubuntu 18.04 bionic
[ceph-node3][INFO  ] installing Ceph on ceph-node3
[ceph-node3][INFO  ] Running command: sudo env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q update
[ceph-node3][DEBUG ] Hit:1 https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal InRelease
[ceph-node3][DEBUG ] Get:2 https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-updates InRelease [114 kB]
[ceph-node3][DEBUG ] Hit:3 https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-backports InRelease
[ceph-node3][DEBUG ] Hit:4 https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-security InRelease
[ceph-node3][DEBUG ] Hit:5 https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific focal InRelease
[ceph-node3][DEBUG ] Fetched 114 kB in 2s (51.3 kB/s)
[ceph-node3][DEBUG ] Reading package lists...
[ceph-node3][INFO  ] Running command: sudo env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install ca-certificates apt-transport-https
[ceph-node3][DEBUG ] Reading package lists...
[ceph-node3][DEBUG ] Building dependency tree...
[ceph-node3][DEBUG ] Reading state information...
[ceph-node3][DEBUG ] ca-certificates is already the newest version (20230311ubuntu0.20.04.1).
[ceph-node3][DEBUG ] apt-transport-https is already the newest version (2.0.10).
[ceph-node3][DEBUG ] The following packages were automatically installed and are no longer required:
[ceph-node3][DEBUG ]   python3.6 python3.6-minimal
[ceph-node3][DEBUG ] Use 'sudo apt autoremove' to remove them.
[ceph-node3][DEBUG ] 0 upgraded, 0 newly installed, 0 to remove and 388 not upgraded.
[ceph-node3][INFO  ] Running command: sudo env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q update
[ceph-node3][DEBUG ] Hit:1 https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal InRelease
[ceph-node3][DEBUG ] Hit:2 https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-updates InRelease
[ceph-node3][DEBUG ] Hit:3 https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-backports InRelease
[ceph-node3][DEBUG ] Hit:4 https://mirrors.tuna.tsinghua.edu.cn/ubuntu focal-security InRelease
[ceph-node3][DEBUG ] Hit:5 https://mirrors.tuna.tsinghua.edu.cn/ceph/debian-pacific focal InRelease
[ceph-node3][DEBUG ] Reading package lists...
[ceph-node3][INFO  ] Running command: sudo env DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get --assume-yes -q --no-install-recommends install ceph ceph-osd ceph-mds ceph-mon radosgw
[ceph-node3][DEBUG ] Reading package lists...
[ceph-node3][DEBUG ] Building dependency tree...
[ceph-node3][DEBUG ] Reading state information...
[ceph-node3][DEBUG ] ceph is already the newest version (16.2.15-1focal).
[ceph-node3][DEBUG ] ceph-mds is already the newest version (16.2.15-1focal).
[ceph-node3][DEBUG ] ceph-mon is already the newest version (16.2.15-1focal).
[ceph-node3][DEBUG ] ceph-osd is already the newest version (16.2.15-1focal).
[ceph-node3][DEBUG ] radosgw is already the newest version (16.2.15-1focal).
[ceph-node3][DEBUG ] The following packages were automatically installed and are no longer required:
[ceph-node3][DEBUG ]   python3.6 python3.6-minimal
[ceph-node3][DEBUG ] Use 'sudo apt autoremove' to remove them.
[ceph-node3][DEBUG ] 0 upgraded, 0 newly installed, 0 to remove and 388 not upgraded.
[ceph-node3][INFO  ] Running command: sudo ceph --version
[ceph-node3][DEBUG ] ceph version 16.2.15 (618f440892089921c3e944a991122ddc44e60516) pacific (stable)
#2.列出磁盘-此处可能会报错 查看报错【列出磁盘报错】
cephadmin@ceph-deploy:~$ ceph-deploy disk list ceph-node1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephadmin/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list ceph-node1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  subcommand                    : list
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7fc2541c6ca0>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7fc2540fc310>
[ceph_deploy.cli][INFO  ]  host                          : ['ceph-node1']
[ceph_deploy.cli][INFO  ]  debug                         : False
[ceph-node1][DEBUG ] connection detected need for sudo
[ceph-node1][DEBUG ] connected to host: ceph-node1
[ceph-node1][INFO  ] Running command: sudo fdisk -l
[ceph-node1][INFO  ] b'Disk /dev/sdb: 30 GiB, 32212254720 bytes, 62914560 sectors'
[ceph-node1][INFO  ] b'Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors'
[ceph-node1][INFO  ] b'Disk /dev/sdc: 30 GiB, 32212254720 bytes, 62914560 sectors'
[ceph-node1][INFO  ] b'Disk /dev/sdd: 30 GiB, 32212254720 bytes, 62914560 sectors'
cephadmin@ceph-deploy:~$ ceph-deploy disk list ceph-node2
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephadmin/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list ceph-node2
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  subcommand                    : list
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7fd0adfd1ca0>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7fd0adf07310>
[ceph_deploy.cli][INFO  ]  host                          : ['ceph-node2']
[ceph_deploy.cli][INFO  ]  debug                         : False
[ceph-node2][DEBUG ] connection detected need for sudo
[ceph-node2][DEBUG ] connected to host: ceph-node2
[ceph-node2][INFO  ] Running command: sudo fdisk -l
[ceph-node2][INFO  ] b'Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors'
[ceph-node2][INFO  ] b'Disk /dev/sdb: 30 GiB, 32212254720 bytes, 62914560 sectors'
[ceph-node2][INFO  ] b'Disk /dev/sdc: 30 GiB, 32212254720 bytes, 62914560 sectors'
[ceph-node2][INFO  ] b'Disk /dev/sdd: 30 GiB, 32212254720 bytes, 62914560 sectors'
cephadmin@ceph-deploy:~$ ceph-deploy disk list ceph-node3
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephadmin/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list ceph-node3
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  subcommand                    : list
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7f25a2f27ca0>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7f25a2e5d310>
[ceph_deploy.cli][INFO  ]  host                          : ['ceph-node3']
[ceph_deploy.cli][INFO  ]  debug                         : False
[ceph-node3][DEBUG ] connection detected need for sudo
[ceph-node3][DEBUG ] connected to host: ceph-node3
[ceph-node3][INFO  ] Running command: sudo fdisk -l
[ceph-node3][INFO  ] b'Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors'
[ceph-node3][INFO  ] b'Disk /dev/sdc: 30 GiB, 32212254720 bytes, 62914560 sectors'
[ceph-node3][INFO  ] b'Disk /dev/sdb: 30 GiB, 32212254720 bytes, 62914560 sectors'
[ceph-node3][INFO  ] b'Disk /dev/sdd: 30 GiB, 32212254720 bytes, 62914560 sectors'
#3.擦除计划-专用于OSD磁盘上的所有分区表和数据以便用于OSD-注意：如果硬盘是无数据的新硬盘此步骤可以不做
ceph-deploy disk zap ceph-node1 /dev/sdb
ceph-deploy disk zap ceph-node1 /dev/sdc
ceph-deploy disk zap ceph-node1 /dev/sdd
ceph-deploy disk zap ceph-node2 /dev/sdb
ceph-deploy disk zap ceph-node2 /dev/sdc
ceph-deploy disk zap ceph-node2 /dev/sdd
ceph-deploy disk zap ceph-node3 /dev/sdb
ceph-deploy disk zap ceph-node3 /dev/sdc
ceph-deploy disk zap ceph-node3 /dev/sdd
 ##14、【添加OSD】
#Data:即ceph保存的对象数据
#Block: rocks DB 数据即元数据
#block-wal:数据库的 wal 日志
单块磁盘:
	>机械硬盘或者SSD:
		>data:即ceph保存的对象数据
		>block: rocks DB数据即元数据
		>block-wal:数据库的wal日志
两块磁盘:
	SSD:
		>block: rocks DB数据即元数据
		>block-wal:数据库的wal日志
	机械硬盘:
		>data:即ceph保存的对象数据
三块磁盘:
	>NVME:
		>block: rocks DB数据即元数据
	SSD:
		>block-wal:数据库的wal日志
	机械硬盘:
		>data:即ceph保存的对象数据
For bluestore, optional devices can be used::

    ceph-deploy osd create {node} --data /path/to/data --block-db /path/to/db-device
    ceph-deploy osd create {node} --data /path/to/data --block-wal /path/to/wal-device
    ceph-deploy osd create {node} --data /path/to/data --block-db /path/to/db-device --block-wal /path/to/wal-device
# 
                             								服务器          ID
    ceph-deploy osd create ceph-node1 --data /dev/sdb       0
    ceph-deploy osd create ceph-node1 --data /dev/sdc       1
    ceph-deploy osd create ceph-node1 --data /dev/sdd       2
    ceph-deploy osd create ceph-node2 --data /dev/sdb    	  3
    ceph-deploy osd create ceph-node2 --data /dev/sdc   		4
    ceph-deploy osd create ceph-node2 --data /dev/sdd	 	    5
    ceph-deploy osd create ceph-node3 --data /dev/sdb       6
    ceph-deploy osd create ceph-node3 --data /dev/sdc       7
    ceph-deploy osd create ceph-node3 --data /dev/sdd       8
#每个OSD 是一个独立的进程 不需要动
cephadmin@ceph-deploy:~$ ceph-deploy osd list ceph-node1
root@ceph-node1:~# ps -ef | grep ceph
ceph         643       1  0 09:09 ?        00:00:00 /usr/bin/python3.8 /usr/bin/ceph-crash
ceph        5020       1  0 10:08 ?        00:00:01 /usr/bin/ceph-osd -f --cluster ceph --id 0 --setuser ceph --setgroup ceph
ceph        6815       1  0 10:08 ?        00:00:00 /usr/bin/ceph-osd -f --cluster ceph --id 1 --setuser ceph --setgroup ceph
ceph        8608       1  0 10:09 ?        00:00:00 /usr/bin/ceph-osd -f --cluster ceph --id 2 --setuser ceph --setgroup ceph
root        9343    1202  0 10:13 pts/0    00:00:00 grep --color=auto ceph
root@ceph-node1:~# systemctl status ceph
ceph-crash.service                                              ceph-osd.target
ceph-mds.target                                                 ceph-radosgw.target
ceph-mgr.target                                                 ceph.service
ceph-mon.target                                                 ceph.target
ceph-osd@0.service                                              ceph-volume@lvm-0-2c3cdec8-518f-4344-863a-1f80ef2558b0.service
ceph-osd@1.service                                              ceph-volume@lvm-1-d86154a2-dab6-4ccb-9933-a65c9b40557c.service
ceph-osd@2.service                                              ceph-volume@lvm-2-d1103227-c41e-426b-aa97-326e1d96f7a6.service
root@ceph-node1:~# systemctl status ceph-osd@0.service
root@ceph-node1:~# systemctl status ceph-osd@1.service
root@ceph-node1:~# systemctl status ceph-osd@2.service
#osd: 9 osds: 9 up (since 45s), 9 in (since 53s)
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum ceph-mon1 (age 61m)
    mgr: ceph-mgr1(active, since 51m)
    osd: 9 osds: 9 up (since 45s), 9 in (since 53s)

  data:
    pools:   1 pools, 1 pgs
    objects: 0 objects, 0 B
    usage:   2.6 GiB used, 267 GiB / 270 GiB avail
    pgs:     1 active+clean
root@ceph-node1:~# pvs
  PV         VG                                        Fmt  Attr PSize   PFree
  /dev/sdb   ceph-0a0515a2-8a93-4046-a6f7-202fd214b4ca lvm2 a--  <30.00g    0
  /dev/sdc   ceph-55b16e2a-e7a6-4f21-aefc-8a42eb36ee9a lvm2 a--  <30.00g    0
  /dev/sdd   ceph-401ed7e6-d538-4033-b179-e9273bfb7a6d lvm2 a--  <30.00g    0
root@ceph-node1:~# vgs
  VG                                        #PV #LV #SN Attr   VSize   VFree
  ceph-0a0515a2-8a93-4046-a6f7-202fd214b4ca   1   1   0 wz--n- <30.00g    0
  ceph-401ed7e6-d538-4033-b179-e9273bfb7a6d   1   1   0 wz--n- <30.00g    0
  ceph-55b16e2a-e7a6-4f21-aefc-8a42eb36ee9a   1   1   0 wz--n- <30.00g    0
root@ceph-node1:~# lvs
  LV                                             VG                                        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  osd-block-2c3cdec8-518f-4344-863a-1f80ef2558b0 ceph-0a0515a2-8a93-4046-a6f7-202fd214b4ca -wi-ao---- <30.00g
  osd-block-d1103227-c41e-426b-aa97-326e1d96f7a6 ceph-401ed7e6-d538-4033-b179-e9273bfb7a6d -wi-ao---- <30.00g
  osd-block-d86154a2-dab6-4ccb-9933-a65c9b40557c ceph-55b16e2a-e7a6-4f21-aefc-8a42eb36ee9a -wi-ao---- <30.00g
root@ceph-node1:~# lsblk
NAME                                                                                                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                                                                                                     8:0    0   20G  0 disk
└─sda1                                                                                                  8:1    0   20G  0 part /
sdb                                                                                                     8:16   0   30G  0 disk
└─ceph--0a0515a2--8a93--4046--a6f7--202fd214b4ca-osd--block--2c3cdec8--518f--4344--863a--1f80ef2558b0 253:0    0   30G  0 lvm
sdc                                                                                                     8:32   0   30G  0 disk
└─ceph--55b16e2a--e7a6--4f21--aefc--8a42eb36ee9a-osd--block--d86154a2--dab6--4ccb--9933--a65c9b40557c 253:1    0   30G  0 lvm
sdd                                                                                                     8:48   0   30G  0 disk
└─ceph--401ed7e6--d538--4033--b179--e9273bfb7a6d-osd--block--d1103227--c41e--426b--aa97--326e1d96f7a6 253:2    0   30G  0 lvm
sr0                                                                                                    11:0    1  951M  0 rom
root@ceph-node1:~# blkid
/dev/sda1: UUID="6b3a541c-c71d-41bf-8e78-9feb72c5d442" TYPE="ext4" PARTUUID="097f6902-01"
/dev/sr0: UUID="2020-08-10-08-53-56-00" LABEL="Ubuntu-Server 18.04.5 LTS amd64" TYPE="iso9660" PTUUID="107c3e44" PTTYPE="dos"
/dev/sdb: UUID="V8VMYE-xSW0-LZok-Y1Jv-Ze03-rI5t-aq64QG" TYPE="LVM2_member"
/dev/sdc: UUID="XE0mQ9-CNAD-XrYJ-fdvw-EcdT-pN8a-qS078Z" TYPE="LVM2_member"
/dev/sdd: UUID="qaNGbu-WFgL-Rx09-MhTa-Osdi-Mn0h-avY1L5" TYPE="LVM2_member"
 ##15、【查看集群最终状态】
#集群状态OK、1个mon、1个mgr、9个OSD、2个池、可以使用的数据容量为270/2=135因为是每个数据存储2份的 所以是135G
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum ceph-mon1 (age 79m)
    mgr: ceph-mgr1(active, since 69m)
    osd: 9 osds: 9 up (since 18m), 9 in (since 19m)

  data:
    pools:   2 pools, 33 pgs
    objects: 0 objects, 0 B
    usage:   2.6 GiB used, 267 GiB / 270 GiB avail
    pgs:     33 active+clean
#查看OSD状态
cephadmin@ceph-deploy:~$ ceph osd status
ID  HOST                   USED  AVAIL  WR OPS  WR DATA  RD OPS  RD DATA  STATE
 0  ceph-node1.sheca.com   290M  29.7G      0        0       0        0   exists,up
 1  ceph-node1.sheca.com   290M  29.7G      0        0       0        0   exists,up
 2  ceph-node1.sheca.com   290M  29.7G      0        0       0        0   exists,up
 3  ceph-node2.sheca.com   290M  29.7G      0        0       0        0   exists,up
 4  ceph-node2.sheca.com   290M  29.7G      0        0       0        0   exists,up
 5  ceph-node2.sheca.com   290M  29.7G      0        0       0        0   exists,up
 6  ceph-node3.sheca.com   290M  29.7G      0        0       0        0   exists,up
 7  ceph-node3.sheca.com   290M  29.7G      0        0       0        0   exists,up
 8  ceph-node3.sheca.com   290M  29.7G      0        0       0        0   exists,up
 ##16、【测试上传与下载数据】
#存取数据时,客户端必须首先连接至 RADOS 集群上某存储池，然后根据对象名称由相关的CRUSH规则完成数据对象寻址。
#于是，为了测试集群的数据存取功能，这里首先创建一个用于测试的存储池 mypool，并设定其 PG 数量为 32 个。
#创建Pool
cephadmin@ceph-deploy:~$ ceph osd pool create mypool 32 32
pool 'mypool' created
#验证PG与PFP组合
cephadmin@ceph-deploy:~$ ceph pg ls-by-pool mypool | awk '{print $1,$2,$15}'
PG OBJECTS ACTING
2.0 0 [3,6,0]p3
2.1 0 [2,6,3]p2
2.2 0 [5,1,8]p5
2.3 0 [5,2,8]p5
2.4 0 [1,7,3]p1
2.5 0 [8,0,4]p8
2.6 0 [1,6,3]p1
2.7 0 [3,7,2]p3
2.8 0 [3,7,0]p3
2.9 0 [1,4,8]p1
2.a 0 [6,1,3]p6
2.b 0 [8,5,2]p8
2.c 0 [6,0,5]p6
2.d 0 [6,3,2]p6
2.e 0 [2,8,3]p2
2.f 0 [8,4,0]p8
2.10 0 [8,1,5]p8
2.11 0 [4,1,8]p4
2.12 0 [7,1,3]p7
2.13 0 [7,4,2]p7
2.14 0 [3,7,0]p3
2.15 0 [7,1,3]p7
2.16 0 [5,7,1]p5
2.17 0 [5,6,2]p5
2.18 0 [8,4,2]p8
2.19 0 [0,4,7]p0
2.1a 0 [3,8,2]p3
2.1b 0 [6,5,2]p6
2.1c 0 [8,4,1]p8
2.1d 0 [7,3,0]p7
2.1e 0 [2,7,5]p2
2.1f 0 [0,3,8]p0

* NOTE: afterwards
cephadmin@ceph-deploy:~$ ceph osd pool ls
device_health_metrics
mypool
cephadmin@ceph-deploy:~$ rados lspools
device_health_metrics
mypool
#当前的 ceph 环境还没还没有部署使用块存储和文件系统使用 ceph，也没有使用对象存储的客户端，但是 ceph 的rados 命令可以实现访问 ceph 对象存储的功能:
#上传文件
sudo rados put msg1 /var/log/syslog --pool=mypool #把 messages 文件上传到 mypool 并指定对象 id 为 msg1
#列出文件
cephadmin@ceph-deploy:~$ rados ls --pool=mypool
msg1
#文件信息
cephadmin@ceph-deploy:~$ ceph osd map mypool msg1
osdmap e53 pool 'mypool' (2) object 'msg1' -> pg 2.c833d430 (2.10) -> up ([8,1,5], p8) acting ([8,1,5], p8)
#下载文件
sudo rados get msg1 --pool=mypool /opt/my.txt
#修改文件
cephadmin@ceph-deploy:~$ sudo rados put msg /etc/passwd --pool=mypool
cephadmin@ceph-deploy:~$ sudo rados get msg1 --pool=mypool /opt/2.txt
cephadmin@ceph-deploy:~$ tail /opt/2.txt
Mar 11 09:10:26 ceph-deploy systemd[1]: Started User Manager for UID 0.
Mar 11 09:10:26 ceph-deploy systemd[866]: Startup finished in 58ms.
Mar 11 09:10:27 ceph-deploy systemd[1]: Started Session 3 of user root.
Mar 11 09:17:01 ceph-deploy CRON[1247]: (root) CMD (   cd / && run-parts --report /etc/cron.hourly)
Mar 11 09:21:35 ceph-deploy systemd-timesyncd[565]: Timed out waiting for reply from 185.125.190.57:123 (ntp.ubuntu.com).
Mar 11 09:21:45 ceph-deploy systemd-timesyncd[565]: Timed out waiting for reply from 185.125.190.58:123 (ntp.ubuntu.com).
Mar 11 09:21:46 ceph-deploy systemd-timesyncd[565]: Synchronized to time server 185.125.190.56:123 (ntp.ubuntu.com).
Mar 11 09:25:44 ceph-deploy systemd[1]: Starting Cleanup of Temporary Directories...
Mar 11 09:25:44 ceph-deploy systemd[1]: Started Cleanup of Temporary Directories.
Mar 11 10:17:01 ceph-deploy CRON[3419]: (root) CMD (   cd / && run-parts --report /etc/cron.hourly)
#删除文件
cephadmin@ceph-deploy:~$ rados ls --pool=mypool
msg
cephadmin@ceph-deploy:~$ sudo rados rm msg --pool=mypool
 ##17、【从 RADOS 移除 OSD】
#Ceph 集群中的一个 OSD 是一个 node 节点的服务进程且对应于一个物理磁盘设备,是一个专用的守护进程。在某 OSD 设备出现故障,或管理员出于管理之需确实要移除特定的 OSD设备时
#需要先停止相关的守护进程，而后再进行移除操作。对于Luminous 及其之后的版本来说，停止和移除命令的格式分别如下所示:
1.停用设备: ceph osd out {osd-num}
2.停止进程: sudo systemctl stop ceph-osd@{osd-num)
3.移除设备: ceph osd purge {id} --yes-i-really-mean-it
 ##18、【集群高可用 - 扩展 ceph-mon】为3台ceph-mon
#当前只有一个Mon节点主机，存在SPOF、添加新的mon节点实现高可用
#注意如果n个mon节点，至少需要保证有n>2个以上的健康mon节点、ceph集群才可以正常使用
#ceph-deploy mon destroy ceph-mon2
#ceph-deploy install --mon ceph-mon2 也可以安装 或者
root@ceph-mon2:~# apt install -y ceph-mon
root@ceph-mon2:~# apt install -y ceph-mon
cephadmin@ceph-deploy:~$ ceph-deploy mon add ceph-mon2
cephadmin@ceph-deploy:~$ ceph-deploy mon add ceph-mon3
cephadmin@ceph-deploy:~$ ceph quorum_status
cephadmin@ceph-deploy:~$ ceph quorum_status --format json-pretty
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 88s)
    mgr: ceph-mgr1(active, since 79m)
    osd: 9 osds: 9 up (since 29m), 9 in (since 29m)

  data:
    pools:   2 pools, 33 pgs
    objects: 0 objects, 0 B
    usage:   2.6 GiB used, 267 GiB / 270 GiB avail
    pgs:     33 active+clean
 ##19、【集群高可用 - 扩展 ceph-mgr】2台ceph-mgr
#当前只有一个Mgr节点主机、存在SPOF、添加新的Mgr节点实现高可用
#Ceph Manager守护进程以Active/Standby模式运行，部署其他ceph-mgr守护进程可确保在Active节点或者其上的ceph-mgr守护进程故障时，其中一个Standby实例可以在不中断服务的情况下接管其任务
#注意，如果所有的Mgr节点故障了，集群将无法正常工作
#ceph-deploy install --mgr ceph-mgr2 或者
root@ceph-mon3:~# apt install ceph-mon
cephadmin@ceph-deploy:~$ ceph-deploy mgr create ceph-mgr2
cephadmin@ceph-deploy:~$ ceph-deploy admin ceph-mgr2 #同步配置文件到 ceph-mg2 节点
#主：ceph-mgr1 备：ceph-mgr2 
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 19m)
    mgr: ceph-mgr1(active, since 97m), standbys: ceph-mgr2
    osd: 9 osds: 9 up (since 47m), 9 in (since 47m)

  data:
    pools:   2 pools, 33 pgs
    objects: 0 objects, 0 B
    usage:   2.6 GiB used, 267 GiB / 270 GiB avail
    pgs:     33 active+clean
 ##20、【验证高可用】
#关闭任务节点Mgr和Mon 测试结果
#关闭ceph-mgr1 ceph-mgr2自动成为主mgr
root@ceph-mgr1:~# poweroff
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2,ceph-mon3 (age 22m)
    mgr: ceph-mgr2(active, since 9s)
    osd: 9 osds: 9 up (since 50m), 9 in (since 50m)

  data:
    pools:   2 pools, 33 pgs
    objects: 0 objects, 0 B
    usage:   2.6 GiB used, 267 GiB / 270 GiB avail
    pgs:     33 active+clean
#关闭一个mon ceph-mon3
root@ceph-mon3:~# poweroff
#有一个HEALTH_WARN 有一个mon挂机
cephadmin@ceph-deploy:~$ ceph -s
  cluster:
    id:     0d8fb726-ee6d-4aaf-aeca-54c68e2584af
    health: HEALTH_WARN
            1/3 mons down, quorum ceph-mon1,ceph-mon2

  services:
    mon: 3 daemons, quorum ceph-mon1,ceph-mon2 (age 12s), out of quorum: ceph-mon3
    mgr: ceph-mgr2(active, since 49s)
    osd: 9 osds: 9 up (since 50m), 9 in (since 50m)

  data:
    pools:   2 pools, 33 pgs
    objects: 0 objects, 0 B
    usage:   2.6 GiB used, 267 GiB / 270 GiB avail
    pgs:     33 active+clean
#再关闭一个mon ceph-mon2
#此时Ceph集权异常、宕机
cephadmin@ceph-deploy:~$ ceph -s
Error处理
##报错1：【集群初始化-使用ceph-deploy工具】
cephadmin@ceph-deploy:~/ceph-cluster$ ceph-deploy new --cluster-network 172.31.40.0/24 --public-network 192.168.40.0/24 ceph-mon1.sheca.com
报错：
[ceph_deploy][ERROR ] RuntimeError: AttributeError: module 'platform' has no attribute 'linux_distribution'
#解决方案1 ：因为python3.8已经没有这个方法了
cephadmin@ceph-deploy:~$ dpkg -l python3
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name                                 Version                 Architecture            Description
+++-====================================-=======================-=======================-=============================================================================
ii  python3                              3.8.2-0ubuntu2          amd64                   interactive high-level object-oriented language (default python3 version)

cephadmin@ceph-deploy:~$ sudo vim /usr/lib/python3/dist-packages/ceph_deploy/hosts/remotes.py
def platform_information(_linux_distribution=None):
    """ detect platform information from remote host """
    distro = release = codename = None
    try:
        linux_distribution = _linux_distribution or platform.linux_distribution
        distro, release, codename = linux_distribution()
    except AttributeError:
        # NOTE: py38 does not have platform.linux_distribution
        pass
#解决方案2 ：使用源码进行安装 ceph-deploy #https://www.cnblogs.com/valeb/p/16131422.html
pip3 install setuptools
apt-get install python3 python3-pip -y
root@ceph-deploy:~# mkdir /ceph-deploy-source && cd /ceph-deploy-source
root@ceph-deploy:~/ceph-deploy# git clone https://github.com/ceph/ceph-deploy.git
root@ceph-deploy:~/ceph-deploy# python3 setup.py install
root@ceph-deploy:~/ceph-deploy# ceph-deploy --version
2.1.0

#N: Unable to locate package ceph-deploy
#装这个版本后续列出disk 会报错
cephadmin@ceph-deploy:~$ sudo apt install python3-pip
cephadmin@ceph-deploy:~$ sudo pip3 install ceph-deploy
Successfully installed ceph-deploy-2.0.1
#解决ceph-deploy无法列出目的主机磁盘信息的pyhton报错
#pip3 uninstall ceph-deploy #如果安装了python3版本的ceph-deploy就先卸载，没有安装就执行下一步安装
#apt install python-pip #安装python2
#pip2 install ceph-deploy #使用python2的pip安装ceph-deploy~/ceph-cluster$ ceph-deploy disklist ceph-node1 #切换到普通用户、验证列出node节点磁盘


#报错2
#【列出磁盘报错】
cephadmin@ceph-deploy:~$ ceph-deploy disk list ceph-node1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephadmin/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy disk list ceph-node1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  subcommand                    : list
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7f8008e5fd00>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  func                          : <function disk at 0x7f8008f14310>
[ceph_deploy.cli][INFO  ]  host                          : ['ceph-node1']
[ceph_deploy.cli][INFO  ]  debug                         : False
[ceph-node1][DEBUG ] connection detected need for sudo
[ceph-node1][DEBUG ] connected to host: ceph-node1
[ceph-node1][INFO  ] Running command: sudo fdisk -l
[ceph_deploy][ERROR ] Traceback (most recent call last):
[ceph_deploy][ERROR ]   File "/usr/lib/python3/dist-packages/ceph_deploy/util/decorators.py", line 69, in newfunc
[ceph_deploy][ERROR ]     return f(*a, **kw)
[ceph_deploy][ERROR ]   File "/usr/lib/python3/dist-packages/ceph_deploy/cli.py", line 166, in _main
[ceph_deploy][ERROR ]     return args.func(args)
[ceph_deploy][ERROR ]   File "/usr/lib/python3/dist-packages/ceph_deploy/osd.py", line 434, in disk
[ceph_deploy][ERROR ]     disk_list(args, cfg)
[ceph_deploy][ERROR ]   File "/usr/lib/python3/dist-packages/ceph_deploy/osd.py", line 375, in disk_list
[ceph_deploy][ERROR ]     if line.startswith('Disk /'):
[ceph_deploy][ERROR ] TypeError: startswith first arg must be bytes or a tuple of bytes, not str
[ceph_deploy][ERROR ]

解决办法：
sudo vim /usr/lib/python3/dist-packages/ceph_deploy/osd.py
修改 375行代码 if line.startswith('Disk /'): 多加一个单词b
             if line.startswith(b'Disk /'):
