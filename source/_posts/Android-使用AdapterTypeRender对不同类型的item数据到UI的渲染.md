---
title: '[Android]使用AdapterTypeRender对不同类型的item数据到UI的渲染'
tags: [android, ListView, adapter, best practices]
date: 2014-09-25 15:07:00
---

本文讲的工具均放在**[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)**开源项目中，欢迎大家star/fork，地址：[https://github.com/wangjiegulu/AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)

&nbsp;

主要实现聊天功能中的发送不同类型的信息，比如纯文本、图片、语音、图文混排多媒体的数据等（具体效果看微信）。

这里使用AdapterTypeRender在BaseTypeAdapter（这个之后会讲到）中实现。

这里主要的实现方式是在ChatAdapter（继承BaseTypeAdapter）中根据每个position的item的type，来使用不同的AdapterTypeRender渲染器进行渲染。渲染的过程当然是在getView方法中进行。

**1.&nbsp;AdapterTypeRender**

先来看看AdapterTypeRender这个接口。它有3个方法：getConvertView()、fitEvents()、fitDatas()三个方法。

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * 用于对不同类型item数据到UI的渲染
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 9/14/14.
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> AdapterTypeRender {

    </span><span style="color: #008000;">/**</span><span style="color: #008000;">
     * 返回一个item的convertView，也就是BaseAdapter中getView方法中返回的convertView
     * </span><span style="color: #808080;">@return</span>
     <span style="color: #008000;">*/</span><span style="color: #000000;">
    View getConvertView();

    </span><span style="color: #008000;">/**</span><span style="color: #008000;">
     * 填充item中各个控件的事件，比如按钮点击事件等
     </span><span style="color: #008000;">*/</span>
    <span style="color: #0000ff;">void</span><span style="color: #000000;"> fitEvents();

    </span><span style="color: #008000;">/**</span><span style="color: #008000;">
     * 对指定position的item进行数据的适配
     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> position
     </span><span style="color: #008000;">*/</span>
    <span style="color: #0000ff;">void</span> fitDatas(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position);

}</span></pre>
</div>

－getconvertView()方法用于返回给BaseTypeAdapter一个convertView，一个AdapterTypeRender实现类对应一个convertView实例，该AdapterTypeRender可以被重用，所以convertView也可以被重用了。

－fitEvents()方法用于给当前的item中的各个控件注册事件，比如点击事件、touch事件等（具体的注册事件后面回讲到），因为这个方法是在getView中只有convertView为null时才会调用，所以只会调用一次，所以在这里添加事件是比较好的。

－fitDatas()方法用于把数据适配到item的各个view中进行显示。这个方法只要getView得到调用，就会被调用。

**2\. BaseTypeAdapter**

这是一个抽象类，是继承于BaseAdapter的，重写了里面的getView方法。会自动根据指定position的item获取对应的type，然后通过type实例化一个AdapterTypeRender的实现，然后又使用了BaseAdapter中自带的convertView的重用机制进行对view的重用，同样也是对AdapterTypeRender的重用。

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter.typeadapter;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.annotation.TargetApi;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.Build;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.ViewGroup;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.BaseAdapter;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.R;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 9/25/14.
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> <span style="color: #0000ff;">class</span> BaseTypeAdapter <span style="color: #0000ff;">extends</span><span style="color: #000000;"> BaseAdapter{
    @TargetApi(Build.VERSION_CODES.DONUT)
    @Override
    </span><span style="color: #0000ff;">public</span> View getView(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position, View convertView, ViewGroup parent) {
        AdapterTypeRender typeRender;
        </span><span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> convertView){
            typeRender </span>=<span style="color: #000000;"> getAdapterTypeRender(position);
            convertView </span>=<span style="color: #000000;"> typeRender.getConvertView();
            convertView.setTag(R.id.ab__id_adapter_item_type_render, typeRender);
            typeRender.fitEvents();
        }</span><span style="color: #0000ff;">else</span><span style="color: #000000;">{
            typeRender </span>=<span style="color: #000000;"> (AdapterTypeRender) convertView.getTag(R.id.ab__id_adapter_item_type_render);
        }
        convertView.setTag(R.id.ab__id_adapter_item_position, position);

        </span><span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> typeRender){
            typeRender.fitDatas(position);
        }

        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> convertView;
    }

    </span><span style="color: #008000;">/**</span><span style="color: #008000;">
     * 根据指定position的item获取对应的type，然后通过type实例化一个AdapterTypeRender的实现
     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> position
     * </span><span style="color: #808080;">@return</span>
     <span style="color: #008000;">*/</span>
    <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">abstract</span> AdapterTypeRender getAdapterTypeRender(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position);
}</span></pre>
</div>

