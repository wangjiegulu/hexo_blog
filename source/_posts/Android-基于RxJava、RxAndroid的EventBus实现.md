---
title: '[Android]基于RxJava、RxAndroid的EventBus实现'
tags: []
date: 2015-06-15 17:09:00
---

**以下内容为原创，欢迎转载，转载请注明**

**<span style="color: #ff0000;">来自天天博客：[<span style="color: #ff0000;">http://www.cnblogs.com/tiantianbyconan/p/4578699.html</span>](http://www.cnblogs.com/tiantianbyconan/p/4578699.html%20 "view: [Android]基于RxJava、RxAndroid的EventBus实现")</span>&nbsp;**

&nbsp;

**<span style="line-height: 1.5;">Github：[https://github.com/wangjiegulu/RxAndroidEventsSample](https://github.com/wangjiegulu/RxAndroidEventsSample)</span>**

EventBus的作用是发布/订阅事件总线，因为项目中用到RxJava、RxAndroid，所以完全可以使用RxJava、RxAndroid来实现EventBus。

&nbsp;

1\. 编写RxBus，用于存储所有事件Subjects。

事件是传递的最小单位，可以把任何类作为一个事件。

RxBus代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 6/11/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> RxBus {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = RxBus.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> RxBus instance;
</span><span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">boolean</span> DEBUG = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">synchronized</span><span style="color: #000000;"> RxBus get() {
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> instance) {
</span><span style="color: #008080;">13</span>             instance = <span style="color: #0000ff;">new</span><span style="color: #000000;"> RxBus();
</span><span style="color: #008080;">14</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">15</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> instance;
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> RxBus() {
</span><span style="color: #008080;">19</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">private</span> ConcurrentHashMap&lt;Object, List&lt;Subject&gt;&gt; subjectMapper = <span style="color: #0000ff;">new</span> ConcurrentHashMap&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span>     @SuppressWarnings("unchecked"<span style="color: #000000;">)
</span><span style="color: #008080;">24</span>     <span style="color: #0000ff;">public</span> &lt;T&gt; Observable&lt;T&gt; register(@NonNull Object tag, @NonNull Class&lt;T&gt;<span style="color: #000000;"> clazz) {
</span><span style="color: #008080;">25</span>         List&lt;Subject&gt; subjectList =<span style="color: #000000;"> subjectMapper.get(tag);
</span><span style="color: #008080;">26</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> subjectList) {
</span><span style="color: #008080;">27</span>             subjectList = <span style="color: #0000ff;">new</span> ArrayList&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">28</span> <span style="color: #000000;">            subjectMapper.put(tag, subjectList);
</span><span style="color: #008080;">29</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span>         Subject&lt;T, T&gt;<span style="color: #000000;"> subject;
</span><span style="color: #008080;">32</span>         subjectList.add(subject =<span style="color: #000000;"> PublishSubject.create());
</span><span style="color: #008080;">33</span>         <span style="color: #0000ff;">if</span> (DEBUG) Log.d(TAG, "[register]subjectMapper: " +<span style="color: #000000;"> subjectMapper);
</span><span style="color: #008080;">34</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> subject;
</span><span style="color: #008080;">35</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">36</span> 
<span style="color: #008080;">37</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> unregister(@NonNull Object tag, @NonNull Observable observable) {
</span><span style="color: #008080;">38</span>         List&lt;Subject&gt; subjects =<span style="color: #000000;"> subjectMapper.get(tag);
</span><span style="color: #008080;">39</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> subjects) {
</span><span style="color: #008080;">40</span> <span style="color: #000000;">            subjects.remove((Subject) observable);
</span><span style="color: #008080;">41</span>             <span style="color: #0000ff;">if</span><span style="color: #000000;"> (ABTextUtil.isEmpty(subjects)) {
</span><span style="color: #008080;">42</span> <span style="color: #000000;">                subjectMapper.remove(tag);
</span><span style="color: #008080;">43</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">44</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">45</span> 
<span style="color: #008080;">46</span>         <span style="color: #0000ff;">if</span> (DEBUG) Log.d(TAG, "[unregister]subjectMapper: " +<span style="color: #000000;"> subjectMapper);
</span><span style="color: #008080;">47</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">48</span> 
<span style="color: #008080;">49</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> post(@NonNull Object content) {
</span><span style="color: #008080;">50</span> <span style="color: #000000;">        post(content.getClass().getName(), content);
</span><span style="color: #008080;">51</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">52</span> 
<span style="color: #008080;">53</span>     @SuppressWarnings("unchecked"<span style="color: #000000;">)
</span><span style="color: #008080;">54</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> post(@NonNull Object tag, @NonNull Object content) {
</span><span style="color: #008080;">55</span>         List&lt;Subject&gt; subjectList =<span style="color: #000000;"> subjectMapper.get(tag);
</span><span style="color: #008080;">56</span> 
<span style="color: #008080;">57</span>         <span style="color: #0000ff;">if</span> (!<span style="color: #000000;">ABTextUtil.isEmpty(subjectList)) {
</span><span style="color: #008080;">58</span>             <span style="color: #0000ff;">for</span><span style="color: #000000;"> (Subject subject : subjectList) {
</span><span style="color: #008080;">59</span> <span style="color: #000000;">                subject.onNext(content);
</span><span style="color: #008080;">60</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">61</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">62</span>         <span style="color: #0000ff;">if</span> (DEBUG) Log.d(TAG, "[send]subjectMapper: " +<span style="color: #000000;"> subjectMapper);
</span><span style="color: #008080;">63</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">64</span> }</pre>
</div>

如上述代码，RxBus只提供了register、unregister、post三个方法。

这里又加入了一个tag的概念，也可以理解为channel，注册Subject、反注册Subject和post事件的时候都需要这个tag，只有tag一致才能正常接收到事件。

比如有一个事件类HelloEvent，这个事件的作用是接收到后toast一个提示&ldquo;hello&rdquo;，如果两个Activity都注册了这个HelloEvent事件，但是没有tag去限制，一旦post了一个helloEvent事件后，两个Activity都会收到这个事件，导致两个Activity都会toast。如果使用tag，post这个HelloEvent的时候可以设置这个tag，只有register时也使用了这个tag才会接收到这个event。

2\. 在Present（如Activity的onCreate）中注册一个Observer（以下以发送一个String类型的事件为例）

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> Observable&lt;String&gt; addOb =<span style="color: #000000;"> RxBus.get()
</span><span style="color: #008080;">2</span>                 .register("addFeedTag", String.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;">3</span> 
<span style="color: #008080;">4</span> <span style="color: #000000;">addOb.observeOn(AndroidSchedulers.mainThread())
</span><span style="color: #008080;">5</span>                 .subscribe(s -&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;">6</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> todo: Accept event and process here</span>
<span style="color: #008080;">7</span>                 });</pre>
</div>

如上，注册了一个String类型的事件，事件的tag是&ldquo;addFeedTag&rdquo;，用来增加一个Feed。使用RxAndroid在Action1中处理接收到的这个事件。

3\. 在任何地方发送一个事件：

<div class="cnblogs_code">
<pre>RxBus.get().post("addFeedTag", "hello RxBus!");</pre>
</div>

这里发送了一个tag为&ldquo;addFeedTag&rdquo;的String类型的事件。

4\. 反注册Observer：

<div class="cnblogs_code">
<pre>RxBus.get().unregister("addFeedTag", addOb);</pre>
</div>

注意：这里的Tag都为&ldquo;addFeedTag&rdquo;。

&nbsp;

**下面使用注解的方式更简单方便地使用RxBus（嗯－。－这里才是重点）。**

首先来看下使用注解后的代码：

1\. 注册Observer

这一步可以省略掉。

2\. 发送一个事件（这里我们换一个事件：FeedItemClickEvent，我们定义这个事件是用来处理当Feed被点击后的事件）

<div class="cnblogs_code">
<pre>RxBus.get().post(<span style="color: #0000ff;">new</span> FeedItemClickEvent().setPosition(position).setFeed(feed));</pre>
</div>

3\. 接收事件，然后处理

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #000000;">@Accept
</span><span style="color: #008080;">2</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onPostAccept(Object tag, FeedItemClickEvent event) {
</span><span style="color: #008080;">3</span> 　　Logger.d(TAG, "onPostAccept event: " +<span style="color: #000000;"> event);
</span><span style="color: #008080;">4</span> 　　Feed feed =<span style="color: #000000;"> event.getFeed();
</span><span style="color: #008080;">5</span> 　　<span style="color: #008000;">//</span><span style="color: #008000;"> 跳转到feed详情页面...</span>
<span style="color: #008080;">6</span> }</pre>
</div>

如上，这里只需要编写一个方法，加上Accept注解，然后在方法中进行事件处理即可。

注意：方法名可以任意

方法参数一：必须为Object类型的tag；

方法参数二，如果这个方法只接收一种事件，则写明具体的事件类型，如上；如果这个方法接收多种事件，则类型需要为Object。

4\. 反注册Observer

这一步也可以省略掉。

&nbsp;

接收多种事件：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">@Accept(
</span><span style="color: #008080;"> 2</span>             acceptScheduler =<span style="color: #000000;"> AcceptScheduler.NEW_THREAD,
</span><span style="color: #008080;"> 3</span>             value =<span style="color: #000000;"> {
</span><span style="color: #008080;"> 4</span>                     @AcceptType(tag = ActionEvent.CLOSE, clazz = String.<span style="color: #0000ff;">class</span><span style="color: #000000;">),
</span><span style="color: #008080;"> 5</span>                     @AcceptType(tag = ActionEvent.BACK, clazz = String.<span style="color: #0000ff;">class</span><span style="color: #000000;">),
</span><span style="color: #008080;"> 6</span>                     @AcceptType(tag = ActionEvent.EDIT, clazz = String.<span style="color: #0000ff;">class</span><span style="color: #000000;">),
</span><span style="color: #008080;"> 7</span>                     @AcceptType(tag = ActionEvent.REFRESH, clazz = String.<span style="color: #0000ff;">class</span><span style="color: #000000;">)
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    )
</span><span style="color: #008080;">10</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onPostAccept(Object tag, Object actionEvent) {
</span><span style="color: #008080;">11</span>         Logger.d(TAG, "[ActionEvent]onPostAccept action event name: " +<span style="color: #000000;"> actionEvent);
</span><span style="color: #008080;">12</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> todo: Accept event and process here (in new thread)</span>
<span style="color: #008080;">13</span>     }</pre>
</div>

这里@Accept注解中设置了acceptScheduler为AcceptScheduler.NEW_THREAD，指明方法运行在子线程中.

value中指明了接收的事件类型，这里表示这个方法接收4种类型的事件：CLOSE, BACK, EDIT, REFRESH.

&nbsp;

**注解解释：**

**@Accept注解**

acceptScheduler: 指定被注解的方法运行的Scheduler。

value[]: AcceptType注解数组，用于指定接收事件的tag和class。

&nbsp;

**@AcceptType注解：**

tag: 接收事件的tag
clazz: 接收事件的类型

&nbsp;

**AcceptScheduler：**

详情见：rx.schedulers.Schedulers和rx.android.schedulers.AndroidSchedulers

如果设置的是AcceptScheduler.EXECUTOR或AcceptScheduler.HANDLER，则需要在Application中配置Executor和Handler：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 6/15/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MyApplication <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Application {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span> Executor acceptExecutor =<span style="color: #000000;"> Executors.newCachedThreadPool();
</span><span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">private</span> Handler handler = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Handler(Looper.getMainLooper());
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">11</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate() {
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate();
</span><span style="color: #008080;">13</span>         RxBus.DEBUG = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span>         DefaultAcceptConfiguration.getInstance().registerAcceptConfiguration(<span style="color: #0000ff;">new</span><span style="color: #000000;"> DefaultAcceptConfiguration.OnDefaultAcceptConfiguration() {
</span><span style="color: #008080;">16</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">17</span>             <span style="color: #0000ff;">public</span><span style="color: #000000;"> Executor applyAcceptExecutor() {
</span><span style="color: #008080;">18</span>                 <span style="color: #0000ff;">return</span><span style="color: #000000;"> acceptExecutor;
</span><span style="color: #008080;">19</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> <span style="color: #000000;">            @Override
</span><span style="color: #008080;">22</span>             <span style="color: #0000ff;">public</span><span style="color: #000000;"> Handler applyAcceptHandler() {
</span><span style="color: #008080;">23</span>                 <span style="color: #0000ff;">return</span><span style="color: #000000;"> handler;
</span><span style="color: #008080;">24</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">25</span> <span style="color: #000000;">        });
</span><span style="color: #008080;">26</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">27</span> }</pre>
</div>

因为需要对Accept和AcceptType注解的解析，所以项目的BaseActivity需要使用**[AIAppCompatActivity](https://github.com/wangjiegulu/androidInject/blob/master/src/com/wangjie/androidinject/annotation/present/AIAppCompatActivity.java)**，然后实现parserMethodAnnotations()方法，使用**[RxBusAnnotationManager](https://github.com/wangjiegulu/RxAndroidEventsSample/blob/master/sample/src/main/java/com/wangjie/rxandroideventssample/rxbus/RxBusAnnotationManager.java)**对注解进行解析。

&nbsp;

参考：[http://nerds.weddingpartyapp.com/tech/2014/12/24/implementing-an-event-bus-with-rxjava-rxbus/](http://nerds.weddingpartyapp.com/tech/2014/12/24/implementing-an-event-bus-with-rxjava-rxbus/)

&nbsp;