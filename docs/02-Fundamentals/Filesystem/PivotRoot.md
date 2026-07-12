# PivotRoot

## 简介

本文说明 `pivot_root` 为什么不是简单换工作目录，而是替换当前 mount namespace 的根挂载。

## 背景

在 initramfs、容器和早期启动流程中，系统常需要把“临时根”切换成“正式根”。这不是 `chroot` 能完成的工作。

## 基本概念

- `pivot_root`：把当前根挂载移到 `put_old`，把 `new_root` 变成新的根挂载
- 它操作的是 mount namespace 中的根挂载，而不是单纯路径前缀

## 工作原理

man7 说明 `pivot_root()` 会改变调用进程所在 mount namespace 的 root mount；旧根被移动到 `put_old`，新根成为 `/`。这也是从 initramfs 切换到真实 Rootfs 的关键机制之一。

## 设计目的

- 让系统从临时根切换到正式 Rootfs
- 为 early userspace 和容器 Rootfs 切换提供内核级机制

## 优缺点

优点：

- 语义明确，能真正替换根挂载
- 适合启动阶段和容器场景

缺点：

- 要求更严格，理解门槛高
- 常与 mount namespace、bind mount、旧根清理一并出现

## 典型应用

- initramfs 切换到 flash Rootfs
- 容器运行时挂入新根

## 在 Buildroot 中的位置

Buildroot 产出的镜像在某些启动链中会先由 initramfs 接手，再通过 `pivot_root` 切到真实文件系统。

## 在 OpenWrt 中的位置

OpenWrt 不一定总显式展示 `pivot_root`，但其根挂载切换和 preinit 逻辑与这一类思路紧密相关。

## 在光猫中的体现

光猫和 IoT 设备若使用救援环境、恢复分区或临时 Rootfs，再切换到正式系统时，经常会出现 `pivot_root` 或同类根切换逻辑。

## 实际案例

为什么有些系统会先从 RAM 启动，再切换到 Flash Rootfs？因为早期驱动、校验和挂载准备完成前，临时根更容易控制。

## 实践操作

```bash
pivot_root --help 2>/dev/null
mount | head -n 20
cat /proc/self/mountinfo | head -n 20
```

怎么看：

- `pivot_root --help`：确认工具是否存在，很多极简系统没有用户态包装命令
- `mountinfo`：更适合观察根挂载切换后的层次变化

## 前置知识

- [Mount机制](./Mount机制.md)
- [Mount Namespace](./Mount Namespace.md)
- [Rootfs](./Rootfs.md)

## 后续知识

- [Chroot](./Chroot.md)
- [FactoryFirmware](./FactoryFirmware.md)

## 知识等级

★★★ 了解即可

## 参考资料

- 官方文档：pivot_root(2) `https://man7.org/linux/man-pages/man2/pivot_root.2.html`
- 官方文档：pivot_root(8) `https://man7.org/linux/man-pages/man8/pivot_root.8.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux pivot_root 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
