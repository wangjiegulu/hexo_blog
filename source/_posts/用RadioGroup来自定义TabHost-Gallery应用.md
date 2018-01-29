---
title: 用RadioGroup来自定义TabHost+Gallery应用
tags: []
date: 2012-02-24 11:06:00
---

**效果图：**

![](http://pic002.cnblogs.com/images/2012/378300/2012022410541464.jpg)

&nbsp;

**思路：****用RadioGroup来自定义Tab（当然用其他的ImageButton等也可以实现）**

mainActivity代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span> com.tiantian.test;
<span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span> android.app.TabActivity;
<span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span> android.content.Context;
<span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span> android.content.Intent;
<span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span> android.content.res.TypedArray;
<span style="color: #008080;">  7</span> <span style="color: #0000ff;">import</span> android.os.Bundle;
<span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span> android.os.Handler;
<span style="color: #008080;">  9</span> <span style="color: #0000ff;">import</span> android.os.Message;
<span style="color: #008080;"> 10</span> <span style="color: #0000ff;">import</span> android.view.View;
<span style="color: #008080;"> 11</span> <span style="color: #0000ff;">import</span> android.view.ViewGroup;
<span style="color: #008080;"> 12</span> <span style="color: #0000ff;">import</span> android.widget.BaseAdapter;
<span style="color: #008080;"> 13</span> <span style="color: #0000ff;">import</span> android.widget.Gallery;
<span style="color: #008080;"> 14</span> <span style="color: #0000ff;">import</span> android.widget.ImageView;
<span style="color: #008080;"> 15</span> <span style="color: #0000ff;">import</span> android.widget.RadioButton;
<span style="color: #008080;"> 16</span> <span style="color: #0000ff;">import</span> android.widget.RadioGroup;
<span style="color: #008080;"> 17</span> <span style="color: #0000ff;">import</span> android.widget.TabHost;
<span style="color: #008080;"> 18</span> 
<span style="color: #008080;"> 19</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> TabDemoActivity <span style="color: #0000ff;">extends</span> TabActivity {
<span style="color: #008080;"> 20</span>     <span style="color: #008000;">/**</span><span style="color: #008000;"> Called when the activity is first created. </span><span style="color: #008000;">*/</span>
<span style="color: #008080;"> 21</span>     TabHost tab;
<span style="color: #008080;"> 22</span>     RadioGroup tab_radioGroup;
<span style="color: #008080;"> 23</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span>[] images = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">int</span>[]{
<span style="color: #008080;"> 24</span>             R.drawable.g1,R.drawable.g2,R.drawable.g3,
<span style="color: #008080;"> 25</span>             R.drawable.g4,R.drawable.g5,R.drawable.g6
<span style="color: #008080;"> 26</span>     };
<span style="color: #008080;"> 27</span>     @Override
<span style="color: #008080;"> 28</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCreate(Bundle savedInstanceState) {
<span style="color: #008080;"> 29</span>         <span style="color: #0000ff;">super</span>.onCreate(savedInstanceState);
<span style="color: #008080;"> 30</span>         setContentView(R.layout.main);
<span style="color: #008080;"> 31</span>         Gallery gallery = (Gallery)findViewById(R.id.gallery);
<span style="color: #008080;"> 32</span>         gallery.setAdapter(<span style="color: #0000ff;">new</span> ImageAdapter(<span style="color: #0000ff;">this</span>));
<span style="color: #008080;"> 33</span>         
<span style="color: #008080;"> 34</span>         tab = getTabHost();
<span style="color: #008080;"> 35</span>         tab.addTab(tab.newTabSpec("Spec-TabList")
<span style="color: #008080;"> 36</span>                 .setIndicator("Ind-TabList")
<span style="color: #008080;"> 37</span>                 .setContent(<span style="color: #0000ff;">new</span> Intent(<span style="color: #0000ff;">this</span>, TabList.<span style="color: #0000ff;">class</span>)));
<span style="color: #008080;"> 38</span>         tab.addTab(tab.newTabSpec("Spec-secondDemo")
<span style="color: #008080;"> 39</span>                 .setIndicator("Ind-secondDemo")
<span style="color: #008080;"> 40</span>                 .setContent(<span style="color: #0000ff;">new</span> Intent(<span style="color: #0000ff;">this</span>, secondDemo.<span style="color: #0000ff;">class</span>)));
<span style="color: #008080;"> 41</span>         tab.addTab(tab.newTabSpec("Spec-thirdDemo")
<span style="color: #008080;"> 42</span>                 .setIndicator("Ind-thirdDemo")
<span style="color: #008080;"> 43</span>                 .setContent(<span style="color: #0000ff;">new</span> Intent(<span style="color: #0000ff;">this</span>, thirdDemo.<span style="color: #0000ff;">class</span>)));
<span style="color: #008080;"> 44</span>         tab.addTab(tab.newTabSpec("Spec-fourthDemo")
<span style="color: #008080;"> 45</span>                 .setIndicator("Ind-fourthDemo")
<span style="color: #008080;"> 46</span>                 .setContent(<span style="color: #0000ff;">new</span> Intent(<span style="color: #0000ff;">this</span>, fourthDemo.<span style="color: #0000ff;">class</span>)));
<span style="color: #008080;"> 47</span>         tab.addTab(tab.newTabSpec("Spec-fifthDemo")
<span style="color: #008080;"> 48</span>                 .setIndicator("Ind-fifthDemo")
<span style="color: #008080;"> 49</span>                 .setContent(<span style="color: #0000ff;">new</span> Intent(<span style="color: #0000ff;">this</span>, fifthDemo.<span style="color: #0000ff;">class</span>)));
<span style="color: #008080;"> 50</span>         
<span style="color: #008080;"> 51</span>         tab_radioGroup = (RadioGroup)findViewById(R.id.tab_radiogroup);
<span style="color: #008080;"> 52</span>         tab_radioGroup.setOnCheckedChangeListener(<span style="color: #0000ff;">new</span> RadioGroup.OnCheckedChangeListener() {
<span style="color: #008080;"> 53</span>             
<span style="color: #008080;"> 54</span>             @Override
<span style="color: #008080;"> 55</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCheckedChanged(RadioGroup group, <span style="color: #0000ff;">int</span> checkedId) {
<span style="color: #008080;"> 56</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 57</span>                 <span style="color: #0000ff;">switch</span>(checkedId){
<span style="color: #008080;"> 58</span>                 <span style="color: #0000ff;">case</span> R.id.radioButton0:
<span style="color: #008080;"> 59</span>                     tab.setCurrentTabByTag("Spec-TabList");
<span style="color: #008080;"> 60</span>                     <span style="color: #0000ff;">break</span>;
<span style="color: #008080;"> 61</span>                 <span style="color: #0000ff;">case</span> R.id.radioButton1:
<span style="color: #008080;"> 62</span>                     tab.setCurrentTabByTag("Spec-secondDemo");
<span style="color: #008080;"> 63</span>                     <span style="color: #0000ff;">break</span>;
<span style="color: #008080;"> 64</span>                 <span style="color: #0000ff;">case</span> R.id.radioButton2:
<span style="color: #008080;"> 65</span>                     tab.setCurrentTabByTag("Spec-thirdDemo");
<span style="color: #008080;"> 66</span>                     <span style="color: #0000ff;">break</span>;
<span style="color: #008080;"> 67</span>                 <span style="color: #0000ff;">case</span> R.id.radioButton3:
<span style="color: #008080;"> 68</span>                     tab.setCurrentTabByTag("Spec-fourthDemo");
<span style="color: #008080;"> 69</span>                     <span style="color: #0000ff;">break</span>;
<span style="color: #008080;"> 70</span>                 <span style="color: #0000ff;">case</span> R.id.radioButton4:
<span style="color: #008080;"> 71</span>                     tab.setCurrentTabByTag("Spec-fifthDemo");
<span style="color: #008080;"> 72</span>                     <span style="color: #0000ff;">break</span>;
<span style="color: #008080;"> 73</span>                 }
<span style="color: #008080;"> 74</span>             }
<span style="color: #008080;"> 75</span>         });
<span style="color: #008080;"> 76</span>         <span style="color: #008000;">//</span><span style="color: #008000;">使他初始化后聚焦在第一个RadioGroup对象</span><span style="color: #008000;">
</span><span style="color: #008080;"> 77</span>         ((RadioButton) tab_radioGroup.getChildAt(0)).toggle();
<span style="color: #008080;"> 78</span>         
<span style="color: #008080;"> 79</span>     }
<span style="color: #008080;"> 80</span>     
<span style="color: #008080;"> 81</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> ImageAdapter <span style="color: #0000ff;">extends</span> BaseAdapter{
<span style="color: #008080;"> 82</span>         <span style="color: #0000ff;">private</span> Context context;
<span style="color: #008080;"> 83</span> <span style="color: #008000;">//</span><span style="color: #008000;">        private int[] images = new int[]{
</span><span style="color: #008080;"> 84</span> <span style="color: #008000;">//</span><span style="color: #008000;">                R.drawable.g1,R.drawable.g2,R.drawable.g3,
</span><span style="color: #008080;"> 85</span> <span style="color: #008000;">//</span><span style="color: #008000;">                R.drawable.g4,R.drawable.g5,R.drawable.g6
</span><span style="color: #008080;"> 86</span> <span style="color: #008000;">//</span><span style="color: #008000;">        };</span><span style="color: #008000;">
</span><span style="color: #008080;"> 87</span>         <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span> mGalleryItemBackground;
<span style="color: #008080;"> 88</span>         <span style="color: #0000ff;">public</span> ImageAdapter(Context context) {
<span style="color: #008080;"> 89</span>             <span style="color: #0000ff;">super</span>();
<span style="color: #008080;"> 90</span>             <span style="color: #0000ff;">this</span>.context = context;
<span style="color: #008080;"> 91</span>             TypedArray a = obtainStyledAttributes(R.styleable.Gallery);
<span style="color: #008080;"> 92</span>             mGalleryItemBackground = a.getResourceId(R.styleable.Gallery_android_galleryItemBackground, 0);
<span style="color: #008080;"> 93</span>             a.recycle();
<span style="color: #008080;"> 94</span>         }
<span style="color: #008080;"> 95</span> 
<span style="color: #008080;"> 96</span>         @Override
<span style="color: #008080;"> 97</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> getCount() {
<span style="color: #008080;"> 98</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;"> 99</span>             <span style="color: #0000ff;">return</span> images.length;
<span style="color: #008080;">100</span>         }
<span style="color: #008080;">101</span> 
<span style="color: #008080;">102</span>         @Override
<span style="color: #008080;">103</span>         <span style="color: #0000ff;">public</span> Object getItem(<span style="color: #0000ff;">int</span> arg0) {
<span style="color: #008080;">104</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">105</span>             <span style="color: #0000ff;">return</span> images[arg0];
<span style="color: #008080;">106</span>         }
<span style="color: #008080;">107</span> 
<span style="color: #008080;">108</span>         @Override
<span style="color: #008080;">109</span>         <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">long</span> getItemId(<span style="color: #0000ff;">int</span> position) {
<span style="color: #008080;">110</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">111</span>             <span style="color: #0000ff;">return</span> position;
<span style="color: #008080;">112</span>         } 
<span style="color: #008080;">113</span>         
<span style="color: #008080;">114</span>         @Override
<span style="color: #008080;">115</span>         <span style="color: #0000ff;">public</span> View getView(<span style="color: #0000ff;">int</span> position, View convertView, ViewGroup parent) {
<span style="color: #008080;">116</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">117</span>             ImageView image = <span style="color: #0000ff;">new</span> ImageView(context);
<span style="color: #008080;">118</span>             image.setImageResource(images[position]);
<span style="color: #008080;">119</span>             image.setScaleType(ImageView.ScaleType.FIT_XY);
<span style="color: #008080;">120</span>             image.setLayoutParams(<span style="color: #0000ff;">new</span> Gallery.LayoutParams(120, 100));
<span style="color: #008080;">121</span>             image.setBackgroundResource(mGalleryItemBackground);
<span style="color: #008080;">122</span>             <span style="color: #0000ff;">return</span> image;
<span style="color: #008080;">123</span>         }
<span style="color: #008080;">124</span>         
<span style="color: #008080;">125</span>     }
<span style="color: #008080;">126</span>     
<span style="color: #008080;">127</span> }</pre>
</div>

