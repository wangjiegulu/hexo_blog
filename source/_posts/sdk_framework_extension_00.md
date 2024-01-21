---
title: 全平台 SDK 统一开发框架 Extension 设计理念
subtitle: "全平台 SDK 统一开发框架 Extension 设计理念"
tags: ["SDK", "extension", "framework", "modular", "模块化", "可测试性", "可维护性", "可扩展性", "服务化", "服务注册中心"]
categories: ["extension", "modular"]
header-img: "https://images.unsplash.com/uploads/14123892966835548e7bd/14369636?q=80&w=3870&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
centercrop: false
hidden: false
copyright: true
date: 2020-12-08 13:45:00
---


# 全平台 SDK 统一开发框架 Extension 设计理念

## 什么才是一个好的 SDK 设计

> 注意：这里的 SDK 是指具有一定完整业务逻辑的独立子系统，开发者可以依赖它通过简洁优雅的 API 解决一些特定领域中的复杂问题；如：APM、HttpDNS、URS、Triton 等等；
> 
> 并不包括一系列工具类的简单聚合的 SDK，如 extension、xxxUtil 等等

对于业务方来说，SDK 的稳定性至关重要，如果 SDK 内部出现问题直接会影响到整个业务 app 的稳定性。

那我们可以从哪些方面可以提高 SDK 的稳定性，怎么样才算是一个比较好的 SDK 设计方案？

或者说，要设计一个好的 SDK，需要考虑哪些方面的因素？

## SDK 应该具有可控性

SDK 不应该是一堆堆死板的代码块，而是鲜活的，具有生命力的，可以呈现给外部 sdk 自己当前的状态，内部有自己的状态管理机制。

接入者可以通过 SDK 开放的 API 来控制或者感知 SDK 的生命周期。

SDK 可能包括但不仅限于 `启动`、`运行中`、`暂停`、`关闭` 等等状态，并且对外提供了影响 SDK 生命状态的方法，如：启动 SDK、关闭 SDK 等等。生命周期应该是一个闭环，并且是可轮回的，如：`启动` 之后可以 `关闭`、`关闭` 之后又可以重新 `启动`。

不论是接入方还是 SDK 内部，都可以随时监听当前 SDK 的生命周期变化，进行对应的逻辑处理。

SDK 内部的活动也应该受生命周期的影响。

> 拿 Triton SDK 举例，Triton SDK 是我们内部使用的用于判断移动端当前网络状态的 SDK，它会通过一系列的策略（有可配置的默认策略，也可以让业务方灵活自定义）来判断当前网络是否正常及网络状况的具体级别。

不管是接入方对 SDK 的调用，还是 SDK 内部本身的逻辑执行过程，所有跟 SDK 相关的操作都需要限定当前 SDK 在某种情况下才能有效执行。如果状态有误，则抛出相关的异常或者忽略后面的逻辑及最终的结果，又或者针对具体的异常的场景进行特定的处理；比如：启动过程只能在关闭状态下才能执行；SDK 内部解析请求只能在 SDK 为运行中的状态下才能执行等等。

否则在 SDK 的内部可能会出现无法预知的问题，比如在接入方调用 Triton API 获取当前网络状态时候，SDK 内部执行了缓存的读取和修改，执行网络探测策略，比如通过系统 api 获取当前的网络可达性的策略，通过 APM 的请求数据来判断网络的策略，当 ping 对应的公共服务器策略时候发现用户没有设置合法的公共服务器，导致理论上配置不合法时不应该启动当前的 Triton SDK，或者说应该启动失败，并提示给接入方，但是因为 SDK 内部没有生命周期的概念，导致流程走到策略3的时候才发现不应该执行探测过程，这时因为前面的策略都已经执行，可能会产生脏数据或者引发意料之外的逻辑。

SDK 其实是一个抽象的概念，业务 app 接入 Triton SDK 之后通常会通过 SDK 内部的一个单例模式（但是并不建议这么做）创建一个 `实例`。当创建完之后，才会有一个真正的 Triton SDK 实例产生，之后 app 运行过程中都会使用该 `SDK 实例`（即 `SDKInstance`），而该 `SDKInstance` 中就延展了所有该 SDK 的所有业务逻辑。

