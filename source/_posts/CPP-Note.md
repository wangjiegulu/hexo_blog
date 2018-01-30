---
title: CPP Note
tags: [cpp, c++]
date: 2017-04-10 15:05:00
---

hello.cpp -> 编译代码`g++ hello.cpp -o a` -> `a.out`

区分大小写的编程语言

<!-- more -->

### 内置类型

一些基本类型可以使用一个或多个类型修饰符进行修饰：

- **signed**: char, int
- **unsigned**: char, int
- **short**: int
- **long**: int, double

|类型|字节|
|---|---|
|**bool**||
|**char**|1|
|**int**|4, 2(short), 8(long)|
|**float**|4|
|**double**|8|
|**void**||
|**wchar_t**（宽字符型）|2, 4|

### typedef 声明

使用 `typedef` 为一个已有的类型取一个新的名字:

```c++
typedef int feet;
// ...
feet distance;
```

### 枚举类型

```
enum enum-name { list of names } var-list; 
```

```
enum color { red, green, blue } c;
c = blue;
```

```
enum color { red, green=5, blue };
```

则 blue = 6

### 变量定义

```c++
type variable_list;

int    i, j, k;
char   c, ch;
float  f, salary;
double d;

extern int d = 3, f = 5;    // d 和 f 的声明 
int d = 3, f = 5;           // 定义并初始化 d 和 f
byte z = 22;                // 定义并初始化 z
char x = 'x';               // 变量 x 的值为 'x'
```

### 变量声明

变量声明向编译器保证变量以给定的类型和名称存在，这样编译器在不需要知道变量完整细节的情况下也能继续进一步的编译。变量声明只在编译时有它的意义，在程序连接时编译器需要实际的变量声明。

### 全局变量默认值

|类型|默认值|
|---|---|
|int|0|
|char|'\0'|
|float|0|
|double|0|
|pointer|NULL|

### 常量

> 0x 或 0X 表示十六进制，0 表示八进制，不带前缀则默认表示十进制。

#### 整数常量

也可以带一个或者多个后缀：

- '**U**': unsigned
- '**L**': long

```
85         // 十进制
0213       // 八进制 
0x4b       // 十六进制 
30         // 整数 
30u        // 无符号整数 
30l        // 长整数 
30ul       // 无符号长整数
```

#### 浮点常量

由整数部分、小数点、小数部分和指数部分组成

```
3.14159       // 合法的 
314159E-5L    // 合法的 
510E          // 非法的：不完整的指数
210f          // 非法的：没有小数或指数
.e55          // 非法的：缺少整数或分数
```

#### 布尔常量

- **true**: 值代表真。
- **false**: 值代表假。

> 不应把 true 的值看成 1，把 false 的值看成 0。

#### 字符常量

字符常量是括在单引号中。如果常量以 L（仅当大写时）开头，则表示它是一个宽字符常量（例如 L'x'），此时它必须存储在 wchar_t 类型的变量中。否则，它就是一个窄字符常量（例如 'x'），此时它可以存储在 char 类型的简单变量中。

|转义序列|含义|
|---|---|---|
|\\|\ 字符|
|\'|' 字符|
|\"|" 字符|
|\?|? 字符|
|\a|警报铃声|
|\b|退格键|
|\f|换页符|
|\n|换行符|
|\r|回车|
|\t|水平制表符|
|\v|垂直制表符|
\ooo|一到三位的八进制数|
\xhh . . .|一个或多个数字的十六进制数|

#### 字符串常量

下面这三种形式所显示的字符串是相同的。

```
"hello, dear"

"hello, \

dear"

"hello, " "d" "ear"
```

### 定义常量

两种简单的定义常量的方式：

- 使用 **#define** 预处理器。
- 使用 **const** 关键字。

#### #define 预处理器

```
#define identifier value
```
```
#define LENGTH 10   
#define WIDTH  5
#define NEWLINE '\n'

int main() {

   int area;  

   area = LENGTH * WIDTH;
   cout << area;
   cout << NEWLINE;
   return 0;
}
```

### const 关键字

```
const type variable = value;
```
```c++
int main() {
   const int  LENGTH = 10;
   const int  WIDTH  = 5;
   const char NEWLINE = '\n';
   int area;  

   area = LENGTH * WIDTH;
   cout << area;
   cout << NEWLINE;
   return 0;
}
```

### 修饰符类型

可以不写 int，只写单词 unsigned、short 或 unsigned、long，int 是隐含的

```java
unsigned x;
unsigned int y;
```

### 类型限定符

|限定符|含义|
|---|---|---|
|const|const 类型的对象在程序执行期间不能被修改改变。|
|volatile|修饰符 volatile 告诉编译器，变量的值可能以程序未明确指定的方式被改变。|
|restrict|由 restrict 修饰的指针是唯一一种访问它所指向的对象的方式。只有 C99 增加了新的类型限定符 restrict。|

### 存储类

