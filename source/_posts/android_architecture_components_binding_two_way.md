---
title: Android Architecture Component DataBinding -- 双向绑定（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 18:01:00
---

# Android Architecture Component DataBinding -- 双向绑定（翻译）

> 原文：<https://developer.android.com/topic/libraries/data-binding/two-way>

要使用双向数据绑定，你可以在一个属性上设置一个值，并设置一个监听器来响应这个属性的变化：

```kotlin
<CheckBox
    android:id="@+id/rememberMeCheckBox"
    android:checked="@{viewmodel.rememberMe}"
    android:onCheckedChanged="@{viewmodel.rememberMeChanged}"
/>
```

双向绑定为这个过程提供了一个捷径：

```kotlin
<CheckBox
    android:id="@+id/rememberMeCheckBox"
    android:checked="@={viewmodel.rememberMe}"
/>
```

使用 `@={}` 记号，重点是里面的 "=" 号，接收对属性的数据更改，并同时监听用户更新。

为了对返回数据中的变化做出反应，你可以让你的 layout variable 是一个 `Observable` 的实现，通常是 [`BaseObservable`](https://developer.android.com/reference/android/databinding/BaseObservable)，并使用 [`@Bindable`](https://developer.android.com/reference/android/databinding/Bindable) 注解，如下代码片段：

```kotlin
class LoginViewModel : BaseObservable {
    // val data = ...

    @Bindable
    fun getRememberMe(): Boolean {
        return data.rememberMe
    }

    fun setRememberMe(value: Boolean) {
        // Avoids infinite loops.
        if (data.rememberMe != value) {
            data.rememberMe = value

            // React to the change.
            saveData()

            // Notify observers of a new value.
            notifyPropertyChanged(BR.remember_me)
        }
    }
}
```

因为 bindable 属性的 getter 方法是 `getRememberMe()`，则相应的 setter 方法自动使用 `setRememberMe()` 这个名字。

更多关于 `BaseObservable` 和 `@Bindable` 的信息，见 [使用可观察的数据对象](https://developer.android.com/topic/libraries/data-binding/observability)。

## 自定义属性实现双向绑定

平台提供了 [最常用的双向绑定属性](https://developer.android.com/topic/libraries/data-binding/two-way#two-way-attributes) 双向绑定实现和监听器改变，你可以作为你 app 的一部分去使用。如果你想使用自定义属性的双向绑定，你需要使用 [`@InverseBindingAdapter`](https://developer.android.com/reference/android/databinding/InverseBindingAdapter) 和 [`@InverseBindingMethod `](https://developer.android.com/reference/android/databinding/InverseBindingMethod) 注解。

举个例子，如果你想在名为 `MyView` 的自定义 view 上面开启 `"time"` 属性的双向绑定，通过以下几步完成：

1. 在设置初始值的方法上添加注解，并在值使用 `@BindingAdapter` 更改时进行更新：

    ```kotlin
    @BindingAdapter("time")
    @JvmStatic fun setTime(view: MyView, newValue: Time) {
        // 这里很重要，要打破潜在的死循环
        if (view.time != newValue) {
            view.time = newValue
        }
    }
    ```

2. 在读取 view 值的方法上添加 `@InverseBindingAdapter` 注解：

    ```kotlin
    @InverseBindingAdapter("time")
    @JvmStatic fun getTime(view: MyView) : Time {
        return view.getTime()
    }
    ```

此时，Data Binding 知道在数据更改时要执行的操作（它会调用加了 [`@BindingAdapter`](https://developer.android.com/reference/android/databinding/BindingAdapter) 注解的方法）和当属性发生改变时（它会调用加了[`InverseBindingListener`](https://developer.android.com/reference/android/databinding/InverseBindingListener)注解的方法）。但是，它不知道属性何时或如何被更改。

为此，你需要在 view 上面设置监听器。它可以自定义监听器，关联到你自定义的 view，或者它是一般事件，比如失去焦点，文本的变化等。在方法上增加一个 `@BindingAdapter` 注解，为属性设置一个改变的监听器：

```kotlin
@BindingAdapter("app:timeAttrChanged")
@JvmStatic fun setListeners(
        view: MyView,
        attrChange: InverseBindingListener
) {
    // Set a listener for click, focus, touch, etc.
}
```

这个监听器包含一个 `InverseBindingListener` 作为参数。你使用 `InverseBindingListener` 来告诉 data binding 系统属性被修改了。系统会开始调用加了 `@InverseBindingAdapter` 注解的方法，等等。

> 每一个双向绑定生成了一个**合成的事件属性**。这个属性与基属性具有一个相同的名字，但是它包含了一个 “**AttrChanged**” 的后缀。合成事件属性允许库去创建一个使用 **@BindingAdapter** 注解的方法，以便将事件监听器与 View 的相应的实例相关联。

在实践中，这个监听器中包含了一些不平凡的逻辑，包括单向数据绑定的监听器。举例见 text attribute change 的 adapter，[TextViewBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/TextViewBindingAdapter.java#344)

## 转换器

如果绑定到一个 [`View`](https://developer.android.com/reference/android/view/View) 的变量需要在展示出来之前被格式化，转换，某种方法修改，它可能需要一个 `Converter` 对象。

举个例子，用一个 `EditText` 对象展示一个日期：

```xml
<EditText
    android:id="@+id/birth_date"
    android:text="@={Converter.dateToString(viewmodel.birthDate)}"
/>
```

`viewmodel.birthDate` 属性包含了一个类型 `Long` 的值，所以它需要通过一个抓暖气来格式化。

因为正在使用双向表达式，所以还需要一个逆转换器，让库知道如何将用户提供的字符串转换回支持数据类型，在这里是 `Long`。这个过程是通过将 [`@InverseMethod`](https://developer.android.com/reference/android/databinding/InverseMethod) 注解添加到其中一个转换器中，并让这个批注引用逆转换器来完成的。此配置的示例出现在下面的代码段中：

```kotlin
object Converter {
    @InverseMethod("stringToDate")
    fun dateToString(
        view: EditText, oldValue: Long,
        value: Long
    ): String {
        // Converts long to String.
    }

    fun stringToDate(
        view: EditText, oldValue: String,
        value: String
    ): Long {
        // Converts String to long.
    }
}
```

## 使用双向绑定的死循环

使用双向数据绑定时，注意不要引入死循环。当用户改变一个属性，`@InverseBindingAdapter` 注解的方法会被调用，并将该值分配给后端属性。这反过来又会调用使用 `@BindingAdapter` 注解的方法，这将触发对使用 `@InverseBindingAdapter` 注解的方法的另一个调用，等等。

因为这个原因，在 `@BindingAdapter` 注解的方法中通过对比新旧的值来打破潜在可能的死循环是很重要的。

## 双向属性

当你使用以下表中属性时，平台提供了内置的双向数据绑定。有关平台如何提供此支持的详细信息，请参阅相应 binding adapters 的实现:

|类|属性|Binding Adapter|
|---|---|---|
|[AdapterView](https://developer.android.com/reference/android/widget/AdapterView)|android:selectedItemPosition<br/>android:selection|[AdapterViewBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/AdapterViewBindingAdapter.java)|
|[CalendarView](https://developer.android.com/reference/android/widget/CalendarView)|android:date|[CalendarViewBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/CalendarViewBindingAdapter.java)|
|[CompoundButton](https://developer.android.com/reference/android/widget/CompoundButton)|[android:checked](https://developer.android.com/reference/android/R.attr#checked)|[CompoundButtonBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/CompoundButtonBindingAdapter.java)|
|[DatePicker](https://developer.android.com/reference/android/widget/DatePicker)|android:year<br/>android:month<br/>android:day|[DatePickerBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/DatePickerBindingAdapter.java)|
|[NumberPicker](https://developer.android.com/reference/android/widget/NumberPicker)|[android:value](https://developer.android.com/reference/android/R.attr#value)|[NumberPickerBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/NumberPickerBindingAdapter.java)|
|[RadioButton](https://developer.android.com/reference/android/widget/RadioButton)|[android:checkedButton](https://developer.android.com/reference/android/R.attr#checkedButton)|[RadioGroupBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/RadioGroupBindingAdapter.java)|
|[RatingBar](https://developer.android.com/reference/android/widget/RatingBar)|[android:rating](https://developer.android.com/reference/android/R.attr#rating)|[RatingBarBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/RatingBarBindingAdapter.java)|
|[SeekBar](https://developer.android.com/reference/android/widget/SeekBar)|[android:progress](https://developer.android.com/reference/android/R.attr#progress)|[SeekBarBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/SeekBarBindingAdapter.java)|
|[TabHost](https://developer.android.com/reference/android/widget/TabHost)|android:currentTab|[TabHostBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/TabHostBindingAdapter.java)|
|[TextView](https://developer.android.com/reference/android/widget/TextView)|[android:text](https://developer.android.com/reference/android/R.attr#text)|[TextViewBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/TextViewBindingAdapter.java)|
|[TimePicker](https://developer.android.com/reference/android/widget/TimePicker)|	android:hour<br/>android:minute|[TimePickerBindingAdapter](https://android.googlesource.com/platform/frameworks/data-binding/+/3b920788e90bb0abe615a5d5c899915f0014444b/extensions/baseAdapters/src/main/java/android/databinding/adapters/TimePickerBindingAdapter.java)|





