# Buildroot常见目录说明

## 简介

本文从工程视角说明 Buildroot 中最常见的几个目录分别应该放什么，以及常见误用是什么。

## 背景

理解目录结构不只是为了“认识名字”，而是为了知道改动应该放在哪里。放错位置，短期看似能跑，长期一定难维护。

## 原理

Buildroot 的目录大致可以分成：

- 配置入口目录
- 包定义目录
- 板级定制目录
- 输出目录
- 外部扩展目录

## 组成

### 常见目录与用途

| 目录 | 作用 | 备注 |
| --- | --- | --- |
| `configs/` | 保存 `defconfig` | 推荐放精简配置 |
| `board/` | 保存板级文件 | 内核、BusyBox、overlay、脚本 |
| `package/` | 包定义 | `Config.in`、`.mk`、`.hash` |
| `system/` | 默认系统骨架与通用系统配置 | 通常少直接改 |
| `toolchain/` | 工具链基础设施 | 理解工具链入口时重要 |
| `output/build/` | 各包构建目录 | 适合看中间产物 |
| `output/host/` | host 工具与 sysroot | 交叉工具链相关 |
| `output/target/` | 近似 rootfs | 不应直接作为刷机内容 |
| `output/images/` | 最终镜像输出 | 最值得关注的交付目录 |
| `br2-external/` | 项目外部扩展树 | 多产品线更推荐 |

## 工作流程

推荐的认知顺序：

1. `configs/` 决定“要构建什么”
2. `board/` 决定“这块板怎么定制”
3. `package/` 决定“软件包怎么纳入系统”
4. `output/` 呈现“构建结果是什么”

## 实际应用

常见误用：

- 把产品默认文件直接手改到 `output/target/`
- 把所有私有程序都放在 overlay，而不是做成包
- 把多产品差异硬塞在一个 `defconfig` 里

更合理的做法：

- 默认配置放 `board/.../rootfs-overlay/`
- 私有程序做成 package
- 多产品拆 `defconfig` 或 `br2-external`

## 光猫中的体现

在光猫项目中，最值得重点看的是：

- `configs/`：产品配置入口
- `board/`：板级与运营商差异
- `package/`：私有守护进程与服务
- `output/images/`：rootfs、kernel、dtb 和中间固件文件

## 注意事项

- 理解目录用途，比背目录名字更重要。
- 目录边界清晰，后续 GPL 发布、版本迁移和内部审计都会轻很多。
- 目录组织不清晰的 Buildroot 工程，后期几乎一定依赖个人记忆。

## 参考资料

- 官方链接：Buildroot Manual `https://buildroot.org/manual.html`
- 官方源码：Buildroot `https://gitlab.com/buildroot.org/buildroot`
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- GPL源码：后续结合厂商 GPL Release 的目录布局验证
- 博客：Bootlin `https://bootlin.com`

## 最后验证时间

更新时间：2026-07-12

适用版本：Buildroot 通用工程目录

验证环境：Buildroot 官方手册与典型工程组织经验整理

作者：Codex