一般来说，SDK 开发者都会为当前 SDK 实例维护一个 `isRunning` 的状态，并制定一系列的生命周期方法关联到 `isRunning` 状态，提供给 SDK 开发者使用，这是个一个不错的实践，如下：

```java
/**
 * SDK 启动前回调
 *
 * @param launchMode 启动模式
 */
void onSDKLaunch(SDKLaunchMode launchMode);

/**
 * SDK 启动后回调
 *
 * @param launchMode 启动模式
 */
void onSDKStart(SDKLaunchMode launchMode);

/**
 * SDK 关闭前回调
 *
 * @param launchMode 启动模式
 */
void onSDKStop(SDKLaunchMode launchMode);

/**
 * SDK 关闭后回调
 *
 * @param launchMode 启动模式
 */
void onSDKShutdown(SDKLaunchMode launchMode);
```

但是实际相对复杂的 SDK 中，我们通常会对 SDK 进行一定的架构设计及领域分层，这时 `SDKInstance` 的职责转变为维护了一系列的领域模型及功能模块，这时 `SDKInstance` 中的生命周期方法就不足以满足各个领域的需求。

所以不同的领域对生命周期状态需要有统一的感知和联动，除了一个简单的 `isRunning` 状态之外，还需要为所有领域模块建立一系列统一标准的生命周期方法，在不同领域的各个的生命周期的方法中来明确业务逻辑的规范。这个在后面 `模块化` 设计中再讲。


> 解决方案：SDK 生命周期化

![sdk_framework_extension_img_01](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/476ae882-84fd-4691-9e75-6f0172f1d364)

SDK 生命周期，启动、关闭流程：

![sdk_framework_extension_img_02](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/dca6b95a-3740-4a74-9f15-0dc8bad08fcf)


## SDK 应该具有可配置性

> 模块化架构

对于接入者来说，SDK 应该可以支持一定程度的可定制化。

可定制化的体现之一就是需要 SDK 具有可配置性，不局限于某些配置开关、某些定制化接口的实现等等。

所以，接入方可以通过 SDK 开放的 api 进行不同的配置，不同的配置需要由配置模块进行统一管理，配置模块的主要职责是：

- 创建最终的配置
- 校验所有配置项的合法性
- 初始化所有默认的配置项
- 维护配置，并在 SDK 内部提供当前的所有配置项。

配置模块会在 SDK 启动的时候，会根据用户的设置来生成最终的配置，配置模块相对其它模块比较特殊，它会作为 SDK 所有模块的第一个模块被启动，因为其它模块都需要依赖配置模块所创建和提供的配置项。

需要注意的是，最终生效的配置在 SDK 的整个生命周期中都不可以改动，如果接入方在 SDK 运行中时调用了 SDK 开放的 api 修改了配置，是不能（也是不应该）实时在 SDK 中生效的。

如果接入方调用了 api 修改配置后实时生效可能会出现什么问题？

比如配置中有两个配置项：url, domain（假设旧的配置为 `url1` 和 `domain1`），通过以下配置成 `url2` 和 `domain2`：

```java
SDK.getInstance()
    .setUrl("url2")
    .setDomain("domain2");
```

配置的修改所在的线程取决于业务 app，SDK 内部无法（也不应该）约束，如果这两个配置是实时生效的，由于 `setUrl()` 和 `setDoamin()` 的执行先后顺序，则有可能会存在 sdk 内部使用了 `url2` 和 `domain1` 这种配置处理的逻辑，而这种配置理论上是不合法的，可能会引发未知的问题。

假设修改的配置是一个新的对象（通过 builder build 也是一样）：

```java
class Configuration{
    String url;
    String domain;
    // ...
}

SDK.getInstance()
    .setConfiguration(new Configuration("url2", "domain2"));
```

即使是以上情况，SDK 内部如果出现以下代码可能也会产生问题：

