# CPU架构

## 简介

本文说明 CPU 架构在嵌入式 Linux 运行环境中的作用，以及为什么“同样是 Linux 程序”并不意味着可以跨设备直接运行。

## 背景

高级语言开发者常把程序理解为“编译后就能运行”。但在嵌入式 Linux 中，程序首先是某种 CPU 指令的集合。CPU 不理解别的架构指令，程序自然无法执行。

## 基本概念

CPU 架构通常至少包含：

- 指令集架构（ISA）
- 寄存器模型
- 调用约定所依赖的硬件基础
- 大小端模式
- 位宽与寻址能力

## 工作原理

程序编译后会变成目标 CPU 能解码的机器指令。若目标设备 CPU 不支持这些指令，内核在 `execve()` 阶段就无法正常装载，常见表现是 `Exec format error`。

## 设计目的

CPU 架构定义了软件与硬件之间最底层的可执行契约。ABI、ELF、libc、动态链接器都建立在该契约之上。

## 优缺点

优点：

- 体系结构明确，便于平台优化
- 可以围绕功耗、性能、面积做不同取舍

缺点：

- 跨架构二进制不可直接复用
- 工具链、libc、Rootfs 都要针对架构分别构建

## 典型应用

- ARM / AArch64：家用路由器、光猫、IoT 网关
- MIPS：大量历史网络设备
- RISC-V：新兴嵌入式平台
- x86_64：开发机、软路由、工控

## 在 Buildroot 中的位置

Buildroot 的第一层配置之一就是目标架构。它决定工具链前缀、libc 构建方式、可用包和镜像格式。

## 在 OpenWrt 中的位置

OpenWrt 通过 target/subtarget 选择架构与平台，并据此生成交叉工具链与目标包。

## 在光猫中的体现

光猫软件几乎总是和 SoC 架构绑定。即使两个设备都运行 Linux，只要一个是 MIPS、一个是 ARM，二进制就不能互用。

## 实际案例

将 AArch64 程序复制到 ARMv7 设备，常见结果是：

- `Exec format error`
- 或内核无法识别目标机器码

根因不是 Linux 版本，而是 CPU 架构和 ABI 根本不匹配。

## 实践操作

```bash
uname -m
cat /proc/cpuinfo
file /bin/busybox
readelf -h /bin/busybox
```

怎么看：

- `uname -m`：看当前内核报告的机器架构
- `/proc/cpuinfo`：看 CPU 家族、型号、特性
- `file`：看二进制是给哪种架构编译的
- `readelf -h`：看 `Machine` 字段

## 前置知识

- Linux 进程基础

## 后续知识

- ARM架构
- ABI
- ELF文件格式
- 交叉编译

## 知识等级

★★★★★ 必须掌握

对光猫分析、OpenWrt 和 Linux 嵌入式开发都是基础中的基础。

## 参考资料

- 官方文档：Linux Kernel 文档 `https://docs.kernel.org/`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合 GPL 发布包中的可执行文件头验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux Embedded 通用 CPU 架构知识

验证环境：内核文档与 ELF 标准整理

作者：Codex
