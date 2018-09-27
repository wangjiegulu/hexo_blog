---
title: 构建自己的 Smart Life 私有云（一）-> 破解涂鸦智能插座
subtitle: "破解涂鸦智能插座，使用 Slack 控制"
tags: ["Smart Life", "Internet of Things", "IoT", "tuya", "plug", "IFTTT", "Google Assistant", "Slack"]
categories: ["Smart Life", "IoT"]
header-img: "https://images.unsplash.com/photo-1532188363366-3a1b2ac4a338?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6acd02e02b1544d4ecc5710336410771&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true
---

# 构建自己的 Smart Life 私有云（一）-> 破解涂鸦智能插座

本系列文章的目标是通过自己搭建的`私有云`、`IFTTT`、`Slack`、`Google Assistant`、`涂鸦智能`、`图灵机器人`等等第三方服务，构建自己的“智能生活”基本的框架。

前段时间我在京东上购买了一个[涂鸦智能的插座](https://item.jd.com/29882207900.html)。涂鸦智能是一个把产品智能化的一个平台，从软件和硬件和云端上面提供给厂商一个一站式人工智能物联网的解决方案（*确实不是涂鸦智能的广告- -.*）。所以严格来说应该是“鹊起”基于涂鸦解决方案所开发出来的一个产品，基于涂鸦提供的一切规范，所有软硬云端的开发规范都可以在官网无权限限制地查看到（<https://docs.tuya.com/cn/>）

## 初试插座

我首先下载了涂鸦的官方app：[Smart Life](https://play.google.com/store/apps/details?id=com.tuya.smartlife&hl=en_US)，注册登录、智能配对插座，通过手机控制插座开关，一切顺利，还支持设置定时开关和 Schedule，而且手机控制到插座的反应十分灵敏（看样子应该使用了长链接）。

## 破解插座

当然使用官方 app 显然是无法满足我们需求，所以查看官方文档，发现文档中的 [tuya.m.device.dp.publish](https://docs.tuya.com/cn/cloudapi/appAPI/tuya.m.device.dp.publish_1.0.html) 接口正好可以满足我们的需求。

通过[接入指南](https://docs.tuya.com/cn/cloudapi/app_access.html)，我们可以知道接入方式提供了两种：

1. MQTT，果然有使用长链接（app端默认用的应该就是长链接了）
2. https，这个目前比较适合我们，暂时不管延迟怎么样，先选择用 https 来验证控制的可行性

下面有列出通用的参数：

|参数名称|参数类型|是否必须|是否签名|参数描述|
|---|---|---|---|---|
|a|String|是|是|API名称|
|v|String|是|是|API接口版本|
|sid|String|否|是|用户登录授权成功后，ATOP颁发给应用的用户session|
|time|String|是|是|时间戳，格式为数字，大小到秒非毫秒，时区为标准时区，例如：1458010495。API服务端允许客户端请求最大时间误差为540分钟。|
|sign|String|是|否|API输入参数签名结果，签名算法参照下面的介绍|
|clientId|String|是|是|用户的APPID(注各平台不一样如:ios、android、云云对接的id都不一样)|
|lang|String|否|是|APP的语言，如"en"，“zh_cn”,错误信息根据语言自动翻译|
|ttid|String|否|是|APP渠道或云端渠道,如公司名,用于数据分析跟踪|
|os|String|是|是|手机操作系统，如"Android"，“ios”,云端可以写linux或写公司名|

上述我们无法拿到的是哪些呢？

- sid：登录后自然就能拿到了
- sign：所有参数都有了，那sign自然能算出来（文档下面有sign算法）
- clientId：这玩意就比较麻烦了，相当于一个apiKey
- ttid：这个非必须，暂时可以不管

所以只要拿到 clientId，我们就能

- 通过 [tuya.m.user.email.token.get](https://docs.tuya.com/cn/cloudapi/appAPI/userAPI/tuya.m.user.mobile.token.get_1.0.html) 接口拿到登录用的 token
- 通过 [tuya.m.user.mobile.passwd.login](tuya.m.user.mobile.passwd.login) 接口登录
- 然后通过 [tuya.m.device.dp.publish](https://docs.tuya.com/cn/cloudapi/appAPI/tuya.m.device.dp.publish_1.0.html) 接口下发指令

那怎么去拿到 clientId 呢？反编译试试（大家应该都知道怎么做），class.dex 有点多，最后拿到了 

- client_id：`8qp5cfk*******3mpmc3`（这个打码了）
- app_secret：`g75ktcvsae8**********e95j738tawg`（同样打码）

###  拿到登录 token

打开 `Postman`，[按照文档](https://docs.tuya.com/cn/cloudapi/appAPI/userAPI/tuya.m.user.mobile.token.get_1.0.html) POST `countryCode` 和 `mobile` 可以得到 token：

```json
{
    "api":"tuya.m.user.mobile.token.get",
    "result":{
        "exponent":"3",
        "pExponent":"...",
        "publicKey":"...",
        "token":"..."
    },
    "status":"ok",
    "success":true
}
```

### 通过 token 进行登录

```json
{
    "countryCode":"86",
    "mobile":"11745678923",
    "passwd":"根据获取token接口返回的公钥对 md5(明文密码) 进行rsa加密",
    "token":"126bb7570dcae343980b0607e6b35084",
    "ifencrypt":1
}
```

根据[登录接口的文档](https://docs.tuya.com/cn/cloudapi/appAPI/userAPI/tuya.m.user.mobile.passwd.login_1.0.html)，密码需要使用 gettoken 接口返回的公钥对 md5之后的密码进行 rsa 加密，apk 反编译之后代码可以完全看到，直接拷贝即可

登录完之后，就可以拿到具体的 sid （sessionId）了，有了 sessionId，就可以去对插座进行下发指令。

### 插座下发指令

同样[根据下发指令接口文档](https://docs.tuya.com/cn/cloudapi/appAPI/tuya.m.device.dp.publish_1.0.html)：

```json
{
    "devId": "002yt001sf000000sfV3",
    "dps": {
       "1":1,
       "2":5
    }
}
```

可以看到，POST 的数据除了 sid，还需要 devId 和 dps

dps 可以参考这里的文档：<https://fchelp.cloud.alipay.com/queryArticleContent.htm?tntInstId=WRNQWLCN&articleId=89429815&helpCode=SCE_00000019>

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46066359-0dcc6b80-c1a7-11e8-8d29-5391b7f7f87a.png">
</div>

我们要控制插座开关的话，那就使用 `{"1": true}` / `{"1": false}` 即可

那 devId 呢？它代表我添加设备 id，那我怎么知道我刚给在 Smart Life 上添加的插座 id 呢？抓包试试（大家应该都知道），通过抓包，我们可以很容易拿到所有你绑定的 devId。


至此，我们可以通过 http 来控制插座的开关了。

## 搭建自己的私有云项目

> 我为自己的项目取名为 `Angelia`，安革利亚，古希腊神话人物之一，为“消息女神”。

搭建 web 项目，新建 `AngeliaController`：

```kotlin
@RestController
@RequestMapping("/angelia")
@Configuration
class AngeliaController {
    // ...
}
```

增加 Tuya 的配置文件：tuyaclient.properties

```
tuya.client.client_id=xxxxxx
tuya.client.app_secret=xxxxxx
tuya.client.ttid=xxxxxx
tuya.client.v=1.0
tuya.client.base_url=https://a1.tuyacn.com/api.json

# smart life app 登录手机号
tuya.client.user_mobile=18511111111
tuya.client.user_country_code=86
tuya.client.user_rsa_encrypted_passwd=xxx

# 设备信息
tuya.client.lang=en
tuya.client.os=Android
tuya.client.os_system=9
tuya.client.time_zone_id=Asia/Shanghai
tuya.client.platform=Pixel
tuya.client.sdk_version=2.6.4
tuya.client.app_version=3.4.3
tuya.client.app_rn_version=5.6
# 设备 id，模拟手机的 deviceId
tuya.client.device_id=e507510a0288accd7******
tuya.client.imei=xxxxxx
tuya.client.imsi=xxxxxx

# 智能设备，可以多个：别名|id|dpid,别名|id|dpid,别名|id|dpid
# dpid: 1. 开关；4.rgb；5. 档位；6. 温度；15. 红外数据
tuya.client.dev_ids=[\
  {\
    "aliasList": ["plug a", "plug 1", "插座a", "洗手间总电源"],\
    "devId": "111222333",\
    "dpId": "1"\
  },\
  {\
    "aliasList": ["plug b", "plug 2", "插座b", "卧室总电源"],\
    "devId": "12341234",\
    "dpId": "1"\
  },\
  // ...
]
```

以上，除了刚刚的那些必要的参数之类，在这个配置文件里面还增加了对所有设备的配置，每个设备对应它的 dpId，devId，还有别名（控制的时候不可能直接说 “devId 为 a1d2f32a1d2f32 的插座关掉”，而是说 “关掉插座1” / “关掉洗手间总电源”等等），每个设备别名可以有多个。

好了，回到 `AngeliaController`，新增一个接口：

```kotlin
/**
* 插座控制接口
*/
@Autowired
lateinit var tuyaClientService: TuyaClientService

@Autowired
lateinit var tuyaClientProperties: TuyaClientProperties

@PostMapping("/control/plug")
fun controlPlug(@RequestBody request: PlugRequestVo): JSONObject {
   val dev = tuyaClientProperties.findDev(request.alias)
   return try {
       if (null == dev) {
           JsonResult.error("Device named ${request.alias} is not found")
       } else {
           tuyaClientService.controlPlug(dev.devId, request.turnOn)
           JsonResult.success()
       }
   } catch (e: Exception) {
       JsonResult.error(e.message)
   }
}

data class PlugRequestVo(
     val alias: String,
     val turnOn: Boolean
)
```

以上，该接口接收别名（alias）和开闭状态（turnOn）两个入参。首先，通过请求的别名去 properties 查找设备，如果找到，则通过 `tuyaClientService` 的 `controlPlug` 方法来下发指令，`controlPlug` 的实现就是刚刚上面说的 `获取登录接口-登录-下发指令`几步。

构建、部署，通过 Postman 访问 `http://localhost:xxxxx/angelia/control/plug`, body 设置为 `{"alias": "卧室总电源", "turnOn": true}`，插座即可打开。


