# OECT刷Armbian系统后的步骤记录
## 1：easytier 安装使用
### 1.1 Armbian下docker安装步骤
**命令：**  
```
docker run --name easytier --net=host --privileged --restart=always -d m.daocloud.io/docker.io/easytier/easytier:latest --hostname nas  -i 10.166.166.1/24 -n 192.168.24.0/24 --vpn-portal wg://0.0.0.0:11013/10.16.11.0/24 --network-name 账户 --network-secret '密码' -p tcp://自建服务器IP:11010 -p tcp://public.easytier.top:11010
```  
**解释:**  
`-i 10.166.166.1/24`表示该core启动生效的IP，注意不要与已有冲突  
`-n 192.168.24.0/24`表示该core代理IP地址段，一般是家庭局域网地址段  
`--vpn-portal wg://0.0.0.0:11013/10.16.11.0/24`表示开启VPN，可通过wireguard连接  
### 1.2 自建easytier服务器  
1：执行`easytier.sh`脚本  
```
./easytier.sh install 账户 该机名称
```  
2：修改`/etc/systemd/system/easytier.service`文件，修改  
```
ExecStart=/root/easytier/easytier-core -i 10.166.166.101/24 --network-name 账户 --hostname 该机名称 --network-secret '密码*' --vpn-portal wg://0.0.0.0:11013/10.16.1.0/24 -p tcp://0.0.0.0:11010 -p tcp://public.easytier.cn:11010
```  
<img width="1895" height="355" alt="image" src="https://github.com/user-attachments/assets/67a38641-fd51-4a24-8703-19d85b32fd77" />  

### 1.3 注意事项  
**vpn是基于udp的，所有云虚机需要开启基于udp的11013端口**
## 2：casaos下安装openwrt
1：打开网卡混杂模式  
```
sudo ip link set eth0 promisc on
```  
2：创建网络(须结合实际网络情况修改IP部分，使用与主路由同网段IP和主路由网关地址，不能照抄命令，不然无法正常联网)  
```
docker network create -d macvlan --subnet=192.168.24.0/24 --gateway=192.168.24.1 --ip-range=192.168.24.254/32 -o parent=eth0 macnet
```
`--ip-range=192.168.24.254/32`强制指定openwrt容器的地址  
查看是否生效：  
```
docker network inspect macnet
```  
删除：  
```
docker network rm macnet
```  
3：拉取镜像  
```
docker pull dreamwsbg/openwrt:16.0
```  
4：运行容器  
```
docker run -d --name="openwrt" --restart unless-stopped --network macnet --privileged dreamwsbg/openwrt:16.0 /sbin/init
```  
5：修改openwrt地址  
进入容器  
```
docker exec -it openwrt bash
```  
**注意ubusd服务状态，如果没有启动，需手动后台启动 ubusd &**  
修改网络：  
```
vim /etc/config/network
```  
重启网络：  
```
/etc/init.d/network restart
```
网络生效:    
<img width="1189" height="681" alt="image" src="https://github.com/user-attachments/assets/0d44a85c-9d50-4e87-bb2c-b7040190d842" />    
**注：若没有自动生成network文件，可参考如下配置：**  
```
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd38:7dd4:a09f::/48'
        option packet_steering '1'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'
        option promisc '1'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.24.254'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option gateway '192.168.24.1'
```
将容器commit为新镜像  
```
docker commit openwrt openwrt-myself:latest
```
验证是否创建成功  
```
docker images | grep openwrt-custom
```
导出镜像为本地文件  
```
docker save -o openwrt-custom.tar openwrt-custom:latest
```
其他机器导入镜像  
```
# 语法：docker load -i [镜像文件.tar]
docker load -i openwrt-custom.tar
```

