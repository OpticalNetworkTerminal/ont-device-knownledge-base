# GCC

## 简介

本文说明 GCC 在嵌入式 Linux 运行环境中的位置，以及它和 ABI、sysroot、libc、binutils 的关系。

## 背景

很多人把 GCC 当成“编译器程序”，但在嵌入式开发中，它更像是整个 toolchain 的入口。你看到的 `gcc` 实际会联动预处理、编译、汇编、链接等多个阶段。

## 基本概念

GCC 在这里主要指 GNU Compiler Collection 提供的编译驱动与相关前端。

## 工作原理

`gcc` 会根据参数调用不同阶段工具：

- 预处理
- 编译为汇编
- 汇编为目标文件
- 调用链接器生成 ELF

它还会根据目标三元组和 sysroot 选择头文件、启动文件、库与链接器选项。

## 设计目的

- 统一多阶段编译流程
- 支持多架构、多 ABI
- 作为交叉工具链前端

## 优缺点

优点：

- 多架构支持成熟
- 与 binutils、libc、Buildroot/OpenWrt 生态结合紧密

缺点：

- 参数与行为较多
- 初学者容易只会“能编过去”，不会检查目标属性

## 典型应用

- Buildroot 内部工具链
- OpenWrt 工具链
- 厂商 SDK

## 在 Buildroot 中的位置

Buildroot 会生成或调用 GCC 工具链来构建整套系统。

## 在 OpenWrt 中的位置

OpenWrt 构建系统同样围绕交叉 GCC 组织软件包和镜像构建。

## 在光猫中的体现

GPL 代码包里的 `arm-linux-...-gcc`、`mipsel-openwrt-linux-gcc` 一类命令，就是光猫 / 路由器工具链的典型入口。

## 实际案例

两个 GCC 名字都带 ARM，不代表产物兼容。必须继续确认：

- 目标三元组
- EABI / hard-float
- libc
- sysroot

## 实践操作

```bash
gcc -v
gcc -print-sysroot
gcc -print-search-dirs
```

怎么看：

- `gcc -v`：看 target 和配置
- `-print-sysroot`：看绑定的目标开发根
- `-print-search-dirs`：看搜索路径

## 前置知识

- Toolchain
- Sysroot

## 后续知识

- Binutils
- readelf
- objdump

## 知识等级

★★★★★ 必须掌握

对 Linux 嵌入式开发和运行环境分析都很重要。

## 参考资料

- 官方文档：GCC Online Docs `https://gcc.gnu.org/onlinedocs/`
- 官方源码：GCC `https://gcc.gnu.org/git.html`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合交叉 GCC 实例验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：GCC 通用嵌入式知识

验证环境：GCC 官方文档整理

作者：Codex
