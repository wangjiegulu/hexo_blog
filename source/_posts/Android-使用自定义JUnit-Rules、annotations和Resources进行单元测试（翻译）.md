---
title: '[Android]使用自定义JUnit Rules、annotations和Resources进行单元测试（翻译）'
tags: [android, unit test, JUnit, Junit Rules, annotations]
date: 2016-08-22 12:00:00
---

# 使用自定义JUnit Rules、annotations和Resources进行单元测试

> 原文：<http://www.thedroidsonroids.com/blog/android/unit-tests-rules-annotations-resources>

## 简介

Unit Test并不只有断言和测试方法组成。它有一些可以用来提高质量和测试代码可读性的技术。在本文中我们将探索：

- annotations
- JUnit rules
- java resources

## 背景

很多或者大多数Android apps作为一个API Client，因此需要数据格式之间的转换（通常是JSON）和POJO（数据模型类）。我们不需要在自己的代码中实现一个转换引擎而是可以使用如 [GSON](https://github.com/google/gson) 或 [moshi](https://github.com/square/moshi) 等三方库来完成。

众所周知的库通常都是有很高的单元测试的覆盖率的，所以如下测试它们是没有意义的：

```java
@Test
public void testGson() {
 //given
 Gson gson = new Gson();
 //when
 String result = gson.fromJson("\"test\"", String.class);
 //then
 assertThat(result).isEqualTo("test");
}
```

*Listing 1\. 无用的GSON单元测试.*

另一方面测试解析（JSON到POJO）和生成（POJO到JSON）逻辑相关的模型类可能是有用的。如下的POJO：

```java
public class Contributor {
 public String login;
 public boolean siteAdmin;
 public long id;
}
```

*Listing 2\. 简单POJO.*

和相应的JSON：

```json
{
    "login": "koral--",
    "id": 3340954,
    "site_admin": true
}
```

*Listing 3\. 简单JSON.*

如果属性映射都正确的话，我们希望去测试它。注意属性`siteAdmin`使用了不同的命名风格 － Java中的驼峰命名和JSON中的蛇底命名。

## 简单方案

最简单的一种unit test看起来如下：

<span id="listing4"></span>

```java
@Test
public void testParseHardcodedContributors() throws Exception {
 //given
 String json = "[\n" +
 "  {\n" +
 "    \"login\": \"koral--\",\n" +
 "    \"id\": 3340954,\n" +
 "    \"site_admin\": true\n" +
 "  },\n" +
 "  {\n" +
 "    \"login\": \"Wavesonics\",\n" +
 "    \"id\": 406473,\n" +
 "    \"site_admin\": false\n" +
 "  }\n" +
 "]\n";

 GsonBuilder gsonBuilder = new GsonBuilder();
 gsonBuilder.setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES);
 Gson gson = gsonBuilder.create();

 //when
 Contributor[] contributors;
 try (Reader reader = new BufferedReader(new StringReader(json))) {
 contributors = gson.fromJson(reader, Contributor[].class);
 }
```

*Listing 4\. 使用硬编码JSON的单元测试.*

这种方法有几个弊端。最值得注意的就是比较差的JSON可读性，有大量的转义字符和没有语法高亮。此外有一点模版代码，如果有更多的JSON需要测试的话将会产生重复代码。让我们思考怎样可以用更加简便的方法来编写，提高可读性和消除代码重复率。

## 改进

首先`Gson`对象可以在测试方法外部实例化，比如使用一些像 [Dagger] (http://google.github.io/dagger) 的DI（依赖注入）机制或者使用一个简单的常量。DI已经超出了本文的范围所以我们在例子代码中使用后者。在代码提取后看起来如下：

```java
public final class Constants {
 public static final Gson GSON;

 static {
 final GsonBuilder gsonBuilder = new GsonBuilder();
 gsonBuilder.setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES);
 GSON = gsonBuilder.create();
 }
}
```

*Listing 5\. 把GSON实例作为一个全局变量.*

接着，文本形式的JSON可以被置于一个resource file中。这会给我们带来语法的高亮和缩进（漂亮的打印），默认情况下Android Studio和Intellij IDEA内置了这些功能特性。不需要引号的转义，所以可读性也不再是问题。再者，文件中的行数和列数和GSON中的一致，所以将会更加容易地像这样debug异常：`MalformedJsonException: Unterminated array at line 4 column 5 path $[2]`。如果JSON被放置在一个单独的文件，行数是会被确切地匹配到的，跟上述硬编码JSON的例子矛盾的地方是，需要通过java源文件中的偏移进行调整。下面是这个示例中被使用的文件：

<span id="listing6"><span/>

```json
[
  {
    "login": "koral--",
    "id": 3340954,
    "site_admin": true
  },
  {
    "login": "Wavesonics",
    "id": 406473,
    "site_admin": false
  }
]
```

*Listing 6\. 包含JSON的Java resource文件.*

最后，代码执行转换可以从测试方法中提取，所以广义说它会更容易在不同的测试用例上使用。它可以使用下章将会讨论的Java和JUnit特性来实现。

## Goodies

### Java resources

Java resources是程序需要的数据文件，它被放置在源代码外面。注意我们讨论的是 [Java resources](https://docs.oracle.com/javase/8/docs/technotes/guides/lang/resources.html)，默认被放置在`src/<source set>/resources`，并不是 [Android App Resources](https://developer.android.com/guide/topics/resources/providing-resources.html)(drawables, layouts等)。这本例子中并没有Android特别的特性。所以一切都是可以像 [Robolectric](http://robolectric.org/) 那样脱离frameworks可单元测试的。

如果[listing 6](#listing6)的JSON文件被保存于`src/test/resources/pl/droidsonroids/modeltesting/api/contributors.json`，它可以通过调用`TestClass.getResourceAsStream("contributors.json")`来被单元测试代码访问。相关的类需要被放置在对应的package中，在这个例子中是`pl.droidsonroids.modeltesting.api`。详情见[**`#getResourceAsStream()` javadoc**](https://developer.android.com/reference/java/lang/Class.html#getResourceAsStream(java.lang.String))

### 注解Annotation

[Annotation](http://docs.oracle.com/javase/8/docs/technotes/guides/language/annotations.html)是关联到源代码元素的元数据（eg. 方法或者类）。有众所周知的一些如[@Override](https://developer.android.com/reference/java/lang/Override.html)或[@Deprecated](https://developer.android.com/reference/java/lang/Deprecated.html)的内置注解。也可以自定义并使用它们把特定的resources绑定到测试方法中。

注解来起来与interface很类似：

```java
Java

@Retention(RUNTIME)
@Target(METHOD)
public @interface JsonFileResource {
	String fileName();
	Class<?> clazz();
}
```

*Listing 7\. 简单注解.*

注意`interface`关键字前面的`@`符号。我们自定义的注解被2个元注解来注解。我们设置[Retention](https://developer.android.com/reference/java/lang/annotation/Retention.html)为[RUNTIME](https://developer.android.com/reference/java/lang/annotation/RetentionPolicy.html#RUNTIME)，因为注解需要在单元测试执行时（运行时）为可读，所以默认的retention（[CLASS](https://developer.android.com/reference/java/lang/annotation/RetentionPolicy.html#CLASS)）的并不满足。我们也需要设置[Target](https://developer.android.com/reference/java/lang/annotation/Target.html)为[METHOD](https://developer.android.com/reference/java/lang/annotation/ElementType.html#METHOD)因为我们只需要为方法进行注解（绑定特定的resource）。错位的注解会引发编译错误。没有指定一个target，注解会可以被用于任何地方。

### JUnit Rules

简单来说，[rule](https://github.com/junit-team/junit4/wiki/Rules)是在测试（方法）运行时触发的一个hook。我们将使用rule在测试方法执行之前增加一些额外的行为。即我们将从resources中解析JSON并提供给测试方法内部相应的POJO。我们的目标时像下面这样支持单元测试：

```java
@Rule public JsonParsingRule jsonParsingRule = new JsonParsingRule(Constants.GSON);

@Test
@JsonFileResource(fileName = "contributors.json", clazz = Contributor[].class)
public void testGetContributors() throws Exception {
 Contributor[] contributors = jsonParsingRule.getValue();
 assertThat(contributors).hasSize(2);
 assertThat(contributors[0].login).isEqualTo("koral--");
}
```

*Listing 8\. 使用自定义rule的简单测试方法.*

如你所见，模版代码与[listing 4](#listing4)相比明显地减少。只有必要的部分是类型明确的：

- GSON实例用来解析JSONs - `jsonParsingRule = new JsonParsingRule(Constants.GSON)`

- 被放置JSON字符串的resource - `@JsonFileResource(fileName = "contributors.json"`

- POJO类 - `, clazz = Contributor[].class`

- POJO实例的接收 - `contributors = jsonParsingRule.getValue()`

注意对于测试类只需要一个`JsonParsingRule`实例。对于每个测试方法Rule会被独立计算并且在特定方法中`jsonParsingRule.getValue()`的结果不会影响到上一次测试。**clazz**并不是一个错字而是故意的，因为`class`是Java语言关键字并不能用做一个标识符。还有一个重要的是被[@Rule](http://junit.org/junit4/javadoc/latest/org/junit/Rule.html)注解的属性必须是public和非static的。

#### Rule实现

看下rule实现的草案：

<span id="listing9"></span>

```java
public class JsonParsingRule implements TestRule {
 private final Gson mGson;
 private Object mValue;

 public JsonParsingRule(Gson gson) {
 mGson = gson;
 }

 @SuppressWarnings("unchecked")
 public  T getValue() {
 return (T) mValue;
 }

 @Override
 public Statement apply(final Statement base, final Description description) {
 return new Statement() {
 @Override
 public void evaluate() throws Throwable {
 //TODO set mValue according to annotation
 base.evaluate();
 }
 };
 }
}
```

*Listing 9\. Rule骨架.*

我们的rule实现了[TestRule](http://junit.org/junit4/javadoc/latest/org/junit/rules/TestRule.html)，因此可以使用被使用`@Rule`注解。我们使用了一个范型的getter，所以它的返回值可以被直接分配给特定类型的变量而不需要在测试方法中转型。在`apply()`方法中我们可以创建一个原始[Statement](http://junit.org/junit4/javadoc/latest/org/junit/runners/model/Statement.html)（测试方法）的包装。调用`base.evaluate()`被放置在最后（在注解处理之后），因此在测试方法执行过程中rule的效果是可见的。

现在更接近地观看statement包装的关键部分（[listing 9](#listing9)中`TODO`的实现）：

```java
JsonFileResource jsonFileResource = description.getAnnotation(JsonFileResource.class);
if (jsonFileResource != null) {
 Class<?> clazz = jsonFileResource.clazz();
 String resourceName = jsonFileResource.fileName();
 Class<?> testClass = description.getTestClass();
 InputStream in = testClass.getResourceAsStream(resourceName);

 assert in != null : "Failed to load resource: " + resourceName + " from " + testClass;
 try (Reader reader = new BufferedReader(new InputStreamReader(in))) {
 mValue = mGson.fromJson(reader, clazz);
 }
}
```

*Listing 10\. Statement的实现.*

`description`参数在这里是必不可少的，它可以让我们访问测试方法包括注解在内的元数据。Rule适用于所有测试方法，包括没有注解的，这种情况下[getAnnotation()](http://junit.org/junit4/javadoc/latest/org/junit/runner/Description.html#getAnnotation(java.lang.Class))会返回`null`，并且我们可以有条件地跳过定制的其余部分。所以测试方法没有`@JsonFileResource`注解的测试方法（比如，一些不涉及JSON的测试）可以放在使用了`JsonParsingRule`的测试类中。第8行是下面代码的一个[简写等效](https://docs.oracle.com/javase/8/docs/technotes/guides/language/assert.html#intro)：

```java
if (in != null) {
 throw new AssertionError("Failed to load resource: " + resourceName + " from " + testClass);
}
```

*Listing 11\. 断言语句判定.*

最后我们传入使用被[Reader](https://developer.android.com/reference/java/io/Reader.html)包装的resource到GSON引擎。[Try-with-resources](https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html)语句在这里被使用，所以Reader将会在读取甚至发生异常之后自动关闭。这里需要在`finally`块中明确类型。

注意try-with-resources从Android API 19（Kitkat）才可用。如果测试代码位于Android gradle module中，并且你的`minSdkVersion`低于19，那么你可能需要在`evaluate()`方法上增加`@TargetApi(Build.VERSION_CODES.KITKAT)`注解来避免[lint](http://tools.android.com/tips/lint-checks)错误。单元测试会在开发机器（Mac，PC等）上被执行而不是Android设备或者模拟器，所以这里只有`compileSdkVersion`才是关键。

这样的单元测试（不需要使用Android特定的API）也可以被放在java module中（`build.gradle`中`apply plugin: 'java'`）。理论上这事最好的idea，但是在Android Studio/Intellij IDEA中有一个[问题](http://tools.android.com/knownissues#TOC-JUnit-tests-missing-resources-in-classpath-when-run-from-Studio)需要预防，那就是从IDE开箱即用地执行单元测试的配置工作。

