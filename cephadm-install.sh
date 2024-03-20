#【使用Cephadm部署Ceph集群】
#https://docs.ceph.com/en/reef/cephadm/install/
##【Ubuntu 22.04】
##【初始化服务器】
#配置hosts 每台都要配置
root@ceph-monmgr1:~# cat /etc/hosts
127.0.0.1 localhost
127.0.1.1 ceph-monmgr1

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
192.168.40.141 ceph-monmgr1 ceph-monmgr1.sheca.com
192.168.40.142 ceph-monmgr2 ceph-monmgr2.sheca.com
192.168.40.143 ceph-monmgr3 ceph-monmgr3.sheca.com
192.168.40.146 ceph-osd1    ceph-osd1.sheca.com
192.168.40.147 ceph-osd2    ceph-osd2.sheca.com
192.168.40.148 ceph-osd3    ceph-osd3.sheca.com

##【Install Docker 20.10.18】
#每台都要安装
cd /usr/local/src/
tar zxvf docker-20.10.18-binary-install.tar.gz
./docker-install.sh

##【Install ceph-admin 17.2.4】
In Ubuntu:
		apt install -y cephadm
或者
#CEPH_RELEASE=18.2.0 # replace this with the active release
#curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm	
curl --silent --remote-name --location https://download.ceph.com/rpm-17.2.4/el9/noarch/cephadm
chmod a+x cephadm
mv cephadm /usr/local/bin/
./cephadm <arguments...>
vim /usr/local/bin/cephadm
#cephadm pull #下载默认镜像
#docker pull 提早下载好镜像
docker pull quay.io/ceph/ceph:v17
docker pull quay.io/prometheus/prometheus:v2.33.4
docker pull docker.io/grafana/loki:2.4.0
docker pull docker.io/grafana/promtail:2.4.0
docker pull quay.io/prometheus/node-exporter:v1.3.1
docker pull quay.io/prometheus/alertmanager:v0.23.0
docker pull quay.io/ceph/ceph-grafana:8.3.5
docker pull quay.io/ceph/haproxy:2.3
docker pull quay.io/ceph/keepalived:2.1.5
docker pull docker.io/maxwo/snmp-notifier:v1.2.1

root@ceph-osd1:/usr/local/src# docker images
REPOSITORY                         TAG       IMAGE ID       CREATED         SIZE
quay.io/ceph/ceph                  v17       ccf08e11baa0   13 days ago     1.26GB
quay.io/ceph/ceph-grafana          8.3.5     dad864ee21e9   23 months ago   558MB
quay.io/prometheus/prometheus      v2.33.4   514e6a882f6e   2 years ago     204MB
quay.io/ceph/keepalived            2.1.5     9f7bdb4a87fd   2 years ago     214MB
quay.io/ceph/haproxy               2.3       e85424b0d443   2 years ago     99.3MB
quay.io/prometheus/node-exporter   v1.3.1    1dbe0e931976   2 years ago     20.9MB
grafana/loki                       2.4.0     24d3d94c71c7   2 years ago     62.5MB
grafana/promtail                   2.4.0     f568284f5b06   2 years ago     179MB
quay.io/prometheus/alertmanager    v0.23.0   ba2b418f427c   2 years ago     57.5MB
maxwo/snmp-notifier                v1.2.1    7ca9dd8b3f09   2 years ago     13.2MB

