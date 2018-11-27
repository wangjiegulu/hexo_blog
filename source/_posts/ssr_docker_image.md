---
title: 制作一个 SSR Docker 镜像
subtitle: "制作一个 SSR Docker 镜像"
tags: ["huginn", "docker", "docker hub", "automate", "mysql", "migration", "shadowsocks", "shadowsocksr", "ss", "ssr"]
categories: ["automate", "docker", "ssr"]
header-img: "https://images.unsplash.com/photo-1478809956569-c7ce9654a947?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=96287b17975bd6c0a003628dd93f6ee6&auto=format&fit=crop&w=2273&q=80"
centercrop: false
hidden: false
copyright: true
---

# 制作一个 SSR Docker 镜像

基于 [秋水逸冰](https://github.com/teddysun/shadowsocks_install) 发布的 [一键安装脚本](https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh) 写的 `Dockerfile`。

因为平时会在多个 vps 上都部署一套，有时候还经常换 vps，但是又比较懒，不想每次都得重新创建自己的配置文件，所以索性把配置文件直接放在镜像里面。

> 本文的镜像文件已经上传到 [Github](https://github.com/wangjiegulu/ssr_dockerfile)：
> https://github.com/wangjiegulu/ssr_dockerfile
> 大家 clone 下来之后可以省去编写 Dockerfile 文件步骤，直接进入到 [构建镜像](#build_image) 步骤。

## 编写 Dockerfile 文件

以下是最终的 Dockerfile 文件，后面我们再分析里面的重要的一些步骤：

```docker
# Dockerfile for ShadowsocksR
# https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh

FROM debian:stretch

LABEL maintainer="Wang Jie <tiantian.china.2@gmail.com>"

# prepare
RUN apt-get update \
  && apt-get install -y procps \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/* \
  && export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/sbin:/usr/local/games:/usr/games

# install ssr
RUN cd /usr/local \
  && mkdir ssr \
  && cd ssr \
  && wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh \
  && chmod +x shadowsocksR.sh \
  && \n | ./shadowsocksR.sh 2>&1 | tee shadowsocksR.log \
  && \n; exit 0

# ssr configuration
COPY shadowsocks.json /etc/

# ssr script
RUN cd /usr/local/ssr \
  # fake log
  && touch fake_log.log \
  # start.sh
  && touch start.sh \
  && echo 'python /usr/local/shadowsocks/server.py -c /etc/shadowsocks.json -d start && tail -f /usr/local/ssr/fake_log.log' > start.sh \
  && chmod 775 start.sh \
  # stop.sh
  && touch stop.sh \
  && echo 'python /usr/local/shadowsocks/server.py -c /etc/shadowsocks.json -d stop' > stop.sh \
  && chmod 775 stop.sh \
  # restart.sh
  && touch restart.sh \
  && echo './stop.sh && ./start.sh' > restart.sh \
  && chmod 775 restart.sh

ENTRYPOINT ["sh", "/usr/local/ssr/start.sh"]
```

根据以上文件可知：

- 首先我们这个 ssr 镜像是在 linxus `debian stretch` 这个版本的基础上制作的。
- 第一个 `RUN` 是做一些构建之前的准备工作：
 - 安装 `wget`，为了方便我们之后从 github 下载 [秋水逸冰](https://github.com/teddysun/shadowsocks_install) 发布的 [一键安装脚本](https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh) 。
 - 配置环境变量。
- 第二个 `RUN` 是用来安装 ssr，先下载 `https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh`，然后再执行 `./shadowsocksR.sh 2>&1 | tee shadowsocksR.log`，这里因为这个脚本是交互式的，安装过程中会让你选择比如端口号，加密协议等等信息，但是我们希望一起都按照默认的安装，最后再用我们的配置文件去覆盖默认的来达到自动部署的目的，所以我们在命令前面加上 `\n`，一律通过回车默认跳过。
- `COPY` 操作是在安装完成之后，把当前目录的 `shadowsocks.json` 拷贝到容器的 `/etc/` 目录。所以大家在使用这个 Dockerfile 构建之前要在同目录下配置好自己的 `shadowsocks.json`。
- 最后一个 `RUN` 是用来创建一些命令脚本，比如 启动 ssr 的 `start.sh`，停止 ssr 的 `stop.sh`，重启 ssr 的 `restart.sh`；除此之外，还会创建一个 `fake_log.log` 文件，因为如果没有这个文件，当你启动这个容器，并执行 `start.sh` 之后，一旦执行成功，容器就被自动关闭了，这个是由 docker 机制决定，所以我们需要在启动之后再 `tail -f fake_log.log`，来确保 容器不会被关闭。
- 最后的 `ENTRYPOINT` 表示从这个镜像启动一个容器之后，自动执行的命令，我们希望在容器启动的时候自动把 ssr 的服务开启，所以需要做这个配置。



<span id="build_image"/>
## 构建镜像

在 `Dockerfile` 的同一目录创建你自己的 `shadowsocks.json` 文件，然后构建生成镜像，然后上传到你自己的 [Docker Hub](https://hub.docker.com/)。之后在任何主机上部署，pull 下你自己的镜像，run 即可，省去每次要修改你的配置的步骤。

> 注意：你创建的这个镜像中是包含了自己的配置文件信息的，所以最好是 `private`。

### 构建步骤

- 在 [Docker Hub](https://hub.docker.com/) （没有就先注册）创建你的 respository （最好 private），如 `ssr`，假设你的 docker hub 用户名为 `zhangsan`。
- Clone 本项目
- 在项目根目录创建 `shadowsocks.json`，编写类似如下的 ssr 配置：
 
 ```json
 {
    "server":"0.0.0.0",
    "server_ipv6":"[::]",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
        "9000":"xxxxxx",
        "9001":{"password":"xxxxxx", "protocol":"auth_chain_a", "obfs":"tls1.2_ticket_auth", "obfs_param":""},
        "9002":{"password":"xxxxxx", "protocol":"auth_chain_a", "obfs":"tls1.2_ticket_auth", "obfs_param":""}
        // ...
    },
    "timeout":120,
    "method":"chacha20",
    "protocol":"origin",
    "protocol_param":"",
    "obfs":"plain",
    "obfs_param":"",
    "redirect":"",
    "dns_ipv6":false,
    "fast_open":false,
    "workers":1
 }
 ```
 
- 创建 docker 镜像：cd 到本项目的根目录，运行命令 `docker build --no-cache -t zhangsan/ssr:0.1 .`。创建成功之后运行 `docker images` 确认下。
- 把你本地生成的镜像 push 到你的仓库：
 - 运行 `docker login`，确认你是登录状态，未登录则登录 `Docker Hub`。
 - 执行 `docker push zhangsan/ssr:0.1`。
 - 成功之后到你的 `Docker Hub` 查看该 respository 的 tag 是否有 `0.1` 的版本存在了。

### 使用步骤

- 登录你的 vps，安装 docker，执行 `docker login` 登录。
- 运行 `docker pull zhangsan/ssr:0.1` 命令把刚刚你创建的镜像 pull 下来。
- 再运行镜像：`docker run -itd --name ssr -p 9000:9000 -p 9001:9001 -p 9002:9002 zhangsan/ssr:0.1`
- 容器（容器的名字为 `ssr`）启动之后，`ssr server` 会自动跑起来。
- 根据你 vps 的系统，把 `docker run ssr` 作为开机自启。