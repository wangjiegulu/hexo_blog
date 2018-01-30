---
title: lucene 使用教程
tags: [java, lucene]
date: 2013-02-24 09:59:00
---

<span>1 lucene简介&nbsp;</span>
<span>1.1 什么是lucene&nbsp;</span>
<span>Lucene是一个全文搜索框架，而不是应用产品。因此它并不像</span>[<span>http://www.baidu.com/</span>](http://www.baidu.com/)<span>&nbsp;或者google Desktop那么拿来就能用，它只是提供了一种工具让你能实现这些产品。</span>

<span>1.2 lucene能做什么&nbsp;</span>
<span>要回答这个问题，先要了解lucene的本质。实际上lucene的功能很单一，说到底，就是你给它若干个字符串，然后它为你提供一个全文搜索服务，告诉你你要搜索的关键词出现在哪里。知道了这个本质，你就可以发挥想象做任何符合这个条件的事情了。你可以把站内新闻都索引了，做个资料库；你可以把一个数据库表的若干个字段索引起来，那就不用再担心因为&ldquo;%like%&rdquo;而锁表了；你也可以写个自己的搜索引擎&hellip;&hellip;</span>

<span>1.3 你该不该选择lucene&nbsp;</span>
<span>下面给出一些测试数据，如果你觉得可以接受，那么可以选择。&nbsp;</span>
<span>测试一：250万记录，300M左右文本，生成索引380M左右，800线程下平均处理时间300ms。&nbsp;</span>
<span>测试二：37000记录，索引数据库中的两个varchar字段，索引文件2.6M，800线程下平均处理时间1.5ms。</span>

<span>2 lucene的工作方式&nbsp;</span>
<span>lucene提供的服务实际包含两部分：一入一出。所谓入是写入，即将你提供的源（本质是字符串）写入索引或者将其从索引中删除；所谓出是读出，即向用户提供全文搜索服务，让用户可以通过关键词定位源。</span>

<span>2.1写入流程&nbsp;</span>
<span>源字符串首先经过analyzer处理，包括：分词，分成一个个单词；去除stopword（可选）。&nbsp;</span>
<span>将源中需要的信息加入Document的各个Field中，并把需要索引的Field索引起来，把需要存储的Field存储起来。&nbsp;</span>
<span>将索引写入存储器，存储器可以是内存或磁盘。</span>

<span>2.2读出流程&nbsp;</span>
<span>用户提供搜索关键词，经过analyzer处理。&nbsp;</span>
<span>对处理后的关键词搜索索引找出对应的Document。&nbsp;</span>
<span>用户根据需要从找到的Document中提取需要的Field。</span>

<span>3 一些需要知道的概念&nbsp;</span>
<span>lucene用到一些概念，了解它们的含义，有利于下面的讲解。</span>

<span>3.1 analyzer&nbsp;</span>
<span>Analyzer 是分析器，它的作用是把一个字符串按某种规则划分成一个个词语，并去除其中的无效词语，这里说的无效词语是指英文中的&ldquo;of&rdquo;、 &ldquo;the&rdquo;，中文中的 &ldquo;的&rdquo;、&ldquo;地&rdquo;等词语，这些词语在文章中大量出现，但是本身不包含什么关键信息，去掉有利于缩小索引文件、提高效率、提高命中率。&nbsp;</span>
<span>分词的规则千变万化，但目的只有一个：按语义划分。这点在英文中比较容易实现，因为英文本身就是以单词为单位的，已经用空格分开；而中文则必须以某种方法将连成一片的句子划分成一个个词语。具体划分方法下面再详细介绍，这里只需了解分析器的概念即可。</span>

<span>3.2 document&nbsp;</span>
<span>用户提供的源是一条条记录，它们可以是文本文件、字符串或者数据库表的一条记录等等。一条记录经过索引之后，就是以一个Document的形式存储在索引文件中的。用户进行搜索，也是以Document列表的形式返回。</span>

<span>3.3 field&nbsp;</span>
<span>一个Document可以包含多个信息域，例如一篇文章可以包含&ldquo;标题&rdquo;、&ldquo;正文&rdquo;、&ldquo;最后修改时间&rdquo;等信息域，这些信息域就是通过Field在Document中存储的。&nbsp;</span>
<span>Field有两个属性可选：存储和索引。通过存储属性你可以控制是否对这个Field进行存储；通过索引属性你可以控制是否对该Field进行索引。这看起来似乎有些废话，事实上对这两个属性的正确组合很重要，下面举例说明：&nbsp;</span>
<span>还是以刚才的文章为例子，我们需要对标题和正文进行全文搜索，所以我们要把索引属性设置为真，同时我们希望能直接从搜索结果中提取文章标题，所以我们把标题域的存储属性设置为真，但是由于正文域太大了，我们为了缩小索引文件大小，将正文域的存储属性设置为假，当需要时再直接读取文件；我们只是希望能从搜索解果中提取最后修改时间，不需要对它进行搜索，所以我们把最后修改时间域的存储属性设置为真，索引属性设置为假。上面的三个域涵盖了两个属性的三种组合，还有一种全为假的没有用到，事实上Field不允许你那么设置，因为既不存储又不索引的域是没有意义的。</span>

<span>3.4 term&nbsp;</span>
<span>term是搜索的最小单位，它表示文档的一个词语，term由两部分组成：它表示的词语和这个词语所出现的field。</span>

<span>3.5 tocken&nbsp;</span>
<span>tocken是term的一次出现，它包含trem文本和相应的起止偏移，以及一个类型字符串。一句话中可以出现多次相同的词语，它们都用同一个term表示，但是用不同的tocken，每个tocken标记该词语出现的地方。</span>

<span>3.6 segment&nbsp;</span>
<span>添加索引时并不是每个document都马上添加到同一个索引文件，它们首先被写入到不同的小文件，然后再合并成一个大索引文件，这里每个小文件都是一个segment。</span>

<span>4 lucene的结构&nbsp;</span>
<span>lucene包括core和sandbox两部分，其中core是lucene稳定的核心部分，sandbox包含了一些附加功能，例如highlighter、各种分析器。&nbsp;</span>
<span>Lucene core有七个包：analysis，document，index，queryParser，search，store，util。&nbsp;</span>
<span>4.1 analysis&nbsp;</span>
<span>Analysis包含一些内建的分析器，例如按空白字符分词的WhitespaceAnalyzer，添加了stopwrod过滤的StopAnalyzer，最常用的StandardAnalyzer。&nbsp;</span>
<span>4.2 document&nbsp;</span>
<span>Document包含文档的数据结构，例如Document类定义了存储文档的数据结构，Field类定义了Document的一个域。&nbsp;</span>
<span>4.3 index&nbsp;</span>
<span>Index 包含了索引的读写类，例如对索引文件的segment进行写、合并、优化的IndexWriter类和对索引进行读取和删除操作的 IndexReader类，这里要注意的是不要被IndexReader这个名字误导，以为它是索引文件的读取类，实际上删除索引也是由它完成， IndexWriter只关心如何将索引写入一个个segment，并将它们合并优化；IndexReader则关注索引文件中各个文档的组织形式。&nbsp;</span>
<span>4.4 queryParser&nbsp;</span>
<span>QueryParser 包含了解析查询语句的类，lucene的查询语句和sql语句有点类似，有各种保留字，按照一定的语法可以组成各种查询。 Lucene有很多种 Query类，它们都继承自Query，执行各种特殊的查询，QueryParser的作用就是解析查询语句，按顺序调用各种 Query类查找出结果。&nbsp;</span>
<span>4.5 search&nbsp;</span>
<span>Search包含了从索引中搜索结果的各种类，例如刚才说的各种Query类，包括TermQuery、BooleanQuery等就在这个包里。&nbsp;</span>
<span>4.6 store&nbsp;</span>
<span>Store包含了索引的存储类，例如Directory定义了索引文件的存储结构，FSDirectory为存储在文件中的索引，RAMDirectory为存储在内存中的索引，MmapDirectory为使用内存映射的索引。&nbsp;</span>
<span>4.7 util&nbsp;</span>
<span>Util包含一些公共工具类，例如时间和字符串之间的转换工具。</span>

<span>5 如何建索引&nbsp;</span>
<span>5.1 最简单的能完成索引的代码片断</span>

<span>IndexWriter writer = new IndexWriter(&ldquo;/data/index/&rdquo;, new StandardAnalyzer(), true);&nbsp;</span>
<span>Document doc = new Document();&nbsp;</span>
<span>doc.add(new Field("title", "lucene introduction", Field.Store.YES, Field.Index.TOKENIZED));&nbsp;</span>
<span>doc.add(new Field("content", "lucene works well", Field.Store.YES, Field.Index.TOKENIZED));&nbsp;</span>
<span>writer.addDocument(doc);&nbsp;</span>
<span>writer.optimize();&nbsp;</span>
<span>writer.close();</span>

<span>下面我们分析一下这段代码。&nbsp;</span>
<span>首先我们创建了一个writer，并指定存放索引的目录为&ldquo;/data/index&rdquo;，使用的分析器为StandardAnalyzer，第三个参数说明如果已经有索引文件在索引目录下，我们将覆盖它们。&nbsp;</span>
<span>然后我们新建一个document。&nbsp;</span>
<span>我们向document添加一个field，名字是&ldquo;title&rdquo;，内容是&ldquo;lucene introduction&rdquo;，对它进行存储并索引。&nbsp;</span>
<span>再添加一个名字是&ldquo;content&rdquo;的field，内容是&ldquo;lucene works well&rdquo;，也是存储并索引。&nbsp;</span>
<span>然后我们将这个文档添加到索引中，如果有多个文档，可以重复上面的操作，创建document并添加。&nbsp;</span>
<span>添加完所有document，我们对索引进行优化，优化主要是将多个segment合并到一个，有利于提高索引速度。&nbsp;</span>
<span>随后将writer关闭，这点很重要。</span>

<span>对，创建索引就这么简单！&nbsp;</span>
<span>当然你可能修改上面的代码获得更具个性化的服务。</span>

<span>5.2 将索引直接写在内存&nbsp;</span>
<span>你需要首先创建一个RAMDirectory，并将其传给writer，代码如下：</span>

<span>Directory dir = new RAMDirectory();&nbsp;</span>
<span>IndexWriter writer = new IndexWriter(dir, new StandardAnalyzer(), true);&nbsp;</span>
<span>Document doc = new Document();&nbsp;</span>
<span>doc.add(new Field("title", "lucene introduction", Field.Store.YES, Field.Index.TOKENIZED));&nbsp;</span>
<span>doc.add(new Field("content", "lucene works well", Field.Store.YES, Field.Index.TOKENIZED));&nbsp;</span>
<span>writer.addDocument(doc);&nbsp;</span>
<span>writer.optimize();&nbsp;</span>
<span>writer.close();</span>

<span>5.3 索引文本文件&nbsp;</span>
<span>如果你想把纯文本文件索引起来，而不想自己将它们读入字符串创建field，你可以用下面的代码创建field：</span>

<span>Field field = new Field("content", new FileReader(file));</span>

<span>这里的file就是该文本文件。该构造函数实际上是读去文件内容，并对其进行索引，但不存储。</span>

<span>6 如何维护索引&nbsp;</span>
<span>索引的维护操作都是由IndexReader类提供。</span>

<span>6.1 如何删除索引&nbsp;</span>
<span>lucene提供了两种从索引中删除document的方法，一种是</span>

<span>void deleteDocument(int docNum)</span>

<span>这种方法是根据document在索引中的编号来删除，每个document加进索引后都会有个唯一编号，所以根据编号删除是一种精确删除，但是这个编号是索引的内部结构，一般我们不会知道某个文件的编号到底是几，所以用处不大。另一种是</span>

<span>void deleteDocuments(Term term)</span>

<span>这种方法实际上是首先根据参数term执行一个搜索操作，然后把搜索到的结果批量删除了。我们可以通过这个方法提供一个严格的查询条件，达到删除指定document的目的。&nbsp;</span>
<span>下面给出一个例子：</span>

<span>Directory dir = FSDirectory.getDirectory(PATH, false);&nbsp;</span>
<span>IndexReader reader = IndexReader.open(dir);&nbsp;</span>
<span>Term term = new Term(field, key);&nbsp;</span>
<span>reader.deleteDocuments(term);&nbsp;</span>
<span>reader.close();</span>

<span>6.2 如何更新索引&nbsp;</span>
<span>lucene并没有提供专门的索引更新方法，我们需要先将相应的document删除，然后再将新的document加入索引。例如：</span>

<span>Directory dir = FSDirectory.getDirectory(PATH, false);&nbsp;</span>
<span>IndexReader reader = IndexReader.open(dir);&nbsp;</span>
<span>Term term = new Term(&ldquo;title&rdquo;, &ldquo;lucene introduction&rdquo;);&nbsp;</span>
<span>reader.deleteDocuments(term);&nbsp;</span>
<span>reader.close();</span>

<span>IndexWriter writer = new IndexWriter(dir, new StandardAnalyzer(), true);&nbsp;</span>
<span>Document doc = new Document();&nbsp;</span>
<span>doc.add(new Field("title", "lucene introduction", Field.Store.YES, Field.Index.TOKENIZED));&nbsp;</span>
<span>doc.add(new Field("content", "lucene is funny", Field.Store.YES, Field.Index.TOKENIZED));&nbsp;</span>
<span>writer.addDocument(doc);&nbsp;</span>
<span>writer.optimize();&nbsp;</span>
<span>writer.close();</span>

<span>7 如何搜索&nbsp;</span>
<span>lucene 的搜索相当强大，它提供了很多辅助查询类，每个类都继承自Query类，各自完成一种特殊的查询，你可以像搭积木一样将它们任意组合使用，完成一些复杂操作；另外lucene还提供了Sort类对结果进行排序，提供了Filter类对查询条件进行限制。你或许会不自觉地拿它跟SQL语句进行比较： &ldquo;lucene能执行and、or、order by、where、like &lsquo;%xx%&rsquo;操作吗？&rdquo;回答是：&ldquo;当然没问题！&rdquo;</span>

<span>7.1 各种各样的Query&nbsp;</span>
<span>下面我们看看lucene到底允许我们进行哪些查询操作：</span>

<span>7.1.1 TermQuery&nbsp;</span>
<span>首先介绍最基本的查询，如果你想执行一个这样的查询：&ldquo;在content域中包含&lsquo;lucene&rsquo;的document&rdquo;，那么你可以用TermQuery：</span>

<span>Term t = new Term("content", " lucene";&nbsp;</span>
<span>Query query = new TermQuery(t);</span>

<span>7.1.2 BooleanQuery&nbsp;</span>
<span>如果你想这么查询：&ldquo;在content域中包含java或perl的document&rdquo;，那么你可以建立两个TermQuery并把它们用BooleanQuery连接起来：</span>

<span>TermQuery termQuery1 = new TermQuery(new Term("content", "java");&nbsp;</span>
<span>TermQuery termQuery 2 = new TermQuery(new Term("content", "perl");&nbsp;</span>
<span>BooleanQuery booleanQuery = new BooleanQuery();&nbsp;</span>
<span>booleanQuery.add(termQuery 1, BooleanClause.Occur.SHOULD);&nbsp;</span>
<span>booleanQuery.add(termQuery 2, BooleanClause.Occur.SHOULD);</span>

<span>7.1.3 WildcardQuery&nbsp;</span>
<span>如果你想对某单词进行通配符查询，你可以用WildcardQuery，通配符包括&rsquo;?&rsquo;匹配一个任意字符和&rsquo;*&rsquo;匹配零个或多个任意字符，例如你搜索&rsquo;use*&rsquo;，你可能找到&rsquo;useful&rsquo;或者&rsquo;useless&rsquo;：</span>

<span>Query query = new WildcardQuery(new Term("content", "use*");</span>

<span>7.1.4 PhraseQuery&nbsp;</span>
<span>你可能对中日关系比较感兴趣，想查找&lsquo;中&rsquo;和&lsquo;日&rsquo;挨得比较近（5个字的距离内）的文章，超过这个距离的不予考虑，你可以：</span>

<span>PhraseQuery query = new PhraseQuery();&nbsp;</span>
<span>query.setSlop(5);&nbsp;</span>
<span>query.add(new Term("content ", &ldquo;中&rdquo;));&nbsp;</span>
<span>query.add(new Term(&ldquo;content&rdquo;, &ldquo;日&rdquo;));</span>

<span>那么它可能搜到&ldquo;中日合作&hellip;&hellip;&rdquo;、&ldquo;中方和日方&hellip;&hellip;&rdquo;，但是搜不到&ldquo;中国某高层领导说日本欠扁&rdquo;。</span>

<span>7.1.5 PrefixQuery&nbsp;</span>
<span>如果你想搜以&lsquo;中&rsquo;开头的词语，你可以用PrefixQuery：</span>

<span>PrefixQuery query = new PrefixQuery(new Term("content ", "中");</span>

<span>7.1.6 FuzzyQuery&nbsp;</span>
<span>FuzzyQuery用来搜索相似的term，使用Levenshtein算法。假设你想搜索跟&lsquo;wuzza&rsquo;相似的词语，你可以：</span>

<span>Query query = new FuzzyQuery(new Term("content", "wuzza");</span>

<span>你可能得到&lsquo;fuzzy&rsquo;和&lsquo;wuzzy&rsquo;。</span>

<span>7.1.7 RangeQuery&nbsp;</span>
<span>另一个常用的Query是RangeQuery，你也许想搜索时间域从20060101到20060130之间的document，你可以用RangeQuery：</span>

<span>RangeQuery query = new RangeQuery(new Term(&ldquo;time&rdquo;, &ldquo;20060101&rdquo;), new Term(&ldquo;time&rdquo;, &ldquo;20060130&rdquo;), true);</span>

<span>最后的true表示用闭合区间。</span>

<span>7.2 QueryParser&nbsp;</span>
<span>看了这么多Query，你可能会问：&ldquo;不会让我自己组合各种Query吧，太麻烦了！&rdquo;当然不会，lucene提供了一种类似于SQL语句的查询语句，我们姑且叫它lucene语句，通过它，你可以把各种查询一句话搞定，lucene会自动把它们查分成小块交给相应Query执行。下面我们对应每种 Query演示一下：&nbsp;</span>
<span>TermQuery可以用&ldquo;field:key&rdquo;方式，例如&ldquo;content:lucene&rdquo;。&nbsp;</span>
<span>BooleanQuery中&lsquo;与&rsquo;用&lsquo;+&rsquo;，&lsquo;或&rsquo;用&lsquo; &rsquo;，例如&ldquo;content:java contenterl&rdquo;。&nbsp;</span>
<span>WildcardQuery仍然用&lsquo;?&rsquo;和&lsquo;*&rsquo;，例如&ldquo;content:use*&rdquo;。&nbsp;</span>
<span>PhraseQuery用&lsquo;~&rsquo;，例如&ldquo;content:"中日"~5&rdquo;。&nbsp;</span>
<span>PrefixQuery用&lsquo;*&rsquo;，例如&ldquo;中*&rdquo;。&nbsp;</span>
<span>FuzzyQuery用&lsquo;~&rsquo;，例如&ldquo;content: wuzza ~&rdquo;。&nbsp;</span>
<span>RangeQuery用&lsquo;[]&rsquo;或&lsquo;{}&rsquo;，前者表示闭区间，后者表示开区间，例如&ldquo;time:[20060101 TO 20060130]&rdquo;，注意TO区分大小写。&nbsp;</span>
<span>你可以任意组合query string，完成复杂操作，例如&ldquo;标题或正文包括lucene，并且时间在20060101到20060130之间的文章&rdquo;可以表示为：&ldquo;+ (title:lucene content:lucene) +time:[20060101 TO 20060130]&rdquo;。代码如下：</span>

<span>Directory dir = FSDirectory.getDirectory(PATH, false);&nbsp;</span>
<span>IndexSearcher is = new IndexSearcher(dir);&nbsp;</span>
<span>QueryParser parser = new QueryParser("content", new StandardAnalyzer());&nbsp;</span>
<span>Query query = parser.parse("+(title:lucene content:lucene) +time:[20060101 TO 20060130]";&nbsp;</span>
<span>Hits hits = is.search(query);&nbsp;</span>
<span>for (int i = 0; i &lt; hits.length(); i++)&nbsp;</span>
<span>{&nbsp;</span>
<span>Document doc = hits.doc(i);&nbsp;</span>
<span>System.out.println(doc.get("title");&nbsp;</span>
<span>}&nbsp;</span>
<span>is.close();</span>

<span>首先我们创建一个在指定文件目录上的IndexSearcher。&nbsp;</span>
<span>然后创建一个使用StandardAnalyzer作为分析器的QueryParser，它默认搜索的域是content。&nbsp;</span>
<span>接着我们用QueryParser来parse查询字串，生成一个Query。&nbsp;</span>
<span>然后利用这个Query去查找结果，结果以Hits的形式返回。&nbsp;</span>
<span>这个Hits对象包含一个列表，我们挨个把它的内容显示出来。</span>

<span>7.3 Filter&nbsp;</span>
<span>filter 的作用就是限制只查询索引的某个子集，它的作用有点像SQL语句里的where，但又有区别，它不是正规查询的一部分，只是对数据源进行预处理，然后交给查询语句。注意它执行的是预处理，而不是对查询结果进行过滤，所以使用filter的代价是很大的，它可能会使一次查询耗时提高一百倍。&nbsp;</span>
<span>最常用的filter是RangeFilter和QueryFilter。RangeFilter是设定只搜索指定范围内的索引；QueryFilter是在上次查询的结果中搜索。&nbsp;</span>
<span>Filter的使用非常简单，你只需创建一个filter实例，然后把它传给searcher。继续上面的例子，查询&ldquo;时间在20060101到20060130之间的文章&rdquo;除了将限制写在query string中，你还可以写在RangeFilter中：</span>

<span>Directory dir = FSDirectory.getDirectory(PATH, false);&nbsp;</span>
<span>IndexSearcher is = new IndexSearcher(dir);&nbsp;</span>
<span>QueryParser parser = new QueryParser("content", new StandardAnalyzer());&nbsp;</span>
<span>Query query = parser.parse("title:lucene content:lucene";&nbsp;</span>
<span>RangeFilter filter = new RangeFilter("time", "20060101", "20060230", true, true);&nbsp;</span>
<span>Hits hits = is.search(query, filter);&nbsp;</span>
<span>for (int i = 0; i &lt; hits.length(); i++)&nbsp;</span>
<span>{&nbsp;</span>
<span>Document doc = hits.doc(i);&nbsp;</span>
<span>System.out.println(doc.get("title");&nbsp;</span>
<span>}&nbsp;</span>
<span>is.close();</span>

<span>7.4 Sort&nbsp;</span>
<span>有时你想要一个排好序的结果集，就像SQL语句的&ldquo;order by&rdquo;，lucene能做到：通过Sort。&nbsp;</span>
<span>Sort sort = new Sort(&ldquo;time&rdquo;); //相当于SQL的&ldquo;order by time&rdquo;&nbsp;</span>
<span>Sort sort = new Sort(&ldquo;time&rdquo;, true); // 相当于SQL的&ldquo;order by time desc&rdquo;&nbsp;</span>
<span>下面是一个完整的例子：</span>

<span>Directory dir = FSDirectory.getDirectory(PATH, false);&nbsp;</span>
<span>IndexSearcher is = new IndexSearcher(dir);&nbsp;</span>
<span>QueryParser parser = new QueryParser("content", new StandardAnalyzer());&nbsp;</span>
<span>Query query = parser.parse("title:lucene content:lucene";&nbsp;</span>
<span>RangeFilter filter = new RangeFilter("time", "20060101", "20060230", true, true);&nbsp;</span>
<span>Sort sort = new Sort(&ldquo;time&rdquo;);&nbsp;</span>
<span>Hits hits = is.search(query, filter, sort);&nbsp;</span>
<span>for (int i = 0; i &lt; hits.length(); i++)&nbsp;</span>
<span>{&nbsp;</span>
<span>Document doc = hits.doc(i);&nbsp;</span>
<span>System.out.println(doc.get("title");&nbsp;</span>
<span>}&nbsp;</span>
<span>is.close();</span>

<span>8 分析器&nbsp;</span>
<span>在前面的概念介绍中我们已经知道了分析器的作用，就是把句子按照语义切分成一个个词语。英文切分已经有了很成熟的分析器： StandardAnalyzer，很多情况下StandardAnalyzer是个不错的选择。甚至你会发现StandardAnalyzer也能对中文进行分词。&nbsp;</span>
<span>但是我们的焦点是中文分词，StandardAnalyzer能支持中文分词吗？实践证明是可以的，但是效果并不好，搜索&ldquo;如果&rdquo; 会把&ldquo;牛奶不如果汁好喝&rdquo;也搜索出来，而且索引文件很大。那么我们手头上还有什么分析器可以使用呢？core里面没有，我们可以在sandbox里面找到两个： ChineseAnalyzer和CJKAnalyzer。但是它们同样都有分词不准的问题。相比之下用StandardAnalyzer和 ChineseAnalyzer建立索引时间差不多，索引文件大小也差不多，CJKAnalyzer表现会差些，索引文件大且耗时比较长。&nbsp;</span>
<span>要解决问题，首先分析一下这三个分析器的分词方式。StandardAnalyzer和ChineseAnalyzer都是把句子按单个字切分，也就是说 &ldquo;牛奶不如果汁好喝&rdquo;会被它们切分成&ldquo;牛 奶 不 如 果 汁 好 喝&rdquo;；而CJKAnalyzer则会切分成&ldquo;牛奶 奶不 不如 如果 果汁 汁好好喝&rdquo;。这也就解释了为什么搜索&ldquo;果汁&rdquo;都能匹配这个句子。&nbsp;</span>
<span>以上分词的缺点至少有两个：匹配不准确和索引文件大。我们的目标是将上面的句子分解成 &ldquo;牛奶 不如 果汁好喝&rdquo;。这里的关键就是语义识别，我们如何识别&ldquo;牛奶&rdquo;是一个词而&ldquo;奶不&rdquo;不是词语？我们很自然会想到基于词库的分词法，也就是我们先得到一个词库，里面列举了大部分词语，我们把句子按某种方式切分，当得到的词语与词库中的项匹配时，我们就认为这种切分是正确的。这样切词的过程就转变成匹配的过程，而匹配的方式最简单的有正向最大匹配和逆向最大匹配两种，说白了就是一个从句子开头向后进行匹配，一个从句子末尾向前进行匹配。基于词库的分词词库非常重要，词库的容量直接影响搜索结果，在相同词库的前提下，据说逆向最大匹配优于正向最大匹配。&nbsp;</span>
<span>当然还有别的分词方法，这本身就是一个学科，我这里也没有深入研究。回到具体应用，我们的目标是能找到成熟的、现成的分词工具，避免重新发明车轮。经过网上搜索，用的比较多的是中科院的 ICTCLAS和一个不开放源码但是免费的JE-Analysis。ICTCLAS有个问题是它是一个动态链接库， java调用需要本地方法调用，不方便也有安全隐患，而且口碑也确实不大好。JE-Analysis效果还不错，当然也会有分词不准的地方，相比比较方便放心。</span>

<span>9 性能优化&nbsp;</span>
<span>一直到这里，我们还是在讨论怎么样使lucene跑起来，完成指定任务。利用前面说的也确实能完成大部分功能。但是测试表明lucene的性能并不是很好，在大数据量大并发的条件下甚至会有半分钟返回的情况。另外大数据量的数据初始化建立索引也是一个十分耗时的过程。那么如何提高lucene的性能呢？下面从优化创建索引性能和优化搜索性能两方面介绍。</span>

<span>9.1 优化创建索引性能&nbsp;</span>
<span>这方面的优化途径比较有限，IndexWriter提供了一些接口可以控制建立索引的操作，另外我们可以先将索引写入RAMDirectory，再批量写入FSDirectory，不管怎样，目的都是尽量少的文件IO，因为创建索引的最大瓶颈在于磁盘IO。另外选择一个较好的分析器也能提高一些性能。</span>

<span>9.1.1 通过设置IndexWriter的参数优化索引建立&nbsp;</span>
<span>setMaxBufferedDocs(int maxBufferedDocs)&nbsp;</span>
<span>控制写入一个新的segment前内存中保存的document的数目，设置较大的数目可以加快建索引速度，默认为10。&nbsp;</span>
<span>setMaxMergeDocs(int maxMergeDocs)&nbsp;</span>
<span>控制一个segment中可以保存的最大document数目，值较小有利于追加索引的速度，默认Integer.MAX_VALUE，无需修改。&nbsp;</span>
<span>setMergeFactor(int mergeFactor)&nbsp;</span>
<span>控制多个segment合并的频率，值较大时建立索引速度较快，默认是10，可以在建立索引时设置为100。</span>

<span>9.1.2 通过RAMDirectory缓写提高性能&nbsp;</span>
<span>我们可以先把索引写入RAMDirectory，达到一定数量时再批量写进FSDirectory，减少磁盘IO次数。</span>

<span>FSDirectory fsDir = FSDirectory.getDirectory("/data/index", true);&nbsp;</span>
<span>RAMDirectory ramDir = new RAMDirectory();&nbsp;</span>
<span>IndexWriter fsWriter = new IndexWriter(fsDir, new StandardAnalyzer(), true);&nbsp;</span>
<span>IndexWriter ramWriter = new IndexWriter(ramDir, new StandardAnalyzer(), true);&nbsp;</span>
<span>while (there are documents to index)&nbsp;</span>
<span>{&nbsp;</span>
<span>... create Document ...&nbsp;</span>
<span>ramWriter.addDocument(doc);&nbsp;</span>
<span>if (condition for flushing memory to disk has been met)&nbsp;</span>
<span>{&nbsp;</span>
<span>fsWriter.addIndexes(new Directory[] { ramDir });&nbsp;</span>
<span>ramWriter.close();&nbsp;</span>
<span>ramWriter = new IndexWriter(ramDir, new StandardAnalyzer(), true);&nbsp;</span>
<span>}&nbsp;</span>
<span>}</span>

<span>9.1.3 选择较好的分析器&nbsp;</span>
<span>这个优化主要是对磁盘空间的优化，可以将索引文件减小将近一半，相同测试数据下由600M减少到380M。但是对时间并没有什么帮助，甚至会需要更长时间，因为较好的分析器需要匹配词库，会消耗更多cpu，测试数据用StandardAnalyzer耗时133分钟；用MMAnalyzer耗时150分钟。</span>

<span>9.2 优化搜索性能&nbsp;</span>
<span>虽然建立索引的操作非常耗时，但是那毕竟只在最初创建时才需要，平时只是少量的维护操作，更何况这些可以放到一个后台进程处理，并不影响用户搜索。我们创建索引的目的就是给用户搜索，所以搜索的性能才是我们最关心的。下面就来探讨一下如何提高搜索性能。</span>

<span>9.2.1 将索引放入内存&nbsp;</span>
<span>这是一个最直观的想法，因为内存比磁盘快很多。Lucene提供了RAMDirectory可以在内存中容纳索引：</span>

<span>Directory fsDir = FSDirectory.getDirectory(&ldquo;/data/index/&rdquo;, false);&nbsp;</span>
<span>Directory ramDir = new RAMDirectory(fsDir);&nbsp;</span>
<span>Searcher searcher = new IndexSearcher(ramDir);</span>

<span>但是实践证明RAMDirectory和FSDirectory速度差不多，当数据量很小时两者都非常快，当数据量较大时（索引文件400M）RAMDirectory甚至比FSDirectory还要慢一点，这确实让人出乎意料。&nbsp;</span>
<span>而且lucene的搜索非常耗内存，即使将400M的索引文件载入内存，在运行一段时间后都会out of memory，所以个人认为载入内存的作用并不大。</span>

<span>9.2.2 优化时间范围限制&nbsp;</span>
<span>既然载入内存并不能提高效率，一定有其它瓶颈，经过测试发现最大的瓶颈居然是时间范围限制，那么我们可以怎样使时间范围限制的代价最小呢？&nbsp;</span>
<span>当需要搜索指定时间范围内的结果时，可以：&nbsp;</span>
<span>1、用RangeQuery，设置范围，但是RangeQuery的实现实际上是将时间范围内的时间点展开，组成一个个BooleanClause加入到 BooleanQuery中查询，因此时间范围不可能设置太大，经测试，范围超过一个月就会抛 BooleanQuery.TooManyClauses，可以通过设置 BooleanQuery.setMaxClauseCount (int maxClauseCount)扩大，但是扩大也是有限的，并且随着maxClauseCount扩大，占用内存也扩大&nbsp;</span>
<span>2、用 RangeFilter代替RangeQuery，经测试速度不会比RangeQuery慢，但是仍然有性能瓶颈，查询的90%以上时间耗费在 RangeFilter，研究其源码发现RangeFilter实际上是首先遍历所有索引，生成一个BitSet，标记每个document，在时间范围内的标记为true，不在的标记为false，然后将结果传递给Searcher查找，这是十分耗时的。&nbsp;</span>
<span>3、进一步提高性能，这个又有两个思路：&nbsp;</span>
<span>a、缓存Filter结果。既然RangeFilter的执行是在搜索之前，那么它的输入都是一定的，就是IndexReader，而 IndexReader是由Directory决定的，所以可以认为RangeFilter的结果是由范围的上下限决定的，也就是由具体的 RangeFilter对象决定，所以我们只要以RangeFilter对象为键，将filter结果BitSet缓存起来即可。lucene API 已经提供了一个CachingWrapperFilter类封装了Filter及其结果，所以具体实施起来我们可以 cache CachingWrapperFilter对象，需要注意的是，不要被CachingWrapperFilter的名字及其说明误导， CachingWrapperFilter看起来是有缓存功能，但的缓存是针对同一个filter的，也就是在你用同一个filter过滤不同 IndexReader时，它可以帮你缓存不同IndexReader的结果，而我们的需求恰恰相反，我们是用不同filter过滤同一个 IndexReader，所以只能把它作为一个封装类。&nbsp;</span>
<span>b、降低时间精度。研究Filter的工作原理可以看出，它每次工作都是遍历整个索引的，所以时间粒度越大，对比越快，搜索时间越短，在不影响功能的情况下，时间精度越低越好，有时甚至牺牲一点精度也值得，当然最好的情况是根本不作时间限制。&nbsp;</span>
<span>下面针对上面的两个思路演示一下优化结果（都采用800线程随机关键词随即时间范围）：&nbsp;</span>
<span>第一组，时间精度为秒：&nbsp;</span>
<span>方式 直接用RangeFilter 使用cache 不用filter&nbsp;</span>
<span>平均每个线程耗时 10s 1s 300ms</span>

<span>第二组，时间精度为天&nbsp;</span>
<span>方式 直接用RangeFilter 使用cache 不用filter&nbsp;</span>
<span>平均每个线程耗时 900ms 360ms 300ms</span>

<span>由以上数据可以得出结论：&nbsp;</span>
<span>1、 尽量降低时间精度，将精度由秒换成天带来的性能提高甚至比使用cache还好，最好不使用filter。&nbsp;</span>
<span>2、 在不能降低时间精度的情况下，使用cache能带了10倍左右的性能提高。</span>

<span>9.2.3 使用更好的分析器&nbsp;</span>
<span>这个跟创建索引优化道理差不多，索引文件小了搜索自然会加快。当然这个提高也是有限的。较好的分析器相对于最差的分析器对性能的提升在20%以下。</span>

<span>10 一些经验</span>

<span>10.1关键词区分大小写&nbsp;</span>
<span>or AND TO等关键词是区分大小写的，lucene只认大写的，小写的当做普通单词。</span>

<span>10.2 读写互斥性&nbsp;</span>
<span>同一时刻只能有一个对索引的写操作，在写的同时可以进行搜索</span>

<span>10.3 文件锁&nbsp;</span>
<span>在写索引的过程中强行退出将在tmp目录留下一个lock文件，使以后的写操作无法进行，可以将其手工删除</span>

<span>10.4 时间格式&nbsp;</span>
<span>lucene只支持一种时间格式yyMMddHHmmss，所以你传一个yy-MM-dd HH:mm:ss的时间给lucene它是不会当作时间来处理的</span>

<span>10.5 设置boost&nbsp;</span>
<span>有些时候在搜索时某个字段的权重需要大一些，例如你可能认为标题中出现关键词的文章比正文中出现关键词的文章更有价值，你可以把标题的boost设置的更大，那么搜索结果会优先显示标题中出现关键词的文章（没有使用排序的前题下）。使用方法：&nbsp;</span>
<span>Field. setBoost(float boost);默认值是1.0，也就是说要增加权重的需要设置得比1大。</span>

