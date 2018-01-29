---
title: ios7 tableview被navigationbar挡住
tags: []
date: 2013-11-08 13:44:00
---

<pre class="lang-c prettyprint prettyprinted"><span>用ego下拉刷新的时候，每次在ios7时，tableview都会上移。。。导致被navagationbar挡住。
ios6是正常的，于是在init的时候添加如下代码。。。</span></pre>
<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: <span style="color: #800000;">@"</span><span style="color: #800000;">7.0</span><span style="color: #800000;">"</span><span style="color: #000000;"> options: NSNumericSearch];
</span><span style="color: #008080;">2</span> <span style="color: #0000ff;">if</span> (order == NSOrderedSame || order ==<span style="color: #000000;"> NSOrderedDescending)
</span><span style="color: #008080;">3</span> <span style="color: #000000;">{
</span><span style="color: #008080;">4</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> OS version &gt;= 7.0</span>
<span style="color: #008080;">5</span>     self.edgesForExtendedLayout =<span style="color: #000000;"> UIRectEdgeNone;
</span><span style="color: #008080;">6</span> }</pre>
</div>

&nbsp;

转自：http://www.cnblogs.com/x1957/archive/2013/09/29/3345264.html