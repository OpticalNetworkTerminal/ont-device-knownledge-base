# Mount机制

## 简介

本文说明 mount 的作用，以及为什么“挂载之后目录里就出现了一棵树”。

## 背景

很多人把 mount 理解成“把磁盘接上去”。更准确地说，Linux 的 mount 是把一个文件系统实例接到统一目录树中的某个挂载点。

## 基本概念

- 挂载点：目录树中的接入点
- 文件系统实例：可以是磁盘文件系统，也可以是 procfs、sysfs、tmpfs、devtmpfs

## 工作原理

执行 mount 后，内核把该文件系统实例接到目录树指定位置。从此访问该目录，就看到新挂载文件系统的内容。

## 设计目的

- 提供统一目录树
- 屏蔽底层存储和接口差异
- 支持运行时动态插入不同文件系统

## 优缺点

优点：

- 统一
- 灵活

缺点：

- 挂载关系复杂时排错困难

## 典型应用

- 根文件系统
- `/proc`、`/sys`、`/dev`
- tmpfs、bind mount、容器私有挂载

## 在 Buildroot 中的位置

Buildroot 系统启动后通常会立即挂载 `/proc`、`/sys`、`/dev`、`/run` 等关键文件系统。

## 在 OpenWrt 中的位置

OpenWrt 同样依赖挂载机制提供根文件系统、overlay 和 API 文件系统。

## 在光猫中的体现

光猫里常见的根文件系统、可写 overlay、`/proc`、`/sys`、`/dev`、`/tmp` 都要通过 mount 组织起来。

## 实际案例

为什么 mount 以后就出现一个目录？因为你不是复制了一堆文件，而是让那个目录成为另一个文件系统的入口。

## 实践操作

```bash
mount
cat /proc/mounts
findmnt 2>/dev/null | head -n 30
```

怎么看：

- `mount` / `/proc/mounts`：看挂载源、挂载点、文件系统类型
- `findmnt`：若可用，可更直观看层级关系

## 前置知识

- VFS

## 后续知识

- Proc文件系统
- Sysfs
- Namespace

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Kernel filesystems docs `https://docs.kernel.org/filesystems/index.html`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：mount 相关 man pages `https://man7.org/linux/man-pages/`
- GPL源码：后续结合 `/proc/mounts` 与 Rootfs 布局验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：LWN `https://lwn.net/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux mount 通用知识

验证环境：man7 与运行时挂载实践整理

作者：Codex
