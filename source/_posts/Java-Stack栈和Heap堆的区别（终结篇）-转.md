---
title: '[Java]Stack栈和Heap堆的区别（终结篇）[转]'
tags: []
date: 2012-12-26 21:11:00
---

<div>首先分清楚Stack，Heap的中文翻译：Stack&mdash;栈，Heap&mdash;堆。</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在中文里，Stack可以翻译为&ldquo;堆栈&rdquo;，所以我直接查找了计算机术语里面堆和栈开头的词语：</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**堆存储： heapstorage&nbsp;&nbsp;&nbsp; 堆存储分配： heapstorage allocation&nbsp; 堆存储管理： heap storage management**</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**&nbsp;栈编址： stack addressing&nbsp; &nbsp;栈变换：stack transformation&nbsp; 栈存储器：stack memory&nbsp; 栈单元： stack cell**</div>
<div>&nbsp;</div>
<div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;接着，总结在Java里面Heap和Stack分别存储数据的不同。</div>
<div>&nbsp;</div>
<div>
<table border="1" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Heap(堆)</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Stack(栈)</td>
</tr>
<tr>
<td>&nbsp;JVM中的功能</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;内存数据区&nbsp;&nbsp;&nbsp;&nbsp;</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 内存指令区</td>
</tr>
<tr>
<td>&nbsp;存储数据</td>
<td>&nbsp;&nbsp;&nbsp;&nbsp; 对象实例(1)</td>
<td>&nbsp;基本数据类型, 指令代码,常量,对象的引用地址(2)</td>
</tr>
</tbody>
</table>
</div>
<div>1\. 保存对象实例，实际上是保存对象实例的属性值，属性的类型和对象本身的类型标记等，并不保存对象的方法（方法是指令，保存在stack中）。
&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp; 对象实例在heap中分配好以后，需要在stack中保存一个4字节的heap内存地址，用来定位该对象实例在heap中的位置，便于找到该对象实例。</div>
<div>&nbsp;</div>
<div>2\. 基本数据类型包括byte、int、char、long、float、double、boolean和short。
&nbsp;&nbsp;&nbsp; 函数方法属于指令.</div>
<div>&nbsp;</div>
<div>&nbsp;=======================&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
<div>&nbsp; 引用网上广泛流传的&ldquo;Java堆和栈的区别&rdquo;里面对堆和栈的介绍；</div>
<div>**&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; "Java 的堆是一个运行时数据区,类的(对象从中分配空间。这些对象通过new、newarray、anewarray和multianewarray等指令建立，它们不需要程序代码来显式的释放。堆是由垃圾回收来负责的，堆的优势是可以动态地分配内存大小，生存期也不必事先告诉编译器，因为它是在运行时动态分配内存的，Java的垃圾收集器会自动收走这些不再使用的数据。但缺点是，由于要在运行时动态分配内存，存取速度较慢。"**</div>
<div>**&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &ldquo;栈的优势是，存取速度比堆要快，仅次于寄存器，栈数据可以共享。但缺点是，存在栈中的数据大小与生存期必须是确定的，缺乏灵活性。栈中主要存放一些基本类型的变量（,int, short, long, byte, float, double, boolean, char）和对象句柄。**&nbsp;**&rdquo;**</div>
<div>**&nbsp;&nbsp;&nbsp;**</div>
<div>**&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;**可见，垃圾回收GC是针对堆Heap的，而栈因为本身是FILO - first in, last out. 先进后出，能够自动释放。 这样就能明白到new创建的，都是放到堆Heap！</div>

本文出自 &ldquo;[学习Android](http://android.blog.51cto.com/)&rdquo; 博客，请务必保留此出处[http://android.blog.51cto.com/268543/50100](http://android.blog.51cto.com/268543/50100)