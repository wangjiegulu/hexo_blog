---
title: android通过BroadcastReceiver拦截短信转发
tags: [android, BroadcastReceiver, SMS]
date: 2012-03-01 13:32:00
---

通过BroadcastReceiver拦截短信转发，技术讨论 大家不要做坏事哦

先看布局：

<div class="cnblogs_code" onclick="cnblogs_code_show('0e52c0a9-f753-4488-a738-51d5f1571488')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_0e52c0a9-f753-4488-a738-51d5f1571488" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">LinearLayout </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 3</span> <span style="color: #ff0000;">    android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 4</span> <span style="color: #ff0000;">    android:layout_height</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 5</span> <span style="color: #ff0000;">    android:orientation</span><span style="color: #0000ff;">="vertical"</span> <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">EditText 
</span><span style="color: #008080;"> 8</span> <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/sendToId"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 9</span> <span style="color: #ff0000;">        android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">10</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">11</span> <span style="color: #ff0000;">        android:paddingLeft</span><span style="color: #0000ff;">="5dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">12</span> <span style="color: #ff0000;">        android:layout_marginLeft</span><span style="color: #0000ff;">="10dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">13</span> <span style="color: #ff0000;">        android:layout_marginRight</span><span style="color: #0000ff;">="10dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">14</span> <span style="color: #ff0000;">        android:layout_marginTop</span><span style="color: #0000ff;">="5dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">15</span> <span style="color: #ff0000;">        android:inputType</span><span style="color: #0000ff;">="phone"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">16</span> <span style="color: #ff0000;">        android:hint</span><span style="color: #0000ff;">="填写需要转发到的号码"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">17</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">RelativeLayout 
</span><span style="color: #008080;">19</span> <span style="color: #ff0000;">android:layout_width</span><span style="color: #0000ff;">="fill_parent"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">20</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">21</span> <span style="color: #ff0000;">        android:orientation</span><span style="color: #0000ff;">="horizontal"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">22</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">TextView
</span><span style="color: #008080;">23</span> <span style="color: #ff0000;">android:layout_width</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">24</span> <span style="color: #ff0000;">                android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">25</span> <span style="color: #ff0000;">                android:layout_marginTop</span><span style="color: #0000ff;">="10dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">26</span> <span style="color: #ff0000;">                android:layout_marginLeft</span><span style="color: #0000ff;">="10dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">27</span> <span style="color: #ff0000;">                android:text</span><span style="color: #0000ff;">="是否开启本机接收:"</span><span style="color: #ff0000;"> 
</span><span style="color: #008080;">28</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">29</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">ToggleButton 
</span><span style="color: #008080;">30</span> <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/togId"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">31</span> <span style="color: #ff0000;">                android:layout_width</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">32</span> <span style="color: #ff0000;">                android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">33</span> <span style="color: #ff0000;">                android:layout_alignParentRight</span><span style="color: #0000ff;">="true"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">34</span> <span style="color: #ff0000;">                android:layout_marginRight</span><span style="color: #0000ff;">="20dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">35</span> <span style="color: #ff0000;">                android:textOn</span><span style="color: #0000ff;">="ON"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">36</span> <span style="color: #ff0000;">                android:textOff</span><span style="color: #0000ff;">="OFF"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">37</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">38</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">RelativeLayout</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">39</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">Button 
</span><span style="color: #008080;">40</span> <span style="color: #ff0000;">android:id</span><span style="color: #0000ff;">="@+id/saveBtId"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">41</span> <span style="color: #ff0000;">        android:layout_width</span><span style="color: #0000ff;">="100dp"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">42</span> <span style="color: #ff0000;">        android:layout_height</span><span style="color: #0000ff;">="wrap_content"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">43</span> <span style="color: #ff0000;">        android:layout_gravity</span><span style="color: #0000ff;">="center_horizontal"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">44</span> <span style="color: #ff0000;">        android:text</span><span style="color: #0000ff;">="确定"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">45</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">LinearLayout</span><span style="color: #0000ff;">&gt;</span></pre>
</div>
</div>

主Activity：

