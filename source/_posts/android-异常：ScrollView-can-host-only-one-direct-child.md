---
title: android 异常：ScrollView can host only one direct child
tags: [android, exception, ScrollView]
date: 2012-05-22 09:19:00
---

android 采用ScrollView布局时出现异常：<span>ScrollView can host only one direct child</span>。

主要是<span>ScrollView内部只能有一个子元素，即不能并列两个子元素</span>，所以需要把所有的子元素放到一个LinearLayout内部或RelativeLayout等其他布局方式。

