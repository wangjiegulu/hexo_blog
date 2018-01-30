---
title: 【IOS】ios中NSUserDefault与android中的SharedPreference用法简单对比
tags: [iOS, NSUserDefault, android, SharedPreference]
date: 2013-11-03 19:37:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span style="color: #ff0000;">**来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/3405308.html](http://www.cnblogs.com/tiantianbyconan/p/3405308.html)**</span>

有Android开发经验的朋友对SharedPreference的用法应该比较亲切的吧，它一般用来保存和读取用户的设置参数，比如保存用户名、加密后的登录密码，是否选择了自动登录，应用选择了哪一套主题皮肤等用户配置信息，使用也非常简单，put/get就能保存/读取这个配置文件，这个文件是用xml形式保存在应用的目录下面

在ios中，也有这么一个类似的工具&mdash;&mdash;NSUserDefault，它支持的数据格式有：NSNumber（Integer、Float、Double），NSString，NSDate，NSArray，NSDictionary，BOOL类型。它是存储在/Library/Prefereces里面，有个plist文件。

下面，我们写一个demo来测试下：

界面很简单，两个button，一个label

点击第一个button用来保存数据，点击第二个button用来显示数据到label

代码如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> - (IBAction)buttonClicked:(<span style="color: #0000ff;">id</span><span style="color: #000000;">)sender {
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">switch</span><span style="color: #000000;"> ([sender tag]) {
</span><span style="color: #008080;"> 3</span>         <span style="color: #0000ff;">case</span> <span style="color: #800080;">1</span>: <span style="color: #008000;">//</span><span style="color: #008000;"> 保存数据</span>
<span style="color: #008080;"> 4</span> <span style="color: #000000;">            [self saveData];
</span><span style="color: #008080;"> 5</span>             <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 6</span>         <span style="color: #0000ff;">case</span> <span style="color: #800080;">2</span>: <span style="color: #008000;">//</span><span style="color: #008000;"> 显示数据</span>
<span style="color: #008080;"> 7</span> <span style="color: #000000;">            [self showData];
</span><span style="color: #008080;"> 8</span>             <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 9</span>             
<span style="color: #008080;">10</span>         <span style="color: #0000ff;">default</span><span style="color: #000000;">:
</span><span style="color: #008080;">11</span>             <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">13</span> <span style="color: #000000;">}
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span> - (<span style="color: #0000ff;">void</span><span style="color: #000000;">)saveData
</span><span style="color: #008080;">17</span> <span style="color: #000000;">{
</span><span style="color: #008080;">18</span>     NSUserDefaults *userDef =<span style="color: #000000;"> [NSUserDefaults standardUserDefaults];
</span><span style="color: #008080;">19</span>     
<span style="color: #008080;">20</span>     [userDef setObject:<span style="color: #800000;">@"</span><span style="color: #800000;">wangjie</span><span style="color: #800000;">"</span> forKey:<span style="color: #800000;">@"</span><span style="color: #800000;">name</span><span style="color: #800000;">"</span><span style="color: #000000;">];
</span><span style="color: #008080;">21</span>     [userDef setInteger:<span style="color: #800080;">23</span> forKey:<span style="color: #800000;">@"</span><span style="color: #800000;">age</span><span style="color: #800000;">"</span><span style="color: #000000;">];
</span><span style="color: #008080;">22</span>     [userDef setBool:YES forKey:<span style="color: #800000;">@"</span><span style="color: #800000;">isAutoLogin</span><span style="color: #800000;">"</span><span style="color: #000000;">];
</span><span style="color: #008080;">23</span>     [userDef setDouble:<span style="color: #800080;">115.0</span> forKey:<span style="color: #800000;">@"</span><span style="color: #800000;">weight</span><span style="color: #800000;">"</span><span style="color: #000000;">];
</span><span style="color: #008080;">24</span>     [userDef setFloat:<span style="color: #800080;">171.2</span> forKey:<span style="color: #800000;">@"</span><span style="color: #800000;">height</span><span style="color: #800000;">"</span><span style="color: #000000;">];
</span><span style="color: #008080;">25</span>     
<span style="color: #008080;">26</span> <span style="color: #000000;">    [userDef synchronize];
</span><span style="color: #008080;">27</span>     NSLog(<span style="color: #800000;">@"</span><span style="color: #800000;">save success!</span><span style="color: #800000;">"</span><span style="color: #000000;">);
</span><span style="color: #008080;">28</span> <span style="color: #000000;">}
</span><span style="color: #008080;">29</span> 
<span style="color: #008080;">30</span> - (<span style="color: #0000ff;">void</span><span style="color: #000000;">)showData
</span><span style="color: #008080;">31</span> <span style="color: #000000;">{
</span><span style="color: #008080;">32</span>     NSUserDefaults *userDef =<span style="color: #000000;"> [NSUserDefaults standardUserDefaults];
</span><span style="color: #008080;">33</span>     NSString *content = [NSString stringWithFormat:<span style="color: #800000;">@"</span><span style="color: #800000;">name: %@; age: %d; isAutoLogin: %hhd; weight: %f; height: %f</span><span style="color: #800000;">"</span><span style="color: #000000;">,
</span><span style="color: #008080;">34</span>                          [userDef stringForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">name</span><span style="color: #800000;">"</span><span style="color: #000000;">],
</span><span style="color: #008080;">35</span>                          [userDef integerForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">age</span><span style="color: #800000;">"</span><span style="color: #000000;">],    
</span><span style="color: #008080;">36</span>                          [userDef boolForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">isAutoLogin</span><span style="color: #800000;">"</span><span style="color: #000000;">],
</span><span style="color: #008080;">37</span>                          [userDef doubleForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">weight</span><span style="color: #800000;">"</span><span style="color: #000000;">],
</span><span style="color: #008080;">38</span>                          [userDef floatForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">height</span><span style="color: #800000;">"</span><span style="color: #000000;">]
</span><span style="color: #008080;">39</span> <span style="color: #000000;">                         ];
</span><span style="color: #008080;">40</span>     
<span style="color: #008080;">41</span> <span style="color: #000000;">    [[self showLb] setText:content];
</span><span style="color: #008080;">42</span>     NSLog(<span style="color: #800000;">@"</span><span style="color: #800000;">%@</span><span style="color: #800000;">"</span><span style="color: #000000;">, [[self showLb] text]);
</span><span style="color: #008080;">43</span> }</pre>
</div>

一：启动应用程序后直接点击第二个button，因为数据之前没有被保存，所以显示的数据都是默认的数据：

![](http://images.cnitblog.com/blog/378300/201311/03193439-fb31db723c6f47598890193e5f312773.png)

二：点击第一个button（数据会被插入），再点击第二个button（已有数据可以显示），此时情况如下：

![](http://images.cnitblog.com/blog/378300/201311/03193549-8ad8294a8e8b46d49770631d4937e47f.png)

&nbsp;

