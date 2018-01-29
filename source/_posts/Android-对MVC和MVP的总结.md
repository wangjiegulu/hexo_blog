---
title: '[Android]对MVC和MVP的总结'
tags: []
date: 2015-12-10 15:48:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5036289.html>
**</font>

经历过的客户端的架构分为这么几个阶段：

### 第一阶段
使用传统的MVC，其中的View，对应的是各种Layout布局文件，但是这些布局文件中并不像Web端那样强大，能做的事情非常有限；Controller对应的是Activity，而Activity中却又具有操作UI的功能，我们在实际的项目中也会有很多UI操作在这一层，也做了很多View中应该做的事情，当然Controller中也包含Controller应该做的事情，比如各种事件的派发回调，而且在一层中我们会根据事件再去调用Model层操作数据，所以这种MVC的方式在实际项目中，Activity所在的Controller是非常重的，各层次之间的耦合情况也比较严重，不方便单元测试。

### 第二阶段
使用MVC的进化版——MVP，MVP中把Layout布局和Activity作为View层，增加了Presenter，Presenter层与Model层进行业务的交互，完成后再与View层交互（也就是Activity）进行回调来刷新UI。这样一来，所有业务逻辑的工作都交给了Presenter中进行，使得View层与Model层的耦合度降低，Activity中的工作也进行了简化。但是在实际项目中，随着逻辑的复杂度越来越大，Activity臃肿的缺点仍然体现出来了，因为Activity中还是充满了大量与View层无关的代码，比如各种事件的处理派发，就如MVC中的那样View层和Controller代码耦合在一起无法自拔。

### 第三阶段
也是现在正在使用的架构，针对第二阶段进行优化，为了把View再次简化，想到两种方式：