```java
private void methodA(){
    Configuration configuration = sdkInstance.getConfiguration();
    // 根据当前 configuration 处理逻辑
    // ...
    methodB();
}

private void methodB(){
    Configuration configuration = sdkInstance.getConfiguration();
    // 根据当前 configuration 处理逻辑，这里拿到的 configuration 跟 methodA 里面拿到的配置可能是不一样的
    // ...
}
```

`methodA` 和 `methodB` 是同一业务链路的，但是 sdk 配置可能在 `methodA()` 执行完之后配置被修改，configuration 被改变，导致运行到 `methodB()` 时，获取到配置项是不一样的，这也会导致整个处理逻辑出现未知的问题。

合理的方案是怎么样的？

接入方手动调用 sdk api 修改配置后，修改的配置是无法实时在当前 sdk 中生效的（只是修改了配置的模版 `configTemplate`），只有在接入方手动调用了 `restart` 对 sdk 进行重启之后才会生效。

```java
SDK.getInstance()
    .setUrl("url2")
    .setDomain("domain2");
// 配置保存，但是未生效
// ...
SDK.getInstance().restart();
// 配置生效
```


## SDK 应该具有可扩展性

> 模块化架构

我们讨论的 SDK 是指 `具有一定完整业务逻辑闭环的独立子系统`。

我们需要针对 SDK 进行基本的架构设计，拆解其业务逻辑，拆分出多个业务上互相独立的一级模块，保证各个子模块的职责单一性；

反过来，如果把这些模块集成到一起，合成一个单独的 `SDKInstance`，即 `SDK 实例`，就可以完成整个 SDK 所需的所有功能。

例如，APM 由以下几个模块组成：

- 手机信息模块
- 网络状态监听模块
- 网络诊断模块
- 网络信息模块
- 定位模块
- 存储模块
- 性能模块
- 上报模块
- 采集模块
- ...

弱网库 Triton 由以下几个模块组成：

- 网络诊断策略模块
- 网络状态缓存模块
- 网络探测模块
- 网络状态监听模块
- ...

当 `SDKInstance` 被启动时，本质上是启动包括 `配置模块` 在内的所有模块 chian，当中一旦有一个模块的初始化过程失败了，则表示整个 SDK 启动失败，会终止后面所有模块的初始化过程的同时，关闭所有已经初始化过的模块，并抛出异常给接入方。

一个模块是否设计得合理，主要体现在以下几个方面。

### 模块的独立性

每个模块都是能够完成独立的功能，它可能会依赖其它的模块或者服务，但是该模块的核心业务逻辑应该是自身能独立完成的，能够在模块内部自身形成完整的功能闭环。

比如网络监听模块，包含完整的 `网络状态监听的注册`、`网络状态监听的反注册`、`网络状态监听的回调通知`、跟系统的网络可达性 API 进行通信，并且对外（SDK 内部其它模块）提供 `网络状态监听` 的服务等等。这些功能都是内聚在 `网络状态监听模块` 中。

对于 SDK 其它模块来说，`网络状态监听` 模块是一个黑盒态，对其它模块只提供 `网络状态监听的注册`、`网络状态监听的反注册` 等几个功能，但是对模块自身内部的实现细节、机制及存储的数据是隐蔽的（其它模块也不需要了解它的内部细节）。即 `对信息隐蔽`。

### 模块的生命周期

模块內业务逻辑的执行是需要依赖整个 SDK 的生命周期的，这就需要与 `SDKInstance` 的生命周期进行关联，即每个模块需要有以下生命周期方法，在 `SDK Instance` 的生命周期改变时，会自动通知回调各个模块的对应生命周期方法：