为了实现AdapterTypeRender的重用，一旦生成了一个AdapterTypeRender实现类的实例，则使用setTag的方法进行对convertView和AdapterTypeRender的绑定（R.id.ab__id_adapter_item_type_render这个id是在**[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)**中定义了的），这个可以参考以前的ViewHolder的写法。

为了实现在同一个item中的事件（这里以view的点击事件为例）响应都共用一个观察者的实例，需要在convertView中保存对应的position。这是因为同一个convertView因为使用了view的重用，是被非显示页面的很多个item所共用的。所以只需要，在当前显示的一屏中，每个convertView对应的postion即可，毕竟这些事件触发只有在当前显示的一屏中才会被触发。保存postion的方式依然使用了setTag的方式（R.id.ab__id_adapter_item_position这个id是在**[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)**中定义了的），注意：子类一般不需要重写getView方法了，其他的数据适配UI渲染都交给Render吧！

除了重写了getView方法之外，还定义了一个抽象方法：getAdapterTypeRender。这个方法需要子类去实现，需要告诉BaseTypeAdapter，指定position的item，它的type对应的AdapterTypeRender的实例是什么。

**3\. 自定义AdapterTypeRender的实现**

接下来，就尝试自己实现几个不同布局的Render吧。这里假设需要实现两种：文本布局（TypeTextRender）、图片布局（TypeImageRender）。

