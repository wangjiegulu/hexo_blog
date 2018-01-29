---
title: 关于Android 的内存泄露及分析
tags: []
date: 2014-04-22 10:09:00
---

一、 Android的内存机制
Android的程序由Java语言编写，所以Android的内存管理与Java的内存管理相似。程序员通过new为对象分配内存，所有对象在java堆内分配空间；然而对象的释放是由垃圾回收器来完成的.
那么GC怎么能够确认某一个对象是不是已经被废弃了呢？Java采用了有向图的原理。Java将引用关系考虑为图的有向边，有向边从引用者指向引用对象。线程对象可以作为有向图的起始顶点，该图就是从起始顶点开始的一棵树，根顶点可以到达的对象都是有效对象，GC不会回收这些对象。如果某个对象 (连通子图)与这个根顶点不可达(注意，该图为有向图)，那么我们认为这个(这些)对象不再被引用，可以被GC回收。

二、Android的内存溢出

1、内存泄露导致

由于我们程序的失误，长期保持某些资源（如Context）的引用，造成内存泄露，资源造成得不到释放。&nbsp;

Android 中常见就是Activity 被引用没有在调用finish之后却没有释放，第二次打开activity 又重新创建，这样的内存泄露则会导致内存的溢出。
2、占用内存较多的对象

&nbsp;保存了多个耗用内存过大的对象（如Bitmap）或加载单个超大的图片，造成内存超出限制。

三、常见的内存泄漏
<span>1.万恶的static</span>
&nbsp; static是Java中的一个关键字，当用它来修饰成员变量时，那么该变量就属于该类，而不是该类的实例。

&nbsp;&nbsp;&nbsp; private static Activity mContext;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; //省略&nbsp;

&nbsp;如何才能有效的避免这种引用的发生呢？

&nbsp;&nbsp;&nbsp; 第一，应该尽量避免static成员变量引用资源耗费过多的实例，比如Context。

&nbsp;&nbsp;&nbsp; 第二、Context尽量使用Application Context，因为Application的Context的生命周期比较长，引用它不会出现内存泄露的问题。

&nbsp;&nbsp;&nbsp; 第三、使用WeakReference代替强引用。比如可以使用WeakReference&lt;Context&gt; mContextRef;

<span>2.线程惹的祸</span>
线程也是造成内存泄露的一个重要的源头。线程产生内存泄露的主要原因在于线程生命周期的不可控。我们来考虑下面一段代码。

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MyActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Activity {     
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">@Override     
</span><span style="color: #008080;"> 3</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {         
</span><span style="color: #008080;"> 4</span>   <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);         
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">  setContentView(R.layout.main);         
</span><span style="color: #008080;"> 6</span>   <span style="color: #0000ff;">new</span><span style="color: #000000;"> MyThread().start();     
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">}       
</span><span style="color: #008080;"> 8</span> <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">class</span> MyThread <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Thread{         
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">@Override         
</span><span style="color: #008080;">10</span>   <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> run() {             
</span><span style="color: #008080;">11</span>   <span style="color: #0000ff;">super</span><span style="color: #000000;">.run();             
</span><span style="color: #008080;">12</span>   <span style="color: #008000;">//</span><span style="color: #008000;">do somthing         </span>
<span style="color: #008080;">13</span> <span style="color: #000000;">}     
</span><span style="color: #008080;">14</span> <span style="color: #000000;">} 
</span><span style="color: #008080;">15</span> }  </pre>
</div>

<span>我们思考一个问题：假设MyThread的run函数是一个很费时的操作，当调用finish的时候Activity 会销毁掉吗？</span>

&nbsp;

&nbsp; &nbsp;事实上由于我们的线程是Activity的内部类，所以MyThread中保存了Activity的一个引用，当MyThread的run函数没有结束时，MyThread是不会被销毁的，因此它所引用的老的Activity也不会被销毁，因此就出现了内存泄露的问题。

&nbsp;

<span>**解决方案**</span>

&nbsp;&nbsp;&nbsp; 第一、将线程的内部类，改为静态内部类。

