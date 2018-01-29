---
title: '[Android]AndroidBucket增加碎片SubLayout功能及AISubLayout的注解支持'
tags: []
date: 2014-05-05 20:31:00
---

<span style="color: #ff0000;">**以下内容为原创，转载请注明：**</span>

<span style="color: #ff0000;">**<span style="color: #ff0000;">来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/3709957.html](http://www.cnblogs.com/tiantianbyconan/p/3709957.html)</span>**</span>

&nbsp;

之前写过一篇博客，是使用Fragment来实现TabHost的效果，并且模拟TabHost的切换各个fragment生命周期的调用，见[http://www.cnblogs.com/tiantianbyconan/p/3360938.html](http://www.cnblogs.com/tiantianbyconan/p/3360938.html)

但是如果要实现的效果是两级的Tab，比如在第一级tab中又有三个子Tab切换不同的布局，

相当于在Fragment中嵌套来Fragment，这个怎么实现？

也有个官方的实现方法，通过使用<span>android-support-v13.jar包中的<span>getChildFragmentManager方法来获取一个Manager。</span></span>

这里带来我写的一个新的方案，使用SubLayout来实现。

相关源码：[https://github.com/wangjiegulu/AndroidBucket/tree/master/src/com/wangjie/androidbucket/customviews/sublayout](https://github.com/wangjiegulu/AndroidBucket/tree/master/src/com/wangjie/androidbucket/customviews/sublayout)

下面使用一个例子来说下使用方法，先看下最后的效果（项目使用了我的开源**[AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)**和**[AndroidInject](https://github.com/wangjiegulu/androidInject)&nbsp;请先添加依赖项目，欢迎star／fork**）：

![](http://images.cnitblog.com/i/378300/201405/051955327296296.png)

效果跟以前的例子大同小异，点击第一个tab上的TextView，然后Toast提示EditText上的信息，但是使用方式却是不一样的。

大体的思路是在MainActivity布局中增加一个FrameLayout，然后在切换过程中不停的用相应的布局去替换FrameLayout中。

main.xml布局如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span>
<span style="color: #008080;"> 3</span> <span style="color: #ff0000;">              android:orientation</span><span style="color: #0000ff;">="vertical"</span>
<span style="color: #008080;"> 4</span> <span style="color: #ff0000;">              android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 5</span> <span style="color: #ff0000;">              android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;"> 6</span>         <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">FrameLayout
</span><span style="color: #008080;"> 9</span>             <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/main_content_view"</span>
<span style="color: #008080;">10</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="match_parent"</span>
<span style="color: #008080;">11</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="0dp"</span>
<span style="color: #008080;">12</span> <span style="color: #ff0000;">            android:layout_weight</span><span style="color: #0000ff;">="1.0"</span>
<span style="color: #008080;">13</span>             <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioGroup
</span><span style="color: #008080;">16</span>             <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/main_tabs_rg"</span>
<span style="color: #008080;">17</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span>
<span style="color: #008080;">18</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="65dp"</span>
<span style="color: #008080;">19</span> <span style="color: #ff0000;">            android:background</span><span style="color: #0000ff;">="#aabbcc"</span>
<span style="color: #008080;">20</span> <span style="color: #ff0000;">            android:gravity</span><span style="color: #0000ff;">="center_vertical"</span>
<span style="color: #008080;">21</span> <span style="color: #ff0000;">            android:orientation</span><span style="color: #0000ff;">="horizontal"</span> <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton
</span><span style="color: #008080;">24</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/main_tab_a_rb"</span>
<span style="color: #008080;">25</span> <span style="color: #ff0000;">                style</span><span style="color: #0000ff;">="@style/tab_item_background"</span>
<span style="color: #008080;">26</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/ic_launcher"</span>
<span style="color: #008080;">27</span> <span style="color: #ff0000;">                android:paddingTop</span><span style="color: #0000ff;">="7dp"</span>
<span style="color: #008080;">28</span> <span style="color: #ff0000;">                android:textSize</span><span style="color: #0000ff;">="13sp"</span>
<span style="color: #008080;">29</span> <span style="color: #ff0000;">                android:checked</span><span style="color: #0000ff;">="true"</span>
<span style="color: #008080;">30</span>                 <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">31</span> 
<span style="color: #008080;">32</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton
</span><span style="color: #008080;">33</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/main_tab_b_rb"</span>
<span style="color: #008080;">34</span> <span style="color: #ff0000;">                style</span><span style="color: #0000ff;">="@style/tab_item_background"</span>
<span style="color: #008080;">35</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/ic_launcher"</span>
<span style="color: #008080;">36</span> <span style="color: #ff0000;">                android:paddingTop</span><span style="color: #0000ff;">="7dp"</span>
<span style="color: #008080;">37</span> <span style="color: #ff0000;">                android:textSize</span><span style="color: #0000ff;">="13sp"</span>
<span style="color: #008080;">38</span>                 <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">39</span> 
<span style="color: #008080;">40</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton
</span><span style="color: #008080;">41</span>                 <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/main_tab_c_rb"</span>
<span style="color: #008080;">42</span> <span style="color: #ff0000;">                style</span><span style="color: #0000ff;">="@style/tab_item_background"</span>
<span style="color: #008080;">43</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/ic_launcher"</span>
<span style="color: #008080;">44</span> <span style="color: #ff0000;">                android:paddingTop</span><span style="color: #0000ff;">="7dp"</span>
<span style="color: #008080;">45</span> <span style="color: #ff0000;">                android:textSize</span><span style="color: #0000ff;">="13sp"</span>
<span style="color: #008080;">46</span>                 <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">47</span> 
<span style="color: #008080;">48</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">RadioGroup</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">49</span> 
<span style="color: #008080;">50</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

布局很简单，一个FrameLayout用于存放不同界面的布局，3个RadioButton表示下面的每一项Tab按钮。

在MainActivity中代码如下：

<div class="cnblogs_code">
<pre><span style="color: #000000;">@AILayout(R.layout.main)
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> AIActivity {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = MainActivity.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();

    @AIView(R.id.main_content_view)
    ViewGroup contentView;

    @AIView(R.id.main_tabs_rg)
    RadioGroup rg;

    SubLayoutManager sbManager;

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);

        sbManager </span>= <span style="color: #0000ff;">new</span> SubLayoutManager&lt;SubLayout&gt;(context, contentView, TabASubLayout.<span style="color: #0000ff;">class</span>, TabBSubLayout.<span style="color: #0000ff;">class</span>, TabCSubLayout.<span style="color: #0000ff;">class</span><span style="color: #000000;">);

        sbManager.setSwitchListener(</span><span style="color: #0000ff;">new</span> SubLayoutManager.LayoutSwitchListener&lt;SubLayout&gt;<span style="color: #000000;">() {
            @Override
            </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> switchSelf(SubLayout subLayout, <span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {
                Logger.d(TAG, </span>"[switch listener]switchSelf, subLayout: " + subLayout + ", position: " +<span style="color: #000000;"> position);
            }

            @Override
            </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> switchCompleted(SubLayout subLayout, <span style="color: #0000ff;">int</span><span style="color: #000000;"> position) {
                Logger.d(TAG, </span>"[switch listener]switchCompleted, subLayout: " + subLayout + ", position: " +<span style="color: #000000;"> position);
            }
        });

        rg.setOnCheckedChangeListener(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> RadioGroup.OnCheckedChangeListener() {
            @Override
            </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCheckedChanged(RadioGroup radioGroup, <span style="color: #0000ff;">int</span><span style="color: #000000;"> i) {
                </span><span style="color: #0000ff;">int</span> index = -1<span style="color: #000000;">;
                </span><span style="color: #0000ff;">switch</span><span style="color: #000000;">(i){
                    </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.main_tab_a_rb:
                        index </span>= 0<span style="color: #000000;">;
                        </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;

                    </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.main_tab_b_rb:
                        index </span>= 1<span style="color: #000000;">;
                        </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;

                    </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.main_tab_c_rb:
                        index </span>= 2<span style="color: #000000;">;
                        </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;
                }
                </span><span style="color: #0000ff;">if</span>(index &lt; 0 || index &gt;=<span style="color: #000000;"> sbManager.getSubLayoutSize()){
                    </span><span style="color: #0000ff;">return</span><span style="color: #000000;">;
                }
                sbManager.switchLayout(index);
            }
        });

        sbManager.switchLayout(</span>0); <span style="color: #008000;">//</span><span style="color: #008000;"> 默认切换第一页</span>
<span style="color: #000000;">
    }

    @Override
    </span><span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onDestroy() {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.onDestroy();
        sbManager.destoryClear();
        sbManager </span>= <span style="color: #0000ff;">null</span><span style="color: #000000;">;

    }

}</span></pre>
</div>

上面的SubLayout相当于一个Fragment，SubLayoutManager用于管理多个SubLayout之间的切换。SubLayoutManager可以通过new获取。

其中构造方法中：

public SubLayoutManager(Context context, ViewGroup contentView, Class&lt;? extends T&gt;... slszzs) {

参数二：contentView表示在MainActivity中预留给SubLayout显示的FrameLayout。

参数三：是个可变长参数，可以在后面（有序）追加所有需要切换的SubLayout的Class对象。

第一次初始化后各个SubLayout对象不会马上生成，只会在切换到改页面时才会生成该对象，会执行SubLayout的initLayout()方法，这个方法只会调用一次（类似onCreate()方法）

需要切换页面时只需要执行SubLayoutManager的switchLayout()方法，传入SubLayout的position就可以了，这个position跟参数三的顺序一致。

&nbsp;

接下来看下几个SubLayout是怎么去实现的，因为三个SubLayout大致相同，所以只分析一个就可以了：

TabASubLayout代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">@AILayout(R.layout.tab_a)
</span><span style="color: #008080;"> 2</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> TabASubLayout <span style="color: #0000ff;">extends</span><span style="color: #000000;"> AISubLayout {
</span><span style="color: #008080;"> 3</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = TabASubLayout.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> 
<span style="color: #008080;"> 6</span> <span style="color: #008000;">//</span><span style="color: #008000;">    @AIView(R.id.tab_a_tv)
</span><span style="color: #008080;"> 7</span> <span style="color: #008000;">//</span><span style="color: #008000;">    TextView tv;</span>
<span style="color: #008080;"> 8</span> <span style="color: #000000;">    @AIView(R.id.tab_a_et)
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    EditText et;
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> TabASubLayout(Context context) {
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context);
</span><span style="color: #008080;">13</span> <span style="color: #008000;">//</span><span style="color: #008000;">        setContentView(R.layout.tab_a);</span>
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">18</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> initLayout() {
</span><span style="color: #008080;">19</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.initLayout();
</span><span style="color: #008080;">20</span>         Logger.d(TAG, "initLayout..."<span style="color: #000000;">);
</span><span style="color: #008080;">21</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> <span style="color: #000000;">    @AIClick({R.id.tab_a_tv})
</span><span style="color: #008080;">24</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClickCallbackSample(View view) {
</span><span style="color: #008080;">25</span>         Toast.makeText(context, "clicked: " + ((TextView)view).getText() + ", " +<span style="color: #000000;"> et.getText(), Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">26</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">27</span> 
<span style="color: #008080;">28</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">29</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onResume() {
</span><span style="color: #008080;">30</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onResume();
</span><span style="color: #008080;">31</span>         Logger.d(TAG, "onResume..."<span style="color: #000000;">);
</span><span style="color: #008080;">32</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">33</span> 
<span style="color: #008080;">34</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">35</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onPause() {
</span><span style="color: #008080;">36</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onPause();
</span><span style="color: #008080;">37</span>         Logger.d(TAG, "onPause..."<span style="color: #000000;">);
</span><span style="color: #008080;">38</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">39</span> 
<span style="color: #008080;">40</span> }</pre>
</div>

代码很简单，继承AISubLayout即可，AISubLayout是AndroidInject中AndroidBucket的子类，实现了SubLayout的注解的支持。当然你也可以直接继承SubLayout，这样的话就不能使用注解了，看上面的被注释的代码，可以通过setContentView来设置对应的布局，可以通过findViewById来获取控件对象。

它也有onResume和onPause方法，当前页A被切换到B的话会调用A的onPause，然后调用B的onResume（如果之前B没有被初始化过，则先调用initLayout再调用onResume方法）

下面来看看log打印的日志：

&nbsp;

// 以下为启动应用，默认加载TabA

_05-05 08:22:32.216 1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ -----switch start-----------------------
05-05 08:22:32.216    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ switch before.........: [DelayObj{clazz=class com.wangjie.sublayouttest.TabASubLayout, delayObj=null}, DelayObj{clazz=class com.wangjie.sublayouttest.TabBSubLayout, delayObj=null}, DelayObj{clazz=class com.wangjie.sublayouttest.TabCSubLayout, delayObj=null}]
05-05 08:22:32.336    1086-1086/com.wangjie.sublayouttest D/TabASubLayout﹕ initLayout...
05-05 08:22:32.336    1086-1086/com.wangjie.sublayouttest D/TabASubLayout﹕ onResume...
05-05 08:22:32.336    1086-1086/com.wangjie.sublayouttest D/MainActivity﹕ [switch listener]switchCompleted, subLayout: com.wangjie.sublayouttest.TabASubLayout@b4dff088, position: 0
05-05 08:22:32.336    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ switch after.........: [DelayObj{clazz=class com.wangjie.sublayouttest.TabASubLayout, delayObj=com.wangjie.sublayouttest.TabASubLayout@b4dff088}, DelayObj{clazz=class com.wangjie.sublayouttest.TabBSubLayout, delayObj=null}, DelayObj{clazz=class com.wangjie.sublayouttest.TabCSubLayout, delayObj=null}]
05-05 08:22:32.336    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ -----switch end-----------------------_

_
// TabA切换到TabB
05-05 08:22:37.926    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ -----switch start-----------------------
05-05 08:22:37.926    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ switch before.........: [DelayObj{clazz=class com.wangjie.sublayouttest.TabASubLayout, delayObj=com.wangjie.sublayouttest.TabASubLayout@b4dff088}, DelayObj{clazz=class com.wangjie.sublayouttest.TabBSubLayout, delayObj=null}, DelayObj{clazz=class com.wangjie.sublayouttest.TabCSubLayout, delayObj=null}]
05-05 08:22:37.946    1086-1086/com.wangjie.sublayouttest D/TabASubLayout﹕ onPause...
05-05 08:22:37.986    1086-1086/com.wangjie.sublayouttest D/TabBSubLayout﹕ initLayout...
05-05 08:22:37.996    1086-1086/com.wangjie.sublayouttest D/TabBSubLayout﹕ onResume...
05-05 08:22:37.996    1086-1086/com.wangjie.sublayouttest D/MainActivity﹕ [switch listener]switchCompleted, subLayout: com.wangjie.sublayouttest.TabBSubLayout@b4de1d80, position: 1
05-05 08:22:37.996    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ switch after.........: [DelayObj{clazz=class com.wangjie.sublayouttest.TabASubLayout, delayObj=com.wangjie.sublayouttest.TabASubLayout@b4dff088}, DelayObj{clazz=class com.wangjie.sublayouttest.TabBSubLayout, delayObj=com.wangjie.sublayouttest.TabBSubLayout@b4de1d80}, DelayObj{clazz=class com.wangjie.sublayouttest.TabCSubLayout, delayObj=null}]
05-05 08:22:37.996    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ -----switch end-----------------------_

_
// TabB切换到TabC
05-05 08:22:41.486    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ -----switch start-----------------------
05-05 08:22:41.486    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ switch before.........: [DelayObj{clazz=class com.wangjie.sublayouttest.TabASubLayout, delayObj=com.wangjie.sublayouttest.TabASubLayout@b4dff088}, DelayObj{clazz=class com.wangjie.sublayouttest.TabBSubLayout, delayObj=com.wangjie.sublayouttest.TabBSubLayout@b4de1d80}, DelayObj{clazz=class com.wangjie.sublayouttest.TabCSubLayout, delayObj=null}]
05-05 08:22:41.496    1086-1086/com.wangjie.sublayouttest D/TabBSubLayout﹕ onPause...
05-05 08:22:41.516    1086-1086/com.wangjie.sublayouttest D/TabCSubLayout﹕ initLayout...
05-05 08:22:41.516    1086-1086/com.wangjie.sublayouttest D/TabCSubLayout﹕ onResume...
05-05 08:22:41.516    1086-1086/com.wangjie.sublayouttest D/MainActivity﹕ [switch listener]switchCompleted, subLayout: com.wangjie.sublayouttest.TabCSubLayout@b4e17840, position: 2
05-05 08:22:41.516    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ switch after.........: [DelayObj{clazz=class com.wangjie.sublayouttest.TabASubLayout, delayObj=com.wangjie.sublayouttest.TabASubLayout@b4dff088}, DelayObj{clazz=class com.wangjie.sublayouttest.TabBSubLayout, delayObj=com.wangjie.sublayouttest.TabBSubLayout@b4de1d80}, DelayObj{clazz=class com.wangjie.sublayouttest.TabCSubLayout, delayObj=com.wangjie.sublayouttest.TabCSubLayout@b4e17840}]
05-05 08:22:41.526    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ -----switch end-----------------------_

&nbsp;

_// TabC切换到TabA
05-05 08:22:44.086    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ -----switch start-----------------------
05-05 08:22:44.086    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ switch before.........: [DelayObj{clazz=class com.wangjie.sublayouttest.TabASubLayout, delayObj=com.wangjie.sublayouttest.TabASubLayout@b4dff088}, DelayObj{clazz=class com.wangjie.sublayouttest.TabBSubLayout, delayObj=com.wangjie.sublayouttest.TabBSubLayout@b4de1d80}, DelayObj{clazz=class com.wangjie.sublayouttest.TabCSubLayout, delayObj=com.wangjie.sublayouttest.TabCSubLayout@b4e17840}]
05-05 08:22:44.086    1086-1086/com.wangjie.sublayouttest D/TabCSubLayout﹕ onPause...
05-05 08:22:44.136    1086-1086/com.wangjie.sublayouttest D/TabASubLayout﹕ onResume...
05-05 08:22:44.136    1086-1086/com.wangjie.sublayouttest D/MainActivity﹕ [switch listener]switchCompleted, subLayout: com.wangjie.sublayouttest.TabASubLayout@b4dff088, position: 0
05-05 08:22:44.136    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ switch after.........: [DelayObj{clazz=class com.wangjie.sublayouttest.TabASubLayout, delayObj=com.wangjie.sublayouttest.TabASubLayout@b4dff088}, DelayObj{clazz=class com.wangjie.sublayouttest.TabBSubLayout, delayObj=com.wangjie.sublayouttest.TabBSubLayout@b4de1d80}, DelayObj{clazz=class com.wangjie.sublayouttest.TabCSubLayout, delayObj=com.wangjie.sublayouttest.TabCSubLayout@b4e17840}]
05-05 08:22:44.136    1086-1086/com.wangjie.sublayouttest D/SubLayoutManager﹕ -----switch end-----------------------

_

&nbsp;