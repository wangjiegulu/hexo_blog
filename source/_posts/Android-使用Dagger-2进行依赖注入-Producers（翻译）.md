---
title: '使用Dagger 2进行依赖注入 - Producers（翻译）'
tags: [android, dagger2, DI, dependency injection, google, 翻译]
date: 2016-12-29 21:08:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/6234811.html>
**</font>

# 使用Dagger 2进行依赖注入 - Producers

> 原文：<http://frogermcs.github.io/dependency-injection-with-dagger-2-producers/>

本文是在Android中使用Dagger 2框架进行依赖注入的系列文章中的一部分。今天我们将探索下Dagger Producers - 使用Java实现异步依赖注入的Dagger2的一个扩展。

## 初始化性能问题

我们都知道Dagger 2是一个优化得很好的依赖注入框架。但是即使有这些全部的微优化，仍然在依赖注入的时候存在可能的性能问题 - “笨重”的第三方库和/或我们那些主线程阻塞的代码。

依赖注入是在尽可能短的时间内在正确的地方传递所请求的依赖的过程 - 这些都是Dagger 2做得很好的。但是DI也会去创建各种依赖。如果我们需要花费几百毫秒创建它们，那么以纳秒级的时间去提供依赖还有什么意义呢？

当我们的app创建了一系列繁重的单例并立即由Dagger2提供服务之后也许可能没有这么重要。但是在我们创建它们的时候仍然需要一个时间成本 - 大多数情况下决定了app启动的时间。

这问题（已经给了提示怎么去调适它）已经在我之前的一篇博客中描述地很详细了：[Dagger 2 - graph creation performance]。

在很短的时间内，让我们想象这么一个场景 - 你的app有一个初始化的界面（SplashScreen），需要在app启动后立即做一些需要的事情：

- 初始化所有tracking libs（Goole Analytics, Crashlytics）然后发送第一份数据给它们。
- 创建用于API和/或数据库通信的整个栈。
- 我们试图的交互逻辑（MVP中的Presenters，MVVM中的ViewModels等等）。

即使我们的代码是优化地非常好的，但是仍然有可能有些额外的库需要几十或者几百毫秒的时间来初始化。在我们启动界面之前将展示必须初始化和交付的所有请求的依赖（和它们的依赖）。这意味着启动时间将会是它们每一个初始化时间的总和。

由 [AndroidDevMetrics] 测量的示例堆栈可能如下所示：

