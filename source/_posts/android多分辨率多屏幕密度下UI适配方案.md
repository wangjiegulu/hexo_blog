---
title: android多分辨率多屏幕密度下UI适配方案
tags: [android, ui]
date: 2015-02-02 19:12:00
---

**文章转载自[http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2013/0627/1393.html](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2013/0627/1393.html)**

**摘要**&nbsp;前言 Android 设计之初就考虑到了 UI 在多平台的适配，它本身提供了一套完善的适配机制，随着版本的发展适配也越来越精确， UI 适配主要受平台两个因素的影响：屏幕尺寸（屏幕的像素宽度及像素高度）和屏幕密度，针对不同的应用场景采用的适配方案也不一样，

<div class="first">

# 前言

Android设计之初就考虑到了UI在多平台的适配，它本身提供了一套完善的适配机制，随着版本的发展适配也越来越精确，UI适配主要受平台两个因素的影响：屏幕尺寸（屏幕的像素宽度及像素高度）和屏幕密度，针对不同的应用场景采用的适配方案也不一样，此文档仅针对Android4.0及以下版本

&nbsp;

**相关概念**

**分辨率：**整个屏幕的像素数目，为了表示方便一般用屏幕的像素宽度（水平像素数目）乘以像素高度表示，形如1280x720，反之分辨率为1280x720的屏幕，像素宽度不一定为1280

**屏幕密度：**表示单位面积内的像素个数，通常用dpi为单位，即每英寸多少个像素点

**px****：**长度单位，以具体像素为单位

**dp****：**长度单位，与具体屏幕密度无关，显示的时候根据具体平台屏幕密度的不同最终转换为相应的像素长度，具体转换规则是: 1dp =&nbsp;（目标屏幕密度/标准密度）*px,标准密度为160dpi，例如，1dp长度在密度为160dpi的平台表示一个像素的长度，而在240dpi的平台则表示1.5个像素的长度

**屏幕尺寸：**屏幕的大小，通常用屏幕对角线的长度表示

# Android界面适配机制

UI界面在不同平台的适配受屏幕尺寸和屏幕密度影响，Android适配机制就是在资源后面添加对这两种因素的限定，通过不同的限定区分不同的平台资源，Android在使用资源的时候会优先选择满足本平台限定的资源，再找最接近条件的，再找默认（即不加限定），通过选择适合当前平台的资源来完成不同平台的适配。

&nbsp;

屏幕尺寸分为：small,normal,large,xlarge分别表示小，中，大，超大屏

屏幕密度分为：ldpi,mdpi,hdpi,xhdpi，它们的标准值分别是：120dpi，160dpi，240dpi，320dpi

以上划分均表示的是一个范围：

