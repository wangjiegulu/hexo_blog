---
title: Android应用签名详解 Eclipse+ADT
tags: [android, apk, signature, eclipse, ADT]
date: 2012-03-03 17:35:00
---

很多开辟人员不熟悉打听apk文件为什么必须签名才干公布，其实签名并非从android平台开端，在畴昔从symbian os就开端须要签名才干公布，如许可以包管每个应用法度开辟商合法id，因为android平台没有uid3的限制，项目组开放商可能经由过程应用雷同的package name来混合调换已经安装的法度。不过今朝斗劲好的是android中所有的permission应用都是免费的，但从今朝git项目中呈现的certinstaller.git包不知道是不是和证书有关，而近几年symbian os从v9.0开端若是应用法度涉及敏感操纵须要capability才干使其真机顺利安装，同时项目组高等权限须要购买和symbian signed测试才干公布，包管体系的安然靠得住性，而这点android平台较为宽松。常规景象下从adb比如eclipse的adt插件安装到模仿器或真机的测试法度经过debug标识表记标帜签名，所以我们签名是都须要先创建key公钥经由过程rsa运算才实现加密。下面具体申明：

&nbsp;

**一、为什么要签名：**&nbsp;

&nbsp;

1、发送者的身份认证，因为开辟商可能经由过程应用雷同的Package Name来混合调换已经安装的法度，以此包管签名不合的包不被调换
2、包管信息传输的完全性，签名对于包中的每个文件进行处理惩罚，以此确保包中内容不被调换，防止交易中的狡赖产生，Market对软件的请求

&nbsp;

**二、签名的申明：**
1、所有的应用法度都必须稀有字证书，Android体系不会安装一个没稀有字证书的应用法度
2、Android法度包应用的数字证书可所以自签名的，不须要一个权势巨子的数字证书机构签名认证
3、若是要正式公布一个Android应用，必须应用一个合适的私钥生成的数字证书来给法度签名，而不克不及应用adt插件或者ant对象生成的调试证书来公布
4、&nbsp;数字证书都是有有效期的，Android只是在应用法度安装的时辰才会搜检证书的有效期。若是法度已经安装在体系中，即使证书过期也不会影响法度的正常功能
5、签名后需应用zipalign优化法度
6、Android将数字证书用来标识应用法度的作者和在应用法度之间建树信赖关系，而不是用来决意终极用户可以安装哪些应用法度

**1.Eclipse工程中右键工程，弹出选项中选择 android对象-生成签名应用包：**&nbsp;

![](http://pic-server2.byywee.com/M0/S580/580495-0.jpg)&nbsp;

**2.选择须要打包的android项目工程：**&nbsp;

![](http://pic-server2.byywee.com/M0/S580/580495-1.jpg)&nbsp;

**3.若是已有私钥文件，选择私钥文件 输入暗码，若是没有私钥文件见 第6和7步创建私钥文件：**&nbsp;

![](http://pic-server2.byywee.com/M0/S580/580495-2.jpg)&nbsp;

**4.输入私钥别号和暗码：**&nbsp;

![](http://pic-server2.byywee.com/M0/S580/580495-3.jpg)&nbsp;

**5.选择APK存储的地位，并完成设置 开端生成：**&nbsp;

![](http://pic-server2.byywee.com/M0/S580/580495-4.jpg)&nbsp;

**6.没有私钥文件的景象，创建私钥文件：**&nbsp;

![](http://pic-server2.byywee.com/M0/S580/580495-5.jpg)&nbsp;

**7.输入私钥文件所需信息，并创建：**&nbsp;

![](http://pic-server2.byywee.com/M0/S580/580495-6.jpg)

