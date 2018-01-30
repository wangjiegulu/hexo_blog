---
title: Android自定义ScrollView分段加载大文本数据到TextView
tags: [android, ScrollView, TextView]
date: 2013-09-10 10:19:00
---

<span style="color: #ff0000;">以下内容为原创，转载时请注明链接地址：[http://www.cnblogs.com/tiantianbyconan/p/3311658.html](http://www.cnblogs.com/tiantianbyconan/p/3311658.html)</span>

这是我现在碰到的一个问题，如果需要在TextView中加载大文本的时候，比如几M的txt文件时，TextView载入的时候会出现卡死的现象，甚至会出现异常等待退出出现。

解决办法之一就是通过&ldquo;分段&rdquo;或&ldquo;分页&rdquo;来显示数据，在TextView（嵌入在ScrollView之中实现了TextView的滚动）中滚动到底部的时候，再去加载下一部分的数据，依次类推，这样每次加载的数据相对来说都比较小，不会出现卡顿的现象。

遇到的问题是，如何监听ScrollView滚动的位置（滚动到顶部还是底部？）。

&nbsp;

如下，通过自定义ScrollView类(BorderScrollView)：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.bigtextloadtest;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.content.Context;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.graphics.Rect;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.util.AttributeSet;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.ScrollView;
</span><span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 9</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;">10</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;">11</span> <span style="color: #008000;"> * Date: 13-9-6
</span><span style="color: #008080;">12</span> <span style="color: #008000;"> * Time: 下午2:06
</span><span style="color: #008080;">13</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">14</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> BorderScrollView <span style="color: #0000ff;">extends</span><span style="color: #000000;"> ScrollView{
</span><span style="color: #008080;">15</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">long</span><span style="color: #000000;"> millis;
</span><span style="color: #008080;">16</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 滚动监听者</span>
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> OnScrollChangedListener onScrollChangedListener;
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> BorderScrollView(Context context) {
</span><span style="color: #008080;">20</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context);
</span><span style="color: #008080;">21</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> BorderScrollView(Context context, AttributeSet attrs) {
</span><span style="color: #008080;">24</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs);
</span><span style="color: #008080;">25</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span>     <span style="color: #0000ff;">public</span> BorderScrollView(Context context, AttributeSet attrs, <span style="color: #0000ff;">int</span><span style="color: #000000;"> defStyle) {
</span><span style="color: #008080;">28</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, attrs, defStyle);
</span><span style="color: #008080;">29</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">32</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span> onScrollChanged(<span style="color: #0000ff;">int</span> l, <span style="color: #0000ff;">int</span> t, <span style="color: #0000ff;">int</span> oldl, <span style="color: #0000ff;">int</span><span style="color: #000000;"> oldt) {
</span><span style="color: #008080;">33</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onScrollChanged(l, t, oldl, oldt);
</span><span style="color: #008080;">34</span> 
<span style="color: #008080;">35</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> onScrollChangedListener){
</span><span style="color: #008080;">36</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">37</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">38</span> 
<span style="color: #008080;">39</span>         <span style="color: #0000ff;">long</span> now =<span style="color: #000000;"> System.currentTimeMillis();
</span><span style="color: #008080;">40</span> 
<span style="color: #008080;">41</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 通知监听者当前滚动的具体信息</span>
<span style="color: #008080;">42</span> <span style="color: #000000;">        onScrollChangedListener.onScrollChanged(l, t, oldl, oldt);
</span><span style="color: #008080;">43</span> 
<span style="color: #008080;">44</span>         <span style="color: #0000ff;">if</span>(now - millis &gt; 1000l<span style="color: #000000;">){
</span><span style="color: #008080;">45</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> 滚动到底部（前提：从不是底部滚动到底部）</span>
<span style="color: #008080;">46</span>             <span style="color: #0000ff;">if</span>((<span style="color: #0000ff;">this</span>.getHeight() + oldt) != <span style="color: #0000ff;">this</span><span style="color: #000000;">.getTotalVerticalScrollRange()
</span><span style="color: #008080;">47</span>                     &amp;&amp; (<span style="color: #0000ff;">this</span>.getHeight() + t) == <span style="color: #0000ff;">this</span><span style="color: #000000;">.getTotalVerticalScrollRange()){
</span><span style="color: #008080;">48</span> 
<span style="color: #008080;">49</span>                 onScrollChangedListener.onScrollBottom(); <span style="color: #008000;">//</span><span style="color: #008000;"> 通知监听者滚动到底部</span>
<span style="color: #008080;">50</span> 
<span style="color: #008080;">51</span>                 millis =<span style="color: #000000;"> now;
</span><span style="color: #008080;">52</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">53</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">54</span> 
<span style="color: #008080;">55</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 滚动到顶部（前提：从不是顶部滚动到顶部）</span>
<span style="color: #008080;">56</span>         <span style="color: #0000ff;">if</span>(oldt != 0 &amp;&amp; t == 0<span style="color: #000000;">){
</span><span style="color: #008080;">57</span>             onScrollChangedListener.onScrollTop(); <span style="color: #008000;">//</span><span style="color: #008000;"> 通知监听者滚动到顶部</span>
<span style="color: #008080;">58</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">59</span> 
<span style="color: #008080;">60</span> 
<span style="color: #008080;">61</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">62</span> 
<span style="color: #008080;">63</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> OnScrollChangedListener getOnScrollChangedListener() {
</span><span style="color: #008080;">64</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> onScrollChangedListener;
</span><span style="color: #008080;">65</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">66</span> 
<span style="color: #008080;">67</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOnScrollChangedListener(OnScrollChangedListener onScrollChangedListener) {
</span><span style="color: #008080;">68</span>         <span style="color: #0000ff;">this</span>.onScrollChangedListener =<span style="color: #000000;"> onScrollChangedListener;
</span><span style="color: #008080;">69</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">70</span> 
<span style="color: #008080;">71</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">72</span> <span style="color: #008000;">     * 获得滚动总长度
</span><span style="color: #008080;">73</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;">74</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">75</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getTotalVerticalScrollRange() {
</span><span style="color: #008080;">76</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">.computeVerticalScrollRange();
</span><span style="color: #008080;">77</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">78</span> 
<span style="color: #008080;">79</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">80</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> computeScrollDeltaToGetChildRectOnScreen(Rect rect) {
</span><span style="color: #008080;">81</span>         <span style="color: #0000ff;">return</span> 0; <span style="color: #008000;">//</span><span style="color: #008000;"> 禁止ScrollView在子控件的布局改变时自动滚动</span>
<span style="color: #008080;">82</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">83</span> 
<span style="color: #008080;">84</span> }</pre>
</div>

&nbsp;

滚动监听器接口OnScrollChangedListener：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.bigtextloadtest;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 6</span> <span style="color: #008000;"> * Date: 13-9-6
</span><span style="color: #008080;"> 7</span> <span style="color: #008000;"> * Time: 下午2:53
</span><span style="color: #008080;"> 8</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> OnScrollChangedListener {
</span><span style="color: #008080;">10</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">11</span> <span style="color: #008000;">     * 监听滚动变化
</span><span style="color: #008080;">12</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> l
</span><span style="color: #008080;">13</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> t
</span><span style="color: #008080;">14</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> oldl
</span><span style="color: #008080;">15</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> oldt
</span><span style="color: #008080;">16</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onScrollChanged(<span style="color: #0000ff;">int</span> l, <span style="color: #0000ff;">int</span> t, <span style="color: #0000ff;">int</span> oldl, <span style="color: #0000ff;">int</span><span style="color: #000000;"> oldt);
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">20</span> <span style="color: #008000;">     * 监听滚动到顶部
</span><span style="color: #008080;">21</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">22</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onScrollTop();
</span><span style="color: #008080;">23</span> 
<span style="color: #008080;">24</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">25</span> <span style="color: #008000;">     * 监听滚动到底部
</span><span style="color: #008080;">26</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">27</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onScrollBottom();
</span><span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> }</pre>
</div>

&nbsp;

滚动监听器的空实现OnScrollChangedListenerSimple（简洁真正用时候的代码）：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.bigtextloadtest;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 6</span> <span style="color: #008000;"> * Date: 13-9-9
</span><span style="color: #008080;"> 7</span> <span style="color: #008000;"> * Time: 下午2:39
</span><span style="color: #008080;"> 8</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> OnScrollChangedListenerSimple <span style="color: #0000ff;">implements</span><span style="color: #000000;"> OnScrollChangedListener{
</span><span style="color: #008080;">10</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">11</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onScrollChanged(<span style="color: #0000ff;">int</span> l, <span style="color: #0000ff;">int</span> t, <span style="color: #0000ff;">int</span> oldl, <span style="color: #0000ff;">int</span><span style="color: #000000;"> oldt) {}
</span><span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">14</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onScrollTop() {}
</span><span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">17</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onScrollBottom() {}
</span><span style="color: #008080;">18</span> }</pre>
</div>

&nbsp;

异步加载分段文本（这里每次加载50行）：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.bigtextloadtest;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.content.Context;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.AsyncTask;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.Handler;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span> java.io.*<span style="color: #000000;">;
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">11</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;">12</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;">13</span> <span style="color: #008000;"> * Date: 13-9-6
</span><span style="color: #008080;">14</span> <span style="color: #008000;"> * Time: 上午11:34
</span><span style="color: #008080;">15</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">16</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> AsyncTextLoadTask <span style="color: #0000ff;">extends</span> AsyncTask&lt;Object, String, String&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;">17</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Context context;
</span><span style="color: #008080;">18</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> MainActivity activity;
</span><span style="color: #008080;">19</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> BufferedReader br;
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> AsyncTextLoadTask(Context context, BufferedReader br) {
</span><span style="color: #008080;">22</span>         <span style="color: #0000ff;">this</span>.context =<span style="color: #000000;"> context;
</span><span style="color: #008080;">23</span>         <span style="color: #0000ff;">this</span>.br =<span style="color: #000000;"> br;
</span><span style="color: #008080;">24</span>         activity =<span style="color: #000000;"> (MainActivity)context;
</span><span style="color: #008080;">25</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">28</span>     <span style="color: #0000ff;">protected</span><span style="color: #000000;"> String doInBackground(Object... params) {
</span><span style="color: #008080;">29</span>         StringBuilder paragraph = <span style="color: #0000ff;">new</span><span style="color: #000000;"> StringBuilder();
</span><span style="color: #008080;">30</span>         <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;">31</span> 
<span style="color: #008080;">32</span>             String line = ""<span style="color: #000000;">;
</span><span style="color: #008080;">33</span> 
<span style="color: #008080;">34</span>             <span style="color: #0000ff;">int</span> index = 0<span style="color: #000000;">;
</span><span style="color: #008080;">35</span>             <span style="color: #0000ff;">while</span>(index &lt; 50 &amp;&amp; (line = br.readLine()) != <span style="color: #0000ff;">null</span><span style="color: #000000;">){
</span><span style="color: #008080;">36</span>                 paragraph.append(line + "\n"<span style="color: #000000;">);
</span><span style="color: #008080;">37</span>                 index++<span style="color: #000000;">;
</span><span style="color: #008080;">38</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">39</span> 
<span style="color: #008080;">40</span>         } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (IOException e) {
</span><span style="color: #008080;">41</span> <span style="color: #000000;">            e.printStackTrace();
</span><span style="color: #008080;">42</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">43</span> 
<span style="color: #008080;">44</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> paragraph.toString();
</span><span style="color: #008080;">45</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span> 
<span style="color: #008080;">48</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">49</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onPreExecute() {
</span><span style="color: #008080;">50</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onPreExecute();
</span><span style="color: #008080;">51</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">52</span> 
<span style="color: #008080;">53</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">54</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onPostExecute(String result) {
</span><span style="color: #008080;">55</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onPostExecute(result);
</span><span style="color: #008080;">56</span> <span style="color: #000000;">        activity.contentTv.setText(result);
</span><span style="color: #008080;">57</span>         <span style="color: #0000ff;">new</span> Handler().postDelayed(<span style="color: #0000ff;">new</span><span style="color: #000000;"> Runnable() {
</span><span style="color: #008080;">58</span> 
<span style="color: #008080;">59</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">60</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> run() {
</span><span style="color: #008080;">61</span>                 activity.contentScroll.scrollTo(0, 0); <span style="color: #008000;">//</span><span style="color: #008000;"> 记载完新数据后滚动到顶部</span>
<span style="color: #008080;">62</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">63</span>         }, 100<span style="color: #000000;">);
</span><span style="color: #008080;">64</span>         activity.isLoading = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">65</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">66</span> 
<span style="color: #008080;">67</span> }</pre>
</div>

&nbsp;

真正使用分段加载数据Activity（这里加载一本小说《百年孤独》）：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.bigtextloadtest;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.app.Activity;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.content.Context;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.Bundle;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.TextView;
</span><span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.BufferedReader;
</span><span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.IOException;
</span><span style="color: #008080;">10</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.InputStream;
</span><span style="color: #008080;">11</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.InputStreamReader;
</span><span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Activity {
</span><span style="color: #008080;">14</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> BorderScrollView contentScroll;
</span><span style="color: #008080;">15</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> TextView contentTv;
</span><span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> BufferedReader br;
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Context context;
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isLoading;
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> 
<span style="color: #008080;">24</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">25</span> <span style="color: #008000;">     * Called when the activity is first created.
</span><span style="color: #008080;">26</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">27</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">28</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
</span><span style="color: #008080;">29</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
</span><span style="color: #008080;">30</span> <span style="color: #000000;">        setContentView(R.layout.main);
</span><span style="color: #008080;">31</span>         context = <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;">32</span> 
<span style="color: #008080;">33</span>         contentTv =<span style="color: #000000;"> (TextView) findViewById(R.id.content);
</span><span style="color: #008080;">34</span>         contentScroll =<span style="color: #000000;"> (BorderScrollView) findViewById(R.id.contentScroll);
</span><span style="color: #008080;">35</span>         
<span style="color: #008080;">36</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 注册刚写的滚动监听器</span>
<span style="color: #008080;">37</span>         contentScroll.setOnScrollChangedListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> OnScrollChangedListenerSimple(){
</span><span style="color: #008080;">38</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">39</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onScrollBottom() {
</span><span style="color: #008080;">40</span>                 <span style="color: #0000ff;">synchronized</span> (MainActivity.<span style="color: #0000ff;">class</span><span style="color: #000000;">){
</span><span style="color: #008080;">41</span>                     <span style="color: #0000ff;">if</span>(!<span style="color: #000000;">isLoading){
</span><span style="color: #008080;">42</span>                         isLoading = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">43</span>                         <span style="color: #0000ff;">new</span><span style="color: #000000;"> AsyncTextLoadTask(context, br).execute();
</span><span style="color: #008080;">44</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">45</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">46</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">47</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">48</span> 
<span style="color: #008080;">49</span>         <span style="color: #0000ff;">try</span><span style="color: #000000;">{
</span><span style="color: #008080;">50</span>             InputStream is = context.getAssets().open("bngd.txt"<span style="color: #000000;">);
</span><span style="color: #008080;">51</span>             br = <span style="color: #0000ff;">new</span> BufferedReader(<span style="color: #0000ff;">new</span><span style="color: #000000;"> InputStreamReader(is));
</span><span style="color: #008080;">52</span> 
<span style="color: #008080;">53</span>             <span style="color: #0000ff;">new</span><span style="color: #000000;"> AsyncTextLoadTask(context, br).execute();
</span><span style="color: #008080;">54</span> 
<span style="color: #008080;">55</span>         }<span style="color: #0000ff;">catch</span><span style="color: #000000;">(Exception ex){
</span><span style="color: #008080;">56</span> <span style="color: #000000;">            ex.printStackTrace();
</span><span style="color: #008080;">57</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">58</span> 
<span style="color: #008080;">59</span> 
<span style="color: #008080;">60</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">61</span> 
<span style="color: #008080;">62</span> 
<span style="color: #008080;">63</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">64</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onDestroy() {
</span><span style="color: #008080;">65</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onDestroy();
</span><span style="color: #008080;">66</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> br){
</span><span style="color: #008080;">67</span>             <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;">68</span> <span style="color: #000000;">                br.close();
</span><span style="color: #008080;">69</span>             } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (IOException e) {
</span><span style="color: #008080;">70</span> <span style="color: #000000;">                e.printStackTrace();
</span><span style="color: #008080;">71</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">72</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">73</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">74</span> 
<span style="color: #008080;">75</span> }</pre>
</div>

&nbsp;

贴上布局：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span>
<span style="color: #008080;"> 3</span> <span style="color: #ff0000;">              android:orientation</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;"> 4</span> <span style="color: #ff0000;">              android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 5</span> <span style="color: #ff0000;">              android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 6</span>         <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">com.wangjie.bigtextloadtest.BorderScrollView
</span><span style="color: #008080;"> 8</span>             <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/contentScroll"</span>
<span style="color: #008080;"> 9</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">10</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">11</span>             <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">12</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout
</span><span style="color: #008080;">13</span>                 <span style="color: #ff0000;">android:orientation</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;">14</span> <span style="color: #ff0000;">                android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">15</span> <span style="color: #ff0000;">                android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">16</span>                 <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">17</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TextView
</span><span style="color: #008080;">18</span>                     <span style="color: #ff0000;">android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">19</span> <span style="color: #ff0000;">                    android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;">20</span> <span style="color: #ff0000;">                    android:text</span><span style="color: #0000ff;">="asdfasdf"</span>
<span style="color: #008080;">21</span>                     <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">22</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TextView
</span><span style="color: #008080;">23</span>                     <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/content"</span>
<span style="color: #008080;">24</span> <span style="color: #ff0000;">                    android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">25</span> <span style="color: #ff0000;">                    android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span>
<span style="color: #008080;">26</span> <span style="color: #ff0000;">                    android:text</span><span style="color: #0000ff;">="Hello World, MainActivity"</span>
<span style="color: #008080;">27</span>                     <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">28</span>         <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">29</span> 
<span style="color: #008080;">30</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">com.wangjie.bigtextloadtest.BorderScrollView</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">31</span> 
<span style="color: #008080;">32</span> 
<span style="color: #008080;">33</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

&nbsp;

&nbsp;