&nbsp;&nbsp;&nbsp; 第二、如果需要引用Acitivity，使用弱引用。
&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; 另外在使用handler 的时候， 尤其用到循环调用的时候，在Activity 退出的时候注意移除。否则也会导致泄露

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> ThreadDemo <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Activity {  
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = "ThreadDemo"<span style="color: #000000;">;  
</span><span style="color: #008080;"> 3</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> count = 0<span style="color: #000000;">;  
</span><span style="color: #008080;"> 4</span>     <span style="color: #0000ff;">private</span> Handler mHandler =  <span style="color: #0000ff;">new</span><span style="color: #000000;"> Handler();  
</span><span style="color: #008080;"> 5</span>       
<span style="color: #008080;"> 6</span>     <span style="color: #0000ff;">private</span> Runnable mRunnable = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Runnable() {  
</span><span style="color: #008080;"> 7</span>           
<span style="color: #008080;"> 8</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> run() {  
</span><span style="color: #008080;"> 9</span>             <span style="color: #008000;">//</span><span style="color: #008000;">为了方便 查看，我们用Log打印出来   </span>
<span style="color: #008080;">10</span>             Log.e(TAG, Thread.currentThread().getName() + " " +<span style="color: #000000;">count);    
</span><span style="color: #008080;">11</span>             <span style="color: #008000;">//</span><span style="color: #008000;">每2秒执行一次   </span>
<span style="color: #008080;">12</span>             mHandler.postDelayed(mRunnable, 2000<span style="color: #000000;">);  
</span><span style="color: #008080;">13</span> <span style="color: #000000;">        }   
</span><span style="color: #008080;">14</span> <span style="color: #000000;">    };  
</span><span style="color: #008080;">15</span> <span style="color: #000000;">    @Override  
</span><span style="color: #008080;">16</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {  
</span><span style="color: #008080;">17</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);  
</span><span style="color: #008080;">18</span> <span style="color: #000000;">        setContentView(R.layout.main);   
</span><span style="color: #008080;">19</span>         <span style="color: #008000;">//</span><span style="color: #008000;">通过Handler启动线程   </span>
<span style="color: #008080;">20</span> <span style="color: #000000;">        mHandler.post(mRunnable);  
</span><span style="color: #008080;">21</span> <span style="color: #000000;">    }  
</span><span style="color: #008080;">22</span>       
<span style="color: #008080;">23</span> <span style="color: #000000;">}
</span><span style="color: #008080;">24</span> <span style="color: #008000;">//</span><span style="color: #008000;">所以我们在应用退出时，要将线程销毁，我们只要在Activity中的，onDestory()方法处理一下就OK了，如下代码所示:</span>
<span style="color: #008080;">25</span> <span style="color: #000000;">@Override  
</span><span style="color: #008080;">26</span>   <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onDestroy() {  
</span><span style="color: #008080;">27</span> <span style="color: #000000;">    mHandler.removeCallbacks(mRunnable);  
</span><span style="color: #008080;">28</span>     <span style="color: #0000ff;">super</span><span style="color: #000000;">.onDestroy();  
</span><span style="color: #008080;">29</span> <span style="color: #000000;">  } 
</span><span style="color: #008080;">30</span>  </pre>
</div>

<span>3.Bitmap</span>
可以说出现OutOfMemory问题的绝大多数人，都是因为Bitmap的问题。因为Bitmap占用的内存实在是太多了，特别是分辨率大的图片，如果要显示多张那问题就更显著了。

&nbsp;&nbsp;&nbsp; 解决方案：

&nbsp;&nbsp;&nbsp; 第一、及时的销毁。

&nbsp;&nbsp;&nbsp; 虽然，系统能够确认Bitmap分配的内存最终会被销毁，但是由于它占用的内存过多，所以很可能会超过java堆的限制。因此，在用完Bitmap时，要及时的recycle掉。recycle并不能确定立即就会将Bitmap释放掉，但是会给虚拟机一个暗示：&ldquo;该图片可以释放了&rdquo;。

&nbsp;&nbsp;&nbsp; 第二、设置一定的采样率。

