---
title: 跨平台 IPC 通信框架 Ploto SDK 实现原理
subtitle: "跨平台 IPC 通信框架 Ploto SDK 实现原理"
tags: ["SDK", "ploto", "IPC", "framework", "modular", "模块化", "可测试性", "可维护性", "可扩展性", "Inter-Process Communication"]
categories: ["extension", "modular"]
header-img: "https://images.unsplash.com/photo-1532255864546-c093fd3786bc?q=80&w=3870&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
centercrop: false
hidden: false
copyright: true
date: 2022-06-10 17:44:00
---


# 跨平台 IPC 通信框架 Ploto SDK 实现原理

> 面对在 Windows、Mac、Linux 等平台上 IPC 通信的差异性，我们在项目中通过 Ploto 跨平台解决方案，磨平了各个平台进程间通信的底层实现差异，降低了各平台之间的技术沟通成本，让开发者更聚焦在业务的设计和开发上。这次，我们来聊聊 Ploto 的整体设计方案和设计理念。

## 1. 背景

工作中开发的 App 实际中会启动不少的进程以提供各种服务，而不同进程间的通信也较为频繁和繁琐。尤其是 App 需要全平台支持（包括 Windows、Mac、Linux、小程序、Android、iOS 等），由于各平台各系统的差异性，各平台使用的 IPC 通信的方式区别比较大，在方案设计等过程中很难设计并保持统一的 IPC 通信协议和通信过程中调用的链路和流程，这进一步对统一各平台整体的技术架构造成了不小的阻碍。同样在方案评审、Code Review 等过程中，跨端进行评审的时候也大大影响了评审的效率，经常无法聚焦到真正的业务。久而久之，各端在架构设计和实现上面差别会越来越大，整个应用的可维护性也越来越低。

## 2. 解决方案

对此，我们的目标是能够通过一种手段尽可能减少各平台的差异化，甚至可以忽略掉差异化而导致的各种技术细节，把真正的关注点回归到业务本身上面，在应用开发上更加侧重业务来进行方案和架构的设计，因此这个设计的过程和成果应该是脱离（或者说是无需关心）平台化存在的差异的，当然 “脱离” 的前提是要保证最终的设计方案在各平台中能够低成本真正的可实现、可落地。因此针对一系列不同领域或者场景的问题，我们需要有一系列对应的用来磨平差异化的稳定的解决方案。
而在 “进程间通信” 这个场景，我们通过 Ploto 来尝试解决了这个问题。


**Ploto 优势**：

- **简单易用**，两个进程的应用接入 Ploto 之后，只需简单配置就能建立连接，并进行双向通信（全双工）
- **代码清晰**，消息发送接收等控制代码及业务代码的关注点实现分离
- **扩展性强**，支持各种底层通信协议的扩展，并且能够一键无缝切换
- **安全性强**，支持通过简单配置实现传输过程中的数据加密，并支持任意的加密方式
- **跨平台**，支持 Windows、Mac、Linux、Android 等各平台，几乎消除各平台进程间通信差异

### 2.1 如何使用

#### 2.1.1 初始化引擎

##### 2.1.1.1 服务端进程

首先在服务端进程，通过以下方式创建 Ploto 引擎，并进行常用的配置：

```cpp
// 创建 ServerEngine，这里选用基于 Socket 实现的 PlotoSocketServerEngine（需要设置当前 engine 唯一别名和 socket 端口号）
std::shared_ptr<PlotoSocketServerEngine> engine(new PlotoSocketServerEngine("demo_server", 27131));

// 设置请求拦截器，用于添加通用请求参数
engine->AddRequestInterceptor(std::make_shared<CommonParamsRequestInterceptor>());
// 设置消息（序列化之后）发送前的拦截器，用于对待发送的数据在传输过程中进行自定义的方式加密
engine->AddMessageSendSerializedInterceptor(std::make_shared<EncryptMessageInterceptor>());
// 设置消息（反序列化之前）接收后的拦截器，用户对接收到的数据进行自定义方式进行解密
engine->AddMessageReceiveSerializedInterceptor(std::make_shared<DecryptMessageInterceptor>());

// 设置当前 ServerEngine 支持处理哪些客户端发送过来的请求
// 参数一是该类请求的唯一 target；参数二是对应的处理请求的 Controller
engine->RegisterRequestController("GetLoginInfo", std::make_shared<GetLoginInfoController>());

// 对 Engine 进行初始化
engine->Initialize();
```

##### 2.1.1.2 客户端进程

同样，在客户端进程中，通过以下方式创建 Ploto 引擎，并进行常用的配置：