![](http://frogermcs.github.io/images/24/example_dependencies.png)

用户将会在600ms（＋额外的系统work）内看到SplashActivity - 所有初始化时间的总和。

## Producers - 异步依赖注入

Dagger 2 有一个名为 **Producers** 的扩展，或多或少能为我们解决这些问题。

思路很简单 - 整个初始化流程可以在一个或多个后台线程中被执行，然后延后再交付给app的主线程。

#### @ProducerModule

类似于`@Module`，这个被用来标记用于传递依赖的类。多亏于它，Dagger将会知道去哪里找到被请求的依赖。

#### @Produces

类似于`@Provide`，这个注解用来标记带有`@ProducerModule`注解的类中的返回依赖的方法。`@Produces`注解的方法可以返回`ListenableFuture<T>`或者自身的对象（也会在所给的后台线程中进行初始化）。

#### @ProductionComponent

类似于`@Component`，它负责依赖的传递。它是我们代码与`@ProducerModule`之间的桥梁。唯一跟`@Component`的不同之处是我们不能决定依赖的scope。这意味着提供给 *component* 的每一个 *Produces 方法* 在 *每个component 实例* 中最多只会被调用一次，不管它作为一个 *依赖* 用于多少次绑定。

也就是说，每一个服务于`@ProductionComponent`的对象都是一个单例（只要我们从这个特殊的component中获取）。

---

Producers的文档已经足够详细了，所以这里没有必要去拷贝到这里。直接看：[Dagger 2 Producers docs]。

### Producers的代价

在我们开始实践前，有一些值得提醒的事情。Producers相比Dagger 2本身有一点更复杂。它看起来手机端app不是他们它们主要使用的目标，而且知道这些事情很重要：

- Producers使用了Guava库，并且建立在ListenableFuture类之上。这意味着你不得不处理15k的额外方法在你的app中。这可能导致你不得不使用*Proguard*来处理并且需要一个更长的编译时间。
- 就如你将看到的，创建`ListenableFutures`并不是没有成本的。所以如果你指望Producers会帮你从10ms优化到0ms那你可能就错了。但是如果规模更大（100ms --> 10ms），你就能有所发现。
- 现在无法使用`@Inject`注解，所以你必须要手动处理ProductionComponents。它会使得你的标准整洁的代码变得混乱。

[这里](http://stackoverflow.com/questions/35617378/injects-after-produces)你可以针对`@Inject`注解找到好的间接的解决方案的尝试。

## Example app

如果你仍然希望使用Producers来处理，那就让我们更新 [GithubClient] 这个app使得它在注入过程使用Producers。在实现之前和之后我们将会使用 [AndroidDevMetrics] 来测量启动时间和对比结果。

[这里](https://github.com/frogermcs/GithubClient/tree/1c14683691e0e7af17b26055a0fd041d4a7df424)是一个在使用producers更新之前的 GithubClient app的版本。并且它测量的平均启动时间如下：

![](http://frogermcs.github.io/images/24/before_update.png)

我们的计划是处理UserManager让它的所有的依赖来自Producers。

### 配置

我们将给一个Dagger v2.1的尝试（但是当前2.0版本的Producers也是可用的）。

让我们在项目中加入一个Dagger新的版本：

***app/build.gradle：***

```groovy
apply plugin: 'com.android.application'
apply plugin: 'com.neenbedankt.android-apt'
apply plugin: 'com.frogermcs.androiddevmetrics'

repositories {
    maven {
        url "https://oss.sonatype.org/content/repositories/snapshots"
    }
}
//...

dependencies {
    //...

    //Dagger 2
    compile 'com.google.dagger:dagger:2.1-SNAPSHOT'
    compile 'com.google.dagger:dagger-producers:2.1-SNAPSHOT'
    apt 'com.google.dagger:dagger-compiler:2.1-SNAPSHOT'

    //...
}
```

如你所见，Producers 作为一个新的依赖，在dagger 2库的下面。还有值得一说的是Dagger v2.1终于不需要`org.glassfish:javax.annotation:10.0-b28`的依赖了。

### Producer Module

现在，让我们移动代码从`GithubApiModule`到新创建的`GithubApiProducerModule`中。原来的代码可以在这里找到：[GithubApiModule]

***GithubApiProducerModule.java***

```java
@ProducerModule
public class GithubApiProducerModule {

    @Produces
    static OkHttpClient produceOkHttpClient() {
        final OkHttpClient.Builder builder = new OkHttpClient.Builder();
        if (BuildConfig.DEBUG) {
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
            logging.setLevel(HttpLoggingInterceptor.Level.BODY);
            builder.addInterceptor(logging);
        }

        builder.connectTimeout(60 * 1000, TimeUnit.MILLISECONDS)
                .readTimeout(60 * 1000, TimeUnit.MILLISECONDS);

        return builder.build();
    }

    @Produces
    public Retrofit produceRestAdapter(Application application, OkHttpClient okHttpClient) {
        Retrofit.Builder builder = new Retrofit.Builder();
        builder.client(okHttpClient)
                .baseUrl(application.getString(R.string.endpoint))
                .addCallAdapterFactory(RxJavaCallAdapterFactory.create())
                .addConverterFactory(GsonConverterFactory.create());
        return builder.build();
    }

    @Produces
    public GithubApiService produceGithubApiService(Retrofit restAdapter) {
        return restAdapter.create(GithubApiService.class);
    }

    @Produces
    public UserManager produceUserManager(GithubApiService githubApiService) {
        return new UserManager(githubApiService);
    }

    @Produces
    public UserModule.Factory produceUserModuleFactory(GithubApiService githubApiService) {
        return new UserModule.Factory(githubApiService);
    }
}
```

看起来很像？没错，我们只是修改了：

- `@Module` 改为 `@ProducerModule`
- `@Provides @Singleton` 改为 `@Produces`。*你还记得吗？在Producers中我们默认就有一个单例*

`UserModule.Factory` 依赖只是因为app的逻辑原因而添加。

## Production Component

现在让我们创建`@ProductionComponent`，它将会为`UserManager`实例提供服务：

```java
@ProductionComponent(
        dependencies = AppComponent.class,
        modules = GithubApiProducerModule.class
)
public interface AppProductionComponent {
    ListenableFuture<UserManager> userManager();

    ListenableFuture<UserModule.Factory> userModuleFactory();
}
```

又一次，非常类似原来的[Dagger's @Component]。

ProductionComponent的构建也是与标准的Component非常相似：

```java
AppProductionComponent appProductionComponent = DaggerAppProductionComponent.builder()
    .executor(Executors.newSingleThreadExecutor())
    .appComponent(appComponent)
    .build();
```

额外附加的参数是`Executor`实例，它告诉ProductionComponent依赖应该在哪里（哪个线程）被创建。在我们的例子中我们使用了一个single-thread executor，但是当然增加并行级别并使用多线程执行不是一个问题。

## 获取依赖

就像我说的，当前我们不能去使用`@Inject`注解。相反，我们必须直接询问ProductionComponent（你可以在[SplashActivityPresenter]找到这些代码）：

```java
appProductionComponent = splashActivity.getAppProductionComponent();
Futures.addCallback(appProductionComponent.userManager(), new FutureCallback<UserManager>() {
    @Override
    public void onSuccess(UserManager result) {
        SplashActivityPresenter.this.userManager = result;
    }

    @Override
    public void onFailure(Throwable t) {

    }
});
```

这里重要的是，对象初始化是在你第一次调用`appProductionComponent.userManager()`的时候开始的。在这之后`UserManager`对象将会被缓存。这表示每一个绑定都拥有跟component实例相同的生命周期。

以上几乎就是所有了。当然你应该知道在`Future.onSuccess()`方法被调用之前userManager实例会时`null`。

## 性能

在最后让我们来看下现在注入的性能是怎么样的：

![](http://frogermcs.github.io/images/24/after_update.png)

是的，没错 - 这时平均值大约是15ms。它小于同步注入（平均. 25ms）但是并不如你期望的那样少。这时因为Producers并不像Dagger本身那样轻量。

所以现在取决于你了 - 是否值得使用Guava, Proguard和代码复杂度来做**这种**优化。

请记住，如果你觉得Producers并不是最适合你的app的，你可以在你的app中尝试使用RxJava或者其他异步代码来包装你的注入。

感谢阅读！

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

[AndroidDevMetrics]: https://github.com/frogermcs/androiddevmetrics

[Dagger 2 Producers docs]: http://google.github.io/dagger/producers.html

[GithubClient]: https://github.com/frogermcs/GithubClient/

[GithubApiModule]: https://github.com/frogermcs/GithubClient/blob/1c14683691e0e7af17b26055a0fd041d4a7df424/app/src/main/java/frogermcs/io/githubclient/data/api/GithubApiModule.java

[Dagger's @Component]:https://github.com/frogermcs/GithubClient/blob/master/app/src/main/java/frogermcs/io/githubclient/AppComponent.java

[SplashActivityPresenter]:https://github.com/frogermcs/GithubClient/blob/master/app/src/main/java/frogermcs/io/githubclient/ui/activity/presenter/SplashActivityPresenter.java
[repository]: https://github.com/frogermcs/GithubClient

