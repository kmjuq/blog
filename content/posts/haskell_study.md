---
title: "Haskell_study"
date: 2024-11-30T11:04:38+08:00
draft: true
---

## 环境安装
略

## 常见的数据类型
### 基础类型
- Num 表示整数
- Fractional 表示浮点数
- Char 表示一个字符，字符列表`[Char]`即字符串
- Bool 只有 True 和 False

```haskell
ghci> :t 1
1 :: Num a => a
ghci> :t 3.14
3.14 :: Fractional a => a
ghci> :t 'A'
'A' :: Char
ghci> :t True
True :: Bool
```

### List
List 里面不能有不同类型的数据。

#### List 构造
List 构造有两种，一种是 `[1,2,3,4]` 字面量，一种是 `[1..10]` range 区间。
字面量是固定的，range 区间则表示了一种区间数据集合，支持等差数列。


```haskell
ghci> [1..20]
[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
ghci> ['a'..'z']
"abcdefghijklmnopqrstuvwxyz"
ghci> ['K'..'Z']  
"KLMNOPQRSTUVWXYZ"
ghci> [2,4..20]
[2,4,6,8,10,12,14,16,18,20]
ghci> [3,6..20]
[3,6,9,12,15,18]
```


#### List 操作
##### 字面量操作
```haskell
# 使用 ghci 解释器来进行说明
# List 合并
ghci> [1,2,3,4] ++ [9,10,11,12]
[1,2,3,4,9,10,11,12]

# 元素和 List 链接
# [1,2,3,4] 实际上是 1:2:3:4:[] 的语法糖。: 将元素和 List 链接，从右向左链接
ghci> 5:[1,2,3,4,5] 
[5,1,2,3,4,5]

# 通过下标获取 List 某个元素，字符串是字符 List，所以可以通过下标获取字符
# 
ghci> "Hello World,Haskell!" !! 6  
'W'
```

#### List Comprehension（列表推导）

```haskell
# 语法为 [表达式｜列表取数,筛选条件]
ghci> [x*2 | x <- [1..10], x*2 >= 12]
[12,14,16,18,20]

# 添加多个限制条件
ghci> [ x | x <- [10..20], x /= 13, x /= 15, x /= 19]
[10,11,12,14,16,17,18,20]

# 从多个 List 中取数的话，会把所有元素组合
ghci> [ x*y | x <- [2,5,10], y <- [8,10,11], x > 3, y > 8 ]
[50,55,100,110]
```

### Tuple
Tuple(元组)是包含有不同类型元素的固定长度容器。主要有两种构造方式，一种是字面量，一种是通过表达式。

```haskell
# tuple 字面量
ghci> (1,"tuple")
(1,"tuple")
# 通过zip函数创建元组列表
ghci> zip [5,3,2,6,2,7,2,5,4,6,6] ["im","a","turtle"]
[(5,"im"),(3,"a"),(2,"turtle")]
```

元组取数通过模式匹配或方法取数
```haskell
# let 表达式模式匹配
ghci> let (x,y) = (1,"tuple") in show x ++ show y
"1\"tuple\""

# 自带的方法 fst snd
ghci> fst (1,"tuple")
1
ghci> snd (1,"tuple")
"tuple"

# 对于三元素以上的元组，可以创建函数来获取
ghci> forth (_,_,_,d) = d
ghci> forth (1,1.0,"tuple",True)
True
```

## 函数
```haskell
ghci> :{
ghci| sum' [] = 0
ghci| sum' (x:xs) = x + (sum' xs)
ghci| :}
ghci> sum' [1,2,3]
6
ghci> :t sum'
sum' :: Num a => [a] -> a
```

以上是我们定义的一个函数 `sum'`, 因为 `sum` 是预加载就有的一个函数，所以命名为 `sum'`, 这也是 haskell 语言的惯例。

