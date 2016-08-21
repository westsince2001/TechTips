##为Kubernetes构建自动伸缩控制器(AutoScaler)

###简介
=========

Kubernetes的1.3版本包含了许多可以保证你的容器化应用在生产环境中顺利运行的特性。这些特性例如水平Pod自动伸缩器（Horizontal Pod Autoscaler: HPA）仍有一点小的可行的产品。现在你仅仅可以通过CPU和内存消耗来进行伸缩（定制的伸缩度量仍是alpha版本）。

我们有一个应用是一个WebSocket服务器，它有着非常“长”链接的客户端。当对我们的应用进行性能测试时，我们发现性能瓶颈为25,000个活动的WebSocket链接，超过它我们的应用就会变得不稳定进而崩溃。当运行这个负载的时候，每个Pod并没有提高CPU负载或内存压力。这就诞生了我们通过WebSocket链接数进行扩展的需求。这篇博客讲述了我们在构建HPA时的收获。

关键字：Kubernetes; RxJS; Prediction; Scaling;

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

为了保证我们的应用不崩溃，我们实现了“可读性检测”，如果达到了WebSocket链接限制，就将我们的Pod标记为NotReady。这导致Kubernetes负载均衡器不会再向这个Pod转发流量。一旦链接总数小于链接限制，这个Pod会被再次标记为Ready，并开始接收来自Kubernetes负载均衡器转发的流量。这个过程需要“手把手”地扩展Pod，不然新的请求最终会停在负载均衡器，因为它的池里已经没有可用的Pod了。


###快速扩展
=========

当扩展的时候，我们想要确定我们可以搞定不断增长的链接数。这样的扩展应该是迅速的，甚至需要过度扩展。因为应用需要一些时间来启动生效，我们需要预测当我们的操作过程结束时最新的负载，并且我们还了解websocketConnectionCount的历史值。

我们开始想用线性预测，基于最后5个websocketConnectionCount值，但是它会导致次优预测，当连接总数按指数增加或减少时。我们然后使用npm回归库来做二元多项式回归来找到一个方程，它满足我们的连接数变化，解它之后来增加为下个值得预测。
![](https://github.com/maxwell92/TechTips/blob/master/IntroIdeas/pics/k8s-custom-hpa-scaling-up.png)
点线是预测负载
###逐渐收缩
=========

当收缩的时候我们不基于预测进行，因为可能的结果在收缩Pod的时候仍为当前负载所需要。我们也需要更加宽松，当收缩的时候，因我们断掉连接的websockets将会尝试重连。所以当我们检测到来自多项式回归预测值比上一个websocketConnectionCount小时，我们将它减少5%，并使用它作为预测值。这样收缩就会变得更长，让我们准备好返回连接。

![](https://github.com/maxwell92/TechTips/blob/master/IntroIdeas/pics/k8s-custom-hpa-scaling-down.png)
点线是减少5%后的值，因为预测比当前负载小

如果超时，这些连接将不会返回，我们仍然会收缩，以一个较低的速率。

###执行Kubernetes伸缩操作
=========

因为我们的特定的HPA运行在同一个Kubernetes集群，如果它取到一个Service令牌，来自/var/run/secrets/kubernetes.io/serviceaccount/token来访问运行在主节点上的API。使用这个令牌我们可以访问API来应用一个patch http请求，给包含我们Pods的deployment的replicas，有效地伸缩了你的应用。


###用RxJS合并
=========

我们使用RxJS，所以我们可以使用对未来事件流的功能组合，这导致非常可读的代码，如下：


```javascript
   const Rx = require('rx');
    const credentials = getKubernetesCredentials();

    Rx.Observable.interval(10 * 1000)
      .map(i => getMetricsofPods(credentials.masterUrl, credentials.token))
      .map(metrics => predictNumberOfPods(metrics, MAX_CONNECTIONS_PER_POD))
      .distinctUntilChanged(prediction => prediction)
      .map(prediction => scaleDeploymentInfiniteRetries(credentials.masterUrl, credentials.token, prediction))
      .switch()
      .subscribe(
        onNext => { },
        onError => {
          console.log(`Uncaught error: ${onError.message} ${onError.stack}`);
          process.exit(1);
        });
      // NOTE: getKubernetesCredentials(), getMetricsofPods(), predictNumberOfPods(), scaleDeploymentInfiniteRetries() left out for brevity
```

它真的是非常优雅，我们可以使用map() + swtich()来保证试着伸缩deployment(+log errors)直到它成功或者一个更新的伸缩请求被初始化。

###部分想法
=========

构建我们自己的HPA是非常有趣的。使用Kubernetes API是好的经验和例子，对于一个API是如何设计的。开始我们认为开发自己的HPA是非常巨大的工作量，但最后是非常欣慰的，对于这些碎片在一起。使用RxJS可以有穷的游戏改变者，当试着描述你的代码流，而不用杂乱地进行状态管理。综合来看，我们对于结果，我们可以说我们的预测对于真实连接工作地非常好。


##译者说
Kubernetes在1.2版本以前，对Pod的扩展和收缩由Replica Controller完成。在1.2版本及以后，将由Replica Set来完成。


##原文链接
[Building your own horizonal pod autoscaler for Kubernetes](http://markswanderingthoughts.nl/post/148836326495/building-your-own-horizontal-pod-autoscaler-for)





按需购买和弹性伸缩是云计算的两大特点。作为面向容器云计算的管理平台，Kubernetes同样很好地支持水平的扩容和缩容。那么如何为我们的Kubernetes构建自动伸缩控制器呢？让我们一起来看看Mark van Straten是怎么做的。