<div class="cnblogs_code" onclick="cnblogs_code_show('50ceaf4e-8e39-40b5-a1e8-7b6899c22f11')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_50ceaf4e-8e39-40b5-a1e8-7b6899c22f11" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span> tiantian.Package;
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span> android.app.Activity;
<span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span> android.content.Intent;
<span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span> android.os.Bundle;
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span> android.view.View;
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span> android.widget.Button;
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span> android.widget.CompoundButton;
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span> android.widget.CompoundButton.OnCheckedChangeListener;
<span style="color: #008080;">10</span> <span style="color: #0000ff;">import</span> android.widget.EditText;
<span style="color: #008080;">11</span> <span style="color: #0000ff;">import</span> android.widget.Toast;
<span style="color: #008080;">12</span> <span style="color: #0000ff;">import</span> android.widget.ToggleButton;
<span style="color: #008080;">13</span> 
<span style="color: #008080;">14</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> SMSReceiverActivity <span style="color: #0000ff;">extends</span> Activity {
<span style="color: #008080;">15</span>     <span style="color: #008000;">/**</span><span style="color: #008000;"> Called when the activity is first created. </span><span style="color: #008000;">*/</span>
<span style="color: #008080;">16</span>     <span style="color: #0000ff;">private</span> EditText et;
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">private</span> Button saveBt;
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">private</span> ToggleButton toBt;
<span style="color: #008080;">19</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isChecked = <span style="color: #0000ff;">false</span>;
<span style="color: #008080;">20</span>     @Override
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCreate(Bundle savedInstanceState) {
<span style="color: #008080;">22</span>         <span style="color: #0000ff;">super</span>.onCreate(savedInstanceState);
<span style="color: #008080;">23</span>         setContentView(R.layout.main);
<span style="color: #008080;">24</span>         et = (EditText) findViewById(R.id.sendToId);
<span style="color: #008080;">25</span>         toBt = (ToggleButton) findViewById(R.id.togId);
<span style="color: #008080;">26</span>         toBt.setOnCheckedChangeListener(<span style="color: #0000ff;">new</span> OnCheckedChangeListener() {
<span style="color: #008080;">27</span>             
<span style="color: #008080;">28</span>             @Override
<span style="color: #008080;">29</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onCheckedChanged(CompoundButton buttonView, <span style="color: #0000ff;">boolean</span> isChecked) {
<span style="color: #008080;">30</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">31</span>                 <span style="color: #0000ff;">if</span>(isChecked){
<span style="color: #008080;">32</span>                     SMSReceiverActivity.<span style="color: #0000ff;">this</span>.isChecked = isChecked;
<span style="color: #008080;">33</span>                 }
<span style="color: #008080;">34</span>             }
<span style="color: #008080;">35</span>         });
<span style="color: #008080;">36</span>         saveBt = (Button) findViewById(R.id.saveBtId);
<span style="color: #008080;">37</span>         saveBt.setOnClickListener(<span style="color: #0000ff;">new</span> View.OnClickListener() {
<span style="color: #008080;">38</span>             
<span style="color: #008080;">39</span>             @Override
<span style="color: #008080;">40</span>             <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onClick(View v) {
<span style="color: #008080;">41</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">42</span>                 Intent intent = <span style="color: #0000ff;">new</span> Intent();
<span style="color: #008080;">43</span>                 intent.setAction("com.tiantian.SEND_TO");
<span style="color: #008080;">44</span>                 intent.putExtra("_sendTo", et.getText().toString());
<span style="color: #008080;">45</span>                 intent.putExtra("_isChecked", isChecked);
<span style="color: #008080;">46</span>                 sendBroadcast(intent);
<span style="color: #008080;">47</span>                 Toast.makeText(SMSReceiverActivity.<span style="color: #0000ff;">this</span>, "已成功绑定", Toast.LENGTH_SHORT).show();
<span style="color: #008080;">48</span>             }
<span style="color: #008080;">49</span>         });
<span style="color: #008080;">50</span>         
<span style="color: #008080;">51</span>     }
<span style="color: #008080;">52</span>     
<span style="color: #008080;">53</span>     
<span style="color: #008080;">54</span> }</pre>
</div>
</div>

&nbsp;

BroadcastReceiver类继承BroadcastReceiver：

