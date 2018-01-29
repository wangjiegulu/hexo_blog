---
title: '[Android]Activity启动过程'
tags: []
date: 2015-11-10 13:25:00
---

### Android系统启动加载流程：

[参考图](http://i11.tietuku.com/0582844414810f38.png)

- Linux内核加载完毕 
- 启动`init`进程 
- `init`进程fork出`zygote`进程
- `zygote`进程在`ZygoteInit.main()`中进行初始化的时候fork出`SystemServer`进程
- `SystemServer`进程开启的时候初始化`ActivityThread`和`ActivityManagerService`（其它还有`PowerManagerService`，`DisplayManagerService`，`PackageManagerService`）
- 启动`Launcher`，`Launcher`本质上也是一个App，继承自`Activity`

### App与AMS通过Binder进行IPC通信

#### 启动一个Activity
> 客户端：ActivityManagerProxy --> Binder驱动 --> ActivityManagerService：服务器

- __ActivityThread__
老板，虽然说家里的事自己说了算，但是需要听从AMS的指挥
- __Instrumentation__
老板娘，负责家里的大事小事，但是一般不抛头露面，听一家之主ActivityThread的安排，每个Activity都有一个`Instrumentation`引用，整个进程只有一个`Instrumentation`实例
- __ActivityManagerProxy__
ActivityManagerNative.getDefault().startActivity获取`ActivityManagerProxy`对象通过Binder IPC与AMS通信
- __AMS__
真正启动一个Ativity（`ActivityStackSupervisor`, `ActivityStack`）

#### Resume一个Activity
> 客户端：ApplicationThread <-- Binder驱动 <-- ApplicationThreadProxy：服务器

- __AMS__
- __ApplicationThreadProxy__
`ApplicationThreadProxy`对象通过Binder IPC与客户端通信。
- __ApplicationThread__
- __Handler__
- __ActivityThread__
- __Activity__
调用onResume方法

### AMS(SystemServer进程)与zygote通过Socket进行IPC通信

参考：http://blog.csdn.net/zhaokaiqiang1992/article/details/49428287