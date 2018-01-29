---
title: Android退出程序的若干方法
tags: []
date: 2012-03-08 16:42:00
---

Android程序有很多Activity，比如说主窗口A，调用了子窗口B，如果在B中直接finish(), 接下里显示的是A。在B中如何关闭整个Android应用程序呢?本人总结了几种比较简单的实现方法。

1\. Dalvik VM的本地方法

android.os.Process.killProcess(android.os.Process.myPid()) //获取PID

System.exit(0); //常规java、c#的标准退出法，返回值为0代表正常退出

2\. 任务管理器方法

首先要说明该方法运行在Android 1.5 API Level为3以上才可以，同时需要权限

ActivityManager am = (ActivityManager)getSystemService (Context.ACTIVITY_SERVICE);

am.restartPackage(getPackageName());

系统会将，该包下的 ，所有进程，服务，全部杀掉，就可以杀干净了，要注意加上权限 android.permission.RESTART_PACKAGES

3\. 根据Activity的声明周期

3\. 我们知道Android的窗口类提供了历史栈，我们可以通过stack的原理来巧妙的实现，这里我们在A窗口打开B窗口时在Intent中直接加入标志 Intent.FLAG_ACTIVITY_CLEAR_TOP，这样开启B时将会清除该进程空间的所有Activity。

在A窗口中使用下面的代码调用B窗口

Intent intent = new Intent();

intent.setClass(Android123.this, CWJ.class);

intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP); //注意本行的FLAG设置

startActivity(intent);

接下来在B窗口中需要退出时直接使用finish方法即可全部退出。

4.自定义一个Actiivty 栈，道理同上，不过利用一个单例模式的Activity栈来管理所有Activity。并提供退出所有Activity的方法。代码如下：

public class ScreenManager {

private static Stack activityStack;

private static ScreenManager instance;

private ScreenManager(){

}

public static ScreenManager getScreenManager(){

instance=new ScreenManager();

}

return instance;

}

//退出栈顶Activity

public void popActivity(Activity activity){

activity.finish();

activityStack.remove(activity);

activity=null;

}

}

//获得当前栈顶Activity

public Activity currentActivity(){

Activity activity=activityStack.lastElement();

return activity;

}

//将当前Activity推入栈中

public void pushActivity(Activity activity){

activityStack=new Stack();

}

activityStack.add(activity);

}

//退出栈中所有Activity

public void popAllActivityExceptOne(Class cls){

while(true){

Activity activity=currentActivity();

break;

}

break;

}

popActivity(activity);

}

}

}