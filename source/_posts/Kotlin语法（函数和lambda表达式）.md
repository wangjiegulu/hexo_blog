---
title: Kotlin语法（函数和lambda表达式）
tags: [kotlin, lambda]
date: 2015-09-11 18:35:00
---

#三、函数和lambda表达式
##1\. 函数声明
```
fun double(x: Int): Int {

}
```
函数参数是用 Pascal 符号定义的　name:type。参数之间用逗号隔开，每个参数必须指明类型。函数参数可以有默认参数。这样相比其他语言可以减少重载。
```
fun read(b: Array<Byte>, off: Int = 0, len: Int = b.size() ) {
...
}
```
##2\. 命名参数
在调用函数时可以参数可以命名。这对于有很多参数或只有一个的函数来说很方便。
```
fun reformat(str: String, normalizeCase: Boolean = true,upperCaseFirstLetter: Boolean = true,
             divideByCamelHumps: Boolean = false,
             wordSeparator: Char = ' ') {
...
}
reformat(str,
    normalizeCase = true,
    uppercaseFirstLetter = true,
    divideByCamelHumps = false,
    wordSeparator = '_'
  )
```
##3\. 变长参数:
```
fun asList<T>(vararg ts: T): List<T> {
    val result = ArrayList<T>()
    for (t in ts)
        result.add(t)
    return result
}
```
传递一个 array 的内容给函数，我们就可以使用 * 前缀操作符：
```
val a = array(1, 2, 3)
val list = asList(-1, 0, *a, 4)
```
Kotlin 中可以在文件个根级声明函数，这就意味者你不用创建一个类来持有函数。除了顶级函数，Kotlin 函数可以声明为局部的，作为成员函数或扩展函数。
Kotlin 支持局部函数，比如在另一个函数使用另一函数。局部函数可以访问外部函数的局部变量(比如闭包)。局部函数甚至可以返回到外部函数

##4\. 高阶函数
高阶函数就是可以接受函数作为参数并返回一个函数的函数。比如 lock() 就是一个很好的例子，它接收一个 lock 对象和一个函数，运行函数并释放 lock;
```
fun lock<T>(lock: Lock, body: () -> T ) : T {
    lock.lock()
    try {
        return body()
    }
    finally {
        lock.unlock()
    }
}
```
其实最方便的办法是传递一个字面函数(通常是 lambda 表达式)：
```
val result = lock(lock, { sharedResource.operation() })
```
在 kotlin 中有一个约定，如果最后一个参数是函数，可以省略括号：
```
lock (lock) {
    sharedResource.operation()
}
```

##5\. 字面函数
- 字面函数被包在大括号里
- 参数在 -> 前面声明(参数类型可以省略)
- 函数体在 -> 之后

字面函数或函数表达式就是一个 "匿名函数"，也就是没有声明的函数，但立即作为表达式传递下去。

##6\. 函数类型
如：(T, T) -> Boolean
注意如果一个函数接受另一个函数做为最后一个参数，该函数文本参数可以在括号内的参数列表外的传递。

##7\. 函数文本语法
函数文本的完全写法是下面这样的：
```
val sum = {x: Int,y: Int -> x + y}
```
函数文本总是在大括号里包裹着，在完全语法中参数声明是在括号内，类型注解是可选的，函数体是在　-> 之后，像下面这样：
```
val sum: (Int, Int) -> Int = {x, y -> x+y }
```

##8\. 函数表达式
```
fun(x: Int, y: Int ): Int = x + y
```

##9\. 内联函数
在高阶函数前增加inline注解可以指定函数內联。inline 标记即影响函数本身也影响传递进来的 lambda 函数：所有的这些都将被关联到调用点。
内联可能会引起生成代码增长，所以可以使用noinline来指定某些函数不进行內联。

注意有些内联函数可以调用传递进来的 lambda 函数，但不是在函数体，而是在另一个执行的上下文中，比如局部对象或者一个嵌套函数。在这样的情形中，非局部的控制流也不允许在lambda 函数中。为了表明，lambda 参数需要有 InlineOptions.ONLY_LOCAL_RETURN 注解

__参考：__
1\. <http://kotlinlang.org/docs/reference/basic-syntax.html>
2\. <http://huanglizhuo.gitbooks.io/kotlin-in-chinese>

