---
title: '[Android]从Launcher开始启动App流程源码分析'
tags: []
date: 2015-12-03 17:45:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5017056.html>
**</font>

## 从Launcher开始启动App流程源码分析

`com.android.launcher.Launcher`就是我们的Launcher页面了，可以看到Launcher其实也是一个`Activity`：

```java
public final class Launcher extends Activity implements View.OnClickListener, OnLongClickListener {
	// ...
}
```

既然是`Activity`，那当然也会有`onCreate`、`onResume`等生命周期了，按照逻辑，应该会去加载所有App，以网格的布局显示在页面上，果然，在`onResume`看到了这个方法：

```java
@Override
protected void onResume() {
    super.onResume();
    if (mRestoring) {
        startLoaders();
    }
    // ...
}
```

看方法名就可以猜到这个方法就是用来加载所有App信息的，进入这个方法：

```java
private void startLoaders() {
	boolean loadApplications = sModel.loadApplications(true, this, mLocaleChanged);
	sModel.loadUserItems(!mLocaleChanged, this, mLocaleChanged, loadApplications);
	mRestoring = false;
}
```

这里调用`sModel`（`LauncherModel`类型）的`loadUserItems`方法去加载数据了，`sModel`明显属于`Model`层，进入`loadUserItems`方法：

```java
void loadUserItems(boolean isLaunching, Launcher launcher, boolean localeChanged,
            boolean loadApplications) {
	// ...
		mDesktopItemsLoaded = false;
        mDesktopItemsLoader = new DesktopItemsLoader(launcher, localeChanged, loadApplications,
                isLaunching);
        mDesktopLoaderThread = new Thread(mDesktopItemsLoader, "Desktop Items Loader");
        mDesktopLoaderThread.start();
	// ...
}
```
然后使用`DesktopItemsLoader`在`mDesktopLoaderThread`线程中加载，：

```java
private class DesktopItemsLoader implements Runnable {
	// ...
	public void run() {
		// ...
		final Cursor c = contentResolver.query(LauncherSettings.Favorites.CONTENT_URI, null, null, null, null);
		// ...
		final int idIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites._ID);
		final int intentIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.INTENT);
		final int titleIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.TITLE);
		final int iconTypeIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.ICON_TYPE);
		final int iconIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.ICON);
		final int iconPackageIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.ICON_PACKAGE);
		final int iconResourceIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.ICON_RESOURCE);
		final int containerIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.CONTAINER);
		final int itemTypeIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.ITEM_TYPE);
		final int appWidgetIdIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.APPWIDGET_ID);
		final int screenIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.SCREEN);
		final int cellXIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.CELLX);
		final int cellYIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.CELLY);
		final int spanXIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.SPANX);
		final int spanYIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.SPANY);
		final int uriIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.URI);
		final int displayModeIndex = c.getColumnIndexOrThrow(LauncherSettings.Favorites.DISPLAY_MODE);
		// ...
		// 通过launcher回调返回数据
		launcher.onDesktopItemsLoaded(uiDesktopItems, uiDesktopWidgets);
		// ...
	}
	// ...
}
```

然后我们回到`Launcher`的`onDesktopItemsLoaded`方法：
```java
void onDesktopItemsLoaded(ArrayList<ItemInfo> shortcuts, ArrayList<LauncherAppWidgetInfo> appWidgets) {
	// ...
	bindDesktopItems(shortcuts, appWidgets);
}
```

继续进入`bindDesktopItems`方法：

```java
private void bindDesktopItems(ArrayList<ItemInfo> shortcuts, ArrayList<LauncherAppWidgetInfo> appWidgets) {
	// ...
	mBinder = new DesktopBinder(this, shortcuts, appWidgets, drawerAdapter);
    mBinder.startBindingItems();
}
```

进入`startBindingItems`方法：

```java
public void startBindingItems() {
	// ...
	obtainMessage(MESSAGE_BIND_ITEMS, 0, mShortcuts.size()).sendToTarget();
}
```

这里使用了`Handler`发送消息，进入`Handler`的`handleMessage`方法：

```java
@Override
public void handleMessage(Message msg) {
	// ...
	switch (msg.what) {
		// ...
		case MESSAGE_BIND_ITEMS: {
			launcher.bindItems(this, mShortcuts, msg.arg1, msg.arg2);
            break;
        }
		// ...
	}
}
```

接收到消息之后调用`bindItems`方法：

```java
private void bindItems(Launcher.DesktopBinder binder, ArrayList<ItemInfo> shortcuts, int start, int count) {
	// ...
	case LauncherSettings.Favorites.ITEM_TYPE_APPLICATION:
	case LauncherSettings.Favorites.ITEM_TYPE_SHORTCUT:
		final View shortcut = createShortcut((ApplicationInfo) item);
		workspace.addInScreen(shortcut, item.screen, item.cellX, item.cellY, 1, 1, !desktopLocked);
	// ...
}
```

