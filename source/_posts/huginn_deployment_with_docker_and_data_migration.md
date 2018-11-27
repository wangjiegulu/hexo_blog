---
title: Huginn 的 Docker 部署及数据迁移
subtitle: "Huginn 的 Docker 部署及数据迁移"
tags: ["huginn", "docker", "docker hub", "automate", "mysql", "migration"]
categories: ["automate", "docker"]
header-img: "https://camo.githubusercontent.com/f7da893be2c2f5f765f2436296656e7d25962437/68747470733a2f2f7261772e6769746875622e636f6d2f687567696e6e2f687567696e6e2f6d61737465722f6d656469612f687567696e6e2d6c6f676f2e706e67"
centercrop: false
hidden: false
copyright: true
---


# Huginn 的 Docker 部署及数据迁移

前两天因为要换 vps，其中之前部署的 Huginn 需要迁移到新的 vps。之前也有朋友问过关于 huginn 的数据备份和迁移的问题。这篇文章就讲下整个流程。

在 vps 上安装 huginn，我之前的博客- [《Huginn及环境搭建》](https://blog.wangjiegulu.com/2018/04/02/build_the_environment_for_huginn/) 有讲到过 Huginn 的部署过程，过程比较复杂，要安装的东西也比较多，做迁移的时候要重新部署一遍，也比较容易出错。而 Huginn 有提供 docker 镜像，所以这次我们通过 docker 来搭建 Huginn 环境。

## 安装 docker

我用的 vps 是 Debian，按照官方文档安装 docker，具体流程见这里：<https://docs.docker.com/install/linux/docker-ce/debian/>。

> 安装过程不再赘述

## 拉取 huginn 镜像

首先登录到 vps。

执行 `docker search huginn` 来搜索所有公开的 huginn 镜像：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/48963645-f99fc180-efd1-11e8-8806-357110a96ea8.png" width="800px">
</div>

上面高亮的就是我们要使用的镜像，拉取下来（默认拉取 lastest ）：

```shell
docker pull huginn/huginn
```

## 运行 huginn

拉取完 huginn 之后，我们其余的环境配置（比如 mysql 安装等等）都不需要再配置了，镜像里面都有了，所以我们要做的就是直接运行 huginn：

```shell
docker run -itd --name huginn -p 3000:3000 huginn/huginn
```
- `-itd`：包括如下 3 个命令：
 - `-t`：在新容器内指定一个伪终端或终端。
 - `-i`：允许你对容器内的标准输入 (STDIN) 进行交互。
 - `-d`：以新的进程在后台运行
- `--name`：给这个容器取个别名叫 `huginn`
- `-p`：容器内部的 3000 端口映射到我们 vps 主机的 3000 端口上

执行 `docker ps` 来查看 huginn 是否有真正运行：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/48963720-a3cc1900-efd3-11e8-97f7-8c473a4298c3.png" width="800px">
</div>

浏览器访问 `<vps:ip>:3000`，应该就能看到 huginn 页面了。但是这个时候因为数据还没有迁移，当前的 huginn 数据库是空的。

## 数据备份

关于 huginn 的备份，[官方 wiki 里面给出的方案](https://github.com/huginn/huginn/wiki/Backing-up-huginn) 是通过 `backup gem` 来进行备份，huginn 作者 给出了 [备份的脚本](https://github.com/huginn/huginn/blob/master/doc/deployment/backup/example_backup.rb)，具体 `backup` 的文档参考见：<http://backup.github.io/backup/v4/>。但是我这次做数据迁移的话，是直接通过 `mysqldump` 来导出数据库。

登录到 `旧的 vps`，然后执行如下命令来备份 mysql 数据：

```shell
mysqldump --single-transaction --opt -u huginn -ppassword huginn_production > huginn_backupfile.sql
```

> 注意：以上命令的参数需要替换：
> 
>  - huginn：mysql 用户名
>  - password：mysql 密码
>  - huginn_production：数据库名

执行完成之后，就会生成一个名为 `huginn_backupfile.sql` 文件，里面就是你 huginn 的所有数据了，包括 `用户信息`，`scenarios`，`agent`，`events`，`user_credentials`，`Services` 等等。

## 恢复数据

备份完之后，就要恢复数据，要恢复数据，得先把数据拷贝到 huginn 容器里面。

首先通过一下命令把文件从 `旧的 vps` 拷贝到 `新的 vps` **主机**上：

```shell
scp huginn_backupfile.sql root@<新 vps ip>:/home/wangjie/huginn_backupfile.sql
```

注意，这个时候，文件是在你的 `新的 vps` 的**主机**上，你还需要把它拷贝到刚刚我们新建的 huginn 容器中，执行如下命令：

```shell
docker cp /home/wangjie/huginn_backupfile.sql huginn: /app/wjhuginn/huginn_backupfile.sql
```

在 `新的 vps` 中对新部署的 `huginn` 进行 restore 数据，如下：

```shell
mysql -u root -ppassword huginn_production < huginn_backupfile.sql
```

> 注意：默认情况下，huginn 镜像中的：
> 
> - 数据库名：huginn_production
> - 用户：root
> - 密码：password

除了以上数据，我们还需要 restore 的是 huginn 中的 `.env` 文件，里面包含了我们的一些配置信息（比如，email，第三方 service key 等等），用同样的方法把 `旧的 vps` 中的 `.env` 拷贝到 `新的 vps`，然后覆盖掉即可。


## 其它配置

### 修改 DNS Host Record

把你的 ip 地址改成新的 vps 的 ip。

### 配置 nginx 反向代理：

如下配置，详情可参考 [这里](https://github.com/huginn/huginn/wiki/Nginx-reverse-proxy-configuration)：

```
server {
    # Make it available from the Internet
    allow all;

    listen 80;

    # server names for this server.
    # any requests that come in that match any these names will use the proxy.
    server_name huginn.server.com;
    access_log /var/log/nginx/huginn.server.com-access.log;
    error_log /var/log/nginx/huginn.server.com-error.log;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    listen 443 ssl;

    # Setup SSL certificate with Let's Encript (https://letsencrypt.org/)
    ssl_certificate /etc/letsencrypt/live/huginn.server.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/huginn.server.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_trusted_certificate /etc/letsencrypt/live/huginn.server.com/chain.pem;
    ssl_stapling on;
    ssl_stapling_verify on;

    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    }
}
```