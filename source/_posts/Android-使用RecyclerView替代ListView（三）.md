---
title: '[Android]使用RecyclerView替代ListView（三）'
tags: [android, RecyclerView, ListView, best practices]
date: 2015-02-02 16:32:00
---

&nbsp;

这次来使用RecyclerView实现PinnedListView的效果，效果很常见：

![](http://images.cnitblog.com/blog/378300/201502/021602294536998.gif)

开发的代码建立在上一篇（**[[Android]使用RecyclerView替代ListView（二）](http://www.cnblogs.com/tiantianbyconan/p/4242541.html)：[http://www.cnblogs.com/tiantianbyconan/p/4242541.html](http://www.cnblogs.com/tiantianbyconan/p/4242541.html)**）基础之上。

修改布局如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span>
<span style="color: #008080;"> 4</span> <span style="color: #ff0000;">              android:orientation</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;"> 5</span> <span style="color: #ff0000;">              android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;"> 6</span> <span style="color: #ff0000;">              android:layout_height</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">android.support.v7.widget.Toolbar
</span><span style="color: #008080;"> 9</span>             <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/recycler_view_pinned_toolbar"</span>
<span style="color: #008080;">10</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;">11</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">12</span> <span style="color: #ff0000;">            android:background</span><span style="color: #0000ff;">="?attr/colorPrimary"</span>
<span style="color: #008080;">13</span>             <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">14</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">android.support.v4.widget.SwipeRefreshLayout
</span><span style="color: #008080;">15</span>             <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/recycler_view_pinned_srl"</span>
<span style="color: #008080;">16</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">17</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;">18</span>             <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">com.wangjie.androidbucket.support.recyclerview.pinnedlayout.PinnedRecyclerViewLayout
</span><span style="color: #008080;">21</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/recycler_view_pinned_layout"</span>
<span style="color: #008080;">22</span> <span style="color: #ff0000;">                android:layout_width</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;"> android:layout_height</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">23</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">android.support.v7.widget.RecyclerView
</span><span style="color: #008080;">24</span>                     <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/recycler_view_pinned_rv"</span>
<span style="color: #008080;">25</span> <span style="color: #ff0000;">                    android:scrollbars</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;">26</span> <span style="color: #ff0000;">                    android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">27</span> <span style="color: #ff0000;">                    android:layout_height</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">28</span> <span style="color: #ff0000;">                    android:background</span><span style="color: #0000ff;">="#bbccaa"</span>
<span style="color: #008080;">29</span>                     <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">30</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">Button
</span><span style="color: #008080;">31</span>                     <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/recycler_view_pinned_add_btn"</span>
<span style="color: #008080;">32</span> <span style="color: #ff0000;">                    android:layout_width</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;"> android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;">33</span> <span style="color: #ff0000;">                    android:layout_centerVertical</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;">34</span> <span style="color: #ff0000;">                    android:background</span><span style="color: #0000ff;">="#abcabc"</span>
<span style="color: #008080;">35</span> <span style="color: #ff0000;">                    android:text</span><span style="color: #0000ff;">="add"</span>
<span style="color: #008080;">36</span>                     <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">37</span> 
<span style="color: #008080;">38</span>         <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">com.wangjie.androidbucket.support.recyclerview.pinnedlayout.PinnedRecyclerViewLayout</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">39</span> 
<span style="color: #008080;">40</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">android.support.v4.widget.SwipeRefreshLayout</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">41</span> 
<span style="color: #008080;">42</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

可以看到RecyclerView是被一个**[PinnedRecyclerViewLayout](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/pinnedlayout/PinnedRecyclerViewLayout.java)（[https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/pinnedlayout/PinnedRecyclerViewLayout.java](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/pinnedlayout/PinnedRecyclerViewLayout.java)）**包含在里面的。这个在项目**[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)（[https://github.com/wangjiegulu/AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)）**中。先看看代码中怎么使用吧，具体实现待会说。

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> pinnedLayout.initRecyclerPinned(recyclerView, layoutManager, LayoutInflater.from(context).inflate(R.layout.recycler_view_item_float, <span style="color: #0000ff;">null</span><span style="color: #000000;">));
</span><span style="color: #008080;">2</span> pinnedLayout.setOnRecyclerViewPinnedViewListener(<span style="color: #0000ff;">this</span>);</pre>
</div>

如上，使用方式很简单：

Line1：初始化绑定PinnedRecyclerViewLayout和RecyclerView，并设置需要被顶上去的pinnedView

Line2：设置OnRecyclerViewPinnedViewListener，作用是在顶部被顶上去替换掉的时候，会回调重新渲染数据，传入的OnRecyclerViewPinnedViewListener是this，显然，此Activity实现了这个接口，实现代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">//</span><span style="color: #008000;"> 渲染pinnedView数据</span>
<span style="color: #008080;"> 2</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 3</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onPinnedViewRender(PinnedRecyclerViewLayout pinnedRecyclerViewLayout, View pinnedView, <span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {
</span><span style="color: #008080;"> 4</span>         <span style="color: #0000ff;">switch</span><span style="color: #000000;"> (pinnedRecyclerViewLayout.getId()) {
</span><span style="color: #008080;"> 5</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.recycler_view_pinned_layout:
</span><span style="color: #008080;"> 6</span>                 TextView nameTv =<span style="color: #000000;"> (TextView) pinnedView.findViewById(R.id.recycler_view_item_float_name_tv);
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">                nameTv.setText(personList.get(position).getName());
</span><span style="color: #008080;"> 8</span>                 TextView ageTv =<span style="color: #000000;"> (TextView) pinnedView.findViewById(R.id.recycler_view_item_float_age_tv);
</span><span style="color: #008080;"> 9</span>                 ageTv.setText(personList.get(position).getAge() + "岁"<span style="color: #000000;">);
</span><span style="color: #008080;">10</span>                 <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">11</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">12</span>     }</pre>
</div>

然后，我们来看看**[PinnedRecyclerViewLayout](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/pinnedlayout/PinnedRecyclerViewLayout.java)**是怎么实现的。

<div class="cnblogs_code">
<pre><span style="color: #008080;">  1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">  2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;">  3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;">  4</span> <span style="color: #008000;"> * Date: 2/2/15.
</span><span style="color: #008080;">  5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">  6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> PinnedRecyclerViewLayout <span style="color: #0000ff;">extends</span><span style="color: #000000;"> RelativeLayout {
</span><span style="color: #008080;">  7</span> 
<span style="color: #008080;">  8</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = PinnedRecyclerViewLayout.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;">  9</span> 
<span style="color: #008080;"> 10</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> OnRecyclerViewPinnedViewListener {
</span><span style="color: #008080;"> 11</span>         <span style="color: #0000ff;">void</span> onPinnedViewRender(PinnedRecyclerViewLayout pinnedRecyclerViewLayout, View pinnedView, <span style="color: #0000ff;">int</span><span style="color: #000000;"> position);
</span><span style="color: #008080;"> 12</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 13</span> 
<span style="color: #008080;"> 14</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> OnRecyclerViewPinnedViewListener onRecyclerViewPinnedViewListener;
</span><span style="color: #008080;"> 15</span> 
<span style="color: #008080;"> 16</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOnRecyclerViewPinnedViewListener(OnRecyclerViewPinnedViewListener onRecyclerViewPinnedViewListener) {
</span><span style="color: #008080;"> 17</span>         <span style="color: #0000ff;">this</span>.onRecyclerViewPinnedViewListener =<span style="color: #000000;"> onRecyclerViewPinnedViewListener;
</span><span style="color: #008080;"> 18</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 19</span> 
<span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> PinnedRecyclerViewLayout(Context context) {
</span><span style="color: #008080;"> 21</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context);
</span><span style="color: #008080;"> 22</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 23</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 24</span> 
<span style="color: #008080;"> 25</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> PinnedRecyclerViewLayout(Context context, AttributeSet attrs) {
</span><span style="color: #008080;"> 26</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs);
</span><span style="color: #008080;"> 27</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 28</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 29</span> 
<span style="color: #008080;"> 30</span>     <span style="color: #0000ff;">public</span> PinnedRecyclerViewLayout(Context context, AttributeSet attrs, <span style="color: #0000ff;">int</span><span style="color: #000000;"> defStyleAttr) {
</span><span style="color: #008080;"> 31</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs, defStyleAttr);
</span><span style="color: #008080;"> 32</span> <span style="color: #000000;">        init(context);
</span><span style="color: #008080;"> 33</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 34</span> 
<span style="color: #008080;"> 35</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> init(Context context) {
</span><span style="color: #008080;"> 36</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 37</span> 
<span style="color: #008080;"> 38</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> View pinnedView;
</span><span style="color: #008080;"> 39</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> ABaseLinearLayoutManager layoutManager;
</span><span style="color: #008080;"> 40</span> 
<span style="color: #008080;"> 41</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> initRecyclerPinned(RecyclerView recyclerView, ABaseLinearLayoutManager layoutManager, View pinnedView) {
</span><span style="color: #008080;"> 42</span>         <span style="color: #0000ff;">this</span>.pinnedView =<span style="color: #000000;"> pinnedView;
</span><span style="color: #008080;"> 43</span>         <span style="color: #0000ff;">this</span>.layoutManager =<span style="color: #000000;"> layoutManager;
</span><span style="color: #008080;"> 44</span>         <span style="color: #0000ff;">this</span>.addView(<span style="color: #0000ff;">this</span><span style="color: #000000;">.pinnedView);
</span><span style="color: #008080;"> 45</span>         RelativeLayout.LayoutParams lp = <span style="color: #0000ff;">new</span><span style="color: #000000;"> RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
</span><span style="color: #008080;"> 46</span>         <span style="color: #0000ff;">this</span><span style="color: #000000;">.pinnedView.setLayoutParams(lp);
</span><span style="color: #008080;"> 47</span>         layoutManager.getRecyclerViewScrollManager().addScrollListener(recyclerView, <span style="color: #0000ff;">new</span><span style="color: #000000;"> OnRecyclerViewScrollListener() {
</span><span style="color: #008080;"> 48</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;"> 49</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onScrollStateChanged(RecyclerView recyclerView, <span style="color: #0000ff;">int</span><span style="color: #000000;"> newState) {
</span><span style="color: #008080;"> 50</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 51</span> 
<span style="color: #008080;"> 52</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;"> 53</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onScrolled(RecyclerView recyclerView, <span style="color: #0000ff;">int</span> dx, <span style="color: #0000ff;">int</span><span style="color: #000000;"> dy) {
</span><span style="color: #008080;"> 54</span> <span style="color: #000000;">                refreshPinnedView();
</span><span style="color: #008080;"> 55</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 56</span> <span style="color: #000000;">        });
</span><span style="color: #008080;"> 57</span> <span style="color: #000000;">        pinnedView.setVisibility(GONE);
</span><span style="color: #008080;"> 58</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 59</span> 
<span style="color: #008080;"> 60</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 保存上次的position</span>
<span style="color: #008080;"> 61</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> lastPosition =<span style="color: #000000;"> RecyclerView.NO_POSITION;
</span><span style="color: #008080;"> 62</span> 
<span style="color: #008080;"> 63</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> refreshPinnedView() {
</span><span style="color: #008080;"> 64</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> == pinnedView || <span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> layoutManager) {
</span><span style="color: #008080;"> 65</span>             Logger.e(TAG, "Please init pinnedView and layoutManager with initRecyclerPinned method first!"<span style="color: #000000;">);
</span><span style="color: #008080;"> 66</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 67</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 68</span>         <span style="color: #0000ff;">if</span> (VISIBLE !=<span style="color: #000000;"> pinnedView.getVisibility()) {
</span><span style="color: #008080;"> 69</span> <span style="color: #000000;">            pinnedView.setVisibility(VISIBLE);
</span><span style="color: #008080;"> 70</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 71</span>         <span style="color: #0000ff;">int</span> curPosition =<span style="color: #000000;"> layoutManager.findFirstVisibleItemPosition();
</span><span style="color: #008080;"> 72</span>         <span style="color: #0000ff;">if</span> (RecyclerView.NO_POSITION ==<span style="color: #000000;"> curPosition) {
</span><span style="color: #008080;"> 73</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 74</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 75</span>         View curItemView =<span style="color: #000000;"> layoutManager.findViewByPosition(curPosition);
</span><span style="color: #008080;"> 76</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> curItemView) {
</span><span style="color: #008080;"> 77</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 78</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 79</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 如果当前的curPosition和上次的lastPosition不一样，则说明需要重新刷新数据，避免curPosition一样的情况下重复刷新相同数据</span>
<span style="color: #008080;"> 80</span>         <span style="color: #0000ff;">if</span> (curPosition !=<span style="color: #000000;"> lastPosition) {
</span><span style="color: #008080;"> 81</span>             <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> onRecyclerViewPinnedViewListener) {
</span><span style="color: #008080;"> 82</span>                 onRecyclerViewPinnedViewListener.onPinnedViewRender(<span style="color: #0000ff;">this</span><span style="color: #000000;">, pinnedView, curPosition);
</span><span style="color: #008080;"> 83</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 84</span>             lastPosition =<span style="color: #000000;"> curPosition;
</span><span style="color: #008080;"> 85</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 86</span> 
<span style="color: #008080;"> 87</span>         <span style="color: #0000ff;">int</span><span style="color: #000000;"> displayTop;
</span><span style="color: #008080;"> 88</span>         <span style="color: #0000ff;">int</span> itemHeight =<span style="color: #000000;"> curItemView.getHeight();
</span><span style="color: #008080;"> 89</span>         <span style="color: #0000ff;">int</span> curTop =<span style="color: #000000;"> curItemView.getTop();
</span><span style="color: #008080;"> 90</span>         <span style="color: #0000ff;">int</span> floatHeight =<span style="color: #000000;"> pinnedView.getHeight();
</span><span style="color: #008080;"> 91</span>         <span style="color: #0000ff;">if</span> (curTop &lt; floatHeight -<span style="color: #000000;"> itemHeight) {
</span><span style="color: #008080;"> 92</span>             displayTop = itemHeight + curTop -<span style="color: #000000;"> floatHeight;
</span><span style="color: #008080;"> 93</span>         } <span style="color: #0000ff;">else</span><span style="color: #000000;"> {
</span><span style="color: #008080;"> 94</span>             displayTop = 0<span style="color: #000000;">;
</span><span style="color: #008080;"> 95</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 96</span>         RelativeLayout.LayoutParams lp =<span style="color: #000000;"> (LayoutParams) pinnedView.getLayoutParams();
</span><span style="color: #008080;"> 97</span>         lp.topMargin =<span style="color: #000000;"> displayTop;
</span><span style="color: #008080;"> 98</span> <span style="color: #000000;">        pinnedView.setLayoutParams(lp);
</span><span style="color: #008080;"> 99</span> <span style="color: #000000;">        pinnedView.invalidate();
</span><span style="color: #008080;">100</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">101</span> 
<span style="color: #008080;">102</span> 
<span style="color: #008080;">103</span> }</pre>
</div>

&nbsp;

这个**[PinnedRecyclerViewLayout](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/pinnedlayout/PinnedRecyclerViewLayout.java)&nbsp;**是继承RelativeLayout的，因为我们需要在里面添加一个被顶上去的pinnedView，需要覆盖在RecyclerView上面。

Line44：把传进来的pinnedView增加到**[PinnedRecyclerViewLayout](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/pinnedlayout/PinnedRecyclerViewLayout.java)&nbsp;**里面

Line47～56：在ABaseLinearLayoutManager中增加一个滚动的监听器，因为我们需要在滚动的时候动态的改变pinnedView的位置，这样才能模拟顶上去的效果。并滚动时调用refreshPinnedView来刷新pinnedView的位置。

Line57：因为在调用initRecyclerPinned方法时，RecyclerView可能还没有数据源，所以不需要显示这个pinnedView，等到真正滚动的时候再显示就可以了。

refreshPinnedView()方法的作用是在滚动的同时用来刷新pinnedView的位置和显示的数据：

Line71～78：通过layoutManager获取当前第一个显示的数据position，然后根据position获取当前第一个显示的View。

Line79~85：如果当前的curPosition和上次的lastPosition不一样，则说明需要重新刷新数据，避免curPosition一样的情况下重复刷新相同数据。

Line87～95：根据当前第一个显示的View，根据它的top、它的高度和pinnedView的高度计算出pinnedView需要往上移动的距离（画个几何图一目了然了）。

Line96～99：刷新pinnedView的位置

&nbsp;

**示例代码：**

**[https://github.com/wangjiegulu/RecyclerViewSample](https://github.com/wangjiegulu/RecyclerViewSample)**

&nbsp;

<span style="font-size: 16px; color: #ff0000;">**[<span style="color: #ff0000;">[Android]使用RecyclerView替代ListView（一）</span>](http://www.cnblogs.com/tiantianbyconan/p/4232560.html)**：</span>

<span style="font-size: 16px;">**[http://www.cnblogs.com/tiantianbyconan/p/4232560.html](http://www.cnblogs.com/tiantianbyconan/p/4232560.html)**</span>

&nbsp;

<span style="color: #ff0000;"><span style="font-size: 16px;">**[<span style="color: #ff0000;">[Android]使用RecyclerView替代ListView（二）</span>](http://www.cnblogs.com/tiantianbyconan/p/4242541.html)**：</span>&nbsp;</span>

**<span style="font-size: 16px;"><span style="color: #ff0000;">[http://www.cnblogs.com/tiantianbyconan/p/4242541.html](http://www.cnblogs.com/tiantianbyconan/p/4242541.html)</span></span>**

