---
title: 'Hibernate3注解[转]'
tags: []
date: 2013-10-08 14:40:00
---

&nbsp;Hibernate3注解 收藏&nbsp;
1、@Entity(name="EntityName")&nbsp;
必须,name为可选,对应数据库中一的个表

2、@Table(name="",catalog="",schema="")&nbsp;
可选,通常和@Entity配合使用,只能标注在实体的class定义处,表示实体对应的数据库表的信息&nbsp;
name:可选,表示表的名称.默认地,表名和实体名称一致,只有在不一致的情况下才需要指定表名&nbsp;
catalog:可选,表示Catalog名称,默认为Catalog("").&nbsp;
schema:可选,表示Schema名称,默认为Schema("").

3、@id&nbsp;
必须&nbsp;
@id定义了映射到数据库表的主键的属性,一个实体只能有一个属性被映射为主键.置于getXxxx()前.

4、@GeneratedValue(strategy=GenerationType,generator="")&nbsp;
可选&nbsp;
strategy:表示主键生成策略,有AUTO,INDENTITY,SEQUENCE 和 TABLE 4种,分别表示让ORM框架自动选择,&nbsp;
根据数据库的Identity字段生成,根据数据库表的Sequence字段生成,以有根据一个额外的表生成主键,默认为AUTO&nbsp;
generator:表示主键生成器的名称,这个属性通常和ORM框架相关,例如,Hibernate可以指定uuid等主键生成方式.&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; @Id&nbsp;
&nbsp;&nbsp;&nbsp; @GeneratedValues(strategy=StrategyType.SEQUENCE)&nbsp;
&nbsp;&nbsp;&nbsp; public int getPk() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return pk;&nbsp;
&nbsp;&nbsp;&nbsp; }

5、@Basic(fetch=FetchType,optional=true)&nbsp;
可选&nbsp;
@Basic表示一个简单的属性到数据库表的字段的映射,对于没有任何标注的getXxxx()方法,默认即为@Basic&nbsp;
fetch: 表示该属性的读取策略,有EAGER和LAZY两种,分别表示主支抓取和延迟加载,默认为EAGER.&nbsp;
optional:表示该属性是否允许为null,默认为true&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; @Basic(optional=false)&nbsp;
&nbsp;&nbsp;&nbsp; public String getAddress() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return address;&nbsp;
&nbsp;&nbsp;&nbsp; }

6、@Column&nbsp;
可选&nbsp;
@Column描述了数据库表中该字段的详细定义,这对于根据JPA注解生成数据库表结构的工具非常有作用.&nbsp;
name:表示数据库表中该字段的名称,默认情形属性名称一致&nbsp;
nullable:表示该字段是否允许为null,默认为true&nbsp;
unique:表示该字段是否是唯一标识,默认为false&nbsp;
length:表示该字段的大小,仅对String类型的字段有效&nbsp;
insertable:表示在ORM框架执行插入操作时,该字段是否应出现INSETRT语句中,默认为true&nbsp;
updateable:表示在ORM框架执行更新操作时,该字段是否应该出现在UPDATE语句中,默认为true.对于一经创建就不可以更改的字段,该属性非常有用,如对于birthday字段.&nbsp;
columnDefinition:表示该字段在数据库中的实际类型.通常ORM框架可以根据属性类型自动判断数据库中字段的类型,但是对于Date类型仍无法确定数据库中字段类型究竟是DATE,TIME还是TIMESTAMP.此外,String的默认映射类型为VARCHAR,如果要将String类型映射到特定数据库的BLOB或TEXT字段类型,该属性非常有用.&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; @Column(name="BIRTH",nullable="false",columnDefinition="DATE")&nbsp;
&nbsp;&nbsp;&nbsp; public String getBithday() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return birthday;&nbsp;
&nbsp;&nbsp;&nbsp; }

