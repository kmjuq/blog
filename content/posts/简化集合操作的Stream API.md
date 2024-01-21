---
title: "简化集合操作的Stream API"
date: 2020-11-03T06:11:09+08:00
draft: true
---
## 什么是流
流是一种支持以声明方式来处理数据的 `Java API`

主要语法结构主要由两部分组成:
- 数据源
- 数据操作
    - 中间操作
    - 终端操作

其中数据源是待处理的数据，中间操作表示数据应该怎么处理，终端操作表示数据的执行。
你可以想象成我们是老师，教了学生**解题思路**，首先应该怎么做，其次应该怎么做，然后告诉学生，理解了吗，**做吧**，然后学生就得出了结果。
老师是我们程序员，学生是jvm,待解决的问题是数据源，解题思路是中间操作，做吧是终端操作。

### 数据源
数据源指的是待处理的数据,比如说数据集合,io流.
```java
// 集合数据源
List<Integer> ints = Arrays.asList(
        1,
        2,
        1,
        3,
        3,
        2,
        4
);

// 文件数据源
"/Users/kmj/Git/javase/src/main/resources/mongo.properties"
```

### 数据操作
#### 中间操作
为数据源定义流通道（表示处理数据的一种方式）,不会进行数据处理，返回的数据依然是流通道，`Stream<T>`。
```java
Stream<String> lines = Files.lines(
        Paths.get("/Users/kmj/Git/javase/src/main/resources/mongo.properties"),
        Charset.defaultCharset()
);
Stream<String> strstrm = Stream.of(
        "Java 8",
        "lambda",
        "in",
        "action"
);
```

两个例子都返回流通道 `Stream<String>` , `Stream.of()` 和 `Files.lines()` 都是返回流的中间操作.


#### 终端操作
执行中间操作,并处理数据,返回一个非流的值.
```java
// 返回类型 --> void
Arrays.asList(1, 2, 3, 4, 5).forEach(System.out::println);

// 返回类型 --> List<String>
Stream
        .of(
                "hello",
                "world"
        )
        .collect(Collectors.toList());
```

这里的 `forEach()` 和 `collect()` 方法都是终端操作.

## 流的使用
介绍一些常用流数据处理方式

| 操作      | 类型     | 返回类型    | 函数式接口            | 函数描述符     |
| :-------- | :------- | :---------- | :-------------------- | :------------- |
| filter    | 中间操作 | Stream<T>   | Predicate<T>          | T -> boolean   |
| distinct  | 中间操作 | Stream<T>   |                       |                |
| limit     | 中间操作 | Stream<T>   | long                  |                |
| skip      | 中间操作 | Stream<T>   | long                  |                |
| map       | 中间操作 | Stream<T>   | Function<T,R>         | T -> R         |
| flatMap   | 中间操作 | Stream<R>   | Function<T,Stream<R>> | T -> Stream<R> |
| sorted    | 中间操作 | Stream<T>   | Comparator<T>         | (T,T) -> int   |
| anyMatch  | 终端操作 | boolean     | Predicate<T>          | T -> boolean   |
| noneMatch | 终端操作 | boolean     | Predicate<T>          | T -> boolean   |
| allMatch  | 终端操作 | boolean     | Predicate<T>          | T -> boolean   |
| findAny   | 终端操作 | Optional<T> |                       |                |
| findFirst | 终端操作 | Optional<T> |                       |                |
| forEach   | 终端操作 | void        | Consumer<T>           | T ->  void     |
| reduce    | 终端操作 | Optional<T> | BinaryOperator<T>     | (T,T) -> T     |

### 中间操作
#### 筛选
##### filter
用于筛选出符合lambda表达式返回ture的数据
```java
// 输出结果 --> KMJ
Stream
        .of(
                "kmj",
                "KMJ",
                "Kmj"
        )
        .filter("KMJ"::equals)
        .forEach(System.out::println);
```

