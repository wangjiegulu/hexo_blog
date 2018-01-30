---
title: Android绘图操作onDraw
tags: [android, onDraw]
date: 2012-03-03 15:55:00
---

<span>做java的都知道，绘图肯定首先需要一个Canvas，然后在用Graphics在上面绘制自己想要图案。不错，Android上面也类似，你可以从一个Bitmap得到它的Canvas，进行绘制，也可以自定义一个View，用它的 Canvas。不同的时，Android里没有Graphics，而用 Paint代之，当然用法也稍有不同。以下是自定义View的一段代码：&nbsp;</span>
<span>@Override&nbsp;</span>
<span>public void onDraw(Canvas canvas) {&nbsp;</span>
<span>// 首先定义一个paint&nbsp;</span>
<span>Paint paint = new Paint();&nbsp;</span>
<span>// 绘制矩形区域-实心矩形&nbsp;</span>
<span>// 设置颜色&nbsp;</span>
<span>paint.setColor(Color.WHITE);&nbsp;</span>
<span>// 设置样式-填充&nbsp;</span>
<span>paint.setStyle(Style.FILL);&nbsp;</span>
<span>// 绘制一个矩形&nbsp;</span>
<span>canvas.drawRect(new Rect(0, 0, getWidth(), getHeight()), paint);&nbsp;</span>
<span>// 绘空心矩形&nbsp;</span>
<span>// 设置颜色&nbsp;</span>
<span>paint.setColor(Color.RED);&nbsp;</span>
<span>// 设置样式-空心矩形&nbsp;</span>
<span>paint.setStyle(Style.STROKE);&nbsp;</span>
<span>// 绘制一个矩形&nbsp;</span>
<span>canvas.drawRect(new Rect(10, 10, 50, 20), paint);&nbsp;</span>
<span>// 绘文字&nbsp;</span>
<span>// 设置颜色&nbsp;</span>
<span>paint.setColor(Color.GREEN);&nbsp;</span>
<span>// 绘文字&nbsp;</span>
<span>canvas.drawText(str, 30, 30, paint);&nbsp;</span>
<span>// 绘图&nbsp;</span>
<span>// 从资源文件中生成位图&nbsp;</span>
<span>Bitmap bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.icon);&nbsp;</span>
<span>// 绘图&nbsp;</span>
<span>canvas.drawBitmap(bitmap, 10, 10, paint);&nbsp;</span>
<span>}&nbsp;</span>
<span>以上需要注意的有三点：&nbsp;</span>
<span>1、Android中的Rect和java中的可能稍有区别，前两个参数是左上角的坐标，后两个参数是右下角的坐标（不是宽度和高度）；&nbsp;</span>
<span>2、Style.STROKE和Style.FILL外边的像素数是有区别的，这点和java里一样；&nbsp;</span>
<span>3、绘文字时，设置的坐标点为(30,30)，但绘出来后你会发现，文字的左上角坐标要比你设置的偏上，不知道是android设置的bug，还是我们有理解到坐标点的意义。</span>

Android绘图操作onDraw | 自由库&nbsp;[http://www.ziyouku.com/archives/android-operating-ondraw-drawing.html](http://www.ziyouku.com/archives/android-operating-ondraw-drawing.html)

