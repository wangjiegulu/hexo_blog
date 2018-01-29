---
title: TextView的属性详解
tags: []
date: 2012-10-15 11:46:00
---

<div align="left">android:autoLink ：设置是否当文本为URL链接/email/电话号码/map时，文本显示为可点击的链接。可选值(none/web /email/phone/map/all)
android:autoText ：如果设置，将自动执行输入值的拼写纠正。此处无效果，在显示输入法并输入的时候起作用。
android:bufferType ： 指定getText()方式取得的文本类别。选项editable 类似于StringBuilder ：可追加字符，也就是说getText后可调用append方法设置文本内容。spannable ：则可在给定的字符区域使用样式，参见这里1、这里2。
android:capitalize ：设置英文字母大写类型。此处无效果，需要弹出输入法才能看得到，参见EditView此属性说明。
android:cursorVisible：设定光标为显示/隐藏，默认显示。
android:digits：设置允许输入哪些字符。如&ldquo;1234567890.+-*/% ()&rdquo;
android:drawableBottom：在text的下方输出一个drawable，如图片。如果指定一个颜色的话会把text的背景设为该颜色，并且同时和background使用时覆盖后者。
android:drawableLeft：在text的左边输出一个drawable，如图片。
android:drawablePadding：设置text与drawable(图片)的间隔，与drawableLeft、 drawableRight、drawableTop、drawableBottom一起使用，可设置为负数，单独使用没有效果。
android:drawableRight：在text的右边输出一个drawable。
android:drawableTop：在text的正上方输出一个drawable。
android:editable：设置是否可编辑。
android:editorExtras：设置文本的额外的输入数据。
android:ellipsize：设置当文字过长时,该控件该如何显示。有如下值设置：&rdquo;start&rdquo;&mdash;?省略号显示在开头;&rdquo;end&rdquo; &mdash;&mdash;省略号显示在结尾;&rdquo;middle&rdquo;&mdash;-省略号显示在中间;&rdquo;marquee&rdquo; &mdash;&mdash;以跑马灯的方式显示(动画横向移动)
android:freezesText：设置保存文本的内容以及光标的位置。
android:gravity：设置文本位置，如设置成&ldquo;center&rdquo;，文本将居中显示。
android:hintText：为空时显示的文字提示信息，可通过textColorHint设置提示信息的颜色。此属性在 EditView中使用，但是这里也可以用。
android:imeOptions：附加功能，设置右下角IME动作与编辑框相关的动作，如actionDone右下角将显示一个&ldquo;完成&rdquo;，而不设置默认是一个回车符号。这个在EditView中再详细说明，此处无用。
android:imeActionId：设置IME动作ID。
android:imeActionLabel：设置IME动作标签。
android:includeFontPadding：设置文本是否包含顶部和底部额外空白，默认为true。
android:inputMethod：为文本指定输入法，需要完全限定名(完整的包名)。例如：com.google.android.inputmethod.pinyin，但是这里报错找不到。
android:inputType：设置文本的类型，用于帮助输入法显示合适的键盘类型。在EditView中再详细说明，这里无效果。
android:linksClickable：设置链接是否点击连接，即使设置了autoLink。
android:marqueeRepeatLimit：在ellipsize指定marquee的情况下，设置重复滚动的次数，当设置为 marquee_forever时表示无限次。
android:ems：设置TextView的宽度为N个字符的宽度。这里测试为一个汉字字符宽度
android:maxEms：设置TextView的宽度为最长为N个字符的宽度。与ems同时使用时覆盖ems选项。
android:minEms：设置TextView的宽度为最短为N个字符的宽度。与ems同时使用时覆盖ems选项。
android:maxLength：限制显示的文本长度，超出部分不显示。
android:lines：设置文本的行数，设置两行就显示两行，即使第二行没有数据。
android:maxLines：设置文本的最大显示行数，与width或者layout_width结合使用，超出部分自动换行，超出行数将不显示。
android:minLines：设置文本的最小行数，与lines类似。
android:lineSpacingExtra：设置行间距。
android:lineSpacingMultiplier：设置行间距的倍数。如&rdquo;1.2&rdquo;
android:numeric：如果被设置，该TextView有一个数字输入法。此处无用，设置后唯一效果是TextView有点击效果，此属性在EdtiView将详细说明。
android:password：以小点&rdquo;.&rdquo;显示文本
android:phoneNumber：设置为电话号码的输入方式。
android:privateImeOptions：设置输入法选项，此处无用，在EditText将进一步讨论。
android:scrollHorizontally：设置文本超出TextView的宽度的情况下，是否出现横拉条。
android:selectAllOnFocus：如果文本是可选择的，让他获取焦点而不是将光标移动为文本的开始位置或者末尾位置。 TextView中设置后无效果。
android:shadowColor：指定文本阴影的颜色，需要与shadowRadius一起使用。
android:shadowDx：设置阴影横向坐标开始位置。
android:shadowDy：设置阴影纵向坐标开始位置。
android:shadowRadius：设置阴影的半径。设置为0.1就变成字体的颜色了，一般设置为3.0的效果比较好。
android:singleLine：设置单行显示。如果和layout_width一起使用，当文本不能全部显示时，后面用&ldquo;&hellip;&rdquo;来表示。如android:text="test_ singleLine "
android:singleLine="true" android:layout_width="20dp"将只显示&ldquo;t&hellip;&rdquo;。如果不设置singleLine或者设置为false，文本将自动换行
android:text：设置显示文本.
android:textAppearance：设置文字外观。如 &ldquo;?android:attr/textAppearanceLargeInverse&rdquo;这里引用的是系统自带的一个外观，?表示系统是否有这种外观，否则使用默认的外观。可设置的值如下：textAppearanceButton/textAppearanceInverse/textAppearanceLarge/textAppearanceLargeInverse/textAppearanceMedium/textAppearanceMediumInverse/textAppearanceSmall/textAppearanceSmallInverse
android:textColor：设置文本颜色
android:textColorHighlight：被选中文字的底色，默认为蓝色
android:textColorHint：设置提示信息文字的颜色，默认为灰色。与hint一起使用。
android:textColorLink：文字链接的颜色.
android:textScaleX：设置文字之间间隔，默认为1.0f。
android:textSize：设置文字大小，推荐度量单位&rdquo;sp&rdquo;，如&rdquo;15sp&rdquo;
android:textStyle：设置字形[bold(粗体) 0, italic(斜体) 1, bolditalic(又粗又斜) 2] 可以设置一个或多个，用&ldquo;|&rdquo;隔开
android:typeface：设置文本字体，必须是以下常量值之一：normal 0, sans 1, serif 2, monospace(等宽字体) 3]
android:height：设置文本区域的高度，支持度量单位：px(像素)/dp/sp/in/mm(毫米)
android:maxHeight：设置文本区域的最大高度
android:minHeight：设置文本区域的最小高度
android:width：设置文本区域的宽度，支持度量单位：px(像素)/dp/sp/in/mm(毫米)，与layout_width 的区别看这里。
android:maxWidth：设置文本区域的最大宽度
android:minWidth：设置文本区域的最小宽度</div>
<div>&nbsp;</div>