存储类定义 C++ 程序中变量/函数的范围（可见性）和生命周期。

- auto: 从 C++ 11 开始不再是 C++ 存储类说明符
- register: 从 C++ 11 开始被弃用
- static
- extern
- mutable
- thread_local (C++11)

#### auto 存储类

声明变量时根据初始化表达式自动推断该变量的类型、声明函数时函数返回值的占位符。使用极少且多余，在C++11中已删除这一用法。

#### register 存储类

register 存储类用于定义存储在寄存器中而不是 RAM 中的局部变量。这意味着变量的最大尺寸等于寄存器的大小（通常是一个词），且不能对它应用一元的 '&' 运算符（因为它没有内存位置）。

寄存器只用于需要快速访问的变量，比如计数器。还应注意的是，定义 'register' 并不意味着变量将被存储在寄存器中，它意味着变量可能存储在寄存器中，这取决于硬件和实现的限制。

#### static 存储类

static 存储类指示编译器在程序的生命周期内保持局部变量的存在，而不需要在每次它进入和离开作用域时进行创建和销毁。

**static 可用于局部变量和全局变量**

#### extern 存储类

extern 存储类用于提供一个全局变量的引用，全局变量对所有的程序文件都是可见的。
通过 extern 声明其它文件的变量，然后在本文件中使用。

#### mutable 存储类

mutable 说明符仅适用于类的对象，它允许对象的成员替代常量。也就是说，mutable 成员可以通过 const 成员函数修改。

#### thread\_local 存储类

使用 thread\_local 说明符声明的变量仅可在它在其上创建的线程上访问。 变量在创建线程时创建，并在销毁线程时销毁。 每个线程都有其自己的变量副本。
thread\_local 说明符可以与 static 或 extern 合并。
可以将 thread\_local 仅应用于数据声明和定义，thread\_local 不能用于函数声明或定义。

### 杂项运算符

|运算符|描述|
|---|---|
|sizeof|sizeof 运算符返回变量的大小。例如，sizeof(a) 将返回 4，其中 a 是整数。|
|Condition ? X : Y|条件运算符。如果 Condition 为真 ? 则值为 X : 否则值为 Y。|
|,|逗号运算符会顺序执行一系列运算。整个逗号表达式的值是以逗号分隔的列表中的最后一个表达式的值。|
|.（点）和 ->（箭头）|成员运算符用于引用类、结构和共用体的成员。|
|Cast|强制转换运算符把一种数据类型转换为另一种数据类型。例如，int(2.2000) 将返回 2。|
|&|指针运算符 & 返回变量的地址。例如 &a; 将给出变量的实际地址。|
|\*|指针运算符 \* 指向一个变量。例如，\*var; 将指向变量 var。|

### 函数参数

|调用类型|描述|
|---|---|
|传值调用|该方法把参数的实际值复制给函数的形式参数。在这种情况下，修改函数内的形式参数对实际参数没有影响。|
|指针调用|该方法把参数的地址复制给形式参数。在函数内，该地址用于访问调用中要用到的实际参数。这意味着，修改形式参数会影响实际参数。|
|引用调用|该方法把参数的引用复制给形式参数。在函数内，该引用用于访问调用中要用到的实际参数。这意味着，修改形式参数会影响实际参数。|

**默认情况下，C++ 使用传值调用来传递参数。**一般来说，这意味着函数内的代码不能改变用于调用函数的参数。之前提到的实例，调用 max() 函数时，使用了相同的方法。

### 参数的默认值

```cpp
int sum(int a, int b=20)
{
  int result;

  result = a + b;

  return result;
}
// ...
result = sum(1, 2); // 3
result = sum(1); // 21
```

### Lambda 函数与表达式

```cpp
// 有参数：[capture](parameters)->return-type{body}
[](int x, int y){ return x < y ; }

// 无参数：[capture](parameters){body}
[]{ ++global_x; } 

// 返回类型可以被明确的指定:
[](int x, int y) -> int { int z = x + y; return z + x; }

```

变量传递有传值和传引用的区别。可以通过前面的[]来指定：

```
[]      // 沒有定义任何变量。使用未定义变量会引发错误。
[x, &y] // x以传值方式传入（默认），y以引用方式传入。
[&]     // 任何被使用到的外部变量都隐式地以引用方式加以引用。
[=]     // 任何被使用到的外部变量都隐式地以传值方式加以引用。
[&, x]  // x显式地以传值方式加以引用。其余变量以引用方式加以引用。
[=, &z] // z显式地以引用方式加以引用。其余变量以传值方式加以引用。
```

对于[=]或[&]的形式，lambda 表达式可以直接使用 this 指针。但是，对于[]的形式，如果要使用 this 指针，必须显式传入：

```
[this]() { this->someFunc(); }();
```

### 数学运算

引用数学头文件 \<cmath\>

sin, cos, tan, log, pow, hypot(两数总和平方根), fabs（绝对值）

### 随机数

