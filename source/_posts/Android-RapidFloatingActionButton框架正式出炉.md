---
title: '[Android]RapidFloatingActionButton框架正式出炉'
tags: []
date: 2015-05-03 21:28:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span style="color: #ff0000;">**来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/4474748.html](http://www.cnblogs.com/tiantianbyconan/p/4474748.html)**</span>

# RapidFloatingActionButton

Google推出了MaterialDesign的设计语言，其中FloatingActionButton就是一部分，但是Google却没有提供一个官方的FloatingActionButton控件，网上找了几个试用了下，但是始终没有找到合适的，所以，自己动手丰衣足食了。

[RapidFloatingActionButton](http://www.cnblogs.com/RapidFloatingActionButton)（以下简称RFAB）是Floating Action Button的快速实现。

**<span style="color: #ff0000;">Github地址：[<span style="color: #ff0000;">https://github.com/wangjiegulu/RapidFloatingActionButton</span>](https://github.com/wangjiegulu/RapidFloatingActionButton)</span>**

[![](https://raw.githubusercontent.com/wangjiegulu/RapidFloatingActionButton/master/screenshot/rfab_label_list.gif)](https://raw.githubusercontent.com/wangjiegulu/RapidFloatingActionButton/master/screenshot/rfab_label_list.gif)&nbsp;[![](https://raw.githubusercontent.com/wangjiegulu/RapidFloatingActionButton/master/screenshot/rfabg.gif)](https://raw.githubusercontent.com/wangjiegulu/RapidFloatingActionButton/master/screenshot/rfabg.gif)&nbsp;

[![](https://raw.githubusercontent.com/wangjiegulu/RapidFloatingActionButton/master/screenshot/rfab_01.png)](https://raw.githubusercontent.com/wangjiegulu/RapidFloatingActionButton/master/screenshot/rfab_01.png)&nbsp;[![](https://raw.githubusercontent.com/wangjiegulu/RapidFloatingActionButton/master/screenshot/rfab_03.png)](https://raw.githubusercontent.com/wangjiegulu/RapidFloatingActionButton/master/screenshot/rfab_03.png)

# [](https://github.com/wangjiegulu/RapidFloatingActionButton#%E4%BD%BF%E7%94%A8%E6%96%B9%E5%BC%8F)使用方式：

依赖：
**[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)([https://github.com/wangjiegulu/AndroidBucket](https://github.com/wangjiegulu/AndroidBucket))**：基础工具包
**[AndroidInject](https://github.com/wangjiegulu/androidInject)([https://github.com/wangjiegulu/androidInject](https://github.com/wangjiegulu/androidInject))**：注解框架

**[NineOldAndroids](https://github.com/JakeWharton/NineOldAndroids)([https://github.com/JakeWharton/NineOldAndroids](https://github.com/JakeWharton/NineOldAndroids))**：兼容低版本的动画框架

## [](https://github.com/wangjiegulu/RapidFloatingActionButton#activity_mainxml)activity_main.xml：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> &lt;<span style="color: #000000;">com.wangjie.rapidfloatingactionbutton.RapidFloatingActionLayout
</span><span style="color: #008080;"> 2</span>       xmlns:rfal="http://schemas.android.com/apk/res-auto"
<span style="color: #008080;"> 3</span>       android:id="@+id/activity_main_rfal"
<span style="color: #008080;"> 4</span>       android:layout_width="match_parent"
<span style="color: #008080;"> 5</span>       android:layout_height="match_parent"
<span style="color: #008080;"> 6</span>       rfal:rfal_frame_color="#ffffff"
<span style="color: #008080;"> 7</span>       rfal:rfal_frame_alpha="0.7"
<span style="color: #008080;"> 8</span>       &gt;
<span style="color: #008080;"> 9</span>   &lt;<span style="color: #000000;">com.wangjie.rapidfloatingactionbutton.RapidFloatingActionButton
</span><span style="color: #008080;">10</span>           xmlns:rfab="http://schemas.android.com/apk/res-auto"
<span style="color: #008080;">11</span>           android:id="@+id/activity_main_rfab"
<span style="color: #008080;">12</span>           android:layout_width="wrap_content"
<span style="color: #008080;">13</span>           android:layout_height="wrap_content"
<span style="color: #008080;">14</span>           android:layout_alignParentRight="true"
<span style="color: #008080;">15</span>           android:layout_alignParentBottom="true"
<span style="color: #008080;">16</span>           android:layout_marginRight="15dp"
<span style="color: #008080;">17</span>           android:layout_marginBottom="15dp"
<span style="color: #008080;">18</span>           android:padding="8dp"
<span style="color: #008080;">19</span>           rfab:rfab_size="normal"
<span style="color: #008080;">20</span>           rfab:rfab_drawable="@drawable/rfab__drawable_rfab_default"
<span style="color: #008080;">21</span>           rfab:rfab_color_normal="#37474f"
<span style="color: #008080;">22</span>           rfab:rfab_color_pressed="#263238"
<span style="color: #008080;">23</span>           rfab:rfab_shadow_radius="7dp"
<span style="color: #008080;">24</span>           rfab:rfab_shadow_color="#999999"
<span style="color: #008080;">25</span>           rfab:rfab_shadow_dx="0dp"
<span style="color: #008080;">26</span>           rfab:rfab_shadow_dy="5dp"
<span style="color: #008080;">27</span>           /&gt;
<span style="color: #008080;">28</span> &lt;/com.wangjie.rapidfloatingactionbutton.RapidFloatingActionLayout&gt;</pre>
</div>

在需要增加RFAB最外层使用`&lt;com.wangjie.rapidfloatingactionbutton.RapidFloatingActionLayout&gt;`，按钮使用`&lt;com.wangjie.rapidfloatingactionbutton.RapidFloatingActionButton&gt;`

### [](https://github.com/wangjiegulu/RapidFloatingActionButton#%E5%B1%9E%E6%80%A7%E8%A7%A3%E9%87%8A)属性解释

#### [](https://github.com/wangjiegulu/RapidFloatingActionButton#rapidfloatingactionlayout)RapidFloatingActionLayout:

<div class="cnblogs_code">
<pre><span style="color: #000000;">  rfal_frame_color: 展开RFAB时候最外覆盖层的颜色，默认是纯白色
  rfal_frame_alpha: 展开RFAB时候最外覆盖层的透明度(0 ~ 1)，默认是0.7</span></pre>
</div>

#### [](https://github.com/wangjiegulu/RapidFloatingActionButton#rapidfloatingactionbutton-1)RapidFloatingActionButton:

<div class="cnblogs_code">
<pre><span style="color: #000000;">　rfab_size: RFAB的尺寸大小，只支持两种尺寸（Material Design规范）：
          normal: 直径56dp
          mini: 直径40dp
  rfab_drawable: RFAB中间的图标，默认是一个"+"图标
  rfab_color_normal: RFAB背景的普通状态下的颜色。默认是白色
  rfab_color_pressed: RFAB背景的触摸按下状态的颜色。默认颜色是"#dddddd"
  rfab_shadow_radius: RFAB的阴影半径。默认是0，表示没有阴影
  rfab_shadow_color: RFAB的阴影颜色。默认是透明，另外如果rfab_shadow_radius为0，则该属性无效
  rfab_shadow_dx: RFAB的阴影X轴偏移量。默认是0
  rfab_shadow_dy: RFAB的阴影Y轴偏移量。默认是0</span></pre>
</div>

## [](https://github.com/wangjiegulu/RapidFloatingActionButton#mainactivity)MainActivity：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">@AILayout(R.layout.activity_main)
</span><span style="color: #008080;"> 2</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span> AIActionBarActivity <span style="color: #0000ff;">implements</span><span style="color: #000000;"> RapidFloatingActionContentLabelList.OnRapidFloatingActionContentListener {
</span><span style="color: #008080;"> 3</span> 
<span style="color: #008080;"> 4</span> <span style="color: #000000;">    @AIView(R.id.activity_main_rfal)
</span><span style="color: #008080;"> 5</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> RapidFloatingActionLayout rfaLayout;
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">    @AIView(R.id.activity_main_rfab)
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> RapidFloatingActionButton rfaBtn;
</span><span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> RapidFloatingActionButtonHelper rfabHelper;
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">11</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
</span><span style="color: #008080;">13</span> 
<span style="color: #008080;">14</span>         RapidFloatingActionContentLabelList rfaContent = <span style="color: #0000ff;">new</span><span style="color: #000000;"> RapidFloatingActionContentLabelList(context);
</span><span style="color: #008080;">15</span>         rfaContent.setOnRapidFloatingActionContentListener(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">16</span>         List&lt;RFACLabelItem&gt; items = <span style="color: #0000ff;">new</span> ArrayList&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">17</span>         items.add(<span style="color: #0000ff;">new</span> RFACLabelItem&lt;Integer&gt;<span style="color: #000000;">()
</span><span style="color: #008080;">18</span>                         .setLabel("Github: wangjiegulu"<span style="color: #000000;">)
</span><span style="color: #008080;">19</span> <span style="color: #000000;">                        .setResId(R.drawable.ic_launcher)
</span><span style="color: #008080;">20</span>                         .setIconNormalColor(0xffd84315<span style="color: #000000;">)
</span><span style="color: #008080;">21</span>                         .setIconPressedColor(0xffbf360c<span style="color: #000000;">)
</span><span style="color: #008080;">22</span>                         .setWrapper(0<span style="color: #000000;">)
</span><span style="color: #008080;">23</span> <span style="color: #000000;">        );
</span><span style="color: #008080;">24</span>         items.add(<span style="color: #0000ff;">new</span> RFACLabelItem&lt;Integer&gt;<span style="color: #000000;">()
</span><span style="color: #008080;">25</span>                         .setLabel("tiantian.china.2@gmail.com"<span style="color: #000000;">)
</span><span style="color: #008080;">26</span> <span style="color: #000000;">                        .setResId(R.drawable.ic_launcher)
</span><span style="color: #008080;">27</span>                         .setIconNormalColor(0xff4e342e<span style="color: #000000;">)
</span><span style="color: #008080;">28</span>                         .setIconPressedColor(0xff3e2723<span style="color: #000000;">)
</span><span style="color: #008080;">29</span>                         .setWrapper(1<span style="color: #000000;">)
</span><span style="color: #008080;">30</span> <span style="color: #000000;">        );
</span><span style="color: #008080;">31</span>         items.add(<span style="color: #0000ff;">new</span> RFACLabelItem&lt;Integer&gt;<span style="color: #000000;">()
</span><span style="color: #008080;">32</span>                         .setLabel("WangJie"<span style="color: #000000;">)
</span><span style="color: #008080;">33</span> <span style="color: #000000;">                        .setResId(R.drawable.ic_launcher)
</span><span style="color: #008080;">34</span>                         .setIconNormalColor(0xff056f00<span style="color: #000000;">)
</span><span style="color: #008080;">35</span>                         .setIconPressedColor(0xff0d5302<span style="color: #000000;">)
</span><span style="color: #008080;">36</span>                         .setWrapper(2<span style="color: #000000;">)
</span><span style="color: #008080;">37</span> <span style="color: #000000;">        );
</span><span style="color: #008080;">38</span>         items.add(<span style="color: #0000ff;">new</span> RFACLabelItem&lt;Integer&gt;<span style="color: #000000;">()
</span><span style="color: #008080;">39</span>                         .setLabel("Compose"<span style="color: #000000;">)
</span><span style="color: #008080;">40</span> <span style="color: #000000;">                        .setResId(R.drawable.ic_launcher)
</span><span style="color: #008080;">41</span>                         .setIconNormalColor(0xff283593<span style="color: #000000;">)
</span><span style="color: #008080;">42</span>                         .setIconPressedColor(0xff1a237e<span style="color: #000000;">)
</span><span style="color: #008080;">43</span>                         .setWrapper(3<span style="color: #000000;">)
</span><span style="color: #008080;">44</span> <span style="color: #000000;">        );
</span><span style="color: #008080;">45</span> <span style="color: #000000;">        rfaContent
</span><span style="color: #008080;">46</span> <span style="color: #000000;">                .setItems(items)
</span><span style="color: #008080;">47</span>                 .setIconShadowRadius(ABTextUtil.dip2px(context, 5<span style="color: #000000;">))
</span><span style="color: #008080;">48</span>                 .setIconShadowColor(0xff999999<span style="color: #000000;">)
</span><span style="color: #008080;">49</span>                 .setIconShadowDy(ABTextUtil.dip2px(context, 5<span style="color: #000000;">))
</span><span style="color: #008080;">50</span> <span style="color: #000000;">        ;
</span><span style="color: #008080;">51</span> 
<span style="color: #008080;">52</span>         rfabHelper = <span style="color: #0000ff;">new</span><span style="color: #000000;"> RapidFloatingActionButtonHelper(
</span><span style="color: #008080;">53</span> <span style="color: #000000;">                context,
</span><span style="color: #008080;">54</span> <span style="color: #000000;">                rfaLayout,
</span><span style="color: #008080;">55</span> <span style="color: #000000;">                rfaBtn,
</span><span style="color: #008080;">56</span> <span style="color: #000000;">                rfaContent
</span><span style="color: #008080;">57</span> <span style="color: #000000;">        ).build();
</span><span style="color: #008080;">58</span> 
<span style="color: #008080;">59</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">60</span> 
<span style="color: #008080;">61</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">62</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onRFACItemLabelClick(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position, RFACLabelItem item) {
</span><span style="color: #008080;">63</span>         Toast.makeText(getContext(), "clicked label: " +<span style="color: #000000;"> position, Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">64</span> <span style="color: #000000;">        rfabHelper.toggleContent();
</span><span style="color: #008080;">65</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">66</span> 
<span style="color: #008080;">67</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">68</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onRFACItemIconClick(<span style="color: #0000ff;">int</span><span style="color: #000000;"> position, RFACLabelItem item) {
</span><span style="color: #008080;">69</span>         Toast.makeText(getContext(), "clicked icon: " +<span style="color: #000000;"> position, Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">70</span> <span style="color: #000000;">        rfabHelper.toggleContent();
</span><span style="color: #008080;">71</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">72</span> }</pre>
</div>

除了xml中设置的`RapidFloatingActionLayout`和`RapidFloatingActionButton`之外，还需要`RapidFloatingActionContent`的实现类来填充和指定RFAB的内容和形式。
这里提供了一个快速的`RapidFloatingActionContent`的实现解决方案:`RapidFloatingActionContentLabelList`。你可以加入多个item（RFACLabelItem，当然，不建议加太多的item，导致超过一个屏幕），然后设置每个item的颜色、图标、阴影、label的背景图片、字体大小颜色甚至动画。
它的效果可参考[最上面的效果图片](https://github.com/wangjiegulu/RapidFloatingActionButton/tree/master/screenshot)或者[Google的Inbox](https://play.google.com/store/apps/details?id=com.google.android.apps.inbox)的效果。
除此之外，你还需要使用`RapidFloatingActionButtonHelper`来把以上所有零散的组件组合起来。

# [](https://github.com/wangjiegulu/RapidFloatingActionButton#%E5%85%B3%E4%BA%8E%E6%89%A9%E5%B1%95)关于扩展：

如果你不喜欢默认提供的`RapidFloatingActionContentLabelList`，理论上你可以扩展自己的内容样式。方法是继承`com.wangjie.rapidfloatingactionbutton.RapidFloatingActionContent`，然后初始化内容布局和样式，并调用父类的`setRootView(xxx);`方法即可。如果你需要增加动画，可以重写如下方法：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onExpandAnimator(AnimatorSet animatorSet);
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCollapseAnimator(AnimatorSet animatorSet);</pre>
</div>

把需要的Animator增加到animatorSet中即可
`另外，作者也会不定期增加更多的RapidFloatingActionContent的扩展`

# [](https://github.com/wangjiegulu/RapidFloatingActionButton#license)License

<div class="cnblogs_code">
<pre><span style="color: #000000;">Copyright 2015 Wang Jie

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.</span></pre>
</div>

&nbsp;