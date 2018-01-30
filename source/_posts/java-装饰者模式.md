---
title: java 装饰者模式
tags: [java, pattern, decorator]
date: 2012-11-20 16:07:00
---

IPerson：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午3:43:04
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> IPerson {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> canDo();
}</span></pre>
</div>

Person：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午3:44:04
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Person <span style="color: #0000ff;">implements</span><span style="color: #000000;"> IPerson{

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> canDo() {
        System.out.println(</span>"I can code"<span style="color: #000000;">);
    }
}</span></pre>
</div>

Decorator（所有Person装饰者的父类）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午3:44:55
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Decorator <span style="color: #0000ff;">implements</span><span style="color: #000000;"> IPerson{
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> IPerson person;
    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> Decorator(IPerson person) {
        </span><span style="color: #0000ff;">this</span>.person =<span style="color: #000000;"> person;
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> canDo() {
        person.canDo();
    }
}</span></pre>
</div>

DecoratorSwim（Swim装饰--为Peron添加&ldquo;Swim&rdquo;功能）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午3:48:54
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> DecoratorSwim <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Decorator{

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> DecoratorSwim(IPerson person) {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">(person);
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> canDo() {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.canDo();
        System.out.println(</span>"I also can swim"<span style="color: #000000;">);
    }
}</span></pre>
</div>

DecoratorDraw（Draw装饰--为Peron添加&ldquo;Draw&rdquo;功能）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午3:47:29
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> DecoratorDraw <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Decorator{

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> DecoratorDraw(IPerson person) {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">(person);
    }
    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> canDo() {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.canDo();
        System.out.println(</span>"I also can draw"<span style="color: #000000;">);
    }
}</span></pre>
</div>

Test：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午3:49:35
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> Test {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> main(String[] args) {</span><span style="color: #000000;">
        Decorator decorator </span>= <span style="color: #0000ff;">new</span> DecoratorDraw(<span style="color: #0000ff;">new</span> DecoratorSwim(<span style="color: #0000ff;">new</span><span style="color: #000000;"> Person()));
        decorator.canDo();
    }
}</span></pre>
</div>

