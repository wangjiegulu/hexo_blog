---
title: Android通过VideoView实现视频播放
tags: [android, VideoView]
date: 2012-03-01 15:02:00
---

在Android系统中，是通过MediaPalyer类播放媒体文件的（包括视频和音频）。虽然这个类已经比较简单了，但是还需要控制各种状态，对于视频还需要设置输出窗口，还是需要仔细研究的。为了避免这些麻烦事儿，Android框架提供了VideoView类来封装MediaPalyer，这个VideoView类非常好用。Android自带的程序Gallery也是用VideoView实现的。本文以实例介绍怎样用VideoView来实现VideoPlayer，本文也参考了Android自带程序Gallery的实现。

<span>创建一个VideoPlayer的工程。main.xml文件如下：</span>

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 3</span> <span style="color: #ff0000;">    android:orientation</span><span style="color: #0000ff;">="vertical"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 4</span> <span style="color: #ff0000;">    android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 5</span> <span style="color: #ff0000;">    android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">VideoView </span><span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/video_view"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 8</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 9</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="match_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">10</span> <span style="color: #ff0000;">            android:layout_centerInParent</span><span style="color: #0000ff;">="true"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">11</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

<span><span>VideoPlayer.java文件如下：</span></span>

<div class="cnblogs_code" onclick="cnblogs_code_show('2921b33f-64c6-4bde-a0dd-3a775ab970fa')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_2921b33f-64c6-4bde-a0dd-3a775ab970fa" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span> com.simon;
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span> android.app.Activity;
<span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span> android.media.MediaPlayer;
<span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span> android.net.Uri;
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span> android.os.Bundle;
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span> android.os.Environment;
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span> android.util.Log;
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span> android.widget.MediaController;
<span style="color: #008080;">10</span> <span style="color: #0000ff;">import</span> android.widget.VideoView;
<span style="color: #008080;">11</span> <span style="color: #0000ff;">import</span> android.content.pm.ActivityInfo;
<span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> VideoPlayer <span style="color: #0000ff;">extends</span> Activity <span style="color: #0000ff;">implements</span> MediaPlayer.OnErrorListener,
<span style="color: #008080;">14</span>         MediaPlayer.OnCompletionListener {
<span style="color: #008080;">15</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = "VideoPlayer";
<span style="color: #008080;">16</span>     <span style="color: #0000ff;">private</span> VideoView mVideoView;
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">private</span> Uri mUri;
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> mPositionWhenPaused = -1;
<span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span>     <span style="color: #0000ff;">private</span> MediaController mMediaController;
<span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span>     <span style="color: #008000;">/**</span><span style="color: #008000;"> Called when the activity is first created. </span><span style="color: #008000;">*/</span>
<span style="color: #008080;">23</span>     @Override
<span style="color: #008080;">24</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCreate(Bundle savedInstanceState) {
<span style="color: #008080;">25</span>         <span style="color: #0000ff;">super</span>.onCreate(savedInstanceState);
<span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span>         setContentView(R.layout.main);
<span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span>         <span style="color: #008000;">//</span><span style="color: #008000;">Set the screen to landscape.</span><span style="color: #008000;">
</span><span style="color: #008080;">30</span>         <span style="color: #0000ff;">this</span>.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
<span style="color: #008080;">31</span> 
<span style="color: #008080;">32</span>         mVideoView = (VideoView)findViewById(R.id.video_view);
<span style="color: #008080;">33</span> 
<span style="color: #008080;">34</span>         <span style="color: #008000;">//</span><span style="color: #008000;">Video file</span><span style="color: #008000;">
</span><span style="color: #008080;">35</span>         mUri = Uri.parse(Environment.getExternalStorageDirectory() + "/1.3gp");
<span style="color: #008080;">36</span> 
<span style="color: #008080;">37</span>         <span style="color: #008000;">//</span><span style="color: #008000;">Create media controller</span><span style="color: #008000;">
</span><span style="color: #008080;">38</span>         mMediaController = <span style="color: #0000ff;">new</span> MediaController(<span style="color: #0000ff;">this</span>);
<span style="color: #008080;">39</span>         mVideoView.setMediaController(mMediaController);
<span style="color: #008080;">40</span>     }
<span style="color: #008080;">41</span> 
<span style="color: #008080;">42</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onStart() {
<span style="color: #008080;">43</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> Play Video</span><span style="color: #008000;">
</span><span style="color: #008080;">44</span>         mVideoView.setVideoURI(mUri);
<span style="color: #008080;">45</span>         mVideoView.start();
<span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span>         <span style="color: #0000ff;">super</span>.onStart();
<span style="color: #008080;">48</span>     }
<span style="color: #008080;">49</span> 
<span style="color: #008080;">50</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onPause() {
<span style="color: #008080;">51</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> Stop video when the activity is pause.</span><span style="color: #008000;">
</span><span style="color: #008080;">52</span>         mPositionWhenPaused = mVideoView.getCurrentPosition();
<span style="color: #008080;">53</span>         mVideoView.stopPlayback();
<span style="color: #008080;">54</span>         Log.d(TAG, "OnStop: mPositionWhenPaused = " + mPositionWhenPaused);
<span style="color: #008080;">55</span>         Log.d(TAG, "OnStop: getDuration  = " + mVideoView.getDuration());
<span style="color: #008080;">56</span> 
<span style="color: #008080;">57</span>         <span style="color: #0000ff;">super</span>.onPause();
<span style="color: #008080;">58</span>     }
<span style="color: #008080;">59</span> 
<span style="color: #008080;">60</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onResume() {
<span style="color: #008080;">61</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> Resume video player</span><span style="color: #008000;">
</span><span style="color: #008080;">62</span>         <span style="color: #0000ff;">if</span>(mPositionWhenPaused &gt;= 0) {
<span style="color: #008080;">63</span>             mVideoView.seekTo(mPositionWhenPaused);
<span style="color: #008080;">64</span>             mPositionWhenPaused = -1;
<span style="color: #008080;">65</span>         }
<span style="color: #008080;">66</span> 
<span style="color: #008080;">67</span>         <span style="color: #0000ff;">super</span>.onResume();
<span style="color: #008080;">68</span>     }
<span style="color: #008080;">69</span> 
<span style="color: #008080;">70</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span> onError(MediaPlayer player, <span style="color: #0000ff;">int</span> arg1, <span style="color: #0000ff;">int</span> arg2) {
<span style="color: #008080;">71</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">false</span>;
<span style="color: #008080;">72</span>     }
<span style="color: #008080;">73</span> 
<span style="color: #008080;">74</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCompletion(MediaPlayer mp) {
<span style="color: #008080;">75</span>         <span style="color: #0000ff;">this</span>.finish();
<span style="color: #008080;">76</span>     }
<span style="color: #008080;">77</span> }</pre>
</div>
</div>