```cpp
// 设置种子
srand( (unsigned)time( NULL ) );

rand();
```

### 数组

#### 声明数组

> 数组是一个常量指针

```cpp
// type arrayName [ arraySize ];
double balance[10];
```

#### 初始化数组

```cpp
double balance[5] = {1000.0, 2.0, 3.4, 17.0, 50.0};
double balance[] = {1000.0, 2.0, 3.4, 17.0, 50.0};

balance[4] = 50.0; // 

```

直接初始化 char 数组是特殊的, **这种初始化要记得字符是以一个 null 结尾的**。

```
char a1[] = {'C', '+', '+'};          // 初始化，没有 null
char a2[] = {'C', '+', '+', '\0'};    // 初始化，明确有 null
char a3[] = "C++";                    // null 终止符自动添加
const char a4[6] = "runoob";          // 报错，没有 null 的位置
```

### 指针变量声明

```c++
type *var-name;

int    *ip;    /* 一个整型的指针 */
double *dp;    /* 一个 double 型的指针 */
float  *fp;    /* 一个浮点型的指针 */
char   *ch;    /* 一个字符型的指针 */
```

```cpp
int var = 20;
// int *ip = &var
int *ip;
ip = &var;

cout << "var: " << var << endl; // 20

cout << "ip: " << ip << endl; // 0x7fff50bbe874

cout << "*ip: " << *ip << endl; // 20
```

#### NULL 指针

NULL 指针是一个定义在标准库中的值为零的常量：

```cpp
int *nullP = NULL;
if(!nullP){
    cout << "nullP: " << nullP << endl; // 0x0
}
```

#### 指针的算术运算

```
ptr++
```

假设 ptr 是一个指向地址 1000 的整型指针，是一个 32 位的整数(4个字节)，,ptr 将指向位置 1004，因为 ptr 每增加一次，它都将指向下一个整数位置，即当前位置往后移 4 个字节。

如果 ptr 指向一个地址为 1000 的字符(1个字节)，上面的运算会导致指针指向位置 1001，因为下一个字符位置是在 1001。

**数组是一个常量指针**

#### 传递指针给函数

```cpp
int *pr;
int **ppr;
pr = &var;
ppr = &pr;

funPointer(pr);
funPointer(*ppr);
int var = 20;
funPointer(&var);

void funPointer(int *p){
	cout << "[funPointer]*p: " << *p << endl;
}
```

#### 从函数返回指针

C++ 不支持在函数外返回局部变量的地址，除非定义局部变量为 static 变量。

```cpp
int var = 20;

int *fp2p = funPointer2(&var);
cout << "*fp2p:" << *fp2p << endl;

int * funPointer2(int *p) {
    p++;
    p--;
    return p;
}
```

### 引用 vs 指针
引用很容易与指针混淆，它们之间有三个主要的不同：

- 不存在空引用。引用必须连接到一块合法的内存。
- 一旦引用被初始化为一个对象，就不能被指向到另一个对象。指针可以在任何时候指向到另一个对象。
- 引用必须在创建时被初始化。指针可以在任何时间被初始化。

#### 创建引用

```cpp
// 声明简单的变量
int    i;
double d;

// 声明引用变量
int&    r = i; // r 是一个初始化为 i 的整型引用
double& s = d; // s 是一个初始化为 d 的 double 型引用

```
在这些声明中，**&** 读作引用。

```cpp
int swapA = 1;
int swapB = 2;

swapWithRef(swapA, swapB);

void swapWithRef(int &a, int &b) {
    int temp = a;
    a = b;
    b = temp;
}
```

```cpp
int swapA = 1;
int swapB = 2;

swapWithPointer(&swapAP, &swapBP);

void swapWithPointer(int *a, int *b){
    int temp = *a; // 局部变量temp的值为[a指针指向的值](1)
    *a = *b; // a指针指向的值改为[b指针指向的值](2)
    *b = temp; // b指针指向的值改为temp(1)
}
```

#### 把引用作为返回值

当函数返回一个引用时，则返回一个指向返回值的隐式指针。这样，函数就可以放在赋值语句的左边。

```cpp
double vals[] = {10.1, 12.6, 33.1, 24.1, 50.0};

double &setValues(int i) {
    return vals[i];   // 返回第 i 个元素的引用
}

setValues(1) = 20.17;
cout << "vals: " << vals[1] << endl;
```

返回一个对局部变量的引用是不合法的，但是，可以返回一个对静态变量的引用。

#### 日期 & 时间

C/C++ 标准库, 引用 \<ctime\> 头文件

`有四个与时间相关的类型：clock_t、time_t、size_t 和 tm`

构类型 tm 把日期和时间以 C 结构的形式保存

