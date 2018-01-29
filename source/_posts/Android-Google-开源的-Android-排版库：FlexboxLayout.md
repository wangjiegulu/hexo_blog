---
title: '[Android]Google 开源的 Android 排版库：FlexboxLayout'
tags: []
date: 2016-05-31 21:57:00
---

最近Google开源了一个项目叫「FlexboxLayout」。

## 1.什么是 Flexbox

简单来说 Flexbox 是属于web前端领域CSS的一种布局方案，是2009年W3C提出了一种新的布局方案，可以简便、完整、响应式地实现各种页面布局，并且 React Native 也是使用的 Flex 布局。

你可以简单的理解为 Flexbox 是CSS领域类似 Linearlayout 的一种布局，但是要比 Linearlayout 要强大的多。

## 2.什么是 FlexboxLayout？

刚才说了 Flexbox 是CSS领域的比较强大的一个布局，我们在 Android 开发中使用 Linearlayout + RelativeLayout 基本可以实现大部分复杂的布局，但是Google就想了，有没有类似 Flexbox 的一个布局呢？这使用起来一个布局就可以搞定各种复杂的情况了，于是 FlexboxLayout 就应运而生了。

所以 FlexboxLayout 是针对 Android 平台的，实现类似 Flexbox 布局方案的一个开源项目，开源地址：<https://github.com/google/flexbox-layout>

## 3.使用方式

使用方式很简单，只需要添加以下依赖：

```groovy
compile 'com.google.android:flexbox:0.1.2'
```

xml中这样使用：

```xml
<com.google.android.flexbox.FlexboxLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    app:flexWrap="wrap"
    app:alignItems="stretch"
    app:alignContent="stretch" >

    <TextView
        android:id="@+id/textview1"
        android:layout_width="120dp"
        android:layout_height="80dp"
        app:layout_flexBasisPercent="50%"
        />

    <TextView
        android:id="@+id/textview2"
        android:layout_width="80dp"
        android:layout_height="80dp"
        app:layout_alignSelf="center"
        />

    <TextView
        android:id="@+id/textview3"
        android:layout_width="160dp"
        android:layout_height="80dp"
        app:layout_alignSelf="flex_end"
        />
</com.google.android.flexbox.FlexboxLayout>
```

或者代码中这样使用：

```java
FlexboxLayout flexboxLayout = (FlexboxLayout) findViewById(R.id.flexbox_layout);
flexboxLayout.setFlexDirection(FlexboxLayout.FLEX_DIRECTION_COLUMN);

View view = flexboxLayout.getChildAt(0);
FlexboxLayout.LayoutParams lp = (FlexboxLayout.LayoutParams) view.getLayoutParams();
lp.order = -1;
lp.flexGrow = 2;
view.setLayoutParams(lp);
```

使用起来是不是很像Linearlayout的用法，只不过有很多属性你们比较陌生，这些属性都是Flexbox布局本身具备的，别着急，下面跟你们介绍下FlexboxLayout的一些具体属性的用法与意义。

## 4.支持的属性

### flexDirection

flexDirection 属性决定主轴的方向（即项目的排列方向）。类似 LinearLayout 的 vertical 和 horizontal。

有四个值可以选择：

- row（默认值）：主轴为水平方向，起点在左端。
- row-reverse：主轴为水平方向，起点在右端。
- column：主轴为垂直方向，起点在上沿。
- column-reverse：主轴为垂直方向，起点在下沿。

### flexWrap

默认情况下 Flex 跟 LinearLayout 一样，都是不带换行排列的，但是flexWrap属性可以支持换行排列。有三个值：

