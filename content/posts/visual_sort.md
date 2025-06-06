---
title: "Visual_sort"
date: 2023-02-20T03:39:49+08:00
draft: true
---

## 排序

### 冒泡排序
先强调重点，冒泡排序的排序思路为：
1. 数据两两比较
2. 数据传播
3. 重复

假设我们要从小到大排序的数字为`[6, 36, 81, 44, 12, 7, 43, 49, 2, 92, 18, 15, 28, 96, 31]`一共有15的数字，

| 步骤  |   0   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |   8   |   9   |  10   |  11   |  12   |  13   |  14   |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
|   0   |   6   |  36   |  81   |  44   |  12   |   7   |  43   |  49   |   2   |  92   |  18   |  15   |  28   |  96   |  31   |
|   1   |   6   |  36   |  81   |  44   |  12   |   7   |  43   |  49   |   2   |  92   |  18   |  15   |  28   |  96   |  31   |
|   2   |   6   |  36   |  44   |  81   |  12   |   7   |  43   |  49   |   2   |  92   |  18   |  15   |  28   |  96   |  31   |
|   3   |   6   |  36   |  44   |  12   |  81   |   7   |  43   |  49   |   2   |  92   |  18   |  15   |  28   |  96   |  31   |
|   4   |   2   |   6   |   7   |  12   |  15   |  18   |  28   |  31   |  36   |  43   |  44   |  49   |  81   |  92   |  96   |

1. 取出6，36，比较大小，6比36小，不执行交换
2. 取出36，81，比较大小，36比81小，不执行交换
3. 取出81，44，比较大小，81大于44，**执行交换**
4. 取出81，12，比较大小，81大于12，**执行交换**
5. 重复1到4，一共14次
6. 重复1到5，一共14次

我们假定15个数字两两比较完的过程为一轮（即1到4的过程），第一轮中我们会将最大的数字传播到最右边，
第二轮中我们也会将大的数字传播到右边，以此类推，当我们排序15个数字时，需要14轮。

以下为代码实现：
```java
/**

 */
public int[] sort(int[] unSortInts) {
    for (int i = 1; i < unSortInts.length; i++) {
        for (int j = 0; j < unSortInts.length - i; j++) {
            if (unSortInts[j] > unSortInts[j + 1]) {
                ArrayUtil.swap(unSortInts, j, j + 1);
            }
        }
    }
    return unSortInts;
}
```

### 选择排序




