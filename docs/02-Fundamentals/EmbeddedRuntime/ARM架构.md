# ARM架构

## 简介

本文说明 ARM 架构在嵌入式 Linux 中的地位，以及它为什么长期是光猫、路由器、AP 和 IoT 设备的主力平台之一。

## 背景

ARM 在嵌入式领域广泛使用，原因通常不是“它最强”，而是它在功耗、成本、生态、SoC 集成度之间长期保持了很好的平衡。

## 基本概念

在嵌入式语境中，“ARM”常同时指：

- ARM 指令集家族
- 32 位 ARM（常称 ARMv7 / AArch32 等）
- 64 位 ARM（AArch64）
- 大量基于 ARM 的 SoC 平台

## 工作原理

ARM Linux 程序需要：

- 匹配 ARM 指令集
- 匹配正确 ABI
- 匹配正确 libc
- 若为动态链接，还要匹配动态链接器路径

任何一层不匹配，都可能导致程序无法运行。

## 设计目的

ARM 架构的目标长期围绕：

- 低功耗
- 高集成度
- 可扩展 SoC 生态
- 覆盖从微控制器到应用处理器的广泛范围

## 优缺点

优点：

- 嵌入式生态成熟
- SoC 厂商支持广
- 工具链与 Linux 支持成熟

缺点：

- 历史包袱较多，32 位 / 64 位、软浮点 / 硬浮点差异明显
- 同为 ARM 也可能存在 ABI 不兼容问题

## 典型应用

- 路由器
- 光猫
- AP
- Mesh 节点
- 随身 WiFi
- IoT 网关

## 在 Buildroot 中的位置

Buildroot 明确支持 ARM、AArch64 等处理器家族，并可为其生成交叉工具链、Rootfs、Kernel 和 Bootloader。

## 在 OpenWrt 中的位置

OpenWrt 的很多主流 target 都基于 ARM 或 ARM64，并围绕对应 target 生成工具链和包。

## 在光猫中的体现

很多现代光猫平台采用 ARM SoC。实际运行时体现为：

- ELF 头中的 `Machine` 为 ARM 或 AArch64
- 动态链接器路径为 ARM 对应版本
- Rootfs 中的 libc 与共享库均针对 ARM 构建

## 实际案例

同样叫“ARM 程序”，也可能因为以下差异不能运行：

- ARMv7 程序不能在纯 AArch64-only 用户态下直接运行
- hard-float 程序不能在 soft-float 用户态中工作
- glibc 程序不能直接丢到 musl Rootfs 中运行

## 实践操作

```bash
uname -m
cat /proc/cpuinfo
file /bin/busybox
readelf -h /bin/busybox
readelf -A /bin/busybox 2>/dev/null
```

怎么看：

- `uname -m`：识别当前是 `armv7l`、`aarch64` 等
- `readelf -h`：看 `Machine`
- `readelf -A`：某些 ARM 平台可看到额外 ABI/浮点属性

## 前置知识

- CPU架构

## 后续知识

- AArch32与AArch64
- EABI
- HardFloat与SoftFloat

## 知识等级

★★★★★ 必须掌握

对光猫分析和 Linux 嵌入式开发尤其重要，对 OpenWrt 也很重要。

## 参考资料

- 官方文档：Linux Kernel ARM/ARM64 文档 `https://docs.kernel.org/arch/arm64/index.html`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合设备 GPL 中 ARM 平台 Rootfs 与工具链验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：ARM Linux Embedded 通用知识

验证环境：Kernel 文档与嵌入式 Linux 工程经验整理

作者：Codex
