---
title: '[Android]异步 layout inflation（翻译）'
tags: []
date: 2016-09-01 14:42:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5829809.html>
**</font>

# 异步 layout inflation

> 原文：<https://medium.com/@lupajz/asynchronous-layout-inflation-7cbca2653bf#.q22vpezg4>

随着最近发布的[Android Support Library, revision 24](https://developer.android.com/topic/libraries/support-library/revisions.html)，Google开发者在v4包中增加了一个用来异步inflate layouts的帮助类。

## 进入 AsyncLayoutInflater

你会发现AsyncLayoutInflater可以使用在当你想要去懒加载你应用中部分UI或者用户行为的响应。这个帮助类将会允许你的UI线程在执行繁重的inflate时继续保持响应。

使用AsyncLayoutInflater你需要在你应用的**UI线程**创建一个它的实例。

假设下面部分代码是你Activity代码中的一部分（我将在这里使用Kotlin语法）：

```kotlin
val inflater = AsyncLayoutInflater(this)
```

然后现在可以通过这个实例inflate你的layout文件：

```kotlin
inflater.inflate(resId: Int, parent: ViewGroup) 
```

如你所见，inflate函数接收3个参数。第一个是你layout资源，第二个是可选的view作为预期inflated层次结构的parent，然后第三个是一个`OnInflateFinishedListener`，是一个回调，一旦layout被inflate完毕它就会被回调（例子中被lambda函数代替）。

比较基本的LayoutInflater的inflate函数，一般使用一个boolean作为第三个参数，它表示是否inflate层次结构应该附属岛一个root参数上面。在我们的inflate函数的异步版本中并没有这样一个参数，大多数情况下你会使用这种方式调用：

```kotlin
inflater.inflate(resId: Int, parent: ViewGroup) 
    { view, resid, parent -> parent.addView(view) }
```
## 使用AsyncLayoutInflater的缺点

当然它有如下一些缺点：

- parent的 `generateLayoutParams()` 函数必须是线程安全的。

- 所有正在构建的views一定不能创建任何 `Handlers` 或者调用 `Looper.myLooper` 函数。

- 不支持设置`LayoutInflater.Factory`也不支持`LayoutInflater.Factory2`

- 不支持包含Fragments的inflating layouts

如果我们尝试异步的方式去inflate的layout不支持这种方式，那么inflation处理将会自动回退到主线程中。

## 使用Kotlin Android Extensions 的 Kotlin的小例子

MainActivity

```kotlin
class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        loadFirst.setOnClickListener { 
           loadAsync(R.layout.async) { 
             second.text = "I am second TextView" 
           } 
        }
    }
}

fun MainActivity.loadAsync(@LayoutRes res: Int, 
                           action: View.() -> Unit) =
    AsyncLayoutInflater(this).inflate(res, frame) 
    { view, resid, parent ->
        with(parent) {
            addView(view)
            action(view)
        }
    }
```

activity_main.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    android:id="@+id/frame"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="@dimen/activity_vertical_margin"
    android:orientation="vertical"
    tools:context="com.cartoon.player.MainActivity">

    <TextView
        android:id="@+id/loadFirst"
        android:layout_width="match_parent"
        android:layout_height="48dp"
        android:gravity="center"
        android:layout_marginBottom="16dp"
        android:text="Load f async"/>

</LinearLayout>
```

async.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="vertical"
    android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <TextView
        android:id="@+id/first"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="16dp"
        android:text="1"/>

    <TextView
        android:id="@+id/second"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="16dp"
        android:text="2"/>

</LinearLayout>
```