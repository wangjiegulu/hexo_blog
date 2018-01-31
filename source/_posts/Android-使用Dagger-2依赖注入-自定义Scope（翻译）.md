---
title: '使用Dagger 2依赖注入 - 自定义Scope（翻译）'
tags: [android, dagger2, DI, dependency injection, google, 翻译]
date: 2016-01-02 22:21:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5095426.html>
**</font>

# 使用Dagger 2依赖注入 - 自定义Scope

> 原文：<http://frogermcs.github.io/dependency-injection-with-dagger-2-custom-scopes/>

这章是展示使用Dagger 2在Android端实现依赖注入的系列中的一部分。今天我会花点时间在自定义Scope（作用域）上面 - 它是很实用，但是对于刚接触依赖注入的人会有一点困难。

## Scope - 它给我们带来了什么？

几乎所有的项目都会用到单例 - 比如API clients，database helpers，analytics managers等。因为我们不需要去关心实例化（由于依赖注入），我们不应该在我们的代码中考虑关于怎么得到这些对象。取而代之的是`@Inject`注解应该提供给我们适合的实例。

在Dagger 2中，Scope机制可以使得在scope存在时保持类的单例。在实践中，这意味着被限定范围为`@ApplicationScope`的实例与Applicaiton对象的生命周期一致。`@ActivityScope`保证引用与Activity的生命周期一致（举个例子我们可以在这个Activity中持有的所有fragment之间分享一个任何类的单例）。

简单来说 - scope给我们带来了“局部单例”，生命周期取决于scope自己。

但是需要弄清楚的是 - Dagger 2默认并不提供`@ActivityScope` 或者/并且 `@ApplicationScope` 这些注解。这些只是最常用的自定义Scope。只有`@Singleton` scope是默认提供的（由Java自己提供）。

## Scope - 实践案例

为了更好地去理解Dagger 2中的scope，我们直接进入实践案例。我们将要去实现比Application/Activity scope更加复杂一点的scope。为此我们将使用 [上一文章] 中的 [GithubClient] 例子。我们的app应需要三种scope：

- __@Sigleton__ - application scope
- __@UserScope__ - 用于与被选中的用户联系起来的类实例的scope（在真实的app中可以是当前登录的用户）。
- __@ActivityScope__ - 生命周期与Activity（在我们例子中的呈现者）一致的实例的scope

讲解的`@UserScope`是今天方案与以前文章之间的主要的不同之处。从用户体验的角度来说它没有带给我们任何东西，但是从架构的观点来说它帮助我们在不传入任何意图参数的情况下提供了User实例。使用方法参数获取用户数据的类（在我们的例子中是`RepositoriesManager`）中我们可以通过构造参数（它将通过依赖图表提供）的方式来获取User实例并在需要的时候被初始化，而不是在app启动的时候创建它。这意味着`RepositoriesManager`可以在我们从Github API获取到用户信息（在`RepositoriesListActivity`呈现之前）之后被创建。

这里有个我们app中scopes和components呈现的简单图表。

