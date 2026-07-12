# OverlayFS

## 简介

本文说明 Linux `overlayfs` 是如何把 upper、lower 合并成一个挂载视图的，以及它为什么适合承载嵌入式设备的 Overlay 设计。

## 背景

`Overlay机制` 讲的是设计思想；`overlayfs` 则是 Linux 内核中的具体实现。很多 OpenWrt、容器和只读镜像系统都会直接或间接使用它。

## 基本概念

- `lowerdir`：只读或基线层
- `upperdir`：可写覆盖层
- `workdir`：overlayfs 内部工作目录
- 同名对象冲突时，upper 层优先可见

## 工作原理

Kernel 文档指出 overlayfs 会把两个文件系统组合为一个视图：同名对象若同时存在，upper 层对象可见；目录则可能发生合并。删除 lower 层文件时，upper 层会创建 whiteout 或标记来表达“逻辑删除”。

## 设计目的

- 提供内核级的分层合并文件系统
- 让用户看到统一目录树而无需感知 lower / upper 分离
- 为只读系统追加最小写入层

## 优缺点

优点：

- 对用户态透明
- 很适合系统基线稳定、现场变化有限的设备

缺点：

- whiteout、rename、xattr 等细节增加理解成本
- 并不是所有底层文件系统都适合做 upper 层

## 典型应用

- OpenWrt 根文件系统合并
- 容器镜像分层
- 只读系统叠加可写运行时状态

## 在 Buildroot 中的位置

Buildroot 侧通常不直接“生成 overlayfs 镜像”，而是生成 lower 层镜像；产品系统在启动时再按分区和脚本挂成 overlayfs。

## 在 OpenWrt 中的位置

OpenWrt 的用户可写视图与保留配置能力，强烈依赖 Overlay / overlayfs 语义；这是理解 `firstboot`、`jffs2reset` 的关键背景。

## 在光猫中的体现

光猫和路由器现场常见现象是“文件能改，但底层镜像其实没动”；overlayfs 正是把这种逻辑写入与物理存储分层隔开的核心机制。

## 实际案例

为什么删除一个来自只读层的文件后，它不会真的从 `SquashFS` 消失？因为 overlayfs 往往只在 upper 层记一笔“这个名字应被隐藏”。

## 实践操作

```bash
mount | grep overlay
cat /proc/mounts | grep overlay
findmnt -t overlay 2>/dev/null
```

怎么看：

- `mount` / `/proc/mounts`：看 overlayfs 的 lowerdir、upperdir、workdir 参数
- `findmnt -t overlay`：快速定位系统中所有 overlay 挂载

## 前置知识

- [Overlay机制](./Overlay机制.md)
- [LinuxRuntime/Mount机制](../LinuxRuntime/Mount机制.md)
- [VFS虚拟文件系统](./VFS虚拟文件系统.md)

## 后续知识

- [OpenWrt/README](../OpenWrt/README.md)
- [常见问题](./常见问题.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Overlay Filesystem `https://docs.kernel.org/filesystems/overlayfs.html`
- 官方文档：mount(8) `https://man7.org/linux/man-pages/man8/mount.8.html`
- 官方文档：OpenWrt Flash Layout `https://openwrt.org/docs/techref/flash.layout`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux overlayfs 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
