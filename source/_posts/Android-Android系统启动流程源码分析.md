---
title: '[Android]Android系统启动流程源码分析'
tags: []
date: 2015-12-02 18:58:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5013863.html>
**</font>

### Android系统启动流程源码分析

首先我们知道，`Android`是基于`Linux`的，当`Linux`内核加载完成时就会自动启动一个`init`的进程。
又因为我们每当我们启动一个App时，就会生成一个新的`dalvik`实例，并处于一个新的进程（当然一个App也可能是多进程的）。
当我们打开第一个App的时候，就会通过`init`进程fork出一个`zygote`进程。之后打开新的App的时候都会`fork`之前的`zygote`进程。

当`fork`一个`zygote`进程时，会进入`com.android.internal.os.ZygoteInit`的`main`方法进行初始化操作：

- 预加载资源
```java
// ...
preloadClasses();
preloadResources();
preloadOpenGL();
preloadSharedLibraries();
preloadTextResources();
// Ask the WebViewFactory to do any initialization that must run in the zygote process,
// for memory sharing purposes.
WebViewFactory.prepareWebViewInZygote();
// ...
```

- 从第一个`zygote`进程`fork`出`SystemServer`进程，这个进程提供各种`ManagerService`。

```java
startSystemServer(abiList, socketName);

private static boolean startSystemServer(String abiList, String socketName)
            throws MethodAndArgsCaller, RuntimeException {
	int pid;
	// ...
	String args[] = {
            "--setuid=1000",
            "--setgid=1000",
            "--setgroups=1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1018,1021,1032,3001,3002,3003,3006,3007",
            "--capabilities=" + capabilities + "," + capabilities,
            "--nice-name=system_server",
            "--runtime-args",
            "com.android.server.SystemServer",
        };
    /* Request to fork the system server process */
    pid = Zygote.forkSystemServer(
            parsedArgs.uid, parsedArgs.gid,
            parsedArgs.gids,
            parsedArgs.debugFlags,
            null,
            parsedArgs.permittedCapabilities,
            parsedArgs.effectiveCapabilities);
        // ...
}
```

- Fork完`SystemServer`进程之后，继续接下来在`handleSystemServerProcess`方法中传入参数到`SystemServer`：
- 
```java
RuntimeInit.zygoteInit(parsedArgs.targetSdkVersion, parsedArgs.remainingArgs, cl);
```
注意，这里传入的参数是fork`SystemServer`进程后剩下的参数（`parsedArgs.remainingArgs`），其实只剩下了`com.android.server.SystemServer`这个参数了。

接下来继续调用`applicationInit` ，传入参数：

```java
private static void applicationInit(int targetSdkVersion, String[] argv, ClassLoader classLoader)
            throws ZygoteInit.MethodAndArgsCaller {
	final Arguments args;
	// ...
	args = new Arguments(argv);
	// ...
}
```

解析成`Arguments`后，得到了一个`startClass`对象，这个`startClass`其实就是刚刚的那个`com.android.server.SystemServer`。

接下来，继续调用 `invokeStaticMain`

```java
private static void invokeStaticMain(String className, String[] argv, ClassLoader classLoader) throws ZygoteInit.MethodAndArgsCaller {
	Class<?> cl;
	// ...
	cl = Class.forName(className, true, classLoader);
	// ...
	m = cl.getMethod("main", new Class[] { String[].class });
	// ...
	throw new ZygoteInit.MethodAndArgsCaller(m, argv);
}
```

就是调用通过反射得到`com.android.server.SystemServer`（也就是上面的`startClass`）的`main(argv[])`方法，然后手动抛一个携带了这个`main(argv[])`方法的`MethodAndArgsCaller`异常，但是这个异常是在`ZygoteInit.main()`方法中被catch，然后去调用它的`run()`方法，当然这个`run()`方法中会再去通过反射调用携带的`main()`方法（这个绕法真是有点坑爹－－。）：

```java
public static class MethodAndArgsCaller extends Exception implements Runnable {
	// ...
	public void run() {
		// ...
	    mMethod.invoke(null, new Object[] { mArgs });
		// ...
	}
	// ...
}
```

绕了这么一大圈，终于通过`MethodAndArgsCaller`调用`SystemServer`的`main()`方法了，代码很简单，直接`new`了之后`run`：

