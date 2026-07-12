# RefactorReport

## 说明

本文只做现状梳理，不删除、不合并、不改写现有知识内容。目标是识别当前知识库中的重复点、边界交叉点和后续整理优先级。

## 当前范围

已检查范围：

- `docs/02-Fundamentals/Buildroot`
- `docs/02-Fundamentals/EmbeddedRuntime`
- `docs/02-Fundamentals/LinuxRuntime`

## 结论总览

- 当前知识层次总体是清晰的：`Buildroot -> EmbeddedRuntime -> LinuxRuntime`
- 现阶段的主要问题不是“冲突”，而是“交叉引用尚未落地”
- 重复主要集中在“章节引言级重复”和“术语表重复”，不是大段正文冲突

## 主要重复主题

### 1. Toolchain / Sysroot / SDK

涉及位置：

- `02-Fundamentals/Buildroot/Buildroot工具链.md`
- `02-Fundamentals/EmbeddedRuntime/Toolchain.md`
- `02-Fundamentals/EmbeddedRuntime/Sysroot.md`
- `02-Fundamentals/EmbeddedRuntime/SDK.md`
- `02-Fundamentals/EmbeddedRuntime/交叉编译.md`

现状判断：

- `Buildroot工具链.md` 讨论的是 Buildroot 工程如何使用工具链
- `EmbeddedRuntime/Toolchain.md` 讨论的是运行环境中的工具链抽象
- 目前属于“上下层都提到了同一概念”，不构成冲突

后续建议：

- 以后 Buildroot 章节提到底层 Toolchain 原理时，优先引用 `../EmbeddedRuntime/Toolchain.md`

### 2. Init

涉及位置：

- `02-Fundamentals/Buildroot/Init系统.md`
- `02-Fundamentals/LinuxRuntime/Init系统.md`

现状判断：

- Buildroot 章节讨论的是构建系统里可选的 init 方案
- LinuxRuntime 章节讨论的是系统启动完成后的 PID 1 角色
- 二者定位不同，但标题同名，后续容易重复展开

后续建议：

- Buildroot 章节保留“Buildroot 里如何选 init”
- LinuxRuntime 章节作为“init 机制的唯一标准解释入口”

### 3. Rootfs / Overlay / Filesystem / Mount

涉及位置：

- `02-Fundamentals/Buildroot/Rootfs生成过程.md`
- `02-Fundamentals/Buildroot/Rootfs Overlay实践.md`
- `02-Fundamentals/Buildroot/Filesystem生成.md`
- `02-Fundamentals/Buildroot/Overlay机制.md`
- `02-Fundamentals/LinuxRuntime/Mount机制.md`
- `02-Fundamentals/LinuxRuntime/VFS.md`
- `02-Fundamentals/LinuxRuntime/Tmpfs.md`

现状判断：

- Buildroot 关注“构建期如何生成 Rootfs”
- LinuxRuntime 关注“启动后 Rootfs 如何参与运行时视图”
- 目前存在主题交叉，但尚未冲突

后续建议：

- 后续 `Filesystem` 章节应成为“根文件系统运行时语义”的统一入口
- Buildroot 保留生成侧，LinuxRuntime 保留运行时侧

### 4. BusyBox

涉及位置：

- `02-Fundamentals/Buildroot/BusyBox关系.md`
- `02-Fundamentals/Buildroot/Init系统.md`
- `02-Fundamentals/LinuxRuntime/Shell.md`

现状判断：

- 当前 BusyBox 主要出现在 Buildroot 章节
- LinuxRuntime 只在 shell 和 init 上轻量提及

后续建议：

- BusyBox 原理层优先沉淀到 `02-Fundamentals/BusyBox/`
- Buildroot 章节只保留“Buildroot 如何使用 BusyBox”

### 5. Socket / Unix Domain Socket / DBus 预备知识

涉及位置：

- `02-Fundamentals/LinuxRuntime/Socket.md`
- `02-Fundamentals/LinuxRuntime/UnixDomainSocket.md`

现状判断：

- 当前已形成良好的基础层
- 后续 DBus / ubus 章节不应再重复解释 socket 原理

## 标题层级现状

统计现状：

- `EmbeddedRuntime` 与 `LinuxRuntime` 主要使用统一二级标题集
- `Buildroot` 使用另一套二级标题集：`原理 / 组成 / 工作流程 / 实际应用 / 光猫中的体现 / 注意事项`

当前不统一点：

- `Buildroot` 使用 `原理`，其余两层使用 `基本概念 + 工作原理 + 设计目的`
- `Buildroot` 使用 `光猫中的体现`，其余两层使用 `在光猫中的体现`
- `Buildroot` 使用 `实际应用`，其余两层使用 `典型应用 + 实际案例`
- `Buildroot` 没有统一的 `前置知识 / 后续知识 / 知识等级`

结论：

- 当前标题体系已经出现两套风格
- 暂时不改正文，但后续新增章节应优先采用 `EmbeddedRuntime / LinuxRuntime` 的统一结构

## Mermaid 现状

当前观察：

- 绝大多数 Mermaid 已统一使用 `flowchart TD`
- 未发现明显颜色或主题风格分裂
- 命名风格仍有轻微差异：有的节点用英文，有的用中文，有的中英混合

建议统一规则：

- 默认使用 `flowchart TD`
- 默认节点名以中文为主，必要时括注英文
- 不引入颜色主题，避免不同章节各自定义样式

## 术语现状

当前已发现需要统一的典型术语：

- `Rootfs` / `RootFS` / `Root File System`
- `AArch64` / `ARM64`
- `动态库` / `共享库`
- `Toolchain` / `工具链`
- `Unix Socket` / `Unix Domain Socket`
- `procfs` / `/proc 文件系统`

已处理方式：

- 统一整理到 [Glossary.md](./Glossary.md)

## 当前不建议立即修改的内容

- 不建议现在就批量改 Buildroot 文档标题结构
- 不建议现在就移动或改名已有文件
- 不建议现在就合并 `常见问题.md`、`术语解释.md` 等重复职能文件

原因：

- 现阶段基础层刚建立，先固定“引用规则”比先大规模改稿更稳

## 下一步整理重点

1. 后续新增章节统一采用 `EmbeddedRuntime / LinuxRuntime` 的标题模板
2. 新章节必须先查 [CrossReference.md](./CrossReference.md)，避免重复解释
3. 需要术语时优先查 [Glossary.md](./Glossary.md)
4. 待 `Filesystem`、`Network`、`IPC` 建设后，再进行第二轮正文级去重
