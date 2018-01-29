---
title: '[工具库]JOJSONBuilder工具类——一键把多个bean对象数据转换为JSON格式数据'
tags: []
date: 2013-02-19 17:30:00
---

本人大四即将毕业的准程序员（JavaSE、JavaEE、android等）一枚，小项目也做过一点，于是乎一时兴起就写了一些工具。

我会在本博客中陆续发布一些平时可能会用到的工具。

代码质量可能不是很好，大家多担待！

代码或者思路有不妥之处，还希望大牛们能不吝赐教哈！

&nbsp;

<span>以下代码为本人原创，转载请注明：</span>

<span>本文转载，来自：[http://www.cnblogs.com/tiantianbyconan/archive/2013/02/19/2917433.html](http://www.cnblogs.com/tiantianbyconan/archive/2013/02/19/2917433.html)</span>

&nbsp;

JOJSONBuilder工具类：一键把多个域对象数据转换为JSON格式数据，方便用于数据的传输和交互。功能类似于通过Gson来生成Json数据。

**源码如下：**

<div class="cnblogs_code" onclick="cnblogs_code_show('4379b86f-99f7-4b7d-81ce-f459e2888a57')">![](http://images.cnblogs.com/OutliningIndicators/ContractedBlock.gif)![](http://images.cnblogs.com/OutliningIndicators/ExpandedBlockStart.gif)<span class="cnblogs_code_collapse">View Code </span>
<div id="cnblogs_code_open_4379b86f-99f7-4b7d-81ce-f459e2888a57" class="cnblogs_code_hide">
<pre><span style="color: #008080;">  1</span> <span style="color: #0000ff;">package</span><span style="color: #000000;"> com.wangjie.extrautil.jojsonbuilder;
</span><span style="color: #008080;">  2</span> 
<span style="color: #008080;">  3</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.reflect.Field;
</span><span style="color: #008080;">  4</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.lang.reflect.Method;
</span><span style="color: #008080;">  5</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.ArrayList;
</span><span style="color: #008080;">  6</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.Arrays;
</span><span style="color: #008080;">  7</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.Iterator;
</span><span style="color: #008080;">  8</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.List;
</span><span style="color: #008080;">  9</span> <span style="color: #0000ff;">import</span><span style="color: #000000;"> java.util.Set;
</span><span style="color: #008080;"> 10</span> 
<span style="color: #008080;"> 11</span> <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 12</span> <span style="color: #008000;"> * 
</span><span style="color: #008080;"> 13</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 14</span> <span style="color: #008000;"> * </span><span style="color: #808080;">@version</span><span style="color: #008000;"> 创建时间：2013-2-14 上午10:49:59
</span><span style="color: #008080;"> 15</span>  <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 16</span> <span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span><span style="color: #000000;"> JOJSONBuilder {
</span><span style="color: #008080;"> 17</span>     <span style="color: #0000ff;">private</span> List&lt;?&gt; list; <span style="color: #008000;">//</span><span style="color: #008000;"> 传入的List数据</span>
<span style="color: #008080;"> 18</span>     <span style="color: #0000ff;">private</span> StringBuilder result = <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 19</span>     <span style="color: #0000ff;">private</span> List&lt;String&gt; includes = <span style="color: #0000ff;">null</span>; <span style="color: #008000;">//</span><span style="color: #008000;"> 要包含的属性列表</span>
<span style="color: #008080;"> 20</span>     <span style="color: #0000ff;">private</span> List&lt;String&gt; excludes = <span style="color: #0000ff;">null</span>; <span style="color: #008000;">//</span><span style="color: #008000;"> 要排除的属性列表</span>
<span style="color: #008080;"> 21</span>     
<span style="color: #008080;"> 22</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 23</span> <span style="color: #008000;">     * 默认构造方法。&lt;br&gt;
</span><span style="color: #008080;"> 24</span> <span style="color: #008000;">     * 使用此默认的构造方法之后必须要调用setList()传入List
</span><span style="color: #008080;"> 25</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 26</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JOJSONBuilder() {
</span><span style="color: #008080;"> 27</span>         
<span style="color: #008080;"> 28</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 29</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 30</span> <span style="color: #008000;">     * 此构造方法会把list中每项的所有属性信息都会生成在json中。
</span><span style="color: #008080;"> 31</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> list 所要生成Json的List数据源
</span><span style="color: #008080;"> 32</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 33</span>     <span style="color: #0000ff;">public</span> JOJSONBuilder(List&lt;?&gt;<span style="color: #000000;"> list) {
</span><span style="color: #008080;"> 34</span>         <span style="color: #0000ff;">this</span>.list =<span style="color: #000000;"> list;
</span><span style="color: #008080;"> 35</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 36</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 37</span> <span style="color: #008000;">     * 此构造方法提供list中每项属性信息的&lt;b&gt;包含&lt;/b&gt;和&lt;b&gt;排除&lt;/b&gt;。&lt;br&gt;
</span><span style="color: #008080;"> 38</span> <span style="color: #008000;">     * &lt;ol&gt;
</span><span style="color: #008080;"> 39</span> <span style="color: #008000;">     * &lt;li&gt;使用includes，不使用excludes：只生成在includes中的信息&lt;br&gt;
</span><span style="color: #008080;"> 40</span> <span style="color: #008000;">     * &lt;li&gt;不使用includes，使用excludes：只生成不在excludes中的信息&lt;br&gt;
</span><span style="color: #008080;"> 41</span> <span style="color: #008000;">     * &lt;li&gt;既使用includes，又使用exclude(不建议)：&lt;br&gt;
</span><span style="color: #008080;"> 42</span> <span style="color: #008000;">     *  - 如果includes中和excludes中的信息不冲突，则生成不在excludes中的信息&lt;br&gt;
</span><span style="color: #008080;"> 43</span> <span style="color: #008000;">     *  - 如果includes中和excludes中的信息冲突(某个属性都出现在这两个数组中)，则冲突部分的信息还是会生成&lt;br&gt;
</span><span style="color: #008080;"> 44</span> <span style="color: #008000;">     * &lt;li&gt;includes和excludes都不使用，则会把list中每项的所有属性信息都会生成在json中
</span><span style="color: #008080;"> 45</span> <span style="color: #008000;">     * &lt;/ol&gt;
</span><span style="color: #008080;"> 46</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> list 所要生成Json的List数据源。
</span><span style="color: #008080;"> 47</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> includes 所要包含的属性名称数组。
</span><span style="color: #008080;"> 48</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> excludes 所要排除的属性名称数组。
</span><span style="color: #008080;"> 49</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 50</span>     <span style="color: #0000ff;">public</span> JOJSONBuilder(List&lt;?&gt;<span style="color: #000000;"> list, String[] includes, String[] excludes) {
</span><span style="color: #008080;"> 51</span>         <span style="color: #0000ff;">this</span>.list =<span style="color: #000000;"> list;
</span><span style="color: #008080;"> 52</span>         <span style="color: #0000ff;">this</span>.includes = <span style="color: #0000ff;">null</span> == includes || includes.length == 0 ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : Arrays.asList(includes);
</span><span style="color: #008080;"> 53</span>         <span style="color: #0000ff;">this</span>.excludes = <span style="color: #0000ff;">null</span> == excludes || excludes.length == 0 ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : Arrays.asList(excludes);
</span><span style="color: #008080;"> 54</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 55</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 56</span> <span style="color: #008000;">     * 获得正在进行生成json文件的信息来源List。
</span><span style="color: #008080;"> 57</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 58</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回正在进行生成json文件的信息来源List
</span><span style="color: #008080;"> 59</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 60</span>     <span style="color: #0000ff;">public</span> List&lt;?&gt;<span style="color: #000000;"> getList() {
</span><span style="color: #008080;"> 61</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> list;
</span><span style="color: #008080;"> 62</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 63</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 64</span> <span style="color: #008000;">     * 可使用此方法来传入、替换JOJSONBuilder对象中的List对象。
</span><span style="color: #008080;"> 65</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 66</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> list 所要生成Json的List数据源。
</span><span style="color: #008080;"> 67</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回当前JOJSONBuilder对象
</span><span style="color: #008080;"> 68</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 69</span>     <span style="color: #0000ff;">public</span> JOJSONBuilder setList(List&lt;?&gt;<span style="color: #000000;"> list) {
</span><span style="color: #008080;"> 70</span>         <span style="color: #0000ff;">this</span>.list =<span style="color: #000000;"> list;
</span><span style="color: #008080;"> 71</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 72</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 73</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 74</span> <span style="color: #008000;">     * 设置包含的属性信息。
</span><span style="color: #008080;"> 75</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 76</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> incFieldName 要包含的属性名
</span><span style="color: #008080;"> 77</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回当前JOJSONBuilder对象
</span><span style="color: #008080;"> 78</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 79</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JOJSONBuilder setIncludes(String... incFieldName) {
</span><span style="color: #008080;"> 80</span>         <span style="color: #0000ff;">this</span>.includes = <span style="color: #0000ff;">null</span> == incFieldName || incFieldName.length == 0 ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : Arrays.asList(incFieldName);
</span><span style="color: #008080;"> 81</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 82</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 83</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 84</span> <span style="color: #008000;">     * 设置排除的属性信息。
</span><span style="color: #008080;"> 85</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 86</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> excFieldName 要排除的属性名
</span><span style="color: #008080;"> 87</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回当前JOJSONBuilder对象
</span><span style="color: #008080;"> 88</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 89</span>     <span style="color: #0000ff;">public</span><span style="color: #000000;"> JOJSONBuilder setExcludes(String... excFieldName) {
</span><span style="color: #008080;"> 90</span>         <span style="color: #0000ff;">this</span>.excludes = <span style="color: #0000ff;">null</span> == excFieldName || excFieldName.length == 0 ? <span style="color: #0000ff;">null</span><span style="color: #000000;"> : Arrays.asList(excFieldName);
</span><span style="color: #008080;"> 91</span>         <span style="color: #0000ff;">return</span> <span style="color: #0000ff;">this</span><span style="color: #000000;">;
</span><span style="color: #008080;"> 92</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 93</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;"> 94</span> <span style="color: #008000;">     * 获得指定Class类型的所有属性，并打印在控制台上。
</span><span style="color: #008080;"> 95</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;"> 96</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> clazz 要获取的属性的类的Class对象。
</span><span style="color: #008080;"> 97</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回该Class对象的所有属性。
</span><span style="color: #008080;"> 98</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;"> 99</span>     <span style="color: #0000ff;">public</span> Field[] getFields(Class&lt;?&gt;<span style="color: #000000;"> clazz) {
</span><span style="color: #008080;">100</span>         Field[] fields =<span style="color: #000000;"> clazz.getDeclaredFields();
</span><span style="color: #008080;">101</span>         System.out.print("fields of the class that named " + clazz.getName() + ": "<span style="color: #000000;">);
</span><span style="color: #008080;">102</span>         <span style="color: #0000ff;">for</span><span style="color: #000000;">(Field field : fields){
</span><span style="color: #008080;">103</span>             System.out.print(field.getName() + ", "<span style="color: #000000;">);
</span><span style="color: #008080;">104</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">105</span> <span style="color: #000000;">        System.out.println();
</span><span style="color: #008080;">106</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> fields;
</span><span style="color: #008080;">107</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">108</span>     
<span style="color: #008080;">109</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">110</span> <span style="color: #008000;">     * 根据list中的对象来生成对应的json文件。
</span><span style="color: #008080;">111</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">112</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回生成的Json字符串。
</span><span style="color: #008080;">113</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@throws</span><span style="color: #008000;"> Exception 如果List检验不通过，则抛出异常。
</span><span style="color: #008080;">114</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">115</span>     <span style="color: #0000ff;">public</span> StringBuilder jsonBuild() <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception{
</span><span style="color: #008080;">116</span>         <span style="color: #008000;">//</span><span style="color: #008000;">检验传入的List是否有效</span>
<span style="color: #008080;">117</span> <span style="color: #000000;">        checkValidityList();
</span><span style="color: #008080;">118</span>         <span style="color: #008000;">//</span><span style="color: #008000;">json文件开始生成-------------------------</span>
<span style="color: #008080;">119</span>         result = <span style="color: #0000ff;">new</span><span style="color: #000000;"> StringBuilder();
</span><span style="color: #008080;">120</span>         jsonSubBuild(list); <span style="color: #008000;">//</span><span style="color: #008000;"> 递归生成</span>
<span style="color: #008080;">121</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> result;
</span><span style="color: #008080;">122</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">123</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">124</span> <span style="color: #008000;">     * 生成json可递归部分的子数据（根据某些对象组成的List来生成属性json文件）
</span><span style="color: #008080;">125</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">126</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> list 
</span><span style="color: #008080;">127</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">128</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> jsonSubBuild(List&lt;?&gt;<span style="color: #000000;"> list){
</span><span style="color: #008080;">129</span> <span style="color: #008000;">//</span><span style="color: #008000;">        Class&lt;?&gt; clazz = list.get(0).getClass(); </span><span style="color: #008000;">//</span><span style="color: #008000;"> 获取对应的Class对象</span>
<span style="color: #008080;">130</span>         Object curObj = <span style="color: #0000ff;">null</span>; <span style="color: #008000;">//</span><span style="color: #008000;"> 每次循环当前的类对象（资源）</span>
<span style="color: #008080;">131</span>         <span style="color: #0000ff;">int</span> listLength = list.size(); <span style="color: #008000;">//</span><span style="color: #008000;"> 类对象个数
</span><span style="color: #008080;">132</span> <span style="color: #008000;">//</span><span style="color: #008000;">        String simpleName = clazz.getSimpleName(); </span><span style="color: #008000;">//</span><span style="color: #008000;"> 获取类名（不含包名）</span>
<span style="color: #008080;">133</span>         
<span style="color: #008080;">134</span>         result.append("["); <span style="color: #008000;">//</span><span style="color: #008000;"> 根标签开始</span>
<span style="color: #008080;">135</span>         
<span style="color: #008080;">136</span>         <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 0; i &lt; listLength; i++<span style="color: #000000;">){
</span><span style="color: #008080;">137</span>             <span style="color: #0000ff;">if</span>(i != 0<span style="color: #000000;">){
</span><span style="color: #008080;">138</span>                 result.append(","<span style="color: #000000;">);
</span><span style="color: #008080;">139</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">140</span>             curObj =<span style="color: #000000;"> list.get(i);
</span><span style="color: #008080;">141</span>             jsonSubSubBuild(curObj, list); <span style="color: #008000;">//</span><span style="color: #008000;"> 子数据递归</span>
<span style="color: #008080;">142</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">143</span>         
<span style="color: #008080;">144</span>         result.append("]"); <span style="color: #008000;">//</span><span style="color: #008000;"> 根标签结束</span>
<span style="color: #008080;">145</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">146</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">147</span> <span style="color: #008000;">     * 生成json可递归部分的子子数据（根据某个对象来生成属性json文件）
</span><span style="color: #008080;">148</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">149</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> curObj 要生成json文件的那个对象 
</span><span style="color: #008080;">150</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> list curObj参数属于的那个List
</span><span style="color: #008080;">151</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">152</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> jsonSubSubBuild(Object curObj, List&lt;?&gt;<span style="color: #000000;"> list){
</span><span style="color: #008080;">153</span>         String fieldName = ""; <span style="color: #008000;">//</span><span style="color: #008000;"> 每次要调用的属性名</span>
<span style="color: #008080;">154</span>         String methodName = ""; <span style="color: #008000;">//</span><span style="color: #008000;"> 每次要调用的方法名</span>
<span style="color: #008080;">155</span>         Method method = <span style="color: #0000ff;">null</span>;; <span style="color: #008000;">//</span><span style="color: #008000;"> 每次要调用的方法</span>
<span style="color: #008080;">156</span>         Object value = ""; <span style="color: #008000;">//</span><span style="color: #008000;"> 每次要获得的属性值（子标签）</span>
<span style="color: #008080;">157</span>         
<span style="color: #008080;">158</span>         Class&lt;?&gt; clazz =<span style="color: #000000;"> curObj.getClass();
</span><span style="color: #008080;">159</span>         Field[] fields = getFields(clazz); <span style="color: #008000;">//</span><span style="color: #008000;"> 获得对应类型的所有变量</span>
<span style="color: #008080;">160</span>         <span style="color: #0000ff;">int</span> fieldsLength = fields.length; <span style="color: #008000;">//</span><span style="color: #008000;"> 类对象的属性数量</span>
<span style="color: #008080;">161</span>         
<span style="color: #008080;">162</span>         result.append("{"<span style="color: #000000;">);
</span><span style="color: #008080;">163</span>         <span style="color: #0000ff;">int</span> offset = 0; <span style="color: #008000;">//</span><span style="color: #008000;"> 包含的第一个属性偏移量</span>
<span style="color: #008080;">164</span>         <span style="color: #0000ff;">int</span> temp = 0<span style="color: #000000;">;
</span><span style="color: #008080;">165</span>         <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> j = 0; j &lt; fieldsLength; j++<span style="color: #000000;">){
</span><span style="color: #008080;">166</span>             fieldName = fields[j].getName(); <span style="color: #008000;">//</span><span style="color: #008000;"> 获取对应属性名</span>
<span style="color: #008080;">167</span>             
<span style="color: #008080;">168</span>             <span style="color: #0000ff;">if</span>(list == <span style="color: #0000ff;">this</span>.list){ <span style="color: #008000;">//</span><span style="color: #008000;"> 只在最外层的类的属性中进行排除包含
</span><span style="color: #008080;">169</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 使用includes，不使用excludes：只生成在includes中的信息</span>
<span style="color: #008080;">170</span>                 <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> != includes &amp;&amp; <span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> excludes){
</span><span style="color: #008080;">171</span>                     <span style="color: #0000ff;">if</span>(!<span style="color: #000000;">includes.contains(fieldName)){
</span><span style="color: #008080;">172</span>                         <span style="color: #0000ff;">continue</span><span style="color: #000000;">;
</span><span style="color: #008080;">173</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">174</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">175</span>                 
<span style="color: #008080;">176</span>                 <span style="color: #008000;">//</span><span style="color: #008000;">不使用includes，使用excludes：只生成不在excludes中的信息</span>
<span style="color: #008080;">177</span>                 <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> == includes &amp;&amp; <span style="color: #0000ff;">null</span> != excludes){ <span style="color: #008000;">//</span><span style="color: #008000;"> 只使用了不包含</span>
<span style="color: #008080;">178</span>                     <span style="color: #0000ff;">if</span><span style="color: #000000;">(excludes.contains(fieldName)){
</span><span style="color: #008080;">179</span>                         <span style="color: #0000ff;">continue</span><span style="color: #000000;">;
</span><span style="color: #008080;">180</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">181</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">182</span>                 
<span style="color: #008080;">183</span>                 <span style="color: #008000;">//</span><span style="color: #008000;">既使用includes，又使用exclude(不建议)：
</span><span style="color: #008080;">184</span>                 <span style="color: #008000;">//</span><span style="color: #008000;">- 如果includes中和excludes中的信息不冲突，则生成不在excludes中的信息
</span><span style="color: #008080;">185</span>                 <span style="color: #008000;">//</span><span style="color: #008000;">- 如果includes中和excludes中的信息冲突(某个属性都出现在这两个数组中)，则冲突部分的信息还是会生成</span>
<span style="color: #008080;">186</span>                 <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> != includes &amp;&amp; <span style="color: #0000ff;">null</span> != excludes){ <span style="color: #008000;">//</span><span style="color: #008000;"> 既使用了包含，又使用了不包含</span>
<span style="color: #008080;">187</span>                     <span style="color: #0000ff;">if</span>(!includes.contains(fieldName) &amp;&amp;<span style="color: #000000;"> excludes.contains(fieldName)){
</span><span style="color: #008080;">188</span>                         <span style="color: #0000ff;">continue</span><span style="color: #000000;">;
</span><span style="color: #008080;">189</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">190</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">191</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 记录第一个包含的属性的索引</span>
<span style="color: #008080;">192</span>                 <span style="color: #0000ff;">if</span>(0 ==<span style="color: #000000;"> temp){
</span><span style="color: #008080;">193</span>                     offset =<span style="color: #000000;"> j;
</span><span style="color: #008080;">194</span>                     temp++<span style="color: #000000;">;
</span><span style="color: #008080;">195</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">196</span> <span style="color: #008000;">//</span><span style="color: #008000;">                offset = 0 == temp++ ? j : 0;</span>
<span style="color: #008080;">197</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">198</span>             
<span style="color: #008080;">199</span>             methodName =<span style="color: #000000;"> getGetterMethodNameByFieldName(fields[j]);
</span><span style="color: #008080;">200</span>             <span style="color: #0000ff;">try</span><span style="color: #000000;"> {
</span><span style="color: #008080;">201</span>                 method = clazz.getDeclaredMethod(methodName, <span style="color: #0000ff;">new</span><span style="color: #000000;"> Class[]{});
</span><span style="color: #008080;">202</span>                 method.setAccessible(<span style="color: #0000ff;">true</span><span style="color: #000000;">);
</span><span style="color: #008080;">203</span>                 value = method.invoke(curObj, <span style="color: #0000ff;">new</span><span style="color: #000000;"> Object[]{});
</span><span style="color: #008080;">204</span>                 <span style="color: #008000;">//</span><span style="color: #008000;">*********************************************************</span>
<span style="color: #008080;">205</span>                 <span style="color: #0000ff;">if</span>(j != offset){ <span style="color: #008000;">//</span><span style="color: #008000;"> 第一个属性前面不加","</span>
<span style="color: #008080;">206</span>                     result.append(","<span style="color: #000000;">);
</span><span style="color: #008080;">207</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">208</span>                 result.append("'" + fieldName + "':"<span style="color: #000000;">);
</span><span style="color: #008080;">209</span>                 <span style="color: #0000ff;">if</span>(fields[j].getType() == List.<span style="color: #0000ff;">class</span>){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果属性是List类型</span>
<span style="color: #008080;">210</span>                     List&lt;?&gt; subList = (List&lt;?&gt;<span style="color: #000000;">)value;
</span><span style="color: #008080;">211</span>                     jsonSubBuild(subList); <span style="color: #008000;">//</span><span style="color: #008000;"> 子数据递归</span>
<span style="color: #008080;">212</span>                 }<span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span>(fields[j].getType() == Set.<span style="color: #0000ff;">class</span>){ <span style="color: #008000;">//</span><span style="color: #008000;"> 如果属性是Set类型的</span>
<span style="color: #008080;">213</span>                     Set&lt;?&gt; subSet = (Set&lt;?&gt;<span style="color: #000000;">)value;
</span><span style="color: #008080;">214</span>                     Iterator&lt;?&gt; iter =<span style="color: #000000;"> subSet.iterator();
</span><span style="color: #008080;">215</span>                     List&lt;Object&gt; subList = <span style="color: #0000ff;">new</span> ArrayList&lt;Object&gt;<span style="color: #000000;">(); 
</span><span style="color: #008080;">216</span>                     <span style="color: #0000ff;">while</span><span style="color: #000000;">(iter.hasNext()){
</span><span style="color: #008080;">217</span> <span style="color: #000000;">                        subList.add(iter.next());
</span><span style="color: #008080;">218</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">219</span>                     jsonSubBuild(subList); <span style="color: #008000;">//</span><span style="color: #008000;"> 子数据递归</span>
<span style="color: #008080;">220</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">221</span>                 <span style="color: #008000;">//</span><span style="color: #008000;"> 如果ClassLoader不是null表示该类不是启动类加载器加载的，不是Java API的类，是自己写的java类</span>
<span style="color: #008080;">222</span>                 <span style="color: #0000ff;">else</span> <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> !=<span style="color: #000000;"> fields[j].getType().getClassLoader()){ 
</span><span style="color: #008080;">223</span>                     jsonSubSubBuild(value, <span style="color: #0000ff;">null</span>); <span style="color: #008000;">//</span><span style="color: #008000;"> 子子数据递归</span>
<span style="color: #008080;">224</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">225</span>                 <span style="color: #0000ff;">else</span>{ <span style="color: #008000;">//</span><span style="color: #008000;"> 其它类型都认为是普通文本类型
</span><span style="color: #008080;">226</span>                     <span style="color: #008000;">//</span><span style="color: #008000;"> 添加子元素（类属性）标签</span>
<span style="color: #008080;">227</span>                     <span style="color: #0000ff;">if</span>(value.getClass() == String.<span style="color: #0000ff;">class</span><span style="color: #000000;">){
</span><span style="color: #008080;">228</span>                         result.append("'" + value + "'"<span style="color: #000000;">);
</span><span style="color: #008080;">229</span>                     }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;">230</span> <span style="color: #000000;">                        result.append(value.toString());
</span><span style="color: #008080;">231</span> <span style="color: #000000;">                    }
</span><span style="color: #008080;">232</span>                     
<span style="color: #008080;">233</span> <span style="color: #000000;">                }
</span><span style="color: #008080;">234</span>                 
<span style="color: #008080;">235</span>                 <span style="color: #008000;">//</span><span style="color: #008000;">*********************************************************</span>
<span style="color: #008080;">236</span>             } <span style="color: #0000ff;">catch</span><span style="color: #000000;"> (Exception e) {
</span><span style="color: #008080;">237</span> <span style="color: #000000;">                e.printStackTrace();
</span><span style="color: #008080;">238</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">239</span>             
<span style="color: #008080;">240</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">241</span>         result.append("}"<span style="color: #000000;">);
</span><span style="color: #008080;">242</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">243</span>     
<span style="color: #008080;">244</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">245</span> <span style="color: #008000;">     * &lt;ol&gt;通过属性Field对象来获取getter方法的方法名。&lt;br&gt;
</span><span style="color: #008080;">246</span> <span style="color: #008000;">     * 如果是boolean或Boolean类型(正则表达式来判断):isBorrow--&gt;isBorrow();isborrow--&gt;isIsborrow();&lt;br&gt;
</span><span style="color: #008080;">247</span> <span style="color: #008000;">     * 否则:borrow--&gt;getBorrow();
</span><span style="color: #008080;">248</span> <span style="color: #008000;">     * &lt;/ol&gt;
</span><span style="color: #008080;">249</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">250</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@param</span><span style="color: #008000;"> field 要生成getter方法的对应属性对象。
</span><span style="color: #008080;">251</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@return</span><span style="color: #008000;"> 返回getter方法的方法名。
</span><span style="color: #008080;">252</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">253</span>     <span style="color: #0000ff;">private</span><span style="color: #000000;"> String getGetterMethodNameByFieldName(Field field){
</span><span style="color: #008080;">254</span>         String methodName = <span style="color: #0000ff;">null</span><span style="color: #000000;">;
</span><span style="color: #008080;">255</span>         String fieldName =<span style="color: #000000;"> field.getName();
</span><span style="color: #008080;">256</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 解析属性对应的getter方法名
</span><span style="color: #008080;">257</span>         <span style="color: #008000;">//</span><span style="color: #008000;"> 判断是否是boolean或Boolean类型:isBorrow--&gt;isBorrow();isborrow--&gt;isIsborrow()</span>
<span style="color: #008080;">258</span>         <span style="color: #0000ff;">if</span>(field.getType() == <span style="color: #0000ff;">boolean</span>.<span style="color: #0000ff;">class</span> || field.getType() == Boolean.<span style="color: #0000ff;">class</span><span style="color: #000000;">){
</span><span style="color: #008080;">259</span>             <span style="color: #0000ff;">if</span>(fieldName.matches("^is[A-Z].*"<span style="color: #000000;">)){
</span><span style="color: #008080;">260</span>                 methodName =<span style="color: #000000;"> fieldName;
</span><span style="color: #008080;">261</span>             }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;">262</span>                 methodName = "is" + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1<span style="color: #000000;">);
</span><span style="color: #008080;">263</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">264</span>         }<span style="color: #0000ff;">else</span><span style="color: #000000;">{
</span><span style="color: #008080;">265</span>             methodName = "get" + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1<span style="color: #000000;">);
</span><span style="color: #008080;">266</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">267</span>         <span style="color: #0000ff;">return</span><span style="color: #000000;"> methodName;
</span><span style="color: #008080;">268</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">269</span>     
<span style="color: #008080;">270</span>     <span style="color: #008000;">/**</span>
<span style="color: #008080;">271</span> <span style="color: #008000;">     * 检验传入的List的合法性（List是不是为null、长度是不是为0、是不是每项都是同一个类型）
</span><span style="color: #008080;">272</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@author</span><span style="color: #008000;"> wangjie
</span><span style="color: #008080;">273</span> <span style="color: #008000;">     * </span><span style="color: #808080;">@throws</span><span style="color: #008000;"> Exception 如果List为null, 或者长度为, 或者每项不是同一个类型, 抛出异常
</span><span style="color: #008080;">274</span>      <span style="color: #008000;">*/</span>
<span style="color: #008080;">275</span>     <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">void</span> checkValidityList() <span style="color: #0000ff;">throws</span><span style="color: #000000;"> Exception{
</span><span style="color: #008080;">276</span>         <span style="color: #0000ff;">if</span>(<span style="color: #0000ff;">null</span> ==<span style="color: #000000;"> list){
</span><span style="color: #008080;">277</span>             <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> Exception("请保证传入的List不为null"<span style="color: #000000;">);
</span><span style="color: #008080;">278</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">279</span>         <span style="color: #0000ff;">int</span> size =<span style="color: #000000;"> list.size();
</span><span style="color: #008080;">280</span>         <span style="color: #0000ff;">if</span>(list.size() == 0<span style="color: #000000;">){
</span><span style="color: #008080;">281</span>             <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> Exception("请保证传入的List长度不为0"<span style="color: #000000;">);
</span><span style="color: #008080;">282</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">283</span>         <span style="color: #0000ff;">for</span>(<span style="color: #0000ff;">int</span> i = 1; i &lt; size; i++<span style="color: #000000;">){
</span><span style="color: #008080;">284</span>             <span style="color: #0000ff;">if</span>(list.get(0).getClass() !=<span style="color: #000000;"> list.get(i).getClass()){
</span><span style="color: #008080;">285</span>                 <span style="color: #0000ff;">throw</span> <span style="color: #0000ff;">new</span> Exception("请保证传入的List每项都是同一个类型"<span style="color: #000000;">);
</span><span style="color: #008080;">286</span> <span style="color: #000000;">            }
</span><span style="color: #008080;">287</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">288</span>         
<span style="color: #008080;">289</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">290</span>     
<span style="color: #008080;">291</span>     
<span style="color: #008080;">292</span>     
<span style="color: #008080;">293</span> }</pre>
</div>
</div>

&nbsp;

**使用方法如下：**

例如:
**Student类**(该类有属性name，age，isBoy，books等属性；其中books属性是一个List，存放Book对象)：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
</span><span style="color: #008080;">2</span> <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> age;
</span><span style="color: #008080;">3</span> <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isBoy;
</span><span style="color: #008080;">4</span> <span style="color: #0000ff;">private</span> List&lt;Book&gt;<span style="color: #000000;"> books;
</span><span style="color: #008080;">5</span> <span style="color: #008000;">//</span><span style="color: #008000;">并实现getter和setter方法；</span></pre>
</div>

&nbsp;

**Book类**(该类有属性name，author，number，length，width，isBorrowed等属性)：

<div class="cnblogs_code">
<pre><span style="color: #008080;">1</span> <span style="color: #0000ff;">private</span><span style="color: #000000;"> String name;
</span><span style="color: #008080;">2</span> <span style="color: #0000ff;">private</span><span style="color: #000000;"> String author;
</span><span style="color: #008080;">3</span> <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">int</span><span style="color: #000000;"> number;
</span><span style="color: #008080;">4</span> <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">float</span><span style="color: #000000;"> length;
</span><span style="color: #008080;">5</span> <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">float</span><span style="color: #000000;"> width;
</span><span style="color: #008080;">6</span> <span style="color: #0000ff;">private</span> <span style="color: #0000ff;">boolean</span><span style="color: #000000;"> isBorrowed;
</span><span style="color: #008080;">7</span> <span style="color: #008000;">//</span><span style="color: #008000;">并实现getter和setter方法；</span></pre>
</div>

&nbsp;

现在有一个List&lt;Student&gt;类型的数据，通过以下代码把该List转换为Json：

<div class="cnblogs_code">
<pre>List&lt;Student&gt; list = <span style="color: #0000ff;">new</span> ArrayList&lt;Student&gt;<span style="color: #000000;">();

</span><span style="color: #008000;">//</span><span style="color: #008000;">构建几个Student对象，放入list中
</span><span style="color: #008000;">//</span><span style="color: #008000;">&hellip;&hellip;

</span><span style="color: #008000;">//</span><span style="color: #008000;">完整数据版（不使用includes和excludes）</span>
JOJSONBuilder jsonBuilder = <span style="color: #0000ff;">new</span><span style="color: #000000;"> JOJSONBuilder(list);
String content </span>=<span style="color: #000000;"> jsonBuilder.jsonBuild().toString();

</span><span style="color: #008000;">//</span><span style="color: #008000;">或者使用包括/排除：</span>
JOJSONBuilder jsonBuilder = <span style="color: #0000ff;">new</span> JOJSONBuilder(list, <span style="color: #0000ff;">new</span> String[]{"name", "age"}, <span style="color: #0000ff;">null</span><span style="color: #000000;">);
jsonBuilder.jsonBuild().toString();

</span><span style="color: #008000;">//</span><span style="color: #008000;">或者使用方法链风格：</span>
<span style="color: #0000ff;">new</span> JOJSONBuilder().setExcludes("name", "age").jsonBuild().toString();</pre>
</div>

&nbsp;

<span>转换之后的Json（完整数据版（不使用includes和excludes））：</span>

<div class="cnblogs_code">
<pre><span style="color: #008080;"> 1</span> <span style="color: #000000;">[
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">        {
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">                'name':'hello',
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">                'age':23,
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">                'isBoy':true,
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">                'books':[
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">                                        {
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">                                                'name':'book1',
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">                                                'author':'author1',
</span><span style="color: #008080;">10</span> <span style="color: #000000;">                                                'number':123,
</span><span style="color: #008080;">11</span> <span style="color: #000000;">                                                'length':23.5,
</span><span style="color: #008080;">12</span> <span style="color: #000000;">                                                'width':18.0,
</span><span style="color: #008080;">13</span> <span style="color: #000000;">                                                'isBorrowed':true
</span><span style="color: #008080;">14</span> <span style="color: #000000;">                                        },
</span><span style="color: #008080;">15</span> <span style="color: #000000;">                                        {
</span><span style="color: #008080;">16</span> <span style="color: #000000;">                                                'name':'book2',
</span><span style="color: #008080;">17</span> <span style="color: #000000;">                                                'author':'author2',
</span><span style="color: #008080;">18</span> <span style="color: #000000;">                                                'number':43,
</span><span style="color: #008080;">19</span> <span style="color: #000000;">                                                'length':42.23,
</span><span style="color: #008080;">20</span> <span style="color: #000000;">                                                'width':30.57,
</span><span style="color: #008080;">21</span> <span style="color: #000000;">                                                'isBorrowed':false
</span><span style="color: #008080;">22</span> <span style="color: #000000;">                                        }
</span><span style="color: #008080;">23</span> <span style="color: #000000;">                                ]
</span><span style="color: #008080;">24</span> <span style="color: #000000;">        },
</span><span style="color: #008080;">25</span> 
<span style="color: #008080;">26</span> <span style="color: #000000;">        {
</span><span style="color: #008080;">27</span> <span style="color: #000000;">                'name':'world',
</span><span style="color: #008080;">28</span> <span style="color: #000000;">                'age':22,
</span><span style="color: #008080;">29</span> <span style="color: #000000;">                'isBoy':false,
</span><span style="color: #008080;">30</span> <span style="color: #000000;">                'books':[
</span><span style="color: #008080;">31</span> <span style="color: #000000;">                                        {
</span><span style="color: #008080;">32</span> <span style="color: #000000;">                                                'name':'book1',
</span><span style="color: #008080;">33</span> <span style="color: #000000;">                                                'author':'author1',
</span><span style="color: #008080;">34</span> <span style="color: #000000;">                                                'number':123,
</span><span style="color: #008080;">35</span> <span style="color: #000000;">                                                'length':23.5,
</span><span style="color: #008080;">36</span> <span style="color: #000000;">                                                'width':18.0,
</span><span style="color: #008080;">37</span> <span style="color: #000000;">                                                'isBorrowed':true
</span><span style="color: #008080;">38</span> <span style="color: #000000;">                                        },
</span><span style="color: #008080;">39</span> <span style="color: #000000;">                                        {
</span><span style="color: #008080;">40</span> <span style="color: #000000;">                                                'name':'book3',
</span><span style="color: #008080;">41</span> <span style="color: #000000;">                                                'author':'author3',
</span><span style="color: #008080;">42</span> <span style="color: #000000;">                                                'number':875,
</span><span style="color: #008080;">43</span> <span style="color: #000000;">                                                'length':20.59,
</span><span style="color: #008080;">44</span> <span style="color: #000000;">                                                'width':15.08,
</span><span style="color: #008080;">45</span> <span style="color: #000000;">                                                'isBorrowed':false
</span><span style="color: #008080;">46</span> <span style="color: #000000;">                                        },
</span><span style="color: #008080;">47</span> <span style="color: #000000;">                                        {
</span><span style="color: #008080;">48</span> <span style="color: #000000;">                                                'name':'book4',
</span><span style="color: #008080;">49</span> <span style="color: #000000;">                                                'author':'author4',
</span><span style="color: #008080;">50</span> <span style="color: #000000;">                                                'number':165,
</span><span style="color: #008080;">51</span> <span style="color: #000000;">                                                'length':22.75,
</span><span style="color: #008080;">52</span> <span style="color: #000000;">                                                'width':19.61,
</span><span style="color: #008080;">53</span> <span style="color: #000000;">                                                'isBorrowed':true
</span><span style="color: #008080;">54</span> <span style="color: #000000;">                                        }
</span><span style="color: #008080;">55</span> <span style="color: #000000;">                                ]
</span><span style="color: #008080;">56</span> <span style="color: #000000;">        }
</span><span style="color: #008080;">57</span> ]</pre>
</div>

&nbsp;

&nbsp;