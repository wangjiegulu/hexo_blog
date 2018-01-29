---
title: '[Android]异步加载图片，内存缓存，文件缓存，imageview显示图片时增加淡入淡出动画'
tags: []
date: 2014-02-28 18:13:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span style="color: #ff0000;">**来自天天博客：[<span style="color: #ff0000;">http://www.cnblogs.com/tiantianbyconan/p/3574131.html</span>](http://www.cnblogs.com/tiantianbyconan/p/3574131.html "view: [Android]异步加载图片，内存缓存，文件缓存，imageview显示图片时增加淡入淡出动画")&nbsp;**</span>

这个可以实现ImageView异步加载图片，内存缓存，文件缓存，imageview显示图片时增加淡入淡出动画。

github地址：[https://github.com/wangjiegulu/ImageLoaderSample](https://github.com/wangjiegulu/ImageLoaderSample)

解决了：

1\. listview加载oom问题

2\. listview加载时卡顿的现象

3\. listview加载时item中图片重复错位等情况

可以配置：

1\. 设置加载图片的最大尺寸

2\. 设置默认图片的显示

3\. 设置图片位图模式

4\. 设置内存缓存的最大值。

5\. 文件缓存保存的目录

　　这个框架基本的代码是很久以前不知道哪里弄的，零零碎碎的，现在已经优化了很多，所以现在上传到github上共享。

　　讲讲使用方式吧：

&nbsp;

首先使用前下载源码或者jar包（见github：[https://github.com/wangjiegulu/ImageLoaderSample](https://github.com/wangjiegulu/ImageLoaderSample)）

然后进行图片加载器（ImageLoader）的配置和初始化，推荐的方法如下：

新建MyApplication类，继承Application，在onCreate中增加如下代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 14-2-27
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Time: 上午11:25
</span><span style="color: #008080;"> 6</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MyApplication <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Application{
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate() {
</span><span style="color: #008080;">10</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate();
</span><span style="color: #008080;">11</span> <span style="color: #000000;">        ImageLoader.init(getApplicationContext(),
</span><span style="color: #008080;">12</span>                 <span style="color: #0000ff;">new</span><span style="color: #000000;"> CacheConfig()
</span><span style="color: #008080;">13</span>                     .setDefRequiredSize(600) <span style="color: #008000;">//</span><span style="color: #008000;"> 设置默认的加载图片尺寸（表示宽高任一不超过该值，默认是70px）</span>
<span style="color: #008080;">14</span>                     .setDefaultResId(R.drawable.ic_launcher) <span style="color: #008000;">//</span><span style="color: #008000;"> 设置显示的默认图片（默认是0，即空白图片）</span>
<span style="color: #008080;">15</span>                     .setBitmapConfig(Bitmap.Config.ARGB_8888) <span style="color: #008000;">//</span><span style="color: #008000;"> 设置图片位图模式（默认是Bitmap.CacheConfig.ARGB_8888）</span>
<span style="color: #008080;">16</span>                     .setMemoryCachelimit(Runtime.getRuntime().maxMemory() / 3) <span style="color: #008000;">//</span><span style="color: #008000;"> 设置图片内存缓存大小（默认是Runtime.getRuntime().maxMemory() / 4）
</span><span style="color: #008080;">17</span> <span style="color: #008000;">//</span><span style="color: #008000;">                  .setFileCachePath(Environment.getExternalStorageDirectory().toString() + "/mycache") </span><span style="color: #008000;">//</span><span style="color: #008000;"> 设置文件缓存保存目录</span>
<span style="color: #008080;">18</span> <span style="color: #000000;">        );
</span><span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> <span style="color: #000000;">    &hellip;&hellip;
</span><span style="color: #008080;">24</span> }</pre>
</div>

&nbsp;

然后再AndroidManifest.xml中添加：

<div class="cnblogs_code">
<pre>&lt;<span style="color: #000000;">application
            ......
            android:name</span>="MyApplication"&gt;<span style="color: #000000;">
            ......
</span>&lt;/application&gt;</pre>
</div>

到此，配置已经全部完成：

接下来，使用ImageLoader来加载图片：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> holder.progress.setText("0%"<span style="color: #000000;">);
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">    holder.progress.setVisibility(View.VISIBLE);
</span><span style="color: #008080;"> 3</span>     <span style="color: #0000ff;">final</span> ViewHolder vhr =<span style="color: #000000;"> holder;
</span><span style="color: #008080;"> 4</span>     ImageLoader.getInstances().displayImage(list.get(position), holder.image, <span style="color: #0000ff;">new</span><span style="color: #000000;"> ImageLoader.OnImageLoaderListener() {
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">        @Override
</span><span style="color: #008080;"> 6</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onProgressImageLoader(ImageView imageView, <span style="color: #0000ff;">int</span> currentSize, <span style="color: #0000ff;">int</span><span style="color: #000000;"> totalSize) {
</span><span style="color: #008080;"> 7</span>             vhr.progress.setText(currentSize * 100 / totalSize + "%"<span style="color: #000000;">);
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span> <span style="color: #000000;">        @Override
</span><span style="color: #008080;">11</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onFinishedImageLoader(ImageView imageView, Bitmap bitmap) {
</span><span style="color: #008080;">12</span> <span style="color: #000000;">            vhr.progress.setVisibility(View.GONE);
</span><span style="color: #008080;">13</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">14</span> <span style="color: #000000;">    });
</span><span style="color: #008080;">15</span> <span style="color: #000000;">    或者：
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    ImageLoader.getInstances().displayImage(url, imageIv);
</span><span style="color: #008080;">17</span> <span style="color: #000000;">    或者
</span><span style="color: #008080;">18</span>     ImageLoader.getInstances().displayImage(url, imageIv, 100);</pre>
</div>

备注：

例子中，用到了一部分注解（与ImageLoader功能无关，但是可以简化代码的编写） 可以点下面连接进入：

github：[https://github.com/wangjiegulu/androidInject](https://github.com/wangjiegulu/androidInject)

博客：

[http://www.cnblogs.com/tiantianbyconan/p/3459139.html](http://www.cnblogs.com/tiantianbyconan/p/3459139.html)

[http://www.cnblogs.com/tiantianbyconan/p/3540427.html](http://www.cnblogs.com/tiantianbyconan/p/3540427.html)

&nbsp;

&nbsp;

&nbsp;

&nbsp;