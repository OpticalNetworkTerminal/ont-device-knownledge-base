# proc

## 简介

本文从文件系统章节视角说明 `procfs` 的定位，以及为什么很多文件系统分析命令都先看 `/proc`。

## 背景

`procfs` 在 `LinuxRuntime` 里已经解释过“为什么它不是磁盘文件系统”。在 Filesystem 章节里，更关注它如何帮助你看挂载、文件系统类型、MTD 分区和进程视图。

## 基本概念

- `procfs`：内核实时导出的伪文件系统
- 它不是持久化文件系统，但经常承载挂载表和文件系统状态入口
- 很多存储排错命令本质都在读 `/proc`

## 工作原理

`/proc/mounts`、`/proc/filesystems`、`/proc/mtd` 等接口把文件系统、挂载和 Flash 状态以文本接口暴露给用户态。

## 设计目的

- 提供统一且轻量的观察入口
- 帮助把“运行时文件系统状态”从磁盘内容中分离出来

## 优缺点

优点：

- 脚本友好
- 是排查挂载、支持类型和 MTD 分区的第一入口

缺点：

- 不是持久化数据
- 不同内核裁剪下可见接口可能不同

## 典型应用

- 查看内核支持的文件系统类型
- 查看挂载表
- 查看 MTD 分区信息

## 在 Buildroot 中的位置

Buildroot 生成的系统最终怎样挂、支持哪些文件系统，很多时候最方便的实时答案就在 `/proc`。

## 在 OpenWrt 中的位置

OpenWrt 的挂载关系、Overlay 状态、MTD 分区布局也常通过 `/proc` 暴露。

## 在光猫中的体现

光猫现场拿到 shell 后，先看 `/proc/mounts` 和 `/proc/mtd` 往往就能大致判断系统存储架构。

## 实际案例

为什么 `mount` 命令和 `cat /proc/mounts` 结果高度相关？因为大量用户态工具最终都依赖内核导出的挂载表。

## 实践操作

```bash
cat /proc/filesystems
cat /proc/mounts | head -n 30
cat /proc/mtd 2>/dev/null
```

怎么看：

- `/proc/filesystems`：看内核支持类型
- `/proc/mounts`：看运行时挂载
- `/proc/mtd`：看 raw flash 分区名称和大小

## 前置知识

- [LinuxRuntime/Proc文件系统](../LinuxRuntime/Proc文件系统.md)
- [Mount机制](./Mount机制.md)

## 后续知识

- [MTD](./MTD.md)
- [Firmware文件结构](./Firmware文件结构.md)

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：proc(5) `https://man7.org/linux/man-pages/man5/proc.5.html`
- 官方文档：Kernel procfs docs `https://docs.kernel.org/filesystems/proc.html`

## 最后验证时间

更新时间：2026-07-12

适用版本：procfs 的文件系统分析视角

验证环境：Kernel / Buildroot / OpenWrt / MTD 文档整理

作者：Codex