a) TypeTextRender的实现：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.activities.typerendertest.adapter;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.content.Context;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.LayoutInflater;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.ImageButton;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.ImageView;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.ProgressBar;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.TextView;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter.typeadapter.AdapterTypeRender;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter.listener.OnConvertViewClickListener;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.thread.ThreadPool;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.utils.ABTimeUtil;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.utils.ABViewUtil;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.imageloadersample.imageloader.ImageLoader;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 9/14/14.
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> TypeTextRender <span style="color: #0000ff;">implements</span><span style="color: #000000;"> AdapterTypeRender {
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Context context;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> ChatAdapter adapter;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> View contentView;

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> TypeTextRender(Context context, ChatAdapter adapter) {
        </span><span style="color: #0000ff;">this</span>.context =<span style="color: #000000;"> context;
        </span><span style="color: #0000ff;">this</span>.adapter =<span style="color: #000000;"> adapter;
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> 解析文本类型的布局</span>
        contentView = LayoutInflater.from(context).inflate(R.layout.item_type_text, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
    }

    @Override
    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> View getConvertView() {
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> 返回文本类型的布局</span>
        <span style="color: #0000ff;">return</span><span style="color: #000000;"> contentView;
    }

    </span><span style="color: #008000;">/**</span><span style="color: #008000;">
     * 这个方法同一个convertView只会被调用一次，所以可以放心地在这里执行事件地绑定，不用担心生成过多的OnClickListener等
     </span><span style="color: #008000;">*/</span><span style="color: #000000;">
    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> fitEvents() {
        </span><span style="color: #008000;">/**</span><span style="color: #008000;">
         * 生成一个在convertView中使用的clickListener
         </span><span style="color: #008000;">*/</span><span style="color: #000000;">
        OnConvertViewClickListener onConvertViewClickListener </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> OnConvertViewClickListener(contentView, R.id.ab__id_adapter_item_position) {
            @Override
            </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClickCallBack(View registedView, <span style="color: #0000ff;">int</span><span style="color: #000000;">... positionIds) {
                ChatAdapter.OnChatItemListener onChatItemListener </span>=<span style="color: #000000;"> adapter.getOnChatItemListener();
                </span><span style="color: #0000ff;">switch</span><span style="color: #000000;"> (registedView.getId()) {
                    </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.item_type_text_view:
                        </span><span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> != onChatItemListener &amp;&amp; <span style="color: #0000ff;">null</span> != positionIds &amp;&amp; positionIds.length &gt; 0<span style="color: #000000;">) {
                            onChatItemListener.onItemClicked(positionIds[</span>0<span style="color: #000000;">]);
                        }
                        </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;

                    </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.item_type_text_head_iv:
                        </span><span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> != onChatItemListener &amp;&amp; <span style="color: #0000ff;">null</span> != positionIds &amp;&amp; positionIds.length &gt; 0<span style="color: #000000;">) {
                            onChatItemListener.onHeadClicked(positionIds[</span>0<span style="color: #000000;">]);
                        }
                        </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;

                }

            }
        };

        </span><span style="color: #008000;">//</span><span style="color: #008000;"> 通过ABViewUtil从contentView中获取对应id的控件，然后设置OnClickListener</span>
<span style="color: #000000;">        ABViewUtil.obtainView(contentView, R.id.item_type_text_view)
                .setOnClickListener(onConvertViewClickListener);
        ABViewUtil.obtainView(contentView, R.id.item_type_text_head_iv)
                .setOnClickListener(onConvertViewClickListener);

    }

    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> ImageView headIv;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> View rootView;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> TextView contentTv;

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> fitDatas(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {        
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> 通过ABViewUtil从contentView中获取对应id的控件，然后设置OnClickListener</span>
        headIv =<span style="color: #000000;"> ABViewUtil.obtainView(contentView, R.id.item_type_text_head_iv);
        contentTv </span>=<span style="color: #000000;"> ABViewUtil.obtainView(contentView, R.id.item_type_text_content_tv);
        </span><span style="color: #008000;">/**</span><span style="color: #008000;">
         * 在这里适配数据到ui
         </span><span style="color: #008000;">*/</span><span style="color: #000000;">
        Message message </span>=<span style="color: #000000;"> adapter.getItem(position);
        contentTv.setText(message.getContent());
        ImageLoader.getInstances().displayImage(message.getHeadUrl(), headIv, </span>100, <span style="color: #0000ff;">null</span><span style="color: #000000;">, R.drawable.default_head);

    }

}</span></pre>
</div>

如上代码，该TypeTextRender实现了AdapterTypeRender接口，实现了其中的3个方法。注意：需要在构造方法中解析出convertView，用于提供给BaseTypeAdapter在getView中返回。

然后在fitEvents中注册各种事件，这里只注册了点击事件（一个rootView、一个headIv注册了点击事件）。这里的OnConvertViewClickListener是一个实现了View.OnClickListener的一个抽象类，生成一个OnConvertViewClickListener时需要传入convertView和positions的id，这样由于Render被重用后，convertView也是被重用了，导致onClickListener也是被重用了，这会导致响应点击事件的时候，回调的onClicked方法中无法得知点击的是哪个View，所以，需要把converView和positions的id传入，positions的id可以用来在convertView中绑定postion作为tag。positonsIds是一个可变长的参数，因为可能是一个ExpandableListView，需要groupPosition和childPosition两个positon来确定。回调的onClickCallBack中的参数registedView表示被点击的view，positionIds，被点击的item的positions（这个也是可以在**[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)**中找到，以后有时间会针对这个详细说明）。

&ldquo;ABViewUtil.obtainView...&rdquo;这个方法对viewHolder进行了封装，把convertView中的控件都缓存在了一个SparseArray&lt;View&gt;中（作用跟常用的ViewHolder相同）。

然后在fitDatas方法中就可以进行对数据的适配了，相当于我们以前在BaseAdapter的getView方法中的操作了。

