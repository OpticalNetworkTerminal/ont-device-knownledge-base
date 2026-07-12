# EABI

## 简介

本文说明 EABI 的作用，以及它为什么在 ARM 嵌入式 Linux 中极其重要。

## 背景

很多开发者第一次看到 `gnueabi`、`gnueabihf` 只把它当成工具链后缀。实际上，这些后缀在明确告诉你：这个二进制采用什么 ABI 契约。

## 基本概念

EABI 通常指 Embedded ABI。在 ARM Linux 语境里，常见字符串包括：

- `gnueabi`
- `gnueabihf`

它们会反映到：

- 工具链三元组
- libc 目录布局
- 动态链接器命名
- 浮点参数传递方式

## 工作原理

EABI 规定了函数调用、参数传递、目标文件约定等二进制层细节。若程序与 Rootfs 采用不同 ARM EABI 变体，程序即使能被识别为 ARM ELF，也可能无法正常运行。

## 设计目的

EABI 的目标是为嵌入式平台提供更明确、更一致的二进制接口规范。

## 优缺点

优点：

- 使工具链、库、应用的二进制契约更清晰
- 有利于跨组件协作

缺点：

- 变体较多，外行容易只看“都是 ARM”而忽略细节

## 典型应用

- ARMv7 Linux toolchain
- Buildroot / OpenWrt 交叉编译
- 动态链接器命名差异，如 `ld-linux-armhf.so.3`

## 在 Buildroot 中的位置

Buildroot 的工具链配置会直接决定是否生成 `eabi`、`eabihf` 目标。

## 在 OpenWrt 中的位置

OpenWrt 的 target toolchain 同样围绕 ARM EABI 组织，包仓库也必须与目标 ABI 一致。

## 在光猫中的体现

同为 ARM 平台的两个光猫，若一个 Rootfs 基于 `gnueabi`，另一个基于 `gnueabihf`，程序和库通常不能随便互拷。

## 实际案例

你看到某个程序依赖 `/lib/ld-linux-armhf.so.3`，而目标设备只有 `/lib/ld-linux.so.3` 或不同解释器路径，这往往说明并非简单缺文件，而是目标 ABI 不匹配。

## 实践操作

```bash
file busybox
readelf -l busybox
readelf -A busybox 2>/dev/null
strings /lib/libc.so.6 2>/dev/null | head
```

怎么看：

- `readelf -l`：看解释器路径
- `readelf -A`：在 ARM 上观察属性信息
- `file`：辅助看架构和位宽

## 前置知识

- ABI
- ARM架构

## 后续知识

- HardFloat与SoftFloat
- 动态链接器(ld-linux)
- Toolchain

## 知识等级

★★★★★ 必须掌握

对 ARM 光猫、OpenWrt、Buildroot 运行环境判断非常重要。

## 参考资料

- 官方文档：GCC 文档 `https://gcc.gnu.org/onlinedocs/`
- 官方源码：Buildroot `https://gitlab.com/buildroot.org/buildroot`、OpenWrt `https://github.com/openwrt/openwrt`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 ARM GPL 工具链三元组验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：ARM Linux EABI 通用知识

验证环境：工具链命名、ELF 解释器和嵌入式工程实践整理

作者：Codex
