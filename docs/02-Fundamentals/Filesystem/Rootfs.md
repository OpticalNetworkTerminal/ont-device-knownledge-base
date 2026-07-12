# Rootfs

## 简介

本文说明 `Rootfs` 是什么、为什么嵌入式设备的 `Rootfs` 往往是只读的，以及它与内核、分区和升级包之间的关系。

## 背景

很多人把 `Rootfs` 直接等同于“某个分区”。实际上它更准确地表示“系统启动后作为 `/` 挂载的根文件系统视图”，这个视图可以来自镜像、分区、Overlay 组合甚至 initramfs 过渡阶段。

## 基本概念

- `Rootfs`：系统最终以 `/` 呈现给用户态的根文件系统
- 它可以由单一文件系统提供，也可以由只读层 + 可写层叠加得到
- 它既是目录树入口，也是很多升级和恢复逻辑的边界

## 工作原理

Bootloader 拉起内核后，内核需要找到早期根文件系统；最终用户态看到的 `/` 可能经过 initramfs、`pivot_root`、Overlay 等步骤才稳定下来。嵌入式设备里，最终 `Rootfs` 通常强调可验证、可压缩、可恢复。

## 设计目的

- 解释系统从“镜像文件”到“运行时 `/`”的转换
- 解释只读 Rootfs 与配置保留的关系
- 为固件解包、分区分析和升级包判断提供锚点

## 优缺点

优点：

- 能把 Buildroot 输出和运行时目录树对应起来
- 是理解升级、恢复出厂、Overlay 的关键入口

缺点：

- Rootfs 一词既可能指运行时视图，也可能被口语化指代某个镜像文件
- 不同项目对 `rootfs` / `rootfs_data` 的命名不统一

## 典型应用

- Buildroot 输出 `rootfs.squashfs`、`rootfs.ubifs`、`rootfs.ext4`
- OpenWrt 的只读根文件系统与可写 Overlay 组合

## 在 Buildroot 中的位置

Buildroot 在 `target/` 形成目标文件树后，再生成 `rootfs` 镜像；最终板级脚本可能再把该镜像与 kernel、header 一起封装。

## 在 OpenWrt 中的位置

OpenWrt 常把只读系统部分放在 `SquashFS` 中，再把用户修改重定向到 Overlay，因此升级基础系统时能尽量保留配置。

## 在光猫中的体现

光猫和路由器之所以偏爱只读 `Rootfs`，是因为运营商设备更重视可恢复性、批量升级一致性和断电后不损坏系统本体。

## 实际案例

为什么很多设备升级后 `/etc` 某些文件恢复了默认值，而 `/etc/config` 还保留着旧配置？因为前者可能来自只读 `Rootfs`，后者可能已被 Overlay 覆盖。

## 实践操作

```bash
mount | head -n 20
cat /proc/mounts | head -n 20
df -h /
findmnt / 2>/dev/null
```

怎么看：

- `mount` / `/proc/mounts`：确认 `/` 到底挂了什么文件系统
- `df -h /`：看根文件系统的容量感知是否来自只读镜像还是可写层
- `findmnt /`：看 `/` 的底层源和挂载选项

## 前置知识

- [Buildroot/Rootfs生成过程](../Buildroot/Rootfs生成过程.md)
- [LinuxRuntime/Linux启动流程](../LinuxRuntime/Linux启动流程.md)
- [LinuxRuntime/Mount机制](../LinuxRuntime/Mount机制.md)

## 后续知识

- [Overlay机制](./Overlay机制.md)
- [Firmware文件结构](./Firmware文件结构.md)
- [FactoryFirmware](./FactoryFirmware.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Buildroot Manual `https://nightly.buildroot.org/manual.html`
- 官方文档：mount(8) `https://man7.org/linux/man-pages/man8/mount.8.html`
- 官方文档：OpenWrt Flash Layout `https://openwrt.org/docs/techref/flash.layout`

## 最后验证时间

更新时间：2026-07-12

适用版本：嵌入式 Rootfs 通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
