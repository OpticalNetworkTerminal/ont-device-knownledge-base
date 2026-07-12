# Overlay机制

## 简介

本文说明“只读层 + 可写层”的 Overlay 设计为什么在嵌入式设备里极其常见，以及它与 Linux `overlayfs` 实现的关系和边界。

## 背景

很多设备并不是把系统本体做成可写，而是把基础系统保持只读，再用独立可写层承载配置和状态。理解这种设计，才能解释为什么恢复出厂往往只需删除 Overlay。

## 基本概念

- Overlay 是一种系统组织策略，不等同于某个单一文件系统实现
- 只读 lower 层承载稳定系统本体
- 可写 upper 层承载配置、日志、状态或替换文件
- 最终用户看到的是合并后的统一视图

## 工作原理

Overlay 的核心思想是把“系统基线”和“现场变化”分离。这样升级时可以替换基线镜像，恢复出厂时可以清空变化层，而不必直接改写整块只读系统镜像。

## 设计目的

- 提升系统稳定性和恢复能力
- 降低对只读镜像的写入需求
- 让升级与保留配置可以同时成立

## 优缺点

优点：

- 升级和恢复逻辑清晰
- 适合 Flash 介质和批量部署设备

缺点：

- 现场排错时容易误判真实文件来源
- 文件删除、whiteout、空间不足等行为更复杂

## 典型应用

- OpenWrt 的 `SquashFS` + `rootfs_data`
- 只读系统镜像 + 可写配置分区
- 容器镜像的分层思路

## 在 Buildroot 中的位置

Buildroot 本身负责输出基础 Rootfs；是否再叠加 Overlay，通常由产品的启动脚本、分区布局和发行方式决定。

## 在 OpenWrt 中的位置

OpenWrt 文档明确把 `SquashFS` 与可写 Overlay 结合作为默认思路之一；首次启动会准备可写层，恢复出厂则清理该层。

## 在光猫中的体现

运营商光猫、Mesh 与大量 IoT 设备都依赖类似策略：系统本体尽量保持只读，配置与状态分离，便于 OTA 升级和快速恢复。

## 实际案例

为什么修改 `/etc/config` 不会真的改写 `SquashFS`？因为实际写入落在 upper 层，运行时视图再把 upper 优先展示出来。

## 实践操作

```bash
mount
cat /proc/mounts
df -h
findmnt 2>/dev/null | grep -i overlay
```

怎么看：

- `mount` / `findmnt`：找 lower、upper、workdir 等线索
- `df -h`：看可写层容量常常远小于只读系统体积
- `/proc/mounts`：看合并后 `/` 是否来自 overlay 或发行版自定义叠层方案

## 前置知识

- [Rootfs](./Rootfs.md)
- [OverlayFS](./OverlayFS.md)
- [LinuxRuntime/Mount机制](../LinuxRuntime/Mount机制.md)

## 后续知识

- [FactoryFirmware](./FactoryFirmware.md)
- [UpgradeFirmware](./UpgradeFirmware.md)
- [常见问题](./常见问题.md)

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Overlay Filesystem `https://docs.kernel.org/filesystems/overlayfs.html`
- 官方文档：OpenWrt Flash Layout `https://openwrt.org/docs/techref/flash.layout`
- 官方文档：OpenWrt Failsafe / Factory Reset `https://openwrt.org/docs/guide-user/troubleshooting/failsafe_and_factory_reset`

## 最后验证时间

更新时间：2026-07-12

适用版本：嵌入式 Overlay 设计通用知识

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
