---
title: '[Android]Android端ORM框架——RapidORM(v1.0)'
tags: [android, orm, rapidorm, library, database, sqlite]
date: 2015-08-21 15:39:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span style="color: #ff0000;">**来自天天博客：[http://www.cnblogs.com/tiantianbyconan/p/4748077.html](http://www.cnblogs.com/tiantianbyconan/p/4748077.html "view: [Android]Android端ORM框架&mdash;&mdash;RapidORM")&nbsp;**</span>

&nbsp;

Android上主流的ORM框架有很多，常用的有ORMLite、GreenDao等。

ORMLite：

－优点：API很友好，使用比较方便简单稳定，相关功能比较完整。

－缺点：内部使用反射实现，性能并不是很好。

GreenDao：

－优点：性能很不错，

－缺点：API却不太友好，而且不支持复合主键，主键必须要有并且必须是long或者Long。持久类可以用它提供的模版生成，但是一旦使用了它的模版，持久类、DAO就不能随意去修改，扩展性不是很好。如果不使用它的模版，代码写起来就很繁琐。

&nbsp;

所以结合了两者重新写了一个ORM：**[RapidORM](https://github.com/wangjiegulu/RapidORM)**（[**https://github.com/wangjiegulu/RapidORM**](https://github.com/wangjiegulu/RapidORM)）

特点：

1\. 支持使用反射和非反射（模版生成）两种方式实现执行SQL。

2\. 支持复合主键

3\. 支持任何主键类型

4\. 兼容android原生的&nbsp;<span style="color: #000000; background-color: #e1e1e1;">android.database.sqlite.SQLiteDatabase</span>&nbsp;和SqlCipher的 <span style="background-color: #e1e1e1;">net.sqlcipher.database.SQLiteDatabase</span>。<span style="background-color: #e1e1e1;">
</span>

缺点：

1\. 不支持链表查询。

&nbsp;

<span style="font-size: 18px;">**快速指南：**</span>

**<span style="font-size: 14px;">一、新建持久类Person：</span>**

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 6/25/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> @Table(propertyClazz = PersonProperty.<span style="color: #0000ff;">class</span><span style="color: #000000;">)
</span><span style="color: #008080;"> 7</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Person <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Serializable{
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span>     @Column(primaryKey = <span style="color: #0000ff;">true</span><span style="color: #000000;">)
</span><span style="color: #008080;">10</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Integer id;
</span><span style="color: #008080;">11</span> 
<span style="color: #008080;">12</span>     @Column(primaryKey = <span style="color: #0000ff;">true</span><span style="color: #000000;">)
</span><span style="color: #008080;">13</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Integer typeId;
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> <span style="color: #000000;">    @Column
</span><span style="color: #008080;">16</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span> <span style="color: #000000;">    @Column
</span><span style="color: #008080;">19</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Integer age;
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> <span style="color: #000000;">    @Column
</span><span style="color: #008080;">22</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String address;
</span><span style="color: #008080;">23</span> 
<span style="color: #008080;">24</span> <span style="color: #000000;">    @Column
</span><span style="color: #008080;">25</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Long birth;
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> <span style="color: #000000;">    @Column
</span><span style="color: #008080;">28</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> Boolean student;
</span><span style="color: #008080;">29</span> 
<span style="color: #008080;">30</span>     <span style="color: #008000;">//</span><span style="color: #008000;"> getter/setter...</span>
<span style="color: #008080;">31</span> 
<span style="color: #008080;">32</span> }</pre>
</div>

&nbsp;

<span style="line-height: 1.5;">1\. Table注解用于标记这个类需要映射到数据表，RapidORM会创建这个表。</span>

－name属性：表示对应表的名称，默认为类的simpleName。

－propertyClazz属性：表示如果不使用反射执行sql时，需要的ModelProperty类的Class，RapidORM会自动在这个ModelProperty中去绑定需要执行SQL的数据。不填写则表示使用默认的反射的方式执行SQL。具体后面会讲到。

2\. Column注解用语标记这个字段映射到的数据表的列（如果）。

－name属性：表示对应列的名称。默认为字段的名称。

－primaryKey属性：表示改列是否是主键，默认是false。（可以在多个字段都适用这个属性，表示为复合主键）。

－autoincrement属性：表示主键是否是自增长，只有该字段是主键并且只有一个主键并且是Integer或int类型才会生效。

－defaultValue属性：表示该列默认值。

－notNull属性：表示该列不能为空。

－unique属性：表示该列唯一约束。

－uniqueCombo属性：暂未实现。

－index属性：暂未实现。

&nbsp;

**<span style="font-size: 14px;">二、注册持久类，并指定SQLiteOpenHelper：</span>**

新建类DatabaseFactory，继承RapidORMConnection：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 6/25/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> DatabaseFactory <span style="color: #0000ff;">extends</span> RapidORMConnection&lt;RapidORMDefaultSQLiteOpenHelperDelegate&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> VERSION = 1<span style="color: #000000;">;
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> DatabaseFactory instance;
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">synchronized</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> DatabaseFactory getInstance() {
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> instance) {
</span><span style="color: #008080;">13</span>             instance = <span style="color: #0000ff;">new</span><span style="color: #000000;"> DatabaseFactory();
</span><span style="color: #008080;">14</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">15</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> instance;
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> DatabaseFactory() {
</span><span style="color: #008080;">19</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">();
</span><span style="color: #008080;">20</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">23</span>     <span style="color: #0000ff;">protected</span><span style="color: #000000;"> RapidORMDefaultSQLiteOpenHelperDelegate getRapidORMDatabaseOpenHelper(@NonNull String databaseName) {
</span><span style="color: #008080;">24</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span> RapidORMDefaultSQLiteOpenHelperDelegate(<span style="color: #0000ff;">new</span><span style="color: #000000;"> MyDatabaseOpenHelper(MyApplication.getInstance(), databaseName, VERSION));
</span><span style="color: #008080;">25</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">28</span>     <span style="color: #0000ff;">protected</span> List&lt;Class&lt;?&gt;&gt;<span style="color: #000000;"> registerAllTableClass() {
</span><span style="color: #008080;">29</span>         List&lt;Class&lt;?&gt;&gt; allTableClass = <span style="color: #0000ff;">new</span> ArrayList&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">30</span>         allTableClass.add(Person.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;">31</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> all table class</span>
<span style="color: #008080;">32</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> allTableClass;
</span><span style="color: #008080;">33</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">34</span> }</pre>
</div>

DatabaseFactory推荐使用单例，实现RapidORMConnection的getRapidORMDatabaseOpenHelper()方法，该方法需要返回一个RapidORMDatabaseOpenHelperDelegate或者它的子类对象，RapidORMDatabaseOpenHelperDelegate是SQLiteOpenHelper的委托，因为需要兼容android原生的&nbsp;<span style="background-color: #e1e1e1;">android.database.sqlite.SQLiteDatabase</span>&nbsp;和SqlCipher的&nbsp;<span style="background-color: #e1e1e1;">net.sqlcipher.database.SQLiteDatabase</span> 两种方式。

如果使用&nbsp;<span style="background-color: #e1e1e1;">android.database.sqlite.SQLiteDatabase</span>&nbsp;，则可以使用RapidORMDefaultSQLiteOpenHelperDelegate，然后构造方法中传入真正的<span style="background-color: #e1e1e1;">android.database.sqlite.SQLiteDatabase</span>&nbsp;（也就是这里的MyDatabaseOpenHelper）即可，使用SqlCipher的方式后面再讲。

还需要实现registerAllTableClass()方法，这里返回一个所有需要映射表的持久类Class集合。

&nbsp;

**<span style="font-size: 14px;">三、在需要的地方进行初始化RapidORM（比如在登录完成之后）：</span>**

<div class="cnblogs_code">
<pre>DatabaseFactory.getInstance().resetDatabase("hello_rapid_orm.db");</pre>
</div>

如上，调用resetDatabase()方法即可初始化数据库。

&nbsp;

**四、编写Dao：**

新建PersonDaoImpl继承BaseDaoImpl&lt;Person&gt;（这里简略了PersonDao接口）：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 6/26/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> PersonDaoImpl <span style="color: #0000ff;">extends</span> BaseDaoImpl&lt;Person&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> PersonDaoImpl() {
</span><span style="color: #008080;"> 8</span>         <span style="color: #0000ff;">super</span>(Person.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span> }</pre>
</div>

BaseDaoImpl中默认实现了下面的基本方法（T为范型，指具体的持久类）：

－void insert(T model) throws Exception;　　//&nbsp;插入一条数据。

－void update(T model) throws Exception;　　//&nbsp;更新一条数据。

－void delete(T model) throws Exception;　　// 删除一条数据。

－void deleteAll() throws Exception;　　　　　　// 删除表中所有的数据

－void insertOrReplace(T model) throws Exception;　　　　// 删除或者替换（暂不支持）

－List&lt;T&gt; queryAll() throws Exception;　　　　　　// 查询表中所有数据

－List&lt;T&gt; rawQuery(String sql, String[] selectionArgs) throws Exception;　　　　　　// 使用原生sql查询表中所有的数据

－void rawExecute(String sql, Object[] bindArgs) throws Exception;　　　　　　　　// 使用原生sql执行一条sql语句

－void insertInTx(T... models) throws Exception;　　　　　　　　　　// 插入多条数据（在一个事务中）

－void insertInTx(Iterable&lt;T&gt; models) throws Exception;　　　　　　// 同上

－void updateInTx(T... models) throws Exception;　　　　　　　　　　// 更新多条数据（在一个事务中）

－void updateInTx(Iterable&lt;T&gt; models) throws Exception;　　　　　　// 同上

－void deleteInTx(T... models) throws Exception;　　　　　　　　　　　　// 删除多条数据（在一个事务中）

－void deleteInTx(Iterable&lt;T&gt; models) throws Exception;　　　　　　　　// 同上

－void executeInTx(RapidORMSQLiteDatabaseDelegate db, RapidOrmFunc1 func1) throws Exception;&nbsp;// 执行一个方法（可多个sql），在一个事务中

－void executeInTx(RapidOrmFunc1 func1) throws Exception;　　　　// 同上

&nbsp;

<span style="font-size: 15px;">**面向对象的方式使用Where和Builder来构建sql语句：**</span>

**1\. Where：**

Where表示一系列的条件语句，含义与SQL中的where关键字一致。

支持的where操作：

－eq(String column, Object value)　　　　//&nbsp;相等条件判断

－ne(String column, Object value)　　　　// 不相等条件判断

－gt(String column, Object value)　　　　 // 大于条件判断

－lt(String column, Object value)　　　　　// 小于条件判断

－ge(String column, Object value)　　　　 //&nbsp;大于等于条件

－le(String column, Object value)　　　　　// 小于等于条件

－in(String column, Object... values)　　　 // 包含条件

－ni(String column, Object... values)　　　 // 不包含条件

－isNull(String column)　　　　　　　　　　//&nbsp;null条件判断

－notNull(String column)　　　　　　　　　// 不为null条件判断

－between(String column, Object value1, Object value2)　　//&nbsp;BETWEEN ... AND ..." condition

－like(String column, Object value)　　　　　　// 模糊匹配条件

－Where raw(String rawWhere, Object... values)　　// 原生sql条件

－and(Where... wheres)　　　　　　　　　　// 多个Where与

－or(Where... wheres)　　　　　　　　　　// 多个Where或

&nbsp;

Where举例：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #000000;">    Where.and(
</span><span style="color: #008080;">2</span>                 Where.like(PersonProperty.name.column, "%wangjie%"<span style="color: #000000;">),
</span><span style="color: #008080;">3</span>                 Where.lt(PersonProperty.id.column, 200<span style="color: #000000;">),
</span><span style="color: #008080;">4</span> <span style="color: #000000;">                Where.or(
</span><span style="color: #008080;">5</span>                         Where.between(PersonProperty.age.column, 19, 39<span style="color: #000000;">),
</span><span style="color: #008080;">6</span> <span style="color: #000000;">                        Where.isNull(PersonProperty.address.column)
</span><span style="color: #008080;">7</span> <span style="color: #000000;">                ),
</span><span style="color: #008080;">8</span>                 Where.eq(PersonProperty.typeId.column, 1<span style="color: #000000;">)
</span><span style="color: #008080;">9</span>         )</pre>
</div>

如上，

Line2条件：name模糊匹配wangjie

Line3条件：id小于200

Line5条件：age在19到39之间

Line6条件：address不是null

Line8条件：typeId等于1

Line4条件：Line5条件和Line6条件是or关系；

Line1条件：Line2、Line3、Line4、Line8条件是and关系。

&nbsp;

**2\. QueryBuilder：**

QueryBuilder用于构建查询语句。

－setWhere(Where where)　　　　// 设置Where条件；

－setLimit(Integer limit)　　　　　　// 设置limit

－addSelectColumn(String... selectColumn)　　　　// 设置查询的数据列名（可以调用多遍来设置多个，默认是查询所有数据）

－addOrder(String column, boolean isAsc)　　　　　// 设置查询结果的排序（可以调用多遍来设置多个）

&nbsp;

QueryBuilder举例：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span>     <span style="color: #0000ff;">public</span> List&lt;Person&gt; findPersonsByWhere() <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception {
</span><span style="color: #008080;"> 2</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> queryBuilder()
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">                .addSelectColumn(PersonProperty.id.column, PersonProperty.typeId.column, PersonProperty.name.column,
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">                        PersonProperty.age.column, PersonProperty.birth.column, PersonProperty.address.column)
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">                .setWhere(Where.and(
</span><span style="color: #008080;"> 6</span>                         Where.like(PersonProperty.name.column, "%wangjie%"<span style="color: #000000;">),
</span><span style="color: #008080;"> 7</span>                         Where.lt(PersonProperty.id.column, 200<span style="color: #000000;">),
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">                        Where.or(
</span><span style="color: #008080;"> 9</span>                                 Where.between(PersonProperty.age.column, 19, 39<span style="color: #000000;">),
</span><span style="color: #008080;">10</span> <span style="color: #000000;">                                Where.isNull(PersonProperty.address.column)
</span><span style="color: #008080;">11</span> <span style="color: #000000;">                        ),
</span><span style="color: #008080;">12</span>                         Where.eq(PersonProperty.typeId.column, 1<span style="color: #000000;">)
</span><span style="color: #008080;">13</span> <span style="color: #000000;">                ))
</span><span style="color: #008080;">14</span>                 .addOrder(PersonProperty.id.column, <span style="color: #0000ff;">false</span><span style="color: #000000;">)
</span><span style="color: #008080;">15</span>                 .addOrder(PersonProperty.name.column, <span style="color: #0000ff;">true</span><span style="color: #000000;">)
</span><span style="color: #008080;">16</span>                 .setLimit(10<span style="color: #000000;">)
</span><span style="color: #008080;">17</span>                 .query(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">18</span>     }</pre>
</div>

如上，通过queryBuilder()方法构建一个QueryBuilder，并设置查询的列名、Where、排序、limit等参数，最后调用query()执行查询。

&nbsp;

**3\. UpdateBuilder：**

UpdateBuilder用于构建更新语句。

－setWhere(Where where)　　　　// 设置Where条件；

－addUpdateColumn(String column, Object value)　　　　// 添加需要更新的字段；

&nbsp;

UpdateBuilder举例：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> updatePerson() <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception {
</span><span style="color: #008080;"> 2</span>         <span style="color: #0000ff;">long</span> now =<span style="color: #000000;"> System.currentTimeMillis();
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">        updateBuilder()
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">                .setWhere(Where.and(
</span><span style="color: #008080;"> 5</span>                         Where.like(PersonProperty.name.column, "%wangjie%"<span style="color: #000000;">),
</span><span style="color: #008080;"> 6</span>                         Where.lt(PersonProperty.id.column, 200<span style="color: #000000;">),
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">                        Where.or(
</span><span style="color: #008080;"> 8</span>                                 Where.between(PersonProperty.age.column, 19, 39<span style="color: #000000;">),
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">                                Where.isNull(PersonProperty.address.column)
</span><span style="color: #008080;">10</span> <span style="color: #000000;">                        ),
</span><span style="color: #008080;">11</span>                         Where.eq(PersonProperty.typeId.column, 1<span style="color: #000000;">)
</span><span style="color: #008080;">12</span> <span style="color: #000000;">                ))
</span><span style="color: #008080;">13</span> <span style="color: #000000;">                .addUpdateColumn(PersonProperty.birth.column, now)
</span><span style="color: #008080;">14</span>                 .addUpdateColumn(PersonProperty.address.column, "address_" + now).update(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">15</span>     }</pre>
</div>

如上，通过updateBuilder()方法构建一个UpdateBuilder，并设置要更新的字段，最后调用update()执行查询。

&nbsp;

**4\. DeleteBuilder：&nbsp;**

DeleteBuilder用于构建删除语句。

－setWhere(Where where)　　　　// 设置Where条件；

&nbsp;

DeleteBuilder举例：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> deletePerson() <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception {
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">        deleteBuilder()
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">                .setWhere(Where.and(
</span><span style="color: #008080;"> 4</span>                         Where.like(PersonProperty.name.column, "%wangjie%"<span style="color: #000000;">),
</span><span style="color: #008080;"> 5</span>                         Where.lt(PersonProperty.id.column, 200<span style="color: #000000;">),
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">                        Where.or(
</span><span style="color: #008080;"> 7</span>                                 Where.between(PersonProperty.age.column, 19, 39<span style="color: #000000;">),
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">                                Where.isNull(PersonProperty.address.column)
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">                        ),
</span><span style="color: #008080;">10</span>                         Where.eq(PersonProperty.typeId.column, 1<span style="color: #000000;">)
</span><span style="color: #008080;">11</span> <span style="color: #000000;">                ))
</span><span style="color: #008080;">12</span>                 .delete(<span style="color: #0000ff;">this</span><span style="color: #000000;">);
</span><span style="color: #008080;">13</span>     }</pre>
</div>

