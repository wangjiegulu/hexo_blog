---
title: '[Android]解决ClickableSpan中点击后ListView中item的长按冲突的问题'
tags: [android, ClickableSpan, ListView]
date: 2014-07-03 22:17:00
---

项目中碰到一个问题，情景是这样的：

有一个ListView，每个item中有一个TextView，这个TextView实现了LongClick事件，这个TextView中又添加了ClickableSpan，实现了方法onClick。

我的需求是点击ClickableSpan，则响应ClickableSpan事件；长按ClickableSpan效果跟长按TextView应该一样，都响应TextView的LongClick事件。

然而结果是点击ClickableSpan响应正常；但是长按ClickableSpan时问题出现了：TextView的长按事件响应了，ClickableSpan点击事件也响应了！

研究了一下代码，解决方法如下：

继承LinkMovementMethod，然后重写里面的onTouchEvent方法，在里面判断，如果当前是长按的状态，则不执行ClickableSpan的onClick事件：

<div class="cnblogs_code">
<pre><span style="color: #0000ff;">package</span><span style="color: #000000;"> com.kanchufang.privatedoctor.util.spannableparser;

</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.text.Layout;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.text.Selection;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.text.Spannable;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.text.method.LinkMovementMethod;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.text.style.ClickableSpan;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.view.MotionEvent;
</span><span style="color: #0000ff;">import</span><span style="color: #000000;"> android.widget.TextView;

</span><span style="color: #008000;">/**</span><span style="color: #008000;">
 * Author: wangjie
 * Email: tiantian.china.2@gmail.com
 * Date: 7/3/14.
 </span><span style="color: #008000;">*/</span>
<span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> LinkMovementClickMethod <span style="color: #0000ff;">extends</span><span style="color: #000000;"> LinkMovementMethod{

    </span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">long</span><span style="color: #000000;"> lastClickTime;

    </span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> <span style="color: #0000ff;">long</span> CLICK_DELAY = 500l<span style="color: #000000;">;

    @Override
    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> onTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
        </span><span style="color: #0000ff;">int</span> action =<span style="color: #000000;"> event.getAction();

        </span><span style="color: #0000ff;">if</span> (action == MotionEvent.ACTION_UP ||<span style="color: #000000;">
                action </span>==<span style="color: #000000;"> MotionEvent.ACTION_DOWN) {
            </span><span style="color: #0000ff;">int</span> x = (<span style="color: #0000ff;">int</span><span style="color: #000000;">) event.getX();
            </span><span style="color: #0000ff;">int</span> y = (<span style="color: #0000ff;">int</span><span style="color: #000000;">) event.getY();

            x </span>-=<span style="color: #000000;"> widget.getTotalPaddingLeft();
            y </span>-=<span style="color: #000000;"> widget.getTotalPaddingTop();

            x </span>+=<span style="color: #000000;"> widget.getScrollX();
            y </span>+=<span style="color: #000000;"> widget.getScrollY();

            Layout layout </span>=<span style="color: #000000;"> widget.getLayout();
            </span><span style="color: #0000ff;">int</span> line =<span style="color: #000000;"> layout.getLineForVertical(y);
            </span><span style="color: #0000ff;">int</span> off =<span style="color: #000000;"> layout.getOffsetForHorizontal(line, x);

            ClickableSpan[] link </span>= buffer.getSpans(off, off, ClickableSpan.<span style="color: #0000ff;">class</span><span style="color: #000000;">);

            </span><span style="color: #0000ff;">if</span> (link.length != 0<span style="color: #000000;">) {
                </span><span style="color: #0000ff;">if</span> (action ==<span style="color: #000000;"> MotionEvent.ACTION_UP) {
                    </span><span style="color: #0000ff;">if</span>(System.currentTimeMillis() - lastClickTime &lt;<span style="color: #000000;"> CLICK_DELAY){
                        link[</span>0<span style="color: #000000;">].onClick(widget);
                    }
                } </span><span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span> (action ==<span style="color: #000000;"> MotionEvent.ACTION_DOWN) {
                    Selection.setSelection(buffer,
                            buffer.getSpanStart(link[</span>0<span style="color: #000000;">]),
                            buffer.getSpanEnd(link[</span>0<span style="color: #000000;">]));
                    lastClickTime </span>=<span style="color: #000000;"> System.currentTimeMillis();
                }

                </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">true</span><span style="color: #000000;">;
            } </span><span style="color: #0000ff;">else</span><span style="color: #000000;"> {
                Selection.removeSelection(buffer);
            }
        }
        </span><span style="color: #0000ff;">return</span> <span style="color: #0000ff;">super</span><span style="color: #000000;">.onTouchEvent(widget, buffer, event);
    }

    </span><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> LinkMovementClickMethod getInstance(){
        </span><span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> sInstance){
            sInstance </span>= <span style="color: #0000ff;">new</span><span style="color: #000000;"> LinkMovementClickMethod();
        }
        </span><span style="color: #0000ff;">return</span><span style="color: #000000;"> sInstance;
    }

    </span><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span><span style="color: #000000;"> LinkMovementClickMethod sInstance;

}</span></pre>
</div>

代码很简单，按住超过500ms，则认定为是长按，则不执行ClickableSpan的onClick

&nbsp;

