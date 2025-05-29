---
title: "FLOW_DSL_API"
date: 2023-02-10T17:36:36+08:00
draft: true
---

## 线性任务
a -> b -> c

## ifelse 任务
a->g@{
    b -> c,
    d -> e -> f,
}->z

## 循环任务
a -> 5@(b -> c) -> d