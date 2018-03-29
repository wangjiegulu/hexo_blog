---
title: 【IOS】从android角度来实现(理解)IOS的UITableView
tags: [iOS, android, UITableView]
date: 2013-11-02 02:58:00
---

本人从在学校开始到现在上班（13年毕业）一直做web和android方面的开发，最近才开学习及ios的开发，所以ios学习中有不当之处，请大家留言指点

以前从来没有接触过Objective-C这门语言，不过我想面向对象编程应该大体思想都差不多

在ios中的UITableView学习中，开发过android的朋友应该马上会联想到ListView和GridView这两个控件，接下来以ListView为例子，跟UITableView做个对比，看看它们实现的方式有什么相同之处。怎么样能让有android开发经验的朋友，马上掌握UITableView这个控件

先新建一个demo，取名TabViewTest（原谅我吧- -，本来要取名TableViewTest，谁知脑抽新建项目的时候写错了，诶。。。算了，将错就错吧- -）

![](http://images.cnitblog.com/blog/378300/201311/02004946-2ab5264ce0bc47dfb40b97a3911a7079.png)

ios没有命名空间的概念，没有包概念（这也是为什么ios中的类都有前缀的原因，比如NS等），所以上面像&ldquo;包&rdquo;一样的文件夹都是我自己新建的&ldquo;group&rdquo;，只是为了看起来比较有分层的概念而已，打开finder，到项目文件里一看如下图，妈呀- -，所有的类都挤在一个文件夹里面。。。这是我觉得蛋疼的地方之一-。-

![](http://images.cnitblog.com/blog/378300/201311/02005325-69347d3e30f24d08bfe4d313ca0895f0.png)

&nbsp;

再回来看看我们项目结构，我分的几个group，如果我把controller这个group的名字改成&ldquo;activity&rdquo;，android开发者肯定有种似曾相识的感觉了：

controller：控制层group，相当于android中的activity

layout：布局group，相当于android中res目录下的layout（xml布局文件）

model：这个不用说就知道放了什么东西了，经典的Person这个测试用的数据结构

adapter：为了还念android中的适配器，然后我就取了这么个group名字

&nbsp;

好了，现在正式开始代码的编写

打开MainAppDelegate.m，它实现了UIApplicationDelegate协议，所以可以在该类中实现应用状态的回调函数

在application:didFinishLaunchingWithOptions:方法（应用程序启动时回调该方法）中来设置它的RootController（根控制器，不知道这样翻译专不专业- -），我的实现是生成一个UINavigationController作为它的root controller，然后把自己新建的一个NaviRootController（在这个Controller中放入一个UITableView，具体下面会讲到）作为UINavigationController的root view，具体代码如下（这个不是我们本次的重点，所以一笔带过）：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *<span style="color: #000000;">)launchOptions
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 3</span>     self.window =<span style="color: #000000;"> [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
</span><span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 生成UINavigationController对象，并设置它的RootController</span>
<span style="color: #008080;"> 6</span>     UINavigationController *naviController =<span style="color: #000000;"> [[UINavigationController alloc] initWithRootViewController:[[NaviRootController alloc] init]];
</span><span style="color: #008080;"> 7</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 然后把NavigationController设置为window的RootViewController</span>
<span style="color: #008080;"> 8</span> <span style="color: #000000;">    [self.window setRootViewController:naviController];
</span><span style="color: #008080;"> 9</span>     
<span style="color: #008080;">10</span>     self.window.backgroundColor =<span style="color: #000000;"> [UIColor whiteColor];
</span><span style="color: #008080;">11</span> <span style="color: #000000;">    [self.window makeKeyAndVisible];
</span><span style="color: #008080;">12</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> YES;
</span><span style="color: #008080;">13</span> }</pre>
</div>

然后，重点就是NaviRootController这个Controller了，

新建NaviRootController，继承UIViewController，在.h文件中：

声明一个NSMutableArray对象data作为tableView的数据源（<span style="color: #993366;">**相当于在android中经常用到的ArrayList&lt;Person&gt; data。NSMutableArray是数组，ArrayList在java中的底层实现本来用的就是数组，所以很好理解**</span>）

声明一个用于适配和绑定tableView数据的适配器TableViewAdapter<span class="s1"> *adapter（这个类是我自己写的，下面会讲到。**<span style="color: #993366;">java中要实现ListView中的数据绑定适配，也要通过一个继承于BaseAdapter的适配器进行数据的适配吧，也很好理解</span>**）</span>

<span class="s1">声明一个UITableView对象（**<span style="color: #993366;">相当于android中，在activity中声明一个private ListView listView;</span>**）</span>

具体代码如下：

<div class="cnblogs_code" onclick="cnblogs_code_show('d9c08616-f985-42b7-8567-4e754559345f')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_d9c08616-f985-42b7-8567-4e754559345f" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;">//</span><span style="color: #008000;">  NaviRootController.h
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;">//</span><span style="color: #008000;">  TabViewTest
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 5</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Created by WANGJIE on 13-10-31.
</span><span style="color: #008080;"> 6</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Copyright (c) 2013年 WANGJIE. All rights reserved.
</span><span style="color: #008080;"> 7</span> <span style="color: #008000;">//
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">#import</span> &lt;UIKit/UIKit.h&gt;
<span style="color: #008080;">10</span> <span style="color: #0000ff;">@class</span><span style="color: #000000;"> TableViewAdapter;
</span><span style="color: #008080;">11</span> <span style="color: #0000ff;">@interface</span><span style="color: #000000;"> NaviRootController : UIViewController
</span><span style="color: #008080;">12</span> <span style="color: #000000;">{
</span><span style="color: #008080;">13</span>     NSMutableArray *<span style="color: #000000;">data;
</span><span style="color: #008080;">14</span>     TableViewAdapter *<span style="color: #000000;">adapter;
</span><span style="color: #008080;">15</span> <span style="color: #000000;">}
</span><span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span> @property (weak, nonatomic) IBOutlet UITableView *<span style="color: #000000;">tableView;
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span> @property NSMutableArray *<span style="color: #000000;">data;
</span><span style="color: #008080;">21</span> @property(strong, nonatomic) TableViewAdapter *<span style="color: #000000;">adapter;
</span><span style="color: #008080;">22</span> <span style="color: #0000ff;">@end</span></pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

好了，声明部分到此为止，接下来看看实现部分

<span class="s1">刚刚在</span>MainAppDelegate中，生成了一个NaviRootController对象，然后把这个对象加入到了UINavigationController对象的rootViewController。生成NaviRootController对象的时候，调用了init方法，我们应该在init方法里面去初始化布局，如下：

<div class="cnblogs_code" onclick="cnblogs_code_show('a6fdcec3-37ba-4d77-9aef-f331f7e32fea')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_a6fdcec3-37ba-4d77-9aef-f331f7e32fea" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> - (<span style="color: #0000ff;">id</span><span style="color: #000000;">)init
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 3</span>     self = [self initWithNibName:<span style="color: #800000;">@"</span><span style="color: #800000;">navi_root</span><span style="color: #800000;">"</span><span style="color: #000000;"> bundle:nil];
</span><span style="color: #008080;"> 4</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> self;
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span> - (<span style="color: #0000ff;">id</span>)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *<span style="color: #000000;">)nibBundleOrNil
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 9</span>     self =<span style="color: #000000;"> [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
</span><span style="color: #008080;">10</span>     <span style="color: #0000ff;">if</span><span style="color: #000000;"> (self) {
</span><span style="color: #008080;">11</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 获得当前导航栏对象</span>
<span style="color: #008080;">12</span>         UINavigationItem *item =<span style="color: #000000;"> [self navigationItem];
</span><span style="color: #008080;">13</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置导航栏左按钮</span>
<span style="color: #008080;">14</span>         UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">leftButton</span><span style="color: #800000;">"</span><span style="color: #000000;"> style:UIBarButtonItemStylePlain target:self action:@selector(buttonClickedAction:)];
</span><span style="color: #008080;">15</span>         [leftButton setTag:<span style="color: #800080;">0</span><span style="color: #000000;">];
</span><span style="color: #008080;">16</span> <span style="color: #000000;">        [item setLeftBarButtonItem:leftButton animated:YES];
</span><span style="color: #008080;">17</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置导航栏右按钮</span>
<span style="color: #008080;">18</span>         UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">rightButton</span><span style="color: #800000;">"</span><span style="color: #000000;"> style:UIBarButtonItemStyleDone target:self action:@selector(buttonClickedAction:)];
</span><span style="color: #008080;">19</span>         [rightButton setTag:<span style="color: #800080;">1</span><span style="color: #000000;">];
</span><span style="color: #008080;">20</span> <span style="color: #000000;">        [item setRightBarButtonItem:rightButton animated:YES];
</span><span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">23</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> self;
</span><span style="color: #008080;">24</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

我们在init方法中调用了initWithNibName:bundle:方法，传入了NibName这个字符串，这个是什么？**<span style="color: #993366;">Nib是ios里面的布局文件，也就是相当于android中类似main.xml这种布局文件吧，现在传进去的时nibname，也就是布局文件的名称。</span>**所以，没错，传入这个参数后，当前的controller（也就是NaviRootController就跟传入的这个布局文件绑定起来了，**<span style="color: #993366;">类似于android中activity中熟悉的setContentView(R.layout.main)一样！</span>**）

然后我们顺便看看navi_root.xib这个布局文件：

![](http://images.cnitblog.com/blog/378300/201311/02020218-ffb5db3c54c54a6184439f8ed617d17d.png)

整个界面就一个UITableView，对了，别忘了在File's Owner中把custom class改成NaviRootController。键盘按住control，用鼠标拖动左边栏的&ldquo;Table View&rdquo;到NaviRootController.h中，会自动生成UITableView声明，并自动绑定。

接下来回到NaviRootController的初始化方法中。

initWithNibName:bundle:方法中后面的UINavigationItem相关的代码是用来设置导航栏左边和右边的按钮，既然是个demo，所以也没什么特别的功能，就是点击下，跳出一个UIAlertView提示下，所以一笔带过。

此时界面布局和controller已经绑定起来了，现在的任务应该是初始化UITableView的数据，也就是上面的data属性，但是在哪里初始化比较好呢？

刚开始，我是直接在init方法中直接去初始化数据，但是失败了，不管在init方法中初始化多少次（data调用多少次addObject方法），data的值永远都是nil（相当于在android中，不管调用多少次list.add(...)方法，list中一条数据也没有加入！），猜测是因为在init方法中的时候属性和控件都还没有被初始化。

最后我的解决办法就是在viewDidLoad方法中去加载数据。viewDidLoad这个回调方法是会在控件加载完毕后调用，所以，我认为在这里去加载数据和做控件的初始化操作是比较合理的。

viewDidLoad方法实现如下：

<div class="cnblogs_code" onclick="cnblogs_code_show('c37254db-2ea2-4e96-a9e5-0ecddbd3c8cc')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_c37254db-2ea2-4e96-a9e5-0ecddbd3c8cc" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> - (<span style="color: #0000ff;">void</span><span style="color: #000000;">)viewDidLoad
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 3</span>     
<span style="color: #008080;"> 4</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> Do any additional setup after loading the view.</span>
<span style="color: #008080;"> 5</span> <span style="color: #000000;">    [super viewDidLoad];
</span><span style="color: #008080;"> 6</span>     
<span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">if</span> (!<span style="color: #000000;">adapter) {
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">        [self initData];
</span><span style="color: #008080;"> 9</span>         
<span style="color: #008080;">10</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 生成适配器委托对象</span>
<span style="color: #008080;">11</span>         adapter =<span style="color: #000000;"> [[TableViewAdapter alloc] initWithSource:data Controller:self];
</span><span style="color: #008080;">12</span>         
<span style="color: #008080;">13</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置适配器委托对象</span>
<span style="color: #008080;">14</span> <span style="color: #000000;">        [[self tableView] setDelegate:adapter];
</span><span style="color: #008080;">15</span> <span style="color: #000000;">        [[self tableView] setDataSource:adapter];
</span><span style="color: #008080;">16</span>         
<span style="color: #008080;">17</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">18</span> }</pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

如上，在viewDidLoad中，我先去初始化数据（demo中的实现其实就是循环了14次，往data中加了14个Person对象），然后生成一个适配器委托对象，传入data（数据源）和self（当前controller对象），**<span style="color: #993366;">相当于android中的 adapter = new MyAdapter(list, this);有木有？？！！</span>**

然后，setDelegate用来设置委托对象（**<span style="color: #993366;">相当于android中的listView.setAdapter(adapter)</span>**），setDataSource用来设置数据源。

这里，完整地列出NaviRootController的代码：

<div class="cnblogs_code" onclick="cnblogs_code_show('2b006d06-4ce6-4ae1-bd35-7ec3abe88e1e')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_2b006d06-4ce6-4ae1-bd35-7ec3abe88e1e" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #008000;">//</span>
<span style="color: #008080;">  2</span> <span style="color: #008000;">//</span><span style="color: #008000;">  NaviRootController.m
</span><span style="color: #008080;">  3</span> <span style="color: #008000;">//</span><span style="color: #008000;">  TabViewTest
</span><span style="color: #008080;">  4</span> <span style="color: #008000;">//</span>
<span style="color: #008080;">  5</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Created by WANGJIE on 13-10-31.
</span><span style="color: #008080;">  6</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Copyright (c) 2013年 WANGJIE. All rights reserved.
</span><span style="color: #008080;">  7</span> <span style="color: #008000;">//
</span><span style="color: #008080;">  8</span> 
<span style="color: #008080;">  9</span> <span style="color: #0000ff;">#import</span> <span style="color: #800000;">"</span><span style="color: #800000;">NaviRootController.h</span><span style="color: #800000;">"</span>
<span style="color: #008080;"> 10</span> <span style="color: #0000ff;">#import</span> <span style="color: #800000;">"</span><span style="color: #800000;">Person.h</span><span style="color: #800000;">"</span>
<span style="color: #008080;"> 11</span> <span style="color: #0000ff;">#import</span> <span style="color: #800000;">"</span><span style="color: #800000;">TableViewAdapter.h</span><span style="color: #800000;">"</span>
<span style="color: #008080;"> 12</span> 
<span style="color: #008080;"> 13</span> <span style="color: #0000ff;">@interface</span><span style="color: #000000;"> NaviRootController ()
</span><span style="color: #008080;"> 14</span> 
<span style="color: #008080;"> 15</span> <span style="color: #0000ff;">@end</span>
<span style="color: #008080;"> 16</span> 
<span style="color: #008080;"> 17</span> <span style="color: #0000ff;">@implementation</span><span style="color: #000000;"> NaviRootController
</span><span style="color: #008080;"> 18</span> <span style="color: #0000ff;">@synthesize</span><span style="color: #000000;"> data, adapter;
</span><span style="color: #008080;"> 19</span> 
<span style="color: #008080;"> 20</span> - (<span style="color: #0000ff;">id</span><span style="color: #000000;">)init
</span><span style="color: #008080;"> 21</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 22</span>     self = [self initWithNibName:<span style="color: #800000;">@"</span><span style="color: #800000;">navi_root</span><span style="color: #800000;">"</span><span style="color: #000000;"> bundle:nil];
</span><span style="color: #008080;"> 23</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> self;
</span><span style="color: #008080;"> 24</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 25</span> 
<span style="color: #008080;"> 26</span> - (<span style="color: #0000ff;">id</span>)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *<span style="color: #000000;">)nibBundleOrNil
</span><span style="color: #008080;"> 27</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 28</span>     self =<span style="color: #000000;"> [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
</span><span style="color: #008080;"> 29</span>     <span style="color: #0000ff;">if</span><span style="color: #000000;"> (self) {
</span><span style="color: #008080;"> 30</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> Custom initialization
</span><span style="color: #008080;"> 31</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 获得当前导航栏对象</span>
<span style="color: #008080;"> 32</span>         UINavigationItem *item =<span style="color: #000000;"> [self navigationItem];
</span><span style="color: #008080;"> 33</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置导航栏左按钮</span>
<span style="color: #008080;"> 34</span>         UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">leftButton</span><span style="color: #800000;">"</span><span style="color: #000000;"> style:UIBarButtonItemStylePlain target:self action:@selector(buttonClickedAction:)];
</span><span style="color: #008080;"> 35</span>         [leftButton setTag:<span style="color: #800080;">0</span><span style="color: #000000;">];
</span><span style="color: #008080;"> 36</span> <span style="color: #000000;">        [item setLeftBarButtonItem:leftButton animated:YES];
</span><span style="color: #008080;"> 37</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置导航栏右按钮</span>
<span style="color: #008080;"> 38</span>         UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">rightButton</span><span style="color: #800000;">"</span><span style="color: #000000;"> style:UIBarButtonItemStyleDone target:self action:@selector(buttonClickedAction:)];
</span><span style="color: #008080;"> 39</span>         [rightButton setTag:<span style="color: #800080;">1</span><span style="color: #000000;">];
</span><span style="color: #008080;"> 40</span> <span style="color: #000000;">        [item setRightBarButtonItem:rightButton animated:YES];
</span><span style="color: #008080;"> 41</span>         
<span style="color: #008080;"> 42</span>         
<span style="color: #008080;"> 43</span>         
<span style="color: #008080;"> 44</span>         
<span style="color: #008080;"> 45</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 46</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> self;
</span><span style="color: #008080;"> 47</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 48</span> 
<span style="color: #008080;"> 49</span> <span style="color: #008000;">/*</span><span style="color: #008000;">*
</span><span style="color: #008080;"> 50</span> <span style="color: #008000;"> * 初始化列表数据
</span><span style="color: #008080;"> 51</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 52</span> - (<span style="color: #0000ff;">void</span><span style="color: #000000;">)initData
</span><span style="color: #008080;"> 53</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 54</span>     data =<span style="color: #000000;"> [[NSMutableArray alloc] init];
</span><span style="color: #008080;"> 55</span>     NSLog(<span style="color: #800000;">@"</span><span style="color: #800000;">%@</span><span style="color: #800000;">"</span><span style="color: #000000;">, NSStringFromSelector(_cmd));
</span><span style="color: #008080;"> 56</span>     Person *<span style="color: #000000;">person;
</span><span style="color: #008080;"> 57</span>     <span style="color: #0000ff;">for</span> (<span style="color: #0000ff;">int</span> i = <span style="color: #800080;">0</span>; i &lt; <span style="color: #800080;">14</span>; i++<span style="color: #000000;">) {
</span><span style="color: #008080;"> 58</span>         person =<span style="color: #000000;"> [[Person alloc] init];
</span><span style="color: #008080;"> 59</span>         [person setName:[<span style="color: #800000;">@"</span><span style="color: #800000;">name</span><span style="color: #800000;">"</span><span style="color: #000000;"> stringByAppendingString:
</span><span style="color: #008080;"> 60</span>                          [NSString stringWithFormat:<span style="color: #800000;">@"</span><span style="color: #800000;">%d</span><span style="color: #800000;">"</span><span style="color: #000000;">, i]
</span><span style="color: #008080;"> 61</span> <span style="color: #000000;">                         ]
</span><span style="color: #008080;"> 62</span> <span style="color: #000000;">         ];
</span><span style="color: #008080;"> 63</span>         
<span style="color: #008080;"> 64</span>         [person setAge:i + <span style="color: #800080;">10</span><span style="color: #000000;">];
</span><span style="color: #008080;"> 65</span>         
<span style="color: #008080;"> 66</span>         [person setPic:[UIImage imageNamed:<span style="color: #800000;">@"</span><span style="color: #800000;">Hypno.png</span><span style="color: #800000;">"</span><span style="color: #000000;">]];
</span><span style="color: #008080;"> 67</span>         
<span style="color: #008080;"> 68</span> <span style="color: #000000;">        [data addObject:person];
</span><span style="color: #008080;"> 69</span>         
<span style="color: #008080;"> 70</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 71</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 72</span> 
<span style="color: #008080;"> 73</span> 
<span style="color: #008080;"> 74</span> - (<span style="color: #0000ff;">void</span><span style="color: #000000;">)viewDidLoad
</span><span style="color: #008080;"> 75</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 76</span>     
<span style="color: #008080;"> 77</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> Do any additional setup after loading the view.</span>
<span style="color: #008080;"> 78</span> <span style="color: #000000;">    [super viewDidLoad];
</span><span style="color: #008080;"> 79</span>     
<span style="color: #008080;"> 80</span>     <span style="color: #0000ff;">if</span> (!<span style="color: #000000;">adapter) {
</span><span style="color: #008080;"> 81</span> <span style="color: #000000;">        [self initData];
</span><span style="color: #008080;"> 82</span>         
<span style="color: #008080;"> 83</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 生成适配器委托对象</span>
<span style="color: #008080;"> 84</span>         adapter =<span style="color: #000000;"> [[TableViewAdapter alloc] initWithSource:data Controller:self];
</span><span style="color: #008080;"> 85</span>         
<span style="color: #008080;"> 86</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 设置适配器委托对象</span>
<span style="color: #008080;"> 87</span> <span style="color: #000000;">        [[self tableView] setDelegate:adapter];
</span><span style="color: #008080;"> 88</span> <span style="color: #000000;">        [[self tableView] setDataSource:adapter];
</span><span style="color: #008080;"> 89</span>         
<span style="color: #008080;"> 90</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 91</span>     
<span style="color: #008080;"> 92</span>     
<span style="color: #008080;"> 93</span>     
<span style="color: #008080;"> 94</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 95</span> 
<span style="color: #008080;"> 96</span> - (<span style="color: #0000ff;">void</span><span style="color: #000000;">)viewWillAppear:(BOOL)animated
</span><span style="color: #008080;"> 97</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 98</span> <span style="color: #000000;">    [super viewWillAppear:YES];
</span><span style="color: #008080;"> 99</span>     
<span style="color: #008080;">100</span> <span style="color: #000000;">}
</span><span style="color: #008080;">101</span> 
<span style="color: #008080;">102</span> - (<span style="color: #0000ff;">void</span><span style="color: #000000;">)didReceiveMemoryWarning
</span><span style="color: #008080;">103</span> <span style="color: #000000;">{
</span><span style="color: #008080;">104</span> <span style="color: #000000;">    [super didReceiveMemoryWarning];
</span><span style="color: #008080;">105</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> Dispose of any resources that can be recreated.</span>
<span style="color: #008080;">106</span> <span style="color: #000000;">}
</span><span style="color: #008080;">107</span> 
<span style="color: #008080;">108</span> <span style="color: #008000;">//</span><span style="color: #008000;"> 按钮点击事件回调</span>
<span style="color: #008080;">109</span> - (<span style="color: #0000ff;">void</span>)buttonClickedAction:(<span style="color: #0000ff;">id</span><span style="color: #000000;">)sender
</span><span style="color: #008080;">110</span> <span style="color: #000000;">{
</span><span style="color: #008080;">111</span>     
<span style="color: #008080;">112</span>     NSString *<span style="color: #000000;">message;
</span><span style="color: #008080;">113</span>     <span style="color: #0000ff;">switch</span><span style="color: #000000;"> ([sender tag]) {
</span><span style="color: #008080;">114</span>         <span style="color: #0000ff;">case</span> <span style="color: #800080;">0</span><span style="color: #000000;">:
</span><span style="color: #008080;">115</span>             message = <span style="color: #800000;">@"</span><span style="color: #800000;">left button clicked!</span><span style="color: #800000;">"</span><span style="color: #000000;">;
</span><span style="color: #008080;">116</span>             <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">117</span>         <span style="color: #0000ff;">case</span> <span style="color: #800080;">1</span><span style="color: #000000;">:
</span><span style="color: #008080;">118</span>             message = <span style="color: #800000;">@"</span><span style="color: #800000;">right button clicked!</span><span style="color: #800000;">"</span><span style="color: #000000;">;
</span><span style="color: #008080;">119</span>             <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">120</span>         <span style="color: #0000ff;">default</span><span style="color: #000000;">:
</span><span style="color: #008080;">121</span>             message = <span style="color: #800000;">@"</span><span style="color: #800000;">unknow button clicked!</span><span style="color: #800000;">"</span><span style="color: #000000;">;
</span><span style="color: #008080;">122</span>             <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;">123</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">124</span>     
<span style="color: #008080;">125</span>     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">alert view</span><span style="color: #800000;">"</span> message:message <span style="color: #0000ff;">delegate</span>:self cancelButtonTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">cancel</span><span style="color: #800000;">"</span><span style="color: #000000;"> otherButtonTitles:nil, nil];
</span><span style="color: #008080;">126</span> <span style="color: #000000;">    [alert show];
</span><span style="color: #008080;">127</span> <span style="color: #000000;">}
</span><span style="color: #008080;">128</span> 
<span style="color: #008080;">129</span> 
<span style="color: #008080;">130</span> 
<span style="color: #008080;">131</span> 
<span style="color: #008080;">132</span> <span style="color: #0000ff;">@end</span></pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

&nbsp;

好了，UITableView的初始化准备工作到此就做完了，现在干嘛？

当然去编写TableViewAdapter这个类啊。数据源有了（并且初始化完毕），用以显示的控件（UITableView）有了（并且初始化完毕），而且两个还已经绑定起来了。但是还缺的就是一个角色，这个角色可以把数据源中的数据跟控件中某个相应的子控件适配起来。比如数据源中有4个数据，A、B、C、D，控件有one、two、three、four这4个控件，这个角色的任务就是告诉one：你要显示的数据是A；告诉two：你要显示的数据是B；告诉three：你要显示的数据是C；告诉four：你要显示的数据是D！

这个角色就是适配器！也就是下面要说的那个TableViewAdapter

新建TableViewAdapter，实现<span class="s1">&lt;</span>UITableViewDataSource<span class="s1">, </span>UITableViewDelegate<span class="s1">&gt;这两个协议（**<span style="color: #993366;">android中适配器不同的是要继承BaseAdapter类</span>**）。声明一个数据源data，这个数据源是从NaviRootController中传过来的已经初始化好了的数据源，还有一个声明是</span>NaviRootController对象传过来的self（需要什么，就让调用者传什么过来，这个应该都懂的-。-），另外还有一个自己写的初始化方法（自己写初始化方法init打头的方法就行，不像java中的构造方法，方法名要跟类名相同，不过这些都是换汤不换药）

<span class="s1">然后看看TableViewAdapter的实现类（.m）</span>

<span class="s1">实现了这两个协议后，你就能覆写里面的一些UITableView的回调方法了，比如：</span>

tableView:numberOfRowsInSection:方法，返回数据源的数量就行了（**<span style="color: #993366;">类似android的adapter中自己要实现的getCount()方法！</span>**）

tableView:cellForRowAtIndexPath:这个是方法是这里最关键的一个方法了，就是在这里进行数据的适配工作（**<span style="color: #993366;">类似android的adapter中自己要实现的getView()方法！</span>**），这里返回的UITableViewCell就是类表中的一项（**<span style="color: #993366;">类似android中listview的一个item</span>**），这个一项的布局，已经在table_cell.xib文件中布局完毕，如下：

![](http://images.cnitblog.com/blog/378300/201311/02023019-1ef72e95265e49d892e83e1a84ef423c.png)

设置File's Owner为TableViewAdapter，设置Table View Cell的identifier设置为&ldquo;MyTableCell&rdquo;，这个可以任意取名，但是要跟后面的方法实现中统一（跟哪里统一？作用是神马？这些下面会讲到，别急-。-），接着设置ImageView的tag为1，nameLabel的tag为2，ageLabel的tag为3（tag的作用，下面也会讲到）。

接着，回到tableView:cellForRowAtIndexPath:这个方法，它的实现如下所示：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *<span style="color: #000000;">)indexPath
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 3</span>     Person *p =<span style="color: #000000;"> [data objectAtIndex:[indexPath row]];
</span><span style="color: #008080;"> 4</span>     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<span style="color: #800000;">@"</span><span style="color: #800000;">MyTableCell</span><span style="color: #800000;">"</span><span style="color: #000000;">];
</span><span style="color: #008080;"> 5</span>     <span style="color: #0000ff;">if</span> (!<span style="color: #000000;">cell) {
</span><span style="color: #008080;"> 6</span>         NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:<span style="color: #800000;">@"</span><span style="color: #800000;">table_cell</span><span style="color: #800000;">"</span><span style="color: #000000;"> owner:self options:nil];
</span><span style="color: #008080;"> 7</span>         cell = [nibViews objectAtIndex:<span style="color: #800080;">0</span><span style="color: #000000;">];
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span>     UIImageView *picIv = (UIImageView *)[cell viewWithTag:<span style="color: #800080;">1</span><span style="color: #000000;">];
</span><span style="color: #008080;">11</span>     UILabel *nameLb = (UILabel *)[cell viewWithTag:<span style="color: #800080;">2</span><span style="color: #000000;">];
</span><span style="color: #008080;">12</span>     UILabel *ageLb = (UILabel *)[cell viewWithTag:<span style="color: #800080;">3</span><span style="color: #000000;">];
</span><span style="color: #008080;">13</span>     
<span style="color: #008080;">14</span> <span style="color: #000000;">    [nameLb setText:[p name]];
</span><span style="color: #008080;">15</span>     [ageLb setText:[NSString stringWithFormat:<span style="color: #800000;">@"</span><span style="color: #800000;">%d</span><span style="color: #800000;">"</span><span style="color: #000000;">, [p age]]];
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    [picIv setImage:[p pic]];
</span><span style="color: #008080;">17</span>     
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> cell;
</span><span style="color: #008080;">19</span> }</pre>
</div>

如上图所示：

第3行，是用于获得所要显示的数据Person对象（**<span style="color: #993366;">这里的[indexPath row]相当于android的adapter的getView方法的position参数</span>**。indexPath中有两个参数，row和section，表示行和列，因为我们现在是要显示一个列表，所以只需要row这个参数就可以了）

<span class="s1">第4行，是用于资源的重复利用，根据标示符&ldquo;MyTableCell&rdquo;去获得一个可再利用的UITableViewCell（这里的标示符就要跟前面在xib文件中设置的标示符要一致，这样才能被识别到，然后在这里被获取到），如果没有获得到，就去新创建一个UITableViewCell。</span>

<span class="s1">第6、7行，是创建新的UITableViewCell的代码，通过mianBundle的loadNibNamed:owner:options方法根据xib的名字去创建（**<span style="color: #993366;">跟</span>**</span>**<span style="color: #993366;">android<span class="s1">中的</span>LayoutInflater.inflate()</span>**<span class="s1">**<span style="color: #993366;">方法通过R.layout.xxx的方法创建类似</span>**），loadNibNamed:owner:options返回的是一个数组，得到第一个就是UITableViewCell了。</span>

<span class="s1">第10、11、12行，是获取到或者新建的cell通过控件之前设置的tag来获得相应地子控件（现在知道之前为什么要设置xib文件中控件的tag了吧？**<span style="color: #993366;">这个跟</span>**</span>**<span style="color: #993366;">android<span class="s1">中的</span>findViewByTag/findViewById又是很类似的！</span>**<span class="s1">）</span>

<span class="s1">第14、15、16行，是为刚刚获得的cell中的子控件适配数据，让它可以把数据显示出来。</span>

<span class="s1">第18行，把生成数据适配完毕的UITableViewCell返回出去（**<span style="color: #993366;">这跟android中的也是很类似</span>**）</span>

TableViewAdapter代码如下：

<div class="cnblogs_code" onclick="cnblogs_code_show('ec009a67-93fe-4bda-989e-4fcd65ed3131')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_ec009a67-93fe-4bda-989e-4fcd65ed3131" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;">//</span><span style="color: #008000;">  TableViewAdapter.m
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;">//</span><span style="color: #008000;">  TabViewTest
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 5</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Created by WANGJIE on 13-10-31.
</span><span style="color: #008080;"> 6</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Copyright (c) 2013年 WANGJIE. All rights reserved.
</span><span style="color: #008080;"> 7</span> <span style="color: #008000;">//
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">#import</span> <span style="color: #800000;">"</span><span style="color: #800000;">TableViewAdapter.h</span><span style="color: #800000;">"</span>
<span style="color: #008080;">10</span> <span style="color: #0000ff;">#import</span> <span style="color: #800000;">"</span><span style="color: #800000;">Person.h</span><span style="color: #800000;">"</span>
<span style="color: #008080;">11</span> <span style="color: #0000ff;">#import</span> <span style="color: #800000;">"</span><span style="color: #800000;">NaviRootController.h</span><span style="color: #800000;">"</span>
<span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> <span style="color: #0000ff;">@implementation</span><span style="color: #000000;"> TableViewAdapter
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> - (<span style="color: #0000ff;">id</span>)initWithSource:(NSMutableArray *)source Controller:(NaviRootController *<span style="color: #000000;">)context
</span><span style="color: #008080;">16</span> <span style="color: #000000;">{
</span><span style="color: #008080;">17</span>     NSLog(<span style="color: #800000;">@"</span><span style="color: #800000;">initWithSource...</span><span style="color: #800000;">"</span><span style="color: #000000;">);
</span><span style="color: #008080;">18</span>     self =<span style="color: #000000;"> [super init];
</span><span style="color: #008080;">19</span>     <span style="color: #0000ff;">if</span><span style="color: #000000;"> (self) {
</span><span style="color: #008080;">20</span>         data =<span style="color: #000000;"> source;
</span><span style="color: #008080;">21</span>         controller =<span style="color: #000000;"> context;
</span><span style="color: #008080;">22</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">23</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> self;
</span><span style="color: #008080;">24</span> <span style="color: #000000;">}
</span><span style="color: #008080;">25</span> 
<span style="color: #008080;">26</span> - (NSInteger)tableView:(UITableView *<span style="color: #000000;">)tableView numberOfRowsInSection:(NSInteger)section
</span><span style="color: #008080;">27</span> <span style="color: #000000;">{
</span><span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> [data count];
</span><span style="color: #008080;">30</span> <span style="color: #000000;">}
</span><span style="color: #008080;">31</span> 
<span style="color: #008080;">32</span> - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *<span style="color: #000000;">)indexPath
</span><span style="color: #008080;">33</span> <span style="color: #000000;">{
</span><span style="color: #008080;">34</span>     NSLog(<span style="color: #800000;">@"</span><span style="color: #800000;">%@</span><span style="color: #800000;">"</span><span style="color: #000000;">, NSStringFromSelector(_cmd));
</span><span style="color: #008080;">35</span> <span style="color: #008000;">//</span><span style="color: #008000;">    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
</span><span style="color: #008080;">36</span> <span style="color: #008000;">//</span><span style="color: #008000;">    if (!cell) {
</span><span style="color: #008080;">37</span> <span style="color: #008000;">//</span><span style="color: #008000;">        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
</span><span style="color: #008080;">38</span> <span style="color: #008000;">//</span><span style="color: #008000;">    }
</span><span style="color: #008080;">39</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 获得当前要显示的数据</span>
<span style="color: #008080;">40</span>     Person *p =<span style="color: #000000;"> [data objectAtIndex:[indexPath row]];
</span><span style="color: #008080;">41</span> <span style="color: #008000;">//</span>
<span style="color: #008080;">42</span> <span style="color: #008000;">//</span><span style="color: #008000;">    [[cell textLabel] setText:[p name]];
</span><span style="color: #008080;">43</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 记得在cell.xib文件中设置identifier以达到重用的目的</span>
<span style="color: #008080;">44</span>     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<span style="color: #800000;">@"</span><span style="color: #800000;">MyTableCell</span><span style="color: #800000;">"</span><span style="color: #000000;">];
</span><span style="color: #008080;">45</span>     <span style="color: #0000ff;">if</span> (!<span style="color: #000000;">cell) {
</span><span style="color: #008080;">46</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 通过mainBundle的loadNibNamed方法去加载布局，类似android中的LayoutInflater.inflate()方法</span>
<span style="color: #008080;">47</span>         NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:<span style="color: #800000;">@"</span><span style="color: #800000;">table_cell</span><span style="color: #800000;">"</span><span style="color: #000000;"> owner:self options:nil];
</span><span style="color: #008080;">48</span>         cell = [nibViews objectAtIndex:<span style="color: #800080;">0</span><span style="color: #000000;">];
</span><span style="color: #008080;">49</span> <span style="color: #008000;">//</span><span style="color: #008000;">        cell.selectionStyle = UITableViewCellSelectionStyleNone;</span>
<span style="color: #008080;">50</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">51</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 通过在cell.xib中各控件设置的tag来获得控件，类似android中的findViewByTag/findViewById</span>
<span style="color: #008080;">52</span>     UIImageView *picIv = (UIImageView *)[cell viewWithTag:<span style="color: #800080;">1</span><span style="color: #000000;">];
</span><span style="color: #008080;">53</span>     UILabel *nameLb = (UILabel *)[cell viewWithTag:<span style="color: #800080;">2</span><span style="color: #000000;">];
</span><span style="color: #008080;">54</span>     UILabel *ageLb = (UILabel *)[cell viewWithTag:<span style="color: #800080;">3</span><span style="color: #000000;">];
</span><span style="color: #008080;">55</span>     
<span style="color: #008080;">56</span> <span style="color: #000000;">    [nameLb setText:[p name]];
</span><span style="color: #008080;">57</span>     [ageLb setText:[NSString stringWithFormat:<span style="color: #800000;">@"</span><span style="color: #800000;">%d</span><span style="color: #800000;">"</span><span style="color: #000000;">, [p age]]];
</span><span style="color: #008080;">58</span> <span style="color: #000000;">    [picIv setImage:[p pic]];
</span><span style="color: #008080;">59</span>     
<span style="color: #008080;">60</span>     
<span style="color: #008080;">61</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> cell;
</span><span style="color: #008080;">62</span> <span style="color: #000000;">}
</span><span style="color: #008080;">63</span> 
<span style="color: #008080;">64</span> 
<span style="color: #008080;">65</span> - (<span style="color: #0000ff;">void</span>)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *<span style="color: #000000;">)indexPath
</span><span style="color: #008080;">66</span> <span style="color: #000000;">{
</span><span style="color: #008080;">67</span>     Person *person =<span style="color: #000000;"> [data objectAtIndex:[indexPath row]];
</span><span style="color: #008080;">68</span>     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">cell clicked!</span><span style="color: #800000;">"</span> message:[NSString stringWithFormat:<span style="color: #800000;">@"</span><span style="color: #800000;">%@ clicked!</span><span style="color: #800000;">"</span>, [person name]]<span style="color: #0000ff;">delegate</span>:self cancelButtonTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">cancel</span><span style="color: #800000;">"</span><span style="color: #000000;"> otherButtonTitles:nil, nil];
</span><span style="color: #008080;">69</span> <span style="color: #000000;">    [alert show];
</span><span style="color: #008080;">70</span> 
<span style="color: #008080;">71</span> <span style="color: #000000;">}
</span><span style="color: #008080;">72</span> 
<span style="color: #008080;">73</span> - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *<span style="color: #000000;">)indexPath
</span><span style="color: #008080;">74</span> <span style="color: #000000;">{
</span><span style="color: #008080;">75</span>     <span style="color: #0000ff;">return</span><span style="color: #000000;"> [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height;
</span><span style="color: #008080;">76</span> <span style="color: #000000;">}
</span><span style="color: #008080;">77</span> 
<span style="color: #008080;">78</span> 
<span style="color: #008080;">79</span> <span style="color: #0000ff;">@end</span></pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

&nbsp;

好了！到此为止整个UITableView实现的流程基本完成了，可以看出跟android的ListView和GridView的实现流程很相似，理解了其中一个，另一个也能很好的理解它的工作流程。

最后来一张效果图：

![](http://images.cnitblog.com/blog/378300/201311/02030600-2d2805ccefc04db9b4e0085845980d43.png)