![](http://static.oschina.net/uploads/space/2016/0516/075805_YI0O_2652078.png)

- nowrap ：不换行
- wrap：按正常方向换行
- wrap-reverse：按反方向换行

### justifyContent

justifyContent属性定义了项目在主轴上的对齐方式。

- flex-start（默认值）：左对齐
- flex-end：右对齐
- center： 居中
- space-between：两端对齐，项目之间的间隔都相等。
- space-around：每个项目两侧的间隔相等。所以，项目之间的间隔比项目与边框的间隔大一倍。

### alignItems

alignItems属性定义项目在副轴轴上如何对齐。

- flex-start：交叉轴的起点对齐。
- flex-end：交叉轴的终点对齐。
- center：交叉轴的中点对齐。
- baseline: 项目的第一行文字的基线对齐。
- stretch（默认值）：如果项目未设置高度或设为auto，将占满整个容器的高度。

![](http://static.oschina.net/uploads/space/2016/0516/075958_K7iO_2652078.png)

### alignContent

alignContent属性定义了多根轴线的对齐方式。如果项目只有一根轴线，该属性不起作用。

- flex-start：与交叉轴的起点对齐。
- flex-end：与交叉轴的终点对齐。
- center：与交叉轴的中点对齐。
- space-between：与交叉轴两端对齐，轴线之间的间隔平均分布。
- space-around：每根轴线两侧的间隔都相等。所以，轴线之间的间隔比轴线与边框的间隔大一倍。
- stretch（默认值）：轴线占满整个交叉轴。

## 5.子元素属性

除以上之外，FlexboxLayout还支持如下子元素属性：

### layout_order

默认情况下子元素的排列方式按照文档流的顺序依次排序，而order属性可以控制排列的顺序，负值在前，正值灾后，按照从小到大的顺序依次排列。我们说之所以 FlexboxLayout 相对LinearLayout强就是因为一些属性比较给力，order就是其中之一。

![](http://static.oschina.net/uploads/space/2016/0516/080144_woPx_2652078.png)

### layout_flexGrow

layout_flexGrow 属性定义项目的放大比例，默认为0，即如果存在剩余空间，也不放大。一张图看懂。跟 LinearLayout 中的weight属性一样。

![](http://static.oschina.net/uploads/space/2016/0516/080148_QD0P_2652078.png)

如果所有项目的 layout_flexGrow  属性都为1，则它们将等分剩余空间（如果有的话）。如果一个项目的 layout_flexGrow  属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍。

### layout_flexShrink

layout_flexShrink  属性定义了项目的缩小比例，默认为1，即如果空间不足，该项目将缩小。

如果所有项目的 layout_flexShrink  属性都为1，当空间不足时，都将等比例缩小。如果一个项目的flex-shrink属性为0，其他项目都为1，则空间不足时，前者不缩小。

负值对该属性无效。

### layout_alignSelf

layout_alignSelf  属性允许单个子元素有与其他子元素不一样的对齐方式，可覆盖 alignItems 属性。默认值为auto，表示继承父元素的 alignItems 属性，如果没有父元素，则等同于stretch。

- auto (default)
- flex_start
- flex_end
- center
- baseline
- stretch

> 该属性可能取6个值，除了auto，其他都与align-items属性完全一致。

### layout_flexBasisPercent

layout_flexBasisPercent 属性定义了在分配多余空间之前，子元素占据的main size主轴空间，浏览器根据这个属性，计算主轴是否有多余空间。它的默认值为auto，即子元素的本来大小。

## 6.不同之处

跟传统的CSS中的Flexbox布局有些不同的是：

1\. 没有 flex-flow 属性

2\. 没有 flex 属性

3\. layout_flexBasisPercent 属性即为CSS中 flexbox 中的 flexBasis 属性

4\. 不支持 min-width 和 min-height 两个属性

以上就是 FlexboxLayout 的一些基本介绍与基本用法，值得提醒大家的是，本身这个项目也是一个很好的自定义View的学习资料，值得大家学习借鉴！

## 参考：

本文的很多 Flexbox 方面的知识大量参考了我司同事的这篇文章，想要更多的了解 Flexbox 相关的知识建议阅读这里：

<http://w4lle.github.io/2016/05/08/Flexbox/>

> 出处：微信公众平台 [AndroidDeveloper](http://mp.weixin.qq.com/s?__biz=MzA4NTQwNDcyMA==&mid=2650661681&idx=1&sn=b151aba0c5fb702492f6bbd82211988d#rd)
>
> 相关链接
FlexboxLayout 的详细介绍：[请点这里](http://www.oschina.net/p/flexboxlayout)
>
>FlexboxLayout 的下载地址：[请点这里](http://www.oschina.net/action/project/go?id=42172&p=download)