```cpp
// 创建 ClientEngine，这里选用基于 Socket 实现的 PlotoSocketClientEngine（需要设置当前 engine 唯一别名和 socket 端口号）
std::shared_ptr<PlotoSocketClientEngine> engine(new PlotoSocketClientEngine("demo_client", 27131));

// 设置请求拦截器，用于添加通用请求参数
engine->AddRequestInterceptor(std::make_shared<CommonParamsRequestInterceptor>());
// 设置消息（序列化之后）发送前的拦截器，用于对待发送的数据在传输过程中进行自定义的方式加密
engine->AddMessageSendSerializedInterceptor(std::make_shared<EncryptMessageInterceptor>());
// 设置消息（反序列化之前）接收后的拦截器，用户对接收到的数据进行自定义方式进行解密
engine->AddMessageReceiveSerializedInterceptor(std::make_shared<DecryptMessageInterceptor>());

// 设置当前 ServerEngine 支持处理哪些客户端发送过来的请求
// 参数一是该类请求的唯一 target；参数二是对应的处理请求的 Controller
engine->RegisterRequestController("ping", std::make_shared<PingpongRequestController>());
engine->RegisterRequestController("MockTimeout", std::make_shared<MockTimeoutController>());

// 对 Engine 进行初始化
engine->Initialize();
```

以上客户端和服务端两个进程，都创建了基于 Socket 实现的 PlotoEngine（`PlotoSocketServerEngine` 和 `PlotoSocketClientEngine`），并对该 Engine 设置了请求通用参数的拦截器，同时通过拦截器来对所有类型消息（包括 Request / Response 及其它扩展类型的消息）进行加密和解密，确保通信过程中使用密文进行传输。

另外，因为客户端和服务端两个进程都需要主动向另一个进程发送消息（每个端理论上即是客户端又是服务端），所以两端都需要在初始化前配置当前 Engine 支持处理的所有请求，通过 Controller 来进行处理并返回结果，通过 `RegisterRequestController` 函数来进行注册。
最后，调用 Engine 的 `Initialize()` 函数进行初始化。

#### 2.1.2 发送请求

因为一旦建立连接之后 Ploto 支持双向通行，即客户端可以发送请求给服务端，服务端也可以发送请求给客户端，这里以客户端发送请求给服务端为例（反过来代码几乎没什么区别）。

```cpp
// 通过 Engine 来构造一个 Request 对象
std::shared_ptr<Request> request = engine->CreateRequest();
// 给 request 设置 target（target 相当于 mapping，服务端会通过这个 target 来映射到对应的请求处理器）
request->SetTarget("GetLoginInfo");
// 给 request 设置参数
request->AddParam("userId", "77131");
// 给 request 设置 header
request->AddHeader("header1", "1a2s3a4sdf");
request->AddHeader("header2", "1a2s3a4s5df2");
// 给 request 设置结果回调函数 lambda
request->SetCallback([](const std::shared_ptr<const Response> response) {
    _ploto::_log::I("[GetLoginInfo]response callback, msg: " + response->GetMsg() + ", data: " + response->GetData());
});
// 通过 Engine 的 Send 方法发送请求
engine->Send(request);
```

客户端首先通过使用的 Engine 来构造一个请求对象 `request`，并设置它的 target，target 相当于 mapping，服务端会通过这个 target 来映射到对应的处理器来处理这个请求。并设置参数（可选）、Header（可选）等信息，设置请求的结果回调。最后调用 Engine 的 `Send` 函数发送。
服务端响应之后 callback 会收到回调，并返回 response。

#### 2.1.3 处理请求

继续上面的案例，客户端发出请求（`target` 为 “GetLoginInfo”，即获取用户登录信息）之后，服务端需要对客户端这个请求进行处理和响应，所以服务端需要做两件事情：
第一，服务端需要在 Engine 初始化前注册对应 target（“GetLoginInfo”） 的处理器（`Controller`）：

```cpp
engine->RegisterRequestController("GetLoginInfo", std::make_shared<GetLoginInfoController>());
```

如上，通过 `RegisterRequestController` 函数来在 Engine 上进行注册，参数一为 target，参数二为对应 target 的 Controller。
第二，实现对应 target 的 Controller，如下：