```cpp
struct tm {
  int tm_sec;   // 秒，正常范围从 0 到 59，但允许至 61
  int tm_min;   // 分，范围从 0 到 59
  int tm_hour;  // 小时，范围从 0 到 23
  int tm_mday;  // 一月中的第几天，范围从 1 到 31
  int tm_mon;   // 月，范围从 0 到 11
  int tm_year;  // 自 1900 年起的年数
  int tm_wday;  // 一周中的第几天，范围从 0 到 6，从星期日算起
  int tm_yday;  // 一年中的第几天，范围从 0 到 365，从 1 月 1 日算起
  int tm_isdst; // 夏令时
}
```
```cpp
time_t now = time(0); // 基于当前系统的当前日期/时间
cout << "now: " << now << endl;

char *dt = ctime(&now); // 把 now 转换为字符串形式
cout << "本地日期和时间：" << dt << endl;

// 把 now 转换为 tm 结构
tm *gmtm = gmtime(&now);
dt = asctime(gmtm);
cout << "UTC 日期和时间：" << dt << endl;

tm *ltm = localtime(&now);
// 输出 tm 结构的各个组成部分
cout << "Year: "<< 1900 + ltm->tm_year << endl;
cout << "Month: "<< 1 + ltm->tm_mon<< endl;
cout << "Day: "<<  ltm->tm_mday << endl;
cout << "Time: "<< ltm->tm_hour << ":";
cout << ltm->tm_min << ":";
cout << ltm->tm_sec << endl;
```

### 标准输出流（cout）

预定义的对象 `cout` 是 `ostream` 类的一个实例, 流插入运算符 `<<`

```cpp
char str[] = "Hello C++";
cout << "Value of str is : " << str << endl;
```

### 标准输入流（cin）

预定义的对象 cin 是 istream 类的一个实例。流提取运算符 `>>`

```cpp
char name[50];
cout << "请输入您的名称： ";
cin >> name;
cout << "您的名称是： " << name << endl;
```

### 标准错误流（cerr）

```cpp
char str[] = "Fake Error...";
cerr << "Error message: " << str << endl;
```

### 标准日志流（clog）

```cpp
char strLog[] = "Fake Log...";
clog << "Log message: " << strLog << endl;
```

### 数据结构

#### 定义结构

使用 **struct** 语句。struct 语句定义了一个包含多个成员的新的数据类型

```cpp
struct type_name {
member_type1 member_name1;
member_type2 member_name2;
member_type3 member_name3;
.
.
} object_names;
```

type\_name 是结构体类型的名称，member\_type1 member\_name1 是标准的变量定义，比如 int i; 或者 float f; 或者其他有效的变量定义。在结构定义的末尾，最后一个分号之前，您可以指定一个或多个结构变量，这是可选的。

```cpp
struct Books
{
   char  title[50];
   char  author[50];
   char  subject[100];
   int   book_id;
} book;
```

#### 访问结构成员

使用成员访问运算符（**.**）

```cpp
struct Book{
    char title[50];
    char author[50];
    char subject[100];
    int book_id;
};
// ...
Book book1;
strcpy(book1.title, "c++");
strcpy(book1.author, "wangjie");
strcpy(book1.subject, "c++ subject");
book1.book_id = 100;

cout << "book1 title: " << book1.title << endl;
cout << "book1 author: " << book1.author << endl;
cout << "book1 subject: " << book1.subject << endl;
cout << "book1 book_id: " << book1.book_id << endl;
```

#### 结构作为函数参数

```cpp
void printBook(struct Book book){
    cout << "[printBook]book title: " << book.title << endl;
    cout << "[printBook]book author: " << book.author << endl;
    cout << "[printBook]book subject: " << book.subject << endl;
    cout << "[printBook]book book_id: " << book.book_id << endl;
}

Book book2;

strcpy(book2.title, "java");
strcpy(book2.author, "wangjie");
strcpy(book2.subject, "java subject");
book2.book_id = 200;

printBook(book2);
```

#### 指向结构的指针

```cpp
Book *book1P = &book1;
cout << "book1P->title: " << book1P->title << endl;
cout << "book1P->author: " << book1P->author << endl;
cout << "book1P->subject: " << book1P->subject << endl;
cout << "book1P->book_id: " << book1P->book_id << endl;
```

**为了使用指向该结构的指针访问结构的成员，您必须使用 `->` 运算符**

#### typedef 关键字

定义结构的方式，可以为创建的类型取一个"别名":

```cpp
typedef struct
{
   char  title[50];
   char  author[50];
   char  subject[100];
   int   book_id;
}Books;
```

可以使用 typedef 关键字来定义非结构类型:

```cpp
typedef long int *pint32;
pint32 x, y, z;
```

x, y 和 z 都是指向长整型 long int 的指针。

### 类和对象

#### 创建类

```cpp
class Box {
public:
    double length;
    double breadth;
    double height;
};
```

#### 成员函数

范围解析运算符 **::**

```cpp
class Box {
public:
    double length;
    double breadth;
    double height;
    // 成员函数定义
    double getVolume(void);
};

// 成员函数声明
double Box::getVolume(void){
    return this->height * this->breadth * this->length;
}
```