7、@Transient&nbsp;
可选&nbsp;
@Transient表示该属性并非一个到数据库表的字段的映射,ORM框架将忽略该属性.&nbsp;
如果一个属性并非数据库表的字段映射,就务必将其标示为@Transient,否则,ORM框架默认其注解为@Basic&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; //根据birth计算出age属性&nbsp;
&nbsp;&nbsp;&nbsp; @Transient&nbsp;
&nbsp;&nbsp;&nbsp; public int getAge() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return getYear(new Date()) - getYear(birth);&nbsp;
&nbsp;&nbsp;&nbsp; }

8、@ManyToOne(fetch=FetchType,cascade=CascadeType)&nbsp;
可选&nbsp;
@ManyToOne表示一个多对一的映射,该注解标注的属性通常是数据库表的外键&nbsp;
optional:是否允许该字段为null,该属性应该根据数据库表的外键约束来确定,默认为true&nbsp;
fetch:表示抓取策略,默认为FetchType.EAGER&nbsp;
cascade:表示默认的级联操作策略,可以指定为ALL,PERSIST,MERGE,REFRESH和REMOVE中的若干组合,默认为无级联操作&nbsp;
targetEntity:表示该属性关联的实体类型.该属性通常不必指定,ORM框架根据属性类型自动判断targetEntity.&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; //订单Order和用户User是一个ManyToOne的关系&nbsp;
&nbsp;&nbsp;&nbsp; //在Order类中定义&nbsp;
&nbsp;&nbsp;&nbsp; @ManyToOne()&nbsp;
&nbsp;&nbsp;&nbsp; @JoinColumn(name="USER")&nbsp;
&nbsp;&nbsp;&nbsp; public User getUser() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return user;&nbsp;
&nbsp;&nbsp;&nbsp; }

9、@JoinColumn&nbsp;
可选&nbsp;
@JoinColumn和@Column类似,介量描述的不是一个简单字段,而一一个关联字段,例如.描述一个@ManyToOne的字段.&nbsp;
name:该字段的名称.由于@JoinColumn描述的是一个关联字段,如ManyToOne,则默认的名称由其关联的实体决定.&nbsp;
例如,实体Order有一个user属性来关联实体User,则Order的user属性为一个外键,&nbsp;
其默认的名称为实体User的名称+下划线+实体User的主键名称&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; 见@ManyToOne

10、@OneToMany(fetch=FetchType,cascade=CascadeType)&nbsp;
可选&nbsp;
@OneToMany描述一个一对多的关联,该属性应该为集体类型,在数据库中并没有实际字段.&nbsp;
fetch:表示抓取策略,默认为FetchType.LAZY,因为关联的多个对象通常不必从数据库预先读取到内存&nbsp;
cascade:表示级联操作策略,对于OneToMany类型的关联非常重要,通常该实体更新或删除时,其关联的实体也应当被更新或删除&nbsp;
例如:实体User和Order是OneToMany的关系,则实体User被删除时,其关联的实体Order也应该被全部删除&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; @OneTyMany(cascade=ALL)&nbsp;
&nbsp;&nbsp;&nbsp; public List getOrders() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return orders;&nbsp;
&nbsp;&nbsp;&nbsp; }

11、@OneToOne(fetch=FetchType,cascade=CascadeType)&nbsp;
可选&nbsp;
@OneToOne描述一个一对一的关联&nbsp;
fetch:表示抓取策略,默认为FetchType.LAZY&nbsp;
cascade:表示级联操作策略&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; @OneToOne(fetch=FetchType.LAZY)&nbsp;
&nbsp;&nbsp;&nbsp; public Blog getBlog() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return blog;&nbsp;
&nbsp;&nbsp;&nbsp; }

