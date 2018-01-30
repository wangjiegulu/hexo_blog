---
title: 【ios】使用Block对POST异步操作的简单封装
tags: [iOS, block, post]
date: 2013-11-06 06:35:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span style="color: #ff0000;">**来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/3409721.html](http://www.cnblogs.com/tiantianbyconan/p/3409721.html)**</span>

一般情况下的POST异步操作需要实现以下几步：

1\. 在controller.h上实现&lt;NSURLConnectionDataDelegate&gt;协议

2\. 实现协议的几个方法，

- (<span class="s1">void</span>)connection:(<span class="s2">NSURLConnection</span> *)connection didReceiveResponse:(<span class="s2">NSURLResponse</span> *)response

- (<span class="s1">void</span>)connection:(<span class="s2">NSURLConnection</span> *)connection didReceiveData:(<span class="s2">NSData</span> *)data

- (<span class="s1">void</span>)connectionDidFinishLoading:(<span class="s2">NSURLConnection</span> *)connection

3\. 编写执行post请求的代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> NSURL *url = [NSURL URLWithString:urlStr]; <span style="color: #008000;">//</span><span style="color: #008000;"> 生成NSURL对象
</span><span style="color: #008080;">2</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 生成Request请求对象（并设置它的缓存协议、网络请求超时配置）</span>
<span style="color: #008080;">3</span>     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:<span style="color: #800080;">30</span><span style="color: #000000;">];
</span><span style="color: #008080;">4</span>     
<span style="color: #008080;">5</span>     [request setHTTPBody:[<span style="color: #0000ff;">params</span> dataUsingEncoding:NSUTF8StringEncoding]]; <span style="color: #008000;">//</span><span style="color: #008000;"> 设置请求参数
</span><span style="color: #008080;">6</span>     
<span style="color: #008080;">7</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 执行请求连接</span>
<span style="color: #008080;">8</span>     NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request <span style="color: #0000ff;">delegate</span>:executorDelegate];</pre>
</div>

&nbsp;

如果controller有很多异步操作，处理就会很麻烦，而且，很多时候我们只需要处理完成和异常（比如超时）的时候的反馈即可

所以，我需要编写一个post请求的封装类，只要传入请求的url、请求参数（字符串形式）、完成时的回调block

首先，新建类：HttpPostExecutor，.h如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;">//</span><span style="color: #008000;">  HttpPostExecutor.h
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;">//</span><span style="color: #008000;">  HttpTest
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 5</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Created by WANGJIE on 13-11-6.
</span><span style="color: #008080;"> 6</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Copyright (c) 2013年 WANGJIE. All rights reserved.
</span><span style="color: #008080;"> 7</span> <span style="color: #008000;">//
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">#import</span> &lt;Foundation/Foundation.h&gt;
<span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> <span style="color: #0000ff;">@interface</span> HttpPostExecutor : NSObject&lt;NSURLConnectionDataDelegate&gt;
<span style="color: #008080;">12</span> <span style="color: #000000;">{
</span><span style="color: #008080;">13</span>     NSMutableData *resultData; <span style="color: #008000;">//</span><span style="color: #008000;"> 存放请求结果</span>
<span style="color: #008080;">14</span>     <span style="color: #0000ff;">void</span> (^finishCallbackBlock)(NSString *); <span style="color: #008000;">//</span><span style="color: #008000;"> 执行完成后回调的block</span>
<span style="color: #008080;">15</span>     
<span style="color: #008080;">16</span> <span style="color: #000000;">}
</span><span style="color: #008080;">17</span> @property NSMutableData *<span style="color: #000000;">resultData;
</span><span style="color: #008080;">18</span> @property(strong) <span style="color: #0000ff;">void</span> (^finishCallbackBlock)(NSString *<span style="color: #000000;">);
</span><span style="color: #008080;">19</span> 
<span style="color: #008080;">20</span> + (<span style="color: #0000ff;">void</span>)postExecuteWithUrlStr:(NSString *)urlStr Paramters:(NSString *)<span style="color: #0000ff;">params</span> FinishCallbackBlock:(<span style="color: #0000ff;">void</span> (^)(NSString *<span style="color: #000000;">))block;
</span><span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span> <span style="color: #0000ff;">@end</span></pre>
</div>

&nbsp;

实现了&lt;NSURLConnectionDataDelegate&gt;协议，因为它要接收post请求的几个回调。

有一个NSMutableData对象，这个对象用于储存请求的结果。

一个finishCallbackBlock的block，这个block用于执行完成后的回调，这个block传入的参数就是返回的结果（这个结果已转成utf-8编码的字符串形式），我们可以在这个block中去处理请求完成后的逻辑

还有一个类方法，这个类方法暴露给外面，让外面进行调用

&nbsp;

接下来，我们看下实现的方法.m文件：

