# docker-compose日常使用
## docker-compose 命令
### 添加docker执行的环境变量
`docker-compose --env-file ./config/.env.dev up`
默认加载 `.env` 文件
### 执行容器的激活状态
`docker-compose --profile debug up`
## yml配置文件说明
### 主要结构
services：用于配置容器相关参数
networks: 定义容器依赖的网络
volumes: 定义容器依赖的数据卷

### 配置参数说明
```yml
# 该文件可以直接获取操作系统环境变量 ， 使用方式 ${环境变量名}
version: "3.9"
services:
  # 服务名
  web:
    # 指定环境变量的文件
    env_file:
      -  ./Docker/api/api.env
    # 设置环境变量参数，启动后的容器的环境变量包含这些，专注于服务运行中的环境变量。
    environment:
      FLASK_ENV: development
    # 设置环境变量参数，启动后的容器的环境变量不包含这些，专注于构建过程的变量。
    args:
      buildno: 1
      password: secret
    # 指定dockerfile的地址，通过该dockerfile构建镜像，镜像名为build指定的名称。
    build: .
      context: ./dir
      # 指定 dockerfile 文件，基于build查找
      dockerfile: Dockerfile-alternate
    # 指定构建的镜像
    image: nginx:1.21.1
    # 容器名称
    container_name: app
    # 指定端口
    ports:
      - "8000:5000"
    # 指定数据卷
    volumes:
      - .:/code
    # 从其他容器中读取数据卷
    volumes_from:
      - service_name
      - service_name:ro
      - container:container_name
      - container:container_name:rw
    # 依赖其他服务，当compose当中定义了多个服务时
    depends_on:
      - db
      - cache
    # 用来设置容器间的网络链接
    links:
      - db
      - redis
    # 设置容器链接的网络
    networks:
     - some-network
     - other-network
    # 指定容器生效的状态
    profiles: ["debug"]
    # 用于链接非此compose内部的容器，对网络有要求
    external_links:
      - project_db_1:mysql
      - project_db_1:postgresql
    # 用来修改/etc/hosts内容
    extra_hosts:
        somehost: "162.242.195.82"
        otherhost: "50.31.209.229"
  cache:
    image: "redis:alpine"
  db:
    image: "postgres:latest"

# 定义网络
networks:
  # 定义网络名
  web:
    # 定义网络的模式
    driver: bridge
```