# armbian 放通防火墙 #
```
# 允许局域网访问 WordPress
sudo iptables -I DOCKER-USER -s 10.166.166.0/24 -p tcp --dport 8080 -j ACCEPT

# 允许局域网访问 Nextcloud
sudo iptables -I DOCKER-USER -s 10.166.166.0/24 -p tcp --dport 8082 -j ACCEPT

# 允许局域网访问五子棋
sudo iptables -I DOCKER-USER -s 10.166.166.0/24 -p tcp --dport 8085 -j ACCEPT

# 允许宿主机访问所有 Docker 映射端口
sudo iptables -I DOCKER-USER -i lo -j ACCEPT

# 默认拒绝其他未经允许的流量（可选，保持安全）
sudo iptables -A DOCKER-USER -j DROP
```
