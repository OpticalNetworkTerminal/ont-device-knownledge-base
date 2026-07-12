# Tmpfs

## 简介

本文说明 tmpfs 的作用，以及为什么 `/run`、`/tmp` 等目录经常是“重启即失”的内存文件系统。

## 背景

嵌入式设备常常不适合把所有运行时数据写回 Flash。tmpfs 为运行时状态和临时文件提供了可写但非持久的空间。

## 基本概念

tmpfs 是以内存为主的临时文件系统，常用于保存运行时状态和临时文件。

## 工作原理

挂载 tmpfs 后，对应路径得到新的内存文件系统视图，目录仍在原位置，但内容由 tmpfs 提供。

## 设计目的

- 提供快速可写空间
- 避免频繁写 Flash
- 适合 PID 文件、socket 文件、临时缓存

## 优缺点

优点：

- 快
- 可写
- 重启自动清空

缺点：

- 占用内存
- 不适合持久化

## 典型应用

- `/run`
- `/tmp`
- 容器运行时目录

## 在 Buildroot 中的位置

Buildroot 设备常在启动时挂载 `/run` 或 `/tmp` 为 tmpfs，以便在只读 Rootfs 上提供可写空间。

## 在 OpenWrt 中的位置

OpenWrt 同样大量依赖 tmpfs 存放运行时状态和轻量缓存。

## 在光猫中的体现

光猫的 PID 文件、临时 socket、运行时缓存和一部分日志缓冲，常常位于 tmpfs 上。

## 实际案例

为什么某个目录 reboot 后内容全没了？因为它不是普通持久目录，而是 tmpfs。

## 实践操作

```bash
mount | grep tmpfs
df -h | grep tmpfs
```

怎么看：

- `mount`：看哪些路径挂了 tmpfs
- `df -h`：看容量和使用情况

## 前置知识

- Mount机制
- VFS

## 后续知识

- Devtmpfs
- 日志系统

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：Kernel filesystems docs `https://docs.kernel.org/filesystems/index.html`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：Linux man-pages `https://man7.org/linux/man-pages/`
- GPL源码：后续结合 `/run`、`/tmp` 挂载验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux tmpfs 通用知识

验证环境：运行时挂载实践整理

作者：Codex