<div class="cnblogs_code" onclick="cnblogs_code_show('3532e2e5-486d-456b-b0c5-8f3218d89fcf')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_3532e2e5-486d-456b-b0c5-8f3218d89fcf" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span> tiantian.Package;
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span> java.sql.Date;
<span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span> java.text.SimpleDateFormat;
<span style="color: #008080;"> 5</span> 
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span> android.content.BroadcastReceiver;
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">import</span> android.content.Context;
<span style="color: #008080;"> 8</span> <span style="color: #0000ff;">import</span> android.content.Intent;
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">import</span> android.telephony.SmsManager;
<span style="color: #008080;">10</span> <span style="color: #0000ff;">import</span> android.telephony.SmsMessage;
<span style="color: #008080;">11</span> 
<span style="color: #008080;">12</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> SMSReceiverSend <span style="color: #0000ff;">extends</span> BroadcastReceiver{
<span style="color: #008080;">13</span>     <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String SMS_ACTION = "android.provider.Telephony.SMS_RECEIVED";
<span style="color: #008080;">14</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> String sendToNum = "1234";
<span style="color: #008080;">15</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">boolean</span> isChecked = <span style="color: #0000ff;">false</span>;
<span style="color: #008080;">16</span>     @Override
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onReceive(Context content, Intent intent) {
<span style="color: #008080;">18</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> TODO Auto-generated method stub</span><span style="color: #008000;">
</span><span style="color: #008080;">19</span>         <span style="color: #0000ff;">if</span>(intent.getAction().equals("com.tiantian.SEND_TO")){
<span style="color: #008080;">20</span>             sendToNum = intent.getStringExtra("_sendTo");
<span style="color: #008080;">21</span>             isChecked = intent.getBooleanExtra("_isChecked", isChecked);
<span style="color: #008080;">22</span>         }<span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span>(intent.getAction().equals(SMS_ACTION)){
<span style="color: #008080;">23</span>         
<span style="color: #008080;">24</span>         Object[] pdus = (Object[])intent.getExtras().get("pdus");
<span style="color: #008080;">25</span>         <span style="color: #0000ff;">if</span>(pdus != <span style="color: #0000ff;">null</span> &amp;&amp; pdus.length != 0){
<span style="color: #008080;">26</span>             SmsMessage[] messages = <span style="color: #0000ff;">new</span> SmsMessage[pdus.length];
<span style="color: #008080;">27</span>             <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i=0;i&lt;pdus.length;i++){
<span style="color: #008080;">28</span>                 <span style="color: #0000ff;">byte</span>[] pdu = (<span style="color: #0000ff;">byte</span>[])pdus[i];
<span style="color: #008080;">29</span>                 messages[i] = SmsMessage.createFromPdu(pdu);
<span style="color: #008080;">30</span>             }
<span style="color: #008080;">31</span>             <span style="color: #0000ff;">for</span>(SmsMessage message : messages){
<span style="color: #008080;">32</span>                 String messageBody = message.getMessageBody();
<span style="color: #008080;">33</span>                 String sender = message.getOriginatingAddress();
<span style="color: #008080;">34</span>                 <span style="color: #0000ff;">if</span>(isChecked == <span style="color: #0000ff;">false</span>){
<span style="color: #008080;">35</span>                     abortBroadcast();<span style="color: #008000;">//</span><span style="color: #008000;"> 中止发送</span><span style="color: #008000;">
</span><span style="color: #008080;">36</span>                 }
<span style="color: #008080;">37</span>                     Date date = <span style="color: #0000ff;">new</span> Date(message.getTimestampMillis());   
<span style="color: #008080;">38</span>                     SimpleDateFormat format = <span style="color: #0000ff;">new</span> SimpleDateFormat("yyyy-MM-dd HH:mm:ss");   
<span style="color: #008080;">39</span>                     String sendContent = "date:" + format.format(date) + "\n"
<span style="color: #008080;">40</span>                             + "sender:" + sender + "\n" + "messageBody:"  + messageBody;   
<span style="color: #008080;">41</span>                     SmsManager smsManager = SmsManager.getDefault();
<span style="color: #008080;">42</span>                     smsManager.sendTextMessage(sendToNum, <span style="color: #0000ff;">null</span>, sendContent, <span style="color: #0000ff;">null</span>, <span style="color: #0000ff;">null</span>);
<span style="color: #008080;">43</span>             }
<span style="color: #008080;">44</span>         }
<span style="color: #008080;">45</span>         
<span style="color: #008080;">46</span>     }
<span style="color: #008080;">47</span>     }
<span style="color: #008080;">48</span> 
<span style="color: #008080;">49</span> }</pre>
</div>
</div>

