---
title: Kotlin语法（其他）
tags: [kotlin]
date: 2015-09-13 17:08:00
---

#三、其他
[TOC]
##1\. 多重声明
有时候可以通过给对象插入多个成员函数做区别是很方便的:
```
val (name, age) = person
```
多重声明一次创建了多个变量。我们声明了俩个新变量：name age 并且可以独立使用：
```
println(name)
println(age)
```
也可以在 for 循环中用:
```
for ((a, b) in collection) { ... }
```
map:
```
for ((key, value) in map) { ... }
```

##2\. Ranges
函数操作符是`:`
```
if (i in 1..10){ ... }
if (x !in 1.0..3.0) println(x)
if (str in "island".."isle") println(str)
for (i in 4 downTo 1) print(i) // prints '4321'
for (i in 1..4 step 2) print(i) // prints "13"
for (i in 4 downTo 1 step 2) print(i) // prints "42"
for (i in 1.0..2.0 step 0.3) print("$i ") // prints "1.0 1.3 1.6 1.9 "
for (i in (1..4).reversed()) print(i) // prints "4321"
for (i in (1..4).reversed() step 2) print(i) // prints "42"
```

##3\. 类型检查和转换
is !is 表达式: 类似Java的instanceof

“不安全”的转换符，如下的x不能为空，否则抛异常:
```
val x: String = y as String
```
"安全"转换符，如下不管 as? 右边的是不是一个非空 String 结果都会转换为可空的:
```
val x: String ?= y as? String
```

##4\. This 表达式
如果 this 没有应用者，则指向的是最内层的闭合范围。为了在其它范围中返回 this ，需要使用标签:`this@lable`

##5\. 等式
在 kotlin 中有两种相等：

- 参照相等: `===`，参照相等是通过 === 操作符判断的(不等是!== ) a===b 只有 a b 指向同一个对象是判别才成立。另外，你可以使用内联函数`identityEquals()` 判断参照相等。

- 结构相等: `==`，结构相等是通过 == 判断的。像`a == b`将会翻译成：`a?.equals(b) ?: b === null`，如果 a 不是 null 则调用 equals(Any?) 函数，否则检查 b 是否参照等于 null。

