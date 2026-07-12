# Rootfs Overlay实践

## 简介

本文从工程实践角度说明如何合理使用 Buildroot 的 Rootfs Overlay，避免把 overlay 用成不可维护的“垃圾桶”。

## 背景

Overlay 是 Buildroot 最常见也最容易被滥用的机制。它几乎总能解决问题，所以团队很容易把所有变更都塞进去，最后导致：

- 无法区分静态资源与动态生成文件
- 不知道哪些配置应由包负责，哪些应由 overlay 负责
- 不知道哪些文件是产品默认值，哪些是调试残留

## 原理

Overlay 的本质是“在目标文件树之上再拷贝一次文件树”。所以它最适合表达：

- 明确且稳定的默认文件
- 不依赖运行时状态的静态内容
- 需要被版本管理和代码审查的目标文件

## 组成

推荐把 overlay 按用途分层：

- `etc/`：默认配置、init 配置、证书
- `usr/bin/`：少量必须覆盖的工具
- `usr/share/`：网页资源、模板、帮助文本
- `lib/` 或 `usr/lib/`：仅在确有必要时放置

不推荐放入：

- 临时调试文件
- 会被包安装覆盖的重复内容
- 本应由 post-build 动态生成的配置

## 工作流程

推荐实践流程：

1. 先确认问题是否应该在包定义中解决
2. 若只是放置静态文件，再放入 overlay
3. 若需要脚本改权限或删文件，再使用 post-build
4. 若基础骨架都不匹配，再考虑 custom skeleton

## 实际应用

一个较稳妥的 overlay 使用原则是：

- 配置默认值放 overlay
- 业务程序通过包安装
- 大规模目录修整放 post-build
- 底层骨架变更放 custom skeleton

这样层次清楚，后期迁移 Buildroot 版本时更轻。

## 光猫中的体现

在光猫里，overlay 常常用来放：

- 默认 LAN / WLAN 配置模板
- Web 资源
- 启动脚本
- 管理服务默认配置
- 证书与厂商文本资源

但如果把数据库初始值、版本文件、调试开关、调试脚本全部混进 overlay，后期会非常难审计。

## 注意事项

- overlay 应尽量小而清晰。
- 对同一路径的覆盖要有明确归属，避免多人随手修改。
- 对运营商差异较大的项目，建议拆成多个 overlay 或借助 `br2-external` 分层。

## 参考资料

- 官方链接：Buildroot Manual `https://buildroot.org/manual.html`
- 官方源码：Buildroot `https://gitlab.com/buildroot.org/buildroot`
- 论坛：恩山无线论坛 `https://www.right.com.cn/forum/`、ChinaDSL `https://www.chinadsl.net/`、吾爱破解 `https://www.52pojie.cn/`
- GPL源码：后续结合厂商 GPL Release 中的 overlay 分层实践验证
- 博客：Bootlin Buildroot Slides `https://bootlin.com/doc/training/buildroot/buildroot-slides.pdf`

## 最后验证时间

更新时间：2026-07-12

适用版本：Buildroot 通用工程实践

验证环境：Buildroot 官方手册与嵌入式项目常见目录组织经验整理

作者：Codex
