---
title: java 适配器模式
tags: [java, adapter]
date: 2012-11-21 17:16:00
---

适配器:基于现有类所提供的服务，向客户提供接口，以满足客户的期望

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;《Java设计模式》

一、类适配器：

OtherOperation（已存在所需功能的类）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-21 下午4:39:18
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> OtherOperation {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> add(<span style="color: #0000ff;">int</span> a, <span style="color: #0000ff;">int</span><span style="color: #000000;"> b){
        </span><span style="color: #0000ff;">return</span> a +<span style="color: #000000;"> b;
    }
}</span></pre>
</div>

Operation（为所要实现的功能定义接口）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-21 下午4:40:12
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> Operation {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> add(<span style="color: #0000ff;">int</span> a, <span style="color: #0000ff;">int</span><span style="color: #000000;"> b);
}</span></pre>
</div>

OperationAdapter（适配器）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-21 下午4:40:41
 * 对象适配器
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> OperationAdapter <span style="color: #0000ff;">extends</span> OtherOperation <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Operation{

}</span></pre>
</div>

-----------------------------------------------------------------------------------------------------------------------------------

二、对象适配器：

假如客户接口期望的功能不止一个，而是多个。
由于java是不能实现多继承的，所以我们不能通过构建一个适配器，让他来继承所有原以完成我们的期望，这时候怎么办呢?只能用适配器的另一种实现--对象适配器：
符合java提倡的编程思想之一，即尽量使用聚合不要使用继承。

OtherAdd和OtherMinus（已存在功能的两个类）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-21 下午4:50:14
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> OtherAdd {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> add(<span style="color: #0000ff;">int</span> a, <span style="color: #0000ff;">int</span><span style="color: #000000;"> b){
        </span><span style="color: #0000ff;">return</span> a +<span style="color: #000000;"> b;
    }
}</span></pre>
</div>
<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-21 下午4:50:46
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> OtherMinus {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> minus(<span style="color: #0000ff;">int</span> a, <span style="color: #0000ff;">int</span><span style="color: #000000;"> b){
        </span><span style="color: #0000ff;">return</span> a -<span style="color: #000000;"> b;
    }
}</span></pre>
</div>

Operation（为所要实现的功能定义接口）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-21 下午4:51:59
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> Operation {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> add(<span style="color: #0000ff;">int</span> a, <span style="color: #0000ff;">int</span><span style="color: #000000;"> b);
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> minus(<span style="color: #0000ff;">int</span> a, <span style="color: #0000ff;">int</span><span style="color: #000000;"> b);
}</span></pre>
</div>

OperationAdapter（<span>通过</span><span>适配类</span><span>的对象来</span><span>获取</span>）：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-21 下午4:52:36
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> OperationAdapter <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Operation{
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> OtherAdd otherAdd;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> OtherMinus otherMinus;

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> OtherAdd getOtherAdd() {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> otherAdd;
    }

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOtherAdd(OtherAdd otherAdd) {
        </span><span style="color: #0000ff;">this</span>.otherAdd =<span style="color: #000000;"> otherAdd;
    }

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> OtherMinus getOtherMinus() {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> otherMinus;
    }

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setOtherMinus(OtherMinus otherMinus) {
        </span><span style="color: #0000ff;">this</span>.otherMinus =<span style="color: #000000;"> otherMinus;
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> add(<span style="color: #0000ff;">int</span> a, <span style="color: #0000ff;">int</span><span style="color: #000000;"> b) {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> otherAdd.add(a, b);
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> minus(<span style="color: #0000ff;">int</span> a, <span style="color: #0000ff;">int</span><span style="color: #000000;"> b) {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> otherMinus.minus(a, b);
    }

}</span></pre>
</div>