通过 `:{` 开启多行输入，`:}` 结束多行输入，以及中间的语句，我们定义了 `sum'` 函数。
因为函数调用时都是根据参数来进行模式匹配（模式匹配必须从上到下依次匹配）来选择要执行的表达式的，所以sum'函数需要两个语句。

`sum' [] = 0` 表示当函数参数是空列表 [] 时，返回0；

`sum' (x:xs) = x + (sum' xs)` 表示当参数符合 x:xs 模式时，x 代表一个元素，xs 代表后面的列表，它让 x 加上 递归调用 sum' 本身，参数为后面的列表；

`sum' [1,2,3]` 的执行流程为：
- sum' [1,2,3]
- 1 + sum' [2,3]
- 1 + (2 + sum' [3])
- 1 + (2 + (3 + sum' [])) # sum' [] 匹配上了 `sum' [] = 0`
- 1 + (2 + (3 + 0))
- 1 + (2 + 3)
- 1 + 5
- 6

### 函数定义

`sum' :: Num a => [a] -> a` 为函数的定义部分，语法分别为：
- `sum'` 函数名
- `::` 函数定义符号
- `Num a =>` 是类型约束，用来确定类型 `a` 的类型的，必须是 `Num` 类型的实例
- `[a]` 参数，参数是列表类型，列表元素类型则是 `a` ,表示任意类型，符合型别约束即可，相当于其他语言的范型
- `a` 返回值，返回值类型和 `[a]` 列表中的元素类型一致

我们可以自定义几个函数试试
```haskell
ghci> double x=x*2
ghci> double 10
20
ghci> :t double
double :: Num a => a -> a
# show 可以将数据转为字符串
ghci> add_string a = show a ++ "Hello"
ghci> add_string 1
"1Hello"
ghci> :t add_string
add_string :: Show a => a -> [Char]
```

### guard 和 where
```haskell
bmiTell :: (RealFloat a) => a -> a -> String  
bmiTell weight height  
    -- guard
    | bmi <= skinny = "You're underweight, you emo, you!"  
    | bmi <= normal = "You're supposedly normal. Pffft, I bet you're ugly!"  
    | bmi <= fat    = "You're fat! Lose some weight, fatty!"  
    | otherwise     = "You're a whale, congratulations!"  
    --
    -- where
    where bmi = weight / height ^ 2  
          skinny = 18.5  
          normal = 25.0  
          fat = 30.0
    --
```
guard是对模式匹配的进一步拆分，符合布尔表达式的才会执行。而且必须存在otherwise。
where是对模式匹配的补充（包含了guard），方便我们简化函数体, where 中定义变量，表达式和函数，同时where也支持嵌套。

### if..then..else..表达式、let表达式、case 表达式
```haskell
-- if..then..else.. 表达式
ghci> [if 5 > 3 then "Woo" else "Boo", if 'a' > 'b' then "Foo" else "Bar"]  
["Woo", "Bar"]  
ghci> 4 * (if 10 > 5 then 10 else 0) + 2  
42
```

```haskell
-- let 表达式
ghci> 4 * (let a = 9 in a + 1) + 2  
42
ghci> [let square x = x * x in (square 5, square 3, square 2)]  
[(25,9,4)]
ghci> :{
ghci| calcBmis :: (RealFloat a) => [(a, a)] -> [a]  
ghci| calcBmis xs = [bmi | (w, h) <- xs, let bmi = w / h ^ 2]
ghci| :}
ghci> calcBmis [(168,85)]
[2.3252595155709342e-2]
ghci> calcBmis [(85,168)]
[3.0116213151927438e-3]
```

```haskell
-- xx.hs
head' :: [a] -> a  
head' [] = error "No head for empty lists!"  
head' (x:_) = x
-- case 表达式
-- 函数定义的模式匹配也是 case 表达式的语法糖
head' :: [a] -> a  
head' xs = case xs of [] -> error "No head for empty lists!"  
                      (x:_) -> x

describeList :: [a] -> String  
describeList xs = "The list is " ++ case xs of [] -> "empty."  
                                               [x] -> "a singleton list."   
                                               xs -> "a longer list."

```

### lambda 表达式
```haskell
-- xx.hs
numLongChains :: Int  
numLongChains = length (filter (\xs -> length xs > 15) (map chain [1..100]))

addThree :: (Num a) => a -> a -> a -> a  
addThree = \x -> \y -> \z -> x + y + z

flip' :: (a -> b -> c) -> b -> a -> c  
flip' f = \x y -> f y x
```

### $ 函数 和 函数组合

```haskell
-- $ 函数
($) :: (a -> b) -> a -> b  
f $ x = f x
-- 使用了 $ 函数，会让函数右边的先执行，当对一个参数进行多次函数调用时可以减少括号()的存在
sum (filter (> 10) (map (*2) [2..10]))
sum $ filter (> 10) $ map (*2) [2..10]

-- 函数组合
(.) :: (b -> c) -> (a -> b) -> a -> c  
f . g = \x -> f (g x)
-- 函数组合是右结合的
ghci> map (\x -> negate (abs x)) [5,-3,-6,7,-3,2,-19,24]  
[-5,-3,-6,-7,-3,-2,-19,-24]
ghci> map (negate . abs) [5,-3,-6,7,-3,2,-19,24]  
[-5,-3,-6,-7,-3,-2,-19,-24]
ghci> map (\xs -> negate (sum (tail xs))) [[1..5],[3..6],[1..7]]  
[-14,-15,-27]
ghci> map (negate . sum . tail) [[1..5],[3..6],[1..7]]  
[-14,-15,-27]
```

## 类型系统

### 自定义类型(Data Types)
上面已经介绍了haskell语言常见的类型。除了这些基础的类型，我们还可以自定义自己的类型。相当其他语言的结构体。

```haskell
-- 创建 Level 类型
data Level = Level String String String deriving (Show)
-- 创建 Rght 类型，可以使用 Level 类型创建 Rght 类型
data Rght = Rght String Level deriving (Show)
```

`data Level = Level String String String deriving (Show)` 是我们申明类型的基础语法：
- `data` 属于关键字，固定用法
- `Level` 声明类型名
- `=` 固定用法
- `Level String String String` 值构造函数，`Level`是函数名，`String String String`是函数参数
- `deriving (Show)` 是派生，可以自动给该类型添加`Show`行为

Rght 类型，取数时需要创建函数进行模式匹配才能取到类型里面的数据，比如说：
```haskell
rght_name :: Rght -> String
rght_name (Rght name _ ) = name

rght_level :: Rght -> Level
rght_level :: (Rght _ level) = level
```

还有另一种创建类型的方式，它可以指定参数语义，且会自动生成相关的函数
```haskell
data Rght' = Rght' {name :: String, level :: Level} deriving (Show)
```

使用 ghci 测试看看
```haskell
ghci> data Level = Level String String String deriving (Show)
ghci> data Rght = Rght String Level deriving (Show)
ghci> data Rght' = Rght' {name :: String, level :: Level} deriving (Show)
ghci> :t name
name :: Rght' -> String
ghci> :t level
level :: Rght' -> Level
ghci> 
```

### 类型参数与类型构造函数
在其他语言中，我们常常使用`范型`来对不同数据类型的做相同的处理逻辑，在 `haskell` 中也有类似的东西，之前的函数就有涉及，`head` 函数可以取不同数据类型的列表的第一个元素。
```haskell
-- 这里的 a 就是不同的类型，`Maybe Int`才是一个数据类型，只有`Maybe`时不算数据类型。
-- Just 就是类型构造函数，后面需要跟一个类型
data Maybe a = Nothing | Just a
```

### 类型别名
`haskell` 的类型别名主要是为了在函数式语言中更加精确的描述事物，当然也有很多时候为了简写类型。
```haskell
type String = [Char]

phoneBook :: [(String,String)]
phoneBook =
    [("betty","555-2938")
    ,("bonnie","452-2928")
    ,("patsy","493-2928")
    ,("lucille","205-2928")
    ,("wendy","939-8282")
    ,("penny","853-2492")
    ]
type PhoneBook = [(String,String)]

type PhoneNumber = String
type Name = String
type PhoneBook = [(Name,PhoneNumber)]
```

### 类型分类(Typeclasses)
给类型添加行为，相当于oop语言的接口。当使用类型约束时，需要类型实现该类型分类。具体语法举例如下：

```haskell
-- 这是判断两个类型是否相等的类型分类，内置的
class Eq a where
    (==) :: a -> a -> Bool
    (/=) :: a -> a -> Bool
    x == y = not (x /= y)
    x /= y = not (x == y)

-- 我们给 Rght 添上 eq 的实现，因为 Rght 依赖 Level 所以也必须给 Level 添加上实现
instance Eq Level where
  (Level l11 l12 l13) == (Level l21 l22 l23) = l11 == l21 && l12 == l22 && l13 == l23

instance Eq Rght where
  (Rght name1 level1) == (Rght name2 level2) = name1 == name2 && level1 == level2
```

```haskell
-- 使用ghci测试代码
ghci> :{
ghci| data Level = Level String String String deriving (Show)
ghci| -- 创建 Rght 类型，可以使用 Level 类型创建 Rght 类型
ghci| data Rght = Rght String Level deriving (Show)
ghci| instance Eq Level where
ghci|   (Level l11 l12 l13) == (Level l21 l22 l23) = l11 == l21 && l12 == l22 && l13 == l23
ghci| 
ghci| instance Eq Rght where
ghci|   (Rght name1 level1) == (Rght name2 level2) = name1 == name2 && level1 == level2
ghci| :}
ghci> let level1=Level "01" "02" "03"
ghci> let level2=Level "01" "02" "03"
ghci> let rght1=Rght "1" level1
ghci> let rght2=Rght "1" level2
ghci> rght1 == rght2
True
```

上述是介绍系统内置的类型分类，我们也可以创建自己的类型分类
```haskell
-- 辅助函数：将字符串加法实现
addStrings :: String -> String -> String
addStrings s1 s2 = show (read s1 + read s2)

class Add1 a where
  add1 :: a -> a

instance Add1 Level where
  add1 (Level l1 l2 l3) = Level (addStrings l1 "1") (addStrings l2 "1") (addStrings l3 "1")
```

```haskell
-- 使用ghci测试代码
ghci> :{
ghci| data Level = Level String String String deriving (Show)
ghci| addStrings :: String -> String -> String
ghci| addStrings s1 s2 = show (read s1 + read s2)
ghci| 
ghci| class Add1 a where
ghci|   add1 :: a -> a
ghci| 
ghci| instance Add1 Level where
ghci|   add1 (Level l1 l2 l3) = Level (addStrings l1 "1") (addStrings l2 "1") (addStrings l3 "1")
ghci| :}
ghci> let level4 = Level "01" "03" "02"
ghci> add1 level4
Level "2" "4" "3"
ghci> 
```



### 派生(deriving)

### IO Action

#### Exception


## 函数式思想
### 柯里化
### fold
### functor
functor 是一个类型分类，专门用来转换类型构造子内部的类型的，典型的比如 `Maybe`
```haskell
-- 这是functor的定义，其中f是类型构造子，f a是一个类型，f b是另外一个类型
class Functor f where
    fmap :: (a -> b) -> f a -> f b

-- 这是 Maybe 实现的functor
instance Functor Maybe where
    fmap f (Just x) = Just (f x)
    fmap f Nothing = Nothing
```

```haskell
-- 这是 Maybe 关于 functor 最简单的使用
ghci> fmap (read :: String -> Int) (Just "1")
Just 1
```
### applicative functor

### Monad
