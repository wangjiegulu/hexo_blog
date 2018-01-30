---
title: '[Android]Android MVP&依赖注入&单元测试'
tags: [android, mvp, dependency injection, unit test, framework, mvc]
date: 2016-04-22 18:44:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5422443.html>
**</font>

# Android MVP&依赖注入&单元测试

> **注意**：为了区分`MVP`中的`View`与`Android`中控件的`View`，以下`MVP`中的`View`使用`Viewer`来表示。

这里暂时先只讨论 `Viewer` 和 `Presenter`，`Model`暂时不去涉及。

## 1.1 MVP 基础框架

### 1.1.1 前提

首先需要解决以下问题：

> `MVP`中把Layout布局和`Activity`等组件作为`Viewer`层，增加了`Presenter`，`Presenter`层与`Model`层进行业务的交互，完成后再与`Viewer`层交互,进行回调来刷新UI。这样一来，业务逻辑的工作都交给了`Presenter`中进行，使得`Viewer`层与`Model`层的耦合度降低，`Viewer`中的工作也进行了简化。但是在实际项目中，随着逻辑的复杂度越来越大，`Viewer`（如`Activity`）臃肿的缺点仍然体现出来了，因为`Activity`中还是充满了大量与`Viewer`层无关的代码，比如各种事件的处理派发，就如`MVC`中的那样`Viewer`层和`Controller`代码耦合在一起无法自拔。

转自我之前的博客（**<http://www.cnblogs.com/tiantianbyconan/p/5036289.html>**）中第二阶段所引发的问题。

解决的方法之一在上述文章中也有提到 —— 加入`Controller`层来分担`Viewer`的职责。

### 1.1.2 Contract

根据以上的解决方案，首先考虑到`Viewer`直接交互的对象可能是`Presenter`（原来的方式），也有可能是`Controller`。

- 如果直接交互的对象是`Presenter`，由于`Presenter`中可能会进行很多同步、异步操作来调用`Model`层的代码，并且会回调到UI来进行UI的更新，所以，我们需要在`Viewer`层对象销毁时能够停止`Presenter`中执行的任务，或者执行完成后拦截UI的相关回调。因此，`Presenter`中应该绑定`Viewer`对象的生命周期（至少`Viewer`销毁的生命周期是需要关心的）

- 如果直接交互的对象是`Controller`，由于`Controller`中会承担`Viewer`中的事件回调并派发的职责（比如，ListView item 的点击回调和点击之后对相应的逻辑进行派发、或者`Viewer`生命周期方法回调后的处理），所以`Controller`层也是需要绑定`Viewer`对象的生命周期的。

这里，使用`Viewer`生命周期回调进行抽象：

```java
public interface OnViewerDestroyListener {
    void onViewerDestroy();
}

public interface OnViewerLifecycleListener extends OnViewerDestroyListener {
    void onViewerResume();
    void onViewerPause();
}
```

`OnViewerDestroyListener`接口提供给需要关心`Viewer`层销毁时期的组件，如上，应该是`Presenter`所需要关心的。

`OnViewerLifecycleListener`接口提供给需要关心`Viewer`层生命周期回调的组件，可以根据项目需求增加更多的生命周期的方法，这里我们只关心`Viewer`的`resume`和`pause`。

### 1.1.3 Viewer层

#### 1.1.3.1 Viewer 抽象

`Viewer`层，也就是表现层，当然有相关常用的UI操作，比如显示一个`toast`、显示/取消一个加载进度条等等。除此之外，由于`Viewer`层可能会直接与`Presenter`或者`Controller`层交互，所以应该还提供对这两者的绑定操作，所以如下：

```java
public interface Viewer {

    Viewer bind(OnViewerLifecycleListener onViewerLifecycleListener);

    Viewer bind(OnViewerDestroyListener onViewerDestroyListener);

    Context context();

    void showToast(String message);

    void showToast(int resStringId);

    void showLoadingDialog(String message);

    void showLoadingDialog(int resStringId);

    void cancelLoadingDialog();

}
```

如上代码，两个`bind()`方法就是用于跟`Presenter`/`Controller`的绑定。

#### 1.1.3.2 Viewer 委托实现

又因为，在Android中`Viewer`层对象可能是`Activity`、`Fragment`、`View`（包括`ViewGroup`），甚至还有自己实现的组件，当然实现的方式一般不外乎上面这几种。所以我们需要使用统一的`Activity`、`Fragment`、`View`，每个都需要实现`Viewer`接口。为了复用相关代码，这里提供默认的委托实现`ViewerDelegate`：

