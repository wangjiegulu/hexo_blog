---
title: 《Kotli­n for ­androi­d Deve­lopers­》中文翻译
tags: [kotlin, Kotli­n for android Developers, 翻译]
date: 2015-11-05 12:32:00
---

<font color="#ff0000">**
以下内容为原创，欢迎转载，转载请注明
来自天天博客：<http://www.cnblogs.com/tiantianbyconan/p/4939080.html>
**</font>

之前一直在关注Kotlin和Android相关的开发，写过两篇关于Kotlin的文章，不了解Kotlin的可以看下：

- [Android]使用Kotlin+Anko开发Android（一）：http://www.cnblogs.com/tiantianbyconan/p/4800656.html
- [Android]使用Kotlin开发Android（二）：http://www.cnblogs.com/tiantianbyconan/p/4829007.html

后来在[Kotlin官网](https://kotlinlang.org/docs/reference/)上面看到了这本书《Kotlin for android developers》：
![](https://s3.amazonaws.com/titlepages.leanpub.com/kotlin-for-android-developers/large?1445802287])

这本书发布在[leanpub](https://leanpub.com/kotlin-for-android-developers)，前两周作者完成本书后，我就购买看了一遍，里面通过一个天气预报的App例子讲解了基本上Kotlin所有的语法和特性，解决了几个困扰我很久的问题。

后来打算把它翻译成中文版贡献给大家，已经翻译完成：

__Gitbook在线阅读或下载__：https://www.gitbook.com/book/wangjiegulu/kotlin-for-android-developers-zh/details
__Github地址__：https://github.com/wangjiegulu/kotlin-for-android-developers-zh

本人水平有限，大家遇到错别字、病句、翻译错误等问题[可以在Github上提issues](https://github.com/wangjiegulu/kotlin-for-android-developers-zh/issues)。不过请说明错误原因。

希望大家支持购买原版：https://leanpub.com/kotlin-for-android-developers

#### 目录

* [Introduction](README.md)
* [写在前面](xie_zai_qian_mian.md)
* [关于本书](guan_yu_ben_shu.md)
* [这本书适合你吗？](zhe_ben_shu_shi_he_ni_ma_ff1f.md)
* [关于作者](guan_yu_zuo_zhe.md)
* [介绍](jie_shao.md)
   * [什么是Kotlin？](shi_yao_shi_kotlin.md)
   * [我们通过Kotlin得到什么](wo_men_tong_guo_kotlin_de_dao_shi_yao.md)
* [准备工作](zhun_bei_gong_zuo.md)
   * [Android Studio](android_studio.md)
   * [安装Kotlin插件](an_zhuang_kotlin_cha_jian.md)
* [创建一个新的项目](chuang_jian_yi_ge_xin_de_xiang_mu.md)
   * [在Android Studio中创建一个项目](zai_android_studio_zhong_chuang_jian_yi_ge_xiang_mu.md)
   * [配置Gradle](pei_zhi_gradle.md)
   * [把MainActivity转换成Kotlin代码](ba_mainactivity_zhuan_huan_cheng_kotlin_dai_ma.md)
   * [测试是否一切就绪](ce_shi_shi_fou_yi_qie_jiu_xu.md)
* [类和函数](lei_he_han_shu.md)
   * [怎么定义一个类](zen_yao_ding_yi_yi_ge_lei.md)
   * [类继承](lei_ji_cheng.md)
   * [函数](han_shu.md)
   * [构造方法和函数参数](gou_zao_fang_fa_he_han_shu_can_shu.md)
* [编写你的第一个类](bian_xie_ni_de_di_yi_ge_lei.md)
   * [创建一个layout](chuang_jian_yi_ge_layout.md)
   * [The Recycler Adapter](the_recycler_adapter.md)
* [变量和属性](bian_liang_he_shu_xing.md)
   * [基本类型](ji_ben_lei_xing.md)
   * [变量](bian_liang.md)
   * [属性](shu_xing.md)
* Anko和扩展的函数
   * [Anko是什么？](ankoshi_shi_yao_ff1f.md)
   * [开始使用Anko](kai_shi_shi_yong_anko.md)
   * [扩展函数](kuo_zhan_han_shu.md)
* 从API中获取数据
   * [执行一个请求](zhi_xing_yi_ge_qing_qiu.md)
   * [在主线程以外执行请求](zai_zhu_xian_cheng_yi_wai_zhi_xing_qing_qiu.md)
* [数据类](shu_ju_lei.md)
   * [额外的函数](e_wai_de_han_shu.md)
   * [复制一个数据类](fu_zhi_yi_ge_shu_ju_lei.md)
   * [映射对象到变量中](ying_she_dui_xiang_dao_bian_liang_zhong.md)
   * [转换json到数据类](zhuan_huan_json_dao_shu_ju_lei.md)
   * [构建domain层](gou_jiandomain_ceng.md)
   * [在UI中绘制数据](zaiui_zhong_hui_zhi_shu_ju.md)
* [操作符重载](cao_zuo_fu_zhong_zai.md)
   * [操作符表](cao_zuo_fu_biao.md)
   * [例子](li_zi.md)
   * [扩展函数中的操作符](kuo_zhan_han_shu_zhong_de_cao_zuo_fu.md)
* [使Forecast list可点击](shi_forecast_list_ke_dian_ji.md)
* [Lambdas](lambdas.md)
   * [简化setOnClickListener()](jian_hua_setonclicklistener.md)
   * [ForecastListAdapter的click listener](forecastlistadapterde_click_listener.md)
   * [扩展语言](kuo_zhan_yu_yan.md)
* [可见性修饰符](ke_jian_xing_xiu_shi_fu.md)
   * [修饰符](xiu_shi_fu.md)
   * [构造器](gou_zao_qi.md)
   * [重构代码](zhong_gou_dai_ma.md)
* [Kotlin Android Extensions](kotlin_android_extensions.md)
   * [怎么去使用Kotlin Android Extensions](zen_yaoqu_shi_yong_kotlinandroid_extensions.md)
   * [重构我们的代码](zhong_gou_wo_men_de_dai_ma.md)
* [Application单例化和属性的Delegated](applicationdan_li_hua_he_shu_xing_de_delegated.md)
   * [Applicaton单例化](applicatondan_li_hua.md)
   * [委托属性](wei_tuo_shu_xing.md)
   * [标准委托](biao_zhun_wei_tuo.md)
   * [怎么去创建一个自定义的委托](zen_yao_qu_chuang_jian_yi_ge_zi_ding_yi_de_wei_tuo.md)
   * [重新实现Application单例化](zhong_xin_shixian_application_dan_li_hua.md)
* [创建一个SQLiteOpenHelper](chuang_jian_yi_ge_sqliteopenhelper.md)
   * [ManagedSqliteOpenHelper](managedsqliteopenhelper.md)
   * [定义表](ding_yi_biao.md)
   * [实现SqliteOpenHelper](shi_xian_sqliteopenhelper.md)
   * [依赖注入](yi_lai_zhu_ru.md)
* [集合和函数操作符](ji_he_he_han_shu_cao_zuo_fu.md)
   * [总数操作符](zong_shu_cao_zuo_fu.md)
   * [过滤操作符](guo_lv_cao_zuo_fu.md)
   * [映射操作符](ying_she_cao_zuo_fu.md)
   * [元素操作符](yuan_su_cao_zuo_fu.md)
   * [生产操作符](sheng_chan_cao_zuo_fu.md)
   * [顺序操作符](shun_xu_cao_zuo_fu.md)
* [从数据库中保存或查询数据](cong_shu_ju_ku_zhong_bao_cun_huo_cha_xun_shu_ju.md)
   * [创建数据库model类](chuang_jian_shu_ju_ku_model_lei.md)
   * [写入和查询数据库](xie_ru_he_cha_xun_shu_ju_ku.md)
* [Kotlin中的null安全](kotlinzhong_de_null_an_quan.md)
   * [可null类型怎么工作](ke_null_lei_xing_zen_yao_gong_zuo.md)
   * [可null性和Java库](ke_null_xing_he_java_ku.md)
* [创建业务逻辑来访问数据](chuang_jian_ye_wu_luo_ji_lai_fang_wen_shu_ju.md)
* [Flow control和ranges](flow_controlhe_ranges.md)
   * [If表达式](ifbiao_da_shi.md)
   * [When表达式](whenbiao_da_shi.md)
   * [For循环](forxun_huan.md)
   * [While和do/while循环](whilehe_do__while_xun_huan.md)
   * [Ranges](ranges.md)
* [创建一个详情界面](chuang_jian_yi_ge_xiang_qing_jie_mian.md)
   * [准备请求](zhun_bei_qing_qiu.md)
   * [提供一个新的activity](ti_gong_yige_xin_de_activity.md)
   * [启动一个activity：reified函数](qi_dong_yige_activity__reified_han_shu.md)
* 接口和委托
   * [接口](jie_kou.md)
   * [委托](wei_tuo.md)
   * [在我们的App中实现一个例子](zai_wo_men_de_app_zhong_shi_xian_yi_ge_li_zi.md)
* [范型](fan_xing.md)
   * [基础](ji_chu.md)
   * [变体](bian_ti.md)
   * [范型例子](fan_xing_li_zi.md)
* [设置界面](she_zhi_jie_mian.md)
   * [创建一个设置activity](chuang_jian_yi_ge_she_zhi_activity.md)
   * [访问Shared Preferences](fang_wen_shared_preferences.md)
   * [范型preference委托](fan_xing_preference_wei_tuo.md)
* [测试你的App](ce_shi_ni_de_app.md)
   * [Unit testing](unit_testing.md)
   * [Instrumentation tests](instrumentation_tests.md)
* [其它的概念](qi_ta_de_gai_nian.md)
   * [内部类](nei_bu_lei.md)
   * [枚举](mei_ju.md)
   * [密封（Sealed）类](mi_feng_lei.md)
   * [异常（Exceptions）](yi_chang_ff08_exceptions.md)
* [结尾](jie_wei.md)