<div class="cnblogs_code" onclick="cnblogs_code_show('5746940f-c0f2-458d-b9ae-6f828341562c')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)
<div id="cnblogs_code_open_5746940f-c0f2-458d-b9ae-6f828341562c" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #008000;">//</span>
<span style="color: #008080;">  2</span> <span style="color: #008000;">//</span><span style="color: #008000;">  POST异步请求的封装
</span><span style="color: #008080;">  3</span> <span style="color: #008000;">//</span><span style="color: #008000;">  使用方法，只需传入url，参数组成的字符串，执行完成后的回调block
</span><span style="color: #008080;">  4</span> <span style="color: #008000;">//</span><span style="color: #008000;">  如下：
</span><span style="color: #008080;">  5</span> <span style="color: #008000;">//</span><span style="color: #008000;">  [HttpPostExecutor postExecuteWithUrlStr:@"</span><span style="color: #008000; text-decoration: underline;">http://www.baidu.com</span><span style="color: #008000;">"
</span><span style="color: #008080;">  6</span> <span style="color: #008000;">//</span><span style="color: #008000;">                              Paramters:@""
</span><span style="color: #008080;">  7</span> <span style="color: #008000;">//</span><span style="color: #008000;">                    FinishCallbackBlock:^(NSString *result){  </span><span style="color: #008000;">//</span><span style="color: #008000;"> 设置执行完成的回调block
</span><span style="color: #008080;">  8</span> <span style="color: #008000;">//</span><span style="color: #008000;">                        NSLog(@"finish callback block, result: %@", result);
</span><span style="color: #008080;">  9</span> <span style="color: #008000;">//</span><span style="color: #008000;">                    }];
</span><span style="color: #008080;"> 10</span> <span style="color: #008000;">//</span><span style="color: #008000;">  post提交的参数，格式如下：
</span><span style="color: #008080;"> 11</span> <span style="color: #008000;">//</span><span style="color: #008000;">  参数1名字=参数1数据&amp;参数2名字＝参数2数据&amp;参数3名字＝参数3数据&amp;...
</span><span style="color: #008080;"> 12</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 13</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 14</span> <span style="color: #008000;">//</span><span style="color: #008000;">  HttpPostExecutor.m
</span><span style="color: #008080;"> 15</span> <span style="color: #008000;">//</span><span style="color: #008000;">  HttpTest
</span><span style="color: #008080;"> 16</span> <span style="color: #008000;">//</span>
<span style="color: #008080;"> 17</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Created by WANGJIE on 13-11-6.
</span><span style="color: #008080;"> 18</span> <span style="color: #008000;">//</span><span style="color: #008000;">  Copyright (c) 2013年 WANGJIE. All rights reserved.
</span><span style="color: #008080;"> 19</span> <span style="color: #008000;">//
</span><span style="color: #008080;"> 20</span> 
<span style="color: #008080;"> 21</span> <span style="color: #0000ff;">#import</span> <span style="color: #800000;">"</span><span style="color: #800000;">HttpPostExecutor.h</span><span style="color: #800000;">"</span>
<span style="color: #008080;"> 22</span> 
<span style="color: #008080;"> 23</span> <span style="color: #0000ff;">@implementation</span><span style="color: #000000;"> HttpPostExecutor
</span><span style="color: #008080;"> 24</span> <span style="color: #0000ff;">@synthesize</span><span style="color: #000000;"> resultData, finishCallbackBlock;
</span><span style="color: #008080;"> 25</span> 
<span style="color: #008080;"> 26</span> <span style="color: #008000;">/*</span><span style="color: #008000;">*
</span><span style="color: #008080;"> 27</span> <span style="color: #008000;"> * 执行POST请求
</span><span style="color: #008080;"> 28</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 29</span> + (<span style="color: #0000ff;">void</span>)postExecuteWithUrlStr:(NSString *)urlStr Paramters:(NSString *)<span style="color: #0000ff;">params</span> FinishCallbackBlock:(<span style="color: #0000ff;">void</span> (^)(NSString *<span style="color: #000000;">))block
</span><span style="color: #008080;"> 30</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 31</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 生成一个post请求回调委托对象（实现了&lt;NSURLConnectionDataDelegate&gt;协议）</span>
<span style="color: #008080;"> 32</span>     HttpPostExecutor *executorDelegate =<span style="color: #000000;"> [[HttpPostExecutor alloc] init];
</span><span style="color: #008080;"> 33</span>     executorDelegate.finishCallbackBlock = block; <span style="color: #008000;">//</span><span style="color: #008000;"> 绑定执行完成时的block</span>
<span style="color: #008080;"> 34</span> 
<span style="color: #008080;"> 35</span>     
<span style="color: #008080;"> 36</span>     NSURL *url = [NSURL URLWithString:urlStr]; <span style="color: #008000;">//</span><span style="color: #008000;"> 生成NSURL对象
</span><span style="color: #008080;"> 37</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 生成Request请求对象（并设置它的缓存协议、网络请求超时配置）</span>
<span style="color: #008080;"> 38</span>     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:<span style="color: #800080;">30</span><span style="color: #000000;">];
</span><span style="color: #008080;"> 39</span>     
<span style="color: #008080;"> 40</span>     [request setHTTPBody:[<span style="color: #0000ff;">params</span> dataUsingEncoding:NSUTF8StringEncoding]]; <span style="color: #008000;">//</span><span style="color: #008000;"> 设置请求参数
</span><span style="color: #008080;"> 41</span>     
<span style="color: #008080;"> 42</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 执行请求连接</span>
<span style="color: #008080;"> 43</span>     NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request <span style="color: #0000ff;">delegate</span><span style="color: #000000;">:executorDelegate];
</span><span style="color: #008080;"> 44</span>     
<span style="color: #008080;"> 45</span>     NSLog(conn ? <span style="color: #800000;">@"</span><span style="color: #800000;">连接创建成功</span><span style="color: #800000;">"</span> : <span style="color: #800000;">@"</span><span style="color: #800000;">连接创建失败</span><span style="color: #800000;">"</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 46</span>     
<span style="color: #008080;"> 47</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 48</span> 
<span style="color: #008080;"> 49</span> 
<span style="color: #008080;"> 50</span> <span style="color: #008000;">/*</span><span style="color: #008000;">*
</span><span style="color: #008080;"> 51</span> <span style="color: #008000;"> * 接收到服务器回应的时回调
</span><span style="color: #008080;"> 52</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 53</span> - (<span style="color: #0000ff;">void</span>)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *<span style="color: #000000;">)response
</span><span style="color: #008080;"> 54</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 55</span>     NSHTTPURLResponse *resp = (NSHTTPURLResponse *<span style="color: #000000;">)response;
</span><span style="color: #008080;"> 56</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 初始化NSMutableData对象（用于保存执行结果）</span>
<span style="color: #008080;"> 57</span>     <span style="color: #0000ff;">if</span>(!<span style="color: #000000;">resultData){
</span><span style="color: #008080;"> 58</span>         resultData =<span style="color: #000000;"> [[NSMutableData alloc] init];
</span><span style="color: #008080;"> 59</span>     }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;"> 60</span>         [resultData setLength:<span style="color: #800080;">0</span><span style="color: #000000;">];
</span><span style="color: #008080;"> 61</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 62</span>     
<span style="color: #008080;"> 63</span>     <span style="color: #0000ff;">if</span><span style="color: #000000;"> ([response respondsToSelector:@selector(allHeaderFields)]) {
</span><span style="color: #008080;"> 64</span>         
<span style="color: #008080;"> 65</span>         NSDictionary *dictionary =<span style="color: #000000;"> [resp allHeaderFields];
</span><span style="color: #008080;"> 66</span>         
<span style="color: #008080;"> 67</span>         NSLog(<span style="color: #800000;">@"</span><span style="color: #800000;">[network]allHeaderFields:%@</span><span style="color: #800000;">"</span><span style="color: #000000;">,[dictionary description]);
</span><span style="color: #008080;"> 68</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 69</span>     
<span style="color: #008080;"> 70</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 71</span> <span style="color: #008000;">/*</span><span style="color: #008000;">*
</span><span style="color: #008080;"> 72</span> <span style="color: #008000;"> * 接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
</span><span style="color: #008080;"> 73</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 74</span> - (<span style="color: #0000ff;">void</span>)connection:(NSURLConnection *)connection didReceiveData:(NSData *<span style="color: #000000;">)data
</span><span style="color: #008080;"> 75</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 76</span>     [resultData appendData:data]; <span style="color: #008000;">//</span><span style="color: #008000;"> 追加结果</span>
<span style="color: #008080;"> 77</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 78</span> <span style="color: #008000;">/*</span><span style="color: #008000;">*
</span><span style="color: #008080;"> 79</span> <span style="color: #008000;"> * 数据传完之后调用此方法
</span><span style="color: #008080;"> 80</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 81</span> - (<span style="color: #0000ff;">void</span>)connectionDidFinishLoading:(NSURLConnection *<span style="color: #000000;">)connection
</span><span style="color: #008080;"> 82</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 83</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> 把请求结果以UTF-8编码转换成字符串</span>
<span style="color: #008080;"> 84</span>     NSString *resultStr =<span style="color: #000000;"> [[NSString alloc] initWithData:[self resultData] encoding:NSUTF8StringEncoding];
</span><span style="color: #008080;"> 85</span>     
<span style="color: #008080;"> 86</span>     <span style="color: #0000ff;">if</span> (finishCallbackBlock) { <span style="color: #008000;">//</span><span style="color: #008000;"> 如果设置了回调的block，直接调用</span>
<span style="color: #008080;"> 87</span> <span style="color: #000000;">        finishCallbackBlock(resultStr);
</span><span style="color: #008080;"> 88</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 89</span> 
<span style="color: #008080;"> 90</span>     
<span style="color: #008080;"> 91</span> <span style="color: #000000;">}
</span><span style="color: #008080;"> 92</span> <span style="color: #008000;">/*</span><span style="color: #008000;">*
</span><span style="color: #008080;"> 93</span> <span style="color: #008000;"> * 网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
</span><span style="color: #008080;"> 94</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 95</span> - (<span style="color: #0000ff;">void</span>)connection:(NSURLConnection *)connection didFailWithError:(NSError *<span style="color: #000000;">)error
</span><span style="color: #008080;"> 96</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 97</span>     NSLog(<span style="color: #800000;">@"</span><span style="color: #800000;">network error: %@</span><span style="color: #800000;">"</span><span style="color: #000000;">, [error localizedDescription]);
</span><span style="color: #008080;"> 98</span>     
<span style="color: #008080;"> 99</span>     <span style="color: #0000ff;">if</span> (finishCallbackBlock) { <span style="color: #008000;">//</span><span style="color: #008000;"> 如果设置了回调的block，直接调用</span>
<span style="color: #008080;">100</span> <span style="color: #000000;">        finishCallbackBlock(nil);
</span><span style="color: #008080;">101</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">102</span>     
<span style="color: #008080;">103</span>     
<span style="color: #008080;">104</span> <span style="color: #000000;">}
</span><span style="color: #008080;">105</span> <span style="color: #0000ff;">@end</span></pre>
</div>
<span class="cnblogs_code_collapse">View Code </span></div>

在这个实现类中，我们在类方法中，先生成一个HttpPostExecutor对象，这个对象用于post请求的回调（因为实现了&lt;NSURLConnectionDataDelegate&gt;协议），然后去执行post连接。

接下来就等下面实现的回调方法被自动调用了，一旦调用

- (<span class="s1">void</span>)connection:(<span class="s2">NSURLConnection</span> *)connection didReceiveResponse:(<span class="s2">NSURLResponse</span> *)response

这个方法，就对resultData（用于存储post请求结果）进行初始化或者清空，因为要开始真正存储数据了嘛；

&nbsp;

- (<span class="s1">void</span>)connection:(<span class="s2">NSURLConnection</span> *)connection didReceiveData:(<span class="s2">NSData</span> *)data

这个方法进行回调的时候，把返回过来的这部分数据存储到resultData中，没什么好说的；

&nbsp;

一旦回调- (<span class="s1">void</span>)connectionDidFinishLoading:(<span class="s2">NSURLConnection</span> *)connection这个方法，说明数据传输完毕了，要做的逻辑就是把数据转成utf-8编码的字符串，然后回调我们设置的回调finishCallbackBlock，把转好的结果字符串传进去，这样我们在回调block方法中实现的逻辑就能正常执行了。

&nbsp;

一旦回调- (<span class="s1">void</span>)connection:(<span class="s2">NSURLConnection</span> *)connection didFailWithError:(<span class="s2">NSError</span> *)error这个方法，说明请求过程中出错了，比如断电、超时等，这时候，也回调我们设置的回调finishCallbackBlock，nil作为结果，这样我们在finishCallbackBlock中就能判断是正常的执行了post还是出了问题。

&nbsp;

好了，接下来，我们就可以在外面去调用了，如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> [HttpPostExecutor postExecuteWithUrlStr:<span style="color: #800000;">@"</span><span style="color: #800000;">http://www.baidu.com</span><span style="color: #800000;">"</span>
<span style="color: #008080;">2</span>                                   Paramters:<span style="color: #800000;">@""</span>
<span style="color: #008080;">3</span>                         FinishCallbackBlock:^(NSString *<span style="color: #000000;">result){
</span><span style="color: #008080;">4</span>                             <span style="color: #008000;">//</span><span style="color: #008000;"> 执行post请求完成后的逻辑</span>
<span style="color: #008080;">5</span>                             NSLog(<span style="color: #800000;">@"</span><span style="color: #800000;">finish callback block, result: %@</span><span style="color: #800000;">"</span><span style="color: #000000;">, result);
</span><span style="color: #008080;">6</span>                         }];</pre>
</div>

这样，以后post请求只需要去调用上面这个方法，在回调block中去处理结果

之后，在我们的代码编写中，就可以只关心业务逻辑，不需要去在意请求协议和回调了

&nbsp;

<span style="color: #800000; font-size: 16px;">**[<span style="color: #800000;">测试demo下载</span>](http://pan.baidu.com/s/1uxVGh)**</span>

&nbsp;

