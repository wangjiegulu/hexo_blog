---
title: Java 单例模式
tags: [java, pattern, singleton]
date: 2012-11-20 13:41:00
---

Singleton模式主要作用是保证在Java[应用程序](http://baike.baidu.com/view/330120.htm)中，一个类Class只有一个实例存在。

好处：

&nbsp;&nbsp; &nbsp; 和全局变量相比，它对于系统性能的优化更好，因为它是属于什么时候用，什么时候实例化的。

　　一般Singleton模式通常有两种形式:

第一种形式: 也是常用的形式。

<div class="cnblogs_code">
<pre>　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> Singleton {
　　</span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> Singleton instance = <span style="color: #0000ff;">null</span><span style="color: #000000;">;
　　</span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Singleton(){
　　　　</span><span style="color: #008000;">//</span><span style="color: #008000;">do something</span>
<span style="color: #000000;">　　　　}
　　</span><span style="color: #008000;">//</span><span style="color: #008000;">这个方法比下面的有所改进，不用每次都进行生成对象，只是第一次使用时生成实例，提高了效率</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> Singleton getInstance(){
　　　　</span><span style="color: #0000ff;">if</span>(instance==<span style="color: #0000ff;">null</span><span style="color: #000000;">){
　　　　　　instance </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Singleton();
　　　　}
　　　　</span><span style="color: #0000ff;">return</span><span style="color: #000000;"> instance;
　　　　}
　　}</span></pre>
</div>

<span>第二种形式:</span>

<div class="cnblogs_code">
<pre>　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> Singleton {
　　　</span><span style="color: #008000;">//</span><span style="color: #008000;">在自己内部定义自己的一个实例，只供内部调用</span>
　　　<span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> Singleton instance = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Singleton();
　　　</span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Singleton(){
　　　　　</span><span style="color: #008000;">//</span><span style="color: #008000;">do something</span>
<span style="color: #000000;">　　　}
　　　</span><span style="color: #008000;">//</span><span style="color: #008000;">这里提供了一个供外部访问本class的静态方法，可以直接访问</span>
　　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> Singleton getInstance(){
　　　　　</span><span style="color: #0000ff;">return</span><span style="color: #000000;"> instance;
　　　}
　}</span></pre>
</div>

ps：在静态初始化器中创建单件，这段代码就保证了线程安全。

对于多线程的访问，我们多半采用第二种&ldquo;急切&rdquo;的方式，而不用第一种延迟处理的方式，这样就会解决多线程对单一访问点访问造成顺序执行出错的问题。

&nbsp;

还有一种方式：用双重检查枷锁，在getInstance（）中减少使用同步

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> Singleton{
  </span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">volatile</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> Singleton instance;
  </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> Singleton(){}
  </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> Singleton getInstance(){
    </span><span style="color: #0000ff;">if</span>(instance==<span style="color: #0000ff;">null</span><span style="color: #000000;">){
      </span><span style="color: #0000ff;">synchronized</span>(Singletion.<span style="color: #0000ff;">class</span><span style="color: #000000;">){
        </span><span style="color: #0000ff;">if</span>(instance == <span style="color: #0000ff;">null</span><span style="color: #000000;">){
          instance </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Singleton();
        }
      }
    }
    </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> instance;
  }
}</span></pre>
</div>

<span>volatile关键词确保：当instance变量被初始化成Singletion实例时，多个线程正确地处理instance变量，因为它会强制变量去对应内存中共享的变量</span>