```cpp
class GetLoginInfoController : public PlotoRequestDispatchController {
   public:
    GetLoginInfoController() {
    }
    ~GetLoginInfoController() {
        // do nothing
    }

    virtual std::shared_ptr<Response> DoRequest(std::shared_ptr<const Request> request) {
        _ploto::_log::I("[GetLoginInfoController]DoRequest...");

        // 从 request 中获取参数
        std::string userId = request->GetParam("userId");
        _ploto::_log::I("[GetLoginInfoController]DoRequest, get userId param from request: " + userId);
        // 从 request 中获取 header
        auto header1 = request->GetHeader("header1");
        _ploto::_log::I("[GetLoginInfoController]DoRequest, get header1 header from request: " + header1);

        // 处理过程...
        // 创建 Response
        std::shared_ptr<Response> response = std::make_shared<Response>(request->GetRequestId(), _ploto::_respCode::SUCCESS);
        // 设置返回结果
        response->SetData(
            "{ \
            \"loginInfo\": { \
                \"user\": { \
                    \"userId\": 51231, \
                    \"username\": \"张三\" \
                }, \
                \"token\": \"e86ee44d7d274ac08b62f7a6e2f6efa9\" \
            } \
        }");
        // 返回数据给客户端
        return response;
    }
};
```

如上，处理器需要继承 PlotoRequestDispatchController，并实现对应的 DoRequest 函数返回处理结果 Response。

## 3. 整体设计


![ipc_framework_ploto_img_01](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/19226d87-f4b7-4b69-a93c-59988011dc98)

底层抽象逻辑的设计是非常简单的，由 Ploto 对 Application（Process）提供 IPC 能力，而 Ploto 的 Engine 负责协调所有 IPC 通信的内部模块及消息的流转，Cable 主要负责与另一进程建立 “连接”，发送和接收消息。

### 3.1 Engine

一般情况下可以这么理解，一个 Engine 对象代表一个 Ploto 实例。针对不同的 IPC 底层通信协议的实现，Engine 的实现会有一些差异性，但是高度抽象的，对于调用者来说提供的接口是一致的。

Engine 主要实现 IPC 通信过程中的核心业务控制流程，主要的功能：
- 接收相关的 Ploto 配置，如拦截器配置、注册请求处理器等
- 对外暴露发送消息和接收消息的接口
- 协调内部通信过程中各个模块消息流转的逻辑

![ipc_framework_ploto_img_02](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/4bdee21e-34f8-4f40-b0ac-ff43b8a8d224)

**接收相关的 Ploto 配置**

在创建 Engine 后、初始化 Engine 之前，允许用户设置一些常规的配置，比如：

- 增加请求拦截器：通过增加请求拦截器，我们可以在消息经过一些流转周期函数时插入自定义的逻辑，如：对请求增加通用参数，对请求进行加密，对请求增加自定义的鉴权逻辑 等等。
- 增加响应拦截器：与请求拦截器类似，我们可以在消息经过的一些流转周期函数时插入自定义的逻辑，如：对响应的数据进行解密 等等。
- 注册请求处理器：通过 `RegisterRequestController` 函数可以注册当前 Ploto 支持的请求及对应的 Controller，只有通过该函数注册过的请求类型，对方进程发送请求消息过来时，当前 Ploto 才能路由和执行相应的处理器。否则对方进程会收到 “请求对应的 Controller 找不到” 的 Response

**对外暴露发送消息和接收消息的接口**

Engine 对外暴露了发送消息和接收消息的接口，如下：

```cpp
// 异步发送消息
virtual void Send(std::shared_ptr<Message> const message) final
// 同步发送消息
virtual std::shared_ptr< const Response> SendSync(std::shared_ptr<Request> const message) override
```

发送的函数分为 **异步** 和 **同步** 两种，Ploto 对内部的各种异常情况做了处理，所以发送的过程是可靠的，在内部错误、超时等等各种异常场景下，确保会始终会返回 Response。同步会阻塞当前线程（如果发送的消息是 Request，则最长的阻塞时间为 Request 设置的超时时间，默认为 5 s），推荐使用 异步 的方式进行发送。

**协调内部通信过程中各个模块消息流转的逻辑**
Engine 本身实现了 `OnMessageMoveListener` 接口，它关心每个消息在整个流转周期内的事件，通过这些周期的事件函数，Engine 会对每个事件进行分发到每个对应的 `Dispatcher`（下文会讲到），根据事件的不同阶段，每个 Dispathcer 会实现相应的内部逻辑。

![ipc_framework_ploto_img_03](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/9e9db64a-0964-4fa1-ad43-73e0a6f02d90)

因此可以说，Engine 实现了整个 Ploto 运行的控制逻辑，而具体的通信能力则是由 Cable 提供。

### 3.2 Cable

Cable，意为 “电缆”，主要负责底层与另一进程进行通信，顾名思义相当于一个 “连接”，这个 “连接” 的存在形式主要取决于 IPC 底层实现的通信协议，可能是管道、消息队列、共享内存、XPC，也有可能是一个 TCP 连接（如 Socket），这里的连接表示的只是一种 “连接” 的关系和形态，不一定是真实存在的一个 Connection。

