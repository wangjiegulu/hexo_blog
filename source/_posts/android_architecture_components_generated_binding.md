---
title: Android Architecture Component DataBinding -- 生成的绑定类（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 15:01:00
---

# Android Architecture Component DataBinding -- 生成的绑定类（翻译）

> 原文：<https://developer.android.com/topic/libraries/data-binding/generated-binding>

Data Binding 库生成绑定类来用于访问 layout 的 variable 和 views。本文展示了如何创建和自定义生成的绑定类。

生成的绑定类链接 layout 中的 variables 和 views。绑定类的名字和包名都是可以[自定义的](https://developer.android.com/topic/libraries/data-binding/generated-binding#custom_binding_class_names)。所有生成的绑定类都继承自 [`ViewDataBinding`](https://developer.android.com/reference/android/databinding/ViewDataBinding.html) 类。

每个 layout 文件都会生成一个 binding class。默认情况下，类名基于 layout 文件的名字。将其转换为 Pascal 大小写, 并向其添加 *Binding* 后缀。上面的 layout 名字是 `activity_main.xml` 所以相应生成的类是 `ActivityMainBinding`。这个类会持有从 layout 属性（比如，`user` 变量）到 layout 的 views 的所有绑定，并知道如何为绑定表达式赋值。

## 创建一个 binding 对象

Binding 对象在 inflating layout 之后马上创建来确保 layout 中 view 层级在使用表达式绑定到 views 之前没有被修改。最常用绑定对象到 layout 的方式是使用绑定类的静态方法。你可以使用绑定类的 `inflate()` 方法来 inflate view 层级和绑定对象到它自身。如下例子：

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val binding: MyLayoutBinding = MyLayoutBinding.inflate(layoutInflater)
}
```

有一个 `inflate()` 方法的替代版本，它除了 [`LayoutInflater`](https://developer.android.com/reference/android/view/LayoutInflater.html) 对象之外还需要一个 [`ViewGroup`](https://developer.android.com/reference/android/view/ViewGroup.html) 对象，如下：

```kotlin
val binding: MyLayoutBinding = MyLayoutBinding.inflate(getLayoutInflater(), viewGroup, false)
```

如果 layout 是使用不同的机制 inflate 的，它可以单独去绑定，如下：

```kotlin
val binding: MyLayoutBinding = MyLayoutBinding.bind(viewRoot)
```

有时无法事先知道绑定类型。在这个情况下，binding 可以使用 [`DataBindingUtil`](https://developer.android.com/reference/android/databinding/DataBindingUtil.html) 类来创建，如下代码片段：

```kotlin
val rootView = LayoutInflater.from(this).inflate(layoutId, parent, attachToParent)
val binding: ViewDataBinding? = DataBindingUtil.bind(viewRoot)
```

如果你在 [`Fragment`](https://developer.android.com/reference/android/app/Fragment.html)，[`ListView`](https://developer.android.com/reference/android/widget/ListView.html)，[`RecyclerView`](https://developer.android.com/reference/android/support/v7/widget/RecyclerView.html) adapter 中使用 data binding，你可能更喜欢使用 bindings classes 的 [`inflate`](https://developer.android.com/reference/android/databinding/DataBindingUtil.html#inflate(android.view.LayoutInflater,%20int,%20android.view.ViewGroup,%20boolean,%20android.databinding.DataBindingComponent)) 方法，或者 [`DataBindingUtil`](https://developer.android.com/reference/android/databinding/DataBindingUtil) 类，如下所示：

```kotlin
val listItemBinding = ListItemBinding.inflate(layoutInflater, viewGroup, false)
// or
val listItemBinding = DataBindingUtil.inflate(layoutInflater, R.layout.list_item, viewGroup, false)
```

## 具有 ID 的 Views

Data Binding 库在绑定类中为每个 layout 中带有 ID 的 view 创建了一个不可改变的属性。比如，下面的 layout 中，Data Binding 库创建了 `firstName` 和 `lastName` 两个 `TextView` 了行的属性：

```kotlin
<layout xmlns:android="http://schemas.android.com/apk/res/android">
   <data>
       <variable name="user" type="com.example.User"/>
   </data>
   <LinearLayout
       android:orientation="vertical"
       android:layout_width="match_parent"
       android:layout_height="match_parent">
       <TextView android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="@{user.firstName}"
   android:id="@+id/firstName"/>
       <TextView android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="@{user.lastName}"
  android:id="@+id/lastName"/>
   </LinearLayout>
