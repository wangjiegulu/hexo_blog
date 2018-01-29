---
title: '[Android]官网《monkeyrunner》中文翻译'
tags: []
date: 2015-12-16 12:20:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5050768.html>
**</font>

翻译自 Android Developer 官网：<http://developer.android.com/tools/help/monkeyrunner_concepts.html>

# monkeyrunner

monkeyrunner工具提供了一套API，在不通过Android代码的情况下编写程序来控制一个Android设备或者模拟器。使用monkeyrunner，你可以编写一个`Python`程序来安装一个Android应用程序或者测试包，运行它，给它发送按键，使用它的interface来创建一个截图，并保存在工作站上。monkeytunner工具主要是被设计用来在功能/框架级别测试应用程序和设备，并运行单元测试套件，但是你也可以使用它来达到其它的目的。

Monkeyrunner工具与也被称为`monkey`的[UI/Application Exerciser Monkey](http://developer.android.com/tools/help/monkey.html)没有任何关系。`Monkey`工具是直接在`adb` shell中运行，通过在设备或者模拟器中产生伪随机流的用户和系统事件的方式。比较之下，monkeyrunner工具在一个工作站中通过API发送指定的命令和事件来控制设备和模拟器。

monkeyrunner工具提供了以下这些在Android测试中独一无二的特性：

- 多设备控制：monkeyrunner可以应用在一个或者多个测试套件跨越多个设备和模拟器。你可以在物理层面上一次性attach所有的设备或者启动所有的模拟器（或者两者都有），按照程序依次连接上每一个，然后运行一个或者多个测试。

- 功能性测试：monkeyrunner可以运行从头至尾全自动化地测试Android应用程序。由你提供输入的按键或者触摸事件，并且查看结果截图。

- 回归测试：monkeyrunner可以通过运行一个应用程序并且把它输出的结果截图与已知正确的截图比较的方式测试应用程序的稳定性。

- 可扩展的自动化：因为monkeyrunner是一套API工具包，你可以基于`Python`模块和程序的开发一个完整的系统来控制Android设备。除了使用monkeyrunner自己的API，你可以使用标准的Python `os`和`subprocess`模块来调用 [Android Debug Bridge](http://developer.android.com/tools/help/adb.html) 等Android工具。你也可以为monkeyrunner API增加自己的类。这个我们会在 [Extending monkeyrunner with plugins](http://developer.android.com/tools/help/monkeyrunner_concepts.html#Plugins) 栏中讨论到更多的细节。

monkeyrunner工具使用了[Jython](http://www.jython.org/)，一个使用Java编程语言的Python实现。Jython允许monkeyrunner API很容易地与Android framework交互。使用Jython，你可以使用Python语法去访问API常量、类和方法。

## 一个简单的monkeyrunner程序

这里有一个简单的monkeyrunner程序，它可以连接到一个设备，创建一个 [`MonkeyDevice`](http://developer.android.com/tools/help/MonkeyDevice.html) 对象。程序中使用 `MonkeyDevice` 对象安装一个Android应用程序，运行它其中的一个Activity，并且发送一个按键的事件给这个Activity。然后程序把结果截图，创建了一个 [`MonkeyImage`](http://developer.android.com/tools/help/MonkeyImage.html) 对象。通过这个对象，程序把截图输出到一个`.png`文件中。

```python
# Import 程序所有使用到的monkeyrunner模块
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice

# 连接当前的设备，返回一个MonkeyDevice对象
device = MonkeyRunner.waitForConnection()

# 安装Android应用。注意这个方法返回一个boolean，所以你需要检查是否安装成功
device.installPackage('myproject/bin/MyApplication.apk')

# 把安装文件的内部包名设置到一个变量中
package = 'com.example.android.myapplication'

# 把Activity的完整类名设置到一个变量中
activity = 'com.example.android.myapplication.MainActivity'

# 设置要启动的component名字
runComponent = package + '/' + activity

# 运行该component
device.startActivity(component=runComponent)

# 按下菜单按钮
device.press('KEYCODE_MENU', MonkeyDevice.DOWN_AND_UP)

# 截图
result = device.takeSnapshot()

# 把截图写入到一个文件中
result.writeToFile('myproject/shot1.png','png')
```

## The monkeyrunner API

monkeyrunner的API处于`com.android.monkeyrunner`中，包括三个模块：

- [`MonkeyRunner`](http://developer.android.com/tools/help/MonkeyRunner.html)：一个包含monkeyrunner程序实用方法的类。这个类提供了一个方法用来把monkeyrunner连接到一个设备或者模拟器。它也提供了方法为monkeyrunner程序创建UI，还有显示内置的help界面。

- [`MonkeyDevice`](http://developer.android.com/tools/help/MonkeyDevice.html)：代表一个设备或者模拟器。这个类提供了一些方法用于安装和卸载应用、启动一个Activity、发送键盘活着触摸事件到一个应用。你也可以使用这个类来运行一个测试应用。

- [`MonkeyImage`](http://developer.android.com/tools/help/MonkeyImage.html)：代表一个屏幕截图图片。这个类提供了一些方法用于截图、把bitmap图片转换成各种格式，对比两个MonkeyImage对象、还有把图片写入到文件中。

在一个Python程序中，你可以像一个Python模块一样访问每一个类。monkeyrunner工具不会自动帮你import这些模块。import模块的方式是使用Python的`from`语句：

```python
from com.android.monkeyrunner import <module>
```

`<module>`就是你希望import的类名。你可以使用同一个的`from`语句通过逗号分隔的方式import多个模块。

## 运行monkeyrunner

你可以从一个文件中运行monkeyrunner程序，也可以在交互会话模式中输入monkeyrunner语句来运行。两者都需要通过调用`monkeyrunner`命令进行，你可以在SDK目录下的`tools/`子目录下可以找到这些命令。如果你提供了一个文件名作为草书，monkeyrunner命令会把这个文件中的内容作为Python程序来运行，否则，它就是以交互会话的方式运行。

monkeyrunner命令的语法如下：

```
monkeyrunner -plugin <plugin_jar> <program_filename> <program_options>
```

表1解释了flags和参数。

__Table 1__. `monkeyrunner` flags和参数。

|参数|描述|
|---|---|
|`-plugin <plugin_jar>`|（可选）指定一个`.jar`文件作为monkeyrunner的插件。更多monkeyrunner插件学习，见[使用插件扩展monkeyrunner](http://developer.android.com/tools/help/monkeyrunner_concepts.html#Plugins)。要指定多个文件，那就多次使用这个参数。
|`<program_filename>`|如果你提供了这个参数，`monkeyrunner`命令就会把这个文件中的内容作为Python程序运行。如果该参数没有被提供，则它就是以交互会话的方式运行。
|`<program_options>`|（可选）<program_file>中该程序的flags和参数。

## monkeyrunner内置的Help

你可以通过以下命令生成monkeyrunner的API reference：

```
monkeyrunner help.py <format> <outfile>
```

参数是：

- `<format>`：`text`表示纯文本输出，或者`html`表示HTML输出。

- `<outfile>`：输出文件的路径。

## 使用插件扩展monkeyrunner

你可以使用Java编程语言编写你的类并构建到一个或者多个`.jar`中来扩展monkeyrunner的API。你可以使用这个特性通过使用你自己的类或者继承已有的类来扩展monkeyrunner API。你也可以使用这个特性来初始化monkeyrunner环境。

要提供一个插件给monkeyrunner，就要调用在`monkeyrunner`命令的时候加上[表1](http://developer.android.com/tools/help/monkeyrunner_concepts.html#table1)中所描述的`-plugin <plugin_jar>`参数。

在你的插件代码中，你可以import和继承monkeyrunner在`com.android.monkeyrunner`中的主要类`MonkeyDevice`、`MonkeyImage`、和`MonkeyRunner`（见[The monkeyrunner API](http://developer.android.com/tools/help/monkeyrunner_concepts.html#APIClasses)）。

注意插件不能让你去访问Android SDK。你不能import像`com.android.app`类似的包。因为monkeyrunner是在framework APIs之外与设备或者模拟器交互的。

### 插件启动类

`.jar`插件文件可以指定一个类会在脚本运行之前被初始化。要指定这个类，就要在`.jar`文件的manifest中增加一个`MonkeyRunnerStartupRunner`属性。它的值应该就是启动时要运行的类的名字。这面这个片段展示了你怎么在`ant` build脚本中去设置：

```xml
<jar jarfile="myplugin" basedir="${build.dir}">
<manifest>
<attribute name="MonkeyRunnerStartupRunner" value="com.myapp.myplugin"/>
</manifest>
</jar>
```

要去访问monkeyrunner的运行时环境，启动类可以实现`com.google.common.base.Predicate<PythonInterpreter>`接口。举个例子，这个类在默认的命名空间中设置了一些变量：

```java
package com.android.example;

import com.google.common.base.Predicate;
import org.python.util.PythonInterpreter;

public class Main implements Predicate<PythonInterpreter> {
    @Override
    public boolean apply(PythonInterpreter anInterpreter) {

        /*
        * 一个例子使用来在monkeyrunner环境的命名空间中初始化一些变量。
        * 在执行期间，monkeyrunner程序可以使用“newtest”和“use_emulator”这些变量
        *
        */
        anInterpreter.set("newtest", "enabled");
        anInterpreter.set("use_emulator", 1);

        return true;
    }
}
```