这里我们只考虑app或者app快捷方式的情况，文件夹和widgets暂时不考虑。app或者app快捷方式实质上都是进入了这个逻辑中，调用`createShortcut`方法：

```java
// 重载方法，最终都会调用这个方法
View createShortcut(int layoutResId, ViewGroup parent, ApplicationInfo info) {
	// ...
	TextView favorite = (TextView) mInflater.inflate(layoutResId, parent, false);
	// ...
	favorite.setCompoundDrawablesWithIntrinsicBounds(null, info.icon, null, null);
	favorite.setText(info.title);
	favorite.setTag(info);
	favorite.setOnClickListener(this);
	// ...
}
```

这里首先inflater出item的布局，然后设置`text`和`OnClickListener`，还有tag，这个tag是`ApplicationInfo`，里面包含了各种App信息，是从App的`AndroidManifest.xml`的`<application>`标签中解析出来的。既然设置了点击事件，显然，点击后应该会打开对应的App才对。所以继续看`onClick`方法：

```java
public void onClick(View v) {
    Object tag = v.getTag();
    if (tag instanceof ApplicationInfo) {
        // Open shortcut
        final Intent intent = ((ApplicationInfo) tag).intent;
        startActivitySafely(intent);
    } else if (tag instanceof FolderInfo) {
        handleFolderClick((FolderInfo) tag);
    }
}
```

点击App就会通过`startActivitySafely`方法使用刚才设置的tag，也就是`ApplicationInfo`中的intent进行跳转：

```java
void startActivitySafely(Intent intent) {
	intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
	// ...
	startActivity(intent);
	// ...
}
```

然后我们来看看打开某个app的时候整个流程是怎么走的。接着上面的的`startActivity()`方法走：

```java
public void startActivity(Intent intent, @Nullable Bundle options) {
	// ...
	if (options != null) {
		startActivityForResult(intent, -1, options);
	} else {
	    startActivityForResult(intent, -1);
	}
	// ...
}
```

可以看到，不管你是调用了`startActivity`还是`startActivityForResult`方法，`startActivityForResult`方法，并且如果是调用的`startActivity`，则默认`requestCode`就是-1，所以如果你想调用`startActivityForResult`的时候，注意不能把`requestCode`设置为-1，否则它的效果就跟`startActivity`一样了，不会再回调`onActivityResult`！，再看看`startActivityForResult`的实现：

```java
public void startActivityForResult(Intent intent, int requestCode, @Nullable Bundle options) {
	Instrumentation.ActivityResult ar = mInstrumentation.execStartActivity(
            this, mMainThread.getApplicationThread(), mToken, this,
            intent, requestCode, options);
    // ...
}
```

可以看到，Activity内部是使用`mInstrumentation`（`Instrumentation`类型）执行`execStartActivity`方法来实现`Activity`跳转的，执行完毕后会返回一个`Instrumentation.ActivityResult`。

然后查看`Instrumentation::execStartActivity`：

```java
public ActivityResult execStartActivity(
	// ...
	int result = ActivityManagerNative.getDefault()
        .startActivity(whoThread, who.getBasePackageName(), intent,
                intent.resolveTypeIfNeeded(who.getContentResolver()),
                token, target != null ? target.mEmbeddedID : null,
                requestCode, 0, null, options);
	// ...
}
```

首先通过`ActivityManagerNative.getDefault()`获得一个`IActivityManager`的实现类：

```java
static public IActivityManager getDefault() {
	return gDefault.get();
}

private static final Singleton<IActivityManager> gDefault = new Singleton<IActivityManager>() {
	protected IActivityManager create() {
		// 通过Binder IPC获取ActivityManager（IBinder）
        IBinder b = ServiceManager.getService("activity");
        // ...
        IActivityManager am = asInterface(b);
        // ...
        return am;
    }
};

static public IActivityManager asInterface(IBinder obj) {
    if (obj == null) {
        return null;
    }
    IActivityManager in =
        (IActivityManager)obj.queryLocalInterface(descriptor);
    if (in != null) {
        return in;
    }
    return new ActivityManagerProxy(obj);
}
```

先通过Binder IPC的方式从服务端获取一个`Activity Manager`，然后通过`ActivityManagernative`封装成一个代理`ActivityManagerProxy`对象，然后调用`startActivity`也是使用了Binder IPC进行与服务器端的通信，（整个Android系统的通信机制使用了大量的Binder IPC，这个以后再专门讨论这个吧），接着，我们进入到了`com.android.server.am.ActivityManagerService`的`startActivity`方法：

