---
title: "Elasticsearch"
date: 2023-07-12T09:18:03+08:00
draft: true
---

## 基础概念
### 索引
### 文档
一个 json 格式的字符串

## elk的安装
### docker-compose
```yml
version: "3.8"
services:
  elk:
    image: sebp/elk
    ports:
      - "5601:5601"
      - "9200:9200"
      - "5044:5044"
    environment:
      - "ES_JAVA_OPTS=-Xms2G -Xmx2G"
```

### 数据集
在使用kibana时，kibana可以通过网络去下载es的样例数据，以下三个索引是其提供的样例：
- kibana_sample_data_ecommerce
- kibana_sample_data_flights
- kibana_sample_data_logs

然后可以去 kaggle 网站下载数据集，通过filebeat将数据集通过logstash传输到es。
- [All 8000+ Top Rated IMDB Movies Dataset](https://www.kaggle.com/datasets/rajkumardubey10/all-top-rated-imdb-movies-dataset)

```yml
// filebeat.yml 配置，将该配置文件和数据集文件放在同一目录
filebeat:
  inputs:
    - paths:
        - ./Top_rated_movies1.csv
      fields:
        type: rated_movies
      fields_under_root: true

output:
  logstash:
    hosts: ["localhost:5044"]
```
执行命令：
- `filebeat -e -c {filebeat.yml全路径名}`   启动filebeat,传输csv数据
- `rm -rf /usr/local/var/lib/filebeat/registry`   删除filebeat执行记录，使filebeat可以重新执行

```conf
## logstash 配置文件
## 在docker 容器内部创建 /etc/logstash/conf.d/13-rated_movies.conf 文件 内容如下
filter {
  if [type] == "rated_movies" {

    csv {
      columns => ["id","title","overview","popularity","release_date","vote_average","vote_count"]
      skip_header => true
    }

    prune {
        whitelist_names => [ "id","title","overview","popularity","release_date","vote_average","vote_count","type" ]
    }
  }
}

## 修改 /etc/logstash/conf.d/30-output.conf 文件，修改内容如下
if [type] == "rated_movies" {
  elasticsearch {
    hosts => ["localhost"]
    manage_template => false
    index => "rated_movies"
    document_id => "%{id}"
  }
} else {
  elasticsearch {
    hosts => ["localhost"]
    manage_template => false
    index => "%{[type]}"
  }
}
```
## 索引
在 es 中，可以通过 `PUT /{index_name}` 接口来创建索引，样例如下：  
```json
PUT /person
{ 
  "mappings": {
    "properties": {
      "name":{
        "type": "text",
        "fields": {
          "keyword":{
            "type": "keyword"
          }
        }
      },
      "gender":{
        "type":"keyword"
      },
      "age":{
        "type":"short"
      },
      "avatar":{
        "type":"keyword",
        "index": false
      },
      "intro":{
        "type":"text",
        "analyzer": "standard"
      },
      "address":{
        "properties": {
          "location": {
            "type":"geo_point"
          },
          "province":{
            "type":"keyword",
            "copy_to":"all_adress"
          },
          "city":{
            "type":"keyword",
            "copy_to":"all_adress"
          },
          "detail_address":{
            "type":"keyword",
            "copy_to":"all_adress"
          },
          "all_address":{
            "type":"text",
            "analyzer": "standard"
          }
        }
      }
    }
  },
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 2
  }
}
```
创建索引 `/person` 后，我们可以通过 `GET /person` 来查看索引的配置。  
我们可以看到 json 的第一层是索引名 `person` , 第二层是 `alias` ，`mappings`，`settings` 这三部分内容就构成了es的索引。

### settings
我们通过kibanna devtools `GET /person/_settings` 来查看索引 `settings` 部分。  
`settings`部份参数跟本身索引的行为和特性相关。
如下两个参数 `number_of_shards` 和 `number_of_replicas` 基本都是要配置的.  
`number_of_shards` 代表的是数据的分片，这个参数的配置根据es服务数量和索引大小有关。  
`number_of_replicas` 代表的是分片的复制，这个参数根数据的可用性相关，可用性要求高，可以配置多一些。  

### mapping
我们通过kibanna devtools `GET /person/_mapping` 来查看索引的 `mapping` 部分。
`mapping` 部分是索引配置中跟我们开发最相关的内容，在 mapping 中，我们可以确定哪些字段需要分词，哪些字段不需要，然后可以根据业务场景来设计字段优化搜索查询。

#### 数据类型
|  类型名称  |    类型标识    |                 类型作用                  |
| :--------: | :------------: | :---------------------------------------: |
| 关键字类型 |    keyword     |             直接保留原始文本              |
|  文本类型  |      text      |       进行文本分析,保存切分后的词语       |
|  数值类型  | long,integer等 |               不同精度数值                |
|  日期类型  |      date      |           默认UTC,需要注意时区            |
|  布尔类型  |    boolean     |                true false                 |
| 经纬度类型 |   geo_point    |                  lon lat                  |
|  对象类型  |       无       | 会展开建立索引,查询时使用address.location |
|  数组类型  |       无       |               直接提交数组                |

#### 多字段
针对同一个字段, 有时需要有不同的数据处理方式, 比如说人名, 既想要通过模糊查询, 又想通过精确匹配查询.
多字段的使用案例如下：
```json
{
    "mappings": {
        "properties": {
            "name": {
                "type": "text",
                "fields": {
                    "keyword": {
                        "type": "keyword"
                    }
                }
            }
        }
    }
}
```
以上配置 es 会创建 `name` 和 `name.keyword` 两份索引，其中 `name` 是需要进行分词的，然后 `name.keyword` 不需要。

> 暂不清楚使用多个字段和使用多字段有什么差异，可能是可以通过`mappings`更好的看出来，`name.keyword` 是一个字段的不同表现。

#### 动态映射
当创建索引时未通过 mapping 约束文档字段时, 直接插入文档会通过动态映射功能自动创建映射，但是自动映射的索引配置基本不可用，因此此功能不实用。

```json
POST /person1/_doc
{
  "gender":"male",
  "birth":"1993-12-13",
  "intro":"a 30 years old boy",
  "hobby": ["play computer game","read book"],
  "age":35,
  "address":{
    "location": {
      "lon": -74,
      "lat": 40.8
    },
    "province":{
      "city": "daye"
    }
  }
}
```

可以通过 `GET /person1/_mapping` 查看索引生成的映射, 当插入的文档结构变化时, 索引也会扩展之前的映射结构.  
如果真的要用最好通过动态模版配置来使用动态映射, 不过不好用, 略.

### alias
索引别名功能在实际生产中经常使用，比如，索引迭代，在es索引创建完后，索引的分片数是不可改变的，然后在业务发展过程中，我们索引的分片数量可能起始是5，由于业务数据量过多，每个分片数据量过大，导致搜索变慢，这时我们可以创建一个新的索引来存储新数据，这个新索引可以使用新的分片数量，然后两者使用相同的别名，可以平滑迁移索引。
索引别名有两种添加方式, 一种是创建索引时添加, 一种是索引运行时动态添加.

```json
// 运行时动态添加
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "kibana_sample_data_ecommerce",
        "alias": "ecommerce"
      }
    }
  ]
}
// 创建索引时添加
PUT /logs-00001
{
  "aliases": {
    "logs-seq": {}
  }
}
```

`POST /_aliases` 方式支持使用通配符.
```json
PUT /logs-001
PUT /logs-002
PUT /logs-003

POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "logs-*",
        "alias": "logs"
      }
    }
  ]
}

GET /logs-001
```

`PUT /logs-00001` 方式支持滚动索引, 当索引只有一个别名时, 可以向索引中插入数据, 不需要指定索引名.

```json
PUT /logs-00001
{
  "aliases": {
    "logs-seq": {}
  }
}

POST /logs-seq/_doc/1
{
  "create_time":"2023-01-01"
}

POST /logs-seq/_rollover
{
  "conditions": {
    "max_age": "7d",
    "max_docs": 1,
    "max_size": "5gb"
  }
}

GET /logs-00002
```

## 文档操作
### CRUD
```h
// 增
POST /person/_doc/1
{
  "gender":"male",
  "birth":"1993-12-13",
  "intro":"a 30 years old boy",
  "hobby": ["play computer game","read book"],
  "age":35,
  "address":{
    "location": {
      "lon": -74,
      "lat": 40.8
    },
    "province":{
      "city": "daye"
    }
  }
}
// 查
GET /person/_doc/1

// 全量更新，直接替换
PUT /person/_doc/1
{
  "gender":"male",
  "birth":"1993-12-13",
  "intro":"a 30 years old boy",
  "hobby": ["play computer game","read book"],
  "age":30,
  "address":{
    "location": {
      "lon": -74,
      "lat": 40.8
    }
  }
  // 省份去掉了
}
// 局部更新
POST /person/_update/1
{
  "doc":{
    "age":31
  }
}

// 删
DELETE /person/_doc/1
```

`POST /person/_doc/1` 这是上面的新增文档url，其中的 urlpath 是我们需要关心的，比如 `/person` 是文档所属的索引名，
`/_doc` 是代表操作的是文档的固定标记，`/1` 表示创建这个文档的唯一id。
### 批量处理
`POST /_bulk` 是es批量处理文档接口，增删改功能都能在批量该接口中实现。
```json
{"create":{"_index":"log","_id":"001"}}
{"createTime":"20231124025834"}
{"create":{"_index":"log","_id":"002"}}
{"createTime":"20231124025934"}
{"create":{"_index":"log","_id":"003"}}
{"createTime":"20231124030034"}
{"update":{"_index":"log","_id":"001"}}
{"doc":{"createTime":"20231124025034"}}
{"delete":{"_index":"log","_id":"002"}}
```

### 根据条件更新删除
`POST /{indexName}/_update_by_query` 接口是根据条件更新数据
`POST /{indexName}/_delete_by_query` 接口是根据条件删除数据

## 查询与检索
查询是有明确的搜索条件边界的，比如，年龄15～25，颜色=红色，价格<3000等。
检索是无搜索条件边界的，结果取决于相关性，其相关性计算无明确边界性条件，如同义词、谐音、别名、错别字等均可成为其相关性判断依据。
### 查询
#### term
```json
GET /kibana_sample_data_ecommerce/_search
{
  "query":{
    "term":{
      "customer_first_name.keyword":{
        "value":"Eddie"
      }
    }
  }
}

// term 查询只支持单个属性的查询，支持数值型、布尔型、日期型、数组型及关键字型。
```
#### terms
```json
GET /kibana_sample_data_ecommerce/_search
{
  "query":{
    "terms":{
      "customer_last_name.keyword": ["Underwood","Weber"]
    }
  }
}

// terms 查询只支持单个属性的查询，支持数值型、布尔型、日期型、数组型及关键字型。
```
#### range
```json
GET /kibana_sample_data_ecommerce/_search
{
  "query":{
    "range":{
      "order_date": {
        "gte":"2023-12-03T09:28:48+00:00",
        "lte":"2023-12-05T09:28:48+00:00"
      },
      "day_of_week_i":{
        "gte":1,
        "lte":3
      }
    }
  }
}

// range 查询只支持单个属性的查询，支持数值型和日期型。
```
#### exists
```json
GET /kibana_sample_data_ecommerce/_search
{
  "query":{
    "exists":{
      "field": "geoip.region_name"
    }
  }
}

// exists 查询只支持单个属性的查询，用来判断文档的某个字段是否有数据。
```
#### 地理位置查询
```json
GET /kibana_sample_data_logs/_search
{
  "query": {
    // 方圆100km有多少数据
    "geo_distance": {
      "distance": "100km", 
      "geo.coordinates": {
        "lat": 38.58338806,
        "lon": -86.46248778
      }
    }
  }
}

GET /kibana_sample_data_logs/_search
{
  "query": {
    // 在这个长方形的区域内，有多少数据
    "geo_bounding_box": {
      "geo.coordinates": {
        "top_left": {
          "lat": 38.58338806,
          "lon": -86.46248778
        }, 
        "bottom_right": {
          "lat": 36.68711028,
          "lon": -82.03333583
        }
      }
    }
  }
}
```
### 检索
#### match
```json
GET /kibana_sample_data_logs/_search
{
  "_source": ["host"], 
  "query": {
    "match": {
      "host": "elastic"
    }
  }
}
```

#### multi_match
```json
GET /kibana_sample_data_logs/_search
{
  "_source": ["message","request"], 
  "query": {
    "multi_match": {
      "query": "elasticsearch",
      "fields": [
        "message",
        "request"
      ]
    }
  }
}
```

#### match_phrase
```json
GET /kibana_sample_data_ecommerce/_search 
{
  "query":{
    "match_phrase": {
      "products.product_name": {
        "query": "black",
        // 匹配词之间的距离阈值
        "slop": 0
      }
    }
  }
}
```

### 布尔查询
上面几种查询都只支持一种搜索，而布尔查询则是支持多种搜索，布尔查询支持一下四种子查询：
| 子查询   | 功能                             |
| :------- | :------------------------------- |
| must     | 必须匹配该查询条件，与           |
| should   | 可以匹配该查询条件，或           |
| must not | 必须不匹配该查询条件，非         |
| filter   | 必须匹配过滤条件，不进行打分计算 |

bool查询可以嵌套，复杂查询场景会用。
#### must
```json
GET /kibana_sample_data_ecommerce/_search
{
  "query":{
    "bool":{
      "must":[
        {
          "term":{
            "customer_first_name.keyword":{
              "value":"Eddie"
            }
          }
        },
        {
          "terms":{
            "customer_last_name.keyword": ["Underwood","Weber"]
          }
        },
        {
          "range":{
            "order_date": {
              "gte":"2023-12-01T09:28:48+00:00",
              "lte":"2023-12-05T09:28:48+00:00"
            }
          }
        }
      ]
    }
  }
}
```
#### should
```json
GET /kibana_sample_data_ecommerce/_search
{
  "query":{
    "bool":{
      "must":[
        {
          "term":{
            "customer_first_name.keyword":{
              "value":"Eddie"
            }
          }
        }
      ],
      "should": [
        {
          "terms":{
            "customer_last_name.keyword": ["Underwood","Weber"]
          }
        },
        {
          "range":{
            "order_date": {
              "gte":"2023-12-01T09:28:48+00:00",
              "lte":"2023-12-05T09:28:48+00:00"
            }
          }
        }
      ]
    }
  }
}
```
#### must not
```json
GET /kibana_sample_data_ecommerce/_search
{
  "query":{
    "bool":{
      "must":[
        {
          "term":{
            "customer_first_name.keyword":{
              "value":"Diane"
            }
          }
        }
      ],
      "should": [
        {
          "terms":{
            "customer_last_name.keyword": ["Chandler","Goodwin"]
          }
        },
        {
          "range":{
            "order_date": {
              "gte":"2023-12-01T09:28:48+00:00",
              "lte":"2023-12-05T09:28:48+00:00"
            }
          }
        }
      ],
      "must_not": [
        {
          "exists":{
            "field": "geoip.city_name"
          }
        }
      ],
      "minimum_should_match": 1
    }
  }
}
```
当 should 和 filter 一起使用时，`minimum_should_match` 参数会变成 0，其他情况默认为 1。
#### filter
filter操作一般用于过滤不会影响文档的相关性分数的条件。
```json
GET /kibana_sample_data_ecommerce/_search
{
  "query":{
    "bool":{
      "filter":[
        {
          "term":{
            "customer_first_name.keyword":{
              "value":"Diane"
            }
          }
        },
        {
          "terms":{
            "customer_last_name.keyword": ["Chandler","Goodwin"]
          }
        },
        {
          "range":{
            "order_date": {
              "gte":"2023-12-01T09:28:48+00:00",
              "lte":"2023-12-05T09:28:48+00:00"
            }
          }
        }
      ]
    }
  }
}
```
### 辅助功能
#### 指定返回字段
```json
GET /kibana_sample_data_ecommerce/_search
{
  "_source":["category","currency"],
  "query": {
    "match_all": {}
  }
}
```
#### 结果计数
```json
GET /kibana_sample_data_ecommerce/_count
{
  "query": {
    "match_all": {}
  }
}
```
#### 结果分页
##### 普通分页
```json
GET /kibana_sample_data_ecommerce/_search
{
  "from":0,
  "size":20,
  "query": {
    "match_all": {}
  }
}
```
##### 滚动分页
```json
GET /rated_movies/_search?scroll=1m
{
  "query":{
    "match_all": {}
  },
  "size": 10,
  "sort":[
    {
      "release_date": {
        "order": "desc"
      }
    }
  ]
}

POST /_search/scroll                                                               
{
  "scroll" : "1m",                                                                 
  "scroll_id" : "FGluY2x1ZGVfY29udGV4dF91dWlkDXF1ZXJ5QW5kRmV0Y2gBFm1rWUM1dC1QUzBhRzg3S0pydkxrUFEAAAAAAAH7MhZNWFpnZnpsUFFUcUR4eVZZTW4yWFlB" 
}
```
##### search after 分页
```json
GET /rated_movies/_search
{
  "query":{
    "match_all": {}
  },
  "sort":[
    {
      "release_date": {
        "order": "desc"
      }
    }
  ]
}

GET /rated_movies/_search
{
  "query":{
    "match_all": {}
  },
  "sort":[
    {
      "release_date": {
        "order": "desc"
      }
    }
  ],
  // 每次都取最后一个排序的数值填入
  "search_after":[1690416000000]
}
```
#### 性能分析
```json
// 会生成搜索的执行计划，查看每一层的耗费时间
GET /kibana_sample_data_ecommerce/_search
{
  "profile":"true",
  "query": {
    "match_all": {}
  }
}
```
#### 评分分析
```json
// 用来查看某个文档对于某个搜索条件的打分情况
GET /kibana_sample_data_ecommerce/_explain/
{
  "profile":"true",
  "query": {
    "match_all": {}
  }
}
```
#### 高亮显示
```json
GET /kibana_sample_data_logs/_search
{
  "_source": ["host"], 
  "query": {
    "match": {
      "host": "elastic"
    }
  },
  "highlight": {
    "fields": {
      "host": {
        // type 可以使用不同的高亮算法
        "type":"unified",
        "pre_tags": "<high class='heightC'>",
        "post_tags": "</high>"
      }
    }
  }
}
```
#### 搜索建议
```json
// 删除索引
DELETE /hotel_sug
// 创建搜索建议索引
PUT /hotel_sug
{
  "mappings": {
    "properties": {
      "query_word":{
        "type":"completion"
      }
    }
  }
}

// 准备数据
POST /hotel_sug/_bulk
{"index":{"_id":"001"}}
{"query_word":"如家酒店"}
{"index":{"_id":"002"}}
{"query_word":"如家快捷酒店"}
{"index":{"_id":"003"}}
{"query_word":"如家精选酒店"}
{"index":{"_id":"004"}}
{"query_word":"如家假日酒店"}

// 查看数据
GET /hotel_sug/_search

// 查询搜索建议
GET /hotel_sug/_search
{
  "suggest": {
    "hotel_zh_sug": {
      "text": "如家快",
      "completion": {
        "field": "query_word"
      }
    }
  }
}
```
相关功能官网地址 [搜索建议](https://www.elastic.co/guide/en/elasticsearch/reference/8.4/search-suggesters.html)

## 聚合
做聚合时，无法对 `text` 进行聚合查询，
### 桶聚合
类比 SQL 中的 group by 的作用，主要用于统计不同类型数据的数量。
在 es 中，桶聚合是一种常用的聚合查询操作，它将文档分为多个"桶"，然后在每个桶上进行统计分析。

```json
GET /kibana_sample_data_ecommerce/_search
{
  "size":0,
  "aggs":{
    "my_aggs":{
      "terms": {
        "field": "products.category.keyword",
        "size": 10
      }
    }
  }
}

GET /kibana_sample_data_ecommerce/_search
{
  "size":0,
  "aggs":{
    "my_aggs":{
      "range": {
        "field": "products.base_price",
        "ranges": [
          {
            "to": 10
          },
          {
            "from": 10, 
            "to": 20
          },
          {
            "from": 20, 
            "to": 30
          }
        ]
      }
    }
  }
}

GET /kibana_sample_data_ecommerce/_search
{
  "size":0,
  "aggs": {
    "my_aggs": {
      "terms": {
        "field": "customer_last_name.keyword",
        "size": 100,
        "order": {
          "_key": "asc"
        }
      },
      "aggs":{
        "my_aggs1":{
          "terms": {
            "field": "customer_gender",
            "size": 10
          }
        }
      }
    }
  }
}

GET /kibana_sample_data_ecommerce/_search
{
  "size":0,
  "aggs":{
    "my_aggs":{
      "multi_terms":{
        "terms":[
          {
            "field":"customer_last_name.keyword"
          },
          {
            "field":"customer_gender"
          }
        ],
        "size":100,
        "order":{
          "_key":"asc"
        }
      }
    }
  }
}
```
### 指标聚合
一般和桶聚合一起工作，没有了分组，指标聚合也没了意义。
```json
GET /kibana_sample_data_ecommerce/_search
{
  "size":0,
  "aggs":{
    "my_avg":{
      "avg": {
        "field": "products.base_price"
      }
    },
    "my_states":{
      "stats": {
        "field": "products.base_price"
      }
    }
  }
}
```
### 管道聚合
管道聚合用于对聚合的结果进行二次聚合
```json
GET /kibana_sample_data_ecommerce/_search?filter_path=aggregations
{
  "size":0,
  "aggs":{
    "my_aggs":{
      "terms": {
        "field": "customer_first_name.keyword",
        "size": 100
      },
      "aggs":{
        "my_avg":{
          "avg": {
            "field": "products.base_price"
          }
        }
      }
    },
    "max_price":{
      // max_bucket 是固定方法，还有类似的 min_bucket
      "max_bucket": {
        "buckets_path": "my_aggs>my_avg"
      }
    },
    "stats_avg_price":{
      "stats_bucket":{
        "buckets_path": "my_aggs>my_avg"
      }
    }
  }
}
```
### 聚合排序
```json
GET /kibana_sample_data_ecommerce/_search?filter_path=aggregations
{
  "size":0,
  "aggs": {
    "my_aggs": {
      "terms": {
        "field": "customer_last_name.keyword",
        "size": 100,
        "order": {
          "_key": "asc"
        }
      }
    }
  }
}

GET /kibana_sample_data_ecommerce/_search?filter_path=aggregations
{
  "size":0,
  "aggs":{
    "my_aggs":{
      "terms": {
        "field": "customer_first_name.keyword",
        "size": 100,
        "order": [
          {
            "_count":"desc"
          },
          {
            "_key":"asc"
          }
        ]
      }
    }
  }
}

GET /kibana_sample_data_ecommerce/_search?filter_path=aggregations
{
  "size":0,
  "aggs":{
    "my_aggs":{
      "terms": {
        "field": "customer_last_name.keyword",
        "order": {
          "my_avg": "desc"
        },
        "size": 100
      },
      "aggs":{
        "my_avg":{
          "avg": {
            "field": "products.base_price"
          }
        }
      }
    }
  }
}
```
### 聚合过滤
聚合功能都会受到 query 查询的影响，
```json
GET /kibana_sample_data_ecommerce/_search?filter_path=aggregations
{
  "query": {
    "terms": {
      "customer_last_name.keyword": [
        "Shaw",
        "Palmer",
        "Hale"
      ]
    }
  },
  "aggs": {
    "my_aggs": {
      "terms": {
        "field": "customer_last_name.keyword",
        "size": 10,
        "order": {
          "my_avg": "desc"
        }
      },
      "aggs": {
        "my_avg": {
          "avg": {
            "field": "products.base_price"
          }
        }
      }
    },
    "other_aggs": {
      // 加上 global 后，other_aggs 则不受 query 影响
      "global": {},
      "aggs": {
        "my_aggs_": {
          "terms": {
            "field": "customer_last_name.keyword",
            "size": 10,
            "order": {
              "my_avg": "desc"
            }
          },
          "aggs": {
            "my_avg": {
              "avg": {
                "field": "products.base_price"
              }
            }
          }
        }
      }
    }
  }
}

GET /kibana_sample_data_ecommerce/_search
{
  "query": {
    "terms": {
      "customer_last_name.keyword": [
        "Perkins",
        "Underwood",
        "Tran",
        "Rivera",
        "Graham",
        "Shaw",
        "Byrd"
      ]
    }
  },
  "aggs": {
    "my_aggs0": {
      "filter": {
        "terms": {
          "customer_last_name.keyword": [
            "Perkins",
            "Underwood",
            "Tran",
            "Rivera",
            "Graham",
            "Shaw"
          ]
        }
      },
      "aggs": {
        "my_aggs1": {
          "terms": {
            "field": "customer_last_name.keyword",
            "size": 10,
            "order": {
              "_count": "desc"
            }
          }
        }
      }
    }
  },
  // 会在返回的 hits 结果中筛选，当只有 "Perkins" 效果更佳明显，也可以通过 hits.total 来判断
  "post_filter": {
    "terms": {
      "customer_last_name.keyword": [
        "Perkins",
        "Underwood",
        "Tran",
        "Rivera",
        "Graham"
      ]
    }
  }
}

PUT /logs/_bulk?refresh
{ "index" : { "_id" : 1 } }
{ "body" : "warning: page could not be rendered" }
{ "index" : { "_id" : 2 } }
{ "body" : "authentication error" }
{ "index" : { "_id" : 3 } }
{ "body" : "warning: connection timed out" }

GET logs/_search
{
  "size": 0,
  "aggs" : {
    "messages" : {
      "filters" : {
        "filters" : {
          "errors" :   { "match" : { "body" : "error"   }},
          "warnings" : { "match" : { "body" : "warning" }}
        }
      }
    }
  }
}
```
## 分析器
es 在 `text` 数据类型字段的索引建立和搜索阶段都会用到分析器，文档在索引建立阶段经过分析器处理，将得到的标记存储在倒排索引中。
而查询时，搜索的文本也要经过相同的分析器处理，以确保查询与索引的标记匹配。
es 将分析器的执行过程标准化为：字符过滤器 -> 分词器 -> 词项过滤器。es给我们准备了很多内置的功能，也通过标准化的API，可以使我们较为容易的调整分析器功能。es内建的分析器也有很多，比如：
| 分析器   | 字符过滤器 | 分词器   | 词项过滤器       |
| :------- | :--------- | :------- | :--------------- |
| Standard | -          | standard | lower case、stop |
| keyword  | -          | keyword  | -                |
| pattern  | -          | pattern  | lower case       |

具体可以查看官方文档 [分析器](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/analysis-analyzers.html)
由于分析器是三个部分组成，直接使用分析器不好对业务场景做定制。

我们可以通过 `GET _analyze` 接口来测试我们自定义的分析器。
```json
GET _analyze
{
  // 字符过滤器
  "char_filter": ["html_strip"], 
  // 分词器
  "tokenizer": "standard",
  // 词项过滤器
  "filter": ["stop"], 
  "text": ["<a href=''>what are you doing<a>"]
}
// 由这个接口参数，我们也可得之，在自定义分析器时，字符过滤器和此项过滤器是可以0个或多个的，而分词器必须是1个。
```
#### 字符过滤器
字符过滤器用于在文本分析之前对原始文本进行字符级别的处理。这些过滤器可以删除、替换或添加字符，以及执行其他一些字符级别的操作。
字符过滤器常用于处理HTML标记、删除特定字符或符号、转换字符的大小写等操作。它们主要影响原始文本的形式，而不涉及标记的划分。

| 名称            | 功能                   |
| :-------------- | :--------------------- |
| HTML strip      | 去掉HTML元素           |
| Pattern replace | 用正则表达式处理字符串 |

官方的 [字符过滤器](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/analysis-charfilters.html)
#### 分词器
分词器是分析器中最重要的工作，按照规则来切分词语，根据语言语法的不同，句子切词也需要有不同的切分方案，es也内置了很多分词器，主要针对英文环境。
| 名称                 | 功能                                      |
| :------------------- | :---------------------------------------- |
| simple pattern split | 根据指定分隔符来分割词语                  |
| standard             | 基于Unicode的文本分词算法，主要使用于英文 |
| simple               | 除了单词和字母，其他都过滤                |
| whitespace           | 按空白符分隔                              |

官方的 [分词器](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/analysis-tokenizers.html)
#### 词项过滤器
词项过滤器在文本分析的较后阶段对分词词语进行处理。它们可以用于将分词词语转为小写、删除停用词、执行同义词扩展、进行词干提取等操作。
词项过滤器影响分词词语的内容和结构，用于在词语级别上进一步调整文本，以提高搜索的准确性和全面性。
| 名称      | 功能         |
| :-------- | :----------- |
| Lowercase | 将词转成小写 |
| Synonym   | 定义同义词   |

官方的 [词项过滤器](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/analysis-tokenfilters.html)
### 自定义分析器
es内置的分析器、字符过滤器、分词器、词项过滤器都开放了配置参数，通过配置参数，可以基于内置的工具做自定义的调整。
```json
// 直接自定义分析器
PUT /customer_analyzer
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "type": "standard",
          "max_token_length": 5,
          "stopwords": "_english_"
        }
      }
    }
  }
}

// 也可分开自定义，再组合成分析器，然后使用分析器。
PUT /customer_analyzer_all
{
  "settings": {
    "analysis": {
      "analyzer": {
        // 创建自定义的分析器
        "my_analyzer": {
          "char_filter":["my_html_strip"],
          "tokenizer":"my_simple_pattern_split",
          "filter":["my_synonym"]
        }
      }, 
      "char_filter": {
        // 自定义的字符过滤器
        "my_html_strip":{
          "type":"html_strip",
          "escaped_tags":["kmj"]
        }
      },
      "tokenizer": {
        // 自定义的分词器
        "my_simple_pattern_split": {
          "type": "simple_pattern_split",
          "pattern": "_"
        }
      },
      "filter": {
        // 自定义的词项过滤器
        "my_synonym": {
            "type": "synonym",
            "lenient": true,
            "synonyms": [ "foo, bar => baz" ]
          }
      }
    }
  },
  "mappings": {
    "properties": {
      "content":{
        "type": "text",
        // 使用自定义的分析器
        "analyzer": "my_analyzer",
        "search_analyzer": "my_analyzer"
      }
    }
  }
}

// 测试自定义的分析器
GET /custom_analyzer_all/_analyze
{
  "analyzer": "my_analyzer", 
  "text":["<a>foo</a>_<kmj>bar</kmj>"]
}
```
### 文档归一化器
文档归一化器（Document Normalizer）通常是指在索引阶段对字段的值进行标准化处理，以确保不同文档中相同字段的值在索引中具有一致的表示形式。这有助于提高搜索的一致性和准确性。
在es中，可以通过自定义分析器中的字符过滤器和词汇过滤器来实现文档归一化。
文档归一化器只用于 `keyword` 类型。
```json
DELETE /custome_normailzer
PUT /custome_normailzer
{
  "settings": {
    "analysis": {
      "normalizer":{
        "my_normalizer":{
          "filter":["uppercase"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "content":{
        "type":"keyword",
        "normalizer": "my_normalizer"
      }
    }
  }
}

GET /custome_normailzer/_analyze
{
  "normalizer":"my_normalizer",
  "text": ["kmjsdaf"]
}
```

## es的模版
### 动态映射模版
当我们直接给不存在的索引添加文档数据时，es的动态映射功能就会生效，它会帮我们创建这个不存在的索引，然后创建一套默认的mapping，
由于 es 默认的动态映射可能不符合我们的业务需求，因此，我们可以通过动态映射模板功能来限制某一类索引的 mapping 生成规则。
### 索引模板
索引模板是为了方便我们管理各种不同业务分类的索引。
创建索引模板的方式和创建索引的方式差不多，根节点多了三个属性`index_patterns`、`template`和`version`，以前配置索引的内容在`tempalte`里面。
```json
// 创建索引模板 app-log-template
PUT _index_template/app-log-template
{
  "index_patterns": ["app-*-log"],
  "template":{
    "settings":{
      "number_of_shards":3,
      "number_of_replicas":0
    },
    "mappings":{},
    "aliases":{
      "app-logs":{}
    }
  },
  "version": 0,
  "priority": 100,
  "_meta":{
    "desc":"app log"
  }
}

// 创建索引 app-web-log
PUT /app-web-log
// 创建索引 app-orm-log
PUT /app-orm-log
GET /app-web-log
GET /app-orm-log
```

索引模板功能的应用流程：
- 应用 es 默认的 settings 和 mappings
- 应用 order 数值低的设定
- 应用 order 数值高的设定，并覆盖之前的设定
- 创建索引时，用户所指定的 settings 和 mappings 覆盖之前模板的设定

> 你可能会看到`_template`接口创建的索引模板，这是旧API，不支持`组件模板`。
### 组件模板
组件模板是对索引模板更细粒度的控制，可以讲索引模板的各个部分拆开来，通过组件来组合成索引模板。
```json
PUT _component_template/little-index
{
  "template": {
    "settings": {
      "number_of_replicas": 1,
      "number_of_shards": 1
    }
  }
}


PUT _component_template/app-logs
{
  "template": {
    "aliases": {
      "app-logs": {}
    }
  }
}

PUT _index_template/robot-app
{
  "index_patterns": ["robot-app-*"],
  "composed_of":["little-index","app-logs"]
}

PUT /robot-app-web

GET /robot-app-web
```



## 原理
### es的分布式
在谈及分布式的时候，有两个概念是无法避免的，一个是分片，一个是复制。
分片的作用是将一台服务器放不下的数据分成多个部分放在多台电脑上，一般是根据某种路由算法平均分配。
复制的作用是避免某个节点无法使用导致数据丢失，是保证数据完整性的关键，一般涉及分布式一致性共识算法来保证数据的一致性。
在分片和复制的实践中，不同产品有不同的实践方式，大家可以去了解 kafka、etcd、redis、elasticsearch 等分布式系统的实践。
在es的实践中，我们在创建索引时就需要将配置分片和复制的参数，`number_of_shards` 和 `number_of_replicas`。
#### es的路由算法
es的路由算法采用的是哈希分片路由算法，通过计算文档ID的哈希值，和索引设计的分片数量取模来计算每个文档所在的分片。
具体就是：`Hash(Id)%(number_of_shards)`。
根据这个路由算法，我们可以得出，分片数量一旦确定，后期就无法修改，因为文档的所在的分片都是根据分片数确定好的，若分片数被修改，在查询时，我们取模计算出来的数据就和原来不一致，那样在根据ID来查询时就查询不出来，就出问题了。
#### es的分布式一致性共识算法
es的共识算法是采用了 Zen Discovery 算法来保证主分片和副本分片的数据一致性。
es 的配置参数`write consistency`可以配置 `all`、`one`、`quorum` , 对数据一致性有不同要求，可以配置不同的参数。
### 读写流程
#### 读流程
#### 写流程
### 高亮算法
es支持的高亮显示搜索策略有 `plain`，`unified`，`fvh`。用户可以根据搜索场景进行选择。
`plain` 是精准度比较高的策略，它必须将文档全部加载到内存中，并重新执行查询分析。在处理大量文档或者大文本的索引进行多字段高亮显示搜索时耗费的资源比较严重。
`unified` 是使用的 BM25 算法来进行匹配的，默认是该算法进行高亮显示。
`fvh` 是基于向量的算法，它更适合在文档中包含了大字段的情况，不过当需要使用这种算法时，需要在`mappings`给字段设置结构时添加额外的参数，`term_vector:with_positions_offsets`


## 优化
### 分片和复制的设计

## 部署

## 实战

## 问题

### Ingest 节点 和 Logstash 的区别
- 简单的数据转换
    
    如果只需要进行一些轻量级的数据转换、提取或过滤，而不需要多阶段处理，Ingest Node 可能更适合。
- 多阶段的数据处理
  
  如果需要执行更复杂的数据处理、转换、过滤操作，涉及多阶段的处理流程，或者需要从多个数据源进行数据集成，Logstash 可能更合适。
- 性能考虑
  
  如果性能是首要考虑因素，特别是在大规模数据写入 Elasticsearch 的情况下，Ingest Node 的嵌入式性能优势可能更为明显。
- 独立性
  
  如果需要在数据处理流程中使用不同的工具，或者将数据导出到多个目标系统，Logstash 的独立性可能更为有利。