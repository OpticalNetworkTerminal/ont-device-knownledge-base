# file命令

## 简介

本文说明 `file` 命令为什么是分析嵌入式 Linux 二进制时的第一眼工具。

## 背景

看到一个陌生文件，最先要问的是“它到底是什么”。`file` 往往能在一行里告诉你：是不是 ELF、是 32 位还是 64 位、大小端、架构、是否动态链接。

## 基本概念

`file` 通过魔数和规则库识别文件类型。

## 工作原理

它并不执行程序，而是读取文件头和特征信息，根据规则判断文件类型和基础属性。

## 设计目的

- 快速识别文件类型
- 为后续 deeper analysis 提供方向

## 优缺点

优点：

- 快
- 对初步判断非常有效

缺点：

- 细节不如 `readelf`
- 有时描述看起来容易误解

## 典型应用

- 判断 `busybox` 是否是 ARM / MIPS / x86 程序
- 判断是动态还是静态
- 判断是 `LSB` 还是 `MSB`

## 在 Buildroot 中的位置

Buildroot 手册甚至把 `file` 列为常用宿主工具之一，说明它在构建和分析流程中的基础地位。

## 在 OpenWrt 中的位置

分析 OpenWrt 包和 Rootfs 文件时，同样常以 `file` 起手。

## 在光猫中的体现

离线解包光猫固件后，最先对关键程序执行 `file`，几乎总是高价值操作。

## 实际案例

`file` 显示 `ELF 64-bit LSB shared object` 时，不要立刻断定“这只是库”。现代 PIE 可执行文件也可能这样显示，还要继续用 `readelf` 判断。

## 实践操作

```bash
file busybox
file libc.so*
```

怎么看：

- `ELF 32-bit / 64-bit`：看位宽
- `LSB / MSB`：看端序
- `ARM / MIPS / x86-64`：看架构
- `dynamically linked`：看是否依赖动态链接

## 前置知识

- CPU架构
- ELF文件格式

## 后续知识

- readelf
- objdump
- 常见问题

## 知识等级

★★★★★ 必须掌握

是所有二进制分析的第一步。

## 参考资料

- 官方文档：Buildroot Manual `https://buildroot.org/manual.html`
- 官方源码：`file` 项目与 Binutils 相关工具文档
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 Rootfs 可执行文件验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：file 命令通用使用知识

验证环境：Buildroot / ELF 实践整理

作者：Codex
