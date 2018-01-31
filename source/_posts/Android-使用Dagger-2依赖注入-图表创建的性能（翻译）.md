---
title: '使用Dagger 2依赖注入 - 图表创建的性能（翻译）'
tags: [android, dagger2, DI, dependency injection, google, 翻译]
date: 2016-01-04 14:55:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5098943.html>
**</font>

# 使用Dagger 2依赖注入 - 图表创建的性能

> 原文：<http://frogermcs.github.io/dagger-graph-creation-performance/>

[#PerfMatters] - 最近非常流行标签，尤其在Android世界中。不管怎样，apps只需要正常工作就可以的时代已经过去了。现在所有的一切都应该是令人愉悦的，流畅并且快速。举个例子，Instagram [花费了半年的时间] 只是让app更加快速，更加美观，和更好的屏幕适配性。

这就是为什么今天我想去分享给你一些小的建议，它会在你app启动时间上有很大的影响（尤其是当app使用了一些额外库的时候）。

## 对象图表的创建

大多情况下，在app开发过程中，它的启动时间或多或少会增加。有时随着一天天地开发它是很难被注意到的，但是当你把第一个版本和你能找到的最近的版本比较时区别就会相对比较大了。

原因很可能就在于dagger对象图表的创建过程。

Dagger 2？你可能会问，确切地说 - 就算你移除了那些基于反射的实现方案，并且你的代码是在编译时期生成的，但是别忘了对象的创建仍然发生是在运行时。

对象（还有它的依赖）会在第一次被注入时创建。Jake Wharton 在Dagger 2演示中的一些幻灯片很清楚地展示了这一点：

以下表示在我们的 [GithubClient] 例子app中它是怎样的：

1\. App第一次（被kill之后）被启动。Application对象并没有`@Inject`属性，所以只有`AppComponent`对象被创建。
2\. App创建了`SplashActivity` - 它有两个`@Inject`属性：`AnalyticsManager`和`SplashActivityPresenter`。
3\. `AnalyticsManager`依赖已被创建的`Application`对象。所以只有`AnalyticsManager`构造方法被调用。
4\. `SplashSctivityPresenter`依赖：`SplashActivity`，`Validator`和`UserManager`。`SplashActivity`已被提供，`Validator`和`UserManager`应该被创建。
5\. `UserManager`依赖需要被创建的`GithubApiService`。之后`UserManager`被创建。
6\. 现在我们拥有了所有依赖，`SplashActivityPresenter`被创建。

![](http://frogermcs.github.io/images/18/graph.png)

有点混乱，但是就结果来说，在`SplashActivity`被创建之前（我们假设对象注入的操作只会在`onCreate()`方法中执行）我们必须要等待以下构造方法（可选配置）：

- `GithubApiService`（它也使用了一些依赖，如`OkHttpClient`，一个`RestAdapter`）
- `UserManager`
- `Validator`
- `SplashActivityPresenter`
- `AnalyticsManager`

一个接一个地被创建。

嘿，别担心，更复杂地图表也几乎被立即创建。

## 问题

现在让我们想象下，我们有两个外部的库需要在app启动时被初始化（比如，Crashlytics, Mixpanel, Google Analytics, Parse等等）。想象下我们的`HeavyExternalLibrary`看起来如下：

```java
public class HeavyExternalLibrary {

    private boolean initialized = false;

    public HeavyExternalLibrary() {
    }

    public void init() {
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        initialized = true;
    }

    public void callMethod() {
        if (!initialized) throw new RuntimeException("Call init() before you use this library");
    }
}
```

简单说 - 构造方法是空的，并且调用几乎不花费任何东西。但是有一个`init()`方法，它耗时500ms并且在我们使用这个库之前必须要被调用。确保在我们module的某处的某一时刻调用了`init()`：

```java
//AppModule

@Provides
@Singleton
HeavyExternalLibrary provideHeavyExternalLibrary() {
    HeavyExternalLibrary heavyExternalLibrary = new HeavyExternalLibrary();
    heavyExternalLibrary.init();
    return heavyExternalLibrary;
}
```

现在我们的`HeavyExternalLibrary`成为了`SplashActivityPresenter`的一部分：

```java
@Provides
@ActivityScope
SplashActivityPresenter
provideSplashActivityPresenter(Validator validator, UserManager userManager, HeavyExternalLibrary heavyExternalLibrary) {
    return new SplashActivityPresenter(splashActivity, validator, userManager, heavyExternalLibrary);
}
```

然后会发生什么？我们app启动时间需要500ms还多，只是因为`HeavyExternalLibrary`的初始化，这过程会在SplashActivityPresenter依赖图表创建中执行。

## 测量

Android SDK（Android Studio本身）给我们提供了一个随着应用执行的时间的可视化的工具 - [Traceview]。多亏这个我们可以看见每个方法花了多少时间，并且找出注入过程中的瓶颈。

顺便说一下，如果你以前没有见过它，可以在[Udi Cohen的博客]看下这篇Android性能优化相关的文章。

Traceview可以直接从Android Studio（Android Monitor tab -> CPU -> Start/Stop Method Tracing）启动，它有时并不是那么精确的，尤其是当我们尝试在app启动时点击`Start`。

对于我们而言，幸运的是当我们知道确切的需要被测量的代码位置时，有一个可以使用的方法。[Debug.startMethodTracing()]可以用来指定我们代码中需要被启动测量的位置。`Debug.stopMethodTracing()`停止追踪并且创建一个新的文件。

为了实践，我们测量了SplashActivity的注入过程：

```java
@Override
protected void setupActivityComponent() {
    Debug.startMethodTracing("SplashTrace");
    GithubClientApplication.get(this)
            .getAppComponent()
            .plus(new SplashActivityModule(this))
            .inject(this);
    Debug.stopMethodTracing();
}
```

`setupActivityComponent()`是在`onCreate()`中调用的。

文档结果被保存在`/sdcard/SplashTrace.trace`中。

在你的terminal中把它pull出来：

`$ adb pull /sdcard/SplashTrace.trace`

现在阅读这个文件所要做的全部事情只是把它拖拽到Android Studio：

![](http://frogermcs.github.io/images/18/trace.png)

你应该会看到类似以下的东西：

![](http://frogermcs.github.io/images/18/traceview.png)

当然，我们这个例子中的结果是非常清晰的：`AppModule_ProvideHeavyExternalLibraryFactory.get()`（HeavyExternalLibrary被创建的地方）花费了500ms。

真正好玩的地方是，缩放trace尾部的那一小块地方：

![](http://frogermcs.github.io/images/18/traceview2.png)

看到不同之处了吗？比如构建类：`AnalyticsManager`花了小于1ms。

如果你想看到它，这里有这个例子中的[SplashTrace.trace]文件。

## 解决方案

不幸的是，对于这类性能问题，有时并没有明确的回答。这里有两种方式会给我们很大的帮助。

### 懒加载（临时的解决方案）

首先，我们要思考是否你需要所有的注入依赖。也许其中一部分可以延迟一定时间后再加载？当然这并不解决真正的问题（UI线程将会在第一次调用Lazy<>.get()方法的时候阻塞）。但是在某些情况下对启动耗时有帮助（尤其是很少地方会使用到的一些对象）。查看[Lazy<>]接口文档获取更多的信息和例子代码。

简单说，每一个你使用`@Inject SomeClass someClass`的地方都可以替换成`@Inject Lazy<SomeClass> someClassLazy`（构造方法注入也是）。然后获取某个类的实例时必须要调用`someClassLazy.get()`。

### 异步对象创建

第二种选择（它仍然只是更多的想法而不是最终的解决方案）是在后台线程中的某处进行对象的初始化，缓存所有方法的调用并在初始化之后再回调它们。

这种方案的缺点是它必须要单独地准备我们要包含的所有类。并且它只有在方法调用可以被执行的将来（就像任何的analytics - 在一些事件被发生之后才可以），这些对象才可能正常工作。

以下就是我们的`HeavyExternalLibrary`使用这种解决方案后的样子：

```java
public class HeavyLibraryWrapper {

    private HeavyExternalLibrary heavyExternalLibrary;

    private boolean isInitialized = false;

    ConnectableObservable<HeavyExternalLibrary> initObservable;

    public HeavyLibraryWrapper() {
        initObservable = Observable.create(new Observable.OnSubscribe<HeavyExternalLibrary>() {
            @Override
            public void call(Subscriber<? super HeavyExternalLibrary> subscriber) {
                HeavyLibraryWrapper.this.heavyExternalLibrary = new HeavyExternalLibrary();
                HeavyLibraryWrapper.this.heavyExternalLibrary.init();
                subscriber.onNext(heavyExternalLibrary);
                subscriber.onCompleted();
            }
        }).subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).publish();

        initObservable.subscribe(new SimpleObserver<HeavyExternalLibrary>() {
            @Override
            public void onNext(HeavyExternalLibrary heavyExternalLibrary) {
                isInitialized = true;
            }
        });

        initObservable.connect();
    }

    public void callMethod() {
        if (isInitialized) {
            HeavyExternalLibrary.callMethod();
        } else {
            initObservable.subscribe(new SimpleObserver<HeavyExternalLibrary>() {
                @Override
                public void onNext(HeavyExternalLibrary heavyExternalLibrary) {
                    heavyExternalLibrary.callMethod();
                }
            });
        }
    }
}
```

当`HeavyLibraryWrapper`构造方法被调用，库的初始化会在后台线程（这里的`Schedulers.io()`）中执行。在此期间，当用户调用`callMethod()`，它会增加一个新的subscription到我们的初始化过程中。当它完成时（onNext()方法返回一个已初始化的HeavyExternalLibrary对象）被缓存的回调会被传送到这个对象。

目前为止，这个想法还是非常简单并且仍然是在开发之中。这里可能会引起内存泄漏（比如，我们不得不在callMethod()方法中传入一些参数），但一般还是适用于简单的情况下的。

### 还有其它方案？

性能优化的过程是非常孤独的。但是如果你想要分享你的ideas，请在这里分享吧。

感谢你的阅读！

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

[Lazy<>]: http://google.github.io/dagger/api/2.0/dagger/Lazy.html
[SplashTrace.trace]: https://github.com/frogermcs/frogermcs.github.io/raw/master/files/18/SplashTrace.trace
[Debug.startMethodTracing()]: http://developer.android.com/reference/android/os/Debug.html#startMethodTracing(java.lang.String)
[Udi Cohen的博客]: http://blog.udinic.com/2015/09/15/speed-up-your-app/
[Traceview]: http://tools.android.com/tips/traceview
[GithubClient]: https://github.com/frogermcs/GithubClient
[花费了半年的时间]: http://instagram-engineering.tumblr.com/post/97740520316/betterandroid
[#PerfMatters]: https://twitter.com/search?q=%23perfmatters
[repository]: https://github.com/frogermcs/GithubClient