```java
new SystemServer().run();
```

接着，我们看`SystemServer`的`run`方法：

```java
// ... (省略初始化当前的language、locale、country、指纹、用户等信息的初始化准备工作)
// 设置当前进程设置优先级为THREAD_PRIORITY_FOREGROUND（-2）
android.os.Process.setThreadPriority(
    android.os.Process.THREAD_PRIORITY_FOREGROUND);
android.os.Process.setCanSelfBackground(false);
// 初始化主线程Looper
Looper.prepareMainLooper();
// ...
// 启动消息循环
Looper.loop()
```

然后调用`createSystemContext()`方法创建初始化`system context`，这个待会再展开。

创建`SystemServiceManager`：
```java
mSystemServiceManager = new SystemServiceManager(mSystemContext);
LocalServices.addService(SystemServiceManager.class, mSystemServiceManager);
```

使用`SystemServiceManager`去通过以下方法创建启动各个`Service`：
1\. startBootstrapServices()：
- `com.android.server.pm.Installer`：提供安装、卸载App等服务
- `com.android.server.am.ActivityServiceManager`：提供Activity等组件的管理的服务，这个比较复杂暂且再挖个坑。
- `com.android.server.power.PowerManagerService`：电源管理的服务。
- `com.android.server.lights.LightsService`：LED管理和背光显示的服务。
- `com.android.server.display.DisplayManagerService`：提供显示的生命周期管理，根据物理显示设备当前的情况决定显示配置，在状态改变时发送通知给系统和应用等服务。
- `com.android.server.pm.PackageManagerService`：管理所有的`.apk`。
- `com.android.server.pm.UserManagerService`：提供用户相关服务。
- 通过`startSensorService()`本地方法启动Sensor服务。

2\. startCoreServices();
- `com.android.server.BatteryService`：电量服务，需要`LightService`。
- `com.android.server.usage.UsageStatsService`：提供收集统计应用程序数据使用状态的服务。
- `com.android.server.webkit.WebViewUpdateService`：私有的服务（@hide），用于`WebView`的更新。

3\. startOtherServices();
- `com.android.server.accounts.AccountManagerService`：提供所有账号、密码、认证管理等等的服务。
- `com.android.server.content.ContentService`：用户数据同步的服务。
- `com.android.server.VibratorService`：震动服务。
- `IAlarmManager`：提醒服务。
- `android.os.storage.IMountService`：存储管理服务。
- `com.android.server.NetworkManagementService`：系统网络连接管理服务。
- `com.android.server.net.NetworkStatsService`：收集统计详细的网络数据服务。
- `com.android.server.net.NetworkPolicyManagerService`：提供低网络策略规则管理服务。
- `com.android.server.ConnectivityService`：提供数据连接服务。
- `com.android.server.NetworkScoreService`：`android.net.NetworkScoreManager`的备份服务。
- `com.android.server.NsdService`：网络发现服务（Network Service Discovery Service）。
- `com.android.server.wm.WindowManagerService`：窗口管理服务。
- `com.android.server.usb.UsbService`：USB服务。
- `com.android.server.SerialService`：串口服务。
- `com.android.server.NetworkTimeUpdateService`：网络时间同步服务。
- `com.android.server.CommonTimeManagementService`：管理本地常见的时间配置的服务，当网络配置变化时会重新配置本地服务。
- `com.android.server.input.InputManagerService`：事件传递分发服务。
- `com.android.server.TelephonyRegistry`：提供电话注册管理的服务。
- `com.android.server.ConsumerIrService`：远程控制服务。
- `com.android.server.audio.AudioService`：音量、铃声、声道等管理服务。
- `com.android.server.MmsServiceBroker`：`MmsService`的代理，因为`MmsService`运行在电话进程中，可能随时crash，它会通过一个`connection`与`MmsService`建立一个桥梁，`MmsService`实现了公开的`SMS/MMS`的API。
- `TelecomLoaderService`
- `CameraService`
- `AlarmManagerService`
- `BluetoothService`
- 还有其它很多很多Service，这方法竟然有近1000行……

在`startOtherServices()`方法的最后：

```java
mActivityManagerService.systemReady(new Runnable() {
	@Override
	public void run() {
		// 下面仍然是各种Service的启动...
	}
}
```

