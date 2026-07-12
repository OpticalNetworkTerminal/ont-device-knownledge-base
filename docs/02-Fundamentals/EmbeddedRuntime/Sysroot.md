# Sysroot

## 简介

本文说明 sysroot 的作用，以及为什么它是理解 SDK、Toolchain、Buildroot 和 OpenWrt Rootfs 的关键。

## 背景

很多开发者第一次见到 sysroot，会把它误认为“目标根文件系统”。实际上，sysroot 更准确地说是“供交叉编译器查找目标头文件与目标库的开发根”。

## 基本概念

sysroot 通常包含：

- 目标头文件
- 目标共享库和静态库
- 链接所需启动文件
- pkg-config 元数据等开发支持文件

它服务于编译与链接，不等于运行时 Rootfs。

## 工作原理

交叉编译器在处理 `#include`、库搜索和链接时，会把 sysroot 视为目标系统的参考根目录。这样编译器虽然运行在宿主机上，却能使用“目标机版本”的头文件和库。

## 设计目的

- 让交叉编译脱离宿主机本地库
- 保证编译时看到的接口与目标运行环境一致
- 支持可复现的嵌入式构建

## 优缺点

优点：

- 明确区分宿主机环境与目标机环境
- 便于构建 SDK

缺点：

- 初学者容易把它和 Rootfs 混淆
- sysroot 与实际部署 Rootfs 若不一致，会导致运行时问题

## 典型应用

- Buildroot `output/host/` 中的目标 sysroot
- OpenWrt `staging_dir` 中的目标开发环境
- 芯片厂商 SDK

## 在 Buildroot 中的位置

Buildroot 官方手册说明，`output/host/` 中既包含 host 工具，也包含目标工具链 sysroot；`make sdk` 也会从这里导出 SDK。

## 在 OpenWrt 中的位置

OpenWrt 的 `staging_dir` 长期扮演类似角色，供交叉编译和包构建使用。

## 在光猫中的体现

光猫 GPL 代码包里常常会附带交叉工具链和一套开发用目录，它们里面的头文件和库就是理解 sysroot 的最好实例。

## 实际案例

程序在你的开发机上能编译过，不代表能在目标光猫上运行。若编译时误用了宿主机头文件或库，而不是目标 sysroot，对应二进制很可能在目标机崩溃或无法加载。

## 实践操作

```bash
gcc -print-sysroot
pkg-config --variable pc_path pkg-config 2>/dev/null
find output/host -maxdepth 3 -type d 2>/dev/null | head
```

怎么看：

- `gcc -print-sysroot`：看当前编译器默认 sysroot
- `pkg-config`：辅助理解依赖解析路径
- `find output/host`：在 Buildroot 工程中观察 sysroot 相关布局

## 前置知识

- glibc
- musl
- ABI

## 后续知识

- Toolchain
- SDK
- 交叉编译

## 知识等级

★★★★★ 必须掌握

对 Buildroot、OpenWrt、交叉编译和 Rootfs 分析都非常关键。

## 参考资料

- 官方文档：Buildroot Manual `https://buildroot.org/manual.html`
- 官方源码：Buildroot `https://gitlab.com/buildroot.org/buildroot`、OpenWrt `https://github.com/openwrt/openwrt`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 SDK 中 sysroot 布局验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux Embedded sysroot 通用知识

验证环境：Buildroot / OpenWrt 工具链模型整理

作者：Codex
