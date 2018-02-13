---
title: 在Android上编写模块化项目（翻译）
tags: ["android", "architecture", "framework", "modular", "room", "dagger2", "kotlin", "翻译"]
categories: ["android", "gradle plugin"]
---

> 原文：<https://medium.com/mindorks/writing-a-modular-project-on-android-304f3b09cb37>

# 在Android上编写模块化项目（翻译）

当我们在 Android Studio 上创建一个新的项目时，自带一个 `app` module。这时我们大多数人编写整个应用的地方。每次点击 `run` 按钮都会触发我们整个所有 module 上的 gradle 构建，并检查所有文件是否有变化。这就是为什么 gradle 构建会在更大的应用程序上花费 [10分钟](https://eng.uber.com/android-monorepo/)的时间，并且减慢开发者的[输出](https://imgs.xkcd.com/comics/compiling.png)。

要解决这个问题，复杂的应用程序，如 Uber 决定对它们的应用程序进行模块化并从中[获得](https://www.youtube.com/watch?v=j6CiHlapado)了很多。下面是试用模块化项目的一些优势：

<!-- more -->

- [更快](https://proandroiddev.com/modular-architecture-for-faster-build-time-d58397cb7bfe)的 gradle 构建
- 跨应用/模块复用通用的功能
- 易于插拔到[Instant apps](https://developer.android.com/topic/instant-apps/overview.html#features)
- 更好的团队工作，一个人可以单独负责一个模块
- 更流畅地git flows

由于上述优势，当我刚开始[Posts](https://github.com/karntrehan/Posts/)这个应用时，我就在始终坚持使用模块化方法。对此，Android 团队已经给我们提供了一些[工具](https://developer.android.com/google/play/publishing/multiple-apks.html#CreatingApks)，但是我确实遇到了一些障碍，一下是我学习到的内容：

## 我该怎么分割我的 modules ？

你的应用程序是流程集构成的，比如，Google Play 有**应用详情**流，它包含了简要，描述详情，应用截图，评论活动等。

![](https://user-images.githubusercontent.com/5423194/36140651-ed8f0d6c-10dc-11e8-9733-e306fd72f9d0.jpeg)

所有这些都可以归为同一模块 —— `app-details`。

你的应用会包含多个类似流程的模块，有 `authentication`, `settings`, `on-boarding`等等。当然还有一些不需要UI元素呈现的模块如 —— `notifications`, `analytics`, `first-fetch`等等。这些模块包含与流程有关的 activities, repositories, entities和依赖注入相关东西。


<div style="text-align: center;">
<img src='https://user-images.githubusercontent.com/5423194/36140945-09253f5a-10de-11e8-8ded-003e53fd78b6.png'/>
</div>

但是这些模块中总是有一些共同的功能和工具。这就是为什么你需要一个 core 模块。

## 什么是 core 模块 ？

`Core` 模块是一个你项目中简单的 module 库。core 库可以（除其它外），

- 给你的依赖注入框架提供全局依赖，如 [Retrofit](https://github.com/karntrehan/Posts/blob/master/core/src/main/java/com/karntrehan/posts/core/di/NetworkModule.kt), [SharedPreferences](https://github.com/karntrehan/Posts/blob/master/core/src/main/java/com/karntrehan/posts/core/di/StorageModule.kt)等等。
- 包含工具类和[扩展方法](https://github.com/karntrehan/Posts/tree/master/core/src/main/java/com/karntrehan/posts/core/extensions)
- 包含[全局类](https://github.com/karntrehan/Posts/blob/master/core/src/main/java/com/karntrehan/posts/core/networking/Outcome.kt)和回调
- 在 application 类中的[初始化库](https://github.com/karntrehan/Posts/blob/master/core/src/main/java/com/karntrehan/posts/core/application/CoreApp.kt)，如 Firebase Analytics，Crashlytics，LeakCanary，Stetho等等

## 怎么使用第三方库？

核心(`core`)模块的其中一个职责是为你的功能(`feature`)模块提供外部依赖。这使得很容易实现在你的 `feature` 模块中共享相同版本的库。只需要在你的 `core` 模块的 dependencies 中使用 `api`，这样你就能在所有 `feature` 模块中使用它们。

```groovy
dependencies {
    api fileTree(include: ['*.jar'], dir: 'libs')
    api deps.support.appCompat
    api deps.support.recyclerView
    api deps.support.cardView
    api deps.support.support
    api deps.support.designSupport

    api deps.android.lifecycleExt
    api deps.android.lifecycleCommon
    api deps.android.roomRuntime
    api deps.android.roomRx

    api deps.kotlin.stdlib

    api deps.reactivex.rxJava
    api deps.reactivex.rxAndroid

    api deps.google.dagger
    kapt deps.google.daggerProcessor

    api deps.square.picasso
    api deps.square.okhttpDownloader

    api deps.square.retrofit
    api deps.square.okhttp
    api deps.square.gsonConverter
    api deps.square.retrofitRxAdapter

    implementation deps.facebook.stetho
    implementation deps.facebook.networkInterceptor

    testApi deps.test.junit
    androidTestApi deps.test.testRunner
    androidTestApi deps.test.espressoCore
}
```

有种依赖的可能性是只有对 `feature-a` 模块有用，但是在 `feature-b` 中无用。对于这种情况，我推荐在你的 core 的依赖中使用 `api`，因为 proguard 注意到而不会包含在 `feature-b` instant app 中。

## 怎么使用 Room ？

这个困扰我挺久的时间。我们希望把我们的数据库定义到 `core` 模块中，因为它是我们应用程序要共享的通用的功能。为了让 Room 工作，你需要一个包含了所有 entity 类的数据库文件。

```kotlin
@Database(entities = [Post::class, User::class, Comment::class], version = 1,exportSchema = false)
abstract class PostDb : RoomDatabase() {
    abstract fun postDao(): PostDao
    abstract fun userDao(): UserDao
    abstract fun commentDao(): CommentDao
}
```

但是，如上面提到的，我们的 entity 类是被定义在 `feature` 模块中，而且 `core` 模块不能去访问它们。这是我碰到障碍的地方，经过一番思考后，你做了一件最棒的事，寻求 [Yigit](https://github.com/yigit) 的帮助。

Yigit 阐明了观点，你必须要在每个 `feature`模块中都创建一个新的 db 文件，然后每个模块一个数据库。

这有几个好处：

- [迁移](https://medium.com/google-developers/understanding-migrations-with-room-f01e04b07929)是模块化的
- 即时 app 仅包含它们需要的表
- 查询会更快

缺点：

- 跨模块数据关系将不可能

*注意：为了 Room 的注解能够工作，不要忘记在你的 `feature` 模块中增加下面依赖*

```groovy
kapt "android.arch.persistence.room:compiler:${versions.room}"
```

## 怎么使用 Dagger 2 ？

同样的问题 Dagger 也遇到了。我的 core 模块中的 application 类不能访问和初始化我 `feature` 模块中的组件。这是从属组件完美的用例。

你的 core 组件定义了它想要暴露给依赖组件的依赖关系

```kotlin
@Singleton
@Component(modules = [AppModule::class, NetworkModule::class, StorageModule::class, ImageModule::class])
interface CoreComponent {

    fun context(): Context

    fun retrofit(): Retrofit

    fun picasso(): Picasso

    fun sharedPreferences(): SharedPreferences

    fun scheduler(): Scheduler
}
```

您的模块组件将 `CoreComponent` 定义为依赖项，并使用传递的依赖

```kotlin
@ListScope
@Component(dependencies = [CoreComponent::class], modules = [ListModule::class])
interface ListComponent {
    fun inject(listActivity: ListActivity)
}

@Module
@ListScope
class ListModule {

    /*Uses parent's provided dependencies like Picasso, Context and Retrofit*/
    @Provides
    @ListScope
    fun adapter(picasso: Picasso): ListAdapter = ListAdapter(picasso)

    @Provides
    @ListScope
    fun postDb(context: Context): PostDb = Room.databaseBuilder(context, PostDb::class.java, Constants.Posts.DB_NAME).build()

    @Provides
    @ListScope
    fun postService(retrofit: Retrofit): PostService = retrofit.create(PostService::class.java)
}
```

## 在哪里初始化我的 components ？

我为我的功能的所有组件创建了一个单例 holder。这个 holder 用于创建，维护和销毁我的 component 实例。

```kotlin
@Singleton
object PostDH {
    private var listComponent: ListComponent? = null

    fun listComponent(): ListComponent {
        if (listComponent == null)
            listComponent = DaggerListComponent.builder().coreComponent(CoreApp.coreComponent).build()
        return listComponent as ListComponent
    }

    fun destroyListComponent() {
        listComponent = null
    }
}
```

*注意：为了 Dagger 的注解能够工作，不要忘记在你的 `feature` 模块中增加下面依赖*

```groovy
kapt "com.google.dagger:dagger-compiler:${versions.dagger}"
```

## 总结

尽管把你的单独的 application 转成模块化有一些棘手，其中一些我试图通过上面的方法来解决，优点是深刻的。如果您在模块中遇到任何障碍，请随时在下面提及它们，我们可以一起讨论解决方案。

谢谢。


