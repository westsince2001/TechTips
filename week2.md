1. 包、帧、段、数据报、消息：
  包：全能
  帧：数据链路层中包的单位
  段：TCP数据流中的消息
  数据报：IP和UDP等网络层以上的分层中包的单位
  消息：应用协议中的数据单位
  
2. Concurrency is not Parallelism. 并发不等同于并行。并发是结构上的概念，是某一很短的时间段上同时dealing with两件事情。并行是从一个时间点上进行衡量，该时刻同时Doing两件事情。
这两个概念的差别非常微妙，从计算机的角度来讲，单核系统不存在并行，并发。而多核系统可以并发，也可以并行。
并行可以以一下两种模式来实现：

A. Blocks --> worker1 --> Factory
   Blocks --> worker2 --> Factory
   Blocks --> worker3 --> Factory
B. 
   Blocks --> worker1 --> Transfer --> worker2 -- Transfer --> worker3 --> Factory
  
