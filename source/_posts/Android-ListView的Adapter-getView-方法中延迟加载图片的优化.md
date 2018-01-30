---
title: '[Android]ListView的Adapter.getView()方法中延迟加载图片的优化'
tags: [android, ListView, optimize, best practices]
date: 2014-12-03 14:19:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

**<span style="color: #ff0000;">来自天天博客：[<span style="color: #ff0000;">http://www.cnblogs.com/tiantianbyconan/p/4139998.html</span>](http://www.cnblogs.com/tiantianbyconan/p/4139998.html%20 "view: [Android]ListView的Adapter.getView()方法中延迟加载图片的优化")</span>[
](http://www.cnblogs.com/tiantianbyconan/p/3574131.html "view: [Android]异步加载图片，内存缓存，文件缓存，imageview显示图片时增加淡入淡出动画")**

&nbsp;

举个例子吧，以好友列表为例

ListView中每个Item表示一个好友，每个好友中都有一个头像，需要从服务端加载到本地，然后显示在item中。

显然，启动加载图片的过程应该是在getView()方法中触发，启动一个线程，然后下载头像图片。这里使用我写的一个开源框架**[ImageLoaderSample](https://github.com/wangjiegulu/ImageLoaderSample)**（[https://github.com/wangjiegulu/ImageLoaderSample](https://github.com/wangjiegulu/ImageLoaderSample)）来加载图片，并实现内存缓存和本地缓存。

额－－这里不再介绍ImageLoaderSample的用法了，给个传送门：[http://www.cnblogs.com/tiantianbyconan/p/3574131.html](http://www.cnblogs.com/tiantianbyconan/p/3574131.html)

&nbsp;

再来看看getView()方法的调用时机：

1\. Adapter调用NotifyDataChanged的时候

2\. ListView滚动时，也就是convertView不断复用的时候。

也就是说，每当ListView滚动时，getView()方法不断被调用，图片下载的过程不断地执行（当然，**[ImageLoaderSample](https://github.com/wangjiegulu/ImageLoaderSample)**中会有缓存，但是内存缓存时有限的，如果内存缓存中找不到要显示的图片，那就需要到文件缓存中查找，需要进行io读写，这个也是相对比较耗时的），显然，这里面还有优化的余地。

怎么去优化这里？只要让ListView滚动的时候图片显示的时候不要去进行io读写就好了，具体逻辑如下：

－如果调用GetView方法时，ListView处于停止状态，则先去内存中查找头像图片；如果内存图片存在，则显示内存中保存好的图片；如果内存图片不存在，则继续到文件缓存中找，如果文件缓存图片存在，则显示文件缓存中的图片；如果文件缓存图片不存在，则根据url去网络下载这张图片，然后显示；

－如果调用getView方法时，ListView处于滚动状态，则去内存中查找头像的图片；如果内存图片存在，则显示内存中保存好的图片；如果内存图片不存在，则显示一张默认的图片（省去了从文件缓存中找图片和网络中去请求图片的步骤）。

&nbsp;

这样的话，我们就必须要改写BaseAdapter，让它能够监测ListView的滚动状态，并在Adapter中可以获取到当前ListView的滚动状态。所以改造BaseAdapter，**[ABaseAdapter](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/adapter/ABaseAdapter.java)**（[https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/adapter/ABaseAdapter.java](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/adapter/ABaseAdapter.java)）：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span> android.widget.*<span style="color: #000000;">;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter.listener.OnAdapterScrollListener;
</span><span style="color: #008080;"> 5</span> 
<span style="color: #008080;"> 6</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 7</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 8</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 9</span> <span style="color: #008000;"> * Date: 12/3/14.
</span><span style="color: #008080;">10</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">11</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> <span style="color: #0000ff;">class</span> ABaseAdapter <span style="color: #0000ff;">extends</span> BaseAdapter <span style="color: #0000ff;">implements</span><span style="color: #000000;"> AbsListView.OnScrollListener {
</span><span style="color: #008080;">12</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> OnAdapterScrollListener onAdapterScrollListener;
</span><span style="color: #008080;">13</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">14</span> <span style="color: #008000;">     * 当前listview是否属于滚动状态
</span><span style="color: #008080;">15</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">16</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isScrolling;
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isScrolling() {
</span><span style="color: #008080;">19</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> isScrolling;
</span><span style="color: #008080;">20</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOnAdapterScrollListener(OnAdapterScrollListener onAdapterScrollListener) {
</span><span style="color: #008080;">23</span>         <span style="color: #0000ff;">this</span>.onAdapterScrollListener =<span style="color: #000000;"> onAdapterScrollListener;
</span><span style="color: #008080;">24</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">25</span> 
<span style="color: #008080;">26</span>     <span style="color: #0000ff;">protected</span><span style="color: #000000;"> ABaseAdapter(AbsListView listView) {
</span><span style="color: #008080;">27</span>         listView.setOnScrollListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">28</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">29</span> 
<span style="color: #008080;">30</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">31</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onScroll(AbsListView view, <span style="color: #0000ff;">int</span> firstVisibleItem, <span style="color: #0000ff;">int</span> visibleItemCount, <span style="color: #0000ff;">int</span><span style="color: #000000;"> totalItemCount) {
</span><span style="color: #008080;">32</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> onAdapterScrollListener) {
</span><span style="color: #008080;">33</span> <span style="color: #000000;">            onAdapterScrollListener.onScroll(view, firstVisibleItem, visibleItemCount, totalItemCount);
</span><span style="color: #008080;">34</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">35</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">36</span> 
<span style="color: #008080;">37</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">38</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onScrollStateChanged(AbsListView view, <span style="color: #0000ff;">int</span><span style="color: #000000;"> scrollState) {
</span><span style="color: #008080;">39</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> onAdapterScrollListener) {
</span><span style="color: #008080;">40</span> <span style="color: #000000;">            onAdapterScrollListener.onScrollStateChanged(view, scrollState);
</span><span style="color: #008080;">41</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">42</span> 
<span style="color: #008080;">43</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置是否滚动的状态</span>
<span style="color: #008080;">44</span>         <span style="color: #0000ff;">if</span> (scrollState == AbsListView.OnScrollListener.SCROLL_STATE_IDLE) { <span style="color: #008000;">//</span><span style="color: #008000;"> 不滚动状态</span>
<span style="color: #008080;">45</span>             isScrolling = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">46</span>             <span style="color: #0000ff;">this</span><span style="color: #000000;">.notifyDataSetChanged();
</span><span style="color: #008080;">47</span>         } <span style="color: #0000ff;">else</span><span style="color: #000000;"> {
</span><span style="color: #008080;">48</span>             isScrolling = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">49</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">50</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">51</span> }</pre>
</div>

如上述代码所示，该Adapter实现了AbsListView.OnScrollListener，并在构造方法中给ListView绑定了OnScrollListener，在实现的onScrollStateChanged方法中获取到当前滚动状态，并且保存这个状态isScrolling，并暴露isScrolling()方法给外面。

OnAdapterScrollListener这个接口是继承了AbsListView.OnScrollListener，因为这里在Adapter中一景设置了OnScrollListener了，所以如果在外面设置了新的OnScrollListener的话，就会失效了，所以必须提供另外一个setOnAdapterScrollListener，然后再传入一个OnScrollListener，然后在每个方法中进行回调就好了，因为考虑到以后可能会扩展其他的接口方法，所以这里新写了一个接口（为了以后扩展时原来的代码不会被影响，推荐使用OnAdapterScrollSampleListener这个实现类来代替OnAdapterScrollListener这个接口，OnAdapterScrollSampleListener这个类只是对OnAdapterScrollListener的所有方法进行了空实现）。

&nbsp;

然后我们编写一个MyAdapter继承ABaseAdapter，然后，在getView()方法中，需要显示头像的时候调用如下方法：

// 如果在滚动（从内存中查找，找不到也不进行网络请求）

<div class="cnblogs_code">
<pre>ImageLoader.getInstances().displayImage(headUrl, headIv, <span style="color: #0000ff;">null</span>, R.drawable.default_head, isScrolling());</pre>
</div>

看到木有？

1\. displayImage()方法发生了改变，多了最后一个参数isOnlyMemory这个参数，表示是否只是在内存缓存中找这张图片，如果没有就不再继续找下去了（displayImage原来的方法我还留着，所以不会影响之前的代码）。

2\. 调用了isScrolling()方法，作为参数isOnlyMemory的值，表示，如果正在滚动的话，就只在缓存中找这张图片。

这样，运行原来的代码试试吧，是不是效率快了一些？

&nbsp;

