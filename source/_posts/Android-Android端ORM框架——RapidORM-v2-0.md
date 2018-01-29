---
title: '[Android]Android端ORM框架——RapidORM(v2.0)'
tags: []
date: 2016-06-29 14:28:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明

来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/5626716.html>
**</font>

# [Android]Android端ORM框架——RapidORM(`v2.0`)

**[RapidORM](https://github.com/wangjiegulu/RapidORM)：Android端轻量高性能的ORM框架**

**GitHub:** https://github.com/wangjiegulu/RapidORM

## 1\. RapidORM `v1.0`

> `v1.0`博客文档：<http://www.cnblogs.com/tiantianbyconan/p/4748077.html>

`v1.0`版本支持使用反射和非反射（模版生成）两种方式实现执行SQL。

### 1.1\. `v1.0`缺点：

1\. 其中默认为反射实现，对性能有一定的影响。

2\. 而如果要采用非反射实现，则需要使用RapidORM提供的模版工具类手动生成相关的帮助类，当数据表需要修改时，必须要手动手动生成帮助类，有潜在的风险。

3\. 非反射时生成的文件是通过`getter/setter`方法调用的，但是`getter/setter`方法名可能会不一致，导致需要手动调整`setter/getter`方法名称。

## 2\. RapidORM `v2.0`

相比较于`v1.0`版本，`v2.0`版本则更加侧重于非反射操作，所有默认都是非反射的。

通过在编译时期根据`@Table`、`@Column`等注解自动生成辅助类`Xxx_RORM.java`文件，**RapidORM**库会使用这些生成的辅助类来进行数据表的初始化、执行SQL等操作，如果数据表有结构有改动，则会自动重新生成或者`rebuild`来手动生成。

### 2.1 `v2.0` 使用指南

> 与`v1.0`相同部分省略。

#### 2.1.1 同样，创建持久类`Person`

```java
/**
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 6/25/15.
 */
@Table
public class Person implements Serializable {

    @Column(primaryKey = true)
    Integer id;

    @Column(primaryKey = true, name = "type_id")
    Integer typeId;

    @Column
    String name;

    @Column
    int age;

    @Column
    String address;

    @Column
    Long birth;

    @Column
    Boolean student;

    @Column(name = "is_succeed")
    boolean isSucceed;

    // getter/setter

}
```

注意，v2.0版本不支持变量为`private`类型，这是为了避免使用`getter/setter`方法来进行数据绑定。如果变量为`private`类型，则编译会报错，如下：

```java
Error:Execution failed for task ':example:compileDebugJavaWithJavac'.
> java.lang.RuntimeException: id in com.wangjie.rapidorm.example.database.model.Person can not be private!
```

#### 2.1.2 Rebuild Project

> Android Studio -> Build -> Rebuild Project

Build成功后，在主项目`build/generated/source/apt/`目录下会生成`Person_RORM`类, 如下：

```java
// GENERATED CODE BY RapidORM. DO NOT MODIFY! "2016-06-29 14:08:504", Source table: "com.wangjie.rapidorm.example.database.model.Person"
package com.wangjie.rapidorm.example.database.model;

import android.database.Cursor;
import com.wangjie.rapidorm.core.config.ColumnConfig;
import com.wangjie.rapidorm.core.config.TableConfig;
import java.util.List;

public class Person_RORM extends TableConfig<Person> {
  /**
   * Column name: "id", field name: {@link Person#id}
   */
  public static final String ID = "id";

  /**
   * Column name: "type_id", field name: {@link Person#typeId}
   */
  public static final String TYPE_ID = "type_id";

  /**
   * Column name: "name", field name: {@link Person#name}
   */
  public static final String NAME = "name";

  /**
   * Column name: "age", field name: {@link Person#age}
   */
  public static final String AGE = "age";

  /**
   * Column name: "address", field name: {@link Person#address}
   */
  public static final String ADDRESS = "address";

  /**
   * Column name: "birth", field name: {@link Person#birth}
   */
  public static final String BIRTH = "birth";

  /**
   * Column name: "student", field name: {@link Person#student}
   */
  public static final String STUDENT = "student";

  /**
   * Column name: "is_succeed", field name: {@link Person#isSucceed}
   */
  public static final String IS_SUCCEED = "is_succeed";

  public Person_RORM() {
    super(Person.class);
  }

  @Override
  protected void parseAllConfigs() {
    tableName = "Person";
    ColumnConfig idColumnConfig = buildColumnConfig("id"/*column name*/, false/*autoincrement*/, false/*notNull*/, ""/*defaultValue*/, false/*index*/, false/*unique*/, false/*uniqueCombo*/, true/*primaryKey*/, "INTEGER"/*dbType*/);
    allColumnConfigs.add(idColumnConfig);
    allFieldColumnConfigMapper.put("id"/*field name*/, idColumnConfig);
    pkColumnConfigs.add(idColumnConfig);
    ColumnConfig typeIdColumnConfig = buildColumnConfig("type_id"/*column name*/, false/*autoincrement*/, false/*notNull*/, ""/*defaultValue*/, false/*index*/, false/*unique*/, false/*uniqueCombo*/, true/*primaryKey*/, "INTEGER"/*dbType*/);
    allColumnConfigs.add(typeIdColumnConfig);
    allFieldColumnConfigMapper.put("typeId"/*field name*/, typeIdColumnConfig);
    pkColumnConfigs.add(typeIdColumnConfig);
    ColumnConfig nameColumnConfig = buildColumnConfig("name"/*column name*/, false/*autoincrement*/, false/*notNull*/, ""/*defaultValue*/, false/*index*/, false/*unique*/, false/*uniqueCombo*/, false/*primaryKey*/, "TEXT"/*dbType*/);
    allColumnConfigs.add(nameColumnConfig);
    allFieldColumnConfigMapper.put("name"/*field name*/, nameColumnConfig);
    noPkColumnConfigs.add(nameColumnConfig);
    ColumnConfig ageColumnConfig = buildColumnConfig("age"/*column name*/, false/*autoincrement*/, false/*notNull*/, ""/*defaultValue*/, false/*index*/, false/*unique*/, false/*uniqueCombo*/, false/*primaryKey*/, "INTEGER"/*dbType*/);
    allColumnConfigs.add(ageColumnConfig);
    allFieldColumnConfigMapper.put("age"/*field name*/, ageColumnConfig);
    noPkColumnConfigs.add(ageColumnConfig);
    ColumnConfig addressColumnConfig = buildColumnConfig("address"/*column name*/, false/*autoincrement*/, false/*notNull*/, ""/*defaultValue*/, false/*index*/, false/*unique*/, false/*uniqueCombo*/, false/*primaryKey*/, "TEXT"/*dbType*/);
    allColumnConfigs.add(addressColumnConfig);
    allFieldColumnConfigMapper.put("address"/*field name*/, addressColumnConfig);
    noPkColumnConfigs.add(addressColumnConfig);
    ColumnConfig birthColumnConfig = buildColumnConfig("birth"/*column name*/, false/*autoincrement*/, false/*notNull*/, ""/*defaultValue*/, false/*index*/, false/*unique*/, false/*uniqueCombo*/, false/*primaryKey*/, "LONG"/*dbType*/);
    allColumnConfigs.add(birthColumnConfig);
    allFieldColumnConfigMapper.put("birth"/*field name*/, birthColumnConfig);
    noPkColumnConfigs.add(birthColumnConfig);
    ColumnConfig studentColumnConfig = buildColumnConfig("student"/*column name*/, false/*autoincrement*/, false/*notNull*/, ""/*defaultValue*/, false/*index*/, false/*unique*/, false/*uniqueCombo*/, false/*primaryKey*/, "INTEGER"/*dbType*/);
    allColumnConfigs.add(studentColumnConfig);
    allFieldColumnConfigMapper.put("student"/*field name*/, studentColumnConfig);
    noPkColumnConfigs.add(studentColumnConfig);
    ColumnConfig isSucceedColumnConfig = buildColumnConfig("is_succeed"/*column name*/, false/*autoincrement*/, false/*notNull*/, ""/*defaultValue*/, false/*index*/, false/*unique*/, false/*uniqueCombo*/, false/*primaryKey*/, "INTEGER"/*dbType*/);
    allColumnConfigs.add(isSucceedColumnConfig);
    allFieldColumnConfigMapper.put("isSucceed"/*field name*/, isSucceedColumnConfig);
    noPkColumnConfigs.add(isSucceedColumnConfig);
  }

  @Override
  public void bindInsertArgs(Person model, List<Object> insertArgs) {
    Integer id = model.id;
    insertArgs.add(null == id ? null : id );
    Integer typeId = model.typeId;
    insertArgs.add(null == typeId ? null : typeId );
    String name = model.name;
    insertArgs.add(null == name ? null : name );
    int age = model.age;
    insertArgs.add(age);
    String address = model.address;
    insertArgs.add(null == address ? null : address );
    Long birth = model.birth;
    insertArgs.add(null == birth ? null : birth );
    Boolean student = model.student;
    insertArgs.add(null == student ? null : student  ? 1 : 0);
    boolean isSucceed = model.isSucceed;
    insertArgs.add(isSucceed ? 1 : 0);
  }

  @Override
  public void bindUpdateArgs(Person model, List<Object> updateArgs) {
    String name = model.name;
    updateArgs.add(null == name ? null : name);
    int age = model.age;
    updateArgs.add(age);
    String address = model.address;
    updateArgs.add(null == address ? null : address);
    Long birth = model.birth;
    updateArgs.add(null == birth ? null : birth);
    Boolean student = model.student;
    updateArgs.add(null == student ? null : student ? 1 : 0);
    boolean isSucceed = model.isSucceed;
    updateArgs.add(isSucceed ? 1 : 0);
  }

  @Override
  public void bindPkArgs(Person model, List<Object> pkArgs) {
    Integer id = model.id;
    pkArgs.add(null == id ? null : id);
    Integer typeId = model.typeId;
    pkArgs.add(null == typeId ? null : typeId);
  }

  @Override
  public Person parseFromCursor(Cursor cursor) {
    Person model = new Person();
    int index;
    index = cursor.getColumnIndex("id");
    if(-1 != index) {
      model.id = cursor.isNull(index) ? null : (cursor.getInt(index));
    }
    index = cursor.getColumnIndex("type_id");
    if(-1 != index) {
      model.typeId = cursor.isNull(index) ? null : (cursor.getInt(index));
    }
    index = cursor.getColumnIndex("name");
    if(-1 != index) {
      model.name = cursor.isNull(index) ? null : (cursor.getString(index));
    }
    index = cursor.getColumnIndex("age");
    if(-1 != index) {
      model.age = cursor.isNull(index) ? null : (cursor.getInt(index));
    }
    index = cursor.getColumnIndex("address");
    if(-1 != index) {
      model.address = cursor.isNull(index) ? null : (cursor.getString(index));
    }
    index = cursor.getColumnIndex("birth");
    if(-1 != index) {
      model.birth = cursor.isNull(index) ? null : (cursor.getLong(index));
    }
    index = cursor.getColumnIndex("student");
    if(-1 != index) {
      model.student = cursor.isNull(index) ? null : (cursor.getInt(index) == 1);
    }
    index = cursor.getColumnIndex("is_succeed");
    if(-1 != index) {
      model.isSucceed = cursor.isNull(index) ? null : (cursor.getInt(index) == 1);
    }
    return model;
  }
}
```

#### 2.1.3 注册持久类

与`v1.0`一样，新建类DatabaseFactory，继承RapidORMConnection（可参考<http://www.cnblogs.com/tiantianbyconan/p/4748077.html>）。

需要注意的是需要实现的并不是原来的`registerAllTableClass()`方法，而是`registerTableConfigMapper(HashMap<Class, TableConfig> tableConfigMapper)`方法：

```java
// ...
@Override
protected void registerTableConfigMapper(HashMap<Class, TableConfig> tableConfigMapper) {
    tableConfigMapper.put(Person.class, new Person_RORM());
    // register all table config here...
}
// ...
```

注意：注册`Person`时，需要连带生成的`Person_RORM`同时注册。

#### 2.1.4 构建Builder

构建Builder时与`v1.0`的方式一致，但是可以直接使用`Person_RORM`中的static变量来作为column name：

**PersonDaoImpl**:

```java
public List<Person> findPersonsByWhere() throws Exception {
    return queryBuilder()
            .addSelectColumn(Person_RORM.ID, Person_RORM.TYPE_ID, Person_RORM.NAME,
                    Person_RORM.AGE, Person_RORM.BIRTH, Person_RORM.ADDRESS)
            .setWhere(
            	Where.and(
	                Where.like(Person_RORM.NAME, "%wangjie%"),
	                Where.lt(Person_RORM.ID, 200),
	                Where.or(
	                        Where.between(Person_RORM.AGE, 19, 39),
	                        Where.isNull(Person_RORM.ADDRESS)
	                ),
	                Where.eq(Person_RORM.TYPE_ID, 1)
        		)
            )
            .addOrder(Person_RORM.ID, false)
            .addOrder(Person_RORM.NAME, true)
            .setLimit(10)
            .query(this);
}
```

#### 2.1.5 兼容SqlCipher

与`v1.0`一致.