Cable 中实现了真正的发送和接收消息的逻辑。不同的 IPC 底层通信协议的 Cable 实现各不相同，有很大的差异，但是与 Engine 一样，Cable 也具有高度的抽象，隐藏了内部的实现细节，对于外部来说所有的 Cable 都具有统一的接口。

```cpp
virtual void Send(std::shared_ptr<Message> const message) final
void SetOnPlotoCableListener(std::weak_ptr<OnMessageMoveListener< SerializeType > > onMessageMoveListener);
```

一般情况下可以这么理解，一个 PlotoEngine 对象代表一个 Ploto 实例，通过这个 PlotoEngine 可以连接到另一进程的 PlotoEngine，一旦连接之后，两个 PlotoEngine 就可以进行通信了，而此时另一进程的 PlotoEngine 对象在当前 PlotoEngine 中是作为一个 PlotoCable 对象存在。

![ipc_framework_ploto_img_04](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/cabbb300-9926-40ac-afb6-8d41d05ffacd)

如上图，在 PlotoEngine A 跟 PlotoEngine B 进行通信时，PlotoEngine A 会在连接（这里的 “连接” 是抽象的概念，具体的连接过程需要依赖具体底层的实现）成功之后创建 PlotoCable（也就是上图中的 “PlotoCable B”），通过这个 PlotoCable B 只能与 PlotoEngine B 进行通信。同样连接成功之后 Engine B 也会创建 Cable（也就是上图中的 “PlotoCable A”），通过这个 PlotoCable A 也只能跟 PlotoEngine A 进行通信。

当然，一个 PlotoEngine 有可能会创建多个 PlotoCable，这时这个 PlotoEngine 可以选择对应的 PlotoCable 来给对应的 PlotoEngine 发送消息。

### 3.3 Message

Message 为 Ploto 通信过程中传输的最小结构单元，所有支持的消息类型都需要继承自 Message 类，并通过指定的序列化器（`MessageSerializer`）对数据进行序列化和反序列化。

目前 Ploto 内部默认实现了基本的 **请求响应模型**，实现了 `Request` 和 `Response` 两种类型的 Message：

- **Request**：发送 Request 消息可以触发一个通信请求，对方进程的 Ploto 可以通过该 Request 中的 target 自动路由到相应的 Controller，在该 Controller 中可以通过 Request 来获取请求参数完成处理逻辑
- **Response**：对方进程处理完成请求、请求超时等时机，需要返回一个 Response 对象，该对象需要返回处理的结果

![ipc_framework_ploto_img_05](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/03088240-5d2e-4e80-83d8-3912101b0761)

#### 3.3.1 消息的流转周期函数

消息（Message）从一个进程被发送开始，到被另一个进程接收，整个过程具有自己的流转周期函数。
初略来讲，一个消息被发送，首先会被对应的 **消息序列化器**（`MessageSerializer`） 进行序列化（具体序列化的方式及序列化之后的数据结构可自定义），然后通过 Cable 实现消息的发送。另一进程接收到消息之后，通过同样的消息序列化器 进行反序列化（同样可以根据不同的底层通信协议进行自定义）成对象。也就是说消息的转发流程与 Ploto 中的消息流转周期函数是对应的，如下图：

![ipc_framework_ploto_img_06](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/1f86d46e-7174-45ad-bb42-fad935d792e7)


在上面的发送过程中，Ploto 会在对应的阶段细分不同的消息流转周期函数，Ploto 内部对消息进行业务逻辑上的处理也是需要依赖于这些流转周期函数。如下图：

![ipc_framework_ploto_img_07](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/988e44a5-69f2-4621-aa60-b213155ec942)

如上图，以上 10 个函数，其中 `OnSendMessage` 和 `OnReceiveMessage` 两个函数用于 Cable 内部真正执行发送和接收消息，细节隐藏在 Cable 内部，不对外暴露，所以余下 8 个为流转周期函数，**按照调用的顺序**如下：
- `OnPreSendMessage`：在消息发送前时回调，此时的 Message 还是一个对象，还没有被序列化
- `OnPreSendMessageSerialized`：在消息发送前回调，此时的 Message 已经被序列化，具体的数据结构取决于使用的序列化器
- `OnPostSendMessageSerialized`：在消息发送后回调，此时参数中会带有序列化和未序列化两种状态的 Message
- `OnPostSendMessage`：在消息发送后回调，此时参数中会携带序列化前的 Message 对象和发送的结果
- `OnPreReceiveMessageSerialized`：在消息接收前回调，此时的消息还是序列化之后的对象
- `OnPreReceiveMessage`：在消息接收前回调，此时接收的消息已经被反序列化
- `OnPostReceiveMessage`：在消息接收后回调，此时接收的消息已经被反序列化
- `OnPostReceiveMessageSerialized`：在消息接收后回调，此时参数中会带有序列化和未序列化两种状态的 Message