附件：Android中的长度单位详解

Android中的长度单位详解（dp、sp、px、in、pt、mm）有很多人不太理解dp、sp 和px 的区别：现在这里介绍一下dp 和sp。dp 也就是dip。这个和sp 基本类似。如果设置表示长度、高度等属性时可以使用dp 或sp。但如果设置字体，需要使用sp。dp 是与密度无关，sp 除了与密度无关外，还与scale 无关。如果屏幕密度为160，这时dp 和sp 和px 是一样的。1dp=1sp=1px，但如果使用px 作单位，如果屏幕大小不变（假设还是3.2 寸），而屏幕密度变成了320。那么原来TextView 的宽度设成160px，在密度为320 的3.2 寸屏幕里看要比在密度为160 的3.2 寸屏幕上看短了一半。但如果设置成160dp 或160sp 的话。系统会自动将width 属性值设置成320px 的。也就是160 * 320 / 160。其中320 / 160 可称为密度比例因子。也就是说，如果使用dp 和sp，系统会根据屏幕密度的变化自动进行转换。

其他单位的含义
px：表示屏幕实际的象素。例如，320*480 的屏幕在横向有320个象素，在纵向有480 个象素。
in：表示英寸，是屏幕的物理尺寸。每英寸等于2.54 厘米。例如，形容手机屏幕大小，经常说，3.2（英）寸、3.5（英）寸、4（英）寸就是指这个单位。这些尺寸是屏幕的对角线长度。如果手机的屏幕是3.2 英寸，表示手机的屏幕（可视区域）对角线长度是3.2*2.54 = 8.128 厘米。读者可以去量一量自己的手机屏幕，看和实际的尺寸是否一致。
mm：表示毫米，是屏幕的物理尺寸。
pt：表示一个点，是屏幕的物理尺寸。大小为1 英寸的1/72。

&nbsp;

&nbsp;
来源：http://liangruijun.blog.51cto.com/3061169/627123