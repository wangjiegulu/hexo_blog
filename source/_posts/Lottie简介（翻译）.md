---
title: Lottie简介（翻译）
tags: [lottie, animator, animation]
date: 2017-02-04 12:21:00
---

# Lottie简介（翻译）

> 原文：<https://medium.com/airbnb-engineering/introducing-lottie-4ff4a0afac0e#.mfnxbtt06>

> 新的向本地apps的构建动画的开源工具。

作者：[Brandon Withrow](http://github.com/buba447), [Gabridl Peal](https://twitter.com/gpeal8), [Leland Richardson](https://twitter.com/intelligibabble) 和 [Salih AbdulKarim](https://twitter.com/therealsalih?lang=en)

在以前，在Android，iOS和React Native app上面构建复杂的动画是困难和冗长的过程。你要么不得不为每个尺寸增加大量的图片文件，要么干脆编写数千行不可维护的代码。正因为如此，大多的apps并没有使用动画——尽管这是一个交流想法和创建引人注目的用户体验的强大的工具。一年前，我们就开始改变。

<!-- more -->

今天，我们很高兴来介绍我们的解决方案。[Lottie](http://airbnb.design/lottie/)是一个iOS，Android和React Native库，可以实时渲染After Effects动画，并且允许本地app像静态资源那样轻松地使用动画。Lottie使用名为[Bodymovin](https://github.com/bodymovin/bodymovin)的开源After Effects的扩展程序导出的JSON文件格式的动画数据。扩展程序与JavaScript player捆绑在一起，可以在web上渲染动画。自从2015年2月开始，Bodymovin的创建者，[Hernan Torrisi](https://twitter.com/airnanan)通过每月为插件添加和改进功能，打造了坚实的基础。我们的团队（[Brandon Withrow](http://github.com/buba447) 在 [iOS](https://github.com/airbnb/lottie-ios), [Gabriel Peal](https://twitter.com/gpeal8) 在 [Android](https://github.com/airbnb/lottie-android)，[Leland Richardson](https://twitter.com/intelligibabble) 在 [React Native](https://github.com/airbnb/lottie-react-native)，和 [我](http://www.salih.tv/) 在体验设计上）在Torrisi的非凡的工作之上开始我们的旅程。

![](https://github.com/airbnb/lottie-android/raw/master/gifs/Example1.gif)

## 轻松地构建一个丰富的动画

Lottie允许工程师构建一个丰富的动画，而没有艰苦地重写它们的开销。Nick Butcher's的[跳跃](https://medium.com/google-developers/animation-jump-through-861f4f5b3de4#.xlw1n2u2d)动画,Bartek Lipinski的[汉堡菜单](https://android.jlelse.eu/animatedvectordrawablecompat-3d9568727c53#.fmiujhcdj), 和Miroslaw Stanek 的[Twitter爱心](http://frogermcs.github.io/twitters-like-animation-in-android-alternative/), 演示它们是多么困难和耗时，它可以用scratch重建动画。使用Lottie，挖掘参考框架，猜测持续时间，手动创建贝赛尔曲线，并重新制作只有一个GIF作为参考的动画将是过去了。现在工程师可以准确地实现设计者的意图，究竟是怎么做的。为了证明它，我们重创建了它们的动画，然后在我们的每个例子中提供了After Effects和JSON文件。

我们的目标是尽可能多地支持After Effects的特性，而不只是简单的图标动画。我们创建了一些其他例子来展示库的灵活性，丰富性和深入的功能集。在例子app中，有用于各种不同种类的动画的源文件，包括基本线条艺术，基于字符的动画，以及具有多个角度和切割的动态logo动画。

![](https://github.com/airbnb/lottie-android/raw/master/gifs/Example2.gif)

我们已经开始在一些界面上使用我们自己的Lottie动画，包括应用内通知，全帧动画插图和在我们的审查流程中。我们计划以一种有趣而有用的方式大大增加我们对动画的使用。

![](https://github.com/airbnb/lottie-android/raw/master/gifs/Example3.gif)

## 灵活高效的解决方案

Airbnb是一个全球的公司，它支持数百万的顾客和主人，所有在多个平台上播放的灵活动画格式对我们来说是非常重要的。有一些与Lottie类似的库，如Marcus Eckert的[Squall](http://www.marcuseckert.com/squall/)和Facebook的[Keyframes](https://github.com/facebookincubator/Keyframes),但是我们的目标略有不同。Facebook选择了一小部分After Effects的特性进行了支持，因为它们主要集中在响应，但是我们想要尽可能多地支持。至于Squall，Airbnb的设计师组合Lottie来使用它，因为它有一个惊艳的After Effects预览app，这使得它成为我们工作流必要的一部分。然而，它只支持iOS，我们的工程师团队需要一个跨平台的解决方案。

Lottie还在其API中内置了几个功能，使它更多样化和高效。它支持通过网络加载JSON文件，这在A/B测试是非常有用。它还有一个额外的缓存机制，所以频繁使用的动画，比如一个愿望清单的爱心，可以每次加载一个缓存的副本。Lottie动画可以通过使用动画进度功能的手势驱动，并且动画速度可以通过简单改变值来控制。iOS甚至支持在运行时增加额外的本地UI到一个动画中，这可以用于复杂的动画过渡。

除了我们迄今为止的增加所有After Effects特性和API之外，我们还有许多未来的想法。它们包括映射视图到Lottie动画中，使用Lottie控制视图过渡，支持[Battle Axe 的 RubberHose](http://www.battleaxe.co/rubberhose/)，渐变，类型和图像的支持。最难的部分是下一个特性支持应该选择哪一个。

![](https://cdn-images-1.medium.com/max/2000/1*bZbrDT3NGJDw8LoIy3L3mQ.png)

## 构建社区

作为开源发布一些东西，并不只是把它拿出来做为公共使用。它是一个人跟人之间连接和交流的桥梁。随着我们更接近通过GitHub向设计师和工程师发布Lottie，我们也想确保与动画人员进行连接。

我们受到了创建的[9 Squares](http://9-squares.tumblr.com/)，[Motion Corpse](https://motioncorpse.tumblr.com/)和[Animography](https://animography.net/products/mobilo)的启发。所有这三个都聚集了来自世界各地的人，在公共动画项目上合作，他们可能永远不会一起工作。这些项目花费了几个月的工作和很多的组织，各自团队的争论，但是它们无疑对整个动画社区提供了巨大的价值。Motion Corpse 和 Animography 公开分享了After Effects的源文件，它们提供了大量人们怎么工作的深刻的见解。

在他们的合作领导下，我们接触了所有这三个团队，为我们的示例app贡献了动画。我们包括了一个来自 Motion Corpse J.R Canest 创建的动画，来自9 Squares 项目的 Al Boardman 的square之一，和一个使用Animography的Mobilo动画字体的键盘动画，其中有二十多个艺术家的工作。我们希望这些动画社区与强大的工程社区的合并将产生一些特别的东西。

![](https://github.com/airbnb/lottie-android/raw/master/gifs/Community%202_3.gif)

> 从左到右：Motion Corpse 的 Jr.canest，来自 9 Squares 的 AI Boardman，Animography 的 Mobilo 字体动画

我们想听到你怎么去使用Lottie——不论你是一个设计师，动画师，还是工程师。请随时直接通过 lottie@airbnb.com 带着你的想法，反馈，见解与我们联系。我们很高兴看到当他们开始以我们从未想象的方式使用Lottie时，世界各地的社区将会做些什么。

下载 [Bodymovin](https://github.com/bodymovin/bodymovin)，Lottie [iOS](https://github.com/airbnb/lottie-ios)，[Android](https://github.com/airbnb/lottie-android) 和 [React Native](https://github.com/airbnb/lottie-react-native)

最初发布于 [airbnb.design/lottie/](http://airbnb.design/lottie/)

