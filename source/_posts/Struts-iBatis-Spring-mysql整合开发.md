---
title: Struts+iBatis+Spring+mysql整合开发
tags: [struts, ibatis, spring, mysql, database, j2ee, java web]
date: 2013-03-03 14:54:00
---

<span style="color: #800000;">**<span style="line-height: 1.5;">转载请注明：[<span style="color: #800000;">http://www.cnblogs.com/tiantianbyconan/archive/2013/03/03/2941554.html</span>](http://www.cnblogs.com/tiantianbyconan/archive/2013/03/03/2941554.html)</span>**</span>

<span style="line-height: 1.5;">本文使用Struts+iBatis+Spring三层框架开实现对user表的CRUD。</span>

<span style="line-height: 1.5;">分层如下：</span>

![](http://images.cnitblog.com/blog/378300/201303/03145921-9115e3b0b60448bab6e391c5233f80c8.jpg)

&nbsp;

<span style="line-height: 1.5;">iBatis配置文件（sqlMapConfig.xml）：</span>

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="UTF-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #0000ff;">&lt;!</span><span style="color: #ff00ff;">DOCTYPE sqlMapConfig      
    PUBLIC "-//ibatis.apache.org//DTD SQL Map Config 2.0//EN"      
    "http://ibatis.apache.org/dtd/sql-map-config-2.dtd"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #0000ff;">&lt;</span><span style="color: #800000;">sqlMapConfig</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">settings </span><span style="color: #ff0000;">cacheModelsEnabled</span><span style="color: #0000ff;">="true"</span><span style="color: #ff0000;"> enhancementEnabled</span><span style="color: #0000ff;">="true"</span><span style="color: #ff0000;">
        lazyLoadingEnabled</span><span style="color: #0000ff;">="true"</span><span style="color: #ff0000;"> errorTracingEnabled</span><span style="color: #0000ff;">="true"</span><span style="color: #ff0000;"> maxRequests</span><span style="color: #0000ff;">="32"</span><span style="color: #ff0000;">
        maxSessions</span><span style="color: #0000ff;">="10"</span><span style="color: #ff0000;"> maxTransactions</span><span style="color: #0000ff;">="5"</span><span style="color: #ff0000;"> useStatementNamespaces</span><span style="color: #0000ff;">="false"</span> <span style="color: #0000ff;">/&gt;</span>

    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">sqlMap </span><span style="color: #ff0000;">resource</span><span style="color: #0000ff;">="com/tiantian/ibatis/model/user.xml"</span> <span style="color: #0000ff;">/&gt;</span>

<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">sqlMapConfig</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

&nbsp;

struts.xml：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="UTF-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #0000ff;">&lt;!</span><span style="color: #ff00ff;">DOCTYPE struts PUBLIC
    "-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
    "http://struts.apache.org/dtds/struts-2.3.dtd"</span><span style="color: #0000ff;">&gt;</span>

<span style="color: #0000ff;">&lt;</span><span style="color: #800000;">struts</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">package </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="ibatis_test"</span><span style="color: #ff0000;"> extends</span><span style="color: #0000ff;">="struts-default"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 注册User action </span><span style="color: #008000;">--&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="registerUser"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="registerUserAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">action</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 删除User action </span><span style="color: #008000;">--&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="deleteUser"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="deleteUserAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">action</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 更新User action </span><span style="color: #008000;">--&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="updateUser"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="updateUserAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">action</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 查询所有User action </span><span style="color: #008000;">--&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="findAllUsers"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="findAllUsersAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">action</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 查询指定id的User action </span><span style="color: #008000;">--&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="findUserById"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="findUserByIdAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">action</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 模糊查询User action </span><span style="color: #008000;">--&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">action </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="findUsersBykeyword"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="findUsersBykeywordAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">action</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">package</span><span style="color: #0000ff;">&gt;</span>

<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">struts</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

&nbsp;

user.xml配置文件：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="UTF-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #0000ff;">&lt;!</span><span style="color: #ff00ff;">DOCTYPE sqlMap      
    PUBLIC "-//ibatis.apache.org//DTD SQL Map 2.0//EN"      
    "http://ibatis.apache.org/dtd/sql-map-2.dtd"</span><span style="color: #0000ff;">&gt;</span>
<span style="color: #0000ff;">&lt;</span><span style="color: #800000;">sqlMap</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 为Student类取个别名 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">typeAlias </span><span style="color: #ff0000;">alias</span><span style="color: #0000ff;">="UserAlias"</span><span style="color: #ff0000;"> type</span><span style="color: #0000ff;">="com.tiantian.ibatis.model.User"</span><span style="color: #0000ff;">/&gt;</span>

    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 配置表和实体Bean之间的映射关系 </span><span style="color: #008000;">--&gt;</span>  
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">resultMap </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="userMap"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.model.User"</span><span style="color: #0000ff;">&gt;</span>  
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">result </span><span style="color: #ff0000;">property</span><span style="color: #0000ff;">="id"</span><span style="color: #ff0000;"> column</span><span style="color: #0000ff;">="id"</span><span style="color: #0000ff;">/&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">result </span><span style="color: #ff0000;">property</span><span style="color: #0000ff;">="username"</span><span style="color: #ff0000;"> column</span><span style="color: #0000ff;">="username"</span><span style="color: #0000ff;">/&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">result </span><span style="color: #ff0000;">property</span><span style="color: #0000ff;">="password"</span><span style="color: #ff0000;"> column</span><span style="color: #0000ff;">="password"</span><span style="color: #0000ff;">/&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">result </span><span style="color: #ff0000;">property</span><span style="color: #0000ff;">="age"</span><span style="color: #ff0000;"> column</span><span style="color: #0000ff;">="age"</span><span style="color: #0000ff;">/&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">resultMap</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 添加数据 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">insert </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="registerUser"</span><span style="color: #ff0000;"> parameterClass</span><span style="color: #0000ff;">="UserAlias"</span><span style="color: #0000ff;">&gt;</span><span style="color: #000000;">
        INSERT INTO user VALUES (NULL, #username#, #password#, #age#);
    </span><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">insert</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 删除指定id的数据 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">delete </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="deleteUser"</span><span style="color: #ff0000;"> parameterClass</span><span style="color: #0000ff;">="UserAlias"</span><span style="color: #0000ff;">&gt;</span><span style="color: #000000;">
        DELETE FROM user WHERE id = #id#;
    </span><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">delete</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 修改指定id的数据 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">update </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="updateUser"</span><span style="color: #ff0000;"> parameterClass</span><span style="color: #0000ff;">="UserAlias"</span><span style="color: #0000ff;">&gt;</span><span style="color: #000000;">
        UPDATE user 
        SET username = #username#, password = #password#, age = #age#
        WHERE id = #id#;
    </span><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">update</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 查询所有User信息 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">select </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="findAllUsers"</span><span style="color: #ff0000;"> resultMap</span><span style="color: #0000ff;">="userMap"</span><span style="color: #0000ff;">&gt;</span><span style="color: #000000;">
        SELECT * FROM user;
    </span><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">select</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 查询指定id的User信息 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">select </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="findUserById"</span><span style="color: #ff0000;"> resultMap</span><span style="color: #0000ff;">="userMap"</span><span style="color: #0000ff;">&gt;</span><span style="color: #000000;">
        SELECT * FROM user WHERE id = #id#;
    </span><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">select</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 模糊查询 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">select </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="findUsersByKeyword"</span><span style="color: #ff0000;"> resultMap</span><span style="color: #0000ff;">="userMap"</span><span style="color: #0000ff;">&gt;</span><span style="color: #000000;">
        SELECT * FROM user WHERE username LIKE '%$keyword$%';
    </span><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">select</span><span style="color: #0000ff;">&gt;</span>

<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">sqlMap</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

&nbsp;

applicationContext.xml配置文件：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">&lt;?</span><span style="color: #ff00ff;">xml version="1.0" encoding="UTF-8"</span><span style="color: #0000ff;">?&gt;</span>
<span style="color: #0000ff;">&lt;</span><span style="color: #800000;">beans </span><span style="color: #ff0000;">xmlns</span><span style="color: #0000ff;">="http://www.springframework.org/schema/beans"</span><span style="color: #ff0000;">
    xmlns:xsi</span><span style="color: #0000ff;">="http://www.w3.org/2001/XMLSchema-instance"</span><span style="color: #ff0000;"> xmlns:p</span><span style="color: #0000ff;">="http://www.springframework.org/schema/p"</span><span style="color: #ff0000;">
    xsi:schemaLocation</span><span style="color: #0000ff;">="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.0.xsd"</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="dataSource"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="org.apache.commons.dbcp.BasicDataSource"</span><span style="color: #ff0000;">
        destroy-method</span><span style="color: #0000ff;">="close"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="driverClassName"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="com.mysql.jdbc.Driver"</span> <span style="color: #0000ff;">/&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="url"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="jdbc:mysql://localhost:3306/test"</span> <span style="color: #0000ff;">/&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="username"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="root"</span> <span style="color: #0000ff;">/&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="password"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="XXXX"</span> <span style="color: #0000ff;">/&gt;</span>

        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="validationQuery"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="select user.id from user"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="maxIdle"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="15"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="maxActive"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="15"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="maxWait"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="1000"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="sqlMapClient"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="org.springframework.orm.ibatis.SqlMapClientFactoryBean"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="configLocation"</span><span style="color: #ff0000;"> value</span><span style="color: #0000ff;">="classpath:sqlMapConfig.xml"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="dataSource"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="dataSource"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 事务管理 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="transactionManager"</span><span style="color: #ff0000;">
        class</span><span style="color: #0000ff;">="org.springframework.jdbc.datasource.DataSourceTransactionManager"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="dataSource"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="dataSource"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 声明式事务管理 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="baseTransactionProxy"</span><span style="color: #ff0000;">
        class</span><span style="color: #0000ff;">="org.springframework.transaction.interceptor.TransactionProxyFactoryBean"</span><span style="color: #ff0000;">
        abstract</span><span style="color: #0000ff;">="true"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="transactionManager"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="transactionManager"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="transactionAttributes"</span><span style="color: #0000ff;">&gt;</span>
            <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">props</span><span style="color: #0000ff;">&gt;</span>
                <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> 
                    表示设置事务属性所有以"find"和"get"开头的方法：
                    - PROPAGATION_REQUIRED: 当前存在事务则使用存在的事务，如果不存在，则开启一个新的事务
                    - readOnly:表示只读的事务
                 </span><span style="color: #008000;">--&gt;</span>
                <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">prop </span><span style="color: #ff0000;">key</span><span style="color: #0000ff;">="find*"</span><span style="color: #0000ff;">&gt;</span>PROPAGATION_REQUIRED,readOnly<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">prop</span><span style="color: #0000ff;">&gt;</span>
                <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">prop </span><span style="color: #ff0000;">key</span><span style="color: #0000ff;">="get*"</span><span style="color: #0000ff;">&gt;</span>PROPAGATION_REQUIRED,readOnly<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">prop</span><span style="color: #0000ff;">&gt;</span>
                <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">prop </span><span style="color: #ff0000;">key</span><span style="color: #0000ff;">="*"</span><span style="color: #0000ff;">&gt;</span>PROPAGATION_REQUIRED<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">prop</span><span style="color: #0000ff;">&gt;</span>
            <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">props</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> *****************************以上一般只需修改数据库配置******************************** </span><span style="color: #008000;">--&gt;</span>

    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> ********************************************************************* </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> *******************************DAO*********************************** </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> ********************************************************************* </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> DAO、Service一般都配置成singleton（可以不写，因为默认是singleton） </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="userDao"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.dao.impl.UserDaoImpl"</span><span style="color: #ff0000;"> scope</span><span style="color: #0000ff;">="singleton"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="sqlMapClient"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="sqlMapClient"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> ************************************************************************* </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> *******************************Service*********************************** </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> ************************************************************************* </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> Service，没有事务功能 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="userServiceTarget"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.service.impl.UserServiceImpl"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="userDao"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="userDao"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> Service的代理，目的是为Service添加事务的功能 </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="userService"</span><span style="color: #ff0000;"> parent</span><span style="color: #0000ff;">="baseTransactionProxy"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="target"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="userServiceTarget"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>

    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> ************************************************************************ </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> *******************************Action*********************************** </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> ************************************************************************ </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> Action一般都配置成prototype（必须要写!） </span><span style="color: #008000;">--&gt;</span>
<span style="color: #008000;">&lt;!--</span><span style="color: #008000;"> **User Actions** </span><span style="color: #008000;">--&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="registerUserAction"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.action.user.RegisterUserAction"</span><span style="color: #ff0000;"> scope</span><span style="color: #0000ff;">="prototype"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="userService"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="userService"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="deleteUserAction"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.action.user.DeleteUserAction"</span><span style="color: #ff0000;"> scope</span><span style="color: #0000ff;">="prototype"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="userService"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="userService"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="updateUserAction"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.action.user.UpdateUserAction"</span><span style="color: #ff0000;"> scope</span><span style="color: #0000ff;">="prototype"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="userService"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="userService"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="findAllUsersAction"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.action.user.FindAllUsersAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="userService"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="userService"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="findUserByIdAction"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.action.user.FindUserByIdAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="userService"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="userService"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">bean </span><span style="color: #ff0000;">id</span><span style="color: #0000ff;">="findUsersBykeywordAction"</span><span style="color: #ff0000;"> class</span><span style="color: #0000ff;">="com.tiantian.ibatis.action.user.FindUsersByKeywordAction"</span><span style="color: #0000ff;">&gt;</span>
        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property </span><span style="color: #ff0000;">name</span><span style="color: #0000ff;">="userService"</span><span style="color: #ff0000;"> ref</span><span style="color: #0000ff;">="userService"</span><span style="color: #0000ff;">&gt;&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span>
    <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">bean</span><span style="color: #0000ff;">&gt;</span>

<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">beans</span><span style="color: #0000ff;">&gt;</span></pre>
</div>

&nbsp;

DAO接口：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-3-1 下午5:44:21
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span><span style="color: #000000;"> UserDao {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> registerUser(User user);
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> deleteUser(User user);
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> updateUser(User user);
    </span><span style="color: #0000ff;">public</span> List&lt;User&gt;<span style="color: #000000;"> findAllUsers();
    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> User findUserById(User user);
    </span><span style="color: #0000ff;">public</span> List&lt;User&gt;<span style="color: #000000;"> findUsersByKeyword(String keyword);
}</span></pre>
</div>

DAO实现类（执行各个Action所需的数据库查询操作）：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.tiantian.ibatis.dao.impl;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> org.springframework.orm.ibatis.support.SqlMapClientDaoSupport;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.tiantian.ibatis.dao.UserDao;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.tiantian.ibatis.model.User;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-3-1 下午6:09:53
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> UserDaoImpl <span style="color: #0000ff;">extends</span> SqlMapClientDaoSupport <span style="color: #0000ff;">implements</span><span style="color: #000000;"> UserDao{

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> registerUser(User user) {
        getSqlMapClientTemplate().insert(</span>"registerUser"<span style="color: #000000;">, user);
    }

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> deleteUser(User user) {
        </span><span style="color: #0000ff;">boolean</span> result = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
        </span><span style="color: #0000ff;">int</span> effectedRow = getSqlMapClientTemplate().delete("deleteUser"<span style="color: #000000;">, user);
        System.out.println(</span>"delete effectedRow: " +<span style="color: #000000;"> effectedRow);
        result </span>= effectedRow &gt; 0 ? <span style="color: #0000ff;">true</span> : <span style="color: #0000ff;">false</span><span style="color: #000000;">;
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> result;
    }

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> updateUser(User user) {
        </span><span style="color: #0000ff;">boolean</span> result = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
        </span><span style="color: #0000ff;">int</span> effectedRow = getSqlMapClientTemplate().update("updateUser"<span style="color: #000000;">, user);
        System.out.println(</span>"update effectedRow: " +<span style="color: #000000;"> effectedRow);
        result </span>= effectedRow &gt; 0 ? <span style="color: #0000ff;">true</span> : <span style="color: #0000ff;">false</span><span style="color: #000000;">;
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> result;
    }

    </span><span style="color: #0000ff;">public</span> List&lt;User&gt;<span style="color: #000000;"> findAllUsers() {
        </span><span style="color: #0000ff;">return</span> (List&lt;User&gt;)getSqlMapClientTemplate().queryForList("findAllUsers"<span style="color: #000000;">);
    }

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> User findUserById(User user) {
        </span><span style="color: #0000ff;">return</span> (User) getSqlMapClientTemplate().queryForObject("findUserById"<span style="color: #000000;">, user);
    }

    </span><span style="color: #0000ff;">public</span> List&lt;User&gt;<span style="color: #000000;"> findUsersByKeyword(String keyword) {
        </span><span style="color: #0000ff;">return</span> (List&lt;User&gt;)getSqlMapClientTemplate().queryForList("findUsersByKeyword"<span style="color: #000000;">, keyword);
    }

}</span></pre>
</div>

Action类（以RegisterUserAction为例）：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.tiantian.ibatis.action.user;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.opensymphony.xwork2.ActionSupport;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.tiantian.ibatis.model.User;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.tiantian.ibatis.service.UserService;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> com.tiantian.ibatis.service.impl.UserServiceImpl;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
 * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-3-2 下午11:26:18
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> RegisterUserAction <span style="color: #0000ff;">extends</span><span style="color: #000000;"> ActionSupport{
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> UserService userService;
    </span><span style="color: #0000ff;">private</span><span style="color: #000000;"> User user;

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> User getUser() {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> user;
    }

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setUser(User user) {
        </span><span style="color: #0000ff;">this</span>.user =<span style="color: #000000;"> user;
    }

    </span><span style="color: #0000ff;">public</span><span style="color: #000000;"> UserService getUserService() {
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> userService;
    }

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setUserService(UserService userService) {
        </span><span style="color: #0000ff;">this</span>.userService =<span style="color: #000000;"> userService;
    }

    @Override
    </span><span style="color: #0000ff;">public</span> String execute() <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception {
        userService.registerUser(user);
        System.out.println(</span>"数据已经插入"<span style="color: #000000;">);
        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">null</span><span style="color: #000000;">;
    }
}</span></pre>
</div>

&nbsp;

&nbsp;

&nbsp;

