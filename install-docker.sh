#!/bin/bash
set -e

echo "🚀 开始在 Debian 上安装 Docker 套件..."

# Step 1. 更新系统
sudo apt update
sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release

# Step 2. 添加 Docker GPG Key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Step 3. 添加 Docker 官方仓库
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 4. 安装 Docker 套件
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 5. 启动并设置开机自启
sudo systemctl enable docker
sudo systemctl start docker

# Step 6. 把当前用户加入 docker 组（避免每次用 sudo）
if ! groups $USER | grep -q '\bdocker\b'; then
  sudo usermod -aG docker $USER
  echo "✅ 已将用户 $USER 添加到 docker 组，需重新登录或执行 'newgrp docker' 生效。"
fi

# Step 7. 验证安装
echo "✅ Docker 版本：$(docker --version)"
echo "✅ Docker Compose 版本：$(docker compose version)"

echo "🎉 Docker 套件安装完成！你可以运行 'docker run hello-world' 测试。"