##6\. 运算符重载
[http://kotlinlang.org/docs/reference/operator-overloading.html](http://kotlinlang.org/docs/reference/operator-overloading.html)

##7\. 空安全
```
var a: String ="abc"
a = null // 编译错误
val l = a.length() // 因为a不能为null，所以不会报错
```
```
var b: String? = "abc"
b = null
val l = b.length() // 错误：b为空
val l = if (b != null) b.length() else -1 // 不会报错
b?.length() // 安全调用不会报错
```
安全调用在链式调用是是很有用的。比如，如果 Bob 是一个雇员可能分配部门(也可能不分配)，如果我们想获取 Bob 的部门名作为名字的前缀，就可以这样做：
```
bob?.department?.head?.name // 
```
__Elvis 操作符:__
```
val l: Int = if (b != null) b.length() else -1
```
也可以使用　Elvis 操作符`?:`:
```
val l = b.length()?: -1
```
如果 ?: 左边表达式不为空则返回，否则返回右边的表达式。注意右边的表带式只有在左边表达式为空是才会执行。

__!!操作符:__
第三个选择是 NPE-lovers。我们可以用 b!! ，这会返回一个非空的 b 或者抛出一个 b 为空的 NPE:
```
val l = b !!.length()
```
__安全转换:__
普通的转换可能产生 ClassCastException 异常。另一个选择就是使用安全转换，如果不成功就返回空：
```
val aInt: Int? = a as? Int
```

##8.异常
所有的异常类都是 Exception 的子类。使用方式与Java类似。
```
try {
  // some code
}
catch (e: SomeException) {
  // handler
}
finally {
  // optional finally block
}
```

##9.注解
注解是一种将元数据附加到代码中的方法。声明注解需要在类前面使用 annotation 关键字：
```
annotation class fancy
```
用法：在多数情形中 @ 标识是可选的。只有在注解表达式或本地声明中才必须
```
@fancy class Foo {
    @fancy fun baz(@fancy foo: Int): Int {
        return (@fancy 1)
    }
}
// 可省略@
fancy class Foo {
    fancy fun baz(fancy foo: Int): Int {
        @fancy fun bar() { ... }
        return (@fancy 1)
    }
}
```
如果要给构造函数注解，就需要在构造函数声明时添加 constructor 关键字，并且需要在前面添加注解：
```
class Foo @inject constructor (dependency: MyDependency)
```
注解可以有带参数的构造函数:
```
annotation class special(val why: String)
special("example") class Foo {}
```
注解也可以用在 Lambda 中。这将会应用到 lambda 生成的 invoke() 方法:
```
annotation class Suspendable
val f = @Suspendable { Fiber.sleep(10) }
```
java 注解在 kotlin 中是完全兼容的。
如果java 中的 value 参数有数组类型，则在 kotlin 中变成 vararg 参数:
```
// Java
public @interface AnnWithArrayValue {
    String[] value();
}
// Kotlin
AnnWithArrayValue("abc", "foo", "bar") class C
```
注解实例的值在 kotlin 代码中是暴露属性。

##10.反射
得到运行时的类引用:
```
val c = MyClass::class
```
引用是一种 KClass类型的值。你可以使用`KClass.properties` 和`KClass.extensionProperties`获取类和父类的所有属性引用的列表。

__函数引用__
使用`::`操作符:
```
fun isOdd(x: Int) =x % 2 !=0
val numbers = listOf(1, 2, 3)
println(numbers.filter( ::isOdd) ) //prints [1, 3]
```
这里`::isOdd`是是一个函数类型的值`(Int) -> Boolean` 

下面是返回一个由两个传递进去的函数的组合。现在你可以把它用在可调用的引用上了：
```
fun compose<A, B, C>(f: (B) -> C, g: (A) -> B): (A) -> C {
    return {x -> f(g(x))}
}

fun length(s: String) = s.size
val oddLength = compose(::isOdd, ::length)
val strings = listOf("a", "ab", "abc")
println(strings.filter(oddLength)) // Prints "[a, abc]"
```
__属性引用__
访问顶级类的属性，我们也可以使用`::`操作符：
```
var x = 1
fun main(args: Array<String>) {
    println(::x.get())
    ::x.set(2)
    println(x)
}
```
`::x`表达式评估为`KProperty<Int>`类型的属性，它允许我们使用`get()`读它的值或者使用名字取回它的属性。
```
class A(val p: Int)

fun main(args: Array<String>) {
    val prop = A::p
    println(prop.get(A(1))) // prints "1"
}
```
对于扩展属性：
```
val String.lastChar: Char
  get() = this[size - 1]

fun main(args: Array<String>) {
  println(String::lastChar.get("abc")) // prints "c"
}
```
__与 java 反射调用__
想找到一个备用字段或者 java getter 方法:
```
import kotlin.reflect.jvm.*

class A(val p: Int)

fun main(args: Array<String>) {
    println(A::p.javaGetter) // prints "public final int A.getP()"
    println(A::p.javaField)  // prints "private final int A.p"
}
```
__构造函数引用__
只需要使用`::`操作符并加上类名。下面的函数是一个没有参数并且返回类型是`Foo`:
```
calss Foo
fun function(factory : () -> Foo) {
    val x: Foo = factory()
}
function(:: Foo)
```

##11\. 动态类型
为了方便使用，`dynamic`应而生：
```
val dyn: dynamic = ...
```
`dynamic`类型关闭了 kotlin 的类型检查：
>这样的类型可以分配任意变量或者在任意的地方作为参数传递 任何值都可以分配为dynamic 类型，或者作为参数传递给任何接受 dynamic 类型参数的函数 这样的类型不做 null 检查

`dynamic`最奇特的特性就是可以在`dynamic`变量上调用任何属性或任何方法。
```
dyn.whatever(1, "foo", dyn) // 'whatever' is not defined anywhere
dyn.whatever(*array(1, 2, 3))
```
动态调用可以返回`dynamic`作为结果，因此我们可以轻松实现链式调用：
```
dyn.foo().bar.bat()
```
当给动态调用传递一个 lambda 表达式时，所有的参数默认都是`dynamic`：
```
dyn.foo {
  x -> x.bar() // x is dynamic
}
```

__参考：__
1\. <http://kotlinlang.org/docs/reference/basic-syntax.html>
2\. <http://huanglizhuo.gitbooks.io/kotlin-in-chinese>

