# readelf

## 简介

本文说明 `readelf` 的作用，以及它为什么是分析嵌入式 Linux 可执行文件时最重要的工具之一。

## 背景

遇到一个陌生二进制时，最有价值的问题通常不是“它叫什么”，而是：

- 属于什么架构
- 是静态还是动态
- 解释器是谁
- 依赖哪些库

`readelf` 正是回答这些问题的核心工具。

## 基本概念

`readelf` 用于读取 ELF 文件内部结构，不依赖执行程序本身。

## 工作原理

它直接解析 ELF Header、Program Header、Section Header、Dynamic Section 等数据结构，并以人类可读方式展示。

## 设计目的

- 帮助开发者理解 ELF 内部结构
- 帮助排查链接和装载问题

## 优缺点

优点：

- 信息权威、直接
- 不需要运行目标程序

缺点：

- 输出较底层
- 需要知道哪些字段最关键

## 典型应用

- 看架构：`readelf -h`
- 看解释器：`readelf -l`
- 看依赖库：`readelf -d`

## 在 Buildroot 中的位置

分析 Buildroot 产物时，`readelf` 是确认 Rootfs 程序属性最直接的工具。

## 在 OpenWrt 中的位置

分析 OpenWrt 包、`staging_dir` 产物和 Rootfs 程序时同样如此。

## 在光猫中的体现

分析光猫 Rootfs 时，通常先对 `busybox`、Web 服务和关键守护进程执行 `readelf -h/-l/-d`。

## 实际案例

程序报 `No such file or directory` 时，`readelf -l` 常能直接看到它请求的解释器路径，快速定位根因。

## 实践操作

```bash
readelf -h busybox
readelf -l busybox
readelf -d busybox
```

怎么看：

- `-h`：看 `Class`、`Data`、`Machine`
- `-l`：看 `INTERP`
- `-d`：看 `NEEDED`

## 前置知识

- ELF文件格式

## 后续知识

- objdump
- ldd
- 动态链接器(ld-linux)

## 知识等级

★★★★★ 必须掌握

对光猫逆向、OpenWrt、Linux 嵌入式排错都非常重要。

## 参考资料

- 官方文档：Binutils Docs `https://sourceware.org/binutils/docs/`
- 官方源码：Binutils `https://sourceware.org/git/?p=binutils-gdb.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 Rootfs ELF 实例验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：readelf 通用使用知识

验证环境：Binutils 实践整理

作者：Codex
