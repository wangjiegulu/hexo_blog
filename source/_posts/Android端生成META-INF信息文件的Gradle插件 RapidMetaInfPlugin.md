---
title: Android端生成META-INF信息文件的Gradle插件 RapidMetaInfPlugin
tags: ["android", "gradle", "gradle plugin", "Android Studio", "META-INF"]
categories: ["android", "gradle plugin"]
---

# Android端生成META-INF信息文件的Gradle插件 RapidMetaInfPlugin

## 1. 需求背景

最近新遇到了一个需求，想在自己的一些库中写入版本信息，在别人使用了我的库后，我可以通过apk文件检测出依赖了我的哪个版本的库。感觉这个需求有点多余？那就举个例子吧。

比如，我编写了一个开源库：[RapidORM](https://github.com/wangjiegulu/RapidORM)，并[上传到了Maven中心库](http://blog.wangjiegulu.com/2015/04/02/Android-%E4%BD%BF%E7%94%A8Gradle%E6%8F%90%E4%BA%A4%E8%87%AA%E5%B7%B1%E5%BC%80%E6%BA%90Android%E5%BA%93%E5%88%B0Maven%E4%B8%AD%E5%BF%83%E5%BA%93/) ，假设一个我不认识的开发者（暂且称它为`X`）在编写app，这个app中的代码对我来说是完全未知的，但是他通过在`build.gradle`中添加了如下依赖：

```groovy
compile "com.github.wangjiegulu:rapidorm:1.0.0"
compile "com.github.wangjiegulu:rapidorm-api:1.0.0"
apt "com.github.wangjiegulu:rapidorm-compiler:1.0.0"
```

很明显，`X`依赖了我写的`RapidORM`库。并且打包成了Apk文件然后发布。这时我下载了这个apk，并且希望得到这个apk中依赖的`RapidORM`版本是多少？这个`RapidORM`在构建这个aar时的开发环境是怎么样的？反编译可能有希望能拿到`RapidORM`具体的版本号，但是aar当时的构建环境就无法得知了。

这时，我就希望在我发布`RapidORM`的Release版本的时候能够在aar中携带好一些自定义的参数，并且这些信息会在依赖了这个库的开发者`X`构建apk的时候跟随保存到apk文件中。

比较典型的一个例子当你依赖了`RxJava`这个库，我们构建apk完成之后，会发现在我们的apk文件中的`META-INF`文件夹下面会有一个`rxjava.properties`文件，打开这个文件就会发现如下内容：

```
Manifest-Version=1.0
Implementation-Title=io.reactivex.rxjava2#rxjava;2.1.2
Implementation-Version=2.1.2
Built-Status=integration
Built-By=travis
Built-OS=Linux
Build-Date=2017-07-23_08:21:58
Gradle-Version=2.14
Module-Owner=benjchristensen@netflix.com
Module-Email=benjchristensen@netflix.com
Module-Source=
Module-Origin=https://github.com/ReactiveX/RxJava.git
Change=e4fbe4c
Branch=e4fbe4cfcb3c240d14a42a586eecbbd74cb379d2
Build-Host=testing-gce-361876de-b66f-4569-b841-e037b0fee9af
Build-Job=LOCAL
Build-Number=LOCAL
Build-Id=LOCAL
Created-By=1.7.0_80-b15 (Oracle Corporation)
Build-Java-Version=1.7.0_80
X-Compile-Target-JDK=1.6
X-Compile-Source-JDK=1.6
```

很显然，这个文件中包含了：`RxJava版本号`, `构建的CI信息`，`构建时间`, `Gradle版本`, `模块负责人信息`, `git分支`, `JDK版本`等等。

通过这个方式，我可以在任意的apk中拿到它依赖的`RxJava`的信息。

当然，你可以通过在`build.gradle`进行如下配置来过排除这个`rxjava.properties`文件（但是不建议这么做，这个文件也许能在你遇到问题时给你帮助）：

```groovy
android {
    ...
    packagingOptions {
        exclude 'META-INF/rxjava.properties'
    }
}
```

## 2. RapidMetaInfPlugin Gradle 插件

> **RapidMetaInfPlugin:** <https://github.com/wangjiegulu/RapidMetaInfPlugin>

因此，写了 [RapidMetaInfPlugin](https://github.com/wangjiegulu/RapidMetaInfPlugin) 这个 Gradle 插件。

这次先说说怎么使用这个插件，以后抽时间再写一篇 Gradle 插件编写教程。之前也写过一个Gradle插件（详情见[Android Gradle 插件 DiscardFilePlugin（清空类和方法）](http://blog.wangjiegulu.com/2017/04/19/Android-Gradle-%E6%8F%92%E4%BB%B6-DiscardFilePlugin%EF%BC%88class%E6%B3%A8%E5%85%A5-%E6%B8%85%E7%A9%BA%E7%B1%BB%E5%92%8C%E6%96%B9%E6%B3%95%EF%BC%89/)）也挺实用的。

### 2.1 最终效果

通过这个插件，我们可以在`apk`或者`aar`（`app`依赖后合并到`apk`）中写入任意信息。

<img src="https://github.com/wangjiegulu/RapidMetaInfPlugin/raw/master/images/apk_meta_inf.png" width=600px />

以上在这个`apk`的`META-INF`中生成了一个名为`DAL_REQUEST.properties`的文件，内容中包含了`dal_request`这个库的名字、版本号和url。

### 2.2 如何使用

在你的`buildscript`的`dependencies`中添加`classpath`依赖（[点击这里获取最新版本](http://search.maven.org/#search%7Cga%7C1%7CRapidMetaInf)）：

```groovy
buildscript {
    repositories {
        jcenter()
        google()
    }
    dependencies {
        // ...
        classpath ('com.github.wangjiegulu:rapidmetainf:x.x.x'){
            exclude group: 'com.android.tools.build', module: 'gradle'
        }
    }
}
```

然后在你的apk或者aar的`build.gradle`文件的顶部写入以下代码来使用插件：

```groovy
apply plugin: 'com.github.wangjiegulu.plg.rapidmetainf'
```

然后通过如下方式填写你需要写进`META-INF`目录中的文件信息：

```groovy
rapidmetainf {
    metaInfName 'DAL_REQUEST.properties'
    metaInfProperties "archiveName=$dbarchiveName",
            "archiveVersion=$dbarchiveVersion",
            "archiveUrl=$dbarchiveUrl"
}
```

如上，`metaInfName`表示在`META-INF`目录中生成的文件名称（文件名任意取，但是不能以"."开头），`metaInfProperties`表示要写入文件的数据，这个变量为数组类型，可通过Groovy语法来编写，比如通过`$符号来引用ext`，通过如下命令参数的方式等等：

```groovy
rapidmetainf {
    metaInfName 'DAL_REQUEST_DEMO.properties'

    String[] infArray = new String[10]
    // ./gradlew clean build -PcommandKey=commandValue
    infArray[0] = "propertyFromCommand=${getParameter('commandKey')}"
    for(int i = 1; i < infArray.length; i++){
        infArray[i] = "array_item_key_$i=array_item_value_$i"
    }

    metaInfProperties infArray
}

def getParameter(String key) {
    // -D
    String value = System.getProperty(key)
    if (null != value && value.length() > 0) {
        return value
    }
    // -P
    if (hasProperty(key)) {
        return getProperty(key)
    }
    return null
}
```

以上，CI构建时就可使用命令`./gradlew clean build -PcommandKey=commandValue`来把`commandValue`写入到文件中。


