---
title: java 工厂模式
tags: []
date: 2012-11-19 21:18:00
---

<span>工厂模式细分有三种，分别为：简单工厂模式、工厂方法模式、抽象工厂模</span><span>式</span>

<span>现单个的讲，最后再讲这三个的区别</span>
<span>这篇文章主要通过一个农场的实例来讲解，这也是java与模式书中的例</span><span>子，只不过我对一些部分进行了简化，一些部分进行了扩充，以帮助理解例</span><span>子如下：</span>
<span>有一个农场公司，专门向市场销售各类水果有如下水果：</span>
<span>葡萄（grape）</span>
<span>草莓（strawberry）</span>
<span>苹果（apple）</span>

<span>**简单工厂模式：**</span>

<span><span>这个比较简单，写一下源代码源代码中给出了必须的注释代码比书上的要</span><span>简单一些，排版也好看一些，只是为了让新手更好的理解</span></span>

<span><span><span>Fruit.java:</span></span></span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> Fruit
{
</span><span style="color: #008000;">/**</span><span style="color: #008000;">
* 水果与其它植物相比有一些专门的属性，以便与农场的
* 其它植物区分开这里的水果假设它必须具备的方法：
* 生长grow()收获harvest()种植plant()
</span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">void</span><span style="color: #000000;"> grow();
</span><span style="color: #0000ff;">void</span><span style="color: #000000;"> harvest();
</span><span style="color: #0000ff;">void</span><span style="color: #000000;"> plant();
}</span></pre>
</div>

<span>下面是Apple类的函数Apple.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Apple <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
</span><span style="color: #008000;">/**</span><span style="color: #008000;"> 
* 苹果是水果类的一种，因此它必须实现水果接口的所有方法即
* grow()harvest()plant()三个函数另外，由于苹果是多年生植物，
* 所以多出一个treeAge性质，描述苹果的树龄
</span><span style="color: #008000;">*/</span>

<span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> treeAge;

</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> grow() { <span style="color: #008000;">//</span><span style="color: #008000;">苹果的生长函数代码 }</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> harvest() { <span style="color: #008000;">//</span><span style="color: #008000;">苹果的收获函数代码 }</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> plant() { <span style="color: #008000;">//</span><span style="color: #008000;">苹果的种植函数代码 }</span>

<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> getTreeAge() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> treeAge; }
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setTreeAge(<span style="color: #0000ff;">int</span> treeAge) { <span style="color: #0000ff;">this</span>.treeAge =<span style="color: #000000;"> treeAge; }
}</span></pre>
</div>

