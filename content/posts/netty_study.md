---
title: "Netty_study"
date: 2023-01-31T18:32:45+08:00
draft: true
---
## netty 的前置概念
## netty 的概念
- channel
- channelHandler
- EventLoopGroup
- ByteBuf
## netty 的线程模型

## netty 的模块
我们通过 maven 添加 netty 所有模块包。
```xml
<dependency>
    <groupId>io.netty</groupId>
    <artifactId>netty-all</artifactId>
    <version>4.1.84.Final</version>
</dependency>
```

所涉及模块分类如下：
- netty-buffer
- netty-codec*
- netty-common
- netty-handler*
- netty-resolver*
- netty-transport*

## 附录
### 所有模块说明
- netty-buffer
- netty-codec
- netty-codec-dns
- netty-codec-haproxy
- netty-codec-http2
- netty-codec-http
- netty-codec-memcache
- netty-codec-mqtt
- netty-codec-redis
- netty-codec-smtp
- netty-codec-socks
- netty-codec-stomp
- netty-codec-xml
- netty-common
- netty-handler
- netty-handler-proxy
- netty-resolver
- netty-resolver-dns
- netty-resolver-dns-classes-macos
- netty-resolver-dns-native-macos:osx-aarch_64
- netty-resolver-dns-native-macos:osx-x86_64
- netty-transport
- netty-transport-classes-epoll
- netty-transport-classes-kqueue
- netty-transport-native-epoll:linux-aarch_64
- netty-transport-native-epoll:linux-x86_64
- netty-transport-native-kqueue:osx-aarch_64
- netty-transport-native-kqueue:osx-x86_64
- netty-transport-native-unix-common
- netty-transport-rxtx
- netty-transport-sctp
- netty-transport-udt