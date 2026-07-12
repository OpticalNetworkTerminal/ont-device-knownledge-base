# VFS虚拟文件系统

## 简介

本文从文件系统分层角度说明 VFS 为什么能把 `ext4`、`SquashFS`、`procfs`、`sysfs`、设备节点和 `socket` 都纳入统一文件接口。

## 背景

在嵌入式现场经常会遇到这种误解：既然都是路径，那底层都应该一样可复制、可编辑、可持久化。VFS 的存在正是为了提供统一接口，但不保证底层语义完全相同。

## 基本概念

- VFS：内核中的统一文件系统抽象层
- superblock / inode / dentry / file：VFS 中的核心对象
- 不同文件系统通过各自实现接入同一套 `open/read/write/stat` 接口

## 工作原理

Kernel 文档把 VFS 描述为“向用户态提供文件系统接口、向内核内部提供统一抽象”的软件层。用户态看到的路径访问先经过 VFS，再路由到具体文件系统实现。

## 设计目的

- 统一用户态接口
- 允许多种文件系统和特殊对象并存
- 让 Rootfs、伪文件系统和设备节点可以组织成单一目录树

## 优缺点

优点：

- 接口统一
- 为 Overlay、mount、设备节点等高级机制提供基础

缺点：

- 统一接口不代表语义相同
- 只理解路径不理解底层类型时容易误判

## 典型应用

- 同一路径树里混合 `SquashFS`、`tmpfs`、`procfs`
- 让 `/dev/null`、Unix socket 和普通文件都能走文件描述符模型

## 在 Buildroot 中的位置

Buildroot 生成的 Rootfs 最终之所以能被挂成统一目录树，依赖的就是 VFS 把多种文件系统和设备对象拼到一起。

## 在 OpenWrt 中的位置

OpenWrt 的只读 `SquashFS`、可写 Overlay、`/proc`、`/sys`、`/dev` 全都建立在 VFS 的统一视图上。

## 在光猫中的体现

光猫分析里经常同时看到普通配置文件、设备节点、Unix socket 和伪文件系统目录；如果不先理解 VFS，就很难解释这些对象为什么都“像文件”。

## 实际案例

为什么 `/etc/config` 和 `/proc/mtd` 看起来都能 `cat`，但一个来自磁盘或 Flash，一个来自内核实时接口？因为 VFS 统一了访问入口，而不是统一了数据来源。

## 实践操作

```bash
cat /proc/filesystems
mount
ls -l /dev | head -n 20
find / -type s 2>/dev/null | head
```

怎么看：

- `/proc/filesystems`：看 VFS 目前注册了哪些文件系统类型
- `mount`：看同一目录树中叠加了哪些实现
- `ls -l /dev`：看设备节点也是 VFS 对象
- `find -type s`：看 Unix Domain Socket 也能出现在路径中

## 前置知识

- [LinuxRuntime/VFS](../LinuxRuntime/VFS.md)
- [LinuxRuntime/SystemCall](../LinuxRuntime/SystemCall.md)

## 后续知识

- [Mount机制](./Mount机制.md)
- [BlockDevice与CharacterDevice](./BlockDevice与CharacterDevice.md)
- [Device Node](./Device Node.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Overview of the Linux Virtual File System `https://docs.kernel.org/filesystems/vfs.html`
- 官方文档：Linux Kernel Filesystems Index `https://docs.kernel.org/filesystems/index.html`
- 标准：proc / mount 相关 man pages `https://man7.org/linux/man-pages/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux VFS 文件系统视角通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
