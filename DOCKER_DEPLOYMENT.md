# Docker 部署指南 - MiroFish

本指南将帮助你使用 Docker 快速部署 MiroFish 多智能体群体智能预测引擎。

## 📋 前置要求

- **Docker**: 版本 20.10 或更高
- **Docker Compose**: 版本 2.0 或更高
- **必需的 API 密钥**:
  - LLM API Key (支持 OpenAI 兼容接口，默认使用阿里云百炼 Qwen-plus)
  - Zep Cloud API Key (用于智能体记忆管理)

检查 Docker 版本：
```bash
docker --version
docker compose version
```

## 🚀 快速开始

### 1. 克隆仓库（如果还未克隆）

```bash
git clone <your-repository-url>
cd MiroFish
```

### 2. 配置环境变量

复制环境变量模板文件：
```bash
cp .env.example .env
```

编辑 `.env` 文件，填入必需的 API 密钥：
```bash
# 必需配置
LLM_API_KEY=your_api_key_here          # 你的 LLM API 密钥
ZEP_API_KEY=your_zep_api_key_here      # 你的 Zep Cloud API 密钥

# LLM 配置（可选，默认使用阿里云百炼）
LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
LLM_MODEL_NAME=qwen-plus

# 可选：Boost LLM 配置（用于加速某些操作）
LLM_BOOST_API_KEY=
LLM_BOOST_BASE_URL=
LLM_BOOST_MODEL_NAME=
```

### 3. 构建并启动服务

```bash
# 构建并启动所有服务（后台运行）
docker compose up -d --build

# 查看启动日志
docker compose logs -f
```

### 4. 访问应用

应用启动后，通过浏览器访问：

- **前端应用**: http://localhost
- **后端 API**: http://localhost:5001

## 📁 项目结构

```
MiroFish/
├── docker-compose.yml          # Docker Compose 编排文件
├── .dockerignore               # Docker 构建忽略文件
├── .env                        # 环境变量配置（需自行创建）
├── .env.example                # 环境变量模板
├── backend/
│   ├── Dockerfile              # 后端容器构建文件
│   └── ...
├── frontend/
│   ├── Dockerfile              # 前端容器构建文件
│   ├── nginx.conf              # Nginx 配置文件
│   └── ...
└── DOCKER_DEPLOYMENT.md        # 本文档
```

## 🔧 Docker 服务说明

### Backend 服务
- **容器名**: mirofish-backend
- **端口**: 5001
- **技术栈**: Python 3.11 + Flask + uv
- **持久化存储**:
  - `mirofish-uploads`: 存储用户上传的文件和模拟数据
  - `mirofish-logs`: 存储应用日志

### Frontend 服务
- **容器名**: mirofish-frontend
- **端口**: 80
- **技术栈**: Vue 3 + Vite + Nginx
- **功能**: 提供静态文件服务，并代理 API 请求到后端

## 📝 常用命令

### 启动服务
```bash
# 前台启动（查看实时日志）
docker compose up

# 后台启动
docker compose up -d

# 重新构建并启动
docker compose up -d --build
```

### 停止服务
```bash
# 停止所有服务
docker compose down

# 停止并删除所有数据卷（警告：会删除上传的数据）
docker compose down -v
```

### 查看日志
```bash
# 查看所有服务日志
docker compose logs -f

# 查看特定服务日志
docker compose logs -f backend
docker compose logs -f frontend
```

### 查看服务状态
```bash
# 查看运行中的容器
docker compose ps

# 查看资源使用情况
docker stats
```

### 重启服务
```bash
# 重启所有服务
docker compose restart

# 重启特定服务
docker compose restart backend
docker compose restart frontend
```

### 进入容器
```bash
# 进入后端容器
docker compose exec backend sh

# 进入前端容器
docker compose exec frontend sh
```

## 🗂️ 数据持久化

应用使用 Docker 命名卷来持久化数据：

- **mirofish-uploads**: 存储用户上传的文件和模拟结果
- **mirofish-logs**: 存储应用运行日志

### 备份数据
```bash
# 备份上传文件
docker run --rm -v mirofish-uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads-backup.tar.gz /data

# 备份日志
docker run --rm -v mirofish-logs:/data -v $(pwd):/backup alpine tar czf /backup/logs-backup.tar.gz /data
```