<span>下面是Grape类的函数Grape.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Grape <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
</span><span style="color: #008000;">/**</span><span style="color: #008000;"> 
* 葡萄是水果类的一种，因此它必须实现水果接口的所有方法即
* grow()harvest()plant()三个函数另外，由于葡萄分为有籽和无籽
* 两种，因此多出一个seedless性质，描述葡萄有籽还是无籽
</span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> seedless;

</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> grow() { <span style="color: #008000;">//</span><span style="color: #008000;">葡萄的生长函数代码 }</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> harvest() { <span style="color: #008000;">//</span><span style="color: #008000;">葡萄的收获函数代码 }</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> plant() { <span style="color: #008000;">//</span><span style="color: #008000;">葡萄的种植函数代码 }</span>

<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span> getSeedless() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> seedless; }
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setSeedless(<span style="color: #0000ff;">boolean</span> seedless) { <span style="color: #0000ff;">this</span>.seedless =<span style="color: #000000;"> seedless; }

}</span></pre>
</div>

<span>下面是Strawberry类的函数Strawberry.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Strawberry <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
</span><span style="color: #008000;">/**</span><span style="color: #008000;"> 
* 草莓是水果类的一种，因此它必须实现水果接口的所有方法即
* grow()harvest()plant()三个函数另外，这里假设草莓分为大棚草莓和一般
* 草莓（即没有棚的草莓）因此草莓比一般水果多出一个性质coteless，描述草莓
* 是大棚草莓还是没有大棚的草莓
</span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> coteless;
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> grow() { <span style="color: #008000;">//</span><span style="color: #008000;">草莓的生长函数代码 }</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> harvest() { <span style="color: #008000;">//</span><span style="color: #008000;">草莓的收获函数代码 }</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> plant() { <span style="color: #008000;">//</span><span style="color: #008000;">草莓的种植函数代码 }</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span> getCoteless() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> coteless; }
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setCoteless(<span style="color: #0000ff;">boolean</span> coteless) { <span style="color: #0000ff;">this</span>. coteless =<span style="color: #000000;"> coteless; }
}</span></pre>
</div>

<span>农场的园丁也是系统的一部分，自然要有一个合适的类来代表，我们用FruitGardener类</span>
<span>来表示FruitGardener类会根据客户端的要求，创建出不同的水果对象，比如苹果（apple）,</span>
<span>葡萄（grape）或草莓（strawberry）的实例代码如下所示：</span>
<span>FruitGardener.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> FruitGardener
{
</span><span style="color: #008000;">/**</span><span style="color: #008000;">
* 通过下面的表态工厂方法，可以根据客户的需要，创建出不同的水果对象
* 如果提供的参数是apple则通过return new Apple()创建出苹果实例
* 如果是提供的参数是grape则创建葡萄实例，这正是简单工厂方法之精髓
</span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> Fruit factory(String which) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> BadFruitException
{
　　</span><span style="color: #0000ff;">if</span> (which.equalsIgnoreCase("apple")) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> Apple(); }
　　</span><span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span> (which.equalsIgnoreCase("strawberry")) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> Strawberry(); }
　　</span><span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span> (which.equalsIgnoreCase("grape")) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> Grape(); }
　　</span><span style="color: #0000ff;">else</span> { <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> BadFruitException("Bad fruit request"<span style="color: #000000;">); }
　　}
}</span></pre>
</div>

<span>简单工厂方法的优点是当在系统中引入新产品时不必修改客户端，但需要个修改工厂</span><span>类，将必要的逻辑加入到工厂类中工厂方法模式就克服了以上缺点，下面谈谈工厂</span><span>方法模式</span>

<span>-------------------------------------------------------------------------------------------------------------------------------------</span>

<span>**工厂方法模式:**</span>

<span><span>由于水果接口以及grape类strawberry类apple类的代码都和上面的一样，所以下</span><span>面相关的源码去掉了注释</span>
<span>Fruit.java:</span></span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> Fruit
{
　　</span><span style="color: #0000ff;">void</span><span style="color: #000000;"> grow();
　　</span><span style="color: #0000ff;">void</span><span style="color: #000000;"> harvest();
　　</span><span style="color: #0000ff;">void</span><span style="color: #000000;"> plant();
}</span></pre>
</div>

<span>Apple.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Apple <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
　　</span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> treeAge;
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> grow() { <span style="color: #008000;">//</span><span style="color: #008000;">苹果的生长函数代码 }</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> harvest() { <span style="color: #008000;">//</span><span style="color: #008000;">苹果的收获函数代码 }</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> plant() { <span style="color: #008000;">//</span><span style="color: #008000;">苹果的种植函数代码 }</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">int</span> getTreeAge() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> treeAge; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setTreeAge(<span style="color: #0000ff;">int</span> treeAge) { <span style="color: #0000ff;">this</span>.treeAge =<span style="color: #000000;"> treeAge; }
}</span></pre>
</div>

<span>Grape.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Grape <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
　　</span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> seedless;
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> grow() { <span style="color: #008000;">//</span><span style="color: #008000;">葡萄的生长函数代码 }</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> harvest() { <span style="color: #008000;">//</span><span style="color: #008000;">葡萄的收获函数代码 }</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> plant() { <span style="color: #008000;">//</span><span style="color: #008000;">葡萄的种植函数代码 }</span>

　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span> getSeedless() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> seedless; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setSeedless(<span style="color: #0000ff;">boolean</span> seedless) { <span style="color: #0000ff;">this</span>.seedless =<span style="color: #000000;"> seedless; }
}</span></pre>
</div>

<span>Strawberry.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Strawberry <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
　　</span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> coteless;
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> grow() { <span style="color: #008000;">//</span><span style="color: #008000;">草莓的生长函数代码 }</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> harvest() { <span style="color: #008000;">//</span><span style="color: #008000;">草莓的收获函数代码 }</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> plant() { <span style="color: #008000;">//</span><span style="color: #008000;">草莓的种植函数代码 }</span>
　　<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span> getCoteless() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> coteless; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setCoteless(<span style="color: #0000ff;">boolean</span> coteless) { <span style="color: #0000ff;">this</span>. coteless =<span style="color: #000000;"> coteless; }
}</span></pre>
</div>

<span>下面的源码就是工厂方法模式的重点了，在简单工厂模式中，将这里将FruitGardener定</span><span>义为一个类，即园丁要管理园里的所有水果，如果园丁哪天病了，水果都不能管理了</span><span>在工厂方法模式中将FruitGardener定义为一个接口，而将管理水果的角色划分得更细，</span><span>比如有</span><span>葡萄园丁、草莓园丁、苹果园丁等等具体角色，实现FruitGardener接口的工厂</span><span>方法源码如下所示：</span>
<span>接口FruitGardener的源码：</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> FruitGardener
{
　　Fruit factory();
}</span></pre>
</div>

<span>苹果园丁类AppleGardener.java的源码：</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> AppleGardener <span style="color: #0000ff;">implements</span><span style="color: #000000;"> FruitGardener
{
　　</span><span style="color: #0000ff;">public</span> Fruit factory() { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> Apple(); }
}</span></pre>
</div>

<span>葡萄园丁类GrapeGardener.java的源码：</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> GrapeGardener <span style="color: #0000ff;">implements</span><span style="color: #000000;"> FruitGardener
{
　　</span><span style="color: #0000ff;">public</span> Fruit factory() { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> Grape(); }
}</span></pre>
</div>

<span>草莓园丁类StrawberryGardener.java的源码：</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> StrawberryGardener <span style="color: #0000ff;">implements</span><span style="color: #000000;"> FruitGardener
{
　　</span><span style="color: #0000ff;">public</span> Fruit factory() { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> Strawberry(); }
}</span></pre>
</div>

<span>由以上源码可以看出，使用工厂方法模式保持了简单工厂模式的优点，克服了其缺点，</span><span>当在系统中引入新产品时，既不必修改客户端，又不必修改具体工厂角色可以较好</span><span>的对系统进行扩展</span>

<span>--------------------------------------------------------------------------------------------------------------------------------</span>

<span>**抽象工厂模式：**
<span>现在工厂再次大发展，要引进塑料大棚技术，在大棚里种植热带（Tropical）和亚热带的</span><span>水果和蔬菜（Veggie）其中水果分为TropicalFruit和NorthernFruit，蔬菜分为TropicalVeggie</span><span>和NorthernVeggie园丁包括TropicalGardener和NorthernGardener也就是说，</span><span>TropicalGardener专门管理TropicalFruit和TropicalGardener，NorthernGardener专门</span><span>管理NorthernFruit和NorthernVeggie抽象工厂模式在这个例子中的源码如下所示：</span>
<span>Fruit.java:</span></span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span> Fruit { }</pre>
</div>

<span>NorthernFruit.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> NorthernFruit <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
　　</span><span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
　　</span><span style="color: #0000ff;">public</span><span style="color: #000000;"> NorthernFruit(String name) { }
　　</span><span style="color: #0000ff;">public</span> String getName() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> name; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setName(String name) { <span style="color: #0000ff;">this</span>.name =<span style="color: #000000;"> name; }
}</span></pre>
</div>

<span>TropicalFruit.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> TropicalFruit <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
　　</span><span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
　　</span><span style="color: #0000ff;">public</span><span style="color: #000000;"> TropicalFruit(String name) { }
　　</span><span style="color: #0000ff;">public</span> String getName() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> name; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setName(String name) { <span style="color: #0000ff;">this</span>.name =<span style="color: #000000;"> name; }
}</span></pre>
</div>

<span>Veggie.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span> Veggie { }</pre>
</div>

<span>TropicalVeggie.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> TropicalVeggie <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Veggie
{
　　</span><span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
　　</span><span style="color: #0000ff;">public</span><span style="color: #000000;"> TropicalVeggie(String name) { }
　　</span><span style="color: #0000ff;">public</span> String getName() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> name; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setName(String name) { <span style="color: #0000ff;">this</span>.name =<span style="color: #000000;"> name; }
}</span></pre>
</div>

<span>NorthernVeggie.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> NorthernVeggie <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Veggie
{
　　</span><span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
　　</span><span style="color: #0000ff;">public</span><span style="color: #000000;"> NorthernVeggie(String name) { }
　　</span><span style="color: #0000ff;">public</span> String getName() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> name; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setName(String name) { <span style="color: #0000ff;">this</span>.name =<span style="color: #000000;"> name; }
}</span></pre>
</div>

<span>Gardener.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> Gardener
{
　　Fruit createFruit(String name);
　　Veggie createVeggie(String name);
}</span></pre>
</div>

<span>TropicalGardener.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> TropicalGardener <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Gardener
{
　　</span><span style="color: #0000ff;">public</span> Fruit createFruit(String name) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> TropicalFruit(name); }
　　</span><span style="color: #0000ff;">public</span> Veggie createVeggie(String name) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> TropicalVeggie(name); }
}</span></pre>
</div>

<span>NorthernGardener.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> NorthernGardener <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Gardener
{
　　</span><span style="color: #0000ff;">public</span> Fruit createFruit(String name) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> NorthernFruit(name); }
　　</span><span style="color: #0000ff;">public</span> Veggie createVeggie(String name) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> NorthernVeggie(name); }
}</span></pre>
</div>

<span>为了简单起见，这里只讲一下增加新产品（族）时该系统如何扩展（关于产品族相关</span><span>知识，请看此书的相关章节，不过不懂产品族也没有关系，这里写得很简单，肯定能</span><span>看懂）比如现在要增加南方水果（SouthFruit）和南方蔬菜（SouthVeggie）那</span><span>么只要增加如下代码即可很容易的扩展：</span>
<span>SouthFruit.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> SouthFruit <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Fruit
{
　　</span><span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
　　</span><span style="color: #0000ff;">public</span><span style="color: #000000;"> SouthFruit (String name) { }
　　</span><span style="color: #0000ff;">public</span> String getName() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> name; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setName(String name) { <span style="color: #0000ff;">this</span>.name =<span style="color: #000000;"> name; }
}</span></pre>
</div>

<span>SouthVeggie.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> SouthVeggie <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Veggie
{
　　</span><span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
　　</span><span style="color: #0000ff;">public</span><span style="color: #000000;"> SouthVeggie (String name) { }
　　</span><span style="color: #0000ff;">public</span> String getName() { <span style="color: #0000ff;">return</span><span style="color: #000000;"> name; }
　　</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setName(String name) { <span style="color: #0000ff;">this</span>.name =<span style="color: #000000;"> name; }
}</span></pre>
</div>

<span>SouthGardener.java:</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> SouthGardener <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Gardener
{
　　</span><span style="color: #0000ff;">public</span> Fruit createFruit(String name) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> SouthFruit(name); }
　　</span><span style="color: #0000ff;">public</span> Veggie createVeggie(String name) { <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> SouthVeggie(name); }
}</span></pre>
</div>

&nbsp;

&nbsp;

&nbsp;