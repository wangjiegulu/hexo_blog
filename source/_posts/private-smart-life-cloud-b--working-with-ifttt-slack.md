---
title: 构建自己的 Smart Life 私有云（二）-> 连通 IFTTT & Slack
subtitle: "配合 IFTTT、Slack、Google Assistant 控制智能插座"
tags: ["Smart Life", "Internet of Things", "IoT", "tuya", "plug", "IFTTT", "Google Assistant", "Slack"]
categories: ["Smart Life", "IoT"]
header-img: "https://images.unsplash.com/photo-1532188363366-3a1b2ac4a338?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6acd02e02b1544d4ecc5710336410771&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true
---

# 构建自己的 Smart Life 私有云（二）-> 连通 IFTTT & Slack

[上一篇](https://blog.wangjiegulu.com/2018/09/26/private-smart-life-cloud-a--hack-tuya-smart-plug/)我们破解了涂鸦的插座，搭建了自己的 web 服务，暴露了一个接口来控制插座的开关。这篇我们配合 IFTTT、Slack 来控制插座：

1. 说 "OK Google" 唤醒 Google Assistant，然后说 “帮我打开卧室的电源”，最后插座被打开。
2. 创建 Slack 机器人 `Angelia`，对它发消息“帮我打开卧室的电源”，然后插座打开， `Angelia` 回复说 “好的，已经打开”。
3. 通过 Slack 机器人 `Angelia`，发送 Slash Commands，打开关闭插座。

## 创建自己私人的 Slack Workspace

打开 Slack，根据提示创建自己的 Slack Workspace: <https://slack.com/create>

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46124165-111e3080-c255-11e8-88ba-7be984c00cf3.png" width="500px">
</div>

比如我的 Workspace 为 <https://wangjie.slack.com>。

## 创建 Slack App

创建完毕登录之后，默认应该有 `#general`、`#random` 等 channel，但暂时不用这两个 channel。

接下来，我们来创建一个 App。

打开 <https://api.slack.com/>，点击 `Start Building`

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46124413-981fd880-c256-11e8-8cbb-572346f29fd7.png" width="600px">
</div>

输入 App 名称和你要添加到的 workspace。

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46124447-df0dce00-c256-11e8-959b-64a6fcd1bc84.png" width="600px">
</div>

### 设置 Bot 信息

创建完毕之后，我们需要设置这个 app 的机器人相关信息，打开 [app 设置页面](https://api.slack.com/apps)，选择 `Bot Users`：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46124676-1335be80-c258-11e8-89fa-b299badb545a.png" width="700px">
</div>

设置机器人的名称（Display name 和 Default name）。勾选 `Always Show My Bot as Online`，点击 `Save Changes`。

### 设置 Events API

[Event API](https://api.slack.com/bot-users#app-mentions-response) 可以在各种时间发生的时候触发调用，比如 消息发送的时候、channels 改变的时候等等。

我们先回到我们的 web 服务，打开上一章创建的 `AngeliaController`，新增一个处理 Event 的 api：

```kotlin
@PostMapping("/say/at")
fun say(@RequestBody request: BotEventRequestVo): JSONObject {
    logger.info("[slack event request]request -> \n$request")
    return JsonResult.success(
                    "token" to request.token,
                    "challenge" to request.challenge,
                    "message" to message
            )
}

data class BotEventRequestVo(
        val challenge: String?,

        val token: String?,
        val team_id: String?,
        val api_app_id: String?,
        val event: BotEventVo?,
        val type: String?,
        val event_id: String?,
        val event_time: String?,
        val authed_users: List<String>?
)

data class BotEventVo(
        val type: String?,
        val user: String?,
        val text: String?,
        val client_msg_id: String?,
        val ts: String?,
        val channel: String?,
        val event_ts: String?,
        val channel_type: String?
)
```

构建，部署到服务器。

打开 Slack App 设置页面的 `Event Subscriptions`：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46125203-abcd3e00-c25a-11e8-805f-d9f17bd235bc.png" width="700px">
</div>

在 `Request URL` 中填写刚刚在我们 web 服务上创建的接口 `http://[server ip]:xxx/angelia/say/at`，并且点击验证。

> 注意：这里认证的依据是，你的接口 Response 需要返回请求中的 `challenge` 数据就算认证成功。

然后在 `Subscribe to Bot Events` 中添加订阅的事件，需要增加的是 [message.im](https://api.slack.com/events/message.im)

> `message.im`表示当你跟 bot 的私聊中产生消息的时候（有可能是你发送消息给 Bot，也有可能是 Bot 发消息给你），事件就会触发。

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46125314-21d1a500-c25b-11e8-83d1-89fbd8a596d1.png" width="600px">
</div>

点击保存。

这时，当你在 Slack 中发送消息给机器人的时候，你的 web 服务端就能收到请求了。

### 处理事件

你的 web 服务器收到请求之后，需要对此进行处理，所以你需要去解析发的消息中的信息，然后打开/关闭对应设备（插座）的开关。完善之前的 `say` 接口：

```kotlin
@Autowired
lateinit var tuyaClientService: TuyaClientService
@Autowired
lateinit var angeliaSlackProperties: AngeliaSlackProperties

/**
* Angelia 机器人 对话入口
*/
@PostMapping("/say/at")
fun say(@RequestBody request: BotEventRequestVo): JSONObject {
    try {
       val text = request.event?.text
       val eventType = request.event?.type
       if (eventType == "message" // 直接对话
            ||
            request.event.user != angeliaSlackProperties.angelia_id // angelia自己发的忽略掉
       ) {
          val message = angeliaBotService.parseTuyaClient(text)
                          ?: "Sorry, I can not understand."

          angeliaSlackService.postMessage(JSONObject().apply {
              this["text"] = "$message"
              this["channel"] = request.event.channel
              this["as_user"] = true
          })
       }
       return JsonResult.success(
               "token" to request.token,
               "challenge" to request.challenge,
               "message" to "Request eventId(${request.event_id}) done."
       )
   } catch (e: Exception) {
       angeliaSlackService.postMessage(JSONObject().apply {
           this["text"] = "Sorry! Something is wrong: ${e.message}"
           this["channel"] = request.event?.channel
           this["as_user"] = true
       })
       return JsonResult.error(e.message)
   }
}
```

上面代码的逻辑很简单：

- 首先，eventType是直接对话的（与机器人 bot 私聊），并且是我发给机器人的（机器人发给我的消息不用处理）才会去处理
- 然后通过 `angeliaBotService.parseTuyaClient()` 方法进行文本解析和处理
- 如果解析不出来，则返回 null，message 就是 "Sorry, I can not understand."
- 最后返回 Response（带上 message），这里的 message 就是 Bot 发送给我的数据。

这里需要做一些 Slack 的配置 slack.properties：

```
# token for bot
angelia.slack.bot_token=Bearer xoxb-2923xxxxxxxxxxxxxxxxxxxx

# slack api
angelia.slack.api_base_url=https://slack.com/api
angelia.slack.api_chat_post_message=/chat.postMessage

angelia.slack.angelia_id=UCWxxxxxx
```

`angelia.slack.bot_token`：是 Bot 发送消息到 Slack 的token，这个 token 可以在 app 设置页面的 `OAuth & Permissions` 中拿到

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46125989-09af5500-c25e-11e8-864b-18e3b6145aca.png" width="600px">
</div>

> 注意：是下面的那个 `Bot User OAuth Access Token`，并且添加到配置文件的时候需要加上 `Bearer `（注意后面有个空格）

`angelia.slack.api_base_url` 和 `angelia.slack.api_chat_post_message` 是发送消息的 url，不用改动。

`angelia.slack.angelia_id` 表示机器人的id，可以通过在 slack 左侧选中机器人右键复制链接，path 最后部分就是 id

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46126106-8d694180-c25e-11e8-84ae-ed01feda481d.png" width="250px">
</div>

最后，你就能在 slack 中打开与机器人聊天框，发送“关闭插座a”来控制插座：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46126279-3748ce00-c25f-11e8-997d-b47d8a1ea6ce.jpg" width="300px">
</div>

## 集成 Google Assistant 和 IFTTT

> 首先确保你的手机装有 Google Assistant（Google Home 先不讨论。。。是的，我没买- -）。

首先我们需要在 web 服务器端再创建如下一个接口：

```kotlin
/**
* 插座控制接口
*/
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

构建部署到服务器。

然后打开IFTTT、注册（如果还没有账户）登录，创建 Applet

**This**：选择 Google Assistant：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46126650-abd03c80-c260-11e8-8cf1-c9446bfa4f83.jpg" width="300px">
</div>

**That**：选择 Webhook：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46126688-d8845400-c260-11e8-894c-b5d3e0df143b.jpg" width="300px">
</div>

> 注意：POST 请求，在 body 中填写如上 json 数据。
> 关闭的 Applet 也是类似，把 body 中的 turnOn 改成 false 就可以了

最后，你就可以通过 “OK, Google” 唤醒 Google Assistant，然后说"Turn on plug a"来打开插座了。

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46126863-5c3e4080-c261-11e8-8e3d-1f199e647201.jpg" width="300px">
</div>

## 使用 Slack 的 Slash Command 控制

在 web 服务中再新增两个接口用于 Slash Command：

```kotlin
/**
* 插座控制接口，For Slack command line(slash commands)
*/
@PostMapping("/plug/turnon")
fun plugTurnOnForCommand(@RequestBody body: String): JSONObject {
   return JsonResult.success("text" to plugControlForCommand(body, true))

}

/**
* For Slack command line(slash commands)
*/
@PostMapping("/plug/turnoff")
fun plugTurnOffForCommand(@RequestBody body: String): JSONObject {
   return JsonResult.success("text" to plugControlForCommand(body, false))
}

/**
* For Slack command line(slash commands) control
*/
private fun plugControlForCommand(body: String, turnOn: Boolean): String {
   try {
       return body.split("&").map {
           val pair = it.split("=")
           Pair(pair[0], URLDecoder.decode(pair[1], "UTF-8"))
       }.firstOrNull {
           it.first == "text"
       }?.let {
           val dev = tuyaClientProperties.findContainsDev(it.second)
           if (null == dev) {
               "Sorry for failed command, Device named ${it.second} is not found."
           } else {
               tuyaClientService.controlPlug(dev.devId, turnOn)
               "${if (turnOn) "Turn On" else "Turn Off"} Done(${it.second})."
           }
       } ?: "Sorry for failed command, Device name required."
   } catch (e: Exception) {
       return "Sorry for failed command, ${e.message}."
   }
}
```


打开 App 设置页面的 `Slash Commands`，

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46126962-a7f0ea00-c261-11e8-808a-6ccc8a63c049.png" width="600px">
</div>

点击 `Create New Command`，

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46127140-5dbc3880-c262-11e8-97fe-75fcb05fc7df.png" width="500px">
</div>

然后在聊天的输入框中就可以通过"/"显示 command 提示，选择命令，后面跟上你要执行该命令的设备别名就行了。

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/46127236-a70c8800-c262-11e8-83a2-cdcfd8ebe10c.png" width="500px">
</div>

## 其它场景

还有其它很多场景可以实现。比如：

- 结合 IFTTT，当离开家门100m远的时候，自动触发 webhook，让你的私有云帮你把电源、智能们关闭。
- 实时检测你的位置和家门，如果你不在家，自动调用 Google Calendar 确定你的日程安排，如果又没有外出的安排，则通过 Slack 发送 Interactive messages 到你手机上提醒，提供按钮一键锁门。
- 小细节，晚上手机充电的时候，可以设定手机一旦充满，关闭电源，又如果手机电源掉电过快，低于90%的电量，重新自动开启电源，确保你早上起床的时候手机电量肯定在某个值之上。
- 等等等等，太多的智能场景可以去实现。

## 章尾

现在越来越多的厂商制作着各种各样的智能设备，但是又在自己的一亩三分地固步自封。做个插座，提供一个 app 控制下开关、定个时、做个 schedule 就是所谓的智能了，你买了我的设备就必须要用我的软硬件产品。那些需要用户花心思去考虑什么时候我该怎么的设备不是冰冷的，没有生命的么？智能是人类赋予了设备生命，掌握了“思考”的能力，现在的生活如此多元化，再牛的公司也不可能覆盖你的所有生活领域，如果买了这样的智能设备但自此被囚困在这里，我想，这才是我非智能生活的开始吧。


