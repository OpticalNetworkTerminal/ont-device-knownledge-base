# KnowledgeMap

## 说明

本文用于描述当前知识库的整体知识地图，只梳理现有结构和已规划结构，不新增知识正文。

## 知识地图

```mermaid
flowchart TD
    ONT["01-ONT\n行业知识"]

    F["02-Fundamentals"]
    BR["Buildroot\n已建设"]
    ER["EmbeddedRuntime\n已建设"]
    LR["LinuxRuntime\n已建设"]
    FS["Filesystem\n待建设"]
    NW["Network\n待建设"]
    IPC["IPC\n待建设"]
    DBUS["DBus\n待建设"]
    OWR["OpenWrt\n待建设"]
    LXC["LXC\n待建设"]
    BOOT["Boot\n待建设"]
    LNX["Linux\n待建设"]

    ER_CPU["CPU / ISA"]
    ER_ABI["ABI / EABI / 浮点 ABI"]
    ER_ELF["ELF / 动态链接 / 动态链接器"]
    ER_LIBC["glibc / musl / uClibc"]
    ER_TC["Sysroot / Toolchain / SDK / 交叉编译"]

    LR_PROC["Process / Thread / Daemon / Shell"]
    LR_KAPI["SystemCall / Signal / Environment"]
    LR_FS["Proc / Sysfs / Devtmpfs / Tmpfs / Mount / VFS"]
    LR_ISO["Namespace / Cgroup / Capability / 权限模型"]

    V["03-Vendors\n待建设"]
    DB["04-Database\n采集数据"]
    G["05-Guides\n操作指南"]
    R["06-References\n引用资料"]

    ONT --> F
    F --> BR
    F --> ER
    F --> LR
    F --> FS
    F --> NW
    F --> IPC
    F --> DBUS
    F --> OWR
    F --> LXC
    F --> BOOT
    F --> LNX

    ER --> ER_CPU
    ER --> ER_ABI
    ER --> ER_ELF
    ER --> ER_LIBC
    ER --> ER_TC

    LR --> LR_PROC
    LR --> LR_KAPI
    LR --> LR_FS
    LR --> LR_ISO

    F --> V
    V --> DB
    V --> G
    V --> R
```

## 阅读顺序

1. `01-ONT`
2. `02-Fundamentals/Buildroot`
3. `02-Fundamentals/EmbeddedRuntime`
4. `02-Fundamentals/LinuxRuntime`
5. 后续待建设的 `Filesystem`、`Network`、`IPC`、`DBus`、`OpenWrt`、`LXC`
6. `03-Vendors`
7. `04-Database`、`05-Guides`、`06-References`

## 当前结论

- `Buildroot` 已经完成“系统构建层”的基础铺垫。
- `EmbeddedRuntime` 已经完成“二进制运行环境层”的基础铺垫。
- `LinuxRuntime` 已经完成“系统启动后运行机制层”的基础铺垫。
- 后续章节应尽量复用这三层，不重复解释底层概念。
