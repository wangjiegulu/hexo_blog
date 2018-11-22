---
title: Android Architecture Component Lifecycle（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles", "翻译"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1473662423067-e88544ee8418?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=4986af3f768f4bc19324126764342cc8&auto=format&fit=crop&w=2252&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 21:01:00
---

# Android Architecture Component Lifecycle（翻译）

> 原文：<https://developer.android.com/topic/libraries/architecture/lifecycle>

生命周期感知的组件执行行为以响应另一个组件的生命周期状态的变化，比如 activities 和 fragments。这些组件可以帮助你生产更好的组织结构，通常是更容易维护的轻量代码。

一种常见的模式是在 activity 和 fragment 的生命周期方法中实现依赖组件的行为。但是，这种模式会导致较差的代码组织，并导致错误激增。通过使用生命周期感知的组件，你可以将相关组件的代码从生命周期方法中移动到组件本身中去。

[`android.arch.lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/package-summary.html) 包提供了类和接口让你去构建 *生命周期感知* 组件 —— 它们是能基于当前 activity 或 fragment 生命周期状态来自动调整它们行为的组件。

> **注意**：要导入 [android.arch.lifecycle](https://developer.android.com/reference/android/arch/lifecycle/package-summary.html) 到你的 Android 项目，可参阅 [增加 components 到你的项目中](https://blog.wangjiegulu.com/2018/04/15/android_architecture_components_overview/#Lifecycle)。

在 Android Framework 中定义的大部分 app components 都附加了 lifecycle。Lifecycles 是被操作系统或者你进程中的运行的 framework 代码所管理。它们是 android 工作原理的核心，你的应用程序必须关心它们。如果不这么做，可能会触发内存泄漏或者甚至是应用崩溃。

想象我们有一个 activity，它在屏幕上显示设备的位置信息。一个常用的实现可能如下：

```kotlin
internal class MyLocationListener(
        private val context: Context,
        private val callback: (Location) -> Unit
) {

    fun start() {
        // connect to system location service
    }

    fun stop() {
        // disconnect from system location service
    }
}

class MyActivity : AppCompatActivity() {
    private lateinit var myLocationListener: MyLocationListener

    override fun onCreate(...) {
        myLocationListener = MyLocationListener(this) { location ->
            // update UI
        }
    }

    public override fun onStart() {
        super.onStart()
        myLocationListener.start()
        // manage other components that need to respond
        // to the activity lifecycle
    }

    public override fun onStop() {
        super.onStop()
        myLocationListener.stop()
        // manage other components that need to respond
        // to the activity lifecycle
    }
}
```

尽管这个例子看起来不错，在实际的 app 中，你最终会有太多的调用来管理 UI 和其它组件来响应生命周期的当前状态。管理多个组件会在生命周期方法中放置大量代码，比如 [`onStart()`](https://developer.android.com/reference/android/app/Activity.html#onStart()) 和 [`onStop()`](https://developer.android.com/reference/android/app/Activity.html#onStop())，它会导致难以维护的问题。

此外，还不能保证组件在 activity 或者 fragment 在停止之前启动。如果我们需要执行长时间运行的操作的时候尤其如此。比如在 [`onStart()`](https://developer.android.com/reference/android/app/Activity.html#onStart()) 中执行一些配置检查。[`onStop()`](https://developer.android.com/reference/android/app/Activity.html#onStop()) 方法在 [`onStart()`](https://developer.android.com/reference/android/app/Activity.html#onStart()) 之前完成这点可能会引起争用条件，使得组件的生存期超过所需的时间。

```kotlin
class MyActivity : AppCompatActivity() {
    private lateinit var myLocationListener: MyLocationListener

    override fun onCreate(...) {
        myLocationListener = MyLocationListener(this) { location ->
            // update UI
        }
    }

    public override fun onStart() {
        super.onStart()
        Util.checkUserStatus { result ->
            // what if this callback is invoked AFTER activity is stopped?
            if (result) {
                myLocationListener.start()
            }
        }
    }

    public override fun onStop() {
        super.onStop()
        myLocationListener.stop()
    }

}
```

[`android.arch.lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/package-summary.html) 包提供的类和接口可以帮助你使用弹性和独立的方式解决这些问题。

