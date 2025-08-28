#!/bin/bash

set -e  # 遇到错误立即退出

# -------------------------------
# ⚡ 1️⃣ 检查 Docker
# -------------------------------
echo "🚀 检查 Docker 是否安装..."
if ! command -v docker &> /dev/null; then
    echo "🔹 未检测到 Docker，开始安装 Docker..."
    curl -fsSL https://get.daocloud.io/docker | sh
    sudo systemctl enable --now docker
else
    echo "✅ Docker 已安装"
fi

# 配置阿里云 Docker 镜像加速
echo "🔹 配置 Docker 镜像加速器..."
ACCELERATOR_URL="https://docker.1ms.run"  # 替换成你的加速器ID
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": ["$ACCELERATOR_URL"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

# -------------------------------
# ⚡ 2️⃣ 检查 Docker Compose V2
# -------------------------------
echo "🚀 检查 Docker Compose V2..."
if ! docker compose version &> /dev/null; then
    echo "🔹 未检测到 Docker Compose V2，安装 docker-compose-plugin..."
    sudo apt update
    sudo apt install -y docker-compose-plugin
else
    echo "✅ Docker Compose V2 已安装"
fi

# -------------------------------
# ⚡ 3️⃣ 创建 Nginx Proxy Manager 目录
# -------------------------------
echo "🚀 创建 Nginx Proxy Manager 目录..."
sudo mkdir -p /etc/docker/npm && cd /etc/docker/npm
sudo chown $(whoami):$(whoami) .

# -------------------------------
# ⚡ 4️⃣ 输入端口
# -------------------------------
read -rp "请输入 HTTP 端口（默认80）: " PORT_HTTP
PORT_HTTP=${PORT_HTTP:-80}

read -rp "请输入 管理面板端口（默认81）: " PORT_PANEL
PORT_PANEL=${PORT_PANEL:-81}

read -rp "请输入 HTTPS 端口（默认443）: " PORT_HTTPS
PORT_HTTPS=${PORT_HTTPS:-443}

echo "🔹 设置端口映射为：HTTP $PORT_HTTP，管理面板 $PORT_PANEL，HTTPS $PORT_HTTPS"

# -------------------------------
# ⚡ 5️⃣ 生成 docker-compose.yml
# -------------------------------
echo "🚀 生成 docker-compose.yml..."
cat > docker-compose.yml <<EOF
services:
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '${PORT_HTTP}:80'
      - '${PORT_PANEL}:81'
      - '${PORT_HTTPS}:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

# -------------------------------
# ⚡ 6️⃣ 启动 Nginx Proxy Manager
# -------------------------------
echo "🚀 启动 Nginx Proxy Manager..."
docker compose up -d

# -------------------------------
# ⚡ 7️⃣ 提示访问信息
# -------------------------------
IP_ADDRESS=$(curl -s http://ipv4.icanhazip.com || hostname -I | awk '{print $1}')
echo "✅ 安装完成！"
echo "🔹 访问管理面板：http://$IP_ADDRESS:$PORT_PANEL"
echo "🔹 默认账号：admin@example.com / changeme"
