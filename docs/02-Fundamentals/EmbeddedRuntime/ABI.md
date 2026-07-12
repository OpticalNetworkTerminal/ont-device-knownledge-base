# ABI

## 简介

本文说明 ABI 的含义，以及为什么它比“是不是同一门语言编译的”更决定程序能否在另一台设备上运行。

## 背景

应用开发者更熟悉 API。API 关注源码接口，ABI 关注二进制接口。嵌入式 Linux 里程序能否运行、库能否加载、函数能否调用，最终都要落到 ABI。

## 基本概念

ABI（Application Binary Interface）通常包含：

- 调用约定
- 参数与返回值如何放寄存器或栈
- 数据类型大小和对齐
- 系统调用接口
- ELF 约定
- 动态链接约定

## 工作原理

即使源码完全一样，只要两边 ABI 不同，最终二进制就可能不兼容。例如：

- 浮点参数传递方式不同
- 结构体布局不同
- 动态链接器路径不同
- libc 的符号与版本约定不同

## 设计目的

ABI 的存在，是为了让分别编译的二进制对象可以组合成可运行程序，而不需要彼此知道源码细节。

## 优缺点

优点：

- 让对象文件、共享库、可执行文件能够协同工作
- 让工具链、libc、内核接口形成稳定契约

缺点：

- ABI 一旦变化，兼容成本极高
- 同一架构内也可能存在多个 ABI 变体

## 典型应用

- ARM EABI
- hard-float 与 soft-float ABI
- glibc / musl / uClibc 运行时差异

## 在 Buildroot 中的位置

Buildroot 的架构、浮点、libc、工具链选项本质上都在决定目标 ABI。

## 在 OpenWrt 中的位置

OpenWrt 的 target / toolchain / staging_dir 同样围绕目标 ABI 组织。包只要 ABI 不匹配，就不能进入同一运行环境。

## 在光猫中的体现

实际设备中常见的“不兼容”很多都不是源码层面问题，而是 ABI 不同：

- 同为 ARM，但浮点 ABI 不同
- 同为 Linux，但 libc 运行时契约不同
- 同为 MIPS，但端序和 ABI 不同

## 实际案例

把一个 hard-float ARM 程序放到 soft-float Rootfs，可能文件存在、权限正确、动态链接器也存在，但运行仍然失败。根因是 ABI 契约不一致。

## 实践操作

```bash
file busybox
readelf -h busybox
readelf -A busybox 2>/dev/null
objdump -x busybox | head -n 40
```

怎么看：

- `file`：先看基础架构和位宽
- `readelf -h`：看 ELF 类、机器类型
- `readelf -A`：某些平台可看 ABI 属性
- `objdump -x`：辅助查看头信息和依赖

## 前置知识

- CPU架构
- ARM架构

## 后续知识

- EABI
- HardFloat与SoftFloat
- 动态链接

## 知识等级

★★★★★ 必须掌握

对光猫分析、OpenWrt 和 Linux 嵌入式开发都极其关键。

## 参考资料

- 官方文档：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：ELF Header `https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.eheader.html`
- GPL源码：后续结合 GPL 可执行文件和共享库验证 ABI 差异
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux Embedded 通用 ABI 知识

验证环境：ELF / 工具链通用模型整理

作者：Codex
