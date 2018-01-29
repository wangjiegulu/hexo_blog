---
title: '[Android]使用Dagger 2依赖注入 - API（翻译）'
tags: []
date: 2015-12-31 18:55:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5092525.html>
**</font>

# 使用Dagger 2依赖注入 - API

> 原文：<http://frogermcs.github.io/dependency-injection-with-dagger-2-the-api/>

这章是展示使用Dagger 2在Android端实现依赖注入的系列中的一部分。今天我会探索Dagger 2的基础并且学习这个依赖注入框架的所有的API。

## Dagger 2

在我上一章中我提到了DI框架给我们带来了什么 - 它让只写一小部分代码就可以使一切联系在一起成为可能。Dagger 2就是DI框架的一个例子，它可以为我们生成很多模版代码。但是为什么它比其它的要更好呢？目前为止它是唯一一个可以生成完整模仿用户手写的可追踪的代码的DI框架。这意味着让依赖图表构建过程不再充满魔幻。Dagger 2相比其它是不具有动态性的（使用时完全不使用反射）但是生成的代码的简洁性和性能都是与手写的代码同水准的。

### Dagger 2 基础

下面是Dagger 2的API：

```java
public @interface Component {
    Class<?>[] modules() default {};
    Class<?>[] dependencies() default {};
}

public @interface Subcomponent {
    Class<?>[] modules() default {};
}

public @interface Module {
    Class<?>[] includes() default {};
}

public @interface Provides {
}

public @interface MapKey {
    boolean unwrapValue() default true;
}

public interface Lazy<T> {
    T get();
}
```

还有在Dagger 2中用到的定义在 [JSR-330] （Java中依赖注入的标准）中的其它元素：

```java
public @interface Inject {
}

public @interface Scope {
}

public @interface Qualifier {
}
```

让我们来学习它们。

#### @Inject 注解

DI中第一个并且是最重要的就是`@Inject`注解。JSR-330标准中的一部分，标记那些应该被依赖注入框架提供的依赖。在Dagger 2中有3种不同的方式来提供依赖：

##### 构造器注入：

`@Inject`使用在类的构造器上：

```java
public class LoginActivityPresenter {

    private LoginActivity loginActivity;
    private UserDataStore userDataStore;
    private UserManager userManager;

    @Inject
    public LoginActivityPresenter(LoginActivity loginActivity,
                                  UserDataStore userDataStore,
                                  UserManager userManager) {
        this.loginActivity = loginActivity;
        this.userDataStore = userDataStore;
        this.userManager = userManager;
    }
}
```

所有的参数都是通过依赖图表中获取。`@Inject`注解被使用在构造器中也会标记这个类为依赖图表的一部分。这意味着它也可以在我们需要的时候被注入：

```java
public class LoginActivity extends BaseActivity {

    @Inject
    LoginActivityPresenter presenter;

    //...
}
```
这个例子中的局限性是我们不能给这个类中的多个构造器作`@Inject`注解。

##### 属性注入

另一种选择是给指定的属性作`@Inject`注解：

```java
public class SplashActivity extends AppCompatActivity {

    @Inject
    LoginActivityPresenter presenter;
    @Inject
    AnalyticsManager analyticsManager;

    @Override
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        getAppComponent().inject(this);
    }
}
```

但是在这个例子中，注入过程必须要在我们类的某处“手动”调用：

```java
public class SplashActivity extends AppCompatActivity {

    //...

    @Override 
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        getAppComponent().inject(this);    //Requested depenencies are injected in this moment
    }
}
```

在这个调用之前，我们的依赖是null值。

属性注入的局限性是我们不能使用`private`。为什么？简单说，生成的代码会直接地调用它们来设置属性，就像这里：

```java
//This class is generated automatically by Dagger 2
public final class SplashActivity_MembersInjector implements MembersInjector<SplashActivity> {

    //...

    @Override
    public void injectMembers(SplashActivity splashActivity) {
        if (splashActivity == null) {
            throw new NullPointerException("Cannot inject members into a null reference");
        }
        supertypeInjector.injectMembers(splashActivity);
        splashActivity.presenter = presenterProvider.get();
        splashActivity.analyticsManager = analyticsManagerProvider.get();
    }
}
```

##### 方法注入

最后一种方法使用`@Inject`注解提供依赖的方式是在这个类的`public`方法中作注解：

```java
public class LoginActivityPresenter {

    private LoginActivity loginActivity;

    @Inject 
    public LoginActivityPresenter(LoginActivity loginActivity) {
        this.loginActivity = loginActivity;
    }

    @Inject
    public void enableWatches(Watches watches) {
        watches.register(this);    //Watches instance required fully constructed LoginActivityPresenter
    }
}
```

