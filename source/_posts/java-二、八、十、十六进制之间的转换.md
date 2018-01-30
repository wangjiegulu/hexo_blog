---
title: '[java]二、八、十、十六进制之间的转换'
tags: [java]
date: 2013-01-29 12:37:00
---

int n1 = 14;
    //十进制转成十六进制：
    Integer.toHexString(n1);
    //十进制转成八进制
    Integer.toOctalString(n1);
    //十进制转成二进制
    Integer.toBinaryString(12);

    //十六进制转成十进制
    Integer.valueOf("FFFF",16).toString();
    //十六进制转成二进制
    Integer.toBinaryString(Integer.valueOf("FFFF",16));
    //十六进制转成八进制
    Integer.toOctalString(Integer.valueOf("FFFF",16));

    //八进制转成十进制
    Integer.valueOf("576",8).toString();
    //八进制转成二进制
    Integer.toBinaryString(Integer.valueOf("23",8));
    //八进制转成十六进制
    Integer.toHexString(Integer.valueOf("23",8));

    //二进制转十进制
    Integer.valueOf("0101",2).toString();
    //二进制转八进制
    Integer.toOctalString(Integer.parseInt("0101", 2));
    //二进制转十六进制
    Integer.toHexString(Integer.parseInt("0101", 2));

