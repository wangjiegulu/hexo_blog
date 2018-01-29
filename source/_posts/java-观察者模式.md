---
title: java 观察者模式
tags: []
date: 2012-11-20 17:12:00
---

IWatched：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午4:58:25
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> IWatched {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> addWatcher(IWatcher watcher);
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> removeWatcher(IWatcher watcher);
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> notifyWatchers(String msg);
}</span></pre>
</div>

IWatcher：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午4:55:23
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> IWatcher {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> update(String msg);
}</span></pre>
</div>

Watched：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午5:01:05
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Watched <span style="color: #0000ff;">implements</span><span style="color: #000000;"> IWatched{
    </span><span style="color: #0000ff;">private</span> List&lt;IWatcher&gt; watchers = <span style="color: #0000ff;">new</span> ArrayList&lt;IWatcher&gt;<span style="color: #000000;">();
    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> addWatcher(IWatcher watcher) {
        watchers.add(watcher);
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> removeWatcher(IWatcher watcher) {
        watchers.remove(watcher);
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> notifyWatchers(String msg) {
        </span><span style="color: #0000ff;">for</span><span style="color: #000000;">(IWatcher watcher : watchers){
            watcher.update(msg);
        }
    }
}</span></pre>
</div>

Watcher：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午5:04:56
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Watcher <span style="color: #0000ff;">implements</span><span style="color: #000000;"> IWatcher{

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> update(String msg) {
        System.out.println(msg);
    }
}</span></pre>
</div>

Test：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2012-11-20 下午5:05:26
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> Test {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> main(String[] args) {
        IWatched watched </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Watched();
        IWatcher watcher1 </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Watcher();
        IWatcher watcher2 </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Watcher();
        IWatcher watcher3 </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Watcher();
        watched.addWatcher(watcher1);
        watched.addWatcher(watcher2);
        watched.addWatcher(watcher3);
        watched.notifyWatchers(</span>"I have been clicked!"<span style="color: #000000;">);

        watched.removeWatcher(watcher1);
        watched.notifyWatchers(</span>"what's up"<span style="color: #000000;">);
    }
}</span></pre>
</div>