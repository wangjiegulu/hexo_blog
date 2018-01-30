---
title: IOS推送功能的实现（javapns）
tags: [iOS, push, javapns]
date: 2013-06-06 18:01:00
---

## IOS的推送实现由这样几步来完成:

1.  创建Push SSL Certification
2.  IOS客户端注册Push功能并获得DeviceToken
3.  使用Provider向APNS发送Push消息
4.  IOS客户端接收处理由APNS发来的消息

## <a name="t1"></a>创建Push SSL Certification

&nbsp;&nbsp;&nbsp; 登录developer.apple.com，创建新的App ID，要求此ID的Bundle Identifier不包含通配符，否则不能启用Push以及IAP功能。例如 com.soso.sosoimage。

&nbsp;&nbsp;&nbsp; 在App IDs列表页面，点击刚创建的app id右面的Configure链接，进入Configure App ID界面，选中"Enable for App Push Notification service"。点击Development Push SSL Certificate一行的Configure按钮，弹出"Apple Push Notification service SSL Certificate Assistant"对话框，依对话框操作，类似于创建开发或发布用的Certificate。

&nbsp;&nbsp;&nbsp; 最终将Development Push SSL Certificate下载并安装到本地Keychain Access。导出成p12文件，备用。导出时需要设置密码，不得为空。

&nbsp;&nbsp;&nbsp; 在developer.apple.com，创建一个新的Provisioning Profile，使用我们刚刚创建的支持Push功能的App ID。下载并安装到本地。

&nbsp;

## <a name="t2"></a>IOS客户端注册Push功能并获得DeviceToken

<span>&nbsp;&nbsp;&nbsp; 创建本地工程，info.plist中设置Bundle identifier为刚刚创建的Bundle Id。Com.soso.sosoimage。设定Code Signing Identity为刚刚创建的Provisioning Profile。</span>

&nbsp;&nbsp;&nbsp; 程序第一次执行的时候，调用如下代码.

<div class="cnblogs_code">
<pre>[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];</pre>
</div>

三个参数分别代表消息（横幅或提醒，由用户Setting决定，程序不可更改）、数字标记、声音。

<span>在AppDelegate.m中添加两个方法.</span>

<div class="cnblogs_code">
<pre><span style="color: #008000;">//</span><span style="color: #008000;">iPhone 从APNs服务器获取deviceToken后回调此方法</span>
- (<span style="color: #0000ff;">void</span>)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *<span style="color: #000000;">)deviceToken
{
    NSString</span>* dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:<span style="color: #800000;">@"</span><span style="color: #800000;">&lt;&gt;</span><span style="color: #800000;">"</span><span style="color: #000000;">]];
    NSLog(</span><span style="color: #800000;">@"</span><span style="color: #800000;">deviceToken:%@</span><span style="color: #800000;">"</span><span style="color: #000000;">, dt);
}

</span><span style="color: #008000;">//</span><span style="color: #008000;">注册push功能失败 后 返回错误信息，执行相应的处理</span>
- (<span style="color: #0000ff;">void</span>)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *<span style="color: #000000;">)err
{
    NSLog(</span><span style="color: #800000;">@"</span><span style="color: #800000;">Push Register Error:%@</span><span style="color: #800000;">"</span><span style="color: #000000;">, err.description);
}</span></pre>
</div>

<span>获取DeviceToken后，将其传给Provider。</span>

## <a name="t3"></a>使用Provider向APNS发送Push消息

 <span>Provider，将推送信息发送给APNS（苹果推送服务器）的程序。有很多开源的实现，我们使用javapns ( http://code.google.com/p/javapns/ )。</span>
<span>首先，Provider要有目标DeviceToken，这是发送目标，由客户端传给Provider之后存在某处。</span>
<span>安装javapns，需要导入的jar为bcprov-jdk15-146.jar, log4j-1.2.15.jar, JavaPNS_2.3_Alpha_5.jar。</span>
<span>将前面导出的P12文件放在Provider的工程目录下。</span>
<span>Provider向APNS发送消息可以参考javapns中NotificationTest.java。也可以参考如下例子。</span>

### <a name="t4"></a>(1)使客户端图标显示数字标记

<div class="cnblogs_code">
<pre>Push.badge(2, keystore, password, <span style="color: #0000ff;">false</span>, "7bb8d508e32df651c6c239439737dbd40a88d2461ad2ac1e5dbe49ecea5ccc67");</pre>
</div>

<span>其中，2为要显示的数字；</span>

<div class="cnblogs_code">
<pre>String keystore = "PushCertificates.p12";     <span style="color: #008000;">//</span><span style="color: #008000;">P12文件的路径；</span>
String password = "sosoimage";                <span style="color: #008000;">//</span><span style="color: #008000;">P12文件的密码；</span></pre>
</div>

<span>false，指的是使用测试环境，使用正式产品环境应传入true.</span>
<span>"7bb8d508e32df651c6c239439737dbd40a88d2461ad2ac1e5dbe49ecea5ccc67"为客户端获得并传给Provider的DeviceToken，此参数还可以传入String[]对象，以同时向多个客户端Push消息。</span>

### <a name="t5"></a>(2)使客户端显示横幅或提醒

Provider可以向客户端Push一条Message，但客户端有权限决定这条Message的显示方式（无、横幅、提醒）。

<div class="cnblogs_code">
<pre>Push.alert("A Message", keystore, password, )<span style="color: #0000ff;">false</span>, "7bb8d508e32df651c6c239439737dbd40a88d2461ad2ac1e5dbe49ecea5ccc67");</pre>
</div>

### (3)混合方式

<span>可以在一个Push消息里附带多种信息，Message, 标记，声音，可以使用如下代码.</span>

<div class="cnblogs_code">
<pre>PushNotificationPayload payload =<span style="color: #000000;"> PushNotificationPayload.complex();
payload.addAlert(</span>"A Message"<span style="color: #000000;">);
payload.addBadge(</span>2<span style="color: #000000;">);
payload.addSound(</span>"test.aiff"<span style="color: #000000;">);
Push.payload(payload, , keystore, password, </span><span style="color: #0000ff;">false</span>, "7bb8d508e32df651c6c239439737dbd40a88d2461ad2ac1e5dbe49ecea5ccc67");</pre>
</div>

<span>上面的代码都有可能会有相应的Exception抛出来，需要处理。更多的使用方式可以参考 http://code.google.com/p/javapns/&nbsp;</span>

## <a name="t7"></a>IOS客户端接收处理由APNS发来的消息

<span>(1)当程序未启动，用户接收到消息。需要在AppDelegate中的didFinishLaunchingWithOptions得到消息内容。代码如下，</span>

<div class="cnblogs_code">
<pre>- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *<span style="color: #000000;">)launchOptions
{
    ...

    NSDictionary</span>* payload =<span style="color: #000000;"> [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    </span><span style="color: #0000ff;">if</span><span style="color: #000000;"> (payload) 
    {
    ...
    }

    </span><span style="color: #000000;">...
}</span></pre>
</div>

<span>(2)当程序在前台运行，接收到消息不会有消息提示（提示框或横幅）。当程序运行在后台，接收到消息会有消息提示，点击消息后进入程序，AppDelegate的didReceiveRemoteNotification函数会被调用（需要自己重写），消息做为此函数的参数传入，代码如下</span>

<div class="cnblogs_code">
<pre>- (<span style="color: #0000ff;">void</span>)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *<span style="color: #000000;">)payload
{ 
    ...
}</span></pre>
</div>

