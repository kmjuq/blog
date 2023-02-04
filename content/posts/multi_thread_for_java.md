---
title: "Java 多线程"
date: 2021-09-27T22:05:09+08:00
draft: true
---

## 多线程学习路线
`synchronized` 和 `volatile` 和内存语义和底层实现原理，了解即可。
`Unsafe` 类的几种底层操作。

## 阻塞状态和等待状态的区别
阻塞状态是被动的，cpu分配时间片，可以获取锁后，就可以立即执行。
等待状态需要主动唤醒，不然无法获取锁，获取cpu时间片，就无法执行。

具体来说，当对一个线程，调用 interrupt() 时，
① 如果线程处于被阻塞状态（例如处于sleep, wait, join 等状态），那么线程将立即退出被阻塞状态，并抛出一个InterruptedException异常。
② 如果线程处于正常活动状态，那么会将该线程的中断标志设置为 true。被设置中断标志的线程将继续正常运行，不受影响。

绝对不能“吞掉中断”！即捕获了InterruptedException而不作任何处理。

真正符合安全的做法，就是让线程自己去结束自己。