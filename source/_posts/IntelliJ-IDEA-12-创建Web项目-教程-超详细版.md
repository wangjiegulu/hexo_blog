---
title: IntelliJ IDEA 12 创建Web项目 教程 超详细版
tags: []
date: 2013-05-18 11:00:00
---

IntelliJ IDEA 12&nbsp;新版本发布 第一时间去官网看了下&nbsp;&nbsp;黑色的主题 很给力 大体使用了下&nbsp;&nbsp;对于一开始就是用eclipse的童鞋们

估计很难从eclipse中走出来&nbsp;当然 我也很艰难的走在路上 ...

**<span>首先要说一点，在IntelliJ IDEA里面&ldquo;new Project&rdquo; 就相当于我们eclipse的&ldquo;workspace&rdquo;，而&ldquo;new Module&rdquo;才是创建一个工程。</span>**

**<span>这个和Eclipse有很大的区别</span>**

&nbsp;

**1.官网下载下来的默认不是黑色的主题&nbsp;这里需要修改一下&nbsp;工具栏上的扳手图标 或者是用ctrl+alt+s打开设置窗口**

**在打开窗口的左侧&nbsp; 找到Appearance&gt;Theme 选择Darcula主题 应用&nbsp; 重启就ok了**

**2.中文乱码问题&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 软件无论是打开项目空间还是其他的&nbsp;&nbsp;&nbsp;&nbsp; 字体显示不全 中文都是口口&nbsp;**

**解决方法:**

**Appearance&gt;Override default fonts by(not recommended)&nbsp;前面打勾**

**此时下方的name下拉框为可选状态&nbsp;&nbsp;找到Name:DialogInput.plain - Size:12&nbsp;&nbsp; 应用就ok了**

&nbsp;

**下面开始一步步的来创建一个web项目**

<span>**1.首先 创建一个Project&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;****也就是项目空间**</span>

**![](http://images.cnitblog.com/blog/355865/201301/29152002-599bc4776245421f9309c080241deb40.gif)**

2.选择项目类型&nbsp;这里选Java Module&nbsp; 自定义工作空间名称 和路径

![](http://images.cnitblog.com/blog/355865/201301/29152128-8f769e2278e0466082619fa750448237.png)

3.选择需要用到的框架组件&nbsp;这里只选了第一个&nbsp;Web Application &gt; Finish

![](http://images.cnitblog.com/blog/355865/201301/29152333-404c8da875d945ec845fbec85b3c5b36.gif)

4.创建完工作空间&nbsp;默认会是一个Module也就是一个项目 但是不推荐使用该项目进行开发

![](http://images.cnitblog.com/blog/355865/201301/29152650-dab203ebafa04bddbcb6be16ebfa5ee1.png)

5.在该项目空间中&nbsp;添加新的工程 选中工作空间&nbsp;右键Open Module Settings 或者是按下F4

![](http://images.cnitblog.com/blog/355865/201301/29153307-89ea6cef216f45319017b50159edd604.png)

6.添加工程

![](http://images.cnitblog.com/blog/355865/201301/29154653-eda8d28c584048b6b346d7514ba3d515.png)

&nbsp;

**![](http://images.cnitblog.com/blog/355865/201301/29154807-49eacbe0dc524460b3f177b6a2668b34.png)**

然后Finish&nbsp;&nbsp;找到新建工程的web&gt;WEB-INF下创建&nbsp;classes 和lib文件夹&nbsp;

![](http://images.cnitblog.com/blog/355865/201301/29155004-ac0e1d8b9d6f4edb99597a88db0f136f.png)

修改编译输出目录&nbsp; Paths&gt;Use module compile output path 转到自定义的classes文件夹

![](http://images.cnitblog.com/blog/355865/201301/29155259-15fc13084bea4b95936b158d6f546473.png)

同样可以指定lib库目录&nbsp;&nbsp;添加&gt;jars or directories 指向创建的lib文件夹&nbsp; 弹出窗口选择jar directory![](http://images.cnitblog.com/blog/355865/201301/29155450-beee086f18d148ebb5480a7686cc9b8f.png)

&nbsp;

接下来&nbsp;部署测试&nbsp; 配置tomcat服务器&nbsp; 点击图&nbsp;箭头方向 那个下拉地方&nbsp;有个编辑服务器的 弹出右侧窗口

点击绿色的添加按钮 &gt;&nbsp;选择tomcat服务器 &gt;local

![](http://images.cnitblog.com/blog/355865/201301/29160928-b7ce076af8e949178a877ac0d554bd68.png)

选择部署的应用

![](http://images.cnitblog.com/blog/355865/201301/29162337-0e28706311fd4e34b8cc51c63b4cac58.png)

&nbsp;

![](http://images.cnitblog.com/blog/355865/201301/29162455-100451324e694e2f81aac0b53423ce0d.png)

&nbsp;

启动测试...

![](http://images.cnitblog.com/blog/355865/201301/29162525-3b11e6a77d8f42aeadd6beb5a7edf59e.png)

ok &gt;

![](http://images.cnitblog.com/blog/355865/201301/29162653-328ea1b084644954a1980cde7c504a3b.png)

转自&nbsp;[http://www.cnblogs.com/cnjava/archive/2013/01/29/2881654.html](http://www.cnblogs.com/cnjava/archive/2013/01/29/2881654.html)