```java
@Override
public final int startActivity(IApplicationThread caller, String callingPackage, Intent intent, String resolvedType, IBinder resultTo, String resultWho, int requestCode, int startFlags, ProfilerInfo profilerInfo, Bundle options) {
    return startActivityAsUser(caller, callingPackage, intent, resolvedType, resultTo, resultWho, requestCode, startFlags, profilerInfo, options, UserHandle.getCallingUserId());
}
```

接下来的调用链：

-> `startActivityAsUser`
-> `startActivityMayWait`
-> `startActivityLocked`
-> `startActivityUncheckedLocked`
-> `targetStack.startActivityLocked(r, newTask, doResume, keepCurTransition, options)`
-> `mStackSupervisor.resumeTopActivitiesLocked(this, r, options)`
-> `resumeTopActivityInnerLocked(prev, options);`
-> `mStackSupervisor.startSpecificActivityLocked(next, true, true)`

`startSpecificActivityLocked`方法如下：

```java
void startSpecificActivityLocked(ActivityRecord r, boolean andResume, boolean checkConfig) {
    ProcessRecord app = mService.getProcessRecordLocked(r.processName,
            r.info.applicationInfo.uid, true);
	// ...
	if (app != null && app.thread != null) {
		// ...
		realStartActivityLocked(r, app, andResume, checkConfig);
		return;
	}
	// ...
	mService.startProcessLocked(r.processName, r.info.applicationInfo, true, 0, "activity", r.intent.getComponent(), false, false, true);
}
```

首先从`mService`找出对应需要启动Activity的进程（通过进程名字和uid，进程名字可以在`AndroidManifest.xml`中配置）如果可以获取到，说明这个Activity所属的进程已经存在了，也就是说app已经在运行了，那就会调用`realStartActivityLocked`，否则，如果该Activity所在的App是第一次启动，则会调用`mService.startProcessLocked`方法：

```java
final ProcessRecord startProcessLocked(/*...*/){
	// ...
	startProcessLocked(app, hostingType, hostingNameStr, abiOverride, entryPoint, entryPointArgs);
	// ...
}

final ProcessRecord startProcessLocked(String processName, ApplicationInfo info, boolean knownToBeDead, int intentFlags, String hostingType, ComponentName hostingName, boolean allowWhileBooting, boolean isolated, int isolatedUid, boolean keepIfLarge, String abiOverride, String entryPoint, String[] entryPointArgs, Runnable crashHandler) {
	// ...
	app = getProcessRecordLocked(processName, info.uid, keepIfLarge);
	// ...
	if (app == null) {
		app = newProcessRecordLocked(info, processName, isolated, isolatedUid);
	}
	// ...
}

private final void startProcessLocked(ProcessRecord app, String hostingType, String hostingNameStr, String abiOverride, String entryPoint, String[] entryPointArgs) {
	// ...
	// entryPoint表示一个类，它用来作为新创建的进程的主入口，会调用这个类的静态main方法，这个参数在startProcessLocked方法中会被检查重置，如果是null的话，就默认是android.app.ActivityThread。
	if (entryPoint == null) entryPoint = "android.app.ActivityThread";
	// ...
	Process.ProcessStartResult startResult = Process.start(entryPoint,
            app.processName, uid, uid, gids, debugFlags, mountExternal,
            app.info.targetSdkVersion, app.info.seinfo, requiredAbi, 
            instructionSet, app.info.dataDir, entryPointArgs);
	// ...	
}
```

这3个重载方法做的事情就是，先根据进程名字调用`getProcessRecordLocked()`获取`ProcessRecord`，如果`ProcessRecord`不存在，则调用`newProcessRecordLocked()`方法建立一个`ProcessRecord`，并且新的`ProcessRecord`绑定了`ApplicationInfo`，`uid`等信息，但后进入第三个重载方法，执行新建、启动进程。

再看`Process::start`的实现：

```java
public static final ProcessStartResult start(/*...*/){
	// ...
	return startViaZygote(processClass, niceName, uid, gid, gids,
              debugFlags, mountExternal, targetSdkVersion, seInfo,
              abi, instructionSet, appDataDir, zygoteArgs);
	// ...
}
```

接下来就是通过`Zygote`进程`fork`一个新的进程作为app的进程。这里要需要讲的一个参数是`processClass`，这个参数表示一个类，它用来作为新创建的进程的主入口，会调用这个类的静态`main`方法，这个参数在`startProcessLocked`方法中会被检查重置，如果是null的话，就默认是`android.app.ActivityThread`。

现在App的进程也创建成功了，就会进入`android.app.ActivityThread`的静态的`main`中：

```java
public static void main(String[] args) {
	// ...
	// 初始化主线程Looper
	Looper.prepareMainLooper();
	// ...
	ActivityThread thread = new ActivityThread();
    thread.attach(false);	
	// ...
	// 启动消息循环
	Looper.loop()
	// ...
}
```

