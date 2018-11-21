---
title: Android Architecture Component DataBinding -- 布局和表达式（翻译）
subtitle: "Android Architecture Component 系列翻译"
tags: ["android", "kotlin", "architecture", "Android Architecture Component", "aac", "ViewModel", "LiveData", "DataBinding", "Lifecycles"]
categories: ["Android Architecture Component", "kotlin", "DataBinding"]
header-img: "https://images.unsplash.com/photo-1464865885825-be7cd16fad8d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=996620e5a840fd2d82fc5bb137a1b4f7&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true

date: 2018-04-15 13:01:00
---

# Android Architecture Component DataBinding -- 布局和表达式（翻译）

表达式语言允许你编写表达式用于 view 派发的事件。Data binding 库自动生成要将 layout 中的 views 与数据对象绑定所需的类。

Data binding 布局有稍微的差别，从 layout 的根节点开始，然后是 `data` 标签和 `view` 根标签。这个 view 标签就是你在非 binding 布局文件的根标签。下面代码展示了一个 layout 文件的例子：

```xml
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">
   <data>
       <variable name="user" type="com.example.User"/>
   </data>
   <LinearLayout
       android:orientation="vertical"
       android:layout_width="match_parent"
       android:layout_height="match_parent">
       <TextView android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="@{user.firstName}"/>
       <TextView android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="@{user.lastName}"/>
   </LinearLayout>
</layout>
```

在 `data` 中的 `user` 变量描述了一个可能会在这个布局中使用的属性。

```xml
<variable name="user" type="com.example.User" />
```

布局中的表达式是使用 `"@{}"` 语法写在属性里面。这里，`TextView` 文本用来设置 `user` 变量的 `firstName` 属性。

```xml
<TextView android:layout_width="wrap_content"
          android:layout_height="wrap_content"
          android:text="@{user.firstName}" />
```

