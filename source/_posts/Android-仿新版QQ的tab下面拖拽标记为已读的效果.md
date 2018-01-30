---
title: '[Android]仿新版QQ的tab下面拖拽标记为已读的效果'
tags: [android, DaggerableFlagView, view, qq]
date: 2014-12-24 17:39:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span style="color: #ff0000;">**来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/4182929.html](http://www.cnblogs.com/tiantianbyconan/p/4182929.html "view: [Android]仿新版QQ的tab下面拖拽标记为已读的效果")**</span>

可拖拽的红点，（仿新版QQ，tab下面拖拽标记为已读的效果），拖拽一定的距离可以消失回调。

![](https://raw.githubusercontent.com/wangjiegulu/DraggableFlagView/master/screenshot/draggableflagview.gif)

&nbsp;![](https://raw.githubusercontent.com/wangjiegulu/DraggableFlagView/master/screenshot/draggableflagview_b.png)<span style="line-height: 1.5;">&nbsp;</span>![](https://raw.githubusercontent.com/wangjiegulu/DraggableFlagView/master/screenshot/draggableflagview_d.png)

&nbsp;

**GitHub：[DraggableFlagView](https://github.com/wangjiegulu/DraggableFlagView)（[https://github.com/wangjiegulu/DraggableFlagView](https://github.com/wangjiegulu/DraggableFlagView)）**

实现原理：

当根据touch事件的移动，不断调用onDraw()方法进行刷新绘制。

<span style="color: #ff0000;">*注意：这里原来的小红点称为红点A；根据手指移动绘制的小红点称为红点B。</span>

touch事件移动的时候需要处理的逻辑：

1\. <span style="color: #000000;">红点A的半径根据滑动的距离会不断地变小。</span>

<span style="color: #000000;">2\. 红点B会紧随手指的位置移动。</span>

<span style="color: #000000;">3\. 在红点A和红点B之间需要用贝塞尔曲线绘制连接区域。</span>

<span style="color: #000000;">4\. 如果红点A和红点B之间的间距达到了设置的最大的距离，则表示，这次的拖拽会有效，一旦放手红点就会消失。</span>

<span style="color: #000000;">5\. 如果达到了第4中情况，则红点A和中间连接的贝塞尔曲线不会被绘制。</span>

<span style="color: #000000;">6\. 如果红点A和红点B之间的距离没有达到设置的最大的距离，则放手后，红点B消失，红点A从原来变小的半径使用反弹动画变换到原来最初的状态</span>

一些工具类需要依赖&nbsp;**[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)([https://github.com/wangjiegulu/AndroidBucket](https://github.com/wangjiegulu/AndroidBucket))，nineoldandroid**

<span style="font-size: 16px;">**<span style="color: #000000;">使用方式：</span>**</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">com.wangjie.draggableflagview.DraggableFlagView
　　　　　　　</span><span style="color: #ff0000;">xmlns:dfv</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/com.wangjie.draggableflagview"</span><span style="color: #ff0000;">
            android:id</span><span style="color: #0000ff;">="@+id/main_dfv"</span><span style="color: #ff0000;">
            android:layout_width</span><span style="color: #0000ff;">="20dp"</span><span style="color: #ff0000;">
            android:layout_height</span><span style="color: #0000ff;">="20dp"</span><span style="color: #ff0000;">
            android:layout_alignParentBottom</span><span style="color: #0000ff;">="true"</span><span style="color: #ff0000;">
            android:layout_margin</span><span style="color: #0000ff;">="15dp"</span><span style="color: #ff0000;">
            dfv:color</span><span style="color: #0000ff;">="#FF3B30"</span>
            <span style="color: #0000ff;">/&gt;</span></pre>
</div>

&nbsp;

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span> Activity <span style="color: #0000ff;">implements</span><span style="color: #000000;"> DraggableFlagView.OnDraggableFlagViewListener, View.OnClickListener {
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 4</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
</span><span style="color: #008080;"> 5</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">        setContentView(R.layout.main);
</span><span style="color: #008080;"> 7</span>         findViewById(R.id.main_btn).setOnClickListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span>         DraggableFlagView draggableFlagView =<span style="color: #000000;"> (DraggableFlagView) findViewById(R.id.main_dfv);
</span><span style="color: #008080;">10</span>         draggableFlagView.setOnDraggableFlagViewListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">11</span>         draggableFlagView.setText("7"<span style="color: #000000;">);
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">13</span> 
<span style="color: #008080;">14</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">15</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onFlagDismiss(DraggableFlagView view) {
</span><span style="color: #008080;">16</span>         Toast.makeText(<span style="color: #0000ff;">this</span>, "onFlagDismiss"<span style="color: #000000;">, Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">17</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">20</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClick(View v) {
</span><span style="color: #008080;">21</span>         <span style="color: #0000ff;">switch</span><span style="color: #000000;"> (v.getId()) {
</span><span style="color: #008080;">22</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.main_btn:
</span><span style="color: #008080;">23</span>                 Toast.makeText(<span style="color: #0000ff;">this</span>, "hello world"<span style="color: #000000;">, Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">24</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">25</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">26</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">27</span> }</pre>
</div>

<span style="font-size: 16px;">**DraggableFlagView代码：**</span>

&nbsp;

<div class="cnblogs_code">
<pre><span style="color: #008080;">  1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">  2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;">  3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;">  4</span> <span style="color: #008000;"> * Date: 12/23/14.
</span><span style="color: #008080;">  5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">  6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> DraggableFlagView <span style="color: #0000ff;">extends</span><span style="color: #000000;"> View {
</span><span style="color: #008080;">  7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = DraggableFlagView.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;">  8</span> 
<span style="color: #008080;">  9</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> OnDraggableFlagViewListener {
</span><span style="color: #008080;"> 10</span>         <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 11</span> <span style="color: #008000;">         * 拖拽销毁圆点后的回调
</span><span style="color: #008080;"> 12</span> <span style="color: #008000;">         *
</span><span style="color: #008080;"> 13</span> <span style="color: #008000;">         * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> view
</span><span style="color: #008080;"> 14</span>          <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 15</span>         <span style="color: #0000ff;">void</span><span style="color: #000000;"> onFlagDismiss(DraggableFlagView view);
</span><span style="color: #008080;"> 16</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 17</span> 
<span style="color: #008080;"> 18</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> OnDraggableFlagViewListener onDraggableFlagViewListener;
</span><span style="color: #008080;"> 19</span> 
<span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOnDraggableFlagViewListener(OnDraggableFlagViewListener onDraggableFlagViewListener) {
</span><span style="color: #008080;"> 21</span>         <span style="color: #0000ff;">this</span>.onDraggableFlagViewListener =<span style="color: #000000;"> onDraggableFlagViewListener;
</span><span style="color: #008080;"> 22</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 23</span> 
<span style="color: #008080;"> 24</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> DraggableFlagView(Context context) {
</span><span style="color: #008080;"> 25</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context);
</span><span style="color: #008080;"> 26</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 27</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 28</span> 
<span style="color: #008080;"> 29</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> patientColor =<span style="color: #000000;"> Color.RED;
</span><span style="color: #008080;"> 30</span> 
<span style="color: #008080;"> 31</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> DraggableFlagView(Context context, AttributeSet attrs) {
</span><span style="color: #008080;"> 32</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs);
</span><span style="color: #008080;"> 33</span>         TypedArray a =<span style="color: #000000;"> context.obtainStyledAttributes(attrs, R.styleable.DraggableFlagView);
</span><span style="color: #008080;"> 34</span>         <span style="color: #0000ff;">int</span> indexCount =<span style="color: #000000;"> a.getIndexCount();
</span><span style="color: #008080;"> 35</span>         <span style="color: #0000ff;">for</span> (<span style="color: #0000ff;">int</span> i = 0; i &lt; indexCount; i++<span style="color: #000000;">) {
</span><span style="color: #008080;"> 36</span>             <span style="color: #0000ff;">int</span> attrIndex =<span style="color: #000000;"> a.getIndex(i);
</span><span style="color: #008080;"> 37</span>             <span style="color: #0000ff;">if</span> (attrIndex ==<span style="color: #000000;"> R.styleable.DraggableFlagView_color) {
</span><span style="color: #008080;"> 38</span>                 patientColor =<span style="color: #000000;"> a.getColor(attrIndex, Color.RED);
</span><span style="color: #008080;"> 39</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 40</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 41</span> <span style="color: #000000;">        a.recycle();
</span><span style="color: #008080;"> 42</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 43</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 44</span> 
<span style="color: #008080;"> 45</span>     <span style="color: #0000ff;">public</span> DraggableFlagView(Context context, AttributeSet attrs, <span style="color: #0000ff;">int</span><span style="color: #000000;"> defStyle) {
</span><span style="color: #008080;"> 46</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs, defStyle);
</span><span style="color: #008080;"> 47</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 48</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 49</span> 
<span style="color: #008080;"> 50</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Context context;
</span><span style="color: #008080;"> 51</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> originRadius; <span style="color: #008000;">//</span><span style="color: #008000;"> 初始的圆的半径</span>
<span style="color: #008080;"> 52</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> originWidth;
</span><span style="color: #008080;"> 53</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> originHeight;
</span><span style="color: #008080;"> 54</span> 
<span style="color: #008080;"> 55</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> maxMoveLength; <span style="color: #008000;">//</span><span style="color: #008000;"> 最大的移动拉长距离</span>
<span style="color: #008080;"> 56</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isArrivedMaxMoved; <span style="color: #008000;">//</span><span style="color: #008000;"> 达到了最大的拉长距离（松手可以触发事件）</span>
<span style="color: #008080;"> 57</span> 
<span style="color: #008080;"> 58</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> curRadius; <span style="color: #008000;">//</span><span style="color: #008000;"> 当前点的半径</span>
<span style="color: #008080;"> 59</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> touchedPointRadius; <span style="color: #008000;">//</span><span style="color: #008000;"> touch的圆的半径</span>
<span style="color: #008080;"> 60</span>     <span style="color: #0000ff;">private</span> Point startPoint = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Point();
</span><span style="color: #008080;"> 61</span>     <span style="color: #0000ff;">private</span> Point endPoint = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Point();
</span><span style="color: #008080;"> 62</span> 
<span style="color: #008080;"> 63</span>     <span style="color: #0000ff;">private</span> Paint paint; <span style="color: #008000;">//</span><span style="color: #008000;"> 绘制圆形图形</span>
<span style="color: #008080;"> 64</span>     <span style="color: #0000ff;">private</span> Paint textPaint; <span style="color: #008000;">//</span><span style="color: #008000;"> 绘制圆形图形</span>
<span style="color: #008080;"> 65</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Paint.FontMetrics textFontMetrics;
</span><span style="color: #008080;"> 66</span> 
<span style="color: #008080;"> 67</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;">[] location;
</span><span style="color: #008080;"> 68</span> 
<span style="color: #008080;"> 69</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isTouched; <span style="color: #008000;">//</span><span style="color: #008000;"> 是否是触摸状态</span>
<span style="color: #008080;"> 70</span> 
<span style="color: #008080;"> 71</span>     <span style="color: #0000ff;">private</span> Triangle triangle = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Triangle();
</span><span style="color: #008080;"> 72</span> 
<span style="color: #008080;"> 73</span>     <span style="color: #0000ff;">private</span> String text = ""; <span style="color: #008000;">//</span><span style="color: #008000;"> 正常状态下显示的文字</span>
<span style="color: #008080;"> 74</span> 
<span style="color: #008080;"> 75</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> init(Context context) {
</span><span style="color: #008080;"> 76</span>         <span style="color: #0000ff;">this</span>.context =<span style="color: #000000;"> context;
</span><span style="color: #008080;"> 77</span> 
<span style="color: #008080;"> 78</span> <span style="color: #000000;">        setBackgroundColor(Color.TRANSPARENT);
</span><span style="color: #008080;"> 79</span> 
<span style="color: #008080;"> 80</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置绘制flag的paint</span>
<span style="color: #008080;"> 81</span>         paint = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Paint();
</span><span style="color: #008080;"> 82</span> <span style="color: #000000;">        paint.setColor(patientColor);
</span><span style="color: #008080;"> 83</span>         paint.setAntiAlias(<span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 84</span> 
<span style="color: #008080;"> 85</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置绘制文字的paint</span>
<span style="color: #008080;"> 86</span>         textPaint = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Paint();
</span><span style="color: #008080;"> 87</span>         textPaint.setAntiAlias(<span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 88</span> <span style="color: #000000;">        textPaint.setColor(Color.WHITE);
</span><span style="color: #008080;"> 89</span>         textPaint.setTextSize(ABTextUtil.sp2px(context, 12<span style="color: #000000;">));
</span><span style="color: #008080;"> 90</span> <span style="color: #000000;">        textPaint.setTextAlign(Paint.Align.CENTER);
</span><span style="color: #008080;"> 91</span>         textFontMetrics =<span style="color: #000000;"> paint.getFontMetrics();
</span><span style="color: #008080;"> 92</span> 
<span style="color: #008080;"> 93</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 94</span> 
<span style="color: #008080;"> 95</span>     RelativeLayout.LayoutParams originLp; <span style="color: #008000;">//</span><span style="color: #008000;"> 实际的layoutparams</span>
<span style="color: #008080;"> 96</span>     RelativeLayout.LayoutParams newLp; <span style="color: #008000;">//</span><span style="color: #008000;"> 触摸时候的LayoutParams</span>
<span style="color: #008080;"> 97</span> 
<span style="color: #008080;"> 98</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isFirst = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 99</span> 
<span style="color: #008080;">100</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">101</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span> onSizeChanged(<span style="color: #0000ff;">int</span> w, <span style="color: #0000ff;">int</span> h, <span style="color: #0000ff;">int</span> oldw, <span style="color: #0000ff;">int</span><span style="color: #000000;"> oldh) {
</span><span style="color: #008080;">102</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onSizeChanged(w, h, oldw, oldh);
</span><span style="color: #008080;">103</span> <span style="color: #008000;">//</span><span style="color: #008000;">        Logger.d(TAG, String.format("onSizeChanged, w: %s, h: %s, oldw: %s, oldh: %s", w, h, oldw, oldh));</span>
<span style="color: #008080;">104</span>         <span style="color: #0000ff;">if</span> (isFirst &amp;&amp; w &gt; 0 &amp;&amp; h &gt; 0<span style="color: #000000;">) {
</span><span style="color: #008080;">105</span>             isFirst = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">106</span> 
<span style="color: #008080;">107</span>             originWidth =<span style="color: #000000;"> w;
</span><span style="color: #008080;">108</span>             originHeight =<span style="color: #000000;"> h;
</span><span style="color: #008080;">109</span> 
<span style="color: #008080;">110</span>             originRadius = Math.min(originWidth, originHeight) / 2<span style="color: #000000;">;
</span><span style="color: #008080;">111</span>             curRadius =<span style="color: #000000;"> originRadius;
</span><span style="color: #008080;">112</span>             touchedPointRadius =<span style="color: #000000;"> originRadius;
</span><span style="color: #008080;">113</span> 
<span style="color: #008080;">114</span>             maxMoveLength = ABAppUtil.getDeviceHeight(context) / 6<span style="color: #000000;">;
</span><span style="color: #008080;">115</span> 
<span style="color: #008080;">116</span> <span style="color: #000000;">            refreshStartPoint();
</span><span style="color: #008080;">117</span> 
<span style="color: #008080;">118</span>             ViewGroup.LayoutParams lp = <span style="color: #0000ff;">this</span><span style="color: #000000;">.getLayoutParams();
</span><span style="color: #008080;">119</span>             <span style="color: #0000ff;">if</span> (RelativeLayout.LayoutParams.<span style="color: #0000ff;">class</span><span style="color: #000000;">.isAssignableFrom(lp.getClass())) {
</span><span style="color: #008080;">120</span>                 originLp =<span style="color: #000000;"> (RelativeLayout.LayoutParams) lp;
</span><span style="color: #008080;">121</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">122</span>             newLp = <span style="color: #0000ff;">new</span><span style="color: #000000;"> RelativeLayout.LayoutParams(lp.width, lp.height);
</span><span style="color: #008080;">123</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">124</span> 
<span style="color: #008080;">125</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">126</span> 
<span style="color: #008080;">127</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">128</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setLayoutParams(ViewGroup.LayoutParams params) {
</span><span style="color: #008080;">129</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.setLayoutParams(params);
</span><span style="color: #008080;">130</span> <span style="color: #000000;">        refreshStartPoint();
</span><span style="color: #008080;">131</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">132</span> 
<span style="color: #008080;">133</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">134</span> <span style="color: #008000;">     * 修改layoutParams后，需要重新设置startPoint
</span><span style="color: #008080;">135</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">136</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> refreshStartPoint() {
</span><span style="color: #008080;">137</span>         location = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">int</span>[2<span style="color: #000000;">];
</span><span style="color: #008080;">138</span>         <span style="color: #0000ff;">this</span><span style="color: #000000;">.getLocationInWindow(location);
</span><span style="color: #008080;">139</span> <span style="color: #008000;">//</span><span style="color: #008000;">        Logger.d(TAG, "location on screen: " + Arrays.toString(location));
</span><span style="color: #008080;">140</span> <span style="color: #008000;">//</span><span style="color: #008000;">            startPoint.set(location[0], location[1] + h);</span>
<span style="color: #008080;">141</span>         <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;">142</span>             location[1] = location[1] -<span style="color: #000000;"> ABAppUtil.getTopBarHeight((Activity) context);
</span><span style="color: #008080;">143</span>         } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (Exception ex) {
</span><span style="color: #008080;">144</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">145</span> 
<span style="color: #008080;">146</span>         startPoint.set(location[0], location[1] +<span style="color: #000000;"> getMeasuredHeight());
</span><span style="color: #008080;">147</span> <span style="color: #008000;">//</span><span style="color: #008000;">        Logger.d(TAG, "startPoint: " + startPoint);</span>
<span style="color: #008080;">148</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">149</span> 
<span style="color: #008080;">150</span>     Path path = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Path();
</span><span style="color: #008080;">151</span> 
<span style="color: #008080;">152</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">153</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onDraw(Canvas canvas) {
</span><span style="color: #008080;">154</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onDraw(canvas);
</span><span style="color: #008080;">155</span> <span style="color: #000000;">        canvas.drawColor(Color.TRANSPARENT);
</span><span style="color: #008080;">156</span> 
<span style="color: #008080;">157</span>         <span style="color: #0000ff;">int</span> startCircleX = 0, startCircleY = 0<span style="color: #000000;">;
</span><span style="color: #008080;">158</span>         <span style="color: #0000ff;">if</span> (isTouched) { <span style="color: #008000;">//</span><span style="color: #008000;"> 触摸状态</span>
<span style="color: #008080;">159</span> 
<span style="color: #008080;">160</span>             startCircleX = startPoint.x +<span style="color: #000000;"> curRadius;
</span><span style="color: #008080;">161</span>             startCircleY = startPoint.y -<span style="color: #000000;"> curRadius;
</span><span style="color: #008080;">162</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> 绘制原来的圆形（触摸移动的时候半径会不断变化）</span>
<span style="color: #008080;">163</span> <span style="color: #000000;">            canvas.drawCircle(startCircleX, startCircleY, curRadius, paint);
</span><span style="color: #008080;">164</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> 绘制手指跟踪的圆形</span>
<span style="color: #008080;">165</span>             <span style="color: #0000ff;">int</span> endCircleX =<span style="color: #000000;"> endPoint.x;
</span><span style="color: #008080;">166</span>             <span style="color: #0000ff;">int</span> endCircleY =<span style="color: #000000;"> endPoint.y;
</span><span style="color: #008080;">167</span> <span style="color: #000000;">            canvas.drawCircle(endCircleX, endCircleY, originRadius, paint);
</span><span style="color: #008080;">168</span> 
<span style="color: #008080;">169</span>             <span style="color: #0000ff;">if</span> (!isArrivedMaxMoved) { <span style="color: #008000;">//</span><span style="color: #008000;"> 没有达到拉伸最大值</span>
<span style="color: #008080;">170</span> <span style="color: #000000;">                path.reset();
</span><span style="color: #008080;">171</span>                 <span style="color: #0000ff;">double</span> sin = triangle.deltaY /<span style="color: #000000;"> triangle.hypotenuse;
</span><span style="color: #008080;">172</span>                 <span style="color: #0000ff;">double</span> cos = triangle.deltaX /<span style="color: #000000;"> triangle.hypotenuse;
</span><span style="color: #008080;">173</span> 
<span style="color: #008080;">174</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> A点</span>
<span style="color: #008080;">175</span> <span style="color: #000000;">                path.moveTo(
</span><span style="color: #008080;">176</span>                         (<span style="color: #0000ff;">float</span>) (startCircleX - curRadius *<span style="color: #000000;"> sin),
</span><span style="color: #008080;">177</span>                         (<span style="color: #0000ff;">float</span>) (startCircleY - curRadius *<span style="color: #000000;"> cos)
</span><span style="color: #008080;">178</span> <span style="color: #000000;">                );
</span><span style="color: #008080;">179</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> B点</span>
<span style="color: #008080;">180</span> <span style="color: #000000;">                path.lineTo(
</span><span style="color: #008080;">181</span>                         (<span style="color: #0000ff;">float</span>) (startCircleX + curRadius *<span style="color: #000000;"> sin),
</span><span style="color: #008080;">182</span>                         (<span style="color: #0000ff;">float</span>) (startCircleY + curRadius *<span style="color: #000000;"> cos)
</span><span style="color: #008080;">183</span> <span style="color: #000000;">                );
</span><span style="color: #008080;">184</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> C点</span>
<span style="color: #008080;">185</span> <span style="color: #000000;">                path.quadTo(
</span><span style="color: #008080;">186</span>                         (startCircleX + endCircleX) / 2, (startCircleY + endCircleY) / 2<span style="color: #000000;">,
</span><span style="color: #008080;">187</span>                         (<span style="color: #0000ff;">float</span>) (endCircleX + originRadius * sin), (<span style="color: #0000ff;">float</span>) (endCircleY + originRadius *<span style="color: #000000;"> cos)
</span><span style="color: #008080;">188</span> <span style="color: #000000;">                );
</span><span style="color: #008080;">189</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> D点</span>
<span style="color: #008080;">190</span> <span style="color: #000000;">                path.lineTo(
</span><span style="color: #008080;">191</span>                         (<span style="color: #0000ff;">float</span>) (endCircleX - originRadius *<span style="color: #000000;"> sin),
</span><span style="color: #008080;">192</span>                         (<span style="color: #0000ff;">float</span>) (endCircleY - originRadius *<span style="color: #000000;"> cos)
</span><span style="color: #008080;">193</span> <span style="color: #000000;">                );
</span><span style="color: #008080;">194</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> A点</span>
<span style="color: #008080;">195</span> <span style="color: #000000;">                path.quadTo(
</span><span style="color: #008080;">196</span>                         (startCircleX + endCircleX) / 2, (startCircleY + endCircleY) / 2<span style="color: #000000;">,
</span><span style="color: #008080;">197</span>                         (<span style="color: #0000ff;">float</span>) (startCircleX - curRadius * sin), (<span style="color: #0000ff;">float</span>) (startCircleY - curRadius *<span style="color: #000000;"> cos)
</span><span style="color: #008080;">198</span> <span style="color: #000000;">                );
</span><span style="color: #008080;">199</span> <span style="color: #000000;">                canvas.drawPath(path, paint);
</span><span style="color: #008080;">200</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">201</span> 
<span style="color: #008080;">202</span> 
<span style="color: #008080;">203</span>         } <span style="color: #0000ff;">else</span> { <span style="color: #008000;">//</span><span style="color: #008000;"> 非触摸状态</span>
<span style="color: #008080;">204</span>             <span style="color: #0000ff;">if</span> (curRadius &gt; 0<span style="color: #000000;">) {
</span><span style="color: #008080;">205</span>                 startCircleX =<span style="color: #000000;"> curRadius;
</span><span style="color: #008080;">206</span>                 startCircleY = originHeight -<span style="color: #000000;"> curRadius;
</span><span style="color: #008080;">207</span> <span style="color: #000000;">                canvas.drawCircle(startCircleX, startCircleY, curRadius, paint);
</span><span style="color: #008080;">208</span>                 <span style="color: #0000ff;">if</span> (curRadius == originRadius) { <span style="color: #008000;">//</span><span style="color: #008000;"> 只有在恢复正常的情况下才显示文字
</span><span style="color: #008080;">209</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 绘制文字</span>
<span style="color: #008080;">210</span>                     <span style="color: #0000ff;">float</span> textH = textFontMetrics.bottom -<span style="color: #000000;"> textFontMetrics.top;
</span><span style="color: #008080;">211</span>                     canvas.drawText(text, startCircleX, startCircleY + textH / 2<span style="color: #000000;">, textPaint);
</span><span style="color: #008080;">212</span> <span style="color: #008000;">//</span><span style="color: #008000;">                    canvas.drawText(text, startCircleX, startCircleY, textPaint);</span>
<span style="color: #008080;">213</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">214</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">215</span> 
<span style="color: #008080;">216</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">217</span> 
<span style="color: #008080;">218</span> <span style="color: #008000;">//</span><span style="color: #008000;">        Logger.d(TAG, "circleX: " + startCircleX + ", circleY: " + startCircleY + ", curRadius: " + curRadius);</span>
<span style="color: #008080;">219</span> 
<span style="color: #008080;">220</span> 
<span style="color: #008080;">221</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">222</span> 
<span style="color: #008080;">223</span>     <span style="color: #0000ff;">float</span> downX =<span style="color: #000000;"> Float.MAX_VALUE;
</span><span style="color: #008080;">224</span>     <span style="color: #0000ff;">float</span> downY =<span style="color: #000000;"> Float.MAX_VALUE;
</span><span style="color: #008080;">225</span> 
<span style="color: #008080;">226</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">227</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onTouchEvent(MotionEvent event) {
</span><span style="color: #008080;">228</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onTouchEvent(event);
</span><span style="color: #008080;">229</span> <span style="color: #008000;">//</span><span style="color: #008000;">        Logger.d(TAG, "onTouchEvent: " + event);</span>
<span style="color: #008080;">230</span>         <span style="color: #0000ff;">switch</span><span style="color: #000000;"> (event.getAction()) {
</span><span style="color: #008080;">231</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_DOWN:
</span><span style="color: #008080;">232</span>                 isTouched = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">233</span>                 <span style="color: #0000ff;">this</span><span style="color: #000000;">.setLayoutParams(newLp);
</span><span style="color: #008080;">234</span>                 endPoint.x = (<span style="color: #0000ff;">int</span><span style="color: #000000;">) downX;
</span><span style="color: #008080;">235</span>                 endPoint.y = (<span style="color: #0000ff;">int</span><span style="color: #000000;">) downY;
</span><span style="color: #008080;">236</span> 
<span style="color: #008080;">237</span>                 changeViewHeight(<span style="color: #0000ff;">this</span><span style="color: #000000;">, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
</span><span style="color: #008080;">238</span> <span style="color: #000000;">                postInvalidate();
</span><span style="color: #008080;">239</span> 
<span style="color: #008080;">240</span>                 downX = event.getX() + location[0<span style="color: #000000;">];
</span><span style="color: #008080;">241</span>                 downY = event.getY() + location[1<span style="color: #000000;">];
</span><span style="color: #008080;">242</span> <span style="color: #008000;">//</span><span style="color: #008000;">                Logger.d(TAG, String.format("downX: %f, downY: %f", downX, downY));</span>
<span style="color: #008080;">243</span> 
<span style="color: #008080;">244</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">245</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_MOVE:
</span><span style="color: #008080;">246</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 计算直角边和斜边（用于计算绘制两圆之间的填充去）</span>
<span style="color: #008080;">247</span>                 triangle.deltaX = event.getX() -<span style="color: #000000;"> downX;
</span><span style="color: #008080;">248</span>                 triangle.deltaY = -1 * (event.getY() - downY); <span style="color: #008000;">//</span><span style="color: #008000;"> y轴方向相反，所有需要取反</span>
<span style="color: #008080;">249</span>                 <span style="color: #0000ff;">double</span> distance = Math.sqrt(triangle.deltaX * triangle.deltaX + triangle.deltaY *<span style="color: #000000;"> triangle.deltaY);
</span><span style="color: #008080;">250</span>                 triangle.hypotenuse =<span style="color: #000000;"> distance;
</span><span style="color: #008080;">251</span> <span style="color: #008000;">//</span><span style="color: #008000;">                Logger.d(TAG, "triangle: " + triangle);</span>
<span style="color: #008080;">252</span>                 refreshCurRadiusByMoveDistance((<span style="color: #0000ff;">int</span><span style="color: #000000;">) distance);
</span><span style="color: #008080;">253</span> 
<span style="color: #008080;">254</span>                 endPoint.x = (<span style="color: #0000ff;">int</span><span style="color: #000000;">) event.getX();
</span><span style="color: #008080;">255</span>                 endPoint.y = (<span style="color: #0000ff;">int</span><span style="color: #000000;">) event.getY();
</span><span style="color: #008080;">256</span> 
<span style="color: #008080;">257</span> <span style="color: #000000;">                postInvalidate();
</span><span style="color: #008080;">258</span> 
<span style="color: #008080;">259</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">260</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_UP:
</span><span style="color: #008080;">261</span>                 isTouched = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">262</span>                 <span style="color: #0000ff;">this</span><span style="color: #000000;">.setLayoutParams(originLp);
</span><span style="color: #008080;">263</span> 
<span style="color: #008080;">264</span>                 <span style="color: #0000ff;">if</span> (isArrivedMaxMoved) { <span style="color: #008000;">//</span><span style="color: #008000;"> 触发事件</span>
<span style="color: #008080;">265</span>                     changeViewHeight(<span style="color: #0000ff;">this</span><span style="color: #000000;">, originWidth, originHeight);
</span><span style="color: #008080;">266</span> <span style="color: #000000;">                    postInvalidate();
</span><span style="color: #008080;">267</span>                     <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> onDraggableFlagViewListener) {
</span><span style="color: #008080;">268</span>                         onDraggableFlagViewListener.onFlagDismiss(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">269</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">270</span>                     Logger.d(TAG, "触发事件..."<span style="color: #000000;">);
</span><span style="color: #008080;">271</span> <span style="color: #000000;">                    resetAfterDismiss();
</span><span style="color: #008080;">272</span>                 } <span style="color: #0000ff;">else</span> { <span style="color: #008000;">//</span><span style="color: #008000;"> 还原</span>
<span style="color: #008080;">273</span>                     changeViewHeight(<span style="color: #0000ff;">this</span><span style="color: #000000;">, originWidth, originHeight);
</span><span style="color: #008080;">274</span>                     startRollBackAnimation(500<span style="color: #008000;">/*</span><span style="color: #008000;">ms</span><span style="color: #008000;">*/</span><span style="color: #000000;">);
</span><span style="color: #008080;">275</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">276</span> 
<span style="color: #008080;">277</span>                 downX =<span style="color: #000000;"> Float.MAX_VALUE;
</span><span style="color: #008080;">278</span>                 downY =<span style="color: #000000;"> Float.MAX_VALUE;
</span><span style="color: #008080;">279</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">280</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">281</span> 
<span style="color: #008080;">282</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">283</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">284</span> 
<span style="color: #008080;">285</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">286</span> <span style="color: #008000;">     * 触发事件之后重置
</span><span style="color: #008080;">287</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">288</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> resetAfterDismiss() {
</span><span style="color: #008080;">289</span>         <span style="color: #0000ff;">this</span><span style="color: #000000;">.setVisibility(GONE);
</span><span style="color: #008080;">290</span>         text = ""<span style="color: #000000;">;
</span><span style="color: #008080;">291</span>         isArrivedMaxMoved = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">292</span>         curRadius =<span style="color: #000000;"> originRadius;
</span><span style="color: #008080;">293</span> <span style="color: #000000;">        postInvalidate();
</span><span style="color: #008080;">294</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">295</span> 
<span style="color: #008080;">296</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">297</span> <span style="color: #008000;">     * 根据移动的距离来刷新原来的圆半径大小
</span><span style="color: #008080;">298</span> <span style="color: #008000;">     *
</span><span style="color: #008080;">299</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> distance
</span><span style="color: #008080;">300</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">301</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> refreshCurRadiusByMoveDistance(<span style="color: #0000ff;">int</span><span style="color: #000000;"> distance) {
</span><span style="color: #008080;">302</span>         <span style="color: #0000ff;">if</span> (distance &gt;<span style="color: #000000;"> maxMoveLength) {
</span><span style="color: #008080;">303</span>             isArrivedMaxMoved = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">304</span>             curRadius = 0<span style="color: #000000;">;
</span><span style="color: #008080;">305</span>         } <span style="color: #0000ff;">else</span><span style="color: #000000;"> {
</span><span style="color: #008080;">306</span>             isArrivedMaxMoved = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">307</span>             <span style="color: #0000ff;">float</span> calcRadius = (1 - 1f * distance / maxMoveLength) *<span style="color: #000000;"> originRadius;
</span><span style="color: #008080;">308</span>             <span style="color: #0000ff;">float</span> maxRadius = ABTextUtil.dip2px(context, 2<span style="color: #000000;">);
</span><span style="color: #008080;">309</span>             curRadius = (<span style="color: #0000ff;">int</span><span style="color: #000000;">) Math.max(calcRadius, maxRadius);
</span><span style="color: #008080;">310</span> <span style="color: #008000;">//</span><span style="color: #008000;">            Logger.d(TAG, "[refreshCurRadiusByMoveDistance]curRadius: " + curRadius + ", calcRadius: " + calcRadius + ", maxRadius: " + maxRadius);</span>
<span style="color: #008080;">311</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">312</span> 
<span style="color: #008080;">313</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">314</span> 
<span style="color: #008080;">315</span> 
<span style="color: #008080;">316</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">317</span> <span style="color: #008000;">     * 改变某控件的高度
</span><span style="color: #008080;">318</span> <span style="color: #008000;">     *
</span><span style="color: #008080;">319</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> view
</span><span style="color: #008080;">320</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> height
</span><span style="color: #008080;">321</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">322</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> changeViewHeight(View view, <span style="color: #0000ff;">int</span> width, <span style="color: #0000ff;">int</span><span style="color: #000000;"> height) {
</span><span style="color: #008080;">323</span>         ViewGroup.LayoutParams lp =<span style="color: #000000;"> view.getLayoutParams();
</span><span style="color: #008080;">324</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> lp) {
</span><span style="color: #008080;">325</span>             lp =<span style="color: #000000;"> originLp;
</span><span style="color: #008080;">326</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">327</span>         lp.width =<span style="color: #000000;"> width;
</span><span style="color: #008080;">328</span>         lp.height =<span style="color: #000000;"> height;
</span><span style="color: #008080;">329</span> <span style="color: #000000;">        view.setLayoutParams(lp);
</span><span style="color: #008080;">330</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">331</span> 
<span style="color: #008080;">332</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">333</span> <span style="color: #008000;">     * 回滚状态动画
</span><span style="color: #008080;">334</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">335</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> ValueAnimator rollBackAnim;
</span><span style="color: #008080;">336</span> 
<span style="color: #008080;">337</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> startRollBackAnimation(<span style="color: #0000ff;">long</span><span style="color: #000000;"> duration) {
</span><span style="color: #008080;">338</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> rollBackAnim) {
</span><span style="color: #008080;">339</span>             rollBackAnim =<span style="color: #000000;"> ValueAnimator.ofFloat(curRadius, originRadius);
</span><span style="color: #008080;">340</span>             rollBackAnim.addUpdateListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> ValueAnimator.AnimatorUpdateListener() {
</span><span style="color: #008080;">341</span> <span style="color: #000000;">                @Override
</span><span style="color: #008080;">342</span>                 <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onAnimationUpdate(ValueAnimator animation) {
</span><span style="color: #008080;">343</span>                     <span style="color: #0000ff;">float</span> value = (<span style="color: #0000ff;">float</span><span style="color: #000000;">) animation.getAnimatedValue();
</span><span style="color: #008080;">344</span>                     curRadius = (<span style="color: #0000ff;">int</span><span style="color: #000000;">) value;
</span><span style="color: #008080;">345</span> <span style="color: #000000;">                    postInvalidate();
</span><span style="color: #008080;">346</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">347</span> <span style="color: #000000;">            });
</span><span style="color: #008080;">348</span>             rollBackAnim.setInterpolator(<span style="color: #0000ff;">new</span> BounceInterpolator()); <span style="color: #008000;">//</span><span style="color: #008000;"> 反弹效果</span>
<span style="color: #008080;">349</span>             rollBackAnim.addListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> AnimatorListenerAdapter() {
</span><span style="color: #008080;">350</span> <span style="color: #000000;">                @Override
</span><span style="color: #008080;">351</span>                 <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onAnimationEnd(Animator animation) {
</span><span style="color: #008080;">352</span>                     <span style="color: #0000ff;">super</span><span style="color: #000000;">.onAnimationEnd(animation);
</span><span style="color: #008080;">353</span>                     DraggableFlagView.<span style="color: #0000ff;">this</span><span style="color: #000000;">.clearAnimation();
</span><span style="color: #008080;">354</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">355</span> <span style="color: #000000;">            });
</span><span style="color: #008080;">356</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">357</span> <span style="color: #000000;">        rollBackAnim.setDuration(duration);
</span><span style="color: #008080;">358</span> <span style="color: #000000;">        rollBackAnim.start();
</span><span style="color: #008080;">359</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">360</span> 
<span style="color: #008080;">361</span> 
<span style="color: #008080;">362</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">363</span> <span style="color: #008000;">     * 计算四个坐标的三角边关系
</span><span style="color: #008080;">364</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">365</span>     <span style="color: #0000ff;">class</span><span style="color: #000000;"> Triangle {
</span><span style="color: #008080;">366</span>         <span style="color: #0000ff;">double</span><span style="color: #000000;"> deltaX;
</span><span style="color: #008080;">367</span>         <span style="color: #0000ff;">double</span><span style="color: #000000;"> deltaY;
</span><span style="color: #008080;">368</span>         <span style="color: #0000ff;">double</span><span style="color: #000000;"> hypotenuse;
</span><span style="color: #008080;">369</span> 
<span style="color: #008080;">370</span> <span style="color: #000000;">        @Override
</span><span style="color: #008080;">371</span>         <span style="color: #0000ff;">public</span><span style="color: #000000;"> String toString() {
</span><span style="color: #008080;">372</span>             <span style="color: #0000ff;">return</span> "Triangle{" +
<span style="color: #008080;">373</span>                     "deltaX=" + deltaX +
<span style="color: #008080;">374</span>                     ", deltaY=" + deltaY +
<span style="color: #008080;">375</span>                     ", hypotenuse=" + hypotenuse +
<span style="color: #008080;">376</span>                     '}'<span style="color: #000000;">;
</span><span style="color: #008080;">377</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">378</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">379</span> 
<span style="color: #008080;">380</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String getText() {
</span><span style="color: #008080;">381</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> text;
</span><span style="color: #008080;">382</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">383</span> 
<span style="color: #008080;">384</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setText(String text) {
</span><span style="color: #008080;">385</span>         <span style="color: #0000ff;">this</span>.text =<span style="color: #000000;"> text;
</span><span style="color: #008080;">386</span> <span style="color: #000000;">        postInvalidate();
</span><span style="color: #008080;">387</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">388</span> }</pre>
</div>

&nbsp;

