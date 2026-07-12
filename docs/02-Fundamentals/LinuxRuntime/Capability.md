# Capability

## 简介

本文说明 Linux capability 的作用，以及为什么 root 权限后来被拆分成更细粒度的能力集合。

## 背景

经典 Unix 模型里，root 几乎无所不能。现代 Linux 需要更细粒度控制，于是引入 capability，把超级权限拆成多个能力位。

## 基本概念

capability 是一组可独立授予或剥夺的特权能力，例如：

- 网络管理
- 挂载
- 修改系统时间

## 工作原理

内核在执行敏感操作时，不仅看 UID 是否为 0，也会看当前进程是否拥有对应 capability。

## 设计目的

减少“一旦是 root 就全能”的风险，更适配最小权限和容器场景。

## 优缺点

优点：

- 粒度更细
- 适合现代隔离场景

缺点：

- 比经典权限更复杂

## 典型应用

- 容器降权
- 服务最小特权

## 在 Buildroot 中的位置

Buildroot 若构建更复杂的网络服务、容器环境或安全策略，capability 会成为重要机制。

## 在 OpenWrt 中的位置

OpenWrt 的服务隔离和容器场景同样会受 capability 影响。

## 在光猫中的体现

光猫若引入容器、轻量隔离或细粒度服务授权，capability 比单纯 root/non-root 更有价值。

## 实际案例

为什么容器里的 root 不一定真能挂载文件系统或修改所有内核资源？因为它可能缺少对应 capability。

## 实践操作

```bash
cat /proc/self/status | grep Cap
```

怎么看：

- `CapEff`、`CapPrm` 等字段展示当前进程能力集合

## 前置知识

- 权限模型
- Namespace

## 后续知识

- SELinux简介
- AppArmor简介
- LXC

## 知识等级

★★★★ 建议掌握

## 参考资料

- 官方文档：Linux man-pages `https://man7.org/linux/man-pages/`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：capabilities 相关 man pages
- GPL源码：后续结合容器与服务权限验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：LWN `https://lwn.net/`

## 最后验证时间

更新时间：2026-07-12

适用版本：Linux capability 通用知识

验证环境：man7 与 `/proc` 状态实践整理

作者：Codex
