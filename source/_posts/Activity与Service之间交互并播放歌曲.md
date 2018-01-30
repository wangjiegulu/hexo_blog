---
title: Activity与Service之间交互并播放歌曲
tags: [android, activity, service]
date: 2012-03-07 14:04:00
---

Activity与Service之间交互并播放歌曲，为了方便，我把要播放的歌曲定死了，大家可以灵活改进
&nbsp;

![](http://pic002.cnblogs.com/images/2012/378300/2012030714015935.jpg)

MService：

<div class="cnblogs_code" onclick="cnblogs_code_show('ab9dded1-5f97-48dc-8388-a9ca9960b61c')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_ab9dded1-5f97-48dc-8388-a9ca9960b61c" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span> com.tiantian.test;
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span> android.app.Service;
<span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span> android.content.Intent;
<span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span> android.media.MediaPlayer;
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span> android.os.Binder;
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span> android.os.Environment;
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span> android.os.IBinder;
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span> android.util.Log;
<span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MService <span style="color: #0000ff;">extends</span> Service{
<span style="color: #008080;">12</span>     MyBinder myBinder = <span style="color: #0000ff;">new</span> MyBinder();
<span style="color: #008080;">13</span>     <span style="color: #0000ff;">private</span> MediaPlayer mediaPlayer;
<span style="color: #008080;">14</span>     
<span style="color: #008080;">15</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MyBinder <span style="color: #0000ff;">extends</span> Binder{
<span style="color: #008080;">16</span>         MService getService(){
<span style="color: #008080;">17</span>             <span style="color: #0000ff;">return</span> MService.<span style="color: #0000ff;">this</span>;
<span style="color: #008080;">18</span>         }
<span style="color: #008080;">19</span>     }
<span style="color: #008080;">20</span>     @Override
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span> IBinder onBind(Intent intent) {
<span style="color: #008080;">22</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">23</span>         Log.v("CAT", "onBind");
<span style="color: #008080;">24</span>         <span style="color: #0000ff;">return</span> myBinder;
<span style="color: #008080;">25</span>     }
<span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span>     @Override
<span style="color: #008080;">28</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCreate() {
<span style="color: #008080;">29</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">30</span>         <span style="color: #0000ff;">super</span>.onCreate();
<span style="color: #008080;">31</span>         Log.v("CAT", "onCreate");
<span style="color: #008080;">32</span>         <span style="color: #0000ff;">try</span> {
<span style="color: #008080;">33</span>             mediaPlayer = <span style="color: #0000ff;">new</span> MediaPlayer();
<span style="color: #008080;">34</span>             mediaPlayer.setDataSource(Environment.getExternalStorageDirectory() + "/mp3/trhxn.mp3");
<span style="color: #008080;">35</span>             mediaPlayer.prepare();
<span style="color: #008080;">36</span>         } <span style="color: #0000ff;">catch</span> (Exception e) {
<span style="color: #008080;">37</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated catch block</span><span style="color: #008000;">
</span><span style="color: #008080;">38</span>             Log.v("CAT", "fail");
<span style="color: #008080;">39</span>             e.printStackTrace();
<span style="color: #008080;">40</span>         } 
<span style="color: #008080;">41</span>     }
<span style="color: #008080;">42</span> 
<span style="color: #008080;">43</span>     @Override
<span style="color: #008080;">44</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onDestroy() {
<span style="color: #008080;">45</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">46</span>         <span style="color: #0000ff;">super</span>.onDestroy();
<span style="color: #008080;">47</span>         Log.v("CAT", "onDestroy");
<span style="color: #008080;">48</span>     }
<span style="color: #008080;">49</span> 
<span style="color: #008080;">50</span>     @Override
<span style="color: #008080;">51</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> onStartCommand(Intent intent, <span style="color: #0000ff;">int</span> flags, <span style="color: #0000ff;">int</span> startId) {
<span style="color: #008080;">52</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">53</span>         Log.v("CAT", "onStartCommand");
<span style="color: #008080;">54</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">super</span>.onStartCommand(intent, flags, startId);
<span style="color: #008080;">55</span>     }
<span style="color: #008080;">56</span> 
<span style="color: #008080;">57</span>     @Override
<span style="color: #008080;">58</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span> onUnbind(Intent intent) {
<span style="color: #008080;">59</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">60</span>         Log.v("CAT", "onUnbind");
<span style="color: #008080;">61</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">false</span>;
<span style="color: #008080;">62</span>     }
<span style="color: #008080;">63</span>     
<span style="color: #008080;">64</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> start(){
<span style="color: #008080;">65</span>         mediaPlayer.start();
<span style="color: #008080;">66</span>     }
<span style="color: #008080;">67</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> pause(){
<span style="color: #008080;">68</span>         mediaPlayer.pause();
<span style="color: #008080;">69</span>     }
<span style="color: #008080;">70</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> stop(){
<span style="color: #008080;">71</span>         mediaPlayer.stop();
<span style="color: #008080;">72</span>         mediaPlayer.release();
<span style="color: #008080;">73</span>     }
<span style="color: #008080;">74</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> getDuration(){
<span style="color: #008080;">75</span>         <span style="color: #0000ff;">return</span> mediaPlayer.getDuration();
<span style="color: #008080;">76</span>     }
<span style="color: #008080;">77</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> getCurrentPosition(){
<span style="color: #008080;">78</span>         <span style="color: #0000ff;">return</span> mediaPlayer.getCurrentPosition();
<span style="color: #008080;">79</span>     }
<span style="color: #008080;">80</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> seekTo(<span style="color: #0000ff;">int</span> position){
<span style="color: #008080;">81</span>         mediaPlayer.seekTo(position);
<span style="color: #008080;">82</span>     }
<span style="color: #008080;">83</span> }</pre>
</div>
</div>

MusicPlayActivity：

<div class="cnblogs_code" onclick="cnblogs_code_show('d0b7bbe9-af89-4993-8d87-e320ceb1ece0')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_d0b7bbe9-af89-4993-8d87-e320ceb1ece0" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span> com.tiantian.test;
<span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span> android.app.Activity;
<span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span> android.content.ComponentName;
<span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span> android.content.Intent;
<span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span> android.content.ServiceConnection;
<span style="color: #008080;">  7</span> <span style="color: #0000ff;">import</span> android.os.Bundle;
<span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span> android.os.Handler;
<span style="color: #008080;">  9</span> <span style="color: #0000ff;">import</span> android.os.IBinder;
<span style="color: #008080;"> 10</span> <span style="color: #0000ff;">import</span> android.util.Log;
<span style="color: #008080;"> 11</span> <span style="color: #0000ff;">import</span> android.view.View;
<span style="color: #008080;"> 12</span> <span style="color: #0000ff;">import</span> android.view.View.OnClickListener;
<span style="color: #008080;"> 13</span> <span style="color: #0000ff;">import</span> android.widget.Button;
<span style="color: #008080;"> 14</span> <span style="color: #0000ff;">import</span> android.widget.SeekBar;
<span style="color: #008080;"> 15</span> 
<span style="color: #008080;"> 16</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MusicPlayActivity <span style="color: #0000ff;">extends</span> Activity {
<span style="color: #008080;"> 17</span>     <span style="color: #008000;">/**</span><span style="color: #008000;"> Called when the activity is first created. </span><span style="color: #008000;">*/</span>
<span style="color: #008080;"> 18</span>     MService mService;
<span style="color: #008080;"> 19</span>     <span style="color: #0000ff;">private</span> ServiceConnection conn = <span style="color: #0000ff;">new</span> ServiceConnection(){
<span style="color: #008080;"> 20</span> 
<span style="color: #008080;"> 21</span>         @Override
<span style="color: #008080;"> 22</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onServiceConnected(ComponentName arg0, IBinder arg1) {
<span style="color: #008080;"> 23</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 24</span>             mService = ((MService.MyBinder)arg1).getService();
<span style="color: #008080;"> 25</span>             Log.v("CAT", "getServiced");
<span style="color: #008080;"> 26</span>         }
<span style="color: #008080;"> 27</span> 
<span style="color: #008080;"> 28</span>         @Override
<span style="color: #008080;"> 29</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onServiceDisconnected(ComponentName name) {
<span style="color: #008080;"> 30</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 31</span>             mService = <span style="color: #0000ff;">null</span>;
<span style="color: #008080;"> 32</span>         }
<span style="color: #008080;"> 33</span>         
<span style="color: #008080;"> 34</span>     };
<span style="color: #008080;"> 35</span>     
<span style="color: #008080;"> 36</span>     <span style="color: #0000ff;">private</span> SeekBar seekBar;
<span style="color: #008080;"> 37</span>     <span style="color: #0000ff;">private</span> Button playBT;
<span style="color: #008080;"> 38</span>     
<span style="color: #008080;"> 39</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isPlaying = <span style="color: #0000ff;">false</span>;
<span style="color: #008080;"> 40</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isBinded = <span style="color: #0000ff;">false</span>;
<span style="color: #008080;"> 41</span>     
<span style="color: #008080;"> 42</span>     <span style="color: #0000ff;">private</span> Handler mHandler;
<span style="color: #008080;"> 43</span>     @Override
<span style="color: #008080;"> 44</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCreate(Bundle savedInstanceState) {
<span style="color: #008080;"> 45</span>         <span style="color: #0000ff;">super</span>.onCreate(savedInstanceState);
<span style="color: #008080;"> 46</span>         setContentView(R.layout.main);
<span style="color: #008080;"> 47</span>         Intent intent = <span style="color: #0000ff;">new</span> Intent(MusicPlayActivity.<span style="color: #0000ff;">this</span>, MService.<span style="color: #0000ff;">class</span>);
<span style="color: #008080;"> 48</span>         <span style="color: #0000ff;">if</span>(!isBinded){
<span style="color: #008080;"> 49</span>             bindService(intent, conn, BIND_AUTO_CREATE);
<span style="color: #008080;"> 50</span>             isBinded = <span style="color: #0000ff;">true</span>;
<span style="color: #008080;"> 51</span>         }
<span style="color: #008080;"> 52</span>         seekBar = (SeekBar) findViewById(R.id.seekBar);
<span style="color: #008080;"> 53</span>         playBT = (Button) findViewById(R.id.startBT);
<span style="color: #008080;"> 54</span>         mHandler = <span style="color: #0000ff;">new</span> Handler();
<span style="color: #008080;"> 55</span>         seekBar.setOnSeekBarChangeListener(<span style="color: #0000ff;">new</span> SeekBar.OnSeekBarChangeListener() {
<span style="color: #008080;"> 56</span>             
<span style="color: #008080;"> 57</span>             @Override
<span style="color: #008080;"> 58</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onStopTrackingTouch(SeekBar seekBar) {}
<span style="color: #008080;"> 59</span>             
<span style="color: #008080;"> 60</span>             @Override
<span style="color: #008080;"> 61</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onStartTrackingTouch(SeekBar seekBar) {}
<span style="color: #008080;"> 62</span>             
<span style="color: #008080;"> 63</span>             @Override
<span style="color: #008080;"> 64</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onProgressChanged(SeekBar seekBar, <span style="color: #0000ff;">int</span> progress,
<span style="color: #008080;"> 65</span>                     <span style="color: #0000ff;">boolean</span> fromUser) {
<span style="color: #008080;"> 66</span>                 <span style="color: #0000ff;">if</span>(fromUser){
<span style="color: #008080;"> 67</span>                     mService.seekTo((progress*mService.getDuration())/100);
<span style="color: #008080;"> 68</span>                 }
<span style="color: #008080;"> 69</span>             }
<span style="color: #008080;"> 70</span>         });
<span style="color: #008080;"> 71</span>         playBT.setOnClickListener(<span style="color: #0000ff;">new</span> OnClickListener() {
<span style="color: #008080;"> 72</span>             
<span style="color: #008080;"> 73</span>             @Override
<span style="color: #008080;"> 74</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClick(View v) {
<span style="color: #008080;"> 75</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 76</span>                 <span style="color: #0000ff;">if</span>(!isPlaying){
<span style="color: #008080;"> 77</span>                     mService.start();
<span style="color: #008080;"> 78</span>                     isPlaying = <span style="color: #0000ff;">true</span>;
<span style="color: #008080;"> 79</span>                     playBT.setText("暂停");
<span style="color: #008080;"> 80</span>                     mHandler.post(seekBarThread);
<span style="color: #008080;"> 81</span>                 }<span style="color: #0000ff;">else</span>{
<span style="color: #008080;"> 82</span>                     mService.pause();
<span style="color: #008080;"> 83</span>                     isPlaying = <span style="color: #0000ff;">false</span>;
<span style="color: #008080;"> 84</span>                     playBT.setText("播放");
<span style="color: #008080;"> 85</span>                     mHandler.removeCallbacks(seekBarThread);
<span style="color: #008080;"> 86</span>                 }
<span style="color: #008080;"> 87</span>             }
<span style="color: #008080;"> 88</span>         });
<span style="color: #008080;"> 89</span>         
<span style="color: #008080;"> 90</span>     }
<span style="color: #008080;"> 91</span>     
<span style="color: #008080;"> 92</span>     Runnable seekBarThread = <span style="color: #0000ff;">new</span> Runnable() {
<span style="color: #008080;"> 93</span>         
<span style="color: #008080;"> 94</span>         @Override
<span style="color: #008080;"> 95</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> run() {
<span style="color: #008080;"> 96</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 97</span>             seekBar.setProgress((mService.getCurrentPosition()*100)/mService.getDuration());
<span style="color: #008080;"> 98</span>             mHandler.postDelayed(seekBarThread, 200);
<span style="color: #008080;"> 99</span>         }
<span style="color: #008080;">100</span>     };
<span style="color: #008080;">101</span>     
<span style="color: #008080;">102</span> }</pre>
</div>
</div>

&nbsp;

