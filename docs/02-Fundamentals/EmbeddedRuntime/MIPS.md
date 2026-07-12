# MIPS

## 简介

本文说明 MIPS 架构在嵌入式 Linux 中的历史地位，以及它在二进制兼容性分析中的常见特征。

## 背景

很多历史路由器、光猫和网络设备都大量采用 MIPS SoC。即使今天新平台里 ARM 更常见，MIPS 仍然是分析旧设备和 GPL 代码时必须认识的架构。

## 基本概念

MIPS 常见差异包括：

- 32 位 / 64 位
- 大端 / 小端
- 不同 ABI 变体
- 厂商 SoC 平台差异

## 工作原理

MIPS 程序能否运行，取决于：

- 指令集兼容性
- 端序是否匹配
- libc 和 ABI 是否匹配
- 动态链接器路径是否正确

## 设计目的

MIPS 长期在嵌入式系统流行，主要因为：

- 架构成熟
- 成本可控
- 在网络设备 SoC 生态中历史包袱深

## 优缺点

优点：

- 在旧网络设备领域生态广
- 很多经典嵌入式平台长期基于 MIPS

缺点：

- 端序、ABI、历史平台差异较多
- 新平台生态活跃度不如 ARM

## 典型应用

- 历史无线路由器
- 老一代光猫与家庭网关
- 各类早期嵌入式网络设备

## 在 Buildroot 中的位置

Buildroot 支持 MIPS 与其多个变体，工具链和 Rootfs 都需按目标 MIPS 配置生成。

## 在 OpenWrt 中的位置

OpenWrt 历史上对 MIPS 支持非常广泛，很多经典 target 都来自 MIPS 平台。

## 在光猫中的体现

历史设备中经常能看到：

- `ELF 32-bit MSB/LSB`
- `MIPS` 机器类型
- 与端序紧密绑定的 Rootfs 和共享库

## 实际案例

把 MIPS 小端程序复制到 MIPS 大端环境，哪怕 CPU 家族名字一样，仍然可能完全不能运行。原因是 ELF 数据编码和运行环境不一致。

## 实践操作

```bash
file busybox
readelf -h busybox
readelf -A busybox 2>/dev/null
```

怎么看：

- `file` 看 `MIPS`、`LSB`、`MSB`
- `readelf -h` 看 `Machine` 和 `Data`

## 前置知识

- CPU架构
- 大小端(LittleEndian_BigEndian)

## 后续知识

- ABI
- ELF文件格式
- 动态链接

## 知识等级

★★★★ 建议掌握

对历史光猫、历史 OpenWrt / Linux 嵌入式设备分析非常重要。

## 参考资料

- 官方文档：Linux Kernel MIPS 文档 `https://docs.kernel.org/`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合历史设备 GPL 发布包验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：MIPS 嵌入式 Linux 通用知识

验证环境：ELF 标准与嵌入式设备实践整理

作者：Codex
