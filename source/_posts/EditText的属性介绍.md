---
title: EditText的属性介绍
tags: [android, EditText]
date: 2012-10-15 11:47:00
---

EditText继承TextView，所以EditText具有TextView的属性特点，下面主要介绍一些EditText的特有的输入法的属性特点

android:layout_gravity="center_vertical"<span>：设置控件显示的位置：默认</span>top<span>，这里居中显示，还有</span>bottom

<div>android:hin<span>：Text为空时显示的文字提示信息，可通过textColorHint设置提示信息的颜色。</span></div>
<div>android:singleLine<span>：设置单行输入，一旦设置为</span>true<span>，则文字不会自动换行。</span></div>
<div>android:gray="top"&nbsp;<span>：多行中指针在第一行第一位置</span>et.setSelection(et.length());<span>：调整光标到最后一行</span></div>
<div>android:autoText&nbsp;<span>：自动拼写帮助。这里单独设置是没有效果的，可能需要其他输入法辅助才行</span></div>
<div>android:capitalize&nbsp;<span>：设置英文字母大写类型。设置如下值：sentences仅第一个字母大写；words每一个单词首字母大小，用空格区分单词；characters每一个英文字母都大写。</span></div>
<div>android:digits&nbsp;<span>：设置允许输入哪些字符。如&ldquo;1234567890.+-*/%\n()&rdquo;</span></div>
<div>android:singleLine&nbsp;<span>：是否单行或者多行，回车是离开文本框还是文本框增加新行</span>android:numeric&nbsp;<span>：如果被设置，该TextView接收数字输入。有如下值设置：integer正整数、signed带符号整数、decimal带小数点浮点数。</span></div>
<div>android:inputType:设置文本的类型</div>
<div>android:password&nbsp;<span>：密码，以小点&rdquo;.&rdquo;显示文本</span></div>
<div>android:phoneNumber&nbsp;<span>：设置为电话号码的输入方式。</span></div>
<div>android:editable&nbsp;<span>：设置是否可编辑。仍然可以获取光标，但是无法输入。</span></div>
<div>android:autoLink=&rdquo;all&rdquo;&nbsp;<span>：设置文本超链接样式当点击网址时，跳向该网址</span></div>
<div>android:textColor = "#ff8c00"<span>：字体颜色</span></div>
<div>android:textStyle="bold"<span>：字体，</span>bold, italic, bolditalic</div>
<div>android:textAlign="center"<span>：</span>EditText<span>没有这个属性，但</span>TextView<span>有</span></div>
<div>android:textColorHighlight="#cccccc"<span>：被选中文字的底色，默认为蓝色</span></div>
<div>android:textColorHint="#ffff00"<span>：设置提示信息文字的颜色，默认为灰色</span></div>
<div>android:textScaleX="1.5"<span>：控制字与字之间的间距</span></div>
<div>android:typeface="monospace"<span>：字型，</span>normal, sans, serif, monospace</div>
<div>android:background="@null"<span>：空间背景，这里没有，指透明</span></div>
<div>android:layout_weight="1"<span>：权重在控制控件显示的大小时蛮有用的。</span></div>
<div>android:textAppearance="?android:attr/textAppearanceLargeInverse"<span>：文字外观，这里引用的是系统自带的一个外观，？表示系统是否有这种外观，否则使用默认的外观。</span></div>
<div><span>&nbsp;</span></div>
<div><span>&nbsp;</span></div>
<div><span>来源:http://liangruijun.blog.51cto.com/3061169/627350</span></div>

