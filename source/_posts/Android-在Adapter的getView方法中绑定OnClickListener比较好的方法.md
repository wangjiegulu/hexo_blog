---
title: '[Android]在Adapter的getView方法中绑定OnClickListener比较好的方法'
tags: [android, adapter, ListView, best practices]
date: 2014-12-05 13:50:00
---

给ListView中每个item绑定点击事件的方法，比较常见的如下这种方式：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">public</span> View getView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> positon, View convertView, ViewGroup parent){
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> convertView){
</span><span style="color: #008080;"> 3</span>         convertView = LayoutInflater.<span style="color: #0000ff;">from</span>(context).inflate(R.layout.item, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 5</span> 
<span style="color: #008080;"> 6</span>     Button button =<span style="color: #000000;"> ABViewUtil.obtainView(convertView, R.id.item_btn);
</span><span style="color: #008080;"> 7</span>     button.setOnClickListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> View.OnClickListener(){
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">        @Override
</span><span style="color: #008080;"> 9</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClick(View v){
</span><span style="color: #008080;">10</span>             Toast.makeText(context, <span style="color: #800000;">"</span><span style="color: #800000;">position: </span><span style="color: #800000;">"</span> +<span style="color: #000000;"> position, Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">11</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    });
</span><span style="color: #008080;">13</span> 
<span style="color: #008080;">14</span> }</pre>
</div>

然后运行，当然没问题。

但是这里有一个可以优化的地方，注意代码第7行，每次调用getView方法都会设置Button的OnClickListener，会生成很多不必要的OnClickListener对象。

所以，我们可以想到，在生成convertView时，同时设置Button的OnClickListener，convertView是被不断地复用的，这样的OnClickListener也就可以被不断地服用，也就是说在第3行和第4行之间进行这一步。这样，代码演化到如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">public</span> View getView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> positon, View convertView, ViewGroup parent){
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> convertView){
</span><span style="color: #008080;"> 3</span>         convertView = LayoutInflater.from(context).inflate(R.layout.item, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 4</span>         Button button =<span style="color: #000000;"> ABViewUtil.obtainView(convertView, R.id.item_btn);
</span><span style="color: #008080;"> 5</span>         button.setOnClickListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> View.OnClickListener(){
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;"> 7</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClick(View v){
</span><span style="color: #008080;"> 8</span>                 Toast.makeText(context, "position: " +<span style="color: #000000;"> position, Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">10</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">11</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">12</span> }</pre>
</div>

这个代码看上去没什么问题，但是问题就在onClick回调的的第8行中使用的position的时候，因为这里使用的是匿名内部类（这个匿名内部类实现了View.OnClickListener这个接口），所以如果需要在onClick中使用position这个变量的话，需要把position声明为final。一旦声明了final，等到编译之后，这个position就会被作为这个匿名内部类中的一个private的成员变量。这样，ListView往下滚动，下面需要显示的item会重用上面不显示的convertView，convertView中的Button设置的OnClickListener实现类的对象，回调onClick时，使用的position其实是该OnClickListener实现类的成员变量position（这个position的值只是在构造的时候被初始化了而已！）。所以，这个ListView刚加载完数据后，还未滚动时，点击屏幕上的item都是正常的，但是如果一旦滚动，有view被重用了，这个时候，position的值就错乱了，所以在onClick中通过position获取到的item的数据当然也是错乱的了。

所以，要解决这个问题，就需要让onClick方法回调的时候得到的position是个正确的值，我们可以选择使用把当前显示的convertView对应的position值保存在convertView中，然后把这个convertView对象传入OnClickListener中保存，所以代码演化到如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">public</span> View getView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> positon, View convertView, ViewGroup parent){
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> convertView){
</span><span style="color: #008080;"> 3</span>         convertView = LayoutInflater.from(context).inflate(R.layout.item, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 4</span>         Button button =<span style="color: #000000;"> ABViewUtil.obtainView(convertView, R.id.item_btn);
</span><span style="color: #008080;"> 5</span>         button.setOnClickListener(<span style="color: #0000ff;">new</span><span style="color: #000000;"> OnConvertViewClickListener(convertView, R.id.ab__id_adapter_item_position){
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">                @Override
</span><span style="color: #008080;"> 7</span>                 <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClickCallBack(View registedView, <span style="color: #0000ff;">int</span><span style="color: #000000;">... positionIds){
</span><span style="color: #008080;"> 8</span>                     Toast.makeText(context, "position: " + positionIds[0<span style="color: #000000;">], Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">10</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">11</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    convertView.setTag(R.id.ab__id_adapter_item_position, position);
</span><span style="color: #008080;">13</span> }</pre>
</div>

就像上面第5行这样，Button绑定的是**[OnConvertViewClickListener](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/adapter/listener/OnConvertViewClickListener.java)**，它是OnClickListener的一个实现类可以保存convertView到Listener中，到时候回调onClick方法的时候可以从保存的convertView中获取到当前显示的item的position（这个position是以tag的方式保存在convertView中的）。

当然，还需要做第12行这一步，它的目的是把当前显示的position保存到convertView中，提供给**[OnConvertViewClickListener](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/adapter/listener/OnConvertViewClickListener.java)**获取当前的position。

这样就ok了，可以在onClickCallBack()方法中进行点击事件的处理了，每个button永远只有一个onClickListener。

<span style="color: #008000;">**注：使用[<span style="color: #008000;">OnConvertViewClickListener</span>](https://github.com/wangjiegulu/AndroidBucket/blob/master/src/com/wangjie/androidbucket/adapter/listener/OnConvertViewClickListener.java)可以依赖[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)（https://github.com/wangjiegulu/AndroidBucket）项目**</span>