b) TypeImageRender的实现（与TypeTextRender大同小异，不做过多的说明了）：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.activities.typerendertest.adapter;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.content.Context;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.LayoutInflater;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.ImageButton;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.ImageView;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.ProgressBar;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.TextView;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter.typeadapter.AdapterTypeRender;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter.listener.OnConvertViewClickListener;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.thread.ThreadPool;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.utils.ABTimeUtil;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.utils.ABViewUtil;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.imageloadersample.imageloader.ImageLoader;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 9/14/14.
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> ChatTypeImageRender <span style="color: #0000ff;">implements</span><span style="color: #000000;"> AdapterTypeRender {
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Context context;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> ChatAdapter adapter;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> View contentView;

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> ChatTypeImageRender(Context context, ChatAdapter adapter) {
        </span><span style="color: #0000ff;">this</span>.context =<span style="color: #000000;"> context;
        </span><span style="color: #0000ff;">this</span>.adapter =<span style="color: #000000;"> adapter;
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> 解析图片类型的布局</span>
        contentView = LayoutInflater.from(context).inflate(R.layout.item_type_text, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
    }

    @Override
    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> View getConvertView() {
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> 返回文本类型的布局</span>
        <span style="color: #0000ff;">return</span><span style="color: #000000;"> contentView;
    }

    </span><span style="color: #008000;">/**</span><span style="color: #008000;">
     * 这个方法同一个convertView只会被调用一次，所以可以放心地在这里执行事件地绑定，不用担心生成过多的OnClickListener等
     </span><span style="color: #008000;">*/</span><span style="color: #000000;">
    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> fitEvents() {
        </span><span style="color: #008000;">/**</span><span style="color: #008000;">
         * 生成一个在convertView中使用的clickListener
         </span><span style="color: #008000;">*/</span><span style="color: #000000;">
        OnConvertViewClickListener onConvertViewClickListener </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> OnConvertViewClickListener(contentView, R.id.ab__id_adapter_item_position) {
            @Override
            </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClickCallBack(View registedView, <span style="color: #0000ff;">int</span><span style="color: #000000;">... positionIds) {
                ChatAdapter.OnChatItemListener onChatItemListener </span>=<span style="color: #000000;"> adapter.getOnChatItemListener();
                </span><span style="color: #0000ff;">switch</span><span style="color: #000000;"> (registedView.getId()) {
                    </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.item_type_text_view:
                        </span><span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> != onChatItemListener &amp;&amp; <span style="color: #0000ff;">null</span> != positionIds &amp;&amp; positionIds.length &gt; 0<span style="color: #000000;">) {
                            onChatItemListener.onItemClicked(positionIds[</span>0<span style="color: #000000;">]);
                        }
                        </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;

                    </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.item_type_text_head_iv:
                        </span><span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> != onChatItemListener &amp;&amp; <span style="color: #0000ff;">null</span> != positionIds &amp;&amp; positionIds.length &gt; 0<span style="color: #000000;">) {
                            onChatItemListener.onHeadClicked(positionIds[</span>0<span style="color: #000000;">]);
                        }
                        </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;
                    </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.item_type_text_content_iv:
                        </span><span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> != onChatItemListener &amp;&amp; <span style="color: #0000ff;">null</span> != positionIds &amp;&amp; positionIds.length &gt; 0<span style="color: #000000;">) {
                            onChatItemListener.onImageClicked(positionIds[</span>0<span style="color: #000000;">]);
                        }
                        </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;

                }

            }
        };

        </span><span style="color: #008000;">//</span><span style="color: #008000;"> 通过ABViewUtil从contentView中获取对应id的控件，然后设置OnClickListener</span>
