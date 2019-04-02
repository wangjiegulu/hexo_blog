---
title: Jenkins 添加 MacOS 节点
subtitle: "Jenkins 添加 MacOS 节点"
tags: ["jenkins", "CI", "持续集成", "Continuous Integration", "iOS"]
categories: ["jenkins", "CI", "持续集成", "Continuous Integration", "iOS"]
header-img: "https://images.unsplash.com/photo-1504691342899-4d92b50853e1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true
---

# Jenkins 添加 MacOS 节点

> `Master` 为 Linux，但是需要支持 iOS 的构建，所以需要添加 `MacOS` 的 `Slave`。

## 开启 Slave 的 SSH 远程登录

在 MacOS 的 `设置` -> `共享` 中如下设置：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/55370715-0018e980-552e-11e9-997c-7b55b17b785d.png" width="600px">
</div>

## 配置权限


在 `Master` 上复制 ssh（`~/.ssh/id_rsa`） 的 `private key`。

增加到 jenkins 的 `Credentials` 中：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/55369900-11142b80-552b-11e9-9e06-3373884b84c0.png" width="800px">
</div>

选择 `SSH Username with private key`，`Private Key` 勾选 `Enter directly`，把 `Master` 的 `private key` 复制进去。

复制 `Master` ssh（`~/.ssh/id_rsa.pub`）的 `public key`

在 `Slave(MacOS)` 中新建 `~/.ssh/authorized_keys`，把 `Master` 的 `public key` 复制进去。

## 在 Jenkins 上增加 Node

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/55370117-0017ea00-552c-11e9-8e83-94075d37092e.png" width="800px">
</div>

如上：

`Node Name` 随意。

选择 `Permanent Agent`。

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/55370326-b4197500-552c-11e9-8ba1-d617b9eff459.png" width="800px">
</div>

- `Name`、`Description` 随意。
- `# of executors`：表示构建并发数，具体视 Slave 的硬件配置决定。
- `Remote root directory`：Slave 的 workspace
- `Labels`：可用于在 Job 中通过该 Label 来指定运行在哪个节点上。
- `Launch method`：选择 `Launch agent agents via SSH`。
    - `Host`：Slave 的 host
    - `Credentials`：选择刚刚创建的 Credential。
- `Node Node Properties`：如果需要配置该 Slave 的环境变量，可以在这里配置。


## 启动节点

保存完毕后，点击 `Launch` 成功后如下：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/55370854-91885b80-552e-11e9-94a7-88af5907f341.png" width="800px">
</div>