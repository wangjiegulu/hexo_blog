---
title: 编写第一个Flutter App（翻译）
subtitle: "Google工程师开发的针对iOS和Android的高性能跨平台框架"
tags: ["flutter", "android", "ios", "dart", "widget", "fuchsia", "Google", "codelab", "翻译"]
categories: ["flutter", "dart"]
cdn: "header-off"
header-img: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=e5a31d03ddee66863a599421f792e07b&auto=format&fit=crop&w=800&q=60"
---

**以下代码 Github 地址：<https://github.com/wangjiegulu/flutter_test_01>**


# 编写你的第一个Flutter App

> 原文：<https://flutter.io/get-started/codelab/>

这个你创建第一个Flutter app的指南。如果你熟悉面向对象的代码，基本的编程概念，比如变量，循环，和条件，你就可以完成本教程。你不需要之前有Dart或者手机的编程经验。

- [第1步：创建启动 Flutter app](#step-1-create-the-starting-flutter-app)
- [第2步：使用外部包](#step-2-use-an-external-package)
- [第3步：增加一个 Stateful widget](#step-3-add-a-stateful-widget)
- [第4步：创建一个无限滚动的 ListView](#step-4-create-an-infinite-scrolling-listview)
- [第5步：增加交互](#step-5-add-interactivity)
- [第6步：导航到一个新的页面](#step-6-navigate-to-a-new-screen)
- [第7步：使用 Theme 来改变 UI](#step-7-change-the-ui-using-themes)
- [干得不错！](#well-done)

**你将构建什么**

你将要实现一个简单的手机 app，为一个初创公司去生成一些推荐的名字。用户可以选择和取消选择这些名字，并保存最好的一些名字。代码一次生成10个名字。当用户滚动时，新的一批名字就会被生成。用户可以点击 app bar 右上角的按钮进入一个新的页面来仅展示被喜欢的名字。

Gif 动图展示了 app 完成之后的运行效果。

<div style='text-align: center;'>
<img src='https://flutter.io/get-started/codelab/images/startup-namer-app.gif' />
</div>

**你将学到什么**

- Flutter app 的基础结构。
- 查询和使用包来扩展特性。
- 使用热重载来实现快速的开发周期。
- 怎么去实现一个 stateful widget 。
- 怎么去创建一个无限，懒加载的列表。
- 怎么去创建和导航到第二个页面。
- 怎么去使用 Theme 来改变 app 的外观。

**你将使用什么**

- Flutter SDK：Flutter SDK 包括 Flutter 的引擎，framework， widget ，工具和 Dart SDK。这个 codelab 需要 v0.1.4 或者更新。
- Android Studio IDE：这个 codelab 具备 Android Studio IDE，但是你也可以使用其它的 IDE，或者使用命令行工作。
- 你的 IDE 插件：你的 IDE 上面必须分别安装 Flutter 和 Dart 插件。除了 Android Studio，Flutter 和 Dart 插件在 [VS Code](https://code.visualstudio.com/download) 和 [IntelliJ](https://www.jetbrains.com/idea/download/#section=mac) IDE。

关于怎么搭建你的环境，可以在 [](https://flutter.io/get-started/install/) 查看更多信息。

<span id='step-1-create-the-starting-flutter-app'/>
## 第1步：创建启动 Flutter app

根据 [开始你的第一个 Flutter app](https://flutter.io/get-started/test-drive/#create-app) 的介绍，创建一个简单，模版的 Flutter app。给项目取名为 **startup_namer** (替换掉 *myapp*)。您将修改这个 app 来创建完成的 app。

在这个 codelab 中，你主要编辑 dart 代码存放处的 **lib/main.dart**。

> **提示：**当复制代码到你的 app 中，缩进可能会歪斜。你可以使用 Flutter 工具来自动修正它们：
> - Android Studio / IntelliJ IDEA: 在 dart 代码上右键并选择 **Reformat Code with dartfmt**。
> - VS Code: 右键并选择 **Format Document**。
> - Ternimal: 运行 flutter format <filename>。

1. 替换 lib/main.dart。
 
    删除 **lib/main.dart** 中的所有代码。使用下面的代码进行替换，它会在屏幕的中央展示 "Hello World"。
 
    ```dart
    import 'package:flutter/material.dart';
    
    void main() => runApp(new MyApp());
    
    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return new MaterialApp(
          title: 'Welcome to Flutter',
          home: new Scaffold(
            appBar: new AppBar(
              title: new Text('Welcome to Flutter'),
            ),
            body: new Center(
              child: new Text('Hello World'),
            ),
          ),
        );
      }
    }
    ```

2. 运行App，你将会看到如下的屏幕

<div style='text-align: center;'>
<img src='https://flutter.io/get-started/codelab/images/hello-world-screenshot.png' />
</div>

### 观察

- 这个例子创建了一个 Material app。[Material](https://material.io/guidelines/) 是手机和 web 上的标准的设计语言。Flutter 提供了丰富的 Material   widget 。
- main 方法制定了一个宽箭头（`=>`）标志，这是一行函数或者方法的简写。
- App 继承了 StatelessWidget，这使得 app 本身称为了一个 widget。在 Flutter 中，几乎所有一切都是 widget，包括 alignment, padding, 和 layout。
- Material 库中的 Scaffold，提供了一个默认的 app bar，title，和一个 body 属性，它持有了主页面的 widget 树。widget 的子树可能相当复杂。
- Widget 的主要的工作是提供一个 `build()` 方法，它描述了如何根据其他较低级别的 widget 显示 widget。
- 这个例子中的 widget 树的构成是一个中心的 widget 包含了一个文本的子 child widget。中心 widget 将它的 widget 子树对齐到屏幕的中心。

---

<span id='step-2-use-an-external-package'/>
## 第2步：使用外部包

在这一步，我将使用一个名为 **english_words** 的开源包，它包含了几千个最常用的英文单词和常用的工具方法。

在 [pub.dartlang.org](https://pub.dartlang.org/flutter/)，你可以找到 [english_words](https://pub.dartlang.org/packages/english_words)，以及很多其它的开源包。

1. pubspec 文件为 Flutter app 管理 assets。在 **pubspec.yaml**，增加 **english_words** (3.1.0或者更高) 到依赖列表。新增行在下面已被高亮：
    
    ```yaml
    dependencies:
    flutter:
    sdk: flutter
        
    cupertino_icons: ^0.1.0
    english_words: ^3.1.0
    ```

2. 在 Android Studio’s editor 视图查看 pubspec，点击右上角的 **Packages get**。这会把包拉取到你的项目中。你会在控制台上看到以下信息：

    ```
    flutter packages get
    Running "flutter packages get" in startup_namer...
    Process finished with exit code 0
    ```

3. 在 **lib/main.dart**，增加一个 `english_words` 的导入，就如高亮展示的那样：

    ```dart
    import 'package:flutter/material.dart';
    import 'package:english_words/english_words.dart';
    ```
    
    由于你的输入，Android Studio 针对库会给你一些导入的建议。然后将导入字符串呈现为灰色，让你知道倒入的库你没有使用它（目前为止）。
    
4. 使用 English words 包生成文本，用来替换掉之前的 "Hello World" 字符串。

    > **提示：**"Pascal case" （也称为 “大驼峰式命名法”），表示字符串中的每个单词，包括第一个单词，首字母大写。所以，“uppercamelcase” 就变成 “UpperCamelCase”。
    
    做以下改变，如下面高亮处：
    
    ```dart
    import 'package:flutter/material.dart';
    import 'package:english_words/english_words.dart';
    
    void main() => runApp(new MyApp());
    
    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        final wordPair = new WordPair.random();
        return new MaterialApp(
          title: 'Welcome to Flutter',
          home: new Scaffold(
            appBar: new AppBar(
              title: new Text('Welcome to Flutter'),
            ),
            body: new Center(
              //child: new Text('Hello World'), // Replace the highlighted text...
              child: new Text(wordPair.asPascalCase),  // With this highlighted text.
            ),
          ),
        );
      }
    }
    ```
    
5. 如果 app 正在运行中，使用热重载按钮（![](https://flutter.io/get-started/codelab/images/hot-reload-button.png)）来更新运行中的 app。每一次你点击了热重载，或者保存了项目，你将会看见不同的词对，它在运行的 app 中是随机的。这是因为词对在 build 方法中被生成。在每次 MaterialApp 需要渲染或者在 Flutter Inspector 中切换平台的时候。

<div style='text-align: center;'>
<img src='https://flutter.io/get-started/codelab/images/step2-screenshot.png' />
</div>

### 问题？

如果你的 app 没有正确运行，排查错误。如果需要，请使用以下链接的代码来追踪。

- [**pubspec.yaml**](https://gist.githubusercontent.com/Sfshaza/bb51e3b7df4ebbf3dfd02a4a38db2655/raw/57c25b976ec34d56591cb898a3df0b320e903b99/pubspec.yaml) (**pubspec.yaml** 不会再次修改了。)
- [**lib/main.dart**](https://gist.githubusercontent.com/Sfshaza/bb51e3b7df4ebbf3dfd02a4a38db2655/raw/57c25b976ec34d56591cb898a3df0b320e903b99/main.dart)

---

<span id='step-3-add-a-stateful-widget'/>
## 第3步：增加一个 Stateful widget

State*less* widget 是不可改变的，意味着它们的属性不能被修改 —— 所有值都是 final 的。

State*ful* widgets 维护了状态，它可能会在 widget 的生命周期内被修改。实现一个 statful widget 需要两个类：1）一个 StatefulWidget 类，用来创建一个实例 2）一个 State 类。StatefulWidget 类本身是不可变的，但 State 类在整个 widget 的生命周期中保持不变。

在这一步中，你将会增加一个 stateful widget，RandomWords，增加它的 State class，RandomWordsState。State 类中将最终维护这个 widget 中推荐喜欢的词对。

1. 增加  stateful RandomWords widget 到你的 main.dart 中。它可以被放在任何地方，甚至 MyApp 之外，但是这里的解决方案放在了文件的底部。RandomWords widget 除了创建它的 State 类没有什么特别的。

    ```dart
    class RandomWords extends StatefulWidget {
      @override
      createState() => new RandomWordsState();
    }
    ```

2. 增加 RandomWordsState 类。app 的大部分代码将会写在这个类中，它维护拉这个 widget 中的 state。这个类会保存生成的词对，会被用户无限滚动，用户通过列表切换中的心图标来添加或删除它们。

    你将逐步编写这个类。作为开始，通过以下高亮的文本来创建一个最小的 class：
    
    ```dart
    class RandomWordsState extends State<RandomWords> {
    }
    ```

3. 在增加了 state class 之后，IDE 警告这个类缺少一个 build 方法。然后，你将增加一个基本的 build 方法通过从 MyApp 转移生成词对的代码到 RandomWordsState 来生成词对：

    ```dart
    class RandomWordsState extends State<RandomWords> {
      @override
      Widget build(BuildContext context) {
        final wordPair = new WordPair.random();
        return new Text(wordPair.asPascalCase);
      }
    }
    ```
    
4. 通过以下高亮改变，从 MyApp 中移除生成词对的代码：

    ```dart
    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        final wordPair = new WordPair.random();  // Delete this line
    
        return new MaterialApp(
          title: 'Welcome to Flutter',
          home: new Scaffold(
            appBar: new AppBar(
              title: new Text('Welcome to Flutter'),
           ),
            body: new Center(
              //child: new Text(wordPair.asPascalCase), // Change the highlighted text to...
              child: new RandomWords(), // ... this highlighted text
            ),
          ),
        );
      }
    }    
    ```

重启 app，如果你尝试去热重载，你可能会看到一个警告：

```
Reloading...
Not all changed program elements ran during view reassembly; consider
restarting.
```

这可能是误报，但考虑重新启动以确保你的更改反映在 app UI 中。

app 应该会跟以前一样，每次你热重载或者保存的时候展示一个词对。

<div style='text-align: center;'>
<img src='https://flutter.io/get-started/codelab/images/step3-screenshot.png' />
</div>

### 问题？

如果你的 app 没有正确运行，排查错误。如果需要，请使用以下链接的代码来追踪。

- [lib/main.dart](https://gist.githubusercontent.com/Sfshaza/d7f13ddd8888556232476be8578efe40/raw/329c397b97309ce99f834bf70ebb90778baa5cfe/main.dart)

---

<span id='step-4-create-an-infinite-scrolling-listview'/>
## 第4步：创建一个无限滚动的 ListView

在这一步，你将扩展 RandomWordsState 来生成和展示一个列表的词对。当用户滚动时，展示在 ListView widget 的列表会无限滚动。ListView 的 `builder` factory 构造方法允许你根据需要实现懒加载。

1. 在 RandomWordsState 类中增加一个 `_suggestions` list 来保存推荐的词对。注意变量以下划线（`_`）开头。在 Dart 语言中，以下划线作为前缀标志代表私有。

    也增加一个 `biggerFont` 变量来使字体变大。
    
    ```dart
    class RandomWordsState extends State<RandomWords> {
      final _suggestions = <WordPair>[];
    
      final _biggerFont = const TextStyle(fontSize: 18.0);
      ...
    }
    ```

2. 在 RandomWordsState 类中增加一个 `_buildSuggestions()` 方法。这个方法构建展示词对的 ListView。

    ListView 类提供了一个 builder 属性，`itemBuilder`，以匿名方法的方式指定一个工厂构造器和回调方法。两个参数会被传入到方法中 —— BuildContext，和行迭代器，`i`。迭代器从0开始，每一次方法被调用时递增，每个推荐词对配对一次。这个模型允许在用户滚动时推荐列表无限滚动。
    
    增加以下高亮行：
    
    ```dart
    class RandomWordsState extends State<RandomWords> {
      ...
      Widget _buildSuggestions() {
        return new ListView.builder(
          padding: const EdgeInsets.all(16.0),
          // The itemBuilder callback is called, once per suggested word pairing,
          // and places each suggestion into a ListTile row.
          // For even rows, the function adds a ListTile row for the word pairing.
          // For odd rows, the function adds a Divider widget to visually
          // separate the entries. Note that the divider may be difficult
          // to see on smaller devices.
          itemBuilder: (context, i) {
            // Add a one-pixel-high divider widget before each row in theListView.
            if (i.isOdd) return new Divider();
    
            // The syntax "i ~/ 2" divides i by 2 and returns an integer result.
            // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
            // This calculates the actual number of word pairings in the ListView,
            // minus the divider widgets.
            final index = i ~/ 2;
            // If you've reached the end of the available word pairings...
            if (index >= _suggestions.length) {
              // ...then generate 10 more and add them to the suggestions list.
              _suggestions.addAll(generateWordPairs().take(10));
            }
            return _buildRow(_suggestions[index]);
          }
        );
      }
    }
    ```

3. `_buildSuggestions` 方法在每个词配对时调用。这个方法在一个 ListTile 中展示一个新的配对，在下一步中它允许你在行中增加交互。

    在 `RandomWordsState` 中增加一个 `_buildRow` 方法：
    
    ```dart
    class RandomWordsState extends State<RandomWords> {
      ...
    
      Widget _buildRow(WordPair pair) {
        return new ListTile(
          title: new Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
        );
      }
    }
    ```

4. 使用 `_buildSuggestions()` 来更新 RandomWordsState 的 build 方法，而不是直接调用生成词对的库。修改以下高亮改变：

    ```dart
    class RandomWordsState extends State<RandomWords> {
      ...
      @override
      Widget build(BuildContext context) {
        final wordPair = new WordPair.random(); // Delete these two lines.
        Return new Text(wordPair.asPascalCase);
        return new Scaffold (
          appBar: new AppBar(
            title: new Text('Startup Name Generator'),
          ),
        body: _buildSuggestions(),
        );
      }
      ...
    }
    ```

5. 更新 MyApp 的 build 方法。在 MyApp 中移除 Scaffold 和 AppBar 实例。这些应该由 RandomWordsState 去管理，这让在下一步中导航到另一个页面时修改 app bar 的名字更简单。

    用下面高亮的 build 方法替换原生的方法：
    
    ```dart
    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return new MaterialApp(
          title: 'Startup Name Generator',
          home: new RandomWords(),
        );
      }
    }
    ```

重启 app，你将看到一个词对列表。按你想要的去滚动列表，你会看到新的词对。

<div style='text-align: center;'>
<img src='https://flutter.io/get-started/codelab/images/step4-screenshot.png' />
</div>

### 问题？

如果你的 app 没有正确运行，排查错误。如果需要，请使用以下链接的代码来追踪。

- [lib/main.dart](https://gist.githubusercontent.com/Sfshaza/d7f13ddd8888556232476be8578efe40/raw/329c397b97309ce99f834bf70ebb90778baa5cfe/main.dart)

---

<span id='step-5-add-interactivity'/>
## 第5步：增加交互

在这一步，你将在没行增加一个可点击的心型图标。当用户点击 list 中的每行时，切换它的 “喜欢” 状态，这会触发词对在保存的集合中增加或者删除。

1. 在 RandomWordsState 中增加一个 `_saved` 集合。这个集合存储了用户喜欢了的词对。集合首选 List，因为正确的实现是 Set 不允许重复的条目。

    ```dart
    class RandomWordsState extends State<RandomWords> {
      final _suggestions = <WordPair>[];
    
      final _saved = new Set<WordPair>();
    
      final _biggerFont = const TextStyle(fontSize: 18.0);
      ...
    }
    ```

2. 在 `_buildRow` 方法中，增加一个 `alreadySaved` 检查来确保词对是否已经添加到喜欢集合中了。

    ```dart
    Widget _buildRow(WordPair pair) {
      final alreadySaved = _saved.contains(pair);
      ...
    }
    ```

3. 在 `_buildRow()`，增加一个心型的图标到 ListTile 来启用喜欢状态。稍后，你会在这个心型图标上增加一个交互。

    增加以下高亮：
    
    ```dart
    Widget _buildRow(WordPair pair) {
      final alreadySaved = _saved.contains(pair);
      return new ListTile(
        title: new Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: new Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
      );
    }
    ```

4. 重启 app，现在你会看到每行都有心型图标，但是它们还不能交互。

5. 在 `_buildRow` 方法中让心形图标可点击。如果一个词对已经被添加到喜欢集合，再次点击会从喜欢集合中删除。当心形图标被点击，调用`setState()`方法来通知系统状态被改变。

    增加高亮行：
    
    ```dart
    Widget _buildRow(WordPair pair) {
      final alreadySaved = _saved.contains(pair);
      return new ListTile(
        title: new Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: new Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              _saved.remove(pair);
            } else {
              _saved.add(pair);
            }
          });
        },
      );
    }
    ```

> **提示：**在 Flutter 响应式风格框架中，调用 **setState()** 触发 State 对象的 **build()** 方法的调用，结果更新在 UI 中。

热重载 app，你应该会看到点击任意行来喜欢，取消喜欢条目。注意，点击一行会生成从心型图标发出的隐式墨迹飞溅动画。

<div style='text-align: center;'>
<img src='https://flutter.io/get-started/codelab/images/step5-screenshot.png' />
</div>

### 问题？

如果你的 app 没有正确运行，排查错误。如果需要，请使用以下链接的代码来追踪。

- [lib/main.dart](https://gist.githubusercontent.com/Sfshaza/d7f13ddd8888556232476be8578efe40/raw/329c397b97309ce99f834bf70ebb90778baa5cfe/main.dart)

---

<span id='step-6-navigate-to-a-new-screen'/>
## 第6步：导航到新的页面

在这一步，你将增加一个新的页面（在 Flutter 被称为 *router*）用来展示喜欢的集合。你将会学习到怎么从首页导航到一个新的页面。

在 Fluter，Navigator 管理包含了 app 路由页面的栈。压入一个页面到 Navigator 的栈，更新展示那个页面。从 Navigator 弹出一个页面，返回展示上一个页面。

1. 在 RandomWordsState 的 build 方法中增加一个列表图标到 AppBar 上。当用户点击这个列表图标，一个包含了喜欢的条目的新页面被压入到 Navigator，展示图标。

    > **提示：**一些widget属性接收单个 widget（**child**），其它的属性，如 **action**，接收一个数组 widgets（**children**），通过中括号（[]）标明。
    
    在 build 方法中增加图标和它对应的 action：
    
    ```dart
    class RandomWordsState extends State<RandomWords> {
      ...
      @override
      Widget build(BuildContext context) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text('Startup Name Generator'),
            actions: <Widget>[
              new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved),
            ],
          ),
          body: _buildSuggestions(),
        );
      }
      ...
    }
    ```

2. 在 RandomWordsState 类中增加一个 `_pushSaved()` 方法。

    ```dart
    class RandomWordsState extends State<RandomWords> {
      ...
      void _pushSaved() {
      }
    }
    ```

    热重载 app，列表图标出现在 app bar 上。点击它还不会发生任何事情，因为 `_pushSaved` 方法是空的。

3. 当用户点击 app bar 上的列表图标，构建一个页面并压入 Navigator 的栈中。这个 action 会改变屏幕去展示新的页面。

    新页面的内容在 MaterialPageRoute 的 `builder` 属性中通过匿名方法构建。
    
    增加调用 `Navigator.push`，如下高亮代码展示，把页面压入到 Navigator 的栈里。
    
    ```dart
    void _pushSaved() {
      Navigator.of(context).push(
      );
    }
    ```

4. 增加 MaterialPageRoute 和它的 builder。现在，增加生成 ListTile 行的代码。ListTile 的 `divideTiles()` 方法在每个 ListTile 之间添加水平间距。分割变量保存最后一行，由 convienice 函数 `toList()` 转换为列表。

    ```dart
    void _pushSaved() {
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) {
            final tiles = _saved.map(
                  (pair) {
                return new ListTile(
                  title: new Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                );
              },
            );
            final divided = ListTile
                .divideTiles(
              context: context,
              tiles: tiles,
            )
                .toList();
          },
        ),
      );
    }
    ```

5. builder 属性返回一个 Scaffold，包含了新页面的 app bar，名为 “Save Suggestions”。新页面 body 的构成是一个 ListView 包含了 ListTiles 行；每行由分隔符分割。

    增加以下高亮代码：
    
    ```dart
    void _pushSaved() {
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) {
            final tiles = _saved.map(
                  (pair) {
                return new ListTile(
                  title: new Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                );
              },
            );
            final divided = ListTile
                .divideTiles(
              context: context,
              tiles: tiles,
            )
                .toList();
    
            return new Scaffold(
              appBar: new AppBar(
                title: new Text('Saved Suggestions'),
              ),
              body: new ListView(children: divided),
            );
          },
        ),
      );
    }
    ```

6. 热重载 app，喜欢其中的一些条目并点击 app bar 上的列表图标。新页面展示出来，且包含了喜欢的条目。注意 Navigator 在 app bar 上增加了一个 “Back” 按钮。你不需要明确地实现 Navigator.pop。点击返回按钮来返回首页。

    <div style='text-align: center;'>
    <img src='https://flutter.io/get-started/codelab/images/step6a-screenshot.png' />
    <img src='https://flutter.io/get-started/codelab/images/step6b-screenshot.png' />    
    </div>

### 问题？

如果你的 app 没有正确运行，排查错误。如果需要，请使用以下链接的代码来追踪。

- [lib/main.dart](https://gist.githubusercontent.com/Sfshaza/d7f13ddd8888556232476be8578efe40/raw/329c397b97309ce99f834bf70ebb90778baa5cfe/main.dart)

---

<span id='step-7-change-the-ui-using-themes'/>
## 第7步：使用 Theme 来改变 UI

在这一步，你将玩转 app 的 theme。**Theme**会控制你的 app 的视觉和感觉。你可以使用默认的 theme，这依赖于物理设备或者模拟器，或者你可以自定义 theme 来反映出你的品牌。

1. 你可以很简单地通过配置 ThemeData 类来改变 app 的主题。你的 app当前使用的是默认的主题，但是你将修改主要颜色为白色。

    通过增加高亮的代码到 MyApop 来改变 app 的主题为白色：
    
    ```dart
    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return new MaterialApp(
          title: 'Startup Name Generator',
          theme: new ThemeData(
            primaryColor: Colors.white,
          ),
          home: new RandomWords(),
        );
      }
    }
    ```
    
2. 热重载 app，注意，整个背景都是白色的，甚至是 app bar。

3. 作为读者的联系，使用 [ThemeData](https://docs.flutter.io/flutter/material/ThemeData-class.html) 来改变 UI 的其它方面。Material 库中的 [Colors](https://docs.flutter.io/flutter/material/Colors-class.html) 类提供了很多颜色常量可以使用，然后热重载使得 UI 实验变的又快又简单。

    <div style='text-align: center;'>
    <img src='https://flutter.io/get-started/codelab/images/step7-themes.png' />
    </div>
    
### 问题？

如果你的 app 没有正确运行，排查错误。如果需要，请使用以下链接的代码来追踪。

- [lib/main.dart](https://gist.githubusercontent.com/Sfshaza/d7f13ddd8888556232476be8578efe40/raw/329c397b97309ce99f834bf70ebb90778baa5cfe/main.dart)

---

<span id='well-done'/>
## 干得不错

你已写了一个运行在 iOS 和 Android 的具有交互性的 Flutter app。在这个 codelab，你已经：

- 从头创建了一个 Flutter app。
- 编写 Dart 代码。
- 使用外部第三方库。
- 使用热重载来进行快速的开发周期。
- 实现了 stateful widget，给你的 app 增加了互动性。
- 使用 ListView 和 ListTiles 创建了一个懒加载，无限滚动的列表。
- 创建了一个页面，且增加了在主页和新的页面之前移动的逻辑。
- 学习改变 app 主题外观和主题