</layout>
```

库一次从 view 层级中取出包括 IDs 的 views。对于 layout 中的每个 view 来说，这个机制会比调用 [`findViewById()`](https://developer.android.com/reference/android/app/Activity.html#findViewById(int)) 方法更快。

如果它们没有 data binding 则不必要，但是在一些情况下，仍然需要从代码中访问 view。

## Variables

Data Binding 库针对每个在 layout 声明了的 variable 生成访问方法。比如，下面的 layout 在绑定类中为 `user`，`image` 和 `note` 生成 setter 和 getter 方法：

```xml
<data>
   <import type="android.graphics.drawable.Drawable"/>
   <variable name="user" type="com.example.User"/>
   <variable name="image" type="Drawable"/>
   <variable name="note" type="String"/>
</data>
```

## ViewStubs

不像普通的 View，[`ViewStub`](https://developer.android.com/reference/android/view/ViewStub.html) 对象以不可见的 view 作为开始。当它们被设置可见或者明确地 inflate 时，它们通过 inflating 另一个 layout 来替换它们自己。

因为 `ViewStub` 本质上在 view 层级上是不可见的，binding 对象中的 view 也必须消失来运行 gc 回收。因为 view 是 final 的，一个 [`ViewStubProxy`](https://developer.android.com/reference/android/databinding/ViewStubProxy.html) 对象在生成的绑定类中取代 `ViewStub`，使你可以在 `ViewStub` 存在时访问它，并在 `ViewStub` 被 inflate 时访问 view 层次结构。

当 inflate 另一个 layout，必须为新 layout 建立绑定。因此，`ViewStubProxy` 必须监听 `ViewStub` 的 [`OnInflateListener`](https://developer.android.com/reference/android/view/ViewStub.OnInflateListener.html)，并在需要时建立绑定。因为只有一个监听器可以在给定的时间里存在，`ViewStubProxy` 允许你去设置一个 `OnInflateListener`，它会在建立绑定后回调。

## 立即绑定

当一个 variable 或者 observable 对象改变时，binding 会在下一帧之前调度变化。但是有时 binding 需要立即执行。要强制执行，使用 [`executePendingBindings()`](https://developer.android.com/reference/android/databinding/ViewDataBinding.html#executePendingBindings()) 方法。

## 高级绑定

### 动态变量

有时，是不知道特定的绑定类的。比如，一个针对任意布局的 [`RecyclerView.Adapter`](https://developer.android.com/reference/android/support/v7/widget/RecyclerView.Adapter.html) 是不知道具体特定的绑定类的。在调用 [onBindViewHolder()](https://developer.android.com/reference/android/support/v7/widget/RecyclerView.Adapter.html#onBindViewHolder(VH,%20int)) 方式时，它仍必须要分配 binding 的值。

在下面的例子中，所有 `RecyclerView` 绑定的布局都有一个 `item` 变量。`BindingHolder` 对象有一个 `getBinding()` 方法返回 [`ViewDataBinding`](https://developer.android.com/reference/android/databinding/ViewDataBinding.html) 基类。

```kotlin
override fun onBindViewHolder(holder: BindingHolder, position: Int) {
    item: T = mItems.get(position)
    holder.binding.setVariable(BR.item, item);
    holder.binding.executePendingBindings();
}
```

> Data Binding 库在 module 包下生成了一个名为 **BR** 的类，它包含了用户数据绑定的 resources IDs。在上面的例子中，库自动生成了 **BR.item** 变量。

## 后台线程

只要数据模型不是集合，你可以在后台线程中更改数据模型。Data Binding 在计算时期对每个variable / field 进行本地化，以避免任何并发问题。

## 自定义绑定类名

默认情况下，一个绑定名字是基于 layout 的名字生成的，以大写字母开头，移除下划线（`_` ），大写下一个字母，添加后缀单词 **Binding**。这个类被放置在这个 module 包下的 `databinding` 包中。比如，layout 文件 `contact_item.xml` 生成 `ContactItemBinding` 类。如果 module 包是 `com.example.my.app`，则绑定类则放置在 `com.example.my.app.databinding` 包中。

通过调整 `data` 标签的 `class` 属性，绑定类可以重命名或放置在不同的包中。举例，下面的 layout 在当前的 module 的 `databinding` 包中 生成 `ContactItem` 类：

```kotlin
<data class="ContactItem">
    …
</data>
```

你可以通过在类名之前加上句点的方式在不同的包中生成绑定类。下面的例子在 module 包中生成绑定类：

```kotlin
<data class=".ContactItem">
    …
</data>
```

你也可以是用全包名来指定生成绑定类的名字。下面例子在 `com.example` 包中创建 `ContactItem` 绑定类：

```kotlin
<data class="com.example.ContactItem">
    …
</data>
```