##【初始化 ceph 集群】
#当前节点安装 mon、mgr 角色,部署 prometheus、grafana、alertmanager、node-exporter等眼务
root@ceph-monmgr1:/usr/local/src# cephadm bootstrap --mon-ip 172.31.40.141 --cluster-network 172.31.40.0/24 --allow-fqdn-hostname
Creating directory /etc/ceph for ceph.conf
Verifying podman|docker is present...
Verifying lvm2 is present...
Verifying time synchronization is in place...
Unit systemd-timesyncd.service is enabled and running
Repeating the final host check...
docker (/usr/bin/docker) is present
systemctl is present
lvcreate is present
Unit systemd-timesyncd.service is enabled and running
Host looks OK
Cluster fsid: e5746d5e-dc35-11ee-b852-000c294eabe4
Verifying IP 172.31.40.141 port 3300 ...
Verifying IP 172.31.40.141 port 6789 ...
Mon IP `172.31.40.141` is in CIDR network `172.31.40.0/24`
Mon IP `172.31.40.141` is in CIDR network `172.31.40.0/24`
Pulling container image quay.io/ceph/ceph:v17...
Ceph version: ceph version 17.2.7 (b12291d110049b2f35e32e0de30d70e9a4c060d2) quincy (stable)
Extracting ceph user uid/gid from container image...
Creating initial keys...
Creating initial monmap...
Creating mon...
Waiting for mon to start...
Waiting for mon...
mon is available
Assimilating anything we can from ceph.conf...
Generating new minimal ceph.conf...
Restarting the monitor...
Setting mon public_network to 172.31.40.0/24
Setting cluster_network to 172.31.40.0/24
Wrote config to /etc/ceph/ceph.conf
Wrote keyring to /etc/ceph/ceph.client.admin.keyring
Creating mgr...
Verifying port 9283 ...
Waiting for mgr to start...
Waiting for mgr...
mgr not available, waiting (1/15)...
mgr not available, waiting (2/15)...
mgr not available, waiting (3/15)...
mgr not available, waiting (4/15)...
mgr is available
Enabling cephadm module...
Waiting for the mgr to restart...
Waiting for mgr epoch 5...
mgr epoch 5 is available
Setting orchestrator backend to cephadm...
Generating ssh key...
Wrote public SSH key to /etc/ceph/ceph.pub
Adding key to root@localhost authorized_keys...
Adding host ceph-monmgr1...
Deploying mon service with default placement...
Deploying mgr service with default placement...
Deploying crash service with default placement...
Deploying prometheus service with default placement...
Deploying grafana service with default placement...
Deploying node-exporter service with default placement...
Deploying alertmanager service with default placement...
Enabling the dashboard module...
Waiting for the mgr to restart...
Waiting for mgr epoch 9...
mgr epoch 9 is available
Generating a dashboard self-signed certificate...
Creating initial admin user...
Fetching dashboard port number...
Ceph Dashboard is now available at:

             URL: https://ceph-monmgr1:8443/
            User: admin
        Password: zpp206r6gd

Enabling client.admin keyring and conf on hosts with "admin" label
Saving cluster configuration to /var/lib/ceph/e5746d5e-dc35-11ee-b852-000c294eabe4/config directory
Enabling autotune for osd_memory_target
You can access the Ceph CLI as following in case of multi-cluster or non-default config:

        sudo /usr/local/bin/cephadm shell --fsid e5746d5e-dc35-11ee-b852-000c294eabe4 -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring

Or, if you are only running a single cluster on this host:

        sudo /usr/local/bin/cephadm shell

Please consider enabling telemetry to help improve Ceph:

        ceph telemetry on

For more information see:

        https://docs.ceph.com/docs/master/mgr/telemetry/

Bootstrap complete.

#启用ceph shell 一个管理ceph集群的交互式命令窗口
root@ceph-monmgr1:/usr/local/src# sudo /usr/local/bin/cephadm shell --fsid e5746d5e-dc35-11                                                                                               ee-b852-000c294eabe4 -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring
Inferring config /var/lib/ceph/e5746d5e-dc35-11ee-b852-000c294eabe4/mon.ceph-monmgr1/config
Using ceph image with id 'ccf08e11baa0' and tag 'v17' created on 2024-02-22 16:05:27 +0000                                                                                                UTC
quay.io/ceph/ceph@sha256:d759526e53a54ae72901bf5d4fa07e7f3ba3c4c8378087531e963a7b0cb555c1
root@ceph-monmgr1:/# ceph version
ceph version 17.2.7 (b12291d110049b2f35e32e0de30d70e9a4c060d2) quincy (stable)
root@ceph-monmgr1:/# ceph -s
  cluster:
    id:     e5746d5e-dc35-11ee-b852-000c294eabe4
    health: HEALTH_WARN
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 1 daemons, quorum ceph-monmgr1 (age 106s)
    mgr: ceph-monmgr1.zjdhlt(active, since 71s)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:

  progress:
    Updating grafana deployment (+1 -> 1) (0s)
      [............................]