### 类访问修饰符

`public`, `protected`, `private`(默认)

```cpp
class Base {

   public:

  // public members go here

   protected:

  // protected members go here

   private:

  // private members go here

};
```

`public`成员在程序中类的外部是可访问的.

`private`成员变量或函数在类的外部是不可访问的，甚至是不可查看的。只有类和友元函数可以访问私有成员。

`protected`成员变量或函数与私有成员十分相似，但有一点不同，保护成员在派生类（即子类）中是可访问的。

### 类的构造函数

```cpp
Box::Box(double length, double breadth, double height){
    this->length = length;
    this->breadth = breadth;
    this->height = height;
    std::cout << "box created2..." << std::endl;
}

Box::Box(double length, double breadth, double height) : length(length), breadth(breadth), height(height){
    std::cout << "box created 初始化列表..." << std::endl;
}
```

### 类的析构函数

类的析构函数是类的一种特殊的成员函数，它会在每次删除所创建的对象时执行。
析构函数的名称与类的名称是完全相同的，只是在前面加了个波浪号（~）作为前缀，它不会返回任何值，也不能带有任何参数。析构函数有助于在跳出程序（比如关闭文件、释放内存等）前释放资源。

```cpp
~Box();

Box::~Box() {
    cout << "Object is being deleted" << endl;
}
```

### 拷贝构造函数

<http://www.runoob.com/cplusplus/cpp-copy-constructor.html>

```cpp
classname (const classname &obj) {
   // 构造函数的主体
}
```

```cpp
Line( const Line &obj);      // 拷贝构造函数

Line::Line(const Line &obj){
    cout << "调用拷贝构造函数并为指针 ptr 分配内存" << endl;
    ptr = new int;
    *ptr = *obj.ptr; // 拷贝值
}
```

### 友元函数

类的友元函数是定义在类外部，但有权访问类的所有私有（private）成员和保护（protected）成员。尽管友元函数的原型有在类的定义中出现过，但是友元函数并不是成员函数。
友元可以是一个函数，该函数被称为友元函数；友元也可以是一个类，该类被称为友元类，在这种情况下，整个类及其所有成员都是友元。

**friend**关键字

声明类 ClassTwo 的所有成员函数作为类 ClassOne 的友元，需要在类 ClassOne 的定义中放置如下声明：
`friend class ClassTwo;`

```cpp
class Box
{
   double width;
public:
   double length;
   friend void printWidth( Box box );
   void setWidth( double wid );
};

// 请注意：printWidth() 不是任何类的成员函数
void printWidth( Box box )
{
   /* 因为 printWidth() 是 Box 的友元，它可以直接访问该类的任何成员 */
   cout << "Width of box : " << box.width <<endl;
}
```

### 内联函数

内联函数是通常与类一起使用。如果一个函数是内联的，那么在编译时，编译器会把该函数的代码副本放置在每个调用该函数的地方。

```cpp
inline int Max(int x, int y)
{
   return (x > y)? x : y;
}

cout << "Max (20,10): " << Max(20,10) << endl;
cout << "Max (0,200): " << Max(0,200) << endl;
cout << "Max (100,1010): " << Max(100,1010) << endl;
```

#### this 指针

每一个对象都能通过 this 指针来访问自己的地址。this 指针是所有成员函数的隐含参数。因此，在成员函数内部，它可以用来指向调用对象。

友元函数没有 this 指针，因为友元不是类的成员。只有成员函数才有 this 指针。

#### 指向类的指针

一个指向 C++ 类的指针与指向结构的指针类似，访问指向类的指针的成员，需要使用成员访问运算符 ->，就像访问指向结构的指针一样。与所有的指针一样，您必须在使用指针之前，对指针进行初始化。

```cpp
Box *boxBPr = &boxB;
cout << "*boxBPr->getVolume(): " << boxBPr->getVolume() << endl;
```

#### 类的静态成员

```cpp
static int objectCount;

// 初始化类 Box 的静态成员
int Box::objectCount = 0;

cout << "static objects: " << Box::objectCount << endl;
```

```
static bool staticFunc();

Box::staticFunc();
```

#### 基类 & 派生类

一个类可以派生自多个类，这意味着，它可以从多个基类继承数据和函数。定义一个派生类，我们使用一个类派生列表来指定基类。类派生列表以一个或多个基类命名，形式如下：

`class derived-class: access-specifier base-class`

`access-specifier` 是 `public`、`protected` 或 `private` 其中的一个，默认为 `private`，`base-class` 是之前定义过的某个类的名称。

一个派生类继承了所有的基类方法，但下列情况除外：

- 基类的构造函数、析构函数和拷贝构造函数。
- 基类的重载运算符。
- 基类的友元函数。

#### 继承类型
我们几乎不使用 protected 或 private 继承，通常使用 public 继承。当使用不同类型的继承时，遵循以下几个规则：

