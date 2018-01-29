---
title: Hbase Java API详解
tags: []
date: 2014-02-20 14:23:00
---

HBase是Hadoop的数据库，能够对大数据提供随机、实时读写访问。他是开源的，分布式的，多版本的，面向列的，存储模型。

在讲解的时候我首先给大家讲解一下HBase的整体结构，如下图：

![ HBase Java API详解 ](http://static.open-open.com/lib/uploadImg/20120717/20120717163859_417.jpg)

HBase Master是服务器负责管理所有的HRegion服务器，HBase Master并不存储HBase服务器的任何数据，HBase逻辑上的表可能会划分为多个HRegion，然后存储在HRegion Server群中，HBase Master Server中存储的是从数据到HRegion Server的映射。

一台机器只能运行一个HRegion服务器，数据的操作会记录在Hlog中，在读取数据时候，HRegion会先访问Hmemcache缓存，如果 缓存中没有数据才回到Hstore中上找，没一个列都会有一个Hstore集合，每个Hstore集合包含了很多具体的HstoreFile文件，这些文 件是B树结构的，方便快速读取。

&nbsp;

再看下HBase数据物理视图如下：

&nbsp;

<table border="1" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td rowspan="2" width="67">**Row Key**</td>
<td rowspan="2" width="104">**Timestamp**</td>
<td colspan="2" width="385">**Column Family**</td>
</tr>
<tr>
<td width="227">**URI**</td>
<td width="158">**Parser**</td>
</tr>
<tr>
<td rowspan="3" width="67">r1</td>
<td width="104">t3</td>
<td width="227">url=http://www.taobao.com</td>
<td width="158">title=天天特价</td>
</tr>
<tr>
<td width="104">t2</td>
<td width="227">host=taobao.com</td>
<td width="158">&nbsp;</td>
</tr>
<tr>
<td width="104">t1</td>
<td width="227">&nbsp;</td>
<td width="158">&nbsp;</td>
</tr>
<tr>
<td rowspan="2" width="67">r2</td>
<td width="104">t5</td>
<td width="227">url=http://www.alibaba.com</td>
<td width="158">content=每天&hellip;</td>
</tr>
<tr>
<td width="104">t4</td>
<td width="227">host=alibaba.com</td>
<td width="158">&nbsp;</td>
</tr>
</tbody>
</table>

<span>&Oslash;&nbsp;&nbsp;Row Key: 行键，Table的主键，Table中的记录按照Row Key排序</span>

<span>&Oslash;&nbsp;&nbsp;Timestamp: 时间戳，每次数据操作对应的时间戳，可以看作是数据的version number</span>

<span>&Oslash;&nbsp;&nbsp;Column Family：列簇，Table在水平方向有一个或者多个Column Family组成，一个Column Family中可以由任意多个Column组成，即Column Family支持动态扩展，无需预先定义Column的数量以及类型，所有Column均以二进制格式存储，用户需要自行进行类型转换。</span>

&nbsp;

了解了HBase的体系结构和HBase数据视图够，现在让我们一起看看怎样通过Java来操作HBase数据吧！

先说说具体的API先，如下

&nbsp;

<span>HBaseConfiguration</span>是每一个hbase client都会使用到的对象，它代表的<span>是HBase配置信息</span>。它有两种构造方式：

public HBaseConfiguration()

public HBaseConfiguration(final Configuration c)

默认的构造方式会尝试从hbase-default.xml和hbase-site.xml中读取配置。如果classpath没有这两个文件，就需要你自己设置配置。

Configuration HBASE_CONFIG = new Configuration();

HBASE_CONFIG.set(&ldquo;hbase.zookeeper.quorum&rdquo;, &ldquo;zkServer&rdquo;);

HBASE_CONFIG.set(&ldquo;hbase.zookeeper.property.clientPort&rdquo;, &ldquo;2181&Prime;);

HBaseConfiguration cfg = new HBaseConfiguration(HBASE_CONFIG);

&nbsp;

创建表

<span>创建表是通过HBaseAdmin对象来操作的</span>。HBaseAdmin负责表的META信息处理。HBaseAdmin提供了createTable这个方法：

public void createTable(HTableDescriptor desc)

<span>HTableDescriptor 代表的是表的schema</span>, 提供的方法中比较有用的有

setMaxFileSize，指定最大的region size

setMemStoreFlushSize 指定memstore flush到HDFS上的文件大小

&nbsp;

增加family通过 addFamily方法

public void addFamily(final HColumnDescriptor family)

HColumnDescriptor 代表的是column的schema，提供的方法比较常用的有

<span>setTimeToLive:指定最大的TTL,单位是ms,过期数据会被自动删除</span>。

setInMemory:指定是否放在内存中，对小表有用，可用于提高效率。默认关闭

setBloomFilter:指定是否使用BloomFilter,可提高随机查询效率。默认关闭

setCompressionType:设定数据压缩类型。默认无压缩。

setMaxVersions:指定数据最大保存的版本个数。默认为3。

&nbsp;

<span>一个简单的例子，创建了4个family的表：</span>

<div class="cnblogs_code">
<pre>HBaseAdmin hAdmin = <span style="color: #0000ff;">new</span><span style="color: #000000;"> HBaseAdmin(hbaseConfig);

HTableDescriptor t </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> HTableDescriptor(tableName);

t.addFamily(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> HColumnDescriptor(&ldquo;f1&Prime;));

t.addFamily(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> HColumnDescriptor(&ldquo;f2&Prime;));

t.addFamily(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> HColumnDescriptor(&ldquo;f3&Prime;));

t.addFamily(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> HColumnDescriptor(&ldquo;f4&Prime;));

hAdmin.createTable(t);</span></pre>
</div>

&nbsp;

&nbsp;

删除表

<span>删除表也是通过HBaseAdmin来操作，删除表之前首先要disable表。</span>这是一个非常耗时的操作，所以不建议频繁删除表。

disableTable和deleteTable分别用来disable和delete表。

Example:

<div class="cnblogs_code">
<pre>HBaseAdmin hAdmin = <span style="color: #0000ff;">new</span><span style="color: #000000;"> HBaseAdmin(hbaseConfig);

</span><span style="color: #0000ff;">if</span><span style="color: #000000;"> (hAdmin.tableExists(tableName)) {

       hAdmin.disableTable(tableName);

       hAdmin.deleteTable(tableName);

}</span></pre>
</div>

<span style="line-height: 1.5;">&nbsp;</span>

查询数据

<span>查询分为单条随机查询和批量查询。</span>

<span>单条查询是通过rowkey在table中查询某一行的数据</span>。HTable提供了get方法来完成单条查询。

<span>批量查询是通过制定一段rowkey的范围来查询</span>。HTable提供了个getScanner方法来完成批量查询。

public Result get(final Get get)

public ResultScanner getScanner(final Scan scan)

Get对象包含了一个Get查询需要的信息。它的构造方法有两种：

&nbsp; public Get(byte [] row)

&nbsp; public Get(byte [] row, RowLock rowLock)

Rowlock是为了保证读写的原子性，你可以传递一个已经存在Rowlock，否则HBase会自动生成一个新的rowlock。

Scan对象提供了默认构造函数，一般使用默认构造函数。

&nbsp;

Get/Scan的常用方法有：

addFamily/addColumn:指定需要的family或者column,如果没有调用任何addFamily或者Column,会返回所有的columns.

setMaxVersions:指定最大的版本个数。如果不带任何参数调用setMaxVersions,表示取所有的版本。如果不掉用setMaxVersions,只会取到最新的版本。

setTimeRange:指定最大的时间戳和最小的时间戳，只有在此范围内的cell才能被获取。

setTimeStamp:指定时间戳。

setFilter:指定Filter来过滤掉不需要的信息

&nbsp;

Scan特有的方法：

setStartRow:指定开始的行。如果不调用，则从表头开始。

setStopRow:指定结束的行（不含此行）。

setBatch:指定最多返回的Cell数目。用于防止一行中有过多的数据，导致OutofMemory错误。

ResultScanner是Result的一个容器，每次调用ResultScanner的next方法，会返回Result.

public Result next() throws IOException;

public Result [] next(int nbRows) throws IOException;

&nbsp;

Result代表是一行的数据。常用方法有：

getRow:返回rowkey

raw:返回所有的key value数组。

getValue:按照column来获取cell的值

&nbsp;

Example:

<div class="cnblogs_code">
<pre>Scan s = <span style="color: #0000ff;">new</span><span style="color: #000000;"> Scan();

s.setMaxVersions();

ResultScanner ss </span>=<span style="color: #000000;"> table.getScanner(s);

</span><span style="color: #0000ff;">for</span><span style="color: #000000;">(Result r:ss){

    System.out.println(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> String(r.getRow()));

    </span><span style="color: #0000ff;">for</span><span style="color: #000000;">(KeyValue kv:r.raw()){

       System.out.println(</span><span style="color: #0000ff;">new</span><span style="color: #000000;"> String(kv.getColumn()));

    }

}</span></pre>
</div>

&nbsp;

&nbsp;

<span>插入数据</span>

HTable通过put方法来插入数据。&nbsp;

public void put(final Put put) throws IOException

public void put(final List&nbsp;puts) throws IOException

可以传递单个批Put对象或者List put对象来分别实现单条插入和批量插入。

Put提供了3种构造方式：

public Put(byte [] row)

public Put(byte [] row, RowLock rowLock)

public Put(Put putToCopy)&nbsp;

&nbsp;

Put常用的方法有：

add:增加一个Cell

setTimeStamp:指定所有cell默认的timestamp,如果一个Cell没有指定timestamp,就会用到这个值。如果没有调用，HBase会将当前时间作为未指定timestamp的cell的timestamp.

setWriteToWAL: WAL是Write Ahead Log的缩写，指的是HBase在插入操作前是否写Log。默认是打开，关掉会提高性能，但是如果系统出现故障(负责插入的Region Server挂掉)，数据可能会丢失。

另外HTable也有两个方法也会影响插入的性能

setAutoFlash: AutoFlush指的是在每次调用HBase的Put操作，是否提交到HBase Server。默认是true,每次会提交。如果此时是单条插入，就会有更多的IO,从而降低性能.

setWriteBufferSize: Write Buffer Size在AutoFlush为false的时候起作用，默认是2MB,也就是当插入数据超过2MB,就会自动提交到Server

&nbsp;

Example:

<div class="cnblogs_code">
<pre>HTable table = <span style="color: #0000ff;">new</span><span style="color: #000000;"> HTable(hbaseConfig, tableName);

table.setAutoFlush(autoFlush);

List lp </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> ArrayList();

</span><span style="color: #0000ff;">int</span> count = 10000<span style="color: #000000;">;

</span><span style="color: #0000ff;">byte</span>[] buffer = <span style="color: #0000ff;">new</span> <span style="color: #0000ff;">byte</span>[1024<span style="color: #000000;">];

Random r </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Random();

</span><span style="color: #0000ff;">for</span> (<span style="color: #0000ff;">int</span> i = 1; i &lt;= count; ++<span style="color: #000000;">i) {

       Put p </span>= <span style="color: #0000ff;">new</span> Put(String.format(&ldquo;row%<span style="color: #000000;">09d&rdquo;,i).getBytes());

       r.nextBytes(buffer);

       p.add(&ldquo;f1&Prime;.getBytes(), </span><span style="color: #0000ff;">null</span><span style="color: #000000;">, buffer);

       p.add(&ldquo;f2&Prime;.getBytes(), </span><span style="color: #0000ff;">null</span><span style="color: #000000;">, buffer);

       p.add(&ldquo;f3&Prime;.getBytes(), </span><span style="color: #0000ff;">null</span><span style="color: #000000;">, buffer);

       p.add(&ldquo;f4&Prime;.getBytes(), </span><span style="color: #0000ff;">null</span><span style="color: #000000;">, buffer);

       p.setWriteToWAL(wal);

       lp.add(p);

       </span><span style="color: #0000ff;">if</span>(i%1000==0<span style="color: #000000;">){

           table.put(lp);

           lp.clear();

       }

    }</span></pre>
</div>

&nbsp;

&nbsp;

<span>删除数据</span>

HTable 通过delete方法来删除数据。

&nbsp; public void delete(final Delete delete)&nbsp;

&nbsp;

Delete构造方法有：

public Delete(byte [] row)

public Delete(byte [] row, long timestamp, RowLock rowLock)

public Delete(final Delete d)

Delete常用方法有

deleteFamily/deleteColumns:指定要删除的family或者column的数据。如果不调用任何这样的方法，将会删除整行。

注意：如果某个Cell的timestamp高于当前时间，这个Cell将不会被删除，仍然可以查出来。

&nbsp;

Example:

<div class="cnblogs_code">
<pre>HTable table = <span style="color: #0000ff;">new</span><span style="color: #000000;"> HTable(hbaseConfig, &ldquo;mytest&rdquo;);

Delete d </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Delete(&ldquo;row1&Prime;.getBytes());

table.delete(d) </span></pre>
</div>

<span style="line-height: 1.5;">&nbsp;</span>

<span>切分表</span>

HBaseAdmin提供split方法来将table 进行split.

public void split(final String tableNameOrRegionName)

&nbsp;

如果提供的tableName，那么会将table所有region进行split ;如果提供的region Name，那么只会split这个region.

由于split是一个异步操作，我们并不能确切的控制region的个数。

&nbsp;

Example:

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> split(String tableName,<span style="color: #0000ff;">int</span> number,<span style="color: #0000ff;">int</span> timeout) <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception {

    Configuration HBASE_CONFIG </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> Configuration();

    HBASE_CONFIG.set(&ldquo;hbase.zookeeper.quorum&rdquo;, GlobalConf.ZOOKEEPER_QUORUM);

    HBASE_CONFIG.set(&ldquo;hbase.zookeeper.property.clientPort&rdquo;, GlobalConf.ZOOKEEPER_PORT);

    HBaseConfiguration cfg </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> HBaseConfiguration(HBASE_CONFIG);

    HBaseAdmin hAdmin </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> HBaseAdmin(cfg);

    HTable hTable </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> HTable(cfg,tableName);

    </span><span style="color: #0000ff;">int</span> oldsize = 0<span style="color: #000000;">;

    t </span>=<span style="color: #000000;">  System.currentTimeMillis();

    </span><span style="color: #0000ff;">while</span>(<span style="color: #0000ff;">true</span><span style="color: #000000;">){

       </span><span style="color: #0000ff;">int</span> size =<span style="color: #000000;"> hTable.getRegionsInfo().size();

       logger.info(&ldquo;the region number</span>=&rdquo;+<span style="color: #000000;">size);

       </span><span style="color: #0000ff;">if</span>(size&gt;=number ) <span style="color: #0000ff;">break</span><span style="color: #000000;">;

       </span><span style="color: #0000ff;">if</span>(size!=<span style="color: #000000;">oldsize){

           hAdmin.split(hTable.getTableName());

           oldsize </span>=<span style="color: #000000;"> size;

       }       </span><span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span>(System.currentTimeMillis()-t&gt;<span style="color: #000000;">timeout){

           </span><span style="color: #0000ff;">break</span><span style="color: #000000;">;

       }

       Thread.sleep(</span>1000*10<span style="color: #000000;">);

    }

}</span></pre>
</div>

&nbsp;

&nbsp;

来自：[http://www.open-open.com/lib/view/open1342514370807.html](http://www.open-open.com/lib/view/open1342514370807.html)