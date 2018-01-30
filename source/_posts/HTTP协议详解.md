---
title: HTTP协议详解
tags: [http]
date: 2016-08-29 14:13:00
---

<div id="editor-reader-full" class="editor-reader-full-shown">
<div class="reader-full-topInfo-shown">来自:&nbsp;[https://www.zybuluo.com/yangfch3/note/167490](https://www.zybuluo.com/yangfch3/note/167490)</div>
<div class="reader-full-topInfo-shown">&nbsp;</div>
<div id="reader-full-topInfo" class="reader-full-topInfo-shown">HTTP协议详解</div>
<div id="wmd-preview" class="wmd-preview wmd-preview-full-reader" data-medium-element="true">

`http`

* * *

<div class="md-section-divider">&nbsp;</div>

### `http`？

*   全称：超文本传输协议`(HyperText Transfer Protocol)`
*   作用：设计之初是为了将超文本标记语言`(HTML)`文档从Web服务器传送到客户端的浏览器。现在`http`的作用已不局限于`HTML`的传输。
*   版本：`http/1.0`&nbsp;`http/1.1*`&nbsp;`http/2.0`

* * *

<div class="md-section-divider">&nbsp;</div>

### 两篇佳文

[输入网址之后发生了什么](https://www.zybuluo.com/yangfch3/note/113028)&nbsp;
[Web开发新人培训系列](http://rapheal.sinaapp.com/)

* * *

<div class="md-section-divider">&nbsp;</div>

### URL详解

一个示例URL

    http://www.mywebsite.com/sj/test;id=8079?name=sviergn&amp;x=true#stuff

    Schema: http
    host: www.mywebsite.com
    path: /sj/test
    URL params: id=8079
    Query String: name=sviergn&amp;x=true
    Anchor: stuff

*   `scheme`：指定低层使用的协议(例如：`http`,&nbsp;`https`,&nbsp;`ftp`)
*   `host`：`HTTP`服务器的`IP`地址或者域名
*   `port#`：`HTTP`服务器的默认端口是`80`，这种情况下端口号可以省略。如果使用了别的端口，必须指明，例如`http://www.mywebsite.com:8080/`
*   `path`：访问资源的路径
*   `url-params`
*   `query-string`：发送给`http`服务器的数据
*   `anchor`：锚

* * *

<div class="md-section-divider">&nbsp;</div>

### 无状态的协议

`http`协议是无状态的：

> 同一个客户端的这次请求和上次请求是没有对应关系，对http服务器来说，它并不知道这两个请求来自同一个客户端。

解决方法：`Cookie`机制来维护状态

既然Http协议是无状态的，那么`Connection:keep-alive`&nbsp;又是怎样一回事？

> 无状态是指协议对于事务处理没有记忆能力，服务器不知道客户端是什么状态。从另一方面讲，打开一个服务器上的网页和你之前打开这个服务器上的网页之间没有任何联系。

* * *

<div class="md-section-divider">&nbsp;</div>

### `http`消息结构

1.  `Request`&nbsp;消息的结构：三部分

> 第一部分叫`Request line`（请求行）， 第二部分叫`http header`, 第三部分是`body`
> 
>     *   请求行：包括`http`请求的种类，请求资源的路径，`http`协议版本
>     *   `http header`：`http`头部信息
>     *   `body`：发送给服务器的`query`信息&nbsp;
> 当使用的是"`GET`" 方法的时候，`body`是为空的（`GET`只能读取服务器上的信息，`post`能写入）&nbsp;
> 
>             1.  `<span class="pln">GET <span class="pun">/<span class="pln">hope<span class="pun">/<span class="pln"> HTTP<span class="pun">/<span class="lit">1.1<span class="pln">   <span class="com">//---请求行</span></span></span></span></span></span></span></span></span>`
>         2.  `<span class="typ">Host<span class="pun">:<span class="pln"> ce<span class="pun">.<span class="pln">sysu<span class="pun">.<span class="pln">edu<span class="pun">.<span class="pln">cn</span></span></span></span></span></span></span></span></span>`
>         3.  `<span class="typ">Accept<span class="pun">:<span class="pln"> <span class="pun">*<span class="com">/*</span></span></span></span></span>`
>         4.  `<span class="com">Accept-Encoding: gzip, deflate, sdch</span>`
>         5.  `<span class="com">Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.6</span>`
>         6.  `<span class="com">Cache-Control: max-age=0</span>`
>         7.  `<span class="com">Cookie:.........</span>`
>         8.  `<span class="com">Referer: http://ce.sysu.edu.cn/hope/</span>`
>         9.  `<span class="com">User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.130 Safari/537.36</span>`
> 10.11.  `<span class="com">---分割线---</span>`
> 12.13.  `<span class="com">POST /hope/ HTTP/1.1   //---请求行</span>`
>         14.  `<span class="com">Host: ce.sysu.edu.cn</span>`
>         15.  `<span class="com">Accept: */<span class="pun">*</span></span>`
>         16.  `<span class="typ">Accept<span class="pun">-<span class="typ">Encoding<span class="pun">:<span class="pln"> gzip<span class="pun">,<span class="pln"> deflate<span class="pun">,<span class="pln"> sdch</span></span></span></span></span></span></span></span></span>`
>         17.  `<span class="typ">Accept<span class="pun">-<span class="typ">Language<span class="pun">:<span class="pln"> zh<span class="pun">-<span class="pln">CN<span class="pun">,<span class="pln">zh<span class="pun">;<span class="pln">q<span class="pun">=<span class="lit">0.8<span class="pun">,<span class="pln">zh<span class="pun">-<span class="pln">TW<span class="pun">;<span class="pln">q<span class="pun">=<span class="lit">0.6</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span>`
>         18.  `<span class="typ">Cache<span class="pun">-<span class="typ">Control<span class="pun">:<span class="pln"> max<span class="pun">-<span class="pln">age<span class="pun">=<span class="lit">0</span></span></span></span></span></span></span></span></span>`
>         19.  `<span class="typ">Cookie<span class="pun">:.........</span></span>`
>         20.  `<span class="typ">Referer<span class="pun">:<span class="pln"> http<span class="pun">:<span class="com">//ce.sysu.edu.cn/hope/</span></span></span></span></span>`
>         21.  `<span class="typ">User<span class="pun">-<span class="typ">Agent<span class="pun">:<span class="pln"> <span class="typ">Mozilla<span class="pun">/<span class="lit">5.0<span class="pln"> <span class="pun">(<span class="typ">Windows<span class="pln"> NT <span class="lit">10.0<span class="pun">;<span class="pln"> WOW64<span class="pun">)<span class="pln"> <span class="typ">AppleWebKit<span class="pun">/<span class="lit">537.36<span class="pln"> <span class="pun">(<span class="pln">KHTML<span class="pun">,<span class="pln"> like <span class="typ">Gecko<span class="pun">)<span class="pln"> <span class="typ">Chrome<span class="pun">/<span class="lit">44.0<span class="pun">.<span class="lit">2403.130<span class="pln"> <span class="typ">Safari<span class="pun">/<span class="lit">537.36</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span>`
> 22.23.  `<span class="pun">...<span class="pln">body<span class="pun">...</span></span></span>`

2.  Response消息的结构

> 也分为三部分，第一部分叫request line, 第二部分叫request header，第三部分是body
> 
>     *   `request line`：协议版本、状态码、`message`
>     *   `request header`：`request`头信息
>     *   `body`：返回的请求资源主体&nbsp;
> 
>         1.  `<span class="pln">HTTP<span class="pun">/<span class="lit">1.1<span class="pln"> <span class="lit">200<span class="pln"> OK</span></span></span></span></span></span>`
>         2.  `<span class="typ">Accept<span class="pun">-<span class="typ">Ranges<span class="pun">:<span class="pln"> bytes</span></span></span></span></span>`
>         3.  `<span class="typ">Content<span class="pun">-<span class="typ">Encoding<span class="pun">:<span class="pln"> gzip</span></span></span></span></span>`
>         4.  `<span class="typ">Content<span class="pun">-<span class="typ">Length<span class="pun">:<span class="pln"> <span class="lit">4533</span></span></span></span></span></span>`
>         5.  `<span class="typ">Content<span class="pun">-<span class="typ">Type<span class="pun">:<span class="pln"> text<span class="pun">/<span class="pln">html</span></span></span></span></span></span></span>`
>         6.  `<span class="typ">Date<span class="pun">:<span class="pln"> <span class="typ">Sun<span class="pun">,<span class="pln"> <span class="lit">06<span class="pln"> <span class="typ">Sep<span class="pln"> <span class="lit">2015<span class="pln"> <span class="lit">07<span class="pun">:<span class="lit">56<span class="pun">:<span class="lit">07<span class="pln"> GMT</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span>`
>         7.  `<span class="typ">ETag<span class="pun">:<span class="pln"> <span class="str">"2788e6e716e7d01:0"</span></span></span></span>`
>         8.  `<span class="typ">Last<span class="pun">-<span class="typ">Modified<span class="pun">:<span class="pln"> <span class="typ">Fri<span class="pun">,<span class="pln"> <span class="lit">04<span class="pln"> <span class="typ">Sep<span class="pln"> <span class="lit">2015<span class="pln"> <span class="lit">13<span class="pun">:<span class="lit">37<span class="pun">:<span class="lit">55<span class="pln"> GMT</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span>`
>         9.  `<span class="typ">Server<span class="pun">:<span class="pln"> <span class="typ">Microsoft<span class="pun">-<span class="pln">IIS<span class="pun">/<span class="lit">7.5</span></span></span></span></span></span></span></span>`
>         10.  `<span class="typ">Vary<span class="pun">:<span class="pln"> <span class="typ">Accept<span class="pun">-<span class="typ">Encoding</span></span></span></span></span></span>`
>         11.  `<span class="pln">X<span class="pun">-<span class="typ">Powered<span class="pun">-<span class="typ">By<span class="pun">:<span class="pln"> ASP<span class="pun">.<span class="pln">NET</span></span></span></span></span></span></span></span></span>`
> 12.13.  `<span class="pun">&lt;!<span class="pln">DOCTYPE html<span class="pun">&gt;</span></span></span>`
>         14.  `<span class="pun">...</span>`
>         15.  `<span class="pun">&lt;&gt;</span>`
>         16.  `<span class="pun">...</span>`

* * *

<div class="md-section-divider">&nbsp;</div>

### `get`&nbsp;和&nbsp;`post`&nbsp;区别

`http`协议定义了很多与服务器交互的方法，最基本的有4种，分别是`GET`,`POST`,`PUT`,`DELETE`。 一个`URL`地址用于描述一个网络上的资源，而`HTTP`中的`GET`,&nbsp;`POST`,&nbsp;`PUT`,&nbsp;`DELETE`&nbsp;就对应着对这个资源的查，改，增，删4个操作。 我们最常见的就是`GET`和`POST`了。`GET`一般用于获取/查询资源信息，而POST一般用于更新资源信息.

1.  `GET`&nbsp;提交的数据会放在`URL`之后，以`?`分割`URL`和传输数据，参数之间以`&amp;`相连，如`EditPosts.aspx?name=test1&amp;id=123456`。`POST`&nbsp;方法是把提交的数据放在`HTTP`包的`Body`中。

2.  `GET`&nbsp;提交的数据大小有限制（因为浏览器对`URL`的长度有限制），而`POST`方法提交的数据没有限制.

3.  `GET`&nbsp;方式需要使用`Request.QueryString`&nbsp;来取得变量的值，而`POST`方式通过`Request.Form`来获取变量的值。

4.  `GET`&nbsp;方式提交数据，会带来安全问题，比如一个登录页面，通过`GET`方式提交数据时，用户名和密码将出现在`URL`上，如果页面可以被缓存或者其他人可以访问这台机器，就可以从历史记录获得该用户的账号和密码.&nbsp;

    [HTTP请求的Get与Post](https://www.zybuluo.com/yangfch3/note/123476)

* * *

<div class="md-section-divider">&nbsp;</div>

### 状态码

`Response`&nbsp;消息中的第一行叫做状态行，由`HTTP`协议版本号，&nbsp;状态码，&nbsp;状态消息&nbsp;三部分组成。

状态码用来告诉`HTTP`客户端，`HTTP`服务器是否产生了预期的`Response`.

`HTTP/1.1`中定义了 5 类状态码。

状态码由三位数字组成，第一个数字定义了响应的类别

*   `1XX`&nbsp;提示信息 - 表示请求已被成功接收，继续处理
*   `2XX`&nbsp;成功 - 表示请求已被成功接收，理解，接受
*   `3XX`&nbsp;重定向 - 要完成请求必须进行更进一步的处理
*   `4XX`&nbsp;客户端错误 - 请求有语法错误或请求无法实现
*   `5XX`&nbsp;服务器端错误 - 服务器未能实现合法的请求

    1.  `200 OK`&nbsp;
请求被成功地完成，所请求的资源发送回客户端
    2.  `302 Found`&nbsp;
重定向，新的`URL`会在`response`中的`Location`中返回，浏览器将会使用新的`URL`发出新的`Request`
    3.  `304 Not Modified`&nbsp;
文档已经被缓存，直接从缓存调用
    4.  `400 Bad Request`&nbsp;
客户端请求与语法错误，不能被服务器所理解&nbsp;
`403 Forbidden`&nbsp;
服务器收到请求，但是拒绝提供服务&nbsp;
`404 Not Found`&nbsp;
请求资源不存在
    5.  `500 Internal Server Error`&nbsp;
服务器发生了不可预期的错误&nbsp;
`503 Server Unavailable`&nbsp;
服务器当前不能处理客户端的请求，一段时间后可能恢复正常

* * *

<div class="md-section-divider">&nbsp;</div>

### http reauest header

`http`&nbsp;请求头包括很多键值对，这些键值对有什么意义与作用？如何根据功能为他们分一下组呢？

1.  `cache`&nbsp;头域

    *   `If-Modified-Since`&nbsp;
用法：`If-Modified-Since: Thu, 09 Feb 2012 09:07:57 GMT`

    把浏览器端缓存页面的最后修改时间发送到服务器去，服务器会把这个时间与服务器上实际文件的最后修改时间进行对比。如果时间一致，那么返回304，客户端就直接使用本地缓存文件。如果时间不一致，就会返回200和新的文件内容。客户端接到之后，会丢弃旧文件，把新文件缓存起来，并显示在浏览器中。&nbsp;

        *   `If-None-Match`&nbsp;
用法：`If-None-Match: "03f2b33c0bfcc1:0"`

    `If-None-Match`和`ETag`一起工作，工作原理是在`HTTP Response`中添加`ETag`信息。 当用户再次请求该资源时，将在`HTTP Request`&nbsp;中加入`If-None-Match`信息(`ETag`的值)。如果服务器验证资源的`ETag`没有改变（该资源没有更新），将返回一个`304`状态告诉客户端使用本地缓存文件。否则将返回`200`状态和新的资源和`Etag`. 使用这样的机制将提高网站的性能&nbsp;

        *   `Pragma`：`Pragma: no-cache`&nbsp;
`Pargma`只有一个用法， 例如：&nbsp;`Pragma: no-cache`

    作用： 防止页面被缓存， 在`HTTP/1.1`版本中，它和`Cache-Control:no-cache`作用一模一样&nbsp;

        *   `Cache-Control`&nbsp;
用法：

            *   `Cache-Control:Public`&nbsp;可以被任何缓存所缓存（）
        *   `Cache-Control:Private`&nbsp;内容只缓存到私有缓存中
        *   `Cache-Control:no-cache`&nbsp;所有内容都不会被缓存

    作用：用来指定`Response-Request`遵循的缓存机制

2.  `Client`&nbsp;头域

    *   `Accept`&nbsp;
用法：`Accept: */*`，`Accept: text/html`

    作用： 浏览器端可以接受的媒体类型；&nbsp;
`Accept: */*`&nbsp;代表浏览器可以处理所有回发的类型，(一般浏览器发给服务器都是发这个）&nbsp;
`Accept: text/html`&nbsp;代表浏览器可以接受服务器回发的类型为&nbsp;`text/html`&nbsp;；如果服务器无法返回`text/html`类型的数据，服务器应该返回一个`406`错误(`non acceptable`)&nbsp;

        *   `Accept-Encoding`&nbsp;
用法：`Accept-Encoding: gzip, deflate`

    作用： 浏览器申明自己接收的文件编码方法，通常指定压缩方法，是否支持压缩，支持什么压缩方法（`gzip`，`deflate`），（注意：这不是指字符编码）&nbsp;

        *   `Accept-Language`&nbsp;
用法：`Accept-Language: en-us`

    作用： 浏览器申明自己接收的语言。&nbsp;

        语言跟字符集的区别：中文是语言，中文有多种字符集，比如`big5`，`gb2312`，`gbk`等等；&nbsp;

        *   `User-Agent`&nbsp;
用法：&nbsp;`User-Agent: Mozilla/4.0......`

    作用：告诉`HTTP`服务器， 客户端使用的操作系统和浏览器的名称和版本.&nbsp;

        *   `Accept-Charset`&nbsp;
用法：`Accept-Charset：utf-8`

    作用：浏览器申明自己接收的字符集，这就是本文前面介绍的各种字符集和字符编码，如gb2312，utf-8（通常我们说Charset包括了相应的字符编码方案）&nbsp;

3.  `Cookie/Login`&nbsp;头域

    *   `Cookie`

            1.  `<span class="typ">Cookie<span class="pun">:<span class="pln"> bdshare_firstime<span class="pun">=<span class="lit">1439081296143<span class="pun">;<span class="pln"> ASP<span class="pun">.<span class="pln">NET_SessionId<span class="pun">=<span class="pln">rcqayd4ufldcke0wkbm1vhxb<span class="pun">;<span class="pln"> pgv_pvi<span class="pun">=<span class="lit">7361416192<span class="pun">;<span class="pln"> pgv_si<span class="pun">=<span class="pln">s6686106624<span class="pun">;<span class="pln"> ce<span class="pun">.<span class="pln">sysu<span class="pun">.<span class="pln">edu<span class="pun">.<span class="pln">cn80<span class="pun">.<span class="pln">ASPXAUTH<span class="pun">=<span class="lit">9E099592DD5A414BEECD8CF43CFC71664</span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span></span>`

    作用：&nbsp;最重要的header, 将`cookie`的值发送给`HTTP`&nbsp;服务器

4.  `Entity`&nbsp;头域

    *   `Content-Length`&nbsp;
用法：`Content-Length: 38`

    作用：发送给HTTP服务器数据的长度。&nbsp;

        *   `Content-Type`&nbsp;
用法：`Content-Type: application/x-www-form-urlencoded`

    不常出现，一般出现在`response`头部，用于指定数据文件类型&nbsp;

5.  `Miscellaneous`&nbsp;头域

    *   `Referer`&nbsp;
用法：`Referer: http://ce.sysu.edu.cn/hope/`

    作用：提供了`Request`的上下文信息的服务器，告诉服务器我是从哪个链接过来的，比如从我主页上链接到一个朋友那里，他的服务器就能够从`HTTP Referer`中统计出每天有多少用户点击我主页上的链接访问他的网站。&nbsp;

6.  `Transport`&nbsp;头域

    *   `Connection`&nbsp;
`Connection: keep-alive`： 当一个网页打开完成后，客户端和服务器之间用于传输HTTP数据的TCP连接不会关闭，如果客户端再次访问这个服务器上的网页，会继续使用这一条已经建立的连接

    `Connection: close`： 代表一个`Request`完成后，客户端和服务器之间用于传输`HTTP`数据的`TCP`连接会关闭， 当客户端再次发送`Request`，需要重新建立`TCP`连接&nbsp;

        *   `Host`&nbsp;
用法：`Host: ce.sysu.edu.cn`

    作用: 请求报头域主要用于指定被请求资源的`Internet`主机和端口号（默认80），它通常从`HTTP URL`中提取出来的
<div class="md-section-divider">&nbsp;</div>

* * *

<div class="md-section-divider">&nbsp;</div>

### HTTP Response header

1.  `Cache`&nbsp;头域

    *   `Date`&nbsp;
用法：`Date: Sat, 11 Feb 2012 11:35:14 GMT`

    作用: 生成消息的具体时间和日期&nbsp;

        *   `Expires`&nbsp;
用法：`Expires: Tue, 08 Feb 2022 11:35:14 GMT`&nbsp;
作用: 浏览器会在指定过期时间内使用本地缓存&nbsp;

        *   `Vary`&nbsp;
用法：Vary: Accept-Encoding&nbsp;

2.  `Cookie/Login`&nbsp;头域

    *   `P3P`&nbsp;
用法：&nbsp;
`P3P: CP=CURa ADMa DEVa PSAo PSDo OUR BUS UNI PUR INT DEM STA PRE COM NAV OTC NOI DSP COR`

    作用: 用于跨域设置Cookie, 这样可以解决`iframe`跨域访问`cookie`的问题&nbsp;

        *   `Set-Cookie`&nbsp;
用法：&nbsp;
`Set-Cookie: sc=4c31523a; path=/; domain=.acookie.taobao.com`

    作用：非常重要的`header`, 用于把`cookie`&nbsp;发送到客户端浏览器， 每一个写入`cookie`都会生成一个`Set-Cookie`.

3.  `Entity`&nbsp;头域

    *   `ETag`&nbsp;
用法：`ETag: "03f2b33c0bfcc1:0"`

    作用: 和`request header`的`If-None-Match`&nbsp;配合使用&nbsp;

        *   `Last-Modified`&nbsp;
用法：`Last-Modified: Wed, 21 Dec 2011 09:09:10 GMT`

    作用：用于指示资源的最后修改日期和时间。（实例请看上节的`If-Modified-Since`的实例）&nbsp;

        *   `Content-Type`&nbsp;
用法：

            *   Content-Type: text/html; charset=utf-8
        *   Content-Type:text/html;charset=GB2312
        *   Content-Type: image/jpeg

    作用：WEB服务器告诉浏览器自己响应的对象的类型和字符集&nbsp;

        *   Content-Encoding&nbsp;
用法：`Content-Encoding：gzip`

    作用：WEB服务器表明自己使用了什么压缩方法（`gzip`，`deflate`）压缩响应中的对象。&nbsp;

        *   `Content-Language`&nbsp;
用法：&nbsp;`Content-Language:da`

    WEB服务器告诉浏览器自己响应的对象的语言

4.  `Miscellaneous`&nbsp;头域

    *   `Server`&nbsp;
用法：`Server: Microsoft-IIS/7.5`

    作用：指明HTTP服务器的软件信息&nbsp;

        *   `X-AspNet-Version`&nbsp;
用法：`X-AspNet-Version: 4.0.30319`

    作用：如果网站是用`ASP.NET`开发的，这个`header`用来表示`ASP.NET`的版本&nbsp;

        *   X-Powered-By&nbsp;
用法：`X-Powered-By: ASP.NET`

    作用：表示网站是用什么技术开发的&nbsp;

5.  `Transport`头域

    *   `Connection`&nbsp;
用法与作用：&nbsp;

            *   `Connection: keep-alive`：当一个网页打开完成后，客户端和服务器之间用于传输HTTP数据的TCP连接不会关闭，如果客户端再次访问这个服务器上的网页，会继续使用这一条已经建立的连接
        *   `Connection: close`：代表一个Request完成后，客户端和服务器之间用于传输HTTP数据的TCP连接会关闭， 当客户端再次发送Request，需要重新建立TCP连接

6.  Location头域

    *   Location&nbsp;
用法：`Location：http://ce.sysu.edu.cn/hope/`&nbsp;
作用： 用于重定向一个新的位置， 包含新的`URL`地址</div>
<div class="remark-icons">
<div class="remark-icon unselectable remark-icon-empty" data-anchor-id="1xa3"><span class="icon-stack"><span class="glyph-comment"><span class="remark-count">+</span></span></span></div>

</div>

</div>
<div class="in-page-preview-buttons in-page-preview-buttons-full-reader">&nbsp;</div>
<div id="reader-full-toolbar" class="reader-full-toolbar-shown">&nbsp;</div>

