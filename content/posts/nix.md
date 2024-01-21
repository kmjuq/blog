---
title: "Nix 语言"
date: 2023-06-03T15:38:49+08:00
draft: true
---

## 数据类型

### let 表达式

```nix
let a = 4; in a
```

### with 表达式

```nix
person1 = { name = "kmj"; age = "30"; }
with person1; name + age
```

### 函数表达式

```nix
// (x: x*2) 中间一定要有一个空格 
double = x: x*2

mul = a: b: a*b                     // mul 3 5
mul = { a,b?2 }: a*b                // mul {a=3;b=5;}
mul = { a, b, ... }: a*b            // mul { a = 3; b = 4; c = 2; }
mul = s@{ a, b, ... }: a*b*s.c      // mul { a = 3; b = 4; c = 2; }
```

### import 表达式
a.nix
```nix
4
```

b.nix
```nix
5
```

mul.nix
```nix
a: b: a*b
```

```nix
a = import ./a.nix
b = import ./b.nix
mul = import ./mul.nix
mul a b
```