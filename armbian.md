# OECT刷Armbian系统后的步骤记录
## 1：easytier 安装使用
### 1.1 Armbian下docker安装步骤
**命令：**  
`docker run --name easytier --net=host --privileged --restart=always -d dockerproxy.net/easytier/easytier -i 10.166.166.1/24 -n 192.168.24.0/24 --vpn-portal wg://0.0.0.0:11013/10.16.11.0/24 --network-name 账户 --network-secret '密钥' -p tcp://自建服务器IP:11010 -p tcp://public.easytier.top:11010`\
**解释:**  
`-i 10.166.166.1/24`表示该core启动生效的IP，注意不要与已有冲突  
`-n 192.168.24.0/24`表示该core代理IP地址段，一般是家庭局域网地址段  
`--vpn-portal wg://0.0.0.0:11013/10.16.11.0/24`表示开启VPN，可通过wireguard连接  

