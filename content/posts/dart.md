---
title: "Dart"
date: 2020-05-25T11:04:17+08:00
draft: false
author: "可梦见"
---

## hello-world
`dart` 语言和 `Java` 一样都有应用程序入口，并且都是 `main()` 函数。
```java
public static void main(String[] args) { }
```

```dart
void main() { }
```

所以我们 `dart` 的 `hello world` 就在这个 `main()` 函数里面啦。

```dart
void main() {
    print('hello world'); // print()打印方法结尾有换行
}
```

## 常用数据类型
`dart` 没有像 `java` 一样有基础数据类型和引用类型的区分，而是全部都是引用类型.
支持以下几种数据类型：
- numbers
    - int
    - double
- strings
- booleans
- lists(arrays)
- sets
- maps

### Numbers
```dart
int aa = 0x321; // 16进制
double bb = 1.42e6; // 科学技术法
int cc = aa >> 2; // int 类型移位操作
```

### Strings
```dart
String aa = 'aa'; // 单引号定义
String bb = "bb"; // 双引号定义
// 单引号形式的多行字符串 
String cc = '''
<p>
    <div></div>
</p>''';
// 双引号形式的多行字符串
String dd = """
<p>
    <div></div>
</p>""";
// 多个字符串相连接
String ee = aa + ' ' + bb;
// 在字符串内引用字符串,调用对象的 toString() 方法。
String ff = '$aa $bb';
String gg = '$aa ${bb.toUpperCase()}';
assert(ee == ff);
assert(ee != gg);
// 字符串的实体字符不进行转义
String hh = r'<p>\n<div></div>\n</p>';
```

### Booleans
bool类型只有两个实例， `true` 和 `false` 。

### Lists,Sets,Maps

#### Lists
```dart
// Lists 初始化
List a = [1, 2, 3];
List b = List();
// 增
b.add(4);
// 删
a.removeLast();
// 改
a[0] = 4;
// 查
a.indexOf(3);
```

#### Sets
```dart
// Sets 初始化方式
Set<String> kmj = {'a', 'b', 'c', 'd'};
Set pc = <String>{};
Set<String> phone = {};
// 增
kmj.add('e');
// 删
kmj.remove('c');
// 改，无改操作，每个都是唯一的
// 查
kmj.contains('a');
```

#### Maps
```dart
// Maps
Map kmj = {'age': 27, 'height': 167, 'weight': 154};
Map jmk = <String,int>{};
Map lm = Map();
var aa = [1, 2, 3];
// 增
kmj['habbit'] = 'play games';
lm.putIfAbsent('age', () => 25);
// 删
kmj.remove('habbit');
// 改，key是唯一的，无法更改
// 查
kmj.containsKey('age');
kmj.containsValue(167);
```

#### collection if 和 collection for
该功能指的是在集合元素初始化过程中可以使用判断和循环，使创建集合元素更加方便容易。

```dart
// Lists
bool flag = true;
List aa = ['1', if (flag) '2' else '3', if (!flag) '2' else '3'];
List bb = ['123', for (String i in aa) '#$i'];
// Sets
Set cc = {'a',if(flag) 'b' else 'c'};
Set dd = {'d','c',for(String i in cc) i};
// Maps
Map ee = {'name':'kmj',if (flag) 'age':27 else 'height':167 };
```

> Maps类型暂时没有发现支持 **collection for** 特性


#### (...) 和 (...?)
`...` 和 `...?` 称为延展操作符，将集合的元素插入到另一个集合中。
`Lists` , `Sets` , `Maps` 三种集合数据类型都支持延展操作符

```dart
// Lists
List a = [4, 2, 3];
List b = [1, ...a];
List c;
List d = [0, ...?c]; // 判断c是否为null，如果是则不进行数组延展
// List e = [0, ...c]; // 报错

//Sets
Set<String> aa = {'1', '2', '3', '4'};
Set<String> bb;
Set<String> cc = {...aa,'5',...?bb};

//Maps
Map aa = {1: 'a', 2: 'b', 3: 'c'};
Map bb;
Map cc = {...aa,4:'d',...?bb};
```

## 变量声明
虽然 `dart` 静态类型语言，但是它支持类型推断，因此你也可以用 `var` 来声明变量。

```dart
var name = 'Voyager I';
var year = 1977;
var antennaDiameter = 3.7;
var flybyObjects = ['Jupiter', 'Saturn', 'Uranus', 'Neptune'];
var image = {
  'tags': ['saturn'],
  'url': '//path/to/saturn.jpg'
};
```

和 `java` 不一样的是，`dart` 没有基础类型，所有类型都是对象，因此所有类型的默认值都是 `null`。

```dart
int lineCount;
assert(lineCount == null);
```

当你尝试定义不会变的变量时，可以加上 `final` 和 `const` 关键字。
而且由于有类型推断，在使用这两个关键字时可以不指定具体数据类型。
如果你的对象需要更改数据，则使用 `final` 。如果不需要则用 `const` 。

```dart
final aa = [1,2,3,4];
const bb = [1,2,3,4];
aa[0] = 4;
bb[0] = 4; // 报错
```