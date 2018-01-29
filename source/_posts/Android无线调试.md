---
title: Android无线调试
tags: []
date: 2014-06-07 18:33:00
---

方法一：

1\. 使用USB数据线连接设备。

2\. 命令输入adb tcpip 5555 ( 5555为端口号，可以自由指定）。

3\. 断开 USB数据，此时可以连接你需要连接的|USB设备。

4\. 再命令输入 adb connect &lt;设备的IP地址&gt;:5555

后面就可以使用ADB ，DDMS 来调试Android应用或显示Logcat 消息。

5\. 如果需要恢复到USB数据线，可以在命令行输入adb usb

注： Android设备的IP地址可以在Settings-&gt;About Phone-&gt;Status 查到

参考：http://blog.csdn.net/daditao/article/details/19077281

&nbsp;

方法二：

<span>首先让手机与电脑处于同一局域网下，然后下载一款名为adbWireless的应用（到Google Play商店可以搜索到），下载安装后运行软件，会显示手机在当前局域网的IP地址和端口（前提是手机需要ROOT），然后可以看到手机出现了IP地址和端口号。</span>

<span><span>随后打开命令行，进入安装SDK的目录中platform-tools文件夹并输入：adb connect 手机IP地址（我的是192.168.1.110）</span></span>

&nbsp;

&nbsp;