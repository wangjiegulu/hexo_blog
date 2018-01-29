---
title: '[工具库]JFileDownloader工具类——多线程下载网络文件，并保存在本地'
tags: []
date: 2013-02-20 17:37:00
---

本人大四即将毕业的准程序员（JavaSE、JavaEE、android等）一枚，小项目也做过一点，于是乎一时兴起就写了一些工具。

我会在本博客中陆续发布一些平时可能会用到的工具。

代码质量可能不是很好，大家多担待！

代码或者思路有不妥之处，还希望大牛们能不吝赐教哈！

&nbsp;

<span>以下代码为本人原创，转载请注明：</span>

<span>本文转载，来自：[http://www.cnblogs.com/tiantianbyconan/archive/2013/02/20/2919132.html](http://www.cnblogs.com/tiantianbyconan/archive/2013/02/20/2919132.html)</span>

&nbsp;

JFileDownloader：用于多线程下载网络文件，并保存在本地。

**源码如下：**

1.JFileDownloader类：主要负责下载的初始化可启动工作。

<div class="cnblogs_code" onclick="cnblogs_code_show('d395f922-7845-43c4-b066-96e79a7d1609')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_d395f922-7845-43c4-b066-96e79a7d1609" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.extrautil.jfiledownloader;
</span><span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.File;
</span><span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.net.HttpURLConnection;
</span><span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.net.URL;
</span><span style="color: #008080;">  6</span> 
<span style="color: #008080;">  7</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">  8</span> <span style="color: #008000;"> * 
</span><span style="color: #008080;">  9</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 10</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-2-7 下午1:40:52
</span><span style="color: #008080;"> 11</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 12</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> JFileDownloader{
</span><span style="color: #008080;"> 13</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String urlPath;
</span><span style="color: #008080;"> 14</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String destFilePath;
</span><span style="color: #008080;"> 15</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> threadCount;
</span><span style="color: #008080;"> 16</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> JFileDownloadThread[] threads;
</span><span style="color: #008080;"> 17</span>     
<span style="color: #008080;"> 18</span>     <span style="color: #0000ff;">private</span> JFileDownloadListener fileDownloadListener; <span style="color: #008000;">//</span><span style="color: #008000;"> 进度监听器</span>
<span style="color: #008080;"> 19</span>     <span style="color: #0000ff;">private</span> JFileDownloaderNotificationThread notificationThread; <span style="color: #008000;">//</span><span style="color: #008000;"> 通知进度线程</span>
<span style="color: #008080;"> 20</span>     
<span style="color: #008080;"> 21</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> File destFile;
</span><span style="color: #008080;"> 22</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 23</span> <span style="color: #008000;">     * 下载过程中文件的后缀名。
</span><span style="color: #008080;"> 24</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 25</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> String DOWNLOADING_SUFFIX = ".jd"<span style="color: #000000;">; 
</span><span style="color: #008080;"> 26</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 27</span> <span style="color: #008000;">     * 默认使用的线程数量。&lt;br&gt;
</span><span style="color: #008080;"> 28</span> <span style="color: #008000;">     * 如果不设置线程数量参数（threadCount），则默认线程启动数量为1，即单线程下载。
</span><span style="color: #008080;"> 29</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 30</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> DEFAULT_THREADCOUNT = 1<span style="color: #000000;">;
</span><span style="color: #008080;"> 31</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 32</span> <span style="color: #008000;">     * 生成JFileDownloader对象。
</span><span style="color: #008080;"> 33</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> urlPath 要下载的目标文件URL路径
</span><span style="color: #008080;"> 34</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> destFilePath 要保存的文件目标（路径+文件名）
</span><span style="color: #008080;"> 35</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> threadCount 下载该文件所需要的线程数量
</span><span style="color: #008080;"> 36</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 37</span>     <span style="color: #0000ff;">public</span> JFileDownloader(String urlPath, String destFilePath, <span style="color: #0000ff;">int</span><span style="color: #000000;"> threadCount) {
</span><span style="color: #008080;"> 38</span>         <span style="color: #0000ff;">this</span>.urlPath =<span style="color: #000000;"> urlPath;
</span><span style="color: #008080;"> 39</span>         <span style="color: #0000ff;">this</span>.destFilePath =<span style="color: #000000;"> destFilePath;
</span><span style="color: #008080;"> 40</span>         <span style="color: #0000ff;">this</span>.threadCount =<span style="color: #000000;"> threadCount;
</span><span style="color: #008080;"> 41</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 42</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 43</span> <span style="color: #008000;">     * 生成JFileDownloader对象，其中下载线程数量默认是1，也就是选择单线程下载。
</span><span style="color: #008080;"> 44</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> urlPath urlPath 要下载的目标文件URL路径
</span><span style="color: #008080;"> 45</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> destFilePath destFilePath 要保存的文件目标（路径+文件名）
</span><span style="color: #008080;"> 46</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 47</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JFileDownloader(String urlPath, String destFilePath) {
</span><span style="color: #008080;"> 48</span>         <span style="color: #0000ff;">this</span><span style="color: #000000;">(urlPath, destFilePath, DEFAULT_THREADCOUNT);
</span><span style="color: #008080;"> 49</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 50</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 51</span> <span style="color: #008000;">     * 默认的构造方法，使用构造方法后必须要调用set方法来设置url等下载所需配置。
</span><span style="color: #008080;"> 52</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 53</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JFileDownloader() {
</span><span style="color: #008080;"> 54</span>         
<span style="color: #008080;"> 55</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 56</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 57</span> <span style="color: #008000;">     * 开始下载方法（流程分为3步）。
</span><span style="color: #008080;"> 58</span> <span style="color: #008000;">     * &lt;br&gt;&lt;ul&gt;
</span><span style="color: #008080;"> 59</span> <span style="color: #008000;">     * &lt;li&gt;检验URL的合法性&lt;br&gt;
</span><span style="color: #008080;"> 60</span> <span style="color: #008000;">     * &lt;li&gt;计算下载所需的线程数量和每个线程需下载多少大小的文件&lt;br&gt;
</span><span style="color: #008080;"> 61</span> <span style="color: #008000;">     * &lt;li&gt;启动各线程。
</span><span style="color: #008080;"> 62</span> <span style="color: #008000;">     * &lt;/ul&gt;
</span><span style="color: #008080;"> 63</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 64</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@throws</span><span style="color: #008000;"> Exception 如果设置的URL，includes等参数不合法，则抛出该异常
</span><span style="color: #008080;"> 65</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 66</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> startDownload() <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception{
</span><span style="color: #008080;"> 67</span>         checkSettingfValidity(); <span style="color: #008000;">//</span><span style="color: #008000;"> 检验参数合法性</span>
<span style="color: #008080;"> 68</span>         
<span style="color: #008080;"> 69</span>         URL url = <span style="color: #0000ff;">new</span><span style="color: #000000;"> URL(urlPath);
</span><span style="color: #008080;"> 70</span>         HttpURLConnection conn =<span style="color: #000000;"> (HttpURLConnection)url.openConnection();
</span><span style="color: #008080;"> 71</span>         conn.setConnectTimeout(20 * 1000<span style="color: #000000;">);
</span><span style="color: #008080;"> 72</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 获取文件长度</span>
<span style="color: #008080;"> 73</span>         <span style="color: #0000ff;">long</span> size =<span style="color: #000000;"> conn.getContentLength();
</span><span style="color: #008080;"> 74</span> <span style="color: #008000;">//</span><span style="color: #008000;">        int size = conn.getInputStream().available();</span>
<span style="color: #008080;"> 75</span>         <span style="color: #0000ff;">if</span>(size &lt; 0 || <span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> conn.getInputStream()){
</span><span style="color: #008080;"> 76</span>             <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> Exception("网络连接错误，请检查URL地址是否正确"<span style="color: #000000;">);
</span><span style="color: #008080;"> 77</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 78</span> <span style="color: #000000;">        conn.disconnect();
</span><span style="color: #008080;"> 79</span>         
<span style="color: #008080;"> 80</span>         
<span style="color: #008080;"> 81</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 计算每个线程需要下载多少byte的文件</span>
<span style="color: #008080;"> 82</span>         <span style="color: #0000ff;">long</span> perSize = size % threadCount == 0 ? size / threadCount : (size / threadCount + 1<span style="color: #000000;">);
</span><span style="color: #008080;"> 83</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 建立目标文件（文件以.jd结尾）</span>
<span style="color: #008080;"> 84</span>         destFile = <span style="color: #0000ff;">new</span> File(destFilePath +<span style="color: #000000;"> DOWNLOADING_SUFFIX);
</span><span style="color: #008080;"> 85</span> <span style="color: #000000;">        destFile.createNewFile();
</span><span style="color: #008080;"> 86</span>         
<span style="color: #008080;"> 87</span>         threads = <span style="color: #0000ff;">new</span><span style="color: #000000;"> JFileDownloadThread[threadCount];
</span><span style="color: #008080;"> 88</span>         
<span style="color: #008080;"> 89</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 启动进度通知线程</span>
<span style="color: #008080;"> 90</span>         notificationThread = <span style="color: #0000ff;">new</span><span style="color: #000000;"> JFileDownloaderNotificationThread(threads, fileDownloadListener, destFile, size);
</span><span style="color: #008080;"> 91</span> <span style="color: #000000;">        notificationThread.start();
</span><span style="color: #008080;"> 92</span>         
<span style="color: #008080;"> 93</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 初始化若干个下载线程</span>
<span style="color: #008080;"> 94</span>         <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; threadCount; i++<span style="color: #000000;">){
</span><span style="color: #008080;"> 95</span>             <span style="color: #0000ff;">if</span>(i != (threadCount - 1<span style="color: #000000;">)){
</span><span style="color: #008080;"> 96</span>                 threads[i] = <span style="color: #0000ff;">new</span><span style="color: #000000;"> JFileDownloadThread(urlPath, destFile, 
</span><span style="color: #008080;"> 97</span>                         i *<span style="color: #000000;"> perSize, perSize, notificationThread);
</span><span style="color: #008080;"> 98</span>             }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;"> 99</span>                 threads[i] = <span style="color: #0000ff;">new</span><span style="color: #000000;"> JFileDownloadThread(urlPath, destFile, 
</span><span style="color: #008080;">100</span>                         i * perSize, size - (threadCount - 1) *<span style="color: #000000;"> perSize, notificationThread);
</span><span style="color: #008080;">101</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">102</span>             threads[i].setPriority(8<span style="color: #000000;">);
</span><span style="color: #008080;">103</span> <span style="color: #008000;">//</span><span style="color: #008000;">            threads[i].start();</span>
<span style="color: #008080;">104</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">105</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 启动若干个下载线程（因为下载线程JFileDownloaderNotificationThread中使用了threads属性，所以必须等下载线程全部初始化以后才能启动线程）</span>
<span style="color: #008080;">106</span>         <span style="color: #0000ff;">for</span><span style="color: #000000;">(JFileDownloadThread thread : threads){
</span><span style="color: #008080;">107</span> <span style="color: #000000;">            thread.start();
</span><span style="color: #008080;">108</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">109</span>         
<span style="color: #008080;">110</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">111</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">112</span> <span style="color: #008000;">     * 取消所有下载线程。
</span><span style="color: #008080;">113</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">114</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">115</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> cancelDownload(){
</span><span style="color: #008080;">116</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> != threads &amp;&amp; 0 != threads.length &amp;&amp; <span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> notificationThread){
</span><span style="color: #008080;">117</span>             <span style="color: #0000ff;">for</span>(JFileDownloadThread thread : threads){ <span style="color: #008000;">//</span><span style="color: #008000;"> 终止所有下载线程</span>
<span style="color: #008080;">118</span> <span style="color: #000000;">                thread.cancelThread();
</span><span style="color: #008080;">119</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">120</span>             notificationThread.cancelThread(); <span style="color: #008000;">//</span><span style="color: #008000;"> 终止通知线程</span>
<span style="color: #008080;">121</span>             System.out.println("下载已被终止。"<span style="color: #000000;">);
</span><span style="color: #008080;">122</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;">123</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">124</span>         System.out.println("下载线程还未启动，无法终止。"<span style="color: #000000;">);
</span><span style="color: #008080;">125</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">126</span>     
<span style="color: #008080;">127</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">128</span> <span style="color: #008000;">     * 设置要下载的目标文件URL路径。
</span><span style="color: #008080;">129</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">130</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> urlPath 要下载的目标文件URL路径
</span><span style="color: #008080;">131</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回当前JFileDownloader对象
</span><span style="color: #008080;">132</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">133</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JFileDownloader setUrlPath(String urlPath) {
</span><span style="color: #008080;">134</span>         <span style="color: #0000ff;">this</span>.urlPath =<span style="color: #000000;"> urlPath;
</span><span style="color: #008080;">135</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;">136</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">137</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">138</span> <span style="color: #008000;">     * 设置要保存的目标文件（路径+文件名）。
</span><span style="color: #008080;">139</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">140</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> destFilePath 要保存的文件目标（路径+文件名）
</span><span style="color: #008080;">141</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回当前JFileDownloader对象
</span><span style="color: #008080;">142</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">143</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JFileDownloader setDestFilePath(String destFilePath) {
</span><span style="color: #008080;">144</span>         <span style="color: #0000ff;">this</span>.destFilePath =<span style="color: #000000;"> destFilePath;
</span><span style="color: #008080;">145</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;">146</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">147</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">148</span> <span style="color: #008000;">     * 设置下载该文件所需要的线程数量。
</span><span style="color: #008080;">149</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">150</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> threadCount 下载该文件所需要的线程数量
</span><span style="color: #008080;">151</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回当前JFileDownloader对象
</span><span style="color: #008080;">152</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">153</span>     <span style="color: #0000ff;">public</span> JFileDownloader setThreadCount(<span style="color: #0000ff;">int</span><span style="color: #000000;"> threadCount) {
</span><span style="color: #008080;">154</span>         <span style="color: #0000ff;">this</span>.threadCount =<span style="color: #000000;"> threadCount;
</span><span style="color: #008080;">155</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;">156</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">157</span>     
<span style="color: #008080;">158</span>     <span style="color: #008000;">//</span><span style="color: #008000;">观察者模式来获取下载进度</span>
<span style="color: #008080;">159</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">160</span> <span style="color: #008000;">     * 设置监听器，以获取下载进度。
</span><span style="color: #008080;">161</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">162</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JFileDownloader setFileDownloadListener(
</span><span style="color: #008080;">163</span> <span style="color: #000000;">            JFileDownloadListener fileDownloadListener) {
</span><span style="color: #008080;">164</span>         <span style="color: #0000ff;">this</span>.fileDownloadListener =<span style="color: #000000;"> fileDownloadListener;
</span><span style="color: #008080;">165</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;">166</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">167</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">168</span> <span style="color: #008000;">     * 通过该方法移出相应的监听器对象。
</span><span style="color: #008080;">169</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">170</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> fileDownloadListener 要移除的监听器对象
</span><span style="color: #008080;">171</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">172</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> removeFileDownloadListener(
</span><span style="color: #008080;">173</span> <span style="color: #000000;">            JFileDownloadListener fileDownloadListener) {
</span><span style="color: #008080;">174</span>         fileDownloadListener = <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">175</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">176</span> 
<span style="color: #008080;">177</span> 
<span style="color: #008080;">178</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">179</span> <span style="color: #008000;">     * 检验设置的参数是否合法。
</span><span style="color: #008080;">180</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">181</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@throws</span><span style="color: #008000;"> Exception 目标文件URL路径不合法，或者线程数小于1，则抛出该异常
</span><span style="color: #008080;">182</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">183</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> checkSettingfValidity() <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception{
</span><span style="color: #008080;">184</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> == urlPath || ""<span style="color: #000000;">.equals(urlPath)){
</span><span style="color: #008080;">185</span>             <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> Exception("目标文件URL路径不能为空"<span style="color: #000000;">);
</span><span style="color: #008080;">186</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">187</span>         <span style="color: #0000ff;">if</span>(threadCount &lt; 1<span style="color: #000000;">){
</span><span style="color: #008080;">188</span>             <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> Exception("线程数不能小于1"<span style="color: #000000;">);
</span><span style="color: #008080;">189</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">190</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">191</span>     
<span style="color: #008080;">192</span> }</pre>
</div>
</div>

&nbsp;

2.JFileDownloadListener接口：该接口用于监听JFileDownloader下载的进度。

<div class="cnblogs_code" onclick="cnblogs_code_show('ee01f91f-781d-4fde-9833-bb14aaf3a587')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_ee01f91f-781d-4fde-9833-bb14aaf3a587" class="cnblogs_code_hide">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.extrautil.jfiledownloader;
</span><span style="color: #008080;"> 2</span> 
<span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.File;
</span><span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 6</span> <span style="color: #008000;"> * 
</span><span style="color: #008080;"> 7</span> <span style="color: #008000;"> * 该接口用于监听JFileDownloader下载的进度。
</span><span style="color: #008080;"> 8</span> <span style="color: #008000;"> * 
</span><span style="color: #008080;"> 9</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">10</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-2-7 下午2:12:45
</span><span style="color: #008080;">11</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">12</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> JFileDownloadListener {
</span><span style="color: #008080;">13</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">14</span> <span style="color: #008000;">     * 该方法可获得文件的下载进度信息。
</span><span style="color: #008080;">15</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">16</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> progress 文件下载的进度值，范围（0-100）。0表示文件还未开始下载；100则表示文件下载完成。
</span><span style="color: #008080;">17</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> speed 此时下载瞬时速度（单位：kb/每秒）。
</span><span style="color: #008080;">18</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> remainTime 此时剩余下载所需时间（单位为毫秒）。
</span><span style="color: #008080;">19</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">20</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> downloadProgress(<span style="color: #0000ff;">int</span> progress, <span style="color: #0000ff;">double</span> speed, <span style="color: #0000ff;">long</span><span style="color: #000000;"> remainTime);
</span><span style="color: #008080;">21</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">22</span> <span style="color: #008000;">     * 文件下载完成会调用该方法。
</span><span style="color: #008080;">23</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">24</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> file 返回下载完成的File对象。
</span><span style="color: #008080;">25</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> downloadTime 下载所用的总时间（单位为毫秒）。
</span><span style="color: #008080;">26</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">27</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> downloadCompleted(File file, <span style="color: #0000ff;">long</span><span style="color: #000000;"> downloadTime);
</span><span style="color: #008080;">28</span> }</pre>
</div>
</div>

&nbsp;

3.JFileDownloaderNotificationThread类：该线程为通知下载进度的线程。

<div class="cnblogs_code" onclick="cnblogs_code_show('606a576f-1d6a-48a8-bb25-21c2a4df4a63')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_606a576f-1d6a-48a8-bb25-21c2a4df4a63" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.extrautil.jfiledownloader;
</span><span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.File;
</span><span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.math.BigDecimal;
</span><span style="color: #008080;">  5</span> 
<span style="color: #008080;">  6</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">  7</span> <span style="color: #008000;"> * 该线程为通知下载进度的线程。
</span><span style="color: #008080;">  8</span> <span style="color: #008000;"> * 用于在下载未完成时通知用户下载的进度，范围（0-100）。0表示文件还未开始下载；100则表示文件下载完成。
</span><span style="color: #008080;">  9</span> <span style="color: #008000;"> * 此时下载瞬时速度（单位：kb/每秒）。
</span><span style="color: #008080;"> 10</span> <span style="color: #008000;"> * 在完成时返回下载完成的File对象给用户。返回下载所用的总时间（单位为毫秒）给用户。
</span><span style="color: #008080;"> 11</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 12</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-2-17 下午12:23:59
</span><span style="color: #008080;"> 13</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 14</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> JFileDownloaderNotificationThread <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Thread{
</span><span style="color: #008080;"> 15</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> JFileDownloadThread[] threads;
</span><span style="color: #008080;"> 16</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> JFileDownloadListener fileDownloadListener;
</span><span style="color: #008080;"> 17</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> File destFile;
</span><span style="color: #008080;"> 18</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">long</span><span style="color: #000000;"> destFileSize;
</span><span style="color: #008080;"> 19</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isRunning; <span style="color: #008000;">//</span><span style="color: #008000;"> 线程运行停止标志</span>
<span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> notificationTag; <span style="color: #008000;">//</span><span style="color: #008000;"> 通知标志</span>
<span style="color: #008080;"> 21</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 22</span> <span style="color: #008000;">     * 通过该方法构建一个进度通知线程。
</span><span style="color: #008080;"> 23</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> threads 下载某文件需要的所有线程。
</span><span style="color: #008080;"> 24</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> fileDownloadListener 要通知进度的监听器对象。
</span><span style="color: #008080;"> 25</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> destFile 下载的文件对象。
</span><span style="color: #008080;"> 26</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 27</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JFileDownloaderNotificationThread(JFileDownloadThread[] threads,
</span><span style="color: #008080;"> 28</span>             JFileDownloadListener fileDownloadListener, File destFile, <span style="color: #0000ff;">long</span><span style="color: #000000;"> destFileSize) {
</span><span style="color: #008080;"> 29</span>         <span style="color: #0000ff;">this</span>.threads =<span style="color: #000000;"> threads;
</span><span style="color: #008080;"> 30</span>         <span style="color: #0000ff;">this</span>.fileDownloadListener =<span style="color: #000000;"> fileDownloadListener;
</span><span style="color: #008080;"> 31</span>         <span style="color: #0000ff;">this</span>.destFile =<span style="color: #000000;"> destFile;
</span><span style="color: #008080;"> 32</span>         <span style="color: #0000ff;">this</span>.destFileSize =<span style="color: #000000;"> destFileSize;
</span><span style="color: #008080;"> 33</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 34</span> 
<span style="color: #008080;"> 35</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 36</span> <span style="color: #008000;">     * 不断地循环来就检查更新进度。
</span><span style="color: #008080;"> 37</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 38</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 39</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> run() {
</span><span style="color: #008080;"> 40</span>         isRunning = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 41</span>         <span style="color: #0000ff;">long</span> startTime = 0<span style="color: #000000;">;
</span><span style="color: #008080;"> 42</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> fileDownloadListener){
</span><span style="color: #008080;"> 43</span>             startTime = System.currentTimeMillis(); <span style="color: #008000;">//</span><span style="color: #008000;"> 文件下载开始时间</span>
<span style="color: #008080;"> 44</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 45</span>         
<span style="color: #008080;"> 46</span>         <span style="color: #0000ff;">long</span> oldTemp = 0; <span style="color: #008000;">//</span><span style="color: #008000;"> 上次已下载数据长度</span>
<span style="color: #008080;"> 47</span>         <span style="color: #0000ff;">long</span> oldTime = 0; <span style="color: #008000;">//</span><span style="color: #008000;"> 上次下载的当前时间</span>
<span style="color: #008080;"> 48</span>         
<span style="color: #008080;"> 49</span>         <span style="color: #0000ff;">while</span><span style="color: #000000;">(isRunning){
</span><span style="color: #008080;"> 50</span>             <span style="color: #0000ff;">if</span>(notificationTag){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果此时正等待检查更新进度。
</span><span style="color: #008080;"> 51</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 计算此时的所有线程下载长度的总和</span>
<span style="color: #008080;"> 52</span>                 <span style="color: #0000ff;">long</span> temp = 0<span style="color: #000000;">;
</span><span style="color: #008080;"> 53</span>                 <span style="color: #0000ff;">for</span><span style="color: #000000;">(JFileDownloadThread thread : threads){
</span><span style="color: #008080;"> 54</span>                     temp +=<span style="color: #000000;"> thread.currentLength;
</span><span style="color: #008080;"> 55</span> <span style="color: #000000;">                }
</span><span style="color: #008080;"> 56</span> <span style="color: #008000;">//</span><span style="color: #008000;">                System.out.println("temp: " + temp);
</span><span style="color: #008080;"> 57</span> <span style="color: #008000;">//</span><span style="color: #008000;">                System.out.println("destFileSize: " + destFileSize);
</span><span style="color: #008080;"> 58</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 换算成进度</span>
<span style="color: #008080;"> 59</span>                 <span style="color: #0000ff;">int</span> progress = (<span style="color: #0000ff;">int</span>) ((<span style="color: #0000ff;">double</span>)temp * 100 / (<span style="color: #0000ff;">double</span><span style="color: #000000;">)destFileSize);
</span><span style="color: #008080;"> 60</span>                 
<span style="color: #008080;"> 61</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 把进度通知给监听器</span>
<span style="color: #008080;"> 62</span>                 <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> fileDownloadListener){
</span><span style="color: #008080;"> 63</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 计算瞬时速度</span>
<span style="color: #008080;"> 64</span>                     <span style="color: #0000ff;">long</span> detaTemp = temp - oldTemp; <span style="color: #008000;">//</span><span style="color: #008000;"> 两次更新进度的时间段内的已下载数据差</span>
<span style="color: #008080;"> 65</span>                     <span style="color: #0000ff;">long</span> detaTime = System.currentTimeMillis() - oldTime; <span style="color: #008000;">//</span><span style="color: #008000;"> 两次更新进度的时间段内的时间差 
</span><span style="color: #008080;"> 66</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 两次更新进度的时间段内的速度作为瞬时速度</span>
<span style="color: #008080;"> 67</span>                     <span style="color: #0000ff;">double</span> speed = ((<span style="color: #0000ff;">double</span>)detaTemp / 1024) / ((<span style="color: #0000ff;">double</span>)(detaTime) / 1000<span style="color: #000000;">); 
</span><span style="color: #008080;"> 68</span>                     
<span style="color: #008080;"> 69</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 保留小数点后2位，最后一位四舍五入</span>
<span style="color: #008080;"> 70</span>                     speed = <span style="color: #0000ff;">new</span> BigDecimal(speed).setScale(2<span style="color: #000000;">, BigDecimal.ROUND_HALF_UP).doubleValue();
</span><span style="color: #008080;"> 71</span>                     
<span style="color: #008080;"> 72</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 计算剩余下载时间</span>
<span style="color: #008080;"> 73</span>                     <span style="color: #0000ff;">double</span> remainTime = (<span style="color: #0000ff;">double</span>)(destFileSize - temp) /<span style="color: #000000;"> speed;
</span><span style="color: #008080;"> 74</span>                     <span style="color: #0000ff;">if</span>(Double.isInfinite(remainTime) ||<span style="color: #000000;"> Double.isNaN(remainTime)){
</span><span style="color: #008080;"> 75</span>                         remainTime = 0<span style="color: #000000;">;
</span><span style="color: #008080;"> 76</span>                     }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;"> 77</span>                         remainTime = <span style="color: #0000ff;">new</span> BigDecimal(remainTime).setScale(0<span style="color: #000000;">, BigDecimal.ROUND_HALF_UP).longValue();
</span><span style="color: #008080;"> 78</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;"> 79</span>                     
<span style="color: #008080;"> 80</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 通知监听者进度和速度以及下载剩余时间</span>
<span style="color: #008080;"> 81</span>                     fileDownloadListener.downloadProgress(progress, speed, (<span style="color: #0000ff;">long</span><span style="color: #000000;">)remainTime);
</span><span style="color: #008080;"> 82</span>                     
<span style="color: #008080;"> 83</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 重置上次已下载数据长度和上次下载的当前时间</span>
<span style="color: #008080;"> 84</span>                     oldTemp =<span style="color: #000000;"> temp;
</span><span style="color: #008080;"> 85</span>                     oldTime =<span style="color: #000000;"> System.currentTimeMillis();
</span><span style="color: #008080;"> 86</span> <span style="color: #000000;">                }
</span><span style="color: #008080;"> 87</span>                 
<span style="color: #008080;"> 88</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 如果下载进度达到100，则表示下载完毕</span>
<span style="color: #008080;"> 89</span>                 <span style="color: #0000ff;">if</span>(100 &lt;=<span style="color: #000000;"> progress){
</span><span style="color: #008080;"> 90</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 给下载好的文件进行重命名，即去掉DOWNLOADING_SUFFIX后缀</span>
<span style="color: #008080;"> 91</span>                     String oldPath =<span style="color: #000000;"> destFile.getPath();
</span><span style="color: #008080;"> 92</span>                     File newFile = <span style="color: #0000ff;">new</span> File(oldPath.substring(0, oldPath.lastIndexOf("."<span style="color: #000000;">)));
</span><span style="color: #008080;"> 93</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 检查去掉后的文件是否存在。如果存在，则删除原来的文件并重命名下载的文件（即：覆盖原文件）</span>
<span style="color: #008080;"> 94</span>                     <span style="color: #0000ff;">if</span><span style="color: #000000;">(newFile.exists()){
</span><span style="color: #008080;"> 95</span> <span style="color: #000000;">                        newFile.delete();
</span><span style="color: #008080;"> 96</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;"> 97</span>                     System.out.println(destFile.renameTo(newFile));<span style="color: #008000;">//</span><span style="color: #008000;"> 重命名
</span><span style="color: #008080;"> 98</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 通知监听器，并传入新的文件对象</span>
<span style="color: #008080;"> 99</span>                     <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> fileDownloadListener){
</span><span style="color: #008080;">100</span>                         fileDownloadListener.downloadCompleted(newFile, System.currentTimeMillis() -<span style="color: #000000;"> startTime);
</span><span style="color: #008080;">101</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">102</span>                     isRunning = <span style="color: #0000ff;">false</span>; <span style="color: #008000;">//</span><span style="color: #008000;"> 文件下载完就结束通知线程。</span>
<span style="color: #008080;">103</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">104</span>                 notificationTag = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">105</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">106</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> 设置为每100毫秒进行检查并更新通知</span>
<span style="color: #008080;">107</span>             <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;">108</span>                 Thread.sleep(100<span style="color: #000000;">);
</span><span style="color: #008080;">109</span>             } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (InterruptedException e) {
</span><span style="color: #008080;">110</span> <span style="color: #000000;">                e.printStackTrace();
</span><span style="color: #008080;">111</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">112</span>             
<span style="color: #008080;">113</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">114</span>         
<span style="color: #008080;">115</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">116</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">117</span> <span style="color: #008000;">     * 调用这个方法，则会使得线程处于待检查更新进度状态。
</span><span style="color: #008080;">118</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">119</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">120</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">synchronized</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> notificationProgress(){
</span><span style="color: #008080;">121</span>         notificationTag = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;">122</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">123</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">124</span> <span style="color: #008000;">     * 取消该通知线程
</span><span style="color: #008080;">125</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">126</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">127</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> cancelThread(){
</span><span style="color: #008080;">128</span>         isRunning = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">129</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">130</span>     
<span style="color: #008080;">131</span> 
<span style="color: #008080;">132</span> }</pre>
</div>
</div>

&nbsp;

4.JFileDownloadThread类：真正的下载线程，该线程用于执行该线程所要负责下载的数据。

<div class="cnblogs_code" onclick="cnblogs_code_show('c46c22f4-1e9a-43c7-b6e7-f5c514b5483e')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_c46c22f4-1e9a-43c7-b6e7-f5c514b5483e" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.extrautil.jfiledownloader;
</span><span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.File;
</span><span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.IOException;
</span><span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.InputStream;
</span><span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.io.RandomAccessFile;
</span><span style="color: #008080;">  7</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.net.HttpURLConnection;
</span><span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.net.URL;
</span><span style="color: #008080;">  9</span> 
<span style="color: #008080;"> 10</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 11</span> <span style="color: #008000;"> * 
</span><span style="color: #008080;"> 12</span> <span style="color: #008000;"> * 真正的下载线程，该线程用于执行该线程所要负责下载的数据。
</span><span style="color: #008080;"> 13</span> <span style="color: #008000;"> * 
</span><span style="color: #008080;"> 14</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 15</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-2-7 上午11:58:24
</span><span style="color: #008080;"> 16</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 17</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> JFileDownloadThread <span style="color: #0000ff;">extends</span><span style="color: #000000;"> Thread{
</span><span style="color: #008080;"> 18</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String urlPath;
</span><span style="color: #008080;"> 19</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> File destFile;
</span><span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">long</span><span style="color: #000000;"> startPos;
</span><span style="color: #008080;"> 21</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 22</span> <span style="color: #008000;">     * 此线程需要下载的数据长度。
</span><span style="color: #008080;"> 23</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 24</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">long</span><span style="color: #000000;"> length;
</span><span style="color: #008080;"> 25</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 26</span> <span style="color: #008000;">     * 此线程现在已下载好了的数据长度。
</span><span style="color: #008080;"> 27</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 28</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">long</span><span style="color: #000000;"> currentLength;
</span><span style="color: #008080;"> 29</span>     
<span style="color: #008080;"> 30</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> JFileDownloaderNotificationThread notificationThread;
</span><span style="color: #008080;"> 31</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isRunning = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 32</span>     
<span style="color: #008080;"> 33</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 34</span> <span style="color: #008000;">     * 构造方法，可生成配置完整的JFileDownloadThread对象
</span><span style="color: #008080;"> 35</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> urlPath 要下载的目标文件URL
</span><span style="color: #008080;"> 36</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> destFile 要保存的目标文件
</span><span style="color: #008080;"> 37</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> startPos 该线程需要下载目标文件第几个byte之后的数据
</span><span style="color: #008080;"> 38</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> length 该线程需要下载多少长度的数据
</span><span style="color: #008080;"> 39</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> notificationThread 通知进度线程
</span><span style="color: #008080;"> 40</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 41</span>     <span style="color: #0000ff;">public</span> JFileDownloadThread(String urlPath, File destFile, <span style="color: #0000ff;">long</span><span style="color: #000000;"> startPos,
</span><span style="color: #008080;"> 42</span>             <span style="color: #0000ff;">long</span><span style="color: #000000;"> length, JFileDownloaderNotificationThread notificationThread) {
</span><span style="color: #008080;"> 43</span>         <span style="color: #0000ff;">this</span>.urlPath =<span style="color: #000000;"> urlPath;
</span><span style="color: #008080;"> 44</span>         <span style="color: #0000ff;">this</span>.destFile =<span style="color: #000000;"> destFile;
</span><span style="color: #008080;"> 45</span>         <span style="color: #0000ff;">this</span>.startPos =<span style="color: #000000;"> startPos;
</span><span style="color: #008080;"> 46</span>         <span style="color: #0000ff;">this</span>.length =<span style="color: #000000;"> length;
</span><span style="color: #008080;"> 47</span>         <span style="color: #0000ff;">this</span>.notificationThread =<span style="color: #000000;"> notificationThread;
</span><span style="color: #008080;"> 48</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 49</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 50</span> <span style="color: #008000;">     * 该方法将执行下载功能，并把数据存储在目标文件中的相应位置。
</span><span style="color: #008080;"> 51</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 52</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 53</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> run() {
</span><span style="color: #008080;"> 54</span>         RandomAccessFile raf = <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 55</span>         HttpURLConnection conn = <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 56</span>         InputStream is = <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 57</span>         <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;"> 58</span> <span style="color: #008000;">//</span><span style="color: #008000;">            URL url = new URL("</span><span style="color: #008000; text-decoration: underline;">http://localhost</span><span style="color: #008000;">:8080/firstserver/files/hibernate.zip");</span>
<span style="color: #008080;"> 59</span>             URL url = <span style="color: #0000ff;">new</span><span style="color: #000000;"> URL(urlPath);
</span><span style="color: #008080;"> 60</span>             conn =<span style="color: #000000;"> (HttpURLConnection)url.openConnection();
</span><span style="color: #008080;"> 61</span>             conn.setConnectTimeout(20 * 1000<span style="color: #000000;">);
</span><span style="color: #008080;"> 62</span>             is =<span style="color: #000000;"> conn.getInputStream();
</span><span style="color: #008080;"> 63</span>             raf = <span style="color: #0000ff;">new</span> RandomAccessFile(destFile, "rw"<span style="color: #000000;">);
</span><span style="color: #008080;"> 64</span>             raf.setLength(conn.getContentLength()); <span style="color: #008000;">//</span><span style="color: #008000;"> 设置保存文件的大小
</span><span style="color: #008080;"> 65</span> <span style="color: #008000;">//</span><span style="color: #008000;">            raf.setLength(conn.getInputStream().available());
</span><span style="color: #008080;"> 66</span>             
<span style="color: #008080;"> 67</span>             <span style="color: #008000;">//</span><span style="color: #008000;"> 设置读入和写入的文件位置</span>
<span style="color: #008080;"> 68</span> <span style="color: #000000;">            is.skip(startPos);
</span><span style="color: #008080;"> 69</span> <span style="color: #000000;">            raf.seek(startPos);
</span><span style="color: #008080;"> 70</span>             
<span style="color: #008080;"> 71</span>             currentLength = 0; <span style="color: #008000;">//</span><span style="color: #008000;"> 当前已下载好的文件长度</span>
<span style="color: #008080;"> 72</span>             <span style="color: #0000ff;">byte</span>[] buffer = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">byte</span>[1024 * 1024<span style="color: #000000;">];
</span><span style="color: #008080;"> 73</span>             <span style="color: #0000ff;">int</span> len = 0<span style="color: #000000;">;
</span><span style="color: #008080;"> 74</span>             <span style="color: #0000ff;">while</span>(currentLength &lt; length &amp;&amp; -1 != (len =<span style="color: #000000;"> is.read(buffer))){
</span><span style="color: #008080;"> 75</span>                 <span style="color: #0000ff;">if</span>(!<span style="color: #000000;">isRunning){
</span><span style="color: #008080;"> 76</span>                     <span style="color: #0000ff;">break</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 77</span> <span style="color: #000000;">                }
</span><span style="color: #008080;"> 78</span>                 <span style="color: #0000ff;">if</span>(currentLength + len &gt;<span style="color: #000000;"> length){
</span><span style="color: #008080;"> 79</span>                     raf.write(buffer, 0, (<span style="color: #0000ff;">int</span>)(length -<span style="color: #000000;"> currentLength));
</span><span style="color: #008080;"> 80</span>                     currentLength =<span style="color: #000000;"> length;
</span><span style="color: #008080;"> 81</span>                     notificationThread.notificationProgress(); <span style="color: #008000;">//</span><span style="color: #008000;"> 通知进度线程来更新进度</span>
<span style="color: #008080;"> 82</span>                     <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 83</span>                 }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;"> 84</span>                     raf.write(buffer, 0<span style="color: #000000;">, len);
</span><span style="color: #008080;"> 85</span>                     currentLength +=<span style="color: #000000;"> len;
</span><span style="color: #008080;"> 86</span>                     notificationThread.notificationProgress(); <span style="color: #008000;">//</span><span style="color: #008000;"> 通知进度线程来更新进度</span>
<span style="color: #008080;"> 87</span> <span style="color: #000000;">                }
</span><span style="color: #008080;"> 88</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 89</span>         } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (Exception e) {
</span><span style="color: #008080;"> 90</span> <span style="color: #000000;">            e.printStackTrace();
</span><span style="color: #008080;"> 91</span>         } <span style="color: #0000ff;">finally</span><span style="color: #000000;">{
</span><span style="color: #008080;"> 92</span>             <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;"> 93</span> <span style="color: #000000;">                is.close();
</span><span style="color: #008080;"> 94</span> <span style="color: #000000;">                raf.close();
</span><span style="color: #008080;"> 95</span> <span style="color: #000000;">                conn.disconnect();
</span><span style="color: #008080;"> 96</span>             } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (IOException e) {
</span><span style="color: #008080;"> 97</span> <span style="color: #000000;">                e.printStackTrace();
</span><span style="color: #008080;"> 98</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 99</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">100</span>         
<span style="color: #008080;">101</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">102</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">103</span> <span style="color: #008000;">     * 取消该线程下载
</span><span style="color: #008080;">104</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">105</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">106</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> cancelThread(){
</span><span style="color: #008080;">107</span>         isRunning = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;">108</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">109</span>     
<span style="color: #008080;">110</span>     
<span style="color: #008080;">111</span> }</pre>
</div>
</div>

&nbsp;

**使用方法如下：**

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> String urlPath = "http://localhost:8080/firstserver/files/test.zip"<span style="color: #000000;">;
</span><span style="color: #008080;"> 2</span> String destFilePath = "C:\\Users\\admin\\Desktop\\杂\\临时仓库\\test.zip"<span style="color: #000000;">;
</span><span style="color: #008080;"> 3</span> <span style="color: #0000ff;">int</span> threadCount = 3<span style="color: #000000;">;
</span><span style="color: #008080;"> 4</span> 
<span style="color: #008080;"> 5</span> JFileDownloader downloader = <span style="color: #0000ff;">new</span><span style="color: #000000;"> JFileDownloader(urlPath, destFilePath, threadCount);
</span><span style="color: #008080;"> 6</span> <span style="color: #008000;">//</span><span style="color: #008000;">或者：</span>
<span style="color: #008080;"> 7</span> JFileDownloader downloader = <span style="color: #0000ff;">new</span><span style="color: #000000;"> JFileDownloader()
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">            .setUrlPath(urlPath)
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">            .setDestFilePath(destFilePath)
</span><span style="color: #008080;">10</span> <span style="color: #000000;">            .setThreadCount(threadCount)
</span><span style="color: #008080;">11</span>             .setFileDownloadListener(<span style="color: #0000ff;">new</span> JFileDownloadListener() { <span style="color: #008000;">//</span><span style="color: #008000;"> 设置进度监听器</span>
<span style="color: #008080;">12</span>                     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> downloadProgress(<span style="color: #0000ff;">int</span> progress, <span style="color: #0000ff;">double</span> speed, <span style="color: #0000ff;">long</span><span style="color: #000000;"> remainTime) {
</span><span style="color: #008080;">13</span>                         System.out.println("文件已下载：" + progress + "%，下载速度为：" + speed + "kb/s，剩余所需时间：" + remainTime + "毫秒"<span style="color: #000000;">);
</span><span style="color: #008080;">14</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">15</span>                     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> downloadCompleted(File file, <span style="color: #0000ff;">long</span><span style="color: #000000;"> downloadTime) {
</span><span style="color: #008080;">16</span>                         System.out.println("文件：" + file.getName() + "下载完成，用时：" + downloadTime + "毫秒"<span style="color: #000000;">);
</span><span style="color: #008080;">17</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">18</span> <span style="color: #000000;">            });
</span><span style="color: #008080;">19</span>     <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;">20</span>         downloader.startDownload(); <span style="color: #008000;">//</span><span style="color: #008000;"> 开始下载</span>
<span style="color: #008080;">21</span>     } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (Exception e) {
</span><span style="color: #008080;">22</span> <span style="color: #000000;">        e.printStackTrace();
</span><span style="color: #008080;">23</span>     }</pre>
</div>

&nbsp;

&nbsp;