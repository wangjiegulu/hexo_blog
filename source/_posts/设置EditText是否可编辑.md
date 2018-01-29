---
title: 设置EditText是否可编辑
tags: []
date: 2012-06-15 10:37:00
---

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 2</span> <span style="color: #008000;">     * 设置EditText是否可编辑
</span><span style="color: #008080;"> 3</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> com.tiantian
</span><span style="color: #008080;"> 4</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> editText 要设置的EditText
</span><span style="color: #008080;"> 5</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> value 可编辑:true 不可编辑:false
</span><span style="color: #008080;"> 6</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> setEditTextEditable(EditText editText, <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> value){
</span><span style="color: #008080;"> 8</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;">(value){
</span><span style="color: #008080;"> 9</span>             editText.setFocusableInTouchMode(<span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;">10</span> <span style="color: #000000;">            editText.requestFocus();
</span><span style="color: #008080;">11</span>         }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;">12</span>             editText.setFocusableInTouchMode(<span style="color: #0000ff;">false</span><span style="color: #000000;">);
</span><span style="color: #008080;">13</span> <span style="color: #000000;">            editText.clearFocus();
</span><span style="color: #008080;">14</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">15</span>     }</pre>
</div>