```java
/**
 * 在 SDK 启动的时候，所有模块都会通过 chain 进行链式初始化；
 *
 * 各个模块初始化的过程中会调用此方法来提供模块进行内部的初始化工作
 */
void onLaunch(SDKLaunchMode launchMode, @NonNull Chain<Config> chain) throws Exception;

/**
 * 整个 SDK 启动后回调（即：所有模块都初始化后回调）
 */
void onSDKStart(SDKLaunchMode launchMode, @NonNull Config config) throws Exception;

/**
 * SDK 停止时回调（即：真正执行 shutdown 之前）
 */
void onSDKStop(SDKLaunchMode launchMode, @NonNull Config config) throws Exception;

/**
 * 在业务方停止 SDK 时，各个业务模块会调用此方法进行收尾处理
 */
void onShutdown(SDKLaunchMode launchMode, @NonNull Chain<Config> chain) throws Exception;

/**
 * 整个 SDK 关闭回调（即：所有模块都关闭后回调）
 */
void onSDKShutdown(SDKLaunchMode launchMode, @NonNull Config config) throws Exception;
```

每个模块自身也有自己的状态管理，同样也可以被 `启动`、`关闭` 等等操作，在运行过程中，SDK 可以控制单独关闭某个功能模块，比如 APM 在运行过程中可以单独关闭 `上报模块`，达到只采集数据但不上报数据的目的。

### 模块的抽象

所有模块之间可能是需要互相依赖的，但是依赖关系需要尽量解耦，保证低耦合。

每个模块应该是抽象的，面向接口、面向协议的，定义好每个协议方法的输入输出，其它模块在调用该模块的方法时只调用协议、不依赖于该模块的具体实现。即，对协议开放。

模块之间也不应该依赖模块注册的顺序。模块之间可能存在依赖关系，假设 `B 模块` 依赖了 `A 模块`，那么 `A 模块` 在 `SDKInstance` 中的模块注册顺序必须是在 `B 模块` 前面吗？

不应该，因为模块之间的依赖关系是不确定的，假设 `B 模块` 依赖了 `A 模块` 的同时，`A 模块` 也依赖了 `B 模块`，那么模块注册的过程中就可能会存在问题。

所以模块的初始化和模块的依赖调用过程需要隔离。

### 模块间的通信

模块间一般面向协议来进行通信。

一种方式是通过上面说的对模块的抽象，面向接口，通过接口来确定通信的标准化协议。

另一种更推荐的方式是通过对协议抽象出服务，通过服务来实现数据的通信。

每个模块通过 `服务注册中心` 注册服务，对其它模块暴露自己的服务，每个模块也可以通过 `服务注册中心` 获取/订阅自己需要的服务。

服务的使用方不关心提供的服务方是谁，服务的提供方也不关心服务的调用方有哪些。淡化依赖关系，所有的依赖关系都由 `服务注册中心` 进行统一的管理。

![sdk_framework_extension_img_03](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/5f499e48-3adf-4244-8cc7-84a848cca221)

如上图，该 `SDKInstance` 实例由 3 个模块组成：`模块 A`、`模块 B`、`模块 C`。

- `模块 A` 对外提供、暴露 `O1` 服务，通过注册到 `服务注册中心` 的方式。同时，`模块 A` 还依赖 `S2` 服务，代码中需要获取该服务进行业务逻辑的处理。`S2` 服务是 `模块 B` 暴露出来的服务（同样也是注册到 `服务注册中心`），但是 `模块 A` 不关心这个，只需要知道自己需要 `S2` 服务，`S2` 服务可以是 `模块 B` 提供的，当然也可以是 `模块 C` 提供的，对 `模块 A` 来说没有任何影响，只要服务的提供方能保证服务的可靠性。
- `模块 B` 提供了 `S2` 服务，但是不依赖与其它任何服务。
- `模块 C` 需要订阅 `O1` 服务，但是它不对外提供、暴露任何服务。
- 同时，以上从 `模块 A` 到 `模块 C`，服务初始化的顺序与服务使用无关。


## SDK 应该具有依赖可重入性

> 去单例化

