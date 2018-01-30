---
title: Android NDK环境搭建及调用JNI的简单步骤
tags: [android, ndk, jni]
date: 2013-10-30 14:06:00
---

**<span style="color: #ff0000;">转载请注明：[<span style="color: #ff0000;">http://www.cnblogs.com/tiantianbyconan/p/3396595.html</span>](http://www.cnblogs.com/tiantianbyconan/p/3396595.html)</span>**

<span>Java Native Interface (JNI)标准是java平台的一部分，它允许Java代码和其他语言写的代码进行交互。JNI 是本地编程接口，它使得在 Java 虚拟机 (VM) 内部运行的 Java 代码能够与用其它编程语言(如 C、C++ 和汇编语言)编写的应用程序和库进行交互操作。</span>

1\. 下载NDK（[http://developer.android.com/tools/sdk/ndk/index.html](http://developer.android.com/tools/sdk/ndk/index.html)），并解压，配置Path路径

&nbsp;

2\. 在项目中新建一个名为jni的文件夹，在jni中新增Android.mk文件，文件内容如下：

<div class="cnblogs_Highlighter">
<pre class="brush:html;gutter:false;">LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE    := PhotoUtil
LOCAL_SRC_FILES := PhotoUtil.c
LOCAL_LDLIBS    := -llog -ljnigraphics
include $(BUILD_SHARED_LIBRARY)
</pre>
</div>

<span>LOCAL_MODULE：当前模块的名称</span>

<span><span>LOCAL_SHARED_LIBRARIES：当前模块需要依赖的共享库。&nbsp;</span></span>

<span><span>LOCAL_SRC_FILES：所要调用的C源码</span></span>

&nbsp;

<span><span>3\. 把PhotoUtil.c文件复制到jni目录下</span></span>

<span><span>PhotoUtil.c，包含一个图片处理方法：</span></span>

<div class="cnblogs_code">
<pre>JNIEXPORT <span style="color: #0000ff;">void</span> JNICALL Java_com_wangjie_customviews_PicturesDialog_functionToBlur(JNIEnv*<span style="color: #000000;"> env, jobject obj, jobject bitmapIn, jobject bitmapOut, jint radius) {
    &hellip;&hellip;
}</span></pre>
</div>

方法Java_com_wangjie_customviews_PicturesDialog_functionToBlur的取名方式：

Java_：固定
com_wangjie_customviews：java包名
PicturesDialog：java类名
functionToBlur：java使用的方法名

&nbsp;

4\. 编译C源码，生产so库文件

进入jni目录：

ndk-build 或者

<span>ndk-build&nbsp;APP_PLATFORM=android-8</span>

<div class="cnblogs_Highlighter">
<pre class="brush:html;gutter:true;">"Compile thumb : PhotoUtil &lt;= PhotoUtil.c
SharedLibrary  : libPhotoUtil.so
Install        : libPhotoUtil.so =&gt; libs/armeabi/libPhotoUtil.so</pre>
</div>

<span>执行完毕之后，android项目的libs目录下就会生成so文件：</span>

<span>\libs\armeabi\libPhotoUtil.so</span>

<span><span>5\. 在android中java代码调用：</span></span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">static</span><span style="color: #000000;">{
      System.loadLibrary(</span>"PhotoUtil"<span style="color: #000000;">);
}</span></pre>
</div>

加载photoUtil库（libPhotoUtil.so）

并添加：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">native</span> <span style="color: #0000ff;">void</span> functionToBlur(Bitmap bitmapIn, Bitmap bitmapOut, <span style="color: #0000ff;">int</span> radius);</pre>
</div>

然后在其他地方只需要调用该functionToBlur()方法即可：

<div class="cnblogs_code">
<pre>functionToBlur(bgBitmap, bitmapOut, 50);</pre>
</div>

&nbsp;

参考：

[http://www.ibm.com/developerworks/opensource/tutorials/os-androidndk/section5.html](http://www.ibm.com/developerworks/opensource/tutorials/os-androidndk/section5.html)

[http://developer.android.com/tools/sdk/ndk/index.html#Installing](http://developer.android.com/tools/sdk/ndk/index.html#Installing)

[http://stackoverflow.com/questions/2067955/fast-bitmap-blur-for-android-sdk](http://stackoverflow.com/questions/2067955/fast-bitmap-blur-for-android-sdk)

&nbsp;

&nbsp;

&nbsp;

