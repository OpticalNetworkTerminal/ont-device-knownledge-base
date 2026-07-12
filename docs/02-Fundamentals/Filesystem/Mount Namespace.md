# Mount Namespace

## 简介

本文说明 mount namespace 为什么能让不同进程看到不同的挂载视图，以及它和容器、`pivot_root`、只读根文件系统切换之间的关系。

## 背景

仅理解 mount 还不够。容器、chroot 环境、服务沙箱之所以能看到“自己的文件系统视图”，关键在于 mount namespace 把挂载表隔离开来。

## 基本概念

- mount namespace：进程可见挂载列表的隔离实例
- 同一内核可以并存多个挂载视图
- `/proc/<pid>/mounts` 和 `mountinfo` 会随 namespace 不同而变化

## 工作原理

man7 指出 mount namespace 会隔离每个实例中的挂载列表；新 namespace 通常从父进程复制一份初始挂载列表，然后各自再独立修改。

## 设计目的

- 为容器、沙箱和 early userspace 根切换提供挂载视图隔离
- 让 Rootfs 切换不必影响宿主全局挂载表

## 优缺点

优点：

- 非常适合理解容器文件系统视图
- 能解释“同一路径在不同进程里不一样”

缺点：

- 传播规则、shared subtree 等细节较复杂
- 不等于完整安全隔离

## 典型应用

- LXC / Docker 文件系统视图
- systemd 服务私有挂载
- initramfs 过渡到真实 Rootfs

## 在 Buildroot 中的位置

Buildroot 生成的系统如果要支持容器或隔离式服务，就会直接或间接依赖 mount namespace。

## 在 OpenWrt 中的位置

OpenWrt 不是以容器为核心，但在更复杂插件化或隔离场景里，mount namespace 仍是重要基础。

## 在光猫中的体现

光猫和网关如果引入 LXC、沙箱插件或隔离式维护环境，mount namespace 能让不同业务看到不同 Rootfs 组合。

## 实际案例

为什么容器里有自己的 `/proc/mounts`，但宿主看见的挂载树又不同？因为它们不在同一个 mount namespace 里。

## 实践操作

```bash
ls /proc/self/ns
readlink /proc/self/ns/mnt
cat /proc/self/mounts | head -n 20
cat /proc/self/mountinfo | head -n 20
```

怎么看：

- `/proc/self/ns/mnt`：看当前进程挂载命名空间对象
- `mounts` / `mountinfo`：看当前进程视角下的挂载表
- 多个环境里比较这些文件时差异尤其明显

## 前置知识

- [Mount机制](./Mount机制.md)
- [LinuxRuntime/Namespace](../LinuxRuntime/Namespace.md)

## 后续知识

- [PivotRoot](./PivotRoot.md)
- [Chroot](./Chroot.md)
- [LXC/README](../LXC/README.md)

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：mount_namespaces(7) `https://man7.org/linux/man-pages/man7/mount_namespaces.7.html`
- 官方文档：pivot_root(2) `https://man7.org/linux/man-pages/man2/pivot_root.2.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux mount namespace 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