### 恢复数据
```bash
# 恢复上传文件
docker run --rm -v mirofish-uploads:/data -v $(pwd):/backup alpine tar xzf /backup/uploads-backup.tar.gz -C /

# 恢复日志
docker run --rm -v mirofish-logs:/data -v $(pwd):/backup alpine tar xzf /backup/logs-backup.tar.gz -C /
```

### 清理数据卷
```bash
# 查看所有数据卷
docker volume ls

# 删除特定数据卷（警告：数据将丢失）
docker volume rm mirofish-uploads
docker volume rm mirofish-logs
```

## 🔍 健康检查

Docker Compose 配置了自动健康检查：

- **后端**: 每 30 秒检查 `/health` 端点
- **前端**: 每 30 秒检查根路径

查看健康状态：
```bash
docker compose ps
```

## 🛠️ 故障排查

### 服务无法启动

1. **检查环境变量**：确保 `.env` 文件配置正确
   ```bash
   cat .env
   ```

2. **查看容器日志**：
   ```bash
   docker compose logs backend
   docker compose logs frontend
   ```

3. **检查端口占用**：
   ```bash
   # Linux/Mac
   lsof -i :80
   lsof -i :5001

   # Windows
   netstat -ano | findstr :80
   netstat -ano | findstr :5001
   ```

### 后端 API 连接失败

1. **确认后端容器运行正常**：
   ```bash
   docker compose ps backend
   ```

2. **测试后端健康检查**：
   ```bash
   curl http://localhost:5001/health
   ```

3. **检查网络连接**：
   ```bash
   docker network inspect mirofish-network
   ```

### 前端无法访问后端

1. **检查 Nginx 配置**：
   ```bash
   docker compose exec frontend cat /etc/nginx/conf.d/default.conf
   ```

2. **检查后端连接**：
   ```bash
   docker compose exec frontend wget -O- http://backend:5001/health
   ```

### API 密钥错误

如果遇到 API 认证错误：
1. 确认 `.env` 文件中的密钥正确无误
2. 重启服务使新配置生效：
   ```bash
   docker compose restart backend
   ```

### 磁盘空间不足

清理未使用的 Docker 资源：
```bash
# 清理所有未使用的容器、网络、镜像
docker system prune -a

# 清理未使用的数据卷（谨慎使用）
docker volume prune
```

## 🔐 生产环境建议

### 1. 使用 HTTPS

建议在生产环境中配置 SSL/TLS 证书：

创建 `docker-compose.prod.yml`：
```yaml
version: '3.8'

services:
  frontend:
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx-prod.conf:/etc/nginx/conf.d/default.conf
      - ./ssl:/etc/nginx/ssl:ro
```

### 2. 环境变量安全

使用 Docker Secrets 管理敏感信息：
```bash
# 创建 secret
echo "your_api_key" | docker secret create llm_api_key -

# 在 docker-compose.yml 中引用
secrets:
  - llm_api_key
```

### 3. 资源限制

在 `docker-compose.yml` 中添加资源限制：
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

### 4. 日志管理

配置日志轮转：
```yaml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### 5. 自动重启策略

确保服务异常时自动重启（已配置 `restart: unless-stopped`）

### 6. 定期备份

设置定时任务自动备份数据卷（建议每天备份）

## 🔄 更新应用

```bash
# 1. 拉取最新代码
git pull origin main

# 2. 重新构建镜像
docker compose build

# 3. 重启服务
docker compose up -d

# 4. 查看日志确认启动成功
docker compose logs -f
```

## 📊 监控和维护

### 查看资源使用
```bash
docker stats mirofish-backend mirofish-frontend
```

### 查看容器信息
```bash
docker compose exec backend python -c "import sys; print(sys.version)"
docker compose exec frontend nginx -v
```

### 清理旧镜像
```bash
docker image prune -a
```

## 🆘 获取帮助

如果遇到问题：

1. 查看日志：`docker compose logs -f`
2. 检查 GitHub Issues
3. 阅读主 README.md 文档

## 📜 许可证

与主项目相同的许可证。
