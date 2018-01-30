---
title: '[Android]在Dagger 2中使用RxJava来进行异步注入（翻译）'
tags: [android, dagger2, DI, dependency injection, google, 翻译, RxJava, RxAndroid]
date: 2016-12-30 13:53:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/6236646.html>
**</font>

# 在Dagger 2中使用RxJava来进行异步注入

> 原文：<http://frogermcs.github.io/async-injection-in-dagger-2-with-rxjava>

几星期前我写了一篇关于在Dagger 2中使用*Producers*进行异步注入的[文章](https://medium.com/@froger_mcs/dependency-injection-with-dagger-2-producers-c424ddc60ba3)。在后台线程中执行对象的初始化又一个很好的优势 - 它负责实时（[每秒60帧](https://www.youtube.com/watch?v=CaMTIgxCSqU)可以保持界面流畅）绘制UI时不会在主线程中阻塞。

值得一提的是，缓慢的初始化过程并不是每个人都会觉得是个问题。但是如果你真的关心这个，所有外部库在构造以及在任何`init()`方法中进行磁盘/网络的操作会很常见。如果你不能确定这一点，我建议你尝试下[AndroidDevMetrics](https://github.com/frogermcs/AndroidDevMetrics) - 我的Android性能测量库。它会告诉你在app中需要花多少时间来显示特定的界面，还有（如果你使用了Dagger 2）在依赖图表中提供每个对象消耗了多少时间。

不幸的是Producers并不是为Android设计的，它有以下缺陷：

- 依赖使用了Guava（会引起64k方法问题，增加build时间）
- 并不是非常快的（注入机制会阻塞主线程几毫秒到几十毫秒的世界，这取决于设备）
- 不能使用@Inject注解（代码会有一点混乱）

虽然我们不能解决最后两个问题，但是第一个我们可以在Android Project中解决。

## 使用RxJava进行异步注入

幸运的是，有大量的Android开发者使用了RxJava（和[RxAndroid](https://github.com/ReactiveX/RxAndroid)）来在我们app中编写异步代码。让我们来尝试在Dagger 2中使用它来进行异步注入。

### 异步@Singleton注入

这是我们繁重的对象：

```java
@Provides
@Singleton
HeavyExternalLibrary provideHeavyExternalLibrary() {
    HeavyExternalLibrary heavyExternalLibrary = new HeavyExternalLibrary();
    heavyExternalLibrary.init(); //This method takes about 500ms
    return heavyExternalLibrary;
}
```

现在让我们来创建一个额外的`provide...()`方法，它返回一个`Observable<HeavyExternalLibrary>`对象，它会异步调用以下代码：

```java
@Singleton
@Provides
Observable<HeavyExternalLibrary> provideHeavyExternalLibraryObservable(final Lazy<HeavyExternalLibrary> heavyExternalLibraryLazy) {
    return Observable.create(new Observable.OnSubscribe<HeavyExternalLibrary>() {
        @Override
        public void call(Subscriber<? super HeavyExternalLibrary> subscriber) {
            subscriber.onNext(heavyExternalLibraryLazy.get());
        }
    }).subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread());
}
```

让我们逐行来分析：

- `@Singleton` - 记住这个很重要，`Observable`对象将会是一个单例，而不是`HeavyExternalLibrary`。Singleton也会阻止创建额外的Observable对象。
- `@Providers` - 因为这个方法是`@Module`注解了的类的一部分。你还记得[Dagger 2 API](http://frogermcs.github.io/dependency-injection-with-dagger-2-the-api/)吗？
- `Lazy<HeavyExternalLibrary> heavyExternalLibraryLazy`对象阻止Dagger（否则，在调用`provideHeavyExternalLibraryObservable()`方法调用的瞬间对象就会被创建）内部对HeavyExternalLibrary对象的初始化。
- `Observable.create(...)`代码 - 它将在每次这个Observable被订阅时通过调用`heavyExternalLibraryLazy.get()`返回`heavyExternalLibrary`对象。
- `.subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread());` - 默认情况下RxJava代码会在Observable被创建的线程中执行。这就是为什么我们要把执行移动到后台线程（这里的`Schedulers.io()`），然后在主线程中（`AndroidSchedulers.mainThread()`）观察结果。

我们的Observable像图表中其它对象一样被注入，但是`heavyExternalLibrary`对象本身将会延迟一点才可用：

```java
public class SplashActivity {

	@Inject
	Observable<HeavyExternalLibrary> heavyExternalLibraryObservable;

	//This will be injected asynchronously
	HeavyExternalLibrary heavyExternalLibrary; 

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate();
		//...
		heavyExternalLibraryObservable.subscribe(new SimpleObserver<HeavyExternalLibrary>() {
            @Override
            public void onNext(HeavyExternalLibrary heavyExternalLibrary) {
	            //Our dependency will be available from this moment
	            SplashActivity.this.heavyExternalLibrary = heavyExternalLibrary;
            }
        });
	}
}
```

### 异步新实例的注入

上面的代码展示了怎么去注入单例的对象。那如果我们想异步注入新的实例呢？

确认我们的对象不再使用了@Singleton注解：

```java
@Provides
HeavyExternalLibrary provideHeavyExternalLibrary() {
    HeavyExternalLibrary heavyExternalLibrary = new HeavyExternalLibrary();
    heavyExternalLibrary.init(); //This method takes about 500ms
    return heavyExternalLibrary;
}
```

我们`Observable<HeavyExternalLibrary>` provider方法也会有一点改变。我们不能使用`Lazy<HeavyExternalLibrary>`因为它只会在第一次调用`get()`方法的时候（详见[Lazy文档](http://google.github.io/dagger/api/latest/dagger/Lazy.html)）才会创建新的实例。

这里是更新后的代码：

```java
@Singleton
@Provides
Observable<HeavyExternalLibrary> provideHeavyExternalLibraryObservable(final Provider<HeavyExternalLibrary> heavyExternalLibraryProvider) {
    return Observable.create(new Observable.OnSubscribe<HeavyExternalLibrary>() {
        @Override
        public void call(Subscriber<? super HeavyExternalLibrary> subscriber) {
            subscriber.onNext(heavyExternalLibraryProvider.get());
        }
    }).subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread());
}
```

我们的`Observable<HeavyExternalLibrary>`可以是一个单例，，但是每一次我们去调用它的subscribe()方法的时候，我们将会在onNext()方法中得到一个新的`HeavyExternalLibrary`实例：

```java
heavyExternalLibraryObservable.subscribe(new SimpleObserver<HeavyExternalLibrary>() {
    @Override
    public void onNext(HeavyExternalLibrary heavyExternalLibrary) {
        //New instance of HeavyExternalLibrary
    }
});
```

### 完全的异步注入

还有另一个方法是用RxJava在Dagger 2中进行异步注入。我们可以使用Observable简单封装整个注入过程。

我们注入的执行是这样的（代码摘自[GithubClient](https://github.com/frogermcs/GithubClient/)项目）：

```java
public class SplashActivity extends BaseActivity {

    @Inject
    SplashActivityPresenter presenter;
    @Inject
    AnalyticsManager analyticsManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    //This method is called in super.onCreate() method
    @Override
    protected void setupActivityComponent() {
        final SplashActivityComponent splashActivityComponent = GithubClientApplication.get(SplashActivity.this)
                .getAppComponent()
                .plus(new SplashActivityModule(SplashActivity.this));
        splashActivityComponent.inject(SplashActivity.this);
    }
}
```

要让它变成异步我们只需要使用Observable封装`setupActivityComponent()`方法：

```java
@Override
protected void setupActivityComponent() {
    Observable.create(new Observable.OnSubscribe<Object>() {
        @Override
        public void call(Subscriber<? super Object> subscriber) {
            final SplashActivityComponent splashActivityComponent = GithubClientApplication.get(SplashActivity.this)
                    .getAppComponent()
                    .plus(new SplashActivityModule(SplashActivity.this));
            splashActivityComponent.inject(SplashActivity.this);
            subscriber.onCompleted();
        }
    })
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(new SimpleObserver<Object>() {
                @Override
                public void onCompleted() {
                    //Here is the moment when injection is done.
                    analyticsManager.logScreenView(getClass().getName());
                    presenter.callAnyMethod();
                }
            });
}
```

正如注释，所有`@Inject`注解了的对象将被未来某一时刻注入。在返回注入过程是异步的并且不会对主线程有很大的影响。

当然创建`Observable`对象和额外`subscribeOn()`线程并不是完全免费的 - 它将会花费一点时间。这类似于**Producers**代码所产生的影响。

![](http://frogermcs.github.io/images/26/splash_metrics.png)

感谢阅读！

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

