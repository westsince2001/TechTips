原文链接：https://pracucci.com/graceful-shutdown-of-kubernetes-pods.htjoml

Kubernetes的“优雅的停止”特性


Docker容器可能被随时终止，由于自动扩、缩容略、Pod或者Deployment(1)升级或回滚过程中的删除操作。在大多数情况下，我们可能需要
优雅的停止正在容器中运行的应用程序。

说说我们遇到的情况，我们想等到所有的当前请求（或者任务已经处理）完成，但是需要优雅的停止的原因有很多，
其中包括释放资源，分布式锁和打开的连接等等。


### 工作原理

当一个Pod将要被停止时：

* 每个容器的主进程（PID 1)会受到一个SIGTERM信号，和一个“优雅的时间周期”的计数器开始计数（默认是30秒，下面会讲如何修改它）

* 当主进程收到SIGTERM信号，每个容器开始执行优雅停止定义的任务然后退出

* 如果在这http://kubernetes.io/docs/user-guide/pods/#termination-of-pods个“优雅的时间周期”内容器没有停止，会向它发送SIGKILL信号，让该容器强制停止

更加详细的信息请查看下面的文档：

* (Kubernetes: Termination of pods)[http://kubernetes.io/docs/user-guide/pods/#termination-of-pods]

* (Kubernetes: Pods lifecycle hooks and termination notice)[http://kubernetes.io/docs/user-guide/production-pods/#lifecycle-hooks-and-termination-notice]

* (Kubernetes: Container lifecycle hooks)[http://kubernetes.io/docs/user-guide/container-environment/]

### 一个常见的错误:使用SIGTERM信号。

我们在编写Dockerfile通常会使用CMD命令来结束shell表单：

```bash
CMD myapp
```

这个shell表单会运行/bash/sh -c myapp命令，所以收到信号的进程实际上是/bin/sh而不是它的子进程
myapp。实际运行中的脚本决定会不会将这个信号传递给它的子进程。例如，在默认的情况下，继承自Alpine
Linux的容器不会将信号传递给它的子进程，但是Bash会传递。如果你的shell没有将系统传递给子进程，
你拥有一系列的选项来确保子进程收到信号。

### 选项一：从exec表单执行CMD命令

可以显式的在exec表单中使用CMD命令，它会运行myapp而不是/bin/sh -c myapp，但是它不允许传递环境
变量作为参数。

```bash
CMD ["myapp"]
```
### 选项二：使用Bash运行命令

确认您的容器包含了Bash并且使用Bash运行您的命令，这么做的目的是支持环境变量做为参数。

```bash
CMD ["/bin/bash", "-c", "myapp --arg=$ENV_VAR"
```

###　如何修改“优雅的时间周期”

在默认的情况下，优雅的时间周期是３０秒，正如很多场景，默认的参数不一定审适合特定的场景，　
有两种方法可以改变默认值：

1. 在Deployment .yaml中修改

2. 使用命令行，挡在运行kubectl delete时

### Deployment

您可以定制“优雅的时间周期”，修改Pod定义中sepc下面的terminationGracePeriodSeconds。例如，
下面的yaml文件将举例介绍，如何在一个简单的Deployment配置文件中将默认的“优雅的停止”设置为60秒。

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
    name: test
spec:
    replicas: 1
    template:
        spec:
            containers:
              - name: test
                image: ...
            terminationGracePeriodSeconds: 60
``` 

### 命令行

您还可以通过手工执行kubectl delete命令时改变默认的“优雅时间周期“，加上--grace-period=SECONDS选项，例如：

```bash
kubectl delete deployment test --grace-period=60
```

### 备选方案