<span><span><span>本例中只是播放外存储器（一般是sd卡）上的1.3gp文件。在onCreate方法中创建了Media control，这个组件可以控制视频的播放，暂停，回复，seek等操作，不需要你实现。</span></span></span>

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> mMediaController = <span style="color: #0000ff;">new</span> MediaController(<span style="color: #0000ff;">this</span>);
<span style="color: #008080;">2</span> mVideoView.setMediaController(mMediaController);</pre>
</div>

然后只需要调用VideoView类的setVideoURI设置播放文件，start方法开始播放即可。 为了节省系统资源，一般需要在Activity的onPause方法中，暂停视频的播放。因为Activity已经不在前台了。在Activity的onResume中恢复视频的播放，因为这是Activity又变成前台程序了。不清楚的朋友可以去查看Activity lifecycle。 你可以通过实现MediaPlayer.OnErrorListener来监听MediaPlayer上报的错误信息。实现MediaPlayer.OnCompletionListener接口，将会在Video播完的时候得到通知，本例只是简单的结束程序。 你可能注意到，我们没有管理MediaPalyer的各种状态，这些状态都让VideoView给封装了，并且，当VideoView创建的时候，MediaPalyer对象将会创建，当VideoView对象销毁的时候，MediaPlayer对象将会释放。这样基本可以傻瓜式的实现媒体播放器了，太Easy了吧。

<span>
</span>

