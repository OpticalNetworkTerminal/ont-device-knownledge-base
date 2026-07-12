# objdump

## 简介

本文说明 `objdump` 的作用，以及它和 `readelf` 在嵌入式 Linux 分析中的区别。

## 背景

`readelf` 更专注于读 ELF 结构；`objdump` 则更像一个综合查看器，既能看头信息，也能看反汇编、符号、段信息。

## 基本概念

`objdump` 是 binutils 的目标文件分析工具。

## 工作原理

它会解析对象文件结构，并按不同选项展示头部、节区、符号表、反汇编结果等。

## 设计目的

- 提供比 `readelf` 更综合的对象文件视角
- 支持反汇编与调试分析

## 优缺点

优点：

- 功能多
- 可同时看结构和机器码

缺点：

- 选项多
- 初学者容易信息过载

## 典型应用

- `objdump -x`：看综合头信息
- `objdump -d`：看反汇编
- `objdump -T`：看动态符号

## 在 Buildroot 中的位置

分析 Buildroot 产物时，`objdump` 常用于确认链接属性和查看反汇编。

## 在 OpenWrt 中的位置

分析 OpenWrt 包和根文件系统中的共享库、程序时同样常用。

## 在光猫中的体现

当你想判断某个守护进程是否静态链接、导出了哪些符号，或想粗看控制流，`objdump` 很实用。

## 实际案例

`objdump -x` 能帮助你把 `file`、`readelf` 的碎片信息拼成一个更完整的判断。

## 实践操作

```bash
objdump -x busybox | head -n 80
objdump -d busybox | head -n 80
```

怎么看：

- `-x`：优先看格式、架构、动态段
- `-d`：看是否确实是目标架构机器码

## 前置知识

- ELF文件格式
- readelf

## 后续知识

- strings命令
- strip
- 常见问题

## 知识等级

★★★★ 建议掌握

对光猫逆向和 Linux 二进制分析很有帮助。

## 参考资料

- 官方文档：Binutils Docs `https://sourceware.org/binutils/docs/`
- 官方源码：Binutils `https://sourceware.org/git/?p=binutils-gdb.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 Rootfs 实际程序验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：objdump 通用使用知识

验证环境：Binutils 实践整理

作者：Codex
