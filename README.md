# 简介

OpenJDK 基于Ubuntu系统的Docker镜像。

**JDK 版本信息：**

- 11、11.0.7-jdk、latest
- 1.8、8u252-jdk
- 1.8、8u242-jdk

**JRE 版本信息：**

- 11、11.0.7-jre、latest
- 1.8、8u252-jre
- 1.8、8u242-jre



**镜像信息：**

- 镜像地址：colovu/openjdk:latest
  - 依赖镜像：colovu/ubuntu:latest



## 使用说明

本镜像为基础JAVA环境镜像，主要用来为后续应用开发提供基础环境使用。

基本验证命令：

```shell
# 11之前的版本
$ docker run -it --rm colovu/openjdk:latest javac -version

# 11之后的版本
$ docker run -it --rm colovu/openjdk:latest javac --version
```



----

本文原始来源 [Endial Fang](https://github.com/colovu) @ [Github.com](https://github.com)