12、@ManyToMany&nbsp;
可选&nbsp;
@ManyToMany 描述一个多对多的关联.多对多关联上是两个一对多关联,但是在ManyToMany描述中,中间表是由ORM框架自动处理&nbsp;
targetEntity:表示多对多关联的另一个实体类的全名,例如:package.Book.class&nbsp;
mappedBy:表示多对多关联的另一个实体类的对应集合属性名称&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; User实体表示用户,Book实体表示书籍,为了描述用户收藏的书籍,可以在User和Book之间建立ManyToMany关联&nbsp;
&nbsp;&nbsp;&nbsp; @Entity&nbsp;
&nbsp;&nbsp;&nbsp; public class User {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; private List books;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; @ManyToMany(targetEntity=package.Book.class)&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; public List getBooks() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return books;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; public void setBooks(List books) {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; this.books=books;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }&nbsp;
&nbsp;&nbsp;&nbsp; }&nbsp;
&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; @Entity&nbsp;
&nbsp;&nbsp;&nbsp; public class Book {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; private List users;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; @ManyToMany(targetEntity=package.Users.class, mappedBy="books")&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; public List getUsers() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return users;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; public void setUsers(List users) {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; this.users=users;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }&nbsp;
&nbsp;&nbsp;&nbsp; }&nbsp;
两个实体间相互关联的属性必须标记为@ManyToMany,并相互指定targetEntity属性,&nbsp;
需要注意的是,有且只有一个实体的@ManyToMany注解需要指定mappedBy属性,指向targetEntity的集合属性名称&nbsp;
利用ORM工具自动生成的表除了User和Book表外,还自动生成了一个User_Book表,用于实现多对多关联

13、@MappedSuperclass&nbsp;
可选&nbsp;
@MappedSuperclass可以将超类的JPA注解传递给子类,使子类能够继承超类的JPA注解&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; @MappedSuperclass&nbsp;
&nbsp;&nbsp;&nbsp; public class Employee() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ....&nbsp;
&nbsp;&nbsp;&nbsp; }&nbsp;
&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; @Entity&nbsp;
&nbsp;&nbsp;&nbsp; public class Engineer extends Employee {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .....&nbsp;
&nbsp;&nbsp;&nbsp; }&nbsp;
&nbsp;&nbsp;&nbsp; @Entity&nbsp;
&nbsp;&nbsp;&nbsp; public class Manager extends Employee {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .....&nbsp;
&nbsp;&nbsp;&nbsp; }

14、@Embedded&nbsp;
可选&nbsp;
@Embedded将几个字段组合成一个类,并作为整个Entity的一个属性.&nbsp;
例如User包括id,name,city,street,zip属性.&nbsp;
我们希望city,street,zip属性映射为Address对象.这样,User对象将具有id,name和address这三个属性.&nbsp;
Address对象必须定义为@Embededable&nbsp;
示例:&nbsp;
&nbsp;&nbsp;&nbsp; @Embeddable&nbsp;
&nbsp;&nbsp;&nbsp; public class Address {city,street,zip}&nbsp;
&nbsp;&nbsp;&nbsp; @Entity&nbsp;
&nbsp;&nbsp;&nbsp; public class User {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; @Embedded&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; public Address getAddress() {&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ..........&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }&nbsp;
&nbsp;&nbsp;&nbsp; }

　　现在，让我们来动手使用Hibernate Annotation。

安装 Hibernate Annotation&nbsp;
　　要使用 Hibernate Annotation，您至少需要具备 Hibernate 3.2和Java 5。可以从 Hibernate 站点 下载 Hibernate 3.2 和 Hibernate Annotation库。除了标准的 Hibernate JAR 和依赖项之外，您还需要 Hibernate Annotations .jar 文件（hibernate-annotations.jar）、Java 持久性 API （lib/ejb3-persistence.jar）。如果您正在使用 Maven，只需要向 POM 文件添加相应的依赖项即可，如下所示：