<span style="color: #000000;">        ABViewUtil.obtainView(contentView, R.id.item_type_text_view)
                .setOnClickListener(onConvertViewClickListener);
        ABViewUtil.obtainView(contentView, R.id.item_type_text_head_iv)
                .setOnClickListener(onConvertViewClickListener);
        ABViewUtil.obtainView(contentView, R.id.item_type_text_content_iv)
                .setOnClickListener(onConvertViewClickListener);

    }

    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> ImageView headIv;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> View rootView;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> ImageView contentIv;

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> fitDatas(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {        
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> 通过ABViewUtil从contentView中获取对应id的控件，然后设置OnClickListener</span>
        headIv =<span style="color: #000000;"> ABViewUtil.obtainView(contentView, R.id.item_type_text_head_iv);
        contentIv </span>=<span style="color: #000000;"> ABViewUtil.obtainView(contentView, R.id.item_type_text_content_iv);
        </span><span style="color: #008000;">/**</span><span style="color: #008000;">
         * 在这里适配数据到ui
         </span><span style="color: #008000;">*/</span><span style="color: #000000;">
        Message message </span>=<span style="color: #000000;"> adapter.getItem(position);
        ImageLoader.getInstances().displayImage(message.getHeadUrl(), headIv, </span>100, <span style="color: #0000ff;">null</span><span style="color: #000000;">, R.drawable.default_head);
        ImageLoader.getInstances().displayImage(message.getContentUrl(), headIv, </span>100, <span style="color: #0000ff;">null</span><span style="color: #000000;">, R.drawable.default_pic);

    }

}</span></pre>
</div>

**3\. BaseTypeAdapter的实现**

到这里，我们已经定义好了各种type的Render了，现在需要在Adapter中去使用它，方法之前讲过，只要继承BaseTypeAdapter，然后实现里面的getAdapterTypeRender方法即可：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.activities.typerendertest.adapter;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.content.Context;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter.typeadapter.AdapterTypeRender;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidbucket.adapter.typeadapter.BaseTypeAdapter;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 9/14/14.
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MessageAdapter <span style="color: #0000ff;">extends</span><span style="color: #000000;"> BaseTypeAdapter {

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> OnChatItemListener{
        </span><span style="color: #0000ff;">void</span> onImageClicked(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position);
        </span><span style="color: #0000ff;">void</span> onHeadClicked(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position);
        </span><span style="color: #0000ff;">void</span> onItemClicked(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position);
    }
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> OnChatItemListener onChatItemListener;
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOnChatItemListener(OnChatItemListener onChatItemListener) {
        </span><span style="color: #0000ff;">this</span>.onChatItemListener =<span style="color: #000000;"> onChatItemListener;
    }
    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> OnChatItemListener getOnChatItemListener() {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> onChatItemListener;
    }

    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Context context;
    </span><span style="color: #0000ff;">private</span> List&lt;Message&gt;<span style="color: #000000;"> list;
    </span><span style="color: #0000ff;">public</span> List&lt;Message&gt;<span style="color: #000000;"> getList() {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> list;
    }

    </span><span style="color: #0000ff;">public</span> MessageAdapter(Context context, List&lt;Message&gt;<span style="color: #000000;"> list) {
        </span><span style="color: #0000ff;">this</span>.context =<span style="color: #000000;"> context;
        </span><span style="color: #0000ff;">this</span>.list =<span style="color: #000000;"> list;
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getCount() {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> list.size();
    }

    @Override
    </span><span style="color: #0000ff;">public</span> DoctorFriendMessageViewModelProxy getItem(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> list.get(position);
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">long</span> getItemId(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> position;
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> getItemViewType(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> list.get(position).getTyp();
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> getViewTypeCount() {
        </span><span style="color: #0000ff;">return</span> 2<span style="color: #000000;">;
    }

    @Override
    </span><span style="color: #0000ff;">public</span> AdapterTypeRender getAdapterTypeRender(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position){
        AdapterTypeRender typeRender </span>= <span style="color: #0000ff;">null</span><span style="color: #000000;">;
        </span><span style="color: #0000ff;">switch</span><span style="color: #000000;">(getItemViewType(position)){
            </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> MessageConstants.MessageType.IMAGE:
                typeRender </span>= <span style="color: #0000ff;">new</span> ChatTypeImageRender(context, <span style="color: #0000ff;">this</span><span style="color: #000000;">);
                </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;
            </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> MessageConstants.MessageType.TEXT:
            </span><span style="color: #0000ff;">default</span><span style="color: #000000;">:
                typeRender </span>= <span style="color: #0000ff;">new</span> ChatTypeTextRender(context, <span style="color: #0000ff;">this</span><span style="color: #000000;">);
                </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;
        }
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> typeRender;
    }

}</span></pre>
</div>

如上代码所示，通过实现getAdapterTypeRender来获取对应类型的Render即可了。

&nbsp;