##### distinct
用于筛选数据源中不相同的数据,根据数据源每个元素的 `hashcode()` 和 `equals()` 来判断是否相同
```java
Arrays
        .asList(
                1,
                2,
                1,
                3,
                3,
                2,
                4
        )
        .stream()
        .distinct()
        .forEach(System.out::println); //输出 1,2,3,4
```
#### 切片
##### limit
返回一个不超过指定长度的流.
```java
// 输出结果 --> 1,2,3
Stream
        .of(1,
            2,
            3,
            4,
            5,
            6)
        .limit(3)
        .forEach(System.out::println);
```
##### skip
跳过指定长度的流,
```java
// 输出结果 --> 4,5,6
Stream
        .of(1,
            2,
            3,
            4,
            5,
            6)
        .skip(3)
        .forEach(System.out::println);
```

#### 映射
##### map
将数据源中的每一项元素使用map接收的转换方法,生成新的元素.
```java
// 输出结果 -> J,I,A
Stream
        .of("Java",
            "In",
            "Action")
        .map(s -> s.charAt(0))
        .forEach(System.out::println);
```

##### flatMap
将多维的数据源转换为一维的数据源.
```java
String[][] words = new String[][]{ { "Java", "In", "Action" }, { "Java 8", "实战" } };
Arrays
        .stream(words)
        .map(Arrays::stream) // 这一步返回的数据类型 --> Stream<Stream<String>>
        .forEach(System.out::print);
System.out.println();
Arrays
        .stream(words)
        .flatMap(Arrays::stream) // 这一步返回的数据类型 --> Stream<String>
        .forEach(System.out::print);

/**
 * 输出结果
 * java.util.stream.ReferencePipeline$Head@3c679bdejava.util.stream.ReferencePipeline$Head@16b4a017
 * JavaInActionJava 8实战
 */
```

### 终端操作
#### 查找
##### anyMatch
检查数据源是否至少有一个匹配的数据
```java
System.out.println(Stream
        .of(
                "Java In Action",
                "Spring In Action"
        )
        .anyMatch(s -> s.startsWith("Java"))); // 输出结果 --> true
```
##### allMatch
检查数据源全部元素是否全部匹配
```java
System.out.println(Stream
        .of(
                "Java In Action",
                "Spring In Action"
        )
        .allMatch(s -> s.endsWith("Action"))); // 输出结果 --> true
```
##### noneMatch
检查数据源全部元素是否都全没有匹配
```java
System.out.println(Stream
        .of(
                "Java In Action",
                "Spring In Action"
        )
        .noneMatch(s -> s.startsWith("Golang"))); // 输出结果 --> true
```
##### findAny,firstFirst
findAny: 返回流中的任意一个元素,firstFirst: 返回流中的第一个元素. 这里需要配合并行流 `parallelStream()` 测试才能看出区别
```java
List<String> source = Arrays.asList("Jhonny", "David", "Jack", "Duke", "Jill","Dany","Julia","Jenish","Divya");

Optional<String> findFirst = source.parallelStream().filter(s -> s.startsWith("D")).findFirst();
Optional<String> fidnAny = source.parallelStream().filter(s -> s.startsWith("J")).findAny();

System.out.println(findFirst.orElse("")); //总是打印出David
System.out.println(fidnAny.orElse("")); //会随机地打印出Jack/Jill/Julia/Jenish
```
这里有个 `Optional<T>` 的用法,不知道最佳实践是哪些场景,感觉不好用.

#### 归约
##### reduce
归约 `reduce()` 是一个累计迭代的数据处理过程.将数据源所有数据项处理为一个值
```java
# 求1,2,3,4的和
Stream
        .of(
                1,
                2,
                3,
                4
        )
        .reduce(Integer::sum)
        .ifPresent(System.out::println); // 输出结果 --> 10
```

## 流特化
特化流指的是 `IntStream` , `DoubleStream` , `LongStream` 三种流.
主要用来避免 `int` 和 `Integer`,原始类型和包装类型的装箱拆箱成本.
而且在统计计算方面,我们一般的 `Stream<T>` 不方便使用.比如说我们要计算每种菜单的热量的和.


```java
// 这里map操作返回的流是 Stream<T>
menu
        .stream()
        .map(Dish::getCalories)
        .reduce(Integer::sum)
        .ifPresent(System.out::println);
// 这里map操作返回的流是 IntStream
System.out.println(
        menu
                .stream()
                .mapToInt(Dish::getCalories)
                .sum()
);
```

在第二种 IntStream 流里面,我们要计算菜单的热量和直接调用 IntStream#sum 方法就行了.

