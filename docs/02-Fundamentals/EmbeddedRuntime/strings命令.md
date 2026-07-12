# strings命令

## 简介

本文说明 `strings` 的作用，以及它为什么常被用来快速识别 libc、路径、版本和错误信息。

## 背景

当你暂时不想做完整反汇编时，`strings` 往往能快速告诉你：

- 程序里出现了哪些路径
- 依赖了什么库名
- 是否包含版本字符串
- 是否能看出动态链接器或错误提示

## 基本概念

`strings` 会提取二进制中可见的可打印字符串片段。

## 工作原理

它不会理解程序逻辑，只是扫描字节流并输出连续可打印字符，因此适合快速摸底，不适合做精确结构分析。

## 设计目的

- 快速观察二进制中的文本痕迹
- 辅助识别版本、路径、特征字符串

## 优缺点

优点：

- 快
- 在已 strip 程序上仍常有价值

缺点：

- 噪音多
- 不能替代 `readelf` 或反汇编

## 典型应用

- 看 `libc` 版本痕迹
- 看程序路径与日志关键字
- 看 Web 资源、命令帮助、配置键名

## 在 Buildroot 中的位置

分析 Buildroot 产物时，它常用于快速看包特征、程序版本、路径布局。

## 在 OpenWrt 中的位置

分析 OpenWrt 二进制和共享库时同样很常见。

## 在光猫中的体现

对光猫固件中已 strip 的守护进程执行 `strings`，常能直接看到：

- `/etc` 路径
- 数据库键名
- CLI 命令
- Web 接口字符串

## 实际案例

`strings libc.so.6 | head` 往往就能帮助识别是不是 glibc；对 musl/uClibc 也常能看出风格差异。

## 实践操作

```bash
strings busybox | head -n 50
strings libc.so.6 2>/dev/null | head -n 50
```

怎么看：

- 看路径、版本串、帮助信息
- 对库文件时，重点看 libc 身份和版本痕迹

## 前置知识

- ELF文件格式
- strip

## 后续知识

- 常见问题
- glibc
- musl

## 知识等级

★★★★ 建议掌握

对快速摸底和逆向前期筛查很有用。

## 参考资料

- 官方文档：Binutils Docs `https://sourceware.org/binutils/docs/`
- 官方源码：Binutils `https://sourceware.org/git/?p=binutils-gdb.git`
- 标准：ELF gABI `https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html`
- GPL源码：后续结合目标程序与共享库验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：strings 命令通用使用知识

验证环境：Binutils / 固件分析实践整理

作者：Codex
