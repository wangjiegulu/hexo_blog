---
title: '[Android Studio]SQLScout插件安装破解'
tags: []
date: 2016-10-18 09:49:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5972138.html>
**</font>

# [Android Studio]SQLScout插件安装破解

## 0\. 写在前面

想当初很长一段时间内不想用Android Studio而喜欢用Intellij IDEA（旗舰版）其中一个原因就是因为Intellij IDEA（旗舰版）自带`Database Explorer`功能便于调试，终于找到了这个Android Studio的插件可以用了，下载试用，满意！就是这个感觉！可惜需要付费，还有点小贵－－，囊中羞涩，所以只好亲自手动破解，大家好孩子别轻易尝试。。。

> **官网**：<http://www.idescout.com/download/>

## 1\. 安装SQLScout插件

1\. 打开`Android Studio`

2\. `Settings`(on Windows and Linux) or `Preferences`(Mac) 

3\. `Plugins`

4\. `Browse Repositories...`
![](http://www.idescout.com/wp-content/uploads/2015/07/install_sqlscout_2.png)

5\. 选择`SQLScout`并安装

## 2\. 激活SQLScout

在试用期过后，需要购买一个商业证书来激活SQLScout。

![](http://www.idescout.com/wp-content/uploads/2015/07/activate1-300x70.png)

通过这里 [购买商业证书] (https://www.idescout.com/secure/buy)，然后点击`Activate`按钮。

![](http://www.idescout.com/wp-content/uploads/2015/07/activate3-e1464220867433.png)

## 3\. 破解

> **注意：**以下破解只供学习讨论，请勿传播

### 3.1 破解SQLScout

通过前面的方法安装SQLScout插件之后，进入Intellij IDEA插件安装目录：

```
~/Library/Application Support/AndroidStudiox.x/SQLScout/lib/
```

反编译`SQLScout.jar`

进入`com/idescout/sqlite/license/`，使用`javassist`修改`License.class`如下：

```java
ClassPool pool = ClassPool.getDefault();
CtClass c = pool.get("com.idescout.sqlite.license.License");
CtMethod m1 = c.getDeclaredMethod("isValidLicense");
m1.setBody("{ return true; }");

CtMethod m2 = c.getDeclaredMethod("isValidLicense", new CtClass[]{pool.makeClass("com.intellij.openapi.project.Project")});
m2.setBody("{ return true; }");

c.writeFile();
```

编译后复制`License.class`文件，替换原来的`License.class`。

然后`jar cvf SQLScout.jar ./*`打包jar。

最后替换`~/Library/Application Support/AndroidStudio/SQLScout/lib/`下的`SQLScout.jar`文件，重启Android Studio。

### 3.3 破解文件下载

> 使用方式，下载下面的`SQLScout.jar`和`SQLScout_console_part.jar`，替换`~/Library/Application Support/AndroidStudio../SQLScout/lib/SQLScout.jar`文件，重启`AndroidStudio`即可。

#### SQLScout 2.0.8: 

> 支持Android Studio 2.3

**下载：**

<https://github.com/wangjiegulu/wangjiegulu.github.com/tree/master/file/SQLScout/2.0.8>

#### SQLScout 2.0.7: 

> 支持Android Studio 2.2

**下载：**

<https://github.com/wangjiegulu/wangjiegulu.github.com/tree/master/file/SQLScout/2.0.7>