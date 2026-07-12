# ldd

## 简介

本文说明 `ldd` 的作用，以及它在分析动态程序依赖时的价值与局限。

## 背景

很多人把 `ldd` 当作“看依赖库”的万能工具，但它其实依赖目标程序的动态装载逻辑，因此在陌生固件、陌生架构、可疑样本上要谨慎使用。

## 基本概念

`ldd` 用于显示动态程序在当前运行环境下会解析到哪些共享库。

## 工作原理

它通常借助动态链接器机制来展示依赖解析结果，因此它看到的是“当前环境下的解析结果”，不一定等于“原目标设备上的真实结果”。

## 设计目的

- 快速显示动态依赖
- 辅助排查缺库、路径问题

## 优缺点

优点：

- 快
- 输出直观

缺点：

- 依赖当前环境
- 不能替代 `readelf -d`
- 对跨架构样本往往不能直接用

## 典型应用

- 查看共享库依赖
- 判断依赖是否缺失
- 验证当前 Rootfs 解析结果

## 在 Buildroot 中的位置

分析 Buildroot 产物在目标环境中的依赖时很实用，但应结合 `readelf -d` 一起看。

## 在 OpenWrt 中的位置

OpenWrt Rootfs 中常可直接用它看包依赖结果，但跨平台分析时仍要谨慎。

## 在光猫中的体现

登录到设备 shell 后，`ldd` 常常是排查运行时缺库的第一工具；但离线分析固件时，`readelf` 通常更可靠。

## 实际案例

在 x86_64 主机上对 ARM 程序执行 `ldd` 往往没有意义，因为当前环境根本不是该程序的真实解释环境。

## 实践操作

```bash
ldd busybox
readelf -d busybox
```

怎么看：

- `ldd`：看当前环境解析出的库路径
- `readelf -d`：看 ELF 原始声明的 `NEEDED`

## 前置知识

- 动态链接
- 动态链接器(ld-linux)

## 后续知识

- 常见问题
- glibc
- musl

## 知识等级

★★★★ 建议掌握

对运行时排错非常有用，但必须理解其边界。

## 参考资料

- 官方文档：glibc Manual `https://sourceware.org/glibc/manual/`
- 官方源码：glibc `https://sourceware.org/git/?p=glibc.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合目标设备 shell 实践验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：ldd 通用使用知识

验证环境：动态链接排错经验整理

作者：Codex
