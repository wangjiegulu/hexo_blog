---
title: Android Architecture Component WorkManager Overview（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles", "WorkManager", "翻译"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1529792083865-d23889753466?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=32475a0b7929a8a98b874ff47bf1bd4c&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-11-20 18:01:00
---

# Android Architecture Component WorkManager Overview（翻译）

> 原文：<https://developer.android.com/topic/libraries/architecture/workmanager/>

WorkManager API 可以让指定可延迟的异步任务以及这些任务应在何时运行变得简单。这些 API 让你创建一个 task，并交给 WorkManager 处理来立即或在适当的时间运行。

WorkManager 会基于设备 API 的级别和 app 状态等因素来选择适当的方式运行你的 task。在 app 运行时，如果 WorkManager 执行你 tasks 的其中一个，WorkManager 可以在你 app 进程中的一个新的线程中执行你的 task。如果 app 没有在运行中，WorkManager 会选择合适的方式来调度一个后台任务 — 取决于设备 API 级别和包含的依赖，WorkManager 可能会使用 [`JobScheduler`](https://developer.android.com/reference/android/app/job/JobScheduler.html)，[`Firebase JobDispatcher`](https://github.com/firebase/firebase-jobdispatcher-android#user-content-firebase-jobdispatcher-)，或者 [`AlarmManager`](https://developer.android.com/reference/android/app/AlarmManager.html)。你不需要编写设备逻辑来确定设备具有哪些功能，并选择适当的 api。而是你仅仅把 task 交给 WorkManager 并让它自己选择最好的方式。

> **注意**：工作管理器适用于需要保证即使应用退出系统也有运行的任务，比如上传 app 数据到服务器。它不适用于在应用进程销毁时要安全终止的进程内后台工作。对于这种场景，我们建议使用 [ThreadPools](https://developer.android.com/training/multiple-threads/create-threadpool#ThreadPool)。

## 主题

- [**WorkManager 基础**](https://developer.android.com/topic/libraries/architecture/workmanager/basics.html)
 
 - 使用工作管理器计划在你选择的场景下运行的单个任务，或以指定间隔运行的定期任务。

- [**WorkManager 高级功能**](https://developer.android.com/topic/libraries/architecture/workmanager/advanced.html)
 
 - 设置链接的任务序列，设置输入输出值的任务，并设置命名的，唯一的工作序列。

## 额外资源

`WorkManager` 在 [Sunflower](https://github.com/googlesamples/android-sunflower) demo app 中被使用。

也可以参阅 Architecture Components [WorkManager sample](https://github.com/googlesamples/android-architecture-components/tree/master/WorkManagerSample)。