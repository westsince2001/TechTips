Cookies
=========
### 背景

背景有二：
1.  potatoHelper需要了解Cookies的基本原理，然后用来编写相应的golang程序。
2.  YCE需要做一些会话管理，也应当补充相应的Cookies知识。

### Cookies的目标
Cookies，不管它是小饼干或者什么你能叫得出名字的东西，它很有用。Cookies的主要目标是管理服务器和客户端之间的状态，这个状态就是Cookies。

所谓状态，尤其是现在常说的微服务里，通常建议采用无状态的服务，这个状态本质上是描述系统的某种状态的数据。

### Cookies相关的标准

Cookies并没有被编入标准化的HTTP/1.1的RFC2616中，而网景公司于1994年前后设计并制定了相关规格标准，除此之外还有RFC2109, RFC2965以及RFC6265。但目前最常见的Cookies并不是属于任何一个RFC，是基于网景公司的业界事实标准进行的扩展。

Cookies的工作机制是用户识别及状态管理。网站为了管理用户，会在用户访问时将一些数据写入用户计算机内，用户随后访问网站可以获取到这些Cookies。

### Cookies的首部和方法

Cookies的首部字段：

|首部字段名|说明|首部类型|
|:--------:|:--:|:------:|
|Set-Cookie|开始状态管理所使用的Cookie信息|响应首部|
|Cookie|服务器接收到的Cookie信息|请求首部|

具体来说，Set-Cookie字段的属性：

|属性|说明|
|:--:|:--:|
|NAME=VALUE|Cookie的键和值|
|expires=DATE|过期时间（默认为浏览器关闭）
|path=PATH|路径（将服务器上的文件目录作为Cookie的适用对象|
|domain=域名|Cookie作用的域名
|Secure|仅在HTTPS时发送|
|HttpOnly|使得Cookie不能被Javascript脚本访问|

需要注意的是：

* Cookies一旦发送给客户端，服务器端是无法直接删除的，只能将其覆盖。
* domain属性可做到跟结尾匹配一致。所以除了针对具体指定的多个域名发送Cookie之外，不指定domain属性显得更安全。
* HttpOnly用于防止跨站脚本攻击（Cross-site-scripting, XSS）对Cookie信息的窃取。但该特性并非是为了防止XSS而开发的。


用户在调用Cookie时，由于可以校验Cookie的有效期、发送方的域、路径、协议等信息，因此正规发布的Cookie是不会被其他Web站点攻击或泄露。

### 参考资料
1.  图解HTTP，【日】上野 宣 著。于均良 译。人民邮电出版社
2.  HTTP权威指南，【美】David Gourley 等著。陈涓， 赵振平 译。人民邮电出版社。


