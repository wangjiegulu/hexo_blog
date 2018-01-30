---
title: '[Android]Android端ORM框架——RapidORM(v2.1)'
tags: [android, orm, rapidorm, library, database, sqlite]
date: 2016-11-01 17:54:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明

来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/6020412.html>
**</font>

# [Android]Android端ORM框架——RapidORM(v2.1)

**[RapidORM](https://github.com/wangjiegulu/RapidORM)：Android端轻量高性能的ORM框架**

**GitHub:** https://github.com/wangjiegulu/RapidORM

## RapidORM v2.1 feature

1\. 在执行SQL和创建表时提升性能。

2\. 提升bind参数时的性能

3\. Index支持。

4\. 上传至Maven中心库。

## 关于 RapidORM

- 主键支持任何类型，支持联合主键。

- 非反射执行SQL。

- 高性能。

- 兼容 `android.database.sqlite.SQLiteDatabase`、 `net.sqlcipher.database.SQLiteDatabase`以及更多加密实现。

- 友好的面向对象接口调用。

- Index支持。

- 联表查询未支持。

`v2.0` blog: <http://www.cnblogs.com/tiantianbyconan/p/5626716.html>

`v1.0` blog: <http://www.cnblogs.com/tiantianbyconan/p/4748077.html>

## 怎么使用

### 1\. `build.gradle` 添加依赖

### Gadle([获取最新版本])

```groovy
compile "com.github.wangjiegulu:rapidorm:x.x.x"

compile "com.github.wangjiegulu:rapidorm-api:x.x.x"

apt "com.github.wangjiegulu:rapidorm-compiler:x.x.x"
```

### Maven([获取最新版本])

```xml
<dependency>
        <groupId>com.github.wangjiegulu</groupId>
        <artifactId>rapidorm</artifactId>
        <version>x.x.x</version>
</dependency>
```

具体使用方式见：

> `v2.0` blog: <http://www.cnblogs.com/tiantianbyconan/p/5626716.html>

> `v1.0` blog: <http://www.cnblogs.com/tiantianbyconan/p/4748077.html>

[获取最新版本]: http://search.maven.org/#search%7Cga%7C1%7CRapidORM

