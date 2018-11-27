---
title: Android Architecture Component WorkManager  高级（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles", "WorkManager", "翻译"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1529792083865-d23889753466?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=32475a0b7929a8a98b874ff47bf1bd4c&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-11-20 20:01:00
---

# Android Architecture Component WorkManager 高级（翻译）

> 原文：<https://developer.android.com/topic/libraries/architecture/workmanager/advanced>

通过 WorkManager 可以轻松地设置和安排复杂的任务请求。你可以在以下场景使用这些 APIs：

- 通过指定顺序去执行 tasks 的 [链序列](https://developer.android.com/topic/libraries/architecture/workmanager/advanced#chained)。
- 唯一的 [命名序列](https://developer.android.com/topic/libraries/architecture/workmanager/advanced#unique)，以及在应用启动两个同名序列时发生的情况的规则。
- Tasks 的 [输入输出值](https://developer.android.com/topic/libraries/architecture/workmanager/advanced#params)，包括每个 task 的输出作为参数输入到下一个 tasks 中的链 tasks。

## 链 tasks

你的 app 可能需要以一个特定的顺序来执行多个 tasks。[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 允许你创建一个工作序列并对它进行排队，该序列指定多个 tasks 以及它应该按什么顺序运行。

举个例子，假设你的 app 有三个 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 对象：`workA`，`workB`，`workC`。任务必须要按照这个顺序执行。为了排队它们，要通过 [`WorkManager.beginWith()`](https://developer.android.com/reference/androidx/work/WorkManager#beginWith(java.util.List%3Candroidx.work.OneTimeWorkRequest%3E)) 方法创建一个序列，传入第一个 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 对象；这个方法返回一个 [`WorkContinuation`](https://developer.android.com/reference/androidx/work/WorkContinuation.html) 对象，它定义了 tasks 的序列。然后使用 [`WorkContinuation.then()`](https://developer.android.com/reference/androidx/work/WorkContinuation#then) 按照顺序增加其它的 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 对象，最后，使用 [`WorkContinuation.enqueue()`](https://developer.android.com/reference/androidx/work/WorkContinuation#enqueue) 来排队整个序列：

```kotlin
WorkManager.getInstance()
    .beginWith(workA)
        // Note: WorkManager.beginWith() returns a
        // WorkContinuation object; the following calls are
        // to WorkContinuation methods
    .then(workB)    // FYI, then() returns a new WorkContinuation instance
    .then(workC)
    .enqueue()
```

[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 会按照请求的顺序以及每个 task 指定的约束来运行 tasks。如果 任何 task 返回了 [`Worker.Result.FAILURE`](https://developer.android.com/reference/androidx/work/Worker.Result#FAILURE)，则整个序列结束。

你也可以传入多个 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 对象到 [`beginWith()`](https://developer.android.com/reference/androidx/work/WorkManager#beginWith(java.util.List%3Candroidx.work.OneTimeWorkRequest%3E)) 和 [`.then()`](https://developer.android.com/reference/androidx/work/WorkContinuation#then) 调用。如果你传入几个 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 到一个单独的方法调用，[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 会在运行其余 tasks 之前运行这些 tasks（并行）。比如：

```kotlin
WorkManager.getInstance()
    // 首先，运行所有 A tasks (并行):
    .beginWith(workA1, workA2, workA3)
    // ...当所有的 A tasks 结束, 运行单个 B task:
    .then(workB)
    // ...然后运行 C tasks (以任何顺序):
    .then(workC1, workC2)
    .enqueue()
```

你可以通过 [`WorkContinuation.combine()`](https://developer.android.com/reference/androidx/work/WorkContinuation#combine) 方法连接多个链来创建更复杂的序列。比如，假设你想要运行像以下的序列：

<div style='text-align: center;'>
<img src='https://user-images.githubusercontent.com/5423194/49058154-c3667a00-f23d-11e8-97a0-ca92352ce1ac.png' width=400px/>
</div>

要设置这个序列，创建两个独立的链，然后把它们链接在一起形成第三个：

```kotlin
val chain1 = WorkManager.getInstance()
    .beginWith(workA)
    .then(workB)
val chain2 = WorkManager.getInstance()
    .beginWith(workC)
    .then(workD)
val chain3 = WorkContinuation
    .combine(chain1, chain2)
    .then(workE)
chain3.enqueue()
```

在这种情况下，[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 在 `workB` 之前运行 `workA`。运行 `workD` 之前运行 `workC`。在 `workB` 和 `workD` 都完成之后，[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 运行 `workE`。

> **注意**：当 [WorkManager](https://developer.android.com/reference/androidx/work/WorkManager.html) 按照顺序运行没个子链，不能保证 **链1** 中的任务与 **链2** 中的任务可能重叠。比如，**workB** 可能在 **workC** 之前或者之后运行，或者同时运行。只能保证每个子链中的 task 将按顺序运行；就是，**workB** 不会运行直到 **workA** 完成。

[`WorkContinuation`](https://developer.android.com/reference/androidx/work/WorkContinuation.html) 有许多变种来提供为特定情况提供快捷。举个例子，[`WorkContinuation.combine(OneTimeWorkRequest, WorkContinuation…)`](https://developer.android.com/reference/androidx/work/WorkContinuation#combine(androidx.work.OneTimeWorkRequest,%20java.util.List%3Candroidx.work.WorkContinuation%3E)) 方法是指示 [`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 完成所有指定的 [`WorkContinuation`](https://developer.android.com/reference/androidx/work/WorkContinuation.html) 链，然后完成指定的 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html)。详请可参阅 [WorkContinuation](https://developer.android.com/reference/androidx/work/WorkContinuation.html)。

## 唯一工作序列

你可以通过调用 [`beginUniqueWork()`](https://developer.android.com/reference/androidx/work/WorkManager#beginUniqueWork(java.lang.String,%20androidx.work.ExistingWorkPolicy,%20androidx.work.OneTimeWorkRequest...)) 而不是 [`beginWith()`](https://developer.android.com/reference/androidx/work/WorkManager#beginWith(java.util.List%3Candroidx.work.OneTimeWorkRequest%3E)) 开始一个序列来创建一个 *唯一的工作序列*。每一个唯一工作序列都有一个名字；[`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 一次只允许一个序列具有该名字。当你创建一个新的唯一工作序列时，你要指定如果已经有一个相同名字并且未完成的序列时 [`WorkManager`](https://developer.android.com/reference/androidx/work/WorkManager.html) 应该怎么做：

- 取消已经存在的序列并用新的 [替换](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy#replace) 它
- [保留](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy#keep) 存在的序列并忽略掉你新的请求。
- [追加](https://developer.android.com/reference/androidx/work/ExistingWorkPolicy#append) 你新的序列到你存在的序列上，在存在的序列的最后一个 task 执行完之后执行新的序列的第一个 task。

唯一工作序列在你有一个 task 不该排队多次的时候很有用。举个例子，如果你的 app 需要同步数据到网络，你可能对名为 “sync” 的序列进行排队，然后指定如果已经有这个名字的序列存在，则你新的 task 应该被忽略。唯一工作序列在你需要去逐渐建立一个长长的任务链时也很有用。举个例子，一个图片编辑 app 可能会让用户撤销一个很长的动作链。这些每个撤销的操作都可能会需要花费一些时间，但是它们需要以一个正确的顺序被执行。在这个情况下，app 应该创建一个 “undo” 链，并且如果需要则追加每个撤销操作。

## 输入和输出值

为了更大的灵活性，你可以传入参数到你的 tasks 并让 task 返回值。输入输出值是键值对。要传入值到一个 task，则需要在你创建 [`WorkRequest`](https://developer.android.com/reference/androidx/work/WorkRequest.html) 对象之前调用 [`WorkRequest.Builder.setInputData()`](https://developer.android.com/reference/androidx/work/WorkRequest.Builder#setinputdata) 方法。这个方法接收一个 [`Data`](https://developer.android.com/reference/androidx/work/Data.html) 对象，你可以通过 [`Data.Builder`](https://developer.android.com/reference/androidx/work/Data.Builder.html) 来创建它。[`Worker`](https://developer.android.com/reference/androidx/work/Worker.html) 类可以通过 [`Worker.getInputData()`](https://developer.android.com/reference/androidx/work/Worker#getinputdata) 来访问这些参数。要输出一个返回值，task 要调用 [`Worker.setOutputData()`](https://developer.android.com/reference/androidx/work/Worker#setoutputdata)，它接受一个 [`Data`](https://developer.android.com/reference/androidx/work/Data.html) 对象。你可以通过观察 task 的 `LiveData<WorkStatus>` 来得到输出。

举个例子，假设你有一个 [`Worker`](https://developer.android.com/reference/androidx/work/Worker.html) 类来执行耗时的计算。以下代码展示了 [`Worker`](https://developer.android.com/reference/androidx/work/Worker.html) 类应该是怎么样的：

```kotlin
// Define the parameter keys:
const val KEY_X_ARG = "X"
const val KEY_Y_ARG = "Y"
const val KEY_Z_ARG = "Z"

// ...and the result key:
const val KEY_RESULT = "result"

// Define the Worker class:
class MathWorker(context : Context, params : WorkerParameters)
    : Worker(context, params)  {

    override fun doWork(): Result {
        val x = inputData.getInt(KEY_X_ARG, 0)
        val y = inputData.getInt(KEY_Y_ARG, 0)
        val z = inputData.getInt(KEY_Z_ARG, 0)

        // ...do the math...
        val result = myCrazyMathFunction(x, y, z);

        //...set the output, and we're done!
        val output: Data = mapOf(KEY_RESULT to result).toWorkData()
        setOutputData(output)

        return Result.SUCCESS
    }
}
```

要创建一个 worker 并传入参数，你应该如下编写代码：

```kotlin
val myData: Data = mapOf("KEY_X_ARG" to 42,
                       "KEY_Y_ARG" to 421,
                       "KEY_Z_ARG" to 8675309)
                     .toWorkData()

// ...then create and enqueue a OneTimeWorkRequest that uses those arguments
val mathWork = OneTimeWorkRequestBuilder<MathWorker>()
        .setInputData(myData)
        .build()
WorkManager.getInstance().enqueue(mathWork)
```

返回值会在 task 的 [`WorkStatus`](https://developer.android.com/reference/androidx/work/WorkStatus.html) 中可用：

```kotlin
WorkManager.getInstance().getStatusById(mathWork.id)
        .observe(this, Observer { status ->
            if (status != null && status.state.isFinished) {
                val myResult = status.outputData.getInt(KEY_RESULT,
                      myDefaultValue)
                // ... do something with the result ...
            }
        })
```

如果你链接了 tasks，一个 task 的输出可作为链中下一个 task 的输入。如果它是一个简单链，使用单个的 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html) 链接另一个单个 [`OneTimeWorkRequest`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.html)，第一个 tasker 通过调用 [`setOutputData()`](https://developer.android.com/reference/androidx/work/Worker.html#setOutputData(androidx.work.Data)) 返回结果，然后下一个 task 通过调用 [`getInputData()`](https://developer.android.com/reference/androidx/work/Worker.html#getinputdata) 获取结果。如果链更复杂 —— 比如，因为几个 task 都发送输入到一个单个的后续任务 —— 你可以在 [`OneTimeWorkRequest.Builder`](https://developer.android.com/reference/androidx/work/OneTimeWorkRequest.Builder.html) 定义一个 [`InputMerger`](https://developer.android.com/reference/androidx/work/InputMerger.html) 来指定如果多个 tasks 返回一个相同 key 的输出时应该怎么处理。

## 额外的资源

`WorkManager` 是一个 [Android Jetpack](https://developer.android.com/jetpack/) architecture component。可参阅使用到它的 [Sunflower](https://github.com/googlesamples/android-sunflower) demo app。