```java
public class ViewerDelegate implements Viewer, OnViewerLifecycleListener {
    private Context mContext;

    public ViewerDelegate(Context context) {
        mContext = context;
    }

    private List<OnViewerDestroyListener> mOnViewerDestroyListeners;

    private List<OnViewerLifecycleListener> mOnViewerLifecycleListeners;

    private Toast toast;
    private ProgressDialog loadingDialog;

    @Override
    public Viewer bind(OnViewerLifecycleListener onViewerLifecycleListener) {
        if (null == mOnViewerLifecycleListeners) {
            mOnViewerLifecycleListeners = new ArrayList<>();
            mOnViewerLifecycleListeners.add(onViewerLifecycleListener);
        } else {
            if (!mOnViewerLifecycleListeners.contains(onViewerLifecycleListener)) {
                mOnViewerLifecycleListeners.add(onViewerLifecycleListener);
            }
        }
        return this;
    }

    @Override
    public Viewer bind(OnViewerDestroyListener onViewerDestroyListener) {
        if (null == mOnViewerDestroyListeners) {
            mOnViewerDestroyListeners = new ArrayList<>();
            mOnViewerDestroyListeners.add(onViewerDestroyListener);
        } else {
            if (!mOnViewerDestroyListeners.contains(onViewerDestroyListener)) {
                mOnViewerDestroyListeners.add(onViewerDestroyListener);
            }
        }
        return this;
    }

    @Override
    public Context context() {
        return mContext;
    }

    @Override
    public void showToast(String message) {
        if (!checkViewer()) {
            return;
        }
        if (null == toast) {
            toast = Toast.makeText(mContext, "", Toast.LENGTH_SHORT);
            toast.setGravity(Gravity.CENTER, 0, 0);
        }
        toast.setText(message);
        toast.show();
    }

    @Override
    public void showToast(int resStringId) {
        if (!checkViewer()) {
            return;
        }
        showToast(mContext.getString(resStringId));
    }

    @Override
    public void showLoadingDialog(String message) {
        if (!checkViewer()) {
            return;
        }

        if (null == loadingDialog) {
            loadingDialog = new ProgressDialog(mContext);
            loadingDialog.setCanceledOnTouchOutside(false);
        }
        loadingDialog.setMessage(message);
        loadingDialog.show();
    }

    @Override
    public void showLoadingDialog(int resStringId) {
        if (!checkViewer()) {
            return;
        }
        showLoadingDialog(mContext.getString(resStringId));
    }

    @Override
    public void cancelLoadingDialog() {
        if (!checkViewer()) {
            return;
        }
        if (null != loadingDialog) {
            loadingDialog.cancel();
        }
    }

    public boolean checkViewer() {
        return null != mContext;
    }

    @Override
    public void onViewerResume() {
        if (null != mOnViewerLifecycleListeners) {
            for (OnViewerLifecycleListener oll : mOnViewerLifecycleListeners) {
                oll.onViewerResume();
            }
        }
    }

    @Override
    public void onViewerPause() {
        if (null != mOnViewerLifecycleListeners) {
            for (OnViewerLifecycleListener oll : mOnViewerLifecycleListeners) {
                oll.onViewerPause();
            }
        }
    }

    @Override
    public void onViewerDestroy() {
        if (null != mOnViewerLifecycleListeners) {
            for (OnViewerLifecycleListener oll : mOnViewerLifecycleListeners) {
                oll.onViewerDestroy();
            }
        }
        if (null != mOnViewerDestroyListeners) {
            for (OnViewerDestroyListener odl : mOnViewerDestroyListeners) {
                odl.onViewerDestroy();
            }
        }
        mContext = null;
        mOnViewerDestroyListeners = null;
        mOnViewerLifecycleListeners = null;
    }
}
```

如上代码：

- 它提供了默认基本的`toast`、和显示/隐藏加载进度条的方法。

- 它实现了两个重载`bind()`方法，并把需要回调的`OnViewerLifecycleListener`和`OnViewerDestroyListener`对应保存在`mOnViewerDestroyListeners`和`mOnViewerLifecycleListeners`中。

- 它实现了`OnViewerLifecycleListener`接口，在回调方法中回调到每个`mOnViewerDestroyListeners`和`mOnViewerLifecycleListeners`。

`mOnViewerDestroyListeners`：Viewer destroy 时的回调，一般情况下只会有Presenter一个对象，但是由于一个Viewer是可以有多个Presenter的,所以可能会维护一个Presenter列表，还有可能是其他需要关心 Viewer destroy 的组件

`mOnViewerLifecycleListeners`：Viewer 简单的生命周期监听对象，一般情况下只有一个Controller一个对象，但是一个Viewer并不限制只有一个Controller对象,所以可能会维护一个Controller列表，还有可能是其他关心 Viewer 简单生命周期的组件

