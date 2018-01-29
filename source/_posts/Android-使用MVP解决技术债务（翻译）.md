---
title: '[Android]使用MVP解决技术债务（翻译）'
tags: []
date: 2016-09-21 15:03:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5892671.html>
**</font>

# 使用MVP解决技术债务

> 原文：<https://medium.com/picnic-engineering/tackling-technical-debt-with-mvp-67e805ed5103#.couu0d5i0>

免责申明：这篇博客并不是讲关于怎么使用MVP的方式（上帝知道关于这些已经太多了）去写Android代码。而仅仅是我的个人经验，关于怎么转换我们的表现层到MVP架构来帮助我们解决一些累积的技术债务，而且在这个过程中也会帮助我们的app从一个原型转变成一个更具维护性的产品。

任何从事Android工作足够久、项目足够大的开发者最有可能达到一个点，他们面对他们的代码库，觉得应该有更好的实现方案。我们在Picnic也是一样，在Android app开发开始后大约八个月，我们到达了的那一刻，就在我们向公众发布第一个版本的时候。

这一刻正好是在我们app推出的时候这也并不意外。直到那时，我们以一个非常快的速度在前进，不断敲打我们的键盘，从零开始构建一个完整的产品，尝试新的东西，结合用户反馈到我们的app中，在每天的基础上增加和丢弃特性。

为了跟上公司的速度我们砍掉了这里那里的边边角角。这样的工作对我们来说很好，这也是我们能够在这么短的时间内构建这个app的原因之一。但是正如预期那样，最后这些决定的影响开始以技术债务的形式显示出来。幸运的是这些技术债务是在数月之内建立的，在app的性能和稳定性上面并没有任何真正的影响。反而我们是在其它领域开始注意到它：

- 新功能迭代时间的增加。
- 新入职的开发者遇到困难
- 它被证实难以实现自动化测试
- 整体功能的复杂性在增加

我们已经有了一个很好的想法和一个易于理解的架构，用于网络层、错误处理和app内部模块通信。但是像大多数Android开发者，我们会对把太多的逻辑放进Activity和Fragment中会产生内疚。

