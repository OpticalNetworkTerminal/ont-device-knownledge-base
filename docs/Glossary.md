# Glossary

## 说明

本文用于统一当前知识库中的核心术语写法。后续新增文档应优先遵循本表，避免同一概念出现多种写法。

## 统一术语表

| 统一写法 | 可接受别名 | 说明 |
| --- | --- | --- |
| `Rootfs` | RootFS、Root File System | 正文统一使用 `Rootfs` |
| `根文件系统` | Rootfs | 中文叙述优先用“根文件系统”，技术标识优先用 `Rootfs` |
| `AArch64` | ARM64 | 技术准确写法统一为 `AArch64`，口语可提一次 ARM64 |
| `AArch32` | ARM32 | 技术准确写法统一为 `AArch32` |
| `ARM` | ARM 架构 | 泛指架构家族时使用 `ARM` |
| `ABI` | 二进制接口 | 正文首次可写“ABI（二进制接口）” |
| `EABI` | Embedded ABI | ARM 语境统一用 `EABI` |
| `Hard Float` | HardFloat、硬浮点 | 正文统一写 `Hard Float`，中文说明可括注“硬浮点” |
| `Soft Float` | SoftFloat、软浮点 | 正文统一写 `Soft Float`，中文说明可括注“软浮点” |
| `ELF` | ELF 文件 | 文件格式名统一用 `ELF` |
| `动态链接器` | `ld-linux`、interpreter | 正文统一写“动态链接器”，首次可括注 `ld-linux` |
| `共享库` | 动态库、Shared Library | 正文统一使用“共享库” |
| `静态链接` | Static Linking | 正文统一使用“静态链接” |
| `Sysroot` | system root、开发根 | 正文统一用 `Sysroot` |
| `Toolchain` | 工具链 | 标题和路径统一用 `Toolchain`，正文可写“工具链（Toolchain）” |
| `SDK` | 开发工具包 | 正文统一用 `SDK` |
| `Buildroot` | buildroot | 专有名词首字母大写 |
| `OpenWrt` | openwrt | 专有名词保持官方写法 |
| `LinuxRuntime` | Linux Runtime | 目录名统一为 `LinuxRuntime` |
| `EmbeddedRuntime` | Embedded Runtime | 目录名统一为 `EmbeddedRuntime` |
| `procfs` | `/proc` 文件系统、Proc 文件系统 | 技术抽象统一用 `procfs`，目录或路径说明使用 `/proc` |
| `sysfs` | `/sys` 文件系统、Sysfs | 技术抽象统一用 `sysfs` |
| `devtmpfs` | `/dev` 文件系统 | 技术抽象统一用 `devtmpfs` |
| `tmpfs` | 临时文件系统 | 技术抽象统一用 `tmpfs` |
| `VFS` | 虚拟文件系统 | 技术抽象统一用 `VFS` |
| `Unix Domain Socket` | Unix Socket、本地 socket | 正文统一使用 `Unix Domain Socket` |
| `socket` | 套接字 | 技术抽象统一用 `socket` |
| `namespace` | 命名空间 | 技术抽象统一用 `namespace` |
| `cgroup` | control group | 技术抽象统一用 `cgroup` |
| `capability` | 能力集 | 技术抽象统一用 `capability` |
| `daemon` | 守护进程 | 正文统一用 `daemon`，首次可写“守护进程（daemon）” |
| `shell` | Shell | 正文统一小写 `shell`，目录文件名保留中文或既定英文 |
| `BusyBox init` | busybox init | 固定写法为 `BusyBox init` |
| `procd` | Procd | OpenWrt 服务管理器统一写 `procd` |
| `Overlay` | overlay、Rootfs Overlay | Buildroot 语境下统一写 `Overlay` 或 `Rootfs Overlay` |

## 用词规则

- 中文正文中，首次出现英文术语时建议采用“中文（英文）”格式。
- 文件名保持现状，不因术语统一再调整现有文件名。
- 后续若同一概念出现第三种写法，优先补入本表后再继续写正文。
