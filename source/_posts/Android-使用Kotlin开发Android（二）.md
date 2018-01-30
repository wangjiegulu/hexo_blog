---
title: '[Android]使用Kotlin开发Android（二）'
tags: [android, kotlin, anko]
date: 2015-09-22 15:08:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/4829007.html>
**</font>

[TOC]
## 使用Kotlin＋OkHttp＋RxJava进行网络请求
代码：<https://github.com/wangjiegulu/KotlinAndroidSample>

### 1\. 需要
- 对[Kotlin]语法有基本的掌握
- 对[OkHttp]有基本的了解
- 对[RxJava] / [RxAndroid]有基本的了解

### 2\. Kotlin搭建环境
见之前的文章：[[Android]使用Kotlin+Anko开发Android（一）](http://www.cnblogs.com/tiantianbyconan/p/4800656.html)

### 3\. Gradle添加相关依赖包：
```
compile "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
compile "org.jetbrains.kotlin:kotlin-reflect:$kotlin_version"
compile 'com.squareup.okhttp:okhttp:2.4.0'
compile 'io.reactivex:rxjava:1.0.12'
compile 'io.reactivex:rxandroid:0.24.0'
```

### 4\. 请求
一般的写法如下：
```kotlin
Observable.defer({ ->
                Observable.just(OkHttpClient().newCall(
                        Request.Builder()
                                .url("https://github.com/wangjiegulu")
                                .get()
                                .build()
                ).execute())
            }).subscribeOn(Schedulers.newThread())
                    .map({r -> r.body().string()})
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({ result -> Log.d(TAG, "request result: $result"); resultTv.setText("Http request succeed, see log") }, {throwable -> Log.e(TAG, "", throwable)});
```

### 5\. 使用Kotlin语法糖进行简化
#### 1) 在String类中扩展http请求方法
我们希望在url（String）中增加一个方法，直接调用后构建一个http请求：
```kotlin
fun String.request(): Request.Builder = Request.Builder().url(this);
```
如上代码，在String类中定义了一个request()方法，返回一个OkHttp的Request.Builder对象，并设置url为当前的String对象，即当前的url。

#### 2) 在Request.Builder类中扩展执行http请求方法
调用String方法的request()方法之后，获得了一个构建的Request.Builder对象，然后希望通过这个对象调用某个方法来执行http请求，于是继续扩展：
```kotlin
fun Request.Builder.rxExecute(): Observable<Response> = Observable.defer({ Observable.just(OkHttpClient().newCall(this.build()).execute()) }).subscribeOn(Schedulers.newThread());
```
我们在Request.Builder类中定义了一个rxExecute()方法，这个方法中，会通过RxJava构建一个Obserable对象，Obserable对象中排出给观察者的数据就是http执行完毕后的结果Response。并且指定了执行http请求所在的线程。

#### 3) 优化后的调用方式
```kotlin
"https://github.com/wangjiegulu".request().get().rxExecute()
                    .map({ r -> r.body().string() })
                    .observeOnMain()
                    .subscribeSafeNext { result -> Log.d(TAG, "request result: $result"); resultTv.setText("Http request succeed, see log") }
```
如上：通过url构建Request.Builder，然后通过RequestBuilder构建一个Obserable，然后订阅获得排出的请求结果。

为了方便调用，又在Obserable中扩展了几个方法：
```kotlin
fun <T> Observable<T>.observeOnMain(): Observable<T> = this.observeOn(AndroidSchedulers.mainThread())

fun <T> Observable<T>.subscribeSafeNext(onNext: (T) -> Unit): Subscription = this.subscribe(onNext, { t -> Log.e(TAG, "", t) }, {});

fun <T> Observable<T>.subscribeSafeCompleted(onCompleted: () -> Unit): Subscription = this.subscribe({}, { t -> Log.e(TAG, "", t) }, onCompleted);
```

[Kotlin]: http://kotlinlang.org/
[OkHttp]: https://github.com/square/okhttp
[RxJava]: https://github.com/ReactiveX/RxJava
[RxAndroid]: https://github.com/ReactiveX/RxAndroid

