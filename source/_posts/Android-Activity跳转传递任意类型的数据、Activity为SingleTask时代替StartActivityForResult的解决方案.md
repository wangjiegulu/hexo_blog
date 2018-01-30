---
title: '[Android]Activity跳转传递任意类型的数据、Activity为SingleTask时代替StartActivityForResult的解决方案'
tags: [android, activity, launch mode]
date: 2015-04-03 12:15:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span style="color: #ff0000;">**来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/4389674.html](http://www.cnblogs.com/tiantianbyconan/p/4389674.html "view: [Android]Activity跳转传递任意类型的数据、Activity为SingleTask时代替StartActivity的解决方案")[<span style="color: #ff0000;">
</span>](http://www.cnblogs.com/tiantianbyconan/p/4388175.html%20)**</span>

&nbsp;

需求：在ActivityA跳转到ActivityB，然后在ActivityB操作完返回数据给ActivityA。

这个很普遍的需求，一般情况是使用startActivityForResult的方式去完成。

但是当ActivityB为SingleTask时，这个方式就无效了。你会发现当你执行startActivityForResult后，onActivityResult方法马上就会被回调。至于为什么会出现这种情况，参考这位老兄的文章就可以理解[http://blog.csdn.net/sodino/article/details/22101881](http://blog.csdn.net/sodino/article/details/22101881)。

解决这种情况的方法，第一种是把ActivityA也设置为SingleTask，然后在ActivityB中startActivity(context, ActivityA.class)，然后ActivityA在onNewIntent(Intent intent)方法中去获取传递数据，这样的方式不仅破坏了ActivityA的lauchMode，而且还需要ActivityB中启动指定的ActivityA。

所以，如果能把ActivityA的当前对象（实现某个接口）传到ActivityB中，然后ActivityB中通过接口直接回调那就解决问题了。

但是问题是怎么把当前对象传过去，使用Intent显然不行。

思路是维护一个StoragePool，里面可以暂存需要传递的数据。相当于一个暂存区，ActivityA跳转前，把数据放入这个暂存区，获得一个唯一标识，然后把这个唯一标识使用Intent的方式传递给ActivityB，然后ActivityB拿到这个唯一标识后去暂存区去取数据就好了。

暂存区StoragePool代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 3/30/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> StoragePool {
</span><span style="color: #008080;"> 7</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 8</span> <span style="color: #008000;">     * key   -- 标识是哪一个intent的（UUID）
</span><span style="color: #008080;"> 9</span> <span style="color: #008000;">     *
</span><span style="color: #008080;">10</span> <span style="color: #008000;">     *         |- key -- 存储的对象标识（StorageKey，使用UUID唯一）
</span><span style="color: #008080;">11</span> <span style="color: #008000;">     * value --|
</span><span style="color: #008080;">12</span> <span style="color: #008000;">     *         |- value -- 存储的内容
</span><span style="color: #008080;">13</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">14</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> ConcurrentHashMap&lt;String, HashMap&lt;StorageKey, WeakReference&lt;Object&gt;&gt;&gt; storageMapper = <span style="color: #0000ff;">new</span> ConcurrentHashMap&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> StoragePool() {
</span><span style="color: #008080;">17</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> storage(String tagUUID, StorageKey key, Object content) {
</span><span style="color: #008080;">20</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> == key || <span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> content) {
</span><span style="color: #008080;">21</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">22</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">23</span>         HashMap&lt;StorageKey, WeakReference&lt;Object&gt;&gt; extraMapper =<span style="color: #000000;"> storageMapper.get(tagUUID);
</span><span style="color: #008080;">24</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> extraMapper) {
</span><span style="color: #008080;">25</span>             extraMapper = <span style="color: #0000ff;">new</span> HashMap&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">26</span> <span style="color: #000000;">            storageMapper.put(tagUUID, extraMapper);
</span><span style="color: #008080;">27</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">28</span>         extraMapper.put(key, <span style="color: #0000ff;">new</span> WeakReference&lt;&gt;<span style="color: #000000;">(content));
</span><span style="color: #008080;">29</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> Object remove(String tagUUID, StorageKey key) {
</span><span style="color: #008080;">32</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> key) {
</span><span style="color: #008080;">33</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">34</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">35</span>         HashMap&lt;StorageKey, WeakReference&lt;Object&gt;&gt; extraMapper =<span style="color: #000000;"> storageMapper.get(tagUUID);
</span><span style="color: #008080;">36</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> extraMapper) {
</span><span style="color: #008080;">37</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">38</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">39</span> 
<span style="color: #008080;">40</span>         WeakReference&lt;Object&gt; ref =<span style="color: #000000;"> extraMapper.remove(key);
</span><span style="color: #008080;">41</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;"> (ABTextUtil.isEmpty(extraMapper)) {
</span><span style="color: #008080;">42</span> <span style="color: #000000;">            storageMapper.remove(tagUUID);
</span><span style="color: #008080;">43</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">44</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span> == ref ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : ref.get();
</span><span style="color: #008080;">45</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> HashMap&lt;StorageKey, WeakReference&lt;Object&gt;&gt;<span style="color: #000000;"> remove(String tagUUID) {
</span><span style="color: #008080;">48</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> tagUUID) {
</span><span style="color: #008080;">49</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">50</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">51</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> storageMapper.remove(tagUUID);
</span><span style="color: #008080;">52</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">53</span> 
<span style="color: #008080;">54</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> clear() {
</span><span style="color: #008080;">55</span> <span style="color: #000000;">        storageMapper.clear();
</span><span style="color: #008080;">56</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">57</span> 
<span style="color: #008080;">58</span> }</pre>
</div>

如上代码，StoragePool维护了一个HashMap，key是一个UUID，代表唯一的一个Intent跳转，ActivityA跳转时会把这个UUID传递到ActivityB，ActivityB就是通过这个UUID来获取这次跳转需要传递的数据的。value也是一个HashMap，里面存储了某次跳转传递的所有数据。key是StorageKey，实质上也是一个UUID，value是任意的数据。

跳转前的存储数据和真正的StartActivity都需要使用StorageIntentCenter来进行操作，代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 3/31/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> StorageIntentCenter {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String STORAGE_INTENT_CENTER_KEY_UUID = StorageIntentCenter.<span style="color: #0000ff;">class</span>.getSimpleName() + "_UUID"<span style="color: #000000;">;
</span><span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = StorageIntentCenter.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Intent intent;
</span><span style="color: #008080;">11</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String uuid;
</span><span style="color: #008080;">12</span>     <span style="color: #0000ff;">private</span> HashMap&lt;StorageKey, Object&gt;<span style="color: #000000;"> extras;
</span><span style="color: #008080;">13</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isUsed;
</span><span style="color: #008080;">14</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> StorageIntentCenter() {
</span><span style="color: #008080;">15</span>         intent = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Intent();
</span><span style="color: #008080;">16</span>         uuid =<span style="color: #000000;"> java.util.UUID.randomUUID().toString();
</span><span style="color: #008080;">17</span> <span style="color: #000000;">        intent.putExtra(STORAGE_INTENT_CENTER_KEY_UUID, uuid);
</span><span style="color: #008080;">18</span>         isUsed = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">19</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> StorageIntentCenter putExtra(String intentKey, Object content){
</span><span style="color: #008080;">22</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> content) {
</span><span style="color: #008080;">23</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;">24</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">25</span>         StorageKey storageKey = <span style="color: #0000ff;">new</span><span style="color: #000000;"> StorageKey(content.getClass());
</span><span style="color: #008080;">26</span> <span style="color: #000000;">        intent.putExtra(intentKey, storageKey);
</span><span style="color: #008080;">27</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> extras){
</span><span style="color: #008080;">28</span>             extras = <span style="color: #0000ff;">new</span> HashMap&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">29</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">30</span> <span style="color: #000000;">        extras.put(storageKey, content);
</span><span style="color: #008080;">31</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;">32</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">33</span> 
<span style="color: #008080;">34</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> startActivity(Context packageContext, Class&lt;?&gt;<span style="color: #000000;"> cls){
</span><span style="color: #008080;">35</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;">(isUsed){
</span><span style="color: #008080;">36</span>             Logger.e(TAG, <span style="color: #0000ff;">this</span> + " can not be reuse!"<span style="color: #000000;">);
</span><span style="color: #008080;">37</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">38</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">39</span> <span style="color: #000000;">        intent.setClass(packageContext, cls);
</span><span style="color: #008080;">40</span>         <span style="color: #0000ff;">if</span>(!<span style="color: #000000;">ABTextUtil.isEmpty(extras)){
</span><span style="color: #008080;">41</span>             Set&lt;Map.Entry&lt;StorageKey, Object&gt;&gt; entrySet =<span style="color: #000000;"> extras.entrySet();
</span><span style="color: #008080;">42</span>             <span style="color: #0000ff;">for</span>(Map.Entry&lt;StorageKey, Object&gt;<span style="color: #000000;"> entry : entrySet){
</span><span style="color: #008080;">43</span> <span style="color: #000000;">                StoragePool.storage(uuid, entry.getKey(), entry.getValue());
</span><span style="color: #008080;">44</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">45</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">46</span>         isUsed = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">47</span> <span style="color: #000000;">        packageContext.startActivity(intent);
</span><span style="color: #008080;">48</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">49</span> 
<span style="color: #008080;">50</span> 
<span style="color: #008080;">51</span> }</pre>
</div>

每个StorageIntentCenter都维护了一个真正跳转的Intent，一个此次跳转的uuid和所有需要传递的数据。

&nbsp;

使用方式（以从MainActivity跳转到OtherActivity为例）：

MainActivity中：

<div class="cnblogs_code">
<pre><span style="color: #000000;">@AILayout(R.layout.main)
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span> BaseActivity <span style="color: #0000ff;">implements</span><span style="color: #000000;"> ICommunicate {

    </span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = MainActivity.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();

    @Override
    @AIClick({R.id.ac_test_a_btn})
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClickCallbackSample(View view) {
        </span><span style="color: #0000ff;">switch</span><span style="color: #000000;"> (view.getId()) {
            </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.ac_test_a_btn:
                </span><span style="color: #0000ff;">new</span><span style="color: #000000;"> StorageIntentCenter()
                        .putExtra(</span>"iCommunicate", <span style="color: #0000ff;">this</span><span style="color: #000000;">)
                        .putExtra(</span>"testString", "hello world"<span style="color: #000000;">)
                        .putExtra(</span>"testFloat", 3.2f<span style="color: #000000;">)
                        .startActivity(context, OtherActivity.</span><span style="color: #0000ff;">class</span><span style="color: #000000;">);

                </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;
        }
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> hello(String content) {
        Logger.d(TAG, </span>"hello received: " +<span style="color: #000000;"> content);
    }

}</span></pre>
</div>

&nbsp;

OtherActivity继承了BaseActivity。

BaseActivity：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 4/2/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> BaseActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> AIActivity {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String storageIntentCenterUUID;
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">10</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
</span><span style="color: #008080;">11</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
</span><span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> <span style="color: #000000;">        initExtraFromStorage();
</span><span style="color: #008080;">14</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> remove extra from StoragePool</span>
<span style="color: #008080;">15</span> <span style="color: #000000;">        StoragePool.remove(storageIntentCenterUUID);
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> initExtraFromStorage() {
</span><span style="color: #008080;">19</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">final</span> &lt;T&gt; T getExtraFromStorage(String key, Class&lt;T&gt;<span style="color: #000000;"> contentType) {
</span><span style="color: #008080;">22</span>         StorageKey storageKey =<span style="color: #000000;"> (StorageKey) getIntent().getSerializableExtra(key);
</span><span style="color: #008080;">23</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> storageIntentCenterUUID) {
</span><span style="color: #008080;">24</span>             storageIntentCenterUUID =<span style="color: #000000;"> getIntent().getStringExtra(StorageIntentCenter.STORAGE_INTENT_CENTER_KEY_UUID);
</span><span style="color: #008080;">25</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">26</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> (T) StoragePool.remove(storageIntentCenterUUID, storageKey);
</span><span style="color: #008080;">27</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> }</pre>
</div>

Line15：为了防止跳转到OtherActivity后，如果没有去暂存区把数据取出来从而导致暂存区有无用的数据（甚至内存泄漏，暂存区使用软引用也是为了防止这种情况的发生），所以这里提供一个initExtraFromStorage方法让子类重写，子类可以在这个方法中去把数据取出来。然后在initExtraFromStorage方法执行完毕后，再及时把暂存区的数据删除。

Line21～27:这里提供了从暂存区提取数据的方法供子类调用。

&nbsp;

OtherActivity：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 4/2/15.
 </span><span style="color: #008000;">*/</span><span style="color: #000000;">
@AILayout(R.layout.other)
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> OtherActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> BaseActivity{
    </span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = OtherActivity.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();

    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> ICommunicate iCommunicate;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> String testString;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Float testFloat;

    @Override
    </span><span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
    }

    @Override
    </span><span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> initExtraFromStorage() {
        iCommunicate </span>= getExtraFromStorage("iCommunicate", ICommunicate.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
        testString </span>= getExtraFromStorage("testString", String.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
        testFloat </span>= getExtraFromStorage("testFloat", Float.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
    }

    @Override
    @AIClick({R.id.other_btn})
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onClickCallbackSample(View view) {
        </span><span style="color: #0000ff;">switch</span><span style="color: #000000;">(view.getId()){
            </span><span style="color: #0000ff;">case</span><span style="color: #000000;"> R.id.other_btn:
                </span><span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> iCommunicate){
                    </span><span style="color: #0000ff;">return</span><span style="color: #000000;">;
                }
                Logger.d(TAG, </span>"iCommunicate: " +<span style="color: #000000;"> iCommunicate);
                iCommunicate.hello(</span>"content from ACTestBActivity!"<span style="color: #000000;">);

                Logger.d(TAG, </span>"testString: " +<span style="color: #000000;"> testString);
                Logger.d(TAG, </span>"testFloat: " +<span style="color: #000000;"> testFloat);
                finish();

                </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;
        }
    }
}</span></pre>
</div>

如上代码OtherActivity中获取了从MainActivity中传递过来的MainActivity实例，在点击事件发生后通过MainActivity实例进行直接回调。

日志打印如下：

<div class="cnblogs_code">
<pre>04-03 12:09:52.184  25529-25529/com.wangjie.androidstorageintent D/<span style="color: #000000;">OtherActivity﹕ iCommunicate: com.wangjie.androidstorageintent.sample.MainActivity@42879ff8
</span>04-03 12:09:52.184  25529-25529/com.wangjie.androidstorageintent D/MainActivity﹕ hello received: content from ACTestBActivity!
04-03 12:09:52.184  25529-25529/com.wangjie.androidstorageintent D/<span style="color: #000000;">OtherActivity﹕ testString: hello world
</span>04-03 12:09:52.184  25529-25529/com.wangjie.androidstorageintent D/OtherActivity﹕ testFloat: 3.2</pre>
</div>

MainActivity被回调，并获取了数据&ldquo;content from ACTestBActivity!&rdquo;字符串。

&nbsp;

<span style="color: #ff0000;">**注：**</span>

<span style="color: #ff0000;">**1\. 以上使用的代码已托管到github：[<span style="color: #ff0000;">https://github.com/wangjiegulu/AndroidStorageIntent</span>](https://github.com/wangjiegulu/AndroidStorageIntent)**</span>

<span style="color: #ff0000;">**2\. 上面的注解实现使用AndroidInject：[<span style="color: #ff0000;">https://github.com/wangjiegulu/androidInject</span>](https://github.com/wangjiegulu/androidInject)**</span>

&nbsp;

