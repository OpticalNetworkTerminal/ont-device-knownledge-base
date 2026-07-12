# Buildroot

## 简介

本目录用于系统整理 Buildroot 的通用知识，目标是让 Linux 嵌入式开发人员能够理解 Buildroot 在光猫、家庭路由器、AP、Mesh、随身 WiFi、IoT 网关、工业网关等设备中的作用，以及它如何从源码生成可交付固件。

## 背景

在运营商设备和消费级嵌入式设备中，厂商通常不需要一套“面向通用桌面”的发行版，而需要一套“可裁剪、可复现、可长期分叉维护”的构建系统。Buildroot 在这一点上非常契合：

- 它直接从源码生成交叉工具链、根文件系统、内核镜像和启动组件。
- 它不强调目标机上的包管理，而强调离线构建、镜像一次成型和系统整体可控。
- 它特别适合 Flash 容量有限、RAM 受限、系统组件固定的设备。

因此，在光猫、路由器、AP、IoT 网关等领域，Buildroot 长期被大量采用，并经常成为厂商 SDK、BSP 或 GPL 代码包的一部分。

## 原理

Buildroot 的核心思路不是“在目标设备上安装软件”，而是“在宿主机构建整个目标系统”。

它通过 Kconfig 风格配置决定：

- 目标 CPU 架构与 ABI
- 工具链类型
- C 库
- 内核与 Bootloader
- BusyBox 和用户态包
- Rootfs 格式
- 镜像后处理方式

最终输出可刷写、可升级、可量产的镜像文件。

## 组成

本目录当前包含以下主题：

- [Buildroot简介.md](./Buildroot简介.md)：Buildroot 的定位、优势、适用边界
- [Buildroot整体架构.md](./Buildroot整体架构.md)：Buildroot 的整体软件与构建架构
- [Buildroot目录结构.md](./Buildroot目录结构.md)：源码树与 `output/` 目录结构
- [Buildroot配置系统.md](./Buildroot配置系统.md)：Kconfig、`defconfig`、板级配置
- [Buildroot构建流程.md](./Buildroot构建流程.md)：从源码到固件的主流程
- [Buildroot工具链.md](./Buildroot工具链.md)：内部工具链、外部工具链、SDK
- [Rootfs生成过程.md](./Rootfs生成过程.md)：目标根文件系统的生成方式
- [Package机制.md](./Package机制.md)：包下载、依赖、编译、安装阶段
- [Overlay机制.md](./Overlay机制.md)：`rootfs overlay` 与 `post-build` 机制
- [Rootfs%20Overlay实践.md](./Rootfs%20Overlay实践.md)：Overlay 的工程化使用建议
- [Filesystem生成.md](./Filesystem生成.md)：镜像格式与文件系统输出
- [Init系统.md](./Init系统.md)：BusyBox init、OpenRC、systemd 的关系
- [设备树(DeviceTree).md](./设备树(DeviceTree).md)：设备树在嵌入式系统中的作用
- [Kernel关系.md](./Kernel关系.md)：Buildroot 与 Linux kernel 的边界
- [BusyBox关系.md](./BusyBox关系.md)：Buildroot 与 BusyBox 的协作关系
- [Buildroot与OpenWrt区别.md](./Buildroot与OpenWrt区别.md)：Buildroot 与 OpenWrt、Yocto、Debian、Ubuntu、Android 的对比
- [Buildroot常见目录说明.md](./Buildroot常见目录说明.md)：常见工程目录解释
- [Buildroot在光猫中的应用.md](./Buildroot在光猫中的应用.md)：面向 ONT 的实际应用分析
- [常见问题.md](./常见问题.md)：Buildroot 常见误解与排错入口
- [术语解释.md](./术语解释.md)：常见术语表

## 工作流程

建议阅读顺序：

1. 先看 [Buildroot简介.md](./Buildroot简介.md) 和 [Buildroot整体架构.md](./Buildroot整体架构.md)
2. 再看 [Buildroot构建流程.md](./Buildroot构建流程.md)、[Buildroot工具链.md](./Buildroot工具链.md)、[Rootfs生成过程.md](./Rootfs生成过程.md)
3. 然后阅读 [Package机制.md](./Package机制.md)、[Overlay机制.md](./Overlay机制.md)、[Init系统.md](./Init系统.md)
4. 最后结合 [Buildroot在光猫中的应用.md](./Buildroot在光猫中的应用.md) 理解 ONT 场景

## 实际应用

本目录重点覆盖以下实际问题：

- 为什么运营商设备大量采用 Buildroot
- 为什么 Buildroot 适合小容量 Flash 和固定功能设备
- 为什么很多厂商会在 Buildroot 基础上做二次开发
- 为什么 Buildroot 常常和 BusyBox、定制内核、定制设备树、私有包体系一起出现
- 为什么它比 Debian / Ubuntu 更适合做固件，而不一定适合做通用发行版

## 光猫中的体现

在 ONT 场景中，Buildroot 常见于：

- 厂商 SDK 的基础构建系统
- `board/` 目录下的板级定制
- 根文件系统 Overlay
- BusyBox 与私有守护进程组合
- 自定义升级镜像、分区布局、只读根文件系统和双镜像升级流程

## 注意事项

- 本目录只讨论 Buildroot 的通用知识，不涉及具体厂商和具体型号。
- 本目录不把社区帖子直接当作最终结论，社区资料只作线索。
- 涉及 ONT 场景时，重点说明“为什么会这样设计”，而不是写成单一设备的逆向笔记。

## 参考资料

- 官方链接：Buildroot Manual `https://buildroot.org/manual.html`
- 官方源码：Buildroot GitLab `https://gitlab.com/buildroot.org/buildroot`
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- GPL源码：后续结合厂商 GPL Release 补充到具体主题文档
- 博客：Bootlin Buildroot 培训材料 `https://bootlin.com/doc/training/buildroot/buildroot-slides.pdf`

## 最后验证时间

更新时间：2026-07-12

适用版本：Buildroot 通用机制，参考 Buildroot 2026.05 手册

验证环境：本地文档整理，结合 Buildroot 官方手册、Kernel 文档、BusyBox 文档、Yocto 文档、Ubuntu Core 官方资料

作者：Codex
