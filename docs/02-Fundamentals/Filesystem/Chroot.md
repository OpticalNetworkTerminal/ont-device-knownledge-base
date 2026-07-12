# Chroot

## 简介

本文说明 `chroot` 的作用、局限，以及它为什么经常被误当成“完整隔离”。

## 背景

很多调试和固件分析流程会把解包后的 Rootfs 作为 `chroot` 环境运行，但这不等于真正切换了内核视角。

## 基本概念

- `chroot`：改变进程解析绝对路径 `/` 的起点
- 它主要影响路径解析，不会自动复制 mount、PID、network 等其它资源视图

## 工作原理

man7 说明 `chroot()` 会改变调用进程的根目录，用于解析以 `/` 开头的路径。它适合测试某个 Rootfs 内部的用户态布局，但不等同于容器。

## 设计目的

- 为固件分析、修复和最小隔离提供路径级根切换
- 帮助在宿主机上模拟目标 Rootfs 的目录结构

## 优缺点

优点：

- 简单直接
- 对离线 Rootfs 调试很有用

缺点：

- 不是安全边界
- 若缺少 `/proc`、`/dev`、动态库或解释器，环境很容易跑不起来

## 典型应用

- 在宿主机上进入解包 Rootfs
- 最小恢复环境

## 在 Buildroot 中的位置

Buildroot 生成的 `target/` 并不等于可直接 `chroot` 运行的最终系统，很多设备节点和权限会在最终镜像阶段补齐。

## 在 OpenWrt 中的位置

OpenWrt Rootfs 离线调试时常会借助 `chroot`，但 Overlay、设备节点和运行时 API 仍需额外挂载。

## 在光猫中的体现

光猫固件解包后如果想运行其中的用户态程序，经常会先用 `chroot` 做目录模拟，再补 `/proc`、`/sys`、`/dev`。

## 实际案例

为什么 `chroot` 进去后很多命令还是报错？因为你只换了路径根，没有自动带上内核接口文件系统和真实设备环境。

## 实践操作

```bash
sudo chroot /tmp/rootfs /bin/sh 2>/dev/null
mount --bind /dev /tmp/rootfs/dev 2>/dev/null
mount -t proc proc /tmp/rootfs/proc 2>/dev/null
```

怎么看：

- `chroot`：只改变根目录视角
- 常见配套动作是 bind `/dev`、挂 `/proc`，否则很多程序无法工作

## 前置知识

- [Rootfs](./Rootfs.md)
- [Mount机制](./Mount机制.md)

## 后续知识

- [PivotRoot](./PivotRoot.md)
- [Firmware文件结构](./Firmware文件结构.md)

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：chroot(2) `https://man7.org/linux/man-pages/man2/chroot.2.html`
- 官方文档：chroot(1) `https://man7.org/linux/man-pages/man1/chroot.1.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux chroot 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
