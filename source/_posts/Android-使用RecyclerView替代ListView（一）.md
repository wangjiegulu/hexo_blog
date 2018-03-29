---
title: '[Android]使用RecyclerView替代ListView（一）'
tags: [android, RecyclerView, ListView, best practices]
date: 2015-01-18 23:01:00
---

RecyclerView是一个比ListView更灵活的一个控件，以后可以直接抛弃ListView了。具体好在哪些地方，往下看就知道了。

首先我们来使用RecyclerView来实现ListView的效果，一个滚动列表，先看下效果图（除了有动画之外，没什么特别－－）：

![](http://images.cnitblog.com/blog/378300/201501/182259096511353.png)

&nbsp;

每个item的布局如下：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span><span style="color: #ff0000;">
              android:id</span><span style="color: #0000ff;">="@+id/recycler_view_test_item_person_view"</span><span style="color: #ff0000;">
              android:orientation</span><span style="color: #0000ff;">="vertical"</span><span style="color: #ff0000;">
              android:layout_width</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
              android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
              android:padding</span><span style="color: #0000ff;">="15dp"</span><span style="color: #ff0000;">
              android:background</span><span style="color: #0000ff;">="#aabbcc"</span>
        <span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TextView
            </span><span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/recycler_view_test_item_person_name_tv"</span><span style="color: #ff0000;">
            android:layout_width</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
            android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
            android:textSize</span><span style="color: #0000ff;">="18sp"</span><span style="color: #ff0000;">
            android:background</span><span style="color: #0000ff;">="#ccbbaa"</span>
            <span style="color: #0000ff;">/&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TextView
            </span><span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/recycler_view_test_item_person_age_tv"</span><span style="color: #ff0000;">
            android:layout_width</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
            android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
            android:paddingLeft</span><span style="color: #0000ff;">="5dp"</span><span style="color: #ff0000;">
            android:background</span><span style="color: #0000ff;">="#aaccbb"</span><span style="color: #ff0000;">
            android:textSize</span><span style="color: #0000ff;">="15sp"</span>
            <span style="color: #0000ff;">/&gt;</span>
<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

item的布局很简单，只有两个TextView，一个用来显示名字，一个用来显示年龄。

Person的实体类就不贴代码了，两个属性：名字和年龄。

然后需要使用到RecyclerView，所以需要把support v7添加到class path，并在布局中添加该控件：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">android.support.v7.widget.RecyclerView
                </span><span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/recycler_view_test_rv"</span><span style="color: #ff0000;">
                android:scrollbars</span><span style="color: #0000ff;">="vertical"</span><span style="color: #ff0000;">
                android:layout_width</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
                android:layout_height</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
                android:background</span><span style="color: #0000ff;">="#bbccaa"</span>
                <span style="color: #0000ff;">/&gt;</span></pre>
</div>

然后在onCreate中：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span>         recyclerView.setHasFixedSize(<span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;">2</span> 
<span style="color: #008080;">3</span>         RecyclerView.LayoutManager layoutManager = <span style="color: #0000ff;">new</span><span style="color: #000000;"> LinearLayoutManager(context);
</span><span style="color: #008080;">4</span> <span style="color: #000000;">        recyclerView.setLayoutManager(layoutManager);
</span><span style="color: #008080;">5</span> 
<span style="color: #008080;">6</span> <span style="color: #000000;">        initData();
</span><span style="color: #008080;">7</span>         adapter = <span style="color: #0000ff;">new</span><span style="color: #000000;"> PersonAdapter(personList);
</span><span style="color: #008080;">8</span>         adapter.setOnRecyclerViewListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">9</span>         recyclerView.setAdapter(adapter);    </pre>
</div>

&nbsp;

如上述代码：

Line1: 使RecyclerView保持固定的大小,这样会提高RecyclerView的性能。

Line3: LinearLayoutManager，如果你需要显示的是横向滚动的列表或者竖直滚动的列表，则使用这个LayoutManager。显然，我们要实现的是ListView的效果，所以需要使用它。生成这个LinearLayoutManager之后可以设置他滚动的方向，默认竖直滚动，所以这里没有显式地设置。

Line6: 初始化数据源。

Line7～9: 跟ListView一样，需要设置RecyclerView的Adapter，但是这里的Adapter跟ListView使用的Adapter不一样，这里的Adapter需要继承RecyclerView.Adapter，需要实现3个方法：

-&nbsp;onCreateViewHolder()

-&nbsp;onBindViewHolder()

-&nbsp;getItemCount()

直接看代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.helloandroid.sample.recycler.person;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.support.v7.widget.RecyclerView;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.LayoutInflater;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.ViewGroup;
</span><span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.LinearLayout;
</span><span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.TextView;
</span><span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.log.Logger;
</span><span style="color: #008080;">10</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.helloandroid.R;
</span><span style="color: #008080;">11</span> 
<span style="color: #008080;">12</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;
</span><span style="color: #008080;">13</span> 
<span style="color: #008080;">14</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">15</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;">16</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;">17</span> <span style="color: #008000;"> * Date: 1/17/15.
</span><span style="color: #008080;">18</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">19</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> PersonAdapter <span style="color: #0000ff;">extends</span><span style="color: #000000;"> RecyclerView.Adapter {
</span><span style="color: #008080;">20</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> OnRecyclerViewListener {
</span><span style="color: #008080;">21</span>         <span style="color: #0000ff;">void</span> onItemClick(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position);
</span><span style="color: #008080;">22</span>         <span style="color: #0000ff;">boolean</span> onItemLongClick(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position);
</span><span style="color: #008080;">23</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> OnRecyclerViewListener onRecyclerViewListener;
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOnRecyclerViewListener(OnRecyclerViewListener onRecyclerViewListener) {
</span><span style="color: #008080;">28</span>         <span style="color: #0000ff;">this</span>.onRecyclerViewListener =<span style="color: #000000;"> onRecyclerViewListener;
</span><span style="color: #008080;">29</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = PersonAdapter.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;">32</span>     <span style="color: #0000ff;">private</span> List&lt;Person&gt;<span style="color: #000000;"> list;
</span><span style="color: #008080;">33</span> 
<span style="color: #008080;">34</span>     <span style="color: #0000ff;">public</span> PersonAdapter(List&lt;Person&gt;<span style="color: #000000;"> list) {
</span><span style="color: #008080;">35</span>         <span style="color: #0000ff;">this</span>.list =<span style="color: #000000;"> list;
</span><span style="color: #008080;">36</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">37</span> 
<span style="color: #008080;">38</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">39</span>     <span style="color: #0000ff;">public</span> RecyclerView.ViewHolder onCreateViewHolder(ViewGroup viewGroup, <span style="color: #0000ff;">int</span><span style="color: #000000;"> i) {
</span><span style="color: #008080;">40</span>         Logger.d(TAG, "onCreateViewHolder, i: " +<span style="color: #000000;"> i);
</span><span style="color: #008080;">41</span>         View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.recycler_view_test_item_person, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
</span><span style="color: #008080;">42</span>         LinearLayout.LayoutParams lp = <span style="color: #0000ff;">new</span><span style="color: #000000;"> LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
</span><span style="color: #008080;">43</span> <span style="color: #000000;">        view.setLayoutParams(lp);
</span><span style="color: #008080;">44</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> PersonViewHolder(view);
</span><span style="color: #008080;">45</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">48</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onBindViewHolder(RecyclerView.ViewHolder viewHolder, <span style="color: #0000ff;">int</span><span style="color: #000000;"> i) {
</span><span style="color: #008080;">49</span>         Logger.d(TAG, "onBindViewHolder, i: " + i + ", viewHolder: " +<span style="color: #000000;"> viewHolder);
</span><span style="color: #008080;">50</span>         PersonViewHolder holder =<span style="color: #000000;"> (PersonViewHolder) viewHolder;
</span><span style="color: #008080;">51</span>         holder.position =<span style="color: #000000;"> i;
</span><span style="color: #008080;">52</span>         Person person =<span style="color: #000000;"> list.get(i);
</span><span style="color: #008080;">53</span> <span style="color: #000000;">        holder.nameTv.setText(person.getName());
</span><span style="color: #008080;">54</span>         holder.ageTv.setText(person.getAge() + "岁"<span style="color: #000000;">);
</span><span style="color: #008080;">55</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">56</span> 
<span style="color: #008080;">57</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">58</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getItemCount() {
</span><span style="color: #008080;">59</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> list.size();
</span><span style="color: #008080;">60</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">61</span> 
<span style="color: #008080;">62</span>     <span style="color: #0000ff;">class</span> PersonViewHolder <span style="color: #0000ff;">extends</span> RecyclerView.ViewHolder <span style="color: #0000ff;">implements</span><span style="color: #000000;"> View.OnClickListener, View.OnLongClickListener
</span><span style="color: #008080;">63</span> <span style="color: #000000;">    {
</span><span style="color: #008080;">64</span>         <span style="color: #0000ff;">public</span><span style="color: #000000;"> View rootView;
</span><span style="color: #008080;">65</span>         <span style="color: #0000ff;">public</span><span style="color: #000000;"> TextView nameTv;
</span><span style="color: #008080;">66</span>         <span style="color: #0000ff;">public</span><span style="color: #000000;"> TextView ageTv;
</span><span style="color: #008080;">67</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> position;
</span><span style="color: #008080;">68</span> 
<span style="color: #008080;">69</span>         <span style="color: #0000ff;">public</span><span style="color: #000000;"> PersonViewHolder(View itemView) {
</span><span style="color: #008080;">70</span>             <span style="color: #0000ff;">super</span><span style="color: #000000;">(itemView);
</span><span style="color: #008080;">71</span>             nameTv =<span style="color: #000000;"> (TextView) itemView.findViewById(R.id.recycler_view_test_item_person_name_tv);
</span><span style="color: #008080;">72</span>             ageTv =<span style="color: #000000;"> (TextView) itemView.findViewById(R.id.recycler_view_test_item_person_age_tv);
</span><span style="color: #008080;">73</span>             rootView =<span style="color: #000000;"> itemView.findViewById(R.id.recycler_view_test_item_person_view);
</span><span style="color: #008080;">74</span>             rootView.setOnClickListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">75</span>             rootView.setOnLongClickListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">76</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">77</span> 
<span style="color: #008080;">78</span> <span style="color: #000000;">        @Override
</span><span style="color: #008080;">79</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClick(View v) {
</span><span style="color: #008080;">80</span>             <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> onRecyclerViewListener) {
</span><span style="color: #008080;">81</span> <span style="color: #000000;">                onRecyclerViewListener.onItemClick(position);
</span><span style="color: #008080;">82</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">83</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">84</span> 
<span style="color: #008080;">85</span> <span style="color: #000000;">        @Override
</span><span style="color: #008080;">86</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onLongClick(View v) {
</span><span style="color: #008080;">87</span>             <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> onRecyclerViewListener){
</span><span style="color: #008080;">88</span>                 <span style="color: #0000ff;">return</span><span style="color: #000000;"> onRecyclerViewListener.onItemLongClick(position);
</span><span style="color: #008080;">89</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">90</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">91</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">92</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">93</span> 
<span style="color: #008080;">94</span> }</pre>
</div>

如上代码所示：

public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i)

这个方法主要生成为每个Item inflater出一个View，但是该方法返回的是一个ViewHolder。方法是把View直接封装在ViewHolder中，然后我们面向的是ViewHolder这个实例，当然这个ViewHolder需要我们自己去编写。直接省去了当初的convertView.setTag(holder)和convertView.getTag()这些繁琐的步骤。

&nbsp;

public void onBindViewHolder(RecyclerView.ViewHolder viewHolder, int i)

这个方法主要用于适配渲染数据到View中。方法提供给你了一个viewHolder，而不是原来的convertView。

对比下以前的写法就一目了然了：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">@Override
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">public</span> View getView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position, View convertView, ViewGroup parent) {
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">        ViewHolder holder;
</span><span style="color: #008080;"> 4</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> convertView){
</span><span style="color: #008080;"> 5</span>             holder = <span style="color: #0000ff;">new</span><span style="color: #000000;"> ViewHolder();
</span><span style="color: #008080;"> 6</span>             LayoutInflater mInflater =<span style="color: #000000;"> (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
</span><span style="color: #008080;"> 7</span>             convertView = mInflater.inflate(R.layout.item, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 8</span>             holder.btn =<span style="color: #000000;"> (Button) convertView.findViewById(R.id.btn);
</span><span style="color: #008080;"> 9</span>             holder.tv =<span style="color: #000000;"> (TextView) convertView.findViewById(R.id.tv);
</span><span style="color: #008080;">10</span>             holder.iv =<span style="color: #000000;"> (TextView) convertView.findViewById(R.id.iv);
</span><span style="color: #008080;">11</span> 
<span style="color: #008080;">12</span> <span style="color: #000000;">            convertView.setTag(holder);
</span><span style="color: #008080;">13</span>         }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;">14</span>             holder =<span style="color: #000000;"> (ViewHolder) convertView.getTag();
</span><span style="color: #008080;">15</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">16</span>         <span style="color: #0000ff;">final</span> HashMap&lt;String, Object&gt; map =<span style="color: #000000;"> list.get(position);
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>         holder.iv.setImageResource(Integer.valueOf(map.get("iv"<span style="color: #000000;">).toString()));
</span><span style="color: #008080;">19</span>         holder.tv.setText(map.get("tv"<span style="color: #000000;">).toString());
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>         holder.btn.setOnClickListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> View.OnClickListener() {
</span><span style="color: #008080;">22</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">23</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClick(View v) {
</span><span style="color: #008080;">24</span>                 Toast.makeText(context, map.get("btn"<span style="color: #000000;">).toString(), Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">25</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">26</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">27</span> 
<span style="color: #008080;">28</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> convertView;
</span><span style="color: #008080;">29</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span>     <span style="color: #0000ff;">class</span><span style="color: #000000;"> ViewHolder{
</span><span style="color: #008080;">32</span> <span style="color: #000000;">        Button btn;
</span><span style="color: #008080;">33</span> <span style="color: #000000;">        ImageView iv;
</span><span style="color: #008080;">34</span> <span style="color: #000000;">        TextView tv;
</span><span style="color: #008080;">35</span> 
<span style="color: #008080;">36</span>     }</pre>
</div>

对比后可以发现：

旧的写法中Line5～Line12＋Line28部分的代码其实起到的作用相当于新的写法的onCreateViewHolder()；

旧的写法中Line14～Line26部分的代码其实起到的作用相当于新的写法的onBindViewHolder()；

既然是这样，那我们就把原来相应的代码搬到对应的onCreateViewHolder()和onBindViewHolder()这两个方法中就可以了。

因为RecyclerView帮我们封装了Holder，所以我们自己写的ViewHolder就需要继承RecyclerView.ViewHolder，只有这样，RecyclerView才能帮你去管理这个ViewHolder类。

既然getView方法的渲染数据部分的代码相当于onBindViewHolder()，所以如果调用adapter.notifyDataSetChanged()方法，应该也会重新调用onBindViewHolder()方法才对吧？实验后，果然如此！

除了adapter.notifyDataSetChanged()这个方法之外，新的Adapter还提供了其他的方法，如下：

<div class="cnblogs_code">
<pre>        <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> notifyDataSetChanged()
        </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">void</span> notifyItemChanged(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position)
        </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">void</span> notifyItemRangeChanged(<span style="color: #0000ff;">int</span> positionStart, <span style="color: #0000ff;">int</span><span style="color: #000000;"> itemCount)
        </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">void</span> notifyItemInserted(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position) 
        </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">void</span> notifyItemMoved(<span style="color: #0000ff;">int</span> fromPosition, <span style="color: #0000ff;">int</span><span style="color: #000000;"> toPosition)
        </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">void</span> notifyItemRangeInserted(<span style="color: #0000ff;">int</span> positionStart, <span style="color: #0000ff;">int</span><span style="color: #000000;"> itemCount)
        </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">void</span> notifyItemRemoved(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position)
        </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">void</span> notifyItemRangeRemoved(<span style="color: #0000ff;">int</span> positionStart, <span style="color: #0000ff;">int</span> itemCount) </pre>
</div>

基本上看到方法的名字就知道这个方法是干嘛的了，

第一个方法没什么好讲的，跟以前一样。

notifyItemChanged(int position)，position数据发生了改变，那调用这个方法，就会回调对应position的onBindViewHolder()方法了，当然，因为ViewHolder是复用的，所以如果position在当前屏幕以外，也就不会回调了，因为没有意义，下次position滚动会当前屏幕以内的时候同样会调用onBindViewHolder()方法刷新数据了。其他的方法也是同样的道理。

public final void notifyItemRangeChanged(int positionStart, int itemCount)，顾名思义，可以刷新从positionStart开始itemCount数量的item了（这里的刷新指回调onBindViewHolder()方法）。

public final void notifyItemInserted(int position)，这个方法是在第position位置被插入了一条数据的时候可以使用这个方法刷新，注意这个方法调用后会有插入的动画，这个动画可以使用默认的，也可以自己定义。

public final void notifyItemMoved(int fromPosition, int toPosition)，这个方法是从fromPosition移动到toPosition为止的时候可以使用这个方法刷新

public final void notifyItemRangeInserted(int positionStart, int itemCount)，显然是批量添加。

public final void notifyItemRemoved(int position)，第position个被删除的时候刷新，同样会有动画。

public final void notifyItemRangeRemoved(int positionStart, int itemCount)，批量删除。

&nbsp;

这些方法分析完之后，我们来实现一个点击一个按钮，新增一条数据，长按一个item，删除一条数据的场景。

以下是新增一条数据的代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> Person person = <span style="color: #0000ff;">new</span> Person(i, "WangJie_" + i, 10 +<span style="color: #000000;"> i);
</span><span style="color: #008080;">2</span> adapter.notifyItemInserted(2<span style="color: #000000;">);
</span><span style="color: #008080;">3</span> personList.add(2<span style="color: #000000;">, person);
</span><span style="color: #008080;">4</span> adapter.notifyItemRangeChanged(2, adapter.getItemCount());</pre>
</div>

如上代码：

Line2：表示在position为2的位置，插入一条数据，这个时候动画开始执行。

Line3: 表示在数据源中position为2的位置新增一条数据（其实这个才是真正的新增数据啦）。

Line4: 为什么要刷新position为2以后的数据呢？因为，在position为2的位置插入了一条数据后，新数据的position变成了2，那原来的position为2的应该变成了3，3的应该变成了4，所以2以后的所有数据的position都发生了改变，所以需要把position2以后的数据都要刷新。理论上是这样，但是实际上刷新的数量只有在屏幕上显示的position为2以后的数据而已。如果这里使用notifyDataSetChanged()来刷新屏幕上显示的所有item可以吗？结果不会出错，但是会有一个问题，前面调用了notifyItemInserted()方法后会在执行动画，如果你调用notifyDataSetChanged()刷新屏幕上显示的所有item的话，必然也会刷新当前正在执行动画的那个item，这样导致的结果是，前面的动画还没执行完，它马上又被刷新了，动画就看不见了。所以只要刷新2以后的item就可以了。

&nbsp;

看了RecyclerView的api，发现没有setOnItemClickListener－－，所以还是自己把onItemClick从Adapter中回调出来吧。这个很简单，就像上面PersonAdaper中写的OnRecyclerViewListener那样。

&nbsp;

长按删除的代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #000000;">adapter.notifyItemRemoved(position);
</span><span style="color: #008080;">2</span> <span style="color: #000000;">personList.remove(position);
</span><span style="color: #008080;">3</span> adapter.notifyItemRangeChanged(position, adapter.getItemCount());</pre>
</div>

代码跟之前插入的代码基本一致。先通知执行动画，然后删除数据源中的数据，然后通知position之后的数据刷新就可以了。

这样ListView的效果就实现了。

&nbsp;

**示例代码：**

**[https://github.com/wangjiegulu/RecyclerViewSample](https://github.com/wangjiegulu/RecyclerViewSample)**

&nbsp;

<span style="font-size: 16px; color: #ff0000;">**[<span style="color: #ff0000;">[Android]使用RecyclerView替代ListView（二）</span>](http://www.cnblogs.com/tiantianbyconan/p/4242541.html)**：</span>

<span style="font-size: 16px; color: #0000ff;">**[<span style="color: #0000ff;">http://www.cnblogs.com/tiantianbyconan/p/4242541.html</span>](http://www.cnblogs.com/tiantianbyconan/p/4242541.html)**</span>

&nbsp;

<span style="color: #ff0000;"><span style="font-size: 16px;">**[<span style="color: #ff0000;">[Android]使用RecyclerView替代ListView（三）</span>](http://www.cnblogs.com/tiantianbyconan/p/4242541.html)**：</span>&nbsp;</span>

<span style="color: #0000ff;">[<span style="color: #0000ff;"><span style="font-size: 16px; line-height: 24px;">**<span style="text-decoration: underline;">http://www.cnblogs.com/tiantianbyconan/p/4268097.html</span>**</span></span>](http://www.cnblogs.com/tiantianbyconan/p/4268097.html)</span>

&nbsp;

