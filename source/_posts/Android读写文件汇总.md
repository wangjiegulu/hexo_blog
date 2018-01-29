---
title: Android读写文件汇总
tags: []
date: 2012-03-03 16:03:00
---

### 一、 从resource中的raw文件夹中获取文件并读取数据（资源文件只能读不能写）

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> String res = "";
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">try</span>{
<span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> InputStream in = getResources().openRawResource(R.raw.bbi);
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span> <span style="color: #008000;">//</span><span style="color: #008000;">在\Test\res\raw\bbi.txt,</span><span style="color: #008000;">
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">int</span> length = in.available();
<span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #0000ff;">byte</span> [] buffer = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">byte</span>[length];
<span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> in.read(buffer);
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> <span style="color: #008000;">//</span><span style="color: #008000;">res = EncodingUtils.getString(buffer, "UTF-8");
</span><span style="color: #008080;">16</span> <span style="color: #008000;">
</span><span style="color: #008080;">17</span> <span style="color: #008000;">//</span><span style="color: #008000;">res = EncodingUtils.getString(buffer, "UNICODE");</span><span style="color: #008000;">
</span><span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> res = EncodingUtils.getString(buffer, "BIG5");
<span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> <span style="color: #008000;">//</span><span style="color: #008000;">依bbi.txt的编码类型选择合适的编码，如果不调整会乱码</span><span style="color: #008000;">
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> in.close();
<span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span> }<span style="color: #0000ff;">catch</span>(Exception e){
<span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> e.printStackTrace();
<span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> }</pre>
</div>

<span>myTextView.setText(res);//把得到的内容显示在TextView上</span>

&nbsp;

### 二、 从asset中获取文件并读取数据（资源文件只能读不能写）

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> String fileName = "yan.txt"; <span style="color: #008000;">//</span><span style="color: #008000;">文件名字</span><span style="color: #008000;">
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> String res="";
<span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> <span style="color: #0000ff;">try</span>{
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span> InputStream in = getResources().getAssets().open(fileName);
<span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> <span style="color: #008000;">//</span><span style="color: #008000;"> \Test\assets\yan.txt这里有这样的文件存在</span><span style="color: #008000;">
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #0000ff;">int</span> length = in.available();
<span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> <span style="color: #0000ff;">byte</span> [] buffer = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">byte</span>[length];
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> in.read(buffer);
<span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span> res = EncodingUtils.getString(buffer, "UTF-8");
<span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> }<span style="color: #0000ff;">catch</span>(Exception e){
<span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> e.printStackTrace();
<span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> }</pre>
</div>

### 三、 从sdcard中去读文件，首先要把文件通过\android-sdk-windows\tools\adb.exe把本地计算机上的文件copy到sdcard上去，adb.exe push e:/Y.txt /sdcard/, 不可以用adb.exe push e:\Y.txt \sdcard\ 同样： 把仿真器上的文件copy到本地计算机上用： adb pull ./data/data/com.tt/files/Test.txt e:/

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> String fileName = "/sdcard/Y.txt";
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #008000;">//</span><span style="color: #008000;">也可以用String fileName = "mnt/sdcard/Y.txt";</span><span style="color: #008000;">
</span><span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> String res="";
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">try</span>{
<span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> FileInputStream fin = <span style="color: #0000ff;">new</span> FileInputStream(fileName);
<span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #008000;">//</span><span style="color: #008000;">FileInputStream fin = openFileInput(fileName);
</span><span style="color: #008080;">12</span> <span style="color: #008000;">
</span><span style="color: #008080;">13</span> <span style="color: #008000;">//</span><span style="color: #008000;">用这个就不行了，必须用FileInputStream</span><span style="color: #008000;">
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> <span style="color: #0000ff;">int</span> length = fin.available();
<span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span> <span style="color: #0000ff;">byte</span> [] buffer = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">byte</span>[length];
<span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> fin.read(buffer);
<span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> res = EncodingUtils.getString(buffer, "UTF-8");
<span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> fin.close();
<span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span> }<span style="color: #0000ff;">catch</span>(Exception e){
<span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> e.printStackTrace();
<span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> }
<span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span> myTextView.setText(res);</pre>
</div>

&nbsp;

### 四、 写文件， 一般写在\data\data\com.test\files\里面，打开DDMS查看file explorer是可以看到仿真器文件存放目录的结构的

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> String fileName = "TEST.txt";
<span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> String message = "FFFFFFF11111FFFFF" ;
<span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> writeFileData(fileName, message);
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span> <span style="color: #0000ff;">public</span> voidwriteFileData(String fileName,String message){
<span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">try</span>{
<span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> FileOutputStream fout =openFileOutput(fileName, MODE_PRIVATE);
<span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> <span style="color: #0000ff;">byte</span> [] bytes = message.getBytes();
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> fout.write(bytes);
<span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span> fout.close();
<span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> }
<span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> <span style="color: #0000ff;">catch</span>(Exception e){
<span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> e.printStackTrace();
<span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span> }
<span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> }</pre>
</div>

