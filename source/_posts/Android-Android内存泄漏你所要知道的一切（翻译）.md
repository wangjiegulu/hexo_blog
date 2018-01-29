---
title: '[Android]Android内存泄漏你所要知道的一切（翻译）'
tags: []
date: 2017-07-25 17:58:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/7235616.html>
**</font>

# Android内存泄漏你所要知道的一切

> 原文：https://blog.aritraroy.in/everything-you-need-to-know-about-memory-leaks-in-android-apps-655f191ca859

写一个Android app很简单，但是**写一个超高品质的内存高效的Android app并不简单**。从我的个人经验来说，我曾经比较关注和感兴趣构建我app的新特性，功能和UI组件。

我主要倾向于工作在具有更多视觉冲击力的东西，而不是花时间在没有人一眼会注意到的东西上面。我开始养成了避免或者给app优化等事情更低优先级的习惯（检测和修复内存泄漏就是其中的一个）。

这自然而然导致我承担起了技术负债，从长远来看，它开始影响我的应用的性能和质量。我满满地改变了我的心态，比起去年我更多地以“性能为重点”。

<!-- more -->

**内存泄漏的概念对很多的开发者来说是非常艰巨的。**他们觉得这是困难，耗时，无聊和不必要的，但幸运的是，这些都不是真的。一旦你开始深入，你将绝对会爱上它。

在本文中，我将尝试让这个话题尽可能地简单，这样即使是新的开发者也能从他们的职业生涯一开始就能构建高质量和高性能的Android apps。

## 垃圾收集器是你的朋友，但不一直是

**Java是一个强大的语言**。在Android中，我们不会（有时候我们会）像 C 或者 C++ 那样去写代码来让我们自己去管理整个内存分配和释放。

现在浮现在我脑中的第一个问题就是，既然Java有了一个内置专用的内存管理系统，它会在我们不需要时清理内存，那么为什么我们还需要关心这个呢。*是垃圾收集器不够完善？*

不，当然不是。**垃圾收集器的工作原理就是如此**。但是我们自己编程错误有时就会阻止垃圾收集器收集大量不必要的内存。

所以基本上，都是我们自己的错误才导致了一切的混乱。**垃圾收集器是Java最好的成就之一**，它值得被尊重。

