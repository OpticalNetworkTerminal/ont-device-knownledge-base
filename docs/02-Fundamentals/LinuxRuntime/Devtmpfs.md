# Devtmpfs

## 简介

本文说明 `/dev` 中很多设备节点为什么会自动出现，以及 devtmpfs 在其中扮演的角色。

## 背景

现代 Linux 中，`/dev` 常建立在 devtmpfs 之上，并与内核设备发现过程联动，而不是靠人工长期维护一堆静态节点。

## 基本概念

devtmpfs 是内核维护的设备文件系统，用于为设备节点提供一个动态、可挂载的 `/dev` 视图。

## 工作原理

当内核识别设备并注册设备号后，devtmpfs 可以为其提供对应节点；用户态 `mdev`、`udev` 再补充权限、命名和符号链接策略。

## 设计目的

- 让系统早期就拥有可用设备节点
- 避免完全依赖用户态创建设备文件

## 优缺点

优点：

- 启动早期即可用
- 与设备发现联动

缺点：

- 复杂命名仍需用户态辅助

## 典型应用

- `/dev/console`
- `/dev/null`
- `/dev/ttyS*`
- `/dev/pts`

## 在 Buildroot 中的位置

Buildroot 提供多种设备管理方案，包括仅用 devtmpfs、devtmpfs + `mdev` 等。

## 在 OpenWrt 中的位置

OpenWrt 同样依赖现代设备节点管理，但保持较轻的用户态策略。

## 在光猫中的体现

光猫启动早期能否正确输出 console、访问串口、打开块设备，往往与 `/dev` 是否正确建立直接相关。

## 实际案例

为什么系统一挂载 `/dev` 就能看到一批节点？因为那不是普通目录被拷贝了文件，而是 devtmpfs 提供了设备视图。

## 实践操作

```bash
mount | grep ' /dev '
ls -l /dev | head -n 30
ls -l /dev/pts 2>/dev/null | head
```

怎么看：

- `mount`：看 `/dev` 挂载类型
- `ls -l /dev`：看字符设备、块设备和符号链接

## 前置知识

- Sysfs
- Mount机制

## 后续知识

- Session与TTY
- Tmpfs

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：Kernel filesystems docs `https://docs.kernel.org/filesystems/index.html`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：Linux man-pages `https://man7.org/linux/man-pages/`
- GPL源码：后续结合 `/dev` 挂载与设备节点验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux devtmpfs 通用知识

验证环境：运行时挂载与设备节点实践整理

作者：Codex