![](http://www.jcodecraeer.com/uploads/20130627/13722624421110.jpg "image001.jpg")

在资源目录后面加上上面的限定就能为资源指定特定的适用平台，如下所示

![](http://www.jcodecraeer.com/uploads/20130627/13722624942474.jpg "image002.jpg")

表示大屏，中密度布局会选择上面那个main.xml，超大屏，中密度会选择下面那个main.xml

&nbsp;

在实际开发过程中屏幕尺寸不够直观，android将其转换为分辨率表示，根据屏幕具体分辨率可选择相应的限定符

![](http://www.jcodecraeer.com/uploads/20130627/13722625497179.jpg "image003.jpg")

小结：通过加上上述限定可以实现一个apk适配几种主流的屏幕尺寸和屏幕密度，这种限定方式比较适用于对外发布应用，不知道终端具体参数的情况，但是不能做到精确适配，对于屏幕尺寸和密度相差不大的两种平台不能很好的区分。

&nbsp;

为了解决上述问题，自Android3.2开始，引入了精确适配，理论上可以适配任意像素宽度，高度，屏幕密度的平台，需用以下方式添加限定符

![](http://www.jcodecraeer.com/uploads/20130627/13722625806649.jpg "image004.jpg")

其中w1280dp表示屏幕宽度为1280dp，h752dp表示屏幕高度为752dp，160dpi表示屏幕密度，其中屏幕宽，高必须以dp为单位，在知道屏幕像素宽高度的情况下可以通过公式：1dp =&nbsp;（目标屏幕密度/标准密度）*px&nbsp;转换成dp单位。

例如：某平台屏幕宽，高分别为1920px，720px，屏幕密度为240dpi

适配该平台的限定为：

![](http://www.jcodecraeer.com/uploads/20130627/13722626152563.jpg "image005.jpg")

或者

![](http://www.jcodecraeer.com/uploads/20130627/13722626311624.jpg "image006.jpg")

根据公式1dp=（240/160）px=1.5px,宽度，高度转为dp单位分别是1280dp和480dp.

&nbsp;

**Android自适应不同分辨率或不同屏幕大小的layout布局(横屏|竖屏**)

一：不同的layout

Android手机屏幕大小不一，有480x320, 640x360, 800x480.怎样才能让App自动适应不同的屏幕呢？
其实很简单，只需要在res目录下创建不同的layout文件夹，比如layout-640x360,layout-800x480,所有的layout文件在编译之后都会写入R.java里，而系统会根据屏幕的大小自己选择合适的layout进行使用。

二：hdpi、mdpi、ldpi

在之前的版本中，只有一个drawable，而2.1版本中有drawable-mdpi、drawable-ldpi、drawable-hdpi三个，这三个主要是为了支持多分辨率。

drawable- hdpi、drawable- mdpi、drawable-ldpi的区别：

(1)drawable-hdpi里面存放高分辨率的图片,如WVGA (480x800),FWVGA (480x854)

(2)drawable-mdpi里面存放中等分辨率的图片,如HVGA (320x480)

(3)drawable-ldpi里面存放低分辨率的图片,如QVGA (240x320)

　　系统会根据机器的分辨率来分别到这几个文件夹里面去找对应的图片。

更正：应该是对应不同density 的图片

　　在开发程序时为了兼容不同平台不同屏幕，建议各自文件夹根据需求均存放不同版本图片。

[i]备注：三者的解析度不一样，就像你把电脑的分辨率调低，图片会变大一样，反之分辨率高，图片缩小。 [/i]&nbsp;
屏幕方向：

横屏竖屏自动切换：

可以在res目录下建立layout-port-800x600和layout-land两个目录，里面分别放置竖屏和横屏两种布局文件，这样在手机屏幕方向变化的时候系统会自动调用相应的布局文件，避免一种布局文件无法满足两种屏幕显示的问题。

不同分辨率横屏竖屏自动切换：

以800x600为例
可以在res目录下建立layout-port-800x600和layout-land-800x600两个目录

不切换：

以下步骤是网上流传的，不过我自己之前是通过图形化界面实现这个配置，算是殊途同归，有空我会把图片贴上来。

还要说明一点：每个activity都有这个属性screenOrientation，每个activity都需要设置，可以设置为竖屏（portrait），也可以设置为无重力感应（nosensor）。

要让程序界面保持一个方向，不随手机方向转动而变化的处理办法：

在AndroidManifest.xml里面配置一下就可以了。加入这一行android:screenOrientation="landscape"。
例如（landscape是横向，portrait是纵向）：

Java代码:

&lt;?xml version="1.0" encoding="utf-8"?&gt;
&lt;manifestxmlns:android="http://schemas.android.com/apk/res/android"&nbsp;
package="com.ray.linkit"&nbsp;
android:versionCode="1"&nbsp;
android:versionName="1.0"&gt;&nbsp;
&lt;application android:icon="@drawable/icon"android:label="@string/app_name"&gt;&nbsp;
&lt;activity android:name=".Main"&nbsp;
android:label="@string/app_name"&nbsp;
android:screenOrientation="portrait"&gt;&nbsp;
&lt;intent-filter&gt;&nbsp;
&lt;action android:name="android.intent.action.MAIN" /&gt;&nbsp;
&lt;category android:name="android.intent.category.LAUNCHER" /&gt;&nbsp;
&lt;/intent-filter&gt;&nbsp;
&lt;/activity&gt;&nbsp;
&lt;activity android:name=".GamePlay"&nbsp;
android:screenOrientation="portrait"&gt;&lt;/activity&gt;&nbsp;
&lt;activity android:name=".OptionView"&nbsp;
android:screenOrientation="portrait"&gt;&lt;/activity&gt;&nbsp;
&lt;/application&gt;&nbsp;
&lt;uses-sdk android:minSdkVersion="3" /&gt;&nbsp;
&lt;/manifest&gt;

另外，android中每次屏幕的切换动会重启Activity，所以应该在Activity销毁前保存当前活动的状态，在Activity再次Create的时候载入配置，那样，进行中的游戏就不会自动重启了！

有的程序适合从竖屏切换到横屏，或者反过来，这个时候怎么办呢？可以在配置Activity的地方进行如下的配置android:screenOrientation="portrait"。这样就可以保证是竖屏总是竖屏了，或者landscape横向。

而有的程序是适合横竖屏切换的。如何处理呢？首先要在配置Activity的时候进行如下的配置：android:configChanges="keyboardHidden|orientation"，另外需要重写Activity的 onConfigurationChanged方法。实现方式如下，不需要做太多的内容：

@Override&nbsp;
public void onConfigurationChanged(Configuration newConfig) {&nbsp;
super.onConfigurationChanged(newConfig);&nbsp;
if (this.getResources().getConfiguration().orientation ==Configuration.ORIENTATION_LANDSCAPE) {&nbsp;
// land do nothing is ok&nbsp;
} else if (this.getResources().getConfiguration().orientation ==Configuration.ORIENTATION_PORTRAIT) {&nbsp;
// port do nothing is ok&nbsp;
}&nbsp;
}

写一个支持多分辨的程序，基于1.6开发的，建立了三个资源文件夹drawable-hdpi drawable-mdpidrawable-ldpi，里面分别存放72*72 48*48 36*36的icon图标文件。当我在G1（1.5的系统）上测试时，图标应该自适应为48*48才对啊，但实际显示的是36*36。怎么才能让其自适应 48*48的icon图标呢

解决办法 drawable-hdpi drawable-mdpi drawable-ldpi改成drawable-480X320 drawable-800X480的多分辨支持的文件夹

对于Android游戏开发我们不得不像iPhone那样思考兼容 Android平板电脑，对于苹果要考虑iPad、iPhone 3GS和iPhone 4等屏幕之间的兼容性，对于几乎所有的分辨率总结了大约超过20中粉笔阿女郎的大小和对应关系，对于开发Android游戏而言可以考虑到未来的3.0以及很多平板电脑的需要。

常规的我们可能只考虑QVGA，HVGA，WVGA，FWVGA和DVGA，但是抛去了手机不谈，可能平板使用类似WSVGA的1024&times;576以及WXGA的1280&times;768等等。
QVGA = 320 * 240;
WQVGA = 320 * 480;
WQVGA2 = 400 * 240;
WQVGA3 = 432 * 240;
HVGA = 480 * 320;
VGA = 640 * 480;
WVGA = 800 * 480;
WVGA2 = 768 * 480;
FWVGA = 854 * 480;
DVGA = 960 * 640;
PAL = 576 * 520;
NTSC = 486 * 440;
SVGA = 800 * 600;
WSVGA [...]

这是一个比较有代表性的Android软件资源包，drawable里面存放的是应用的图标文件，layout存放的是布局，简单说就是这些图标如何摆放。为什么Android上需要这么多资源包文件和布局文件是我们接下来需要讨论的问题。

Android设备屏幕的尺寸是各式各样的，如小米是4英寸的，Xoom平板是10英寸；分辨率也千奇百怪，800&times;480，960&times;540等；Android版本的碎片化问题更是萦绕于心，不过在设计应用时可以分为两大块：3.0之前的版本和3.0之后的版本。这种情况会带来什么问题我们用三个假设来说明一下。

1\. 假设你的手上有两个4英寸的设备，设备A的分辨率是800&times;480，设备B的分辨率是1600&times;960。你在设备A上设计了一个64&times;64像素的图标，感觉它大小正合适，但放到设备B上的时候，这个图标看上去就只有之前一半大小了。

2\. 假设你手上的两个设备，设备A是4英寸，设备B是10英寸。在设备A上方放了一个tab控件，有三个页签。放到设备B上看时tab控件的三个页签被拉得很长，本来放6个页签的空间只放了三个页签。

3\. 假设你手上的两个设备，设备A装的是Android2.3，设备B装的是Android4.0，而设备B没有menu建，风格也不一样。你发现两个设备上用同一套风格的皮肤并不合适。

Google提供了一套体系去解决这些问题。我们再回到上面的那张图，drawable文件夹有ldpi、mdpi、hdpi、xhdpi四种。dpi指像素/英寸，而ldpi指120，mdpi指160，hdpi指240，xhdpi指320。小米手机是4英寸、854&times;480的分辨率，那么小米手机的dpi就是854的平方加480的平方和开2次方后除以4，结果大约是245。如果应用安装在小米手机上，那么系统会调用图中drawable-hdpi里面的资源。这样，你只要做4套资源分别放在drawable-ldpi、drawable-mdpi、drawable-hdpi以及drawable-xdpi下（图标可以按照3：4：6：8的比例制作图片资源），那么就可以解决上面假设1当中提到的问题。

对于相同dpi、但尺寸不一样的设备，可以通过layout文件控制各种资源的布局。Google将设备分为small（2～3英寸）、normal（4英寸左右）、large（5～7英寸）、xlarge（7英寸以上）。在上面的假设2种，我们可以在layout-normal里配置3个页签的tab栏，在layout-xlarge里配置6个页签的tab栏。如果应用在所有设备上布局都一样，那么就不用考虑针对不同尺寸的layout。从图中那些layout*文件夹可以看出，该应用在hdpi及xhdpi上支持横竖屏，而且横竖屏的布局不一致，但没有考虑不同尺寸的设备使用不同布局的情况。

Android3.0之前的风格与Android3.0（包含3.0）之后的风格区别很大，图中那个应用就使用了两种风格的资源及布局。Android2.3的小米会使用drawable-hdpi及layout-hdpi当中的文件，而Android4.0的小米就会使用drawable-hdpi-v11及layout-hdpi-v11里面的文件。

今天就到此为止了，有空的时候再说说9-Patch的使用。这篇文章也就只能起到抛砖引玉的作用，在实际设计应用的时候还需要多去参考其他文档资料，特别是Android开发的官方文档。

</div>

