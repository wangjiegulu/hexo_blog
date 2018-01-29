---
title: WEB项目的分层结构
tags: []
date: 2012-11-30 11:04:00
---

**WEB****项目的分层结构**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;大部分的WEB应用在职责上至少被分成四层：表示层、持久层、业务层和域模块层。

**一、&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;****表示层**

一般来讲，一个典型的WEB应用的前端应该是表示层，可以使用Struts框架。

下面是Struts所负责的：

1、&nbsp;&nbsp;管理用户的请求，做出相应的响应。

2、&nbsp;&nbsp;提供一个流程控制，委派调用业务逻辑和其他上层处理。

3、&nbsp;&nbsp;处理异常。

4、&nbsp;&nbsp;为显示提供一个数据模型（即把数据对象设置到某一个范围内，用于前台获取数据）。

5、&nbsp;&nbsp;用户界面的验证。

以下内容，不该在Struts表示层的编码中经常出现，它们与表示层无关的。

1、&nbsp;&nbsp;与数据库直接通信。

2、&nbsp;&nbsp;与应用程序相关联的业务逻辑有校验

3、&nbsp;&nbsp;事务处理。

**二、&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;****持久层**

典型的WEB应用的后端是持久层。可以用Hibernate实现。Hibernate的持久对象是基于POJO（Plain Old Java Object）和Java集合的。

下面是Hibernate所负责的内容：

1、&nbsp;&nbsp;如何查询对象的相关信息。

Hibernate是通过一个面向对象查询语言（HQL）或正则表达的API来完成查询的。HQL非常类似于SQL，只是把SQL里的table和columns用Object和它的fields代替。

2、&nbsp;&nbsp;如何存储、更新、删除数据库记录。

3、&nbsp;&nbsp;Hibernate这类高级ORM框架支持大部分主流数据库，并且支持父表/子表关系、事务处理、继承和多态。

**三、&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;****业务层**

一个典型WEB应用的中间部分是业务层或服务层。可以用Spring来实现。

下面是业务层所负责的：

1、&nbsp;&nbsp;处理应用程序的业务逻辑和业务校验。

2、&nbsp;&nbsp;管理事务。

3、&nbsp;&nbsp;提供与其他层相互作用的接口。

4、&nbsp;&nbsp;管理业务层级别的对象的依赖。

5、&nbsp;&nbsp;在表示层和持久层之间增加一个灵活的机制，使得他们不直接联系在一起。

6、&nbsp;&nbsp;通过揭示从表示层到业务层之间的上下文来得到业务逻辑。

7、&nbsp;&nbsp;管理程序的执行（从业务层到持久层）。

**四、&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;****域模块层**

既然我们致力于一个WEB的应用，我们就需要一个对象集合，让它在不同层之间移动。域模块层由实际需求中业务对象组成，比如订单明细、产品、等。开发者在这层不用管哪些数据传输对象，而关注域对象即可。例如，Hibernate允许你将数据库中的信息存入域对象，这样你可以在连接断开的情况下把这些数据显示到用户界面层，而那些对象也可以返回给持久层，从而在数据库里更新。而且，你不必把对象转化成DTO（这可能导致它在不同层之间传输过程中丢失）。这个模型使得Java开发者能很自然运用面向编程，而不需要附加编码。