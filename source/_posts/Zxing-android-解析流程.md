---
title: Zxing android 解析流程
tags: []
date: 2012-10-23 11:50:00
---

&nbsp;对于刚开始学习android开发的童鞋们来说，若有一个简单而又全面的android工程能来剖析，那就是再好不过了，zxing就是不错得例子。

<div>&nbsp;&nbsp;&nbsp;&nbsp;zxing的源码可以到google code上下载，整个源码check out 下来，里面有各个平台的源码，ios的，android的。当然我们需要的就是android代码。</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;将android的工程导入到eclipse中，导入完成后，eclipse会显示各种错误，这是缺少core文件夹里面的核心库文件所致，在project中创建文件夹core，再将zxing源码中得core文件夹下得代码导入进来，这样就可以了。</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;如果遇到unable resolved target-X，则是你的avd版本问题，可以在project.propertities修改target值。clean下就ok。</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;如上的都是zxing android代码分析的准备，下面的则是正式开始。</div>
<div>

![](http://pic4.xihuan.me/dr/680__90/t02110ad14c2cdda9e7.png)

</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;如上图：为整个android工程的代码，android入门就重这些代码着手。其中主要关注的是android，camera，encode，result文件夹。</div>
<div>&nbsp;&nbsp;&nbsp;程序启动的流程：加载main activity，在此类中创建CaptureActivityHandler对象，该对象启动相机，实现自动聚焦，创建DecodeThread线程，DecodeThread创建Decodehandler，这个对象就获取从相机得到的原始byte数据，开始解码的第一步工作，从获取的byte中解析qr图来，并解析出qr图中的字符，将这块没有分析的字符抛送到CaptureActivityHandler中handle，该类调用main activity的decode函数完成对字符的分析，最后显示在界面上（刷新UI，最好在UI线程里完成）。这样一个解析qr图的过程并完成。</div>
<div>&nbsp;&nbsp;&nbsp;下面具体分析整个过程。重点之处有main activity,camera.</div>
<div>&nbsp;&nbsp;&nbsp;程序启动的第一个activity便是：CaptureActivity,有点类似于c中的main函数，在此是main activity。这个acitvity做的主要的事便是：加载扫描各种条形码，二维码的一个界面，启动一个处理获取一维码二维码信息的线程，完成对于获取的图像信息进行解码，最后再将解码的信息显示在界面上。</div>
<div>&nbsp;&nbsp;&nbsp;</div>
<div>&nbsp;&nbsp;&nbsp;完成界面的加载主要在于onCreate，和onResume函数中，这涉及到了一个activity的生命周期，以后再具体分析。首先调用onCreate，再调用onResume，在onResume中会判断这个activity是由什么启动的，可能是其他的app触发了，也可能是用户直接启动的。这样就初始化了三个变量，一是source，便是启动activity的源，一是decodeFormats，指出解码的方式，是qr，还是其他的等等，最后一个是：charactreset，即是对于这些生成qr图的字符的编码方式。若没有对core中得代码修改，用该程序解析GB2312编码的字符则会乱码。乱码的解决后面将提到。</div>
<div>&nbsp;&nbsp;&nbsp;界面的加载中有两个很关键的类。surfaceview 和 ViewFinderView，前面的是用来加载从底层硬件获取的相机取景的图像，后面的是自定义的view，实现了扫描时的界面，不停的刷新，并将识别的一些数据，如定位的点回调显示在界面上。</div>