![sdk_framework_extension_img_04](https://github.com/wangjiegulu/wangjiegulu.github.com/assets/5423194/67e15fb4-f63d-4b66-b4e4-c72538e0ad6b)

一般 SDK 只会提供给 app 接入，可能不存在不同 SDK 内部的互相循环依赖等问题；

但是作为公技部门，为了让 SDK 的提供的服务具有可复用性，功能粒度一般是更细的，比如上图，`App` 依赖了 `HttpDNS`，`URS` 依赖了 `HttpDNS`，即 `App` 也直接或者间接两次依赖了 `HttpDNS`；

App 依赖的 `HttpDNS` 和 `URS` 依赖的 `HttpDNS` 因为对应的配置是不一样的，显然不应该是同一个 `HttpDNS` 实例，`App` 的 `HttpDNS` 和 `URS` 的 `HttpDNS` 应该互不干扰，相互独立。

因此，每个 SDK 都不应该是单例的，应该去单例化，理论上可以在一个 JVM 中创建任意多个 SDK 实例提供给不同的业务方使用。

```java
// App 初始化 HttpDNS
HttpDNSInstance httpDNSInstanceForApp = new HttpDNSInstance(/*...*/);
httpDNSInstanceForApp
    .withXxx() // 配置一
    .withYyy() // 配置二
httpDNSInstanceForApp.start();


// URS SDK 内部使用 HttpDNS
HttpDNSInstance httpDNSInstanceForURS = new HttpDNSInstance(/*...*/);
httpDNSInstanceForURS
    .withXxx() // 配置一
    .withYyy() // 配置二
httpDNSInstanceForURS.start();
```

`httpDNSInstanceForApp` 和 `httpDNSInstanceForURS` 两个 `HttpDNS` 实例一般情况下没有任何关系，互不干扰（可考虑加入沙箱机制保证每个实例之间的完全隔离和安全性），只服务于自己的业务方。

所以类似 `XxxSDK.getInstance()` 单例化的方式并不推荐。

> 当然，粗暴地去单例的方式可能在很多的场景下并不优雅，也并不符合预期。


## SDK 的服务应该具有可复用性

> 引导器 Bootstrap、服务注册中心

上面说过，每个 SDK 其实都是一个单独具有一定完整业务逻辑的独立子系统，并且每个 SDK 是去单例化的，不同单例可能是完全隔离的。但是很多情况下，相同 SDK 的不同实例、甚至是不同 SDK 的不同实例它们之间也是有非常多的联系，它们有可能需要共享它们的其中一些服务。

比如弱网库，大部分 SDK 和 app 都应该可以通过弱网库来识别当前的网络状况。这可能就导致了 triton sdk 被多次依赖的问题，比如上图的复杂的 SDK 内部依赖关系；

- App 依赖 Triton
- APM 依赖 Triton
- HttpDNS 依赖 Triton
- URS 依赖 Triton
- URS 依赖 APM
- App 有依赖 APM、URS、HttpDNS、Triton
- ...

显然，之前讲的每个 App 或者 SDK 都有一个 Triton 实例，这么多 Triton 实例之间互相独立，互不干扰当然可以正常运行。

但是作为 Triton（弱网库），存在这么多 Triton 实例是没有太大意义的，就同一个设备来说，只需要一个 Triton SDK 实例用来探测网络状态并通知给所有的订阅方（跨不同的 SDK）就足够了，过多的 Triton 实例只会造成资源的浪费（多个定时器、不共享的缓存、冗余的网络探测过程等等）。

合理的方案：

- 如果 App 也直接使用了 Triton，则所有直接或者间接依赖 Triton 的 SDK 都应该复用 App 的 Triton 实例，而不是 SDK 自己去创建一个 Triton 实例。
- 如果 App 没有使用 Triton，则所有直接依赖 Triton 的 SDK 应该只有一个 Triton 实例被创建，其它 SDK 都复用这一个 Triton 实例。

因为涉及到服务的共享问题，因此我们使用了 `服务注册中心` 来解决。

所有可能会共享的服务都可以被注册到 `服务注册中心` 上面，所有使用共享服务的 app 或者 SDK 都会从 `服务注册中心` 上获取服务来进行使用。在这个场景下，这个共享的服务就是 Triton 的实例。

> 当然，共享的服务不止是 SDK 实例，也可能是一个 `定时任务`，或者是 `网络监听回调`，`当前手机信息` 等等。万物皆服务，服务可共享。


因为涉及到各个 SDK 的服务共享问题，业务方在接入时可能会感觉比较繁琐，因为业务方需要关心每个 SDK 它共享出去什么服务，又需要依赖哪些服务。

所以，可以通过 SDK 的引导器（Bootstrap）让业务方傻瓜式接入，业务方无需关心各个 SDK 的依赖关系，所有的依赖关系都交给 Bootstrap 中的 `SDKExporterModule` 即可。

如下（目前处于实验阶段，后期 api 可能会有调整）：

```java
// 初始化并启动引导器
SDKBootstrap.withContext(this)
        .newSDK("Triton", ()=> new TritonExporterModule(new TritonInstance(BootstrapActivity.this)))
        .newSDK("APM", ()=> new SDKExporterModule<>(new TritonInstance(BootstrapActivity.this)))
        // 一旦调用了 SDKBootstrap 的 start 方法并不意味着启动了所有的 SDK 实例，只是启动了 Bootstrap 实例，去统一管理每一个上面声明了的 SDK 及它们之间的所有依赖关系，所有 SDK 都没有被真正启动
        .start();

// ...

// 在业务方合适的时机，启动弱网库 Triton SDK
SDKBootstrap.getInstance().<TritonInstance>getSDK("Triton").start();

// ...

// 在业务方合适的时机，启动 APM SDK
SDKBootstrap.getInstance().<MamAgentV3Instance>getSDK("APM").start();
```

调用 `SDKBootstrap::start` 方法时并不会真正启动里面的 SDK，只会初始化所有依赖关系并启动 SDK 引导器；只有业务方通过 `Bootstrap::getSDK::start` 时才会真正启动对应的 SDK。


## SDK 的服务应该是进程间可共享的

> 服务注册中心

因为 Android 系统允许开发者使用多进程进行开发，经常会导致同一个 SDK 在多个进程中进行初始化，并且每个进程间的数据都是隔离的。在某些 SDK 场景下，就会存在一不同进程间的数据共享问题。

如 `HttpDNS`，在不同的进程下面，可能会出现以下问题：

- 对应进程的多次重复初始化数据
- DNS 解析的结果是不会在不同进程之间进行共享的，所以可能会导致同一个 app，不同进程的解析缓存数据命中率下降，出现过多的无用重复解析请求等问题。

重复的次数取决于 app 所拥有的进程数量，对于 SDK 来说这是完全不可控的。

解决方案，通过进程间的通信来实现数据在不同进程间的共享问题。

又通过 `服务注册中心` 扩展出进程间的通信：

- `进程 A` 的生产者可以在 `服务注册中心` 注册服务；
- 其它进程的订阅者可以在 `服务注册中心` 订阅 `进程 A` 所创建的服务；
- 当 `进程 A` 产生了新的数据时，通过服务发送数据；
- 其它订阅者进程收到 `进程 A` 发送的数据

进程间的 Binder IPC 通信逻辑都通过 `服务注册中心` 上层封装隐藏起来。

当然，每个进程的 `HttpDNS` 实例都有可能是生产者。所以，**对于每个进程来说自己又是生产者，又是订阅者**，即把自己的解析结果共享给其它进程，又接收其它进程解析的结果给自己使用。

只是单纯的数据共享还是无法完全满足需求，可能会出现多个进程同时去解析同一个域名的情况。

所以可以通过 `进程锁` 来控制多个进程的并发解析问题。

`进程锁` 同样也是通过 `服务注册中心` （底层 Binder IPC）来进行实现。


## SDK 应该具有可测试性

> 单元测试、服务注册中心

前面提到，整个 SDK 通过不同的领域模块进行拆分，每个模块之间通过协议进行抽象，使用 `服务注册中心` 来实现不同模块、甚至不同 SDK 之间的通信。

所以，每个模块天然地对测试是友好的，我们可以通过 `Mockito` 等 Mock 框架去 mock 不同接口的输入和输出结果，来断言模块内部的逻辑代码是否能正确执行。

如下，用于测试**配置模块**的 `initDefaultConfig` 方法，当业务方没有配置 `探测策略` 时（即 `config.getDetectionStrategy()` 返回 null），则 `initDefaultConfig` 方法是否能正确重置为默认的 `探测策略` 配置：

```java
/**
 * ConfigurationModuleTest.java
 */
@Test
public void test_initDefaultConfig_detectionStrategy_null() throws Exception {
    TritonConfig config = tritonEnvRule.getConfig();
    doReturn(null).when(config).getDetectionStrategy();

    configurationModule.initDefaultConfig(config);

    verify(config, times(1)).setDetectionStrategy(any(DetectionStrategy.class));
    doCallRealMethod().when(config).getDetectionStrategy();
    Assert.assertNotNull(config.getDetectionStrategy());
    Assert.assertEquals(AlphaDetectionStrategy.class, config.getDetectionStrategy().getClass());
}
```

// TODO: FEATURE wangjie `展开细节以后再讲` @ 2020-11-18 15:45:17

## SDK 应该具有版本管理

如上面提到，因为 SDK 可能会出现互相依赖的情况，App、SDK 的依赖关系会变得非常复杂，甚至会陷入 `依赖地狱`。这时，我们需要通过版本管理来解决这个问题。

每个 SDK 都必须提供对外暴露的公共 `API`。SDK 接入方主要通过这些公共 `API` 来使用该 SDK。如 `Triton SDK`，业务方都是调用 `TritonApi` 这个接口进行访问。

版本的管理严格使用 [语义化版本号](https://semver.org/)： `[主版本号].[次版本号].[修订号]`，先行版本或者编译元数据可以加在后面作为延伸。如 `3.0.0`，`3.2.1`，`1.0.0-alpha`，`1.0.0-alpha.1`，`1.0.0+20130313144700`，`2.3.1-rc.1`，`1.3.23`。

- **主版本号**：进行不向下兼容的修改时，递增主版本号。如以下情况：
    - 如删除了某个 `API` 方法；
    - 修改了某个 `API` 方法的定义，方法签名有修改；
    - 修改了某个 `API` 相关类型的数据结构，且无法兼容之前的版本；
    - [也可以是]大量次版本号及修订级别的改变；
    - `API` 相关的包移动、类重命名；
    - 其它无法兼容之前版本的修改；
- **次版本号**：`API` 保持向下兼容的新增及修改时，递增次版本号；
    - 新增了新的 feature，但是兼容之前的版本；
    - `API` 的某个方法被标记为弃用；
    - [也可以是]内部有大量的新功能或者（也可以是修订级别的）优化时；
    - 其它能向下兼容旧版本的修改；
- **修订号**：修复问题但不影响 `API` 时，递增修订号
    - 解决了某个 `API` 方法的 bug，但是方法的签名没有改变；
    - 优化了某个 `API` 方法的内部实现，但是方法的签名没有改变；
    - 修改了某个 `API` 相关类型的数据结构，但是兼容之前的版本；
    - 解决了某些内部的 bug，但是不影响使用；
    - 其它不影响 `API` 的修改；

举个例子：假设 `URS` 依赖 `HttpDNS`，`URS` 需要 `HttpDNS 1.3.0` 的新功能，那么你可以放心地去指定 `URS` 可以依赖于 大于 `1.3.0` 小于 `2.0.0` 版本的 `HttpDNS`。

### 版本冲突

如果 App、SDK 依赖关系较为复杂时，可能就会引发版本冲突的问题。

**理想场景下**

- App：依赖 `HttpDNS 1.3.0`
- App：依赖 `URS 3.8.0`
    - `URS 3.8.0` 依赖 `HttpDNS 1.3.0`

以上场景，两个 `HttpDNS` 依赖的版本都是 `1.3.0`，并没有冲突的问题，所以最终依赖的各 SDK 如下：

- `URS 3.8.0`
- `HttpDNS 1.3.0`

**修订版本冲突场景**

- App：依赖 `HttpDNS 1.3.0`
- App：依赖 `URS 3.8.0`
    - `URS 3.8.0` 依赖 `HttpDNS 1.3.2`

以上场景，App 依赖的 HttpDNS（`1.3.0`） 和 URS 依赖的 HttpDNS（`1.3.2`） 版本是不一致的，但是，两个版本的差异只是修订版本，所以最终依赖的各 SDK 如下：

- `URS 3.8.0`
- `HttpDNS 1.3.2`

以上场景，HttpDNS 最终应该使用 `1.3.2` 版本，因为这个版本是向下兼容 `1.3.0`，并可能包含了修复的一些存在的问题；

**次版本冲突场景**

- App：依赖 `HttpDNS 1.3.2`
- App：依赖 `URS 3.8.0`
    - `URS 3.8.0` 依赖 `HttpDNS 1.4.1`

以上场景，App 依赖的 HttpDNS（`1.3.2`） 和 URS 依赖的 HttpDNS（`1.4.1`） 版本是不一致的，但是，两个版本的差异只是次版本，所以最终依赖的各 SDK 如下：

- `URS 3.8.0`
- `HttpDNS 1.4.1`

以上场景，HttpDNS 最终应该使用 `1.4.1` 版本，因为这个版本是向下兼容 `1.3.2`，并可能包含了修复的一些存在的问题和新增了一些新的 feature，而这些差异可能会影响到 URS；

**主版本冲突场景**

- App：依赖 `HttpDNS 1.3.2`
- App：依赖 `URS 3.8.0`
    - `URS 3.8.0` 依赖 `HttpDNS 2.0.1`

以上场景，App 依赖的 HttpDNS（`1.3.2`） 和 URS 依赖的 HttpDNS（`2.0.1`） 版本是不一致的，两个版本的差异是主版本，两个版本理论上是不兼容的，所以无法决定最终使用哪个版本的 `HttpDNS`（使用任意一个版本都可能会引起另一个出错），此时，App 依赖应该直接报错。

### 语义化版本依赖插件

要保证版本依赖的准确性，需要依赖方（业务方）保持警惕，并检查当前直接或者间接依赖的所有 SDK 之间是否有版本冲突的问题，很多时候，这是无法在编译期间把问题暴露出来的，可能会把问题留到运行时甚至线上。那如何解决或者避免由于版本冲突导致的不可预知的问题呢？

以 android 为例，通过自定义开发 `gradle` 插件来规范每个 sdk 的语义化版本的依赖方式，使用方式如下：

```groovy
// 支持修订号兼容
// 类似于 `api("com.netease.android:httpdns:x.x.x")` 且 `1.3.2 <= x.x.x < 1.4.0`
semverApi("com.netease.android:httpdns:~1.3.2")

// 支持小版本兼容
// 类似于 `implemention("com.netease.android:httpdns:x.x.x")` 且 `1.3.2 <= x.x.x < 2.0.0`
semverImplemention("com.netease.android:httpdns:^1.3.2")
```

**场景一**

- App：`semverImplemention("com.netease.android:httpdns:~1.3.0")`
- App：`semverImplemention("com.netease.android:urs:^3.8.0")`
    - URS：`semverImplemention("com.netease.android:httpdns:^1.3.2")`

如上：
- App 需要依赖的 HttpDNS 版本区间为：`1.3.0 <= version < 1.4.0`
- App 依赖了 URS，而 URS 需要依赖的 HttpDNS 版本区间为：`1.3.2 <= version < 2.0.0`
- 两者取交集：`1.3.2 <= version < 1.4.0`
- 最后，version 取最小，则 version 最终自动选为 `1.3.2`

**场景二**

- App：`semverImplemention("com.netease.android:httpdns:^2.3.0")`
- App：`semverImplemention("com.netease.android:urs:^3.8.0")`
    - URS：`semverImplemention("com.netease.android:httpdns:~1.3.2")`

如上：
- App 需要依赖的 HttpDNS 版本区间为：`2.3.0 <= version < 3.0.0`
- App 依赖了 URS，而 URS 需要依赖的 HttpDNS 版本区间为：`1.3.2 <= version < 1.4.0`
- 两者并没有交集，说明没有 version 能满足两处的依赖，**编译不通过，报错**。




