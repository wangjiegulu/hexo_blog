---
title: Android Architecture Component LiveData（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1528413538163-0e0d91129480?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=5ac8c3c838e83e06f88f8333c23a3f10&auto=format&fit=crop&w=1934&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 20:01:00
---

# Android Architecture Component LiveData（翻译）

> 原文：<https://developer.android.com/topic/libraries/architecture/livedata>

[`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 是一个可观察数据的持有类。不像常规的 observable，LiveData 是生命周期感知的，这意味着它关心其它 app 组件的生命周期，比如 activities，fragments，或者 services。这种感知可确保 LiveData 仅更新处于活动生命周期状态的 app 组件 observers。

> 要导入 LiveData 到你的 Android 项目中，见[增加 Components 到你的项目中](https://developer.android.com/topic/libraries/architecture/adding-components.html#lifecycle)

LiveData 认为，如果观察者的生命周期处于 [STARTED](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#STARTED) 或 [RESUME](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#RESUMED) 状态，则该观察者 (以 [Observer](https://developer.android.com/reference/android/arch/lifecycle/Observer.html) 类呈现) 处于活动状态。LiveData 只通知活动状态的 observers 进行更新。注册到 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 的非活动状态的 observers 不会接收到改变通知。

你可以注册配对一个 observer 和实现了 [`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 接口的对象。这种关系允许在相应 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 对象进入到 [`DESTROYED`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#DESTROYED) 的时候删除相应的 observer。这对 activities 和 fragments 特别有帮助，因为它们可以安全地观察 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象，并且不需要去担心泄漏 —— activites 和 framgents 在销毁时，它们会立即被取消订阅。

关于如何使用 LiveData 的更多详情，见 [使用 LiveData 对象](https://developer.android.com/topic/libraries/architecture/livedata#work_livedata)。

## 使用 LiveData 的优势

使用 LiveData 提供了以下优势：

- 确保您的 UI 与您的数据状态相匹配

 LiveData 遵循观察者模式。当生命周期状态改变时，LiveData 通知 [`Observer`](https://developer.android.com/reference/android/arch/lifecycle/Observer.html) 对象。你可以巩固你的代码在这些 observer 对象中更新 UI。Observer 在每次有变化是更新 UI，而不只是在每次 app 数据变化时更新 UI。

- 没有内存泄漏

 Observer 绑定到 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 对象，并在其关联的生命周期销毁后进行清理。

- 没有因为 activities 停止导致的崩溃

 如果 Observer 的生命周期处于非活动状态，例如在后台堆栈中的活动的情况下，则它不会接收任何 LiveData 事件。

- 无需手动的生命周期处理
 
 UI 组件只是观察相关数据，不会停止或恢复观察。LiveData 会自动管理所有这些，因为它在观察时了解相关的生命周期状态更改。

- 始终是最新的数据
 
 如果生命周期变为非活动状态，它将在再次处于活动状态时接收最新数据。例如，后台的活动在返回到前台后立即接收最新数据。

- 正确的配置更改
 
 如果由于配置更改，比如设备旋转，而重新创建 activity 或 fragment，它将立即接收最新的可用数据。

- 共享资源

 您可以使用单例模式扩展 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象来包装系统服务，以便在 app 中共享这些服务。`LiveData` 对象连接到系统服务一次，然后任何需要资源的观察者都可以只监听 `LiveData` 对象。有关详情，请参阅 [扩展 LiveData](https://developer.android.com/topic/libraries/architecture/livedata#extend_livedata)。

## 使用 LiveData 对象

跟随以下几步来使用 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象：

1. 创建一个 `LiveData` 的实例来持有某个类型的数据。这通常是在你的 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 类中做的。
2. 创建一个定义了 [`onChanged()`](https://developer.android.com/reference/android/arch/lifecycle/Observer.html#onChanged(T)) 方法的 [`Observer`](https://developer.android.com/reference/android/arch/lifecycle/Observer.html) 对象，它会在 `LiveData` 对象持有的数据发生改变时进行控制处理。你通常要在 UI controller 中创建 `Observer` 对象，比如在 activity 或者 fragment。
3. 使用 [`observe()`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html#observe(android.arch.lifecycle.LifecycleOwner,%0Aandroid.arch.lifecycle.Observer%3CT%3E)) 方法来把 `Observer` 对象 attach 到 `LiveData` 对象上。`observe()` 方法接收一个 [`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 对象。这将 `Observer` 对象订阅到 `LiveData` 对象上，以便它收到改变的通知。你通常会 attach `Observer` 到 UI Controller 上，比如 activity 或者 fragment。

> 你可以使用 [observeForever(Observer)](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html#observeForever(android.arch.lifecycle.Observer%3CT%3E)) 方法以不关联一个 [LifecycleOwner](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 对象的方式来注册一个 observer。在这种情况下，observer 被认为始终处于活动状态，因此始终会收到有关改变的通知。你可以使用 [removeObserver(Observer)](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html#removeObserver(android.arch.lifecycle.Observer%3CT%3E)) 方法来移除这些 observer 的调用。

当你更新存储在 `LiveData` 对象的值的时候，它会触发所有注册的 observers 只要关联的 `LifecycleOwner` 的状态是 active 的。

LiveData 允许 UI Controller 的 observer 去订阅更新。当持有数据的 `LiveData` 对象更新时，UI 会在响应中自动更新。

### 创建 LiveData 对象

LiveData 是一个可用于任何数据的一个包装，包括实现了 [`Collections`](https://developer.android.com/reference/java/util/Collections.html) 的对象，比如 [`List`](https://developer.android.com/reference/java/util/List.html)。一个 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象通常存储在 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象中，并且通过 getter 方法访问，就像下面演示的那样：

```kotlin
class NameViewModel : ViewModel() {

    // Create a LiveData with a String
    val currentName: MutableLiveData<String> by lazy {
        MutableLiveData<String>()
    }

    // Rest of the ViewModel...
}
```

最初，`LiveData` 对象中的数据没有被设置。

> 注意：确保存储的更新 UI 的 **LiveData** 对象是在 **ViewModel** 对象中，而不是 activity 或者 fragment，原因如下：
> - 避免臃肿的 activities 和 fragments。现在这些 UI Controllers 是负责展示数据，而不持有数据的状态。
> - 要从特定的 activity 或者 fragment 实例中解耦 **LiveData** 实例，并且允许 **LiveData** 对象在配置更改后继续生存。

你可以在 [ViewModel 指南](https://developer.android.com/topic/libraries/architecture/viewmodel.html) 中了解更多关于 `ViewModel` 类型使用的好处。

### 观察 LiveData 对象

在大多情况下，一个 app 组件的 [`onCreate()`](https://developer.android.com/reference/android/app/Activity.html#onCreate(android.os.Bundle)) 方法是开始观察 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象比较正确的地方，愿意如下：

- 可以确保系统不会在 activity 或者 fragment 的 [onResume()](https://developer.android.com/reference/android/app/Activity.html#onResume()) 有过多的调用。
- 可以确保 activity 或者 fragment 状态变为 active 时有数据可以尽快显示出来。一旦一个 app 组件处于 [STARTED](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#STARTED)，它会从它观察中的 `LiveData` 对象接收到最近的数据。这只会在观察了 `LiveData` 时才会发生这种情况。

通常情况下，LiveData 仅在数据更改时提供更新，并且仅向 active 状态的 observer 提供更新。这个行为的一个例外是，observer 在从 inactive 状态更改为 active 状态时也会收到更新。此外，observer 第二次从 inactive 到 active 状态，只有自从上次变成 active 为止数据改变了，它才会接收到更新。

下面的例子说明了如何开始观察一个 `LiveData` 对象：

```kotlin
class NameActivity : AppCompatActivity() {

    private lateinit var mModel: NameViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Other code to setup the activity...

        // Get the ViewModel.
        mModel = ViewModelProviders.of(this).get(NameViewModel::class.java)


        // Create the observer which updates the UI.
        val nameObserver = Observer<String> { newName ->
            // Update the UI, in this case, a TextView.
            mNameTextView.text = newName
        }

        // Observe the LiveData, passing in this activity as the LifecycleOwner and the observer.
        mModel.currentName.observe(this, nameObserver)
    }
}
```

`nameObserver` 作为参数传入的 [`observe()`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html#observe(android.arch.lifecycle.LifecycleOwner,%0Aandroid.arch.lifecycle.Observer%3CT%3E)) 被调用之后，[`onChanged()`](https://developer.android.com/reference/android/arch/lifecycle/Observer.html#onChanged(T)) 立刻就会被调用并提供存储在 `mCurrentName` 中最近的值。如果 `LiveData` 对象 `mCurrentName` 中没有被设置值，则 `onChanged()` 不会被调用。

### 更新 LiveData 对象

LiveData 没有公开可用的方法用来存储更新存储的数据。[`MutableLiveData`](https://developer.android.com/reference/android/arch/lifecycle/MutableLiveData.html) 类暴露公开了 [`setValue(T)`](https://developer.android.com/reference/android/arch/lifecycle/MutableLiveData.html#setValue(T)) 和 [`postValue(T)`](https://developer.android.com/reference/android/arch/lifecycle/MutableLiveData.html#postValue(T)) 方法，如果你需要编辑存储在 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象中的值，你必须要使用它们。通常，`MutableLiveData` 被在 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 中被使用，`ViewModel` 只暴露不可编辑的 `LiveData` 对象给 observers。

当你设置了 observer 关系之后，你可以更新 `LiveData` 对象中的值，就如下面例子展示的，当用户按下按钮时触发所有 observers：

```kotlin
mButton.setOnClickListener {
    val anotherName = "John Doe"
    mModel.currentName.setValue(anotherName)
}
```

在例子中调用 `setValue(T)`，observers 调用它们的 [`onChanged()`](https://developer.android.com/reference/android/arch/lifecycle/Observer.html#onChanged(T)) 方法，值为 `John Doe`。例子展示了一个按钮被按下，但由于各种原因，可以调用 `setValue()` 或 `postValue()` 来更新 `mName`，包括在网络请求的 response 中，或者数据库加载完成；在所有情况中，调用 `setValue()` 和 `postValue()` 会触发 observers 并更新 UI。

> 注意：你必须在主线程调用 [setValue(T)](https://developer.android.com/reference/android/arch/lifecycle/MutableLiveData.html#setValue(T)) 更新 **LiveData** 对象。如果代码执行在一个工作线程，你可以使用 [postValue(T)](https://developer.android.com/reference/android/arch/lifecycle/MutableLiveData.html#postValue(T)) 方法来更新 **LiveData** 对象。

### 结合 Room 使用 LiveData

持久化库 [Room](https://developer.android.com/training/data-storage/room/index.html) 支持 observable 查询，它返回 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象。Observable 查询被作为数据访问对象（DAO）的一部分被编写。

Room 生成所有必要的代码来在数据库更新时更新 `LiveData` 对象。如果需要，被生成的代码在后台线程运行异步查询。这个模式可用于使 UI 中显示的数据与存储在数据库中的数据保持同步。你可以在 [Room 持久化库指南](https://developer.android.com/topic/libraries/architecture/room.html) 了解更多关于 Room 和 DAOs。

### 扩展 LiveData

如果 observer 的生命周期是 [`STARTED`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#STARTED) 或者 [`RESUMED`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.State.html#RESUMED) 状态，LiveData 则认为 observer 处于 active 状态，下面的代码展示了如何扩展继承 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 类：

```kotlin
class StockLiveData(symbol: String) : LiveData<BigDecimal>() {
    private val mStockManager = StockManager(symbol)

    private val mListener = { price: BigDecimal ->
        value = price
    }

    override fun onActive() {
        mStockManager.requestPriceUpdates(mListener)
    }

    override fun onInactive() {
        mStockManager.removeUpdates(mListener)
    }
}
```

在上述例子的 price listener 的实现中包含了以下几个重要的方法：

- [`onActive()`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html#onActive()) 方法在 `LiveData` 对象有一个 active observer 的时候被调用。这意味着你需要在这个方法中开始观察 stock price 的更新。
- [`onInactive()`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html#onInactive()) 方法在 `LiveData` 对象没有任何一个 active observer 的时候被调用。因为没有 observers 正在监听，所以没有理由与 `StockManager` 服务保持连接。
- [`setValue(T)`](https://developer.android.com/reference/android/arch/lifecycle/MutableLiveData.html#setValue(T)) 方法更新 `LiveData` 实例的值，并且通知任何 active 状态的 observers 关于这次改变。

你可以如下使用 `StockLiveData` 类：

```kotlin
override fun onActivityCreated(savedInstanceState: Bundle?) {
    super.onActivityCreated(savedInstanceState)
    val myPriceListener: LiveData<BigDecimal> = ...
    myPriceListener.observe(this, Observer<BigDecimal> { price: BigDecimal? ->
        // Update the UI.
    })
}
```

[`observe()`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html#observe(android.arch.lifecycle.LifecycleOwner,%0Aandroid.arch.lifecycle.Observer%3CT%3E)) 方法传入 fragment 作为第一个参数，它是 [`LifecycleOwner`](https://developer.android.com/reference/android/arch/lifecycle/LifecycleOwner.html) 的一个实例。这样做表示此 observer 绑定到与所有者关联的 [`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/Lifecycle.html) 对象，意味着：

- 如果 `Lifecycle` 对象不处于 active 状态了，那么就算值改变了 observer 也不会回调。
- 在 `Lifecycle` 对象被销毁了，observer 会自动被移除。

`LiveData` 对象是生命周期感知的事实，这意味着你可以在多个 activity，fragment，service 之间共享它们。为了保持例子简单，你可以把 `LiveData` 类作为一个单例实现，如下：

```kotlin
class StockLiveData(symbol: String) : LiveData<BigDecimal>() {
    private val mStockManager: StockManager = StockManager(symbol)

    private val mListener = { price: BigDecimal ->
        value = price
    }

    override fun onActive() {
        mStockManager.requestPriceUpdates(mListener)
    }

    override fun onInactive() {
        mStockManager.removeUpdates(mListener)
    }

    companion object {
        private lateinit var sInstance: StockLiveData

        @MainThread
        fun get(symbol: String): StockLiveData {
            sInstance = if (::sInstance.isInitialized) sInstance else StockLiveData(symbol)
            return sInstance
        }
    }
}
```

然后，你可以在 fragment 中使用它，如下：

```kotlin
class MyFragment : Fragment() {

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        StockLiveData.get(symbol).observe(this, Observer<BigDecimal> { price: BigDecimal? ->
            // Update the UI.
        })

    }
```

多个 fragments 和 activities 可以观察这个 `MyPriceListener` 实例。LiveData 只会在它们中的一个或多个是可见和 active 的才会连接到系统服务。

## 转换 LiveData

储存在 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 的数据在派发给 observers 之前，你可能需要做一些改变，或者你可能需要基于另一个值返回一个不同的 `LiveData` 实例。[`Lifecycle`](https://developer.android.com/reference/android/arch/lifecycle/package-summary.html) 包提供了 [`Transformations`](https://developer.android.com/reference/android/arch/lifecycle/Transformations.html) 类，它包含了一些帮助的方法来支持这些场景。

[`Transformations.map()`](https://developer.android.com/reference/android/arch/lifecycle/Transformations.html#map(android.arch.lifecycle.LiveData%3CX%3E,%20android.arch.core.util.Function%3CX,%20Y%3E))

对存储在 `LiveData` 对象中的值执行函数，并将结果发送到下游。

```kotlin
val userLiveData: LiveData<User> = UserLiveData()
val userName: LiveData<String> = Transformations.map(userLiveData) {
    user -> "${user.name} ${user.lastName}"
}
```

[`Transformations.switchMap()`](https://developer.android.com/reference/android/arch/lifecycle/Transformations.html#switchMap(android.arch.lifecycle.LiveData%3CX%3E,%20android.arch.core.util.Function%3CX,%20android.arch.lifecycle.LiveData%3CY%3E%3E))

类似于 `map()`，对存储在 `LiveData` 对象中的值执行函数，并在下游展开和调度结果。传入 `switchMap()` 的函数必须返回一个 `LiveData` 对象，如下面例子所示：

```kotlin
private fun getUser(id: String): LiveData<User> {
  ...
}
val userId: LiveData<String> = ...
val user = Transformations.switchMap(userId) { id -> getUser(id) }
```

你可以使用转换方法在 observer 的整个生命周期中传输信息。transformations 不会被计算，除非一个 observer 正在监听返回的 `LiveData` 对象。因为 transformations 是懒计算的，与生命周期相关的行为被隐式传递，而不需要额外的显式调用或依赖。

如果你觉得你在 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 对象中需要一个 `Lifecycle` 对象，transformation 是一个更好的解决方案。举个例子，假设你有一个 UI 组件，它接收一个 address 并返回一个 该 address 的 postal code。你可以针对该组件实现单纯的 `ViewModel`，如下代码所示：

```kotlin
class MyViewModel(private val repository: PostalCodeRepository) : ViewModel() {

    private fun getPostalCode(address: String): LiveData<String> {
        // DON'T DO THIS
        return repository.getPostCode(address)
    }
}
```

那么当每次调用 `getPostalCode()`时，UI 组件需要从上一个 `LiveData` 对象反注册，并注册到新的实例。另外，如果 UI component 被重建，它会触发另一个 `repository.getPostCode()` 调用而不是使用之前调用的结果。

对此你实现 postal code 查找作为 address 输入的转换，如下所示：

```kotlin
class MyViewModel(private val repository: PostalCodeRepository) : ViewModel() {
    private val addressInput = MutableLiveData<String>()
    private val postalCode: LiveData<String> =
            Transformations.switchMap(addressInput) { address -> repository.getPostCode(address) }


    private fun setInput(address: String) {
        addressInput.value = address
    }
}
```

在这个例子中，`postalCode` field 是 `public` 和 `final` 的，因为这个 field 永远不会改变。`postalCode` 这个 field 被定义为 `addressInput` 的一个转换，这意味着 `repository.getPostCode()` 在 `addressInput` 改变时被调用。在 `repository.getPostCode()` 被调用的时候，如果有一个 active 的 observer 则是真的，如果没有 active 的 observer，在添加 observer 之前，不进行任何计算。

这个机制允许低级别的 app 去创建按需懒计算的 `LiveData` 对象。一个 `ViewModel` 对象可以轻松地获取 `LiveData` 对象的引用，然后在其基础上定义转换规则。

### 创建新的转换

在你的应用中可能有十几个不同且有用的特定转换，但默认情况下是不提供的。要实现你自己的 transformation 你可以使用 [`MediatorLiveData`](https://developer.android.com/reference/android/arch/lifecycle/MediatorLiveData.html) 类，它监听其它 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 对象并处理它们发出的事件。`MediatorLiveData` 正确地将其状态传送到源 `LiveData` 对象。学习关于这个模式的详情，查看 [`Transformations`](https://developer.android.com/reference/android/arch/lifecycle/Transformations.html) 类的参考文档。

## 合并多个 LiveData 源

[`MediatorLiveData`](https://developer.android.com/reference/android/arch/lifecycle/MediatorLiveData.html) 是 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 的一个子类，它允许你去合并多个 LiveData 源。 每当任何原始 LiveData 源对象更改时，`MediatorLiveData` 对象的 observers 会被触发。

举个例子，如果你在你的 UI 有一个 `LiveData` 对象，它可以从本地数据库和网络中更新，然后你可以增加下面几个源到 `MediatorLiveData` 对象：

- 一个 `LiveData` 对象，与存储在数据库中的数据相关联。
- 一个 `LiveData` 对象，于访问网络的数据相关联。

你的 activity 只需要去观察 `MediatorLiveData` 对象来从上面两种源中接收更新。有详细示例，见 [App Architecture 指南]() 的 [附录: 公开网络状态](https://developer.android.com/topic/libraries/architecture/guide.html#addendum) 栏。

## 额外资源

`LiveData` 被使用在了 [Sunflower](https://github.com/googlesamples/android-sunflower) 的 demo app 中。

也可以查看 Architecture Components [BasicSample](https://github.com/googlesamples/android-architecture-components/tree/master/BasicSample)。

了解更多详情关于与 [Snackbar](https://developer.android.com/training/snackbar) Message，navigation events，和 other events 一起使用 `LiveData`，查看[本文](https://medium.com/google-developers/livedata-with-snackbar-navigation-and-other-events-the-singleliveevent-case-ac2622673150)。







