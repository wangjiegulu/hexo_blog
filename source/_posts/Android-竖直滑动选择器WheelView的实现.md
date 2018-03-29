---
title: '[Android]竖直滑动选择器WheelView的实现'
tags: [android, WheelView, github, library]
date: 2014-07-01 23:37:00
---


公司项目中有这么一个需求，所以需要自己实现下。效果类似android4.0以上原生的DatePicker这种。

这个WheelView控件我已经放在github上了，大家有兴趣可以看看，地址：[https://github.com/wangjiegulu/WheelView](https://github.com/wangjiegulu/WheelView)，欢迎Star或者Fork哦！（建库的时候忘了选ignore了－－，所以有些gen什么的直接无视掉，我也懒得改了－－）

&nbsp;

先贴上效果图：

![](http://images.cnitblog.com/i/378300/201407/012249013099471.png)&nbsp;![](http://images.cnitblog.com/i/378300/201407/012249532936951.png)&nbsp;![](http://images.cnitblog.com/i/378300/201407/012251028875647.png)

&nbsp;

讲下思路吧，因为这是一个滚动选择器，所以首先想到的是可以基于ListView或者ScrollView自定义。

刚开始我用的是继承ListView来实现，把滑动选择的每个item作为listview中的一个item，然后根据FirstVisiblePosition、LastVisiblePosition来判断某个item是否在选中的区域，但是后来发现偶尔有时候调用getFirstVisiblePosition和getLastVisiblePosition的结果跟我看到的界面显示的item并不一致（我是在Adapter中调用的这两个方法），后来分析可能是因为我调用了scrollTo后没有刷新adapter的原因吧。

再后来，就打算使用ScrollView来实现了，其中的每个item都是一个View（我这里使用了TextView）。因为这个选中框是在中间的位置，所以刚启动时第一个item应该需要在中间选中框显示，所以前面应该使用空白补全。最后一个也是如此，后面也需要空白补全。

在滑动过程中需要实现这种场景：滑动结束后，必须且只有一个item完整显示在选择框中。所以我们必须要监听滚动停止的事件，然后在滚动停止后判断是不是满足前面的场景，如果没有，则需要代码中实现滚动到正确位置。但是，蛋疼的是，sdk中竟然没有提供原生的监听滚动停止的api，然后在网上找了很久，得到的结果是只能另辟蹊径，使用了[stackoverflow](http://stackoverflow.com/questions/8181828/android-detect-when-scrollview-stops-scrolling/10198865#10198865)一个网友的做法通过主动检测是否停止滚动的方法去实现（总觉得方法有点坑，额 好吧 但是暂时先用了这个方法）。

思路就讲到这里了。

&nbsp;

使用方式：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 7/1/14.
 </span><span style="color: #008000;">*/</span><span style="color: #000000;">
@AILayout(R.layout.main)
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> AIActivity {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = MainActivity.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();

    </span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String[] PLANETS = <span style="color: #0000ff;">new</span> String[]{"Mercury", "Venus", "Earth", "Mars", "Jupiter", "Uranus", "Neptune", "Pluto"<span style="color: #000000;">};

    @AIView(R.id.main_wv)
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> WheelView wva;

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);

        wva.setOffset(</span>1<span style="color: #000000;">);
        wva.setItems(Arrays.asList(PLANETS));
        wva.setOnWheelViewListener(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> WheelView.OnWheelViewListener() {
            @Override
            </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onSelected(<span style="color: #0000ff;">int</span><span style="color: #000000;"> selectedIndex, String item) {
                Logger.d(TAG, </span>"selectedIndex: " + selectedIndex + ", item: " +<span style="color: #000000;"> item);
            }
        });

    }

    @AIClick({R.id.main_show_dialog_btn})
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClickCallbackSample(View view) {
        </span><span style="color: #0000ff;">switch</span><span style="color: #000000;"> (view.getId()) {
            </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.main_show_dialog_btn:
                View outerView </span>= LayoutInflater.from(context).inflate(R.layout.wheel_view, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
                WheelView wv </span>=<span style="color: #000000;"> (WheelView) outerView.findViewById(R.id.wheel_view_wv);
                wv.setOffset(</span>2<span style="color: #000000;">);
                wv.setItems(Arrays.asList(PLANETS));
                wv.setSeletion(</span>3<span style="color: #000000;">);
                wv.setOnWheelViewListener(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> WheelView.OnWheelViewListener() {
                    @Override
                    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onSelected(<span style="color: #0000ff;">int</span><span style="color: #000000;"> selectedIndex, String item) {
                        Logger.d(TAG, </span>"[Dialog]selectedIndex: " + selectedIndex + ", item: " +<span style="color: #000000;"> item);
                    }
                });

                </span><span style="color: #0000ff;">new</span><span style="color: #000000;"> AlertDialog.Builder(context)
                        .setTitle(</span>"WheelView in Dialog"<span style="color: #000000;">)
                        .setView(outerView)
                        .setPositiveButton(</span>"OK", <span style="color: #0000ff;">null</span><span style="color: #000000;">)
                        .show();

                </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;
        }
    }

}</span></pre>
</div>

&nbsp;

注意：这个Demo只是一个临时解决方案，比较适合选项较少的时候使用，比如选择性别、星期等。因为里面的买个item都是一个单独的View，并没有去实现View的缓存和重用，所以大家这点需要注意下。如果有时间我会完善优化这个代码，实现View的复用。关于View的复用，大家可以fork后自己尝试改写，我讲下主要的思路（我的思路，当然不能代表是最优的方案）是：假设，每页显示5个item以供选择，那么刚开始加载时，先生成6个item，其中6个是正常的6个选项所new出来的item，注意！因为每页显示5个item，所以第6个item不可见，但是却已经new出来了，其实可以正常显示。然后往下滚动时，监听滚动事件，第6个完全显示时，这个时候第一个item已经不可见了，所以可以重用该item的view。所以如果往下滚要显示第7个item时，重用第一个item的view，作为第7个item的view显示数据。再往下也是一样。总之，重用当前不可见的item的view给即将显示的item。

&nbsp;

注意：项目使用到了一部分注解、日志方面的东西，跟实现WheelView没关系，但是可以简化代码，提高编码效率

AndroidInject：[https://github.com/wangjiegulu/androidInject](https://github.com/wangjiegulu/androidInject)

AndroidBucket：[https://github.com/wangjiegulu/AndroidBucket](https://github.com/wangjiegulu/AndroidBucket)

&nbsp;

&nbsp;

