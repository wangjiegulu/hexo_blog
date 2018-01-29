---
title: '[Android]使用RecyclerView替代ListView（二）'
tags: []
date: 2015-01-22 19:51:00
---

<span style="color: #ff0000;">**以下内容为原创，转载请注明：**</span>

**<span style="color: #ff0000;">来自天天博客：[<span style="color: #ff0000;">http://www.cnblogs.com/tiantianbyconan/p/4242541.html</span>](http://www.cnblogs.com/tiantianbyconan/p/4242541.html "view: [Android]使用RecyclerView替代ListView（二）")</span>
**

&nbsp;

以前写过一篇&ldquo;[[Android]使用AdapterTypeRender对不同类型的item数据到UI的渲染](http://www.cnblogs.com/tiantianbyconan/p/3992843.html)（[http://www.cnblogs.com/tiantianbyconan/p/3992843.html](http://www.cnblogs.com/tiantianbyconan/p/3992843.html)）&rdquo;，用于在有很多不同类型不同布局的item的时候怎么去较好的进行view的绑定和数据的渲染，但是这个是针对ListView写的。这次我针对RecyclerView也重新实现了一遍。

接下来演示下怎么去渲染不同类型的item，并且使它支持下拉刷新，滚动到底部显示加载进度条显示。

以下所有的封装都在[**AndroidBucket**](https://github.com/wangjiegulu/AndroidBucket)项目中：**[https://github.com/wangjiegulu/AndroidBucket/tree/master/src/com/wangjie/androidbucket/support/recyclerview](https://github.com/wangjiegulu/AndroidBucket/tree/master/src/com/wangjie/androidbucket/support/recyclerview)
**

![](http://images.cnitblog.com/blog/378300/201501/221902087508177.png)&nbsp;![](http://images.cnitblog.com/blog/378300/201501/221902461722079.png)

使用的方式如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">final</span> View footerView = LayoutInflater.from(context).inflate(R.layout.recycler_view_item_type_footer, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 2</span> <span style="color: #008000;">//</span><span style="color: #008000;">        不知道为什么在xml设置的&ldquo;android:layout_width="match_parent"&rdquo;无效了，需要在这里重新设置</span>
<span style="color: #008080;"> 3</span>         LinearLayout.LayoutParams lp = <span style="color: #0000ff;">new</span><span style="color: #000000;"> LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">        footerView.setLayoutParams(lp);
</span><span style="color: #008080;"> 5</span> 
<span style="color: #008080;"> 6</span>         recyclerView.setHasFixedSize(<span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span>         <span style="color: #0000ff;">final</span> ABaseLinearLayoutManager layoutManager = <span style="color: #0000ff;">new</span><span style="color: #000000;"> ABaseLinearLayoutManager(context);
</span><span style="color: #008080;"> 9</span>         layoutManager.setOnRecyclerViewScrollLocationListener(recyclerView, <span style="color: #0000ff;">new</span><span style="color: #000000;"> OnRecyclerViewScrollLocationListener() {
</span><span style="color: #008080;">10</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">11</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onTopWhenScrollIdle(RecyclerView recyclerView) {
</span><span style="color: #008080;">12</span>                 Logger.d(TAG, "onTopWhenScrollIdle..."<span style="color: #000000;">);
</span><span style="color: #008080;">13</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">16</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onBottomWhenScrollIdle(RecyclerView recyclerView) {
</span><span style="color: #008080;">17</span>                 Logger.d(TAG, "onBottomWhenScrollIdle..."<span style="color: #000000;">);
</span><span style="color: #008080;">18</span> <span style="color: #000000;">                footerView.setVisibility(View.VISIBLE);
</span><span style="color: #008080;">19</span>                 ThreadPool.go(<span style="color: #0000ff;">new</span> Runtask&lt;Object, Object&gt;<span style="color: #000000;">() {
</span><span style="color: #008080;">20</span> <span style="color: #000000;">                    @Override
</span><span style="color: #008080;">21</span>                     <span style="color: #0000ff;">public</span><span style="color: #000000;"> Object runInBackground() {
</span><span style="color: #008080;">22</span>                         ABThreadUtil.sleep(3000<span style="color: #000000;">);
</span><span style="color: #008080;">23</span>                         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">24</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">25</span> 
<span style="color: #008080;">26</span> <span style="color: #000000;">                    @Override
</span><span style="color: #008080;">27</span>                     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onResult(Object result) {
</span><span style="color: #008080;">28</span>                         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onResult(result);
</span><span style="color: #008080;">29</span>                         refreshLayout.setRefreshing(<span style="color: #0000ff;">false</span><span style="color: #000000;">);
</span><span style="color: #008080;">30</span> <span style="color: #000000;">                        footerView.setVisibility(View.GONE);
</span><span style="color: #008080;">31</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">32</span> <span style="color: #000000;">                });
</span><span style="color: #008080;">33</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">34</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">35</span> <span style="color: #000000;">        layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
</span><span style="color: #008080;">36</span>         layoutManager.getRecyclerViewScrollManager().addScrollListener(recyclerView, <span style="color: #0000ff;">new</span><span style="color: #000000;"> OnRecyclerViewScrollListener() {
</span><span style="color: #008080;">37</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">38</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onScrollStateChanged(RecyclerView recyclerView, <span style="color: #0000ff;">int</span><span style="color: #000000;"> newState) {
</span><span style="color: #008080;">39</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">40</span> 
<span style="color: #008080;">41</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">42</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onScrolled(RecyclerView recyclerView, <span style="color: #0000ff;">int</span> dx, <span style="color: #0000ff;">int</span><span style="color: #000000;"> dy) {
</span><span style="color: #008080;">43</span>                 refreshLayout.setEnabled(layoutManager.findFirstCompletelyVisibleItemPosition() == 0<span style="color: #000000;">);
</span><span style="color: #008080;">44</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">45</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">46</span> <span style="color: #000000;">        recyclerView.setLayoutManager(layoutManager);
</span><span style="color: #008080;">47</span> 
<span style="color: #008080;">48</span> <span style="color: #000000;">        initData();
</span><span style="color: #008080;">49</span> 
<span style="color: #008080;">50</span>         adapter = <span style="color: #0000ff;">new</span> PersonTypeAdapter(context, personList, <span style="color: #0000ff;">null</span><span style="color: #000000;">, footerView);
</span><span style="color: #008080;">51</span>         adapter.setOnRecyclerViewListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">52</span> <span style="color: #000000;">        recyclerView.setAdapter(adapter);
</span><span style="color: #008080;">53</span> 
<span style="color: #008080;">54</span> <span style="color: #000000;">        refreshLayout.setColorSchemeColors(Color.BLUE, Color.RED, Color.YELLOW, Color.GREEN);
</span><span style="color: #008080;">55</span>         refreshLayout.setOnRefreshListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> SwipeRefreshLayout.OnRefreshListener() {
</span><span style="color: #008080;">56</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">57</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onRefresh() {
</span><span style="color: #008080;">58</span>                 ThreadPool.go(<span style="color: #0000ff;">new</span> Runtask&lt;Object, Object&gt;<span style="color: #000000;">() {
</span><span style="color: #008080;">59</span> <span style="color: #000000;">                    @Override
</span><span style="color: #008080;">60</span>                     <span style="color: #0000ff;">public</span><span style="color: #000000;"> Object runInBackground() {
</span><span style="color: #008080;">61</span>                         ABThreadUtil.sleep(3000<span style="color: #000000;">);
</span><span style="color: #008080;">62</span>                         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">63</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">64</span> 
<span style="color: #008080;">65</span> <span style="color: #000000;">                    @Override
</span><span style="color: #008080;">66</span>                     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onResult(Object result) {
</span><span style="color: #008080;">67</span>                         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onResult(result);
</span><span style="color: #008080;">68</span>                         refreshLayout.setRefreshing(<span style="color: #0000ff;">false</span><span style="color: #000000;">);
</span><span style="color: #008080;">69</span> <span style="color: #000000;">                        footerView.setVisibility(View.GONE);
</span><span style="color: #008080;">70</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">71</span> <span style="color: #000000;">                });
</span><span style="color: #008080;">72</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">73</span>         });</pre>
</div>

&nbsp;

<span style="line-height: 1.5;">如上述代码：</span>

Line1：从布局文件中inflate出一个View实例，这个View实例，下面会被用于作为下载提示的footer。

Line8：生成一个**[ABaseLinearLayoutManager](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/layoutmanager/ABaseLinearLayoutManager.java)**实例，显然这个类是继承LinearLayoutManager之后扩展的，详见：[https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/layoutmanager/ABaseLinearLayoutManager.java](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/layoutmanager/ABaseLinearLayoutManager.java)，这个类对滑动的监听进行了扩展，可以监听滑动到顶部或者底部的事件

Line9～34：设置滑动到顶部或底部的监听器，然后一旦滑动到底部则加载更多数据。

Line36～45：也是设置滑动监听器，滑动过程中如果不是处在第一个item，如果是，则就可以下拉使用SwipeRefreshLayout进行刷新，如果不是则，仅用SwipeRefreshLayout。之所以需要做这个处理，是因为Google事件处理的一个bug－－。

Line50：使用了一个PersonTypeAdapter，这个类继承了**[ABRecyclerViewTypeExtraViewAdapter](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/extra/ABRecyclerViewTypeExtraViewAdapter.java)，**这个类继承RecyclerView.Adapter实现了对不同type渲染数据的封装。

&nbsp;

接下来重点分析下ABRecyclerViewTypeExtraViewAdapter这个类（这个类在平常使用时不需要关注）：

<div class="cnblogs_code">
<pre><span style="color: #008080;">  1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">  2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;">  3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;">  4</span> <span style="color: #008000;"> * Date: 1/22/15.
</span><span style="color: #008080;">  5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">  6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> <span style="color: #0000ff;">class</span> ABRecyclerViewTypeExtraViewAdapter <span style="color: #0000ff;">extends</span> RecyclerView.Adapter&lt;ABRecyclerViewTypeExtraHolder&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;">  7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> TYPE_HEADER_VIEW = 0x7683<span style="color: #000000;">;
</span><span style="color: #008080;">  8</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> View headerView;
</span><span style="color: #008080;">  9</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> TYPE_FOOTER_VIEW = 0x7684<span style="color: #000000;">;
</span><span style="color: #008080;"> 10</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> View footerView;
</span><span style="color: #008080;"> 11</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> extraCount;
</span><span style="color: #008080;"> 12</span> 
<span style="color: #008080;"> 13</span>     <span style="color: #0000ff;">protected</span><span style="color: #000000;"> ABRecyclerViewTypeExtraViewAdapter(View headerView, View footerView) {
</span><span style="color: #008080;"> 14</span>         <span style="color: #0000ff;">this</span>.headerView =<span style="color: #000000;"> headerView;
</span><span style="color: #008080;"> 15</span>         <span style="color: #0000ff;">this</span>.footerView =<span style="color: #000000;"> footerView;
</span><span style="color: #008080;"> 16</span>         extraCount += hasHeaderView() ? 0 : 1<span style="color: #000000;">;
</span><span style="color: #008080;"> 17</span>         extraCount += hasFooterView() ? 0 : 1<span style="color: #000000;">;
</span><span style="color: #008080;"> 18</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 19</span> 
<span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> hasHeaderView() {
</span><span style="color: #008080;"> 21</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> headerView;
</span><span style="color: #008080;"> 22</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 23</span> 
<span style="color: #008080;"> 24</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> hasFooterView() {
</span><span style="color: #008080;"> 25</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> footerView;
</span><span style="color: #008080;"> 26</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 27</span> 
<span style="color: #008080;"> 28</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> innerPositionToRealItemPosition(<span style="color: #0000ff;">int</span><span style="color: #000000;"> innerPosition) {
</span><span style="color: #008080;"> 29</span>         <span style="color: #0000ff;">return</span> hasHeaderView() ? innerPosition - 1<span style="color: #000000;"> : innerPosition;
</span><span style="color: #008080;"> 30</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 31</span> 
<span style="color: #008080;"> 32</span> <span style="color: #000000;">    @TargetApi(Build.VERSION_CODES.DONUT)
</span><span style="color: #008080;"> 33</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 34</span>     <span style="color: #0000ff;">public</span> ABRecyclerViewTypeExtraHolder onCreateViewHolder(ViewGroup viewGroup, <span style="color: #0000ff;">int</span><span style="color: #000000;"> viewType) {
</span><span style="color: #008080;"> 35</span>         ABAdapterTypeRender&lt;ABRecyclerViewTypeExtraHolder&gt; render =<span style="color: #000000;"> getAdapterTypeRender(viewType);
</span><span style="color: #008080;"> 36</span>         ABRecyclerViewTypeExtraHolder holder =<span style="color: #000000;"> render.getReusableComponent();
</span><span style="color: #008080;"> 37</span> <span style="color: #000000;">        holder.itemView.setTag(R.id.ab__id_adapter_item_type_render, render);
</span><span style="color: #008080;"> 38</span> <span style="color: #000000;">        render.fitEvents();
</span><span style="color: #008080;"> 39</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> holder;
</span><span style="color: #008080;"> 40</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 41</span> 
<span style="color: #008080;"> 42</span> <span style="color: #000000;">    @TargetApi(Build.VERSION_CODES.DONUT)
</span><span style="color: #008080;"> 43</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 44</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onBindViewHolder(ABRecyclerViewTypeExtraHolder holder, <span style="color: #0000ff;">int</span><span style="color: #000000;"> innerPosition) {
</span><span style="color: #008080;"> 45</span>         ABAdapterTypeRender&lt;ABRecyclerViewTypeExtraHolder&gt; render = (ABAdapterTypeRender&lt;ABRecyclerViewTypeExtraHolder&gt;<span style="color: #000000;">) holder.itemView.getTag(R.id.ab__id_adapter_item_type_render);
</span><span style="color: #008080;"> 46</span>         <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 47</span> <span style="color: #008000;">         * 计算该item在list中的index（不包括headerView和footerView）
</span><span style="color: #008080;"> 48</span>          <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 49</span>         <span style="color: #0000ff;">int</span> realItemPosition =<span style="color: #000000;"> innerPositionToRealItemPosition(innerPosition);
</span><span style="color: #008080;"> 50</span> <span style="color: #000000;">        render.fitDatas(realItemPosition);
</span><span style="color: #008080;"> 51</span>         <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 52</span> <span style="color: #008000;">         * 重新设置item在list中的index（不包括headerView和footerView）
</span><span style="color: #008080;"> 53</span>          <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 54</span> <span style="color: #000000;">        holder.setRealItemPosition(realItemPosition);
</span><span style="color: #008080;"> 55</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 56</span> 
<span style="color: #008080;"> 57</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 58</span> <span style="color: #008000;">     * 通过类型获得对应的render（不包括headerView和footerView）
</span><span style="color: #008080;"> 59</span> <span style="color: #008000;">     *
</span><span style="color: #008080;"> 60</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> type
</span><span style="color: #008080;"> 61</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;"> 62</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 63</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> ABAdapterTypeRender&lt;ABRecyclerViewTypeExtraHolder&gt; getAdapterTypeRenderExcludeExtraView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> type);
</span><span style="color: #008080;"> 64</span> 
<span style="color: #008080;"> 65</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 66</span> <span style="color: #008000;">     * 获取item的数量（不包括headerView和footerView）
</span><span style="color: #008080;"> 67</span> <span style="color: #008000;">     *
</span><span style="color: #008080;"> 68</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;"> 69</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 70</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getItemCountExcludeExtraView();
</span><span style="color: #008080;"> 71</span> 
<span style="color: #008080;"> 72</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 73</span> <span style="color: #008000;">     * 通过realItemPosition得到该item的类型（不包括headerView和footerView）
</span><span style="color: #008080;"> 74</span> <span style="color: #008000;">     *
</span><span style="color: #008080;"> 75</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> realItemPosition
</span><span style="color: #008080;"> 76</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;"> 77</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 78</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> <span style="color: #0000ff;">int</span> getItemViewTypeExcludeExtraView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> realItemPosition);
</span><span style="color: #008080;"> 79</span> 
<span style="color: #008080;"> 80</span>     <span style="color: #0000ff;">public</span> ABAdapterTypeRender&lt;ABRecyclerViewTypeExtraHolder&gt; getAdapterTypeRender(<span style="color: #0000ff;">int</span><span style="color: #000000;"> type) {
</span><span style="color: #008080;"> 81</span>         <span style="color: #0000ff;">switch</span><span style="color: #000000;"> (type) {
</span><span style="color: #008080;"> 82</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> TYPE_HEADER_VIEW:
</span><span style="color: #008080;"> 83</span>                 <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> ABRecyclerViewTypeExtraRender(headerView);
</span><span style="color: #008080;"> 84</span>             <span style="color: #0000ff;">case</span><span style="color: #000000;"> TYPE_FOOTER_VIEW:
</span><span style="color: #008080;"> 85</span>                 <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> ABRecyclerViewTypeExtraRender(footerView);
</span><span style="color: #008080;"> 86</span>             <span style="color: #0000ff;">default</span><span style="color: #000000;">:
</span><span style="color: #008080;"> 87</span>                 <span style="color: #0000ff;">return</span><span style="color: #000000;"> getAdapterTypeRenderExcludeExtraView(type);
</span><span style="color: #008080;"> 88</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 89</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 90</span> 
<span style="color: #008080;"> 91</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 92</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getItemCount() {
</span><span style="color: #008080;"> 93</span>         <span style="color: #0000ff;">return</span> getItemCountExcludeExtraView() +<span style="color: #000000;"> extraCount;
</span><span style="color: #008080;"> 94</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 95</span> 
<span style="color: #008080;"> 96</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 97</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> getItemViewType(<span style="color: #0000ff;">int</span><span style="color: #000000;"> innerPosition) {
</span><span style="color: #008080;"> 98</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> != headerView &amp;&amp; 0 == innerPosition) { <span style="color: #008000;">//</span><span style="color: #008000;"> header</span>
<span style="color: #008080;"> 99</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;"> TYPE_HEADER_VIEW;
</span><span style="color: #008080;">100</span>         } <span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> != footerView &amp;&amp; getItemCount() - 1 == innerPosition) { <span style="color: #008000;">//</span><span style="color: #008000;"> footer</span>
<span style="color: #008080;">101</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;"> TYPE_FOOTER_VIEW;
</span><span style="color: #008080;">102</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">103</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> getItemViewTypeExcludeExtraView(innerPositionToRealItemPosition(innerPosition));
</span><span style="color: #008080;">104</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">105</span> }</pre>
</div>

如上述代码所示：

因为我们的需求是需要添加&ldquo;加载进度条&rdquo;，所以需要像ListView那样，添加一个FooterView。可是坑爹的是，RecyclerView不提供addheaderView()和addFooterView()方法，所以只能我们自己去实现了，方法当然是使用不同type来区分类型。虽然headerView这里没有用到，但是也顺带实现下好了。

这里我们使用的Holder是[**ABRecyclerViewTypeExtraHolder**](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/extra/ABRecyclerViewTypeExtraHolder.java)，这个类待会分析。

headerView和footerView这里使用构造方法传入，并缓存headerView和footerView。在onCreateViewHolder中，我们通过不同type，生成相应的render。并把render绑定到holder的itemView上面，因为既然现在复用的是holder，那我的render也要实现复用的话，也绑定在holder里面吧。然后调用render的fitEvents方法，来实现render里面的事件绑定。

onBindViewHolder方法中，通过holder，取出render，然后注意Line49～54，里面执行了innerPositionToRealItemPosition()方法对innerPosition到RealItemPosition的转换，这里的innerPosition代表内部的position，因为这里可能会添加了headerView，一旦添加了headerView，那position跟数据源List中的index就不匹配了，这样的话绑定点击事件后，通过holder.getPositon()得到的position就不是index了，所以不能写&ldquo;list.get(position)...&rdquo;了。这里的realItemPosition就代表数据源对应的index 。所以我们要把innerPosition转换为realItemPosition，方法很简单，innerPosition－1=realItemPosition（这里的减去1实际上就是减去了headerView）。其实holder中本来就缓存了当前使用了这个holder的item的position，但是因为有了headerView的存在，position就不等于realItemPosition了，所以我们还需要缓存realItemPosition。所以代码Line46～54诞生了。

getItemCountExcludeExtraView()方法需要子类实现，返回数据源中的数据数量，然后再加上extraCount即是getItemCount的值。

getItemViewType()方法先执行了header类型和footer类型的逻辑，然后再让自类去实现getItemViewTypeExcludeExtraView()来执行其他类型的逻辑。

至于**[ABRecyclerViewTypeExtraRender](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/extra/ABRecyclerViewTypeExtraRender.java)（[https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/extra/ABRecyclerViewTypeExtraRender.java](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/extra/ABRecyclerViewTypeExtraRender.java)）**

部分的实现可以查看

**[[Android]使用AdapterTypeRender对不同类型的item数据到UI的渲染](http://www.cnblogs.com/[Android]使用AdapterTypeRender对不同类型的item数据到UI的渲染)**（**[http://www.cnblogs.com/tiantianbyconan/p/3992843.html](http://www.cnblogs.com/tiantianbyconan/p/3992843.html)**）

实现的原理大同小异了。

&nbsp;

然后分析下**[ABRecyclerViewTypeExtraHolder](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/extra/ABRecyclerViewTypeExtraHolder.java)（[https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/extra/ABRecyclerViewTypeExtraHolder.java](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/extra/ABRecyclerViewTypeExtraHolder.java)）**这个类，代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 1/22/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> ABRecyclerViewTypeExtraHolder <span style="color: #0000ff;">extends</span><span style="color: #000000;"> ABRecyclerViewHolder {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> ABRecyclerViewTypeExtraHolder(View itemView) {
</span><span style="color: #008080;"> 8</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(itemView);
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">12</span> <span style="color: #008000;">     * 保存当前position（list index，不包括headerView和footerView）
</span><span style="color: #008080;">13</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">14</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> realItemPosition;
</span><span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getRealItemPosition() {
</span><span style="color: #008080;">17</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> realItemPosition;
</span><span style="color: #008080;">18</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span> setRealItemPosition(<span style="color: #0000ff;">int</span><span style="color: #000000;"> realItemPosition) {
</span><span style="color: #008080;">21</span>         <span style="color: #0000ff;">this</span>.realItemPosition =<span style="color: #000000;"> realItemPosition;
</span><span style="color: #008080;">22</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">23</span> 
<span style="color: #008080;">24</span> }</pre>
</div>

它继承了[**ABRecyclerViewHolder**](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/ABRecyclerViewHolder.java)（**[https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/ABRecyclerViewHolder.java](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/ABRecyclerViewHolder.java)**），只是保存了一个刚刚讲到的realItemPosition对象。

所以我们再贴下**[ABRecyclerViewHolder](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/support/recyclerview/adapter/ABRecyclerViewHolder.java)**的代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 1/19/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> ABRecyclerViewHolder <span style="color: #0000ff;">extends</span><span style="color: #000000;"> RecyclerView.ViewHolder {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = ABRecyclerViewHolder.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">private</span> SparseArray&lt;View&gt; holder = <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> ABRecyclerViewHolder(View itemView) {
</span><span style="color: #008080;">11</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(itemView);
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">13</span> 
<span style="color: #008080;">14</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">15</span> <span style="color: #008000;">     * 获取一个缓存的view
</span><span style="color: #008080;">16</span> <span style="color: #008000;">     *
</span><span style="color: #008080;">17</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> id
</span><span style="color: #008080;">18</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> &lt;T&gt;
</span><span style="color: #008080;">19</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;">20</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span> &lt;T <span style="color: #0000ff;">extends</span> View&gt; T obtainView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> id) {
</span><span style="color: #008080;">22</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> holder) {
</span><span style="color: #008080;">23</span>             holder = <span style="color: #0000ff;">new</span> SparseArray&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">24</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">25</span>         View view =<span style="color: #000000;"> holder.get(id);
</span><span style="color: #008080;">26</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> view) {
</span><span style="color: #008080;">27</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;"> (T) view;
</span><span style="color: #008080;">28</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">29</span>         view =<span style="color: #000000;"> itemView.findViewById(id);
</span><span style="color: #008080;">30</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> view) {
</span><span style="color: #008080;">31</span>             Logger.e(TAG, "no view that id is " +<span style="color: #000000;"> id);
</span><span style="color: #008080;">32</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">33</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">34</span> <span style="color: #000000;">        holder.put(id, view);
</span><span style="color: #008080;">35</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> (T) view;
</span><span style="color: #008080;">36</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">37</span> 
<span style="color: #008080;">38</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">39</span> <span style="color: #008000;">     * 获取一个缓存的view，并自动转型
</span><span style="color: #008080;">40</span> <span style="color: #008000;">     *
</span><span style="color: #008080;">41</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> id
</span><span style="color: #008080;">42</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> &lt;T&gt;
</span><span style="color: #008080;">43</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;">44</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">45</span>     <span style="color: #0000ff;">public</span> &lt;T&gt; T obtainView(<span style="color: #0000ff;">int</span> id, Class&lt;T&gt;<span style="color: #000000;"> viewClazz) {
</span><span style="color: #008080;">46</span>         View view =<span style="color: #000000;"> obtainView(id);
</span><span style="color: #008080;">47</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> view) {
</span><span style="color: #008080;">48</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">49</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">50</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> (T) view;
</span><span style="color: #008080;">51</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">52</span> 
<span style="color: #008080;">53</span> }</pre>
</div>

然后发现，它的作用是在于使用SparseArray来缓存findViewById后的控件。这样做的好处是，这个holder可以适用于任何的RecyclerView.Adapter中。只要通过obtainView()方法就能得到itemView中的具体的view对象，如下代码所示：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> Person person =<span style="color: #000000;"> adapter.getList().get(position);
</span><span style="color: #008080;">2</span> holder.obtainView(R.id.recycler_view_test_item_person_name_tv, TextView.<span style="color: #0000ff;">class</span><span style="color: #000000;">).setText(person.getName());＝
</span><span style="color: #008080;">3</span> holder.obtainView(R.id.recycler_view_test_item_person_age_tv, TextView.<span style="color: #0000ff;">class</span>).setText(person.getAge() + "岁");</pre>
</div>

&nbsp;

**示例代码：**

**[https://github.com/wangjiegulu/RecyclerViewSample](https://github.com/wangjiegulu/RecyclerViewSample)**

&nbsp;

<span style="font-size: 16px; color: #ff0000;">**[<span style="color: #ff0000;">[Android]使用RecyclerView替代ListView（一）</span>](http://www.cnblogs.com/tiantianbyconan/p/4232560.html)**：</span>

<span style="font-size: 16px;">**[http://www.cnblogs.com/tiantianbyconan/p/4232560.html](http://www.cnblogs.com/tiantianbyconan/p/4232560.html)**</span>

&nbsp;

<span style="color: #ff0000;"><span style="font-size: 16px;">**[<span style="color: #ff0000;">[Android]使用RecyclerView替代ListView（三）</span>](http://www.cnblogs.com/tiantianbyconan/p/4268097.html)**：</span>&nbsp;</span>

<span style="font-size: 16px; line-height: 24px;">**[http://www.cnblogs.com/tiantianbyconan/p/4268097.html](http://www.cnblogs.com/tiantianbyconan/p/4268097.html)**</span>

&nbsp;