&nbsp;&nbsp;&nbsp; 有时候，我们要显示的区域很小，没有必要将整个图片都加载出来，而只需要记载一个缩小过的图片，这时候可以设置一定的采样率，那么就可以大大减小占用的内存。如下面的代码：

private ImageView preview;&nbsp;&nbsp;

BitmapFactory.Options options = new BitmapFactory.Options();&nbsp;&nbsp;

options.inSampleSize = 2;//图片宽高都为原来的二分之一，即图片为原来的四分之一&nbsp;&nbsp;

Bitmap bitmap = BitmapFactory.decodeStream(cr.openInputStream(uri), null, options);&nbsp; preview.setImageBitmap(bitmap);&nbsp;

第三、巧妙的运用软引用（SoftRefrence）

&nbsp;&nbsp;&nbsp; 有些时候，我们使用Bitmap后没有保留对它的引用，因此就无法调用Recycle函数。这时候巧妙的运用软引用，可以使Bitmap在内存快不足时得到有效的释放。
&nbsp;&nbsp;

<span>4.行踪诡异的Cursor</span>

&nbsp;&nbsp;&nbsp; Cursor是Android查询数据后得到的一个管理数据集合的类，正常情况下，如果查询得到的数据量较小时不会有内存问题，而且虚拟机能够保证Cusor最终会被释放掉。

&nbsp;&nbsp;&nbsp; 然而如果Cursor的数据量特表大，特别是如果里面有Blob信息时，应该保证Cursor占用的内存被及时的释放掉，而不是等待GC来处理。并且Android明显是倾向于编程者手动的将Cursor close掉

&nbsp; 而且android数据库中对Cursor资源的是又限制个数的，如果不及时close掉，会导致别的地方无法获得
&nbsp;&nbsp;&nbsp;&nbsp;
<span>5.构造Adapter时，没有使用缓存的 convertView&nbsp;</span>
&nbsp; 以构造ListView的BaseAdapter为例，在BaseAdapter中提高了方法：
&nbsp; &nbsp;public View getView(int position, View convertView, ViewGroup parent)

&nbsp; AdapterView 在使用View会有一个循环的View队列的，把不显示的View重新投入使用，所以在<span>convertView不为空的时候，不要直接创建新的View</span>

小结:

static:引用了大对象如context

线程：切屏时Activity因为线程引用而没有如期被销毁；handler有关，Activity意外终止但线程还在

Bitmap:要及时recycle,降低采样率

Cursor:要及时关闭

Adapter:没有使用缓存的convertView

&nbsp;

四、内存泄漏调试:
(1).内存监测工具 DDMS --&gt; Heap
&nbsp;用 Heap监测应用进程使用内存情况的步骤如下：
&nbsp; &nbsp; &nbsp; 1\. 切换到DDMS透视图，并确认Devices视图、Heap视图都是打开的；
&nbsp; &nbsp; &nbsp; 2\. 正常与手机链接成功后，在DDMS的Devices视图中将会显示手机设备的序列号，以及设备中正在运行的部分进程信息；
&nbsp; &nbsp; &nbsp; 3\. 点击选中想要监测的进程
&nbsp; &nbsp; &nbsp; 4\. 点击选中Devices视图界面中最上方一排图标中的&ldquo;Update Heap&rdquo;图标；
&nbsp; &nbsp; &nbsp; 5\. 点击Heap视图中的&ldquo;Cause GC&rdquo;按钮；
&nbsp; &nbsp; &nbsp; 6\. 此时在Heap视图中就会看到当前选中的进程的内存使用量的详细情况。
&nbsp; &nbsp;Heap视图界面会定时刷新，在对应用的不断的操作过程中就可以看到内存使用的变化；
&nbsp; 如何才能知道我们的程序是否有内存泄漏的可能性呢。这里需要注意一个值：Heap视图中部有一个Type叫做data object，即数据对象，也就是我们的程序中大量存在的类类型的对象。在data object一行中有一列是&ldquo;Total Size&rdquo;，其值就是当前进程中所有Java数据对象的内存总量，一般情况下，这个值的大小决定了是否会有内存泄漏。可以这样判断：
&nbsp; &nbsp;a) 不断的操作当前应用，同时注意观察data object的Total Size值；
&nbsp; &nbsp;b) 正常情况下Total Size值都会稳定在一个有限的范围内，也就是说由于程序中的的代码良好，没有造成对象不被垃圾回收的情况，所以说 &nbsp;虽然我们不断的操作会不断的生成很多对象，而在虚拟机不断的进行GC的过程中，这些对象都被回收了，内存占用量会会落到一个稳定的水平；
&nbsp; &nbsp; c) 反之如果代码中存在没有释放对象引用的情况，则data object的Total Size值在每次GC后不会有明显的回落，随着操作次数的增多Total Size的值会越来越大，

