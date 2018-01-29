---
title: 'android:ellipsize属性的含义'
tags: []
date: 2012-05-22 09:34:00
---

<span>TextView及其子类，当字符内容太长显示不下时可以省略号代替未显示的字符；省略号可以在显示区域的起始，中间，结束位置，或者以跑马灯的方式显示文字(textview的状态为被选中)。&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 其实现只需在xml中对textview的ellipsize属性做相应的设置即可。</span>

<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:ellipsize="start"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 省略号在开头&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:ellipsize="middle"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 省略号在中间&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:ellipsize="end"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 省略号在结尾&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; android:ellipsize="marquee"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 跑马灯显示</span>

<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 或者在程序中可通过setEillpsize显式设置。
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 注: EditText不支持marquee这种模式。</span>