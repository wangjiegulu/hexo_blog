---
title: Android Architecture Component DataBinding -- Get Started（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 12:01:00
---

# Android Architecture Component DataBinding -- Get Started（翻译）

> 原文：<https://developer.android.com/topic/libraries/data-binding/start>

学习如何让你的开发环境准备好使用 Data Binding 库，包括支持 android studio 中的 Data Binding 代码。

Data Binding 库提供了灵活性和广泛的兼容性 —— 它是一个支持库，所以你可以在运行 Android 4.0（API level 14）及以上版本的设备上使用它。

推荐在你的项目中使用最新的 Android Gradle 插件。但是，data binding 支持 1.5.0 及以上版本。更多详情，见如何[更新 Android Gradle 插件](https://developer.android.com/studio/releases/gradle-plugin.html#updating-plugin)。

## 构建环境

要开始使用 Data Binding，在 Android SDK Manager 的 **Support Repository** 中下载库。更多详情见[更新 IDE 和 SDK Tools](https://developer.android.com/studio/intro/update.html)。

要配置你的 app 使用 data binding，在你的 app module 的 `build.gradle` 文件中增加 `dataBinding` 标签，如下所示：

```groovy
android {
    ...
    dataBinding {
        enabled = true
    }
}
```

> 注意：如果你的 app 依赖了使用 data binding 的库，就算你的 app module 没有直接使用 data binding，也必须在你的 app moudle 中进行配置。

## Android Studio 支持 data binding

Android studio 支持 Data Binding 代码的许多编辑功能。举例，它支持以下 data binding 表达式的功能：

- 语法高亮
- 表达式语言的语法错误标记
- xml 代码编译
- 引用，包括 [导航](https://www.jetbrains.com/help/idea/2017.1/navigation-in-source-code.html) （比如导航跳转到声明）和 [快速文档](https://www.jetbrains.com/help/idea/2017.1/viewing-inline-documentation.html)

> 小心：数组和[泛型类型](https://docs.oracle.com/javase/tutorial/java/generics/types.html)，比如 [Observable](https://developer.android.com/reference/android/databinding/Observable.html) 类，可能错误提示不准确。

**Layout Editor** 的 **Preview** 窗口会展示 data binding 表达式的默认值如果提供了的话。举例，**Preview** 窗口在如下声明的 `TextView` 控件中显示 `my_default` 值：

```xml
<TextView android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="@{user.firstName, default=my_default}"/>
```

如果你只需要在项目的设计阶段显示默认值，你可以使用 `tools` 属性来代替默认的表达式值，就像 [Tools Attributes Reference](https://developer.android.com/studio/write/tool-attributes.html) 中描述的那样。

## 用于绑定类的新 data binding 编译器

Android Gradle plugin 版本 `3.1.0-alpha06` 包括了一个新的 data binding 编译器用于生成绑定类。在大多数情况下，新的编译器会增量创建绑定类，这加快了构建过程。学习更多关于绑定类，见 **[生成的绑定类](https://developer.android.com/topic/libraries/data-binding/generated-binding)**。

以前版本的 data binding 编译器在编译你的托管代码的同一步骤中生成绑定类。如果你的托管代码编译失败，你可能会得到多个 binding class 找不到的错误。新的 data binding 编译器通过在编译器生成你的 app 之前生成绑定类来避免这些错误。

要打开新的 data binding 编译器，在你的 `gradle.properties` 文件中增加如下选项：

```groovy
android.databinding.enableV2=true
```

你也可以在 gradle 命令行中增加以下参数来启用新的编译器：

```
-Pandroid.databinding.enableV2=true
```

> 注意：Android Plugin 3.1 版本的新的 data binding 编译器向后不兼容。你需要在启用此功能的情况下生成所有绑定类，以使用增量编译。但是，Android Plugin 3.2 版中的新编译器与以前版本生成的绑定类兼容。新的编译器在 3.2 版本中默认启用。

启用新的 data binding 编译器时，会有以下行为变化：

- 在编译你的托管代码之前，Android Gradle plugin 会为你的 layouts 生成 binding class。
- 如果一个 layout 包含在多个目标资源配置，对于所有共享相同的资源 id（不包括视图类型）的views，data binding 库会使用 `android.view.View` 作为默认的 view 类型
- Library modules 的 Binding class，会被编译打包到相应的 AAR 文件中。 App modules 依赖的这些 library modules 不需要再去生成这些 binding class。更多关于 AAR 文件的详情，见 [创建一个 Android 库](https://developer.android.com/studio/projects/android-library)。
- 一个 module 的 binding adapters 不能更改模块依赖的 adapter 的行为。Binding adapters 只能影响自己 module 的代码 和 module 的使用者的代码。