对应的布局文件：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TabHost 
</span><span style="color: #008080;"> 3</span> 　　　<span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@android:id/tabhost"</span><span style="color: #ff0000;"> 
</span><span style="color: #008080;"> 4</span> <span style="color: #ff0000;">    android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 5</span> <span style="color: #ff0000;">    android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;"> 
</span><span style="color: #008080;"> 6</span> <span style="color: #ff0000;">    xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 7</span>     
<span style="color: #008080;"> 8</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout 
</span><span style="color: #008080;"> 9　　　</span> <span style="color: #ff0000;">android:orientation</span><span style="color: #0000ff;">="vertical"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">10</span> <span style="color: #ff0000;">    android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;"> 
</span><span style="color: #008080;">11</span> <span style="color: #ff0000;">    android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">12</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">Gallery 
</span><span style="color: #008080;">13</span> 　　　　　　<span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/gallery"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">14</span> <span style="color: #ff0000;">        android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">15</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">16</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">17</span>         
<span style="color: #008080;">18</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TabWidget 
</span><span style="color: #008080;">19　　　　</span> <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@android:id/tabs"</span><span style="color: #ff0000;"> 
</span><span style="color: #008080;">20</span> <span style="color: #ff0000;">        android:visibility</span><span style="color: #0000ff;">="gone"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">21</span> <span style="color: #ff0000;">        android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">22</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">23</span> <span style="color: #ff0000;">        android:layout_weight</span><span style="color: #0000ff;">="0.0"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">24</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">FrameLayout 
</span><span style="color: #008080;">25</span> 　　　　　　　　<span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@android:id/tabcontent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">26</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;"> 
</span><span style="color: #008080;">27</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="0.0dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">28</span> <span style="color: #ff0000;">            android:layout_weight</span><span style="color: #0000ff;">="1.0"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">29</span>         
<span style="color: #008080;">30</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioGroup 
</span><span style="color: #008080;">31</span> 　　　　　　　　<span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/tab_radiogroup"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">32</span> <span style="color: #ff0000;">            android:orientation</span><span style="color: #0000ff;">="horizontal"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">33</span> <span style="color: #ff0000;">            android:background</span><span style="color: #0000ff;">="@drawable/tab_widget_background"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">34</span> <span style="color: #ff0000;">            android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;"> 
</span><span style="color: #008080;">35</span> <span style="color: #ff0000;">            android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">36</span> <span style="color: #ff0000;">            android:padding</span><span style="color: #0000ff;">="2dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">37</span> <span style="color: #ff0000;">            android:gravity</span><span style="color: #0000ff;">="center_vertical"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">38</span> <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">39</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton 
</span><span style="color: #008080;">40</span> 　　　　　　　　　　<span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/radioButton0"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">41</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="评分"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">42</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tab_icon1"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">43</span> <span style="color: #ff0000;">                style</span><span style="color: #0000ff;">="@style/tab_item_background"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">44</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">45</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton 
</span><span style="color: #008080;">46　　　　　　　　　　</span> <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/radioButton1"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">47</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="紫色"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">48</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tab_icon2"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">49</span> <span style="color: #ff0000;">                style</span><span style="color: #0000ff;">="@style/tab_item_background"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">50</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">51</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton 
</span><span style="color: #008080;">52</span> 　　　　　　　　　　<span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/radioButton2"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">53</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="红色"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">54</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tab_icon3"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">55</span> <span style="color: #ff0000;">                style</span><span style="color: #0000ff;">="@style/tab_item_background"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">56</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">57</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton 
</span><span style="color: #008080;">58　　　　　　　　　　</span> <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/radioButton3"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">59</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="蓝色"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">60</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tab_icon4"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">61</span> <span style="color: #ff0000;">                style</span><span style="color: #0000ff;">="@style/tab_item_background"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">62</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">63</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RadioButton 
</span><span style="color: #008080;">64</span> 　　　　　　　　　<span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/radioButton4"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">65</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="绿色"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">66</span> <span style="color: #ff0000;">                android:drawableTop</span><span style="color: #0000ff;">="@drawable/tab_icon5"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">67</span> <span style="color: #ff0000;">                style</span><span style="color: #0000ff;">="@style/tab_item_background"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">68</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">69</span>         <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">RadioGroup</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">70</span>         
<span style="color: #008080;">71</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">72</span>     
<span style="color: #008080;">73</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">TabHost</span><span style="color: #0000ff;">&gt;</span></pre>
</div>