---
title: Android Architecture Component WorkManager 基础（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles", "WorkManager", "翻译"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1529792083865-d23889753466?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=32475a0b7929a8a98b874ff47bf1bd4c&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-10-20 19:01:00
---

# Android Architecture Component WorkManager 基础（翻译）

> 原文：<https://developer.android.com/topic/libraries/architecture/workmanager/basics/>

使用 WorkManager，你可以很容易地设置任务，并将它移交给系统并在你指定的条件下运行。

本文述介绍了 WorkManager 最基本的功能。你可以学习到如何去设置一个 task，指定在什么条件下运行，并交给系统处理。你也可以如何去设置一个重复的 jobs。

更多关于 WorkManager 高级功能的信息，比如 job 链的输入输出值，参阅 [WorkManager 高级功能](https://developer.android.com/topic/libraries/architecture/workmanager/advanced.html)。还有更多可用的功能；完整信息见 [WorkManager 参考文档](https://developer.android.com/reference/androidx/work/package-summary)。

> **注意**：要导入 WorkManager 到你的项目中，见 [在你的项目中增加 Components](https://developer.android.com/topic/libraries/architecture/adding-components.html#workmanager)。

## 类和概念

WorkManager API 使用了几个不通的类。在一些情况下，你要编写其中一些 API 类的子类。

以下是最重要的 WorkManager 类：

- [`Worker`](https://developer.android.com/reference/androidx/work/Worker.html)：指定你需要执行的 task。WorkManager APIs 包含了一个抽象的 [`Worker`](https://developer.android.com/reference/androidx/work/Worker.html) 类。你要继承这个类并在这里执行工作。
- [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html)：表示一个单个 task。最低限度，一个 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 对象指定哪个 [`Worker`](https://developer.android.com/reference/androidx/work/Worker.html) 类应该执行 task。但是你也可以在 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 对象中增加细节，指定任务应该在哪种情况下运行的事项。每个 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 有一个自动生成的唯一 ID；你可以使用 ID 来做一些比如取消排队中的 task 或者获取 task 的状态等操作。[`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 是一个抽象类；在你的代码中，你将使用它的直接子类之一，[`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 或者 [`PeriodicWorkRequest`](https://developer.android.com/reference/androidx/work/PeriodicWorkRequest.html)。
 - [`WorkRequest.Builder`](https://developer.android.com/reference/androidx/work/WorkRequest.Builder.html)：一个帮助类，用于创建 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 对象。同样，你将使用它的子类之一，[`OneTimeWorkRequest.Builder`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.Builder.html) 或者 [`PeriodicWorkRequest.Builder`](https://developer.android.com/reference/androidx/work/PeriodicWorkRequest.Builder.html)。
 - [`Constraints`](https://developer.android.com/reference/androidx/work/Constraints.html)：指定何时运行 task（比如，“只在连接到网络时”） 的约束。你使用 [`Constraints.Builder`](https://developer.android.com/reference/androidx/work/Constraints.Builder.html) 来创建 [`Constraints`](https://developer.android.com/reference/androidx/work/Constraints.html)，并且传递 [`Constraints`](https://developer.android.com/reference/androidx/work/Constraints.html) 到 [`WorkRequest.Builder`](https://developer.android.com/reference/androidx/work/WorkRequest.Builder.html) 来创建 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html)
- [`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html)：排队和管理 work 请求。你把 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 对象传入到 [`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 将 task 排队。[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 可以在一个分散系统资源的负载同时又遵守指定约束的的方式调度 task。
- [`WorkInfo`](https://developer.android.com/reference/androidx/work/WorkInfo.html)：包含了关于某个特定 task 的信息。[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 为每个 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 对象提供了一个 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html)。[`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 持有一个 [`WorkInfo`](https://developer.android.com/reference/androidx/work/WorkInfo.html) 对象；通过观察这个 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html)，你可以确定任务的当前状态，并在任务完成后获取任何返回的值。

## 典型的工作流程

假设你正在编写一个图片库的 app，并且这个 app 需要定期去压缩存储的图片。你希望使用 WorkManager APIs 来调度图片压缩。在这种情况下，你并不特别关心图片何时会被压缩；你想设置任务，然后就忘掉它。

首先，你应该去定义你的 [`Work`](https://developer.android.com/reference/androidx/work/Worker.html) 类，然后复写它的 [`doWork()`](https://developer.android.com/reference/androidx/work/Worker.html#doWork()) 方法。你的 Worker 类指定如何去执行这个操作，但没有任何有关 task 应该在何时运行的信息。

```kotlin
class CompressWorker(context : Context, params : WorkerParameters)
    : Worker(context, params) {

    override fun doWork(): Result {

        // Do the work here--in this case, compress the stored images.
        // In this example no parameters are passed; the task is
        // assumed to be "compress the whole library."
        myCompress()

        // Indicate success or failure with your return value:
        return Result.SUCCESS

        // (Returning RETRY tells WorkManager to try this task again
        // later; FAILURE says not to try again.)

    }

}
```

然后你基于 [`Worker`](https://developer.android.com/reference/androidx/work/Worker.html) 去创建一个 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 对象，然后使用 [`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 将其排队：

```kotlin
val compressionWork = OneTimeWorkRequestBuilder<CompressWorker>().build()
WorkManager.getInstance().enqueue(compressionWork)
```

[WorkManager](https://developer.android.com/reference/androidx/work/WorkManager.html) 选择一个合适的时间去运行这个 task 来平衡诸如系统负载，设备是否插入等考虑因素。在大多情况下，如果你不指定任何约束，[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 会立即运行你的任务。如果你需要去检查 task 的状态，你可以通过获取适当的 `LiveData<WorkInfo>` 的句柄来获取一个 [`WorkInfo`](https://developer.android.com/reference/androidx/work/WorkInfo.html)。举个例子，如果你想要去检查 task 是否已经完成了，你应该通过以下方式：

```kotlin
WorkManager.getInstance().getWorkInfoByIdLiveData(compressionWork.id)
                .observe(lifecycleOwner, Observer { workInfo ->
                    // Do something with the status
                    if (workInfo != null && workInfo.state.isFinished) {
                        // ...
                    }
                })
```

更多关于使用 [`LiveData`](https://developer.android.com/reference/android/arch/lifecycle/LiveData.html) 的详情，见 [LiveData 概要](https://developer.android.com/topic/libraries/architecture/livedata)。

## Task 条件

如果你想要，你可以去指定 task 在何时应该运行的约束。举例，你可能想要去指定 task 应该只运行在设备闲置，并且电源连接时。在这两种情况下，你需要创建一个 [`OneTimeWorkRequest.Builder`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.Builder.html) 对象，并使用这个 builder 来创建一个真正的 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html)：

```kotlin
// Create a Constraints object that defines when the task should run
val myConstraints = Constraints.Builder()
        .setRequiresDeviceIdle(true)
        .setRequiresCharging(true)
        // Many other constraints are available, see the
        // Constraints.Builder reference
        .build()

// ...then create a OneTimeWorkRequest that uses those constraints
val compressionWork = OneTimeWorkRequestBuilder<CompressWorker>()
        .setConstraints(myConstraints)
        .build()
```

然后把新的 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 对象传递到 [`WorkManager.enqueue()`](https://developer.android.com/reference/androidx/work/WorkManager#enqueue(java.util.List%3C?%20extends%20androidx.work.WorkRequest%3E))，像之前所说的，[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 会在找运行任务时间时会考虑你的约束条件。

## 取消一个 Task

在你把一个 task 加入到队列后，你可以去取消它。要取消这个 task，你需要一个它的 work ID，这可以在从 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 对象。举例，下面的代码取消了上面一节中的 `compressionWork` 请求：

```kotlin
val compressionWorkId:UUID = compressionWork.getId()
WorkManager.getInstance().cancelWorkById(compressionWorkId)
```

[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 会尽最大努力去取消这个 task，但这本质上是不确定的 -- 当你试图取消任务时，任务可能已经运行中或已经完成。[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 也提供方法去取消在 [唯一工作序列](https://developer.android.com/topic/libraries/architecture/workmanager/advanced.html#unique) 中的所有 task，或者所有拥有一个指定 tag 的所有 tasks，也是在尽最大努力的基础上的。

## Tagged Work

你可以通过给任何 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 对象分配一个字符串的 tag 来为你的 tasks 在逻辑上进行分组。要设置一个 tag，调用 [`WorkRequest.Builder.addTag()`](https://developer.android.com/reference/androidx/work/WorkRequest.Builder#addtag)，比如：

```kotlin
val cacheCleanupTask =
        OneTimeWorkRequestBuilder<MyCacheCleanupWorker>()
    .setConstraints(myConstraints)
    .addTag("cleanup")
    .build()
```

[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 类提供了几个工具方法来让你通过指定的 tag 来操作所有的 tasks。比如，[`WorkManager.cancelAllWorkByTag()`](https://developer.android.com/reference/androidx/work/WorkManager#cancelallworkbytag) 通过指定 tag 来取消所有 tasks，[`WorkManager.getWorkInfosByTagLiveData()`](https://developer.android.com/reference/androidx/work/WorkManager#getworkinfosbytaglivedata) 返回一个所有这个 tag 的 tasks 的 [`WorkInfo`](https://developer.android.com/reference/androidx/work/WorkInfo.html) 列表。

## 重复 tasks

你可能有一个 task 需要去重复地执行。举个例子，图片管理 app 可能不会只压缩图片一次。更可能的是，它会经常去检查共享的照片，看是否有新的或者修改过的照片需要被压缩。这个重复的 task 可以在它找到新的图片时压缩图片，或者，当它发现需要压缩的图像时，它可能会触发新的 “压缩此图像” 任务。

要创建一个重复的 task，使用 [`PeriodicWorkRequest.Builder`](https://developer.android.com/reference/androidx/work/PeriodicWorkRequest.Builder.html) 类来创建一个 [`PeriodicWorkRequest`](https://developer.android.com/reference/androidx/work/PeriodicWorkRequest.html) 对象，然后跟 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 同样的方式去排队 [`PeriodicWorkRequest`](https://developer.android.com/reference/androidx/work/PeriodicWorkRequest.html)。举个例子，假设我们定义了一个 `PhotoCheckWorker` 类来识别图片是否需要被压缩。如果你想要每 12 小时一次运行这个清单 task，你应该如下创建一个 [`PeriodicWorkRequest`](https://developer.android.com/reference/androidx/work/PeriodicWorkRequest.html) 对象：

```kotlin
val photoCheckBuilder =
        PeriodicWorkRequestBuilder<PhotoCheckWorker>(12, TimeUnit.HOURS)
// ...if you want, you can apply constraints to the builder here...

// Create the actual work object:
val photoCheckWork = photoCheckBuilder.build()
// Then enqueue the recurring task:
WorkManager.getInstance().enqueue(photoCheckWork)
```

[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 尝试在你请求的时间间隔去运行你的 task，受你设置的限制和其他要求的约束。





