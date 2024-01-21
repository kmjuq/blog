---
title: "JVM之垃圾收集器"
date: 2023-03-02T16:15:07+08:00
draft: true
---
## 前置知识
jvm 内存模型及其作用
## 什么是垃圾收集器
在 java 中,我们编写的程序是不需要程序员申请,释放内存的.但这并不代表着,我们的程序没有内存的申请和释放,帮助我们执行这一操作的就是 jvm .今天我们主要关注在 jvm 中内存的释放过程,由于不需要我们程序员手动释放内存,所以 jvm 有个叫垃圾收集器的东西来帮助我们释放程序中不需要使用的对象.
## 分代收集理论
分代收集理论其实是一套符合大多数程序运行实际情况的经验法则,收集器应该将堆划分出不同的区域,然后将回收对象依据其年龄(年龄即对象熬过垃圾收集过程的次数)分配到不同的区域之中存储.
## 垃圾收集算法
垃圾收集算法有三种思路,分别为标记清除,标记复制,标记整理.
### 标记清除
### 标记复制
### 标记整理

## 垃圾收集器
垃圾收集器主要分为分代垃圾收集器和低延迟垃圾收集器.分代垃圾收集器以分代(新生代或者老年代)为回收单元,低延迟以region为回收单元.
### 分代垃圾收集器
#### serial
最初的虚拟机新生代垃圾收集器,单线程.
现在是hotspot虚拟机在客户端模式下的默认新生代收集器
#### parnew
新生代垃圾收集器,serial的多线程版本,cms出来后,就成了cms的内置新生代收集器.
#### parallel scavenge
新生代垃圾收集器,关注于吞吐量的垃圾收集器,主要用于计算领域.
#### serial old
老年代垃圾收集器,主要意义供客户端模式下的hotspot虚拟机使用.
#### parallel old
老年代垃圾收集器,parallel scavenge的老年代版本,都是关注吞吐量的,所以只能parallel scavenge + parallel old 搭配,为java8默认配置.
#### cms
老年代垃圾收集器,基于标记清除算法,是一种以获取最短回收停顿时间(即低延迟)为目标的收集器.在以基于浏览器的b/s系统的服务端上,都是使用的此收集器.
### 低延迟垃圾收集器
#### g1
g1主要面向服务端应用的低延迟垃圾收集器,在jdk9发布时,g1成为服务端模式下的默认垃圾收集器,并将cms标记为过期.
#### shenandoah
先进的g1
#### zgc
另类的shenandoah
## 如何挑选我们的垃圾收集器