### 五、 写， 读data/data/目录(相当AP工作目录)上的文件，用openFileOutput

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">//</span><span style="color: #008000;">写文件在./data/data/com.tt/files/下面</span><span style="color: #008000;">
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">public</span> voidwriteFileData(String fileName,String message){
<span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> <span style="color: #0000ff;">try</span>{
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span> FileOutputStream fout =openFileOutput(fileName, MODE_PRIVATE);
<span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">byte</span> [] bytes = message.getBytes();
<span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> fout.write(bytes);
<span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> fout.close();
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> }
<span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span> <span style="color: #0000ff;">catch</span>(Exception e){
<span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> e.printStackTrace();
<span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> }
<span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> }
<span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span> <span style="color: #008000;">//</span><span style="color: #008000;">-------------------------------------------------------
</span><span style="color: #008080;">26</span> <span style="color: #008000;">
</span><span style="color: #008080;">27</span> <span style="color: #008000;">//</span><span style="color: #008000;">读文件在./data/data/com.tt/files/下面</span><span style="color: #008000;">
</span><span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> <span style="color: #0000ff;">public</span> String readFileData(String fileName){
<span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span> String res="";
<span style="color: #008080;">32</span> 
<span style="color: #008080;">33</span> <span style="color: #0000ff;">try</span>{
<span style="color: #008080;">34</span> 
<span style="color: #008080;">35</span> FileInputStream fin = openFileInput(fileName);
<span style="color: #008080;">36</span> 
<span style="color: #008080;">37</span> <span style="color: #0000ff;">int</span> length = fin.available();
<span style="color: #008080;">38</span> 
<span style="color: #008080;">39</span> <span style="color: #0000ff;">byte</span> [] buffer = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">byte</span>[length];
<span style="color: #008080;">40</span> 
<span style="color: #008080;">41</span> fin.read(buffer);
<span style="color: #008080;">42</span> 
<span style="color: #008080;">43</span> res = EncodingUtils.getString(buffer, "UTF-8");
<span style="color: #008080;">44</span> 
<span style="color: #008080;">45</span> fin.close();
<span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span> }
<span style="color: #008080;">48</span> 
<span style="color: #008080;">49</span> <span style="color: #0000ff;">catch</span>(Exception e){
<span style="color: #008080;">50</span> 
<span style="color: #008080;">51</span> e.printStackTrace();
<span style="color: #008080;">52</span> 
<span style="color: #008080;">53</span> }
<span style="color: #008080;">54</span> 
<span style="color: #008080;">55</span> <span style="color: #0000ff;">return</span> res;
<span style="color: #008080;">56</span> 
<span style="color: #008080;">57</span> }</pre>
</div>

### 六、 写， 读sdcard目录上的文件，要用FileOutputStream， 不能用openFileOutput

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">//</span><span style="color: #008000;">写在/mnt/sdcard/目录下面的文件</span><span style="color: #008000;">
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">public</span> voidwriteFileSdcard(String fileName,String message){
<span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> <span style="color: #0000ff;">try</span>{
<span style="color: #008080;"> 6</span> 
<span style="color: #008080;"> 7</span> <span style="color: #008000;">//</span><span style="color: #008000;">FileOutputStream fout = openFileOutput(fileName, MODE_PRIVATE);</span><span style="color: #008000;">
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> FileOutputStream fout = newFileOutputStream(fileName);
<span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #0000ff;">byte</span> [] bytes = message.getBytes();
<span style="color: #008080;">12</span> 
<span style="color: #008080;">13</span> fout.write(bytes);
<span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> fout.close();
<span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span> }
<span style="color: #008080;">18</span> 
<span style="color: #008080;">19</span> <span style="color: #0000ff;">catch</span>(Exception e){
<span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> e.printStackTrace();
<span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span> }
<span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span> }
<span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> <span style="color: #008000;">//</span><span style="color: #008000;">读在/mnt/sdcard/目录下面的文件</span><span style="color: #008000;">
</span><span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> <span style="color: #0000ff;">public</span> String readFileSdcard(String fileName){
<span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span> String res="";
<span style="color: #008080;">32</span> 
<span style="color: #008080;">33</span> <span style="color: #0000ff;">try</span>{
<span style="color: #008080;">34</span> 
<span style="color: #008080;">35</span> FileInputStream fin = <span style="color: #0000ff;">new</span> FileInputStream(fileName);
<span style="color: #008080;">36</span> 
<span style="color: #008080;">37</span> <span style="color: #0000ff;">int</span> length = fin.available();
<span style="color: #008080;">38</span> 
<span style="color: #008080;">39</span> <span style="color: #0000ff;">byte</span> [] buffer = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">byte</span>[length];
<span style="color: #008080;">40</span> 
<span style="color: #008080;">41</span> fin.read(buffer);
<span style="color: #008080;">42</span> 
<span style="color: #008080;">43</span> res = EncodingUtils.getString(buffer, "UTF-8");
<span style="color: #008080;">44</span> 
<span style="color: #008080;">45</span> fin.close();
<span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span> }
<span style="color: #008080;">48</span> 
<span style="color: #008080;">49</span> <span style="color: #0000ff;">catch</span>(Exception e){
<span style="color: #008080;">50</span> 
<span style="color: #008080;">51</span> e.printStackTrace();
<span style="color: #008080;">52</span> 
<span style="color: #008080;">53</span> }
<span style="color: #008080;">54</span> 
<span style="color: #008080;">55</span> <span style="color: #0000ff;">return</span> res;
<span style="color: #008080;">56</span> 
<span style="color: #008080;">57</span> }</pre>
</div>

**注：**<span>&nbsp;</span>**openFileOutput****是在****raw****里编译过的，****FileOutputStream****是任何文件都可以**
<span><span>Android读写文件汇总</span>&nbsp;</span>[http://www.ziyouku.com/archives/android-to-read-and-write-file-summary.html](http://www.ziyouku.com/archives/android-to-read-and-write-file-summary.html)