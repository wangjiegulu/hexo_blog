---
title: 理解 CI 和 CD 之间的区别（翻译）
subtitle: ""
tags: ["CI", "Continuous Integration", "持续集成", "CD", "Continuous Delivery", "持续交付", "Continuous Deployment", "持续部署"]
categories: ["ci", "cd"]
header-img: "https://images.unsplash.com/photo-1512758017271-d7b84c2113f1?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=9a027edb5b7b5ef475a0a4441a54b630&auto=format&fit=crop&w=2100&q=80"
centercrop: false
hidden: false
copyright: true
---

# 理解 CI 和 CD 之间的区别

> 原文：<https://thenewstack.io/understanding-the-difference-between-ci-and-cd/?utm_source=wanqu.co&utm_campaign=Wanqu+Daily&utm_medium=website>

有很多关于持续集成（CI）和持续交付（CD）的资料。很多文章用技术术语来进行解释，以及它们怎么帮助你的组织。可惜的是，在一些情况下，这些方法通常与特定工具、甚至供应商相关联。在公司食堂里非常常见的谈话可能是：

1. 你在你们团队里面使用持续集成吗？
2. 当然，我们使用 X 工具

*让我来告诉你一些秘密*。持续集成和持续交付都是开发方法。它们没有链接到特定的工具或者供应商。尽管有DO（比如[Codefresh](https://codefresh.io/)）这样的工具和解决方法在这两方面帮助你，实际上，一个公司可以只使用 Bash 脚本和 Perl one-liners（不是真的使用，但是有可能的）来练习 CI / CD。

所以，我们不会陷入使用工具和技术术语来解释 CI / DI 的陷阱，我们将用最重要的东西来解释：人！

## 关于人的故事 — 软件集成的黑暗时代

Alice, Bob, Charlie, David, 和 Elizabeth，他们都在 `SoftwareCo` 公司。开发 `SuperBigProject` 应用。Alice, Bob, 和 Charlie 是开发者。David 是一个测试工程师。Elizabeth 是团队的项目经理。

开发应用的传统方法如下：

Alice, Bob, 和 Charlie 在它们各自的工作区，工作在3个不同的 feature。每个开发人员都以各自的方法编写和测试代码。他们使用一个长周期的 feature 分支，在它们合并进生产之前可能存在几周或者甚至几个月。

<div style='text-align: center;'>
    <image src='https://cdn.thenewstack.io/media/2018/08/8b059cb3-codefresh1.png' width='600px'/>
</div>

在某个时间点，Elizabeth（PM）召集整个团队，并宣布：“各位，我们需要构建一个 Release”。

此时，Alice, Bob, 和 Charlie 争先恐后地集成所有3个 feature 分支到同一个分支中。这是一个非常紧张的时刻，因为这些分支之前并没有合并一起进行测试过。由于错误的假设或者环境原因，会出现很多bug和问题（请记住，目前为止，所有 feature 仅仅在各自的工作站中进行过测试，彼此是隔离的）。

一旦这个高度紧张的时期结束了，合并的结果将传递给将执行额外的手动和自动测试的 David，此期间也很耗时, 因为他是可以根据发现的决定性 bug 的数量来批准或阻止发布的人。当他测试时, 所有的目光都落在了大卫身上, 因为他的测试可以暴露出严重的问题, 会导致 Release 的 delay。

最后，测试结束了，Elizabeth 高兴地宣布，该版本已经打包好，并运往客户。

那么，人们面对这个虚构的（又非常现实）的故事是什么感受呢？

1. Alice, Bob, 和 Charlie（开发）都不高兴，因为他们总是在发布即将发生之前了解集成问题。集成期感觉就像交火, 同一时刻出现很多问题。
2. David（测试）也不高兴，因为他的工作实在不平衡。当他在等待开发在 feature 完成它们的工作的时候是和平时期。然后在测试阶段他陷于测试工作中，需要处理意想不到的测试场景，并且每个人都站在他的肩旁上看他。
3. Elizabeth（管理人员）也不高兴。集成阶段是项目的关键路径。这是一个紧张的时期, 任何意想不到的问题,都会阻碍推动产品的进一步交付。Elizabeth 一直梦想软件发布没有任何意外情况, 但这在现实中从来不会发生。项目时间线中的集成阶段总变成一个猜谜游戏。

团队的每个人都不高兴（顺便一提，如果你的公司仍然在这样开发软件，请尝试了解这种开发工作流对团队的士气造成的损害）。

这里的主要问题是**单一**的“集成”阶段发生在每个产品发布。这是工作流的难点，它阻碍了团队进行无压力发布过程。

## 在集成中增加“持续”

现在我们已经知道了什么是“集成”，很容易理解“持续集成”的需要之处。俗话说，“[如果某事是痛苦的，那就多做它](https://martinfowler.com/bliki/FrequencyReducesDifficulty.html)”。持续集成实质上是通过高频率的重复集成步骤减轻它的痛苦。最显而易见的方法就是在每次 feature 合并后进行集成（而不是在宣布正式 release 之前等待）。


<div style='text-align: center;'>
    <image src='https://cdn.thenewstack.io/media/2018/08/cdc82f2b-codefresh2.png' width='600px'/>
</div>

当一个团队实践持续集成...

1. 所有 feature 分支都直接合并到主分支（主线）中。
2. 开发人员不是孤立工作的。所有 feature 都是从主线开始开发的。
3. 如果主线是健康的，而不是在它单独的工作站上工作，则一项 feature 被视为已完成。
4. 测试在 feature 级别和主线级别都会被触发。

这些是持续集成的要点！当然，还有更多的细节（实际上关于这个主题有一本[完整的书籍](https://martinfowler.com/books/duvall.html)）。但是重要的一点是，所有合并和测试并不是在一个单一的有压力的集成时刻，集成一直在连续的时刻发生。

持续集成是开发软件的一种更好的方法（相比于“简单”集成），因为它：

1. 减少在合并 feature 时出现的意外次数。
2. 解决“在我的机子上没问题”的问题
3. 将测试周期切片到每个 feature 逐渐合并到主线中的阶段（而不是一次性的）。

其结果就是，一个使用 CI 的团队不是生活在过山车上 (在开发时期很平静，伴随着的是有压力的 release)，而是可以在如何接近完成项目的渐进方式中得到更好的可见性。

利用 CI 工作是现代软件开发的支柱之一。这一点上，该技术被非常好的记录和知晓。如果现在你们的软件项目中还没有实践 CI，你的组织没有任何借口不去实践它。

## 软件交付的黑暗时代

现在我们知道了 “集成” 的历史，以及持续集成的工作原理，我们可以将它带到一个下一级，持续交付。

如果我们回到原来的故事，我们可以看到类似模式的发布方式正在发生：

<div style='text-align: center;'>
    <image src='https://cdn.thenewstack.io/media/2018/08/8d8eb43f-codefresh3.png' width='600px'/>
</div>

执行 Release 发布实质上是一个“大爆炸”事件。在软件被认为已经测试过，有人会负责包装和部署的过程。部署软件到生产也是一个非常有压力的阶段，传统来说会涉及到很多手动的步骤（和 checklists）。部署可能是很少次的（有的公司每六个月才会部署一次）。在极端情况下，部署可能只发生一次（瀑布流设计方法）。

只有到 deadline 时才交付软件，这会出现与不频繁集成一样的挑战：

1. 通常发现生产环境与需要在最后一刻进行额外配置的测试环境不同。
2. 在测试环境中工作正常的功能在生产中被发现问题。
3. 在发布时还没有准备就绪的功能，或者根本就不会交付给客户，或者他们进一步推迟发布日期。
4. 发布导致开发人员（想要发布新功能）和运营（想要稳定，不想一次部署太多的新功能）之间的关系变得紧张。

你应该能理解这里的模式。如果我们通过更频繁地来缓解“集成”阶段的痛苦，我们也可以为“交付”阶段做同样的事情。

## 在交付中增加“持续”

持续交付是尽可能频繁地组装和准备软件（就像它会被发布到生产那样）的实践。最极端的交付方式是在每个 feature 合并之后。

<div style='text-align: center;'>
    <image src='https://cdn.thenewstack.io/media/2018/08/3219a4ee-codefresh4.png' width='600px'/>
</div>

因此，CD，让 CI 走得更远一步。在每个 feature 合并到主线中，软件不仅要测试正确性，而且也要包装和部署到测试环境（比较理想地符合生产环境）。所有这一切都是以完全自动化的方式。注意，上图中缺少的草图 (表示手动步骤)。

还要注意，每个 feature 都是推送到生产的潜在**候选者**。不是所有候选人都会被发送到生产。根据组织，部署到生产的决定需要人工干预，人类只决定一个 release 是否应该发送到生产（但不会准备这个 release 本身）。这个 release 在测试环境已经被打包，测试和部署。

持续交付比持续集成更难采用。其原因是因为每个发布候选者都有可能达到生产，因此需要自动化整个生命周期：

1. 构建应该是可重复性和确定性的。
2. 所有 release 步骤应该都是自动化的（它比听起来更难）。
3. 所有的配置和关联的文件都应该存在于代码控制中 (而不仅仅是源代码)。
4. 每个 feature / release 都应该在它的测试环境中被测试过（以动态方式创建和销毁的理想方法）。
5. 所有测试套件都应自动化且相对快速（它也是比听起来更难）。

虽然云当然可以帮助满足所有这些要求，但在软件团队 (开发人员和运营部门) 中需要一定程度的纪律，以便真正拥抱持续交付。

一旦 CD 落地，发布会变得微不足道，因为它们可以按个按钮就能执行。每个人（不仅仅是项目经理）都具有 release candidate *（译者：release 候选版本，以下对此术语不做翻译）*的可见性。当前的 release candidate 可能没有所有请求的功能，或者说它可能无法满足所有的要求，但是这对于发布过程来说并不重要。重要的其实是这个 release 是完整测试和打包的，准备就绪发送到生产（如果需要）。任何项目的相关人员可以给出绿灯并立即把 release 部署到生产。

如果你使用 CD，则软件的生命周期可以概括成如下：

<div style='text-align: center;'>
    <image src='https://cdn.thenewstack.io/media/2018/08/077b76c5-codefresh5.png' width='600px'/>
</div>

每个 release candidate 都是预先预备好的。一个人决定是否一个 release candidate 版本是否推送到生产。没有推送到生产的 Release Candidate 仍然会作为一个 artifact 储存起来，如果将来有需要可以进行召回。

就像持续集成一样，如果你想知道更多的细节，这里有[整本围绕持续交付的书籍](https://martinfowler.com/books/continuousDelivery.html)。

## 额外奖励：持续部署

CD 中的 “D” 也可以表示部署（Deployment）。这种开发方法建立在持续交付上, 基本上完全消除了所有人类干预。任何被发现准备就绪的 release candidate （并且通过所有质量测试）都会*立即*推送到生产。

<div style='text-align: center;'>
    <image src='https://cdn.thenewstack.io/media/2018/08/cd81028d-codefresh6.png' width='600px'/>
</div>

不可否认的是，只有极少数的公司可以这样做。没有人类干预直接推送到生产应该不能掉以轻心。在撰写这篇文章时，许多公司甚至都没有实践持续交付，更别说部署了。现在应该清楚的是，每种开发方法都需要建立在之前那些基础之上。

<div style='text-align: center;'>
    <image src='https://cdn.thenewstack.io/media/2018/08/9b53d1f0-codefresh7.png' width='600px'/>
</div>

在向上移动之前（译者：按上图向上移动），你的组织应该确保每个基础都是真正稳固的。在 Codefresh，我们已经看到了很多公司试图进入云时代，在他们没有真正的理解 CI/CD 管道时试图硬塞进现有的做法（为数据中心进行优化），并且其中一些做法现在已经过时。尝试采用持续部署而不完全拥抱持续交付是一场失败的战役。

另一种方法是查看这些方法涵盖的内容以及 CD 需要 CI 的方式,，如下图所示：

<div style='text-align: center;'>
    <image src='https://cdn.thenewstack.io/media/2018/08/f600b7cb-codefresh8.png' width='600px'/>
</div>

请确保以正确的顺序处理每个开发模式。针对持续交付是一个更现实的目标，可选的工具也很丰富。

