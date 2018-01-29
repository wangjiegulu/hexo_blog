---
title: '[Android]官网《Testing Support Library》中文翻译'
tags: []
date: 2015-12-15 15:44:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5048524.html>
**</font>

翻译自 Android Developer 官网：<http://developer.android.com/tools/testing-support-library/index.html>

# Testing Support Library

`Android Testing Support Library`为Android app的测试提供了一个广泛的框架。 这个库提供了一系列的API可以让你快速build和run你app的代码，它包括了`JUnit 4`和功能性的用户界面（UI）测试。你可以通过[Android Studio IDE](http://developer.android.com/tools/studio/index.html)或者命令行的方式运行你使用这些API创建的测试。

`Android Testing Support Library`已经可以通过`Android SDK Manager`下载使用了。详情可见[Testing Support Library Setup](http://developer.android.com/tools/testing-support-library/index.html#setup)

这页中会提供一些关于`Android Testing Support Library`中所提供的工具的信息，怎样在你的测试环境中使用它们，还有库发布的相关信息。

## Testing Support Library的特性

`Android Testing Support Library`提供包括了以下自动化测试工具：

- [AndroidJUnitRunner]：兼容Android的JUnit 4。

- [Espresso]：UI测试框架，适用于app内的功能性UI测试。

- [UI Automator]：UI测试框架，适用于系统和安装app间跨app的功能性UI测试。

### AndroidJUnitRunner

[AndroidJUnitRunner] 类是一个 [JUnit] 测试runner，它可以让你在Android设备上运行`JUnit 3`或者`JUnit 4-style`的测试类，包括使用了 [Espresso] 和 [UI Automator] 测试框架的。`test runner`处理的事情有 加载你的测试package和需要在设备上测试的app，运行你的测试，还有报告测试结果。这个类会替换掉只支持`JUnit 3`测试的[InstrumentationTestRunner](http://developer.android.com/reference/android/test/InstrumentationTestRunner.html)类。

这个`test runner`的关键特性包括：

- [JUnit的支持](http://developer.android.com/tools/testing-support-library/index.html#ajur-junit)

- [访问instrumentation信息](http://developer.android.com/tools/testing-support-library/index.html#ajur-instrumentation)

- [测试过滤](http://developer.android.com/tools/testing-support-library/index.html#ajur-filtering)

- [测试拆分](http://developer.android.com/tools/testing-support-library/index.html#ajur-sharding)

需要 Android2.2(API level 8) 或者更高。

#### JUnit的支持

`Rest runner`兼容`JUnit 3`和`JUnit 4`（最高到`JUnit 4.10`）的测试。不管怎样，你应该避免在一个package中混合使用JUnit 3和 JUnit 4的代码，因为这样做可能会引发一些预料之外的问题。如果你创建了一个JUnit 4的测试类在设备或者模拟器上运行时，你的测试类必须要加上`@RunWith(AndroidJUnit4.class)`注解作为前缀。

下面的代码片段展示了你应该怎么去编写一个JUnit 4测试来验证`CalculatorActivity`类中的`add`操作是正确执行的。

```java
import android.support.test.runner.AndroidJUnit4;
import android.support.test.runner.AndroidJUnitRunner;
import android.test.ActivityInstrumentationTestCase2;

@RunWith(AndroidJUnit4.class)
public class CalculatorInstrumentationTest
        extends ActivityInstrumentationTestCase2<CalculatorActivity> {

    @Before
    public void setUp() throws Exception {
        super.setUp();

        // 当你使用`AndroidJUnitRunner`运行测试时，
        // 注入Instrumentation实例是必要的。
        injectInstrumentation(InstrumentationRegistry.getInstrumentation());
        mActivity = getActivity();
    }

    @Test
    public void typeOperandsAndPerformAddOperation() {
        // 调用CalculatorActivity add()方法并传入一些操作数据，
        // 然后检查返回值是否是期望值
    }

    @After
    public void tearDown() throws Exception {
        super.tearDown();
    }
}
```

#### 访问instrumentation信息

你可以使用 [`InstrumentationRegistry`](http://developer.android.com/reference/android/support/test/InstrumentationRegistry.html) 类来访问你测试的app的相关信息。这个类包含一个 [`Instrumentation`] 对象，目标app的 [`Context`] 对象，还有你通过命令行传入到该测试的参数。这个数据在你使用UI Automator框架编写测试或者编写一些依赖 [`Instrumentation`] 或者 [`Context`] 对象的测试的时候是很有用的。

#### 测试过滤

在你的 JUnit 4 测试中， 你可以使用注解来配置你的测试的运行。这会最大限度地减少你测试中需要的模版代码和有条件的代码。除了 JUnit 4 支持的标准注解，`test runner`也支持一些针对Android的特殊的注解，包括：

- [`@RequiresDevice`](http://developer.android.com/reference/android/support/test/filters/RequiresDevice.html)：指明这个测试只能运行的物理设备上面，而不是模拟器上面。

- [`@SdkSupress`](http://developer.android.com/reference/android/support/test/filters/SdkSuppress.html)：限制这个测试运行在低于给定的Android API level。举个例子，限制测试运行在API level低于18的环境下，使用注解 `@SDKSupress(minSdkVersion=18)`。

- [`@SmallTest`](http://developer.android.com/reference/android/test/suitebuilder/annotation/SmallTest.html)，[`@MediumTest`](http://developer.android.com/reference/android/test/suitebuilder/annotation/MediumTest.html)，和[`@LargeTest`](http://developer.android.com/reference/android/test/suitebuilder/annotation/LargeTest.html)：对测试需要的时间运行来分类，因此，可以决定是否可以经常运行该测试。

#### 测试拆分

`Test runner` 支持把一个测试套件分割成多个碎片，所以你可以很简单地运行属于通过碎片分组的所有测试，并且它们使用同一个 [`Instrumentation`] 实例。每一个碎片都有一个索引编号（index number）作为它的唯一识别。当运行测试时，使用 `-e numShards` 选项来指定要创建的碎片的数量和 `-e shardIndex` 选项来指定哪些碎片运行。

举个例子，把一个测试套件分割成10个碎片，并且只运行被分组的测试中的第二个碎片，使用以下的命令：

```
adb shell am instrument -w -e numShards 10 -e shardIndex 2
```

这个 `test runner` 的更多相关学习，见 [API reference](http://developer.android.com/reference/android/support/test/package-summary.html)。

### Espresso

Espresso 测试框架提供了一系列的API用于构建UI测试来测试app内用户流操作。这些API让你可以编写简洁可靠的自动化UI测试。__Espresso非常适合用来编写白盒测试__，其中测试代码的编写是利用了被测试app中程序代码实现细节。

Espresso测试框架的关键特性包括：

- 提供了灵活的API用于匹配目标app中`view`和`adapter`。更多的信息，见 [View 匹配](http://developer.android.com/tools/testing-support-library/index.html#espresso-matching)

- 大而全的 `行为 api`（action APIs） 用于自动化UI交互。更多的信息，见 [行为 APIs](http://developer.android.com/tools/testing-support-library/index.html#espresso-actions)

- UI线程同步来提高测试可靠性。更多信息，见 [UI 线程同步](http://developer.android.com/tools/testing-support-library/index.html#espresso-thread-sync)

需要 Android2.2(API level 8) 或者更高。

#### View 匹配

[`Espresso.onView()`](http://developer.android.com/reference/android/support/test/espresso/Espresso.html#onView) 方法可以让你访问目标app中的一个UI组件并与它交互。这个方法接收一个 [`Matcher`](http://hamcrest.org/JavaHamcrest/javadoc/1.3/org/hamcrest/Matcher.html) 作为参数，然后根据我们给定的条件在view的层次结构中搜索出对应相符的[`View`](http://developer.android.com/reference/android/view/View.html)实例。你可以使用如下的条件来优化你的搜索结果：

- View的类名
- View内容的描述（`content description`）
- View的`R.id`
- View显示的文本

举个例子，寻找一个ID为`my_button`的目标button，你可以如以下一样指定一个matcher：

```java
onView(withId(R.id.my_button));
```

如果搜索是成功的，[`onView()`] 方法会返回一个可以让你执行用户行为和测试目标中对view断言的引用。

#### Adapter 匹配

在一个 [`AdapterView`] 的布局中，布局是在运行时根据children动态填充的。如果目标view是在 [`AdapterView`] 子类（比如[`ListView`](http://developer.android.com/reference/android/widget/ListView.html) 或者 [`GridView`](http://developer.android.com/reference/android/widget/GridView.html)）的布局中的，[`onView()`] 方法可能就不起作用了，因为当前加载的view层次结构可能只是layout的一个子集。

替代方案是使用 [`Espresso.onData()`] 方法去访问一个目标view元素。[`Espresso.onData()`] 方法返回一个可以让你执行用户行为和测试目标 [`AdapterView`] 中对元素断言的引用。

#### 行为 APIs

典型的，你可以通过对app的用户界面执行一些用户交互来测试app。在你的测试中使用 [`ViewActions`](http://developer.android.com/reference/android/support/test/espresso/action/ViewActions.html) API 可以让你很容易地自动化这些行为。你可以通过以下方式执行这些UI交互：

- View的点击

- 滑动

- 按键和按钮的按下

- 输入文本

- 打开一个链接

举个例子，模拟输入一个字符串数据并按下按钮来提交这个值，你可以像这样编写一个自动化测试脚本。 [`ViewInteraction.preform()`](http://developer.android.com/reference/android/support/test/espresso/ViewInteraction.html#perform(android.support.test.espresso.ViewAction...)) 和 [`DataInteraction.perform()`](http://developer.android.com/reference/android/support/test/espresso/DataInteraction.html#perform(android.support.test.espresso.ViewAction...)) 方法接收一个或者多个[`ViewAction`](http://developer.android.com/reference/android/support/test/espresso/ViewAction.html) 参数并且按照提供的顺序执行这些`actions`。

```java
// 在一个EditText中输入文本信息，然后关闭软键盘
onView(withId(R.id.editTextUserInput))
    .perform(typeText(STRING_TO_BE_TYPED), closeSoftKeyboard());

// 按下按钮来提交改变的文本
onView(withId(R.id.changeTextBt)).perform(click());
```

#### UI线程同步

在Android设备上测试可能由于时间的关系会随机性地失败。这个测试问题称为test flakiness（测试片状）。在Espresso之前，变通的办法是在测试中插入足够长的睡眠或者一段时间后超时，或者增加在操作失败之后保持重试的代码。Espresso测试框架会在[`Instrumentation`]和UI线程之间保持同步；这样就可以去掉之前因为时间问题使用的变通的方法，并且确保你测试的行为和断言运行更加可靠。

更多Espresso的相关学习，见 [API reference](http://developer.android.com/reference/android/support/test/package-summary.html) 和 [针对单个App的UI测试](http://developer.android.com/training/testing/ui-testing/espresso-testing.html) 练习。

### UI Automator

UI Automator测试框架提供了一系列的API来构建在用户app和系统app之间的UI测试。UI Automator APIs  允许你在测试设备中执行例如打开设置菜单或者launcher等操作。__UI Automator 测试框架非常适合用来写黑盒测试__，其中测试代码的编写不需要依赖于目标app的内部实现细节。

UI Automator测试框架的关键特性包括：

- 检查layout层次结构的Viewer。更多信息，见 [`UI Automator Viewer`](http://developer.android.com/tools/testing-support-library/index.html#uia-viewer)。

- 一个用于在目标设备上获取状态信息和执行操作的API。更多信息，见 [`访问设备状态`](http://developer.android.com/tools/testing-support-library/index.html#uia-device-state)

- 跨app的UI测试APIs。更多信息，见 [`UI automator APIS`](http://developer.android.com/tools/testing-support-library/index.html#uia-apis)

需要 Android4.3(API level 18) 或者更高。

#### UI Automator Viewer

`uiautomatorviewer` 工具提供了一个方便的GUI来扫描和分析当前在Android设备上显示的UI组件。你可以使用这些工具来检查layout层次结构和查看在设备前台可见的组件的属性。这个信息可以让你使用UI Automator创建更加细粒度的测试，比如创建一个匹配指定的可见性属性的UI选择器。

`uiautomatorviewer` 工具在 `<android-sdk>/tools/` 目录下。

#### 访问设备状态

UI Automator测试框架提供了一个 [`UIDevice`] 类在目标app运行的设备上访问和执行操作。你可以调用它的方法来访问如当前的设备定向活着显示尺寸等设备属性。 [`UIDevice`] 类也可以让你执行一些如下的行为：

- 旋转设备

- 按下 `D-pad` 键

- 按下返回键、Home键、菜单键

- 打开通知栏

- 当前的窗口截图

举个例子，模拟按下Home按钮，调用 `UiDevice.pressHome()` 方法。

#### UI Automator APIs

UI Automator APIs 允许你在不需要知道目标app实现细节的情况下去编写强大的测试。你可以使用这些APIs来捕获和操作跨越多个app的UI组件：

- [`UiCollection`](http://developer.android.com/reference/android/support/test/uiautomator/UiCollection.html)：枚举容器中的UI元素来计数，或者通过子元素的可见text或`content-description`属性来作为一个目标。

- [`UiObject`](http://developer.android.com/reference/android/support/test/uiautomator/UiObject.html)：代表在设备上一个可见的UI元素。

- [`UiScrollable`](http://developer.android.com/reference/android/support/test/uiautomator/UiScrollable.html)：对可滚动的UI容器中搜索UI元素提供支持。

- [`UiSelector`](http://developer.android.com/reference/android/support/test/uiautomator/UiSelector.html)：代表一个设备上对一个或者多个目标UI元素的查询。

- [`Configurator`](http://developer.android.com/reference/android/support/test/uiautomator/Configurator.html)：允许你设置UI Automator测试的关键参数。

举个例子，下面的代码展示了怎么样去编写一个测试脚本来获取默认的app launcher：

```java
// 初始化 UiDevice 实例
mDevice = UiDevice.getInstance(getInstrumentation());

// 在 HOME 按钮上执行一个短暂的按压
mDevice().pressHome();

// 通过匹配启动按钮的content-description来搜索一个UI组件
// 得到默认的launcher
UiObject allAppsButton = mDevice
        .findObject(new UiSelector().description("Apps"));

// 在得到的launcher 按钮上面执行一个点击
allAppsButton.clickAndWaitForNewWindow();
```

更多UI Automator相关学习，见 [API reference](http://developer.android.com/reference/android/support/test/package-summary.html) 和 [多App的UI测试](http://developer.android.com/training/testing/ui-testing/uiautomator-testing.html) 练习。

## Testing Support Library Setup

Android Testing Support Library package已经包含在最新版本的作为补充库、可在SDK Manager中下载的Android Support Repository中。

通过SDK Manager下载Android Support Repository：

1\. 启动 [Android SDK Manager](http://developer.android.com/tools/help/sdk-manager.html)。

2\. 在SDK Manager窗口，滚动到Packages列表的最底部，找到`Extras`目录，如果需要，把它展开显示它的内容。

3\. 找到 __Android Support Repository__ 项。

4\. 点击 __Install packages...__ 按钮。

下载完之后，工具把Support Repository文件安装在存在的Android SDK目录。库文件会被放置在你SDK目录的子目录中：`<sdk>/extras/android/m2respository` 目录。

Android Testing Support Library 类被放置在`android.support.test`包下面。

为了在你的Gradle项目中使用Android Testing Support Library，在你的`build.gradle`文件中增加如下依赖：

```groovy
dependencies {
  androidTestCompile 'com.android.support.test:runner:0.4'
  // Set this dependency to use JUnit 4 rules
  androidTestCompile 'com.android.support.test:rules:0.4'
  // Set this dependency to build and run Espresso tests
  androidTestCompile 'com.android.support.test.espresso:espresso-core:2.2.1'
  // Set this dependency to build and run UI Automator tests
  androidTestCompile 'com.android.support.test.uiautomator:uiautomator-v18:2.1.2'
}
```

为了在你的Gradle项目中默认使用[AndroidJUnitRunner]作为默认的instrumentation runner，在你的`build.gradle`文件中指定这个依赖：

```groovy
android {
    defaultConfig {
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
    }
}
```

强烈推荐你与Android Studio IDE一起使用Android Testing Support Library。Android Studio提供了支持测试开发的功能，比如：

- 灵活并基于Gradle构建系统，支持对你测试代码的依赖管理。

- 单元和instrumented测试代码与你的app的源代码放置在单个项目结构中。

- 支持从命令行或者GUI来部署和运行你的测试在虚拟或者物理设备中。

更多Android Studio相关和下载，见 [下载Android Studio和SDK Tools](http://developer.android.com/sdk/index.html)。

[AndroidJUnitRunner]: http://developer.android.com/reference/android/support/test/runner/AndroidJUnitRunner.html
[Espresso]: http://developer.android.com/tools/testing-support-library/index.html#Espresso
[UI Automator]: http://developer.android.com/tools/testing-support-library/index.html#UIAutomator
[JUnit]: http://junit.org/
[`Instrumentation`]: http://developer.android.com/reference/android/app/Instrumentation.html
[`Context`]: http://developer.android.com/reference/android/content/Context.html
[`AdapterView`]: http://developer.android.com/reference/android/widget/AdapterView.html
[`onView()`]: http://developer.android.com/reference/android/support/test/espresso/Espresso.html#onView
[`Espresso.onData()`]: http://developer.android.com/reference/android/support/test/espresso/Espresso.html#onData)
[`UIDevice`]: http://developer.android.com/reference/android/support/test/uiautomator/UiDevice.html