如上，通过deleteBuilder()方法构建一个DeleteBuilder，并设置Where条件，最后调用delete()执行查询。

&nbsp;

<span style="font-size: 15px;">**使用模版生成ModelProperty：**</span>

如果你打算使用非反射的方式执行sql，则可以使用ModelPropertyGenerator模版来生成

1\. 新建一个类，在main方法中执行：

<div class="cnblogs_code">
<pre><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 7/2/15.
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> MyGenerator {
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">void</span> main(String[] args) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception {

        Class tableClazz </span>= Person.<span style="color: #0000ff;">class</span><span style="color: #000000;">;
        </span><span style="color: #0000ff;">new</span><span style="color: #000000;"> ModelPropertyGenerator().generate(tableClazz,
                </span>"example/src/main/java"<span style="color: #000000;">,
                tableClazz.getPackage().getName() </span>+ ".config"<span style="color: #000000;">);

    }

}</span></pre>
</div>

如上，generate()方法参数如下：

generate(Class tableClazz, String outerDir, String packageName)

参数一：要生成的Property持久类的Class

参数二：生成的ModelProperty类文件存放目录

参数三：生成的ModelProperty类文件的包名

执行完毕后，就会在com.wangjie.rapidorm.example.database.model.config包下生成如下的ModelProperty：