在消息流转周期函数中，我们可以针对不同的 Message 类型进行不同的业务处理。

如针对 `Request` 类型的消息：

- 在发送 `Request` 类型的消息前（`OnPreSendMessage`）和 发送消息后（`OnPostSendMessage`）两个流转周期函数中处理请求的缓存和超时的处理。
- 在接收 `Request` 类型的消息后（`OnPostReceiveMessage`）流转周期函数中处理请求路由转发和 Controller 执行等逻辑。
- 在发送 `Request` 类型的消息前（`OnPreSendMessage` 和 `OnPreSendMessageSerialized`）实现请求发送拦截器，如增加通用参数，加密 Request 等
- 在接收 `Request` 类型的消息后（`OnPreReceiveMessageSerialized`）实现请求接收拦截器，如解密 Request 等

针对 `Response` 类型的消息一样也有类似消息流转周期函数中的实现。

#### 3.3.2 消息的标准化协议

所有消息（包括自定义消息）都需要继承自 Message，Message 的数据结构如下：

```cpp
class Message {
   private:
    //---------- 需要序列化 ----------//
    /**
     * 创建当前 Message 的 point name
     */
    std::string fromPointName_;
    /**
     * @brief 消息类型
     */
    message::Type type_;
}
```

如上，Message 中 `fromPointName_` 表示该 Message 创建自哪个 PlotoEngine，`type_` 表示该 Message 的类型，可能是 `Request` 类型、`Response` 类型或者其它扩展的类型。

除了以上这些字段之外，其它数据结构需要具体的扩展类型自由创建，并实现和维护对应的序列化器。

**内置类型 Request**

```cpp
class Request : public Message {
   private:
    //---------- 需要序列化 ----------//
    std::string requestId_;
    std::string target_;
    std::map<std::string, std::string> params_;
    std::map<std::string, std::string> headers_;
    // 请求超时时间
    ploto_int64 timeout_ = 5000;  // millis
    // 请求真正发送时间
    ploto_int64 sendStartTime_ = 0;
    ploto_int64 expiredTime_ = 0;  // 超时过期时间
    // ...
}
```

如上，Request 的标准数据结构中，包括请求参数 `params_`、请求 `header_`、超时时间 `timeout_`、路由标识 `target_` 等基本参数配置。对方 PlotoCable 接收到 request 之后，会通过 `target_` 来路由执行 Controller。

**内置类型 Response**

```cpp
class Response : public Message {
   private:
    std::string requestId_;
    std::string responseId_;
    int code_;
    std::string msg_;
    std::string data_;
}
```

Response 的标准化结构为 结果码 `code_`、结果描述 `msg_`、响应数据 `data_`。

### 3.4 Container 和 Dispatcher

Ploto 的部分核心的业务逻辑功能需要依赖于消息的流转周期函数，PlotoEngine 监听了每个消息的流转周期函数，并作为控制器进行消息流转周期事件的转发和调度。
而真正的转发和调度需要依赖于 `Container` 和 `Dispatcher`，Container 与 Message 的类型相关，Dispatcher 与收发过程相关，不同的消息类型，通过各自的 Container 来组装每种 Dispatcher，最终形成整个转发和调度的网络。如下图：

![ipc_framework_ploto_img_08](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/4b45f04d-283a-4a67-a525-5112ec823ffe)

如上图，每个消息类型需要两个 Dispatcher 来进行分发，一个是消息发送时进行分发，相应函数与消息的发送周期函数对应；一个是消息接收时进行分发，相应函数与消息接收周期函数对应。

> HiddenMessageContainer 是特殊的 Container，其中的 Dispatcher 主要用于处理反序列化前的数据，因为此时的数据尚未反序列化成对象，所以具体的消息类型并不明确。

#### 3.4.1 拦截器的实现

Ploto 基于 Dispatcher 和消息流转周期函数，实现并对外提供了 4 种拦截器：