#### 1.1.3.3 真实 Viewer 实现

然后在真实的`Viewer`中（这里以`Activity`为例，其他`Fragment`/`View`等也是一样），首先，应该实现`Viewer`接口，并且应该维护一个委托对象`mViewerDelegate`，在实现的`Viewer`方法中使用`mViewerDelegate`的具体实现。

```java
public class BaseActivity extends AppCompatActivity implements Viewer{

	private ViewerDelegate mViewerDelegate;

	@Override
    protected void onCreate(Bundle savedInstanceState) {
    	super.onCreate(savedInstanceState);
    	// ...
    	mViewerDelegate = new ViewerDelegate(this);
    }

    @Override
    protected void onResume() {
        mViewerDelegate.onViewerResume();
        super.onResume();
    }

    @Override
    protected void onPause() {
        mViewerDelegate.onViewerPause();
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        mViewerDelegate.onViewerDestroy();
        super.onDestroy();
    }

    @Override
    public Viewer bind(OnViewerDestroyListener onViewerDestroyListener) {
        mViewerDelegate.bind(onViewerDestroyListener);
        return this;
    }

    @Override
    public Viewer bind(OnViewerLifecycleListener onViewerLifecycleListener) {
        mViewerDelegate.bind(onViewerLifecycleListener);
        return this;
    }

    @Override
    public Context context() {
        return mViewerDelegate.context();
    }

    @Override
    public void showToast(String message) {
        mViewerDelegate.showToast(message);
    }

    @Override
    public void showToast(int resStringId) {
        mViewerDelegate.showToast(resStringId);
    }

    @Override
    public void showLoadingDialog(String message) {
        mViewerDelegate.showLoadingDialog(message);
    }

    @Override
    public void showLoadingDialog(int resStringId) {
        mViewerDelegate.showLoadingDialog(resStringId);
    }

    @Override
    public void cancelLoadingDialog() {
        mViewerDelegate.cancelLoadingDialog();
    }
}
```

如上，`BaseActivity`构建完成。

**在具体真实的`Viewer`实现中，包含的方法应该都是类似`onXxxYyyZzz()`的回调方法，并且这些回调方法应该只进行UI操作，比如`onLoadMessage(List<Message> message)`方法在加载完`Message`数据后回调该方法来进行UI的更新。**

在项目中使用时，应该使用依赖注入来把`Controller`对象注入到`Viewer`中（这个后面会提到）。

```java
@RInject
IBuyingRequestPostSucceedController controller;

@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    // ...
    BuyingRequestPostSucceedView_Rapier
            .create()
            .inject(module, this);

    controller.bind(this);
}
```

使用`RInject`通过`BuyingRequestPostSucceedView_Rapier`扩展类来进行注入`Controller`对象，然后调用`Controller`的`bind`方法进行生命周期的绑定。

### 1.1.4 Controller 层

#### 1.1.4.1 Controller 抽象

前面讲过，`Controller`是需要关心`Viewer`生命周期的，所以需要实现`OnViewerLifecycleListener`接口。

```java
public interface Controller extends OnViewerLifecycleListener {
    void bind(Viewer bindViewer);
}
```

又提供一个`bind()`方法来进行对自身进行绑定到对应的`Viewer`上面。

#### 1.1.4.2 Controller 实现

调用`Viewer`层的`bind()`方法来进行绑定，对生命周期进行空实现。

```java
public class BaseController implements Controller {
	public void bind(Viewer bindViewer) {
        bindViewer.bind(this);
    }
    @Override
    public void onViewerResume() {
        // empty
    }

    @Override
    public void onViewerPause() {
        // empty
    }

    @Override
    public void onViewerDestroy() {
        // empty
    }
}
```

该`bind()`方法除了用于绑定`Viewer`之外，还可以让子类重写用于做为Controller的初始化方法,但是注意重写的时候必须要调用`super.bind()`。

**具体`Controller`实现中，应该只包含类似`onXxxYyyZzz()`的回调方法，并且这些回调方法应该都是各种事件回调，比如`onClick()`用于View点击事件的回调，`onItemClick()`表示AdapterView item点击事件的回调。**

### 1.1.5 Presenter 层

#### 1.1.5.1 Presenter 抽象

> `Presenter`层，作为沟通 `View` 和 `Model` 的桥梁，它从 `Model` 层检索数据后，返回给 `View` 层，它也可以决定与 `View` 层的交互操作。

前面讲到过，`View`也是与`Presenter`直接交互的，Presenter中可能会进行很多同步、异步操作来调用Model层的代码，并且会回调到UI来进行UI的更新，所以，我们需要在Viewer层对象销毁时能够停止Presenter中执行的任务，或者执行完成后拦截UI的相关回调。