方法的所有参数都是通过依赖图表提供的。但是为什么我们需要方法注入呢？在某些情况下会用到，如当我们希望传入类的当前实例（`this`引用）到被注入的依赖中。方法注入会在构造器调用后马上被调用，所以这表示我们可以传入完全被构造的`this`。

#### @Module 注解

`@Module`是Dagger 2 API的一部分。这个注解用于标记提供依赖的类 - 多亏它Dagger才会知道某些地方需要的对象被构建。

```java
@Module
public class GithubApiModule {

    @Provides
    @Singleton
    OkHttpClient provideOkHttpClient() {
        OkHttpClient okHttpClient = new OkHttpClient();
        okHttpClient.setConnectTimeout(60 * 1000, TimeUnit.MILLISECONDS);
        okHttpClient.setReadTimeout(60 * 1000, TimeUnit.MILLISECONDS);
        return okHttpClient;
    }

    @Provides
    @Singleton
    RestAdapter provideRestAdapter(Application application, OkHttpClient okHttpClient) {
        RestAdapter.Builder builder = new RestAdapter.Builder();
        builder.setClient(new OkClient(okHttpClient))
               .setEndpoint(application.getString(R.string.endpoint));
        return builder.build();
    }
}
view rawGithubApiModule.java hosted with ❤ by GitHub
```

#### @Provides 注解

这个注解用在`@Module`类中。`@Provides`会标记Module中那些返回依赖的方法。

```java
@Module
public class GithubApiModule {

    //...

    @Provides   //This annotation means that method below provides dependency
    @Singleton
    RestAdapter provideRestAdapter(Application application, OkHttpClient okHttpClient) {
        RestAdapter.Builder builder = new RestAdapter.Builder();
        builder.setClient(new OkClient(okHttpClient))
               .setEndpoint(application.getString(R.string.endpoint));
        return builder.build();
    }
}
```

#### @Component 注解

这个注解用在把一切联系在一起的接口上面。在这里我们可以定义从哪些module（或者哪些Components）中获取依赖。这里也可以用来定义哪些图表依赖应该公开可见（可以被注入）和哪里我们的component可以注入对象。`@Component`通常是`@Module`和`@Inject`之间的桥梁。

这里有个使用了两个module的`@Component`例子代码，可以注入依赖到`GithubClientApplication`，并且标记了三个依赖公开可见：

```java
@Singleton
@Component(
    modules = {
        AppModule.class,
        GithubApiModule.class
    }
)
public interface AppComponent {

    void inject(GithubClientApplication githubClientApplication);

    Application getApplication();

    AnalyticsManager getAnalyticsManager();

    UserManager getUserManager();
}
```

`@Component`也可以依赖其它的component，并且定义了生命周期（我会在以后的文章中讲解Scope）：

```java
@ActivityScope
@Component(      
    modules = SplashActivityModule.class,
    dependencies = AppComponent.class
)
public interface SplashActivityComponent {
    SplashActivity inject(SplashActivity splashActivity);

    SplashActivityPresenter presenter();
}
```

#### @Scope 注解

```java
@Scope
public @interface ActivityScope {
}
```

JSR-330标准的又一部分。在Dagger 2中，`@Scope`被用于标记自定义的scope注解。简单说它们可以类似单例地标记依赖。被作注解的依赖会变成单例，但是这会与component的生命周期（不是整个应用）关联。但是正如我刚才所说 - 我会在下一篇文章中深入scope。现在值得一提的是所有自定义scope做的是同样的事情（从代码角度）- 它们为对象保持单例。但是他们也会被在图表认证处理中使用，这对尽可能地捕捉图表结构问题是有帮助的。

---

接下来是一些不太重要，不会经常用到的东西：

#### MapKey

这个注解用在定义一些依赖集合（目前为止，Maps和Sets）。让例子代码自己来解释吧：

定义：
```java
@MapKey(unwrapValue = true)
@interface TestKey {
    String value();
}
```

提供依赖：

```java
@Provides(type = Type.MAP)
@TestKey("foo")
String provideFooKey() {
    return "foo value";
}

@Provides(type = Type.MAP)
@TestKey("bar")
String provideBarKey() {
    return "bar value";
}
```

使用：

```java
@Inject
Map<String, String> map;

map.toString() // => „{foo=foo value, bar=bar value}”
```

`@MapKey`注解目前只提供两种类型 - String和Enum。

#### @Qualifier

`@Qualifier`注解帮助我们去为相同接口的依赖创建“tags”。想象下你需要提供两个`RestAdapter`对象 - 一个用于Github API，另一个用于Fackbook API。`Qualifier`会帮助你区分对应的一个：

命名依赖：

