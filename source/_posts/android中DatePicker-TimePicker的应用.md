---
title: android中DatePicker&TimePicker的应用
tags: [android, DatePicker, TimePicker]
date: 2012-03-01 18:44:00
---

![](http://pic002.cnblogs.com/images/2012/378300/2012030118412226.jpg)

布局：

<div class="cnblogs_code" onclick="cnblogs_code_show('210ec2ed-ef8a-41d7-b9e4-93fa5b27d84f')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_210ec2ed-ef8a-41d7-b9e4-93fa5b27d84f" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> &lt;?xml version="1.0" encoding="utf-8"?&gt;
<span style="color: #008080;"> 2</span> &lt;LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
<span style="color: #008080;"> 3</span>     android:layout_width="fill_parent"
<span style="color: #008080;"> 4</span>     android:layout_height="fill_parent"
<span style="color: #008080;"> 5</span>     android:orientation="vertical" &gt;
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span>     &lt;TextView
<span style="color: #008080;"> 8</span>         android:id="@+id/dateText"
<span style="color: #008080;"> 9</span>         android:layout_width="wrap_content"
<span style="color: #008080;">10</span>         android:layout_height="wrap_content"
<span style="color: #008080;">11</span>         /&gt;
<span style="color: #008080;">12</span>     &lt;Button 
<span style="color: #008080;">13</span>         android:id="@+id/dateButton"
<span style="color: #008080;">14</span>         android:layout_width="fill_parent"
<span style="color: #008080;">15</span>         android:layout_height="wrap_content"
<span style="color: #008080;">16</span>         android:text="设置日期"
<span style="color: #008080;">17</span>         /&gt;
<span style="color: #008080;">18</span>     &lt;TextView
<span style="color: #008080;">19</span>         android:id="@+id/timeText"
<span style="color: #008080;">20</span>         android:layout_width="wrap_content"
<span style="color: #008080;">21</span>         android:layout_height="wrap_content"
<span style="color: #008080;">22</span>         /&gt;
<span style="color: #008080;">23</span>     &lt;Button 
<span style="color: #008080;">24</span>         android:id="@+id/timeButton"
<span style="color: #008080;">25</span>         android:layout_width="fill_parent"
<span style="color: #008080;">26</span>         android:layout_height="wrap_content"
<span style="color: #008080;">27</span>         android:text="设置时间"
<span style="color: #008080;">28</span>         /&gt;
<span style="color: #008080;">29</span>     
<span style="color: #008080;">30</span> &lt;/LinearLayout&gt;</pre>
</div>
</div>

代码：

<div class="cnblogs_code" onclick="cnblogs_code_show('f6d9b226-be27-40a2-a3c2-424286c96fac')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_f6d9b226-be27-40a2-a3c2-424286c96fac" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span> com.tiantian.test;
<span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span> java.util.Calendar;
<span style="color: #008080;">  4</span> 
<span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span> android.app.Activity;
<span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span> android.app.DatePickerDialog;
<span style="color: #008080;">  7</span> <span style="color: #0000ff;">import</span> android.app.DatePickerDialog.OnDateSetListener;
<span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span> android.app.Dialog;
<span style="color: #008080;">  9</span> <span style="color: #0000ff;">import</span> android.app.TimePickerDialog;
<span style="color: #008080;"> 10</span> <span style="color: #0000ff;">import</span> android.app.TimePickerDialog.OnTimeSetListener;
<span style="color: #008080;"> 11</span> <span style="color: #0000ff;">import</span> android.content.Intent;
<span style="color: #008080;"> 12</span> <span style="color: #0000ff;">import</span> android.graphics.Bitmap;
<span style="color: #008080;"> 13</span> <span style="color: #0000ff;">import</span> android.graphics.BitmapFactory;
<span style="color: #008080;"> 14</span> <span style="color: #0000ff;">import</span> android.graphics.Matrix;
<span style="color: #008080;"> 15</span> <span style="color: #0000ff;">import</span> android.net.Uri;
<span style="color: #008080;"> 16</span> <span style="color: #0000ff;">import</span> android.os.Bundle;
<span style="color: #008080;"> 17</span> <span style="color: #0000ff;">import</span> android.os.SystemClock;
<span style="color: #008080;"> 18</span> <span style="color: #0000ff;">import</span> android.util.DisplayMetrics;
<span style="color: #008080;"> 19</span> <span style="color: #0000ff;">import</span> android.view.View;
<span style="color: #008080;"> 20</span> <span style="color: #0000ff;">import</span> android.view.View.OnClickListener;
<span style="color: #008080;"> 21</span> <span style="color: #0000ff;">import</span> android.widget.Button;
<span style="color: #008080;"> 22</span> <span style="color: #0000ff;">import</span> android.widget.Chronometer;
<span style="color: #008080;"> 23</span> <span style="color: #0000ff;">import</span> android.widget.DatePicker;
<span style="color: #008080;"> 24</span> <span style="color: #0000ff;">import</span> android.widget.DatePicker.OnDateChangedListener;
<span style="color: #008080;"> 25</span> <span style="color: #0000ff;">import</span> android.widget.ImageView;
<span style="color: #008080;"> 26</span> <span style="color: #0000ff;">import</span> android.widget.TextView;
<span style="color: #008080;"> 27</span> <span style="color: #0000ff;">import</span> android.widget.TimePicker;
<span style="color: #008080;"> 28</span> <span style="color: #0000ff;">import</span> android.widget.TimePicker.OnTimeChangedListener;
<span style="color: #008080;"> 29</span> <span style="color: #0000ff;">import</span> android.widget.ZoomControls;
<span style="color: #008080;"> 30</span> 
<span style="color: #008080;"> 31</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> TextAndridActivity <span style="color: #0000ff;">extends</span> Activity {
<span style="color: #008080;"> 32</span>     <span style="color: #008000;">/**</span><span style="color: #008000;"> Called when the activity is first created. </span><span style="color: #008000;">*/</span>
<span style="color: #008080;"> 33</span>     <span style="color: #0000ff;">private</span> TextView dateText;
<span style="color: #008080;"> 34</span>     <span style="color: #0000ff;">private</span> TextView timeText;
<span style="color: #008080;"> 35</span>     <span style="color: #0000ff;">private</span> Button dateButton;
<span style="color: #008080;"> 36</span>     <span style="color: #0000ff;">private</span> Button timeButton;
<span style="color: #008080;"> 37</span>     
<span style="color: #008080;"> 38</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> year;
<span style="color: #008080;"> 39</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> monthOfYear;
<span style="color: #008080;"> 40</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> dayOfMonth;
<span style="color: #008080;"> 41</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> hour;
<span style="color: #008080;"> 42</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> minute;
<span style="color: #008080;"> 43</span>     <span style="color: #008000;">//</span><span style="color: #008000;">声明一个独一无二的标识，来作为要显示DatePicker的Dialog的ID</span><span style="color: #008000;">
</span><span style="color: #008080;"> 44</span>     <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">int</span> DATE_DIALOG_ID = 1;
<span style="color: #008080;"> 45</span>     <span style="color: #008000;">//</span><span style="color: #008000;">声明一个独一无二的标识，来作为要显示TimePicker的Dialog的ID</span><span style="color: #008000;">
</span><span style="color: #008080;"> 46</span>     <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">int</span> TIME_DIALOG_ID = 2;
<span style="color: #008080;"> 47</span>     @Override
<span style="color: #008080;"> 48</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCreate(Bundle savedInstanceState) {
<span style="color: #008080;"> 49</span>         <span style="color: #0000ff;">super</span>.onCreate(savedInstanceState);
<span style="color: #008080;"> 50</span>         setContentView(R.layout.main);
<span style="color: #008080;"> 51</span>         
<span style="color: #008080;"> 52</span>         dateText = (TextView) findViewById(R.id.dateText);
<span style="color: #008080;"> 53</span>         timeText = (TextView) findViewById(R.id.timeText);
<span style="color: #008080;"> 54</span>         dateButton = (Button) findViewById(R.id.dateButton);
<span style="color: #008080;"> 55</span>         dateButton.setOnClickListener(<span style="color: #0000ff;">new</span> OnClickListener() {
<span style="color: #008080;"> 56</span>             
<span style="color: #008080;"> 57</span>             @Override
<span style="color: #008080;"> 58</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClick(View v) {
<span style="color: #008080;"> 59</span>                 <span style="color: #008000;">//</span><span style="color: #008000;">调用Activity类的方法来显示Dialog:调用这个方法会允许Activity管理该Dialog的生命周期，  
</span><span style="color: #008080;"> 60</span> <span style="color: #008000;">//</span><span style="color: #008000;">并会调用 onCreateDialog(int)回调函数来请求一个Dialog</span><span style="color: #008000;">
</span><span style="color: #008080;"> 61</span>                 showDialog(DATE_DIALOG_ID);
<span style="color: #008080;"> 62</span>             }
<span style="color: #008080;"> 63</span>         });
<span style="color: #008080;"> 64</span>         timeButton = (Button) findViewById(R.id.timeButton);
<span style="color: #008080;"> 65</span>         timeButton.setOnClickListener(<span style="color: #0000ff;">new</span> OnClickListener() {
<span style="color: #008080;"> 66</span>             
<span style="color: #008080;"> 67</span>             @Override
<span style="color: #008080;"> 68</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClick(View v) {
<span style="color: #008080;"> 69</span>                 <span style="color: #008000;">//</span><span style="color: #008000;">调用Activity类的方法来显示Dialog:调用这个方法会允许Activity管理该Dialog的生命周期，  
</span><span style="color: #008080;"> 70</span> <span style="color: #008000;">//</span><span style="color: #008000;">并会调用 onCreateDialog(int)回调函数来请求一个Dialog</span><span style="color: #008000;">
</span><span style="color: #008080;"> 71</span>                 showDialog(TIME_DIALOG_ID);
<span style="color: #008080;"> 72</span>             }
<span style="color: #008080;"> 73</span>         });
<span style="color: #008080;"> 74</span>         <span style="color: #008000;">//</span><span style="color: #008000;">得到当前日期和时间(作为初始值)</span><span style="color: #008000;">
</span><span style="color: #008080;"> 75</span>         Calendar calendar = Calendar.getInstance();
<span style="color: #008080;"> 76</span>         year = calendar.get(Calendar.YEAR);
<span style="color: #008080;"> 77</span>         monthOfYear = calendar.get(Calendar.MONTH);
<span style="color: #008080;"> 78</span>         dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);
<span style="color: #008080;"> 79</span>         hour = calendar.get(Calendar.HOUR_OF_DAY);
<span style="color: #008080;"> 80</span>         minute = calendar.get(Calendar.MINUTE);
<span style="color: #008080;"> 81</span>         
<span style="color: #008080;"> 82</span>     }
<span style="color: #008080;"> 83</span>     
<span style="color: #008080;"> 84</span>     <span style="color: #008000;">//</span><span style="color: #008000;">当Activity调用showDialog函数时会触发该函数的调用：</span><span style="color: #008000;">
</span><span style="color: #008080;"> 85</span>     @Override
<span style="color: #008080;"> 86</span>     <span style="color: #0000ff;">protected</span> Dialog onCreateDialog(<span style="color: #0000ff;">int</span> id) {
<span style="color: #008080;"> 87</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 88</span>         <span style="color: #0000ff;">switch</span>(id){
<span style="color: #008080;"> 89</span>         <span style="color: #0000ff;">case</span> DATE_DIALOG_ID:
<span style="color: #008080;"> 90</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span> DatePickerDialog(<span style="color: #0000ff;">this</span>, <span style="color: #0000ff;">new</span> OnDateSetListener() {
<span style="color: #008080;"> 91</span>                 
<span style="color: #008080;"> 92</span>                 @Override
<span style="color: #008080;"> 93</span>                 <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onDateSet(DatePicker view, <span style="color: #0000ff;">int</span> year, <span style="color: #0000ff;">int</span> monthOfYear,
<span style="color: #008080;"> 94</span>                         <span style="color: #0000ff;">int</span> dayOfMonth) {
<span style="color: #008080;"> 95</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 96</span>                     dateText.setText(year + "年" + (monthOfYear + 1) + "月" + dayOfMonth + "日");
<span style="color: #008080;"> 97</span>                 }
<span style="color: #008080;"> 98</span>             }, year, monthOfYear, dayOfMonth);
<span style="color: #008080;"> 99</span>         <span style="color: #0000ff;">case</span> TIME_DIALOG_ID:
<span style="color: #008080;">100</span>             <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span> TimePickerDialog(<span style="color: #0000ff;">this</span>, <span style="color: #0000ff;">new</span> OnTimeSetListener() {
<span style="color: #008080;">101</span>                 
<span style="color: #008080;">102</span>                 @Override
<span style="color: #008080;">103</span>                 <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onTimeSet(TimePicker view, <span style="color: #0000ff;">int</span> hourOfDay, <span style="color: #0000ff;">int</span> minute) {
<span style="color: #008080;">104</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">105</span>                     timeText.setText(hourOfDay + "时" + minute + "分");
<span style="color: #008080;">106</span>                 }
<span style="color: #008080;">107</span>             }, hour, minute, <span style="color: #0000ff;">true</span>);
<span style="color: #008080;">108</span>         }
<span style="color: #008080;">109</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span>;
<span style="color: #008080;">110</span>     }
<span style="color: #008080;">111</span>     
<span style="color: #008080;">112</span>     
<span style="color: #008080;">113</span>     
<span style="color: #008080;">114</span> }</pre>
</div>
</div>