因此：

- `Presenter` 中应该也有`bind()`方法来进行与`Viewer`层的生命周期的绑定
- `Presenter` 中应该提供一个方法`closeAllTask()`来终止或拦截掉UI相关的异步任务。

如下：

```java
public interface Presenter extends OnViewerDestroyListener {
    void bind(Viewer bindViewer);
    void closeAllTask();
}
```

#### 1.1.5.2 Presenter RxJava 抽象

因为项目技术需求，需要实现对`RxJava`的支持，因此，这里对`Presenter`进行相关的扩展，提供两个方法以便于`Presenter`对任务的扩展。

```java
public interface RxPresenter extends Presenter {
    void goSubscription(Subscription subscription);
    void removeSubscription(Subscription subscription);
}
```

`goSubscription()`方法主要用处是，订阅时缓存该订阅对象到`Presenter`中，便于管理（怎么管理，下面会讲到）。

`removeSubscription()`方法可以从`Presenter`中管理的订阅缓存中移除掉该订阅。

#### 1.1.5.3 Presenter RxJava 实现

在Presenter RxJava 实现（`RxBasePresenter`）中，我们使用`WeakHashMap`来构建一个弱引用的`Set`，用它来缓存所有订阅。在调用`goSubscription()`方法中，把对应的`Subscription`加入到`Set`中，在`removeSubscription()`方法中，把对应的`Subscription`从`Set`中移除掉。

```java
public class RxBasePresenter implements RxPresenter {
    private static final String TAG = RxBasePresenter.class.getSimpleName();

    private final Set<Subscription> subscriptions = Collections.newSetFromMap(new WeakHashMap<Subscription, Boolean>());

    @Override
    public void closeAllTask() {
        synchronized (subscriptions) {
            Iterator iter = this.subscriptions.iterator();
            while (iter.hasNext()) {
                Subscription subscription = (Subscription) iter.next();
                XLog.i(TAG, "closeAllTask[subscriptions]: " + subscription);
                if (null != subscription && !subscription.isUnsubscribed()) {
                    subscription.unsubscribe();
                }
                iter.remove();
            }
        }
    }

    @Override
    public void goSubscription(Subscription subscription) {
        synchronized (subscriptions) {
            this.subscriptions.add(subscription);
        }
    }

    @Override
    public void removeSubscription(Subscription subscription) {
        synchronized (subscriptions) {
            XLog.i(TAG, "removeSubscription: " + subscription);
            if (null != subscription && !subscription.isUnsubscribed()) {
                subscription.unsubscribe();
            }
            this.subscriptions.remove(subscription);
        }
    }

    @Override
    public void bind(Viewer bindViewer) {
        bindViewer.bind(this);
    }

    @Override
    public void onViewerDestroy() {
        closeAllTask();
    }
}
```

如上代码，在`onViewerDestroy()`回调时（因为跟`Viewer`生命周期进行了绑定），会调用`closeAllTask`把所有缓存中的`Subscription`取消订阅。

> **注意**：因为缓存中使用了弱引用，所以上面的`removeSubscription`不需要再去手动调用，在订阅completed后，gc自然会回收掉没有强引用指向的`Subscription`对象。

#### 1.1.5.4 Presenter 具体实现

在`Presenter`具体的实现中，同样依赖注入各种来自`Model`层的`Interactor/Api`（网络、数据库、文件等等），然后订阅这些对象返回的`Observable`，然后进行订阅，并调用`goSubscription()`缓存`Subscription`：

```java
public class BuyingRequestPostSucceedPresenter extends RxBasePresenter implements IBuyingRequestPostSucceedPresenter {
	private IBuyingRequestPostSucceedView viewer;
	@RInject
    ApiSearcher apiSearcher;

    public BuyingRequestPostSucceedPresenter(IBuyingRequestPostSucceedView viewer, BuyingRequestPostSucceedPresenterModule module) {
        this.viewer = viewer;
        // inject
        BuyingRequestPostSucceedPresenter_Rapier
                .create()
                .inject(module, this);
    }

    @Override
    public void loadSomeThing(final String foo, final String bar) {
        goSubscription(
                apiSearcher.searcherSomeThing(foo, bar)
                        .compose(TransformerBridge.<OceanServerResponse<SomeThing>>subscribeOnNet())
                        .map(new Func1<OceanServerResponse<SomeThing>, SomeThing>() {
                            @Override
                            public SomeThing call(OceanServerResponse<SomeThing> response) {
                                return response.getBody();
                            }
                        })
                        .compose(TransformerBridge.<SomeThing>observableOnMain())
                        .subscribe(new Subscriber<SomeThing>() {

                            @Override
                            public void onError(Throwable e) {
                                XLog.e(TAG, "", e);
                            }

                            @Override
                            public void onNext(SomeThing someThing) {
                                XLog.d(TAG, "XLog onNext...");
                                viewer.onLoadSomeThing(someThing);
                            }

                            @Override
                            public void onCompleted() {
                            }

                        })
        );
	}
    // ... 
}
```

