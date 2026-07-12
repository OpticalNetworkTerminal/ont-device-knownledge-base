# ramfs

## 简介

本文说明 `ramfs` 与 `tmpfs` 的区别，以及为什么大多数嵌入式系统更常用 `tmpfs` 而不是 `ramfs`。

## 背景

两者都和“内存文件系统”有关，但工程上差别很大。不了解这点，就很难理解为什么系统普遍推荐 `tmpfs`。

## 基本概念

- `ramfs`：简单的内存文件系统
- 与 `tmpfs` 相比，`ramfs` 没有大小限制与回收控制

## 工作原理

`ramfs` 把页缓存直接暴露成文件系统视图，写入内容会无限消耗内存；`tmpfs` 则提供了更可控的内存文件系统实现。

## 设计目的

- 解释为什么“都在内存里”并不代表可替换
- 帮助理解系统为什么更偏向 `tmpfs`

## 优缺点

优点：

- 概念简单
- 适合理解内存文件系统演化

缺点：

- 缺少限制，现场风险大
- 实际部署中通常不如 `tmpfs` 安全

## 典型应用

- 早期或极简内存文件系统讨论
- 对比 `tmpfs` 设计

## 在 Buildroot 中的位置

Buildroot 若要提供运行时可写空间，通常更推荐 `tmpfs` 这类可控实现，而不是无上限的 `ramfs`。

## 在 OpenWrt 中的位置

OpenWrt 等面向长期稳定运行的系统也更需要可控内存消耗，因此实际更常见 `tmpfs`。

## 在光猫中的体现

在光猫和 IoT 场景中，内存本就紧张，`ramfs` 无限制增长的风险尤其不适合现场系统。

## 实际案例

为什么 `ramfs` 常被拿来讲原理却很少成为默认方案？因为它简单，但对内存边界太不友好。

## 实践操作

```bash
cat /proc/filesystems | grep ramfs
mount | grep ramfs 2>/dev/null
```

怎么看：

- `/proc/filesystems`：确认内核是否支持 `ramfs`
- 现场一般较少看到真实挂载，更多是作为与 `tmpfs` 的概念对比

## 前置知识

- [tmpfs](./tmpfs.md)
- [Linux文件系统概述](./Linux文件系统概述.md)

## 后续知识

- [常见问题](./常见问题.md)

## 知识等级

★★★ 了解即可

## 参考资料

- 官方文档：Kernel filesystems docs `https://docs.kernel.org/filesystems/index.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：ramfs 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
