---
title: '[Android]官网《UI/Application Exerciser Monkey》中文翻译'
tags: []
date: 2015-12-15 18:11:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5049041.html>
**</font>

翻译自 Android Developer 官网：<http://developer.android.com/tools/help/monkey.html>

# UI/Application Exerciser Monkey

Monkey是一个程序，它会运行在你的[模拟器](http://developer.android.com/tools/help/emulator.html)或者设备上并且会产生伪随机的用户事件流，比如点击、触摸或手势，以及大量的系统级的事件。你可以使用Monkey来对你开发的应用程序以随机和重复的方式来进行压力测试。

## 概述

Monkey是一个命令行工具，你可以在模拟器或者设备上运行它。它发送伪随机的用户事件流到系统，它可以作为你开发的应用程序的压力测试。

Monkey包含很多的选项，但是总结成四种主要的种类：

- 基础配置选项，比如设置试图尝试的事件数量。

- 操作限制，比如限制在单个包中测试。

- 事件类型和频率。

- debugging选项。

当Monkey运行时，它会产生事件并把它们发送到系统。它也需要在测试下观察系统并寻找需要它特别处理的三种情况：

- 如果你限制Monkey运行在一个或者多个指定的包下，它会观察导航到其他包的事件，并且拦截它们。

- 如果你的应用程序崩溃或者接收到了任何形式的未处理的异常，Monkey会停止并且报告错误。

- 如果你的应用程序产生了applicaiton not responding（ANR）错误，Monkey会停止并且报告错误。

根据你所选择的详细程度，你还可以看到Monkey的进度报告和正在生成的事件。

## Monkey的基本使用

你可以使用你开发机器上的命令行或者选择一个脚本来启动Monkey。因为Monkey运行在模拟器/设备环境，你必须通过这个环境的shell来启动它。你可以在每句命令前加上`adb shell`，或者进入shell并直接使用Monkey命令。

基本的语法是：

```
$ adb shell monkey [options] <event-count>
```

不使用任何选项指定，Monkey会以一种安静的模式启动，然后发送事件到任何（所有）你目标设备上安装的包中。这里有一个更加典型的命令行，它会启动你的应用程序，然后发送500个伪随机的事件给它：

```
$ adb shell monkey -p your.package.name -v 500
```

## 命令选项参考

|分类|选项|描述
|---|---|---|
|普通|`--help`|打印出一个简单的使用指南
||`-v`|命令行中的每一个-v都会增加详细程度。Level 0（默认）会在启动通知、测试完成、最后结果时提供少量的信息。Level 1提供更多测试运行时的细节，比如每个发送到你activities的事件。Level 2提供更详细的设置信息，比如测试时activitues选择的或者未选择的。
|事件|`-s <seed>`| 伪随机数字生成器种子。如果你使用相同的seed值重新运行Monkey，它会产生相同序列的事件
||`--throttle <milliseconds>`| 在事件之间插入一个固定的延迟。你可以使用这个选项来让Monkey减速。如果没有指定，事件就没有任何延迟，事件会尽可能快地生成。
||`--pct-touch <percent>`| 调整触摸事件的百分比。（触摸事件是一个在屏幕单个位置的down-up事件。）
||`--pct-motion <percent>`|调整移动事件的百分比。（移动事件组成：屏幕上的一个down事件，一系列的伪随机移动事件，和一个up事件。）
||`--pct-trackball <percent>`|调整轨迹球事件的百分比。（轨迹球事件组成：一个或者多个随机移动，有时跟随一个点击事件。）
||`--pct-nav <percent>`|调整“basic”导航事件的百分比。（导航事件组成：up/down/left/right，作为一个方向输入设备输入。）
||`--pct-majornav <percent>`|调整“major”导航事件的百分比。（这些导航事件比较典型的是由你的UI引发的行为，比如5-way pad中间按钮、返回键或者菜单键。）
||`--pct-syskeys <percent>`|调整“system”按键事件的百分比。（这些按键一般都是被系统保留的，比如Home、返回、拨打电话、挂电话、音量控制。）
||`--pct-appswitch <percent>`|调整Activity启动的百分比。在一个随机的间隔，Monkey会调用startActivity()方法，最大限度地覆盖到你包里的所有Activity。
||`--pct-anyevent <percent>`|调整其它事件类型的百分比。它会包含所有类型的事件，比如按键，其它很少使用的设备按钮等等。
|限制|`-p <allowed-package-name>`|如果你使用这个方式指定了一个或者多个包，Monkey将会只允许系统访问这些包中的Activities，如果你的应用程序需要访问其它包（比如，选择一个联系人），你也同样需要指定这些包。如果你不指定任何包，Monkey会允许系统启动所有包中的activities。要指定多个包，就多次使用`-p`—— 每一个包使用一个`-p`。
||`-c <main-category>`|如果使用这个方式指定了一个或者多个`categories`，Monkey会只允许系统访问指定`categories`列表中任意一个`category`的Activities。如果你没有指定任何`categories`，Monkey会查询`Intent.CATEGORY_LAUNCHER`或者`Intent.CATEGORY_MONKEY`。要指定多个`category`，就多次使用`-c`—— 每一个`category`使用一个`-c`。
|调试|`--dbg-no-events`|当这个被指定时，Monkey会执行初始化启动一个测试activity，但是不会再进一步产生任何事件了。最好的方式是结合`-v`，一个或者多个包限制和非零的间隔来保持Monkey运行30秒或者更高。这样它就提供了一个可以监视应用程序调用包之间的转换过程的环境。
||`--hprof`|如果设置，这个选择会在Monkey事件序列之前和之后都会生成分析报告。这个会生成一个大文件（~5Mb）在`/data/misc`目录下，所以需要小心使用。更多追踪文件信息见[Traceview](http://developer.android.com/tools/debugging/debugging-tracing.html)。
||`--ignore-crashes`|通常情况下，Monkey会在应用程序崩溃或者遭遇到未处理的异常时停止运行。如果你设置了设个选项，Monkey将会继续发送事件到系统，直到完成所有。
||`--ignore-timeouts`|通常情况下，Monkey会在应用程序崩溃或者遭遇到类型为超时的异常如"Application Not Responding"对话框时停止运行。如果你指定了这个选项，Monkey将会继续发送事件到系统，直到完成所有。
||`--ignore-security-exceptions`|通常情况下，Monkey会在应用程序崩溃或者遭遇到类型为权限错误的异常时停止运行，如试图去启动一个需要确定权限的Activity时。如果你指定了这个选项，Monkey将会继续发送事件到系统，直到完成所有。
||`--kill-process-after-error`|通常情况下，当Monkey由于一个错误而停止运行，出错的应用程序还会继续运行，如果你指定了这个选项，它会发一个信号来停止这个发生错误的进程。注意，在正常（成功）完成时，启动了的进程不会被关闭，设备只是在事件完成后简单地保持最后的状态。
||`--monitor-native-crashes`|观察和报告Android系统native代码引发的崩溃。如果`If --kill-process-after-error`被设置了，则整个系统就会被停止。
||`--wait-dbg`|停止Monkey的执行，直到有调试器跟它连接到。