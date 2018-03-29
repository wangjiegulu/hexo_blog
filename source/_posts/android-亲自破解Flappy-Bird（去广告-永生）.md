---
title: '[android]亲自破解Flappy Bird（去广告+永生）'
tags: [android, 破解, Flappy Bird]
date: 2014-02-11 17:21:00
---

<span>听说最近Flappy Bird很火，但是难度令人发指，于是怒了，亲自破解（去广告+永生）</span>

<span>只要不碰到地上，永远不死，直接穿过管道- -！下载地址：</span>[http://pan.baidu.com/s/1kT7bA55](http://pan.baidu.com/s/1kT7bA55)

注意：只支持android版本

效果图：

![](http://images.cnitblog.com/blog/378300/201402/111729388451360.png)&nbsp;![](http://images.cnitblog.com/blog/378300/201402/111730054144409.png)

&nbsp;

&nbsp;

反编译后修改smali：

<span style="color: #ff0000;">去广告：</span>

修改Flappy_Bird\smali\com\dotgears\a.smali和b.smali中run()方法中对应修改为：

<div class="cnblogs_code">
<pre><span style="color: #000000;">const/4 v1, 0x4

    invoke-virtual {v0, v1}, Lcom/google/ads/AdView;-&gt;setVisibility(I)V</span></pre>
</div>

&nbsp;

<span style="line-height: 1.5; color: #ff0000;">永生（取消碰撞检测即可）：</span>

修改Flappy_Bird\smali\com\dotgears\flappy\c.smali

<div class="cnblogs_code">
<pre><span style="color: #000000;">.method public static a(IIIIIIII)Z
    .locals 1

    add-int v0, p0, p2

    if-lt v0, p4, :cond_0

    add-int v0, p4, p6

    if-gt p0, v0, :cond_0

    add-int v0, p1, p3

    if-lt v0, p5, :cond_0

    add-int v0, p5, p7

    if-le p1, v0, :cond_1

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0

    :cond_1
    const/4 v0, 0x1

    goto :goto_0
.end method</span></pre>
</div>

改为：

<div class="cnblogs_code">
<pre><span style="color: #000000;">.method public static a(IIIIIIII)Z
    .locals 1

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0

    :cond_1
    const/4 v0, 0x1

    goto :goto_0
.end method</span></pre>
</div>

&nbsp;