调用这个方法用来告诉`ActivityManagerService`，此时可以运行第三方的代码了（注意：这里的Home界面、Launcher等内置的App也算是第三方的App）。

```java
public void systemReady(final Runnable goingCallback) {
	// ...
	if (mSystemReady) {
		// 回调到SystemServer，继续启动各种Service
		if (goingCallback != null) {
		    goingCallback.run();
		}
		return;
	}
	// ...

	ResolveInfo ri = mContext.getPackageManager().resolveActivity(new Intent(Intent.ACTION_FACTORY_TEST), STOCK_PM_FLAGS);
	// ...
	ActivityInfo ai = ri.activityInfo;
	ApplicationInfo app = ai.applicationInfo;
	// ...从PackageManager中获取要打开的HomeActivity
	mTopComponent = new ComponentName(app.packageName, ai.name);
	// ...
	// 启动第一个Home界面
	startHomeActivityLocked(mCurrentUserId, "systemReady");

	// ...
	// 广播通知启动完成
	broadcastIntentLocked(/*...*/, mCurrentUserId);
	broadcastIntentLocked(/*...*/, UserHandle.USER_ALL);
	// ...
}
```

启动Home界面的`startHomeActivityLocked`方法，调用`mStackSupervisor`启动`HomeActivity`：

```java
boolean startHomeActivityLocked(int userId, String reason) {
	// ...
	Intent intent = getHomeIntent();
	// ...
	intent.setFlags(intent.getFlags() | Intent.FLAG_ACTIVITY_NEW_TASK);
	mStackSupervisor.startHomeActivity(intent, aInfo, reason);
	// ...
}

Intent getHomeIntent() {
	Intent intent = new Intent(mTopAction, mTopData != null ? Uri.parse(mTopData) : null);
	// 设置前面获取到的mTopComponent
	intent.setComponent(mTopComponent);
	// ...
	intent.addCategory(Intent.CATEGORY_HOME);
	// ...
}
```

到此为止，`SystemServer` start完毕，并且启动了Home界面。

然后我们再回过头去看看在我们前面创建系统级的`Context`（`createSystemContext`）的时候做了什么：
```java
ActivityThread activityThread = ActivityThread.systemMain();
mSystemContext = activityThread.getSystemContext();
mSystemContext.setTheme(android.R.style.Theme_DeviceDefault_Light_DarkActionBar);
```

首先调用了`ActivityThread`的静态方法`systemMain()`：

```java
public static ActivityThread systemMain() {
	// ...
    ActivityThread thread = new ActivityThread();
    thread.attach(true);
    return thread;
}
```

创建一个`ActivityThread`，然后调用它的`attach()`方法：

```java
thread.attach(true);

private void attach(boolean system) {
	if (!system) {
		// ...
	}else{
		// ...
		mInstrumentation = new Instrumentation();
        ContextImpl context = ContextImpl.createAppContext(this, getSystemContext().mPackageInfo);
        mInitialApplication = context.mPackageInfo.makeApplication(true, null);
        mInitialApplication.onCreate();
		// ...
	}
}
```

参数`system`表示，是否是系统级的线程，现在我们是启动整个Android系统，显然当前传入的参数为`true`。所以进入else，首先，创建一个`Instrumentation`，`Instrumentation`是什么？暂时先挖个坑。接着通过`System Context`创建一个`ContextImpl`，然后使用它的`LoadedApk::makeApplication`方法来创建整个应用的`Application`对象，然后调用`Application`的`onCreate`方法。

然后看下`LoadedApk::makeApplication`方法的实现：

```java
public Application makeApplication(boolean forceDefaultAppClass,
            Instrumentation instrumentation) {
	// 只有第一次调用makeApplication才会往下执行
	if (mApplication != null) {
	    return mApplication;
    }
    // 初始化系统的Application，所以appClass是"android.app.Application"
	String appClass = mApplicationInfo.className;
    if (forceDefaultAppClass || (appClass == null)) {
        appClass = "android.app.Application";
    }
	// ...
	ContextImpl appContext = ContextImpl.createAppContext(mActivityThread, this);
    app = mActivityThread.mInstrumentation.newApplication(
            cl, appClass, appContext);
    appContext.setOuterContext(app);
	// ...	
}
```

创建`appContext`，然后通过`Instrumentation`生成`Application`对象，并给`appContext`设置外部引用。