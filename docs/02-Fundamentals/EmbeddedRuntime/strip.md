# strip

## 简介

本文说明 `strip` 的作用，以及它为什么在嵌入式系统里很常见。

## 背景

嵌入式设备的 Flash 很宝贵。为了节省空间，发布固件时常常会把调试符号和不必要元数据去掉，这就是 `strip` 的常见用途。

## 基本概念

`strip` 是 binutils 工具，用于移除符号、调试信息或其他非运行必需内容。

## 工作原理

它通过修改 ELF 内容，删除某些节区和符号信息，从而减小文件体积。

## 设计目的

- 缩小二进制体积
- 减少发布产物中的调试信息

## 优缺点

优点：

- 节省空间
- 发布固件更轻

缺点：

- 调试难度提高
- 逆向和故障分析信息减少

## 典型应用

- 发布版程序
- BusyBox
- 共享库

## 在 Buildroot 中的位置

Buildroot 会在目标优化和镜像生成过程中利用裁剪策略减少体积。

## 在 OpenWrt 中的位置

OpenWrt 的发布包同样重视体积控制，strip 是常见步骤之一。

## 在光猫中的体现

光猫 Rootfs 中很多程序和库都经过 strip，因此函数名、调试信息往往不可见。

## 实际案例

两个程序逻辑相同，未 strip 的版本更容易分析；而固件里看到的往往是已 strip 版本，导致 `strings`、`objdump` 可见信息显著减少。

## 实践操作

```bash
strip --version
file busybox
readelf -S busybox | head -n 40
```

怎么看：

- `readelf -S`：看节区是否保留调试信息
- `file`：辅助确认文件仍是有效 ELF

## 前置知识

- ELF文件格式
- Binutils

## 后续知识

- strings命令
- 常见问题

## 知识等级

★★★ 了解即可

对空间优化和逆向分析有帮助。

## 参考资料

- 官方文档：Binutils Docs `https://sourceware.org/binutils/docs/`
- 官方源码：Binutils `https://sourceware.org/git/?p=binutils-gdb.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合已 strip 程序与未 strip 程序对比验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：strip 通用使用知识

验证环境：Binutils 实践整理

作者：Codex
