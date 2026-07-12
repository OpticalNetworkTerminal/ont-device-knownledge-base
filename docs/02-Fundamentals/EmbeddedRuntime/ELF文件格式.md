# ELF文件格式

## 简介

本文说明 ELF 文件格式在 Linux 嵌入式运行环境中的角色，以及为什么 `file` 和 `readelf` 能帮你快速判断一个程序能否运行。

## 背景

Linux 下的可执行文件、共享库、目标文件通常都采用 ELF。理解 ELF，不只是会读头部，而是能通过头部反推出架构、位宽、端序、解释器、依赖和装载方式。

## 基本概念

ELF 常见对象类型包括：

- 可执行文件
- 共享库
- 可重定位目标文件

关键结构包括：

- ELF Header
- Program Header
- Section Header
- Dynamic Section

## 工作原理

ELF 头部中的 `e_ident` 会告诉你：

- `EI_CLASS`：32 位还是 64 位
- `EI_DATA`：小端还是大端
- `EI_OSABI`：OS/ABI 标识

Program Header 则告诉内核如何映射段、是否存在解释器、是否需要动态链接。

## 设计目的

ELF 的目标是为 Unix / Linux 系统提供统一对象文件格式，让编译器、链接器、内核装载器和动态链接器之间有共同语言。

## 优缺点

优点：

- 结构清晰
- 可表达静态和动态链接信息
- 支持多架构

缺点：

- 字段较多，初学者容易只看表面字符串
- 仅看文件名完全无法判断真实兼容性

## 典型应用

- `busybox`
- `dropbear`
- `libc.so`
- 内核模块以外的大多数用户态二进制

## 在 Buildroot 中的位置

Buildroot 产出的可执行文件和共享库本质上都是 ELF，它还会把动态链接器与目标库一并装入 Rootfs。

## 在 OpenWrt 中的位置

OpenWrt 产出的用户态包也是 ELF，并通过包元数据与 Rootfs 组织运行时依赖。

## 在光猫中的体现

分析光猫 Rootfs 时，只要先看几个核心 ELF，例如 `busybox`、Web 服务、TR-069 客户端，就能大致判断：

- 架构
- 位宽
- libc 体系
- 动态链接器路径

## 实际案例

`file` 显示 `ELF 64-bit LSB shared object` 并不表示“这是库，不能执行”。很多 PIE 可执行文件也会显示成 shared object 风格，因为它们是位置无关可执行文件。

## 实践操作

```bash
file busybox
readelf -h busybox
readelf -l busybox
readelf -d busybox
objdump -x busybox | head -n 80
```

怎么看：

- `readelf -h`：先看 `Class`、`Data`、`Machine`
- `readelf -l`：看 `INTERP`
- `readelf -d`：看 `NEEDED`
- `objdump -x`：综合看头部和动态段

## 前置知识

- CPU架构
- ABI
- 大小端(LittleEndian_BigEndian)

## 后续知识

- 动态链接
- 静态链接
- 动态链接器(ld-linux)

## 知识等级

★★★★★ 必须掌握

对光猫逆向、OpenWrt、Linux 开发都极其重要。

## 参考资料

- 官方文档：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- 官方源码：Binutils `https://sourceware.org/binutils/docs/`
- 标准：ELF Header `https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.eheader.html`
- GPL源码：后续结合 GPL Rootfs 中 ELF 实例验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux ELF 通用知识

验证环境：ELF gABI 与 binutils 工具实践整理

作者：Codex