- **RequestInterceptor**：请求类型的消息拦截器，该拦截器会在请求被发送前，通过 Chain 进行调用，通过这个拦截器可以给所有请求配置一些通用的请求参数、对请求数据进行签名等等。注意，只有请求类型的消息才会进入到该拦截器。
- **ResponseInterceptor**：响应类型的消息拦截器，该拦截器会在请求被接收后马上被回调，通过这个拦截器可以对响应进行一些通用的处理，比如拦截一些特殊的返回 Code，并做出一些特定的处理。注意，只有响应类型的消息才会进入到该拦截器。
- **MessageSendSerializedInterceptor**：消息发送拦截器（消息是序列化后的状态），该拦截器会在消息被发送之后调用，此时消息是序列化之后的数据，所以我们可以通过这个拦截器对请求进行加密等处理。注意：该拦截器不区分消息类型，所有消息都会经过该拦截器
- **MessageReceiveSerializedInterceptor**：消息接收拦截器（消息是序列化后的状态），该拦截器会在消息被接收后调用，所以我们可以通过这个拦截器对消息进行解密等处理。注意：该拦截器不区分消息类型，所有消息都会经过该拦截器

以 **MessageSendSerializedInterceptor** 的实现为例，首先通过 `PlotoEngine::AddMessageSendSerializedInterceptor` 设置拦截器，然后根据消息流转周期函数，请求发送前会进入到 HiddenMessageReceiveDispatcher 中，拦截器会被 push 到 `interceptors_` ，在发送过程中，会进入到流转周期函数（`OnPreReceiveMessageSerialized`），然后通过 `PlotoChain` 来执行所有的 `MessageSendSerializeInterceptor` 拦截器。

#### 3.4.2 请求缓存的实现

Ploto 内部对所有的请求做了缓存，主要作用是缓存当前的请求数据，在拿到请求结果时能够根据对应的请求进行相应的处理，比如把结果通知调用者。请求结果有可能是对方进程返回的响应，也有可能是对方进程没有响应，导致请求超时，还有可能是在 Ploto 底层处理过程中出现异常返回的内部错误。

请求缓存的实现也是基于 Dispatcher 的流转周期函数，跟 PlotoEngine 和 PlotoCable 两者的逻辑也是解耦的，流程如下：

![ipc_framework_ploto_img_09](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/032ddffd-0ad5-4faa-b83c-88905024103b)

在 Ploto SDK 初始化 / 启动时，后台会自动拉起一个线程，定时扫描当前所有请求的当前状态，用于检查是否存在超时的请求，并对超时的请求进行通知和处理。在请求发送时，会进入 `RequestMessageSendDispatcher` 中，在流转周期函数 `OnPreSendMessage` 中把请求加入缓存。PlotoCable 负责发送该请求消息，在 Process B 处理完成并返回 Response 消息后，PlotoCable 会接收到该 Request 对应的响应消息，并通过 PlotoEngine 分发到 `ResponseMessageReceiveDispatcher` 中，在流转周期函数 `OnPostReceiveMessage` 中通过 ContainerOwner 接口通知请求结束，在请求缓存中清除对应的请求并回调给调用方。

#### 2.4.3 请求处理实现

在 PlotoCable 接收到对方进程的 request 类型消息时，PlotoCable 会把消息分发到 `RequestMessageReceiveDispatcher` 中，在流转周期函数 `OnPostReceiveMessage` 中就可以处理这个请求，处理完成之后构建对应的 Response 发送给对方进程。

处理这个请求的方式比较简单，首先检索到对应请求的 Controller，而所有的 Controller 则是在使用者初始化当前 Ploto SDK 时通过 `PlotoEngine::RegisterRequestController` 函数注册进来，匹配的规则是通过 Request 的 `target` 来进行匹配路由。具体流程如下：


## 4. 基于 Socket 的 Ploto 实现

上述整体设计方案理论上支持各种 IPC 底层通信协议，Ploto 提供了基于 Socket TCP 协议的跨平台（支持 Windows / Mac / Linux / Android，同时支持 Electron 版本）实现。

遵从上述的设计理念，我们基于 PlotoEngine 进行了扩展，从 `PlotoEngine` 扩展出 `PlotoServerSocketEngine` 和 `PlotoClientSocketEngine`，PlotoServerSocketEngine 允许与多个 Client 建立连接，而 PlotoClientSocketEngine 只能与一个 Server 进行连接，因此延伸出以下方案设计：

![ipc_framework_ploto_img_10](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/20fad7a1-4c98-4837-b558-1a2018cc1b2d)

### 4.1 PlotoSocketEngine

PlotoSocketServerEngine 的实现，在 OnInitialize 过程中，初始化 socket，绑定指定的端口并进行监听，然后启动 accept 线程，等待客户端的连接。

