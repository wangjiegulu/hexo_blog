---
title: Android Architecture Component -- 概要（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin"]
header-img: "https://images.unsplash.com/photo-1542125977-7d17f88fe0dc?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=c4c2a1406798f5137f0302659f56fa2e&auto=format&fit=crop&w=2689&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 10:01:00
---

# Android Architecture Component -- 概要（翻译）

> 写在前面：抽空整理一下 Android Architecture Component 官方文档的翻译，根据官方文档会分成很多篇，当自己回顾做个笔记，也方便大家参考。
> 
> 注：以下 “Android Architecture Component”，Android 体系结构组件，在译文中均不做具体翻译。
> <br/>
> 原文：
> - <https://developer.android.com/topic/libraries/architecture/index>
> - <https://developer.android.com/topic/libraries/architecture/adding-components>

## 概要

Android Architecture Components 是一系列可以帮助你设计具有鲁棒性，可测试性，可维护性的 app。从管理 UI 组件生命周期和处理数据持久类开始。

- 轻松管理应用的生命周期。新的 [lifecycle-aware components](https://developer.android.com/topic/libraries/architecture/lifecycle) 可以帮助你管理 Activity 和 Fragment 的生命周期。配置被改变时重建，避免内存泄漏并轻松地加载数据到UI。
- 使用 [LiveData](https://developer.android.com/topic/libraries/architecture/livedata) 来构建数据对象，它会在底层数据库修改时通知给 View。
- [ViewModel](https://developer.android.com/topic/libraries/architecture/viewmodel) 存储了 UI 相关的对象，它不会在 app 被旋转时销毁。
- [Room](https://developer.android.com/topic/libraries/architecture/room) 是一个 SQLite 对象映射库。使用它可以避免模版代码并简单地转换 SQLite 数据表数据到 Java 对象)。Room 提供了编译时期的 SQLite 语句的检查，并可以返回 RxJava，Flowable 和 LiveData 观察者。

## 增加 Components 到你的项目中

在开始之前，我们推荐先阅读 Architecture Components [App 体系结构指南](https://developer.android.com/topic/libraries/architecture/guide.html)。这个指南中有一些有用的准则可以运用到所有的 Android App 中，并且展示了怎么一起使用 Architecture Components。

Architecture Components 目前在 Google Maven 仓库中已经可用，以下步骤：

### 增加 Google Maven 仓库

Android Studio 项目没有被配置默认访问这个仓库。

增加到你的项目中，打开你**项目**(不是你 app 或者 module 的)的 `build.gradle` 文件，在以下一行增加 `google()` 仓库：

```groovy
allprojects {
    repositories {
        jcenter()
        google()
    }
}
```

### 声明依赖

打开你 **app 或者 module** 的 `build.gradle` 文件并增加你需要的 artifacts 作为依赖。你可以增加所有的依赖，或者选择子集。

#### Android X

当前版本的 Arch Components 是使用 Android X 包开发的。这些被列出的表示可用的，并且名称于之前版本（1.x）不同。

更多 AndroidX 相关的重构的信息，还有它们是如何影响类包和模块 id的，请看 AndroidX [重构文档](https://developer.android.com/topic/libraries/support-library/refactor)

#### Kotlin

Kotlin extesion modules 如以下用 `// use -ktx for Kotlin` 标签的则是支持的，替换它即可，比如：

```groovy
implementation "androidx.lifecycle:lifecycle-viewmodel:$lifecycle_version" // use -ktx for Kotlin
```

以及

```groovy
implementation "androidx.lifecycle:lifecycle-viewmodel-ktx:$lifecycle_version"
```

包括 Kotlin extensions 的文档的更多信息，可以看这里 [ktx documentation](https://developer.android.com/kotlin/ktx)。

> 对于基于 Kotlin 的app，确保你使用了 **kapt** 代替 **annotationProcessor**。你应该再增加 **kotlin-kapt** 插件。

#### Futures

Futures 依赖。

```groovy
dependencies {
    def futures_version = "1.0.0-alpha02"

    implementation "androidx.concurrent:concurrent-futures:$futures_version"
}
```

#### Lifecycle

[Lifecycle](https://developer.android.com/topic/libraries/architecture/lifecycle.html) 依赖，包括 [LiveData](https://developer.android.com/topic/libraries/architecture/livedata.html) 和 [ViewModel](https://developer.android.com/topic/libraries/architecture/viewmodel.html)

**AndroidX**

```groovy
dependencies {
    def lifecycle_version = "2.0.0"

    // ViewModel and LiveData
    implementation "androidx.lifecycle:lifecycle-extensions:$lifecycle_version"
    // alternatively - just ViewModel
    implementation "androidx.lifecycle:lifecycle-viewmodel:$lifecycle_version" // use -ktx for Kotlin
    // alternatively - just LiveData
    implementation "androidx.lifecycle:lifecycle-livedata:$lifecycle_version"
    // alternatively - Lifecycles only (no ViewModel or LiveData). Some UI
    //     AndroidX libraries use this lightweight import for Lifecycle
    implementation "androidx.lifecycle:lifecycle-runtime:$lifecycle_version"

    annotationProcessor "androidx.lifecycle:lifecycle-compiler:$lifecycle_version" // use kapt for Kotlin
    // alternately - if using Java8, use the following instead of lifecycle-compiler
    implementation "androidx.lifecycle:lifecycle-common-java8:$lifecycle_version"

    // optional - ReactiveStreams support for LiveData
    implementation "androidx.lifecycle:lifecycle-reactivestreams:$lifecycle_version" // use -ktx for Kotlin

    // optional - Test helpers for LiveData
    testImplementation "androidx.arch.core:core-testing:$lifecycle_version"
}
```

Pre-AndroidX

```groovy
dependencies {
    def lifecycle_version = "1.1.1"

    // ViewModel and LiveData
    implementation "android.arch.lifecycle:extensions:$lifecycle_version"
    // alternatively - just ViewModel
    implementation "android.arch.lifecycle:viewmodel:$lifecycle_version" // use -ktx for Kotlin
    // alternatively - just LiveData
    implementation "android.arch.lifecycle:livedata:$lifecycle_version"
    // alternatively - Lifecycles only (no ViewModel or LiveData).
    //     Support library depends on this lightweight import
    implementation "android.arch.lifecycle:runtime:$lifecycle_version"

    annotationProcessor "android.arch.lifecycle:compiler:$lifecycle_version" // use kapt for Kotlin
    // alternately - if using Java8, use the following instead of compiler
    implementation "android.arch.lifecycle:common-java8:$lifecycle_version"

    // optional - ReactiveStreams support for LiveData
    implementation "android.arch.lifecycle:reactivestreams:$lifecycle_version"

    // optional - Test helpers for LiveData
    testImplementation "android.arch.core:core-testing:$lifecycle_version"
}
```

#### Room

[Room](https://developer.android.com/topic/libraries/architecture/room.html) 依赖，包括 [测试 Room 迁移](https://developer.android.com/topic/libraries/architecture/room.html#db-migration-testing) 和 [Room RxJava](https://developer.android.com/training/data-storage/room/accessing-data.html#query-rxjava)

**AndroidX**

```groovy
dependencies {
    def room_version = "2.1.0-alpha02"

    implementation "androidx.room:room-runtime:$room_version"
    annotationProcessor "androidx.room:room-compiler:$room_version" // use kapt for Kotlin

    // optional - RxJava support for Room
    implementation "androidx.room:room-rxjava2:$room_version"

    // optional - Guava support for Room, including Optional and ListenableFuture
    implementation "androidx.room:room-guava:$room_version"

    // Test helpers
    testImplementation "androidx.room:room-testing:$room_version"
}
```

**Pre-AndroidX**

```groovy
dependencies {
    def room_version = "1.1.1"

    implementation "android.arch.persistence.room:runtime:$room_version"
    annotationProcessor "android.arch.persistence.room:compiler:$room_version" // use kapt for Kotlin

    // optional - RxJava support for Room
    implementation "android.arch.persistence.room:rxjava2:$room_version"

    // optional - Guava support for Room, including Optional and ListenableFuture
    implementation "android.arch.persistence.room:guava:$room_version"

    // Test helpers
    testImplementation "android.arch.persistence.room:testing:$room_version"
}
```

#### Paging

[Paging](https://developer.android.com/topic/libraries/architecture/paging.html)依赖

**AndroidX**

```groovy
dependencies {
    def paging_version = "2.1.0-beta01"

    implementation "androidx.paging:paging-runtime:$paging_version" // use -ktx for Kotlin

    // alternatively - without Android dependencies for testing
    testImplementation "androidx.paging:paging-common:$paging_version" // use -ktx for Kotlin

    // optional - RxJava support
    implementation "androidx.paging:paging-rxjava2:$paging_version" // use -ktx for Kotlin
}
```

**Pre-AndroidX**

```groovy
dependencies {
    def paging_version = "1.0.0"

    implementation "android.arch.paging:runtime:$paging_version"

    // alternatively - without Android dependencies for testing
    testImplementation "android.arch.paging:common:$paging_version"

    // optional - RxJava support
    implementation "android.arch.paging:rxjava2:$paging_version"
}
```

#### Navigation

[Navigation](https://developer.android.com/topic/libraries/architecture/navigation/navigation-implementing.html) 依赖

Navigation 相关的类已经存在于 androidx.navigation 包中，但是当前依赖于 Support Library 27.1.1 和 关联的 Arch component 版本。AndroidX dependencies 依赖的 Navigation 版本将会在未来发布。

```groovy
dependencies {
    def nav_version = "1.0.0-alpha07"

    implementation "android.arch.navigation:navigation-fragment:$nav_version" // use -ktx for Kotlin
    implementation "android.arch.navigation:navigation-ui:$nav_version" // use -ktx for Kotlin

    // optional - Test helpers
    // this library depends on the Kotlin standard library
    androidTestImplementation "android.arch.navigation:navigation-testing:$nav_version"
}
```

#### Safe args

[Safe args](https://developer.android.com/topic/libraries/architecture/navigation/navigation-implementing.html#Safe-args) 依赖，增加下面的 **classPath** 到你**最顶层**的 `build.gradle` 文件中

```groovy
buildscript {
    repositories {
        google()
    }
    dependencies {
        classpath "android.arch.navigation:navigation-safe-args-gradle-plugin:1.0.0-alpha07"
    }
}
```

增加 **你的 app 或者 module** 的 `build.gradle` 文件

```groovy
apply plugin: "androidx.navigation.safeargs"
```

#### WorkManager

[WorkManager](https://developer.android.com/topic/libraries/architecture/workmanager.html) 依赖。

WorkManager 相关的类已经存在于 androidx.navigation 包中，但是当前依赖于 Support Library 27.1.1 和 关联的 Arch component 版本。AndroidX dependencies 依赖的 WorkManager 版本将会在未来发布。

WorkManager 需要 `compileSdk` 版本 28 或者更高。

```groovy
dependencies {
    def work_version = "1.0.0-alpha11"

    implementation "android.arch.work:work-runtime:$work_version" // use -ktx for Kotlin

    // optional - Firebase JobDispatcher support
    implementation "android.arch.work:work-firebase:$work_version"

    // optional - Test helpers
    androidTestImplementation "android.arch.work:work-testing:$work_version"
}
```