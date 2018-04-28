---
title: '使用Google Cloud Platform(GCP GCE)安装SSR+BBR教程'
tags: ["google cloud platform", "gcp", "ssr", "shadowsocks", "shadowsocksr", "vpn"]
date: 2017-05-29 17:52:00
---

# 使用Google Cloud Platform(GCP GCE)安装SSR+BBR教程

GCP是原GCE，其优美的界面和丰富的功能深得各类程序员的喜好。近日发现Google Cloud Platform对大陆优化好，并且送300美金（12个月）的礼品卡。特此一试，效果甚好，故收集教程并集合关于Google Cloud Platform(GCP GCE)安装SS+BBR。

## 创建实例

在左侧的菜单中找到 计算引擎 –  VM 实例
通过创建实例或者单击加号来创建一个虚拟机。

- 名称：随意输入
- 地区：建议`asia-east1-c`
- 机器类型：小型（建议）/微型
- 启动磁盘单击更改 – Ubuntu 16.04 LTS
- 防火墙：允许HTTP流量，允许HTTPS流量

## 初步配置

- 左侧导航 – 计算 – 网络

- 外部IP地址 – 选择一个ip – 类型调整为静态

- 防火墙规则 – 创建防火墙规则（未提及的全部默认）：流量方向`入站`、来源ip地址`0.0.0.0/0`、协议和端口`全部允许`

- 防火墙规则 – 创建防火墙规则（未提及的全部默认）：流量方向`出站`、来源ip地址`0.0.0.0/0`、协议和端口`全部允许（注意要创建两次防火墙规则，一次出站，一次入站）`

## 配置SS以及BBR

进入实例控制台 – SSH – 在浏览器窗口中打开

### 获取root权限

```
sudo su
```

### 安装SS（根据脚本提示来）

```
wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocksR.sh
chmod +x shadowsocksR.sh
./shadowsocksR.sh 2>&1 | tee shadowsocksR.log
```

服务器端口：默认为 8989
密码：默认为 teddysun.com
加密方式：默认为 aes-256-cfb
协议（Protocol）：默认为 origin
混淆（obfs）：默认为 plain

### 安装BBR加速

wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh

### 重置VM实例



### 重复第一步和第二步，输入

```
sysctl net.ipv4.tcp_available_congestion_control
```

若出现

```
net.ipv4.tcp_available_congestion_control = bbr cubic reno
```

### 第三第四步可以合并为一步，通过[ShadowsocksR+BBR加速一键安装包](http://suiyuanjian.com/139.html)

## 问题及参考

无法连接外网：

- 在VM实例的网络选项中要勾选外网IP地址，不然无法联上外网。

创建步骤参考自：

- [如何免费打造一个安全稳定超高速的科学上网环境](https://sspai.com/post/39361)
- [GOOGLE COMPUTE ENGINE(GCE)注册开VPS教程](https://www.91yun.org/archives/2297)
- [拥有一架 Google 的小飞机是一种怎样的体验](https://github.com/kaiye/kaiye.github.com/issues/9)

SSR/SS相关问题：

- [SSR一键脚本](https://shadowsocks.be/9.html)

BBR相关问题：

- [一键安装最新内核并开启BBR脚本](https://teddysun.com/489.html)

> --随缘箭·版权所有：[使用Google Cloud Platform(GCP GCE)安装SSR+BBR教程](https://suiyuanjian.com/124.html)--