然后创建了一个`ActivityThread`，说明每当一个新的app进程被创建，都会对应一个新的`ActivityThread`实例，然后调用它的`attach`方法：

```java
private void attach(boolean system) {
	// ...
	if (!system) {
		// ...
		final IActivityManager mgr = ActivityManagerNative.getDefault();
		// ...
		mgr.attachApplication(mAppThread);
		// ...
	}else{
		// ...
	}
	// ...
}
```

然后再次通过Binder IPC调用`ActivityManagerProxy`的`attachApplication`，传入的`ApplicationThread`（Binder）参数用于在服务端进行回调通信。最后进入`ActivityManagerService::attachApplication`，再调用`attachApplicationLocked(thread, callingPid)`

```java
private final boolean attachApplicationLocked(IApplicationThread thread, int pid) {
	// ...
	app = mPidsSelfLocked.get(pid);
	// ...
	app.makeActive(thread, mProcessStats);
    app.curAdj = app.setAdj= -100;
    app.curSchedGroup = app.setSchedGroup = Process.THREAD_GROUP_DEFAULT;
    app.forcingToForeground = null;
    updateProcessForegroundLocked(app, false, false);
    app.hasShownUi = false;
    app.debugging = false;
    app.cached = false;
    app.killedByAm = false;
	// ...
	thread.bindApplication(processName, appInfo, providers, app.instrumentationClass, profilerInfo, app.instrumentationArguments, app.instrumentationWatcher, app.instrumentationUiAutomationConnection, testMode, enableOpenGlTrace, enableTrackAllocation, isRestrictedBackupMode || !normalMode, app.persistent, new Configuration(mConfiguration), app.compat, getCommonServicesLocked(app.isolated), mCoreSettingsObserver.getCoreSettingsLocked());
	// ...
	if (normalMode) {
	    try {
	        if (mStackSupervisor.attachApplicationLocked(app)) {
	            didSomething = true;
	        }
	    } catch (Exception e) {
	        Slog.wtf(TAG, "Exception thrown launching activities in " + app, e);
	        badApp = true;
	    }
	}
	// ...
}
```

首先，通过pid获取刚刚创建的进程，然后对app进行一些初始化工作，然后调用`bindApplication`远程调用客户端`ActivityThread::bindApplication`，再通过`Handler`调用到`ActivityThread::handleBindApplication`方法：

```java
private void handleBindApplication(AppBindData data) {
	// ...
	final ContextImpl appContext = ContextImpl.createAppContext(this, data.info);
	if (data.instrumentationName != null) {
		// ...
		mInstrumentationPackageName = ii.packageName;
        mInstrumentationAppDir = ii.sourceDir;
        mInstrumentationSplitAppDirs = ii.splitSourceDirs;
        mInstrumentationLibDir = ii.nativeLibraryDir;
        mInstrumentedAppDir = data.info.getAppDir();
        mInstrumentedSplitAppDirs = data.info.getSplitAppDirs();
        mInstrumentedLibDir = data.info.getLibDir();

        ApplicationInfo instrApp = new ApplicationInfo();
        instrApp.packageName = ii.packageName;
        instrApp.sourceDir = ii.sourceDir;
        instrApp.publicSourceDir = ii.publicSourceDir;
        instrApp.splitSourceDirs = ii.splitSourceDirs;
        instrApp.splitPublicSourceDirs = ii.splitPublicSourceDirs;
        instrApp.dataDir = ii.dataDir;
        instrApp.nativeLibraryDir = ii.nativeLibraryDir;
        LoadedApk pi = getPackageInfo(instrApp, data.compatInfo,
                appContext.getClassLoader(), false, true, false);
        ContextImpl instrContext = ContextImpl.createAppContext(this, pi);
        // ...
java.lang.ClassLoader cl = instrContext.getClassLoader();
        mInstrumentation = (Instrumentation) cl.loadClass(data.instrumentationName.getClassName()).newInstance();
        mInstrumentation.init(this, instrContext, appContext, new ComponentName(ii.packageName, ii.name), data.instrumentationWatcher, data.instrumentationUiAutomationConnection);
        // ...
	}else{
		mInstrumentation = new Instrumentation();
	}
	// ...
	Application app = data.info.makeApplication(data.restrictedBackupMode, null);
    mInitialApplication = app;
	// ...
	mInstrumentation.callApplicationOnCreate(app);
	// ...
}
```

首先，创建一个当前App的`Context`，然后如果`data.instrumentationName != null`，则初始化`Instrumentation`相关的变量，并创建`Instrumentation`的`ApplicationInfo`等对象来创建`Instrumentation`的`Context`，然后创建`Instrumentation`对象，并调用它的`init`方法进行初始化。如果`data.instrumentationName == null`，则new一个`Instrumentation`（在一个进程中只会有一个`Instrumentation`实例）然后创建`Application`对象，并调用它的`onCreate`方法，这样`Application`就会被回调了。

