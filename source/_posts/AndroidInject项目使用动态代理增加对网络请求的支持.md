---
title: AndroidInject项目使用动态代理增加对网络请求的支持
tags: [android, library, proxy, dynamic proxy, http, annotations]
date: 2014-02-08 14:32:00
---

AndroidInject项目是我写的一个使用注解注入来简化代码的开源项目

[https://github.com/wangjiegulu/androidInject](https://github.com/wangjiegulu/androidInject)

今天新增功能如下：

1\. 增加@AIScreenSize注解，作用于属性，用于注入当前设备的屏幕大小（宽高）
2\. 增加对网络请求的支持，使用动态代理实现：@AIGet注解，作用于接口方法，表示以GET来请求url；@AIPost注解，作用于接口方法，表示以POST来请求url；@AIParam，用于注入请求参数
3\. 增加@AINetWorker注解，作用于属性，用于注入网络请求服务
4\. 增加GET或POST请求时请求参数可使用Params类传入，简化代码

&nbsp;

主要执行代码如下：

用@AINetWorker注解注入NetWorker接口的子类代理（动态代理模式）：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #000000;">@AINetWorker
</span><span style="color: #008080;">2</span> <span style="color: #0000ff;">private</span> PersonWorker personWorker;</pre>
</div>

<span style="line-height: 1.5;">然后启动线程，在线程中调用进行网络请求：</span>

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #0000ff;">new</span> Thread(<span style="color: #0000ff;">new</span><span style="color: #000000;"> Runnable() {
</span><span style="color: #008080;">2</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">3</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> run() {
</span><span style="color: #008080;">4</span> <span style="color: #008000;">//</span><span style="color: #008000;">        RetMessage&lt;Person&gt; retMsg = personWorker.getPersonsForGet("a1", "b1", "c1");
</span><span style="color: #008080;">5</span> <span style="color: #008000;">//</span><span style="color: #008000;">        RetMessage&lt;Person&gt; retMsg = personWorker.getPersonsForGet2(new Params().add("aa", "a1").add("bb", "b1").add("cc", "c1"));</span>
<span style="color: #008080;">6</span>         RetMessage&lt;Person&gt; retMsg = personWorker.getPersonsForPost2(<span style="color: #0000ff;">new</span> Params().add("aa", "a1").add("bb", "b1").add("cc", "c1"<span style="color: #000000;">));
</span><span style="color: #008080;">7</span> <span style="color: #000000;">        System.out.println(retMsg.getList().toString());
</span><span style="color: #008080;">8</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">9</span> }).start();</pre>
</div>

请求的结果封装在RetMessage类中（AndroidInject框架所作的事就是执行Get或者Post请求，获得返回结果，然后json解析后封装在RetMessage中）：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.core.net;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.google.gson.Gson;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Json响应结果包装类
 * Created with IntelliJ IDEA.
 * Author: wangjie  email:tiantian.china.2@gmial.com
 * Date: 14-2-7
 * Time: 下午4:25
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> RetMessage&lt;T&gt;<span style="color: #000000;">
{
    </span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> resultCode; <span style="color: #008000;">//</span><span style="color: #008000;"> 结果码，必须包含</span>

    <span style="color: #0000ff;">private</span> List&lt;T&gt; list; <span style="color: #008000;">//</span><span style="color: #008000;"> 返回的数据</span>

    <span style="color: #0000ff;">private</span> T obj; <span style="color: #008000;">//</span><span style="color: #008000;"> 返回的数据</span>

    <span style="color: #0000ff;">private</span> Integer size; <span style="color: #008000;">//</span><span style="color: #008000;"> 返回数据长度</span>

    <span style="color: #0000ff;">private</span> String errorMessage; <span style="color: #008000;">//</span><span style="color: #008000;"> 返回错误信息</span>

    <span style="color: #0000ff;">public</span><span style="color: #000000;"> String toJson(){
        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span> Gson().toJson(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
    }
    </span><span style="color: #008000;">//</span><span style="color: #008000;"> getter和setter方法省略...</span><span style="color: #000000;">
}</span></pre>
</div>

接下来看下PersonWorker接口中所作的事情：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.androidinject;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.annotations.net.AIGet;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.annotations.net.AIParam;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.annotations.net.AIPost;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.core.net.RetMessage;
</span><span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.util.Params;
</span><span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.model.Person;
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">11</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;">12</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;">13</span> <span style="color: #008000;"> * Date: 14-2-7
</span><span style="color: #008080;">14</span> <span style="color: #008000;"> * Time: 下午1:44
</span><span style="color: #008080;">15</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">16</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> PersonWorker {
</span><span style="color: #008080;">17</span>     @AIGet("http://192.168.2.198:8080/HelloSpringMVC/person/findPersons?aa=#{a3}&amp;bb=#{b3}&amp;cc=#{c3}"<span style="color: #000000;">)
</span><span style="color: #008080;">18</span>     <span style="color: #0000ff;">public</span> RetMessage&lt;Person&gt; getPersonsForGet(@AIParam("a3")String a2, @AIParam("b3") String b2, @AIParam("c3"<span style="color: #000000;">) String c2);
</span><span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span>     @AIPost("http://192.168.2.198:8080/HelloSpringMVC/person/findPersons"<span style="color: #000000;">)
</span><span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span> RetMessage&lt;Person&gt; getPersonsForPost(@AIParam("aa")String a2, @AIParam("bb") String b2, @AIParam("cc"<span style="color: #000000;">) String c2);
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span>     @AIGet("http://192.168.2.198:8080/HelloSpringMVC/person/findPersons"<span style="color: #000000;">)
</span><span style="color: #008080;">24</span>     <span style="color: #0000ff;">public</span> RetMessage&lt;Person&gt;<span style="color: #000000;"> getPersonsForGet2(Params params);
</span><span style="color: #008080;">25</span> 
<span style="color: #008080;">26</span>     @AIPost("http://192.168.2.198:8080/HelloSpringMVC/person/findPersons"<span style="color: #000000;">)
</span><span style="color: #008080;">27</span>     <span style="color: #0000ff;">public</span> RetMessage&lt;Person&gt;<span style="color: #000000;"> getPersonsForPost2(Params params);
</span><span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> 
<span style="color: #008080;">30</span> }</pre>
</div>

PersonWorker是自己写的一个接口（以后需要有新的网络请求，都可以类似编写Worker），声明了执行网络请求的各种方法，这些方法需要加上@AIGet或者@AIPost注解，用于声明请求方式，并在此注解中的value()值设置为所要请求的url（此注解的其他属性后续会陆续扩展）

方法的@AIParam注解是作用与mybatis的@Param注解类似，可以设置请求携带的参数

如果参数比较多，则推荐使用Params来存放参数，以此来简化代码，Params类实质上就是一个HashMap，存放参数的键值对即可。

&nbsp;

接下来分析下框架是怎么实现的，其实上面讲过，主要是用Annotaion和动态代理了

首先看看PersonWorker的注入，在AIActivity（AIActivity，AndroidInject开源项目中的Activity使用注解的话，你写的Activity必须继承AIActivity，另外如果要使用FragmentActivity，则需要继承AISupportFragmentActivity）启动时，首先会去解析添加的注解，这里讨论@AINetWorker注解，内部代码很简单：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">2</span> <span style="color: #008000;"> * 注入NetWorker
</span><span style="color: #008080;">3</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> field
</span><span style="color: #008080;">4</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@throws</span><span style="color: #008000;"> Exception
</span><span style="color: #008080;">5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">6</span>  <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> netWorkerBind(Field field) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception{
</span><span style="color: #008080;">7</span>         field.setAccessible(<span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;">8</span> <span style="color: #000000;">        field.set(present, NetInvoHandler.getWorker(field.getType()));
</span><span style="color: #008080;">9</span>  }</pre>
</div>

通过代码可知，是使用反射来实现的，主要的代码是这句：

<div class="cnblogs_code">
<pre>NetInvoHandler.getWorker(field.getType());</pre>
</div>

这句代码的作用是通过Class获得一个PersonWorker实现类的代理对象，这里很明显是使用了动态代理。

所以，最核心的类应该是NetInvoHandler这个类，这个类的代码如下（篇幅问题，所以就折叠了）：

<div class="cnblogs_code" onclick="cnblogs_code_show('7d38bbca-82a1-429f-a5c2-68b2ebe85e58')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_7d38bbca-82a1-429f-a5c2-68b2ebe85e58" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.core.net;
</span><span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.text.TextUtils;
</span><span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.google.gson.Gson;
</span><span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.annotations.net.AIGet;
</span><span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.annotations.net.AIParam;
</span><span style="color: #008080;">  7</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.annotations.net.AIPost;
</span><span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.util.Params;
</span><span style="color: #008080;">  9</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.androidinject.annotation.util.StringUtil;
</span><span style="color: #008080;"> 10</span> 
<span style="color: #008080;"> 11</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.annotation.Annotation;
</span><span style="color: #008080;"> 12</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.reflect.InvocationHandler;
</span><span style="color: #008080;"> 13</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.reflect.Method;
</span><span style="color: #008080;"> 14</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.reflect.Proxy;
</span><span style="color: #008080;"> 15</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.HashMap;
</span><span style="color: #008080;"> 16</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.Map;
</span><span style="color: #008080;"> 17</span> 
<span style="color: #008080;"> 18</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 19</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 20</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 21</span> <span style="color: #008000;"> * Date: 14-2-7
</span><span style="color: #008080;"> 22</span> <span style="color: #008000;"> * Time: 下午1:40
</span><span style="color: #008080;"> 23</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 24</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> NetInvoHandler <span style="color: #0000ff;">implements</span><span style="color: #000000;"> InvocationHandler{
</span><span style="color: #008080;"> 25</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> HashMap&lt;Class&lt;?&gt;, NetInvoHandler&gt; invoHandlers = <span style="color: #0000ff;">new</span> HashMap&lt;Class&lt;?&gt;, NetInvoHandler&gt;<span style="color: #000000;">();
</span><span style="color: #008080;"> 26</span> 
<span style="color: #008080;"> 27</span>     <span style="color: #0000ff;">private</span> Object proxy; <span style="color: #008000;">//</span><span style="color: #008000;"> 代理对象</span>
<span style="color: #008080;"> 28</span> 
<span style="color: #008080;"> 29</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">synchronized</span>  <span style="color: #0000ff;">static</span>&lt;T&gt; T getWorker(Class&lt;T&gt;<span style="color: #000000;"> clazz){
</span><span style="color: #008080;"> 30</span>         NetInvoHandler netInvoHandler =<span style="color: #000000;"> invoHandlers.get(clazz);
</span><span style="color: #008080;"> 31</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> netInvoHandler){
</span><span style="color: #008080;"> 32</span>             netInvoHandler = <span style="color: #0000ff;">new</span><span style="color: #000000;"> NetInvoHandler();
</span><span style="color: #008080;"> 33</span>             netInvoHandler.setProxy(Proxy.newProxyInstance(clazz.getClassLoader(), <span style="color: #0000ff;">new</span><span style="color: #000000;"> Class[]{clazz}, netInvoHandler));
</span><span style="color: #008080;"> 34</span> <span style="color: #000000;">            invoHandlers.put(clazz, netInvoHandler);
</span><span style="color: #008080;"> 35</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 36</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> (T)netInvoHandler.getProxy();
</span><span style="color: #008080;"> 37</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 38</span> 
<span style="color: #008080;"> 39</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 40</span>     <span style="color: #0000ff;">public</span> Object invoke(Object proxy, Method method, Object[] args) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Throwable {
</span><span style="color: #008080;"> 41</span> 
<span style="color: #008080;"> 42</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> get请求</span>
<span style="color: #008080;"> 43</span>         <span style="color: #0000ff;">if</span>(method.isAnnotationPresent(AIGet.<span style="color: #0000ff;">class</span><span style="color: #000000;">)){
</span><span style="color: #008080;"> 44</span>             AIGet aiGet = method.getAnnotation(AIGet.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 45</span>             String url =<span style="color: #000000;"> aiGet.value();
</span><span style="color: #008080;"> 46</span>             <span style="color: #0000ff;">if</span><span style="color: #000000;">(TextUtils.isEmpty(url)){
</span><span style="color: #008080;"> 47</span>                 <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> Exception("net work [" + method.getName() + "]@AIGet value()[url] is empty!!"<span style="color: #000000;">);
</span><span style="color: #008080;"> 48</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 49</span>             Annotation[][] annotaions =<span style="color: #000000;"> method.getParameterAnnotations();
</span><span style="color: #008080;"> 50</span>             <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; args.length; i++<span style="color: #000000;">){
</span><span style="color: #008080;"> 51</span>                 <span style="color: #0000ff;">if</span>(Params.<span style="color: #0000ff;">class</span>.isAssignableFrom(args[i].getClass())){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果属性为Params，则追加在后面</span>
<span style="color: #008080;"> 52</span>                     url =<span style="color: #000000;"> StringUtil.appendParamsAfterUrl(url, (Params)args[i]);
</span><span style="color: #008080;"> 53</span>                 }<span style="color: #0000ff;">else</span>{ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果属性添加了@AIParam注解，则替换链接中#{xxx}</span>
<span style="color: #008080;"> 54</span>                     String repName = ((AIParam)annotaions[i][0<span style="color: #000000;">]).value();
</span><span style="color: #008080;"> 55</span>                     url = url.replace("#{" + repName + "}", args[i] + ""<span style="color: #000000;">);
</span><span style="color: #008080;"> 56</span> <span style="color: #000000;">                }
</span><span style="color: #008080;"> 57</span> 
<span style="color: #008080;"> 58</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 59</span>             StringBuilder sb =<span style="color: #000000;"> NetWork.getStringFromUrl(url);
</span><span style="color: #008080;"> 60</span>             <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> sb){
</span><span style="color: #008080;"> 61</span>                 <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 62</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 63</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> Gson().fromJson(sb.toString(), method.getReturnType());
</span><span style="color: #008080;"> 64</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 65</span> 
<span style="color: #008080;"> 66</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> post请求</span>
<span style="color: #008080;"> 67</span>         <span style="color: #0000ff;">if</span>(method.isAnnotationPresent(AIPost.<span style="color: #0000ff;">class</span><span style="color: #000000;">)){
</span><span style="color: #008080;"> 68</span>             AIPost aiPost = method.getAnnotation(AIPost.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 69</span>             String url =<span style="color: #000000;"> aiPost.value();
</span><span style="color: #008080;"> 70</span>             <span style="color: #0000ff;">if</span><span style="color: #000000;">(TextUtils.isEmpty(url)){
</span><span style="color: #008080;"> 71</span>                 <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> Exception("net work [" + method.getName() + "]@AIPost value()[url] is empty!!"<span style="color: #000000;">);
</span><span style="color: #008080;"> 72</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 73</span>             Annotation[][] annotaions =<span style="color: #000000;"> method.getParameterAnnotations();
</span><span style="color: #008080;"> 74</span>             Map&lt;String, String&gt; map = <span style="color: #0000ff;">new</span> HashMap&lt;String, String&gt;<span style="color: #000000;">();
</span><span style="color: #008080;"> 75</span>             <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; args.length; i++<span style="color: #000000;">){
</span><span style="color: #008080;"> 76</span>                 <span style="color: #0000ff;">if</span>(Params.<span style="color: #0000ff;">class</span>.isAssignableFrom(args[i].getClass())){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果属性为Params，则追加在后面</span>
<span style="color: #008080;"> 77</span> <span style="color: #000000;">                    map.putAll((Params)args[i]);
</span><span style="color: #008080;"> 78</span>                 }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;"> 79</span>                     String repName = ((AIParam)annotaions[i][0<span style="color: #000000;">]).value();
</span><span style="color: #008080;"> 80</span>                     map.put(repName, args[i] + ""<span style="color: #000000;">);
</span><span style="color: #008080;"> 81</span> <span style="color: #000000;">                }
</span><span style="color: #008080;"> 82</span> 
<span style="color: #008080;"> 83</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 84</span>             StringBuilder sb =<span style="color: #000000;"> NetWork.postStringFromUrl(url, map);
</span><span style="color: #008080;"> 85</span>             <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> sb){
</span><span style="color: #008080;"> 86</span>                 <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 87</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 88</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> Gson().fromJson(sb.toString(), method.getReturnType());
</span><span style="color: #008080;"> 89</span> 
<span style="color: #008080;"> 90</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 91</span> 
<span style="color: #008080;"> 92</span> 
<span style="color: #008080;"> 93</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 94</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 95</span> 
<span style="color: #008080;"> 96</span> 
<span style="color: #008080;"> 97</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> Object getProxy() {
</span><span style="color: #008080;"> 98</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> proxy;
</span><span style="color: #008080;"> 99</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">100</span> 
<span style="color: #008080;">101</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setProxy(Object proxy) {
</span><span style="color: #008080;">102</span>         <span style="color: #0000ff;">this</span>.proxy =<span style="color: #000000;"> proxy;
</span><span style="color: #008080;">103</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">104</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

里面的代码还没有好好的重构，所以，看起来会更直白，该类实现了InvocationHandler，很明显的动态代理。

我们通过NetInvoHandler的getWorker静态方法，来获取一个指定Class的Worker实现类的代理对象，由于实际应用时，Worker接口应该会很多，为了不重复生成相同Worker实现类的代理对象，所以这里在生成一个后，保存起来，确保一个Worker只生成一个代理对象，一个NetInvoHandler。

这里有个地方需要注意一下，以前使用的动态代理，需要一个RealSubject，也就是真实对象，是Worker的实现类。这样，在invoke方法中就可以调用真实对象的对应方法了，但是现在，进行网络请求，我们没有去写一个类然后实现PersonWorker接口，因为没有必要，我们完全可以在invoke方法中去执行相同的网络请求。

请想下，之所以需要框架的存在 不就是为了把一些模板的东西给简化掉么？现在的网络请求这些步骤就是一些模板话的东西，我们需要的就是调用方法，自动进行网络请求（框架做的事），然后返回给我结果。所以网络请求这一步，写在invoke方法中即可。

而不是所谓的编写一个类，实现PersonWorker接口，在这个实现类中进行网络请求，然后在invoke方法中调用真实对象的对应该方法。

因此，在Proxy.newProxyInstance的interfaces中填写需要实现的接口，也就是现在的PersonWorker。

&nbsp;

接下来看下invoke中做的事情，首先根据方法增加的注解来识别是GET请求还是POST请求。然后各自执行请求（因为我请求的执行，写在NetWork中了，这里直接返回了请求结果字符串StringBuilder sb）。

接下来，使用Gson这个霸气的工具，一键从json解析封装成RetMessage对象。（所以，这里是需要Gson库的支持，大家网上下载gson.jar，或者使用maven）

当然，要使用Gson一键解析封装的前提是服务器端的编写需要保存一致性，下面是我服务器端测试的代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> @RequestMapping("/findPersons"<span style="color: #000000;">)
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> findPersons(HttpServletRequest request, HttpServletResponse response, 
</span><span style="color: #008080;"> 3</span>                                 @RequestParam("aa"<span style="color: #000000;">) String aa, 
</span><span style="color: #008080;"> 4</span>                                 @RequestParam("bb"<span style="color: #000000;">) String bb, 
</span><span style="color: #008080;"> 5</span>                                 @RequestParam("cc") String cc) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> IOException{
</span><span style="color: #008080;"> 6</span>         System.out.println("aa: " + aa + ", bb: " + bb + ", cc: " +<span style="color: #000000;"> cc);
</span><span style="color: #008080;"> 7</span>         RetMessage&lt;Person&gt; rm = <span style="color: #0000ff;">new</span> RetMessage&lt;Person&gt;<span style="color: #000000;">();
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span>         rm.setResultCode(0<span style="color: #000000;">);
</span><span style="color: #008080;">10</span>         
<span style="color: #008080;">11</span>         List&lt;Person&gt; persons = <span style="color: #0000ff;">new</span> ArrayList&lt;Person&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; 5; i++<span style="color: #000000;">){
</span><span style="color: #008080;">13</span>             Person p = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Person();
</span><span style="color: #008080;">14</span>             p.setName("wangjie_" +<span style="color: #000000;"> i);
</span><span style="color: #008080;">15</span>             p.setAge(20 +<span style="color: #000000;"> i);
</span><span style="color: #008080;">16</span> <span style="color: #000000;">            persons.add(p);
</span><span style="color: #008080;">17</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">18</span>         
<span style="color: #008080;">19</span> <span style="color: #000000;">        rm.setList(persons);
</span><span style="color: #008080;">20</span>         
<span style="color: #008080;">21</span> <span style="color: #000000;">        ServletUtil.obtinUTF8JsonWriter(response).write(rm.toJson());
</span><span style="color: #008080;">22</span>     }</pre>
</div>

服务器端返回结果时，也是封装在RetMessage类中，这个类服务器端和客户端是保持一致的，所以可以一键转换。

如果你在开发的过程中，RetMessage类中封装的东西不能满足你的需求，可以自己编写结果类，当然在Worker中声明方法中返回值就应该是你写的结果类了。

&nbsp;

到此为止，讲解完毕

另：如果，你需要写一个查询User信息的网络请求，应该怎么写？

只需编写UserWorker接口，然后声明方法findUsers()，写上@AIGet或者@AIPost注解，写明url和请求参数。然后通过@AINetWorker注解注入userWorker，然后开启线程，调用userWorker的findUsers()方法即可。

当然UserWorker也可以不使用注解获得，而是调用&ldquo;NetInvoHandler.getWorker(UserWorker.class)&rdquo;获得！

&nbsp;

&nbsp;