&nbsp;&nbsp;&nbsp; ...&nbsp;
&lt;dependency&gt;&nbsp;
&lt;groupId&gt;org.hibernate&lt;/groupId&gt;&nbsp;
&lt;artifactId&gt;hibernate&lt;/artifactId&gt;&nbsp;
&lt;version&gt;3.2.1.ga&lt;/version&gt;&nbsp;
&lt;/dependency&gt;&nbsp;
&lt;dependency&gt;&nbsp;
&lt;groupId&gt;org.hibernate&lt;/groupId&gt;&nbsp;
&lt;artifactId&gt;hibernate-annotations&lt;/artifactId&gt;&nbsp;
&lt;version&gt;3.2.0.ga&lt;/version&gt;&nbsp;
&lt;/dependency&gt;&nbsp;
&lt;dependency&gt;&nbsp;
&lt;groupId&gt;javax.persistence&lt;/groupId&gt;&nbsp;
&lt;artifactId&gt;persistence-api&lt;/artifactId&gt;&nbsp;
&lt;version&gt;1.0&lt;/version&gt;&nbsp;
&lt;/dependency&gt;&nbsp;
...&nbsp;
　　下一步就是获取 Hibernate 会话工厂。尽管无需惊天的修改，但这一工作与使用 Hibernate Annotations有所不同。您需要使用 AnnotationConfiguration 类来建立会话工厂：

sessionFactory = new&nbsp;
AnnotationConfiguration().buildSessionFactory();&nbsp;
　　尽管通常使用 &lt;mapping&gt; 元素来声明持久性类，您还是需要在 Hibernate 配置文件（通常是 hibernate.cfg.xml）中声明持久性类：

&lt;!DOCTYPE hibernate-configuration PUBLIC&nbsp;
"-//Hibernate/Hibernate Configuration DTD 3.0//EN"&nbsp;
"[http://hibernate.sourceforge.net/hibernate-configuration-3.0.dtd](http://hibernate.sourceforge.net/hibernate-configuration-3.0.dtd)"&gt;&nbsp;
&lt;hibernate-configuration&gt;&nbsp;
&lt;session-factory&gt;&nbsp;
&lt;mapping class="com.onjava.modelplanes.domain.PlaneType"/&gt;&nbsp;
&lt;mapping class="com.onjava.modelplanes.domain.ModelPlane"/&gt;&nbsp;
&lt;/session-factory&gt;&nbsp;
&lt;/hibernate-configuration&gt;&nbsp;
　　近期的许多 Java 项目都使用了轻量级的应用框架，例如 Spring。如果您正在使用 Spring 框架，可以使用 AnnotationSessionFactoryBean 类轻松建立一个基于注释的 Hibernate 会话工厂，如下所示：

&lt;!-- Hibernate session factory --&gt;&nbsp;
&lt;bean id="sessionFactory"&nbsp;
class="org.springframework.orm.hibernate3.annotation.AnnotationSessionFactoryBean"&gt;&nbsp;
&lt;property name="dataSource"&gt;&nbsp;
&lt;ref bean="dataSource"/&gt;&nbsp;
&lt;/property&gt;&nbsp;
&lt;property name="hibernateProperties"&gt;&nbsp;
&lt;props&gt;&nbsp;
&lt;prop key="hibernate.dialect"&gt;org.hibernate.dialect.DerbyDialect&lt;/prop&gt;&nbsp;
&lt;prop key="hibernate.hbm2ddl.auto"&gt;create&lt;/prop&gt;&nbsp;
...&nbsp;
&lt;/props&gt;&nbsp;
&lt;/property&gt;&nbsp;
&lt;property name="annotatedClasses"&gt;&nbsp;
&lt;list&gt;&nbsp;
&lt;value&gt;com.onjava.modelplanes.domain.PlaneType&lt;/value&gt;&nbsp;
&lt;value&gt;com.onjava.modelplanes.domain.ModelPlane&lt;/value&gt;&nbsp;
...&nbsp;
&lt;/list&gt;&nbsp;
&lt;/property&gt;&nbsp;
&lt;/bean&gt;&nbsp;
第一个持久性类&nbsp;
　　既然已经知道了如何获得注释所支持的 Hibernate 会话，下面让我们来了解一下带注释的持久性类的情况：

