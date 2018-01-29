---
title: 'TimePicker,SharedPreferences实现android小闹钟'
tags: []
date: 2012-03-03 13:23:00
---

![](http://pic002.cnblogs.com/images/2012/378300/2012030313175433.jpg)

![](http://pic002.cnblogs.com/images/2012/378300/2012030313182297.jpg)

![](http://pic002.cnblogs.com/images/2012/378300/2012030313183586.jpg)

简述：

使用TimePickerDialog来实现设置闹钟

分为一次性闹钟和周期性闹钟

使用SharedPreferences来储存闹钟的设置信息

&nbsp;

AlarmClockActivity布局：

<div class="cnblogs_code" onclick="cnblogs_code_show('e85b0aeb-2755-4966-96ab-92b2ce96e0f6')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_e85b0aeb-2755-4966-96ab-92b2ce96e0f6" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> &lt;?xml version="1.0" encoding="utf-8"?&gt;
<span style="color: #008080;">  2</span> &lt;LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
<span style="color: #008080;">  3</span>     android:layout_width="fill_parent"
<span style="color: #008080;">  4</span>     android:layout_height="fill_parent"
<span style="color: #008080;">  5</span>     android:orientation="vertical"&gt;
<span style="color: #008080;">  6</span> 
<span style="color: #008080;">  7</span>     &lt;TextView
<span style="color: #008080;">  8</span>         android:id="@+id/timeId"
<span style="color: #008080;">  9</span>         android:layout_width="fill_parent"
<span style="color: #008080;"> 10</span>         android:layout_height="wrap_content"
<span style="color: #008080;"> 11</span>         android:textSize="33dp"
<span style="color: #008080;"> 12</span>         android:gravity="center_horizontal"
<span style="color: #008080;"> 13</span>         android:layout_marginTop="10dp"
<span style="color: #008080;"> 14</span>         android:text="00:00  AM" /&gt;
<span style="color: #008080;"> 15</span> 
<span style="color: #008080;"> 16</span>     &lt;TableLayout
<span style="color: #008080;"> 17</span>         android:id="@+id/tableLayout1"
<span style="color: #008080;"> 18</span>         android:layout_width="match_parent"
<span style="color: #008080;"> 19</span>         android:layout_height="wrap_content" 
<span style="color: #008080;"> 20</span>         android:layout_marginTop="10dp"&gt;
<span style="color: #008080;"> 21</span> 
<span style="color: #008080;"> 22</span>         &lt;TableRow
<span style="color: #008080;"> 23</span>             android:id="@+id/tableRow1"
<span style="color: #008080;"> 24</span>             android:layout_width="wrap_content"
<span style="color: #008080;"> 25</span>             android:layout_height="wrap_content" &gt;
<span style="color: #008080;"> 26</span> 
<span style="color: #008080;"> 27</span>             &lt;TextView
<span style="color: #008080;"> 28</span>                 android:layout_width="wrap_content"
<span style="color: #008080;"> 29</span>                 android:layout_height="wrap_content"
<span style="color: #008080;"> 30</span>                 android:layout_marginLeft="15dp"
<span style="color: #008080;"> 31</span>                 android:layout_weight="1.0"
<span style="color: #008080;"> 32</span>                 android:textSize="20sp"
<span style="color: #008080;"> 33</span>                 android:text="只响一次的闹钟" /&gt;
<span style="color: #008080;"> 34</span> 
<span style="color: #008080;"> 35</span>             &lt;Button
<span style="color: #008080;"> 36</span>                 android:id="@+id/onceSetId"
<span style="color: #008080;"> 37</span>                 android:layout_width="wrap_content"
<span style="color: #008080;"> 38</span>                 android:layout_height="wrap_content"
<span style="color: #008080;"> 39</span>                 android:layout_marginRight="10dp"
<span style="color: #008080;"> 40</span>                 android:layout_weight="1.0"
<span style="color: #008080;"> 41</span>                 android:text="设置闹钟" /&gt;
<span style="color: #008080;"> 42</span>         &lt;/TableRow&gt;
<span style="color: #008080;"> 43</span> 
<span style="color: #008080;"> 44</span>         &lt;TableRow
<span style="color: #008080;"> 45</span>             android:id="@+id/tableRow2"
<span style="color: #008080;"> 46</span>             android:layout_width="wrap_content"
<span style="color: #008080;"> 47</span>             android:layout_height="wrap_content" &gt;
<span style="color: #008080;"> 48</span> 
<span style="color: #008080;"> 49</span>             &lt;TextView
<span style="color: #008080;"> 50</span>                 android:id="@+id/onceTextId"
<span style="color: #008080;"> 51</span>                 android:layout_width="wrap_content"
<span style="color: #008080;"> 52</span>                 android:layout_height="wrap_content"
<span style="color: #008080;"> 53</span>                 android:layout_marginLeft="15dp"
<span style="color: #008080;"> 54</span>                 android:layout_weight="1.0"
<span style="color: #008080;"> 55</span>                 android:textSize="20sp"
<span style="color: #008080;"> 56</span>                 android:text="暂无设置" /&gt;
<span style="color: #008080;"> 57</span> 
<span style="color: #008080;"> 58</span>             &lt;Button
<span style="color: #008080;"> 59</span>                 android:id="@+id/onceDeleId"
<span style="color: #008080;"> 60</span>                 android:layout_width="wrap_content"
<span style="color: #008080;"> 61</span>                 android:layout_height="wrap_content"
<span style="color: #008080;"> 62</span>                 android:layout_marginRight="10dp"
<span style="color: #008080;"> 63</span>                 android:layout_weight="1.0"
<span style="color: #008080;"> 64</span>                 android:text="删除闹钟" /&gt;
<span style="color: #008080;"> 65</span>         &lt;/TableRow&gt;
<span style="color: #008080;"> 66</span> 
<span style="color: #008080;"> 67</span>         &lt;TableRow
<span style="color: #008080;"> 68</span>             android:id="@+id/tableRow3"
<span style="color: #008080;"> 69</span>             android:layout_width="wrap_content"
<span style="color: #008080;"> 70</span>             android:layout_height="wrap_content" 
<span style="color: #008080;"> 71</span>             android:layout_marginTop="25dp"&gt;
<span style="color: #008080;"> 72</span> 
<span style="color: #008080;"> 73</span>             &lt;TextView
<span style="color: #008080;"> 74</span>                 android:layout_width="wrap_content"
<span style="color: #008080;"> 75</span>                 android:layout_height="wrap_content"
<span style="color: #008080;"> 76</span>                 android:layout_marginLeft="15dp"
<span style="color: #008080;"> 77</span>                 android:layout_weight="1.0"
<span style="color: #008080;"> 78</span>                 android:textSize="20sp"
<span style="color: #008080;"> 79</span>                 android:text="重复响起的闹钟" /&gt;
<span style="color: #008080;"> 80</span> 
<span style="color: #008080;"> 81</span>             &lt;Button
<span style="color: #008080;"> 82</span>                 android:id="@+id/timesSetId"
<span style="color: #008080;"> 83</span>                 android:layout_width="wrap_content"
<span style="color: #008080;"> 84</span>                 android:layout_height="wrap_content"
<span style="color: #008080;"> 85</span>                 android:layout_marginRight="10dp"
<span style="color: #008080;"> 86</span>                 android:layout_weight="1.0"
<span style="color: #008080;"> 87</span>                 android:text="设置闹钟" /&gt;
<span style="color: #008080;"> 88</span>         &lt;/TableRow&gt;
<span style="color: #008080;"> 89</span> 
<span style="color: #008080;"> 90</span>         &lt;TableRow
<span style="color: #008080;"> 91</span>             android:id="@+id/tableRow4"
<span style="color: #008080;"> 92</span>             android:layout_width="wrap_content"
<span style="color: #008080;"> 93</span>             android:layout_height="wrap_content" &gt;
<span style="color: #008080;"> 94</span> 
<span style="color: #008080;"> 95</span>             &lt;TextView
<span style="color: #008080;"> 96</span>                 android:id="@+id/timesTextId"
<span style="color: #008080;"> 97</span>                 android:layout_width="wrap_content"
<span style="color: #008080;"> 98</span>                 android:layout_height="wrap_content"
<span style="color: #008080;"> 99</span>                 android:layout_marginLeft="15dp"
<span style="color: #008080;">100</span>                 android:layout_weight="1.0"
<span style="color: #008080;">101</span>                 android:textSize="20sp"
<span style="color: #008080;">102</span>                 android:text="暂无设置" /&gt;
<span style="color: #008080;">103</span> 
<span style="color: #008080;">104</span>             &lt;Button
<span style="color: #008080;">105</span>                 android:id="@+id/timesDeleId"
<span style="color: #008080;">106</span>                 android:layout_width="wrap_content"
<span style="color: #008080;">107</span>                 android:layout_height="wrap_content"
<span style="color: #008080;">108</span>                 android:layout_marginRight="10dp"
<span style="color: #008080;">109</span>                 android:layout_weight="1.0"
<span style="color: #008080;">110</span>                 android:text="删除闹钟" /&gt;
<span style="color: #008080;">111</span>         &lt;/TableRow&gt;
<span style="color: #008080;">112</span>     &lt;/TableLayout&gt;
<span style="color: #008080;">113</span>     
<span style="color: #008080;">114</span> &lt;/LinearLayout&gt;</pre>
</div>
</div>

&nbsp;

AlarmClockActivity.java：

<div class="cnblogs_code" onclick="cnblogs_code_show('a0a29346-6f57-40d1-a0e1-349296dc9b15')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_a0a29346-6f57-40d1-a0e1-349296dc9b15" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span> com.tiantian.test;
<span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span> java.util.Calendar;
<span style="color: #008080;">  4</span> 
<span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span> android.app.Activity;
<span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span> android.app.AlarmManager;
<span style="color: #008080;">  7</span> <span style="color: #0000ff;">import</span> android.app.PendingIntent;
<span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span> android.app.TimePickerDialog;
<span style="color: #008080;">  9</span> <span style="color: #0000ff;">import</span> android.app.TimePickerDialog.OnTimeSetListener;
<span style="color: #008080;"> 10</span> <span style="color: #0000ff;">import</span> android.content.Intent;
<span style="color: #008080;"> 11</span> <span style="color: #0000ff;">import</span> android.content.SharedPreferences;
<span style="color: #008080;"> 12</span> <span style="color: #0000ff;">import</span> android.content.SharedPreferences.Editor;
<span style="color: #008080;"> 13</span> <span style="color: #0000ff;">import</span> android.os.Bundle;
<span style="color: #008080;"> 14</span> <span style="color: #0000ff;">import</span> android.os.Handler;
<span style="color: #008080;"> 15</span> <span style="color: #0000ff;">import</span> android.text.format.Time;
<span style="color: #008080;"> 16</span> <span style="color: #0000ff;">import</span> android.util.Log;
<span style="color: #008080;"> 17</span> <span style="color: #0000ff;">import</span> android.view.View;
<span style="color: #008080;"> 18</span> <span style="color: #0000ff;">import</span> android.view.View.OnClickListener;
<span style="color: #008080;"> 19</span> <span style="color: #0000ff;">import</span> android.widget.Button;
<span style="color: #008080;"> 20</span> <span style="color: #0000ff;">import</span> android.widget.TextView;
<span style="color: #008080;"> 21</span> <span style="color: #0000ff;">import</span> android.widget.TimePicker;
<span style="color: #008080;"> 22</span> 
<span style="color: #008080;"> 23</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> AlarmClockActivity <span style="color: #0000ff;">extends</span> Activity {
<span style="color: #008080;"> 24</span>     <span style="color: #008000;">/**</span><span style="color: #008000;"> Called when the activity is first created. </span><span style="color: #008000;">*/</span>
<span style="color: #008080;"> 25</span>     <span style="color: #0000ff;">private</span> TextView timeTV;
<span style="color: #008080;"> 26</span>     <span style="color: #0000ff;">static</span> TextView onceTV;
<span style="color: #008080;"> 27</span>     <span style="color: #0000ff;">private</span> TextView timesTV;
<span style="color: #008080;"> 28</span>     <span style="color: #0000ff;">private</span> Button onceSetBT;
<span style="color: #008080;"> 29</span>     <span style="color: #0000ff;">private</span> Button onceDeleBT;
<span style="color: #008080;"> 30</span>     <span style="color: #0000ff;">private</span> Button timesSetBT;
<span style="color: #008080;"> 31</span>     <span style="color: #0000ff;">private</span> Button timesDelBT;
<span style="color: #008080;"> 32</span>     <span style="color: #0000ff;">private</span> Calendar c;
<span style="color: #008080;"> 33</span>     
<span style="color: #008080;"> 34</span>     <span style="color: #0000ff;">private</span> Handler mHandler;
<span style="color: #008080;"> 35</span>     <span style="color: #0000ff;">private</span> SharedPreferences prefs;
<span style="color: #008080;"> 36</span>     <span style="color: #0000ff;">private</span> Editor editor;
<span style="color: #008080;"> 37</span>     
<span style="color: #008080;"> 38</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> String ONCE_ALARM = "com.tiantian.action.ONCE_ALARM";
<span style="color: #008080;"> 39</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> String TIMES_ALARM = "com.tiantian.action.TIMES_ALARM";
<span style="color: #008080;"> 40</span>     @Override
<span style="color: #008080;"> 41</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCreate(Bundle savedInstanceState) {
<span style="color: #008080;"> 42</span>         <span style="color: #0000ff;">super</span>.onCreate(savedInstanceState);
<span style="color: #008080;"> 43</span>         setContentView(R.layout.main);
<span style="color: #008080;"> 44</span>         timeTV = (TextView) findViewById(R.id.timeId);
<span style="color: #008080;"> 45</span>         onceTV = (TextView) findViewById(R.id.onceTextId);
<span style="color: #008080;"> 46</span>         timesTV = (TextView) findViewById(R.id.timesTextId);
<span style="color: #008080;"> 47</span>         mHandler = <span style="color: #0000ff;">new</span> Handler();
<span style="color: #008080;"> 48</span>         mHandler.post(timeThread);
<span style="color: #008080;"> 49</span>         
<span style="color: #008080;"> 50</span>         prefs = getSharedPreferences("alarmClock", MODE_PRIVATE);
<span style="color: #008080;"> 51</span>         editor = prefs.edit();
<span style="color: #008080;"> 52</span>         <span style="color: #0000ff;">if</span>(prefs != <span style="color: #0000ff;">null</span>){
<span style="color: #008080;"> 53</span>             onceTV.setText(prefs.getString("_onceTV", "暂无设置"));
<span style="color: #008080;"> 54</span>             timesTV.setText(prefs.getString("_timesTV", "暂无设置"));
<span style="color: #008080;"> 55</span>         }
<span style="color: #008080;"> 56</span>         
<span style="color: #008080;"> 57</span>         onceSetBT = (Button) findViewById(R.id.onceSetId);
<span style="color: #008080;"> 58</span>         onceSetBT.setOnClickListener(<span style="color: #0000ff;">new</span> ButtonListener());
<span style="color: #008080;"> 59</span>         onceDeleBT = (Button) findViewById(R.id.onceDeleId);
<span style="color: #008080;"> 60</span>         onceDeleBT.setOnClickListener(<span style="color: #0000ff;">new</span> ButtonListener());
<span style="color: #008080;"> 61</span>         timesSetBT = (Button) findViewById(R.id.timesSetId);
<span style="color: #008080;"> 62</span>         timesSetBT.setOnClickListener(<span style="color: #0000ff;">new</span> ButtonListener());
<span style="color: #008080;"> 63</span>         timesDelBT = (Button) findViewById(R.id.timesDeleId);
<span style="color: #008080;"> 64</span>         timesDelBT.setOnClickListener(<span style="color: #0000ff;">new</span> ButtonListener());
<span style="color: #008080;"> 65</span>         
<span style="color: #008080;"> 66</span>     }
<span style="color: #008080;"> 67</span>     
<span style="color: #008080;"> 68</span>     <span style="color: #0000ff;">class</span> ButtonListener <span style="color: #0000ff;">implements</span> OnClickListener{
<span style="color: #008080;"> 69</span> 
<span style="color: #008080;"> 70</span>         @Override
<span style="color: #008080;"> 71</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClick(View v) {
<span style="color: #008080;"> 72</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 73</span>             <span style="color: #0000ff;">switch</span>(v.getId()){
<span style="color: #008080;"> 74</span>             <span style="color: #0000ff;">case</span> R.id.onceSetId:
<span style="color: #008080;"> 75</span>                 c = Calendar.getInstance();
<span style="color: #008080;"> 76</span>                 <span style="color: #0000ff;">int</span> hour = c.get(Calendar.HOUR_OF_DAY);
<span style="color: #008080;"> 77</span>                 <span style="color: #0000ff;">int</span> minute = c.get(Calendar.MINUTE);
<span style="color: #008080;"> 78</span>                 <span style="color: #0000ff;">new</span> TimePickerDialog(AlarmClockActivity.<span style="color: #0000ff;">this</span>, <span style="color: #0000ff;">new</span> OnTimeSetListener() {
<span style="color: #008080;"> 79</span>                     
<span style="color: #008080;"> 80</span>                     @Override
<span style="color: #008080;"> 81</span>                     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onTimeSet(TimePicker view, <span style="color: #0000ff;">int</span> hourOfDay, <span style="color: #0000ff;">int</span> minute) {
<span style="color: #008080;"> 82</span>                         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 83</span>                         onceTV.setText("已设置为：" + changeTime(hourOfDay) + ":" + changeTime(minute));
<span style="color: #008080;"> 84</span>                         c = timePicker(hourOfDay, minute);
<span style="color: #008080;"> 85</span>                         AlarmManager am = (AlarmManager) getSystemService(ALARM_SERVICE);
<span style="color: #008080;"> 86</span>                         Intent intent = <span style="color: #0000ff;">new</span> Intent(AlarmClockActivity.<span style="color: #0000ff;">this</span>, CallAlarm.<span style="color: #0000ff;">class</span>);
<span style="color: #008080;"> 87</span>                         intent.setAction(ONCE_ALARM);
<span style="color: #008080;"> 88</span>                         PendingIntent senderPI = PendingIntent.getBroadcast(AlarmClockActivity.<span style="color: #0000ff;">this</span>, 0, intent, 0);
<span style="color: #008080;"> 89</span>                         am.set(AlarmManager.RTC_WAKEUP, c.getTimeInMillis(), senderPI);
<span style="color: #008080;"> 90</span>                     }
<span style="color: #008080;"> 91</span>                 }, hour, minute, <span style="color: #0000ff;">true</span>).show();
<span style="color: #008080;"> 92</span>                 <span style="color: #0000ff;">break</span>;
<span style="color: #008080;"> 93</span>             <span style="color: #0000ff;">case</span> R.id.onceDeleId:
<span style="color: #008080;"> 94</span>                 AlarmManager am = (AlarmManager) getSystemService(ALARM_SERVICE);
<span style="color: #008080;"> 95</span>                 Intent intent = <span style="color: #0000ff;">new</span> Intent(AlarmClockActivity.<span style="color: #0000ff;">this</span>, CallAlarm.<span style="color: #0000ff;">class</span>);
<span style="color: #008080;"> 96</span>                 PendingIntent senderPI = PendingIntent.getBroadcast(AlarmClockActivity.<span style="color: #0000ff;">this</span>, 0, intent, 0);
<span style="color: #008080;"> 97</span>                 am.cancel(senderPI);
<span style="color: #008080;"> 98</span>                 onceTV.setText("暂无设置");
<span style="color: #008080;"> 99</span>                 <span style="color: #0000ff;">break</span>;
<span style="color: #008080;">100</span>             <span style="color: #0000ff;">case</span> R.id.timesSetId:
<span style="color: #008080;">101</span>                 c = Calendar.getInstance();
<span style="color: #008080;">102</span>                 <span style="color: #0000ff;">int</span> hour1 = c.get(Calendar.HOUR_OF_DAY);
<span style="color: #008080;">103</span>                 <span style="color: #0000ff;">int</span> minute1 = c.get(Calendar.MINUTE);
<span style="color: #008080;">104</span>                 <span style="color: #0000ff;">new</span> TimePickerDialog(AlarmClockActivity.<span style="color: #0000ff;">this</span>, <span style="color: #0000ff;">new</span> OnTimeSetListener() {
<span style="color: #008080;">105</span>                     
<span style="color: #008080;">106</span>                     @Override
<span style="color: #008080;">107</span>                     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onTimeSet(TimePicker view, <span style="color: #0000ff;">int</span> hourOfDay, <span style="color: #0000ff;">int</span> minute) {
<span style="color: #008080;">108</span>                         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">109</span>                         timesTV.setText("已设置为：" + changeTime(hourOfDay) + ":" + changeTime(minute));
<span style="color: #008080;">110</span>                         c = timePicker(hourOfDay, minute);
<span style="color: #008080;">111</span>                         AlarmManager am = (AlarmManager) getSystemService(ALARM_SERVICE);
<span style="color: #008080;">112</span>                         Intent intent = <span style="color: #0000ff;">new</span> Intent(AlarmClockActivity.<span style="color: #0000ff;">this</span>, CallAlarm.<span style="color: #0000ff;">class</span>);
<span style="color: #008080;">113</span>                         intent.setAction(TIMES_ALARM);
<span style="color: #008080;">114</span>                         PendingIntent senderPI = PendingIntent.getBroadcast(AlarmClockActivity.<span style="color: #0000ff;">this</span>, 1, intent, 0);
<span style="color: #008080;">115</span>                         am.setRepeating(AlarmManager.RTC_WAKEUP, c.getTimeInMillis(), 24*60*60*1000, senderPI);
<span style="color: #008080;">116</span>                     }
<span style="color: #008080;">117</span>                 }, hour1, minute1, <span style="color: #0000ff;">true</span>).show();
<span style="color: #008080;">118</span>                 <span style="color: #0000ff;">break</span>;
<span style="color: #008080;">119</span>             <span style="color: #0000ff;">case</span> R.id.timesDeleId:
<span style="color: #008080;">120</span>                 AlarmManager am1 = (AlarmManager) getSystemService(ALARM_SERVICE);
<span style="color: #008080;">121</span>                 Intent intent1 = <span style="color: #0000ff;">new</span> Intent(AlarmClockActivity.<span style="color: #0000ff;">this</span>, CallAlarm.<span style="color: #0000ff;">class</span>);
<span style="color: #008080;">122</span>                 PendingIntent senderPI1 = PendingIntent.getBroadcast(AlarmClockActivity.<span style="color: #0000ff;">this</span>, 1, intent1, 0);
<span style="color: #008080;">123</span>                 am1.cancel(senderPI1);
<span style="color: #008080;">124</span>                 timesTV.setText("暂无设置");
<span style="color: #008080;">125</span>                 <span style="color: #0000ff;">break</span>;
<span style="color: #008080;">126</span>             }
<span style="color: #008080;">127</span>             
<span style="color: #008080;">128</span>         }
<span style="color: #008080;">129</span>         
<span style="color: #008080;">130</span>     }
<span style="color: #008080;">131</span>     
<span style="color: #008080;">132</span>     <span style="color: #0000ff;">private</span> Calendar timePicker(<span style="color: #0000ff;">int</span> hourOfDay, <span style="color: #0000ff;">int</span> minute){
<span style="color: #008080;">133</span>         c.setTimeInMillis(System.currentTimeMillis());
<span style="color: #008080;">134</span>         c.set(Calendar.HOUR_OF_DAY, hourOfDay);
<span style="color: #008080;">135</span>         c.set(Calendar.MINUTE, minute);
<span style="color: #008080;">136</span>         c.set(Calendar.SECOND, 0);
<span style="color: #008080;">137</span>         c.set(Calendar.MILLISECOND, 0);
<span style="color: #008080;">138</span>         <span style="color: #008000;">//</span><span style="color: #008000;">避免设置时间比当前时间小时 马上响应的情况发生</span><span style="color: #008000;">
</span><span style="color: #008080;">139</span>         <span style="color: #0000ff;">if</span>(c.getTimeInMillis() &lt; Calendar.getInstance().getTimeInMillis()){
<span style="color: #008080;">140</span>             c.set(Calendar.DAY_OF_MONTH, Calendar.DAY_OF_MONTH + 1);
<span style="color: #008080;">141</span>         }
<span style="color: #008080;">142</span>         <span style="color: #0000ff;">return</span> c;
<span style="color: #008080;">143</span>     }
<span style="color: #008080;">144</span>     
<span style="color: #008080;">145</span>     
<span style="color: #008080;">146</span>     @Override
<span style="color: #008080;">147</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span> onDestroy() {
<span style="color: #008080;">148</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">149</span>         <span style="color: #0000ff;">super</span>.onDestroy();
<span style="color: #008080;">150</span>         editor.putString("_onceTV", onceTV.getText().toString());
<span style="color: #008080;">151</span>         editor.putString("_timesTV", timesTV.getText().toString());
<span style="color: #008080;">152</span>         editor.commit();
<span style="color: #008080;">153</span>     }
<span style="color: #008080;">154</span> 
<span style="color: #008080;">155</span> 
<span style="color: #008080;">156</span>     Runnable timeThread = <span style="color: #0000ff;">new</span> Runnable() {
<span style="color: #008080;">157</span>         
<span style="color: #008080;">158</span>         @Override
<span style="color: #008080;">159</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> run() {
<span style="color: #008080;">160</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">161</span>             timeTV.setText(changeTime(Calendar.getInstance().get(Calendar.HOUR)) 
<span style="color: #008080;">162</span>                     + ":" +changeTime(Calendar.getInstance().get(Calendar.MINUTE)) 
<span style="color: #008080;">163</span>                     + "  " + changeAMPM(Calendar.getInstance().get(Calendar.AM_PM)));
<span style="color: #008080;">164</span>             mHandler.postDelayed(timeThread, 100);
<span style="color: #008080;">165</span>         }
<span style="color: #008080;">166</span>     };
<span style="color: #008080;">167</span>     
<span style="color: #008080;">168</span>     <span style="color: #0000ff;">private</span> String changeTime(<span style="color: #0000ff;">int</span> a){
<span style="color: #008080;">169</span>         String num = <span style="color: #0000ff;">null</span>;
<span style="color: #008080;">170</span>         <span style="color: #0000ff;">if</span>(a &lt; 10){
<span style="color: #008080;">171</span>             num = "0" + a;
<span style="color: #008080;">172</span>         }<span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span>(a &gt; 9){
<span style="color: #008080;">173</span>             num = "" + a;
<span style="color: #008080;">174</span>         }
<span style="color: #008080;">175</span>         <span style="color: #0000ff;">return</span> num;
<span style="color: #008080;">176</span>     }
<span style="color: #008080;">177</span>     <span style="color: #0000ff;">private</span> String changeAMPM(<span style="color: #0000ff;">int</span> ap){
<span style="color: #008080;">178</span>         String apStr = <span style="color: #0000ff;">null</span>;
<span style="color: #008080;">179</span>         <span style="color: #0000ff;">if</span>(ap == 0){
<span style="color: #008080;">180</span>             apStr = "AM";
<span style="color: #008080;">181</span>         }<span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span>(ap == 1){
<span style="color: #008080;">182</span>             apStr = "PM";
<span style="color: #008080;">183</span>         }
<span style="color: #008080;">184</span>         <span style="color: #0000ff;">return</span> apStr;
<span style="color: #008080;">185</span>     }
<span style="color: #008080;">186</span>     
<span style="color: #008080;">187</span> }</pre>
</div>
</div>

CallAlarm.java：

<div class="cnblogs_code" onclick="cnblogs_code_show('c5bf7d4e-03e7-4260-9ace-1b63849d1153')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_c5bf7d4e-03e7-4260-9ace-1b63849d1153" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span> com.tiantian.test;
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span> android.content.BroadcastReceiver;
<span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span> android.content.Context;
<span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span> android.content.Intent;
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span> android.util.Log;
<span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> CallAlarm <span style="color: #0000ff;">extends</span> BroadcastReceiver{
<span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> String ONCE_ALARM = "com.tiantian.action.ONCE_ALARM";
<span style="color: #008080;">10</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> String TIMES_ALARM = "com.tiantian.action.TIMES_ALARM";
<span style="color: #008080;">11</span>     @Override
<span style="color: #008080;">12</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onReceive(Context context, Intent intent) {
<span style="color: #008080;">13</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">14</span>         Log.v("CAT", "I'm in BroadcastReceiver");
<span style="color: #008080;">15</span>         Intent wakeUpIntent = <span style="color: #0000ff;">new</span> Intent(context, WakeUp.<span style="color: #0000ff;">class</span>);
<span style="color: #008080;">16</span>         wakeUpIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
<span style="color: #008080;">17</span>         <span style="color: #0000ff;">if</span>(intent.getAction().equals(ONCE_ALARM)){
<span style="color: #008080;">18</span>             wakeUpIntent.setAction(ONCE_ALARM);
<span style="color: #008080;">19</span>         }<span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span>(intent.getAction().endsWith(TIMES_ALARM)){
<span style="color: #008080;">20</span>             wakeUpIntent.setAction(TIMES_ALARM);
<span style="color: #008080;">21</span>         }
<span style="color: #008080;">22</span>         context.startActivity(wakeUpIntent);
<span style="color: #008080;">23</span>     }
<span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span> }</pre>
</div>
</div>

&nbsp;

WakeUp.java

<div class="cnblogs_code" onclick="cnblogs_code_show('5a640f02-d1eb-4506-b25e-73dd110e947e')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_5a640f02-d1eb-4506-b25e-73dd110e947e" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span> com.tiantian.test;
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span> android.app.Activity;
<span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span> android.app.AlertDialog;
<span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span> android.content.DialogInterface;
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span> android.content.DialogInterface.OnClickListener;
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span> android.content.SharedPreferences;
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span> android.content.SharedPreferences.Editor;
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span> android.media.MediaPlayer;
<span style="color: #008080;">10</span> <span style="color: #0000ff;">import</span> android.os.Bundle;
<span style="color: #008080;">11</span> <span style="color: #0000ff;">import</span> android.os.Environment;
<span style="color: #008080;">12</span> <span style="color: #0000ff;">import</span> android.view.View;
<span style="color: #008080;">13</span> <span style="color: #0000ff;">import</span> android.widget.Button;
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> WakeUp <span style="color: #0000ff;">extends</span> Activity{
<span style="color: #008080;">16</span>     <span style="color: #0000ff;">private</span> Button okButton;
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">private</span> SharedPreferences prefs;
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">private</span> Editor editor;
<span style="color: #008080;">19</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> String ONCE_ALARM = "com.tiantian.action.ONCE_ALARM";
<span style="color: #008080;">20</span>     
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">private</span> MediaPlayer mediaPlayer;
<span style="color: #008080;">22</span>     @Override
<span style="color: #008080;">23</span>     <span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span> onCreate(Bundle savedInstanceState) {
<span style="color: #008080;">24</span>         <span style="color: #0000ff;">super</span>.onCreate(savedInstanceState);
<span style="color: #008080;">25</span>         setContentView(R.layout.wake_up);
<span style="color: #008080;">26</span>         prefs = getSharedPreferences("alarmClock", MODE_PRIVATE);
<span style="color: #008080;">27</span>         mediaPlayer = <span style="color: #0000ff;">new</span> MediaPlayer();
<span style="color: #008080;">28</span>         <span style="color: #0000ff;">try</span> {
<span style="color: #008080;">29</span>             <span style="color: #008000;">//</span><span style="color: #008000;">mediaPlayer.setDataSource(Environment.getExternalStorageDirectory() + "/mp3/trhxn.mp3");</span><span style="color: #008000;">
</span><span style="color: #008080;">30</span>             mediaPlayer = MediaPlayer.create(<span style="color: #0000ff;">this</span>, R.raw.conan);
<span style="color: #008080;">31</span>             <span style="color: #008000;">//</span><span style="color: #008000;">mediaPlayer.prepare();</span><span style="color: #008000;">
</span><span style="color: #008080;">32</span>             mediaPlayer.setLooping(<span style="color: #0000ff;">true</span>);
<span style="color: #008080;">33</span>             mediaPlayer.start();
<span style="color: #008080;">34</span>         } <span style="color: #0000ff;">catch</span> (Exception e) {
<span style="color: #008080;">35</span>             e.printStackTrace();
<span style="color: #008080;">36</span>         }
<span style="color: #008080;">37</span>         
<span style="color: #008080;">38</span>         okButton = (Button) findViewById(R.id.okButtonId);
<span style="color: #008080;">39</span>         okButton.setOnClickListener(<span style="color: #0000ff;">new</span> View.OnClickListener() {
<span style="color: #008080;">40</span>             
<span style="color: #008080;">41</span>             @Override
<span style="color: #008080;">42</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClick(View v) {
<span style="color: #008080;">43</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">44</span>                 <span style="color: #0000ff;">if</span>(getIntent().getAction().equals(ONCE_ALARM)){
<span style="color: #008080;">45</span>                     editor = prefs.edit();
<span style="color: #008080;">46</span>                     editor.putString("_onceTV", "暂无设置");
<span style="color: #008080;">47</span>                     editor.commit();
<span style="color: #008080;">48</span>                     AlarmClockActivity.onceTV.setText("暂无设置");
<span style="color: #008080;">49</span>                 }
<span style="color: #008080;">50</span>                 mediaPlayer.stop();
<span style="color: #008080;">51</span>                 mediaPlayer.release();
<span style="color: #008080;">52</span>                 finish();
<span style="color: #008080;">53</span>             }
<span style="color: #008080;">54</span>         });
<span style="color: #008080;">55</span>         
<span style="color: #008080;">56</span>         
<span style="color: #008080;">57</span>         
<span style="color: #008080;">58</span>     }
<span style="color: #008080;">59</span>     
<span style="color: #008080;">60</span> 
<span style="color: #008080;">61</span> }</pre>
</div>
</div>