然后我们回到`ActivityManagerService::attachApplicationLocked`方法，远程执行完`thread.bindApplication`方法之后，接下来会调用`mStackSupervisor.attachApplicationLocked(app)`方法：

```java
boolean attachApplicationLocked(ProcessRecord app) throws RemoteException {
	// ...
	ActivityRecord hr = stack.topRunningActivityLocked(null);
	// ...
	realStartActivityLocked(hr, app, true, true)
	// ...
}
```

先通过`topRunningActivityLocked`从堆栈顶端获取要启动的Activity，然后`realStartActivityLocked(hr, app, true, true)`：

```java
final boolean realStartActivityLocked(ActivityRecord r,
            ProcessRecord app, boolean andResume, boolean checkConfig)
            throws RemoteException {
	// ...
	app.thread.scheduleLaunchActivity(new Intent(r.intent), r.appToken, System.identityHashCode(r), r.info, new Configuration(mService.mConfiguration), new Configuration(stack.mOverrideConfig), r.compat, r.launchedFromPackage, task.voiceInteractor, app.repProcState, r.icicle, r.persistentState, results, newIntents, !andResume, mService.isNextTransitionForward(), profilerInfo);
	// ...
}
```

继续通过Binder IPC远程调用`scheduleLaunchActivity`方法，然后进入`ActivityThread`的`scheduleLaunchActivity`方法中，然后通过`Handler`进入`handleLaunchActivity`方法：

```java
private void handleLaunchActivity(ActivityClientRecord r, Intent customIntent){
	// ...
	Activity a = performLaunchActivity(r, customIntent);

	handleResumeActivity(r.token, false, r.isForward, !r.activity.mFinished && !r.startsNotResumed);
	// ...
}
```

先调用`performLaunchActivity`方法返回一个`Activity`，然后调用`handleResumeActivity`方法让该`Activity`进入`onResume`状态。所以很显然在`performLaunchActivity`中肯定是生成了`Activity`实例，并调用了`onCreate`方法了，来看下代码：

```java
private Activity performLaunchActivity(ActivityClientRecord r, Intent customIntent) {
	// ...
	ActivityInfo aInfo = r.activityInfo;
	if (r.packageInfo == null) {
	    r.packageInfo = getPackageInfo(aInfo.applicationInfo, r.compatInfo,
	            Context.CONTEXT_INCLUDE_CODE);
	}
	// ...
	java.lang.ClassLoader cl = r.packageInfo.getClassLoader();
    activity = mInstrumentation.newActivity(cl, component.getClassName(), r.intent);
	// ...
	Context appContext = createBaseContextForActivity(r, activity);
	// ...
	activity.attach(appContext, this, getInstrumentation(), r.token, r.ident, app, r.intent, r.activityInfo, title, r.parent, r.embeddedID, r.lastNonConfigurationInstances, config, r.referrer, r.voiceInteractor);
	// ...
	if (r.isPersistable()) {
     mInstrumentation.callActivityOnCreate(activity, r.state, r.persistentState);
    } else {
        mInstrumentation.callActivityOnCreate(activity, r.state);
    }
	// ...
	mInstrumentation.callActivityOnRestoreInstanceState(activity, r.state, r.persistentState);
	// ...
	mInstrumentation.callActivityOnPostCreate(activity, r.state, r.persistentState);
	// ...
}
```

首先，初始化`LoadedApk`，然后通过`Instrumentation`来创建一个`Activity`实例，通过`createBaseContextForActivity`方法创建一个`Activity Context`，调用`activity`的`attach`方法，然后依次触发该`Activity`的`onCreate`、`onRestoreInstanceState`、`onPostCreate`等生命周期方法。

`createBaseContextForActivity`方法如下：

```java
private Context createBaseContextForActivity(ActivityClientRecord r, final Activity activity) {
	// ...
	ContextImpl appContext = ContextImpl.createActivityContext(this, r.packageInfo, displayId, r.overrideConfig);
    appContext.setOuterContext(activity);
    Context baseContext = appContext;
	// ...
}
```

通过`ContextImpl::createActivityContext`创建的`Context`对象，可以发现，不论是`System Context/App Context/Activity Context`，这些`Context`都是通过`ContextImpl`生成的，具体这里再挖个坑先。

再继续进入`Activity::attach`方法：

