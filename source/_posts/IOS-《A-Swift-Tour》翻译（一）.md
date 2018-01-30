---
title: '[IOS]《A Swift Tour》翻译（一）'
tags: [iOS, swift, 翻译]
date: 2014-06-04 23:06:00
---

<span style="color: #ff0000;">**以下翻译内容为原创，转载请注明：**</span>

<span style="color: #ff0000;">**来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/3768936.html](http://www.cnblogs.com/tiantianbyconan/p/3768936.html)**</span>

&nbsp;

碎碎念。。。

Swift是苹果在WWDC刚发布的新语言，本人也没学过，现在看苹果官方文档一边翻译一边学习，再加上英语水平和对编程理解很有限，有错误的地方请大家指出，翻译只供参考，建议阅读[苹果Swift官方的文档](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/GuidedTour.html#//apple_ref/doc/uid/TP40014097-CH2-XID_1)

&nbsp;

<span class="s1">Swift 之旅</span>

<span class="s1">按照传统，在开始学习一门新的语言时写的第一个程序应该是在屏幕上打印&ldquo;Hello, World&rdquo;，这个可以用一行来完成：</span>

&nbsp;

<span class="s1">print(&ldquo;Hello, world&rdquo;)</span>

&nbsp;

<span class="s1">&nbsp;如果你有写过C或者Objective-C的经验，这个语法你应该会感觉很熟悉&mdash;&mdash;在Swift中，这行代码就是一个完整的程序。你不需要像输入输出流或者字符串处理等那样去导入另外的具有功能性的库。在全局范围编写的代码即是程序的入口点，所以你不需要一个main方法。你也不需要在每个语句后面写上分号。</span>

<span class="s1">&nbsp; &nbsp; 这个旅程会带给你足够的信息让你用Swift来完成各种编程任务。不用担心你是否懂得一些编程&mdash;&mdash;这本书对各个方面都进行来详细的介绍。</span>

&nbsp;

&nbsp;

基本数据

<span class="s1">&nbsp; &nbsp; 使用let来表示一个常量，使用var来表示一个变量。常量的值不需要在编译时期被知道，但是你必须且只能一次分配一个值给它。这表示你一旦给这个常量分配了一个值，你就能在很多地方使用它了。</span>

&nbsp;

<span class="s1">var myVariable = 42;</span>

<span class="s1">myVariable = 50;</span>

<span class="s1">let myConstant = 42;</span>

&nbsp;

<span class="s1">一个常量或者变量的类型必须要跟你分配给它的值的类型一致。然而，你一般不需要精确的写明它的类型。当你创建了一个常量或者变量，并赋值后，编译器会自动推断出它的类型。比如在上面的例子中，编译器会推断出myVariable是一个integer，因为它的初始值就是一个integer。</span>

<span class="s1">如果初始值不能提供足够的信息（或者它根本没有初始值），可以在这个变量后面加上冒号，然后写上指定类型。</span>

&nbsp;

<span class="s1">let implicitInteger = 70</span>

<span class="s1">let implicitDouble = 70.0</span>

<span class="s1">let explicitDouble: Double = 70</span>

&nbsp;

<span class="s1">值不会隐式地被转换成另一种类型。如果你需要转换成一个不同类型的值，显示地生成一个期望类型的实例。</span>

&nbsp;

<span class="s1">let label = &ldquo;The width is &rdquo;</span>

<span class="s1">let width = 94</span>

<span class="s1">let widthLabel = label + String(width)</span>

&nbsp;

<span class="s1">还有一个更简单的方法，在字符串中包含变量值：写一对括号里面写一个变量值，然后在括号前面写一个反斜杠，举个例子：</span>

&nbsp;

<span class="s1">let apples = 3</span>

<span class="s1">let oranges = 5</span>

<span class="s1">let appleSummary = &ldquo;I have \(apples) apples.&rdquo;</span>

<span class="s1">let fruitSummary = &ldquo;I have \(apples + oranges) pieces of fruit.&rdquo;</span>

&nbsp;

<span class="s1">使用中括号（[]）来创建一个数组或者字典，使用index（索引）或者key（键）访问他们的某一项。</span>

&nbsp;

<span class="s1">var shoppingList = [&ldquo;catfish&rdquo;, &ldquo;water&rdquo;, &ldquo;tulips&rdquo;, &ldquo;blue paint&rdquo;]</span>

<span class="s1">shoppingList[1] = &ldquo;bottle of water&rdquo;</span>

<span class="s1">var occupations = [</span>

<span class="s1">&ldquo;Malcolm&rdquo;: &ldquo;Captain&rdquo;,</span>

<span class="s1">&ldquo;Kaylee&rdquo;: &ldquo;Mechanic&rdquo;,</span>

<span class="s1">]</span>

<span class="s1">occupations[&ldquo;Jayne&rdquo;] = &ldquo;Public Relations&rdquo;</span>

&nbsp;

<span class="s1">使用初始化器的语法来创建一个空的数组或者字典。</span>

&nbsp;

<span class="s1">let emptyArray = String[]()</span>

<span class="s1">let emptyDictionary = Dictionary&lt;String, Float&gt;()</span>

&nbsp;

<span class="s1">如果类型信息是可推断的，你可以使用[]创建一个空的数组，使用[:]来创建一个空的字典，举个例子，当你设置一个新的值或者往方法中传入一个变量作为参数</span>

&nbsp;

<span class="s1">shoppingList = []</span>

&nbsp;

<span class="s1">控制语句</span>

<span class="s1">使用if和switch来创建一个条件，使用for-in，for，while和do-while来创建一个循环。</span>

<span class="s1">条件和循环变量上的括号是可选的。if后面大括号和循环体的大括号是必须的。</span>

&nbsp;

<span class="s1">let individualScores = [75, 43, 103, 87, 12]</span>

<span class="s1">var teamScore = 0</span>

<span class="s1">for score in individualScores{</span>

<span class="s1">if score &gt; 50{</span>

<span class="s1">teamScore += 3</span>

<span class="s1">}else{</span>

<span class="s1">teamScore += 1</span>

<span class="s1">}</span>

<span class="s1">}</span>

<span class="s1">teamScore</span>

&nbsp;

<span class="s1">在一个if语句中，条件必须是一个布尔类型的表达式&mdash;&mdash;这表示像if score { &hellip; }这样的代码是错误的，这个score并不是隐式地去跟0比较。</span>

&nbsp;

<span class="s1">你可以在值可能为空的时候同时使用if和let。这些值就被表示为可选地。一个可选的值可能包含一个值或者包含一个nil，nil表示这个值是空。在这个值的类型后面写上一个疑问符号（?）可以把这个值标记为可选的。</span>

&nbsp;

<span class="s1">var optionalString: String? = &ldquo;Hello&rdquo;</span>

<span class="s1">optionalString == nil</span>

&nbsp;

<span class="s1">var optionalName: String? = &ldquo;John Appleseed&rdquo;</span>

<span class="s1">var greeting = &ldquo;Hello!&rdquo;</span>

<span class="s1">if let name = optionalName{</span>

<span class="s1">greeting = &ldquo;Hello, \(name)&rdquo;</span>

<span class="s1">}</span>

&nbsp;

<span class="s1">如果可选值是nil，那么这个条件就为false，大括号中代码就会跳过。否则，可选值执行后面代码块中的代码并分配给let后面的常数。</span>

<span class="s1">Switches支持各种数据和各种各样的比较操作&mdash;&mdash;它们不局限于integers和相等式的比较。</span>

&nbsp;

<span class="s1">let vegetable = &ldquo;red pepper&rdquo;</span>

<span class="s1">switch vegetable{</span>

<span class="s1">case &ldquo;celery&rdquo;:</span>

<span class="s1">let vegetableComment = &ldquo;Add some raisins and make ants on a log.&rdquo;</span>

<span class="s1">case &ldquo;cucumber&rdquo;, &ldquo;watercress&rdquo;:</span>

<span class="s1">let vegetableComment = &ldquo;That would make a good tea sandwich.&rdquo;</span>

<span class="s1">case let x where x.hasSuffix(&ldquo;pepper&rdquo;):</span>

<span class="s1">let vegetableComment = &ldquo;Is it a spicy \(x)?&rdquo;</span>

<span class="s1">default:</span>

<span class="s1">let vegetableComment = &ldquo;Everything tastes good in soup.&rdquo;</span>

<span class="s1">}</span>

&nbsp;

&nbsp;

<span class="s1">在匹配的case中执行完代码后，程序退出switch语句。执行不会在下一个case中继续，所以不需要显示的在每个cases中的最后依次写上跳出该switch的break语句。</span>

<span class="s1">你可以使用for-in语句来迭代键值对形式的字典中的所有items。</span>

&nbsp;

<span class="s1">let interestingNumbers = [</span>

<span class="s1">&ldquo;Prime&rdquo;: [2, 3, 5, 7, 11, 13],</span>

<span class="s1">&ldquo;Fibonacci&rdquo;: [1, 1, 2, 3, 5, 8],</span>

<span class="s1">&ldquo;Square&rdquo;: [1, 4, 9, 16, 25],</span>

<span class="s1">]</span>

<span class="s1">var largest = 0</span>

<span class="s1">for(kind, numbers) in interestingNumbers{</span>

<span class="s1">for number in numbers{</span>

<span class="s1">if number &gt; largest{</span>

<span class="s1">largest = number</span>

<span class="s1">}</span>

<span class="s1">}</span>

<span class="s1">}</span>

<span class="s1">largest</span>

&nbsp;

&nbsp;

<span class="s1">使用while来重复代码块中的代码，直到条件改变。循环条件也可以放在最后，可以确保这个循环至少执行一次。</span>

&nbsp;

<span class="s1">var n = 2</span>

<span class="s1">while n &lt; 100{</span>

<span class="s1">n = n * 2</span>

<span class="s1">}</span>

<span class="s1">n</span>

&nbsp;

<span class="s1">var m = 2</span>

<span class="s1">do{</span>

<span class="s1">m = m * 2</span>

<span class="s1">} while m &lt; 100</span>

<span class="s1">m</span>

&nbsp;

<span class="s1">你可以在循环中保持一个索引index&mdash;&mdash;通过使用..来限定一个索引范围或者指明初始值，条件和增量。下面两个结果一样的循环：</span>

&nbsp;

<span class="s1">var firstForLoop = 0</span>

<span class="s1">for i in 0..3{</span>

<span class="s1">firstForLoop += i</span>

<span class="s1">}</span>

<span class="s1">firstForLoop</span>

&nbsp;

<span class="s1">var secondForLoop = 0</span>

<span class="s1">for var i = 0; i &lt; 3; ++i{</span>

<span class="s1">secondForLoop += 1</span>

<span class="s1">}</span>

<span class="s1">secondForLoop</span>

&nbsp;

<span class="s1">使用..来限定范围会省略范围的上限值，使用...来限定范围会包含所有限定值。（译者注：..是左闭右开整数区间，&hellip;是左闭右闭整数区间）</span>

&nbsp;

&nbsp;

&nbsp;

