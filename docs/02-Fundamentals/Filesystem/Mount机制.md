# Mount机制

## 简介

本文从文件系统组织角度说明 mount 为什么是把“文件系统实例接到目录树上”，以及它在 Rootfs、Overlay、伪文件系统和固件分析中的意义。

## 背景

同样是“文件系统”，只有被 mount 到目录树，用户态才真正看见它。Rootfs、`/proc`、`/sys`、`/dev`、Overlay 都离不开 mount。

## 基本概念

- 挂载点：目录树中的接入点
- 挂载源：块设备、MTD/UBI 卷、镜像文件、伪文件系统名等
- 同一路径在 mount 前后可呈现完全不同内容

## 工作原理

一个文件系统镜像、一个分区、甚至一个内核伪文件系统，只有被挂到某个路径后才成为运行时视图的一部分。嵌入式系统常用 mount 先建立只读基线，再挂入 Overlay、tmpfs 和运行时 API 文件系统。

## 设计目的

- 把镜像、分区和路径视图连接起来
- 理解 Rootfs、Overlay、挂载传播和容器视图

## 优缺点

优点：

- 是所有文件系统分析的总入口
- 能快速解释“为什么这里突然出现一棵新树”

缺点：

- 只看目录不看 mount 会严重误判
- bind mount、namespace、Overlay 会增加层次复杂度

## 典型应用

- 根文件系统挂载
- `procfs` / `sysfs` / `devtmpfs` 挂载
- loop 挂载镜像文件
- 容器私有挂载

## 在 Buildroot 中的位置

Buildroot 负责生成镜像，但真正系统怎么挂，取决于启动脚本、内核参数和产品布局。

## 在 OpenWrt 中的位置

OpenWrt 的根挂载、Overlay、`rootfs_data`、恢复出厂行为，都必须通过 mount 关系来理解。

## 在光猫中的体现

光猫现场排错时，`mount` 通常比单纯 `ls` 更能说明问题，因为很多“目录内容变化”本质上是挂载关系变化。

## 实际案例

为什么解包固件看见的 `rootfs.squashfs` 内容，和设备运行时 `/` 下看到的内容不完全一致？因为运行时还叠加了 `tmpfs`、Overlay 和伪文件系统。

## 实践操作

```bash
mount
cat /proc/mounts
findmnt 2>/dev/null | head -n 30
cat /proc/filesystems
```

怎么看：

- `mount` / `/proc/mounts`：看源、目标、类型和选项
- `findmnt`：看树状层次
- `/proc/filesystems`：确认内核是否支持某种挂载类型

## 前置知识

- [LinuxRuntime/Mount机制](../LinuxRuntime/Mount机制.md)
- [VFS虚拟文件系统](./VFS虚拟文件系统.md)

## 后续知识

- [Mount Namespace](./Mount Namespace.md)
- [PivotRoot](./PivotRoot.md)
- [LoopDevice](./LoopDevice.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：mount(8) `https://man7.org/linux/man-pages/man8/mount.8.html`
- 官方文档：mount_namespaces(7) `https://man7.org/linux/man-pages/man7/mount_namespaces.7.html`
- 官方文档：Linux Filesystems Index `https://docs.kernel.org/filesystems/index.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux mount 机制的文件系统视角

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