- 公有继承（**public**）：当一个类派生自**公有**基类时，基类的**公有**成员也是派生类的**公有**成员，基类的**保护**成员也是派生类的**保护**成员，基类的**私有**成员不能直接被派生类访问，但是可以通过调用基类的**公有**和**保护**成员来访问。
- 保护继承（**protected**）： 当一个类派生自**保护**基类时，基类的**公有**和**保护**成员将成为派生类的**保护**成员。
- 私有继承（**private**）：当一个类派生自**私有**基类时，基类的**公有**和**保护**成员将成为派生类的**私有**成员。

#### 多继承

多继承即一个子类可以有多个父类，它继承了多个父类的特性。
语法如下：

```cpp
class <派生类名>:<继承方式1><基类名1>,<继承方式2><基类名2>,…
{
<派生类类体>
};

class Rectangle: public Shape, public PaintCost{
// ...
}
```

#### 函数重载

当您调用一个重载函数或重载运算符时，编译器通过把您所使用的参数类型与定义中的参数类型进行比较，决定选用最合适的定义。选择最合适的重载函数或重载运算符的过程，称为重载决策。

```cpp
void Rectangle::print(int intValue) {
    cout << "int value: " << intValue << endl;
}

void Rectangle::print(int *intValue) {
    cout << "*int value: " << *intValue << endl;
}

void Rectangle::print(double doubleValue) {
    cout << "double value: " << doubleValue << endl;
}

void Rectangle::print(const char *c) {
    cout << "char values: " << c << endl;
}

rect.print(3);
rect.print(3.3);
int intValue = 300;
rect.print(&intValue);
rect.print("hello print string.");
```

#### 运算符重载

可以重定义或重载大部分 C++ 内置的运算符。这样，您就能使用自定义类型的运算符。

重载的运算符是带有特殊名称的函数，函数名是由关键字 operator 和其后要重载的运算符符号构成的。与其他函数一样，重载运算符有一个返回类型和一个参数列表。

```cpp
Box operator+(const Box&);
```

声明加法运算符用于把两个 Box 对象相加，返回最终的 Box 对象。

大多数的重载运算符可被定义为普通的非成员函数或者被定义为类成员函数。

```cpp
Box operator+(const Box&, const Box&);

Box Box::operator+(Box &b) {
    Box resultBox;
    resultBox.width = this->width + b.width;
    resultBox.height = this->height + b.height;
    resultBox.breadth = this->breadth + b.breadth;
    resultBox.length = this->length + b.length;
    return resultBox;
}
```

##### 可重载运算符

|||||||
|---|---|---|---|---|---|
|+|-|*|/|%|^|
|&|\||~|!|,|=|
|<|>|<=|>=|++|--|
|<<|>>|==|!=|&&|\|\||
|+=|-=|/=|%=|^=|&=|
|\||=|*=|<<=|>>=|[]|()|
|->|->*|new|new []|delete|delete []|

##### 不可重载运算符

|||||
|---|---|---|---|
|::|.*|.|?:|

运算符重载实例: http://www.runoob.com/cplusplus/cpp-overloading.html

#### 多态

```cpp
// in Shape class
virtual int getArea();

// in Rectangle class
int Rectangle::getArea() {
    cout << "Rectangle::getArea()" << endl;
    return width * height;
}

// in Triangle class
int Triangle::getArea() {
    cout << "Triangle::getArea()" << endl;
    return width * height;
}

Shape *shapePtr;
shapePtr = &rect;
cout << "&rect pointer->getArea(): " << shapePtr->getArea() << endl;
Triangle triangle(3, 4);
shapePtr = &triangle;
cout << "&triangle pointer->getArea(): " << shapePtr->getArea() << endl;
```

```
// out put
&rect pointer->getArea(): Rectangle::getArea()
&triangle pointer->getArea(): Triangle::getArea()

```

调用函数 area() 被编译器设置为基类中的版本，这就是所谓的**静态多态**，或**静态链接** - 函数调用在程序执行前就准备好了。有时候这也被称为**早绑定**，因为 area() 函数在程序编译期间就已经设置好了。

放置关键字**virtual**后，编译器看的是指针的内容，而不是它的类型。

#### 虚函数

**虚函数** 是在基类中使用关键字 virtual 声明的函数。在派生类中重新定义基类中定义的虚函数时，会告诉编译器不要静态链接到该函数。

我们想要的是在程序中任意点可以根据所调用的对象类型来选择调用的函数，这种操作被称为**动态链接**，或**后期绑定**。

#### 纯虚函数

您可能想要在基类中定义虚函数，以便在派生类中重新定义该函数更好地适用于对象，但是您在基类中又不能对虚函数给出有意义的实现，这个时候就会用到纯虚函数。

```cpp
// pure virtual function
virtual int area() = 0;
```

**= 0** 告诉编译器，函数没有主体，上面的虚函数是纯虚函数。

#### 文件和流

