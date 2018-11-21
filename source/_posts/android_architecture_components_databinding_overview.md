---
title: Android Architecture Component DataBinding -- 概要（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 11:01:00
---

# Android Architecture Component DataBinding -- 概要（翻译）

Data Binding 库是一个允许你在你的 app 中使用声明性格式而非动态的方式绑定 layout 的 UI 组件到数据源的支持库。

Layout 通常是使用代码在 activities 中调用 UI 层额的方法来定义的。举例，下面代码调用 `[findViewById](https://developer.android.com/reference/android/app/Activity.html#findViewById(int))` 来找到一个 `[TextView](https://developer.android.com/reference/android/widget/TextView.html)` 控件并把它绑定到 `viewModel` 变量的 `userName` 属性：

```kotlin
findViewById<TextView>(R.id.sample_text).apply {
    text = viewModel.userName
}
```

下面的例子展示了怎样使用 Data Binding 库直接在 layout 文件中将 text 分配给控件。这样就不需要调用以上任何的 java 代码。注意在分配表达式中使用 `@{}` 语法:

```xml
<TextView
    android:text="@{viewmodel.userName}" />
```

通过对 layout 文件中的绑定组件，你可以移除 Activities 中很多的 UI 层的调用，使其更简单和更易于维护。这还可以提高应用的性能，并有助于防止内存泄漏和空指针异常。

## 使用 Data Binding 库

通过以下页面了解如何在 android 应用中使用 Data Binding 库。

### [Get Started](https://developer.android.com/topic/libraries/data-binding/start.html)

了解如何让你的开发环境准备好使用 data binding 库，包括支持 android studio 中的 data binding 代码。

### [布局和绑定表达式](https://developer.android.com/topic/libraries/data-binding/expressions.html)

表达式语言允许你编写连接变量到 layout 中的 view 的表达式。Data binding 库会自动生成将 layout 中的 view 与数据对象绑定所需的类。该库提供了 import，variables 等功能，包括可在 layout 中使用的功能。

这些库的特性与你存在的布局是无缝共存的。举例，可以在表达式中使用的绑定变量是被定义在  UI 布局的根标签同级的 `data` 标签。两者标签都被包含在一个 `layout` 标签中，就如下面例子中这样：

```xml
<layout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto">
    <data>
        <variable
            name="viewmodel"
            type="com.myapp.data.ViewModel" />
    </data>
    <ConstraintLayout... /> <!-- UI layout's root element -->
</layout>
```

### [使用可观察的数据对象](https://developer.android.com/topic/libraries/data-binding/observability.html)

Data binding 库提供了类和方法来很容易地观察数据的改变。当底层数据源发生改变时，你不需要担心刷新 UI。你可以使变量或其属性是可观察的。这个库允许你使对象，字段，集合可观察化。

### [生成绑定类](https://developer.android.com/topic/libraries/data-binding/generated-binding.html)

Data binding 库会生成绑定类，用来访问 layout 的变量和 views。此页展示如何使用和自定义生成的绑定类。

### [Binding adapters](https://developer.android.com/topic/libraries/data-binding/binding-adapters.html)

对于每个布局表达式，都有一个绑定适配器，用来进行设置框架调用需要的相应的属性或者监听器。举例，binding adapter 可以负责调用 `setText()` 方法来设置文本属性或调用 `setOnclickListener()` 方法将监听器添加到 click ·。大部分通用的 binding adapters，比如这一章例子中使用的 `android:text` 属性的 adapters 是可用的，它在 `android.databinding.adapters` 包中。常见 binding adapters 的列表，见 [adapters](https://android.googlesource.com/platform/frameworks/data-binding/+/studio-master-dev/extensions/baseAdapters/src/main/java/androidx/databinding/adapters)。你可以创建自己的 adapters，如下面的例子：

```kotlin
@BindingAdapter("app:goneUnless")
fun goneUnless(view: View, visible: Boolean) {
    view.visibility = if (visible) View.VISIBLE else View.GONE
}
```

### [绑定布局 views 到 Architecture Components](https://developer.android.com/topic/libraries/data-binding/architecture.html)

Android Support Library 包括了 [Architecture Components](https://developer.android.com/topic/libraries/architecture/index.html)，它可以帮助你设计具有鲁棒性，可测试性，可维护性的 app。你可以使用 Architecture Components 和 Data Binding 库来进一步简化 UI 的开发。

### [双向数据绑定](https://developer.android.com/topic/libraries/data-binding/two-way)

Data Binding 库支持双向绑定。用于这类绑定支持接收对属性的数据更改，同时监听用户对该属性的修改的能力。