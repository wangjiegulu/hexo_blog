---
title: Java数据结构和算法——汉诺塔问题
tags: [java]
date: 2013-03-04 17:18:00
---

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.tiantian.algorithms;
</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 *    _|_1              |                |
 *   __|__2             |                |
 *  ___|___3            |                |            (1).把A上的4个木块移动到C上。
 * ____|____4           |                |
 *     A                B                C
 * 
 *     |                |                |
 *     |               _|_1              |
 *     |              __|__2             |            要完成(1)的效果，必须要把1、2、3木块移动到B，这样才能把4移动到C
 * ____|____4        ___|___3            |            如：代码中的&ldquo;调用(XX)&rdquo;
 *     A                B                C
 *     
 *     |                |                |
 *     |               _|_1              |
 *     |              __|__2             |            此时，题目就变成了把B上的3个木块移动到C上，回到了题目(1)
 *     |             ___|___3        ____|____4        如：代码中的&ldquo;调用(YY)&rdquo;
 *     A                B                C
 *     
 *     然后循环这个过程
 * 
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-3-4 下午4:09:53
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> HanoiTowerTest {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> main(String[] args) {
        doTowers(</span>4, 'A', 'B', 'C'<span style="color: #000000;">);
    }

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span> doTowers(<span style="color: #0000ff;">int</span> topN, <span style="color: #0000ff;">char</span> from, <span style="color: #0000ff;">char</span> inter, <span style="color: #0000ff;">char</span><span style="color: #000000;"> to){
        </span><span style="color: #0000ff;">if</span>(topN == 1<span style="color: #000000;">){
            System.out.println(</span>"最后把木块1从" + from + "移动到" +<span style="color: #000000;"> to);
        }</span><span style="color: #0000ff;">else</span><span style="color: #000000;">{
            doTowers(topN </span>- 1, from, to, inter); <span style="color: #008000;">//</span><span style="color: #008000;"> 调用(XX)</span>
            System.out.println("把木块" + topN + "从" + from + "移动到" +<span style="color: #000000;"> to);
            doTowers(topN </span>- 1, inter, from ,to); <span style="color: #008000;">//</span><span style="color: #008000;"> 调用(YY)</span>
<span style="color: #000000;">        }

    }
}</span></pre>
</div>

&nbsp;

