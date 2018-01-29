---
title: 直接拿来用！十大Material Design开源项目
tags: []
date: 2014-11-23 11:51:00
---

来自：[http://www.csdn.net/article/2014-11-21/2822753-material-design-libs/1](http://www.csdn.net/article/2014-11-21/2822753-material-design-libs/1)

介于拟物和扁平之间的Material Design自面世以来，便引起了很多人的关注与思考，就此产生的讨论也不绝于耳。本文详细介绍了在Android开发者圈子里颇受青睐的十个Material Design开源项目，从示例、FAB、菜单、动画、Ripple到Dialog，看被称为&ldquo;Google第一次在设计语言和规范上超越了Apple&rdquo;的Material Design是如何逐渐成为App的一种全新设计标准。

**1.&nbsp;[MaterialDesignLibrary](https://github.com/navasmdc/MaterialDesignLibrary)**

在众多新晋库中，MaterialDesignLibrary可以说是颇受开发者瞩目的一个控件效果库，能够让开发者在Android 2.2系统上使用Android 5.0才支持的控件效果，比如扁平、矩形、浮动按钮，复选框以及各式各样的进度指示器等。

![](http://cms.csdnimg.cn/article/201411/21/546e9b100445a_middle.jpg)

除上述之外，MaterialDesignLibrary还拥有SnackBar、Dialog、Color selector组件，可非常便捷地对应用界面进行设置。

进度指示器样式效果设置：&nbsp;

<div class="dp-highlighter bg_xml">
<div class="bar">
<div class="tools">
<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">com.gc.materialdesign.views.ProgressBarCircularIndetermininate  
                </span><span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/progressBarCircularIndetermininate"</span><span style="color: #ff0000;">  
                android:layout_width</span><span style="color: #0000ff;">="32dp"</span><span style="color: #ff0000;">  
                android:layout_height</span><span style="color: #0000ff;">="32dp"</span><span style="color: #ff0000;">  
                android:background</span><span style="color: #0000ff;">="#1E88E5"</span> <span style="color: #0000ff;">/&gt;</span></pre>
</div>

&nbsp;

</div>
</div>
</div>

Dialog：

<div class="cnblogs_code">
<pre>Dialog dialog = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Dialog(Context context,String title, String message);
dialog.show();</span></pre>
</div>

&nbsp;

**2.&nbsp;[RippleEffect](https://github.com/traex/RippleEffect)**

由来自法兰西的Robin Chutaux开发的RippleEffect基于MIT许可协议开源，能够在Android API 9+上实现Material Design，为开发者提供了一种极为简易的方式来创建带有可扩展视图的header视图，并且允许最大程度上的自定制。

![](http://cms.csdnimg.cn/article/201411/21/546ea09e7c452_middle.jpg)

用法（在XML文件中声明一个RippleView）：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">com.andexert.library.RippleView
  </span><span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/more"</span><span style="color: #ff0000;">
  android:layout_width</span><span style="color: #0000ff;">="?android:actionBarSize"</span><span style="color: #ff0000;">
  android:layout_height</span><span style="color: #0000ff;">="?android:actionBarSize"</span><span style="color: #ff0000;">
  android:layout_toLeftOf</span><span style="color: #0000ff;">="@+id/more2"</span><span style="color: #ff0000;">
  android:layout_margin</span><span style="color: #0000ff;">="5dp"</span><span style="color: #ff0000;">
  ripple:rv_centered</span><span style="color: #0000ff;">="true"</span><span style="color: #0000ff;">&gt;</span>

  <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">ImageView
    </span><span style="color: #ff0000;">android:layout_width</span><span style="color: #0000ff;">="?android:actionBarSize"</span><span style="color: #ff0000;">
    android:layout_height</span><span style="color: #0000ff;">="?android:actionBarSize"</span><span style="color: #ff0000;">
    android:src</span><span style="color: #0000ff;">="@android:drawable/ic_menu_edit"</span><span style="color: #ff0000;">
    android:layout_centerInParent</span><span style="color: #0000ff;">="true"</span><span style="color: #ff0000;">
    android:padding</span><span style="color: #0000ff;">="10dp"</span><span style="color: #ff0000;">
    android:background</span><span style="color: #0000ff;">="@android:color/holo_blue_dark"</span><span style="color: #0000ff;">/&gt;</span>

<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">com.andexert.library.RippleView</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

&nbsp;

**3.&nbsp;[MaterialEditText](https://github.com/rengwuxian/MaterialEditText)**

随着Material Design的到来，AppCompat v21也为开发者提供了Material Design的控件外观支持，其中就包括EditText，但却并不好用，没有设置颜色的API，也没有任何Google Material Design Spec中提到的特性。于是，来自国内的开发者&ldquo;扔物线&rdquo;开发了MaterialEditText库，直接继承EditText，无需修改Java文件即能实现自定义控件颜色。

![](http://cms.csdnimg.cn/article/201411/21/546ea1168a50c_middle.jpg)

自定义Base Color：

<div class="cnblogs_code">
<pre>app:baseColor="#0056d3"</pre>
</div>

![](http://cms.csdnimg.cn/article/201411/21/546ea26d93a02_middle.jpg)

&nbsp;

自定义Error Color：

<div class="cnblogs_code">
<pre><span style="color: #000000;">app:maxCharacters="10"
app:errorColor="#ddaa00"</span></pre>
</div>

<span style="line-height: 1.5;">&nbsp;</span>

![](http://cms.csdnimg.cn/article/201411/21/546ea27b0fc23_middle.jpg)

**4.&nbsp;[Android-LollipopShowcase](https://github.com/mikepenz/Android-LollipopShowcase)**

Android-LollipopShowcase是由来自奥地利的移动、后端及Web开发者Mike Penz所开发的演示应用，集中演示了新Material Design中所有的UI效果，以及Android Lollipop中其他非常酷炫的特性元素，比如Toolbar、RecyclerView、ActionBarDrawerToggle、Floating Action Button（FAB）、Android Compat Theme等。

![](http://cms.csdnimg.cn/article/201411/21/546ed8a896530_middle.jpg)

**5.&nbsp;[MaterialList](https://github.com/dexafree/MaterialList)**

MaterialList是一个能够帮助所有Android开发者获取谷歌UI设计规范中新增的CardView（卡片视图）的开源库，支持Android 2.3+系统。作为ListView的扩展，MaterialList可以接收、存储卡片列表，并根据它们的Android风格和设计模式进行展示。此外，开发者还可以创建专属于自己的卡片布局，并轻松将其添加到CardList中。

![](http://cms.csdnimg.cn/article/201411/21/546ede74f3033_middle.jpg)

使用过程代码，在布局中声明MaterialListView：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RelativeLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span><span style="color: #ff0000;">
    android:layout_width</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
    android:layout_height</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
    android:paddingLeft</span><span style="color: #0000ff;">="@dimen/activity_horizontal_margin"</span><span style="color: #ff0000;">
    android:paddingRight</span><span style="color: #0000ff;">="@dimen/activity_horizontal_margin"</span><span style="color: #ff0000;">
    android:paddingTop</span><span style="color: #0000ff;">="@dimen/activity_vertical_margin"</span><span style="color: #ff0000;">
    android:paddingBottom</span><span style="color: #0000ff;">="@dimen/activity_vertical_margin"</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">com.dexafree.materiallistviewexample.view.MaterialListView
        </span><span style="color: #ff0000;">android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
        android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
        android:id</span><span style="color: #0000ff;">="@+id/material_listview"</span><span style="color: #0000ff;">/&gt;</span>

<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">RelativeLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

&nbsp;

**6.&nbsp;[android-floating-action-button](https://github.com/futuresimple/android-floating-action-button)**

Floating Action Button（FAB）是众多专家大牛针对Material Design讨论比较细化的一个点，通过圆形元素与分割线、卡片、各种Bar的直线形成鲜明对比，并使用色彩设定中鲜艳的辅色，带来更具突破性的视觉效果。也正因如此，在Github上，有着许多与FAB相关的开源项目，基于Material Design规范的开源Android浮动Action Button控件android-floating-action-button便是其中之一。

![](http://cms.csdnimg.cn/article/201411/21/546efe7e3a855_middle.jpg?_=33895)&nbsp;![](http://cms.csdnimg.cn/article/201411/21/546efe84a5da6.jpg)

其主要特性如下：

&nbsp;

*   支持常规56dp和最小40dp的按钮；
*   支持自定义正常、Press状态以及可拖拽图标的按钮背景颜色；
*   AddFloatingActionButton类能够让开发者非常方便地直接在代码中写入加号图标；
*   FloatingActionsMenu类支持展开/折叠显示动作。

&nbsp;

**7.&nbsp;[android-ui](https://github.com/markushi/android-ui)**

android-ui是Android UI组件类库，支持Android API 14+，包含了ActionView、RevealColorView等UI组件。其中，ActionView可使Action动作显示动画效果，而RevealColorView则带来了Android 5.0中的圆形显示/隐藏动画体验。

![](http://cms.csdnimg.cn/article/201411/21/546f0a7681186.jpg)

**8.&nbsp;[Material Menu](https://github.com/balysv/material-menu)**

Material Menu为开发者带来了非常酷炫的Android菜单、返回、删除以及检查按钮变形，完全控制动画，并为开发者提供了两种MaterialMenuDrawable包装。

![](http://cms.csdnimg.cn/article/201411/21/546f0b8672e44.jpg)

自定义颜色等操作：

<div class="cnblogs_code">
<pre><span style="color: #008000;">//</span><span style="color: #008000;"> change color</span>
MaterialMenu.setColor(<span style="color: #0000ff;">int</span><span style="color: #000000;"> color)

</span><span style="color: #008000;">//</span><span style="color: #008000;"> change transformation animation duration</span>
MaterialMenu.setTransformationDuration(<span style="color: #0000ff;">int</span><span style="color: #000000;"> duration)

</span><span style="color: #008000;">//</span><span style="color: #008000;"> change pressed animation duration</span>
MaterialMenu.setPressedDuration(<span style="color: #0000ff;">int</span><span style="color: #000000;"> duration)

</span><span style="color: #008000;">//</span><span style="color: #008000;"> change transformation interpolator</span>
<span style="color: #000000;">MaterialMenu.setInterpolator(Interpolator interpolator)

</span><span style="color: #008000;">//</span><span style="color: #008000;"> set RTL layout support</span>
MaterialMenu.setRTLEnabled(<span style="color: #0000ff;">boolean</span> enabled)</pre>
</div>

&nbsp;

&nbsp;

**9.&nbsp;[Android-ObservableScrollView](https://github.com/ksoichiro/Android-ObservableScrollView)**

Android-ObservableScrollView是一款用于在滚动视图中观测滚动事件的Android库。它能够轻而易举地与Android 5.0 Lollipop引进的工具栏（Toolbar）进行交互，还可以帮助开发者实现拥有Material Design应用视觉体验的界面外观，支持ListView、ScrollView、WebView、RecyclerView、GridView组件。

![](http://cms.csdnimg.cn/article/201411/21/546ef6d6abfcd.jpg)![](http://cms.csdnimg.cn/article/201411/21/546ef6e476b55.jpg)![](http://cms.csdnimg.cn/article/201411/21/546ef6eea211e.jpg)

交互代码回调：

<div class="cnblogs_code">
<pre><span style="color: #000000;">@Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onUpOrCancelMotionEvent(ScrollState scrollState) {
        ActionBar ab </span>=<span style="color: #000000;"> getSupportActionBar();
        </span><span style="color: #0000ff;">if</span> (scrollState ==<span style="color: #000000;"> ScrollState.UP) {
            </span><span style="color: #0000ff;">if</span><span style="color: #000000;"> (ab.isShowing()) {
                ab.hide();
            }
        } </span><span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span> (scrollState ==<span style="color: #000000;"> ScrollState.DOWN) {
            </span><span style="color: #0000ff;">if</span> (!<span style="color: #000000;">ab.isShowing()) {
                ab.show();
            }
        }
    }</span></pre>
</div>

&nbsp;

**10.&nbsp;[Material Design Icons](https://github.com/google/material-design-icons)**

最后，再来介绍一下Google Material Design规范的官方开源图标集Material Design Icons。良心Google开源了包括Material Design系统图标包在内的750个字形，涵盖动作、音视频、通信、内容、编辑器、文件、硬件、图像、地图、导航、通知、社交等各个方面，适用于Web、Android和iOS应用开发，绝对是开发者及设计师必备的资源。

![](http://cms.csdnimg.cn/article/201411/21/546ef31fa0f7e_middle.jpg)

图标格式主要包括：&nbsp;

*   SVG格式，24px和48px；
*   SVG和CSS Sprites；
*   适用于Web平台的1x、2x PNG格式图标；
*   适用于iOS的1x、2x、3x PNG图标；
*   所有图标的Hi-dpi版本（hdpi、mdpi、xhdpi、xxhdpi、xxxhdpi）。

&nbsp;