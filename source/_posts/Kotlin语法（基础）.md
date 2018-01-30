---
title: Kotlin语法（基础）
tags: [kotlin]
date: 2015-09-11 14:50:00
---

#一、基础语法：
##1\. 定义包名：
包名应该在源文件的最开头，包名不必和文件夹路径一致：源文件可以放在任意位置。
```
package my.demo
```

##2\. 定义函数：
```
fun sum(a: Int , b: Int) : Int{
　　return a + b
}
```
表达式函数体自动推断型的返回值：
```
fun sum(a: Int, b Int) = a + b
```

要想函数在模块外面可见就必须有一个确定的返回值：
```
public fun sum(a: Int, b: Int): Int = a + b
```
Unit相当于Java中的void，可省略

##3\. 定义变量：
- `var a: Int = 1`，普通变量
- `val a: Int = 1`，只读变量，相当于Java中的final
- `var a = 1`，可推导出Int类型

##4\. 字符串模板
```
fun main(args: Array<String>) {
    if (args.size() == 0) return
    print("First argument: ${args[0]}")
}
```
换行：\n

三个引号包(""")裹的,不包含分割符并且可以包含其它字符：
```
val text = """
    for (c in "foo")
        print(c)
"""
```

###5\. if语句
除了类似Java的用法，还可以当作表达式：
```
fun max(a: Int,  b: Int) = if (a > b) a else b
```
可直接返回if结果：
```
fun foo(param: Int){
    val result = if (param == 1) {
        "one"
    } else if (param == 2) {
        "two"
    } else {
        "three"
    }
}
```

###6\. 可空变量以及空值检查
声明可空变量：`var a:Int? = null`
函数返回可空：
```
fun parseInt(str : String): Int?{
}
```
调用时自动检查null：
```
val files = File("Test").listFiles()
println(files?.size)
```
调用时自动检查null（可设置如果为null时的默认值）：
```
val files = File("test").listFiles()
println(files?.size ?: "empty")
```
如果为空执行某操作：
```
val data = ...
val email = data["email"] ?: throw
IllegalStateException("Email is missing!")
```

如果不为空执行某操作：
```
val date = ...
data?.let{
    ...//如果不为空执行该语句块
}
```

###7\. 使用值检查
`is`：相当于Java中的instanceof, 是否是某个类型的实例。如果对一个不可变的局部变量属性检查是否是某种特定类型，就没有必要明确转换

###8\. 循环
```
for (arg in args){
    print(arg)
}
```
`While`等循环与Java一样

###9\. When表达式
相当于Java中的switch case，但是更强大。
```
fun cases(obj: Any) {
    when (obj) {
    1    -> print("one")
    "hello"    -> print("Greeting")
    is Long    -> print("Long")
    ! is Long    -> print("Not a string")
    else    -> print("Ubknow")
    }
}
```
可直接返回when的判断结果：
```
fun transform(color: String): Int {
    return when(color) {
        "Red" -> 0
        "Green" -> 1
        "Blue" -> 2
        else -> throw IllegalArgumentException("Invalid color param value")
    }
}
```

###10\. ranges & in
检查 in 操作符检查数值是否在某个范围内（同样适用于集合）：
```
if (x in 1..100){
    print("${x} in 1~100")
}
```
```
if (x !in 1..100){
    print("${x} not in 1~100")
}
```
使用 in 操作符检查集合中是否包含某个对象：
```
if (text in names) //将会调用nemes.contains(text)方法
    print("Yes)
```
遍历 map：
```
for ((k, v) in map) {
    print("$k -> $v")
}
```

###11\. 函数默认值
```
fun foo(a: Int = 0, b: String = "") {...}
```

###12\. 过滤 list
```
val positives = list.filter { x -> x >0 }
```
或者更短：
```
val positives = list.filter { it > 0 }
```

###13\. 只读 list/map
```
val list = listOf("a", "b", "c")
```
或者：
```
val map = maoOf("a" to 1, "b" to 2, "c" to 3)
```
获取map中的值：
```
println(map["key"])
map["key"] = value
```

###14\. 扩展函数(给现有类增添新函数)
```
fun String.spcaceToCamelCase() { ... }
"Convert this to camelcase".spcaceToCamelCase()
```

### 15\. 创建单例模式
```
object Resource {
    val name = "Name"
}
```

### 16\. try-catch
```
    try {
        count()
    }catch (e: ArithmeticException) {
        throw IllegaStateException(e)
    }
```
可直接返回try-catch结果：
```
fun test() {
    val result = try {
        count()
    }catch (e: ArithmeticException) {
        throw IllegaStateException(e)
    }
    //处理 result
}
```

### 17\. 返回与跳转
return break 结束最近的闭合循环 continue 跳到最近的闭合循环的下一次循环。

使用标签快速跳转：
```
loop@ for(i in 1..5){
        println("-i: $i")
        for(j in 11..17){
            if(14 == j){
                break@loop
            }
            println("-> j: $j")
        }
    }
```
输出：
```
-i: 1
-> j: 11
-> j: 12
-> j: 13
```
break 是跳转标签后面的表达式，continue 是跳转到循环的下一次迭代。</br>
return 允许我们返回到外层函数。最重要的例子就是从字面函数中返回。

__参考：__
1\. <http://kotlinlang.org/docs/reference/basic-syntax.html>
2\. <http://huanglizhuo.gitbooks.io/kotlin-in-chinese>