```java
final void attach(Context context, ActivityThread aThread,
            Instrumentation instr, IBinder token, int ident,
            Application application, Intent intent, ActivityInfo info,
            CharSequence title, Activity parent, String id,
            NonConfigurationInstances lastNonConfigurationInstances,
            Configuration config, String referrer, IVoiceInteractor voiceInteractor) {
	// ...
	mMainThread = aThread;
    mInstrumentation = instr;
    mToken = token;
    mIdent = ident;
    mApplication = application;
    mIntent = intent;
    mReferrer = referrer;
    mComponent = intent.getComponent();
    mActivityInfo = info;
    mTitle = title;
    mParent = parent;
    mEmbeddedID = id;
    mLastNonConfigurationInstances = lastNonConfigurationInstances;
	// ...
}
```

上面对`Activity`与`ActivityThread`、`Instrumentation`等进行了绑定，所以说每个`Activity`都含有一个`ActivityThread`引用和一个`Instrumentation`引用，而`ActivityThread`实例和`Instrumentation`实例在一个进程中都只有一个实例，因为`ActivityThread`是在进程被创建成功后，进入`ActivityThread`的`static main()`时才会被创建，而`Instrumentation`则是在`ActivityThread`被创建后进行`attach`的之后被创建。

### 启动应用流程所有方法链调用总结：

- `Activity::startActivity`

- `Activity::startActivityForResult`

- `Instrumentation::execStartActivity`：
携带参数：
1\. `who`：from的Context
2\. `contextThread`：from的`ActivityThread`的`ApplicationThread`，`ApplicationThread`中可以通过Binder IPC提供给服务端回调`Activity`生命周期等操作（from的主线程）。
3\. `mToken`：`Binder`类型，用来标识from的Activity，可能为null。
4\. `target`：from的Activity（所以是用来接收跳转结果的），如果不是从Activity跳转则为null。
5\. `intent`：跳转Intent。
6\. `requestCode`：如果是`startActivity`，则为-1。
7\. `options`：额外Bundle数据。

- `ActivityManagerProxy::startActivity()`：
携带参数：
1\. `caller`：上面的`contextThread`，from主线程。
2\. `callingPackage`：from的Context包名。
3\. `intent`：跳转Intent。
4\. `resolvedType`：跳转Intent的MIME类型。
5\. `resultTo`：上面的`token`，`Binder`类型，用来标识from的Activity。
6\. `resultWho`：from的Activity的mEmbeddedID（唯一标示字符串）
7\. `requestCode`：如果是`startActivity`，则为-1。
8\. `startFlags`：默认传入为0。
9\. `profilerInfo`：默认传入为null。
10\. `options`：额外Bundle数据。

- `ActivityManagerService::startActivity()`（通过Binder IPC调用）：
携带参数跟上面一样。

- `ActivityManagerService::startActivityAsUser`
携带参数包括`ActivityManagerService::startActivity()`所有的参数，最再加一个：
1\. `userId`：userId，根据给当前进程分配的Linux UID（这个UID可以用来让上层系统服务进行身份识别和权限检查）得到一个userId（如果不是多用户，则直接返回0）。

- `ActivityStackSupervisor::startActivityMayWait()`
参数：
1\. `caller`：上面的`caller/contextThread`，from主线程。
2\. `callingUid`：调用用户uid。
3\. `callingPackage`：from的Context包名。
4\. `intent`：跳转Intent。
5\. `resolvedType`：跳转Intent的MIME类型。
6\. `voiceSession`：传null。
7\. `voiceInteractor`：传null。
8\. `resultTo`：上面的`resultTo/token`，`Binder`类型，用来标识from的Activity。
9\. `resultWho`：from的Activity的mEmbeddedID（唯一标示字符串）
10\. `requestCode`：如果是`startActivity`，则为-1。
11\. `startFlags`：传null。
12\. `profilerInfo`：传null。
13\. `outResult`：传null。
14\. `config`：传null。
15\. `options`：额外数据。
16\. `ignoreTargetSecurity`：false。
17\. `userId`：上面的`userId`，根据给当前进程分配的Linux UID（这个UID可以用来让上层系统服务进行身份识别和权限检查）得到一个userId（如果不是多用户，则直接返回0）。
18\. `iContainer`：传null。
19\. `inTask`：null。

- `ActivityStackSupervisor::startActivityLocked()`：
参数：
1\. `caller`：上面的`caller/contextThread`，from主线程。
2\. `intent`：跳转Intent。
3\. `resolvedType`：跳转Intent的MIME类型。
4\. `aInfo`：`ActivityInfo`类型，解析from的Activity的Intent信息。
5\. `voiceSession`：传null。
6\. `voiceInteractor`：传null。
7\. `resultTo`：上面的`resultTo/token`，`Binder`类型，用来标识from的Activity。
8\. `resultWho`：from的Activity的mEmbeddedID（唯一标示字符串）
9\. `requestCode`：如果是`startActivity`，则为-1。
10\. `callingPackage`：from的Context包名。
11\. `startFlags`：传null。
12\. `options`：额外数据。
13\. `ignoreTargetSecurity`：false。
14\. `componentSpecified`：是否显示指定了`component`。
15\. `outActivity`：传null。
16\. `container`：上面的`iContainer`，转型成了`ActivityContainer`，还是null。
17\. `inTask`：null。
在这个方法中，通过`ProcessRecord callerApp = mService.getRecordForAppLocked(caller);`获取到之前创建的`ProcessRecord`，然后从`Activity`栈中根据`resultTo/token`获取到对应from Activity的`ActivityRecord`（sourceRecord），然后__创建将要跳转的Activity的ActivityRecord对象__（`Token`也是在这个时候生成的）。

