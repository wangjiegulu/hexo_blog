---
title: 'IFCTT，即If Copy Then That，一个基于IFTTT的`This`实现'
subtitle: "IFTTT的扩展app"
date: 2017-12-20 12:41:00
tags: [ifttt, ifctt, android, automate, huginn, hash tag, google play, clipboard]
header-img: "img/xingkong.jpg"
---

IFCTT，即：`If Copy Then That`，是一个基于IFTTT（`If This Then That`）的"This"实现，它打通了"用户手机端操作"与"This条件触发"之间的桥梁，让这个过程更具方便性和快捷性。通过手机端的Copy动作，以"Tagged Email"的方式连接到IFTTT，从而触发IFTTT中所有支持的"That"行为。用户只需要复制然后选择触发IFTTT的"Hash Tag"即可，它支持用户配置多种"Hash Tag"来进行多种自定义方式内容传输，比如：

- 手机端执行拷贝Url地址（随时随地，任何地方，如Twitter/Facebook/Instagram/wechat/weibo/blog...），一键通过IFCTT & IFTTT，保存链接对应的文章到Instapaper/Pocket，最低成本实现Read it later
- 手机端执行拷贝文章内容，一键通过IFCTT & IFTTT，保存发送对应的内容到Evernote/Google doc/kindle...
- 等等

使用IFCTT需要以下几个条件：

- 你需要拥有IFTTT账号，并开启相应的Applets
- 你需要使用与IFTTT相同的Email账号在IFCTT中进行smtp授权和配置

首先，下载安装IFCTT App<font color="#FF2D51">（12月21日～12月28日圣诞节免限中）</font>：

<font color="#FF2D51">**Google Play：<https://play.google.com/store/apps/details?id=com.wangjie.ifctt>**</font>

<!-- more -->

## IFCTT Email配置

> **根据你在IFTTT使用的邮箱来进行配置(推荐使用Gmail)**

### 1. Gmail邮箱配置
<span id="app_password"/>
### 1.1 生成应用专用密码

首先需要为IFCTT生成一个App专用密码，打开以下链接并登陆Google账号：

<https://support.google.com/accounts/answer/185833>

选择app为`Mail`：

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_email_configuration/app_password_01.png" width=700px/>

选择设备为`Other (Custom name)`：

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_email_configuration/app_password_02.png" width=700px/>

然后在输入框中填入`IFCTT`：

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_email_configuration/app_password_03.png" width=700px/>

然后，点击`GENERATE`：

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_email_configuration/app_password_04.png" width=700px/>

**以上黄色区域中的16个字符的密码就是我们需要的专用密码，选中复制**

### 1.2 在IFCTT中配置Gmail

打开IFCTT，进入`Settings` -> `Email Configuration` 并填写相关信息：

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_email_configuration/ifctt_email_configuration_01.png" width=400px/>

> **注意**：
> 
> **password**：为[1.1 生成应用专用密码](#app_password)中生成的应用专用密码
> **Extra properties**：如果你使用的是Gmail邮箱，则内容不需要改动，保持最初始的状态即可



## 怎么使用IFCTT自带默认的Hash tags


在安装完IFCTT之后，首次进入，app会自动帮你创建以下5个默认的Hash tags：

- **\#instapaper**：这个标签会使得当你复制了文本内容时，此标签会识别当前复制的内容，如果是链接，则通过IFTTT推送到你的`instapaper`
- **\#box**：这个标签会使得当你复制了文本内容时，此标签会通过IFTTT推送到你的box，把内容追加保存在box的路径为`IFTTT/Email/IFCTT`的文件中
- **\#evernote**：这个标签会使得当你复制了文本内容时，此标签会通过IFTTT推送到你的`evernote`，把内容追加保存在`evernote`的名为`IFTTT/Email/IFCTT`的文件中
- **\#pocket**：这个标签会使得当你复制了文本内容时，此标签会识别当前复制的内容，如果是链接，则通过IFTTT推送到你的`pocket`
- **\#googledoc**：这个标签会使得当你复制了文本内容时，此标签会通过IFTTT推送到你的`google docs`，把内容追加保存在`google docs`的名为`IFTTT/Email/IFCTT`的文件中

第一次进入后，所有的Hash tags都是默认`OFF`状态的，如下图所示：

<img src='http://blog.wangjiegulu.com/web/ifctt/ifctt_use_default_hash_tags/hash_tag_disabled.png' width=350/>

下面以开启`instapaper`这个Hash tag为例

首先点击进入`#instapaper`的编辑页面，如下图：

<img src='http://blog.wangjiegulu.com/web/ifctt/ifctt_use_default_hash_tags/instapaper_detail.png' width=350/>

首先如上图中，先点击开启按钮

然后因为默认的Hash tag所对应的`IFTTT Applet`都已经创建好了，所以可以直接进入IFTTT的Applet界面添加并开启，如上图，点击红色字体部分或者`IFTTT`的图标，将会打开如下`IFTTT`的Applet界面：

<img src='http://blog.wangjiegulu.com/web/ifctt/ifctt_use_default_hash_tags/ifttt_instapaper_applet.png' width=350/>

点击开启图标，这时IFTTT可能会让你绑定你的instapaper账号，按照流程正常绑定即可（如果以前已经绑定过了则不需要再次绑定），操作完毕后，IFTTT的instapaper applet就会开启。

最后返回到IFCTT `#instapaper`的编辑页面，点击右上角进行保存，成功后回到首页，instapaper的card将会变成彩色。

其他IFCTT自带默认的Hash tags开启方式都类似。


## 创建自定义的Hash tags


除了[使用IFCTT提供的默认Hash tags](http://blog.wangjiegulu.com/web/ifctt/ifctt_use_default_hash_tags/ifctt_use_default_hash_tags.md)之外，你还可以创建自己的Hash tags，现在我们来创建一个Hash tags实现如下功能：

```
当你复制了一段文字后，点击此标签后，自动通过IFTTT在你的`Twitter`上发送一条推特
```

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_create_custom_hash_tags/main_hash_tag.png" width=350/>

点击首页右上角的`+`按钮，添加一个Hash tag，

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_create_custom_hash_tags/new_twitter_hash_tag.png" width=350/>

<span id="tag_twitter"/>
如上，填写`tag`为`twitter`（可以自己任意填写）和note（任意填写），除了填写以上信息，还需要在IFTTT中创建对应的`IFTTT Applet`，点击上图红色字或者IFTTT的图标，即会进入到IFTTT界面，点击下图顶部的`+`按钮来创建`IFTTT Applet`：

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_create_custom_hash_tags/ifttt_my_applet.png" width=350/>

`this`（trigger）选择`Email`，并选择**`Send IFTTT an email tagged`**（必须）：

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_create_custom_hash_tags/ifttt_this_twitter.png" width=350/>

上图中的`Tag`输入为`twitter`（[必须要与IFCTT中的一致](#tag_twitter)！），

`that`（action）选择`Twitter`，并选择**`Post a tweet`**，然后设置如下：

<img src="http://blog.wangjiegulu.com/web/ifctt/ifctt_create_custom_hash_tags/ifttt_post_a_tweet.png" width=350/>

上面中的`body`就是指的就是IFCTT中的复制内容

提交成功后，返回到IFCTT中的创建页面提交，这时Hash tag创建成功

