---
title: Android使用Fragment来实现ViewPager的功能（解决切换Fragment状态不保存）以及各个Fragment之间的通信
tags: [android, fragment, ViewPager]
date: 2013-10-12 09:57:00
---

**<span><span style="color: #ff0000;">以下内容为原创，转载请注明：[<span style="color: #ff0000;">http://www.cnblogs.com/tiantianbyconan/p/3364728.html</span>](http://www.cnblogs.com/tiantianbyconan/p/3364728.html)</span>[<span>
</span>](http://www.cnblogs.com/tiantianbyconan/p/3360938.html)</span>**

我前两天写过一篇博客《Android使用Fragment来实现TabHost的功能（解决切换Fragment状态不保存）以及各个Fragment之间的通信》（[http://www.cnblogs.com/tiantianbyconan/p/3360938.html](http://www.cnblogs.com/tiantianbyconan/p/3360938.html)），实现了Tab切换时保留当前Fragment状态，并在切换前自动回调onPause()方法，在切换后自动调用onResume()，这样就做到了跟TahHost一样的功能。

今天来实现下ViewPager的功能，google提供了一个FragmentPagerAdapter这么一个适配器，蛋疼的是，碰到了跟上次类似的问题。比如ViewPager有5个page，刚打开的时候，会加载page1和page2，我们手动切换到page2的时候，会加载page3，切换到page3的时候，加载page4的同时会destory掉page1，所以，还是面临同样的问题，page的状态无法保存，于是，咱还是自己来实现下好了，自己动手，丰衣足食嘛！（同样&nbsp;<span>有朋友知道解决办法的话，希望联系我，赐教下哈</span>）

先来看下整个demo的结构，跟上次实现TabHost的例子差不多：

![](http://images.cnitblog.com/blog/378300/201310/12093410-5a0bb7a1077d4614898ce8b0fbb85d07.jpg)

<span>TabAFm到TabEFm都是Fragment，并且每个Fragment对应一个布局文件。</span>

<span><span>TabAFm.java：</span></span>

&nbsp;

<div class="cnblogs_code" onclick="cnblogs_code_show('9a8422d4-8368-43fb-ba86-2c66b20d04f0')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_9a8422d4-8368-43fb-ba86-2c66b20d04f0" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.fragmentviewpagertest;
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

<span>现在来看MainActivity：</span>

<div class="cnblogs_code" onclick="cnblogs_code_show('dbc347d7-5a93-47e3-90cc-e45cae3803c7')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_dbc347d7-5a93-47e3-90cc-e45cae3803c7" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.fragmentviewpagertest;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.Bundle;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.Fragment;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.FragmentActivity;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.view.ViewPager;
</span><span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.ArrayList;
</span><span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> FragmentActivity {
</span><span style="color: #008080;">12</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> ViewPager viewPager;
</span><span style="color: #008080;">13</span>     <span style="color: #0000ff;">public</span> List&lt;Fragment&gt; fragments = <span style="color: #0000ff;">new</span> ArrayList&lt;Fragment&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">14</span>     <span style="color: #0000ff;">public</span> String hello = "hello "<span style="color: #000000;">;
</span><span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">17</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
</span><span style="color: #008080;">18</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
</span><span style="color: #008080;">19</span> <span style="color: #000000;">        setContentView(R.layout.main);
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabAFm());
</span><span style="color: #008080;">22</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabBFm());
</span><span style="color: #008080;">23</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabCFm());
</span><span style="color: #008080;">24</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabDFm());
</span><span style="color: #008080;">25</span>         fragments.add(<span style="color: #0000ff;">new</span><span style="color: #000000;"> TabEFm());
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span>         viewPager =<span style="color: #000000;"> (ViewPager) findViewById(R.id.viewPager);
</span><span style="color: #008080;">28</span>         FragmentViewPagerAdapter adapter = <span style="color: #0000ff;">new</span> FragmentViewPagerAdapter(<span style="color: #0000ff;">this</span><span style="color: #000000;">.getSupportFragmentManager(), viewPager,fragments);
</span><span style="color: #008080;">29</span>         adapter.setOnExtraPageChangeListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> FragmentViewPagerAdapter.OnExtraPageChangeListener(){
</span><span style="color: #008080;">30</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">31</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onExtraPageSelected(<span style="color: #0000ff;">int</span><span style="color: #000000;"> i) {
</span><span style="color: #008080;">32</span>                 System.out.println("Extra...i: " +<span style="color: #000000;"> i);
</span><span style="color: #008080;">33</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">34</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">35</span> 
<span style="color: #008080;">36</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">37</span> 
<span style="color: #008080;">38</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

MainActivity上述代码所示

MainActivity是包含Fragment的Activity（也就是这里的5个Fragment）

他继承了FragmentActivity（因为我这里用的是android-support-v4.jar）

用一个List&lt;Fragment&gt;去维护5个Fragment，也就是5个page。

MainActivity的布局很简单，就一个ViewPager，main.xml如下：

<div class="cnblogs_code" onclick="cnblogs_code_show('0e611c66-2fd1-4dc0-9690-f0b0cbcacee6')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_0e611c66-2fd1-4dc0-9690-f0b0cbcacee6" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span>
<span style="color: #008080;"> 3</span> <span style="color: #ff0000;">              android:orientation</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;"> 4</span> <span style="color: #ff0000;">              android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 5</span> <span style="color: #ff0000;">              android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 6</span>         <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">android.support.v4.view.ViewPager
</span><span style="color: #008080;"> 8</span>         <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/viewPager"</span>
<span style="color: #008080;"> 9</span> <span style="color: #ff0000;">        android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">10</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">11</span>         <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

&nbsp;

<span>现在回到MainActivity中，下面这个FragmentViewPagerAdapter类是关键，是我自己编写的用于绑定和处理fragments和ViewPager之间的逻辑关系</span>

<div class="cnblogs_code">
<pre>FragmentViewPagerAdapter adapter = <span style="color: #0000ff;">new</span> FragmentViewPagerAdapter(<span style="color: #0000ff;">this</span>.getSupportFragmentManager(), viewPager,fragments);</pre>
</div>

&nbsp;

<span>现在看下FragmentViewPagerAdapter：</span>

<div class="cnblogs_code" onclick="cnblogs_code_show('f1a422a5-1bf1-44e2-9205-f1cf67fe1843')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_f1a422a5-1bf1-44e2-9205-f1cf67fe1843" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.fragmentviewpagertest;
</span><span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.Fragment;
</span><span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.FragmentManager;
</span><span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.app.FragmentTransaction;
</span><span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.view.PagerAdapter;
</span><span style="color: #008080;">  7</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v4.view.ViewPager;
</span><span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #008080;">  9</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.ViewGroup;
</span><span style="color: #008080;"> 10</span> 
<span style="color: #008080;"> 11</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;
</span><span style="color: #008080;"> 12</span> 
<span style="color: #008080;"> 13</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 14</span> <span style="color: #008000;"> * 为ViewPager添加布局（Fragment），绑定和处理fragments和viewpager之间的逻辑关系
</span><span style="color: #008080;"> 15</span> <span style="color: #008000;"> *
</span><span style="color: #008080;"> 16</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 17</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 18</span> <span style="color: #008000;"> * Date: 13-10-11
</span><span style="color: #008080;"> 19</span> <span style="color: #008000;"> * Time: 下午3:03
</span><span style="color: #008080;"> 20</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 21</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> FragmentViewPagerAdapter <span style="color: #0000ff;">extends</span> PagerAdapter <span style="color: #0000ff;">implements</span><span style="color: #000000;"> ViewPager.OnPageChangeListener{
</span><span style="color: #008080;"> 22</span>     <span style="color: #0000ff;">private</span> List&lt;Fragment&gt; fragments; <span style="color: #008000;">//</span><span style="color: #008000;"> 每个Fragment对应一个Page</span>
<span style="color: #008080;"> 23</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> FragmentManager fragmentManager;
</span><span style="color: #008080;"> 24</span>     <span style="color: #0000ff;">private</span> ViewPager viewPager; <span style="color: #008000;">//</span><span style="color: #008000;"> viewPager对象</span>
<span style="color: #008080;"> 25</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> currentPageIndex = 0; <span style="color: #008000;">//</span><span style="color: #008000;"> 当前page索引（切换之前）</span>
<span style="color: #008080;"> 26</span> 
<span style="color: #008080;"> 27</span>     <span style="color: #0000ff;">private</span> OnExtraPageChangeListener onExtraPageChangeListener; <span style="color: #008000;">//</span><span style="color: #008000;"> ViewPager切换页面时的额外功能添加接口</span>
<span style="color: #008080;"> 28</span> 
<span style="color: #008080;"> 29</span>     <span style="color: #0000ff;">public</span> FragmentViewPagerAdapter(FragmentManager fragmentManager, ViewPager viewPager , List&lt;Fragment&gt;<span style="color: #000000;"> fragments) {
</span><span style="color: #008080;"> 30</span>         <span style="color: #0000ff;">this</span>.fragments =<span style="color: #000000;"> fragments;
</span><span style="color: #008080;"> 31</span>         <span style="color: #0000ff;">this</span>.fragmentManager =<span style="color: #000000;"> fragmentManager;
</span><span style="color: #008080;"> 32</span>         <span style="color: #0000ff;">this</span>.viewPager =<span style="color: #000000;"> viewPager;
</span><span style="color: #008080;"> 33</span>         <span style="color: #0000ff;">this</span>.viewPager.setAdapter(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 34</span>         <span style="color: #0000ff;">this</span>.viewPager.setOnPageChangeListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 35</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 36</span> 
<span style="color: #008080;"> 37</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 38</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getCount() {
</span><span style="color: #008080;"> 39</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> fragments.size();
</span><span style="color: #008080;"> 40</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 41</span> 
<span style="color: #008080;"> 42</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 43</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isViewFromObject(View view, Object o) {
</span><span style="color: #008080;"> 44</span>         <span style="color: #0000ff;">return</span> view ==<span style="color: #000000;"> o;
</span><span style="color: #008080;"> 45</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 46</span> 
<span style="color: #008080;"> 47</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 48</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> destroyItem(ViewGroup container, <span style="color: #0000ff;">int</span><span style="color: #000000;"> position, Object object) {
</span><span style="color: #008080;"> 49</span>         container.removeView(fragments.get(position).getView()); <span style="color: #008000;">//</span><span style="color: #008000;"> 移出viewpager两边之外的page布局</span>
<span style="color: #008080;"> 50</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 51</span> 
<span style="color: #008080;"> 52</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 53</span>     <span style="color: #0000ff;">public</span> Object instantiateItem(ViewGroup container, <span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {
</span><span style="color: #008080;"> 54</span>         Fragment fragment =<span style="color: #000000;"> fragments.get(position);
</span><span style="color: #008080;"> 55</span>         <span style="color: #0000ff;">if</span>(!fragment.isAdded()){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果fragment还没有added</span>
<span style="color: #008080;"> 56</span>             FragmentTransaction ft =<span style="color: #000000;"> fragmentManager.beginTransaction();
</span><span style="color: #008080;"> 57</span> <span style="color: #000000;">            ft.add(fragment, fragment.getClass().getSimpleName());
</span><span style="color: #008080;"> 58</span> <span style="color: #000000;">            ft.commit();
</span><span style="color: #008080;"> 59</span>             <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 60</span> <span style="color: #008000;">             * 在用FragmentTransaction.commit()方法提交FragmentTransaction对象后
</span><span style="color: #008080;"> 61</span> <span style="color: #008000;">             * 会在进程的主线程中，用异步的方式来执行。
</span><span style="color: #008080;"> 62</span> <span style="color: #008000;">             * 如果想要立即执行这个等待中的操作，就要调用这个方法（只能在主线程中调用）。
</span><span style="color: #008080;"> 63</span> <span style="color: #008000;">             * 要注意的是，所有的回调和相关的行为都会在这个调用中被执行完成，因此要仔细确认这个方法的调用位置。
</span><span style="color: #008080;"> 64</span>              <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 65</span> <span style="color: #000000;">            fragmentManager.executePendingTransactions();
</span><span style="color: #008080;"> 66</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 67</span> 
<span style="color: #008080;"> 68</span>         <span style="color: #0000ff;">if</span>(fragment.getView().getParent() == <span style="color: #0000ff;">null</span><span style="color: #000000;">){
</span><span style="color: #008080;"> 69</span>             container.addView(fragment.getView()); <span style="color: #008000;">//</span><span style="color: #008000;"> 为viewpager增加布局</span>
<span style="color: #008080;"> 70</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 71</span> 
<span style="color: #008080;"> 72</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> fragment.getView();
</span><span style="color: #008080;"> 73</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 74</span> 
<span style="color: #008080;"> 75</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 76</span> <span style="color: #008000;">     * 当前page索引（切换之前）
</span><span style="color: #008080;"> 77</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;"> 78</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 79</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getCurrentPageIndex() {
</span><span style="color: #008080;"> 80</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> currentPageIndex;
</span><span style="color: #008080;"> 81</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 82</span> 
<span style="color: #008080;"> 83</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> OnExtraPageChangeListener getOnExtraPageChangeListener() {
</span><span style="color: #008080;"> 84</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> onExtraPageChangeListener;
</span><span style="color: #008080;"> 85</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 86</span> 
<span style="color: #008080;"> 87</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 88</span> <span style="color: #008000;">     * 设置页面切换额外功能监听器
</span><span style="color: #008080;"> 89</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> onExtraPageChangeListener
</span><span style="color: #008080;"> 90</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 91</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOnExtraPageChangeListener(OnExtraPageChangeListener onExtraPageChangeListener) {
</span><span style="color: #008080;"> 92</span>         <span style="color: #0000ff;">this</span>.onExtraPageChangeListener =<span style="color: #000000;"> onExtraPageChangeListener;
</span><span style="color: #008080;"> 93</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 94</span> 
<span style="color: #008080;"> 95</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 96</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onPageScrolled(<span style="color: #0000ff;">int</span> i, <span style="color: #0000ff;">float</span> v, <span style="color: #0000ff;">int</span><span style="color: #000000;"> i2) {
</span><span style="color: #008080;"> 97</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> != onExtraPageChangeListener){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果设置了额外功能接口</span>
<span style="color: #008080;"> 98</span> <span style="color: #000000;">            onExtraPageChangeListener.onExtraPageScrolled(i, v, i2);
</span><span style="color: #008080;"> 99</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">100</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">101</span> 
<span style="color: #008080;">102</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">103</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onPageSelected(<span style="color: #0000ff;">int</span><span style="color: #000000;"> i) {
</span><span style="color: #008080;">104</span>         fragments.get(currentPageIndex).onPause(); <span style="color: #008000;">//</span><span style="color: #008000;"> 调用切换前Fargment的onPause()
</span><span style="color: #008080;">105</span> <span style="color: #008000;">//</span><span style="color: #008000;">        fragments.get(currentPageIndex).onStop(); </span><span style="color: #008000;">//</span><span style="color: #008000;"> 调用切换前Fargment的onStop()</span>
<span style="color: #008080;">106</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;">(fragments.get(i).isAdded()){
</span><span style="color: #008080;">107</span> <span style="color: #008000;">//</span><span style="color: #008000;">            fragments.get(i).onStart(); </span><span style="color: #008000;">//</span><span style="color: #008000;"> 调用切换后Fargment的onStart()</span>
<span style="color: #008080;">108</span>             fragments.get(i).onResume(); <span style="color: #008000;">//</span><span style="color: #008000;"> 调用切换后Fargment的onResume()</span>
<span style="color: #008080;">109</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">110</span>         currentPageIndex =<span style="color: #000000;"> i;
</span><span style="color: #008080;">111</span> 
<span style="color: #008080;">112</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> != onExtraPageChangeListener){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果设置了额外功能接口</span>
<span style="color: #008080;">113</span> <span style="color: #000000;">            onExtraPageChangeListener.onExtraPageSelected(i);
</span><span style="color: #008080;">114</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">115</span> 
<span style="color: #008080;">116</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">117</span> 
<span style="color: #008080;">118</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">119</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onPageScrollStateChanged(<span style="color: #0000ff;">int</span><span style="color: #000000;"> i) {
</span><span style="color: #008080;">120</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> != onExtraPageChangeListener){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果设置了额外功能接口</span>
<span style="color: #008080;">121</span> <span style="color: #000000;">            onExtraPageChangeListener.onExtraPageScrollStateChanged(i);
</span><span style="color: #008080;">122</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">123</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">124</span> 
<span style="color: #008080;">125</span> 
<span style="color: #008080;">126</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">127</span> <span style="color: #008000;">     * page切换额外功能接口
</span><span style="color: #008080;">128</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">129</span>     <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> OnExtraPageChangeListener{
</span><span style="color: #008080;">130</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onExtraPageScrolled(<span style="color: #0000ff;">int</span> i, <span style="color: #0000ff;">float</span> v, <span style="color: #0000ff;">int</span><span style="color: #000000;"> i2){}
</span><span style="color: #008080;">131</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onExtraPageSelected(<span style="color: #0000ff;">int</span><span style="color: #000000;"> i){}
</span><span style="color: #008080;">132</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onExtraPageScrollStateChanged(<span style="color: #0000ff;">int</span><span style="color: #000000;"> i){}
</span><span style="color: #008080;">133</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">134</span> 
<span style="color: #008080;">135</span> 
<span style="color: #008080;">136</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

<span>这里解决Fragment切换重新加载布局的办法，用的是把几个Fragment全部Add，然后根据要显示的哪个Fragment就把哪个Fragment的View给添加到&ldquo;ViewGroup container&rdquo;上去。</span>

<span>效果输出：</span>

<span>// 以下打开程序后，加载PageA和PageB</span>

10-12 09:42:46.671: INFO/System.out(27248): AAAAAAAAAA____onAttach
10-12 09:42:46.671: INFO/System.out(27248): AAAAAAAAAA____onCreate
10-12 09:42:46.671: INFO/System.out(27248): AAAAAAAAAA____onCreateView
10-12 09:42:46.761: INFO/System.out(27248): AAAAAAAAAA____onActivityCreated
10-12 09:42:46.765: INFO/System.out(27248): AAAAAAAAAA____onStart
10-12 09:42:46.765: INFO/System.out(27248): AAAAAAAAAA____onResume
10-12 09:42:46.847: INFO/System.out(27248): BBBBBBBBBBB____onAttach
10-12 09:42:46.847: INFO/System.out(27248): BBBBBBBBBBB____onCreate
10-12 09:42:46.851: INFO/System.out(27248): BBBBBBBBBBB____onCreateView
10-12 09:42:46.867: INFO/System.out(27248): BBBBBBBBBBB____onActivityCreated
10-12 09:42:46.867: INFO/System.out(27248): BBBBBBBBBBB____onStart
10-12 09:42:46.867: INFO/System.out(27248): BBBBBBBBBBB____onResume

// 以下切换到PageB

10-12 09:42:57.285: INFO/System.out(27248): AAAAAAAAAA____onPause　　　　// 切换到PageB前会调用PageA的onPause()方法
10-12 09:42:57.285: INFO/System.out(27248): BBBBBBBBBBB____onResume　　// 切换到PageB后会调用PageB的onResume()方法
10-12 09:42:57.285: INFO/System.out(27248): Extra...i: 1　　　　　　　　　　　　// 切换页面时会调用切换额外功能接口（用户可以自己写需要的逻辑）
10-12 09:42:57.582: INFO/System.out(27248): CCCCCCCCCC____onAttach　　　　// 切换到PageB后会加载PageC
10-12 09:42:57.586: INFO/System.out(27248): CCCCCCCCCC____onCreate
10-12 09:42:57.586: INFO/System.out(27248): CCCCCCCCCC____onCreateView
10-12 09:42:57.675: INFO/System.out(27248): CCCCCCCCCC____onActivityCreated
10-12 09:42:57.675: INFO/System.out(27248): CCCCCCCCCC____onStart
10-12 09:42:57.675: INFO/System.out(27248): CCCCCCCCCC____onResume

// 以下切换到PageC

10-12 09:43:18.261: INFO/System.out(27248): BBBBBBBBBBB____onPause&nbsp;　　　　// 切换到PageC前会调用PageB的onPause()方法
10-12 09:43:18.261: INFO/System.out(27248): CCCCCCCCCC____onResume　　　　// 切换到PageC后会调用PageC的onResume()方法
10-12 09:43:18.261: INFO/System.out(27248): Extra...i: 2　　　　　　　　　　　　　　// 切换页面时会调用切换额外功能接口（用户可以自己写需要的逻辑）
10-12 09:43:18.726: INFO/System.out(27248): DDDDDDDDD____onAttach　　　　　　// 切换到PageC后会加载PageD
10-12 09:43:18.726: INFO/System.out(27248): DDDDDDDDD____onCreate
10-12 09:43:18.726: INFO/System.out(27248): DDDDDDDDD____onCreateView
10-12 09:43:18.738: INFO/System.out(27248): DDDDDDDDD____onActivityCreated
10-12 09:43:18.738: INFO/System.out(27248): DDDDDDDDD____onStart
10-12 09:43:18.742: INFO/System.out(27248): DDDDDDDDD____onResume

// 以下切换到PageB
10-12 09:43:20.742: INFO/System.out(27248): CCCCCCCCCC____onPause　　　　　　// 切换到PageB前会调用PageC的onPause()方法
10-12 09:43:20.742: INFO/System.out(27248): BBBBBBBBBBB____onResume　　　　//&nbsp;切换到PageB后会调用PageB的onResume()方法
10-12 09:43:20.746: INFO/System.out(27248): Extra...i: 1　　　　　　　　　　　　　　// 切换页面时会调用切换额外功能接口（用户可以自己写需要的逻辑）

&nbsp;

好了，到此为止，我们已经用Fragment实现了ViewPager的功能了，同样，下面来看下各个Fragment之间的通信

现在的情况是TabAFm中有个EditText，TabBFm中有个Button，MainActivity中有个变量&ldquo;hello&rdquo;

要做的是，切换到A，输入&ldquo;I'm PageA&rdquo;，切换到B，点击Button后，Toast显示&ldquo;hello I'm PageA&rdquo;

MainActivity中没什么好说的，就一个hello变量：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> String hello = "hello ";</pre>
</div>

<span>TabBFm中：</span>

<div class="cnblogs_code" onclick="cnblogs_code_show('0e5b4cd8-d376-4ab8-aae2-68446bfeb227')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_0e5b4cd8-d376-4ab8-aae2-68446bfeb227" class="cnblogs_code_hide">
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

&nbsp;

最终效果图：

![](http://images.cnitblog.com/blog/378300/201310/12095728-8961829b190244259fb98e23eb7f59b5.png)

&nbsp;

<span style="color: #ff0000;">**demo下载：[http://pan.baidu.com/s/1stGQ7](http://pan.baidu.com/s/1stGQ7)**</span>

