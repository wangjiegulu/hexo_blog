---
title: '[Android]使用Dagger 2依赖注入 - DI介绍（翻译）'
tags: [android, dagger2, DI, dependency injection, google, 翻译]
date: 2015-12-31 16:19:00
---

<font color="#ff0000">
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5092083.html>
</font>

## 使用Dagger 2依赖注入 - DI介绍

> 原文：<http://frogermcs.github.io/dependency-injection-with-dagger-2-introdution-to-di/>

不久之前，在克拉科夫的 [Tech Space] 的 Google I/O 扩展中，我 [展示] 了一些关于使用Dagger 2来进行依赖注入。在准备期间我认识到有太多相关的东西需要去讲，无法用一打幻灯片就能覆盖到全部。但是它可以作为一个很好的进入点来开展更多这一系列主题－Android端的依赖注入。

在这一章中我会去通过之前所展示的来进行一个总结。可能并不是按部就班的 - 我认为现在是时候打破过去，使用一些原本我们不会使用或者不应该使用的方法来解决问题了。__Jake Wharton__ [讲述] 了相关历史（Guice, Dagger 1），__Gregory Kick__ [也是]（几乎有一半是关于Spring, Guice, Dagger 1）。我也会花几分钟的时间讲述以前的解决方式。但是此刻是时候开始了。

### 依赖注入

依赖注入的全部就是构建对象并在我们需要时把它们传入。我不会深入到它的学说（查看维基百科对[DI的定义]）。想象一个简单的类：`UserManager`，它依赖`UserStore`和`ApiService`。如果没有使用依赖注入，这个类会看起来像这样：

