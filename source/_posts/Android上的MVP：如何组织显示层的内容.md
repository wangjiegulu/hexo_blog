---
title: Android上的MVP：如何组织显示层的内容
tags: [android, mvp, mvc, framework, best practices]
date: 2014-07-13 18:55:00
---

MVP（Model View Presenter）模式是著名的MVC（Model View Controller）模式的一个演化版本，目前它在Android应用开发中越来越重要了，大家也都在讨论关于MVP的理论，只是结构化的资料非常少。这就是我写这篇博客的原因，我想鼓励大家多参与讨论，然后把MVP模式运用在项目开发中。

### 什么是MVP？

MVP模式可以分离显示层和逻辑层，所以功能接口如何工作与功能的展示可以实现分离，MVP模式理想化地可以实现同一份逻辑代码搭配不同的显示界面。首先要澄清就是MVP不是一个结构化的模式，它只是负责显示层而已，任何时候都可以在自己的项目结构中使用MVP模式。

### 为什么要使用MVP？

我们知道在Android上逻辑接口和数据存取是紧耦合的，这个问题可以看看CursorAdapter这个例子，它既融合了适配器，同时也有显示的成分，而cursor很大程度上应该是数据数据存取层的。

对于一个可扩展、稳定的应用来说，我们需要定义各个分离层，毕竟，我们不知道以后还要加入什么逻辑，是从本地数据库检索数据？还是从远程的web Service中？

MVP模式可以让显示界面和数据分离，我们开发的应用可以分离至少三层，这样也可以进行独立测试。有了MVP我们就可以从Activity中分离大部分代码，而且不用单元测试可以对每个模块进行单独测试了。

### 怎么在Android上实现MVP？

说到这里，问题就有点复杂了。实现MVP的方式有很多种，每个人都可以根据自己的需求和自己喜欢的方式去修正MVP的实现方式，它可以随着Presenter的复杂程度变化。

在View中需不需要控制进度条？或者是在Presenter处理？还有，谁来决定Action Bar该显示什么操作？这是一个艰难的决定。这里我会展示我自己的做法，但是我希望本文成为一个讨论如何应用MVP的地方，因为目前为止还没有实现MVP的标准方式。

### Presenter

Presenter主要作为沟通View和Model的桥梁，它从Model层检索数据后，返回给View层，但是不想典型的MVC结构，因为它也可以决定与View层的交互操作。

### View

View通常来说是由Activity实现的（也许是Fragment，VIew，取决于app的整体结构），它会包含一个Presenter的引用，最理想的是Presenter由一个依赖注入管理器提供，比如[Dagger](http://square.github.io/dagger/)，不过如果不用注入器的话，就需要独立创建Presenter对象了。View要做的就只是在每次有接口调用的时候（比如按钮点击后）调用Presenter的方法。

### Model

对于一个结构化的APP来说，Model主要是通向主领域层或者逻辑层的通道，如果使用了[Uncle Bob clean architecture](http://blog.8thlight.com/uncle-bob/2012/08/13/the-clean-architecture.html)的话，Model就可能是一个实现了用例场景的交互工具，这也是我将要在另一篇文章中讨论的一个主题。现在，只要把它看做是给View提供数据的容器就对了。

### 一个例子

鉴于已经解释的太长了，本人写了一个例子[an MVP example on Github](https://github.com/antoniolg/androidmvp)，由一个登录界面组成，可以验证数据然后进入一个带有列表的主界面，数据来自Model，因为比较简单，所以本文就不讲代码了，但是如果读者觉得还是很难理解的话，我还可以再写一篇文章详细介绍。

### 总结

在Android上要分离接口和逻辑不容易实现，但是Model-View-Presenter模式可以更简单的防止在Activity中掺杂太多代码在大的项目中，组织好代码结构是最基本的要求，不然，代码的稳定和扩展就很困难了。

&nbsp;

原文链接：&nbsp;[antonioleiva](http://antonioleiva.com/mvp-android/)&nbsp;&nbsp;&nbsp;翻译：&nbsp;[伯乐在线&nbsp;](http://blog.jobbole.com/)-&nbsp;[chris](http://blog.jobbole.com/author/chris/)
译文链接：&nbsp;[http://blog.jobbole.com/71209/](http://blog.jobbole.com/71209/)

