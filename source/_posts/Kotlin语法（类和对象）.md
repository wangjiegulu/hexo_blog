---
title: Kotlin语法（类和对象）
tags: []
date: 2015-09-11 17:47:00
---

#二、类和对象：
##1\. 类定义：
类的声明包含类名，类头(指定类型参数，主构造函数等等)，以及类主体，用大括号包裹。类头和类体是可选的；如果没有类体可以省略大括号。
```
class Invoice{
}
```

##2\. 构造函数:
在 Kotlin 中类可以有一个主构造函数以及多个二级构造函数。主构造函数是类头的一部分：跟在类名后面(可以有可选的参数)。
```
class Person(val firstName: String, val lastName: String, var age: Int){
}
```
初始化代码可以放在以 init 做前缀的初始化块内：
```
class Customer(name: String){
    init {
        logger,info("Customer initialized with value ${name}")
    }
}
```
如果构造函数有注解或可见性声明，则 constructor 关键字是不可少的，并且注解应该在前：
```
class Customer public inject constructor (name: String) {...}
```

##3\. 二级构造函数:
前缀是 constructor：
```
class Person {
    constructor(parent: Person) {
        parent.children.add(this)
    }
}
```
如果类有主构造函数，每个二级构造函数都要，或直接或间接通过另一个二级构造函数代理主构造函数。在同一个类中代理另一个构造函数使用 this 关键字：
```
class Person(val name: String) {
    constructor (name: String, paret: Person) : this(name) {
        parent.children.add(this)
    }
}
```
没有声明构造函数，则有一个默认的无参构造函数。

##4\. 创建类的实例:
```
val invoice = Invoice()
val customer = Customer("Joe Smith")
```

##5\. 继承
所有类的基类：Any，类似Java中的Object

所有非抽象类默认都是不可继承的（java中的final），如果要被子类继承，需要使用`open`关键字（与java中的final功能相反），继承用`:`操作符。
```
open class Base(p: Ont)
class Derived(p: Int) : Base(p)
```
方法如果要被重写，则也需要是`open`的，不想被重写就加`final`
```
open class AnotherDerived() : Base() {
    final override fun v() {}
}
```
方法重写规则：如果有多个相同的方法（继承或者实现自其他类，如A、B类），则必须要重写该方法，使用super范型去选择性地调用父类的实现。
```
open class A {
    open fun f () { print("A") }
    fun a() { print("a") }
}

interface B {
    fun f() { print("B") } //接口的成员变量默认是 open 的
    fun b() { print("b") }
}

class C() : A() , B{
    override fun f() {
        super<A>.f()//调用 A.f()
        super<B>.f()//调用 B.f()
    }
}
```

##6\. 抽象类
`abstract`关键字，抽象类和函数默认是`open`的。
```
open class Base {
    open fun f() {}
}

abstract class Derived : Base() {
    override abstract fun f()
}
```

##7\. 伴随对象
使用伴随对象可以直接使用类名来访问（用法类似Java中的static，但是不一样）：
```
class MyClass {
    companion object {
        var BASE_URL: String = "BASE_URL";
    }
}

println("BASE_URL: " + MyClass.BASE_URL)
```
与java的static不同，运行时它们仍然是真正对象的成员实例，比如可以实现接口：
```
inerface Factory<T> {
    fun create(): T
}

class MyClass {
    companion object : Factory<MyClass> {
        override fun create(): MyClass = MyClass()
    }
}
```

##8\. Getter 和 Setter 函数
一般定义变量的时候有默认的getter/setter方法；如果使用$访问，则可以避开getter/setter方法。
```
var stringRepresentation: String
    get() = this.toString()
    set (value) {
        setDataFormString(value)
}
```
改变一个访问者的可见性或者注解它，可以不用改变默认的实现:
```
var settVisibilite: String = "abc"//非空类型必须初始化
    private set // setter 是私有的并且有默认的实现
var setterVithAnnotation: Any?
    @Inject set // 用 Inject 注解 setter
```

##9\. 接口
可以包含抽象方法，以及方法的默认实现。可以有属性但必须是抽象的。一个类或对象可以实现一个或多个接口。
```
interface MyInterface {
    fun bar()
    fun foo() {
        //函数体是可选的
    }
}
```
接口属性不能赋值，需要被子类override：
```
interface MyInterface {
    val property: Int //抽象属性
    fun foo() {
        println(property)
    }
}
class Child : MyInterface {
    override val property: Int = 29
}
输出：29
```

##10\. 可见性修饰词
- private: 只在该类(以及它的成员)中可见
- protected: 和 private 一样但在子类中也可见
- internal: 在本模块的所有可以访问该类的均可以访问该类的所有 internal 成员
- public: 任何地方可见

##11\. 数据类
使用`data`关键词修饰类，则会自动添加`equals()/hashCode`, `toString`, `[compontN()functions]对应按声明顺序出现的所有属性`, `copy()`
```
data class User(val name: String, val age: Int)
```
组件函数允许数据类在多重声明中使用：
```
val jane = User("jane", 35)
val (name, age) = jane
println("$name, $age years of age")
```

##12\. 内部类
类可以标记为 inner 这样就可以访问外部类的成员。内部类拥有外部类的一个对象引用：
```
class Outer {
    private val bar: Int = 1
    inner class Inner {
        fun foo() = bar
    }
}

val demo = Outer().Inner().foo()
```

##13\. 对象表达式
类似Java的匿名内部类，可以继承/实现多个：
```
var zhangsan = object : Person(), MyInterface{
        override val property: Int = 512

        override fun toString(): String {
            return "toString() modified"
        }
    }
println(zhangsan.toString())
```
一个没有父类的对象，我们可以这样写：
```
val adHoc = object {
    var x: Int = 0
    var y: Int = 0
}
print(adHoc.x + adHoc.y)
```

##14\. 代理
类代理：
```
interface Base {
    fun print()
}

class BaseImpl(val x: Int) : Base {
    override fun print() { printz(x) }
}

class Derived(b: Base) : Base by b

fun main() {
    val b = BaseImpl(10)
    Derived(b).print()
}
```
属性代理：
```
class Example {
    var p: String by Delegate()
}
class Delegate {
    fun get(thisRef: Any?, prop: PropertyMetadata): String {
        return "$thisRef, thank you for delegating '${prop.name}' to me !"
    }

    fun set(thisRef: Any?, prop: PropertyMatada, value: String) {
        println("$value has been assigned to '${prop.name} in $thisRef.'")
    }
}
val e = Example()
pintln(e.p)

输出：Example@33a17727, thank you for delegating ‘p’ to me!
```
[标准代理](http://huanglizhuo.gitbooks.io/kotlin-in-chinese/content/ClassesAndObjects/DelegationProperties.html)

__参考：__
1\. <http://kotlinlang.org/docs/reference/basic-syntax.html>
2\. <http://huanglizhuo.gitbooks.io/kotlin-in-chinese>