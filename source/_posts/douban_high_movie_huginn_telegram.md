---
title: Huginn实现自动通过Telegram推送豆瓣高分电影
subtitle: "正在上映的电影中有豆瓣高分电影时自动通过Telegram通知给我"
tags: ["huginn", "ifttt", "integromat", "zapier", "automate", "geek", "douban", "movies", "telegram"]
categories: ["huginn", "automate", "telegram"]
header-img: "https://images.unsplash.com/photo-1521931961826-fe48677230a5?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=ea0a29a438c74124fe8798e41faccb6a&auto=format&fit=crop&w=2250&q=80"
centercrop: false
hidden: false
copyright: true
---

# Huginn实现自动通过telegram推送豆瓣高分电影

之前博客[《Huginn实现自动通过slack推送豆瓣高分电影》](https://blog.wangjiegulu.com/2018/04/03/huginn_douban_high_score_movies_and_slack/)有讲到过通过 Huginn 来实现自动获取豆瓣正在上映中的高分（设定分数超过7.8分）电影，并且自动通过 Slack 通知给我。那么怎样通过 Telegram 来进行推送呢？

## 创建 Telegram Bot

其实跟 Slack 一样，首先需要创建一个 telegram bot，然后通过 telegram bot 来进行通知。

具体我们可以参考 telegram 的官方文档：<https://core.telegram.org/bots#6-botfather>

这里创建 Bot 的方式跟 Slack 有所不同，需要通过跟 `BotFather` 进行对话来创建，打开 telegram 客户端，搜索 `BotFather`进入对话框：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/48595853-74912880-e991-11e8-915c-7b2fbd82ccf0.png" width="400px">
</div>

给 `BotFather` 发送一个创建 Bot 的命令 `/newbot`：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/48595984-f08b7080-e991-11e8-8989-5a65de625a0c.png" width="700px">
</div>

如上图所示，通过发送 `/newbot` 命令（消息）后，`BotFather` 会回复让你进行设置 `bot` 的 `name` 和 `user_name`，其中 `username` 必须要是 `bot` 结尾，我这里 `name` 和 `username` 都设置为 `angelia_bot`。

最后 `BotFather` 会回复创建成功，并且返回你创建的机器人的 `access token`，有了`access token`我们就能给 group 或者 channel 发送消息了。

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/48596207-fa61a380-e992-11e8-9cd5-0320c69303ea.png" width="700px">
</div>

## 创建接收消息的频道Channel

接下来我们需要创建一个用来接收消息的 `Channel`（当然，你用 `Group` 也可以，如果用 `Group` 的话，很多人加进来聊天发消息会比较乱，`Channel`的话，别人订阅之后就只能接受查看消息，比较符合我们现在的场景）。

创建完之后，通过访问 <https://api.telegram.org/bot<bot-access-token\>/getUpdates>，找到刚刚创建的 `channel`，拿到这个 `channel` 的id（应该是负数的id）。

> 把上面的 url 中的 `<bot-access-token>` 替换成刚刚创建 `bot` 拿到的 `access token`

把刚刚我们创建的 `bot` 添加到我们创建的 `channel` 中：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/48596921-0733c680-e996-11e8-9190-2533727bf27d.png" width="400px">
</div>


## 创建发送 telegram 消息的 agent

之前的流程跟[《Huginn实现自动通过slack推送豆瓣高分电影》](https://blog.wangjiegulu.com/2018/04/03/huginn_douban_high_score_movies_and_slack/)中的一样，只是最后需要创建一个发送到 telegram 的 agent。

如下：创建一个 `PostAgent`：

```json
{
  "post_url": "{% credential telegram_base_url %}bot{% credential telegram_bot_token %}/sendPhoto",
  "expected_receive_period_in_days": "1",
  "content_type": "json",
  "method": "post",
  "payload": {
    "chat_id": "{% credential telegram_movie_channel_id %}",
    "photo": "{{image_url}}",
    "parse_mode": "Markdown",
    "caption": "*Title*: [<<{{title}}>>]({{detail_url}}) \n*Score*: {{score}}\n*Star*: {{star}}\n*Release*: {{release}}\n*Region*: {{region}}\n*Actors*: {{actors}}\n*Director*: {{director}}"
  },
  "headers": {
  },
  "emit_events": "false",
  "no_merge": "false",
  "output_mode": "clean"
}
```

每当检测到豆瓣上有新的上映中的电影超过7.8分，刚刚创建的 Channel 中即可查看到 `Bot` 的通知：

<div style='text-align: center;'>
    <img src="https://user-images.githubusercontent.com/5423194/48597282-0308a880-e998-11e8-8df0-7f8ac6857608.png" width="600px">
</div>

## 最后

如果你懒得上面的各种配置，ok，加入下面这个 channel，你就能收到通知啦：

> https://t.me/angelia_movies
