---
title: "虚拟机性能监控与故障处理工具"
date: 2023-02-25T22:50:52+08:00
draft: true
---

## 虚拟机性能监控与故障处理工具
## jps
查看 jvm 进程id、主类和启动参数。
### jstat
查看 jvm 虚拟机的内存年代分配和垃圾回收情况.通过 `jstat -options` 命令可以查看能够查看的报表种类。
常用命令为 `jstat -gcutil 9847 1000`。
### jinfo
jinfo可以实时查看并修改虚拟机进程的参数和依赖的环境变量，不过很多参数都是不允许动态修改的，因此这个命令不是很实用。
### jmap
java内存映像工具，可以生成堆转储文件快照，一般会给虚拟机参数`-XX:+HeapDumpOnOutOfMemoryError`，这样当虚拟机发生内存溢出时会生成快照，从服务器拿下来可以分析内存数据。一般可以通过MAT软件分析。
也可以手动执行`jmap -dump:format=b,file=dump.heap 虚拟机进程ID`。
一般用来分析内存溢出问题。
### jhat
搭配jmap一起使用，可以分析通过jmap生成的快照文件。一般不使用这个命令。
`jhat -port 端口 dump.heap`
### jstack
用来生成虚拟机当前时刻的线程快照，排查线程长时间停顿的原因，比如说线程间死锁，死循环，请求外部资源长时间刮起等。
`jstack -F 虚拟机进程ID`，可以查看线程池的线程状态。
### jcmd
jcmd 是监控门面集合, jps,jstack,jmap,jinfo 等命令的功能都有.通过 jcmd 获取 jvm pid 后,可以通过此命令 `jcmd pid help` 查看帮助,也可以通过 `jcmd 0 help` 查看所有进程能够执行的命令。
### VisualVM
开发时可以通过VisualVM可视化工具监控服务器上服务的运行情况。

## 场景排查
### 内存溢出

### 系统卡顿
系统卡顿一般都是fullgc过多，可以通过jstat命令查看gc情况，比如说fullgc过多，minorgc过快等。
然后可以通过jmap查看卡顿时是什么类数据过多。如果是java自带的类，还得通过日志来查看大概在进行哪些业务，可能有哪些地方会造成这个原因。
### 死锁