旁注：这是Android开发者的共同的问题，而作为开发者需要在黑暗中摸索，因为Google对这个话题保持沉默。我们从它们那里得到的第一个（算是）官方回复是来自Android团队的一个开发者在 [Google+ post](https://plus.google.com/+DianneHackborn/posts/FXCCYxepsDU)，说明我们应该把核心的Android API作为一个‘系统框架’，意味着他们会带我们手把手地到达Android核心的组件（Activity, BroadcastReceiver, Service 和 ContentProvider）。之后我们做什么都是看我们自己了。而且就在最近，Google终于提供了一系列的例子用来解决关于怎么构建一个Android app的共同问题，它着重于MVP。尽管只是beta，但是它可以在这里查看：[Android Architecture Blueprints](https://github.com/googlesamples/android-architecture)。

无论如何，这其实是一件好事，因为这意味着我们可以自由地去实验任何我们喜欢的方式，而不是被强制在一个平台遵循一个特定的模式。

现在讲回我们的故事… 除非你处在Android开发世界的远古时期，你应该会注意到表现层架构是现在的热门。关于最好的方式是什么，每个人甚至连他妈妈似乎都有自己的观点。工作中标准的Android方式（类似MVC），到MVP，到通过data-binding的MVVM，所有的方式都沿用了 Uncle Bob 的 *clean architecture*。每一种方式围绕赞成或者反对的意见都有一些有趣的讨论，但是有一件事我们要明确知道，那就是我们应该避免喝Kool-Aid*（译者注：这里是比喻，表示非常愚昧地接受信奉某种观点或者思想）*和期望其中一种是银色子弹*（译者注：这里是比喻为具有极端有效性的解决方法）*然后永远解决所有问题。

当在考虑怎么去重构我们的表现层时，我们已经有近一年的代码库的积累，我们很清楚我们的缺陷在哪里，然后我们需要使用一个新的实现（以上主要表示一些能够解决我们的技术债务的点）来达到我们的目标。我们在虚拟的项目中试玩了一些，体验了各种方法的不同之处，然后最终决定使用MVP。从它的核心来说，MVP本身仅仅是一个概念，而Android框架，根据设计，并不强制任何模式，我们可以自由地选择实际的实现细节。

在Android团队中，首先我们是不过度工程的信徒，让代码随着时间的推移自然地发展，而不是过早地在试图为自己不可预知的未来做准备的抽象之上增加抽象。正因为这个原因，我们选择另一风味的MVP，使得可以最低限度地保持我们的抽象层次。在代码级别，这意味着有一个单独的接口来表示View。所有其它的组件都是具体的类。你可能会问自己，怎么会只有View使用接口？考虑到我们迫切的需要，这是真正受益于这样的接口的唯一的组件，因为我们实际上有不同的具体的Views来共享相同的接口。所以在我们的案例中，这里的一个接口将被允许我们去重用Presenters。一些MVP实现建议给所有组件（M，V和P）设置接口。尽管这样会工作得很完美，但是我们在较早的阶段并不提倡，因为添加之后的成本是代码可读性和维护性，尤其是当我们考虑到新入职对MVP陌生的初级开发者的时候，好处超过面向接口编程的方式。

相比其他，MVP实现是非常标准的。View（Activity，Fragment或者一个自定义View）负责创造和维护Presenter，而Presenter处理各种业务相关的逻辑（数据获取，存储，格式化等等），然后根据需要通过更新UI回调到View。在我们的案例中，数据层已经是相当模块化了，构造用于表示数据模型的POJOs，以及一个预先存在的控制层用于处理网络通信。

这是一个非常标准的MVP设置，也因为它很简单，我们可以在几周的时间内替换几乎我们的所有的UI代码。因为我们已经存在独立的数据层来处理所有与后端的API交互，所以真正需要重构的只是Views和Presenters的交互。

在重构的过程中，我们也学习了一些可能会派得上用场的东西：

- **生命周期：**因为Presenter是View创建的，我们需要确保完全地理解View的生命周期，特别是因为它将最有可能去处理状态更新和异步数据。举个例子，每一个Presenter应该在View destroyed的情况下有一个取消异步任务的方式，或者应该在用户暂停或者恢复视图事件时重置到原始状态等等。最后但同样重要的是，当View已经被销毁，试图从Presenter去更新View元素，始终需要注意可怕的NPEs。

- **保持Views尽可能地愚蠢：**我们的Views应该不再包含任何业务相关的逻辑。它应该只包含Android框架inflate和设置View的这些最低限度的东西。任何用户交互应该派发到Presenter。根据经验，如果你的views有任何其它方法去更新UI元素或者响应用户触发的事件，那么你可能应该去检查它们的实现。

- **保持Presenter尽可能地纯粹：**这一点，我们的意思时你应该尽可能地避免有Android相关的代码在你的presenters中。为这些组件编写纯粹的单元测试，而不需要使用其它如Robolectric等测试框架，这明显地得到了简化。这明显说起来比做起来容易得多，因为你终归会在某些地方遇到这种情况，举个例子，你将需要有一个Context的引用用来比如数据加载、访问strings文件等等。

## 结论

那么，说了那么多，最终的结论是什么呢？总的来说，我很高兴使用了MVP。它一定程度上帮我们解决了我们快速开发所累积的技术债务，然后，我们准备了更多来针对第二阶段的开发。

一些值得一提的事情：

- **测试数：**在重构之前，测试的数量用两只手都可以数得过来。这是一个巨大的任务来针对包含了所有逻辑如执行数据解析、格式化、网络请求、错误处理和管理自己的生命周期的Activity编写测试。仅思考如果在这些条件下编写测试就足以让我们去寻找其它的方式了。一旦转换我们的第一份代码到MVP，对此编写测试就变得碎片化了。通过一个清晰的合同明确什么View能够处理，我们可以把自己的代码与Android UI框架隔离开，然后仅仅测试实际调用的是否是正确的方法，并给出每个测试场景。现在实际的业务相关逻辑被放置在Presenters中，因为它们绝大多数都不需要有Android OS相关的认知（或者小部分相关的可以被mocked），我们也可以针对它们编写非常有效率的单元测试，因此，在过去几个月里，我们的测试用例从原来的10增加到900，而且还在增长中。

- **可预见性：**这个是有一点软度量，但是非常强大的一点。针对UI，我们选择并坚持一个通用的模式，我可以在代码库中获得可预见的好处。这意味着，无论是哪种开发者眼里的UI元素（Activity，Dialog，Fragment等等），如果理解其中一个怎么工作，那也就能理解所有怎么工作。打开一个就算不是你写的文件也不再会遇到让你觉得惊喜的东西了。明确规定职责，每一单个的UI组件都遵循相同的明确的模式。让新入职的新开发者从第一天起就是高效的，这是非常宝贵的。

我们别忘记MVP并不只是用于表现层，但是作为前端开发人员，这里花费了我们太多的时间。所以努力去寻找一个解决方案来给我们带来更好的可预见性和在新的开发者加入我们的时候也能让我们快速迭代是值得的。经过全面的考虑，我们可以有把握地说MVP是可以帮助我们达到这个目标的一个重要的里程碑。

P.S. 如果你仍然渴望看到一些源代码，这里有一个我们MVP实现‘忘记密码’用例的剥离下来的版本，展示MVP组件与用户的交互，用户点击‘重置密码’按钮进入他们的邮件地址（为保持代码的简洁，Android模版代码已经移除）：

```java
// BasePresenter.java (Base class for all our Presenters)
public abstract class BasePresenter<V> {

  private WeakReference<V> mView;

  public void bindView(@NonNull V view) {
    mView = new WeakReference<>(view);
  }

  public void unbindView() {
    mView = null;
  }

  public V getView() {
    if (mView == null) {
      return null;
    } else {
      return mView.get();
    }
  }

  protected final boolean isViewAttached() {
    return mView != null && mView.get() != null;
  }
}

// IForgotPasswordView.java (view interface)
public interface IForgotPasswordView {
  void showLoading();
  void hideLoading();
  void setEmailText(String email);
  void showEmailNotValidError();
  void showPasswordRequestOk(String message);
  void showPasswordRequestFail();
}

// ForgotPasswordFragment.java (view implementation)
public class ForgotPasswordFragment implements IForgotPasswordView,
        View.OnClickListener {

  // Triggered by the user clicking a button
  public void onResetPasswordClick() {
    String email = mEmailEditText.getText().toString();

    // Forward all logic to the Presenter
    mPresenter.requestPasswordChange(email);
  }

}

// ForgotPasswordPresenter.java
public class ForgotPasswordPresenter extends BasePresenter<IForgotPasswordView> {

  public void requestPasswordChange(String email) {
    if (!Utils.isEmailValid(email)) {

      // Make sure the view is still alive before trying to access it
      if(isViewAttached()) {
        getView().showEmailNotValidError();    
      }
    } else {
      requestPasswordChangeAsync(email);
    }
  }

  private void requestPasswordChangeAsync(String email) {

    // Update the view's UI elements
    if(isViewAttached()) {
      getView().hideKeyboard();
      getView().showLoading();

      // Call our API (results are posted back on an EventBus)
      api.forgotPassword(email);
    }

  }

  // Subscription to the event bus
  @Subscribe
  public void onEvent(final Event event) {

    if (isViewAttached()) {

      // Update the view's UI elements
      getView().hideLoading();

      switch (event.getType()) {
        case FORGOT_PASSWORD_OK:
          getView().showPasswordRequestOk((String) event.getData());
          break;
        case FORGOT_PASSWORD_FAILED:
          getView().showPasswordRequestFail();
          break;
        }
      }
  }
}
```