```cpp
class PlotoSocketServerEngine : public PlotoServerEngine<PlotoSocketClientCable, std::string>,
    public PlotoSocketCableAbnormalStatusListener,
    public std::enable_shared_from_this<PlotoSocketServerEngine> {
public:
    sockaddr_in address_;
    S_SOCKET server_fd_;

    int port_;

    /**
     * @brief accept 线程
     *
     */
    std::shared_ptr<std::thread> acceptThread_;
    std::atomic<bool> acceptThreadQuitFlag_;

public:
    /**
     * @brief 创建 socket server engine
     * 
     * @param port 启动 socket 使用的端口号
     * @param pointName 当前 engine 的 endpoint name。每一个实例都需要对于同一server唯一，用于另一端区分是哪个 engine。
     */
    PlotoSocketServerEngine(const std::string& pointName,int port) :acceptThreadQuitFlag_(false),port_(port),
        PlotoServerEngine(pointName) {
    }
    // ...
    virtual ~PlotoSocketServerEngine() {
        // do nothing
    }
    // ...
    virtual bool RemoveClientCable(std::shared_ptr<PlotoSocketClientCable> clientCable) override;

    virtual void OnPlotoSocketCableAbnormal(std::shared_ptr<PlotoSocketCable> plotoCable, const int& errNum, const std::string& errMsg) override;
    virtual void OnPlotoSocketCableClosed(std::shared_ptr<PlotoSocketCable> plotoCable) override;

protected:
    virtual void OnInitialize() override;
    virtual void OnDestroy() override;
    // ...
};
```

一旦客户端连接成功，PlotoSocketServerEngine 就会在 engine 线程中创建一个对应该客户端的 `PlotoSocketClientCable` 对象，并启动 PlotoSocketClientCable。

PlotoSocketClientEngine 的实现，在 OnInitialize 过程中，通过端口连接到 Server，并且创建 `PlotoSocketServerCable` 对象，并启动 PlotoSocketServerCable。

```cpp
class PlotoSocketClientEngine : public PlotoClientEngine<PlotoSocketServerCable, std::string>,
                                public PlotoSocketCableAbnormalStatusListener,
                                public std::enable_shared_from_this<PlotoSocketClientEngine> {
public:
    /**
     * @brief 创建 socket client engine
     * 
     * @param port 服务端的端口号
     * @param pointName 当前 engine 的 endpoint name。每一个实例都需要对于同一 server 唯一，用于另一端区分是哪个 engine。
     */
    PlotoSocketClientEngine(const std::string &pointName,int port) :PlotoClientEngine(pointName),port_(port){}
    virtual ~PlotoSocketClientEngine(){
        // do nothing
    }

    virtual void OnPlotoSocketCableAbnormal(std::shared_ptr<PlotoSocketCable> plotoCable, const int& errNum, const std::string& errMsg) override;
    virtual void OnPlotoSocketCableClosed(std::shared_ptr<PlotoSocketCable> plotoCable) override;

protected:
    virtual void OnInitialize() override;
    virtual void OnDestroy() override;
    
private:
    sockaddr_in serv_addr_;
    /**
     * @brief 当前连接的 socket 句柄
     * 
     */
    S_SOCKET sock_;
    int port_;
};
```

在创建 PlotoCable 的同时，两个 PlotoEngine 都会监听 PlotoCable 的连接状态，关注异常断开等情况，并进行相应的处理。

### 4.2 PlotoSocketCable

根据上述的设计理念，Cable 真正实现了消息的发送和接收的能力。
PlotoSocketCable 中继承 PlotoCable，需要实现 `OnSend` 函数和对 `OnReceive` 函数的调用。

```cpp
class PlotoSocketCable : public PlotoCable<std::string> {
    public:
    /**
     * @brief cable 状态异常的监听
     * 
     */
    std::weak_ptr<PlotoSocketCableAbnormalStatusListener> plotoSocketCableStatusAbnormalListener_;
    
    private:
    /**
     * @brief 消息接收线程
     * 
     */
    std::shared_ptr<std::thread> receiveThread_;
  

   public:
    /**
     * @brief 当前连接的 socket 句柄
     * 
     */
    S_SOCKET socket_;
    /**
     * @brief 接收线程的退出标志
     * 
     */
    std::atomic<bool> receiveThreadQuitFlag_;

    /**
     * @brief 消息粘包/拆包处理
     * 
     */
    std::shared_ptr<PlotoSocketStickyManager> plotoSocketStickyManager_;

    PlotoSocketCable(std::string pointName,
                     PlotoSocketPointID &cablePointID,
                     std::shared_ptr<MessageSerializer<std::string> > messageSerializer,
                     std::shared_ptr<ILooperThread> sendThread = std::make_shared<LooperThread>())
        :receiveThreadQuitFlag_(false), PlotoCable(pointName, cablePointID, messageSerializer, sendThread) {
        // ...
    }
    virtual ~PlotoSocketCable() {
    }
    virtual void Start(const char * threadName) override;
    virtual void Shutdown() override;
    void SetPlotoSocketCableAbnormalStatusListener(std::weak_ptr<PlotoSocketCableAbnormalStatusListener> listener) {
        plotoSocketCableStatusAbnormalListener_ = listener;
    }
    std::weak_ptr<PlotoSocketCableAbnormalStatusListener> GetPlotoSocketCableAbnormalStatusListener() {
        return plotoSocketCableStatusAbnormalListener_;
    }
    
   protected:
    /**
     * @brief 真正的发送逻辑
     * 
     * @param message 
     * @return const std::shared_ptr<PlotoRet> 
     */
    virtual const std::shared_ptr<PlotoRet> OnSend(const std::shared_ptr<std::string> message) override;
};
```

