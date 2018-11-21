---
title: Android Architecture Component DataBinding -- 使用可观察的数据对象（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 14:01:00
---

# Android Architecture Component DataBinding -- 使用可观察的数据对象（翻译）

> 原文：<https://developer.android.com/topic/libraries/data-binding/observability>

可观察性是指对象将其数据的变化通知他人的能力。Data Binding 库允许你去创建对象，属性，可观察集合。

任何普通的对象都可以使用 Data Binding，但是修改修改之后不会自动引发 UI 的更新。Data Binding 可以使数据对象能够在其数据更改时通知其他对象，也就是监听器。有 3 种不同的可观察类的类型：[`objects`](https://developer.android.com/topic/libraries/data-binding/observability#observable_objects)，[`fields`](https://developer.android.com/topic/libraries/data-binding/observability#observable_fields) 和 [`collections`](https://developer.android.com/topic/libraries/data-binding/observability#observable_collections)。

当这些可观察的数据对象之一绑定到 UI，并且数据对象的属性发生改变时，UI 将自动更新。

## Observable fields

创建实现了 [`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 接口的类会涉及到一些工作，如果你的类只有几个属性，这就不值得这么做。在这种情况下，你可以使用泛型 [`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 类和下面几种特定于原生的类来使得属性变得可观察：

- [`ObservableBoolean`](https://developer.android.com/reference/android/databinding/ObservableBoolean.html)
- [`ObservableByte`](https://developer.android.com/reference/android/databinding/ObservableByte.html)
- [`ObservableChar`](https://developer.android.com/reference/android/databinding/ObservableChar.html)
- [`ObservableShort`](https://developer.android.com/reference/android/databinding/ObservableShort.html)
- [`ObservableInt`](https://developer.android.com/reference/android/databinding/ObservableInt.html)
- [`ObservableLong`](https://developer.android.com/reference/android/databinding/ObservableLong.html)
- [`ObservableFloat`](https://developer.android.com/reference/android/databinding/ObservableFloat.html)
- [`ObservableDouble`](https://developer.android.com/reference/android/databinding/ObservableDouble.html)
- [`ObservableParcelable`](https://developer.android.com/reference/android/databinding/ObservableParcelable.html)

Observable fields 是仅包含了一个属性的可观察对象。原始数据类型版本是为了避免访问时的装箱和拆箱操作。要使用这个机制，创建一个在 Java 语言中的 `public final` 属性或者在 Kotlin 语言中的只读属性，如下所示：

```kotlin
class User {
    val firstName = ObservableField<String>()
    val lastName = ObservableField<String>()
    val age = ObservableInt()
}
```

要访问属性的值，使用 [`set()`](https://developer.android.com/reference/android/databinding/ObservableField.html#set) 和 [`get()`](https://developer.android.com/reference/android/databinding/ObservableField.html#get) 访问器方法，如下：

```kotlin
user.firstName = "Google"
val age = user.age
```

> Android Studio 3.1 或者更高的版本允许你使用 LiveData 替换 Obervable 对象，它可以给你的 app 带来额外的好处。更多详情见 [当数据改变时使用 LiveData 通知 UI](https://developer.android.com/topic/libraries/data-binding/architecture.html#livedata)。

### Observable collections

一些 app 使用动态结构来保存数据。Observable collections 允许你使用一个 key 来访问这些结构。[`ObservableArrayMap`](https://developer.android.com/reference/android/databinding/ObservableArrayMap.html) 类在 key 是引用类型时候（比如 `String`）是很有用的，比如下面的例子：

```kotlin
ObservableArrayMap<String, Any>().apply {
    put("firstName", "Google")
    put("lastName", "Inc.")
    put("age", 17)
}
```

在 layout 中，可以使用 string keys 来访问，如下：

```xml
<data>
    <import type="android.databinding.ObservableMap"/>
    <variable name="user" type="ObservableMap<String, Object>"/>
</data>
…
<TextView
    android:text="@{user.lastName}"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
<TextView
    android:text="@{String.valueOf(1 + (Integer)user.age)}"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
```

[`ObservableArrayList`](https://developer.android.com/reference/android/databinding/ObservableArrayList.html) 类在 key 是 integer 时很有用，如下：

```kotlin
ObservableArrayList<Any>().apply {
    add("Google")
    add("Inc.")
    add(17)
}
```

在 layout 中，list 可以通过 indexes 访问，如下：

```xml
<data>
    <import type="android.databinding.ObservableList"/>
    <import type="com.example.my.app.Fields"/>
    <variable name="user" type="ObservableList<Object>"/>
</data>
…
<TextView
    android:text='@{user[Fields.LAST_NAME]}'
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
<TextView
    android:text='@{String.valueOf(1 + (Integer)user[Fields.AGE])}'
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
```

## Observable objects

一个实现了 [`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 接口的类允许监听器的注册来针对 observable 对象上属性被改变时希望收到通知。

[`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 接口有一个增加和移除监听器的机制，但是你必须决定什么时候发送通知。为了让开发更简单，Data Binding 库提供了 [`BaseObservable`](https://developer.android.com/reference/android/databinding/BaseObservable.html) 类，它实现了监听器的注册机制。实现了 `BaseObservable` 的类负责属性变化时的通知。在 getter 方法上面增加 [`Bindable`](https://developer.android.com/reference/android/databinding/Bindable.html) 注解，在 setter 方法上面调用 [`notifyPropertyChanged()`](https://developer.android.com/reference/android/databinding/BaseObservable.html#notifyPropertyChanged(int)) 方法，如下：

```kotlin
class User : BaseObservable() {

    @get:Bindable
    var firstName: String = ""
        set(value) {
            field = value
            notifyPropertyChanged(BR.firstName)
        }

    @get:Bindable
    var lastName: String = ""
        set(value) {
            field = value
            notifyPropertyChanged(BR.lastName)
        }
}
```

Data Binding 在 module 包下面（包含了 resource ids）生成了一个名为 `BR` 的类用于数据绑定。[`Bindable`](https://developer.android.com/reference/android/databinding/Bindable.html) 注解在编译时期在 `BR` 类中生成了一个 entry。如果数据类不能被修改，[`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 接口可以通过使用一个[`PropertyChangeRegistry`](https://developer.android.com/reference/android/databinding/PropertyChangeRegistry.html)来有效地注册和通知监听器的方式被实现。