　　像在其他任何 Hibernate应用程序中一样，带注释的持久性类也是普通 POJO。差不多可以说是。您需要向 Java 持久性 API （javax.persistence.*）添加依赖项，如果您正在使用任何特定于 Hibernate的扩展，那很可能就是 Hibernate Annotation 程序包（org.hibernate.annotations.*），但除此之外，它们只是具备了持久性注释的普通 POJO 。下面是一个简单的例子：

@Entity&nbsp;
public class ModelPlane {&nbsp;
private Long id;&nbsp;
private String name;&nbsp;
@Id&nbsp;
public Long getId() {&nbsp;
return id;&nbsp;
}&nbsp;
public void setId(Long id) {&nbsp;
this.id = id;&nbsp;
}&nbsp;
public String getName() {&nbsp;
return name;&nbsp;
}&nbsp;
public void setName(String name) {&nbsp;
this.name = name;&nbsp;
}&nbsp;
}&nbsp;
　　正像我们所提到的，这非常简单。@Entity 注释声明该类为持久类。@Id 注释可以表明哪种属性是该类中的独特标识符。事实上，您既可以保持字段（注释成员变量），也可以保持属性（注释getter方法）的持久性。后文中将使用基于属性的注释。基于注释的持久性的优点之一在于大量使用了默认值（最大的优点就是 &ldquo;惯例优先原则（convention over configuration）&rdquo;）。例如，您无需说明每个属性的持久性&mdash;&mdash;任何属性都被假定为持久的，除非您使用 @Transient 注释来说明其他情况。这简化了代码，相对使用老的 XML 映射文件而言也大幅地减少了输入工作量。

生成主键&nbsp;
　　Hibernate 能够出色地自动生成主键。Hibernate/EBJ 3 注释也可以为主键的自动生成提供丰富的支持，允许实现各种策略。下面的示例说明了一种常用的方法，其中 Hibernate 将会根据底层数据库来确定一种恰当的键生成策略：

@Id&nbsp;
@GeneratedValue(strategy=GenerationType.AUTO)&nbsp;
public Long getId() {&nbsp;
return id;&nbsp;
}&nbsp;
定制表和字段映射&nbsp;
　　默认情况下，Hibernate 会将持久类以匹配的名称映射到表和字段中。例如，前一个类可以与映射到以如下代码创建的表中：

CREATE TABLE MODELPLANE&nbsp;
(&nbsp;
ID long,&nbsp;
NAME varchar&nbsp;
)&nbsp;
　　如果您是自己生成并维护数据库，那么这种方法很有效，通过省略代码可以大大简化代码维护。然而，这并不能满足所有人的需求。有些应用程序需要访问外部数据库，而另一些可能需要遵从公司的数据库命名惯例。如果有必要，您可以使用 @Table 和 @Column 注释来定制您自己的持久性映射，如下所示：

@Entity&nbsp;
@Table(name="T_MODEL_PLANE")&nbsp;
public class ModelPlane {&nbsp;
private Long id;&nbsp;
private String name;&nbsp;
@Id&nbsp;
@Column(name="PLANE_ID")&nbsp;
public Long getId() {&nbsp;
return id;&nbsp;
}&nbsp;
public void setId(Long id) {&nbsp;
this.id = id;&nbsp;
}&nbsp;
@Column(name="PLANE_NAME")&nbsp;
public String getName() {&nbsp;
return name;&nbsp;
}&nbsp;
public void setName(String name) {&nbsp;
this.name = name;&nbsp;
}&nbsp;
}&nbsp;
　　该内容将映射到下表中：

CREATE TABLE T_MODEL_PLANE&nbsp;
(&nbsp;
PLANE_ID long,&nbsp;
PLANE_NAME varchar&nbsp;
)&nbsp;
　　也可以使用其他图和列的属性来定制映射。这使您可以指定诸如列长度、非空约束等详细内容。Hibernate支持大量针对这些注释的属性。下例中就包含了几种属性：

