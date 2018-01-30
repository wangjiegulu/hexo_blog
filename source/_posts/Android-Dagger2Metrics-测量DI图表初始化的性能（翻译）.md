---
title: '[Android]Dagger2Metrics - 测量DI图表初始化的性能（翻译）'
tags: [android, dagger2, memory, DI, dependency injection, 翻译]
date: 2016-02-16 17:39:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5098943.html>
**</font>

# Dagger2Metrics - 测量DI图表初始化的性能

> 原文：<http://frogermcs.github.io/dagger2metrics-measure-performance-of-graph-initialization/>

几个月前我们通过 [Dagger 2 - graph creation performance] 经历了一些可能会遇到的问题。多亏 [TraceView] 这个工具我们可以很确切地看到初始化所有需要的依赖需要多少时间。但是这并不简单 - 我们必须要在我们代码中找出需要开始和停止测量的地方，然后在Android Studio中dump和分析它们。为了让它变得更简单，我们准备了一个简单的库，它可以帮助我们捕捉潜在的性能问题。

## Dagger2Metrics

### Dagger 2 初始化过程的性能测量库

_下面的描述内容是从 Dagger2Metrics Github [项目网站]拷贝过来的。_

如果你在Android应用中使用Dagger 2来进行依赖注入，你可能知道它最大的一处优化就是Google（原来是Square）的优秀工程师通过使用非反射代码实现。

即使有了所有的这些优化以及完全的非动态代码生成，但是仍然有潜在的性能问题隐藏在我们的代码中和所有通过Dagger 2注入的第三方代码中。

性能的问题通常是慢慢地变慢的，所以在每天的开发中是很难意识到我们的app（或者Activity、或者其他View）启动50ms或者更长。又一次变成150ms，又一次变成100ms...

使用Dagger2Metrics，你将可以看到初始化所有需要的依赖需要多少时间（以及这些依赖之间的依赖关系）。

![](https://raw.githubusercontent.com/frogermcs/dagger2metrics/master/art/dagger2metrics.png)

### 准备开始

在你的`build.gradle`中：

```groovy
buildscript {
  repositories {
    jcenter()
  }

  dependencies {
    classpath 'com.frogermcs.dagger2metrics:dagger2metrics-plugin:0.2'
  }
}

apply plugin: 'com.android.application'
apply plugin: 'com.frogermcs.dagger2metrics'
```

在你的`Application`类中：

```java
public class ExampleApplication extends Application {

 @Override
 public void onCreate() {
     super.onCreate();
     //Use it only in debug builds
     if (BuildConfig.DEBUG) {
         Dagger2Metrics.enableCapturing(this);
     }
  }
 }
```

这样就完成了。在你的app中，你将会看到notification，它可以打开所有已完成的初始化的一个简单的概述。

![](https://raw.githubusercontent.com/frogermcs/dagger2metrics/master/art/dagger2metrics-notification.png)

### 它是怎么工作的？

Dagger2Metrics会捕捉所有的初始化，通过 - 所有带有 `@Module` -> `@Provides` 注解的方法和`@Inject`注解的构造方法。

总之，你会看到大多数顶级注入依赖地依赖关系树。每一个依赖显示了提供这些对象到Dagger 2对象图表需要多少时间（构建本身所用时间以及所有的依赖）。

![](https://raw.githubusercontent.com/frogermcs/dagger2metrics/master/art/dagger2metrics.png)

### 为什么我看不到所有（子）依赖？

测量树不会显示那些已经提供给Dagger图表的依赖，所以只有从头开始构建的才会显示出来。主要是因为可读性以及另外一个简单的理由就是 - 我们不想在大多数没有错误的情况下去测量Dagger 2的性能。我们应该确保我们的代码尽可能快地提供依赖。

### 自定义

Dagger2Metrics 有3种默认级别的警告：

```
Dagger2Metrics.WARNING_1_LIMIT_MILLIS // 30ms
Dagger2Metrics.WARNING_2_LIMIT_MILLIS // 50ms
Dagger2Metrics.WARNING_3_LIMIT_MILLIS // 100ms
```

你可以根据你的需要对它们进行调整。

### 例子app

你可以查看 [GithubClient] 项目 - 一个展示怎么使用Dagger 2的Android app的例子。最近的版本在debug build中使用了Dagger2Metrics。

### 更多关于Dagger 2

如果你刚开始接触Dagger 2，下面的资源列表可以帮助你：

[GithubClient] - 基于Dagger 2依赖注入框架的Github API 客户端实现的例子。

Blog posts：

- [Dagger 1 to 2 migration process]
- [Introdution to Dependency Injection]
- [Dagger 2 API]
- [Dagger 2 - custom scopes]
- [Dagger 2 - graph creation performance]

### 代码：

以上描述的完整代码可见Github [repository]。

## 作者

[Miroslaw Stanek](http://about.me/froger_mcs)

Head of Mobile Development @ [Azimo](https://azimo.com/)

> __[Android]使用Dagger 2依赖注入 - DI介绍（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/5092083.html>

> __[Android]使用Dagger 2依赖注入 - API（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/5092525.html>

> __[Android]使用Dagger 2依赖注入 - 自定义Scope（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/5095426.html>

> __[Android]使用Dagger 2依赖注入 - 图表创建的性能（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/5098943.html>

> __[Android]Dagger2Metrics - 测量DI图表初始化的性能（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/5193437.html>

> __[Android]使用Dagger 2进行依赖注入 - Producers（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/6234811.html>

> __[Android]在Dagger 2中使用RxJava来进行异步注入（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/6236646.html>

> __[Android]使用Dagger 2来构建UserScope（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/6237731.html>

> __[Android]在Dagger 2中Activities和Subcomponents的多绑定（翻译）:__

<http://www.cnblogs.com/tiantianbyconan/p/6266442.html>

[Dagger 2 - graph creation performance]: http://frogermcs.github.io/dagger-graph-creation-performance/
[TraceView]: http://tools.android.com/tips/traceview
[项目网站]: https://github.com/frogermcs/dagger2metrics
[GithubClient]: https://github.com/frogermcs/githubclient
[Dagger 1 to 2 migration process]: http://frogermcs.github.io/dagger-1-to-2-migration/
[Introdution to Dependency Injection]: http://frogermcs.github.io/dependency-injection-with-dagger-2-introdution-to-di/
[Dagger 2 API]: http://frogermcs.github.io/dependency-injection-with-dagger-2-the-api/
[Dagger 2 - custom scopes]: http://frogermcs.github.io/dependency-injection-with-dagger-2-custom-scopes/
[Dagger 2 - graph creation performance]: http://frogermcs.github.io/dagger-graph-creation-performance/
[repository]: https://github.com/frogermcs/GithubClient