<div class="cnblogs_code">
<pre><span style="color: #008080;">  1</span> <span style="color: #008000;">//</span><span style="color: #008000;"> THIS CODE IS GENERATED BY RapidORM, DO NOT EDIT.</span>
<span style="color: #008080;">  2</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">  3</span> <span style="color: #008000;">* Property of Person
</span><span style="color: #008080;">  4</span> <span style="color: #008000;">*/</span>
<span style="color: #008080;">  5</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> PersonProperty <span style="color: #0000ff;">implements</span> IModelProperty&lt;Person&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;">  6</span> 
<span style="color: #008080;">  7</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> ModelFieldMapper id = <span style="color: #0000ff;">new</span> ModelFieldMapper(0, "id", "id"<span style="color: #000000;">);
</span><span style="color: #008080;">  8</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> ModelFieldMapper typeId = <span style="color: #0000ff;">new</span> ModelFieldMapper(1, "typeId", "typeId"<span style="color: #000000;">);
</span><span style="color: #008080;">  9</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> ModelFieldMapper name = <span style="color: #0000ff;">new</span> ModelFieldMapper(2, "name", "name"<span style="color: #000000;">);
</span><span style="color: #008080;"> 10</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> ModelFieldMapper age = <span style="color: #0000ff;">new</span> ModelFieldMapper(3, "age", "age"<span style="color: #000000;">);
</span><span style="color: #008080;"> 11</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> ModelFieldMapper address = <span style="color: #0000ff;">new</span> ModelFieldMapper(4, "address", "address"<span style="color: #000000;">);
</span><span style="color: #008080;"> 12</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> ModelFieldMapper birth = <span style="color: #0000ff;">new</span> ModelFieldMapper(5, "birth", "birth"<span style="color: #000000;">);
</span><span style="color: #008080;"> 13</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> ModelFieldMapper student = <span style="color: #0000ff;">new</span> ModelFieldMapper(6, "student", "student"<span style="color: #000000;">);
</span><span style="color: #008080;"> 14</span> 
<span style="color: #008080;"> 15</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> PersonProperty() {
</span><span style="color: #008080;"> 16</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 17</span> 
<span style="color: #008080;"> 18</span> 
<span style="color: #008080;"> 19</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> bindInsertArgs(Person model, List&lt;Object&gt;<span style="color: #000000;"> insertArgs) {
</span><span style="color: #008080;"> 21</span>         Integer id =<span style="color: #000000;"> model.getId();
</span><span style="color: #008080;"> 22</span>         insertArgs.add(<span style="color: #0000ff;">null</span> == id ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : id);
</span><span style="color: #008080;"> 23</span> 
<span style="color: #008080;"> 24</span>         Integer typeId =<span style="color: #000000;"> model.getTypeId();
</span><span style="color: #008080;"> 25</span>         insertArgs.add(<span style="color: #0000ff;">null</span> == typeId ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : typeId);
</span><span style="color: #008080;"> 26</span> 
<span style="color: #008080;"> 27</span>         String name =<span style="color: #000000;"> model.getName();
</span><span style="color: #008080;"> 28</span>         insertArgs.add(<span style="color: #0000ff;">null</span> == name ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : name);
</span><span style="color: #008080;"> 29</span> 
<span style="color: #008080;"> 30</span>         Integer age =<span style="color: #000000;"> model.getAge();
</span><span style="color: #008080;"> 31</span>         insertArgs.add(<span style="color: #0000ff;">null</span> == age ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : age);
</span><span style="color: #008080;"> 32</span> 
<span style="color: #008080;"> 33</span>         String address =<span style="color: #000000;"> model.getAddress();
</span><span style="color: #008080;"> 34</span>         insertArgs.add(<span style="color: #0000ff;">null</span> == address ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : address);
</span><span style="color: #008080;"> 35</span> 
<span style="color: #008080;"> 36</span>         Long birth =<span style="color: #000000;"> model.getBirth();
</span><span style="color: #008080;"> 37</span>         insertArgs.add(<span style="color: #0000ff;">null</span> == birth ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : birth);
</span><span style="color: #008080;"> 38</span> 
<span style="color: #008080;"> 39</span>         Boolean student =<span style="color: #000000;"> model.isStudent();
</span><span style="color: #008080;"> 40</span>         insertArgs.add(<span style="color: #0000ff;">null</span> == student ? <span style="color: #0000ff;">null</span> : student ? 1 : 0<span style="color: #000000;">);
</span><span style="color: #008080;"> 41</span> 
<span style="color: #008080;"> 42</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 43</span> 
<span style="color: #008080;"> 44</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 45</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> bindUpdateArgs(Person model, List&lt;Object&gt;<span style="color: #000000;"> updateArgs) {
</span><span style="color: #008080;"> 46</span>         String name =<span style="color: #000000;"> model.getName();
</span><span style="color: #008080;"> 47</span>         updateArgs.add(<span style="color: #0000ff;">null</span> == name ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : name);
</span><span style="color: #008080;"> 48</span> 
<span style="color: #008080;"> 49</span>         Integer age =<span style="color: #000000;"> model.getAge();
</span><span style="color: #008080;"> 50</span>         updateArgs.add(<span style="color: #0000ff;">null</span> == age ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : age);
</span><span style="color: #008080;"> 51</span> 
<span style="color: #008080;"> 52</span>         String address =<span style="color: #000000;"> model.getAddress();
</span><span style="color: #008080;"> 53</span>         updateArgs.add(<span style="color: #0000ff;">null</span> == address ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : address);
</span><span style="color: #008080;"> 54</span> 
<span style="color: #008080;"> 55</span>         Long birth =<span style="color: #000000;"> model.getBirth();
</span><span style="color: #008080;"> 56</span>         updateArgs.add(<span style="color: #0000ff;">null</span> == birth ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : birth);
</span><span style="color: #008080;"> 57</span> 
<span style="color: #008080;"> 58</span>         Boolean student =<span style="color: #000000;"> model.isStudent();
</span><span style="color: #008080;"> 59</span>         updateArgs.add(<span style="color: #0000ff;">null</span> == student ? <span style="color: #0000ff;">null</span> : student ? 1 : 0<span style="color: #000000;">);
</span><span style="color: #008080;"> 60</span> 
<span style="color: #008080;"> 61</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 62</span> 
<span style="color: #008080;"> 63</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 64</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> bindPkArgs(Person model, List&lt;Object&gt;<span style="color: #000000;"> pkArgs) {
</span><span style="color: #008080;"> 65</span>         Integer id =<span style="color: #000000;"> model.getId();
</span><span style="color: #008080;"> 66</span>         pkArgs.add(<span style="color: #0000ff;">null</span> == id ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : id);
</span><span style="color: #008080;"> 67</span> 
<span style="color: #008080;"> 68</span>         Integer typeId =<span style="color: #000000;"> model.getTypeId();
</span><span style="color: #008080;"> 69</span>         pkArgs.add(<span style="color: #0000ff;">null</span> == typeId ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : typeId);
</span><span style="color: #008080;"> 70</span> 
<span style="color: #008080;"> 71</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 72</span> 
<span style="color: #008080;"> 73</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 74</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> Person parseFromCursor(Cursor cursor) {
</span><span style="color: #008080;"> 75</span>         Person model = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Person();
</span><span style="color: #008080;"> 76</span>         <span style="color: #0000ff;">int</span><span style="color: #000000;"> index;
</span><span style="color: #008080;"> 77</span>         index = cursor.getColumnIndex("id"<span style="color: #000000;">);
</span><span style="color: #008080;"> 78</span>         <span style="color: #0000ff;">if</span>(-1 !=<span style="color: #000000;"> index){
</span><span style="color: #008080;"> 79</span>             model.setId(cursor.isNull(index) ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : (cursor.getInt(index)));
</span><span style="color: #008080;"> 80</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 81</span> 
<span style="color: #008080;"> 82</span>         index = cursor.getColumnIndex("typeId"<span style="color: #000000;">);
</span><span style="color: #008080;"> 83</span>         <span style="color: #0000ff;">if</span>(-1 !=<span style="color: #000000;"> index){
</span><span style="color: #008080;"> 84</span>             model.setTypeId(cursor.isNull(index) ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : (cursor.getInt(index)));
</span><span style="color: #008080;"> 85</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 86</span> 
<span style="color: #008080;"> 87</span>         index = cursor.getColumnIndex("name"<span style="color: #000000;">);
</span><span style="color: #008080;"> 88</span>         <span style="color: #0000ff;">if</span>(-1 !=<span style="color: #000000;"> index){
</span><span style="color: #008080;"> 89</span>             model.setName(cursor.isNull(index) ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : (cursor.getString(index)));
</span><span style="color: #008080;"> 90</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 91</span> 
<span style="color: #008080;"> 92</span>         index = cursor.getColumnIndex("age"<span style="color: #000000;">);
</span><span style="color: #008080;"> 93</span>         <span style="color: #0000ff;">if</span>(-1 !=<span style="color: #000000;"> index){
</span><span style="color: #008080;"> 94</span>             model.setAge(cursor.isNull(index) ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : (cursor.getInt(index)));
</span><span style="color: #008080;"> 95</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 96</span> 
<span style="color: #008080;"> 97</span>         index = cursor.getColumnIndex("address"<span style="color: #000000;">);
</span><span style="color: #008080;"> 98</span>         <span style="color: #0000ff;">if</span>(-1 !=<span style="color: #000000;"> index){
</span><span style="color: #008080;"> 99</span>             model.setAddress(cursor.isNull(index) ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : (cursor.getString(index)));
</span><span style="color: #008080;">100</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">101</span> 
<span style="color: #008080;">102</span>         index = cursor.getColumnIndex("birth"<span style="color: #000000;">);
</span><span style="color: #008080;">103</span>         <span style="color: #0000ff;">if</span>(-1 !=<span style="color: #000000;"> index){
</span><span style="color: #008080;">104</span>             model.setBirth(cursor.isNull(index) ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : (cursor.getLong(index)));
</span><span style="color: #008080;">105</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">106</span> 
<span style="color: #008080;">107</span>         index = cursor.getColumnIndex("student"<span style="color: #000000;">);
</span><span style="color: #008080;">108</span>         <span style="color: #0000ff;">if</span>(-1 !=<span style="color: #000000;"> index){
</span><span style="color: #008080;">109</span>             model.setStudent(cursor.isNull(index) ? <span style="color: #0000ff;">null</span> : (cursor.getInt(index) == 1<span style="color: #000000;">));
</span><span style="color: #008080;">110</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">111</span> 
<span style="color: #008080;">112</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> model;
</span><span style="color: #008080;">113</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">114</span> 
<span style="color: #008080;">115</span> }</pre>
</div>

注意：此Property类一旦生成，则不能修改；如果该持久类相关的注解属性改变，则需要重新生成这个Property类。

2\. 在相应的持久类的@Table注解中设置propertyClazz：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> @Table(propertyClazz = PersonProperty.<span style="color: #0000ff;">class</span><span style="color: #000000;">)
</span><span style="color: #008080;">2</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> Person <span style="color: #0000ff;">implements</span> Serializable{</pre>
</div>

&nbsp;

<span style="font-size: 16px;">**如何兼容SqlCipher**</span>

1\. 新建MySQLCipherOpenHelper，继承net.sqlcipher.database.SQLiteOpenHelper：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.content.Context;
</span><span style="color: #008080;"> 2</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.rapidorm.core.dao.DatabaseProcessor;
</span><span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.rapidorm.core.delegate.database.RapidORMSQLiteDatabaseDelegate;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> net.sqlcipher.database.SQLiteDatabase;
</span><span style="color: #008080;"> 5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> net.sqlcipher.database.SQLiteDatabaseHook;
</span><span style="color: #008080;"> 6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> net.sqlcipher.database.SQLiteOpenHelper;
</span><span style="color: #008080;"> 7</span> 
<span style="color: #008080;"> 8</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 9</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;">10</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;">11</span> <span style="color: #008000;"> * Date: 8/17/15.
</span><span style="color: #008080;">12</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">13</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MySQLCipherOpenHelper <span style="color: #0000ff;">extends</span><span style="color: #000000;"> SQLiteOpenHelper {
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> RapidORMSQLiteDatabaseDelegate rapidORMSQLiteDatabaseDelegate;
</span><span style="color: #008080;">16</span> 
<span style="color: #008080;">17</span>     <span style="color: #0000ff;">public</span> MySQLCipherOpenHelper(Context context, String name, <span style="color: #0000ff;">int</span><span style="color: #000000;"> version) {
</span><span style="color: #008080;">18</span>         <span style="color: #0000ff;">super</span>(context, name, <span style="color: #0000ff;">null</span><span style="color: #000000;">, version);
</span><span style="color: #008080;">19</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span>     <span style="color: #0000ff;">public</span> MySQLCipherOpenHelper(Context context, String name, SQLiteDatabase.CursorFactory factory, <span style="color: #0000ff;">int</span><span style="color: #000000;"> version) {
</span><span style="color: #008080;">22</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, name, factory, version);
</span><span style="color: #008080;">23</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">24</span> 
<span style="color: #008080;">25</span>     <span style="color: #0000ff;">public</span> MySQLCipherOpenHelper(Context context, String name, SQLiteDatabase.CursorFactory factory, <span style="color: #0000ff;">int</span><span style="color: #000000;"> version, SQLiteDatabaseHook hook) {
</span><span style="color: #008080;">26</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context, name, factory, version, hook);
</span><span style="color: #008080;">27</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">28</span> 
<span style="color: #008080;">29</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">30</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(SQLiteDatabase db) {
</span><span style="color: #008080;">31</span> <span style="color: #008000;">//</span><span style="color: #008000;">        super.onCreate(db);</span>
<span style="color: #008080;">32</span>         rapidORMSQLiteDatabaseDelegate = <span style="color: #0000ff;">new</span><span style="color: #000000;"> MySQLCipherDatabaseDelegate(db);
</span><span style="color: #008080;">33</span>         DatabaseProcessor databaseProcessor =<span style="color: #000000;"> DatabaseProcessor.getInstance();
</span><span style="color: #008080;">34</span>         <span style="color: #0000ff;">for</span> (Class&lt;?&gt;<span style="color: #000000;"> tableClazz : databaseProcessor.getAllTableClass()) {
</span><span style="color: #008080;">35</span>             databaseProcessor.createTable(rapidORMSQLiteDatabaseDelegate, tableClazz, <span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;">36</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">37</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">38</span> 
<span style="color: #008080;">39</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">40</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> onUpgrade(SQLiteDatabase db, <span style="color: #0000ff;">int</span> oldVersion, <span style="color: #0000ff;">int</span><span style="color: #000000;"> newVersion) {
</span><span style="color: #008080;">41</span> <span style="color: #008000;">//</span><span style="color: #008000;">        super.onUpgrade(db, oldVersion, newVersion);</span>
<span style="color: #008080;">42</span>         rapidORMSQLiteDatabaseDelegate = <span style="color: #0000ff;">new</span><span style="color: #000000;"> MySQLCipherDatabaseDelegate(db);
</span><span style="color: #008080;">43</span>         DatabaseProcessor databaseProcessor =<span style="color: #000000;"> DatabaseProcessor.getInstance();
</span><span style="color: #008080;">44</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> todo: dev only!!!!!</span>
<span style="color: #008080;">45</span> <span style="color: #000000;">        databaseProcessor.dropAllTable(rapidORMSQLiteDatabaseDelegate);
</span><span style="color: #008080;">46</span> 
<span style="color: #008080;">47</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">48</span> }</pre>
</div>

&nbsp;

2\. 新建MySQLCipherDatabaseDelegate继承RapidORMSQLiteDatabaseDelegate，并实现以下的方法：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.database.Cursor;
</span><span style="color: #008080;"> 2</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> android.database.SQLException;
</span><span style="color: #008080;"> 3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.rapidorm.core.delegate.database.RapidORMSQLiteDatabaseDelegate;
</span><span style="color: #008080;"> 4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> net.sqlcipher.database.SQLiteDatabase;
</span><span style="color: #008080;"> 5</span> 
<span style="color: #008080;"> 6</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 7</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 8</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 9</span> <span style="color: #008000;"> * Date: 8/17/15.
</span><span style="color: #008080;">10</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">11</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MySQLCipherDatabaseDelegate <span style="color: #0000ff;">extends</span> RapidORMSQLiteDatabaseDelegate&lt;SQLiteDatabase&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;">12</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> MySQLCipherDatabaseDelegate(SQLiteDatabase db) {
</span><span style="color: #008080;">13</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(db);
</span><span style="color: #008080;">14</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">17</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> execSQL(String sql) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> SQLException {
</span><span style="color: #008080;">18</span> <span style="color: #000000;">        db.execSQL(sql);
</span><span style="color: #008080;">19</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">22</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isDbLockedByCurrentThread() {
</span><span style="color: #008080;">23</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> db.isDbLockedByCurrentThread();
</span><span style="color: #008080;">24</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">25</span> 
<span style="color: #008080;">26</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">27</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> execSQL(String sql, Object[] bindArgs) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception {
</span><span style="color: #008080;">28</span> <span style="color: #000000;">        db.execSQL(sql, bindArgs);
</span><span style="color: #008080;">29</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">30</span> 
<span style="color: #008080;">31</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">32</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> Cursor rawQuery(String sql, String[] selectionArgs) {
</span><span style="color: #008080;">33</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> db.rawQuery(sql, selectionArgs);
</span><span style="color: #008080;">34</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">35</span> 
<span style="color: #008080;">36</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">37</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> beginTransaction() {
</span><span style="color: #008080;">38</span> <span style="color: #000000;">        db.beginTransaction();
</span><span style="color: #008080;">39</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">40</span> 
<span style="color: #008080;">41</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">42</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> setTransactionSuccessful() {
</span><span style="color: #008080;">43</span> <span style="color: #000000;">        db.setTransactionSuccessful();
</span><span style="color: #008080;">44</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">45</span> 
<span style="color: #008080;">46</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">47</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> endTransaction() {
</span><span style="color: #008080;">48</span> <span style="color: #000000;">        db.endTransaction();
</span><span style="color: #008080;">49</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">50</span> 
<span style="color: #008080;">51</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">52</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> close() {
</span><span style="color: #008080;">53</span> <span style="color: #000000;">        db.close();
</span><span style="color: #008080;">54</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">55</span> }</pre>
</div>

注意这里的import，这里的SQLiteDatabase需要导入&nbsp;<span style="background-color: #d8d8d8;">net.sqlcipher.database.SQLiteDatabase</span>&nbsp;。

&nbsp;

3\. 新建MySQLCipherOpenHelperDelegate继承RapidORMDatabaseOpenHelperDelegate，实现如下方法：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> com.wangjie.rapidorm.core.delegate.openhelper.RapidORMDatabaseOpenHelperDelegate;
</span><span style="color: #008080;"> 2</span> <span style="color: #008080;"> 3</span> 
<span style="color: #008080;"> 4</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 6</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 7</span> <span style="color: #008000;"> * Date: 6/18/15.
</span><span style="color: #008080;"> 8</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 9</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> MySQLCipherOpenHelperDelegate <span style="color: #0000ff;">extends</span> RapidORMDatabaseOpenHelperDelegate&lt;MySQLCipherOpenHelper, MySQLCipherOpenHelperDelegate&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;">10</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> MySQLCipherOpenHelperDelegate(MySQLCipherOpenHelper sqLiteOpenHelper) {
</span><span style="color: #008080;">11</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(sqLiteOpenHelper);
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">13</span> 
<span style="color: #008080;">14</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String SECRET_KEY = "1234567890abcdef"<span style="color: #000000;">;
</span><span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">17</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> MySQLCipherOpenHelperDelegate getReadableDatabase() {
</span><span style="color: #008080;">18</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> MySQLCipherDatabaseDelegate(openHelper.getReadableDatabase(SECRET_KEY));
</span><span style="color: #008080;">19</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">20</span> 
<span style="color: #008080;">21</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">22</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> MySQLCipherOpenHelperDelegate getWritableDatabase() {
</span><span style="color: #008080;">23</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> MySQLCipherDatabaseDelegate(openHelper.getWritableDatabase(SECRET_KEY));
</span><span style="color: #008080;">24</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">25</span> 
<span style="color: #008080;">26</span> }</pre>
</div>

&nbsp;

4\. 在DatabaseFactory中使用SqlCipher版本：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 6/25/15.
</span><span style="color: #008080;"> 5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> DatabaseFactory <span style="color: #0000ff;">extends</span> RapidORMConnection&lt;MySQLCipherOpenHelperDelegate&gt;<span style="color: #000000;"> {
</span><span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">int</span> VERSION = 1<span style="color: #000000;">;
</span><span style="color: #008080;"> 8</span> 
<span style="color: #008080;"> 9</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> DatabaseFactory instance;
</span><span style="color: #008080;">10</span> 
<span style="color: #008080;">11</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">synchronized</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> DatabaseFactory getInstance() {
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">if</span> (<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> instance) {
</span><span style="color: #008080;">13</span>             instance = <span style="color: #0000ff;">new</span><span style="color: #000000;"> DatabaseFactory();
</span><span style="color: #008080;">14</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">15</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> instance;
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">17</span> 
<span style="color: #008080;">18</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> DatabaseFactory() {
</span><span style="color: #008080;">19</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">();
</span><span style="color: #008080;">20</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">21</span> 
<span style="color: #008080;">22</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">23</span>     <span style="color: #0000ff;">protected</span><span style="color: #000000;"> MySQLCipherOpenHelperDelegate getRapidORMDatabaseOpenHelper(@NonNull String databaseName) {
</span><span style="color: #008080;">24</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span> MySQLCipherOpenHelperDelegate(<span style="color: #0000ff;">new</span><span style="color: #000000;"> MySQLCipherOpenHelper(applicationContext, databaseName, VERSION));
</span><span style="color: #008080;">25</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">26</span> 
<span style="color: #008080;">27</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">28</span>     <span style="color: #0000ff;">protected</span> List&lt;Class&lt;?&gt;&gt;<span style="color: #000000;"> registerAllTableClass() {
</span><span style="color: #008080;">29</span>         List&lt;Class&lt;?&gt;&gt; allTableClass = <span style="color: #0000ff;">new</span> ArrayList&lt;&gt;<span style="color: #000000;">();
</span><span style="color: #008080;">30</span>         allTableClass.add(Person.<span style="color: #0000ff;">class</span><span style="color: #000000;">);
</span><span style="color: #008080;">31</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> register all table class here...</span>
<span style="color: #008080;">32</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> allTableClass;
</span><span style="color: #008080;">33</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">34</span> }</pre>
</div>

&nbsp;

