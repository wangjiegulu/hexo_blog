---
title: Android Architecture Component DataBinding -- Architecture（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 17:01:00
---

# Android Architecture Component DataBinding -- Architecture（翻译）

> 原文：<https://developer.android.com/topic/libraries/data-binding/architecture>

AndroidX 库包含了 [Architecture Components](https://developer.android.com/topic/libraries/architecture/index.html)，你可以使用它来设计具有鲁棒性，可测试性，可维护性的 apps。Data Binding 库与 Architecture Components 无缝协作，以进一步简化了 UI 的开发。在 Architecture Components 中，你 app 的 layout 可以绑定到数据，它已经帮助你管理 UI 控制器的生命周期，并通知有关数据中的改动。

本文展示如何把 Architecture Components 继承进你的 app，来让你的 app 进一步增强使用 Data Binding 库的好处。

## 使用 LiveData 来通知 UI 数据的更改

你可以使用 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData) 对象作为 data binding 源在数据变化时候自动通知 UI。更多 Architecture Component 相关详情见 [LiveData 概要](https://developer.android.com/topic/libraries/architecture/livedata)。

不像实现 [`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) —— 比如 [ observable fields]() —— `LiveData` 对象知道观察者订阅数据变化的生命周期。这点可以引发很多好处，这已经在 [LiveData 的优势](https://developer.android.com/topic/libraries/architecture/livedata.html#the_advantages_of_using_livedata) 中解释了。在 Android Studio 3.1 及以上，你可以在你的 data binding 代码中用 `LiveData` 对象 替换 [observable fields](https://developer.android.com/topic/libraries/data-binding/observability.html#observable_fields)。

要在你的绑定类中使用 `LiveData` 对象，你需要指定一个 lifecycle owner 来定义 `LiveData` 对象的范围。下面的例子在绑定类初始化后，指定了这个 activity 作为 lifecycle owner：

```kotlin
class ViewModelActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Inflate view and obtain an instance of the binding class.
        val binding: UserBinding = DataBindingUtil.setContentView(this, R.layout.user)

        // Specify the current activity as the lifecycle owner.
        binding.setLifecycleOwner(this)
    }
}
```

你使用了一个 [ViewModel](https://developer.android.com/reference/android/arch/lifecycle/ViewModel) 组件，在 [使用 ViewModel 管理 UI 相关的数据](https://developer.android.com/topic/libraries/data-binding/architecture#viewmodel)中解释，来绑定数据到 layout。在 `ViewModel` 组件中，你可以使用 `LiveData` 来改变数据或合并多个数据源。下面的例子展示了如何改变 `ViewModel` 中的数据源：

```kotlin
class ScheduleViewModel : ViewModel() {
    val userName: LiveData

    init {
        val result = Repository.userName
        userName = Transformations.map(result) { result -> result.value }
    }
}
```

## 使用 ViewModel 管理 UI 相关的数据

Data Binding 库与 `ViewModel` 组件无缝协作，它暴露 layout observes 数据并对其更改做出反应。与 Data Binding 使用 `ViewModel` 组件允许你把 UI 逻辑从 layout 移动到组件中，使得更容易测试。Data Binding 库确保在需要时从数据源绑定和取消绑定 views。剩下的大部分工作都是为了确保你暴露了正确的数据。更多关于这个 Architecture Component，见 [ViewModel 概要](https://developer.android.com/topic/libraries/architecture/viewmodel.html)。

要将 `ViewModel` 组件与 Data Binding 库一起使用，你必须要实例化你的组件，它继承自 [ViewModel](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 类，获取一个你绑定类的实例，然后把 `ViewModel` 组件赋值到绑定类中。下面的例子展示了如何跟库一起使用组建：

```kotlin
class ViewModelActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Obtain the ViewModel component.
        UserModel userModel = ViewModelProviders.of(getActivity())
                                                  .get(UserModel.class)

        // Inflate view and obtain an instance of the binding class.
        val binding: UserBinding = DataBindingUtil.setContentView(this, R.layout.user)

        // Assign the component to a property in the binding class.
        binding.viewmodel = userModel
    }
}
```

在你的 layout 中，在你的 views 绑定表达式中分配相应的 `ViewModel` 组件的属性和方法：

```xml
<CheckBox
    android:id="@+id/rememberMeCheckBox"
    android:checked="@{viewmodel.rememberMe}"
    android:onCheckedChanged="@{() -> viewmodel.rememberMeChanged()}" />
```

## 使用一个 Observable ViewModel 对 binding adapters 进行更多的控制

你可以使用一个 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 组件实现 [`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 在数据改变时通知其它 app 组件，就像如何使用 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData) 对象。

在某些情况下, 您可能更喜欢使用实现 [`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 接口的 `ViewModel` 组件，而不是使用 `LiveData` 对象，即使失去 `LiveData` 的生命周期管理功能。使用实现 `Observable` 的 `ViewModel` 组件可让你更好地控制应用中的binding adapters。举例，这个模式让你可以更好地控制数据更改时的通知，它还允许你指定自定义方法，以便在双向数据绑定中设置属性的值。

要实现一个 observable `ViewModel` 组件，你必须创建一个类继承 [`ViewModel`](https://developer.android.com/reference/android/arch/lifecycle/ViewModel.html) 类并实现 [`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 接口。当一个观察者订阅或取消订阅来使用 [`addOnPropertyChangedCallback()`](https://developer.android.com/reference/android/databinding/Observable.html#addOnPropertyChangedCallback(android.databinding.Observable.OnPropertyChangedCallback)) 和 [`removeOnPropertyChangedCallback()`](https://developer.android.com/reference/android/databinding/Observable.html#removeOnPropertyChangedCallback(android.databinding.Observable.OnPropertyChangedCallback)) 进行通知时，你可以提供自定义逻辑。你也可以在属性改变时运行在 [`notifyPropertyChanged()`](https://developer.android.com/reference/android/databinding/BaseObservable.html#notifyPropertyChanged(int)) 方法中时提供自定义逻辑。下面的例子展示了如何实现一个 observable `ViewModel`：

```kotlin
/**
 * A ViewModel that is also an Observable,
 * to be used with the Data Binding Library.
 */
open class ObservableViewModel : ViewModel(), Observable {
    private val callbacks: PropertyChangeRegistry = PropertyChangeRegistry()

    override fun addOnPropertyChangedCallback(
            callback: Observable.OnPropertyChangedCallback) {
        callbacks.add(callback)
    }

    override fun removeOnPropertyChangedCallback(
            callback: Observable.OnPropertyChangedCallback) {
        callbacks.remove(callback)
    }

    /**
     * Notifies observers that all properties of this instance have changed.
     */
    fun notifyChange() {
        callbacks.notifyCallbacks(this, 0, null)
    }

    /**
     * Notifies observers that a specific property has changed. The getter for the
     * property that changes should be marked with the @Bindable annotation to
     * generate a field in the BR class to be used as the fieldId parameter.
     *
     * @param fieldId The generated BR id for the Bindable field.
     */
    fun notifyPropertyChanged(fieldId: Int) {
        callbacks.notifyCallbacks(this, fieldId, null)
    }
}
```