- `ActivityStackSupervisor::startActivityUncheckedLocked()`：
参数：
1\. `r`：`ActivityRecord`类型，就是`ActivityStackSupervisor::startActivityLocked()`中创建的将要跳转的Activity的ActivityRecord对象。
2\. `sourceRecord`：就是`ActivityStackSupervisor::startActivityLocked()`方法获取的from Activity的`sourceRecord`。
3\. `voiceSession`：传null。
4\. `voiceInteractor`：传null。
5\. `startFlags`：传null。
6\. `doResume`：传true。
7\. `options`：额外数据。
8\. `inTask`：null。
这个方法中有大量的代码来处理`task/stack`等方面的逻辑，以后再仔细深入这个方法。

- `ActivityStrack::startActivityLocked()`：
方法调用者：`ActivityStack`类型，
`targetStack`：在`ActivityStackSupervisor::startActivityUncheckedLocked()`中确定的需要添加到的`ActivityStack`。
参数：
1\. `r`：`ActivityRecord`类型，就是`ActivityStackSupervisor::startActivityLocked()`中创建的跳转的Activity的ActivityRecord对象。
2\. `newTask`：是否`Intent`是否设置了`Intent.FLAG_ACTIVITY_NEW_TASK`。
3\. `doResume`：传true。
4\. `keepCurTransition`：这个具体后面再研究，跟`Intent`的flag有关。
5\. `options`：额外数据。
同样，这个方法中有大量的代码来处理`task/stack`等方面的逻辑，以后再仔细深入这个方法__（执行完这个方法后，`ActivityRecord`就会被真正加入到`ActivityStack`中）__。

- `ActivityStackSupervisor::resumeTopActivitiesLocked()`：
参数：
1\. `targetStack`：在`ActivityStackSupervisor::startActivityUncheckedLocked()`中确定的需要添加到的`ActivityStack`。
2\. `target`：`ActivityRecord`类型，就是`ActivityStackSupervisor::startActivityLocked()`中创建的跳转的Activity的ActivityRecord对象。
3\. `targetOptions`：额外数据。

- `ActivityStack::resumeTopActivityLocked()`：
参数：
1\. `prev`：`ActivityRecord`类型，就是`ActivityStackSupervisor::startActivityLocked()`中创建的跳转的Activity的ActivityRecord对象。
2\. `options`：额外数据。

- `ActivityStack::resumeTopActivityInnerLocked()`：
参数：
1\. `prev`：`ActivityRecord`类型，就是`ActivityStackSupervisor::startActivityLocked()`中创建的跳转的Activity的ActivityRecord对象。
2\. `options`：额外数据。

- `ActivityStackSupervisor::startSpecificActivityLocked()`：
参数：
1\. `r`：最顶部没有处于finishing的Activity，就是刚刚在`startActivityLocked`中加入的将要跳转的`ActivityRecord`，通过`topRunningActivityLocked(null)`查找
2\. `andResume`：传true
3\. `checkConfig`：传true

- `ActivityManagerService::startProcessLocked()`：
参数：
1\. `processName`：创建进程的名称，就是`ActivityStack::startSpecificActivityLocked()`中的`r.processName`
2\. `info`：`ApplicationInfo`，也是`r.info.applicaitonInfo`，具体可以查看`ActivityStackSupervisor::startActivityLocked()`中创建`ActivityRecord`的代码。
3\. `knownToBeDead`：传true。
4\. `intentFlags`：传0。
5\. `hostingType`：传字符串“activity”。
6\. `hostingName`：`ComponentName`类型，`intent`中的`Componentname`
7\. `allowWhileBooting`：传false。
8\. `isolated`：传false
9\. `keepIfLarge`传true

- `ActivityManagerService::startProcessLocked()`（重载方法）：
参数包含上面所有，多了以下几个：
1\. `isolatedUid`：传0
2\. `abiOverride`：传null
3\. `entryPoint`：传null
4\. `entryPointArgs`传null
5\. `crashHandler`传null
注意：在这个方法中，会创建新进程的`ProcessRecord`对象，并绑定`ApplicationInfo`等信息，这样，启动进程后进行`bindApplicaiton`的时候就可以根据进程PID获取到所有的`ApplicationInfo`信息了。

