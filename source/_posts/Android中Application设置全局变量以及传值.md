---
title: Android中Application设置全局变量以及传值
tags: []
date: 2012-06-14 10:25:00
---

<span>Application设置全局变量以及传值&nbsp;</span>

1.  /**
2.  * 重写Application，主要重写里面的onCreate方法，就是创建的时候，
3.  * 我们让它初始化一些值，前段时间在javaeye里面看到过一个例子，与此相似，
4.  * 我做了些改进。听说外国开发者习惯用此初始化一些全局变量，好像在Activity
5.  * 一些类里面初始化全局变量的化，会遇到一些空指针的异常，当然，我没有遇到过。
6.  * 如果用此方法初始化的话，那么就可以避免那些有可能出现的错误。
7.  *&nbsp;
8.  * 启动Application，他就会创建一个PID，就是进程ID，所有的Activity就会在此进程上运行。
9.  * 那么我们在Application创建的时候初始化全局变量，那么是不是所有的Activity都可以拿到这些
10.  * 全局变量，再进一步说，我们在某一个Activity中改变了这些全局变量的值，那么在别的Activity中
11.  * 是不是值就改变了呢，这个算不算传值呢？
12.  * OK，那么下面的例子我们测试下。。。
13.  * @author yong.wang
14.  *
15.  */
16.  public class MyApplication extends Application {
17.18.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;private String name;
19.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
20.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;@Override
21.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;public void onCreate() {
22.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; super.onCreate();
23.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; setName(NAME); //初始化全局变量
24.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;}
25.26.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;public String getName() {
27.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; return name;
28.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;}
29.30.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;public void setName(String name) {
31.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; this.name = name;
32.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;}
33.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
34.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;private static final String NAME = "MyApplication";
35.  }

<span>//Ok,应用程序创建好了，不过我们应该在配置文件ApplicationManifest.xml中将要运行的应用程序MyApplication加进去，修改下:</span>

1.  &lt;?xml version="1.0" encoding="utf-8"?&gt;
2.  &lt;manifest xmlns:android="http://schemas.android.com/apk/res/android"
3.  &nbsp; &nbsp;&nbsp; &nbsp;package="com.hisoft.app"
4.  &nbsp; &nbsp;&nbsp; &nbsp;android:versionCode="1"
5.  &nbsp; &nbsp;&nbsp; &nbsp;android:versionName="1.0"&gt;
6.  &nbsp; &nbsp; &lt;application android:icon="@drawable/icon" android:label="@string/app_name"
7.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;android:name=".MyApplication"&gt;&nbsp;&nbsp;就是这儿，将我们以前一直用的默认Application给他设置成我们自己做的MyApplication
8.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&lt;activity&nbsp;android:name=".MyFirstActivity"
9.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;android:label="@string/app_name"&gt;
10.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&lt;intent-filter&gt;
11.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &lt;action android:name="android.intent.action.MAIN" /&gt;
12.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &lt;category android:name="android.intent.category.LAUNCHER" /&gt;
13.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&lt;/intent-filter&gt;
14.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&lt;/activity&gt;
15.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&lt;activity android:name=".MySecondActivity"&gt;&lt;/activity&gt;
16.  &nbsp; &nbsp; &lt;/application&gt;
17.  &nbsp; &nbsp; &lt;uses-sdk&nbsp;android:minSdkVersion="8" /&gt;
18.19.  &lt;/manifest&gt;

<span>当xml配置文件运行完android:name=".MyApplication"&gt;，在此那么就分配好了进程ID，再下面，我们就要运行我们的Activity了</span>

1.  public class MyFirstActivity extends Activity {
2.  &nbsp; &nbsp;&nbsp;
3.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;private MyApplication app;
4.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
5.  &nbsp; &nbsp; @Override
6.  &nbsp; &nbsp; public void onCreate(Bundle savedInstanceState) {
7.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;super.onCreate(savedInstanceState);
8.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;setContentView(R.layout.main);
9.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;app = (MyApplication) getApplication(); //获得我们的应用程序MyApplication
10.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;Log.e("MyFirstActivityOriginal", app.getName());&nbsp; &nbsp;//将我们放到进程中的全局变量拿出来，看是不是我们曾经设置的值
11.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;app.setName("is cool");&nbsp;&nbsp;//OK，现在我们开始修改了
12.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;Log.e("MyFirstActivityChanged", app.getName()); //再看下，这个值改变了没有
13.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;Intent&nbsp;intent = new Intent();&nbsp;&nbsp;//更重要的是我们可以看在别的Activity中是拿到初始化的值，还是修改后的
14.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;intent.setClass(this, MySecondActivity.class);
15.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;startActivity(intent);
16.  &nbsp; &nbsp; }
17.  }

<span>上面运行完了，就要跳到这个Activity了</span>

1.  public class MySecondActivity extends Activity {
2.3.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;private MyApplication app;
4.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
5.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;@Override
6.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;protected void onCreate(Bundle savedInstanceState) {
7.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; super.onCreate(savedInstanceState);
8.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; setContentView(R.layout.main);
9.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; app = (MyApplication) getApplication();&nbsp;&nbsp;//获取应用程序
10.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; Log.e("MySecondActivity", app.getName()); //获取全局值
11.  &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;}&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
12.  }

_复制代码_

<span>OK，看下值：当然我已经运行过了，</span>
<span>MyFirstActivityOriginal&nbsp; &nbsp;&nbsp; &nbsp; MyApplication&nbsp;</span>
<span>MyFirstActivityChanged&nbsp; &nbsp;&nbsp;&nbsp;is cool</span>
<span>MySecondActivity&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; is cool</span>
<span>看看，是不是特别令人兴奋,当然有可能你退出之后再运行的时候，就第2、3。。。次，有可能会3个输出全是 is cool，那是你没杀掉进程的问题。</span>