**[推荐阅读](https://blog.aritraroy.in/what-my-2-years-of-android-development-have-taught-me-the-hard-way-52b495ba5c51)**

## 垃圾收集器“更多的一点”

在进一步之前，你需要了解一点垃圾收集器的工作原理。**它的原理非常简单**，但是它的内部有时候非常复杂。但是不用担心，我们将主要关注简单的部分。

![](http://images2015.cnblogs.com/blog/378300/201707/378300-20170724130625383-711376452.png)

每一个Android（或者Java）应用程序都有一个从对象开始获取实例化、方法被调用的起点。**所以我们可以认为这个起点是内存树的“root”**。一些对象直接保持了一个对“root”的引用，并且从它们中实例化其它对象，保持这些对象的引用等等。

因而，形成了创建内存树的引用链。所以，垃圾收集器从GC roots开始，然后直接或间接遍历对象链接到根。在这个过程的最后，存在一些GC从来没有访问到的对象。

**这些是你的垃圾（或者dead objects）**，这些对象就是我们所钟爱的垃圾收集器有资格去收集的。

到目前为止，这似乎是一个童话故事，但让我们深入了解一下开始真正的乐趣。

**Bonus:** 如果你希望学习更多关于垃圾收集器，我强烈推荐你看下 [这里](https://www.youtube.com/watch?v=UnaNQgzw4zY) 和 [这里](http://www.cubrid.org/blog/dev-platform/understanding-java-garbage-collection/) 。

## 那么现在，什么是内存泄漏呢？

知道现在，你有了一个简单想法的垃圾收集器，那么，在Android apps中内存管理师怎么工作的。现在，让我们关注于更详细的内存泄漏这个话题。

简单来说，**内存泄漏发生在当你长时间持有一个已经达到目的的对象**。实际的概念就这么简单。

每个对象都有它自己的生命，之后它需要说拜拜，然后释放内存。但是如果一些对象持有这个对象（直接或间接），那么垃圾收集器就无法收集它。**这就是我们的朋友，内存泄漏**。

但是有个好消息就是你不需要担心你app中的每一处的内存泄漏。并不是所有的内存泄漏都会伤害你的app。

有一些泄漏真的非常小（泄漏了几千字节的内存），有些存在于Android framework本身（是的，你没看错），这些你不能也不需要去修复。他们通常对于你的app影响很小并且你可以安全地忽略它们。

但是也存在其它的可以**让你的应用程序崩溃，使它像地狱一样滞留，并将其逐字缩小**。这些是你要关注的东西。

**[推荐阅读](https://blog.aritraroy.in/20-awesome-open-source-android-apps-to-boost-your-development-skills-b62832cf0fa4)**

## 为什么你真的需要解决内存泄漏？

没有人希望使用**一个缓慢的、迟钝的、吃很多内存、每用几分钟就会crash的app**。对于用户长时间使用，它真的会创建一个糟糕的体验，然后你就有永远失去用户的可能性。

![](http://images2015.cnblogs.com/blog/378300/201707/378300-20170724160146731-1663679590.png)

随着用户继续使用你的app，堆内存也不断地增长，如果你的app中有内存泄漏，那么GC就无法释放你无用的内存。所以你app的堆内存就会经常增长，直到达到一个死亡的点，**这时将没有更多的内存分配给你的app，从而导致可怕的 [OutOfMemoryError](https://docs.oracle.com/javase/7/docs/api/java/lang/OutOfMemoryError.html) 并最终让你的应用程序崩溃。**

你还要必须记住一件事情，垃圾收集器是一个繁重的过程，*垃圾收集器跑得越少，对你的app就越好。*

App正在被使用，对内存保持着增长状态，一个小的GC将启动并尝试清除刚刚死亡的对象。现在这些小的GC同时运行着（在单独的线程上），并且不会减缓你的app（2-5ms的暂停）。

**但是如果你的app内部有严重的内存泄漏的问题**，那么这些小的GC无法去回收这些内存，并且堆还在持续增长，从而迫使更大的GC被启动，这通常是一个"[停止世界](https://plumbr.eu/blog/garbage-collection/minor-gc-vs-major-gc-vs-full-gc) 的GC"，它会暂停整个app主线程（大约50-100ms），从而**使你的app严重滞后，甚至有时几乎不可用**。

所以现在你知道这些内存泄漏可能对你的应用程序产生的影响，以及**为什么需要立即修复它们**，为用户提供他们应得的最佳体验。

## 怎么去检测这些内存泄漏？

目前为止，你应该相当信服你需要修复这些隐藏在你app中的内存泄漏。**但是怎么去实际检测它们呢？**

不错的是，对于这点Android Studio提供了一个非常有用且强大的工具，**Monitors**。这个显示器不仅展示了内存使用，同样还有网络、CPU、GPU使用（更多信息查看[这里](https://developer.android.com/studio/profile/android-monitor.html)）。

![](http://images2015.cnblogs.com/blog/378300/201707/378300-20170724162545262-106537289.png)

当你在使用和调试你的app时，应该密切关注这个内存监视器。*内存泄漏的第一症状是当你持续使用你的app时内存使用图表经常增长*，并且从不下降，甚至在你切换到后台后。

[Allocation Tracker](https://developer.android.com/studio/profile/am-allocation.html)可以派上用场，你可以使用它来检查分配给应用程序中不同类型对象的内存百分比。

但是这本身还不够，因为你现在需要使用**Dump Java Heap**选项来创建一个实际表示给定时间内存快照的[heap dump](https://developer.android.com/studio/profile/am-hprof.html)。看起来是一个无聊和重复性的工作，对吧？对，它确实是。

![](http://images2015.cnblogs.com/blog/378300/201707/378300-20170724163402043-410997.png)

我们工程师往往是懒惰的，**这点 [LeakCanary](https://github.com/square/leakcanary) 来救援了**。这个库随着你的app一起运行。在需要时dump出内存，寻找潜在的内存泄漏并且通过一个清晰有用的stack trace来寻找泄漏的根源。

*LeakCanary 让任何人在他们的app中检测泄漏变得超级简单*。我不能再感谢 [Py](https://twitter.com/piwai)(来自 [Square](https://github.com/square))写了如此惊人和拯救了生命的库了。奖励！

**Bonus**: 如果你想详细学习怎么充分使用这个库，看[这里](https://realm.io/news/droidcon-ricau-memory-leaks-leakcanary/)。

[推荐阅读](https://blog.aritraroy.in/50-ultimate-resources-to-master-android-development-15165d6bc376)

## 一些实际常见的内存泄漏情况并怎么去解决它们

从我们经验来看，有几个最常见的可能会导致内存泄漏的场景，它们都非常相似，你会在日常的Android开发中遇到这些情况。

一旦你知道这些内存泄漏发生在什么时候，什么地方，怎么发生，你就可以更容易对此进行修复。

### Unregistered Listeners

有很多场景，你在Activity（或者Fragment）中进行了一个监听器的注册，但是忘记把它反注册掉。**如果运气不好，这个很容易导致一个巨大的内存泄漏**。一般情况下，这些监听器是平衡的，所以如果你在某些地方注册了它，你也需要在那里反注册它。

现在我们来看一个简单的例子。假设你要在你的app中接收到位置的更新，你要做的事就是拿到一个 [LocationManager](https://developer.android.com/reference/android/location/LocationManager.html) 系统服务，然后为位置更新注册一个listener。

```java
private void registerLocationUpdates(){
mManager = (LocationManager) getSystemService(LOCATION_SERVICE);
mManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,
            TimeUnit.MINUTES.toMillis(1), 
            100, 
            this);
}
```

你在Activity本身实现了listener接口，*因此 LocationManager 持有了一个它的引用*。现在你的Activity是时候要销毁了，Android Framework将会调用它的 onDestroy() 方法，但是垃圾收集器将不能从内存中把这个实例删除，因为 LocationManager 仍然持有了它的强引用。

**解决方案非常简单**。仅仅在 onDestroy() 方法中反注册掉listener，这个很好实现。这是我们大多数人忘记甚至不知道的。

```java
@Override
public void onDestroy() {
    super.onDestroy();
    if (mManager != null) {
        mManager.removeUpdates(this);
    }
}
```

### 内部类

内部类在Java中非常常见，由于它的简洁性，Android开发者经常使用在各种任务中。但是由于不恰当的使用，*这些内部类也导致了潜在的内存泄漏。*

让我们再在一个简单例子的帮助下看看，

```java
public class BadActivity extends Activity {
    private TextView mMessageView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_bad_activity);
        mMessageView = (TextView) findViewById(R.id.messageView);
        new LongRunningTask().execute();
    }
    private class LongRunningTask extends AsyncTask<Void, Void, String> {
        @Override
        protected String doInBackground(Void... params) {
            return "Am finally done!";
        }
        @Override
        protected void onPostExecute(String result) {
            mMessageView.setText(result);
        }
    }
}
```

这是一个非常简单的Activity，它在后台（也许是复杂的数据库查询或者一个缓慢的网络请求）启动了一个耗时任务。在Task完成时，结果被展示在 TextView。看起来一切都很好？

不，当然不是。问题在于**非静态内部类持有一个外部类的隐式引用**（也就是Activity本身）。现在如果我们旋转了屏幕或者如果这个耗时的任务比Activity生命长，那么它不会让垃圾收集器把整个Activity实例从内存回收。**一个简单的错误导致了一个巨大的内存泄漏**。

但是解决方案还是非常简单，看了你就明白了，

```java
public class GoodActivity extends Activity {
    private AsyncTask mLongRunningTask;
    private TextView mMessageView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_good_activity);
        mMessageView = (TextView) findViewById(R.id.messageView);
        mLongRunningTask = new LongRunningTask(mMessageView).execute();
    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        mLongRunningTask.cancel(true);
    }
    private static class LongRunningTask extends AsyncTask<Void, Void, String> {
        private final WeakReference<TextView> messageViewReference;
        public LongRunningTask(TextView messageView) {
            this.messageViewReference = new WeakReference<>(messageView);
        }
        @Override
        protected String doInBackground(Void... params) {
            String message = null;
            if (!isCancelled()) {
                message = "I am finally done!";
            }
            return message;
        }
        @Override
        protected void onPostExecute(String result) {
            TextView view = messageViewReference.get();
            if (view != null) {
                view.setText(result);
            }
        }
    }
}
```

如你所见，**我把非静态内部类改成了静态内部类**，这样静态内部类就不会持有任何外部类的隐式引用。但是我们不能通过静态上下文去访问外部类的非静态变量（比如 TextView），所以我们不得不通过构造方法传递我们需要的对象引用到内部类。

我强烈推荐使用 WeakReference 包装这个对象引用来防止进一步的内存泄漏。你需要开始学习关于**在Java中各个可用的引用类型**。

### 匿名类

匿名类是很多开发者最喜欢的，因为它们被定义的方式使得用它们编写代码非常容易和简洁。但是根据我的经验**这些匿名类是内存泄漏最常见的原因**。

匿名类没有什么，但是非静态内部类会由于前面我讲到过的同样的理由引发潜在的内存泄漏。你已经在app的一系列地方用到了它，**但是你不知道如果错误的使用可能会对你app的性能有严重的影响**。

```java
public class MoviesActivity extends Activity {
    private TextView mNoOfMoviesThisWeek;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_movies_activity);
        mNoOfMoviesThisWeek = (TextView) findViewById(R.id.no_of_movies_text_view);
        MoviesRepository repository = ((MoviesApp) getApplication()).getRepository();
        repository.getMoviesThisWeek()
                .enqueue(new Callback<List<Movie>>() {

                    @Override
                    public void onResponse(Call<List<Movie>> call,
                                           Response<List<Movie>> response) {
                        int numberOfMovies = response.body().size();
                        mNoOfMoviesThisWeek.setText("No of movies this week: " + String.valueOf(numberOfMovies));
                    }
                    @Override
                    public void onFailure(Call<List<Movie>> call, Throwable t) {
                        // Oops.
                    }
                });
    }
}
```

这里，我们使用了一个非常流行的库 [Retrofit](https://github.com/square/retrofit) 来执行一个网络请求并把结果显示在 TextView 上。很明显，Callable 对象持有了一个外部Activity类的引用。

如果这个网络请求执行速度非常慢，并且在调用结束之前 Activity 因为某种情况被旋转了屏幕或者被销毁，**那么整个Activity实例都会被泄漏**。

不管是否必须，使用静态内部类来代替匿名内部类通常是明智之举。不是我突然告诉你完全停止使用匿名类，而是你必须要懂得判断什么时候能用什么时候不能用。

[推荐阅读](https://blog.aritraroy.in/why-you-should-start-using-kotlin-to-supercharge-your-android-development-in-2017-61db1f11d666)

### Bitmaps

在你app中看到的所有图片都没关系，除了 [Bitmap](https://developer.android.com/reference/android/graphics/Bitmap.html) ，它包含了图像的整个像素数据。

这些 bitmaps 对象一般非常重，**如果处理不当可能会引发明显的内存泄漏**，并最终让你的app因为 [OutOfMemoryError](https://developer.android.com/reference/java/lang/OutOfMemoryError.html) 而崩溃。你在app中使用的图片相关的 bitmap 内存 都会由Android Framework 自身自动管理，如果你手动处理 Bitmap，确保在使用后进行 [recycle()](https://developer.android.com/reference/android/graphics/Bitmap.html#recycle%28%29)。

**你还必须学会怎么去正确地管理这些bitmaps**，加载大的Bitmap时通过压缩，以及使用bitmap缓存池来尽可能减少内存的占用。[这里](https://developer.android.com/training/displaying-bitmaps/manage-memory.html) 有一个理解 bitmap 处理的很好的资源。

### Contexts

另一个相当常见的内存泄漏是滥用 context 实例。[Context](https://developer.android.com/reference/android/content/Context.html) 只是一个抽象类，它有很多类（比如 Activity，Application，Service 等等）继承它并提供它们自己的功能。

> *如果你要在 Android 中完成任务，那么 Context 对象就是你的老板。*

但是这些 contexts 有一些不同之处。非常重要的一点是**理解 Activity级别的Context 和 Application级别的Context 之间的区别**，分别用在什么情况下。

在错误的地方使用 Activity context 会持有整个 Activity 的引用并引发潜在的内存泄漏。[这里](https://medium.com/@ali.muzaffar/which-context-should-i-use-in-android-e3133d00772c#.mruk222z2)有篇很好的文章作为开始。

## 总结

现在你肯定知道垃圾收集器是怎么工作的，什么是内存泄漏，它们如何对你的app产生重大的影响。你也学习了怎样检测和修复这些内存泄漏。

**没有任何借口，从现在开始让我们开始构建一个高质量，高性能的 Android app**。检测和修复内存泄漏不仅会让你的app的用户体验更好，而且会慢慢地让你成为一个更好的开发者。

本文最初发表于 [TechBeacon](http://techbeacon.com/).