## Lifecycle

[`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 这个类持有了关于组件（比如 activity 和 fragment）生命周期状态的信息，并允许其它对象观察这个状态。

[`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 使用两种主要的枚举来追踪关联组件的生命周期状态：

- **Event**
 
 生命周期 event 从 framework 和 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 类中派发。这些事件在 activities 和 fragments 中映射到回调 events 中。
 
- **State**
 
 组件通过 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 对象追踪的当前状态。

<div style='text-align: center;'>
<img src='https://user-images.githubusercontent.com/5423194/48882877-e36df600-ee57-11e8-91df-117c02e796ee.png' width=600px/>
</div>

将 states 视为图形的节点，将 events 视为这些节点之间的边。

一个类可以通过在它方法上增加一些注解来模拟组件的生命周期状态。然后你可以通过调用 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 类的 [`addObserver()`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html#addObserver(android.arch.lifecycle.LifecycleObserver)) 方法并传入一个 observer 的实例来增加一个 observer，如下例子所示：

```kotlin
class MyObserver : LifecycleObserver {

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun connectListener() {
        ...
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    fun disconnectListener() {
        ...
    }
}
```

在上述的例子中，`myLifecycleOwner` 对象实现了 [`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 接口，它会在面再详细说明。

## LifecycleOwner

[`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 是一个单方法的接口，表示这个类有一个 [Lifecycle](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html)。它有一个方法，[`getLifecycle()`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html#getLifecycle())，它必须由类去实现。如果你尝试管理整个应用程序进程的 lifecycle，见 [`ProcessLifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/ProcessLifecycleOwner.html)。

这个接口抽象了单独的类，比如 [`Fragment`](https://developer.android.com/reference/android/support/v4/app/Fragment.html) 和 [`AppCompatActivity`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html) 的 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 所有权，允许编写组件来跟它们一起工作。任何自定义的应用类都可以实现 [`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 接口。

实现了 [`LifecycleObserver`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleObserver.html) 的组件可以无缝与 [`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 一起工作，因为一个 owner 可以提供一个 lifecycle，observer 可以注册观察它。

对于位置追踪的例子，我们可以让 `MyLocationListener` 类实现 [`LifecycleObserver`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleObserver.html) 并通过 Activity [`onCreate`](https://developer.android.com/reference/android/app/Activity.html#onCreate(android.os.Bundle)) 方法中的 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 初始化它。这允许 `MyLocationListener` 类自给自足，意味着对生命周期状态变化做出反应的逻辑的声明是在 `MyLocationListener` 中，而不是 activity。让各个组件存储自己的逻辑使 activity 和 fragment 逻辑更易于管理。

```kotlin
class MyActivity : AppCompatActivity() {
    private lateinit var myLocationListener: MyLocationListener

    override fun onCreate(...) {
        myLocationListener = MyLocationListener(this, lifecycle) { location ->
            // update UI
        }
        Util.checkUserStatus { result ->
            if (result) {
                myLocationListener.enable()
            }
        }
    }
}
```

一个常用的用例是，如果 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 当前不是一个好的状态，则避免调用某些回调。举例，如果回调在保存 activity 状态后运行 fragment 事务，它可能会触发一个崩溃，所以我们永远都不希望执行这个回调。

为了让用例简单，[`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 类允许其它对象去查询当前的状态。

```kotlin
internal class MyLocationListener(
        private val context: Context,
        private val lifecycle: Lifecycle,
        private val callback: (Location) -> Unit
) {

    private var enabled = false

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    fun start() {
        if (enabled) {
            // connect
        }
    }

    fun enable() {
        enabled = true
        if (lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)) {
            // connect if not connected
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    fun stop() {
        // disconnect if connected
    }
}
```

通过这个实现，我们的 `LocationListener` 类是完全生命周期感知的。如果我们需要从其它的 activity 和 fragment 去使用 `LocationListener`，我们只需要初始化它。所有 setup 和 teardown 的操作都是自己类本身管理的。

如果库提供的类需要与 Android 生命周期一起使用，我们推荐使用生命周期感知的组件。你的库 client 端可以轻松集成这些组件，而无需在 client 端进行手动生命周期管理。

### 实现一个自定义的 LifecycleOwner

在 Support Library 26.1.0 及以上版本，Fragments 和 Activities 已经使用 [`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 接口实现。

如果你要自定义一个 [`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 的类，你可以使用 [LifecycleRegistry](https://developer.android.com/reference/android/arch/lifecycle/LifecycleRegistry.html) 类，但是需要在这个 class 中转发 events，如下示例：

```kotlin
class MyActivity : AppCompatActivity(), LifecycleOwner {

    private lateinit var mLifecycleRegistry: LifecycleRegistry

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        mLifecycleRegistry = LifecycleRegistry(this)
        mLifecycleRegistry.markState(Lifecycle.State.CREATED)
    }

    public override fun onStart() {
        super.onStart()
        mLifecycleRegistry.markState(Lifecycle.State.STARTED)
    }

    override fun getLifecycle(): Lifecycle {
        return mLifecycleRegistry
    }
}
```

## 生命周期感知组件的最佳实践

- 保持你的 UI Controllers （activities 和 fragments）尽可能简洁。它们不应该去尝试获取它们自己的数据。而是应该使用 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 去做，然后观察一个 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象去响应对 view 的更改。
- 在你的 UI Controllers 中尝试编写数据驱动的 UI，它负责在数据改变时更新 views，或者通知用户的行为给 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html)。
- 把数据逻辑代码放在 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 类中。[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 应该作为 UI Controller 和 app 其余部分之间的连接器。不过要小心，[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 不负责去获取数据（比如，从网络）。[`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 应该调用适当的组件去获取数据，然后提供结果给 UI Controller。
- 使用 [Data Binding](https://developer.android.com/topic/libraries/data-binding/index.html) 在你的 views 和 UI Controller 之间去维护一个清晰的接口。这让你可以使你的 views 更具声明性，并最大限度地减少你需要在 activities 和 fragments 中编写的更新代码。如果还是希望使用 Java 语言来做这些，使用像 [Butter Knife](http://jakewharton.github.io/butterknife/) 的库来避免模版代码和做更好的抽象。
- 如果你的 UI 是复杂的，考虑创建一个 [presenter](http://www.gwtproject.org/articles/mvp-architecture.html#presenter) 类来处理 UI 改动。这可能是个费力的任务，但是它会让你的 UI 组件变得更容易测试。   
- 避免在你的 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 中引用 [`View`](https://developer.android.com/reference/android/view/View.html) 和 [`Activity`](https://developer.android.com/reference/android/app/Activity.html) context。如果 `ViewModel` 寿命比 activity 长（比如配置改变的情况），你的 activity 会泄漏并且 gc 不会正确处理它。

## 生命周期感知组件的用例

生命周期感知组件可以让你在各种情况下更轻松地管理生命周期。以下是几个例子：

- 在粗粒度和细粒度的位置更新之间切换。使用生命周期感知组件，在位置应用可见时启用细粒度位置更新，并在应用处于后台时切换到粗粒度更新。[`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html)，一个生命周期感知的组件，当你的用户改变位置时，允许你的 app 自动更新 UI。
- 停止和启动视频缓冲。使用生命周期感知组件来尽可能快地开始视频缓冲，但会推迟播放，直到应用程序完全启动。你还可以使用生命周期感知组件在应用被销毁时终止缓冲。
- 启动和停止网络连接。使用生命周期感知组件当 app 在前台时启用网络数据的实时更新（流），也在 app 进入到后台的时候自动暂停。
- 暂停和恢复动画绘图。使用生命周期感知组件当 app 在后台时暂停动画绘制，当 app 在前台时恢复绘制。

## 对停止事件的处理

当 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 属于一个 [`AppCompatActivity`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html) 或者 [`Fragment`](https://developer.android.com/reference/android/support/v4/app/Fragment.html)，当  [`AppCompatActivity`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html) 或者 [`Fragment`](https://developer.android.com/reference/android/support/v4/app/Fragment.html) 的 [`onSaveInstanceState()`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onSaveInstanceState(android.os.Bundle)) 被调用时，事件被派发，使得[`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 的状态变为 [`CREATED`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#CREATED) 和 [`ON_STOP`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.Event.html#ON_STOP)。

当 [`Fragment`](https://developer.android.com/reference/android/support/v4/app/Fragment.html) 或者 [`AppCompatActivity`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html) 的状态被保存在 [`onSaveInstanceState()`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onSaveInstanceState(android.os.Bundle))，它的 UI 被认为是不可变的，直到 [`ON_START`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.Event.html#ON_START) 被调用。在保存状态后尝试修改 UI 可能会导致应用程序的导航状态不一致，这就是为什么当应用在保存状态后运行 [`FragmentTransaction`](https://developer.android.com/reference/android/support/v4/app/FragmentTransaction.html) 时，[`FragmentManager`](https://developer.android.com/reference/android/support/v4/app/FragmentManager.html) 将引发异常的原因。详情见 [`commit()`](https://developer.android.com/reference/android/support/v4/app/FragmentTransaction.html#commit())。

[`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 防止这种边界情况发生，它通过当 observer 关联的 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 不是至少是 [`STARTED`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#STARTED)，则避免调用它的 observer。在幕后，它在决定调用 obserfver 之前调用了 [`isAtLeast()`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#isAtLeast(android.arch.lifecycle.Lifecycle.State))。

不幸的是，[`AppCompatActivity`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html) 的 [`onStop()`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onStop()) 方法是在 [`onSaveInstanceState()`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onSaveInstanceState(android.os.Bundle)) 之后，这就留下了一个空隙，即不允许 UI 状态改变，但生命周期还未到 [`CREATED`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#CREATED) 状态。

为了防止这个问题，[`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 类在版本 `beta2` 及以下标记状态为 [`CREATED`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#CREATED) 而不经过事件派发，所以检查当前状态的任何代码都会获得真正的值，即使在 [`onStop()`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onStop()) 被系统调用之前，该事件才被调度。

不幸的是，这个解决方案会有两个主要的问题：

- 在 API level 23 及以下，Android 系统实际上保存了一个 activity 的状态，即使它被另一个 activity *部分* 覆盖。换句话说，Android 系统调用 [`onSaveInstanceState()`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onSaveInstanceState(android.os.Bundle))，但是它不一定调用 [`onStop()`](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onStop())。这将创建一个可能较长的时间间隔，观察者仍然认为生命周期是 active 的，尽管它的 UI 状态无法修改。
- 任何想要向 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 类公开类似行为的类都必须实现生命周期 `beta2` 及以下版本提供的解决方法。

> **注意**：为了使此流程更简单，并提供与旧版本更好的兼容性，从版本 **1.0.0-rc1** 开始，[Lifecycle](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 对象在 [onSaveInstanceState()](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onSaveInstanceState(android.os.Bundle)) 被调用（没有等 [onStop](https://developer.android.com/reference/android/support/v7/app/AppCompatActivity.html#onStop()) 方法被调用），派发标记 [CREATED](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#CREATED) 和 [ON_STOP](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.Event.html#ON_STOP)。这不太可能影响你的代码，但这是你需要注意的，因为这与 API level 26 及以下的 [Activity](https://developer.android.com/reference/android/app/Activity.html) 类中调用顺序不一致。

## 额外资源

尝试生命周期组件 [codelab](https://codelabs.developers.google.com/codelabs/android-lifecycles/#0)，并查阅 Architecture Components [BasicSample](https://github.com/googlesamples/android-architecture-components/tree/master/BasicSample)。生命周期感知组件也在 [Sunflower](https://github.com/googlesamples/android-sunflower) demo app 中使用。