![](http://frogermcs.github.io/images/13/user_manager_no_di.png)

`UserStore` 和 `ApiService` 两者都是在`UserManager`类中构造和提供的：

```java
class UserManager {

    private ApiService apiService;
    private UserStore userStore;

    //No-args constructor. Dependencies are created inside.
    public UserManager() {
        this.apiService = new ApiSerivce();
        this.userStore = new UserStore();
    }

    void registerUser() {/*  */}

}

class RegisterActivity extends Activity {

    private UserManager userManager;

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        this.userManager = new UserManager();
    }

    public void onRegisterClick(View v) {
        userManager.registerUser();
    }
}
```

为什么这些代码会给我们制造一些问题呢？让我们想象一下，你希望去改变`UserStore`的实现，用`SharedPreferences`来作为它的存储机制。它需要至少一个`Context`对象来创建一个实例，所以我们需要把它通过构造器传入到`UserStore`。它意味着`UserManager`类中也需要被修改来使用新的`UserStore`构造器。现在想象下有很多类使用了`UserStore` - 它们全部都需要被修改。

现在再来看下我们使用了依赖注入的`UserManager`类：

![](http://frogermcs.github.io/images/13/user_manager_di.png)

它的依赖是在类的外面创建和提供的：

```java
class UserManager {

    private ApiService apiService;
    private UserStore userStore;

    //Dependencies are passed as arguments
    public UserManager(ApiService apiService, UserStore userStore) {
        this.apiService = apiService;
        this.userStore = userStore;
    }

    void registerUser() {/*  */}

}

class RegisterActivity extends Activity {

    private UserManager userManager;

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        ApiService api = ApiService.getInstance();
        UserStore store = UserStore.getInstance();

        this.userManager = new UserManager(api, store);
    }

    public void onRegisterClick(View v) {
        userManager.registerUser();
    }

}
```

现在在相似的情况下 - 我们改变它其中一个依赖的实现方式 - 我们不需要修改`UserManager`源代码。所有它的依赖都是从外面提供的，所以我们唯一一个需要修改的地方就是我们构造的`UserStore`对象。

所以使用依赖注入的优势是什么呢？

#### 构造/使用 的分离

当我们构造类的实例 - 通常这些对象会在其它的地方被使用到，多亏这个方法让我们的代码更加模块化 - 所有的依赖都可以被很简单地替换掉（只要他们实现了相同的接口），并且不会与我们应用的逻辑产生冲突。想要改变`DatabaseUserStore`为`SharedPrefsUserStore` ？好的，只需要关心公开的API（与`DatabaseUserStore`相同的）或者实现相同的接口。

#### 单元测试（Unit testing）

真正的单元测试假设一个类是可以完全被隔离进行测试的 - 不需要了解它的相关依赖。在实践中，基于我们的`UserManager`类，这里有一个我们应该编写的单元测试的例子：

```java
public class UserManagerTests {

    UserManager userManager;

    @Mock
    ApiService apiServiceMock;
    @Mock
    UserStore userStoreMock;

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);
        userManager = new UserManager(apiServiceMock, userStoreMock);
    }

    @After
    public void tearDown() {
    }

    @Test
    public void testSomething() {
        //Test our userManager here - all its dependencies are satisfied
    }
}
```

它可能只能使用DI - 多亏`UserManager`是完全独立于`UserStore`和`ApiService`实现的。我们可以提供这些类的mock（简单地说 - mocks是一些拥有相同公开API的类，它在方法中不做任何事情并且/或者返回我们期望的值），然后在一个与所依赖的真实实现分离出来的环境下进行对`UserManager`的测试。

#### 独立/并行开发

多亏模块化的代码（`UserStore`可以从`UserManager`中独立出来进行实现），它也可以非常方便在程序员间进行代码的分离。只需要`UserStore`相关的接口被每个人知道（尤其是在`UserManager`中使用到的`UserStore`中的公开方法）即可。剩下的（实现，逻辑）可以通过单元测试来测试。

### 依赖注入框架

依赖注入除了这些优点之外还有一些缺点。其中一个缺点是会产生很大的模版代码。想象一个简单的`LoginActivity`类，它在MVP（model-view-presenter）模式中被实现。这个类看起来就像这样：

![](http://frogermcs.github.io/images/13/login_activity_diagram.png)

唯一有问题的部分代码就是`LoginActivityPresenter`的初始化，如下：

```java
public class LoginActivity extends AppCompatActivity {

    LoginActivityPresenter presenter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        OkHttpClient okHttpClient = new OkHttpClient();
        RestAdapter.Builder builder = new RestAdapter.Builder();
        builder.setClient(new OkClient(okHttpClient));
        RestAdapter restAdapter = builder.build();
        ApiService apiService = restAdapter.create(ApiService.class);
        UserManager userManager = UserManager.getInstance(apiService);

        UserDataStore userDataStore = UserDataStore.getInstance(
                getSharedPreferences("prefs", MODE_PRIVATE)
        );

        //Presenter is initialized here
        presenter = new LoginActivityPresenter(this, userManager, userDataStore);
    }
}
```

它看起来不太友好，不是吗？

这就是DI框架需要解决的问题。相同功能的代码看起来就像这样：

```java
public class LoginActivity extends AppCompatActivity {

    @Inject
    LoginActivityPresenter presenter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //Satisfy all dependencies requested by @Inject annotation
        getDependenciesGraph().inject(this);
    }
}
```

简单多了，对吧？当然DI框架没有地方可以获取到对象 - 他们仍然需要在我们代码的某个地方进行初始化和配置。但是对象构建从使用中分离出来了（实质上这是DI模式的准则）。DI框架关心怎么样去把它们联系在一起（怎么在对象被需要时分配给它们）。

### 未完待续

我上面所有描述的东西都是使用Dagger 2的简单的背景 - 用于Android和Java开发的依赖注入框架。在下一章我将尝试讲解所有Dagger 2的API。如果你等不急可以尝试我的[Github client example]，它建立在Dagger 2之上并且会用在我的展示中。一个小提示 - `@Module`和`@Component`就是构建/提供对象的地方。`@Inject`是我们对象使用到的地方。

More detailed description - soon.

### 参考

- [DAGGER 2 - A New Type of dependency injection](https://www.youtube.com/watch?v=oK_XtfXPkqw) by Gregory Kick
- [The Future of Dependency Injection with Dagger 2](https://www.parleys.com/tutorial/the-future-dependency-injection-dagger-2) by Jake Wharton
- [Dagger 1 to 2 migration process](http://frogermcs.github.io/dagger-1-to-2-migration/)

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

[Github client example]: https://github.com/frogermcs/GithubClient
[DI的定义]: http://en.wikipedia.org/wiki/Dependency_injection
[也是]: https://www.youtube.com/watch?v=oK_XtfXPkqw
[讲述]: https://www.parleys.com/tutorial/5471cdd1e4b065ebcfa1d557/
[展示]: https://speakerdeck.com/frogermcs/dependency-injection-with-dagger-2
[Tech Space]: http://frogermcs.github.io/dependency-injection-with-dagger-2-introdution-to-di/

