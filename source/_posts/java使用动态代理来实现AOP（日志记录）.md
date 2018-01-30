---
title: java使用动态代理来实现AOP（日志记录）
tags: [java, aop, dynamic proxy, log, logger]
date: 2013-09-24 12:05:00
---

<span style="line-height: 1.5; color: #ff0000;">以下内容为原创，转载时请注明链接地址：[<span style="color: #ff0000;">http://www.cnblogs.com/tiantianbyconan/p/3336627.html</span>](http://www.cnblogs.com/tiantianbyconan/p/3336627.html)</span>

<span style="line-height: 1.5;">AOP（面向方面）的思想，就是把项目共同的那部分功能分离开来，比如日志记录，避免在业务逻辑里面夹杂着跟业务逻辑无关的代码。</span>

下面是一个AOP实现的简单例子：

![](http://images.cnitblog.com/blog/378300/201309/24111801-c8f719406a074bf5805d2a94ac2dcccb.jpg)

首先定义一些业务方法：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 13-9-23
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Time: 下午3:49
</span><span style="color: #008080;"> 6</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> BussinessService {
</span><span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String login(String username, String password);
</span><span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String find();
</span><span style="color: #008080;">10</span> <span style="color: #000000;">}
</span><span style="color: #008080;">11</span> 
<span style="color: #008080;">12</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> BussinessServiceImpl <span style="color: #0000ff;">implements</span><span style="color: #000000;"> BussinessService {
</span><span style="color: #008080;">13</span>     <span style="color: #0000ff;">private</span> Logger logger = Logger.getLogger(<span style="color: #0000ff;">this</span><span style="color: #000000;">.getClass().getSimpleName());
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">16</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String login(String username, String password) {
</span><span style="color: #008080;">17</span>         <span style="color: #0000ff;">return</span> "login success"<span style="color: #000000;">;
</span><span style="color: #008080;">18</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String find() {
</span><span style="color: #008080;">22</span>         <span style="color: #0000ff;">return</span> "find success"<span style="color: #000000;">;
</span><span style="color: #008080;">23</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span> }</pre>
</div>
<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 13-9-24
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Time: 上午10:27
</span><span style="color: #008080;"> 6</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> WorkService {
</span><span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String work();
</span><span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String sleep();
</span><span style="color: #008080;">10</span> <span style="color: #000000;">}
</span><span style="color: #008080;">11</span> 
<span style="color: #008080;">12</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> WorkServiceImpl <span style="color: #0000ff;">implements</span><span style="color: #000000;"> WorkService{
</span><span style="color: #008080;">13</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">14</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String work() {
</span><span style="color: #008080;">15</span>         <span style="color: #0000ff;">return</span> "work success"<span style="color: #000000;">;
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">19</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> String sleep() {
</span><span style="color: #008080;">20</span>         <span style="color: #0000ff;">return</span> "sleep success"<span style="color: #000000;">;
</span><span style="color: #008080;">21</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">22</span> }</pre>
</div>

实现InvocationHandler接口，使用map来存储不同的InvocationHandler对象，避免生成过多。

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.aoptest2.invohandler;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.reflect.InvocationHandler;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.reflect.Method;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.reflect.Proxy;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.Arrays;
</span><span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.HashMap;
</span><span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.logging.Logger;
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">11</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;">12</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;">13</span> <span style="color: #008000;"> * Date: 13-9-23
</span><span style="color: #008080;">14</span> <span style="color: #008000;"> * Time: 下午3:47
</span><span style="color: #008080;">15</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">16</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> LogInvoHandler <span style="color: #0000ff;">implements</span><span style="color: #000000;"> InvocationHandler{
</span><span style="color: #008080;">17</span>     <span style="color: #0000ff;">private</span> Logger logger = Logger.getLogger(<span style="color: #0000ff;">this</span><span style="color: #000000;">.getClass().getSimpleName());
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span>     <span style="color: #0000ff;">private</span> Object target; <span style="color: #008000;">//</span><span style="color: #008000;"> 代理目标</span>
<span style="color: #008080;">20</span>     <span style="color: #0000ff;">private</span> Object proxy; <span style="color: #008000;">//</span><span style="color: #008000;"> 代理对象</span>
<span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> HashMap&lt;Class&lt;?&gt;, LogInvoHandler&gt; invoHandlers = <span style="color: #0000ff;">new</span> HashMap&lt;Class&lt;?&gt;, LogInvoHandler&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">23</span> 
<span style="color: #008080;">24</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> LogInvoHandler() {
</span><span style="color: #008080;">25</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">28</span> <span style="color: #008000;">     * 通过Class来生成动态代理对象Proxy
</span><span style="color: #008080;">29</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> clazz
</span><span style="color: #008080;">30</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span>
<span style="color: #008080;">31</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">32</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">synchronized</span> <span style="color: #0000ff;">static</span>&lt;T&gt; T getProxyInstance(Class&lt;T&gt;<span style="color: #000000;"> clazz){
</span><span style="color: #008080;">33</span>         LogInvoHandler invoHandler =<span style="color: #000000;"> invoHandlers.get(clazz);
</span><span style="color: #008080;">34</span> 
<span style="color: #008080;">35</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> invoHandler){
</span><span style="color: #008080;">36</span>             invoHandler = <span style="color: #0000ff;">new</span><span style="color: #000000;"> LogInvoHandler();
</span><span style="color: #008080;">37</span>             <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;">38</span>                 T tar =<span style="color: #000000;"> clazz.newInstance();
</span><span style="color: #008080;">39</span> <span style="color: #000000;">                invoHandler.setTarget(tar);
</span><span style="color: #008080;">40</span> <span style="color: #000000;">                invoHandler.setProxy(Proxy.newProxyInstance(tar.getClass().getClassLoader(),
</span><span style="color: #008080;">41</span> <span style="color: #000000;">                        tar.getClass().getInterfaces(), invoHandler));
</span><span style="color: #008080;">42</span>             } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (Exception e) {
</span><span style="color: #008080;">43</span> <span style="color: #000000;">                e.printStackTrace();
</span><span style="color: #008080;">44</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">45</span> <span style="color: #000000;">            invoHandlers.put(clazz, invoHandler);
</span><span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">48</span> 
<span style="color: #008080;">49</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> (T)invoHandler.getProxy();
</span><span style="color: #008080;">50</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">51</span> 
<span style="color: #008080;">52</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">53</span>     <span style="color: #0000ff;">public</span> Object invoke(Object proxy, Method method, Object[] args) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Throwable {
</span><span style="color: #008080;">54</span> 
<span style="color: #008080;">55</span>         Object result = method.invoke(target, args); <span style="color: #008000;">//</span><span style="color: #008000;"> 执行业务处理
</span><span style="color: #008080;">56</span> 
<span style="color: #008080;">57</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 打印日志</span>
<span style="color: #008080;">58</span>         logger.info("____invoke method: " +<span style="color: #000000;"> method.getName()
</span><span style="color: #008080;">59</span>                     + "; args: " + (<span style="color: #0000ff;">null</span> == args ? "null"<span style="color: #000000;"> : Arrays.asList(args).toString())
</span><span style="color: #008080;">60</span>                     + "; return: " +<span style="color: #000000;"> result);
</span><span style="color: #008080;">61</span> 
<span style="color: #008080;">62</span> 
<span style="color: #008080;">63</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> result;
</span><span style="color: #008080;">64</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">65</span> 
<span style="color: #008080;">66</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> Object getTarget() {
</span><span style="color: #008080;">67</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> target;
</span><span style="color: #008080;">68</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">69</span> 
<span style="color: #008080;">70</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setTarget(Object target) {
</span><span style="color: #008080;">71</span>         <span style="color: #0000ff;">this</span>.target =<span style="color: #000000;"> target;
</span><span style="color: #008080;">72</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">73</span> 
<span style="color: #008080;">74</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> Object getProxy() {
</span><span style="color: #008080;">75</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> proxy;
</span><span style="color: #008080;">76</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">77</span> 
<span style="color: #008080;">78</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setProxy(Object proxy) {
</span><span style="color: #008080;">79</span>         <span style="color: #0000ff;">this</span>.proxy =<span style="color: #000000;"> proxy;
</span><span style="color: #008080;">80</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">81</span> }</pre>
</div>

&nbsp;

然后编写一个Test类测试：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 13-9-24
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Time: 上午9:54
</span><span style="color: #008080;"> 6</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> Test {
</span><span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> Logger logger = Logger.getLogger(Test.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName());
</span><span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> main(String[] args) {
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span>         BussinessService bs = LogInvoHandler.getProxyInstance(BussinessServiceImpl.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;">12</span>         bs.login("zhangsan", "123456"<span style="color: #000000;">);
</span><span style="color: #008080;">13</span> <span style="color: #000000;">        bs.find();
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span>         logger.info("--------------------------------------"<span style="color: #000000;">);
</span><span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span>         WorkService ws = LogInvoHandler.getProxyInstance(WorkServiceImpl.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;">18</span> <span style="color: #000000;">        ws.work();
</span><span style="color: #008080;">19</span> <span style="color: #000000;">        ws.sleep();
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>         logger.info("--------------------------------------"<span style="color: #000000;">);
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span>         BussinessService bss = LogInvoHandler.getProxyInstance(BussinessServiceImpl.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;">24</span>         bss.login("lisi", "654321"<span style="color: #000000;">);
</span><span style="color: #008080;">25</span> <span style="color: #000000;">        bss.find();
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">28</span> }</pre>
</div>

以后需要添加新的业务逻辑XXXService，只需要调用

XXXService xs = LogInvoHandler.getProxyInstance(XXXServiceImpl.class);

即可。

也可以模仿Spring等框架的配置，把bean的类名配置在xml文件中，如：

&lt;bean id="bussinessService" class="com.wangjie.aoptest2.service.impl.BussinessServiceImpl"&gt;

然后在java代码中解析xml，通过Class.forName("com.wangjie.aoptest2.service.impl.BussinessServiceImpl");获得Class对象

然后通过LogInvoHandler.getProxyInstance(Class.forName("com.wangjie.aoptest2.service.impl.BussinessServiceImpl"));获得代理对象Proxy

再使用反射去调用代理对象的方法。

&nbsp;

运行结果如下：

九月 24, 2013 11:08:03 上午 com.wangjie.aoptest2.invohandler.LogInvoHandler invoke
INFO: ____invoke method: login; args: [zhangsan, 123456]; return: login success
九月 24, 2013 11:08:03 上午 com.wangjie.aoptest2.invohandler.LogInvoHandler invoke
INFO: ____invoke method: find; args: null; return: find success
九月 24, 2013 11:08:03 上午 com.wangjie.aoptest2.Test main
INFO: --------------------------------------
九月 24, 2013 11:08:03 上午 com.wangjie.aoptest2.invohandler.LogInvoHandler invoke
INFO: ____invoke method: work; args: null; return: work success
九月 24, 2013 11:08:03 上午 com.wangjie.aoptest2.invohandler.LogInvoHandler invoke
INFO: ____invoke method: sleep; args: null; return: sleep success
九月 24, 2013 11:08:03 上午 com.wangjie.aoptest2.Test main
INFO: --------------------------------------
九月 24, 2013 11:08:03 上午 com.wangjie.aoptest2.invohandler.LogInvoHandler invoke
INFO: ____invoke method: login; args: [lisi, 654321]; return: login success
九月 24, 2013 11:08:03 上午 com.wangjie.aoptest2.invohandler.LogInvoHandler invoke
INFO: ____invoke method: find; args: null; return: find success

&nbsp;