PlotoSocketCable 会启动一个 Send 线程和一个 Receive 线程，OnSend 和 OnReceive 函数的实现基于标准的 Socket 模型，处理了粘包/拆包等问题，并对各平台进行了适配。

## 5. 可扩展性

### 5.1 底层通信协议可扩展

由于 Ploto 底层是高度抽象的，同时又使用了大量的模板，PlotoEngine / PlotoCable 等各核心组件的接口与具体的通信协议无关，因此 Ploto 也就具备了扩展性，它支持扩展出不同的底层 IPC 通信协议，如在 Android 端可以基于 [Binder](https://developer.android.com/reference/android/os/Binder) 扩展出 PlotoBinderEngine，在 Mac 端可以基于 [XPC](https://developer.apple.com/documentation/xpc) 扩展出 PlotoXPCEngine 等，也可以基于管道、共享内存等传统的 IPC 进行扩展，这样不同的平台或者场景在底层可以使用各自最合适的 IPC 解决方案。


### 5.2 通信消息可扩展

同样，消息的结构及消息的派发处理的流程也都是可扩展的，针对不同的协议，可以使用不同的消息结构（如 Android 的 Parcelable 等），也就是说，除了 Ploto 内置的 Request 和 Response 两种消息类型（虽然这两种消息类型可以基本能够满足常见的使用场景）之外，我们也可以创建自定义的类型，让 Ploto 能够正常发送和接收自定义的消息类型。

那么消息类型的扩展需要哪些步骤？

首先，创建任意的自定义类型的消息，如 PushMessage（可能是代表推送消息类型），表示一个进程主动给另一进程推送的消息。

接着，由于创建的消息是任意的，所以需要对该消息类型实现消息的序列化和反序列化的过程，以便于在消息发送和接收时进行相应的处理，于是需要在对应的 MessageSerializer 中进行实现。

此时，该自定义消息是可以被发送和接收了，但是消息接收之后可能会有相应的处理的逻辑，因此需要在该消息的流转周期函数中实现对应的 Container 和 Dispatcher，在 Dispatcher 中完善该自定义消息的逻辑处理。

所以，消息的可扩展主要体现在两方面，支持扩展消息的类型，以及支持扩展消息类型的流转处理逻辑。

## 6. 跨平台支持程度

目前 Ploto 理论上 5 个平台均支持，其中 Windows 和 Mac 已得到线上的广泛验证，Linux 端还处于内测中，Android 端初步跑通，但还未在实际项目中使用。

|平台|语言版本|发展情况|备注|
|---|---|---|---|
|Windows|`C++`|通过功能性测试、兼容性测试、压测，并在实际线上项目中已正常使用||
|Mac|`Objective-C` 胶水层 & `C++`|通过功能性测试、兼容性测试、压测，并在实际线上项目中已正常使用||
|Linux|1、`C++`<br/>2、`Typescript / Javascript`（Electron）胶水层 & `C++`|通过功能性测试、兼容性测试、压测，并在实际线上项目中已接入验证||
|Android|`Java` 胶水层 & `C++`|初步验证跑通，尚未在实际项目中使用||
|iOS|`Objective-C` & `C++`|理论上支持，但是目前未验证|iOS 由于本身进程管理的限制，仅支持单进程通信，所以目前不作为 Ploto 主要支持的目标平台|

## 7. 尾巴

Ploto 跨平台的解决方案，磨平了各个平台进程间通信的底层实现差异，为进一步统一了各平台的多进程架构的设计提供了基础，为各平台进程间的通信建立了输入和输出的标准，降低了各平台之间的技术沟通成本，让开发者更聚焦在业务的设计和开发上。

除了在客户端使用之外，Ploto 后续还会计划作为 SDK 统一基础开发框架 Extension 的底层能力，实现 Extension 中服务注册中心的跨进程的服务订阅和共享，打破进程的限制。




