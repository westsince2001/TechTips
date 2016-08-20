##为Kubernetes构建自动伸缩控制器
=========
*一段简介*
Kubernetes的1.3版本包含了许多可以保证你的容器化应用在生产环境中顺利运行的特性。这些特性例如水平Pod自动伸缩器（Horizontal Pod Autoscaler: HPA）仍有一点小的可行的产品。现在你仅仅可以通过CPU和内存消耗来进行伸缩（定制的伸缩度量仍是alpha版本）。

我们有一个应用是一个WebSocket服务器，它有着非常“长”链接的客户端。当对我们的应用进行性能测试时，我们发现性能瓶颈为25,000个活动的WebSocket链接，超过它我们的应用就会变得不稳定进而崩溃。当运行这个负载的时候，每个Pod并没有提高CPU负载或内存压力。这就诞生了我们通过WebSocket链接数进行扩展的需求。这篇博客讲述了我们在构建HPA时的收获。

*原文翻译+笔记*

###Kubernetes原生HPA是怎么工作的
=========
阅读Kubernetes关于HPA的源码后发现，目前它的实现非常“简单粗暴”：

1. 计算所有Pod的CPU利用率。
2. 基于targetUtilization计算所有Pod所需的资源总额。
3. 按照计算出的副本总数进行扩展。

我想我们可以做得更好。我们自定义了HPA的一些目标如下：

1. 当前负载下应用不崩溃（即使负载超过了可用量）。
2. 快速扩展，如果需要可以过度扩展（overscale）。
3. 在扩展时考虑新应用实例的启动时间。
4. 逐渐收缩，直到当前负载低于最大可用量时停止。


###确定我们的应用不会崩溃
=========

为了保证我们的应用不崩溃，我们实现了“可读性检测”，如果达到了WebSocket链接限制，就将我们的Pod标记为NotReady。这导致Kubernetes负载均衡器不会再向这个Pod转发流量。一旦链接总数小于链接限制，这个Pod会被再次标记为Ready，并开始接收来自Kubernetes负载均衡器转发的流量。这个过程


###快速扩展
=========

###逐渐收缩
=========

###执行Kubernetes伸缩操作
=========

###用RxJS合并
=========

###部分想法
=========



##译者说
Kubernetes在1.2版本以前，对Pod的扩展和收缩由Replica Controller完成。在1.2版本及以后，将由Replica Set来完成。


##原文链接
[Building your own horizonal pod autoscaler for Kubernetes](http://markswanderingthoughts.nl/post/148836326495/building-your-own-horizontal-pod-autoscaler-for)





按需购买和弹性伸缩是云计算的两大特点。作为面向容器云计算的管理平台，Kubernetes同样很好地支持水平的扩容和缩容。那么如何为我们的Kubernetes构建自动伸缩控制器呢？让我们一起来看看Mark van Straten是怎么做的。