### 1.1.6 Model 层

暂不讨论。

## 1.2 针对 MVP 进行依赖注入

上面提到，`Viewer`、`Controller`和`Presenter`中都使用了`RInject`注解来进行依赖的注入。

这里并没有使用其他第三方实现的`DI`框架，比如`Dagger/Dagger2`等，而是自己实现的[Rapier](https://github.com/wangjiegulu/Rapier)，它的原理与`Dagger2`类似，会在编译时期生成一些扩展扩展类来简化代码，比如前面的`BuyingRequestPostSucceedView_Rapier`、`BuyingRequestPostSucceedPresenter_Rapier`、`BuyingRequestPostSucceedController_Rapier`等。它也支持`Named`、`Lazy`等功能，但是它比`Dagger2`更加轻量，`Module`的使用方式更加简单，更加倾向于对`Module`的复用，更强的可控性，但是由于这次的重构主要是基于在兼容旧版本的情况下使用，暂时没有加上`Scope`的支持。

之后再针对这个`Rapier`库进行详细讨论。

## 1.3 针对 MVP 进行单元测试

这里主要还是讨论针对`Viewer`和`Presenter`的单元测试。

### 1.3.1 针对 Viewer 进行单元测试

针对`Viewer`进行单元测试，这里不涉及任何业务相关的逻辑，而且，`Viewer`层的测试都是UI相关，必须要Android环境，所以需要在手机或者模拟器安装一个`test` apk，然后进行测试。

为了不被`Viewer`中的`Controller`和`Presenter`的逻辑所干扰，我们必须要mock掉`Viewer`中的`Controller`和`Presenter`对象，又因为`Controller`对象是通过依赖注入的方式提供的，也就是来自`Rapier`中的`Module`，所以，我们只需要mock掉`Viewer`对应的`module`。

### 1.3.1.1 如果 Viewer 是 View

如果`Viewer`层是由`View`实现的，比如继承`FrameLayout`。这个时候，测试时，就必须要放在一个`Activity`中测试（`Fragment`也一样，也必须依赖于`Activity`），所以我们应该有一个专门用于测试`View/Fragment`的`Activity` —— `TestContainerActivity`，如下：

```java
public class TestContainerActivity extends BaseActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
}
```

记得在`AndroidManifest.xml`中注册。

前面说过，我们需要mock掉`Module`。

如果`Viewer`是`View`，mock掉`Module`就非常容易了，只要在`View`中提供一个传入mock的`Module`的构造方法即可，如下：

```java
@VisibleForTesting
public BuyingRequestPostSucceedView(Context context, BuyingRequestPostSucceedModule module) {
	super(context);
	// inject
	BuyingRequestPostSucceedView_Rapier
	        .create()
	        .inject(module, this);
}
```

如上代码，这里为测试专门提供了一个构造方法来进行对`Module`的mock，之后的测试如下：

```java
BuyingRequestPostSucceedView requestPostSucceedView;

@Rule
public ActivityTestRule<TestContainerActivity> mActivityTestRule = new ActivityTestRule<TestContainerActivity>(TestContainerActivity.class) {

        @Override
        protected void afterActivityLaunched() {
            super.afterActivityLaunched();
            final TestContainerActivity activity = getActivity();
            logger("afterActivityLaunched");
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    BuyingRequestPostSucceedModule module = mock(BuyingRequestPostSucceedModule.class);
                    when(module.pickController()).thenReturn(mock(IBuyingRequestPostSucceedController.class));
                    requestPostSucceedView = new BuyingRequestPostSucceedView(activity, module);
                    activity.setContentView(requestPostSucceedView);
                }
            });

        }
    };

    @Test
    public void testOnLoadSomeThings() {
        final SomeThings products = mock(SomeThings.class);
        ArrayList<SomeThing> list = mock(ArrayList.class);

        SomeThing product = mock(SomeThing.class);

        when(list.get(anyInt())).thenReturn(product);
        products.productList = list;

        TestContainerActivity activity = mActivityTestRule.getActivity();

        when(list.size()).thenReturn(1);
        when(list.isEmpty()).thenReturn(false);
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                requestPostSucceedView.onLoadSomeThing(products);
            }
        });
        onView(withId(R.id.id_tips_you_may_also_like_tv)).check(matches(isDisplayed()));
        // ...
    }
```

如上代码，在`TestContainerActivity`启动后，构造一个mock了`Module`的待测试`View`，并增加到`Activity`的content view中。

### 1.3.1.2 如果 Viewer 是 Activity

如果`Viewer`是`Activity`，由于它本来就是Activity，所以它不需要借助`TestContainerActivity`来测试；mock `module`时就不能使用构造方法的方式了，因为我们是不能直接对`Activity`进行实例化的，那应该怎么办呢？

一般情况下，我们会在调用`onCreate`方法的时候去进行对依赖的注入，也就是调用`XxxYyyZzz_Rapier`扩展类，而且，如果这个`Activity`需要在一启动就去进行一些数据请求，我们要拦截掉这个请求，因为这个请求返回的数据可能会对我们的UI测试造成干扰，所以我们需要在`onCreate`在被调用之前把`module` mock掉。

首先看test support 中的 `ActivityTestRule`这个类，它提供了以下几个方法：

- `getActivityIntent()`：这个方法只能在Intent中增加携带的参数，我们要mock的是整个`Module`，无法序列化，所以也无法通过这个传入。

- `beforeActivityLaunched()`：这个方法回调时，`Activity`实例还没有生成，所以无法拿到`Activity`实例，并进行`Module`的替换。

- `afterActivityFinished()`：这个方法就更不可能了-.-

- `afterActivityLaunched()`：这个方法看它的源码（无关代码已省略）：

```java
public T launchActivity(@Nullable Intent startIntent) {
        // ...

        beforeActivityLaunched();
        // The following cast is correct because the activity we're creating is of the same type as
        // the one passed in
        mActivity = mActivityClass.cast(mInstrumentation.startActivitySync(startIntent));

        mInstrumentation.waitForIdleSync();

        afterActivityLaunched();
        return mActivity;
    }
```

如上代码，`afterActivityLaunched()`方法是在真正启动`Activity`（`mInstrumentation.startActivitySync(startIntent)`）后调用的。但是显然这个方法是同步的，之后再进入源码，来查看启动的流程，整个流程有些复杂我就不赘述了，可以查看我以前写的分析启动流程的博客（**<http://www.cnblogs.com/tiantianbyconan/p/5017056.html>**），最后会调用`mInstrumentation.callActivityOnCreate(...)`。

但是因为测试时，启动`Activity`的过程也是同步的，所以显然这个方法是在`onCreate()`被调用后才会被回调的，所以，这个方法也不行。

既然貌似已经找到了mock的正确位置，那就继续分析下去：

这里的`mInstrumentation`是哪个`Instrumentation`实例呢？

我们回到`ActivityTestRule`中：

```java
public ActivityTestRule(Class<T> activityClass, boolean initialTouchMode,
            boolean launchActivity) {
        mActivityClass = activityClass;
        mInitialTouchMode = initialTouchMode;
        mLaunchActivity = launchActivity;
        mInstrumentation = InstrumentationRegistry.getInstrumentation();
    }
```

继续进入`InstrumentationRegistry.getInstrumentation()`：

```java
public static Instrumentation getInstrumentation() {
        Instrumentation instance = sInstrumentationRef.get();
        if (null == instance) {
            throw new IllegalStateException("No instrumentation registered! "
                    + "Must run under a registering instrumentation.");
        }
        return instance;
}
```

继续查找`sInstrumentationRef`是在哪里`set`进去的：

```java
public static void registerInstance(Instrumentation instrumentation, Bundle arguments) {
        sInstrumentationRef.set(instrumentation);
        sArguments.set(new Bundle(arguments));
}
```

继续查找调用，终于在`MonitoringInstrumentation`中找到：

```java
@Override
public void onCreate(Bundle arguments) {
    // ...
    InstrumentationRegistry.registerInstance(this, arguments);
    // ...
}
```

所以，测试使用的`MonitoringInstrumentation`，然后进入`MonitoringInstrumentation`的`callActivityOnCreate()`方法：

```java
@Override
public void callActivityOnCreate(Activity activity, Bundle bundle) {
        mLifecycleMonitor.signalLifecycleChange(Stage.PRE_ON_CREATE, activity);
        super.callActivityOnCreate(activity, bundle);
        mLifecycleMonitor.signalLifecycleChange(Stage.CREATED, activity);
    }
```

既然我们需要在`Activity`真正执行`onCreate()`方法时拦截掉，那如上代码，只要关心`signalLifecycleChange()`方法，发现了`ActivityLifecycleCallback`的回调：

```java
public void signalLifecycleChange(Stage stage, Activity activity) {
	// ...
	Iterator<WeakReference<ActivityLifecycleCallback>> refIter = mCallbacks.iterator();
    while (refIter.hasNext()) {
        ActivityLifecycleCallback callback = refIter.next().get();
        if (null == callback) {
            refIter.remove();
        } else {
        		// ...
        		callback.onActivityLifecycleChanged(activity, stage);
        		// ...
        }
}
```

所以，问题解决了，我们只要添加一个`Activity`生命周期回调就搞定了，代码如下：

```java
ActivityLifecycleMonitorRegistry.getInstance().addLifecycleCallback(new ActivityLifecycleCallback() {
    @Override
    public void onActivityLifecycleChanged(Activity activity, Stage stage) {
        logger("onActivityLifecycleChanged, activity" + activity + ", stage: " + stage);
        if(activity instanceof SomethingActivity && Stage.PRE_ON_CREATE == stage){
            logger("onActivityLifecycleChanged, got it!!!");
            ((SomethingActivity)activity).setModule(mock(SomethingModule.class));
        }
    }
});
```

至此，`Activity`的 mock `module`成功了。

### 1.3.2 针对 Presenter 进行单元测试

#### 1.3.2.1 测试与 Android SDK 分离

`Presenter` 的单元测试与 `Viewer` 不一样，在`Presenter`中不应该有`Android SDK`相关存在，所有的`Inteactor/Api`等都是与`Android`解耦的。显然更加不能有`TextView`等存在。正是因为这个，使得它可以基于PC上的JVM来进行单元测试，也就是说，`Presenter`测试不需要Android环境，省去了安装到手机或者模拟器的步骤。

怎么去避免`Anroid`相关的SDK在`Presenter`中存在？

的确有极个别的SDK很难避免，比如`Log`。

##### 1.3.2.1.1 使用 XLog 与 Log 分离

所以，我们需要一个`XLog`：

```java
public class XLog {
    private static IXLog delegate;
    private static boolean DEBUG = true;

    public static void setDebug(boolean debug) {
        XLog.DEBUG = debug;
    }

    public static void setDelegate(IXLog delegate) {
        XLog.delegate = delegate;
    }

    public static void v(String tag, String msg) {
        if (DEBUG && null != delegate) {
            delegate.v(tag, msg);
        }
    }

    public static void v(String tag, String msg, Throwable tr) {
        if (DEBUG && null != delegate) {
            delegate.v(tag, msg, tr);
        }
    }

    public static void d(String tag, String msg) {
        if (DEBUG && null != delegate) {
            delegate.d(tag, msg);
        }
    }
	// ...
```

在Android环境中使用的策略：

```java
XLog.setDelegate(new XLogDef());
```

其中`XLogDef`类中的实现为原生Androd SDK的Log实现。

在测试环境中使用的策略：

```java
logDelegateSpy = Mockito.spy(new XLogJavaTest());
XLog.setDelegate(logDelegateSpy);
```

其中`XLogJavaTest`使用的是纯Java的`System.out.println()`

#### 1.3.2.2 异步操作同步化

因为`Presenter`中会有很多的异步任务存在，但是在细粒度的单元测试中，没有异步任务存在的必要性，相应反而增加了测试复杂度。所以，我们应该把所有异步任务切换成同步操作。

调度的切换使用的是`RxJava`，所以所有切换到主线程也是使用了`Android SDK`。这里也要采用策略进行处理。

首先定义了几种不同的`ScheduleType`：

```java
public class SchedulerType {
    public static final int MAIN = 0x3783;
    public static final int NET = 0x8739;
    public static final int DB = 0x1385;
    // ...
}
```

在`Schedule`选择器中根据`ScheduleType`进行对应类型的实现：

```java
SchedulerSelector schedulerSelector = SchedulerSelector.get();

schedulerSelector.putScheduler(SchedulerType.MAIN, new SchedulerSelector.SchedulerCreation<Scheduler>() {
    @Override
    public Scheduler create() {
        return AndroidSchedulers.mainThread();
    }
});

schedulerSelector.putScheduler(SchedulerType.NET, new SchedulerSelector.SchedulerCreation<Scheduler>() {
    @Override
    public Scheduler create() {
        return Schedulers.from(THREAD_POOL_EXECUTOR_NETWORK);
    }
});

schedulerSelector.putScheduler(SchedulerType.DB, new SchedulerSelector.SchedulerCreation<Scheduler>() {
    @Override
    public Scheduler create() {
        return Schedulers.from(THREAD_POOL_EXECUTOR_DATABASE);
    }
});
// ...
```

当测试时，对调度选择器中的不同类型的实现进行如下替换：

```java
SchedulerSelector.get().putScheduler(SchedulerType.NET, new SchedulerSelector.SchedulerCreation<Scheduler>() {
    @Override
    public Scheduler create() {
        return Schedulers.immediate();
    }
});

SchedulerSelector.get().putScheduler(SchedulerType.MAIN, new SchedulerSelector.SchedulerCreation<Scheduler>() {
    @Override
    public Scheduler create() {
        return Schedulers.immediate();
    }
});
```

把所有调度都改成当前线程执行即可。

最后`Presenter`测试几个范例：

```java
@Mock
    AccountContract.IAccountViewer viewer;

    @Mock
    UserInteractor userInteractor;

    AccountPresenter presenter;

    @Before
    public void setUp() throws Exception {
        MockitoAnnotations.initMocks(this);
        presenter = new AccountPresenter(viewer);
        presenter.userInteractor = userInteractor;
    }

    @Test
    public void requestEditUserInfo() throws Exception {
        // case 1, succeed
        reset(viewer);
        resetLog();

        when(userInteractor.requestEditUserInfo(any(User.class))).thenReturn(Observable.just(anyBoolean()));
        presenter.requestEditUserInfo(new User());

        verifyOnce(viewer).onRequestEditUserInfo();

        // case 2, null
        reset(viewer);
        resetLog();
        when(userInteractor.requestEditUserInfo(any(User.class))).thenReturn(Observable.just(null));
        presenter.requestEditUserInfo(new User());

        verifyOnce(viewer).onRequestEditUserInfo();

        // case 3, error
        assertFailedAndError(() -> userInteractor.requestEditUserInfo(any(User.class)), () -> presenter.requestEditUserInfo(new User()));
    }
```

```java
public class SBuyingRequestPostSucceedViewPresenterTest extends BaseJavaTest {

    @Mock
    public IBuyingRequestPostSucceedView viewer;
    @Mock
    public BuyingRequestPostSucceedPresenterModule module;
    @Mock
    public ApiSearcher apiSearcher;
    public IBuyingRequestPostSucceedPresenter presenter;

    @Before
    public void setUp() {
        MockitoAnnotations.initMocks(this);

        when(module.pickApiSearcher()).thenReturn(apiSearcher);
        presenter = new BuyingRequestPostSucceedPresenter(viewer, module);
    }

    @Test
    public void testLoadSomethingSuccess() throws TimeoutException {
        // Mock success observable
        when(apiSearcher.searcherSomething(anyString(), anyString(), anyString()))
                .thenReturn(Observable.create(new Observable.OnSubscribe<OceanServerResponse<Something>>() {
                    @Override
                    public void call(Subscriber<? super OceanServerResponse<Something>> subscriber) {
                        try {
                            OceanServerResponse<Something> oceanServerResponse = mock(OceanServerResponse.class);
                            when(oceanServerResponse.getBody(any(Class.class))).thenReturn(mock(Something.class));
                            subscriber.onNext(oceanServerResponse);
                            subscriber.onCompleted();
                        } catch (Throwable throwable) {
                            subscriber.onError(throwable);
                        }
                    }I
                }));

        final ExecuteStuff executeStuff = new ExecuteStuff();
        Answer succeedAnswer = new Answer() {
            @Override
            public Object answer(InvocationOnMock invocationOnMock) throws Throwable {
                loggerMockAnswer(invocationOnMock);
                executeStuff.setSucceed(true);
                return null;
            }
        };

        doAnswer(succeedAnswer).when(viewer).onLoadSomething(Matchers.any(Something.class));

        presenter.loadSomething("whatever", "whatever");

        logger("loadSomething result: " + executeStuff.isSucceed());
        Assert.assertTrue("testLoadSomethingSuccess result true", executeStuff.isSucceed());

    }

    @Test
    public void testLoadSomethingFailed() throws TimeoutException {
        // Mock error observable
        when(apiSearcher.searcherRFQInterestedProductsSuggestion(anyString(), anyString(), anyString()))
                .thenReturn(Observable.<OceanServerResponse<Something>>error(new RuntimeException("mock error observable")));

        final ExecuteStuff executeStuff = new ExecuteStuff();
        Answer failedAnswer = new Answer() {
            @Override
            public Object answer(InvocationOnMock invocationOnMock) throws Throwable {
                loggerMockAnswer(invocationOnMock);
                executeStuff.setSucceed(false);
                return null;
            }
        };
        doAnswerWhenLogError(failedAnswer);

        presenter.loadSomething("whatever", "whatever");

        logger("testLoadSomethingFailed result: " + executeStuff.isSucceed());
        Assert.assertFalse("testLoadSomethingFailed result false", executeStuff.isSucceed());

    }

}
```