root@ceph-monmgr1:/# ceph orch ps
NAME                        HOST          PORTS        STATUS          REFRESHED   AGE  MEM                                                                                                USE  MEM LIM  VERSION    IMAGE ID      CONTAINER ID
alertmanager.ceph-monmgr1   ceph-monmgr1  *:9093,9094  starting                -     -                                                                                                       -        -  <unknown>  <unknown>     <unknown>
crash.ceph-monmgr1          ceph-monmgr1               starting                -     -                                                                                                       -        -  <unknown>  <unknown>     <unknown>
mgr.ceph-monmgr1.zjdhlt     ceph-monmgr1  *:9283       running (110s)    70s ago  110s                                                                                                    425M        -  17.2.7     ccf08e11baa0  4aa85a3a9bca
mon.ceph-monmgr1            ceph-monmgr1               running (111s)    70s ago  112s    2                                                                                               5.0M    2048M  17.2.7     ccf08e11baa0  1e4a484f6b9d
node-exporter.ceph-monmgr1  ceph-monmgr1  *:9100       starting                -     -                                                                                                       -        -  <unknown>  <unknown>     <unknown>
root@ceph-monmgr1:/# ceph orch ps


##【安装宿主机ceph 命令来管理集群】
cephadm install ceph-common 或者 apt install -y ceph-common

##【将ceph-mon 添加到 ceph集群】
#分发密钥
root@ceph-monmgr1:~$ ssh-copy-id -f -i /etc/ceph/ceph.pub root@ceph-monmgr1
root@ceph-monmgr1:~$ ssh-copy-id -f -i /etc/ceph/ceph.pub root@ceph-monmgr2
root@ceph-monmgr1:~$ ssh-copy-id -f -i /etc/ceph/ceph.pub root@ceph-monmgr3
root@ceph-monmgr1:~$ ssh-copy-id -f -i /etc/ceph/ceph.pub root@ceph-osd1
root@ceph-monmgr1:~$ ssh-copy-id -f -i /etc/ceph/ceph.pub root@ceph-osd2
root@ceph-monmgr1:~$ ssh-copy-id -f -i /etc/ceph/ceph.pub root@ceph-osd3

#添加主机-如果把osd节点也当mon也可以 最多5个mon
#cephadm shell ceph orch host add ceph-monmgr2 172.31.40.142 
ceph orch host add ceph-monmgr2 172.31.40.142
Added host 'ceph-monmgr2' with addr '172.31.40.142'
#cephadm shell ceph orch host add ceph-monmgr3 172.31.40.143
ceph orch host add ceph-monmgr3 172.31.40.143
Added host 'ceph-monmgr3' with addr '172.31.40.143'
#cephadm shell ceph orch host add ceph-osd1.sheca.com 172.31.40.146
ceph orch host add ceph-osd1 172.31.40.146
Added host 'ceph-osd1' with addr '172.31.40.146'
#cephadm shell ceph orch host add ceph-osd2.sheca.com 172.31.40.147
ceph orch host add ceph-osd2 172.31.40.147
Added host 'ceph-osd2' with addr '172.31.40.147'
#cephadm shell ceph orch host add ceph-osd3.sheca.com 172.31.40.148
ceph orch host add ceph-osd3 172.31.40.148
Added host 'ceph-osd3' with addr '172.31.40.148'