```java
@Provides
@Singleton
@GithubRestAdapter  //Qualifier
RestAdapter provideRestAdapter() {
    return new RestAdapter.Builder()
        .setEndpoint("https://api.github.com")
        .build();
}

@Provides
@Singleton
@FacebookRestAdapter  //Qualifier
RestAdapter provideRestAdapter() {
    return new RestAdapter.Builder()
        .setEndpoint("https://api.facebook.com")
        .build();
}
```

注入依赖：

```java
@Inject
@GithubRestAdapter
RestAdapter githubRestAdapter;

@Inject
@FacebookRestAdapter
RestAdapter facebookRestAdapter;
```

以上就是全部了。我们刚刚已经了解了所有Dagger 2 API中重要的元素了。

### App example

现在是时候让我们在实践中检验我们的知识了。我们会基于Dagger 2来实现一个简单的Github客户端app。

#### 想法

我们的Github客户端有三个Activity和非常简单的使用case。它的全部流程：

1\. 输入Github用户名
2\. 如果用户存在则显示它所有公开的库。
3\. 当用户按下list的item后显示库的详情。

这里就是我们的app看起来的样子：

![](http://frogermcs.github.io/images/14/app_flow.png)

在内部，从DI角度我们的app结构看起来如下：

![](http://frogermcs.github.io/images/14/local_components.png)

简单说 - 每一个Activity都有它自己的依赖图表。每个图表（_Component类）有两个对象 - `_Prresenter`和`_Activity`。每个component也会从全局的component（`AppComponent`，包含了`Application`, `UserManager`, `RepositoriesManager`等）中获取依赖。

![](http://frogermcs.github.io/images/14/app_component.png)

讲讲`AppComponent` - 看上面最近的图表。它包含了两个modules：`AppModule`和`GithubApiModule`。

`GithubApiModule`提供了一些依赖，比如`OkHttpClient`或`RestAdapter`，他们只会在这个module的其它依赖使用。在Dagger 2中我们可以控制哪些对象对外部的component可见。在我们例子中我们不希望暴露这些被使用了的对象。所以我们只是暴露了`UserManager`和`RepositoriesManager`，因为这有这些对象才会被我们的Activity用到。所有都通过public、返回非void类型并无参数的方法被定义。

文档中的例子：

__提供依赖的方法__：

```java
SomeType getSomeType();
Set<SomeType> getSomeTypes();
@PortNumber int getPortNumber();
```

此外，我们必须要定义哪里我们希望要去注入依赖（通过成员注入）。在我们例子中`AppComponent`没有任何地方可以去注入，因为它只是作为我们Components的依赖。所以它们每一个都被定义了 一个`inject(_Activity activity)`方法。这里我们也有一些简单的规则 - 注入通过一个单个参数的方法被定义（定义一个实例，它代表我们需要往这个实例中注入依赖），它可以有任意的名字，但是必须要返回类型是void或者返回被传入的参数类型。

文档中的例子：

__成员注入的方法__：

```java
SomeType getSomeType();
Provider<SomeType> getSomeTypeProvider();
Lazy<SomeType> getLazySomeType();
```

#### 实现

我不想深入太多的代码。clone [GithubClient] 代码并导入到最新的Android Studio。这里给出一些开始的提示：

#### Dagger 2 安装

只需要获得`/app/build.gradle`文件。我们需要增加Dagger 2依赖和使用 [android-apt] 插件来对生成的代码和Android Studio IDE之间进行绑定。

##### AppComponent

从`GithubClientApplication`类开始探索。在这里`AppComponent`会被创建和存储。这意味着所有单例的对象的生命周期都会与Applicaiton一致（所以每时每刻都是如此）。

`AppComponent`的实现由Dagger 2（对象可以通过builder模式被创建）生成的代码提供。在这里我们也可以放入所有的Component的依赖（module和其他components）。

##### 限定的component

可以通过`SplashActivity`来探索Activities Components是怎么创建的。它重写了`setupActivityComponent(AppComponent)`，在这里它创建它自己的Component（`SplashActivityComponent`），然后注入所有被做`@Inject`注解的依赖（这个例子中的`SplashActivityPresenter`和`AnalyticsManager`）。

在这里我们也会提供AppComponent实例（因为`SplashActivityComponent`是依赖它的）以及`SplashActivityModule`（它提供了Presenter和Activity实例）。

剩下的就靠你自己了。认真的说 - 尝试弄清楚一切是怎么合适地联系在一起的。下一章节我们尝试深入Dagger 2的那些紧密的元素（在底层它们是怎么工作的）。

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

[repository]: https://github.com/frogermcs/GithubClient/tree/1bf53a2a36c8a85435e877847b987395e482ab4a
[android-apt]: https://bitbucket.org/hvisser/android-apt
[GithubClient]: https://github.com/frogermcs/GithubClient
[JSR-330]: https://jcp.org/en/jsr/detail?id=330