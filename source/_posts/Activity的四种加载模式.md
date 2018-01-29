---
title: Activity的四种加载模式
tags: []
date: 2012-02-24 10:41:00
---

1、standard ：系统的默认模式，一次跳转即会生成一个新的实例。假设有一个activity命名为Act1，执行语句：
 startActivity(new Intent(Act1.this, Act1.class));
后Act1将跳转到另外一个Act1，也就是现在的栈里面有 Act1 的两个实例。按返回键后你会发现仍然是在Act1（第一个）里面。

2、singleTop：singleTop 跟standard 模式比较类似。唯一的区别就是，当跳转的对象是位于栈顶的activity（应该可以理解为用户眼前所 看到的activity）时，程序将不会生成一个新的activity实例，而是直接跳到现存于栈顶的那个activity实例。拿上面的例子来说，当Act1 为 singleTop 模式时，执行跳转后栈里面依旧只有一个实例，如果现在按返回键程序将直接退出。这个貌似用得比较少。

3、singleTask： singleTask模式和后面的singleInstance模式都是只创建一个实例的。在这种模式下，无论跳转的对象是不是位于栈顶的activity，程序都不会生成一个新的实例（当然前提是栈里面已经有这个实例）。这种模式相当有用，在以后的多activity开发中， 经常会因为跳转的关系导致同个页面生成多个实例，这个在用户体验上始终有点不好，而如果你将对应的activity声明为 singleTask 模式，这种问题将不复存在。不过前阵子好像又看过有人说一般不要将除开始页面的其他页面设置为 singleTask 模式，原因暂时不明，哪位知道的可以请教下。

4、singleInstance: 设置为 singleInstance 模式的 activity 将独占一个task（感觉task可以理解为进程），独占一个task的activity与其说是activity，倒不如说是一个应用，这个应用与其他activity是独立的，它有自己的上下文activity。拿一个例子来说明吧：
现在有以下三个activity: Act1、Act2、Act3，其中Acti2 为 singleInstance 模式。它们之间的跳转关系为： Act1 -- Act2 -- Act3 ，现在在Act3中按下返回键，由于Act2位于一个独立的task中，它不属于Act3的上下文activity，所以此时将直接返回到Act1。这就是singleInstance模式。