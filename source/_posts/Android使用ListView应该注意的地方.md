---
title: Android使用ListView应该注意的地方
tags: [android, ListView, view, tips]
date: 2012-06-19 08:28:00
---

<span>在ListView中设置Selector为null会报空指针？</span>&nbsp;
mListView.setSelector(null);//空指针&nbsp;
试试下面这种：&nbsp;
mListView.setSelector(new ColorDrawable(Color.TRANSPARENT));&nbsp;

<span>如何让ListView初始化的时候就选中一项?</span>&nbsp;
ListView需要在初始化好数据后,其中一项需要呈选中状态。所谓"选中状态"就是该项底色与其它项不同,setSelection(position)只能定位到某个item，但是无法改变底色呈高亮。setSelection(position)只能让某个item显示在可见Item的最上面(如果Item超过一屏的话)! 就是所谓的firstVisibleItem啦！&nbsp;
如果想要实现效果可以在listview所绑定的adapter里的getView函数里去完成一些具体的工作。可以记下你要高亮的那个item的index，在getView函数里判断index（也就是position），如果满足条件则加载不同的背景。&nbsp;

<span>ListView的右边滚动滑块启用方法？</span>&nbsp;
&nbsp;&nbsp;&nbsp; 很多开发者不知道ListView列表控件的快速滚动滑块是如何启用的，其实辅助滚动滑块只需要一行代码就可以搞定，如果你使用XML布局只需要在ListView节点中加入&nbsp; android:fastScrollEnabled="true" 这个属性即可，而对于Java代码可以通过myListView.setFastScrollEnabled(true); 来控制启用，参数false为隐藏。&nbsp;
&nbsp;&nbsp;&nbsp; 还有一点就是当你的滚动内容较小，不到当前ListView的3个屏幕高度时则不会出现这个快速滚动滑块，该方法是AbsListView的基础方法，可以在ListView或GridView等子类中使用快速滚动辅助。&nbsp;

