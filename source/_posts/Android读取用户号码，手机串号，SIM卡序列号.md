---
title: Android读取用户号码，手机串号，SIM卡序列号
tags: []
date: 2012-03-08 16:58:00
---

1、使用TelephonyManager提供的方法，核心代码:

TelephonyManager tm = (TelephonyManager) this.getSystemService(TELEPHONY_SERVICE);
String imei = tm.getDeviceId();&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; //取出IMEI
Log.d(TAG, "IMEI:"+imei);
String tel = tm.getLine1Number();&nbsp;&nbsp;&nbsp;&nbsp; //取出MSISDN，很可能为空
Log.d(TAG, "MSISDN:"+tel);
String iccid =tm.getSimSerialNumber();&nbsp; //取出ICCID
Log.d(TAG, "ICCID:"+iccid);
String imsi =tm.getSubscriberId();&nbsp;&nbsp;&nbsp;&nbsp; //取出IMSI
Log.d(TAG, "IMSI:"+imsi);

2、加入权限

在manifest.xml文件中要添加 &lt;uses-permission android:name="android.permission.READ_PHONE_STATE" /&gt;