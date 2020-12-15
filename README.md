# 简介

针对 OpenJDK 的 Docker 镜像，用于提供基础 Java 开发环境及运行环境。

使用说明可参考：官方说明



**JDK 版本信息：**

- 8u262

**镜像信息：**

- 镜像地址：registry.cn-shenzhen.aliyuncs.com/colovu/openjdk:latest

  

## **TL;DR**

基本验证命令：

```shell
# 11之前的版本
$ docker run -it --rm registry.cn-shenzhen.aliyuncs.com/colovu/openjdk javac -version

# 11之后的版本
$ docker run -it --rm registry.cn-shenzhen.aliyuncs.com/colovu/openjdk javac --version
```



----

本文原始来源 [Endial Fang](https://github.com/colovu) @ [Github.com](https://github.com)