![](http://frogermcs.github.io/images/15/dagger-scopes.png)

单例（Application scope）是最长的scope（在实践中是与application一样长）。UserScope作为Application scope的一个子集scope，它可以访问它的对象（我们可以从父scope中得到对象）。ActivityScope（生命周期与Activity一致）也是如此 - 它可以从UserScope和ApplicationScope中得到对象。

## Scope生命周期的例子

这里有一个我们app中scope生命周期的案例：

![](http://frogermcs.github.io/images/15/scopes-lifecycle.png)

单例的生命周期是从app启动后的所有的时期，当我们从Github API（在真实app中是用户登录之后）得到了`User`实例时UserScope被创建了，然后当我们回退到SplashActivity（在真实app中是用户退出之后）时被销毁。

## 实现

在Dagger 2中，Scope的实现归结于对Components的一个正确的设置。一般情况下我们有两种方式 - 使用`Subcomponent`注解或者使用Components依赖。它们两者最大的区别就是对象图表的共享。Subcomponents可以访问它们parent的所有对象图表，而Component依赖只能访问通过Component接口暴露的对象。

我选择第一种使用 `@Subcomponent` 注解，如果你之前使用过Dagger 1，它几乎与从`ObjectGraph`创建一个subgraphs（子图表）是一样的。此外，对于创建一个subgraphs的方法我们会使用类似的命名法则（但这不是强制性的）。

我们从`AppComponent`的实现开始：

```java
@Singleton
@Component(
        modules = {
                AppModule.class,
                GithubApiModule.class
        }
)
public interface AppComponent {

    UserComponent plus(UserModule userModule);

    SplashActivityComponent plus(SplashActivityModule splashActivityModule);

}
```

它将会是其它subcomponents的根Components：`UserComponent`和Activities Components。正如你注意到的那样（尤其如果你在前面的文章中看过的[AppComponent 实现]）所有的返回依赖图表对象的公开方法全部消失了。因为我们有subcomponents了，我们不需要去公开去暴露依赖了 - 无论如何subgraphs都可以访问它们全部了。

作为替代，我们新增了两个方法：

- `UserComponent plus(UserModule userModule);`
- `SplashActivityComponent plus(SplashActivityModule splashActivityModule);`

这表示，我们可以从`AppComponent`创建两个子Components（subcomponents）：`UserComponent`和`SplashActivityComponent`。因为它们都是AppComponent的subcomponents，所以它们两者都可以访问`AppModule`和`GithubApiModule`创建的实例。

_这些方法的命名法则是：返回类型是subcomponent类，方法名字随意，参数是这个subcomponent需要的modules。_

如你所见，`UserComponent`需要另一个module（它通过`plus()`方法的参数传入）。这样，我们通过增加一个新的用于生成对象的module，继承`AppComponent`图表。`UserComponent`类看起来这样：

```java
@UserScope
@Subcomponent(
        modules = {
                UserModule.class
        }
)
public interface UserComponent {
    RepositoriesListActivityComponent plus(RepositoriesListActivityModule repositoriesListActivityModule);

    RepositoryDetailsActivityComponent plus(RepositoryDetailsActivityModule repositoryDetailsActivityModule);
}
```

当然`@UserScope`注解是我们自己创建的：

```java
@Scope
@Retention(RetentionPolicy.RUNTIME)
public @interface UserScope {
}
```

我们可以从`UserComponent`创建另外两个subcomponents：`RepositoriesListActivityComponent`和`RepositoryDetailsActivityComponent`。

```java
@UserScope
@Subcomponent(
        modules = {
                UserModule.class
        }
)
public interface UserComponent {
    RepositoriesListActivityComponent plus(RepositoriesListActivityModule repositoriesListActivityModule);

    RepositoryDetailsActivityComponent plus(RepositoryDetailsActivityModule repositoryDetailsActivityModule);
}
```

并且更重要的是所有scope的东西都发生在这里。所有`UserComponent`中从`AppComponent`继承过来的仍然shi是单例的（是 Applicaton scope）。但是`UserModule`（`UserComponent`的那部分）创建的对象将会是“局部单例”，它的生命周期跟`UserComponent`实例是一样的。

所以，每次一创建另一个`UserComponent`实例将会调用：

```java
UserComponent appComponent = appComponent.plus(new UserModule(user))
```

从`UserModule`中获取的对象将是不同的实例。

但是这里很重要的一点是 - 我们要负责`UserComponent`的生命周期。所以我们应该关心它的初始化和释放。在我们的例子中，我为它增加了两个额外的方法：

```java
public class GithubClientApplication extends Application {

    private AppComponent appComponent;
    private UserComponent userComponent;

    //...

    public UserComponent createUserComponent(User user) {
        userComponent = appComponent.plus(new UserModule(user));
        return userComponent;
    }

    public void releaseUserComponent() {
        userComponent = null;
    }

    //...
}
```

`createUserComponent()`方法会在我们从Github API（在`SplashActivity`中）获取到`User`对象时调用。`releaseUserComponent()`方法会在我们从`RepositoriesListActivity`（这个时候我们不再需要user scope了）中返回时调用。

## Dagger 2中的Scope - 内部实现

查看它的内部的工作原理是很不错的。通常在这种情况下可以确定，在Dagger 2的scope机制下并不存在什么魔法。

我们从`UserModule.provideRepositoriesManager()`方法开始研究。它提供了`RepositoriesManager`实例，它应该使用`@UserScope`Scope。我们来检验这个方法哪里被调用（第8行）：

```java
@Generated("dagger.internal.codegen.ComponentProcessor")
public final class UserModule_ProvideRepositoriesManagerFactory implements Factory<RepositoriesManager> {

  //...

  @Override
  public RepositoriesManager get() {  
    RepositoriesManager provided = module.provideRepositoriesManager(userProvider.get(), githubApiServiceProvider.get());
    if (provided == null) {
      throw new NullPointerException("Cannot return null from a non-@Nullable @Provides method");
    }
    return provided;
  }

  public static Factory<RepositoriesManager> create(UserModule module, Provider<User> userProvider, Provider<GithubApiService> githubApiServiceProvider) {  
    return new UserModule_ProvideRepositoriesManagerFactory(module, userProvider, githubApiServiceProvider);
  }
}
```

`UserModule_ProvideRepositoriesManagerFactory`仅仅是一个工厂模式的现实，它从`UserModule`中获取到`RepositoriesManager`实例。我们应该往更深层次挖掘。

`UserModule_ProvideRepositoriesManagerFactory`在`UserComponentImpl`中被使用 - 我们component的实现（line 15）：

```java
private final class UserComponentImpl implements UserComponent {

    //...

    private UserComponentImpl(UserModule userModule) {
      if (userModule == null) {
        throw new NullPointerException();
      }
      this.userModule = userModule;
      initialize();
    }

    private void initialize() {
      this.provideUserProvider = ScopedProvider.create(UserModule_ProvideUserFactory.create(userModule));
      this.provideRepositoriesManagerProvider = ScopedProvider.create(UserModule_ProvideRepositoriesManagerFactory.create(userModule, provideUserProvider, DaggerAppComponent.this.provideGithubApiServiceProvider));
    }

    //...

}
```

`provideRepositoriesManagerProvider`对象在我们每次请求它时负责提供`RepositoriesManager`实例。如我们所见，provider是通过`ScopedProvider`实现的。来看下它的部分代码：

```java
public final class ScopedProvider<T> implements Provider<T> {

  //...

  private ScopedProvider(Factory<T> factory) {
    assert factory != null;
    this.factory = factory;
  }

  @SuppressWarnings("unchecked") // cast only happens when result comes from the factory
  @Override
  public T get() {
    // double-check idiom from EJ2: Item 71
    Object result = instance;
    if (result == UNINITIALIZED) {
      synchronized (this) {
        result = instance;
        if (result == UNINITIALIZED) {
          instance = result = factory.get();
        }
      }
    }
    return (T) result;
  }

  //...

}
```

再简单不过了吧？第一次调用`ScopedProvider`从factory（我们的例子中是`UserModule_ProvideRepositoriesManagerFactory`）中获取实例并像单例模式一样存储起来。我们的scoped provider只是`UserComponentImpl`中的一个属性，所以简单说就是`ScopedProvider`返回一个与依赖于Component的单例。

在这里你可以查看 [ScopedProvider] 的所有的实现。

就是这样。我们弄清楚了Dagger 2中Scope底层是怎么工作的。现在我们知道，它们没有以任何方式于Scope注解连接。自定义注解只是给了我们一个简单的方式来进行编译时代码校验和标记一个类是单例/非单例。所有的scope相关东西都是与Component的生命周期相关联。

以上就是今天的全部内容。我希望从现在开始scopes会变得更加容易使用。感谢阅读！

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

[repository]: https://github.com/frogermcs/GithubClient
[ScopedProvider]: https://github.com/google/dagger/blob/master/core/src/main/java/dagger/internal/ScopedProvider.java
[AppComponent 实现]: https://github.com/frogermcs/GithubClient/blob/1bf53a2a36c8a85435e877847b987395e482ab4a/app/src/main/java/frogermcs/io/githubclient/AppComponent.java
[GithubClient]: https://github.com/frogermcs/GithubClient
[上一文章]: http://frogermcs.github.io/dependency-injection-with-dagger-2-the-api/

