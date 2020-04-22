# 简介

OpenJDK 1.8 (JDK 8u242) 版本基于的Ubuntu系统的Docker镜像。



## 基本信息

* 镜像地址：endial/openjdk:8u242-jdk
  * 依赖镜像：endial/ubuntu:18.04



## 使用说明

本镜像为基础JAVA环境镜像，主要用来为后续应用开发提供基础环境使用。

基本验证命令：

```shell
docker run -it --rm endial/openjdk:8u242-jre javac -version
```



----

本文原始来源 [Endial Fang](https://github.com/endial) @ [Github.com](https://github.com)