<span>(2)</span><span>内存分析工具 MAT(Memory Analyzer Tool)</span>
<span>&nbsp; 这里介绍一个极好的内存分析工具 -- Memory Analyzer Tool(MAT)。</span>
<span>&nbsp;&nbsp;MAT是一个Eclipse插件，同时也有单独的RCP客户端。官方下载地址、MAT介绍和详细的使用教程请参见：</span>[www.eclipse.org/mat](http://www.eclipse.org/mat)<span>，在此不进行说明了。另外在MAT安装后的帮助文档里也有完备的使用教程。在此仅举例说明其使用方法。我自己使用的是MAT的eclipse插件，使用插件要比RCP稍微方便一些。插件安装成功后，分析步骤（安装方法有多重，大家随便）</span>
<span>&nbsp;</span>
<span>&nbsp; &nbsp;(a) 生成.hprof文件</span>
<span>&nbsp;&nbsp;</span>
<span>&nbsp; &nbsp; &nbsp; 1\. 打开eclipse并切换到DDMS</span>
<span>&nbsp; &nbsp; &nbsp; 2\. 点击选中想要分析的应用的进程，在Devices视图上方的一行图标按钮中，选中&ldquo;Update Heap&rdquo;。</span>
<span>&nbsp; &nbsp; &nbsp; 3\. 当内存你感觉异常的时候，按下&ldquo;Dump HPROF file&rdquo;按钮，这个时候会提示设置hprof文件的保存路径。</span>
<span>(二) 使用MAT导入.hprof文件</span>
<span>&nbsp; &nbsp; &nbsp;1\. 通过</span><span>/ANDROID_SDK/tools目录下的hprof-conv.exe工具（使用命令同adb），输入命令hprof-conv xxx.hprof yyy.hprof，其中xxx.hprof为原始文件，yyy.hprof为转换过后的文件。</span>
<span>&nbsp; &nbsp; 2\. 在Eclipse中点击Windows-&gt;Open Perspective-&gt;Other-&gt;Memory Analysis perspective界面。在MAT中点击File-&gt;Open File，浏览并导入刚刚 转换而得到的.hprof文件。</span>
<span>(三) 使用MAT的视图工具分析内存</span>
<span>&nbsp;&nbsp;导入.hprof文件以后，MAT会自动解析并生成报告，报告中会列出使用内存过多或者初始化的实例过多的类。</span>

<span>&nbsp;点击Dominator Tree，并按Package分组，选择报告中提到的可疑实例的类，在弹出菜单中选择List objects-&gt;With incoming references。这时会列出所有可疑类，右键点击某一项，并选择Path to GC Roots -&gt; exclude weak/soft references，会进一步筛选出跟程序相关的所有有内存泄露的类。据此，可以追踪到代码中的某一个产生泄露的类。</span>
<span><span>&nbsp;</span><span>&nbsp; 主要是看可疑类的引用是因为什么代码的引用而导致无法释放的</span></span>
<span>&nbsp;&nbsp;总之使用MAT分析内存查找内存泄漏的根本思路，就是找到哪个类的对象的引用没有被释放，找到没有被释放的原因，也就可以很容易定位代码中的哪些片段的逻辑有问题了。</span>

&nbsp;

转自：http://blog.csdn.net/cs_epo/article/details/7843766

&nbsp;