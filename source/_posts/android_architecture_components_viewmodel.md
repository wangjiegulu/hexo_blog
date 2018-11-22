---
title: Android Architecture Component ViewModel（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1476984251899-8d7fdfc5c92c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=046161063394b907536a34f38cbff537&auto=format&fit=crop&w=2689&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 21:01:00
---

# Android Architecture Component ViewModel（翻译）

> 原文：<https://developer.android.com/topic/libraries/architecture/viewmodel>

[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 被设计为以生命周期意识的方式存储和管理 UI 相关的数据的类。[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 类允许数据在屏幕旋转之后保存下来。

> **注意**：要导入 [ViewModel](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 到你的 Android 项目中，请查阅 [添加 components 到你的项目中](https://developer.android.com/topic/libraries/architecture/adding-components.html#lifecycle)。

Android Framework 会管理 UI Controllers 的生命周期，比如 activities 和 fragment。Framework 可能会决定去销毁或重建一个 UI Controller 来响应某些完全超出你控制范围的用户操作或设备事件。

如果系统销毁或者重建一个 UI Controller，你存储在其中的任何瞬态 UI 相关数据都将丢失。举个例子，你的应用可能会在其中一个 activity 中包含用户列表。当 activity 因为配置改变而重建时，新的 activity 会去重新拉取用户列表数据。对于简单的数据，activity 可以使用 [`onSaveInstanceState()`](https://developer.android.com/reference/android/app/Activity.html#onSaveInstanceState(android.os.Bundle)) 方法并在 [`onCreate`](https://developer.android.com/reference/android/app/Activity.html#onCreate(android.os.Bundle)) 方法中从 bundle 中还原数据，但是这个方法只适用于可以序列化和反序列化的少量的数据，而不是潜在的大量数据，如用户列表或 bitmaps。

另一个问题，UI Controllers 频繁地去进行异步调用，它可能会需要一段时间之后才返回。UI Controller 需要管理这些调用并确保系统会在销毁之后为避免潜在的内存泄漏而把它们清理掉。这种管理需要大量的维护，并且在为配置更改重建对象的情况下，这是对资源的浪费，因为对象可能不得不重新执行它已经执行过的调用。

UI Controllers，比如 activities 和 fragments 主要负责 UI 数据的显示，对用户行为作出反应，或者处理与操作系统的通信，比如权限请求。要求 UI Controllers 也负责从数据库或网络加载数据会让类变得臃肿。将过多的责任分配给 UI Controller 可能会导致单个类尝试单独处理 app 的所有工作，而不是将工作委派给其他类。以这种方式为 UI Controller 分配过多的责任也会使测试变得更加困难。

将 view 数据所有权从 UI Controller 逻辑剥离时更容易，更高效的。

## 实现一个 ViewModel

对于 UI Controller，Architecture Components 提供了一个 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 帮助类，让它负责为 UI 准备数据。在配置发生变化时，[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象会自动保留，所以它们持有的数据会立刻对于下一个 activity 或者 fragment 实例变得可用。举例，如果你需要在你的 app 中显示一个用户列表，确保你给 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 分配获取和持有用户列表数据的职责，而不是给 activity 或者 fragment，如下代码所示：

```kotlin
class MyViewModel : ViewModel() {
    private lateinit var users: MutableLiveData<List<User>>

    fun getUsers(): LiveData<List<User>> {
        if (!::users.isInitialized) {
            users = MutableLiveData()
            loadUsers()
        }
        return users
    }

    private fun loadUsers() {
        // Do an asynchronous operation to fetch users.
    }
}
```

你可以从 activity 中如下方式进行访问：

```kotlin
class MyActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Create a ViewModel the first time the system calls an activity's onCreate() method.
        // Re-created activities receive the same MyViewModel instance created by the first activity.

        val model = ViewModelProviders.of(this).get(MyViewModel::class.java)
        model.getUsers().observe(this, Observer<List<User>>{ users ->
            // update UI
        })
    }
}
```

如果 activity 被重建，它会收到同一个 `MyViewModel` 实例，也就是第一个 activity 创建的那个。当所有拥有者 activity 结束完成，framework 会调用 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象的 [`onCleared()`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html#onCleared()) 方法，以便于它可以清理资源。

> 警告：[ViewModel](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 一定不能引用 view，[Lifecycle](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html)，或者任何可能会持有 activity context 的引用的类。

[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象被设计为比生命周期比 views，[`LifecycleOwners`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 长。这个设计也意味着你可以更容易写覆盖 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 的测试，因为你不需要知道 view 和 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 对象。[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象可以包含 [`LifecycleObservers`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleObserver.html)，比如 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象。但是 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象一定不能观察生命周期感知的 observables 的改变，比如 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象。如果 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html)需要 [`Application`](https://developer.android.com/reference/android/app/Application.html)，比如需要获取系统服务，它可以继承 [`AndroidViewModel`](https://developer.android.com/reference/android/arch/lifecycle/AndroidViewModel.html) 类，它有一个接收 [`Application`](https://developer.android.com/reference/android/app/Application.html) 的构造方法，因为 [`Application`](https://developer.android.com/reference/android/app/Application.html) 类继承 [`Context`](https://developer.android.com/reference/android/content/Context.html)。

## ViewModel 的生命周期

当获取 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 时，[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象的作用域是被传入 [`ViewModelProvider`](https://developer.android.com/reference/android/arch/lifecycle/ViewModelProvider.html)的 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html)。[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 会留在内存中，直到 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 的范围是永久消失为止：对于 activity，当它 finish 的情况下，对于 fragment，当它 detached 的情况下。

示图 1 展示了一个 activity 各种生命周期状态，当它经历了一个旋转，再 finish。插图也展示了 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 的整个周期，在关联的 activity 生命周期的旁边。此特定关系图说明了 activity 的状态。同样的基本状态也适用于 fragment 的生命周期。

<div style='text-align: center;'>
<img src='https://user-images.githubusercontent.com/5423194/48878990-e6132000-ee44-11e8-986b-269898892b39.png' width= 550px/>
</div>

你通常要请求一个 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 在第一次调用 activity 对象的 [`onCreate`](https://developer.android.com/reference/android/app/Activity.html#onCreate(android.os.Bundle)) 方法。在 activity 的生命周期中，系统可能会调用多次 [`onCreate`](https://developer.android.com/reference/android/app/Activity.html#onCreate(android.os.Bundle))，比如当设备屏幕旋转。[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 会从当你第一次请求 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 一直存在，直到 activity finished 并 destroyed。

## 在 fragments 之间共享数据

在一个 activity 中多个 fragments 需要互相通信是很常见的。想象一个常见的 master-detail fragments 的情况，其中用户在一个 fragment 的列表中选择一个 item，另一个 fragment 显示所选 item 的内容。这种情况从来都不是不重要的，因为这两个 fragment 都需要定义一些接口描述，并且 owner activity 必须将两者绑定在一起。另外，两个 fragment 都必须处理另一个 fragment 是否已被创建或者可见的场景。

这个常见的痛点可以通过 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象来解决。这些 fragment 可以共享一个 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html)，使用它们的 activity scope 来处理这个通信，如下示例：

```kotlin
class SharedViewModel : ViewModel() {
    val selected = MutableLiveData<Item>()

    fun select(item: Item) {
        selected.value = item
    }
}

class MasterFragment : Fragment() {

    private lateinit var itemSelector: Selector

    private lateinit var model: SharedViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        model = activity?.run {
            ViewModelProviders.of(this).get(SharedViewModel::class.java)
        } ?: throw Exception("Invalid Activity")
        itemSelector.setOnClickListener { item ->
            // Update the UI
        }
    }
}

class DetailFragment : Fragment() {

    private lateinit var model: SharedViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        model = activity?.run {
            ViewModelProviders.of(this).get(SharedViewModel::class.java)
        } ?: throw Exception("Invalid Activity")
        model.selected.observe(this, Observer<Item> { item ->
            // Update the UI
        })
    }
}
```

要注意的是两个 fragment 在获取 [ViewModelProvider](https://developer.android.com/reference/android/arch/lifecycle/ViewModelProvider.html) 的时候都使用 [`getActivity()`](https://developer.android.com/reference/android/app/Fragment.html#getActivity())。结果，两个 fragment 都接受一个相同的 `SharedViewModel` 实力，它的范围是 activity。

这个方法有下面几个好处：

- Activity 不需要做任何事情，或者知道关于这个通信的任何事情
- Fragments 不需要知道互相之间除了 `SharedViewModel` 契约的其它任何事情。如果其中一个 fragments 消失了，另一个照常保持工作。
- 每一个 fragments 都有它自己的生命周期，并不受到另一个生命周期的影响。如果一个 fragment replace 另外一个，UI 会继续工作，不会有问题。

## 使用 ViewModel 替换 Loaders

Loader 类，比如 [`CursorLoader`](https://developer.android.com/reference/android/content/CursorLoader.html)，会频繁地使用来保持 app 中的 UI 数据与数据库保持同步。你可以通过几个其它类使用 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 来替换 loader。使用 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 从数据加载操作中隔离你的 UI controller，这意味着你在这些类中拥有更少的强引用。

在一个使用 loaders 的常用方法，app 可能使用 [`CursorLoader`](https://developer.android.com/reference/android/content/CursorLoader.html) 来观察数据库的内容。当数据库中的值发生改变，loader 会自动触发一个重新加在并更新 UI：

<div style='text-align: center;'>
<img src='https://user-images.githubusercontent.com/5423194/48879871-c41b9c80-ee48-11e8-8b26-c051ca94d272.png' width= 600px/>
</div>

[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 与 [Room](https://developer.android.com/topic/libraries/architecture/room.html) 和 [LiveData](https://developer.android.com/topic/libraries/architecture/livedata.html) 一起使用来替换 loader。[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 确保数据在设备配置改变时存活。[Room](https://developer.android.com/topic/libraries/architecture/room.html) 会在数据库发生改变时通知你的 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html)，然后 [LiveData](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 反过来使用最新的数据更新你的 UI。

<div style='text-align: center;'>
<img src='https://user-images.githubusercontent.com/5423194/48880164-1c06d300-ee4a-11e8-98b1-cc4dad768914.png' width= 600px/>
</div>

## 额外资源

[本文](https://medium.com/google-developers/lifecycle-aware-data-loading-with-android-architecture-components-f95484159de4) 描述了如何使用 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 和 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 来替换 [`AsyncTaskLoader`](https://developer.android.com/reference/android/content/AsyncTaskLoader.html)。

当你的数据变得越来越复杂，你可以选择用一个单独的类专门用来加载数据。[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 的目的是为 UI Controller 封装数据，使得当设置配置改变时让数据存活。更多关于跨配置改变去加载，持久化，管理数据的详情，见 [保存 UI 状态](https://developer.android.com/topic/libraries/architecture/saving-states.html)。

[Android App Architecture 指南](https://developer.android.com/topic/libraries/architecture/guide.html#fetching_data) 建议构建一个 repository 类来处理这些函数。

[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 被用在 Android 生命周期 [codelab](https://codelabs.developers.google.com/codelabs/android-lifecycles/#0) 和 [Sunflower](https://github.com/googlesamples/android-sunflower) demo app。也可以参阅 Architecture Components [BasicSample](https://github.com/googlesamples/android-architecture-components/tree/master/BasicSample)。



