---
title: 'Android高级模糊技术[转]'
tags: []
date: 2014-03-28 10:46:00
---

今天我们来更深入了解一下Android开发上的模糊技术。我读过几篇有关的文章，也在StackOverFlow上看过一些相关教程的帖子，所以我想在这里总结一下学到的东西。

### 为什么学习这个模糊技术？

现在越来越多的开发者喜欢在自定义控件的时候加上各种模糊背景，看看RomanNurik开发的[Muzei](https://play.google.com/store/apps/details?id=net.nurik.roman.muzei)或者Yahoo的[Weather应用](https://play.google.com/store/apps/details?id=com.yahoo.mobile.client.android.weather)app都非常不错。我非常喜欢他们的设计。

我从**Mark Allison**的帖子([帖子地址](http://blog.stylingandroid.com/archives/2304))得到启发，然后写了这篇文章。

这是我们需要完成下图展示的效果：

[![1](http://www.linuxeden.com/upimg/allimg/140328/0S1031332-0.png)](http://www.linuxeden.com/upimg/allimg/140328/0S1031332-0.png "Android高级模糊技术")

### 预备知识

首先描述一下我们需要的文件。我们需要一个主`Activity`，里面有一个含有多个`Fragment`的`ViewPager`，每个`Fragment`展示一种模糊技术。

<span>这是主</span>`Activity`<span>的布局文件内容：</span>

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">android.support.v4.view.ViewPager
</span><span style="color: #008080;">2</span> <span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span>
<span style="color: #008080;">3</span> <span style="color: #ff0000;">    xmlns:tools</span><span style="color: #0000ff;">="http://schemas.android.com/tools"</span>
<span style="color: #008080;">4</span> <span style="color: #ff0000;">    android:id</span><span style="color: #0000ff;">="@+id/pager"</span>
<span style="color: #008080;">5</span> <span style="color: #ff0000;">    android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">6</span> <span style="color: #ff0000;">    android:layout_height</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">7</span> <span style="color: #ff0000;">    tools:context</span><span style="color: #0000ff;">="com.paveldudka.MainActivity"</span> <span style="color: #0000ff;">/&gt;</span></pre>
</div>

<span>这是</span>`Fragment`<span>的布局文件内容：</span>

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span>  
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">FrameLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span>
<span style="color: #008080;"> 4</span> <span style="color: #ff0000;">    android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;"> 5</span> <span style="color: #ff0000;">    android:layout_height</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 6</span>  
<span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">ImageView
</span><span style="color: #008080;"> 8</span>         <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/picture"</span>
<span style="color: #008080;"> 9</span> <span style="color: #ff0000;">        android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">10</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">11</span> <span style="color: #ff0000;">        android:src</span><span style="color: #0000ff;">="@drawable/picture"</span>
<span style="color: #008080;">12</span> <span style="color: #ff0000;">        android:scaleType</span><span style="color: #0000ff;">="centerCrop"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">13</span>  
<span style="color: #008080;">14</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TextView
</span><span style="color: #008080;">15</span>         <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/text"</span>
<span style="color: #008080;">16</span> <span style="color: #ff0000;">        android:gravity</span><span style="color: #0000ff;">="center_horizontal"</span>
<span style="color: #008080;">17</span> <span style="color: #ff0000;">        android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">18</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;">19</span> <span style="color: #ff0000;">        android:text</span><span style="color: #0000ff;">="My super text"</span>
<span style="color: #008080;">20</span> <span style="color: #ff0000;">        android:textColor</span><span style="color: #0000ff;">="&lt;a href="</span><span style="color: #ff0000;">http://www.jobbole.com/members/android/" rel</span><span style="color: #0000ff;">="nofollow"</span><span style="color: #0000ff;">&gt;</span>@android<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">a</span><span style="color: #0000ff;">&gt;</span><span style="color: #000000;">:color/white"
</span><span style="color: #008080;">21</span> <span style="color: #000000;">        android:layout_gravity="center_vertical"
</span><span style="color: #008080;">22</span> <span style="color: #000000;">        android:textStyle="bold"
</span><span style="color: #008080;">23</span> <span style="color: #000000;">        android:textSize="48sp" /&gt;
</span><span style="color: #008080;">24</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout
</span><span style="color: #008080;">25</span>         <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/controls"</span>
<span style="color: #008080;">26</span> <span style="color: #ff0000;">        android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">27</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;">28</span> <span style="color: #ff0000;">        android:background</span><span style="color: #0000ff;">="#7f000000"</span>
<span style="color: #008080;">29</span> <span style="color: #ff0000;">        android:orientation</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;">30</span> <span style="color: #ff0000;">        android:layout_gravity</span><span style="color: #0000ff;">="bottom"</span><span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">31</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">FrameLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

我们只是在布局上放了一个`ImageView`，然后在中间加一个`TextView`，还有一些作为效果显示和测试的控件（如 @+id/controls）。

最普遍的模糊技术是这样做的：

*   从`TextView`的后一层背景中截取一部分；
*   进行模糊处理；
*   把模糊处理后的部分设置为`TextView`的背景。

### Renderscript

那怎么在Android中实现模糊处理呢？最好的答案就是Renderscript。这是一个功能强大的图形处理&ldquo;引擎&rdquo;。RenderScript的底层原理就不做介绍了（因为我也不知道），而且这超过了我们这篇文章的范围。

先看下面的代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">public class RSBlurFragment extends Fragment {
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">    private ImageView image;
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">    private TextView text;
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">    private TextView statusText;
</span><span style="color: #008080;"> 5</span>  
<span style="color: #008080;"> 6</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">        View view = inflater.inflate(R.layout.fragment_layout, container, false);
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">        image = (ImageView) view.findViewById(R.id.picture);
</span><span style="color: #008080;">10</span> <span style="color: #000000;">        text = (TextView) view.findViewById(R.id.text);
</span><span style="color: #008080;">11</span> <span style="color: #000000;">        statusText = addStatusText((ViewGroup) view.findViewById(R.id.controls));
</span><span style="color: #008080;">12</span> <span style="color: #000000;">        applyBlur();
</span><span style="color: #008080;">13</span> <span style="color: #000000;">        return view;
</span><span style="color: #008080;">14</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">15</span>  
<span style="color: #008080;">16</span> <span style="color: #000000;">    private void applyBlur() {
</span><span style="color: #008080;">17</span> <span style="color: #000000;">        image.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
</span><span style="color: #008080;">18</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">19</span> <span style="color: #000000;">            public boolean onPreDraw() {
</span><span style="color: #008080;">20</span> <span style="color: #000000;">                image.getViewTreeObserver().removeOnPreDrawListener(this);
</span><span style="color: #008080;">21</span> <span style="color: #000000;">                image.buildDrawingCache();
</span><span style="color: #008080;">22</span>  
<span style="color: #008080;">23</span> <span style="color: #000000;">                Bitmap bmp = image.getDrawingCache();
</span><span style="color: #008080;">24</span> <span style="color: #000000;">                blur(bmp, text);
</span><span style="color: #008080;">25</span> <span style="color: #000000;">                return true;
</span><span style="color: #008080;">26</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">27</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">28</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">29</span>  
<span style="color: #008080;">30</span> <span style="color: #000000;">    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
</span><span style="color: #008080;">31</span> <span style="color: #000000;">    private void blur(Bitmap bkg, View view) {
</span><span style="color: #008080;">32</span> <span style="color: #000000;">        long startMs = System.currentTimeMillis();
</span><span style="color: #008080;">33</span>  
<span style="color: #008080;">34</span> <span style="color: #000000;">        float radius = 20;
</span><span style="color: #008080;">35</span>  
<span style="color: #008080;">36</span> <span style="color: #000000;">        Bitmap overlay = Bitmap.createBitmap((int) (view.getMeasuredWidth()),
</span><span style="color: #008080;">37</span> <span style="color: #000000;">                (int) (view.getMeasuredHeight()), Bitmap.Config.ARGB_8888);
</span><span style="color: #008080;">38</span>  
<span style="color: #008080;">39</span> <span style="color: #000000;">        Canvas canvas = new Canvas(overlay);
</span><span style="color: #008080;">40</span>  
<span style="color: #008080;">41</span> <span style="color: #000000;">        canvas.translate(-view.getLeft(), -view.getTop());
</span><span style="color: #008080;">42</span> <span style="color: #000000;">        canvas.drawBitmap(bkg, 0, 0, null);
</span><span style="color: #008080;">43</span>  
<span style="color: #008080;">44</span> <span style="color: #000000;">        RenderScript rs = RenderScript.create(getActivity());
</span><span style="color: #008080;">45</span>  
<span style="color: #008080;">46</span> <span style="color: #000000;">        Allocation overlayAlloc = Allocation.createFromBitmap(
</span><span style="color: #008080;">47</span> <span style="color: #000000;">                rs, overlay);
</span><span style="color: #008080;">48</span>  
<span style="color: #008080;">49</span> <span style="color: #000000;">        ScriptIntrinsicBlur blur = ScriptIntrinsicBlur.create(
</span><span style="color: #008080;">50</span> <span style="color: #000000;">                rs, overlayAlloc.getElement());
</span><span style="color: #008080;">51</span>  
<span style="color: #008080;">52</span> <span style="color: #000000;">        blur.setInput(overlayAlloc);
</span><span style="color: #008080;">53</span>  
<span style="color: #008080;">54</span> <span style="color: #000000;">        blur.setRadius(radius);
</span><span style="color: #008080;">55</span>  
<span style="color: #008080;">56</span> <span style="color: #000000;">        blur.forEach(overlayAlloc);
</span><span style="color: #008080;">57</span>  
<span style="color: #008080;">58</span> <span style="color: #000000;">        overlayAlloc.copyTo(overlay);
</span><span style="color: #008080;">59</span>  
<span style="color: #008080;">60</span> <span style="color: #000000;">        view.setBackground(new BitmapDrawable(
</span><span style="color: #008080;">61</span> <span style="color: #000000;">                getResources(), overlay));
</span><span style="color: #008080;">62</span>  
<span style="color: #008080;">63</span> <span style="color: #000000;">        rs.destroy();
</span><span style="color: #008080;">64</span> <span style="color: #000000;">        statusText.setText(System.currentTimeMillis() - startMs + "ms");
</span><span style="color: #008080;">65</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">66</span>  
<span style="color: #008080;">67</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">68</span> <span style="color: #000000;">    public String toString() {
</span><span style="color: #008080;">69</span> <span style="color: #000000;">        return "RenderScript";
</span><span style="color: #008080;">70</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">71</span>  
<span style="color: #008080;">72</span> <span style="color: #000000;">    private TextView addStatusText(ViewGroup container) {
</span><span style="color: #008080;">73</span> <span style="color: #000000;">        TextView result = new TextView(getActivity());
</span><span style="color: #008080;">74</span> <span style="color: #000000;">        result.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
</span><span style="color: #008080;">75</span> <span style="color: #000000;">        result.setTextColor(0xFFFFFFFF);
</span><span style="color: #008080;">76</span> <span style="color: #000000;">        container.addView(result);
</span><span style="color: #008080;">77</span> <span style="color: #000000;">        return result;
</span><span style="color: #008080;">78</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">79</span> }</pre>
</div>

*   在`Fragment`创建的时候，我先载入了布局文件，然后把`TextView`添加到我在布局文件中定义的LinearLayout中（用来显示模糊效果，进行效果测试），最后对图片做模糊处理。
*   在`applyBlur()`函数中我注册了`onPreDrawListener()`。因为在`applyBlur()`方法调用的时候界面还没有开始布局，所以我需要实现这个监听器否则不能进行模糊处理。需要等到布局文件全都经过**measured**、**laid out**、**displayed**的时候，才能进行操作。
*   在`onPreDraw()`回调函数中，我首先把返回值**false**改成**true**。这个很重要，如果返回**false**的话，刚开始出现的那一帧画面会被跳过，但是我们需要显示这第一帧，所以要返回**true**。
*   接着我去掉了里面的回调方法，因为我们不需要监听它的`preDraw`事件。
*   然后我们需要从`ImageView`中获取`Bitmap`，然后用`getDrawingCache()`函数创建**drawing cache**并保存。
*   最后就是进行模糊处理了，我们接下来会详细讨论这个环节。

需要说明的是，我的代码中在两种情况下考虑不是很周全：

*   在布局文件改变时不会再自动重新模糊处理。这个问题可以通过注册`onGlobalLayoutListener`监听器解决，在布局文件改变时重新进行模糊处理就可以了。
*   这个模糊处理操作是在主线程中进行的。我们知道在实际开发中不会这么做，但是为了方便暂时先这么做了。

现在回到`blur()`方法：

*   首先我创建了一个空的bitmap，把背景的一部分复制进去，之后我会对这个bitmap进行模糊处理并设置为`TextView`的背景。
*   通过这个bitmap保存`Canvas`的状态；
*   在父布局文件中把`Canvas`移动到`TextView`的位置；
*   把`ImageView`的内容绘到bitmap中；
*   此时，我们就有了一个和`TextView`一样大小的bitmap，它包含了`ImageView`的一部分内容，也就是`TextView`背后一层布局的内容；
*   创建一个Renderscript的实例；
*   把bitmap复制一份到Renderscript需要的数据片中；
*   创建Renderscript模糊处理的实例；
*   设置输入，半径范围然后进行模糊处理；
*   把处理后的结果复制回之前的bitmap中；
*   好了，我们已经把bitmap惊醒模糊处理了，可以将它设置为`TextView`背景了；

这是我们处理后的效果：

[![2](http://www.linuxeden.com/upimg/allimg/140328/0S1032447-1.png)](http://www.linuxeden.com/upimg/allimg/140328/0S1032447-1.png "Android高级模糊技术")

可以看到效果还不错，但是它用了57ms的时间。我们知道在Android中渲染一帧的时间应该不超过16ms（60fps），但如果在UI线程中做模糊处理就会让帧率降到了17fps。显然这是不可接受的，我们需要把这个操作移到**AsyncTask**上或者使用别的机制实现。

而且有必要说明的是，**ScriptIntrinsicBlur**只支持API17以上，当然也可以用Renderscript的**support lib**降低一些API版本的要求。

可是我们还是需要支持一些老一些的API版本，它们不支持Renderscript，现在我们看看该怎么办吧。

### FastBlur

因为我们知道，这种模糊处理的过程也就是像素处理而已，所以我们可以尝试着手动进行模糊操作。幸运的是，Java上已经有了很多实现模糊处理方案的例子。我们唯一要做的就是找到一个相对快速的实现方案。

感谢在StackOverFlow上的一篇帖子，我找到了一个能快速实现模糊处理的方案。先看看它是怎么样的。

因为很多代码都是一样的，所以这里只讨论关于模糊处理的函数：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">private void blur(Bitmap bkg, View view) {
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">    long startMs = System.currentTimeMillis();
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">    float radius = 20;
</span><span style="color: #008080;"> 4</span>  
<span style="color: #008080;"> 5</span> <span style="color: #000000;">    Bitmap overlay = Bitmap.createBitmap((int) (view.getMeasuredWidth()),
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">            (int) (view.getMeasuredHeight()), Bitmap.Config.ARGB_8888);
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">    Canvas canvas = new Canvas(overlay);
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">    canvas.translate(-view.getLeft(), -view.getTop());
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    canvas.drawBitmap(bkg, 0, 0, null);
</span><span style="color: #008080;">10</span> <span style="color: #000000;">    overlay = FastBlur.doBlur(overlay, (int)radius, true);
</span><span style="color: #008080;">11</span> <span style="color: #000000;">    view.setBackground(new BitmapDrawable(getResources(), overlay));
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    statusText.setText(System.currentTimeMillis() - startMs + "ms");
</span><span style="color: #008080;">13</span> }</pre>
</div>

实现的效果如下：

[![3](http://www.linuxeden.com/upimg/allimg/140328/0S10323F-2.png)](http://www.linuxeden.com/upimg/allimg/140328/0S10323F-2.png "Android高级模糊技术")

可以看到，模糊处理的效果也相当不错。使用FastBlur的好处是，我们可以去掉对Renderscript的依赖（还有最低API版本的限制）。但是可恶的是，理模糊操作竟然花费了147ms！这还不是最慢的**SW**模糊算法，我都不敢用高斯模糊了&hellip;

### 继续深入

现在我们要想想该怎么做。模糊处理的过程都会有精度损失，你知道什么是精度损失吗？对，要降低尺寸。

既然这样，为什么不把bitmap的尺寸先降低然后进行模糊处理，然后再放大尺寸呢？我试着实现了一下这个想法，这是处理后得到的效果：

[![4](http://www.linuxeden.com/upimg/allimg/140328/0S10345Z-3.png)](http://www.linuxeden.com/upimg/allimg/140328/0S10345Z-3.png "Android高级模糊技术")

看到了吗！Renderscript只用了13ms，FastBlur只用了2ms！还不错。

再看看代码。这里只讨论FastBlur版本，因为Renderscript也是一样的，全部代码都可以从<span class="wp_keywordlink">[GitHub](http://blog.jobbole.com/6492/ "GitHub如何运作系列文章")</span>仓库中检出。

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">private void blur(Bitmap bkg, View view) {
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">    long startMs = System.currentTimeMillis();
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">    float scaleFactor = 1;
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">    float radius = 20;
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">    if (downScale.isChecked()) {
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">        scaleFactor = 8;
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">        radius = 2;
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 9</span>  
<span style="color: #008080;">10</span> <span style="color: #000000;">    Bitmap overlay = Bitmap.createBitmap((int) (view.getMeasuredWidth()/scaleFactor),
</span><span style="color: #008080;">11</span> <span style="color: #000000;">            (int) (view.getMeasuredHeight()/scaleFactor), Bitmap.Config.ARGB_8888);
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    Canvas canvas = new Canvas(overlay);
</span><span style="color: #008080;">13</span> <span style="color: #000000;">    canvas.translate(-view.getLeft()/scaleFactor, -view.getTop()/scaleFactor);
</span><span style="color: #008080;">14</span> <span style="color: #000000;">    canvas.scale(1 / scaleFactor, 1 / scaleFactor);
</span><span style="color: #008080;">15</span> <span style="color: #000000;">    Paint paint = new Paint();
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    paint.setFlags(Paint.FILTER_BITMAP_FLAG);
</span><span style="color: #008080;">17</span> <span style="color: #000000;">    canvas.drawBitmap(bkg, 0, 0, paint);
</span><span style="color: #008080;">18</span>  
<span style="color: #008080;">19</span> <span style="color: #000000;">    overlay = FastBlur.doBlur(overlay, (int)radius, true);
</span><span style="color: #008080;">20</span> <span style="color: #000000;">    view.setBackground(new BitmapDrawable(getResources(), overlay));
</span><span style="color: #008080;">21</span> <span style="color: #000000;">    statusText.setText(System.currentTimeMillis() - startMs + "ms");
</span><span style="color: #008080;">22</span> }</pre>
</div>

我们过一遍这个代码：

*   **scaleFactor**提供了需要缩小的等级，在代码中我把bitmap的尺寸缩小到原图的1/8。因为这个bitmap在模糊处理时会先被缩小然后再放大，所以在我的模糊算法中就不用**radius**这个参数了，所以把它设成2。
*   接着需要创建bitmap，这个bitmap比最后需要的小八倍。
*   请注意我给**Paint**提供了**FILTER_BITMAP_FLAG**标示，这样的话在处理bitmap缩放的时候，就可以达到双缓冲的效果，模糊处理的过程就更加顺畅了。
*   接下来和之前一样进行模糊处理操作，这次的图片小了很多，幅度也降低了很多，所以模糊过程非常快。
*   把模糊处理后的图片作为背景，它会自动进行放大操作的。

之前说到FastBlur进行模糊操作比Renderscript还要快，这是因为FastBlur在进行bitmap复制操作时还会同时进行其他操作，节省了时间。经过了这些处理后，我们应该已经掌握了相对快速的模糊处理方案和原理，并去掉了对Renderscript的依赖。

本文的示例代码：[GitHub &ndash; blurring](https://github.com/paveldudka/blurring)。

&nbsp;

<span>原文链接：&nbsp;</span>[trickyandroid](http://trickyandroid.com/advanced-blurring-techniques/)<span>&nbsp;&nbsp;&nbsp;翻译：&nbsp;</span>[伯乐在线&nbsp;](http://blog.jobbole.com/)<span>-&nbsp;</span>[chris](http://blog.jobbole.com/author/chris/)
<span>译文链接：&nbsp;</span>[http://blog.jobbole.com/63894/](http://blog.jobbole.com/63894/)

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;

&nbsp;