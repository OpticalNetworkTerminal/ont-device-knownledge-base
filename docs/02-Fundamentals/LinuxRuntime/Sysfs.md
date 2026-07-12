# Sysfs

## 简介

本文说明 `/sys` 的作用，以及为什么往 `/sys` 写入内容可能改变驱动和设备行为。

## 背景

`/sys` 经常被误认为另一个配置目录。其实它是内核对象模型向用户态暴露的接口，和普通磁盘文件不是同一种东西。

## 基本概念

sysfs 是基于内存的文件系统，用于导出内核数据结构、属性以及对象之间的联系，并与 kobject 基础设施紧密相关。

## 工作原理

读 `/sys` 文件时，用户态触发内核属性的 show 回调；写 `/sys` 文件时，触发 store 回调。

## 设计目的

统一导出设备模型与驱动属性，让用户态能查看和调整设备相关状态。

## 优缺点

优点：接口统一，易脚本访问。

缺点：不是稳定内部 ABI，误写可能改系统行为。

## 典型应用

- `/sys/class`
- `/sys/block`
- `/sys/devices`

## 在 Buildroot 中的位置

Buildroot 设备只要使用现代 Linux 设备模型，用户态就会依赖 sysfs 获取设备和驱动状态。

## 在 OpenWrt 中的位置

OpenWrt 中很多热插拔、网络、LED、按钮等运行时行为都与 `/sys` 有交集。

## 在光猫中的体现

光猫里的网口、LED、Wi-Fi、按键和块设备状态，往往都能在 `/sys` 下找到对应视图或控制接口。

## 实际案例

为什么 `/sys` 可以修改驱动？因为写入动作不是在改磁盘文本，而是在调用内核对象的属性处理逻辑。

## 实践操作

```bash
ls /sys | head -n 30
ls /sys/class | head -n 30
ls /sys/block | head -n 30
```

怎么看：`/sys/class` 看逻辑设备分类，`/sys/block` 看块设备。

## 前置知识

- VFS
- SystemCall

## 后续知识

- Devtmpfs
- Mount机制

## 知识等级

★★★★★ 必须掌握

## 参考资料

- 官方文档：Linux Kernel Docs `https://docs.kernel.org/`、Buildroot Manual `https://buildroot.org/manual.html`、OpenWrt Docs `https://openwrt.org/docs/start`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`、OpenWrt `https://github.com/openwrt/openwrt`
- 标准：Linux man-pages `https://man7.org/linux/man-pages/`
- GPL源码：后续结合 Rootfs、init 脚本、socket、容器配置和运行时目录验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：Bootlin `https://bootlin.com/`、LWN `https://lwn.net/`


## 最后验证时间

更新时间：2026-07-12

适用版本：Linux 系统运行机制通用知识

验证环境：Kernel 文档、man7、Buildroot / OpenWrt 文档整理

作者：Codex
