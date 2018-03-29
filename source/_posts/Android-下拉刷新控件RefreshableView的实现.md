---
title: '[Android]下拉刷新控件RefreshableView的实现'
tags: [android, RefreshableView, view]
date: 2014-12-18 19:35:00
---


&nbsp;

需求：自定义一个ViewGroup，实现可以下拉刷新的功能。下拉一定距离后（下拉时显示的界面可以自定义任何复杂的界面）释放手指可以回调刷新的功能，用户处理完刷新的内容后，可以调用方法onCompleteRefresh()通知刷新完毕，然后回归正常状态。效果如下：

![](https://raw.githubusercontent.com/wangjiegulu/RefreshableView/master/screenshot/refreshableview.gif)&nbsp;&nbsp;&nbsp;![](https://raw.githubusercontent.com/wangjiegulu/RefreshableView/master/screenshot/refreshablelistview.gif)

&nbsp;

**源代码：<span style="color: #ff0000;">[<span style="color: #ff0000;">RefreshableView</span>](https://github.com/wangjiegulu/RefreshableView)</span>（<span style="color: #ff0000;">[<span style="color: #ff0000;">https://github.com/wangjiegulu/RefreshableView</span>](https://github.com/wangjiegulu/RefreshableView)</span>）**

<span style="font-size: 18px;">**分析：**</span>

我们的目的是不管什么控件，只要在xml中外面包一层标签，那这个标签下面的所有子标签所在的控件都被支持可以下拉刷新了。所以，我们可以使用ViewGroup来实现，这里我选择的是继承LinearLayout，当然其他的（FrameLayout等）也一样了。

因为根据手指下滑，需要有一个刷新的view被显示出来，所以这里需要添加一个子view（称为refreshHeaderView），并放置在最顶部，使用LinearLayout的好处是可以设置为VERTICAL，这样可以直接&ldquo;this.addView(refreshHeaderView, 0);&rdquo;搞定了。然后就要根据手指滑动的距离，动态地去改变refreshHeaderView的高度。同时检测是否到达了可以刷新的高度了，如果达到了，更新当前的刷新状态。手指放开时，根据之前移动的刷新状态，执行刷新或者回归正常状态。

RefreshableView代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;">  1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">  2</span> <span style="color: #008000;"> * 下拉刷新控件
</span><span style="color: #008080;">  3</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;">  4</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;">  5</span> <span style="color: #008000;"> * Date: 12/13/14.
</span><span style="color: #008080;">  6</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">  7</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> RefreshableView <span style="color: #0000ff;">extends</span><span style="color: #000000;"> LinearLayout {
</span><span style="color: #008080;">  8</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = RefreshableView.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;">  9</span> 
<span style="color: #008080;"> 10</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> RefreshableView(Context context) {
</span><span style="color: #008080;"> 11</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context);
</span><span style="color: #008080;"> 12</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 13</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 14</span> 
<span style="color: #008080;"> 15</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> RefreshableView(Context context, AttributeSet attrs) {
</span><span style="color: #008080;"> 16</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs);
</span><span style="color: #008080;"> 17</span> 
<span style="color: #008080;"> 18</span>         TypedArray a =<span style="color: #000000;"> context.obtainStyledAttributes(attrs, R.styleable.refreshableView);
</span><span style="color: #008080;"> 19</span>         <span style="color: #0000ff;">for</span> (<span style="color: #0000ff;">int</span> i = 0, len = a.length(); i &lt; len; i++<span style="color: #000000;">) {
</span><span style="color: #008080;"> 20</span>             <span style="color: #0000ff;">int</span> attrIndex =<span style="color: #000000;"> a.getIndex(i);
</span><span style="color: #008080;"> 21</span>             <span style="color: #0000ff;">switch</span><span style="color: #000000;"> (attrIndex) {
</span><span style="color: #008080;"> 22</span>                 <span style="color: #0000ff;">case</span><span style="color: #000000;"> R.styleable.refreshableView_interceptAllMoveEvents:
</span><span style="color: #008080;"> 23</span>                     interceptAllMoveEvents = a.getBoolean(i, <span style="color: #0000ff;">false</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 24</span>                     <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 25</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 26</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 27</span> <span style="color: #000000;">        a.recycle();
</span><span style="color: #008080;"> 28</span> 
<span style="color: #008080;"> 29</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 30</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 31</span> 
<span style="color: #008080;"> 32</span>     <span style="color: #0000ff;">public</span> RefreshableView(Context context, AttributeSet attrs, <span style="color: #0000ff;">int</span><span style="color: #000000;"> defStyle) {
</span><span style="color: #008080;"> 33</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs, defStyle);
</span><span style="color: #008080;"> 34</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 35</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 36</span> 
<span style="color: #008080;"> 37</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 38</span> <span style="color: #008000;">     * 刷新状态
</span><span style="color: #008080;"> 39</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 40</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> STATE_REFRESH_NORMAL = 0x21<span style="color: #000000;">;
</span><span style="color: #008080;"> 41</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> STATE_REFRESH_NOT_ARRIVED = 0x22<span style="color: #000000;">;
</span><span style="color: #008080;"> 42</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> STATE_REFRESH_ARRIVED = 0x23<span style="color: #000000;">;
</span><span style="color: #008080;"> 43</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> STATE_REFRESHING = 0x24<span style="color: #000000;">;
</span><span style="color: #008080;"> 44</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> refreshState;
</span><span style="color: #008080;"> 45</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 刷新状态监听</span>
<span style="color: #008080;"> 46</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> RefreshableHelper refreshableHelper;
</span><span style="color: #008080;"> 47</span> 
<span style="color: #008080;"> 48</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setRefreshableHelper(RefreshableHelper refreshableHelper) {
</span><span style="color: #008080;"> 49</span>         <span style="color: #0000ff;">this</span>.refreshableHelper =<span style="color: #000000;"> refreshableHelper;
</span><span style="color: #008080;"> 50</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 51</span> 
<span style="color: #008080;"> 52</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Context context;
</span><span style="color: #008080;"> 53</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 54</span> <span style="color: #008000;">     * 刷新的view
</span><span style="color: #008080;"> 55</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 56</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> View refreshHeaderView;
</span><span style="color: #008080;"> 57</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 58</span> <span style="color: #008000;">     * 刷新的view的真实高度
</span><span style="color: #008080;"> 59</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 60</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> originRefreshHeight;
</span><span style="color: #008080;"> 61</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 62</span> <span style="color: #008000;">     * 有效下拉刷新需要达到的高度
</span><span style="color: #008080;"> 63</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 64</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> refreshArrivedStateHeight;
</span><span style="color: #008080;"> 65</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 66</span> <span style="color: #008000;">     * 刷新时显示的高度
</span><span style="color: #008080;"> 67</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 68</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> refreshingHeight;
</span><span style="color: #008080;"> 69</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 70</span> <span style="color: #008000;">     * 正常未刷新高度
</span><span style="color: #008080;"> 71</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 72</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> refreshNormalHeight;
</span><span style="color: #008080;"> 73</span> 
<span style="color: #008080;"> 74</span> 
<span style="color: #008080;"> 75</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 76</span> <span style="color: #008000;">     * 默认不允许拦截（即，往子view传递事件），该属性只有在interceptAllMoveEvents为false的时候才有效
</span><span style="color: #008080;"> 77</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 78</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> disallowIntercept = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 79</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 80</span> <span style="color: #008000;">     * xml中可设置它的值为false，表示不把移动的事件传递给子控件
</span><span style="color: #008080;"> 81</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 82</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> interceptAllMoveEvents;
</span><span style="color: #008080;"> 83</span> 
<span style="color: #008080;"> 84</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> init(Context context) {
</span><span style="color: #008080;"> 85</span>         <span style="color: #0000ff;">this</span>.context =<span style="color: #000000;"> context;
</span><span style="color: #008080;"> 86</span>         <span style="color: #0000ff;">this</span><span style="color: #000000;">.setOrientation(VERTICAL);
</span><span style="color: #008080;"> 87</span> 
<span style="color: #008080;"> 88</span> <span style="color: #008000;">//</span><span style="color: #008000;">        Log.d(TAG, "[init]originRefreshHeight: " + refreshHeaderView.getMeasuredHeight());</span>
<span style="color: #008080;"> 89</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 90</span> 
<span style="color: #008080;"> 91</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 92</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span> onSizeChanged(<span style="color: #0000ff;">int</span> w, <span style="color: #0000ff;">int</span> h, <span style="color: #0000ff;">int</span> oldw, <span style="color: #0000ff;">int</span><span style="color: #000000;"> oldh) {
</span><span style="color: #008080;"> 93</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onSizeChanged(w, h, oldw, oldh);
</span><span style="color: #008080;"> 94</span> 
<span style="color: #008080;"> 95</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> refreshableHelper) {
</span><span style="color: #008080;"> 96</span>             refreshHeaderView =<span style="color: #000000;"> refreshableHelper.onInitRefreshHeaderView();
</span><span style="color: #008080;"> 97</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 98</span> <span style="color: #008000;">//</span><span style="color: #008000;">        refreshHeaderView = LayoutInflater.from(context).inflate(R.layout.refresh_head, null);</span>
<span style="color: #008080;"> 99</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> refreshHeaderView) {
</span><span style="color: #008080;">100</span>             Log.e(TAG, "refreshHeaderView is null!"<span style="color: #000000;">);
</span><span style="color: #008080;">101</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">102</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">103</span>         <span style="color: #0000ff;">this</span><span style="color: #000000;">.removeView(refreshHeaderView);
</span><span style="color: #008080;">104</span>         <span style="color: #0000ff;">this</span>.addView(refreshHeaderView, 0<span style="color: #000000;">);
</span><span style="color: #008080;">105</span> 
<span style="color: #008080;">106</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 计算refreshHeadView尺寸</span>
<span style="color: #008080;">107</span>         <span style="color: #0000ff;">int</span> width = View.MeasureSpec.makeMeasureSpec(0<span style="color: #000000;">, View.MeasureSpec.UNSPECIFIED);
</span><span style="color: #008080;">108</span>         <span style="color: #0000ff;">int</span> expandSpec = View.MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE &gt;&gt; 2<span style="color: #000000;">, View.MeasureSpec.AT_MOST);
</span><span style="color: #008080;">109</span> <span style="color: #000000;">        refreshHeaderView.measure(width, expandSpec);
</span><span style="color: #008080;">110</span> 
<span style="color: #008080;">111</span>         Log.d(TAG, "[onSizeChanged]w: " + w + ", h: " +<span style="color: #000000;"> h);
</span><span style="color: #008080;">112</span>         Log.d(TAG, "[onSizeChanged]oldw: " + oldw + ", oldh: " +<span style="color: #000000;"> oldh);
</span><span style="color: #008080;">113</span>         Log.d(TAG, "[onSizeChanged]child counts: " + <span style="color: #0000ff;">this</span><span style="color: #000000;">.getChildCount());
</span><span style="color: #008080;">114</span>         originRefreshHeight =<span style="color: #000000;"> refreshHeaderView.getMeasuredHeight();
</span><span style="color: #008080;">115</span> 
<span style="color: #008080;">116</span>         <span style="color: #0000ff;">boolean</span> isUseDefault = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">117</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> refreshableHelper) {
</span><span style="color: #008080;">118</span>             isUseDefault =<span style="color: #000000;"> refreshableHelper.onInitRefreshHeight(originRefreshHeight);
</span><span style="color: #008080;">119</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">120</span> 
<span style="color: #008080;">121</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 初始化各个高度</span>
<span style="color: #008080;">122</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;"> (isUseDefault) {
</span><span style="color: #008080;">123</span>             refreshArrivedStateHeight =<span style="color: #000000;"> originRefreshHeight;
</span><span style="color: #008080;">124</span>             refreshingHeight =<span style="color: #000000;"> originRefreshHeight;
</span><span style="color: #008080;">125</span>             refreshNormalHeight = 0<span style="color: #000000;">;
</span><span style="color: #008080;">126</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">127</span>         Log.d(TAG, "[onSizeChanged]refreshHeaderView origin height: " +<span style="color: #000000;"> originRefreshHeight);
</span><span style="color: #008080;">128</span> <span style="color: #000000;">        changeViewHeight(refreshHeaderView, refreshNormalHeight);
</span><span style="color: #008080;">129</span> 
<span style="color: #008080;">130</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 初始化为正常状态</span>
<span style="color: #008080;">131</span> <span style="color: #000000;">        setRefreshState(STATE_REFRESH_NORMAL);
</span><span style="color: #008080;">132</span> 
<span style="color: #008080;">133</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">134</span> 
<span style="color: #008080;">135</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">136</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> dispatchTouchEvent(MotionEvent ev) {
</span><span style="color: #008080;">137</span>         Log.d(TAG, "[dispatchTouchEvent]ev action: " +<span style="color: #000000;"> ev.getAction());
</span><span style="color: #008080;">138</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">super</span><span style="color: #000000;">.dispatchTouchEvent(ev);
</span><span style="color: #008080;">139</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">140</span> 
<span style="color: #008080;">141</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">142</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onInterceptTouchEvent(MotionEvent ev) {
</span><span style="color: #008080;">143</span>         Log.d(TAG, "[onInterceptTouchEvent]ev action: " +<span style="color: #000000;"> ev.getAction());
</span><span style="color: #008080;">144</span>         <span style="color: #0000ff;">if</span> (!<span style="color: #000000;">interceptAllMoveEvents) {
</span><span style="color: #008080;">145</span>             <span style="color: #0000ff;">return</span> !<span style="color: #000000;">disallowIntercept;
</span><span style="color: #008080;">146</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">147</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 如果设置了拦截所有move事件，即interceptAllMoveEvents为true</span>
<span style="color: #008080;">148</span>         <span style="color: #0000ff;">if</span> (MotionEvent.ACTION_MOVE ==<span style="color: #000000;"> ev.getAction()) {
</span><span style="color: #008080;">149</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">150</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">151</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">152</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">153</span> 
<span style="color: #008080;">154</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">155</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> requestDisallowInterceptTouchEvent(<span style="color: #0000ff;">boolean</span><span style="color: #000000;"> disallowIntercept) {
</span><span style="color: #008080;">156</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">this</span>.disallowIntercept ==<span style="color: #000000;"> disallowIntercept) {
</span><span style="color: #008080;">157</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">158</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">159</span>         <span style="color: #0000ff;">this</span>.disallowIntercept =<span style="color: #000000;"> disallowIntercept;
</span><span style="color: #008080;">160</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.requestDisallowInterceptTouchEvent(disallowIntercept);
</span><span style="color: #008080;">161</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">162</span> 
<span style="color: #008080;">163</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">float</span> downY =<span style="color: #000000;"> Float.MAX_VALUE;
</span><span style="color: #008080;">164</span> 
<span style="color: #008080;">165</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">166</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onTouchEvent(MotionEvent event) {
</span><span style="color: #008080;">167</span> <span style="color: #008000;">//</span><span style="color: #008000;">        super.onTouchEvent(event);</span>
<span style="color: #008080;">168</span>         Log.d(TAG, "[onTouchEvent]ev action: " +<span style="color: #000000;"> event.getAction());
</span><span style="color: #008080;">169</span>         <span style="color: #0000ff;">switch</span><span style="color: #000000;"> (event.getAction()) {
</span><span style="color: #008080;">170</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_DOWN:
</span><span style="color: #008080;">171</span>                 downY =<span style="color: #000000;"> event.getY();
</span><span style="color: #008080;">172</span>                 Log.d(TAG, "Down --&gt; downY: " +<span style="color: #000000;"> downY);
</span><span style="color: #008080;">173</span>                 requestDisallowInterceptTouchEvent(<span style="color: #0000ff;">true</span>); <span style="color: #008000;">//</span><span style="color: #008000;"> 保证事件可往下传递</span>
<span style="color: #008080;">174</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">175</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_MOVE:
</span><span style="color: #008080;">176</span> 
<span style="color: #008080;">177</span>                 <span style="color: #0000ff;">float</span> curY =<span style="color: #000000;"> event.getY();
</span><span style="color: #008080;">178</span>                 <span style="color: #0000ff;">float</span> deltaY = curY -<span style="color: #000000;"> downY;
</span><span style="color: #008080;">179</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 是否是有效的往下拖动事件（则需要显示加载header）</span>
<span style="color: #008080;">180</span>                 <span style="color: #0000ff;">boolean</span> isDropDownValidate = Float.MAX_VALUE !=<span style="color: #000000;"> downY;
</span><span style="color: #008080;">181</span>                 <span style="color: #008000;">/**</span>
<span style="color: #008080;">182</span> <span style="color: #008000;">                 * 修改拦截设置
</span><span style="color: #008080;">183</span> <span style="color: #008000;">                 * 如果是有效往下拖动事件，则事件需要在本ViewGroup中处理，所以需要拦截不往子控件传递，即不允许拦截设为false
</span><span style="color: #008080;">184</span> <span style="color: #008000;">                 * 如果是有效往下拖动事件，则事件传递给子控件处理，所以不需要拦截，并往子控件传递，即不允许拦截设为true
</span><span style="color: #008080;">185</span>                  <span style="color: #008000;">*/</span>
<span style="color: #008080;">186</span>                 requestDisallowInterceptTouchEvent(!<span style="color: #000000;">isDropDownValidate);
</span><span style="color: #008080;">187</span> 
<span style="color: #008080;">188</span>                 downY =<span style="color: #000000;"> curY;
</span><span style="color: #008080;">189</span>                 Log.d(TAG, "Move --&gt; deltaY(curY - downY): " +<span style="color: #000000;"> deltaY);
</span><span style="color: #008080;">190</span>                 <span style="color: #0000ff;">int</span> curHeight =<span style="color: #000000;"> refreshHeaderView.getMeasuredHeight();
</span><span style="color: #008080;">191</span>                 <span style="color: #0000ff;">int</span> exceptHeight = curHeight + (<span style="color: #0000ff;">int</span>) (deltaY / 2<span style="color: #000000;">);
</span><span style="color: #008080;">192</span> 
<span style="color: #008080;">193</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 如果当前没有处在正在刷新状态，则更新刷新状态</span>
<span style="color: #008080;">194</span>                 <span style="color: #0000ff;">if</span> (STATE_REFRESHING !=<span style="color: #000000;"> refreshState) {
</span><span style="color: #008080;">195</span>                     <span style="color: #0000ff;">if</span> (curHeight &gt;= refreshArrivedStateHeight) { <span style="color: #008000;">//</span><span style="color: #008000;"> 达到可刷新状态</span>
<span style="color: #008080;">196</span> <span style="color: #000000;">                        setRefreshState(STATE_REFRESH_ARRIVED);
</span><span style="color: #008080;">197</span>                     } <span style="color: #0000ff;">else</span> { <span style="color: #008000;">//</span><span style="color: #008000;"> 未达到可刷新状态</span>
<span style="color: #008080;">198</span> <span style="color: #000000;">                        setRefreshState(STATE_REFRESH_NOT_ARRIVED);
</span><span style="color: #008080;">199</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">200</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">201</span>                 <span style="color: #0000ff;">if</span><span style="color: #000000;"> (isDropDownValidate) {
</span><span style="color: #008080;">202</span> <span style="color: #000000;">                    changeViewHeight(refreshHeaderView, Math.max(refreshNormalHeight, exceptHeight));
</span><span style="color: #008080;">203</span>                 } <span style="color: #0000ff;">else</span> { <span style="color: #008000;">//</span><span style="color: #008000;"> 防止从子控件修改拦截后引发的downY为Float.MAX_VALUE的问题</span>
<span style="color: #008080;">204</span> <span style="color: #000000;">                    changeViewHeight(refreshHeaderView, Math.max(curHeight, exceptHeight));
</span><span style="color: #008080;">205</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">206</span> 
<span style="color: #008080;">207</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">208</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_UP:
</span><span style="color: #008080;">209</span>                 downY =<span style="color: #000000;"> Float.MAX_VALUE;
</span><span style="color: #008080;">210</span>                 Log.d(TAG, "Up --&gt; downY: " +<span style="color: #000000;"> downY);
</span><span style="color: #008080;">211</span>                 requestDisallowInterceptTouchEvent(<span style="color: #0000ff;">true</span>); <span style="color: #008000;">//</span><span style="color: #008000;"> 保证事件可往下传递
</span><span style="color: #008080;">212</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 如果是达到刷新状态，则设置正在刷新状态的高度</span>
<span style="color: #008080;">213</span>                 <span style="color: #0000ff;">if</span> (STATE_REFRESH_ARRIVED == refreshState) { <span style="color: #008000;">//</span><span style="color: #008000;"> 达到了刷新的状态</span>
<span style="color: #008080;">214</span> <span style="color: #000000;">                    startHeightAnimation(refreshHeaderView, refreshHeaderView.getMeasuredHeight(), refreshingHeight);
</span><span style="color: #008080;">215</span> <span style="color: #000000;">                    setRefreshState(STATE_REFRESHING);
</span><span style="color: #008080;">216</span>                 } <span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span> (STATE_REFRESHING == refreshState) { <span style="color: #008000;">//</span><span style="color: #008000;"> 正在刷新的状态</span>
<span style="color: #008080;">217</span> <span style="color: #000000;">                    startHeightAnimation(refreshHeaderView, refreshHeaderView.getMeasuredHeight(), refreshingHeight);
</span><span style="color: #008080;">218</span>                 } <span style="color: #0000ff;">else</span><span style="color: #000000;"> {
</span><span style="color: #008080;">219</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 执行动画后回归正常状态</span>
<span style="color: #008080;">220</span> <span style="color: #000000;">                    startHeightAnimation(refreshHeaderView, refreshHeaderView.getMeasuredHeight(), refreshNormalHeight, normalAnimatorListener);
</span><span style="color: #008080;">221</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">222</span> 
<span style="color: #008080;">223</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">224</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_CANCEL:
</span><span style="color: #008080;">225</span>                 Log.d(TAG, "cancel"<span style="color: #000000;">);
</span><span style="color: #008080;">226</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">227</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">228</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">229</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">230</span> 
<span style="color: #008080;">231</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">232</span> <span style="color: #008000;">     * 刷新完毕后调用此方法
</span><span style="color: #008080;">233</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">234</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCompleteRefresh() {
</span><span style="color: #008080;">235</span>         <span style="color: #0000ff;">if</span> (STATE_REFRESHING ==<span style="color: #000000;"> refreshState) {
</span><span style="color: #008080;">236</span> <span style="color: #000000;">            setRefreshState(STATE_REFRESH_NORMAL);
</span><span style="color: #008080;">237</span> <span style="color: #000000;">            startHeightAnimation(refreshHeaderView, refreshHeaderView.getMeasuredHeight(), refreshNormalHeight);
</span><span style="color: #008080;">238</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">239</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">240</span> 
<span style="color: #008080;">241</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">242</span> <span style="color: #008000;">     * 修改当前的刷新状态
</span><span style="color: #008080;">243</span> <span style="color: #008000;">     *
</span><span style="color: #008080;">244</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> expectRefreshState
</span><span style="color: #008080;">245</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">246</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> setRefreshState(<span style="color: #0000ff;">int</span><span style="color: #000000;"> expectRefreshState) {
</span><span style="color: #008080;">247</span>         <span style="color: #0000ff;">if</span> (expectRefreshState !=<span style="color: #000000;"> refreshState) {
</span><span style="color: #008080;">248</span>             refreshState =<span style="color: #000000;"> expectRefreshState;
</span><span style="color: #008080;">249</span>             <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> refreshableHelper) {
</span><span style="color: #008080;">250</span> <span style="color: #000000;">                refreshableHelper.onRefreshStateChanged(refreshHeaderView, refreshState);
</span><span style="color: #008080;">251</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">252</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">253</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">254</span> 
<span style="color: #008080;">255</span> 
<span style="color: #008080;">256</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">257</span> <span style="color: #008000;">     * 改变某控件的高度
</span><span style="color: #008080;">258</span> <span style="color: #008000;">     *
</span><span style="color: #008080;">259</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> view
</span><span style="color: #008080;">260</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> height
</span><span style="color: #008080;">261</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">262</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> changeViewHeight(View view, <span style="color: #0000ff;">int</span><span style="color: #000000;"> height) {
</span><span style="color: #008080;">263</span>         Log.d(TAG, "[changeViewHeight]change Height: " +<span style="color: #000000;"> height);
</span><span style="color: #008080;">264</span>         ViewGroup.LayoutParams lp =<span style="color: #000000;"> view.getLayoutParams();
</span><span style="color: #008080;">265</span>         lp.height =<span style="color: #000000;"> height;
</span><span style="color: #008080;">266</span> <span style="color: #000000;">        view.setLayoutParams(lp);
</span><span style="color: #008080;">267</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">268</span> 
<span style="color: #008080;">269</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">270</span> <span style="color: #008000;">     * 改变某控件的高度动画
</span><span style="color: #008080;">271</span> <span style="color: #008000;">     *
</span><span style="color: #008080;">272</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> view
</span><span style="color: #008080;">273</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> fromHeight
</span><span style="color: #008080;">274</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> toHeight
</span><span style="color: #008080;">275</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">276</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> startHeightAnimation(<span style="color: #0000ff;">final</span> View view, <span style="color: #0000ff;">int</span> fromHeight, <span style="color: #0000ff;">int</span><span style="color: #000000;"> toHeight) {
</span><span style="color: #008080;">277</span>         startHeightAnimation(view, fromHeight, toHeight, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
</span><span style="color: #008080;">278</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">279</span> 
<span style="color: #008080;">280</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> startHeightAnimation(<span style="color: #0000ff;">final</span> View view, <span style="color: #0000ff;">int</span> fromHeight, <span style="color: #0000ff;">int</span><span style="color: #000000;"> toHeight, Animator.AnimatorListener animatorListener) {
</span><span style="color: #008080;">281</span>         <span style="color: #0000ff;">if</span> (toHeight ==<span style="color: #000000;"> view.getMeasuredHeight()) {
</span><span style="color: #008080;">282</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">283</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">284</span>         ValueAnimator heightAnimator =<span style="color: #000000;"> ValueAnimator.ofInt(fromHeight, toHeight);
</span><span style="color: #008080;">285</span>         heightAnimator.addUpdateListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> ValueAnimator.AnimatorUpdateListener() {
</span><span style="color: #008080;">286</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">287</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onAnimationUpdate(ValueAnimator valueAnimator) {
</span><span style="color: #008080;">288</span>                 Integer value =<span style="color: #000000;"> (Integer) valueAnimator.getAnimatedValue();
</span><span style="color: #008080;">289</span>                 <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> == value) <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">290</span> <span style="color: #000000;">                changeViewHeight(view, value);
</span><span style="color: #008080;">291</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">292</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">293</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> animatorListener) {
</span><span style="color: #008080;">294</span> <span style="color: #000000;">            heightAnimator.addListener(animatorListener);
</span><span style="color: #008080;">295</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">296</span>         heightAnimator.setInterpolator(<span style="color: #0000ff;">new</span><span style="color: #000000;"> LinearInterpolator());
</span><span style="color: #008080;">297</span>         heightAnimator.setDuration(300<span style="color: #008000;">/*</span><span style="color: #008000;">ms</span><span style="color: #008000;">*/</span><span style="color: #000000;">);
</span><span style="color: #008080;">298</span> <span style="color: #000000;">        heightAnimator.start();
</span><span style="color: #008080;">299</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">300</span> 
<span style="color: #008080;">301</span>     AnimatorListenerAdapter normalAnimatorListener = <span style="color: #0000ff;">new</span><span style="color: #000000;"> AnimatorListenerAdapter() {
</span><span style="color: #008080;">302</span> <span style="color: #000000;">        @Override
</span><span style="color: #008080;">303</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onAnimationEnd(Animator animation) {
</span><span style="color: #008080;">304</span>             <span style="color: #0000ff;">super</span><span style="color: #000000;">.onAnimationEnd(animation);
</span><span style="color: #008080;">305</span>             setRefreshState(STATE_REFRESH_NORMAL); <span style="color: #008000;">//</span><span style="color: #008000;"> 回归正常状态</span>
<span style="color: #008080;">306</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">307</span> <span style="color: #000000;">    };
</span><span style="color: #008080;">308</span> 
<span style="color: #008080;">309</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setRefreshArrivedStateHeight(<span style="color: #0000ff;">int</span><span style="color: #000000;"> refreshArrivedStateHeight) {
</span><span style="color: #008080;">310</span>         <span style="color: #0000ff;">this</span>.refreshArrivedStateHeight =<span style="color: #000000;"> refreshArrivedStateHeight;
</span><span style="color: #008080;">311</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">312</span> 
<span style="color: #008080;">313</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setRefreshingHeight(<span style="color: #0000ff;">int</span><span style="color: #000000;"> refreshingHeight) {
</span><span style="color: #008080;">314</span>         <span style="color: #0000ff;">this</span>.refreshingHeight =<span style="color: #000000;"> refreshingHeight;
</span><span style="color: #008080;">315</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">316</span> 
<span style="color: #008080;">317</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setRefreshNormalHeight(<span style="color: #0000ff;">int</span><span style="color: #000000;"> refreshNormalHeight) {
</span><span style="color: #008080;">318</span>         <span style="color: #0000ff;">this</span>.refreshNormalHeight =<span style="color: #000000;"> refreshNormalHeight;
</span><span style="color: #008080;">319</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">320</span> 
<span style="color: #008080;">321</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getOriginRefreshHeight() {
</span><span style="color: #008080;">322</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> originRefreshHeight;
</span><span style="color: #008080;">323</span>     }</pre>
</div>

其中：

originRefreshHeight，表示头部刷新view的实际高度。

refreshArrivedStateHeight，表示下拉多少距离可以执行刷新了

refreshingHeight，表示刷新的时候显示的高度时多少

refreshNormalHeight，表示正常状态下refreshHeaderView显示的高度是多少

&nbsp;

主要的核心代码应该是在onTouchEvent方法中，

先简单分析里面的主要代码：在ACTION_DOWN的时候，纪录当前手指下落的y坐标，然后再ACTION_MOVE的时候，去计算滑动的距离，并且判断如果滑动的距离大于refreshArrivedStateHeight，更新处于已经达到可刷新的状态，反之就更新处于未达到可刷新的状态。然后再ACTION_UP中，如果已经达到了可刷新的状态，则更新当前状态为正在刷新状态，并且回调状态改变的方法。

&nbsp;

如果里面有ScrollView等可以滚动的控件的时候，应该怎么处理里面的事件呢？

就以[https://github.com/wangjiegulu/RefreshableView](https://github.com/wangjiegulu/RefreshableView)&nbsp;为例

xml布局如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">com.wangjie.refreshableview.RefreshableView
</span><span style="color: #008080;"> 2</span>             <span style="color: #ff0000;">xmlns:rv</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/com.wangjie.refreshableview"</span>
<span style="color: #008080;"> 3</span> <span style="color: #ff0000;">            android:id</span><span style="color: #0000ff;">="@+id/main_refresh_view"</span>
<span style="color: #008080;"> 4</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;"> 5</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;"> 6</span> <span style="color: #ff0000;">            rv:interceptAllMoveEvents</span><span style="color: #0000ff;">="false"</span>
<span style="color: #008080;"> 7</span>             <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 8</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">com.wangjie.refreshableview.NestScrollView </span><span style="color: #ff0000;">android:layout_width</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;"> android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;"> 9</span> <span style="color: #ff0000;">                android:fillViewport</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;">10</span>                 <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">11</span> 
<span style="color: #008080;">12</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TextView
</span><span style="color: #008080;">13</span>                     <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/main_tv"</span>
<span style="color: #008080;">14</span> <span style="color: #ff0000;">                    android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">15</span> <span style="color: #ff0000;">                    android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;">16</span> <span style="color: #ff0000;">                    android:gravity</span><span style="color: #0000ff;">="center"</span>
<span style="color: #008080;">17</span> <span style="color: #ff0000;">                    android:padding</span><span style="color: #0000ff;">="20dp"</span>
<span style="color: #008080;">18</span> <span style="color: #ff0000;">                    android:textSize</span><span style="color: #0000ff;">="18sp"</span>
<span style="color: #008080;">19</span> <span style="color: #ff0000;">                    android:text</span><span style="color: #0000ff;">="Drop Down For Refresh\n\n\n\n\n\n\n\n\n\n\nDrop Down For Refresh\nDrop Down For Refresh\n\n\n\n\n\n\n\n\n\n\nDrop Down For Refresh\nDrop Down For Refresh\n\n\n\n\n\n\n\n\n\n\nDrop Down For Refresh\nDrop Down For Refresh\n\n\n\n\n\n\n\n\n\n\nDrop Down For Refresh"</span>
<span style="color: #008080;">20</span>                     <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span>         <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">com.wangjie.refreshableview.NestScrollView</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">23</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">com.wangjie.refreshableview.RefreshableView</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

如上，最外面是一个RefreshableView，然后里面是一个NestScrollView，NestScrollView里面是TextView，其中TextView中因为文字较多，所以使用NestScrollView来实现滚动（NestScrollView扩展自ScrollView，下面会讲到）。这个时候的逻辑应该是，当NestScrollView处于顶部的时候，手指向下滑动，这时这个touch事件应该交给RefreshableView处理；当手指向上滑动时，也就是ScrollView向下滚动，这时，需要把touch事件给RefreshableView来处理。

&nbsp;

下面分析里面的代码：

RefreshableView的interceptAllMoveEvents表示是否需要RefreshableView阻止所有MOVE的事件（也就是说由RefreshableView自己处理所有MOVE事件），如果自控件中没有ScrollView等需要处理MOVE事件的控件，则可以设置为true；如果有类似ScrollView等控件，则需要设置为false，这样的话，RefreshableView会把MOVE事件传递给子类，由子类去处理。显然，现在例子中的情况是需要把interceptAllMoveEvents设置为false。设置的方法可以看上面的xml文件，使用rv:interceptAllMoveEvents="false"这个属性即可。

onInterceptTouchEvent()方法中，我们返回的是disallowIntercept，这个disallowIntercept是根据requestDisallowInterceptTouchEvent()方法的调用来动态变化的，这样可以做到切换touch事件的处理对象。

在手指落下的时候，先调用requestDisallowInterceptTouchEvent()方法，保证当前的事件可以正常往子控件传递，也就是现在的ScrollView。然后手指会开始移动，在ACTION_MOVE中，先计算出当前滑动的距离。

如果是有效往下拖动事件，则事件需要在RefreshableView中处理，所以需要拦截不往子控件传递，即不允许拦截设为false；如果不是有效往下拖动事件，则事件传递给子控件处理，所以不需要拦截，并往子控件传递，即不允许拦截设为true。

怎么去判断是否有效呢？根据downY，如果downY是原来的初始值Float.MAX_VALUE，说明，这个MOVE事件刚开始DOWN的时候是被子控件处理的，而不是RefreshableView处理的，说明对于RefreshableView来说，是一个无效的往下拖动事件；如果downY不是原来的初始值Float.MAX_VALUE，说明，这个MOVE事件在DOWN的时候就已经是RefreshableView处理的了，所以是有效的。

然后，计算refreshHeaderView的高度，根据滑动的差量对refreshHeaderView的高度进行变换。

如果当前的状态是正在刷新，那MOVE事件直接无效。

否则，再去判断当前的高度是不是达到了可刷新状态，或者没有达到可刷新状态，更新状态值。

在UP的时候，还是先保证事件往下传递。并重置downY。然后根据当前的状态，如果达到了刷新的状态，则开始刷新，并更新当前的额状态时正在刷新状态；如果没有达到刷新状态，则执行动画返回到正常状态；如果本来就是正在刷新状态，也执行动画回归到正在刷新的高度。

&nbsp;

然后分析下NestScrollView：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 12/13/14.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> NestScrollView <span style="color: #0000ff;">extends</span><span style="color: #000000;"> ScrollView {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = NestScrollView.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> NestScrollView(Context context) {
</span><span style="color: #008080;">10</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context);
</span><span style="color: #008080;">11</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> NestScrollView(Context context, AttributeSet attrs) {
</span><span style="color: #008080;">14</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs);
</span><span style="color: #008080;">15</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">public</span> NestScrollView(Context context, AttributeSet attrs, <span style="color: #0000ff;">int</span><span style="color: #000000;"> defStyle) {
</span><span style="color: #008080;">18</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs, defStyle);
</span><span style="color: #008080;">19</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">22</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> dispatchTouchEvent(MotionEvent ev) {
</span><span style="color: #008080;">23</span>         Log.d(TAG, "___[dispatchTouchEvent]ev action: " +<span style="color: #000000;"> ev.getAction());
</span><span style="color: #008080;">24</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">super</span><span style="color: #000000;">.dispatchTouchEvent(ev);
</span><span style="color: #008080;">25</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">28</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onInterceptTouchEvent(MotionEvent ev) {
</span><span style="color: #008080;">29</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onInterceptTouchEvent(ev);
</span><span style="color: #008080;">30</span>         Log.d(TAG, "___[onInterceptTouchEvent]ev action: " +<span style="color: #000000;"> ev.getAction());
</span><span style="color: #008080;">31</span>         <span style="color: #0000ff;">if</span> (MotionEvent.ACTION_MOVE ==<span style="color: #000000;"> ev.getAction()) {
</span><span style="color: #008080;">32</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">33</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">34</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">35</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">36</span> 
<span style="color: #008080;">37</span>     <span style="color: #0000ff;">float</span><span style="color: #000000;"> lastDownY;
</span><span style="color: #008080;">38</span> 
<span style="color: #008080;">39</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">40</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onTouchEvent(MotionEvent event) {
</span><span style="color: #008080;">41</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onTouchEvent(event);
</span><span style="color: #008080;">42</span>         <span style="color: #0000ff;">switch</span><span style="color: #000000;"> (event.getAction()) {
</span><span style="color: #008080;">43</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_DOWN:
</span><span style="color: #008080;">44</span>                 lastDownY =<span style="color: #000000;"> event.getY();
</span><span style="color: #008080;">45</span>                 parentRequestDisallowInterceptTouchEvent(<span style="color: #0000ff;">true</span>); <span style="color: #008000;">//</span><span style="color: #008000;"> 保证事件可往下传递</span>
<span style="color: #008080;">46</span>                 Log.d(TAG, "___Down"<span style="color: #000000;">);
</span><span style="color: #008080;">47</span>                 <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">48</span> <span style="color: #008000;">//</span><span style="color: #008000;">                break;</span>
<span style="color: #008080;">49</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_MOVE:
</span><span style="color: #008080;">50</span>                 Log.d(TAG, "___move, this.getScrollY(): " + <span style="color: #0000ff;">this</span><span style="color: #000000;">.getScrollY());
</span><span style="color: #008080;">51</span>                 <span style="color: #0000ff;">boolean</span> isTop = event.getY() - lastDownY &gt; 0 &amp;&amp; <span style="color: #0000ff;">this</span>.getScrollY() == 0<span style="color: #000000;">;
</span><span style="color: #008080;">52</span>                 <span style="color: #0000ff;">if</span> (isTop) { <span style="color: #008000;">//</span><span style="color: #008000;"> 允许父控件拦截，即不允许父控件拦截设为false</span>
<span style="color: #008080;">53</span>                     parentRequestDisallowInterceptTouchEvent(<span style="color: #0000ff;">false</span><span style="color: #000000;">);
</span><span style="color: #008080;">54</span>                     <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">55</span>                 } <span style="color: #0000ff;">else</span> { <span style="color: #008000;">//</span><span style="color: #008000;"> 不允许父控件拦截，即不允许父控件拦截设为true</span>
<span style="color: #008080;">56</span>                     parentRequestDisallowInterceptTouchEvent(<span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;">57</span>                     <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">58</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">59</span> <span style="color: #008000;">//</span><span style="color: #008000;">                break;</span>
<span style="color: #008080;">60</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_UP:
</span><span style="color: #008080;">61</span>                 Log.d(TAG, "___up, this.getScrollY(): " + <span style="color: #0000ff;">this</span><span style="color: #000000;">.getScrollY());
</span><span style="color: #008080;">62</span>                 parentRequestDisallowInterceptTouchEvent(<span style="color: #0000ff;">true</span>); <span style="color: #008000;">//</span><span style="color: #008000;"> 保证事件可往下传递</span>
<span style="color: #008080;">63</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">64</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> MotionEvent.ACTION_CANCEL:
</span><span style="color: #008080;">65</span>                 Log.d(TAG, "___cancel"<span style="color: #000000;">);
</span><span style="color: #008080;">66</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">67</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">68</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">69</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">70</span> 
<span style="color: #008080;">71</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">72</span> <span style="color: #008000;">     * 是否允许父控件拦截事件
</span><span style="color: #008080;">73</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> disallowIntercept
</span><span style="color: #008080;">74</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">75</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> parentRequestDisallowInterceptTouchEvent(<span style="color: #0000ff;">boolean</span><span style="color: #000000;"> disallowIntercept) {
</span><span style="color: #008080;">76</span>         ViewParent vp =<span style="color: #000000;"> getParent();
</span><span style="color: #008080;">77</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> vp) {
</span><span style="color: #008080;">78</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">79</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">80</span> <span style="color: #000000;">        vp.requestDisallowInterceptTouchEvent(disallowIntercept);
</span><span style="color: #008080;">81</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">82</span> 
<span style="color: #008080;">83</span> }</pre>
</div>

如上所示，也需要重写onInterceptTouchEvent()方法，它需要把除了MOVE事件外的所有事件传递下去，这样最里面的TextView才有OnClick等事件。

在onTouchEvent方法中，在ACTION_DOWN的时候，先纪录down的y坐标，然后保证parent（即，RefreshableView）的事件可以传递过来，所以需要调用getParent().requestDisallowInterceptTouchEvent()方法。因为下拉刷新只能发生在ScrollView滚动条在顶部的时候，所以在MOVE中，如果当前状态在顶部，那就需要让父控件（RefreshableView）拦截，然后直接返回false，让当前的事件传递到RefreshableView中的onTouchEvent方法中处理。如果不是在top，那就屏蔽调用父控件（RefreshableView）的处理，直接自己处理。最后在UP的时候再确保事件可以传递到ScrollView这里来。

&nbsp;