![](http://dl.iteye.com/upload/attachment/463627/bb15bcb0-3d45-33fc-9460-8ca9f90bb29d.jpg)&nbsp;

1\. 更新ListView中的數據,通過調用BaseAdapter對象的notifyDataSetChanged()方法：&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mAdapter.notifyDataSetChanged();&nbsp;

2\. 每個listview都有無效的位置,如第一行的前一行,最後一行的後一行,這個無效的位置是一個常量.&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp; ListView.INVALID_POSITION&nbsp;

3\. 有時我們需要在程序中通過點擊按鈕來控制ListView行的選中,這就用到了在程序中如何使用代碼來選擇ListView項.&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mListView.requestFocusFromTouch();&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mListView.setSelection(int index);&nbsp;

&nbsp;&nbsp;&nbsp;&nbsp; 第一條語句並不是必須的,但是若你ListView項中含有Button,RadioButton,CheckBox等比ListView取得 焦點優先級高的控件時,那麼第一條語句是你必須加的.&nbsp;

<span>4.&nbsp; 同樣的,若你ListView項中含有Button,RadioButton,CheckBox等比ListView取得 焦點優先級高的控件時,ListView的setOnItemClickListener是不被執行的,這時你需要在你的xml文件中對這些控件添加&nbsp;&nbsp;<span>android:focusable="false" 注意這條語句要放在xml文件中修改,在代碼中使用是無效的.</span>&nbsp;</span>

5\. 如何保持ListView的滾動條一直顯示,不隱藏呢:&nbsp; xml文件中做如下修改&nbsp;&nbsp;&nbsp; android:fadeScrollbars="false"&nbsp;

6\. ListView本身有自己的按鍵事件，即你不需要設置方向鍵的標識，按下方向鍵ListView就會有默認的動作，那如何進行控制，編寫自己的onKey呢，你需要在Activity中重寫dispatchKeyEvent(KeyEvent event)；方法，在這裡面定義你自己的動作就可以了&nbsp;

<span>ListView 自定义滚动条样式：</span>&nbsp;
&lt;ListView android:id="@android:id/list"&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:layout_width="match_parent"&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:layout_height="0dip"&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:layout_weight="1"&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:stackFromBottom="true"//从下开始显示条目&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:transcriptMode="normal"&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:fastScrollEnabled="true"&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:focusable="true"&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:scrollbarTrackVertical="@drawable/scrollbar_vertical_track"&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:scrollbarThumbVertical="@drawable/scrollbar_vertical_thumb"&nbsp;
/&gt;&nbsp;
//scrollbar_vertical_track，crollbar_vertical_thumb自定义的xml文件，放在Drawable中，track是指长条，thumb是指短条&nbsp;
<span>去掉ListView Selector选种时黄色底纹一闪的效果：</span>&nbsp;

<div class="dp-highlighter">
<div class="bar">
<div class="tools">Xml代码&nbsp; &nbsp;[![收藏代码](http://gundumw100.iteye.com/images/icon_star.png)](http://gundumw100.iteye.com/blog/1169065 "收藏这段代码")</div>

</div>

1.  <span><span class="tag">&lt;?</span><span class="tag-name">xml</span>&nbsp;<span class="attribute">version</span>=<span class="attribute-value">"1.0"</span>&nbsp;<span class="attribute">encoding</span>=<span class="attribute-value">"utf-8"</span><span class="tag">?&gt;</span>&nbsp;&nbsp;</span>
2.  <span><span class="tag">&lt;</span><span class="tag-name">shape</span>&nbsp;<span class="attribute">xmlns:android</span>=<span class="attribute-value">"http://schemas.android.com/apk/res/android"</span><span class="tag">&gt;</span>&nbsp;&nbsp;</span>
3.  <span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="tag">&lt;</span><span class="tag-name">solid</span>&nbsp;<span class="attribute">android:color</span>=<span class="attribute-value">"@android:color/transparent"</span><span class="tag">/&gt;</span>&nbsp;&nbsp;</span>
4.  <span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="tag">&lt;</span><span class="tag-name">corners</span>&nbsp;<span class="attribute">android:radius</span>=<span class="attribute-value">"0dip"</span>&nbsp;<span class="tag">/&gt;</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
5.  <span><span class="tag">&lt;/</span><span class="tag-name">shape</span><span class="tag">&gt;</span>&nbsp;&nbsp;</span>
6.  <span>//listview.setSelector(R.drawable.thisShape);&nbsp;&nbsp;</span></div>

或者还有一种办法：&nbsp;
在Adapter中重写public boolean isEnabled(int position)方法，将其返回false就可以了，推荐采用此种办法,具体见[http://gundumw100.iteye.com/admin/blogs/850654](http://gundumw100.iteye.com/admin/blogs/850654)&nbsp;

<div class="dp-highlighter">
<div class="bar">
<div class="tools">Java代码&nbsp; &nbsp;[![收藏代码](http://gundumw100.iteye.com/images/icon_star.png)](http://gundumw100.iteye.com/blog/1169065 "收藏这段代码")</div>

</div>

1.  <span><span class="keyword">public</span>&nbsp;<span class="keyword">boolean</span>&nbsp;isEnabled(<span class="keyword">int</span>&nbsp;position)&nbsp;{&nbsp;&nbsp;</span>
2.  <span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="comment">//&nbsp;TODO&nbsp;Auto-generated&nbsp;method&nbsp;stub</span>&nbsp;&nbsp;</span>
3.  <span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span>&nbsp;<span class="keyword">false</span>;&nbsp;&nbsp;</span>
4.  <span>}&nbsp;&nbsp;</span></div>

<span>ListView几个比较特别的属性</span>&nbsp;
首先是stackFromBottom属性，这只该属性之后你做好的列表就会显示你列表的最下面，值为true和false&nbsp;
android:stackFromBottom="true"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

第二是transciptMode属性，需要用ListView或者其它显示大量Items的控件实时跟踪或者查看信息，并且希望最新的条目可以自动滚动到可视范围内。通过设置的控件transcriptMode属性可以将Android平台的控件（支持ScrollBar）自动滑动到最底部。&nbsp;
android:transcriptMode="alwaysScroll"&nbsp;&nbsp;&nbsp;&nbsp;

第三cacheColorHint属性，很多人希望能够改变一下它的背景，使他能够符合整体的UI设计，改变背景背很简单只需要准备一张图片然后指定属性 android:background="@drawable/bg"，不过不要高兴地太早，当你这么做以后，发现背景是变了，但是当你拖动，或者点击list空白位置的时候发现ListItem都变成黑色的了，破坏了整体效果。&nbsp;
如果你只是换背景的颜色的话，可以直接指定android:cacheColorHint为你所要的颜色，如果你是用图片做背景的话，那也只要将android:cacheColorHint指定为透明（#00000000）就可以了&nbsp;

第四divider属性，该属性作用是每一项之间需要设置一个图片做为间隔，或是去掉item之间的分割线android:divider="@drawable/list_driver"&nbsp; 其中&nbsp; @drawable/list_driver 是一个图片资源，如果不想显示分割线则只要设置为android:divider="@drawable/@null" 就可以了&nbsp;

第五fadingEdge属性，上边和下边有黑色的阴影android:fadingEdge="none" 设置后没有阴影了~&nbsp;

第五scrollbars属性，作用是隐藏listView的滚动条，android:scrollbars="none"与setVerticalScrollBarEnabled(true);的效果是一样的，不活动的时候隐藏，活动的时候也隐藏&nbsp;

第六fadeScrollbars属性，android:fadeScrollbars="true"&nbsp; 配置ListView布局的时候，设置这个属性为true就可以实现滚动条的自动隐藏和显示。&nbsp;

<span>如何在使用gallery在flinging拖动时候不出现选择的情况？&nbsp;</span>
这时候需要注意使用&nbsp;
gallery.setCallbackDuringFling(false)&nbsp;

<span>如何让ListView自动滚动？&nbsp;</span>
注意stackFromBottom以及transcriptMode这两个属性。类似Market客户端的低端不断滚动。&nbsp;
&lt;ListView android:id="listCWJ"&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp; android:layout_width="fill_parent"&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp; android:layout_height="fill_parent"&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp; android:stackFromBottom="true"&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp; android:transcriptMode="alwaysScroll"&nbsp;&nbsp;
/&gt;&nbsp;
<span>如何遍历listView 的的单选框？</span>&nbsp;

<div class="dp-highlighter">
<div class="bar">
<div class="tools">Java代码&nbsp; &nbsp;[![收藏代码](http://gundumw100.iteye.com/images/icon_star.png)](http://gundumw100.iteye.com/blog/1169065 "收藏这段代码")</div>

</div>

1.  <span>ListView&nbsp;listView&nbsp;=&nbsp;(ListView)findViewById(R.id.配置文件中ListView的ID);&nbsp;&nbsp;</span>
2.  <span><span class="comment">//全选遍历ListView的选项，每个选项就相当于布局配置文件中的RelativeLayout</span>&nbsp;&nbsp;</span>
3.  <span><span class="keyword">for</span>(<span class="keyword">int</span>&nbsp;i&nbsp;=&nbsp;<span class="number">0</span>;&nbsp;i&nbsp;&lt;&nbsp;listView.getChildCount();&nbsp;i++){&nbsp;&nbsp;</span>
4.  <span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;View&nbsp;view&nbsp;=&nbsp;listView.getChildAt(i);&nbsp;&nbsp;</span>
5.  <span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;CheckBox&nbsp;cb&nbsp;=&nbsp;(CheckBox)view.findViewById(R.id.CheckBoxID);&nbsp;&nbsp;</span>
6.  <span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cb.setChecked(<span class="keyword">true</span>);&nbsp;&nbsp;</span>
7.  <span>}&nbsp;&nbsp;</span></div>

<span>如何让ListView中TextView的字体颜色跟随焦点的变化？&nbsp;</span>
我们通常需要ListView中某一项选中时，他的字体颜色和原来的不一样。 如何设置字体的颜色呢？ 在布局文件中TextColor一项来设置颜色，但是不是只设置一种颜色，而是在不同的条件下设置不同的颜色： 下面是个例子：&nbsp;

<div class="dp-highlighter">
<div class="bar">
<div class="tools">Xml代码&nbsp; &nbsp;[![收藏代码](http://gundumw100.iteye.com/images/icon_star.png)](http://gundumw100.iteye.com/blog/1169065 "收藏这段代码")</div>

</div>

1.  <span><span class="tag">&lt;?</span><span class="tag-name">xml</span>&nbsp;<span class="attribute">version</span>=<span class="attribute-value">"1.0"</span>&nbsp;<span class="attribute">encoding</span>=<span class="attribute-value">"utf-8"</span>&nbsp;<span class="tag">?&gt;</span>&nbsp;&nbsp;</span>
2.  <span><span class="tag">&lt;</span><span class="tag-name">selector</span>&nbsp;<span class="attribute">xmlns:android</span>=<span class="attribute-value">"http://schemas.android.com/apk/res/android"</span><span class="tag">&gt;</span>&nbsp;&nbsp;</span>
3.  <span><span class="tag">&lt;</span><span class="tag-name">item</span>&nbsp;<span class="attribute">android:state_enabled</span>=<span class="attribute-value">"false"</span>&nbsp;<span class="attribute">android:color</span>=<span class="attribute-value">"@color/orange"</span><span class="tag">&gt;</span><span class="tag">&lt;/</span><span class="tag-name">item</span><span class="tag">&gt;</span>&nbsp;&nbsp;</span>
4.  <span><span class="tag">&lt;</span><span class="tag-name">item</span>&nbsp;<span class="attribute">android:state_window_focused</span>=<span class="attribute-value">"false"</span>&nbsp;<span class="attribute">android:color</span>=<span class="attribute-value">"@color/orange"</span><span class="tag">&gt;</span><span class="tag">&lt;/</span><span class="tag-name">item</span><span class="tag">&gt;</span>&nbsp;&nbsp;</span>
5.  <span><span class="tag">&lt;</span><span class="tag-name">item</span>&nbsp;<span class="attribute">android:state_pressed</span>=<span class="attribute-value">"true"</span>&nbsp;<span class="attribute">android:color</span>=<span class="attribute-value">"@color/white"</span><span class="tag">&gt;</span><span class="tag">&lt;/</span><span class="tag-name">item</span><span class="tag">&gt;</span>&nbsp;&nbsp;</span>
6.  <span><span class="tag">&lt;</span><span class="tag-name">item</span>&nbsp;<span class="attribute">android:state_selected</span>=<span class="attribute-value">"true"</span>&nbsp;<span class="attribute">android:color</span>=<span class="attribute-value">"@color/white"</span><span class="tag">&gt;</span><span class="tag">&lt;/</span><span class="tag-name">item</span><span class="tag">&gt;</span>&nbsp;&nbsp;</span>
7.  <span><span class="tag">&lt;</span><span class="tag-name">item</span>&nbsp;<span class="attribute">android:color</span>=<span class="attribute-value">"@color/orange"</span><span class="tag">&gt;</span><span class="tag">&lt;/</span><span class="tag-name">item</span><span class="tag">&gt;</span>&nbsp;&nbsp;</span>
8.  <span><span class="tag">&lt;/</span><span class="tag-name">selector</span><span class="tag">&gt;</span>&nbsp;&nbsp;&nbsp;</span>
9.  <span>在获取焦点或者选中的情况下设置为白色，其他情况设置为橘黄色。&nbsp;&nbsp;</span></div>

<span>如何自定义ListView行间的分割线？</span>&nbsp;
所有基于ListView或者说AbsListView实现的widget控件均可以通过下面的方法设置行间距的分割线，分割线可以自定义颜色、或图片。&nbsp;
在ListView中我们使用属性android:divider="#FF0000" 定义分隔符为红色，当然这里值可以指向一个drawable图片对象，如果使用了图片可能高度大于系统默认的像素，可以自己设置高度比如6个像素android:dividerHeight="6px" ，当然在Java中ListView也有相关方法可以设置。&nbsp;

<span>ListView不通过notifyDataSetChanged()更新指定的Item</span>&nbsp;
Listview一般大都是通过notifyDataSetChanged()來更新listview,但通过notifyDataSetChanged()会把界面上现实的的item都重绘一次，这样会影响ui性能。&nbsp;
可以通过更新指定的Item提高效率，伪代码如下：&nbsp;

<div class="dp-highlighter">
<div class="bar">
<div class="tools">Java代码&nbsp; &nbsp;[![收藏代码](http://gundumw100.iteye.com/images/icon_star.png)](http://gundumw100.iteye.com/blog/1169065 "收藏这段代码")</div>

</div>

1.  <span><span class="keyword">private</span>&nbsp;<span class="keyword">void</span>&nbsp;updateView(<span class="keyword">int</span>&nbsp;itemIndex){&nbsp;&nbsp;&nbsp;&nbsp;</span>
2.  <span>&nbsp;&nbsp;<span class="keyword">int</span>&nbsp;visiblePosition&nbsp;=&nbsp;yourListView.getFirstVisiblePosition();&nbsp;&nbsp;&nbsp;&nbsp;</span>
3.  <span>&nbsp;&nbsp;View&nbsp;v&nbsp;=&nbsp;yourListView.getChildAt(itemIndex&nbsp;-&nbsp;visiblePosition);<span class="comment">//Do&nbsp;something&nbsp;fancy&nbsp;with&nbsp;your&nbsp;listitem&nbsp;view&nbsp;&nbsp;</span>&nbsp;&nbsp;</span>
4.  <span>&nbsp;&nbsp;TextView&nbsp;tv&nbsp;=&nbsp;(TextView)v.findViewById(R.id.sometextview);&nbsp;&nbsp;</span>
5.  <span>&nbsp;&nbsp;tv.setText(<span class="string">"Hi!&nbsp;I&nbsp;updated&nbsp;you&nbsp;manually"</span>);&nbsp;&nbsp;</span>
6.  <span>}&nbsp;&nbsp;</span></div>

<span>让ListView中长按某些Item时能弹出contextMenu，有些不能</span>&nbsp;
定义了一个listView，并为他设置了setOnCreateContextMenuListener的监听，但这样做只能使这个listView中的所有项在长按的时候弹出contextMenu 。&nbsp;
有时希望的是有些长按时能弹出contextMenu，有些不能。解决这个问题的办法是为这个listView设置setOnItemLongClickListener监听，然后实现&nbsp;

<div class="dp-highlighter">
<div class="bar">
<div class="tools">Java代码&nbsp; &nbsp;[![收藏代码](http://gundumw100.iteye.com/images/icon_star.png)](http://gundumw100.iteye.com/blog/1169065 "收藏这段代码")</div>

</div>

1.  <span><span class="keyword">public</span>&nbsp;<span class="keyword">boolean</span>&nbsp;onItemLongClick(AdapterView&lt;?&gt;&nbsp;parent,&nbsp;View&nbsp;view,&nbsp;&nbsp;&nbsp;</span>
2.  <span><span class="keyword">int</span>&nbsp;position,&nbsp;<span class="keyword">long</span>&nbsp;id)&nbsp;{&nbsp;&nbsp;&nbsp;</span>
3.  <span>&nbsp;&nbsp;<span class="keyword">if</span>(id&nbsp;==&nbsp;<span class="number">1</span>){&nbsp;&nbsp;&nbsp;</span>
4.  <span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="keyword">return</span>&nbsp;<span class="keyword">true</span>;&nbsp;&nbsp;&nbsp;</span>
5.  <span>&nbsp;&nbsp;}&nbsp;&nbsp;&nbsp;</span>
6.  <span>&nbsp;&nbsp;<span class="keyword">return</span>&nbsp;<span class="keyword">false</span>;&nbsp;&nbsp;&nbsp;</span>
7.  <span>}&nbsp;&nbsp;&nbsp;</span></div>

如果这一项的id=1,就不能长按。 这样就可以了&nbsp;

<span>ListView底部分隔线的问题</span>&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 在工作中遇到了一个难题，就是一个listView在最下面的一个item下面没有分割线，要求是必须得有这条分割线。经过一通研究发现了这个奇怪的现象：&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1\. ListActivity有这条底部分割线。&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2.在Activity中只有listview，没有别的控件的话也会有。&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 其实ListActivity也是一个Activity，只不过在其中使用了SetContentView(listView)方法设置了一个listView作为其显示的View而已。所以结论就是只要这个activity调用了SetContentView(listView)就会有这条底部分割线。&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 那么什么情况下才不会有这条分割线呢？在Activity中如果调用setContentView(View)而ListView只是内嵌入到这个View的话有可能会没有这条分割线。&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 分析其原因：通过加断点调试发现在listView中，所有的分割线都是通过画一个很窄的矩形来实现的，但是在画分割线前都会都会判断目前的位置A和listView的长度B，如果A=B了，那么就不会画这条分割线了。但是将Listview嵌入到一个View中，一般会设置为高度为wrap_content,这种情况下，最后那条分割线的位置刚好等于listView的高度，所以系统不会画上这条分割线。那要怎么样才会画上呢？很简单，将ListView的高度设置为fill_partent就可以了。&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp; 当然以上所说的都是item很少的情况下，如果item很多以至于必须显示滚动条的话，那最后一个item下面是肯定不会有分割线了。<span>&lt;!--[endif]--&gt;&nbsp;&lt;!--[endif]--&gt;</span>