&nbsp;&nbsp;&nbsp; ...&nbsp;
@Column(name="PLANE_ID", length=80, nullable=true)&nbsp;
public String getName() {&nbsp;
return name;&nbsp;
}&nbsp;
...&nbsp;
映射关系&nbsp;
　　Java 持久性映射过程中最重要和最复杂的一环就是确定如何映射表间的关系。像其他产品一样， Hibernate 在该领域中提供了高度的灵活性，但却是以复杂度的增加为代价。我们将通过研究几个常见案例来了解如何使用注释来处理这一问题。

　　其中一种最常用的关系就是多对一的关系。假定在以上示例中每个 ModelPlane 通过多对一的关系（也就是说，每个飞机模型只与一种飞机类型建立联系，尽管指定的飞机类型可以与七种飞机模型建立联系）来与 PlaneType 建立联系。可如下进行映射：

&nbsp;&nbsp;&nbsp; @ManyToOne( cascade = {CascadeType.PERSIST, CascadeType.MERGE} )&nbsp;
public PlaneType getPlaneType() {&nbsp;
return planeType;&nbsp;
}&nbsp;
　　CascadeType 值表明 Hibernate 应如何处理级联操作。

　　另一种常用的关系与上述关系相反：一对多再对一关系，也称为集合。在老式的 Hibernate 版本中进行映射或使用注释时，集合令人头疼，这里我们将简要加以探讨，以使您了解如何处理集合，例如，在以上示例中每个 PlaneType 对象都可能会包含一个 ModelPlanes 集合。可映射如下：

@OneToMany(mappedBy="planeType",&nbsp;
cascade=CascadeType.ALL,&nbsp;
fetch=FetchType.EAGER)&nbsp;
@OrderBy("name")&nbsp;
public List&lt;ModelPlane&gt; getModelPlanes() {&nbsp;
return modelPlanes;&nbsp;
}&nbsp;
命名查询&nbsp;
　　Hibernate 最优秀的功能之一就在于它能够在您的映射文件中声明命名查询。随后即可通过代码中的名称调用此类查询，这使您可以专注于查询，而避免了 SQL 或者 HQL 代码分散于整个应用程序中的情况。

　　也可以使用注释来实现命名查询，可以使用 @NamedQueries 和 @NamedQuery 注释，如下所示：

@NamedQueries(&nbsp;
{&nbsp;
@NamedQuery(&nbsp;
name="planeType.findById",&nbsp;
query="select p from PlaneType p left join fetch p.modelPlanes where id=:id"&nbsp;
),&nbsp;
@NamedQuery(&nbsp;
name="planeType.findAll",&nbsp;
query="select p from PlaneType p"&nbsp;
),&nbsp;
@NamedQuery(&nbsp;
name="planeType.delete",&nbsp;
query="delete from PlaneType where id=:id"&nbsp;
)&nbsp;
}&nbsp;
)&nbsp;
　　一旦完成了定义，您就可以像调用其他任何其他命名查询一样来调用它们。

结束语&nbsp;
　　Hibernate 3 注释提供了强大而精致的 API，简化了 Java 数据库中的持久性代码，本文中只进行了简单的讨论。您可以选择遵从标准并使用 Java 持久性 API，也可以利用特定于 Hibernate的扩展，这些功能以损失可移植性为代价提供了更为强大的功能和更高的灵活性。无论如何，通过消除对 XML 映射文件的需求，Hibernate 注释将简化应用程序的维护，同时也可以使您对EJB 3 有初步认识。来试试吧！&nbsp;
&nbsp;
&nbsp;
本文来自CSDN博客，转载请标明出处：[http://blog.csdn.net/dingqinghu/archive/2011/03/25/6275798.aspx](http://blog.csdn.net/dingqinghu/archive/2011/03/25/6275798.aspx)