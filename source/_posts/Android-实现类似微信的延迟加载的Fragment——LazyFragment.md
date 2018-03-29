---
title: '[Android]实现类似微信的延迟加载的Fragment——LazyFragment'
tags: [android, LazyFragment, lazy, Fragment, wechat, 微信]
date: 2015-02-27 18:02:00
---

参考微信，使用ViewPager来显示不同的tab，每个tab是一个Fragment，

假设有3个tab，对应的fragment是FragmentA、FragmentB、FragmentC

需要实现的效果是进入后，默认先只加载FragmentA，具体滑动到了哪个Fragment，再去加载该Fragment的数据。

可以参考如下BaseLazyFragment代码：

<div class="cnblogs_code">
<pre><span style="color: #008080;">  1</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;">  2</span> <span style="color: #008000;"> * Author: wangjie
</span><span style="color: #008080;">  3</span> <span style="color: #008000;"> * Email: tiantian.china.2@gmail.com
</span><span style="color: #008080;">  4</span> <span style="color: #008000;"> * Date: 1/23/15.
</span><span style="color: #008080;">  5</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;">  6</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> BaseLazyFragment <span style="color: #0000ff;">extends</span><span style="color: #000000;"> BaseFragment {
</span><span style="color: #008080;">  7</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">static</span> <span style="color: #0000ff;">final</span> String TAG = BaseLazyFragment.<span style="color: #0000ff;">class</span><span style="color: #000000;">.getSimpleName();
</span><span style="color: #008080;">  8</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isPrepared;
</span><span style="color: #008080;">  9</span> 
<span style="color: #008080;"> 10</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 11</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onActivityCreated(Bundle savedInstanceState) {
</span><span style="color: #008080;"> 12</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onActivityCreated(savedInstanceState);
</span><span style="color: #008080;"> 13</span> <span style="color: #000000;">        initPrepare();
</span><span style="color: #008080;"> 14</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 15</span> 
<span style="color: #008080;"> 16</span> 
<span style="color: #008080;"> 17</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 18</span> <span style="color: #008000;">     * 第一次onResume中的调用onUserVisible避免操作与onFirstUserVisible操作重复
</span><span style="color: #008080;"> 19</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isFirstResume = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 21</span> 
<span style="color: #008080;"> 22</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 23</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onResume() {
</span><span style="color: #008080;"> 24</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onResume();
</span><span style="color: #008080;"> 25</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;"> (isFirstResume) {
</span><span style="color: #008080;"> 26</span>             isFirstResume = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 27</span>             <span style="color: #0000ff;">return</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 28</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 29</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;"> (getUserVisibleHint()) {
</span><span style="color: #008080;"> 30</span> <span style="color: #000000;">            onUserVisible();
</span><span style="color: #008080;"> 31</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 32</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 33</span> 
<span style="color: #008080;"> 34</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 35</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onPause() {
</span><span style="color: #008080;"> 36</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.onPause();
</span><span style="color: #008080;"> 37</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;"> (getUserVisibleHint()) {
</span><span style="color: #008080;"> 38</span> <span style="color: #000000;">            onUserInvisible();
</span><span style="color: #008080;"> 39</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 40</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 41</span> 
<span style="color: #008080;"> 42</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isFirstVisible = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 43</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span> isFirstInvisible = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 44</span> 
<span style="color: #008080;"> 45</span> <span style="color: #000000;">    @Override
</span><span style="color: #008080;"> 46</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> setUserVisibleHint(<span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isVisibleToUser) {
</span><span style="color: #008080;"> 47</span>         <span style="color: #0000ff;">super</span><span style="color: #000000;">.setUserVisibleHint(isVisibleToUser);
</span><span style="color: #008080;"> 48</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;"> (isVisibleToUser) {
</span><span style="color: #008080;"> 49</span>             <span style="color: #0000ff;">if</span><span style="color: #000000;"> (isFirstVisible) {
</span><span style="color: #008080;"> 50</span>                 isFirstVisible = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 51</span> <span style="color: #000000;">                initPrepare();
</span><span style="color: #008080;"> 52</span>             } <span style="color: #0000ff;">else</span><span style="color: #000000;"> {
</span><span style="color: #008080;"> 53</span> <span style="color: #000000;">                onUserVisible();
</span><span style="color: #008080;"> 54</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 55</span>         } <span style="color: #0000ff;">else</span><span style="color: #000000;"> {
</span><span style="color: #008080;"> 56</span>             <span style="color: #0000ff;">if</span><span style="color: #000000;"> (isFirstInvisible) {
</span><span style="color: #008080;"> 57</span>                 isFirstInvisible = <span style="color: #0000ff;">false</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 58</span> <span style="color: #000000;">                onFirstUserInvisible();
</span><span style="color: #008080;"> 59</span>             } <span style="color: #0000ff;">else</span><span style="color: #000000;"> {
</span><span style="color: #008080;"> 60</span> <span style="color: #000000;">                onUserInvisible();
</span><span style="color: #008080;"> 61</span> <span style="color: #000000;">            }
</span><span style="color: #008080;"> 62</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 63</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 64</span> 
<span style="color: #008080;"> 65</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">synchronized</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> initPrepare() {
</span><span style="color: #008080;"> 66</span>         <span style="color: #0000ff;">if</span><span style="color: #000000;"> (isPrepared) {
</span><span style="color: #008080;"> 67</span> <span style="color: #000000;">            onFirstUserVisible();
</span><span style="color: #008080;"> 68</span>         } <span style="color: #0000ff;">else</span><span style="color: #000000;"> {
</span><span style="color: #008080;"> 69</span>             isPrepared = <span style="color: #0000ff;">true</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 70</span> <span style="color: #000000;">        }
</span><span style="color: #008080;"> 71</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 72</span> 
<span style="color: #008080;"> 73</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 74</span> <span style="color: #008000;">     * 第一次fragment可见（进行初始化工作）
</span><span style="color: #008080;"> 75</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 76</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onFirstUserVisible() {
</span><span style="color: #008080;"> 77</span> 
<span style="color: #008080;"> 78</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 79</span> 
<span style="color: #008080;"> 80</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 81</span> <span style="color: #008000;">     * fragment可见（切换回来或者onResume）
</span><span style="color: #008080;"> 82</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 83</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onUserVisible() {
</span><span style="color: #008080;"> 84</span> 
<span style="color: #008080;"> 85</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 86</span> 
<span style="color: #008080;"> 87</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 88</span> <span style="color: #008000;">     * 第一次fragment不可见（不建议在此处理事件）
</span><span style="color: #008080;"> 89</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 90</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onFirstUserInvisible() {
</span><span style="color: #008080;"> 91</span> 
<span style="color: #008080;"> 92</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 93</span> 
<span style="color: #008080;"> 94</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 95</span> <span style="color: #008000;">     * fragment不可见（切换掉或者onPause）
</span><span style="color: #008080;"> 96</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 97</span>     <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span><span style="color: #000000;"> onUserInvisible() {
</span><span style="color: #008080;"> 98</span> 
<span style="color: #008080;"> 99</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">100</span> 
<span style="color: #008080;">101</span> }</pre>
</div>

如上代码，使用setUserVisibleHint方法作为回调的依据，

暴露出来让子类使用的新的生命周期方法为：

- onFirstUserVisible();

第一次fragment可见（进行初始化工作）

- onUserVisible();&nbsp;

fragment可见（切换回来或者onResume）

- onFirstUserInvisible();

第一次fragment不可见（不建议在此处理事件）

- onUserInvisible();

fragment不可见（切换掉或者onPause）

&nbsp;

具体的效果是：

1\. 首先加载ViewPager，回调FragmentA（第一个默认呈现的Fragment）的onFirstUserVisible()，可以在这里进行FragmentA的初始化工作，其他Fragment保持不变。

2\. 用户从FragmentA滑动到FragmentB，回调FragmentA的onUserInvisible()、FragmentB的onFirstUserVisible()（因为第一次切换到FragmentB，可以在这里进行初始化工作）。

3\. 用户从FragmentB滑动到FragmentC，回调FragmentB的onUserInvisible()、FragmentC的onFirstUserVisible()（因为第一次切换到FragmentC，可以在这里进行初始化工作）。

4\. 用户从FragmentC滑动到FragmentB，回调FragmentC的onUserInvisible()、FragmentB的onUserVisible()（因为FragmentB之前已经被加载过）。

5\. 因为到此为止，suoyou的Fragment都已经被加载过了，所以以后这3个Fragment互相任意切换，只会回调原来Fragment的onUserInvisible()和切换后的Fragment的onUserVisible()。

6\. 用户处于FragmentB，关闭手机屏幕，回调FragmentB的onUserInvisible()。

7.&nbsp;用户处于FragmentB，手机屏幕处关闭状态，然后开启手机屏幕解锁，只回调FragmentB的onUserVisible()。

&nbsp;

