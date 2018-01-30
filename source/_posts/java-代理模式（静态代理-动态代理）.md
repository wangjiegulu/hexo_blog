---
title: java 代理模式（静态代理+动态代理）
tags: [java, pattern, proxy]
date: 2012-11-20 15:22:00
---

静态代理：

ISubject：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午1:49:29
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> ISubject {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> request();
}</span></pre>
</div>

RealSubject（真实角色）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午1:51:37
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> RealSubject <span style="color: #0000ff;">implements</span><span style="color: #000000;"> ISubject{

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> request() {
        System.out.println(</span>"realSubject requesting"<span style="color: #000000;">);
    }
}</span></pre>
</div>

ProxySubject（代理类）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午1:52:22
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> ProxySubject <span style="color: #0000ff;">implements</span><span style="color: #000000;"> ISubject{
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> RealSubject realSubject;
    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> ProxySubject() {
        realSubject </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> RealSubject();
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> request() {
        System.out.println(</span>"do something before"<span style="color: #000000;">);
        realSubject.request();
        System.out.println(</span>"do something after"<span style="color: #000000;">);
    }
}</span></pre>
</div>

Test（客户端测试）:

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午1:54:47
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> Test {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> main(String[] args) {
        ISubject proxySubject </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> ProxySubject();
        proxySubject.request();
    }
}</span></pre>
</div>

------------------------------------------------------------------------------------------------------------------------------

动态代理：

ISubject：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午2:51:31
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> ISubject {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> request();
}</span></pre>
</div>

RealSubject：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午2:52:00
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> RealSubject <span style="color: #0000ff;">implements</span><span style="color: #000000;"> ISubject{

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> request() {
        System.out.println(</span>"realSubject requesting"<span style="color: #000000;">);
    }
}</span></pre>
</div>

SubjectInvocationHandler（调用处理类）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午2:54:38
 * 调用处理类
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> SubjectInvocationHandler <span style="color: #0000ff;">implements</span><span style="color: #000000;"> InvocationHandler{
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Object obj;

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> SubjectInvocationHandler(Object obj) {
        </span><span style="color: #0000ff;">this</span>.obj =<span style="color: #000000;"> obj;
    }

    </span><span style="color: #008000;">/**</span><span style="color: #008000;">
     * 生成代理类工厂
     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> realObj
     * </span><span style="color: #808080;">@return 返回生成的代理类</span>
     <span style="color: #008000;">*/</span>
    <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> Object getProxyInstanceFactory(Object realObj){
        Class</span>&lt;?&gt; classType =<span style="color: #000000;"> realObj.getClass();
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> Proxy.newProxyInstance(classType.getClassLoader(), 
                classType.getInterfaces(), </span><span style="color: #0000ff;">new</span><span style="color: #000000;"> SubjectInvocationHandler(realObj));
    }

    @Override
    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> Object invoke(Object proxy, Method method, Object[] args)
            </span><span style="color: #0000ff;">throws</span><span style="color: #000000;"> Throwable {
        System.out.println(</span>"before"<span style="color: #000000;">);

        method.invoke(obj, args);

        System.out.println(</span>"after"<span style="color: #000000;">);

        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
    }
}</span></pre>
</div>

Test：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午2:56:25
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> Test {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> main(String[] args) {
        RealSubject realSubject </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> RealSubject();
</span><span style="color: #008000;">//</span><span style="color: #008000;">        InvocationHandler handler = new SubjectInvocationHandler(realSubject);
</span><span style="color: #008000;">//</span><span style="color: #008000;">        ISubject subject = (ISubject)Proxy.newProxyInstance(realSubject.getClass().getClassLoader(),
</span><span style="color: #008000;">//</span><span style="color: #008000;">                realSubject.getClass().getInterfaces(), handler);</span>
        ISubject subject =<span style="color: #000000;"> (ISubject)SubjectInvocationHandler.getProxyInstanceFactory(realSubject);
        subject.request();

    }
}</span></pre>
</div>

&nbsp;

&nbsp;

&nbsp;

