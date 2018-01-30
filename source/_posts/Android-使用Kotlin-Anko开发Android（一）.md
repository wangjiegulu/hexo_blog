---
title: '[Android]使用Kotlin+Anko开发Android（一）'
tags: [android, kotlin, anko]
date: 2015-09-11 13:20:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span style="color: #ff0000;">**来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/4800656.html](http://www.cnblogs.com/tiantianbyconan/p/4800656.html)&nbsp;**</span>

&nbsp;

Kotlin是由JetBrains开发并且开源的静态类型JVM语言。比Java语言语法简洁，支持很多Java中不支持的语法特性，如高阶函数、內联函数、null安全、灵活扩展、操作符重载等等。而且它还完全兼容Java，与Scala类似，但是Scala的宗旨是&ldquo;尽可能自己实现，不得已才使用Java&rdquo;，而Kotlin却相反：&ldquo;尽可能复用Java的实现，不得已才自己实现&rdquo;。所以相比之下Kotlin更简洁轻量，非常适合移动端的开发。另外JetBrains针对Android开发提供了一个由Kotlin实现的&ldquo;anko&rdquo;开源库，可以让你使用DSL的方式直接用代码编写UI，让你从繁琐的xml中解脱出来，而且避免了xml解析过程所带来的性能问题。

&nbsp;

这篇先讲怎么去使用idea（Android Studio用户也一样）搭建Kotlin的Android开发环境。

&nbsp;

<span style="font-size: 15px;">**一、下载以下相关idea插件：**</span>

1\. Kotlin

2\. Kotlin Extensions For Android

3\. Anko DSL Preview

其中Anko DSL Preview插件用于预览使用DSL编写的UI代码，就像以前使用xml编写UI文件时可以动态在&ldquo;Preview&rdquo;窗口预览效果一样。

&nbsp;

<span style="font-size: 15px;">**二、新建Android项目**</span>

在src/main目录下，新建kotlin目录（用于放置kotlin代码），配置Gradle如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">buildscript {
</span><span style="color: #008080;"> 2</span>     ext.kotlin_version = '0.12.1230'
<span style="color: #008080;"> 3</span> <span style="color: #000000;">    repositories {
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">        mavenCentral()
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">    dependencies {
</span><span style="color: #008080;"> 7</span>         classpath 'com.android.tools.build:gradle:1.1.1'
<span style="color: #008080;"> 8</span>         classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
<span style="color: #008080;"> 9</span>         classpath "org.jetbrains.kotlin:kotlin-android-extensions:$kotlin_version"
<span style="color: #008080;">10</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">11</span> <span style="color: #000000;">}
</span><span style="color: #008080;">12</span> apply plugin: 'com.android.application'
<span style="color: #008080;">13</span> apply plugin: 'kotlin-android'
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> <span style="color: #000000;">repositories {
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    mavenCentral()
</span><span style="color: #008080;">17</span> <span style="color: #000000;">}
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> <span style="color: #000000;">android {
</span><span style="color: #008080;">20</span>     compileSdkVersion 22
<span style="color: #008080;">21</span>     buildToolsVersion "22.0.1"
<span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> <span style="color: #000000;">    defaultConfig {
</span><span style="color: #008080;">24</span>         applicationId "com.wangjie.androidwithkotlin"
<span style="color: #008080;">25</span>         minSdkVersion 9
<span style="color: #008080;">26</span>         targetSdkVersion 22
<span style="color: #008080;">27</span>         versionCode 1
<span style="color: #008080;">28</span>         versionName "1.0"
<span style="color: #008080;">29</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span> <span style="color: #000000;">    sourceSets {
</span><span style="color: #008080;">32</span>         main.java.srcDirs += 'src/main/kotlin'
<span style="color: #008080;">33</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">34</span> 
<span style="color: #008080;">35</span> <span style="color: #000000;">    buildTypes {
</span><span style="color: #008080;">36</span> <span style="color: #000000;">        release {
</span><span style="color: #008080;">37</span>             minifyEnabled <span style="color: #0000ff;">false</span>
<span style="color: #008080;">38</span>             proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
<span style="color: #008080;">39</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">40</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">41</span> <span style="color: #000000;">}
</span><span style="color: #008080;">42</span> 
<span style="color: #008080;">43</span> <span style="color: #000000;">dependencies {
</span><span style="color: #008080;">44</span>     compile fileTree(dir: 'libs', include: ['*.jar'<span style="color: #000000;">])
</span><span style="color: #008080;">45</span>     compile 'com.android.support:appcompat-v7:22.2.0'
<span style="color: #008080;">46</span>     compile "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
<span style="color: #008080;">47</span>     compile "org.jetbrains.kotlin:kotlin-reflect:$kotlin_version"
<span style="color: #008080;">48</span>     compile 'org.jetbrains.anko:anko:0.6.3-15'
<span style="color: #008080;">49</span> }</pre>
</div>

然后sync &amp; build。

&nbsp;

<span style="font-size: 15px;">**三、配置Kotlin**</span>

调用&ldquo;Configuring Kotlin in the project&rdquo;这个Action

![](http://kotlinlang.org/assets/images/tutorials//kotlin-android/configure-kotlin-in-project.png)

![](http://kotlinlang.org/assets/images/tutorials//kotlin-android/configure-kotlin-in-project-details.png)

&nbsp;

<span style="font-size: 15px;">**四、把Java代码一键转成kotlin代码**</span>

打开要转换的Java文件，调用&ldquo;Convert Java File to Kotlin File&rdquo;这个Action即可。

![](http://kotlinlang.org/assets/images/tutorials//kotlin-android/convert-java-to-kotlin.png)

转换之前的Java代码：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MainActivity <span style="color: #0000ff;">extends</span><span style="color: #000000;"> ActionBarActivity {

    @Override
    </span><span style="color: #0000ff;">protected</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(Bundle savedInstanceState) {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onCreateOptionsMenu(Menu menu) {
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> Inflate the menu; this adds items to the action bar if it is present.</span>
<span style="color: #000000;">        getMenuInflater().inflate(R.menu.menu_main, menu);
        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
    }

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onOptionsItemSelected(MenuItem item) {
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> Handle action bar item clicks here. The action bar will
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> automatically handle clicks on the Home/Up button, so long
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> as you specify a parent activity in AndroidManifest.xml.</span>
        <span style="color: #0000ff;">int</span> id =<span style="color: #000000;"> item.getItemId();

        </span><span style="color: #008000;">//</span><span style="color: #008000;">noinspection SimplifiableIfStatement</span>
        <span style="color: #0000ff;">if</span> (id ==<span style="color: #000000;"> R.id.action_settings) {
            </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
        }

        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">super</span><span style="color: #000000;">.onOptionsItemSelected(item);
    }
}</span></pre>
</div>

转换之后的Kotlin代码：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> MainActivity : ActionBarActivity() {

    override fun onCreate(savedInstanceState: Bundle</span>?<span style="color: #000000;">) {
        </span><span style="color: #0000ff;">super</span><span style="color: #000000;">.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    override fun onCreateOptionsMenu(menu: Menu</span>?<span style="color: #000000;">): Boolean {
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> Inflate the menu; this adds items to the action bar if it is present.</span>
<span style="color: #000000;">        getMenuInflater().inflate(R.menu.menu_main, menu)
        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">
    }

    override fun onOptionsItemSelected(item: MenuItem</span>?<span style="color: #000000;">): Boolean {
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> Handle action bar item clicks here. The action bar will
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> automatically handle clicks on the Home/Up button, so long
        </span><span style="color: #008000;">//</span><span style="color: #008000;"> as you specify a parent activity in AndroidManifest.xml.</span>
        val id = item!!<span style="color: #000000;">.getItemId()

        </span><span style="color: #008000;">//</span><span style="color: #008000;">noinspection SimplifiableIfStatement</span>
        <span style="color: #0000ff;">if</span> (id ==<span style="color: #000000;"> R.id.action_settings) {
            </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">
        }

        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">super</span><span style="color: #000000;">.onOptionsItemSelected(item)
    }
}</span></pre>
</div>

&nbsp;

