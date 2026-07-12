# 大小端(LittleEndian_BigEndian)

## 简介

本文说明大小端的含义，以及它为什么会影响 ELF、共享库和跨设备运行兼容性。

## 背景

很多人知道“大小端”这个词，但不知道它为什么会让程序不兼容。原因是：端序不仅影响内存中数据如何排列，也影响 ELF 对象文件和 ABI 的解释方式。

## 基本概念

- Little Endian：低字节放低地址
- Big Endian：高字节放低地址

ELF 头中的 `EI_DATA` 会明确标识对象文件的数据编码方式。

## 工作原理

CPU、ABI、对象文件格式、共享库都要对数据字节顺序有一致理解。若 ELF 按大端编码，而运行环境按小端解释，内容就会被错误解析。

## 设计目的

端序本身不是“谁更先进”，它只是不同体系结构历史选择的一部分。关键在于整个运行环境要保持一致。

## 优缺点

优点：

- 不同架构可根据历史和实现选择端序

缺点：

- 造成跨平台二进制兼容复杂度
- 同一架构家族内部也可能出现端序分化

## 典型应用

- ARM 通常以小端为主
- MIPS 历史上大端、小端都常见
- 网络协议字段与主机端序转换是常见场景

## 在 Buildroot 中的位置

Buildroot 架构配置会隐含或显式决定端序，进而影响工具链和 ELF 产物。

## 在 OpenWrt 中的位置

OpenWrt 某些历史平台需要区分大小端目标，因此包与 Rootfs 也需分别构建。

## 在光猫中的体现

在历史 MIPS 光猫中，大小端差异常见于：

- ELF `LSB/MSB`
- Rootfs 中共享库完全不通用
- 网络守护进程源码需要频繁做字节序转换

## 实际案例

把 MIPS 大端程序放到 MIPS 小端系统，常常不是“逻辑错”，而是根本无法作为有效目标文件使用。

## 实践操作

```bash
file busybox
readelf -h busybox
hexdump -C busybox | head
```

怎么看：

- `file` 里会出现 `LSB` 或 `MSB`
- `readelf -h` 里 `Data` 字段更标准
- `hexdump` 适合辅助理解字节顺序，但不适合单独判断兼容性

## 前置知识

- CPU架构

## 后续知识

- ELF文件格式
- ABI
- MIPS

## 知识等级

★★★★ 建议掌握

对历史网络设备、协议分析、二进制兼容性判断很重要。

## 参考资料

- 官方文档：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.eheader.html`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：ELF `EI_DATA` 定义 `https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.eheader.html`
- GPL源码：后续结合 GPL 程序头部验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：通用 ELF / CPU 端序知识

验证环境：ELF 标准整理

作者：Codex