- `ActivityManagerService::startProcessLocked()`（重载方法）：
参数：
1\. `app`：`ProcessRecord`类型，创建的进程。
2\. `hostingType`：传字符串“activity”。
3\. `hostingNameStr`：通过`hostingName`生成的字符串（包名 + "/" + 类的简单类名）
4\. `abiOverride`：传null
5\. `entryPoint`：传null
6\. `entryPointArgs`传null

- `Process.start()`
参数（省略部分参数）：
1\. `processClass`：上面的`entryPoint`，但是并不是null了，而是`android.app.ActivityThread`，因为在`ActivityManagerService::startProcessLocked()`中被设置默认值了，它表示一个类，用来作为新创建的进程的主入口，会调用这个类的静态main方法。所以启动完这个进程就会进入`ActivityThread`的`static main()`方法。
2\. `zygoteArgs`：fork zygote进程时的参数。

- `ActivityThread::main()`

- `ActivityThread::attach()`

- `ActivityManagerProxy::attachApplication()`：
参数：
1\. `mAppThread`：`ApplicationThread()`类型，Binder，用来提供给AMS调用。

- `ActivityManagerService::attachApplication()`：
参数：
1\. `mAppThread`：`ApplicationThread()`类型，Binder，用来提供给AMS调用。

- `ActivityManagerService::attachApplicationLocked()`：
参数：
1\. `thread`：`ApplicationThread()`类型，Binder，用来提供给AMS调用。上面的`mAppThread`。
2\. `pid`：当前调用的进程PID。

- `IApplicationThread::bindApplication()`：
方法调用调用者：上面的`thread/mAppThread`，Binder，用来提供给AMS调用。
参数（省略部分参数）：
1\. `packageName`：用的进程名字`processName`
2\. `info`：`ApplicationInfo`类型，从`ProcessRecord`中的`instrumentationInfo或者info`，这个`ApplicationInfo`是在建立`ProcessRecord`时就保存了。

- `ActivityThread::bindApplication()`：
参数：同上

- `ActivityThread::handleBindApplication()`：
通过Handler调用。
参数：
1\. `data`：`AppBindData`类型，里面包含的类型`processName`，`providers`，`instrumentationName`，`instrumentationArgs`，`instrumentationWatcher`，`instrumentationUiAutomationConnection`，`config`等数据。

- `ActivityManagerService`中的`ActivityThread::bindApplication()`执行完毕之后

- `ActivityStackSupervisor::attachApplicationLocked()`：
参数：
1\. `app`：新建的进程绑定的`ProcessRecord`。

- `ActivityStackSupervisor::realStartActivityLocked()`：
参数：
1\. `r`：`ActivityRecord`类型，topRunningActivityLocked从堆栈顶端获取要启动的Activity。
2\. `app`：新建的进程绑定的`ProcessRecord`。
3\. `andResume`：传入true
4\. `checkConfig`：传入true

- `IApplicationThread::scheduleLaunchActivity()`：
参数（部分）：
1\. `intent`：将要启动的`ActivityRecord`中的`intent`。
2\. `token`：将要启动的`ActivityRecord`中的`token`。
3\. `info`：将要启动的`ActivityRecord`中的`ApplicationInfo`。

- `ActivityThread::scheduleLaunchActivity()`：
Binder IPC调用，参数与`IApplicationThread::scheduleLaunchActivity()`相同。

- `ActivityThread::handleLaunchActivity()`：
该方法通过Handler调用，参数同上。
1\. `r`：`ActivityClientRecord`类型，在`ActivityThread::scheduleLaunchActivity()`中封装，包括的数据有`token`, `ident`, `intent`, `activityInfo`等等，但是`LoadedApk`是这时根据包名从`ActivityThread`中弱引用缓存中获取的的。
2\. `customIntent`：null

- `ActivityThread::performLaunchActivity()`：
参数与`ActivityThread::handleLaunchActivity()`相同。

- `Activity::attach()`：
参数（部分）：
1\. `context`：`ActivityThread::performLaunchActivity()`中创建的`Activity Context`。
2\. `aThread`：`ActivityThread`类型，主线程，一个进程都共用一个。
3\. `token`：构建`ActivityRecord`时生成的`token`。
4\. `application`：`Application`第一次的时候创建一遍。
5\. `intent`：将要启动的ActivityRecord中的intent。
6\. `info`：`ActivityInfo`类型，将要启动的ActivityRecord中的`ActivityInfo`。

- `Instrumentation::callActivityOnCreate()`：
参数（部分）：
1\. `activity`：`ActivityThread::performLaunchActivity()`中创建的`Activity`。

- `Activity::performCreate()`

- `Activity::onCreate()`