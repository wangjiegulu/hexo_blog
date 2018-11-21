---
title: Android Architecture Component LiveData（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 19:01:00
---

# Android Architecture Component LiveData（翻译）

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
 
 如果生命周期变为非活动状态, 它将在再次处于活动状态时接收最新数据。例如, 后台的活动在返回到前台后立即接收最新数据。
