---
title: '[Android]对BaseAdapter中ViewHolder编写简化'
tags: [android, ListView, adapter, best practices]
date: 2014-04-03 13:44:00
---

在Android项目中，经常都会用到ListView这个控件，而相应的Adapter中getView()方法的编写有一个标准的形式，如下：

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

以下是碎碎念（想直接看代码的，就跳过这段吧-_-！）：

也就是说每次编写Adapter都需要编写class ViewHolder...、if(null == convertView){...等等。这些代码跟业务逻辑关系不大，没有必要每次都写重复代码，

所以，显然有简化代码的余地。

既然我们的需求是不需要重复编写ViewHolder等内部类，那就把它移到父类吧。

但是ViewHolder中在实际项目中有不同的View，那就用list存放起来吧，但是放在list中的话，怎么取出来？用index？显然不是好的方法，不是有Resource Id这玩意，通过这个取不就好了么？所以以Resource Id为key放在Map中比较合适，但是既然以int（Resource Id）为key，那自然而然想到使用SparseArray了。

然后再把if(null == converView)...这些代码统统移到父类中。

所以ABaseAdapter诞生了，代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * 实现对BaseAdapter中ViewHolder相关的简化
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Date: 14-4-2
</span><span style="color: #008080;"> 6</span> <span style="color: #008000;"> * Time: 下午5:54
</span><span style="color: #008080;"> 7</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> <span style="color: #0000ff;">class</span> ABaseAdapter <span style="color: #0000ff;">extends</span><span style="color: #000000;"> BaseAdapter{
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    Context context;
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span>     <span style="color: #0000ff;">protected</span><span style="color: #000000;"> ABaseAdapter(Context context) {
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">this</span>.context =<span style="color: #000000;"> context;
</span><span style="color: #008080;">13</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span>     <span style="color: #0000ff;">protected</span><span style="color: #000000;"> ABaseAdapter() {
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">19</span> <span style="color: #008000;">     * 各个控件的缓存
</span><span style="color: #008080;">20</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">21</span>     public <span style="color: #0000ff;">class</span><span style="color: #000000;"> ViewHolder{
</span><span style="color: #008080;">22</span>         <span style="color: #0000ff;">public</span> SparseArray&lt;View&gt; views = <span style="color: #0000ff;">new</span> SparseArray&lt;View&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">23</span> 
<span style="color: #008080;">24</span>         <span style="color: #008000;">/**</span>
<span style="color: #008080;">25</span> <span style="color: #008000;">         * 指定resId和类型即可获取到相应的view
</span><span style="color: #008080;">26</span> <span style="color: #008000;">         * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> convertView
</span><span style="color: #008080;">27</span> <span style="color: #008000;">         * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> resId
</span><span style="color: #008080;">28</span> <span style="color: #008000;">         * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> &lt;T&gt;
</span><span style="color: #008080;">29</span> <span style="color: #008000;">         * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;">30</span>          <span style="color: #008000;">*/</span>
<span style="color: #008080;">31</span>         <span style="color: #0000ff;">public</span> &lt;T <span style="color: #0000ff;">extends</span> View&gt; T obtainView(View convertView, <span style="color: #0000ff;">int</span><span style="color: #000000;"> resId){
</span><span style="color: #008080;">32</span>             View v =<span style="color: #000000;"> views.get(resId);
</span><span style="color: #008080;">33</span>             <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> v){
</span><span style="color: #008080;">34</span>                 v =<span style="color: #000000;"> convertView.findViewById(resId);
</span><span style="color: #008080;">35</span> <span style="color: #000000;">                views.put(resId, v);
</span><span style="color: #008080;">36</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">37</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;"> (T)v;
</span><span style="color: #008080;">38</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">39</span> 
<span style="color: #008080;">40</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">41</span> 
<span style="color: #008080;">42</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">43</span> <span style="color: #008000;">     * 改方法需要子类实现，需要返回item布局的resource id
</span><span style="color: #008080;">44</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;">45</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">46</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> itemLayoutRes();
</span><span style="color: #008080;">47</span> 
<span style="color: #008080;">48</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">49</span>     <span style="color: #0000ff;">public</span> View getView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position, View convertView, ViewGroup parent) {
</span><span style="color: #008080;">50</span> <span style="color: #000000;">        ViewHolder holder;
</span><span style="color: #008080;">51</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> convertView){
</span><span style="color: #008080;">52</span>             holder = <span style="color: #0000ff;">new</span><span style="color: #000000;"> ViewHolder();
</span><span style="color: #008080;">53</span>             convertView = LayoutInflater.from(context).inflate(itemLayoutRes(), <span style="color: #0000ff;">null</span><span style="color: #000000;">);
</span><span style="color: #008080;">54</span> <span style="color: #000000;">            convertView.setTag(holder);
</span><span style="color: #008080;">55</span>         }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;">56</span>             holder =<span style="color: #000000;"> (ViewHolder) convertView.getTag();
</span><span style="color: #008080;">57</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">58</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> getView(position, convertView, parent, holder);
</span><span style="color: #008080;">59</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">60</span> 
<span style="color: #008080;">61</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">62</span> <span style="color: #008000;">     * 使用该getView方法替换原来的getView方法，需要子类实现
</span><span style="color: #008080;">63</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> position
</span><span style="color: #008080;">64</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> convertView
</span><span style="color: #008080;">65</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> parent
</span><span style="color: #008080;">66</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> holder
</span><span style="color: #008080;">67</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;">68</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">69</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> View getView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position, View convertView, ViewGroup parent, ViewHolder holder);
</span><span style="color: #008080;">70</span> 
<span style="color: #008080;">71</span> }</pre>
</div>

如上代码：增加了一个itemLayoutRes()的抽象方法，该抽象方法提供给子类实现，返回item布局的resource id，为后面的getView方法提供调用。

可以看到上述代码中，在系统的getView方法中，进行我们以前在BaseAdapter实现类中所做的事（初始化converView，并绑定ViewHolder作为tag），然后抛弃了系统提供的getView方法，直接去调用自己写的getView抽象方法，这个getView方法是提供给子类去实现的，作用跟系统的getView一样，但是这个getView方法中携带了一个ViewHolder对象，子类可以通过这个对象进行获取item中的控件。

具体使用方式如下，比如创建了MyAdapter并继承了ABaseAdapter：

注意，在构造方法中需要调用父类的构造方法：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #0000ff;">public</span> MyAdapter(Context context, List&lt;HashMap&lt;String, Object&gt;&gt;<span style="color: #000000;"> list) {
</span><span style="color: #008080;">2</span>     <span style="color: #0000ff;">super</span><span style="color: #000000;">(context);
</span><span style="color: #008080;">3</span>     <span style="color: #0000ff;">this</span>.list =<span style="color: #000000;"> list;
</span><span style="color: #008080;">4</span> }</pre>
</div>

即，以上的&ldquo;super(context);&rdquo;必须调用。

接着实现itemLayoutRes()方法，返回item的布局：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #000000;">@Override
</span><span style="color: #008080;">2</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> itemLayoutRes() {
</span><span style="color: #008080;">3</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> R.layout.item;
</span><span style="color: #008080;">4</span> }</pre>
</div>

&nbsp;

getView方法中的实现如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">@Override
</span><span style="color: #008080;"> 2</span> <span style="color: #0000ff;">public</span> View getView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position, View convertView, ViewGroup parent, ViewHolder holder) {
</span><span style="color: #008080;"> 3</span>     <span style="color: #0000ff;">final</span> HashMap&lt;String, Object&gt; map =<span style="color: #000000;"> list.get(position);
</span><span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span>     Button btn =<span style="color: #000000;"> holder.obtainView(convertView, R.id.item_btn);
</span><span style="color: #008080;"> 6</span>     ImageView iv =<span style="color: #000000;"> holder.obtainView(convertView, R.id.item_iv);
</span><span style="color: #008080;"> 7</span>     TextView tv =<span style="color: #000000;"> holder.obtainView(convertView, R.id.item_tv);
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span>      btn.setOnClickListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> View.OnClickListener() {
</span><span style="color: #008080;">10</span> <span style="color: #000000;">        @Override
</span><span style="color: #008080;">11</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClick(View v) {
</span><span style="color: #008080;">12</span>             Toast.makeText(context, map.get("btn"<span style="color: #000000;">).toString(), Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">13</span> <span style="color: #000000;">         }
</span><span style="color: #008080;">14</span> <span style="color: #000000;">     });
</span><span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span>      iv.setImageResource(Integer.valueOf(map.get("iv"<span style="color: #000000;">).toString()));
</span><span style="color: #008080;">17</span>      tv.setText(map.get("tv"<span style="color: #000000;">).toString());
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> convertView;
</span><span style="color: #008080;">20</span>     }</pre>
</div>

如上代码：调用holder.obtainView方法既可获取item中的控件；

&nbsp;

&nbsp;

