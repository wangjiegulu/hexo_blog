---
title: android屏蔽返回键和home键
tags: [android, key]
date: 2012-03-08 17:04:00
---

<div class="dp-highlighter">

1.  屏蔽返回键的代码:
public boolean onKeyDown(int keyCode,KeyEvent event){
switch(keyCode){
case KeyEvent.KEYCODE_HOME:return true;
case KeyEvent.KEYCODE_BACK:return true;
case KeyEvent.KEYCODE_CALL:return true;
case KeyEvent.KEYCODE_SYM: return true;
case KeyEvent.KEYCODE_VOLUME_DOWN: return true;
case KeyEvent.KEYCODE_VOLUME_UP: return true;
case KeyEvent.KEYCODE_STAR: return true;
}
return super.onKeyDown(keyCode, event);
}

屏蔽home键的代码:
public void onAttachedToWindow() {
this.getWindow().setType(WindowManager.LayoutParams.TYPE_KEYGUARD);
super.onAttachedToWindow();
}</div>

