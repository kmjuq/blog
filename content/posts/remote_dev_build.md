---
title: "Remote_dev_build"
date: 2023-02-24T01:59:39+08:00
draft: true
---

## vscode远程开发环境搭建
docker 准备开发环境, dockerfile 如下:
```dockerfile
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk update && \
    apk add openjdk17 --no-cache && \
    apk add maven --no-cache && \
    apk add git
```
通过dockerfile文件建立image后,就可以通过 vscode remote 功能连接 docker 容器.需要在项目下的 vscode settings 里面添加如下设置,指定jdt环境和,运行时环境.
```json
{
    "java.compile.nullAnalysis.mode": "automatic",
    "java.jdt.ls.java.home": "/usr/lib/jvm/java-17-openjdk",
    "java.configuration.runtimes": [
        {
            "name": "JavaSE-17",
            "path": "/usr/lib/jvm/java-17-openjdk",
            "default": true
        }
    ]
}
```