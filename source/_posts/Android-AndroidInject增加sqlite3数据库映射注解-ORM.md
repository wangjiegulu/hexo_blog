---
title: '[Android]AndroidInject增加sqlite3数据库映射注解(ORM)'
tags: []
date: 2014-03-25 14:21:00
---

<span style="color: #ff0000;">**以下内容为原创，欢迎转载，转载请注明**</span>

<span>**<span style="color: #ff0000;">来自天天博客：[<span style="color: #ff0000;">http://www.cnblogs.com/tiantianbyconan/p/3623050.html</span>](http://www.cnblogs.com/tiantianbyconan/p/3623050.html)</span>[
](http://www.cnblogs.com/tiantianbyconan/p/3540427.html)**</span>

AndroidInject项目是我写的一个使用注解注入来简化代码的开源项目

[https://github.com/wangjiegulu/androidInject](https://github.com/wangjiegulu/androidInject)

今天新增功能如下：

1\. 增加对sqlite3数据库的orm注解支持，增加@AIColumn、@AIPrimaryKey、@AITable三个注解来映射到表（有待改进）

2\. 使用反射来封装AIDbExecutor类，实现半自动化orm，类似mybatis

![](http://images.cnitblog.com/i/378300/201403/251333009205565.png)

　　先说说使用的方式吧

　　一. 新建DatabaseHelper，继承AIDatabaseHelper（AndroidInject提供，直接继承了SQLiteOpenHelper），在onCreate中调用如下方法来新建表user：

<div class="cnblogs_code">
<pre><span style="color: #000000;">@Override
</span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onCreate(SQLiteDatabase db) {
        AIDbUtil.createTableIfNotExist(db,
                </span>"create table user(uid INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "username varchar(20), " +
                        "password varchar(20), " +
                        "createmillis long, " +
                        "height float, " +
                        "weight double)"<span style="color: #000000;">,
                </span>"user"<span style="color: #000000;">);
}</span></pre>
</div>

其中方法createTableIfNotExist (SQLiteDatabase db, String sql, String tableName) 用于新建表，如果存在该表，则不创建&nbsp; &nbsp;&nbsp;

　　二. 既然是ORM，不管怎么样，总要在表与持久层对象之间映射，所以新建表完毕之后，就要新建类User：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;"> * Created with IntelliJ IDEA.
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;"> * Author: wangjie  email:tiantian.china.2@gmail.com
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;"> * Date: 14-3-25
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;"> * Time: 上午10:04
</span><span style="color: #008080;"> 6</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 7</span> <span style="color: #000000;">@AITable("user")
</span><span style="color: #008080;"> 8</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> User <span style="color: #0000ff;">implements</span><span style="color: #000000;"> Serializable{
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    @AIColumn
</span><span style="color: #008080;">10</span>     @AIPrimaryKey(insertable = <span style="color: #0000ff;">false</span><span style="color: #000000;">)
</span><span style="color: #008080;">11</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> uid;
</span><span style="color: #008080;">12</span>     @AIColumn("username"<span style="color: #000000;">)
</span><span style="color: #008080;">13</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String username;
</span><span style="color: #008080;">14</span> <span style="color: #000000;">    @AIColumn
</span><span style="color: #008080;">15</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String password;
</span><span style="color: #008080;">16</span> <span style="color: #000000;">    @AIColumn
</span><span style="color: #008080;">17</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">long</span><span style="color: #000000;"> createmillis;
</span><span style="color: #008080;">18</span> <span style="color: #000000;">    @AIColumn
</span><span style="color: #008080;">19</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">float</span><span style="color: #000000;"> height;
</span><span style="color: #008080;">20</span> <span style="color: #000000;">    @AIColumn
</span><span style="color: #008080;">21</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">double</span><span style="color: #000000;"> weight;
</span><span style="color: #008080;">22</span> 
<span style="color: #008080;">23</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String notCol;
</span><span style="color: #008080;">24</span>     // getter/setter...
<span style="color: #008080;">25</span> }</pre>
</div>

如上面的代码所示：

@AITable&nbsp;类注解，用于映射类到表， value()表示要映射到的表的名称，不填写或未增加该注解则默认以类名小写为表名

@AIPrimaryKey&nbsp;属性注解，用于指定属性为主键，insertable()表示插入数据时是否同时也插入主键到表。默认为false，即表的主键应该为自动生成

@AIColumn&nbsp;属性注解，用于映射属性到表字段，value()表示要映射到的表字段名称，不填写则默认以属性名作为表字段名

这样，类和表之间就用以上的几个注解进行了映射。

&nbsp; &nbsp; 三. AndroidInject提供了一个AIDbExecutor抽象类来对表数据进行操作，使用时需要自己编写一个DbExecutor来继承AIDbExecutor，并实现obtainDbHelper()方法，用于提供给DbExecutor一个AIDatabaseHelper。如下：

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> DbExecutor&lt;T&gt; <span style="color: #0000ff;">extends</span> AIDbExecutor&lt;T&gt;<span style="color: #000000;">{
</span><span style="color: #008080;"> 2</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> String TAG = DbExecutor.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;"> 3</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> String DB_NAME = "androidinject_db"<span style="color: #000000;">;
</span><span style="color: #008080;"> 4</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">int</span> VERSION = 1<span style="color: #000000;">;
</span><span style="color: #008080;"> 5</span> 
<span style="color: #008080;"> 6</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> DbExecutor(Context context) {
</span><span style="color: #008080;"> 7</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">(context);
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 9</span> 
<span style="color: #008080;">10</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;">11</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> AIDatabaseHelper obtainDbHelper() {
</span><span style="color: #008080;">12</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">new</span><span style="color: #000000;"> DatabaseHelper(context, DB_NAME, VERSION);
</span><span style="color: #008080;">13</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">14</span> 
<span style="color: #008080;">15</span> 
<span style="color: #008080;">16</span> }</pre>
</div>

&nbsp; &nbsp;接下来就可以直接使用AIDbExecutor来进行数据库的操作了，如下：

<div class="cnblogs_code">
<pre><span style="color: #008000;">//</span><span style="color: #008000;"> 创建一个用于操作user表的dbExecutor对象</span>
AIDbExecutor&lt;User&gt; userExecutor = <span style="color: #0000ff;">new</span> DbExecutor&lt;User&gt;<span style="color: #000000;">(context);

</span><span style="color: #008000;">//</span><span style="color: #008000;"> 插入一条user数据：</span>
User dbUser = <span style="color: #0000ff;">new</span> User("wangjie" + rd.nextInt(10000), String.valueOf(rd.nextInt(10000) + 10000), System.currentTimeMillis(), rd.nextInt(80) + 120, rd.nextInt(80) + 120, "aaaa"<span style="color: #000000;">);
userExecutor.executeSave(dbUser);

</span><span style="color: #008000;">//</span><span style="color: #008000;"> 查询user表</span>
List&lt;User&gt; users = userExecutor.executeQuery("select * from user where uid &gt; ?", <span style="color: #0000ff;">new</span> String[]{"4"}, User.<span style="color: #0000ff;">class</span><span style="color: #000000;">);

</span><span style="color: #008000;">//</span><span style="color: #008000;"> 删除user表中的一条数据</span>
userExecutor.executeDelete(users.get(0<span style="color: #000000;">));

</span><span style="color: #008000;">//</span><span style="color: #008000;"> 更新user表中的一条数据</span>
User user = users.get(0<span style="color: #000000;">);
user.setUsername(user.getUsername().startsWith(</span>"wangjie") ? "jiewang" + rd.nextInt(10000) : "wangjie" + rd.nextInt(10000<span style="color: #000000;">));
user.setPassword(user.getPassword().startsWith(</span>"123456") ? "abcdef" : "123456"<span style="color: #000000;">);
user.setCreatemillis(System.currentTimeMillis());
user.setHeight(rd.nextInt(</span>80) + 120<span style="color: #000000;">);
user.setWeight(rd.nextInt(</span>80) + 120<span style="color: #000000;">);
user.setNotCol(</span>"bbb"<span style="color: #000000;">);
userExecutor.executeUpdate(user, </span><span style="color: #0000ff;">null</span>, <span style="color: #0000ff;">new</span> String[]{"createmillis"});</pre>
</div>

四. AIDbExecutor类中提供的方法有：

1\. public List&lt;T&gt; executeQuery(String sql, String[] selectionArgs, Class&lt;?&gt; clazz) throws Exception;

用于查询表，并自动封装到List&lt;T&gt;中，告别Cursor

2.&nbsp;public int executeSave(final T obj) throws Exception;

用于保存一条数据

3.&nbsp;public int executeUpdate(final T obj, final String[] includeParams, final String[] excludeParams) throws Exception;

用于更新一条数据，更新数据时，是根据主键去更新其他字段的。可以对其他要更新的字段进行包含和排除（填写类的属性）。

注意：包含在includeParams，并且不包含在excludeParams中才会被更新。

4.&nbsp;public int executeDelete(final T obj) throws Exception;

删除一条数据，根据主键删除一条数据

5.&nbsp;public void executeSql(String sql, Object[] selectionArgs) throws Exception;

执行一条sql语句（insert、update、delete）

6\. 同时提供了生成SQLiteDatabase对象的方法

public SQLiteDatabase getReadableDatabase();

public SQLiteDatabase getWritableDatabase();

&nbsp;