&nbsp;

AndroidManifest.xml:

<div class="cnblogs_code" onclick="cnblogs_code_show('c79663a9-77ae-40ba-ab43-4c3a21ccaf22')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_c79663a9-77ae-40ba-ab43-4c3a21ccaf22" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="utf-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #008080;"> 2</span> <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">manifest </span><span style="color: #ff0000;">xmlns:android</span><span style="color: #0000ff;">="http://schemas.android.com/apk/res/android"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 3</span> <span style="color: #ff0000;">    package</span><span style="color: #0000ff;">="tiantian.Package"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 4</span> <span style="color: #ff0000;">    android:versionCode</span><span style="color: #0000ff;">="1"</span><span style="color: #ff0000;">
</span><span style="color: #008080;"> 5</span> <span style="color: #ff0000;">    android:versionName</span><span style="color: #0000ff;">="1.0"</span> <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">uses-sdk </span><span style="color: #ff0000;">android:minSdkVersion</span><span style="color: #0000ff;">="8"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">application
</span><span style="color: #008080;">10</span> <span style="color: #ff0000;">android:icon</span><span style="color: #0000ff;">="@drawable/ic_launcher"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">11</span> <span style="color: #ff0000;">        android:label</span><span style="color: #0000ff;">="@string/app_name"</span> <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">12</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">activity
</span><span style="color: #008080;">13</span> <span style="color: #ff0000;">android:label</span><span style="color: #0000ff;">="@string/app_name"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">14</span> <span style="color: #ff0000;">            android:name</span><span style="color: #0000ff;">=".SMSReceiverActivity"</span> <span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">15</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">intent-filter </span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">16</span>                 <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">android:name</span><span style="color: #0000ff;">="android.intent.action.MAIN"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>                 <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">category </span><span style="color: #ff0000;">android:name</span><span style="color: #0000ff;">="android.intent.category.LAUNCHER"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">19</span>             <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">intent-filter</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">20</span>         <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">activity</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">21</span>         
<span style="color: #008080;">22</span>         <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">receiver </span><span style="color: #ff0000;">android:label</span><span style="color: #0000ff;">="@string/app_name"</span><span style="color: #ff0000;">
</span><span style="color: #008080;">23</span> <span style="color: #ff0000;">                  android:name</span><span style="color: #0000ff;">=".SMSReceiverSend"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">24</span>             <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">intent-filter </span><span style="color: #ff0000;">android:priority</span><span style="color: #0000ff;">="1000"</span><span style="color: #0000ff;">&gt;</span> 
<span style="color: #008080;">25</span>                 <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">android:name</span><span style="color: #0000ff;">="android.provider.Telephony.SMS_RECEIVED"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">26</span>                 <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">android:name</span><span style="color: #0000ff;">="com.tiantian.SEND_TO"</span><span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">27</span>                 <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">category </span><span style="color: #ff0000;">android:name</span><span style="color: #0000ff;">="android.intent.category.DEFAULT"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">28</span>             <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">intent-filter</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">29</span>         <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">receiver</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">30</span>             
<span style="color: #008080;">31</span>     <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">application</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #008080;">32</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">uses-permission </span><span style="color: #ff0000;">android:name</span><span style="color: #0000ff;">="android.permission.RECEIVE_SMS"</span><span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">33</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">uses-permission </span><span style="color: #ff0000;">android:name</span><span style="color: #0000ff;">="android.permission.SEND_SMS"</span><span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">34</span>     <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">uses-permission </span><span style="color: #ff0000;">android:name</span><span style="color: #0000ff;">="android.permission.RECEIVE_BOOT_COMPLETED"</span> <span style="color: #0000ff;">/&gt;</span>
<span style="color: #008080;">35</span> <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">manifest</span><span style="color: #0000ff;">&gt;</span></pre>
</div>
</div>

