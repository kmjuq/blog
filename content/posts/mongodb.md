---
title: "Mongodb"
date: 2023-11-21T21:53:53+08:00
draft: true
---

## mongodb的安装与启动

### 本地化安装
#### 下载mongodb
[mongodb官网下载地址](https://www.mongodb.com/download-center/enterprise?jmp=docs)

由于我选择安装在云服务器中,所以下载的是 `Linux` 平台通用的安装包.
版本为: Mongodb Community Server 4.0.6 [下载连接](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-4.0.6.tgz)

#### mongodb的安装
选择你想要安装的目录,解压压缩包. `tar -zxvf mongodb-linux-x86_64-4.0.6.tgz`

```bash
# 进入安装目录,查看压缩包内的内容
[root@iZwz98jvb8bcz3qpijx66gZ ~]# cd mongodb-linux-x86_64-4.0.6
[root@iZwz98jvb8bcz3qpijx66gZ mongodb-linux-x86_64-4.0.6]# ls
bin  LICENSE-Community.txt  MPL-2  README  THIRD-PARTY-NOTICES
```

ps.可以注意到,下载的二进制包,真的是除了命令,啥都没有.

将mongodb目录下的bin文件夹加入到环境变量内,便于用户执行mongodb的命令.

```bash
# 找到mongodb根目录
# 替换其中的 /opt/mongodb-linux-x86_64-4.0.6
# 执行以下命令将mongodb bin下的命令添加到当前用户(划重点)的环境变量中
echo -e "\nMONGODB_HOME=/opt/mongodb-linux-x86_64-4.0.6\nexport PATH=\$PATH:\$MONGODB_HOME/bin" >> ~/.bash_profile
```

```bash
# 查看bin目录下的命令
[root@iZwz98jvb8bcz3qpijx66gZ bin]# ls
bsondump         mongod       mongofiles   mongorestore  mongotop
install_compass  mongodump    mongoimport  mongos
mongo            mongoexport  mongoreplay  mongostat
```

- mongod: 控制数据库实例
- mongo: MongoDB shell(连接实例,调用 api)
- mongotop: 监控集合的使用信息
- mongostat: 监控实例的使用信息
- install_compass: MongoDB GUI
- bsondump: 格式转换(bson,json)
- mongodump: 数据备份
- mongorestore: 数据恢复
- mongoimport: 数据导入(json,csv,tsv)
- mongoexport: 数据导出(json,csv)
- mongos: 配置路由(数据库分片)
- mongoreplay: 记录并传递命令
- mongofiles: GridFs文件系统

ps.可以自行查看每个命令的 `help` 帮助信息.

#### 启动 mongodb 实例
创建配置文件 mongobd.config
```shell
# 定义数据存储文件
dbpath=/opt/mongodb-linux-x86_64-4.0.6/db/data
# 允许其他 IP 连接实例
bind_ip_all=true
# 允许本地 IP 连接实例
bind_ip=127.0.0.1
# 定义日志存储文件
logpath=/opt/mongodb-linux-x86_64-4.0.6/db/mongodb.logs
# 允许后台运行(必须配置 logpath )
fork=true 
```
启动实例 `mongod -f /opt/mongodb-linux-x86_64-4.0.6/mongo.config`

### mongodb altas
`mongodb altas` 是官方的mongodb的云服务，最小化学习版本不要钱，只要解决网络问题，这个更方便。
而且 altas 里面有现成的各种样例数据。

## mongodb 数据对象
### document
MongoDB 存储数据记录的基本单位是 BSON document,BSON 是 JSON 的二进制表示.
### collection
集合就是一组文档，并且集合对加入集合的文档没有结构限制，任意结构的json文档都可以加入集合，集合只会通过语义化的集合名称来约束集合内的文档内容。
### database
MongoDB 使用集合对文档进行分组，使用数据库对集合进行分组。一个MongoDB 实例可以承载多个数据库，每个数据库有零个或多个集合。  
mongodb 实例自带三个数据库：
- admin 

    该库会在身份验证和授权时被使用
- config 

    MongoDB 的分片集群会使用 config 数据库存储关于每个分片的信息
- local 

    特定于单个服务器的数据会存储在此数据库中。在副本集中，local 用于存储复制过程中所使用的数据，而 local 数据库本身不会被复制。

### view
### Capped Collections
固定大小的集合,当集合已经满数据,它会通过覆盖集合中最旧的文档为新文档腾出空间.


以下是两个 document 记录.
```javascript
{
    name:"sue",
    age:26,
    status:"A",
    groups:["news","sports"]
}
{
    _id: ObjectId("5099803df3f4948bd2f98391"),
    name: { first: "Alan", last: "Turing" },
    birth: new Date('Jun 23, 1912'),
    death: new Date('Jun 07, 1954'),
    contribs: [ "Turing machine", "Turing test", "Turingery" ],
    views : NumberLong(1250000)
}
```
### field

### 数据类型
Embedded Documents
Arrays
Date

#### ObjectId
ObjectId 是 "_id" 的默认类型。ObjectId 类采用了轻量化设计，可以很容易地在不同的机器上以全局唯一的方式生成。  
ObjectId 占用了 12 字节的存储空间，可以用 24个十六进制数字组成的字符串来表示。  
ObjectId 的前 4 字节是从 Unix 纪元开始以秒为单位的时间戳。  
ObjectId 中接下来的 5 字节是一个随机值。  
最后 3 字节只是一个递增计数器，负责确保单个进程中 1 秒内的唯一性。

## CRUD 操作
### Create Operations
在插入文档时,若当前的 `collection` 是未存在的,则插入操作会创建该 `collection` .
同时在插入文档时,如果插入的 `document` 中没有包含 `_id` 属性,则 `mongodb` 会在插入 `document` 时,生成一个 `ObjectId` 作为 `_id` 属性的值.而 `_id` 属性在 `document` 中作为主键.

`db.collection.insertOne()` 插入单个 `document` 到 `collection` 中.

```javascript
> show dbs;                                                                                    
admin   0.000GB
config  0.000GB
local   0.000GB
test    0.000GB
> use kmj;                                                                                     
switched to db kmj
> show collections;                                                                            
> db.inventory.insertOne({ id:123 });                                                          
{
        "acknowledged" : true,
        "insertedId" : ObjectId("5cc719e478c4513205d2d3f7")
}
> show collections;                                                                            
inventory
> show dbs;                                                                                    
admin   0.000GB
config  0.000GB
kmj     0.000GB
local   0.000GB
test    0.000GB
> db.inventory.insertOne({ _id:123 });                                                         
{ "acknowledged" : true, "insertedId" : 123 }
> db.inventory.find();                                                                         
{ "_id" : ObjectId("5cc719e478c4513205d2d3f7"), "id" : 123 }
{ "_id" : 123 }
```

`db.collection.insertMany()` 插入多个文档
`db.collection.insert()` 插入多个文档


### Read Operations
从集合 `collection` 中读取 `document` ,查询功能.

`db.collection.find(query, projection)` 是官方 `api` 提供的查询功能,该功能可以输入两个参数,并且两个参数都是可选的.
第一个参数用来查询符合要求的数据,第二个参数则是用来选择列的,在 `document` 的 `field` 过多的情况下,我们查询数据时,可能只想要指定几个字段.

```javascript
db.inventory.insertMany([
   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "A" },
   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" }
]);
```

| mongodb api                                                      | RDBMS sql                                                                    |
| :--------------------------------------------------------------- | :--------------------------------------------------------------------------- |
| db.inventory.find({})                                            | SELECT * FROM inventory                                                      |
| db.inventory.find({status:"D"})                                  | SELECT * FROM inventory WHERE status = "D"                                   |
| db.inventory.find({status:{$in:["A","D"]}})                      | SELECT * FROM inventory WHERE status in ("A", "D")                           |
| db.inventory.find({status:"A",qty:{$lt:30}})                     | SELECT * FROM inventory WHERE status = "A" AND qty < 30                      |
| db.inventory.find({$or:[{status:"A"},{qty:{$lt:30}}]})           | SELECT * FROM inventory WHERE status = "A" OR qty < 30                       |
| db.inventory.find({status:"A",$or:[{qty:{$lt:30}},{item:/^p/}]}) | SELECT * FROM inventory WHERE status = "A" AND ( qty < 30 OR item LIKE "p%") |

```javascript
//查询完整的一行数据,包含所有的列
db.inventory.find({status:"A",qty:{$lt:30}})
{
    "_id" : ObjectId("5cc7a4825947c1ff6c35ce61"),
    "item" : "journal",
    "qty" : 25.0,
    "size" : {
        "h" : 14.0,
        "w" : 21.0,
        "uom" : "cm"
    },
    "status" : "A"
}
//指定要查询出来的列
db.inventory.find({status:"A",qty:{$lt:30}},{"size":1,"item":1})
{
    "_id" : ObjectId("5cc7a4825947c1ff6c35ce61"),
    "item" : "journal",
    "size" : {
        "h" : 14.0,
        "w" : 21.0,
        "uom" : "cm"
    }
}
/*
第二个参数 {"size":1,"item":1}
key 代表 字段名
value 代表 是否取出该列 若为 1,则取出该列数据,若为 0,则取出该列,取其他列.必须全为 1 或全为 0.
*/
//排除要查询出来的列
db.inventory.find({status:"A",qty:{$lt:30}},{"size":0,"item":0})
{
    "_id" : ObjectId("5cc7a4825947c1ff6c35ce61"),
    "qty" : 25.0,
    "status" : "A"
}

db.food.find({"fruit.2":"peach"})

db.movies.find({"_id":ObjectId("573a1390f29313caabcd42e8"),"case":})
```

### Update Operations
更新某个 collection 中已经存在的 documents .相关API操作有：
- `db.collection.updateOne()`
- `db.collection.updateMany()`
- `db.collection.replaceOne()`
- `db.collection.findOneAndReplace()`
- `db.collection.findOneAndUpdate()`

find 系列的api会返回文档，其他的只会返回是否操作成功，更新数量。

```javascript
db.users.updateMany(
    { age: { $lt: 18 } },
    { $set: { status: "reject" } }
);
`{ age: { $lt: 18 } }` 过滤器,找到需要更新的数据
`{ $set: { status: "reject" } }` 更新操作. `$set` 修饰符用来给旧文档新增字段

db.blog.posts.updateOne(
    {"title":"A blog post"},
    {"$push":{"comments":{"name":"joe"}}}
)

// 使用 sample_mfilx 数据库，movies 集合
`$push` 运算符用来给数组字段加数据的
db.movies.updateOne(
    {"_id":ObjectId("573a1390f29313caabcd42e8")},
    {"$push":{"genres":{"$each":["b1","a1"],"$slice":-3,"$sort":-1}}}
)
`$each` 修饰符的修饰的字段为数组，然后 `$each` 修饰符的属性也为数组，需要往数组字段批量加数据时使用
"$slice" 修饰符配合 `$push` 来防止数组的增长超过某个大小，从而有效地生成"top N"列表
`$sort` 修饰符可以将原本的和 `$push`加入的一起进行排序

db.movies.updateOne(
    {"_id":ObjectId("573a1390f29313caabcd42e8")},
    {"$addToSet":{"genres":{"$each":["a1","a1"]}}}
)
`$addToSet` 运算符会将数组类型的属性当作集合，在添加元素时会判断数组里是否有添加的元素，若有，则不添加

db.movies.updateOne(
    {"_id":ObjectId("573a1390f29313caabcd42e8")},
    {"$pop":{"genres":1}}
)
`$pop` 从数组类型的属性的头尾进行删除

db.movies.updateOne(
    {"_id":ObjectId("573a1390f29313caabcd42e8")},
    {"$pull":{"genres":"a2"}}
)
`$pull` 删除数组中所有相等的元素
```



### Delete Operations
删除某个 collection 中的 documents.
`db.collection.deleteOne()`
`db.collection.deleteMany()`

```javascript
db.users.deleteMany(
    { status: "reject" }
);
```
`{ status: "reject" }` 过滤器,找到符合要求的数据.

### 查询条件修饰符
| 修饰符     | 作用                                                                           |
| :--------- | :----------------------------------------------------------------------------- |
| $lt        | 小于                                                                           |
| $lte       | 小于或等于                                                                     |
| $gt        | 大于                                                                           |
| $gte       | 大于或等于                                                                     |
| $ne        | 不等于                                                                         |
| $in        | 属性内容在范围内                                                               |
| $nin       | 属性内容不在范围内                                                             |
| $or        | 或，满足不同属性                                                               |
| $mod       | 将查询的值除以第一个给定值，如果余数等于第二个给定值，则匹配成功               |
| $not       | 和$mod，正则搭配使用，取反                                                     |
| $exists    | 文档内容必须包含此属性                                                         |
| $eq        | 用于特殊场景，比如属性值为 null，默认是$eq                                     |
| $regex     | 正则匹配，最好使用区分大小写和限制前缀的表达式，可以利用索引                   |
| $all       | 用于数组的匹配，当期望对数组多个元素做匹配时使用                               |
| $size      | 查询特定长度的数组                                                             |
| $elemMatch | 将子句与单个数组元素进行比较，当需要对数组一个元素多个属性进行同时限制时很有效 |
|            |                                                                                |
|            |                                                                                |


### 更新运算符及修饰符
| 运算符    | 修饰符 | 作用                                                                                   |
| :-------- | :----- | :------------------------------------------------------------------------------------- |
| $inc      | -      | 原子地执行递增操作，只能用于整型、长整型或双精度浮点型的值                             |
| $set      | -      | 用来设置一个字段的值                                                                   |
| $push     | -      | 如果数组已存在，"$push" 就会将元素添加到数组末尾；如果数组不存在，则会创建一个新的数组 |
| $push     | $each  | $each修饰的字段为数组，当需要批量加数据到数组时使用                                    |
| $push     | $slice | 防止数组元素过多                                                                       |
| $push     | $sort  | 对已有的元素和加入的元素一起排序                                                       |
| $addToSet | -      | 判断数组元素有没有新增的元素，有就不加，没有就加                                       |
| $pop      | -      | 从数组头部或者尾部删除                                                                 |
| $pull     | -      | 从数组中删除某些元素                                                                   |

## 游标
数据库会使用游标返回 find 的执行结果。游标的客户端实现通常能够在很大程度上对查询的最终输出进行控制。
调用 find 时，shell 并不会立即查询数据库，而是等到真正开始请求结果时才发送查询，这样可以在执行之前给查询附加额外的选项。
比如，你可以限制结果的数量，跳过一些结果，按任意方向的任意键组合对结果进行排序，以及执行许多其他功能强大的操作。
而且cursor 对象的大多数方法会返回游标本身，这样就可以按照任意顺序将选项链接起来了。

```js
var cursor = db.collection.find()
while(cursor.hasNext()){
    obj = cursor.next()
}

```


> 由于 mongodb 是文档是动态结构的，因此对于一个键有多种类型时，对其排序有类型顺序。
> skip() 进行大数据量跳过时，会有性能问题，可以先排序获取数据，然后再次查询时通过上次的批次的数据作为查询条件。

## 索引
mongo 也是使用 explain 来查看执行计划。
```js
// 使用的db是 sample_airbnb  collections 是 listingsAndReviews
db.listingsAndReviews.find({"_id":"10006546"}).explain("executionStats")
{
  explainVersion: '1',
  queryPlanner: {
    namespace: 'sample_airbnb.listingsAndReviews',
    indexFilterSet: false,
    parsedQuery: { _id: { '$eq': '10006546' } },
    queryHash: '740C02B0',
    planCacheKey: 'E351FFEC',
    maxIndexedOrSolutionsReached: false,
    maxIndexedAndSolutionsReached: false,
    maxScansToExplodeReached: false,
    winningPlan: { stage: 'IDHACK' },
    rejectedPlans: []
  },
  executionStats: {
    executionSuccess: true,
    // 查询后的返回数
    nReturned: 1,
    executionTimeMillis: 0,
    totalKeysExamined: 1,
    // 扫描过的文档数
    totalDocsExamined: 1,
    executionStages: {
      stage: 'IDHACK',
      nReturned: 1,
      executionTimeMillisEstimate: 0,
      works: 2,
      advanced: 1,
      needTime: 0,
      needYield: 0,
      saveState: 0,
      restoreState: 0,
      isEOF: 1,
      keysExamined: 1,
      docsExamined: 1
    }
  },
  command: {
    find: 'listingsAndReviews',
    filter: { _id: '10006546' },
    '$db': 'sample_airbnb'
  },
  serverInfo: {
    host: 'ac-fgi7pjm-shard-00-02.wstzjm2.mongodb.net',
    port: 27017,
    version: '6.0.11',
    gitVersion: 'f797f841eaf1759c770271ae00c88b92b2766eed'
  },
  serverParameters: {
    internalQueryFacetBufferSizeBytes: 104857600,
    internalQueryFacetMaxOutputDocSizeBytes: 104857600,
    internalLookupStageIntermediateDocumentMaxSizeBytes: 16793600,
    internalDocumentSourceGroupMaxMemoryBytes: 104857600,
    internalQueryMaxBlockingSortMemoryUsageBytes: 33554432,
    internalQueryProhibitBlockingMergeOnMongoS: 0,
    internalQueryMaxAddToSetBytes: 104857600,
    internalDocumentSourceSetWindowFieldsMaxMemoryBytes: 104857600
  },
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1700654054, i: 2 }),
    signature: {
      hash: Binary.createFromBase64('4biVPM9Ys3uAlfWDpxlwvqY+Y8Q=', 0),
      keyId: Long('7256785174342402050')
    }
  },
  operationTime: Timestamp({ t: 1700654054, i: 2 })
}
```
### 索引的创建
`db.listingsAndReviews.createIndex({"key":1})` 该句就是 mongo 的索引创建方法，"key" 就是需要创建索引的属性。

| 索引类型 | 语句                                            |
| :------- | :---------------------------------------------- |
| 普通索引 | db.collections.createIndex({"key":1})           |
| 复合索引 | db.collections.createIndex({"key1":1,"key2":1}) |
|          |                                                 |

#### 复合索引
通常在设计复合索引时，应该将等值过滤字段排在多值过滤字段之前。
在多个条件下的复合索引时，索引使用方向必须和索引建立方向一致。

#### 覆盖索引
如果查询只需要查找索引中包含的字段，那就没有必要去获取实际的文档了。当一个索引包含用户请求的所有字段时，这个索引就覆盖了本次查询。
只要切实可行，就应该优先使用覆盖查询，而不是去获取实际的文档，这样可以使工作集大幅减小。
#### 隐式索引
如果有一个拥有 N 个键的索引，那么你同时“免费”得到了所有这些键的前缀所组成的索引。  
如果有一个类似 {"a": 1, "b": 1, "c": 1..., "z": 1} 这样的索引，那么实际上也等于有了 {"a": 1}、{"a": 1, "b" : 1}、{"a": 1,"b": 1, "c": 1} 等一系列索引。



### mongo索引选择原理
当有查询进来时，MongoDB 会查看这个查询的形状。这个形状与要搜索的字段和一些附加信息（比如是否有排序）有关。基于这些信息，系统会识别出一组可能用于满足查询的候选索引。
假设有一个查询进入，5 个索引中的 3 个被标识为该查询的候选索引。然后，MongoDB 会为每个索引创建 1 个查询计划，并在 3 个并行线程中运行此查询，每个线程使用不同的索引。
让多个查询计划相互竞争的真正价值在于，对于具有相同形状的后续查询，MongoDB 会知道要选择哪个索引。
服务器端维护了查询计划的缓存。一个获胜的计划存储在缓存中，以备在将来用于进行该形状的查询。
随着时间的推移以及集合和索引的变化，查询计划可能会从缓存中被淘汰。而 MongoDB 会再次进行尝试，以找到最适合当前集合和索引集的查询计划。

### 查询选项
| 运算符 | 修饰符 | 作用               |
| :----- | :----- | :----------------- |
| $limit | -      | 限制返回结果的数量 |
| $skip  | -      | 略过一定数量的结果 |
| $sort  | -      | 排序               |

## mongodb-java
### mongodb 驱动选择
[mongodb java 驱动下载](http://mongodb.github.io/mongo-java-driver/?jmp=docs)

驱动分类:
- mongodb-driver-sync
- mongodb-driver-legacy
- mongodb-driver-async

`mongodb-driver-sync` MongoDB 最新的 Java Driver 驱动程序.
`mongodb-driver-async` MongoDB 最新的 Reactive Programing(即响应式编程,相应编程思想代表 spring-webflux) 的 Java Driver 驱动程序.
`mongodb-driver-legacy` MongoDB **过时的** Java Driver 驱动程序.不建议使用.

### MongoDB Java Driver Base Classes
MongoDB Java 驱动包中的基础类:
- MongoClient
- MongoDatabases
- MongoCollection
- Document
- Bson

`MongoClient` 用来连接 MongoDB 数据库.
其他的很容易理解,就是 MongoDB 相关的对象, Database , Collection , Document , Bson.



## 附录
- [ 菜鸟教程 ] - (http://www.runoob.com/mongodb/mongodb-tutorial.html)
- [ Manual ] - (https://docs.mongodb.com/manual/reference/program/)
- [ University ] - (https://university.mongodb.com/courses/M001/about)
- [ Mongo Driver ] - (http://mongodb.github.io/mongo-java-driver/3.10/driver/getting-started/quick-start/)

