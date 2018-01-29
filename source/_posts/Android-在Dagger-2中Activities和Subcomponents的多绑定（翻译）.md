---
title: '[Android]在Dagger 2中Activities和Subcomponents的多绑定（翻译）'
tags: []
date: 2017-01-09 20:23:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/6266442.html>
**</font>

# 在Dagger 2中Activities和Subcomponents的多绑定

> 原文：<http://frogermcs.github.io/activities-multibinding-in-dagger-2>

几个月前，在[MCE^3](http://2016.mceconf.com/)会议中，Gregory Kick在他的[演讲](https://www.youtube.com/watch?v=iwjXqRlEevg)中展示了一个提供Subcomponents（比如，为Activity）的新概念。新的方式给我们带来了一个创建不使用AppComponent对象引用（以前时Activities Subcomponents的工厂）的方式。为了让它成为现实，我们不得不等到了新的Dagger release版本：[version 2.7](https://github.com/google/dagger/releases/tag/dagger-2.7)。

<!-- more -->

## 问题

在Dagger 2.7之前，创建Subcomponent（比如，`AppComponent`的subcomponent `MainActivityComponent`）我们必须要在父Component中声明它的工厂：

```java
@Singleton
@Component(
    modules = {
        AppModule.class
    }
)
public interface AppComponent {
    MainActivityComponent plus(MainActivityComponent.ModuleImpl module);

    //...
}
```

多亏Dagger理解这个声明，`MainActivityComponent`能够访问从`AppComponent`的依赖。

有了这个，`MainActivity`中的注入看起来如下：

```java
@Override
protected ActivityComponent onCreateComponent() {
    ((MyApplication) getApplication()).getComponent().plus(new MainActivityComponent.ModuleImpl(this));
    component.inject(this);
    return component;
}
```

这个代码的问题在于：

- Activity依赖于`AppComponent`（通过`((MyApplication) getApplication()).getComponent())`返回 - 我们是否想要去创建Subcomponent，我们需要去访问父Component的对象）。

- `AppComponent`必须要去声明所有Subcomponents（或者它们的builders），比如：`MainActivityComponent plus(MainActivityComponent.ModuleImpl module);`。

## Modules.subcomponents

从Dagger 2.7开始，我们有了一个新的方法来声明subcomponents的父级。`@Module`注解有一个可选的[subcomponents](http://google.github.io/dagger/api/2.7/dagger/Module.html#subcomponents--)属性，它可以得到subcomponents类的列表，它们应该是安装此module组件的子component。

### Example：

```java
@Module(
        subcomponents = {
                MainActivityComponent.class,
                SecondActivityComponent.class
        })
public abstract class ActivityBindingModule {
    //...
}
```

`ActivityBindingModule`在`AppComponent`中被安装。这表示`MainActivityComponent`和`SecondActivityComponent`两者都是`AppComponent`的Subcomponents。

Subcomponents的声明在这种方法中不需要明确地在`AppComponent`中进行声明（就像本章开头的代码）。

## Activities的多绑定

让我们来看看我们怎么样使用`Modules.subcomponents`来构建Activities多绑定并且摆脱AppComponent对象传入Activity（这在[这个演讲](https://www.youtube.com/watch?v=iwjXqRlEevg&feature=youtu.be&t=1693)中也解释到）。我将只浏览代码中最重要的部分。整个实现已在Github中可用：[Dagger2Recipes-ActivitiesMultibinding](https://github.com/frogermcs/Dagger2Recipes-ActivitiesMultibinding)。

我们的app包含两个屏幕：`MainActivity`和`SecondActivity`。我们想要去给它们两者提供Subcomponents且并不传入`AppComponent`对象。

让我们从为所有Activity Components builders构建一个基本的接口来开始：

```java
public interface ActivityComponentBuilder<M extends ActivityModule, C extends ActivityComponent> {
    ActivityComponentBuilder<M, C> activityModule(M activityModule);
    C build();
}
```

Subcomponents：`MainActivityComponent`的例子看起来如下：

```java
@ActivityScope
@Subcomponent(
        modules = MainActivityComponent.MainActivityModule.class
)
public interface MainActivityComponent extends ActivityComponent<MainActivity> {

    @Subcomponent.Builder
    interface Builder extends ActivityComponentBuilder<MainActivityModule, MainActivityComponent> {
    }

    @Module
    class MainActivityModule extends ActivityModule<MainActivity> {
        MainActivityModule(MainActivity activity) {
            super(activity);
        }
    }
}
```

现在我们可以使用Subcomponents builders的`Map`来得到每一个Activity类的意图builder。让我们如下使用`Multibinding`特性：

```java
@Module(
        subcomponents = {
                MainActivityComponent.class,
                SecondActivityComponent.class
        })
public abstract class ActivityBindingModule {

    @Binds
    @IntoMap
    @ActivityKey(MainActivity.class)
    public abstract ActivityComponentBuilder mainActivityComponentBuilder(MainActivityComponent.Builder impl);

    @Binds
    @IntoMap
    @ActivityKey(SecondActivity.class)
    public abstract ActivityComponentBuilder secondActivityComponentBuilder(SecondActivityComponent.Builder impl);
}
```

`ActivityBindingModule`在`AppComponent`中被安装。就如它被解释的那样，多亏`MainActivityComponent`和`SecondActivityComponent`将会是`AppComponent`的Subcomponent。

现在我们可以注入`Subcomponents` builder的Map（比如，注入到`MyApplication` class）：

```java
public class MyApplication extends Application implements HasActivitySubcomponentBuilders {

    @Inject
    Map<Class<? extends Activity>, ActivityComponentBuilder> activityComponentBuilders;

    private AppComponent appComponent;

    public static HasActivitySubcomponentBuilders get(Context context) {
        return ((HasActivitySubcomponentBuilders) context.getApplicationContext());
    }

    @Override
    public void onCreate() {
        super.onCreate();
        appComponent = DaggerAppComponent.create();
        appComponent.inject(this);
    }

    @Override
    public ActivityComponentBuilder getActivityComponentBuilder(Class<? extends Activity> activityClass) {
        return activityComponentBuilders.get(activityClass);
    }
}
```

我们创建了`HashActivitySubcomponentBuilders`接口作为额外的抽象（因为builders的`Map`不一定是注入到`Appliction`类的）：

```java
public interface HasActivitySubcomponentBuilders {
    ActivityComponentBuilder getActivityComponentBuilder(Class<? extends Activity> activityClass);
}
```

然后最后在Activity class中进行注入的实现：

```java
public class MainActivity extends BaseActivity {

    //...

    @Override
    protected void injectMembers(HasActivitySubcomponentBuilders hasActivitySubcomponentBuilders) {
        ((MainActivityComponent.Builder) hasActivitySubcomponentBuilders.getActivityComponentBuilder(MainActivity.class))
                .activityModule(new MainActivityComponent.MainActivityModule(this))
                .build().injectMembers(this);
    }
}
```

它非常类似于我们的第一个实现，但如上，最重要的事是我们不再传入`ActivityComponent`对象到我们的Activities中。

## 用例example —— instrumentation tests mocking

除了解耦和解决循环依赖（Activity <-> Application），这不是一个大的问题，尤其是在较小的项目/团队中，让我们思考一个这个实现有帮助的真实用例 —— 在instrumentation testing中的mocking依赖。

目前在Android Instrumentation测试中mocking依赖最著名的方式之一是使用[DaggerMock](https://medium.com/@fabioCollini/android-testing-using-dagger-2-mockito-and-a-custom-junit-rule-c8487ed01b56#.eh5zfyou5)（Github [项目地址](https://github.com/fabioCollini/DaggerMock)）。虽然DaggerMock是一个强大的工具，但是非常难理解它面具之下是怎么工作的。其中有一些反射代码不容易被追踪。

在Activity中直接构建Subcomponent，而不需要访问AppComponent类给了我们一个方式来测试单独的Activity并从我们app的其它部分解耦。

听起来很酷，现在我们来看下代码。

在我们的instrumentation test中使用Applicaton类：

```java
public class ApplicationMock extends MyApplication {

    public void putActivityComponentBuilder(ActivityComponentBuilder builder, Class<? extends Activity> cls) {
        Map<Class<? extends Activity>, ActivityComponentBuilder> activityComponentBuilders = new HashMap<>(this.activityComponentBuilders);
        activityComponentBuilders.put(cls, builder);
        this.activityComponentBuilders = activityComponentBuilders;
    }
}
```

`putActivityComponentBuilder()`方法给我们一个对给定Activity类替换ActivityComponentBuilder的实现的方法。

现在来看下我们Espresso Instrumentation Test例子：

```java
@RunWith(AndroidJUnit4.class)
public class MainActivityUITest {

    @Rule
    public MockitoRule mockitoRule = MockitoJUnit.rule();

    @Rule
    public ActivityTestRule<MainActivity> activityRule = new ActivityTestRule<>(MainActivity.class, true, false);

    @Mock
    MainActivityComponent.Builder builder;
    @Mock
    Utils utilsMock;

    private MainActivityComponent mainActivityComponent = new MainActivityComponent() {
        @Override
        public void injectMembers(MainActivity instance) {
            instance.mainActivityPresenter = new MainActivityPresenter(instance, utilsMock);
        }
    };

    @Before
    public void setUp() {
        when(builder.build()).thenReturn(mainActivityComponent);
        when(builder.activityModule(any(MainActivityComponent.MainActivityModule.class))).thenReturn(builder);

        ApplicationMock app = (ApplicationMock) InstrumentationRegistry.getTargetContext().getApplicationContext();
        app.putActivityComponentBuilder(builder, MainActivity.class);
    }
```

一步一步来：

- 我们提供了`MainActivityComponent.Builder`的Mock和所有我们必须要mock的依赖（在本例中只是`Utils`）。我们mocked`Builder`返回一个`MainActivityComponent`的一个自定义实现，它用于注入`MainActivityPresenter`（其中使用了mocked `Utils`）。

- 然后我们的`MainActivityComponent.Builder`替换了在`MyApplication`（28行）中被注入的原始Builder：`app.putActivityComponentBuilder(builder, MainActivity.class);`

- 最后测试 —— 我们mock`Util.getHardcodedText()`方法。注入过程发生在Activity被创建（36行）：`activityRule.launchActivity(new Intent());`接着在最后我们使用Espresso来检验结果。

以上就是全部。如你所见，几乎一切都发生在`MainActivityUITest`类中，而且代码相当简单和可读。

## 源码

如果你想自己去测试这个实现，源码与工作例子展示怎么去创建**Activities Multibinding**和在Instrumentation Tests中mock依赖见Github：[Dagger2Recipes-ActivitiesMultibinding](https://github.com/frogermcs/Dagger2Recipes-ActivitiesMultibinding)

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