|数据类型|描述|
|---|---|
|ofstream|该数据类型表示输出文件流，用于创建文件并向文件写入信息。|
|ifstream|该数据类型表示输入文件流，用于从文件读取信息。|
|fstream|该数据类型通常表示文件流，且同时具有 ofstream 和 ifstream 两种功能，这意味着它可以创建文件，向文件写入信息，从文件读取信息。|

|模式标志|描述|
|---|---|
|ios::app|追加模式。所有写入都追加到文件末尾。|
|ios::ate|文件打开后定位到文件末尾。|
|ios::in|打开文件用于读取。|
|ios::out|打开文件用于写入。|
|ios::trunc|如果该文件已经存在，其内容将在打开文件之前被截断，即把文件长度设为 0。|

```cpp
const char *filePath = "/Users/wangjie/work/cpp/HelloCpp/com.wangjie.cpptest/file_temp";
ofstream outfile;
outfile.open(filePath, ios::trunc);
outfile << "temp" << endl;
outfile.close();

ifstream infile;
infile.open(filePath);
char data[100];
infile >> data;
cout << data << endl;
infile.close();

// 定位到 fileObject 的第 n 个字节（假设是 ios::beg）
fileObject.seekg( n );

// 把文件的读指针从 fileObject 当前位置向后移 n 个字节
fileObject.seekg( n, ios::cur );

// 把文件的读指针从 fileObject 末尾往回移 n 个字节
fileObject.seekg( n, ios::end );

// 定位到 fileObject 的末尾
fileObject.seekg( 0, ios::end );
```

#### 异常处理

抛出异常:

```cpp
double division(int a, int b)
{
   if( b == 0 )
   {
      throw "Division by zero condition!";
   }
   return (a/b);
}
```

C++ 提供了一系列标准的异常，定义在 <exception> 中。

定义新的异常：

|异常|描述|
|---|---|
|std::exception|该异常是所有标准 C++ 异常的父类。|
|std::bad\_alloc|该异常可以通过 new 抛出。|
|std::bad\_cast|该异常可以通过 dynamic_cast 抛出。|
|std::bad\_exception|这在处理 C++ 程序中无法预期的异常时非常有用。|
|std::bad\_typeid|该异常可以通过 typeid 抛出。|
|std::logic\_error|理论上可以通过读取代码来检测到的异常。|
|std::domain\_error|当使用了一个无效的数学域时，会抛出该异常。|
|std::invalid\_argument|当使用了无效的参数时，会抛出该异常。|
|std::length\_error|当创建了太长的 std::string 时，会抛出该异常。|
|std::out\_of\_range|该异常可以通过方法抛出，例如 std::vector 和 std::bitset<>::operator\[]()。|
|std::runtime\_error|理论上不可以通过读取代码来检测到的异常。|
|std::overflow\_error|当发生数学上溢时，会抛出该异常。|
|std::range\_error|当尝试存储超出范围的值时，会抛出该异常。|
|std::underflow\_error|当发生数学下溢时，会抛出该异常。|

```cpp
#include <iostream>
#include <exception>
using namespace std;

struct MyException : public exception
{
  const char * what () const throw ()
  {
    return "C++ Exception";
  }
};

int main()
{
  try
  {
    throw MyException();
  }
  catch(MyException& e)
  {
    std::cout << "MyException caught" << std::endl;
    std::cout << e.what() << std::endl;
  }
  catch(std::exception& e)
  {
    //其他的错误
  }
}
```

#### 动态内存

内存分为两个部分：

- 栈：在函数内部声明的所有变量都将占用栈内存。
- 堆：这是程序中未使用的内存，在程序运行时可用于动态分配内存。

很多时候，您无法提前预知需要多少内存来存储某个定义变量中的特定信息，所需内存的大小需要在运行时才能确定。
在 C++ 中，您可以使用特殊的运算符为给定类型的变量在运行时分配堆内的内存，这会返回所分配的空间地址。这种运算符即 **new** 运算符。

如果您不需要动态分配内存，可以使用 **delete** 运算符，删除之前由 new 运算符分配的内存。

```cpp
double* pvalue  = NULL; // 初始化为 null 的指针
pvalue  = new double;   // 为变量请求内存

double* pvalue  = NULL;
if( !(pvalue  = new double ))
{
   cout << "Error: out of memory." <<endl;
   exit(1);
}

// new 与 malloc() 函数相比，其主要的优点是，new 不只是分配了内存，它还创建了对象。

delete pvalue; // 释放 pvalue 所指向的内存

// ...

char* pvalue  = NULL;   // 初始化为 null 的指针
pvalue  = new char[20]; // 为变量请求内存

delete [] pvalue;        // 删除 pvalue 所指向的数组
```

#### 命名空间

定义命名空间:

```cpp
namespace namespace_name {
   // 代码声明
}
```

```cpp
namespace first_space {
    void func() {
        cout << "Inside first_space" << endl;
    }
}

namespace second_space {
    void func() {
        cout << "Inside second_space" << endl;
    }
}

first_space::func();
second_space::func();
```