#添加到集群的主机，默认会部署 mon 服务
root@ceph-monmgr1:~# ceph -s
  cluster:
    id:     e5746d5e-dc35-11ee-b852-000c294eabe4
    health: HEALTH_WARN
            OSD count 0 < osd_pool_default_size 3

  services:
    mon: 3 daemons, quorum ceph-monmgr1,ceph-monmgr2,ceph-monmgr3 (age 53s)
    mgr: ceph-monmgr1.zjdhlt(active, since 3m), standbys: ceph-monmgr2.gzxnzn
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:

#验证主机-共6个 最多5个mon 但是可以调整为3个mon 两个mgr
#cephadm shell ceph orch host ls or ceph orch host ls
root@ceph-monmgr1:~# ceph orch host ls
HOST          ADDR           LABELS  STATUS
ceph-monmgr1  172.31.40.141  _admin
ceph-monmgr2  172.31.40.142
ceph-monmgr3  172.31.40.143
ceph-osd1     172.31.40.146
ceph-osd2     172.31.40.147
ceph-osd3     172.31.40.148
6 hosts in cluster

#可以调整ceph-mon 节点为3个
#ceph orch apply mon ceph-monmgr1,ceph-monmgr2,ceph-monmgr3
ceph orch apply mon ceph-monmgr1,ceph-monmgr2,ceph-monmgr3	

##【将磁盘添加到集群】-上面一步ceph orch host add ceph-osd1/2/3 一定要添加 否则无法列出磁盘
#cephadm shell ceph orch device ls
root@ceph-monmgr1:~# ceph orch device ls
HOST       PATH      TYPE  DEVICE ID   SIZE  AVAILABLE  REFRESHED  REJECT REASONS
ceph-osd1  /dev/sdb  hdd              30.0G  Yes        4m ago
ceph-osd1  /dev/sdc  hdd              30.0G  Yes        4m ago
ceph-osd1  /dev/sdd  hdd              30.0G  Yes        4m ago
ceph-osd2  /dev/sdb  hdd              30.0G  Yes        4m ago
ceph-osd2  /dev/sdc  hdd              30.0G  Yes        4m ago
ceph-osd2  /dev/sdd  hdd              30.0G  Yes        4m ago
ceph-osd3  /dev/sdb  hdd              30.0G  Yes        3m ago
ceph-osd3  /dev/sdc  hdd              30.0G  Yes        3m ago
ceph-osd3  /dev/sdd  hdd              30.0G  Yes        3m ago

root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd1:/dev/sdb
Created osd(s) 0 on host 'ceph-osd1'
root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd1:/dev/sdc
Created osd(s) 1 on host 'ceph-osd1'
root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd1:/dev/sdd
Created osd(s) 2 on host 'ceph-osd1'
root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd2:/dev/sdb
Created osd(s) 3 on host 'ceph-osd2'
root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd2:/dev/sdc
Created osd(s) 4 on host 'ceph-osd2'
root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd2:/dev/sdd
Created osd(s) 5 on host 'ceph-osd2'
root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd3:/dev/sdb
Created osd(s) 6 on host 'ceph-osd3'
root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd3:/dev/sdc
Created osd(s) 7 on host 'ceph-osd3'
root@ceph-monmgr1:~# ceph orch daemon add osd ceph-osd3:/dev/sdd
Created osd(s) 8 on host 'ceph-osd3'

#验证集群状态 -  9 osds: 9 up (since 13s), 9 in (since 29s)
root@ceph-monmgr1:~# ceph -s
  cluster:
    id:     e5746d5e-dc35-11ee-b852-000c294eabe4
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph-monmgr1,ceph-monmgr2,ceph-monmgr3 (age 14m)
    mgr: ceph-monmgr1.zjdhlt(active, since 17m), standbys: ceph-monmgr2.gzxnzn
    osd: 9 osds: 9 up (since 13s), 9 in (since 29s)

  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 449 KiB
    usage:   2.6 GiB used, 267 GiB / 270 GiB avail
    pgs:     1 active+clean

