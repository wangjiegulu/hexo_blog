---
title: Android使用Fragment来实现TabHost的功能（解决切换Fragment状态不保存）以及各个Fragment之间的通信
tags: [android, fragment, TabHost]
date: 2013-10-10 11:37:00
---

![](http://images.cnitblog.com/blog/378300/201310/10104944-40b5dbc296894475bdaf8914a59d0498.png)

如新浪微博下面的标签切换功能，我以前也写过一篇博文（[http://www.cnblogs.com/tiantianbyconan/archive/2012/02/24/2366237.html](http://www.cnblogs.com/tiantianbyconan/archive/2012/02/24/2366237.html)），可以实现，用的是TabHost。但是android发展比较迅速，TabHost这玩意现在已经被弃用了，虽说用现在也能用，但是被弃用的东西还是少用为妙。

官方有个FragmentTabHost这么一个替代品，于是试了一下，发现每次切换tab，都会调用<span>onCreateView()方法，控件被重新加载，也就是说你从tab1切换到别的tab后，再切换回来，tab1的状态并没有保存，重新加载了控件。</span>

<span>搞了半天，暂时没有好的解决办法（有朋友知道解决办法的话，希望联系我，赐教下哈）</span>

<span style="line-height: 1.5;">于是，怒了，自己实现一个吧- -</span>

&nbsp;

<span style="line-height: 1.5;">先来看看整个demo的结构：</span>

<span style="line-height: 1.5;">![](http://images.cnitblog.com/blog/378300/201310/10110710-b8f18222f40441d4b46f9ae54fc2c83f.jpg)</span>

<span style="line-height: 1.5;">TabAFm到TabEFm都是Fragment，并且每个Fragment对应一个布局文件。</span>

<span style="line-height: 1.5;">TabAFm.java：</span>

<div class="cnblogs_code" onclick="cnblogs_code_show('85262c98-765c-40bc-8095-dbdf4707c217')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_85262c98-765c-40bc-8095-dbdf4707c217" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.fragmenttabhost;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.app.Activity;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.Bundle;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.Fragment;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.LayoutInflater;
</span><span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.ViewGroup;
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">11</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;">12</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;">13</span> <span style="color: #008000;"> * Date: 13-6-14
</span><span style="color: #008080;">14</span> <span style="color: #008000;"> * Time: 下午2:39
</span><span style="color: #008080;">15</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">16</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> TabAFm <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Fragment{
</span><span style="color: #008080;">17</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">18</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onAttach(Activity activity) {
</span><span style="color: #008080;">19</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onAttach(activity);
</span><span style="color: #008080;">20</span>         System.out.println("AAAAAAAAAA____onAttach"<span style="color: #000000;">);
</span><span style="color: #008080;">21</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">24</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
</span><span style="color: #008080;">25</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
</span><span style="color: #008080;">26</span>         System.out.println("AAAAAAAAAA____onCreate"<span style="color: #000000;">);
</span><span style="color: #008080;">27</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">30</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
</span><span style="color: #008080;">31</span>         System.out.println("AAAAAAAAAA____onCreateView"<span style="color: #000000;">);
</span><span style="color: #008080;">32</span>         <span style="color: #0000ff;">return</span> inflater.inflate(R.layout.tab_a, container, <span style="color: #0000ff;">false</span><span style="color: #000000;">);
</span><span style="color: #008080;">33</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">34</span> 
<span style="color: #008080;">35</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">36</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onActivityCreated(Bundle savedInstanceState) {
</span><span style="color: #008080;">37</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onActivityCreated(savedInstanceState);
</span><span style="color: #008080;">38</span>         System.out.println("AAAAAAAAAA____onActivityCreated"<span style="color: #000000;">);
</span><span style="color: #008080;">39</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">40</span> 
<span style="color: #008080;">41</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">42</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onStart() {
</span><span style="color: #008080;">43</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onStart();
</span><span style="color: #008080;">44</span>         System.out.println("AAAAAAAAAA____onStart"<span style="color: #000000;">);
</span><span style="color: #008080;">45</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">48</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onResume() {
</span><span style="color: #008080;">49</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onResume();
</span><span style="color: #008080;">50</span>         System.out.println("AAAAAAAAAA____onResume"<span style="color: #000000;">);
</span><span style="color: #008080;">51</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">52</span> 
<span style="color: #008080;">53</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">54</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onPause() {
</span><span style="color: #008080;">55</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onPause();
</span><span style="color: #008080;">56</span>         System.out.println("AAAAAAAAAA____onPause"<span style="color: #000000;">);
</span><span style="color: #008080;">57</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">58</span> 
<span style="color: #008080;">59</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">60</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onStop() {
</span><span style="color: #008080;">61</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onStop();
</span><span style="color: #008080;">62</span>         System.out.println("AAAAAAAAAA____onStop"<span style="color: #000000;">);
</span><span style="color: #008080;">63</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">64</span> 
<span style="color: #008080;">65</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">66</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onDestroyView() {
</span><span style="color: #008080;">67</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onDestroyView();
</span><span style="color: #008080;">68</span>         System.out.println("AAAAAAAAAA____onDestroyView"<span style="color: #000000;">);
</span><span style="color: #008080;">69</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">70</span> 
<span style="color: #008080;">71</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">72</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onDestroy() {
</span><span style="color: #008080;">73</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onDestroy();
</span><span style="color: #008080;">74</span>         System.out.println("AAAAAAAAAA____onDestroy"<span style="color: #000000;">);
</span><span style="color: #008080;">75</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">76</span> 
<span style="color: #008080;">77</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">78</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onDetach() {
</span><span style="color: #008080;">79</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onDetach();
</span><span style="color: #008080;">80</span>         System.out.println("AAAAAAAAAA____onDetach"<span style="color: #000000;">);
</span><span style="color: #008080;">81</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">82</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

如上述代码所示，TabAFm是一个Fragment，对应的布局文件是tab_a.xml，并实现了他的所有的生命周期回调函数并打印，便于调试

tab_a.xml布局中有个EditText

其他的Fragment大同小异，这里就不贴出代码了

&nbsp;

现在来看MainActivity：

<div class="cnblogs_code" onclick="cnblogs_code_show('fd8312f8-350d-43e1-95d2-8e9f8c7ec8dc')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_fd8312f8-350d-43e1-95d2-8e9f8c7ec8dc" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.fragmenttabhost;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.Bundle;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.Fragment;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.FragmentActivity;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.RadioGroup;
</span><span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.ArrayList;
</span><span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> FragmentActivity {
</span><span style="color: #008080;">12</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">13</span> <span style="color: #008000;">     * Called when the activity is first created.
</span><span style="color: #008080;">14</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">15</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> RadioGroup rgs;
</span><span style="color: #008080;">16</span>     <span style="color: #0000ff;">public</span> List&lt;Fragment&gt; fragments = <span style="color: #0000ff;">new</span> ArrayList&lt;Fragment&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">public</span> String hello = "hello "<span style="color: #000000;">;
</span><span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
</span><span style="color: #008080;">22</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
</span><span style="color: #008080;">23</span> <span style="color: #000000;">        setContentView(R.layout.main);
</span><span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabAFm());
</span><span style="color: #008080;">26</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabBFm());
</span><span style="color: #008080;">27</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabCFm());
</span><span style="color: #008080;">28</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabDFm());
</span><span style="color: #008080;">29</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabEFm());
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span> 
<span style="color: #008080;">32</span>         rgs =<span style="color: #000000;"> (RadioGroup) findViewById(R.id.tabs_rg);
</span><span style="color: #008080;">33</span> 
<span style="color: #008080;">34</span>         FragmentTabAdapter tabAdapter = <span style="color: #0000ff;">new</span> FragmentTabAdapter(<span style="color: #0000ff;">this</span><span style="color: #000000;">, fragments, R.id.tab_content, rgs);
</span><span style="color: #008080;">35</span>         tabAdapter.setOnRgsExtraCheckedChangedListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> FragmentTabAdapter.OnRgsExtraCheckedChangedListener(){
</span><span style="color: #008080;">36</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">37</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> OnRgsExtraCheckedChanged(RadioGroup radioGroup, <span style="color: #0000ff;">int</span> checkedId, <span style="color: #0000ff;">int</span><span style="color: #000000;"> index) {
</span><span style="color: #008080;">38</span>                 System.out.println("Extra---- " + index + " checked!!! "<span style="color: #000000;">);
</span><span style="color: #008080;">39</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">40</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">41</span> 
<span style="color: #008080;">42</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">43</span> 
<span style="color: #008080;">44</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

MainActivity上述代码所示

MainActivity是包含Fragment的Activity（也就是这里的5个Fragment）

他继承了FragmentActivity（因为我这里用的是android-support-v4.jar）

用一个List&lt;Fragment&gt;去维护5个Fragment，也就是5个tab

main布局中有一个id为tab_content的FrameLayout，用来存放要显示的Fragment。底部有一个RadioGroup，用于tab的切换，如下：

<div class="cnblogs_code" onclick="cnblogs_code_show('1616a5c6-aec1-4ccd-98f6-7d115ad2bef5')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_1616a5c6-aec1-4ccd-98f6-7d115ad2bef5" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;">  2</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span>
<span style="color: #008080;">  3</span> <span style="color: #ff0000;">              android:orientation</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;">  4</span> <span style="color: #ff0000;">              android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">  5</span> <span style="color: #ff0000;">              android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">  6</span> <span style="color: #ff0000;">              android:background</span><span style="color: #0000ff;">="@android:color/white"</span>
<span style="color: #008080;">  7</span>         <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">  8</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout
</span><span style="color: #008080;">  9</span>             <span style="color: #ff0000;">android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 10</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 11</span> <span style="color: #ff0000;">            android:orientation</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;"> 12</span>         <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 13</span> 
<span style="color: #008080;"> 14</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">FrameLayout
</span><span style="color: #008080;"> 15</span>             <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/tab_content"</span>
<span style="color: #008080;"> 16</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 17</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="0dp"</span>
<span style="color: #008080;"> 18</span> <span style="color: #ff0000;">            android:layout_weight</span><span style="color: #0000ff;">="1.0"</span>
<span style="color: #008080;"> 19</span> <span style="color: #ff0000;">            android:background</span><span style="color: #0000ff;">="#77557799"</span>
<span style="color: #008080;"> 20</span>             <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;"> 21</span> 
<span style="color: #008080;"> 22</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioGroup
</span><span style="color: #008080;"> 23</span>             <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/tabs_rg"</span>
<span style="color: #008080;"> 24</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 25</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;"> 26</span> <span style="color: #ff0000;">            android:orientation</span><span style="color: #0000ff;">="horizontal"</span>
<span style="color: #008080;"> 27</span> <span style="color: #ff0000;">            android:gravity</span><span style="color: #0000ff;">="center"</span>
<span style="color: #008080;"> 28</span> <span style="color: #ff0000;">            android:paddingTop</span><span style="color: #0000ff;">="7dp"</span>
<span style="color: #008080;"> 29</span> <span style="color: #ff0000;">            android:paddingBottom</span><span style="color: #0000ff;">="7dp"</span>
<span style="color: #008080;"> 30</span>             <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 31</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton
</span><span style="color: #008080;"> 32</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/tab_rb_a"</span>
<span style="color: #008080;"> 33</span> <span style="color: #ff0000;">                android:layout_width</span><span style="color: #0000ff;">="0dp"</span>
<span style="color: #008080;"> 34</span> <span style="color: #ff0000;">                android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;"> 35</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tablatestalert"</span>
<span style="color: #008080;"> 36</span> <span style="color: #ff0000;">                android:button</span><span style="color: #0000ff;">="@null"</span>
<span style="color: #008080;"> 37</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="Tab1"</span>
<span style="color: #008080;"> 38</span> <span style="color: #ff0000;">                android:textColor</span><span style="color: #0000ff;">="#000000"</span>
<span style="color: #008080;"> 39</span> <span style="color: #ff0000;">                android:textSize</span><span style="color: #0000ff;">="13sp"</span>
<span style="color: #008080;"> 40</span> <span style="color: #ff0000;">                android:layout_weight</span><span style="color: #0000ff;">="1.0"</span>
<span style="color: #008080;"> 41</span> <span style="color: #ff0000;">                android:gravity</span><span style="color: #0000ff;">="center"</span>
<span style="color: #008080;"> 42</span> <span style="color: #ff0000;">                android:singleLine</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;"> 43</span> <span style="color: #ff0000;">                android:checked</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;"> 44</span> <span style="color: #ff0000;">                android:background</span><span style="color: #0000ff;">="@drawable/selector_tab"</span>
<span style="color: #008080;"> 45</span>                 <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;"> 46</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton
</span><span style="color: #008080;"> 47</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/tab_rb_b"</span>
<span style="color: #008080;"> 48</span> <span style="color: #ff0000;">                android:layout_width</span><span style="color: #0000ff;">="0dp"</span>
<span style="color: #008080;"> 49</span> <span style="color: #ff0000;">                android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;"> 50</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tabsearch"</span>
<span style="color: #008080;"> 51</span> <span style="color: #ff0000;">                android:button</span><span style="color: #0000ff;">="@null"</span>
<span style="color: #008080;"> 52</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="Tab2"</span>
<span style="color: #008080;"> 53</span> <span style="color: #ff0000;">                android:textColor</span><span style="color: #0000ff;">="#000000"</span>
<span style="color: #008080;"> 54</span> <span style="color: #ff0000;">                android:textSize</span><span style="color: #0000ff;">="13sp"</span>
<span style="color: #008080;"> 55</span> <span style="color: #ff0000;">                android:layout_weight</span><span style="color: #0000ff;">="1.0"</span>
<span style="color: #008080;"> 56</span> <span style="color: #ff0000;">                android:gravity</span><span style="color: #0000ff;">="center"</span>
<span style="color: #008080;"> 57</span> <span style="color: #ff0000;">                android:singleLine</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;"> 58</span> <span style="color: #ff0000;">                android:background</span><span style="color: #0000ff;">="@drawable/selector_tab"</span>
<span style="color: #008080;"> 59</span>                 <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;"> 60</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton
</span><span style="color: #008080;"> 61</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/tab_rb_c"</span>
<span style="color: #008080;"> 62</span> <span style="color: #ff0000;">                android:layout_width</span><span style="color: #0000ff;">="0dp"</span>
<span style="color: #008080;"> 63</span> <span style="color: #ff0000;">                android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;"> 64</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tabrecommd"</span>
<span style="color: #008080;"> 65</span> <span style="color: #ff0000;">                android:button</span><span style="color: #0000ff;">="@null"</span>
<span style="color: #008080;"> 66</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="Tab3"</span>
<span style="color: #008080;"> 67</span> <span style="color: #ff0000;">                android:textColor</span><span style="color: #0000ff;">="#000000"</span>
<span style="color: #008080;"> 68</span> <span style="color: #ff0000;">                android:textSize</span><span style="color: #0000ff;">="13sp"</span>
<span style="color: #008080;"> 69</span> <span style="color: #ff0000;">                android:layout_weight</span><span style="color: #0000ff;">="1.0"</span>
<span style="color: #008080;"> 70</span> <span style="color: #ff0000;">                android:gravity</span><span style="color: #0000ff;">="center"</span>
<span style="color: #008080;"> 71</span> <span style="color: #ff0000;">                android:singleLine</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;"> 72</span> <span style="color: #ff0000;">                android:background</span><span style="color: #0000ff;">="@drawable/selector_tab"</span>
<span style="color: #008080;"> 73</span>                 <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;"> 74</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton
</span><span style="color: #008080;"> 75</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/tab_rb_d"</span>
<span style="color: #008080;"> 76</span> <span style="color: #ff0000;">                android:layout_width</span><span style="color: #0000ff;">="0dp"</span>
<span style="color: #008080;"> 77</span> <span style="color: #ff0000;">                android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;"> 78</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tabconfigicon"</span>
<span style="color: #008080;"> 79</span> <span style="color: #ff0000;">                android:button</span><span style="color: #0000ff;">="@null"</span>
<span style="color: #008080;"> 80</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="Tab4"</span>
<span style="color: #008080;"> 81</span> <span style="color: #ff0000;">                android:textColor</span><span style="color: #0000ff;">="#000000"</span>
<span style="color: #008080;"> 82</span> <span style="color: #ff0000;">                android:textSize</span><span style="color: #0000ff;">="13sp"</span>
<span style="color: #008080;"> 83</span> <span style="color: #ff0000;">                android:layout_weight</span><span style="color: #0000ff;">="1.0"</span>
<span style="color: #008080;"> 84</span> <span style="color: #ff0000;">                android:gravity</span><span style="color: #0000ff;">="center"</span>
<span style="color: #008080;"> 85</span> <span style="color: #ff0000;">                android:singleLine</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;"> 86</span> <span style="color: #ff0000;">                android:background</span><span style="color: #0000ff;">="@drawable/selector_tab"</span>
<span style="color: #008080;"> 87</span>                 <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;"> 88</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton
</span><span style="color: #008080;"> 89</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/tab_rb_e"</span>
<span style="color: #008080;"> 90</span> <span style="color: #ff0000;">                android:layout_width</span><span style="color: #0000ff;">="0dp"</span>
<span style="color: #008080;"> 91</span> <span style="color: #ff0000;">                android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;"> 92</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tababoutus"</span>
<span style="color: #008080;"> 93</span> <span style="color: #ff0000;">                android:button</span><span style="color: #0000ff;">="@null"</span>
<span style="color: #008080;"> 94</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="Tab5"</span>
<span style="color: #008080;"> 95</span> <span style="color: #ff0000;">                android:textColor</span><span style="color: #0000ff;">="#000000"</span>
<span style="color: #008080;"> 96</span> <span style="color: #ff0000;">                android:textSize</span><span style="color: #0000ff;">="13sp"</span>
<span style="color: #008080;"> 97</span> <span style="color: #ff0000;">                android:layout_weight</span><span style="color: #0000ff;">="1.0"</span>
<span style="color: #008080;"> 98</span> <span style="color: #ff0000;">                android:gravity</span><span style="color: #0000ff;">="center"</span>
<span style="color: #008080;"> 99</span> <span style="color: #ff0000;">                android:singleLine</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;">100</span> <span style="color: #ff0000;">                android:background</span><span style="color: #0000ff;">="@drawable/selector_tab"</span>
<span style="color: #008080;">101</span>                 <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">102</span> 
<span style="color: #008080;">103</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">RadioGroup</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">104</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">105</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

现在回到MainActivity中，下面这个FragmentTabAdapter类是关键，是我自己编写的用于绑定和处理fragments和RadioGroup之间的逻辑关系

<div class="cnblogs_code">
<pre>FragmentTabAdapter tabAdapter = <span style="color: #0000ff;">new</span> FragmentTabAdapter(<span style="color: #0000ff;">this</span>, fragments, R.id.tab_content, rgs);</pre>
</div>

&nbsp;

现在看下FragmentTabAdapter：

<div class="cnblogs_code" onclick="cnblogs_code_show('1827caab-5f05-4ffc-9974-0616b027aa79')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_1827caab-5f05-4ffc-9974-0616b027aa79" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.fragmenttabhost;
</span><span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.Fragment;
</span><span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.FragmentActivity;
</span><span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.FragmentTransaction;
</span><span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.RadioGroup;
</span><span style="color: #008080;">  7</span> 
<span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;
</span><span style="color: #008080;">  9</span> 
<span style="color: #008080;"> 10</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 11</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 12</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 13</span> <span style="color: #008000;"> * Date: 13-10-10
</span><span style="color: #008080;"> 14</span> <span style="color: #008000;"> * Time: 上午9:25
</span><span style="color: #008080;"> 15</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 16</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> FragmentTabAdapter <span style="color: #0000ff;">implements</span><span style="color: #000000;"> RadioGroup.OnCheckedChangeListener{
</span><span style="color: #008080;"> 17</span>     <span style="color: #0000ff;">private</span> List&lt;Fragment&gt; fragments; <span style="color: #008000;">//</span><span style="color: #008000;"> 一个tab页面对应一个Fragment</span>
<span style="color: #008080;"> 18</span>     <span style="color: #0000ff;">private</span> RadioGroup rgs; <span style="color: #008000;">//</span><span style="color: #008000;"> 用于切换tab</span>
<span style="color: #008080;"> 19</span>     <span style="color: #0000ff;">private</span> FragmentActivity fragmentActivity; <span style="color: #008000;">//</span><span style="color: #008000;"> Fragment所属的Activity</span>
<span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> fragmentContentId; <span style="color: #008000;">//</span><span style="color: #008000;"> Activity中所要被替换的区域的id</span>
<span style="color: #008080;"> 21</span> 
<span style="color: #008080;"> 22</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> currentTab; <span style="color: #008000;">//</span><span style="color: #008000;"> 当前Tab页面索引</span>
<span style="color: #008080;"> 23</span> 
<span style="color: #008080;"> 24</span>     <span style="color: #0000ff;">private</span> OnRgsExtraCheckedChangedListener onRgsExtraCheckedChangedListener; <span style="color: #008000;">//</span><span style="color: #008000;"> 用于让调用者在切换tab时候增加新的功能</span>
<span style="color: #008080;"> 25</span> 
<span style="color: #008080;"> 26</span>     <span style="color: #0000ff;">public</span> FragmentTabAdapter(FragmentActivity fragmentActivity, List&lt;Fragment&gt; fragments, <span style="color: #0000ff;">int</span><span style="color: #000000;"> fragmentContentId, RadioGroup rgs) {
</span><span style="color: #008080;"> 27</span>         <span style="color: #0000ff;">this</span>.fragments =<span style="color: #000000;"> fragments;
</span><span style="color: #008080;"> 28</span>         <span style="color: #0000ff;">this</span>.rgs =<span style="color: #000000;"> rgs;
</span><span style="color: #008080;"> 29</span>         <span style="color: #0000ff;">this</span>.fragmentActivity =<span style="color: #000000;"> fragmentActivity;
</span><span style="color: #008080;"> 30</span>         <span style="color: #0000ff;">this</span>.fragmentContentId =<span style="color: #000000;"> fragmentContentId;
</span><span style="color: #008080;"> 31</span> 
<span style="color: #008080;"> 32</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 默认显示第一页</span>
<span style="color: #008080;"> 33</span>         FragmentTransaction ft =<span style="color: #000000;"> fragmentActivity.getSupportFragmentManager().beginTransaction();
</span><span style="color: #008080;"> 34</span>         ft.add(fragmentContentId, fragments.get(0<span style="color: #000000;">));
</span><span style="color: #008080;"> 35</span> <span style="color: #000000;">        ft.commit();
</span><span style="color: #008080;"> 36</span> 
<span style="color: #008080;"> 37</span>         rgs.setOnCheckedChangeListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 38</span> 
<span style="color: #008080;"> 39</span> 
<span style="color: #008080;"> 40</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 41</span> 
<span style="color: #008080;"> 42</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 43</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCheckedChanged(RadioGroup radioGroup, <span style="color: #0000ff;">int</span><span style="color: #000000;"> checkedId) {
</span><span style="color: #008080;"> 44</span>         <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; rgs.getChildCount(); i++<span style="color: #000000;">){
</span><span style="color: #008080;"> 45</span>             <span style="color: #0000ff;">if</span>(rgs.getChildAt(i).getId() ==<span style="color: #000000;"> checkedId){
</span><span style="color: #008080;"> 46</span>                 Fragment fragment =<span style="color: #000000;"> fragments.get(i);
</span><span style="color: #008080;"> 47</span>                 FragmentTransaction ft =<span style="color: #000000;"> obtainFragmentTransaction(i);
</span><span style="color: #008080;"> 48</span> 
<span style="color: #008080;"> 49</span>                 getCurrentFragment().onPause(); <span style="color: #008000;">//</span><span style="color: #008000;"> 暂停当前tab
</span><span style="color: #008080;"> 50</span> <span style="color: #008000;">//</span><span style="color: #008000;">                getCurrentFragment().onStop(); </span><span style="color: #008000;">//</span><span style="color: #008000;"> 暂停当前tab</span>
<span style="color: #008080;"> 51</span> 
<span style="color: #008080;"> 52</span>                 <span style="color: #0000ff;">if</span><span style="color: #000000;">(fragment.isAdded()){
</span><span style="color: #008080;"> 53</span> <span style="color: #008000;">//</span><span style="color: #008000;">                    fragment.onStart(); </span><span style="color: #008000;">//</span><span style="color: #008000;"> 启动目标tab的onStart()</span>
<span style="color: #008080;"> 54</span>                     fragment.onResume(); <span style="color: #008000;">//</span><span style="color: #008000;"> 启动目标tab的onResume()</span>
<span style="color: #008080;"> 55</span>                 }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;"> 56</span> <span style="color: #000000;">                    ft.add(fragmentContentId, fragment);
</span><span style="color: #008080;"> 57</span> <span style="color: #000000;">                }
</span><span style="color: #008080;"> 58</span>                 showTab(i); <span style="color: #008000;">//</span><span style="color: #008000;"> 显示目标tab</span>
<span style="color: #008080;"> 59</span> <span style="color: #000000;">                ft.commit();
</span><span style="color: #008080;"> 60</span> 
<span style="color: #008080;"> 61</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 如果设置了切换tab额外功能功能接口</span>
<span style="color: #008080;"> 62</span>                 <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> onRgsExtraCheckedChangedListener){
</span><span style="color: #008080;"> 63</span> <span style="color: #000000;">                    onRgsExtraCheckedChangedListener.OnRgsExtraCheckedChanged(radioGroup, checkedId, i);
</span><span style="color: #008080;"> 64</span> <span style="color: #000000;">                }
</span><span style="color: #008080;"> 65</span> 
<span style="color: #008080;"> 66</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 67</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 68</span> 
<span style="color: #008080;"> 69</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 70</span> 
<span style="color: #008080;"> 71</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 72</span> <span style="color: #008000;">     * 切换tab
</span><span style="color: #008080;"> 73</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> idx
</span><span style="color: #008080;"> 74</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 75</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> showTab(<span style="color: #0000ff;">int</span><span style="color: #000000;"> idx){
</span><span style="color: #008080;"> 76</span>         <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; fragments.size(); i++<span style="color: #000000;">){
</span><span style="color: #008080;"> 77</span>             Fragment fragment =<span style="color: #000000;"> fragments.get(i);
</span><span style="color: #008080;"> 78</span>             FragmentTransaction ft =<span style="color: #000000;"> obtainFragmentTransaction(idx);
</span><span style="color: #008080;"> 79</span> 
<span style="color: #008080;"> 80</span>             <span style="color: #0000ff;">if</span>(idx ==<span style="color: #000000;"> i){
</span><span style="color: #008080;"> 81</span> <span style="color: #000000;">                ft.show(fragment);
</span><span style="color: #008080;"> 82</span>             }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;"> 83</span> <span style="color: #000000;">                ft.hide(fragment);
</span><span style="color: #008080;"> 84</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 85</span> <span style="color: #000000;">            ft.commit();
</span><span style="color: #008080;"> 86</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 87</span>         currentTab = idx; <span style="color: #008000;">//</span><span style="color: #008000;"> 更新目标tab为当前tab</span>
<span style="color: #008080;"> 88</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 89</span> 
<span style="color: #008080;"> 90</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 91</span> <span style="color: #008000;">     * 获取一个带动画的FragmentTransaction
</span><span style="color: #008080;"> 92</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> index
</span><span style="color: #008080;"> 93</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;"> 94</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 95</span>     <span style="color: #0000ff;">private</span> FragmentTransaction obtainFragmentTransaction(<span style="color: #0000ff;">int</span><span style="color: #000000;"> index){
</span><span style="color: #008080;"> 96</span>         FragmentTransaction ft =<span style="color: #000000;"> fragmentActivity.getSupportFragmentManager().beginTransaction();
</span><span style="color: #008080;"> 97</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置切换动画</span>
<span style="color: #008080;"> 98</span>         <span style="color: #0000ff;">if</span>(index &gt;<span style="color: #000000;"> currentTab){
</span><span style="color: #008080;"> 99</span> <span style="color: #000000;">            ft.setCustomAnimations(R.anim.slide_left_in, R.anim.slide_left_out);
</span><span style="color: #008080;">100</span>         }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;">101</span> <span style="color: #000000;">            ft.setCustomAnimations(R.anim.slide_right_in, R.anim.slide_right_out);
</span><span style="color: #008080;">102</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">103</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> ft;
</span><span style="color: #008080;">104</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">105</span> 
<span style="color: #008080;">106</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getCurrentTab() {
</span><span style="color: #008080;">107</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> currentTab;
</span><span style="color: #008080;">108</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">109</span> 
<span style="color: #008080;">110</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> Fragment getCurrentFragment(){
</span><span style="color: #008080;">111</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> fragments.get(currentTab);
</span><span style="color: #008080;">112</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">113</span> 
<span style="color: #008080;">114</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> OnRgsExtraCheckedChangedListener getOnRgsExtraCheckedChangedListener() {
</span><span style="color: #008080;">115</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> onRgsExtraCheckedChangedListener;
</span><span style="color: #008080;">116</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">117</span> 
<span style="color: #008080;">118</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOnRgsExtraCheckedChangedListener(OnRgsExtraCheckedChangedListener onRgsExtraCheckedChangedListener) {
</span><span style="color: #008080;">119</span>         <span style="color: #0000ff;">this</span>.onRgsExtraCheckedChangedListener =<span style="color: #000000;"> onRgsExtraCheckedChangedListener;
</span><span style="color: #008080;">120</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">121</span> 
<span style="color: #008080;">122</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">123</span> <span style="color: #008000;">     *  切换tab额外功能功能接口
</span><span style="color: #008080;">124</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">125</span>     <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> OnRgsExtraCheckedChangedListener{
</span><span style="color: #008080;">126</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> OnRgsExtraCheckedChanged(RadioGroup radioGroup, <span style="color: #0000ff;">int</span> checkedId, <span style="color: #0000ff;">int</span><span style="color: #000000;"> index){
</span><span style="color: #008080;">127</span> 
<span style="color: #008080;">128</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">129</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">130</span> 
<span style="color: #008080;">131</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

这里解决Fragment切换重新加载布局的办法，用的是把几个Fragment全部Add，然后根据要显示的哪个Fragment设置show或者hide

效果输出：

10-10 11:55:41.168: INFO/System.out(18368): AAAAAAAAAA____onAttach　　　　　　<span style="color: #0000ff;">// 第一次进入，显示TabA</span>
10-10 11:55:41.168: INFO/System.out(18368): AAAAAAAAAA____onCreate
10-10 11:55:41.168: INFO/System.out(18368): AAAAAAAAAA____onCreateView
10-10 11:55:41.175: INFO/System.out(18368): AAAAAAAAAA____onActivityCreated
10-10 11:55:41.179: INFO/System.out(18368): AAAAAAAAAA____onStart
10-10 11:55:41.179: INFO/System.out(18368): AAAAAAAAAA____onResume
10-10 11:55:44.980: INFO/System.out(18368): AAAAAAAAAA____onPause　　　　　　<span style="color: #0000ff;">// 从TabA切换到TabB（TabA调用onPause）</span>
10-10 11:55:44.980: INFO/System.out(18368): Extra---- 1 checked!!!
10-10 11:55:44.996: INFO/System.out(18368): BBBBBBBBBBB____onAttach
10-10 11:55:44.996: INFO/System.out(18368): BBBBBBBBBBB____onCreate
10-10 11:55:44.996: INFO/System.out(18368): BBBBBBBBBBB____onCreateView
10-10 11:55:45.004: INFO/System.out(18368): BBBBBBBBBBB____onActivityCreated
10-10 11:55:45.004: INFO/System.out(18368): BBBBBBBBBBB____onStart
10-10 11:55:45.004: INFO/System.out(18368): BBBBBBBBBBB____onResume
10-10 11:55:52.062: INFO/System.out(18368): BBBBBBBBBBB____onPause　　　　　　<span style="color: #0000ff;">// 从TabB切换到TabC（TabB调用onPause）</span>
10-10 11:55:52.062: INFO/System.out(18368): Extra---- 2 checked!!!
10-10 11:55:52.082: INFO/System.out(18368): CCCCCCCCCC____onAttach
10-10 11:55:52.082: INFO/System.out(18368): CCCCCCCCCC____onCreate
10-10 11:55:52.086: INFO/System.out(18368): CCCCCCCCCC____onCreateView
10-10 11:55:52.090: INFO/System.out(18368): CCCCCCCCCC____onActivityCreated
10-10 11:55:52.090: INFO/System.out(18368): CCCCCCCCCC____onStart
10-10 11:55:52.090: INFO/System.out(18368): CCCCCCCCCC____onResume
10-10 11:56:06.535: INFO/System.out(18368): CCCCCCCCCC____onPause　　　　　　<span style="color: #0000ff;">// 从TabC切换到TabB（TabC调用onPause）</span>
10-10 11:56:06.535: INFO/System.out(18368): BBBBBBBBBBB____onResume　　　　<span style="color: #0000ff;">//&nbsp;从TabC切换到TabB（TabB调用onResume）</span>
10-10 11:56:06.535: INFO/System.out(18368): Extra---- 1 checked!!!

&nbsp;

好了，到此为止，我们已经用Fragment实现了类似TabHost的功能了，下面来看下各个Fragment之间的通信

现在的情况是TabAFm中有个EditText，TabBFm中有个Button，MainActivity中有个变量&ldquo;hello&rdquo;

要做的是，切换到TabA，输入&ldquo;I'm TabA&rdquo;，切换到B，点击Button后，Toast显示&ldquo;hello I'm TabA&rdquo;

MainActivity中没什么好说的，就一个hello变量：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> String hello = "hello ";</pre>
</div>

TabAFm在布局文件tab_a.xml中加个EditText，设置个id就可以了

TabBFm中：

<div class="cnblogs_code" onclick="cnblogs_code_show('584d6f2a-4f17-4bc3-b261-291e61788031')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_584d6f2a-4f17-4bc3-b261-291e61788031" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">@Override
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onActivityCreated(Bundle savedInstanceState) {
</span><span style="color: #008080;"> 3</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onActivityCreated(savedInstanceState);
</span><span style="color: #008080;"> 4</span>         System.out.println("BBBBBBBBBBB____onActivityCreated"<span style="color: #000000;">);
</span><span style="color: #008080;"> 5</span>         <span style="color: #0000ff;">this</span>.getView().findViewById(R.id.clickme).setOnClickListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> View.OnClickListener() {
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;"> 7</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClick(View view) {
</span><span style="color: #008080;"> 8</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 获得绑定的FragmentActivity</span>
<span style="color: #008080;"> 9</span>                 MainActivity activity =<span style="color: #000000;"> ((MainActivity)getActivity());
</span><span style="color: #008080;">10</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 获得TabAFm的控件</span>
<span style="color: #008080;">11</span>                 EditText editText = (EditText) activity.fragments.get(0<span style="color: #000000;">).getView().findViewById(R.id.edit);
</span><span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span>                 Toast.makeText(activity, activity.hello +<span style="color: #000000;"> editText.getText(), Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">14</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">15</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">16</span>     }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>
<div class="cnblogs_code">
<pre><span style="color: #008000;">//</span><span style="color: #008000;"> 获得绑定的FragmentActivity</span>
MainActivity activity = ((MainActivity)getActivity());</pre>
</div>

通过getActivity()即可得到Fragment所在的FragmentActivity

&nbsp;

最终效果图：

![](http://images.cnitblog.com/blog/378300/201310/10114324-42b27a496916463e91d7400c5c3d1884.png)

<span style="color: #ff0000;">**demo下载地址：[<span style="color: #ff0000;">http://pan.baidu.com/s/1wxsIX</span>](http://pan.baidu.com/s/1wxsIX)**</span>

