---
title: Android Architecture Component DataBinding -- Binding adapters（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 16:01:00
---

# Android Architecture Component DataBinding -- Binding adapters（翻译）

> 原文：<https://developer.android.com/topic/libraries/data-binding/binding-adapters>

Binding adapters 负责对设置值进行适当的框架调用。一个例子是像调用 [`setText()`](https://developer.android.com/reference/android/widget/TextView.html#setText(char[],%20int,%20int)) 方法去设置属性值。另一个例子是像调用 [`setOnClickListener()`](https://developer.android.com/reference/android/view/View.html#setOnClickListener(android.view.View.OnClickListener)) 方法去设置一个事件监听器。

Data Binding 库允许你去指定设置一个值的方法，提供你自己的绑定逻辑，以及通过使用 adapters 来指定返回对象的类型。

## 设置属性值

每当绑定的值改变，生成的绑定类必须调用一个 view 的表达式 的 setter 方法。你可以让 Data Binding 自动确定方法，显式声明方法或提供自定义逻辑以选择方法。

### 自动选择方法

对于名为 `name` 的属性，库会自动尝试寻找方法 `setExample(arg)`，它接受一个相应的类型作为参数。不考虑属性的命名空间，在搜索方法时只使用属性名称和类型。

举个例子，给定 `android:text="@{user.name}"` 表达式，库会自动寻找一个 `setText(args)` 的方法，它接收一个 `user.getName()` 返回值的类型的参数。如果 `user.getName()` 返回类型是 `String`，库会去寻找一个接收一个 `String` 类型参数的 `setText()` 方法。如果 `user.getName()` 返回类型是 `int`，库会去寻找一个接收一个 `int` 类型参数的 `setText()` 方法。表达式必须返回正确的类型，必要时你可以去对返回值进行转型。

甚至没有给定名字的属性存在，Data Binding 也能正常工作。你可以通过 data binding 为任何 setter 创建属性。下面 layout 自动使用 [`setScrimColor(int)`](https://developer.android.com/reference/android/support/v4/widget/DrawerLayout.html#setScrimColor(int)) 和 [`setDrawerListener(DrawerListener)`](https://developer.android.com/reference/android/support/v4/widget/DrawerLayout.html#setDrawerListener(android.support.v4.widget.DrawerLayout.DrawerListener)) 方法作为 `app:scrimColor` 和 `app:drawerListener` 属性的 setter 方法。分别为：

```xml
<android.support.v4.widget.DrawerLayout
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:scrimColor="@{@color/scrim}"
    app:drawerListener="@{fragment.drawerListener}">
```

### 指定自定义方法名

一些属性的 setter 与名称不匹配。在这种情况下，属性可以使用 [`BindingMethods`](https://developer.android.com/reference/android/databinding/BindingMethods.html) 注解进行 setter 的关联。注解可以与类一起使用，并且可以包含多个 [`BindingMethod`](https://developer.android.com/reference/android/databinding/BindingMethod.html) 注解，每一个都有一个重命名的方法。BindingMethods 注解可以被加在你 app 中的任何类上面。下面的例子中，`android:tint` 属性与 [`setImageTintList(ColorStateList)`](https://developer.android.com/reference/android/widget/ImageView.html#setImageTintList(android.content.res.ColorStateList)) 方法关联，而不是 `setTint()` 方法：

```kotlin
@BindingMethods(value = [
    BindingMethod(
        type = android.widget.ImageView::class,
        attribute = "android:tint",
        method = "setImageTintList")])
```

大多数情况下，你不需要重命名 Android Framework 类中的 setters。属性已经使用名称约定实现了自动查找匹配方法。

### 提供自定义逻辑

一些属性需要自定义绑定逻辑。举个例子，没有一个与 `android:paddingLeft` 属性关联的 setter。但是提供了 `setPadding(left, top, right, bottom)`。一个带有 [`BindingAdapter`](https://developer.android.com/reference/android/databinding/BindingAdapter.html) 注解的，静态的 binding adapter 方法可以允许你自定义属性调用的 setter 是怎么样的。

Android Framework 类的属性已经创建了 `BindingAdapter` 注解。举例，下面的例子展示了 `paddingLeft` 属性的 binding adapter：

```kotlin
@BindingAdapter("android:paddingLeft")
fun setPaddingLeft(view: View, padding: Int) {
    view.setPadding(padding,
                view.getPaddingTop(),
                view.getPaddingRight(),
                view.getPaddingBottom())
}
```

参数类型是很重要的，第一个参数决定了与属性相关联的 view 的类型。第二个参数决定了给定属性表达式中接收的类型。

Binding adapter 对其它类型的自定义是很有用的。举例，一个工作线程中自定义加载器可以被调用来加载图片。

如果与 Android Framework 冲突，你定义的 binding adapters 会覆盖它。

你的 adapters 也可以接收多个属性，如下：

```kotlin
@BindingAdapter("imageUrl", "error")
fun loadImage(view: ImageView, url: String, error: Drawable) {
    Picasso.get().load(url).error(error).into(view)
}
```

你可以如下在你的 layout 中使用 adapter。注意，`@drawable/venueError` 引用了你 app 中的 resource。使用 `@{}` 包围使它成为一个合法的 binding 表达式。

```xml
<ImageView app:imageUrl="@{venue.imageUrl}" app:error="@{@drawable/venueError}" />
```

> Data Binding Library 忽略了自定义命名空间以用于匹配。

如果，`imageUrl` 和 `error` 都被 [`ImageView`](https://developer.android.com/reference/android/widget/ImageView.html) 对象使用，并且 `imageUrl` 是一个 String，`error` 是一个 [`Drawable`](https://developer.android.com/reference/android/graphics/drawable/Drawable.html)，adapter 就会被调用。如果你希望它们任何属性被调用时就让 adapter 调用，你可以设置 [`requireAll`](https://developer.android.com/reference/android/databinding/BindingAdapter.html#requireAll()) 标志为 `false`，如下：

```kotlin
@BindingAdapter(value = ["imageUrl", "placeholder"], requireAll = false)
fun setImageUrl(imageView: ImageView, url: String, placeHolder: Drawable) {
    if (url == null) {
        imageView.setImageDrawable(placeholder);
    } else {
        MyImageLoader.loadInto(imageView, url, placeholder);
    }
}
```

> 当有冲突时，你的 binding adapters 覆盖默认的 data binding adapters。

Binding adapter 方法可以选择在处理器中返回旧值。一个方法声明旧值和新值时应该首先声明 *所有* 属性的旧值，然后再是新值，如下：

```kotlin
@BindingAdapter("android:paddingLeft")
fun setPaddingLeft(view: View, oldPadding: Int, newPadding: Int) {
    if (oldPadding != newPadding) {
        view.setPadding(padding,
                    view.getPaddingTop(),
                    view.getPaddingRight(),
                    view.getPaddingBottom())
    }
}
```

事件处理器只能与只有一个抽象方法的接口或抽象类一起使用，如下：

```kotlin
@BindingAdapter("android:onLayoutChange")
fun setOnLayoutChangeListener(
        view: View,
        oldValue: View.OnLayoutChangeListener?,
        newValue: View.OnLayoutChangeListener?
) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
        if (oldValue != null) {
            view.removeOnLayoutChangeListener(oldValue)
        }
        if (newValue != null) {
            view.addOnLayoutChangeListener(newValue)
        }
    }
}
```

如下在你的 layout 中使用事件处理器：

```xml
<View android:onLayoutChange="@{() -> handler.layoutChanged()}"/>
```

当一个监听器有多个方法，必须要把它分割成多个监听器。比如，[`View.OnAttachStateChangeListener`](https://developer.android.com/reference/android/view/View.OnAttachStateChangeListener.html) 有两个方法：[`onViewAttachedToWindow(View)`](https://developer.android.com/reference/android/view/View.OnAttachStateChangeListener.html#onViewAttachedToWindow(android.view.View)) 和 [`onViewDetachedFromWindow(View)`](https://developer.android.com/reference/android/view/View.OnAttachStateChangeListener.html#onViewDetachedFromWindow(android.view.View))。对此，库提供了两个接口来区分属性和处理器：

```kotlin
// Translation from provided interfaces in Java:
@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
interface OnViewDetachedFromWindow {
    fun onViewDetachedFromWindow(v: View)
}

@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
interface OnViewAttachedToWindow {
    fun onViewAttachedToWindow(v: View)
}
```

因为改变其中一个监听器也会影响另一个，所以你需要一个任意或者全部属性的 adapter。你可以在注解中设置 [`requireAll`](https://developer.android.com/reference/android/databinding/BindingAdapter.html#requireAll()) 为 `false` 来指定不是所有属性都必须设置一个绑定表达式，如下：

```kotlin
@BindingAdapter(
        "android:onViewDetachedFromWindow",
        "android:onViewAttachedToWindow",
        requireAll = false
)
fun setListener(view: View, detach: OnViewDetachedFromWindow?, attach: OnViewAttachedToWindow?) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1) {
        val newListener: View.OnAttachStateChangeListener?
        newListener = if (detach == null && attach == null) {
            null
        } else {
            object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(v: View) {
                    attach?.onViewAttachedToWindow(v)
                }

                override fun onViewDetachedFromWindow(v: View) {
                    detach?.onViewDetachedFromWindow(v)
                }
            }
        }

        val oldListener: View.OnAttachStateChangeListener? =
                ListenerUtil.trackListener(view, newListener, R.id.onAttachStateChangeListener)
        if (oldListener != null) {
            view.removeOnAttachStateChangeListener(oldListener)
        }
        if (newListener != null) {
            view.addOnAttachStateChangeListener(newListener)
        }
    }
}
```

上面的例子比一般的稍微复杂一点，因为 [`View`](https://developer.android.com/reference/android/view/View.html) 类使用 [`addOnAttachStateChangeListener()`](https://developer.android.com/reference/android/view/View.html#addOnAttachStateChangeListener(android.view.View.OnAttachStateChangeListener)) 和 [`removeOnAttachStateChangeListener()`](https://developer.android.com/reference/android/view/View.html#removeOnAttachStateChangeListener(android.view.View.OnAttachStateChangeListener)) 方法而不是 [`OnAttachStateChangeListener`](https://developer.android.com/reference/android/view/View.OnAttachStateChangeListener.html) 的 setter 方法。`android.databinding.adapters.ListenerUtil` 类帮助保持跟踪之前的监听器，以便于它们在 binding adapter 中便于移除。

通过在接口 `OnViewDetachedFromWindow` 和 `OnViewAttachedToWindow` 添加 `@TargetApi(VERSION_CODES.HONEYCOMB_MR1)` 注解，data binding 代码生成器知道 监听器应该只会在 Android 3.1（API level 12）及以上才会生成，支持的版本与 [`addOnAttachStateChangeListener()`](https://developer.android.com/reference/android/view/View.html#addOnAttachStateChangeListener(android.view.View.OnAttachStateChangeListener)) 方法相同。

## 对象转化

### 自动对象转化

当一个 [`Object`](https://developer.android.com/reference/java/lang/Object.html) 从绑定表达式中返回时，库选择方法来设置属性的值。`Object` 被转换为所选方法的参数类型。使用 [`ObservableMap`](https://developer.android.com/reference/android/databinding/ObservableMap.html) 类来存储数据这个行为在 app 中是很方便的，如下：

```kotlin
<TextView
   android:text='@{userMap["lastName"]}'
   android:layout_width="wrap_content"
   android:layout_height="wrap_content" />
```

> 你也可以使用 **object.key** 的方式引用值。比如，上面例子中的 @{**userMap["lastName"]**} 可以被替换为 @{**userMap.lastName**}

表达式中的 `userMap` 对象返回一个值，它自动转型成 用户通过 `android:text` 属性设置值的 `setText(CharSequence)` 方法的参数类型。如果参数类型产生歧义的，你必须要在表达式中进行类型转换。

### 自定义转换

在一些情况下，在两个特殊的类型之间自定义转换是需要的。比如，View 的 `android:background` 属性期望是一个 [`Drawable`](https://developer.android.com/reference/android/graphics/drawable/Drawable.html)，但是指定的 `color` 值是一个 integer。下面的例子展示了属性期望是 `Drawable`，但是提供的却是 integer：

```kotlin
<View
   android:background="@{isError ? @color/red : @color/white}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"/>
```

每当期望一个 `Drawable` 并返回一个 integer 时，`int` 应该要被转换成一个 [`ColorDrawable`](https://developer.android.com/reference/android/graphics/drawable/ColorDrawable.html)。这个转换可以通过使用一个带有 [`BindingConversion`](https://developer.android.com/reference/android/databinding/BindingConversion.html) static 的方法做到：

```kotlin
@BindingConversion
fun convertColorToDrawable(color: Int) = ColorDrawable(color)
```

但是，绑定表达式中提供的值类型必须是一致的。不能在同一表达式中使用不同的类型，如下示例所示：

```kotlin
<View
   android:background="@{isError ? @drawable/error : @color/white}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"/>
```