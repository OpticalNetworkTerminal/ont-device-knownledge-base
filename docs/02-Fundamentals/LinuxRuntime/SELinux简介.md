# SELinux简介

## 简介

本文简要说明 SELinux 的定位，以及它与经典权限模型的区别。

## 背景

传统 Linux 权限模型表达能力有限，难以描述复杂最小权限策略。SELinux 通过强制访问控制提供更细粒度的安全边界。

## 基本概念

SELinux 是 Linux Security Module 体系中的一种强制访问控制方案。

## 工作原理

内核在做访问决策时，不只看 UID/GID/权限位，还会看安全上下文和策略规则是否允许该操作。

## 设计目的

提供比传统权限更细的控制，限制进程即使被攻破后还能访问的范围。

## 优缺点

优点：

- 强约束
- 粒度细

缺点：

- 配置复杂
- 对轻量嵌入式设备维护成本高

## 典型应用

- 企业发行版
- 安全要求高的系统

## 在 Buildroot 中的位置

Buildroot 可以支持更复杂安全模型，但对大量资源敏感嵌入式设备而言，SELinux 不是默认首选。

## 在 OpenWrt 中的位置

OpenWrt 更强调轻量与网络设备场景，通常不会把 SELinux 作为默认基础能力。

## 在光猫中的体现

典型光猫更常见轻量权限模型、自定义限制和最小服务集；SELinux 不是最常见默认选择，但理解其定位有助于建立完整安全视角。

## 实际案例

为什么有些系统中文件权限看起来允许，访问仍被拒绝？因为在启用强制访问控制的系统中，经典权限只是第一层。

## 实践操作

```bash
getenforce 2>/dev/null
ls -Z / 2>/dev/null | head
```

怎么看：

- `getenforce`：看 SELinux 是否启用
- `ls -Z`：若可用，查看安全上下文

## 前置知识

- 权限模型
- Capability

## 后续知识

- AppArmor简介
- Security

## 知识等级

★★★ 了解即可

## 参考资料

- 官方文档：Kernel docs `https://docs.kernel.org/`
- 官方源码：Linux kernel `https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
- 标准：Linux man-pages `https://man7.org/linux/man-pages/`
- GPL源码：后续结合启用 SELinux 的系统验证
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- 博客：LWN `https://lwn.net/`

## 最后验证时间

更新时间：2026-07-12

适用版本：SELinux 基础定位知识

验证环境：Kernel 安全机制资料整理

作者：Codex