<span>(3)无论在哪个函数传入，消息总是一个NSDictionary对象，处理方式可以参考如下代码</span>

<div class="cnblogs_code">
<pre>- (<span style="color: #0000ff;">void</span>)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *<span style="color: #000000;">)payload 
{
    NSLog(</span><span style="color: #800000;">@"</span><span style="color: #800000;">remote notification: %@</span><span style="color: #800000;">"</span><span style="color: #000000;">,[payload description]);
    NSString</span>* alertStr =<span style="color: #000000;"> nil;        
    NSDictionary </span>*apsInfo = [payload objectForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">aps</span><span style="color: #800000;">"</span><span style="color: #000000;">];    
    NSObject </span>*alert = [apsInfo objectForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">alert</span><span style="color: #800000;">"</span><span style="color: #000000;">];    
    </span><span style="color: #0000ff;">if</span> ([alert isKindOfClass:[NSString <span style="color: #0000ff;">class</span><span style="color: #000000;">]])    
    {       
        alertStr </span>= (NSString*<span style="color: #000000;">)alert;    
    }    
    </span><span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span> ([alert isKindOfClass:[NSDictionary <span style="color: #0000ff;">class</span><span style="color: #000000;">]])    
    {        
        NSDictionary</span>* alertDict = (NSDictionary*<span style="color: #000000;">)alert;        
        alertStr </span>= [alertDict objectForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">body</span><span style="color: #800000;">"</span><span style="color: #000000;">];    
    }        
    application.applicationIconBadgeNumber </span>= [[apsInfo objectForKey:<span style="color: #800000;">@"</span><span style="color: #800000;">badge</span><span style="color: #800000;">"</span><span style="color: #000000;">] integerValue];        
    </span><span style="color: #0000ff;">if</span> ([application applicationState] == UIApplicationStateActive &amp;&amp; alertStr !=<span style="color: #000000;"> nil)    
    {
        UIAlertView</span>* alertView = [[UIAlertView alloc] initWithTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">Pushed Message</span><span style="color: #800000;">"</span> message:alertStr <span style="color: #0000ff;">delegate</span>:nil cancelButtonTitle:<span style="color: #800000;">@"</span><span style="color: #800000;">OK</span><span style="color: #800000;">"</span><span style="color: #000000;"> otherButtonTitles:nil];
        [alertView show];    
    }
}</span></pre>
</div>

&nbsp;

来自：[http://blog.csdn.net/worldmatrix/article/details/7634596](http://blog.csdn.net/worldmatrix/article/details/7634596)

&nbsp;

