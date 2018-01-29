---
title: '[android]AndroidInject框架——我的第一个android小型框架'
tags: []
date: 2013-12-05 11:17:00
---

作为一个移动应用开发者，随着需求的日益增多，Android项目的越来越臃肿，代码量越来越大，

现在冷静下来回头看看我们的代码，有多少代码跟业务逻辑没什么关系的

&nbsp;

所以，本人自不量力，在github上建了个开源项目，希望能一定程度地简化我的代码-。-

现在第一个版本完成，希望有兴趣的朋友能加入一起完善。

本人才疏学浅，代码中有写得不妥的地方希望大家不吝赐教哈！

**github地址：**

[https://github.com/wangjiegulu/androidInject](https://github.com/wangjiegulu/androidInject)

**androidInject_1.0.jar：**

[http://pan.baidu.com/s/1rcSiy](http://pan.baidu.com/s/1rcSiy)

&nbsp;

主要的思想就是通过注解的方式，把我们要做的事情直接注入进来给我们，&ldquo;不是我去调用对象，而是对象自己来找我&rdquo;

现在刚写完了10个注解：

@AINoTitle， @AIFullScreen， @AILayout， @AIView， @AIBean， @AISystemService， @AIClick， @AIItemClick， @AILongClick， @AIItemLongClick

使用方法如下：

Activity中使用：

<div class="cnblogs_code" onclick="cnblogs_code_show('519219a9-a150-4491-a51e-2962ccedc68e')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_519219a9-a150-4491-a51e-2962ccedc68e" class="cnblogs_code_hide">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.androidinject;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.app.AlarmManager;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.content.Intent;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.location.LocationManager;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.Bundle;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.LayoutInflater;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #0000ff;">import</span> android.widget.*<span style="color: #000000;">;
</span><span style="color: #0000ff;">import</span> com.wangjie.androidinject.annotation.annotations.*<span style="color: #000000;">;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.present.AIActivity;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.model.Person;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.ArrayList;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.HashMap;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.Map;

@AIFullScreen
@AINoTitle
@AILayout(R.layout.main)
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> AIActivity{

    @AIView(id </span>= R.id.btn1, clickMethod = "onClickCallback", longClickMethod = "onLongClickCallback"<span style="color: #000000;">)
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Button btn1;

    @AIView(clickMethod </span>= "onClickCallback", longClickMethod = "onLongClickCallback"<span style="color: #000000;">)
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Button btn2;

</span><span style="color: #008000;">//</span><span style="color: #008000;">    @AIView(id = R.id.btn3)
</span><span style="color: #008000;">//</span><span style="color: #008000;">    private Button btn3;

</span><span style="color: #008000;">//</span><span style="color: #008000;">    @AIView(id = R.id.listView, itemClickMethod = "onItemClickCallback", itemLongClickMethod = "onItemLongClickCallbackForListView")</span>
    @AIView(id =<span style="color: #000000;"> R.id.listView)
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> ListView listView;

    @AIBean
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Person person;

    @AISystemService
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> AlarmManager alarmManager;
    @AISystemService
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> LocationManager locationManager;
    @AISystemService
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> LayoutInflater inflater;

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);

        List</span>&lt;Map&lt;String, String&gt;&gt; list = <span style="color: #0000ff;">new</span> ArrayList&lt;Map&lt;String, String&gt;&gt;<span style="color: #000000;">();
        Map</span>&lt;String, String&gt;<span style="color: #000000;"> map;
        </span><span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; 10; i++<span style="color: #000000;">){
            map </span>= <span style="color: #0000ff;">new</span> HashMap&lt;String, String&gt;<span style="color: #000000;">();
            map.put(</span>"title", "item_" +<span style="color: #000000;"> i);
            list.add(map);
        }

        SimpleAdapter adapter </span>= <span style="color: #0000ff;">new</span> SimpleAdapter(context, list, R.layout.list_item, <span style="color: #0000ff;">new</span> String[]{"title"}, <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">int</span><span style="color: #000000;">[]{R.id.list_item_title_tv});
        listView.setAdapter(adapter);

        person.setName(</span>"wangjie"<span style="color: #000000;">);
        person.setAge(</span>23<span style="color: #000000;">);
        System.out.println(person.toString());

        System.out.println(</span>"alarmManager: " + alarmManager + ", locationManager: " + locationManager + ", inflater: " +<span style="color: #000000;"> inflater);

    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClickCallback(View view){
        </span><span style="color: #0000ff;">if</span>(view <span style="color: #0000ff;">instanceof</span><span style="color: #000000;"> Button){
            Toast.makeText(context, </span>"onClickCallback: " +<span style="color: #000000;"> ((Button)view).getText(), Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onLongClickCallback(View view){
        </span><span style="color: #0000ff;">if</span>(view <span style="color: #0000ff;">instanceof</span><span style="color: #000000;"> Button){
            Toast.makeText(context, </span>"onLongClickCallback: " +<span style="color: #000000;"> ((Button)view).getText(), Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onItemClickCallback(AdapterView&lt;?&gt; adapterView, View view, <span style="color: #0000ff;">int</span> i, <span style="color: #0000ff;">long</span><span style="color: #000000;"> l) {
        Toast.makeText(context, </span>"onItemClickCallback: " + ((Map&lt;String, String&gt;)adapterView.getAdapter().getItem(i)).get("title"<span style="color: #000000;">), Toast.LENGTH_SHORT).show();
    }

    @AIClick({R.id.btn3, R.id.toFragmentBtn})
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClickCallbackForBtn3(View view){
        </span><span style="color: #0000ff;">if</span>(view <span style="color: #0000ff;">instanceof</span><span style="color: #000000;"> Button){
            Toast.makeText(context, </span>"onClickForBtn3: " +<span style="color: #000000;"> ((Button)view).getText(), Toast.LENGTH_SHORT).show();
        }

        </span><span style="color: #0000ff;">if</span>(view.getId() ==<span style="color: #000000;"> R.id.toFragmentBtn){
            startActivity(</span><span style="color: #0000ff;">new</span> Intent(context, SecendActivity.<span style="color: #0000ff;">class</span><span style="color: #000000;">));
        }

    }

    @AILongClick({R.id.btn3})
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onLongClickCallbackForBtn3(View view){
        </span><span style="color: #0000ff;">if</span>(view <span style="color: #0000ff;">instanceof</span><span style="color: #000000;"> Button){
            Toast.makeText(context, </span>"onLongClickCallbackForBtn3: " +<span style="color: #000000;"> ((Button)view).getText(), Toast.LENGTH_SHORT).show();
        }
    }

    @AIItemClick({R.id.listView})
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onItemClickCallbackForListView(AdapterView&lt;?&gt; adapterView, View view, <span style="color: #0000ff;">int</span> i, <span style="color: #0000ff;">long</span><span style="color: #000000;"> l){
        Toast.makeText(context, </span>"onItemClickCallbackForListView: " + ((Map&lt;String, String&gt;)adapterView.getAdapter().getItem(i)).get("title"<span style="color: #000000;">), Toast.LENGTH_SHORT).show();
    }

    @AIItemLongClick(R.id.listView)
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span> onItemLongClickCallbackForListView(AdapterView&lt;?&gt; adapterView, View view, <span style="color: #0000ff;">int</span> i, <span style="color: #0000ff;">long</span><span style="color: #000000;"> l) {
        Toast.makeText(context, </span>"onItemLongClickCallbackForListView: " + ((Map&lt;String, String&gt;)adapterView.getAdapter().getItem(i)).get("title"<span style="color: #000000;">), Toast.LENGTH_SHORT).show();
        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
    }

}</span></pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

Fragment中使用：

<div class="cnblogs_code" onclick="cnblogs_code_show('456512ad-1927-42c5-b337-ab7c6067fadc')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_456512ad-1927-42c5-b337-ab7c6067fadc" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.androidinject;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.app.AlarmManager;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.os.Bundle;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.View;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span> android.widget.*<span style="color: #000000;">;
</span><span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span> com.wangjie.androidinject.annotation.annotations.*<span style="color: #000000;">;
</span><span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.present.AISupportFragment;
</span><span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.model.Person;
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.ArrayList;
</span><span style="color: #008080;">12</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.HashMap;
</span><span style="color: #008080;">13</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;
</span><span style="color: #008080;">14</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.Map;
</span><span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">17</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;">18</span> <span style="color: #008000;"> * Author: wangjie  email:wangjie@cyyun.com
</span><span style="color: #008080;">19</span> <span style="color: #008000;"> * Date: 13-12-4
</span><span style="color: #008080;">20</span> <span style="color: #008000;"> * Time: 下午4:37
</span><span style="color: #008080;">21</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">22</span> <span style="color: #000000;">@AILayout(R.layout.fragment_a)
</span><span style="color: #008080;">23</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> FragmentA <span style="color: #0000ff;">extends</span><span style="color: #000000;"> AISupportFragment{
</span><span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span> <span style="color: #000000;">    @AIView
</span><span style="color: #008080;">26</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Button fragmentABtn1;
</span><span style="color: #008080;">27</span> 
<span style="color: #008080;">28</span> <span style="color: #000000;">    @AIView
</span><span style="color: #008080;">29</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> GridView fragmentGv;
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span> <span style="color: #000000;">    @AIBean
</span><span style="color: #008080;">32</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Person person;
</span><span style="color: #008080;">33</span> 
<span style="color: #008080;">34</span> <span style="color: #000000;">    @AISystemService
</span><span style="color: #008080;">35</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> AlarmManager alarmManager;
</span><span style="color: #008080;">36</span> 
<span style="color: #008080;">37</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">38</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onActivityCreated(Bundle savedInstanceState) {
</span><span style="color: #008080;">39</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onActivityCreated(savedInstanceState);
</span><span style="color: #008080;">40</span> 
<span style="color: #008080;">41</span>         List&lt;Map&lt;String, String&gt;&gt; list = <span style="color: #0000ff;">new</span> ArrayList&lt;Map&lt;String, String&gt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">42</span>         Map&lt;String, String&gt;<span style="color: #000000;"> map;
</span><span style="color: #008080;">43</span>         <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; 10; i++<span style="color: #000000;">){
</span><span style="color: #008080;">44</span>             map = <span style="color: #0000ff;">new</span> HashMap&lt;String, String&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">45</span>             map.put("title", "fragment_item_" +<span style="color: #000000;"> i);
</span><span style="color: #008080;">46</span> <span style="color: #000000;">            list.add(map);
</span><span style="color: #008080;">47</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">48</span> 
<span style="color: #008080;">49</span>         SimpleAdapter adapter = <span style="color: #0000ff;">new</span> SimpleAdapter(context, list, R.layout.list_item, <span style="color: #0000ff;">new</span> String[]{"title"}, <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">int</span><span style="color: #000000;">[]{R.id.list_item_title_tv});
</span><span style="color: #008080;">50</span> <span style="color: #000000;">        fragmentGv.setAdapter(adapter);
</span><span style="color: #008080;">51</span> 
<span style="color: #008080;">52</span>         person.setName("androidInject"<span style="color: #000000;">);
</span><span style="color: #008080;">53</span>         person.setAge(1<span style="color: #000000;">);
</span><span style="color: #008080;">54</span> <span style="color: #000000;">        System.out.println(person.toString());
</span><span style="color: #008080;">55</span> 
<span style="color: #008080;">56</span>         System.out.println("alarmManager: " +<span style="color: #000000;"> alarmManager);
</span><span style="color: #008080;">57</span> 
<span style="color: #008080;">58</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">59</span> 
<span style="color: #008080;">60</span> <span style="color: #000000;">    @AIClick(R.id.fragmentABtn1)
</span><span style="color: #008080;">61</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> btnOnclick(View view){
</span><span style="color: #008080;">62</span>         <span style="color: #0000ff;">if</span>(view <span style="color: #0000ff;">instanceof</span><span style="color: #000000;"> Button){
</span><span style="color: #008080;">63</span>             Toast.makeText(context, "btnOnclick: " +<span style="color: #000000;"> ((Button)view).getText(), Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">64</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">65</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">66</span> 
<span style="color: #008080;">67</span> <span style="color: #000000;">    @AILongClick(R.id.fragmentABtn1)
</span><span style="color: #008080;">68</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> btnOnLongClick(View view){
</span><span style="color: #008080;">69</span>         <span style="color: #0000ff;">if</span>(view <span style="color: #0000ff;">instanceof</span><span style="color: #000000;"> Button){
</span><span style="color: #008080;">70</span>             Toast.makeText(context, "btnOnLongClick: " +<span style="color: #000000;"> ((Button)view).getText(), Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">71</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">72</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">73</span> 
<span style="color: #008080;">74</span> <span style="color: #000000;">    @AIItemClick(R.id.fragmentGv)
</span><span style="color: #008080;">75</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> gvOnItemClick(AdapterView&lt;?&gt; adapterView, View view, <span style="color: #0000ff;">int</span> i, <span style="color: #0000ff;">long</span><span style="color: #000000;"> l){
</span><span style="color: #008080;">76</span>         Toast.makeText(context, "gvOnItemClick: " + ((Map&lt;String, String&gt;)adapterView.getAdapter().getItem(i)).get("title"<span style="color: #000000;">), Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">77</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">78</span> 
<span style="color: #008080;">79</span> <span style="color: #000000;">    @AIItemLongClick(R.id.fragmentGv)
</span><span style="color: #008080;">80</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> gvOnItemLongClick(AdapterView&lt;?&gt; adapterView, View view, <span style="color: #0000ff;">int</span> i, <span style="color: #0000ff;">long</span><span style="color: #000000;"> l){
</span><span style="color: #008080;">81</span>         Toast.makeText(context, "gvOnItemLongClick: " + ((Map&lt;String, String&gt;)adapterView.getAdapter().getItem(i)).get("title"<span style="color: #000000;">), Toast.LENGTH_SHORT).show();
</span><span style="color: #008080;">82</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">83</span> 
<span style="color: #008080;">84</span> 
<span style="color: #008080;">85</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

&nbsp;

具体注解如下：

@AINoTitle: 类注解, 只适用于Activity(需继承于AIActivity), 设置Activity不显示Title

@AIFullScreen: 类注解, 只适用于Activity(需继承于AIActivity), 设置Activity全屏

 @AILayout: 类注解
            value[int]: 用于设置该Activity的布局 ---- setContentView(resId);

        @AIView: 属性注解
            id[int]: 用于绑定控件 ---- findViewById(resId);(default identifier[R.id.{field name}] if did not set id)
            clickMethod[String]: 用于设置控件点击事件的回调方法, 可选, 方法名称任意, 参数必须为(View view)
            longClickMethod[String]: 用于设置控件长按的回调方法, 可选, 方法名任意, 参数必须为(View view)
            itemClickMethod[String]: 用于设置控件item点击的回调方法, 可选, 方法名任意, 参数必须为(AdapterView, View, int, long)
            itemLongClickMethod[String]: 用于设置控件item长按的回调方法, 可选, 方法名任意, 参数必须为(AdapterView, View, int, long)

        @AIBean: 属性注解, 为该属性生成一个对象并注入, 该对象必须有个默认的不带参数的构造方法

        @AISystemService: 属性注解，为该属性注入系统服务对象

        @AIClick: 方法注解
            value[int[], 所要绑定控件的id]: 用于绑定控件点击事件的回调方法, 方法名称任意, 参数必须为(View view)

        @AIItemClick: 方法注解
            value[int[], 所要绑定控件的id]: 用于绑定控件item点击事件的回调方法, 方法名称任意, 参数必须为(AdapterView, View, int, long)

        @AILongClick: 方法注解
            value[int[], 所要绑定控件的id]: 用于绑定控件长按事件的回调方法, 方法名称任意, 参数必须为(View view)

        @AIItemLongClick: 方法注解
            value[int[], 所要绑定控件的id]: 用于绑定控件item长按事件的回调方法, 方法名称任意, 参数必须为(AdapterView, View, int, long)

&nbsp;

&nbsp;

&nbsp;