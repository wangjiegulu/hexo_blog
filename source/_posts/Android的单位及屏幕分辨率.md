---
title: Android的单位及屏幕分辨率
tags: []
date: 2012-03-08 17:01:00
---

一、常用的单位：相对单位主要有：px、sp、dp

绝对单位主要有：pt、in、mm

二、单位应用总结：一般用相对单位，而不是绝对单位

1、字体的大小一般使用SP，用此单位的字体能够根据用户设置字体的大小而自动缩放

2、空间等相对距离一般使用dp（dip）,随着密度变化，对应的像素数量也变化，但并没有直接的相对比例的变化。

3、px与实际像素有关，及与密度有关！dp和sp和实际像素没有关系，对于一定分辨率但不同密度的屏幕，px单位的应用可能会导致长度的相对比例的变化。

三、密度与分辨率：

密度值表示每英寸有多少个显示点，与分辨率是两个概念。

其屏幕密度标准是：HVGA屏density=160；QVGA屏density=120；WVGA屏density=240；WQVGA屏density=120

具体的应用运算关系：假设分辨率是 x*y， 密度为 d， 屏幕实际大小为 a*b那么关系为 x*y = d * a * b (约等于)

不同density下屏幕分辨率信息，以480dip*800dip的 WVGA(density=240)为例density=120时 屏幕实际分辨率为240px*400px （两个点对应一个分辨率）

四、对比总结：

1、在相同密度（即同一实体屏幕）不同分辨率的情况下，与实体密度无关的相对单位sp和dp显示正常

2、在相同分辨率不同密度的情况下，因为一般情况下，都用的标准密度，所以分析的意义不是很大

**其他资料：**
px：是屏幕的像素点
in：英寸
mm：毫米
pt：磅，1/72 英寸
dp：一个基于density的抽象单位，如果一个160dpi的屏幕，1dp=1px
dip：等同于dp
sp：同dp相似，但还会根据用户的字体大小偏好来缩放。
建议使用sp作为文本的单位，其它用dip
针对dip和px 的关系，做以下概述：
HVGA屏density=160；QVGA屏density=120；WVGA屏density=240；WQVGA屏density=120
density值表示每英寸有多少个显示点，与分辨率是两个概念。
不同density下屏幕分辨率信息，以480dip*800dip的 WVGA(density=240)为例

density=120时 屏幕实际分辨率为240px*400px （两个点对应一个分辨率）
状态栏和标题栏高各19px或者25dip
横屏是屏幕宽度400px 或者800dip,工作区域高度211px或者480dip
竖屏时屏幕宽度240px或者480dip,工作区域高度381px或者775dip

density=160时 屏幕实际分辨率为320px*533px （3个点对应两个分辨率）
状态栏和标题栏高个25px或者25dip
横屏是屏幕宽度533px 或者800dip,工作区域高度295px或者480dip
竖屏时屏幕宽度320px或者480dip,工作区域高度508px或者775dip

density=240时 屏幕实际分辨率为480px*800px （一个点对于一个分辨率）
状态栏和标题栏高个38px或者25dip
横屏是屏幕宽度800px 或者800dip,工作区域高度442px或者480dip
竖屏时屏幕宽度480px或者480dip,工作区域高度762px或者775dip

apk的资源包中，当屏幕density=240时使用hdpi 标签的资源
当屏幕density=160时，使用mdpi标签的资源
当屏幕density=120时，使用ldpi标签的资源。
不加任何标签的资源是各种分辨率情况下共用的。
布局时尽量使用单位dip，少使用px

&nbsp;

下面是几种不同单位的相互转换.

public&nbsp;static&nbsp;int&nbsp;dip2px(Context context, float dipValue){
final float scale&nbsp;=&nbsp;context.getResources().getDisplayMetrics().density;
return (int)(dipValue&nbsp;*&nbsp;scale&nbsp;+&nbsp;0.5f);
}
public&nbsp;static&nbsp;int&nbsp;px2dip(Context context, float pxValue){
final float scale&nbsp;=&nbsp;context.getResource().getDisplayMetrics().density;
return (int)(pxValue&nbsp;/&nbsp;scale&nbsp;+&nbsp;0.5f);
}
public&nbsp;static&nbsp;int&nbsp;dip2px(Context context, float dipValue){
final float scale&nbsp;=&nbsp;context.getResources().getDisplayMetrics().density;
return (int)(dipValue&nbsp;*&nbsp;scale&nbsp;+&nbsp;0.5f);
}
public&nbsp;static&nbsp;int&nbsp;px2dip(Context context, float pxValue){
final float scale&nbsp;=&nbsp;context.getResource().getDisplayMetrics().density;
return (int)(pxValue&nbsp;/&nbsp;scale&nbsp;+&nbsp;0.5f);
}

下面说下如何获取分辨率:

在一个Activity的onCreate方法中，写入如下代码：
DisplayMetrics metric = new DisplayMetrics();
getWindowManager().getDefaultDisplay().getMetrics(metric);
int width = metric.widthPixels;&nbsp;&nbsp;// 屏幕宽度（像素）
int height = metric.heightPixels;&nbsp;&nbsp;// 屏幕高度（像素）
float density&nbsp;= metric.density;&nbsp;&nbsp;// 屏幕密度（0.75 / 1.0 / 1.5）
int densityDpi = metric.densityDpi;&nbsp;&nbsp;// 屏幕密度DPI（120 / 160 / 240）
这还是挺简单的, 可是你有没有在800*480的机器上试过, 是不是得到的宽度是533 ? 因为android刚开始时默认的density是1.0 , 此时你可以再manifest.xml中加入

1.uses-sdk节点,&nbsp;&lt;uses-sdk android:minSdkVersion="4" /&gt; , 表示不sdk1.6以下的机器不能安装你的apk了.

2.supports-screens 节点.

&lt;supports-screens
android:smallScreens="true"
android:normalScreens="true"
android:largeScreens="true"
android:resizeable="true"
android:anyDensity="true" /&gt;