1\. 通过使用一个Presenter代理的方式，在PresenterProxy中处理各种事件机制，View中维护一个PresenterProxy对象当然Presenter中同样实现了真实对象Presnter所实现的接口，这样，我们同样在View中通过代理对象调用真实对象的代码，结构图如下：
![](https://raw.githubusercontent.com/wangjiegulu/wangjiegulu.github.com/master/images/mvp/MVP_PresenterProxy.jpg)

2\. 为MVP增加一层专门用于处理各种的事件派发Controller层，Controller的作用仅仅是处理事件并根据事件通过维护的Presenter对象派发到对应的业务中，也就是说View层只有一个Controller的对象，View层不会主动去调用Presenter层，但是Controller层和Presenter都可能会回调到View层来刷新UI，所以层次结构就变成了如下：
![](https://raw.githubusercontent.com/wangjiegulu/wangjiegulu.github.com/master/images/mvp/MVP_Controller.jpg)

现在使用的是第2种方式，使用Controller来进行对Activity中事件代码的分离，下面使用登录的例子来讲解，其中代码使用的并不是Java，而是Kotlin。

在演示之前，先来看下实现MVP的几个基础的接口和类（[点这里查看AKBMVPExt.kt](https://github.com/wangjiegulu/AndroidKotlinBucket/blob/master/library/src/main/kotlin/com/wangjie/androidkotlinbucket/library/AKBMVPExt.kt)）：

```kotlin
/**
 * MVP的View层，UI相关，Activity需要实现该interface
 * 它会包含一个Presenter的引用，当有事件发生（比如按钮点击后），会调用Presenter层的方法
 */
public interface KViewer {
    //    val onClickListener: ((view: View) -> Unit)?
    val context: Context?;

    fun toast(message: String, duration: Int = Toast.LENGTH_SHORT) {
        context?.lets { Toast.makeText(this, message, duration).show() }
    }

    fun dialog(title: String? = null,
               message: String?,
               okText: String? = "OK",
               cancelText: String? = null,
               positiveClickListener: ((DialogInterface, Int) -> Unit)? = null,
               negativeClickListener: ((DialogInterface, Int) -> Unit)? = null
    ) {
        context?.lets {
            AlertDialog.Builder(this)
                    .setTitle(title)
                    .setMessage(message)
                    .setPositiveButton(okText, positiveClickListener)
                    .setNegativeButton(cancelText, negativeClickListener)
                    .show()
        }
    }

    fun showLoading(message: String) {
        Log.w(KViewer::class.java.simpleName, "loadingDialog should impl by subclass")
    }

    fun cancelLoading() {
        Log.w(KViewer::class.java.simpleName, "cancelLoadingDialog should impl by subclass")
    }

    fun <T : View> findView(resId: Int): T;

}
```

所有`View`层的Activity、Fragment或者View都要实现`KViewer`接口，该接口中有一个属性和一个函数需要被子类的Activity实现：

- `context`属性：该属性需要被子类override，该属性用于一些接口公用的UI相关操作的方法，如`toast`、`dialog`、`cancelDialog`等。

- `fun <T : View> findView(resId: Int): T`函数：该函数需要被子类Activity、Fragment或者View实现，这个方法用于从当前View层中根据id获取到对应的View，该方法在Activity、Fragment或者View中并不一致。

当然所有的重写都可以在BaseActivity、BaseFragment、BaseFrameLayout等中重写，之后使用它们的子类即可。

```kotlin
/**
 * MVP的Presenter层，作为沟通View和Model的桥梁，它从Model层检索数据后，返回给View层，它也可以决定与View层的交互操作。
 * 它包含一个View层的引用和一个Model层的引用
 */
public open class KPresenter<V : KViewer>(var viewer: V) {

    open public fun closeAll() {
        Log.w(KViewer::class.java.simpleName, "closeAll in KPresenter should impl by subclass")
    }

}
```

`KPresenter`类是作为所有Presenter层的实现的基类的，它只有一个`closeAll`函数需要被重写，当Activity在被destory时，需要调用close函数停止到子线程的任务。

```kotlin
/**
 * Controller，用于派发View中的事件，它在根据不同的事件调用Presenter
 */
public abstract class KController<KV : KViewer, KP : KPresenter<*>>(val viewer: KV, presenterCreate: () -> KP) {
    protected val presenter: KP by lazy { presenterCreate() }

    private val viewCache: SparseArray<View> = SparseArray();

    /**
     * 注册事件
     */
    abstract fun bindEvents()

    public fun <T : View> getView(resId: Int): T {
        val view: View? = viewCache.get(resId)
        return view as T? ?: viewer.findView<T>(resId).apply {
            viewCache.put(resId, this)
        }
    }

    public fun closeAll() = presenter.closeAll()
}
```

同样`KController`是所有`Controller`类的基类，需要子类实现`bindEvents()`函数，在这个函数中，可以绑定各种View的事件。还提供了`getView()`方法来从Viewer中获取到对应的控件，并且会缓存找到的控件。

#### 一、创建`BaseActivity`并实现`KViewer`

```kotlin
open class BaseActivity : AppCompatActivity(), KViewer {
    override fun <T : View> findView(resId: Int): T = findViewById(resId) as T

    override val context: Context = this

    open val controller: KController<*, *>? = null

    private val loadingDialog: ProgressDialog by lazy { ProgressDialog(this) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 强制竖屏
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
    }

    override fun showLoading(message: String) {
        loadingDialog.setMessage(message)
        loadingDialog.show()
    }

    override fun cancelLoading() {
        if (loadingDialog.isShowing) {
            loadingDialog.cancel()
        }
    }

    override fun onDestroy() {
        controller?.closeAll()
        super.onDestroy()
    }
}
```

这里我重写了`KViewer`中的`findView()`函数，函数实现是通过`Activity::findViewById()`的方式。

又实现了`controller`属性，设置为null，这个`controller`还需要子类再来重写。

然后重写了`showLoading`和`cancelLoading`，在`onDestory`中通过`controller`调用`presenter`中的`closeAll`函数。

#### 二、实现`LoginActivity`

新建`LoginViewer`接口，继承`KViewer`，并定义各种逻辑回调：

```kotlin
interface LoginViewer : KViewer {
    fun onLogin()
}
```
里面所有的函数应该都是名字`onXXX`的函数，都是需要去操作UI的，这里定义的是一个`onLogin()`函数，表示登录成功后，我们现在是如果登录成功后，则跳转到主界面`MainActivity`。

然后创建`LoginActivity`，实现我们的`LoginViewer`：

```kotlin
class LoginActivity : BaseActivity(), LoginViewer {
    override val controller: LoginController by lazy { LoginController(this) }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        controller.bindEvents()
    }

    override fun onLogin() {
        toActivity<MainActivity> { }
        finish()
    }
}
```

这里我们首先重写父类中的`controller`属性，通过`lazy`懒初始化`LoginController`，然后在`onCreate`中调用`controller`的`bindEvents()`，这样，我们在`controller`中的`bindEvents()`函数中就可以对各种View进行事件的绑定，甚至包括自定义的Dialog、PopupWindow等组件的回调。

然后实现`onLogin`函数，在这个函数中进行界面的跳转。

#### 三、实现LoginController

创建`LoginController`，继承`KController`：

```kotlin
class LoginController(viewer: LoginViewer) : KController<LoginViewer, LoginPresenter>(viewer, { LoginPresenter(viewer) }),
        View.OnClickListener {

    override fun bindEvents() {
        getView<Button>(R.id.activity_login_submit_btn).setOnClickListener(this)
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.activity_login_submit_btn -> presenter.login(getView<EditText>(R.id.activity_login_username_et).text.toString(), getView<EditText>(R.id.activity_login_password_et).text.toString())

        }
    }

}
```

实现`KController`中的`bindEvents`函数，在`bindEvents`中我们通过`KController`中`getView()`函数获取到Id为`R.id.activity_login_submit_btn`的按钮，然后设置`OnClickListener`，在onClick回调方法中，`Controller`会根据事件派发到`Presenter`来进行真正的登录操作。

#### 四、实现Presenter

创建`Presenter`，继承`KPresenter`：

```kotlin
class LoginPresenter(viewer: LoginViewer) : KPresenter<LoginViewer>(viewer) {
    fun login(username: String, password: String) {
        viewer.showLoading(_resString(R.string.xr_hint_logging_in))

        HttpsUrl(HttpWebApi.System.LOGIN).rxRequest {
            it.posts(
                    "username" to username,
                    "password" to password
            )
        }
                .map {
                    _gson._fromJson<LoginHttpResponse>(it.body().string()) 
                }
                .observeOnMain()
                .doOnNextOrError { viewer.cancelLoading() }
                .subscribe ({
                    if (it.success) {
                        viewer.onLogin()
                    } else {
                        showHint(it.msg)
                    }
                }) {
                    Log.e("Login", "", it)
                    viewer.toast(_resString(R.string.xr_error_default))
                }
                .bindPresenter(this)
    }
}
```

编写`login()`函数，然后执行登录请求，登录成功后，通过`viewer`回调到`View`层的`onLogin()`函数。

如此一来，`View`层中只负责UI部分的工作，UI所产生的各种事件绑定、派发等职责放在`Controller`中，`Presenter`和`Model`还是与之前一样的职责。

关于`Presenter`的测试，只需mock一个`LoginViewer`实现类即可。

### 第四阶段：

MVVM，把`Presenter`改成`ViewModel`，它与`View`之间的交互可以使用`Data Binding`的方式双向进行，也就是说`View`和`ViewModel`任意一方的改变都会体现在另一方中，Google IO上提供的框架暂时还不成熟，只支持单向，所以暂时还没有在正式的项目中使用。

实质上MV*的思想都是一样的，解耦隔离视图（View）和模型（Model），在实际的应用中不需要给`MVC`、`MVP`和`MVVM`一个明确的界限，甚至可以把几者融合在一起。