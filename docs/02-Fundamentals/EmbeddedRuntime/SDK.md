# SDK

## 简介

本文说明 SDK 在嵌入式 Linux 中的含义，以及它与 toolchain、sysroot、Rootfs 的关系。

## 背景

在嵌入式项目里，“SDK”这个词经常被滥用。有时它指芯片厂商整套开发包，有时指可分发的交叉工具链，有时又包含 Buildroot / OpenWrt 工程。必须把层次拆开。

## 基本概念

最狭义的 SDK 往往包含：

- toolchain
- sysroot
- 头文件与库
- 构建辅助脚本

更广义的 SDK 还可能包含：

- BSP
- 内核源码
- 示例程序
- 构建系统

## 工作原理

SDK 的核心价值是把“对某一目标平台可用的开发环境”打包分发给应用开发者，而不要求每个人都从头搭工具链。

## 设计目的

- 降低应用开发和集成门槛
- 固定目标 ABI 与 libc
- 保证不同开发者产物可与同一 Rootfs 协作

## 优缺点

优点：

- 上手快
- 易分发
- 保持团队环境一致

缺点：

- 若 SDK 版本陈旧，容易造成历史包袱
- 若 SDK 与实际固件脱节，会产生隐藏兼容性问题

## 典型应用

- Buildroot `make sdk` 导出工具链包
- OpenWrt SDK
- 芯片厂商发行的 Linux SDK

## 在 Buildroot 中的位置

Buildroot 官方支持 `make sdk` 导出包含 toolchain 与开发文件的 SDK 压缩包。

## 在 OpenWrt 中的位置

OpenWrt 也常提供 SDK 以便独立构建软件包，而不必完整重建整套系统。

## 在光猫中的体现

光猫相关 GPL 代码包经常附带 SDK。理解它之后，你就会知道：

- 它不等于目标 Rootfs
- 它也不一定等于完整产品源码
- 它主要服务于“为目标系统编译东西”

## 实际案例

有人从 SDK 里拷出 `libc.so` 到另一台设备，以为这样就能运行程序。实际上，SDK 中的开发文件、sysroot 布局和目标机真实 Rootfs 未必能直接一一对应。

## 实践操作

```bash
gcc -v
gcc -print-sysroot
find . -maxdepth 2 -type d | head
```

怎么看：

- `gcc -v`：确认 SDK 提供的是哪套目标工具链
- `gcc -print-sysroot`：确认它绑定的目标开发根
- `find`：观察 SDK 是否同时包含内核、BSP、示例代码等

## 前置知识

- Toolchain
- Sysroot

## 后续知识

- 交叉编译
- Buildroot Rootfs
- OpenWrt Rootfs

## 知识等级

★★★★★ 必须掌握

对理解 GPL 代码包、厂商开发包和应用移植都非常重要。

## 参考资料

- 官方文档：Buildroot Manual `https://buildroot.org/manual.html`
- 官方源码：Buildroot `https://gitlab.com/buildroot.org/buildroot`、OpenWrt `https://github.com/openwrt/openwrt`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合厂商 SDK 与 GPL 发布包结构验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux Embedded SDK 通用知识

验证环境：Buildroot / OpenWrt / GPL SDK 常见结构整理

作者：Codex