##【添加ceph-mgr专用节点】
#由于本环境mon mgr共用 之前已经添加过了 如果不是共用的 单独部署的mon mgr需要添加
#cephadm shell ceph orch host add ceph-monmgr1 172.31.40.141
ceph orch host add ceph-monmgr1 172.31.40.141
#cephadm shell ceph orch host add ceph-monmgr2 172.31.40.142
ceph orch host add ceph-monmgr2 172.31.40.142
#切换mgr节点
root@ceph-monmgr1:~# ceph orch apply mgr ceph-monmgr1,ceph-monmgr2
Scheduled mgr update...
#切换 mgr 流程
#添加 mgr 到集群-成为备份节点-新旧 mgr 节点进行主从切换-新的成为主节点-旧的成为备份节点-删除不需要的 mgr 节点
#验证ceph 集群当前状态 - mgr: ceph-monmgr1.zjdhlt(active, since 22m), standbys: ceph-monmgr2.gzxnzn
root@ceph-monmgr1:~# ceph -s
  cluster:
    id:     e5746d5e-dc35-11ee-b852-000c294eabe4
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum ceph-monmgr1,ceph-monmgr2,ceph-monmgr3 (age 19m)
    mgr: ceph-monmgr1.zjdhlt(active, since 22m), standbys: ceph-monmgr2.gzxnzn
    osd: 9 osds: 9 up (since 5m), 9 in (since 5m)

  data:
    pools:   1 pools, 1 pgs
    objects: 2 objects, 449 KiB
    usage:   2.6 GiB used, 267 GiB / 270 GiB avail
    pgs:     1 active+clean