> 布局表达式应该保持短小而简洁，因为它们不能被单元测试并且 IDE 支持有限。为了简化布局表达式，你可以使用自定义的 [binding adapters](https://developer.android.com/topic/libraries/data-binding/binding-adapters)。

## 数据对象

假设我们现在有一个简单的对象来描述 `User` 实体：

```kotlin
data class User(val firstName: String, val lastName: String)
```
```java
public class User {
  public final String firstName;
  public final String lastName;
  public User(String firstName, String lastName) {
      this.firstName = firstName;
      this.lastName = lastName;
  }
}
```

这种类型的对象永远不会改变数据。在应用中，通常会有一次读取的数据此后永远不会更改的情况。还可以使用遵循一组约定的对象，例如在 java 中使用访问器方法，如下所示：

```java
public class User {
  private final String firstName;
  private final String lastName;
  public User(String firstName, String lastName) {
      this.firstName = firstName;
      this.lastName = lastName;
  }
  public String getFirstName() {
      return this.firstName;
  }
  public String getLastName() {
      return this.lastName;
  }
}
```

从数据绑定的角度来看，这两个类是等价的。用于 [`android:text`](https://developer.android.com/reference/android/widget/TextView.html#attr_android:text) 属性的表达式 `@{user.firstName}` 访问前者类的 `firstName`属性，访问后者的 `getFirstName()` 方法。或者如果存在的话会访问 `firstName()` 方法。

## 绑定数据

每个 layout 文件都会生成一个 binding class。默认情况下，类名基于 layout 文件的名字。将其转换为 Pascal 大小写, 并向其添加 *Binding* 后缀。上面的 layout 名字是 `activity_main.xml` 所以相应生成的类是 `ActivityMainBinding`。这个类会持有从 layout 属性（比如，`user` 变量）到 layout 的 views 的所有绑定，并知道如何为绑定表达式赋值。推荐的方法去创建 binding 是在 inflating 布局的时候，如下代码所示：

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val binding: ActivityMainBinding = DataBindingUtil.setContentView(
            this, R.layout.activity_main)

    binding.user = User("Test", "User")
}
```

在运行时，app 在 UI 上显示 **Test** 用户。或者你可以使用 [`LayoutInflater`](https://developer.android.com/reference/android/view/LayoutInflater.html) 来获取 view，如下所示：

```kotlin
val binding: ActivityMainBinding = ActivityMainBinding.inflate(getLayoutInflater())
```

如果你在 [`Fragment`](https://developer.android.com/reference/android/app/Fragment.html)，[`ListView`](https://developer.android.com/reference/android/widget/ListView.html)，[`RecyclerView`](https://developer.android.com/reference/android/support/v7/widget/RecyclerView.html) adapter 中使用 data binding，你可能更喜欢使用 bindings classes 的 [`inflate`](https://developer.android.com/reference/android/databinding/DataBindingUtil.html#inflate(android.view.LayoutInflater,%20int,%20android.view.ViewGroup,%20boolean,%20android.databinding.DataBindingComponent)) 方法，或者 [`DataBindingUtil`](https://developer.android.com/reference/android/databinding/DataBindingUtil) 类，如下所示：

```kotlin
val listItemBinding = ListItemBinding.inflate(layoutInflater, viewGroup, false)
// or
val listItemBinding = DataBindingUtil.inflate(layoutInflater, R.layout.list_item, viewGroup, false)
```

## 表达语言

### 常见功能

表达式语言看起来很像托管代码中找到的表达式。你可以在表达式语言中使用以下操作符和关键字：

- 数学，`+ - / * %`
- 字符串连接，`+`
- 逻辑，`&& ||`
- 二进制，`& | ^`
- 一元，`+ - ! ~`
- 移位，`>> >>> <<`
- 比较，`== > < >= <=`
- `instanceof`
- 分组，`()`
- 源文本 - 字符，字符串，数字，`null`
- 转型
- 方法调用
- 属性访问
- 数组访问
- 三元操作法 `?:`

举例：

```xml
android:text="@{String.valueOf(index + 1)}"
android:visibility="@{age < 13 ? View.GONE : View.VISIBLE}"
android:transitionName='@{"image_" + id}'
```

### 缺失操作

下面在代码中可以使用的操作在表达式语法中是缺失的：

- `this`
- `super`
- `new`
- 显示泛型调用

### 空合运算符

空合运算符（`??`）如果左边不是 `null` 则选择左边，否则选右边。

```xml
android:text="@{user.displayName ?? user.lastName}"
```

这在功能上等效于：

```xml
android:text="@{user.displayName != null ? user.displayName : user.lastName}"
```

### 属性引用

表达式可以通过使用以下格式引用类中的属性，该格式对于字段，getters 和 [`ObservableField`](https://developer.android.com/reference/android/databinding/ObservableField.html) 对象是相同的：

```xml
android:text="@{user.lastName}"
```

### 避免空指针异常

生成的 data binding 代码会自动检查 `null` 和避免空指针异常。举例，在表达式 `@{user.name}`，如果 `user` 是 null，`user.name` 被赋值 `null` 的默认值。如果你引用了 `user.age`，age 是 `int` 类型，那么 data binding 使用默认值 `0`。

### 集合

常用的集合，比如 arrays，lists，sparse list 和 map，可以方便地使用 `[]` 来访问。

```xml
<data>
    <import type="android.util.SparseArray"/>
    <import type="java.util.Map"/>
    <import type="java.util.List"/>
    <variable name="list" type="List<String>"/>
    <variable name="sparse" type="SparseArray<String>"/>
    <variable name="map" type="Map<String, String>"/>
    <variable name="index" type="int"/>
    <variable name="key" type="String"/>
</data>
…
android:text="@{list[index]}"
…
android:text="@{sparse[index]}"
…
android:text="@{map[key]}"
```

> 你还可以使用 **object.key** 表示法引用 map 中的值。举例，上面例子中的 @{**map[key]**} 我们可以替换为 @{**map.key**}。

### String 源文本

你可以使用单引号包围属性值，这允许您在表达式中使用双引号，如下所示：

```xml
android:text='@{map["firstName"]}'
```

也可以使用双引号来包围属性值。当我们这样做时，字符串文本应使用反引号 `：

```xml
android:text="@{map[`firstName`]}"
```

### Resources

你可以在表达式中使用以下语法来访问 resources：

```xml
android:padding="@{large? @dimen/largePadding : @dimen/smallPadding}"
```

格式化 string 和 plurals 可能需要通过提供参数来计算：

```xml
android:text="@{@string/nameFormat(firstName, lastName)}"
android:text="@{@plurals/banana(bananaCount)}"
```

当一个 plural 使用多个参数，则所有参数都应该被传入：

```xml

  Have an orange
  Have %d oranges

android:text="@{@plurals/orange(orangeCount, orangeCount)}"
```

一些资源需要显式类型计算，如下表所示:

|类型|普通引用|表达式引用|
|---|---|---|
|String[]|@array|@stringArray|
|int[]|@array|@intArray|
|TypedArray|@array|@typedArray|
|Animator|@animator|@animator|
|StateListAnimator|@animator|@stateListAnimator|
|color|int|@color|@color|
|ColorStateList|@color|@colorStateList|

## 事件处理

Data binding 允许你编写表达式来处理从 views 派发的事件（比如，[`onClick`](https://developer.android.com/reference/android/view/View.OnClickListener.html#onClick(android.view.View)) 方法）。事件属性名由监听器方法名确定，但有少数例外。举例，[`View.OnClickListener`](https://developer.android.com/reference/android/view/View.OnClickListener.html) 有一个方法 [`onClick`](https://developer.android.com/reference/android/view/View.OnClickListener.html#onClick(android.view.View))，所以这个 event 的属性是 `android:onClick`。

对于点击事件，有一些特殊的事件处理器不使用 `android:onClick` 而需要一个属性，以避免冲突。你可以使用下面属性来避免这种类型的冲突：

|类|监听器设置|属性|
|---|---|---|
|[`SearchView`](https://developer.android.com/reference/android/widget/SearchView.html)|[`setOnSearchClickListener(View.OnClickListener)`](https://developer.android.com/reference/android/widget/SearchView.html#setOnSearchClickListener(android.view.View.OnClickListener))|android:onSearchClick|
|[`ZoomControls`](https://developer.android.com/reference/android/widget/ZoomControls.html)|[`setOnZoomInClickListener(View.OnClickListener)`](https://developer.android.com/reference/android/widget/ZoomControls.html#setOnZoomInClickListener(android.view.View.OnClickListener))|android:onZoomIn|
|[`ZoomControls`](https://developer.android.com/reference/android/widget/ZoomControls.html)|[`setOnZoomOutClickListener(View.OnClickListener)`](https://developer.android.com/reference/android/widget/ZoomControls.html#setOnZoomOutClickListener(android.view.View.OnClickListener))|android:onZoomOut|

你可以使用以下机制来处理事件：

- [方法引用](https://developer.android.com/topic/libraries/data-binding/expressions#method_references)：在你的表达式中，你可以引用符合监听器方法签名的方法。当表达式计算结果是方法引用时，Data binding 包装方法引用和所有者的对象，并在目标 view 上设置监听器。如果表达式计算结果为 `null`，Data binding 不会创建监听器并且设置监听器为 `null`。
- [监听器绑定](https://developer.android.com/topic/libraries/data-binding/expressions#listener_bindings)：当事件发生时，lambda 表达式会被计算。Data binding 总是创建监听器并设置在 view 上。当事件被派发，监听器将计算 lambda 表达式。

### 方法引用

事件可以直接绑定到处理的方法上，类似 [`android:onClick`](https://developer.android.com/reference/android/view/View.html#attr_android:onClick) 可以被分配到一个 Activity 中的一个方法上。与 [`View`](https://developer.android.com/reference/android/view/View.html) `onClick` 属性相比，一个主要的优势是表达式在编译时期被处理，因此如果方法不存在或者签名不准确，你将会收到一个编译错误。

方法引用与监听器绑定两者的主要区别是实际的监听器实现在数据被绑定时创建，而不是在事件触发的时候。如果你希望在事件发生的时候计算表达式，你应该使用[监听器绑定](https://developer.android.com/topic/libraries/data-binding/expressions#listener_bindings)。

要将事件分配给它的处理器，就使用正常的绑定表达式，值是要调用的方法名。例如，思考下面的布局数据对象示例：

```kotlin
class MyHandlers {
    fun onClickFriend(view: View) { ... }
}
```

绑定表达式可以为一个 view 分配一个点击监听器到 `onClickFriend()` 方法，如下：

```xml
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">
   <data>
       <variable name="handlers" type="com.example.MyHandlers"/>
       <variable name="user" type="com.example.User"/>
   </data>
   <LinearLayout
       android:orientation="vertical"
       android:layout_width="match_parent"
       android:layout_height="match_parent">
       <TextView android:layout_width="wrap_content"
           android:layout_height="wrap_content"
           android:text="@{user.firstName}"
           android:onClick="@{handlers::onClickFriend}"/>
   </LinearLayout>
</layout>
```

> 表达式中的方法签名必须跟监听器对象的方法签名确切匹配。

### 监听器绑定

监听器绑定是在事件发生的时候绑定表达式。它们与方法引用相似，但是它们允许你运行任意数据绑定表达式。这个功能在 Android Gradle Plugin 2.0 及之后版本可用。

在方法引用，方法的参数必须跟事件监听器的参数匹配。在监听器绑定中，你只需要返回值与监听器期望的返回值（除非是 void）匹配即可。举例，思考下面包含 `onSaveClick()` 方法的 presenter 类：

```kotlin
class Presenter {
    fun onSaveClick(task: Task){}
}
```

接着，你可以绑定点击事件到 `onSaveClick()` 方法， 如下：

```kotlin
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">
    <data>
        <variable name="task" type="com.android.example.Task" />
        <variable name="presenter" type="com.android.example.Presenter" />
    </data>
    <LinearLayout android:layout_width="match_parent" android:layout_height="match_parent">
        <Button android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:onClick="@{() -> presenter.onSaveClick(task)}" />
    </LinearLayout>
</layout>
```

当一个回调在表达式中被使用，data binding 自动创建必要的监听器并根据事件注册它。当 view 触发这个事件，data binding 计算所给的表达。与正则表达式绑定一样，在计算这些监听器表达式时，你仍然得到数据绑定的 null 和线程安全性。

在上面的例子中，我们没有定义传入 [`onClick(View)`](https://developer.android.com/reference/android/view/View.OnClickListener.html#onClick(android.view.View)) 的 `view` 参数。监听器绑定针对监听器参数提供了两种选择：你可以忽略方法的所有参数或者命名它们。如果你更喜欢命名参数，则可以在表达式中使用它们。比如，上面的表达式可以按照以下重写：

```xml
android:onClick="@{(view) -> presenter.onSaveClick(task)}"
```

或者你想在表达式中使用参数，它可以如下工作：

```kotlin
class Presenter {
    fun onSaveClick(view: View, task: Task){}
}
```

```xml
android:onClick="@{(theView) -> presenter.onSaveClick(theView, task)}"
```

你可以使用 lambda 表达式使用多个参数：

```kotlin
class Presenter {
    fun onCompletedChanged(task: Task, completed: Boolean){}
}
```

```xml
<CheckBox android:layout_width="wrap_content" android:layout_height="wrap_content"
      android:onCheckedChanged="@{(cb, isChecked) -> presenter.completeChanged(task, isChecked)}" />
```

如果你监听的事件返回的的类型不是 `void`，你的表达式也必须返回相同类型的类型。举例，如果你想监听 long click 事件，你的表达式应该返回一个 boolean。

```kotlin
class Presenter {
    fun onLongClick(view: View, task: Task): Boolean { }
}
```

```xml
android:onLongClick="@{(theView) -> presenter.onLongClick(theView, task)}"
```

如果因为 `null` 对象无法计算表达式，data binding 会返回那个类型的默认值。比如，引用类型的 `null`，`int` 类型的 `0`，`boolean` 类型的 `false` 等等。

如果你需要在表达式中使用条件（比如，三元），你可以把 `void` 作为一个符号使用。

```xml
android:onClick="@{(v) -> v.isVisible() ? doSomething() : void}"
```

**避免复杂的监听器**

监听器表达式是强大的，并且可以使得你的代码更容易阅读。另一方面，包含负责表达式的监听器会使得你的 layout 难以阅读和维护。这些表达式应该非常简单，就像将可用数据从 UI 传递到回调方法一样。你应该在从监听器表达式调用的回调方法中实现任何业务逻辑。

## Imports, variables, 和 includes

Data binding 库提供了 imports，variables，includes 等功能。Imports 让你在 layout 文件中引用类变得更简单。Variables 允许你描述一个可以在绑定表达式中使用的属性。Includes 让你在 app 中复用复杂的 layouts。

### Imports

Imports 允许你在 layouts 文件中简单地引用类，就像托管代码中那样。在 `data` 标签中可以有零个或者多个 `import` 标签。下面的示例代码在 layout 文件中导入 [`View`](https://developer.android.com/reference/android/view/View.html) 类：

```xml
<data>
    <import type="android.view.View"/>
</data>
```

导入 [`View`](https://developer.android.com/reference/android/view/View.html) 类允许你从绑定表达式中引用它。下面的代码展示了如何引用 `View` 类中的 [`VISIBLE`](https://developer.android.com/reference/android/view/View.html#VISIBLE) 和 [`GONE`](https://developer.android.com/reference/android/view/View.html#GONE) 常量：

```xml
<TextView
   android:text="@{user.lastName}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"
   android:visibility="@{user.isAdult ? View.VISIBLE : View.GONE}"/>
```

#### 类型别名

当类名冲突时，其中一个应该被重命名一个别名。下面例子重命名 `com.example.real.estate` 包中的 `View` 为 `Vista`：

```xml
<import type="android.view.View"/>
<import type="com.example.real.estate.View"
        alias="Vista"/>
```

你可以在 layout 文件中使用 `Vista` 去引用 `com.example.real.estate.View` 和使用 `View` 引用 `android.view.View`。

#### Import 其它 class

导入的类型可以在 variables 和表达式中作为类型来引用。下面的例子展示了 `User` 和 `List` 作为变量的类型使用：

```xml
<data>
    <import type="com.example.User"/>
    <import type="java.util.List"/>
    <variable name="user" type="User"/>
    <variable name="userList" type="List<User>"/>
</data>
```

> Android Studio 目前还不能处理导入，所以对于完成导入的变量，你的 IDE 还不能自动补全。你的 app 仍然会编译，并且你可以通过定义的变量的完全限定名来解决 IDE 问题。

你还可以使用导入的类型对表达式的一部分进行转型。下面的例子把 `connection` 属性转型为 `User` 类型：

```xml
<TextView
   android:text="@{((User)(user.connection)).lastName}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"/>
```

被导入的类型在表达式中可能也会被引用静态属性和方法来使用。下面的代码导入来 `MyStringUtils` 类并引用了它的 `capitalize` 方法：

```xml
<data>
    <import type="com.example.MyStringUtils"/>
    <variable name="user" type="com.example.User"/>
</data>
…
<TextView
   android:text="@{MyStringUtils.capitalize(user.lastName)}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"/>
```

就像托管代码那样，`java.lang.*` 是被自动导入了的。

### Variables

在 `data` 标签下你可以使用多个 `variable` 标签。每个 `variable` 标签描述了一个属性，它会在 layout 文件的绑定表达式中被使用。下面的例子声明了 `user`，`image` 和 `note` 变量：

```xml
<data>
    <import type="android.graphics.drawable.Drawable"/>
    <variable name="user" type="com.example.User"/>
    <variable name="image" type="Drawable"/>
    <variable name="note" type="String"/>
</data>
```

Variable 类型会在编译时期被检查，所以如果一个变量实现了 [`Observable`](https://developer.android.com/reference/android/databinding/Observable.html) 或者是一个 [`observable collection`](https://developer.android.com/topic/libraries/data-binding/observability.html#observable_collections)，则会反映在类型中。如果 variable 是没有实现 `Observable` 接口的一个基类或者一个接口，那这个 variable 就*不能*被观察。

当不同的配置有不同的配置文件时（比如，横向或者纵向），variables 将被组合。这些 layout 文件之间不能有冲突的 variable 定义。

生成的 binding 类针对每个描述的 variable 都有一个 setter 和 getter 方法。这些 variables 值都是代码中的默认值，直到 setter 方法被调用 —— 引用类型的 `null`，`int` 类型的 `0`，`boolean` 类型的 `false` 等等。

一个名为 `context` 的特殊的 variable 会被生成以便于根据需要可以在绑定表达式中使用。`context` 值是从根 view 的 [`getContext()`](https://developer.android.com/reference/android/view/View.html#getContext()) 方法返回的 [`Context`](https://developer.android.com/reference/android/content/Context.html) 对象。`context` 变量会被具有该名称的显式变量声明所覆盖。

### Includes

通过使用 app 命名空间和属性中的变量名，可以将变量从包含布局传递到包含的布局绑定中。下面的例子展示了 `name.xml` 和 `contact.xml` 中的 `user` 变量。

```xml
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:bind="http://schemas.android.com/apk/res-auto">
   <data>
       <variable name="user" type="com.example.User"/>
   </data>
   <LinearLayout
       android:orientation="vertical"
       android:layout_width="match_parent"
       android:layout_height="match_parent">
       <include layout="@layout/name"
           bind:user="@{user}"/>
       <include layout="@layout/contact"
           bind:user="@{user}"/>
   </LinearLayout>
</layout>
```

Data Binding 不支持将其作为 merge 标签的直接子级包括在内。举例，*下面的 layout 不支持*：

```xml
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:bind="http://schemas.android.com/apk/res-auto">
   <data>
       <variable name="user" type="com.example.User"/>
   </data>
   <merge><!-- Doesn't work -->
       <include layout="@layout/name"
           bind:user="@{user}"/>
       <include layout="@layout/contact"
           bind:user="@{user}"/>
   </merge>
</layout>
```







