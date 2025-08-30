# 云虚机使用记录
## Oracle云修改ssh端口 
1： 放开云虚机安全组端口 : 实例-->网络-->网络安全组-->子网-->虚拟云网络-->安全-->安全规则  
2：放开虚机防火墙规则：
查看规则  
```
iptables -L
```
**查看INPUT链的规则编号（方便删除）**  
```
sudo iptables -L INPUT --line-numbers
```

**执行删除（把6换成你的1122规则编号）**  
```
sudo iptables -D INPUT 6
```
**插入1122端口允许规则到INPUT链的第4位（确保在REJECT之前）**  
```
sudo iptables -I INPUT 4 -p tcp --dport 1122 -m state --state NEW -j ACCEPT
```
**查看当前规则**
```
sudo iptables -L INPUT
```
**保存规则：Ubuntu/Debian系统**  
```
sudo iptables-save > /etc/iptables/rules.v4
```
**CentOS/RHEL系统**
```
sudo service iptables save
```