##【查看所有程序是否正常】
root@ceph-monmgr1:~# ceph orch ps
NAME                        HOST          PORTS        STATUS         REFRESHED  AGE  MEM USE  MEM LIM  VERSION  IMAGE ID      CONTAINER ID
alertmanager.ceph-monmgr1   ceph-monmgr1  *:9093,9094  running (21m)     5m ago  27m    14.2M        -  0.25.0   c8568f914cd2  2f063c49a7fc
crash.ceph-monmgr1          ceph-monmgr1               running (27m)     5m ago  27m    7111k        -  17.2.7   ccf08e11baa0  8b874fb911d1
crash.ceph-monmgr2          ceph-monmgr2               running (21m)    10m ago  21m    7071k        -  17.2.7   ccf08e11baa0  f6adbbf89a00
crash.ceph-monmgr3          ceph-monmgr3               running (20m)     8m ago  20m    7079k        -  17.2.7   ccf08e11baa0  e2d3db3fa031
crash.ceph-osd1             ceph-osd1                  running (16m)     9m ago  16m    7075k        -  17.2.7   ccf08e11baa0  c7446cf30364
crash.ceph-osd2             ceph-osd2                  running (16m)     7m ago  16m    7075k        -  17.2.7   ccf08e11baa0  96dd35ffacd7
crash.ceph-osd3             ceph-osd3                  running (15m)     6m ago  15m    7079k        -  17.2.7   ccf08e11baa0  3516477d57a5
grafana.ceph-monmgr1        ceph-monmgr1  *:3000       running (23m)     5m ago  24m    74.1M        -  9.4.7    954c08fa6188  864bfc7ab5f6
mgr.ceph-monmgr1.zjdhlt     ceph-monmgr1  *:9283       running (28m)     5m ago  28m     493M        -  17.2.7   ccf08e11baa0  4aa85a3a9bca
mgr.ceph-monmgr2.gzxnzn     ceph-monmgr2  *:8443,9283  running (21m)    10m ago  21m     417M        -  17.2.7   ccf08e11baa0  58c086714cca
mon.ceph-monmgr1            ceph-monmgr1               running (28m)     5m ago  28m    49.1M    2048M  17.2.7   ccf08e11baa0  1e4a484f6b9d
mon.ceph-monmgr2            ceph-monmgr2               running (21m)    10m ago  21m    30.3M    2048M  17.2.7   ccf08e11baa0  37c7540f65ac
mon.ceph-monmgr3            ceph-monmgr3               running (20m)     8m ago  20m    30.6M    2048M  17.2.7   ccf08e11baa0  0672763d2084
node-exporter.ceph-monmgr1  ceph-monmgr1  *:9100       running (27m)     5m ago  27m    8076k        -  1.5.0    0da6a335fe13  29799c8f408e
node-exporter.ceph-monmgr2  ceph-monmgr2  *:9100       running (21m)    10m ago  21m    8076k        -  1.5.0    0da6a335fe13  c5b1a507f96c
node-exporter.ceph-monmgr3  ceph-monmgr3  *:9100       running (20m)     8m ago  20m    8347k        -  1.5.0    0da6a335fe13  ae62eb7fc2e6
node-exporter.ceph-osd1     ceph-osd1     *:9100       running (16m)     9m ago  16m    8160k        -  1.5.0    0da6a335fe13  c56eed1a444f
node-exporter.ceph-osd2     ceph-osd2     *:9100       running (16m)     7m ago  16m    7728k        -  1.5.0    0da6a335fe13  b2ed3a622a6f
node-exporter.ceph-osd3     ceph-osd3     *:9100       running (15m)     6m ago  15m    8152k        -  1.5.0    0da6a335fe13  c38a1660af35
osd.0                       ceph-osd1                  running (11m)     9m ago  11m    49.0M     989M  17.2.7   ccf08e11baa0  64873e49e0b8
osd.1                       ceph-osd1                  running (10m)     9m ago  10m    46.9M     989M  17.2.7   ccf08e11baa0  48b6501e41b8
osd.2                       ceph-osd1                  running (9m)      9m ago   9m    11.2M     989M  17.2.7   ccf08e11baa0  793de502f405
osd.3                       ceph-osd2                  running (8m)      7m ago   8m    52.6M     989M  17.2.7   ccf08e11baa0  1610fd610ce4
osd.4                       ceph-osd2                  running (8m)      7m ago   8m    48.6M     989M  17.2.7   ccf08e11baa0  50016f8ff59a
osd.5                       ceph-osd2                  running (7m)      7m ago   7m    11.2M     989M  17.2.7   ccf08e11baa0  85949bede45a
osd.6                       ceph-osd3                  running (7m)      6m ago   7m    49.8M     989M  17.2.7   ccf08e11baa0  639afdee1a06
osd.7                       ceph-osd3                  running (6m)      6m ago   6m    50.6M     989M  17.2.7   ccf08e11baa0  5ed05555a2e5
osd.8                       ceph-osd3                  running (6m)      6m ago   6m    11.2M     989M  17.2.7   ccf08e11baa0  4610bd0d9f2a
prometheus.ceph-monmgr1     ceph-monmgr1  *:9095       running (15m)     5m ago  23m    53.0M        -  2.43.0   a07b618ecd1d  400d11ba0dc5

##【Ceph - Dashboard】-账户密码 初始化有 admin/
#             URL: https://ceph-monmgr1:8443/
#            User: admin
#        Password: zpp206r6gd
#https://192.168.40.141:8443/

##【Grafana 设置初始管理员密码】
#默认情况下,Grafana不会创建初始管理员用户。为了创建管理员用户，请创建一个包含以下内容的 grafana.yaml 文件:
vim grafana.yaml
service type: grafana
spec:
  initial admin_password: password12345678
然后应用此规范:
root@ceph-monmgr1:~# ceph orch apply -i grafana.yaml
Scheduled grafana update...
root@ceph-monmgr1:~# ceph orch redeploy grafana
Scheduled to redeploy grafana.ceph-monmgr1 on host 'ceph-monmgr1'

##【每个节点安装了node-exporter 9100】
#192.168.40.141/142/143/146/147/148:9100

#