可以使用 using namespace 指令，这样在使用命名空间时就可以不用在前面加上命名空间的名称。

using 指令也可以用来指定命名空间中的特定项目。例如，如果您只打算使用 std 命名空间中的 cout 部分，您可以使用如下的语句：

```cpp
using std::cout;
```

#### 不连续的命名空间
命名空间可以定义在几个不同的部分中，因此命名空间是由几个单独定义的部分组成的。一个命名空间的各个组成部分可以分散在多个文件中。

下面的命名空间定义可以是定义一个新的命名空间，也可以是为已有的命名空间增加新的元素：
```cpp
namespace namespace_name {
   // 代码声明
}
```

#### 函数模板

```cpp
template <typename T>
inline T const& maxTemplate(T const& a, T const& b){
    return a < b ? b : a;
}

cout << "maxTemplate(1, 2): " << maxTemplate(1, 2) << endl;
cout << "maxTemplate(1.0, 2.0): " << maxTemplate(1.0, 2.0) << endl;
cout << "maxTemplate(\"a\", \"b\"): " << maxTemplate("a", "b") << endl;
```

#### 类模板

```cpp
template <class type> class class-name {
.
.
.
}
```

#### 预处理器

预处理器是一些指令，指示编译器在实际编译之前所需完成的预处理。
所有的预处理器指令都是以井号（#）开头，只有空格字符可以出现在预处理指令之前。预处理指令不是 C++ 语句，所以它们不会以分号（;）结尾。
我们已经看到，之前所有的实例中都有 #include 指令。这个宏用于把头文件包含到源文件中。

C++ 还支持很多预处理指令，比如 #include、#define、#if、#else、#line 等，让我们一起看看这些重要指令。

##### \#define 预处理

\#define 预处理指令用于创建符号常量。该符号常量通常称为宏，指令的一般形式是：

```
#define macro-name replacement-text 
```

```cpp
#include <iostream>
using namespace std;

#define PI 3.14159

int main ()
{
    cout << "Value of PI :" << PI << endl; 
    return 0;
}
```

函数宏：

```cpp
#define MIN(a, b) (a < b ? a : b)

cout << "#MIN(1, 2): " << MIN(1, 2) << endl;
```

条件编译: http://www.runoob.com/cplusplus/cpp-preprocessor.html

### 信号处理

信号是由操作系统传给进程的中断，会提早终止一个程序。在 UNIX、LINUX、Mac OS X 或 Windows 系统上，可以通过按 Ctrl+C 产生中断。

有些信号不能被程序捕获，但是下表所列信号可以在程序中捕获，并可以基于信号采取适当的动作。这些信号是定义在 C++ 头文件 <csignal> 中。

|信号|描述|
|---|---|
|SIGABRT|程序的异常终止，如调用 abort。|
|SIGFPE|错误的算术运算，比如除以零或导致溢出的操作。|
|SIGILL|检测非法指令。|
|SIGINT|接收到交互注意信号。|
|SIGSEGV|非法访问内存。|
|SIGTERM|发送到程序的终止请求。|

#### signal() 函数

用来捕获突发事件。以下是 signal() 函数的语法：

```cpp
void (*signal (int sig, void (*func)(int)))(int); 
```

这个函数接收两个参数：第一个参数是一个整数，代表了信号的编号；第二个参数是一个指向信号处理函数的指针。

```cpp
void signalHandler( int signum ){
    cout << "Interrupt signal (" << signum << ") received.\n";

    // 清理并关闭
    // 终止程序  

   exit(signum);  

}

int main (){
    // 注册信号 SIGINT 和信号处理程序
    signal(SIGINT, signalHandler);  

    while(1){
       cout << "Going to sleep...." << endl;
       sleep(1);
    }

    return 0;
}
```

```
Going to sleep....
Going to sleep....
Going to sleep....
[按 Ctrl+C 来中断程序]
Interrupt signal (2) received.
```

#### raise() 函数

可以使用函数 raise() 生成信号，该函数带有一个整数信号编号作为参数，语法如下：

```cpp
int raise (signal sig);
```

在这里，sig 是要发送的信号的编号，这些信号包括：SIGINT、SIGABRT、SIGFPE、SIGILL、SIGSEGV、SIGTERM、SIGHUP。以下是我们使用 raise() 函数内部生成信号的实例：

```cpp
void signalHandler( int signum ){
    cout << "Interrupt signal (" << signum << ") received.\n";

    // 清理并关闭
    // 终止程序 

   exit(signum);  

}

int main (){
    int i = 0;
    // 注册信号 SIGINT 和信号处理程序
    signal(SIGINT, signalHandler);  

    while(++i){
       cout << "Going to sleep...." << endl;
       if( i == 3 ){
          raise( SIGINT);
       }
       sleep(1);
    }

    return 0;
}
```

```
Going to sleep....
Going to sleep....
Going to sleep....
Interrupt signal (2) received.
```

