# tmpfs

## 简介

本文从文件系统章节视角说明 `tmpfs` 为什么在嵌入式系统中常用于运行时状态，而不适合承载持久化配置。

## 背景

设备空间有限、Flash 写入代价高，许多运行时数据不应写回持久介质；这时 `tmpfs` 就成为理想的临时承载层。

## 基本概念

- `tmpfs`：以内存为主的临时文件系统
- 通常用于 `/tmp`、`/run`、缓存、socket、PID 文件

## 工作原理

`tmpfs` 挂上后，对应目录变成内存文件系统视图。数据可能交换到 swap，但在很多嵌入式系统里它主要就是易失性存储。

## 设计目的

- 提供快速可写空间
- 减少对 Flash 的频繁写入
- 承载运行时易失状态

## 优缺点

优点：

- 速度快
- 重启自动清空，适合临时数据

缺点：

- 占用内存
- 不适合配置持久化

## 典型应用

- `/tmp`
- `/run`
- 临时日志和 socket 文件

## 在 Buildroot 中的位置

Buildroot 系统常在启动时挂载 `tmpfs` 提供可写运行时目录，尤其是在只读 Rootfs 场景中。

## 在 OpenWrt 中的位置

OpenWrt 也广泛使用 `tmpfs` 存放运行时状态，因此很多问题 reboot 后会“消失”。

## 在光猫中的体现

光猫和 IoT 设备经常把 PID、socket、临时日志放在 `tmpfs`，这样既减轻 Flash 写放大，也便于恢复。

## 实际案例

为什么 `/tmp` 里的文件重启就没了？因为它通常根本不在持久化文件系统里，而是在 `tmpfs` 上。

## 实践操作

```bash
mount | grep tmpfs
df -h | grep tmpfs
find /tmp -maxdepth 2 -type f 2>/dev/null | head
```

怎么看：

- `mount`：看哪些目录用了 `tmpfs`
- `df -h`：看容量是否来自内存分配
- 观察 `/tmp` 内容有助于区分运行时状态和持久化配置

## 前置知识

- [LinuxRuntime/Tmpfs](../LinuxRuntime/Tmpfs.md)
- [Overlay机制](./Overlay机制.md)

## 后续知识

- [ramfs](./ramfs.md)
- [常见问题](./常见问题.md)

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：Kernel filesystems docs `https://docs.kernel.org/filesystems/index.html`
- 标准：mount(8) `https://man7.org/linux/man-pages/man8/mount.8.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：tmpfs 的文件系统分析视角

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
