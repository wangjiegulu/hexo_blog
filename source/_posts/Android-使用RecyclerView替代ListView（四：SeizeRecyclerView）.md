---
title: '[Android]使用RecyclerView替代ListView（四：SeizeRecyclerView）'
tags: [android, RecyclerView, ListView, best practices, SeizeRecyclerView]
date: 2017-03-29 21:09:00
---

# [Android]使用RecyclerView替代ListView（四：SeizeRecyclerView）

在RecyclerView的开发过程中，可能会遇到一些窘境，比如，下图是今日头条的视频详情页面：

<!-- more -->

![](http://images2015.cnblogs.com/blog/378300/201703/378300-20170329202135217-815673664.png) ![](http://images2015.cnblogs.com/blog/378300/201703/378300-20170329202140514-614081911.png)

除去播放器外，其它组件应该是一个RecyclerView，但是这个RecyclerView中的item有两种类型：

- 一种是上部的推荐视频

- 一种是下面的评论

问题在于两类数据的最下面都有一个组件用于进行更多数据的加载，加载完毕后插入对应的position。

这里实现的方式应该怎么做呢？方法有很多，比如：

- 所有数据放在一个List中，保存加载更多的index，点击加载更多的index的时候触发请求返回后把推荐更多数据插入对应的index中并更新index，评论也是一样。。

- 推荐视频和评论保存在两个不同的List中，在Adapter中维护两份数据，重写`getItemCount()`等方法。

- ...

但是这些方法在以后业务的扩展和灵活性等方面都不值得提倡。因为就算是以后的业务只是想把推荐视频和评论两大块互换位置（虽然这个业务场景可能性不大）都是一个不小的工作量。

原因在于，默认情况下一个`RecyclerView`只会有一个`Adapter`来进行数据的适配，这样的话，如果数据分成了几个块（推荐视频和评论），单个`Adapter`的控制能力就很有限了。

设想一下，如果一个`RecyclerView`可以有很多个`Adapter`来进行数据的适配的话，那问题是不是迎刃而解了？

`RecyclerView`中有`RecommendAdapter`和`CommentAdapter`，`RecommendAdapter`中维护一个`List<Recommend>`数据集，`CommentAdapter`中维护了一个`List<Comment>`数据集，每个`Adapter`中可以设置`Header`和`Footer`，把加载更多的组件作为一个`Footer`加在`RecommendAdapter`和`CommentAdapter`中，然后响应点击事件，请求到数据之后`recommendAdapter.addList(List<Recommend>)`加入到推荐视频的数据集中，然后`recommendAdapter.notifyDataSetChanged()`，评论的数据加载也是如此。

于是根据这个思想，**[SeizeRecyclerView](https://github.com/wangjiegulu/SeizeRecyclerView)** 编写完成，下面以电影详情为例，界面与上面的视频详情一样，整个`RecyclreView`被分为两个部分：**演员区域(Actor)**和**评论区域(Comment)**。

使用方式如下：

引入 **[SeizeRecyclerView](https://github.com/wangjiegulu/SeizeRecyclerView) 库：<https://github.com/wangjiegulu/SeizeRecyclerView>**，后续会上传到Maven中心库

```java
feedRv = (RecyclerView) findViewById(R.id.activity_main_rv);

// RecyclerView真正的Adapter
adapter = new FeedAdapter();
// 为真正的Adapter增加Header和Footer
adapter.setHeader(headerView = inflaterHeaderOrFooterAndBindClick(R.layout.header_film));
adapter.setFooter(footerView = inflaterHeaderOrFooterAndBindClick(R.layout.footer_film));

// 为真正的Adapter绑定各种seizeAdapter，这里的顺序决定了UI上显示的顺序
adapter.setSeizeAdapters(
        filmActorSeizeAdapter = new FilmActorSeizeAdapter(),
        filmCommentSeizeAdapter = new FilmCommentSeizeAdapter()
);

// 设置演员seize adapter的 header 和 footer
filmActorSeizeAdapter.setHeader(actorHeaderView = inflaterHeaderOrFooterAndBindClick(R.layout.header_film_actor));
filmActorSeizeAdapter.setFooter(actorFooterView = inflaterHeaderOrFooterAndBindClick(R.layout.footer_film_actor));

// 设置评论seize adapter的 header 和 footer
filmCommentSeizeAdapter.setHeader(commentHeaderView = inflaterHeaderOrFooterAndBindClick(R.layout.header_film_comment));
filmCommentSeizeAdapter.setFooter(commentFooterView = inflaterHeaderOrFooterAndBindClick(R.layout.footer_film_comment));

LinearLayoutManager layoutManager = new LinearLayoutManager(this);
layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
feedRv.setLayoutManager(layoutManager);

// 为RecyclerView设置真正的adapter
feedRv.setAdapter(adapter);
```

以上是RecylerView的初始化，并为`Adapter`添加两个`SeizeAdapter`（`FilmActorSeizeAdapter`和`FilmCommentSeizeAdapter`）。

请求完数据之后直接使用`SeizeAdapter`进行数据的填充和`notifyDataSetChanged`：

```java
public void onRequestActors(List<ActorVM> list) {
    filmActorSeizeAdapter.addList(list);
    filmActorSeizeAdapter.notifyDataSetChanged();
}

public void onRequestComment(List<CommentVM> list) {
    filmCommentSeizeAdapter.addList(list);
    filmCommentSeizeAdapter.notifyDataSetChanged();
}
```

后续会增加 [SeizeRecyclerView](https://github.com/wangjiegulu/SeizeRecyclerView) 详细的使用说明。

最后效果如下：

![](https://github.com/wangjiegulu/SeizeRecyclerView/raw/master/screenshot/basic.gif) ![](https://github.com/wangjiegulu/SeizeRecyclerView/raw/master/screenshot/multi_type.gif)

