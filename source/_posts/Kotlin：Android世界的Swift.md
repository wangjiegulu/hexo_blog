---
title: Kotlin：Android世界的Swift
tags: []
date: 2015-09-09 14:23:00
---

转自：http://www.infoq.com/cn/news/2015/06/Android-JVM-JetBrains-Kotlin

[Kotlin](http://kotlinlang.org/)是一门与Swift类似的静态类型JVM语言，由[JetBrains](https://www.jetbrains.com/)设计开发并[开源](https://github.com/jetbrains/kotlin)。与Java相比，Kotlin的语法更简洁、更具表达性，而且提供了更多的特性，比如，高阶函数、操作符重载、字符串模板。它与Java高度可互操作，可以同时用在一个项目中。

[按照JetBrains的说法](http://kotlinlang.org/docs/reference/faq.html)，根据他们多年的Java平台开发经验，他们认为Java编程语言有一定的局限性和问题，而且由于需要向后兼容，它们不可能或很难得到解决。因此，他们创建了Kotlin项目，主要目标是：

*   创建一种兼容Java的语言
*   编译速度至少同Java一样快
*   比Java更安全
*   比Java更简洁
*   比最成熟的竞争者Scala还简单

[Ashraff Hathibelagal](http://tutsplus.com/authors/ashraff-hathibelagal)是一名喜欢研究新框架和SDK的独立开发者。近日，他[撰文](http://code.tutsplus.com/tutorials/an-introduction-to-kotlin--cms-24051)介绍了Kotlin的一些语法。按照他的说法，一个合格的Java程序员可以在很短的时间内学会使用Kotlin。

**类与构造函数**

Kotlin创建类的方式与Java类似，比如下面的代码创建了一个有三个属性的`Person`类：

    class Person{
        var name: String = ""
        var age: Int = 0
        var college: String? = null
    }
    `</pre>

    可以看到，Kotlin的变量声明方式略有些不同。在Kotline中，声明变量必须使用关键字`var`，而如果要创建一个只读/只赋值一次的变量，则需要使用`val`代替它。另外，为了实现&ldquo;空安全（null safety）&rdquo;，Kotlin对可以为空的变量和不可以为空的变量作了区分。在上述代码中，变量`name`和`age`不可为空，而`？`表明变量`college`可以为空。定义完类之后，创建实例就非常简单了：

    <pre>`var jake = Person()
    `</pre>

    注意，Kotlin没有关键字`new`。实例创建完成后，就可以像在Java中一样为变量赋值了：

    <pre>`jake.name = "Jake Hill"
    jake.age = 24
    jake.college = "Stephen's College"
    `</pre>

    变量可以采用上述方式赋值，也可以通过构造函数赋值，但后者是一种更好的编码实践。在Kotlin中，创建这样的一个构造函数非常简单：

    <pre>`class Person(var name: String, var age: Int, var college: String?) {
    }
    `</pre>

    而实际上，由于构造函数中没有其它操作，所以花括号也可以省略，代码变得相当简洁：

    <pre>`class Person(var name: String, var age: Int, var college: String?)

    var jake = Person("Jake Hill", 24, "Stephen's College")
    `</pre>

    上述代码中的构造函数是类头的一部分，称为主构造函数。在Kotlin中，还可以使用`constructor`关键字创建辅助构造函数，例如，下面的代码增加了一个辅助构造函数初始化变量`email`：

    <pre>`class Person(var name: String, var age: Int, var college: String?) {

        var email: String = ""

        constructor(name:String, age:Int, college: String?, email: String) : this(name, age, college) {
            this.email = email
        }
    }
    `</pre>

    Kotlin允许创建派生类，但要遵循如下规则：

*   必须使用`：`代替Java中的`extends`关键字
*   基类头必须有`open`注解
*   基类必须有一个带参数的构造函数，派生类要在它自己的头中初始化那些参数

    比如下面的代码创建了一个名为`Empoyee`的派生类：

    <pre>`open class Person(var name: String, var age: Int, var college: String?) {
        ...
    }

    class Employee(name: String, age: Int, college: String?, var company: String) : Person(name, age, college) {
    }
    `</pre>

    **函数与扩展**

    有派生就有重载。与类的派生一样，允许重载的方法要有`open`注解，而在派生类中重载时要使用`override`注解。例如，下面是在`Employee`类中重载`Person`类的`isEligibleToVote`方法的代码：

    <pre>`override fun isEligibleToVote(): Boolean {
        return true
    }
    `</pre>

    除了改变类的已有行为，Kotlin还允许开发者在不修改类的原始定义的情况下实现对类的扩展，如下面的代码为`Person`类增加了一个名为`isTeenager`的扩展：

    <pre>`fun Person.isTeenager(): Boolean {
        return age in 13..19
    }
    `</pre>

    在需要扩展来自其它项目的类时，这个特性特别有用。

    上面提到的函数都与Java中的函数类似，但Kotlin还支持其它类型的函数。如果一个函数返回单个表达式的值，那么可以使用`=`来定义函数。下面是一个创建单表达式函数的例子：

    <pre>`fun isOctogenarian(): Boolean = age in 80 .. 89
    `</pre>

    Kotlin还支持高阶函数和Lambda表达式。例如，lambda表达式`{x,y-&gt;x+y}`可以像下面这样给一个变量赋值：

    <pre>`val sumLambda: (Int, Int) -&gt; Int = {x,y -&gt; x+y}
    `</pre>

    而下面的高阶函数将上述表达式作为一个参数，并将表达式的计算结果翻倍：

    <pre>`fun doubleTheResult(x:Int, y:Int, f:(Int, Int)-&gt;Int): Int {
        return f(x,y) * 2
    }
    `</pre>

    该函数可以使用下面的其中一种方式调用：

    <pre>`val result1 = doubleTheResult(3, 4, sumLambda)
    `</pre>

    或

    <pre>`val result2 = doubleTheResult(3, 4, {x,y -&gt; x+y})
    `</pre>

    **范围表达式**

    在Kotlin中，范围表达式用的比较多。范围创建只需要`..`操作符，例如：

    <pre>`val r1 = 1..5
    //该范围包含数值1,2,3,4,5
    `</pre>

    如果创建一个降序范围，则需要使用`downTo`函数，例如：

    <pre>`val r2 = 5 downTo 1
    //该范围包含数值5,4,3,2,1
    `</pre>

    如果步长不是1，则需要使用`step`函数，例如：

    <pre>`val r3 = 5 downTo 1 step 2
    //该范围包含数值5,3,1
    `</pre>

    **条件结构**

    在Kotlin中，if是一个表达式，根据条件是否满足返回不同的值，例如，下面的代码将`isEligibleToVote`设置为&ldquo;Yes&rdquo;

    <pre>`var age = 20
    val isEligibleToVote = if(age &gt; 18) "Yes" else "No"
    `</pre>

    `when`表达式相当于Java的`switch`，但功能更强大，例如，下面的代码将`typeOfPerson`设置为&ldquo;Teenager&rdquo;：

    <pre>`val age = 17

    val typeOfPerson = when(age){
        0 -&gt; "New born"
        in 1..12 -&gt; "Child"
        in 13..19 -&gt; "Teenager"
        else -&gt; "Adult"
    }
    `</pre>

    **循环结构**

    Kotlin使用`for..in`遍历数组、集合及其它提供了迭代器的数据结构，语法同Java几乎完全相同，只是用`in`操作符取代了`:`操作符，例如，下面的代码将遍历一个`String`对象数组：

    <pre>`val names = arrayOf("Jake", "Jill", "Ashley", "Bill")

    for (name in names) {
        println(name)
    }
    `</pre>

    `while`和`do..while`循环的语法与Java完全相同。

    **字符串模板**

    Kotlin允许在字符串中嵌入变量和表达式，例如：

    <pre>`val name = "Bob"
    println("My name is ${name}") //打印"My name is Bob"

    val a = 10
    val b = 20
    println("The sum is ${a+b}") //打印"The sum is 30"

此外，Kotlin与Java高度可互操作。Kotlin可以用一种自然的方式调用现有的Java代码，而Java也很容易调用Kotlin代码。同时，Kotlin也可以与JavaScript互操作。

上面介绍的只是Kotlin的一些基本语法和特性，更多细节请查阅[官方文档](http://kotlinlang.org/docs/reference/)。事实上，到目前为止，Kotlin还仍然只是一个预览版本，接下来的几个月中还会有多项重大改进及新增特性。尽管如此，[GitHub上已有400多个与Kotlin项目相关的库](https://github.com/search?q=Kotlin&amp;ref=cmdform)。

在另外一篇[文章](http://code.tutsplus.com/tutorials/how-to-use-kotlin-in-your-android-projects--cms-24052)中，Hathibelagal写道，&ldquo;如果你正在为Android开发寻找一种替代编程语言，那么应该试下Kotlin。它很容易在Android项目中替代Java或者同Java一起使用。&rdquo;想要了解如何在Android Studio中使用Kotlin开发Android项目的读者，可以读下这篇文章。