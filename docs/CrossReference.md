# CrossReference

## 说明

本文用于定义当前知识库的交叉引用规则。目标是后续新增内容时，不重复解释已有基础知识，而是统一引用到既有章节。

## 相对路径规范

统一使用仓库内相对路径，格式示例：

```md
参见：

- `../EmbeddedRuntime/Toolchain.md`
- `../LinuxRuntime/Mount机制.md`
```

规则：

- 同级目录引用：`./文件名.md`
- 同层不同目录引用：`../目录名/文件名.md`
- 根目录下汇总文档引用：`../../KnowledgeMap.md` 或 `../../Glossary.md`

## 当前标准引用目标

### Buildroot 章节应引用

| 主题 | 标准引用 |
| --- | --- |
| Toolchain | `../EmbeddedRuntime/Toolchain.md` |
| Sysroot | `../EmbeddedRuntime/Sysroot.md` |
| SDK | `../EmbeddedRuntime/SDK.md` |
| 交叉编译 | `../EmbeddedRuntime/交叉编译.md` |
| ELF / 动态链接 | `../EmbeddedRuntime/ELF文件格式.md`、`../EmbeddedRuntime/动态链接.md` |
| libc | `../EmbeddedRuntime/glibc.md`、`../EmbeddedRuntime/musl.md`、`../EmbeddedRuntime/uClibc.md` |
| Init 运行机制 | `../LinuxRuntime/Init系统.md` |
| mount / VFS / tmpfs | `../LinuxRuntime/Mount机制.md`、`../LinuxRuntime/VFS.md`、`../LinuxRuntime/Tmpfs.md` |

### EmbeddedRuntime 章节应引用

| 主题 | 标准引用 |
| --- | --- |
| Buildroot 工程上下文 | `../Buildroot/README.md` |
| Rootfs 组装 | `../Buildroot/Rootfs生成过程.md` |
| 运行时目录和系统状态 | `../LinuxRuntime/README.md` |
| 进程 / mount / `/proc` | `../LinuxRuntime/PID与进程.md`、`../LinuxRuntime/Mount机制.md`、`../LinuxRuntime/Proc文件系统.md` |

### LinuxRuntime 章节应引用

| 主题 | 标准引用 |
| --- | --- |
| ELF / ABI / Toolchain | `../EmbeddedRuntime/ELF文件格式.md`、`../EmbeddedRuntime/ABI.md`、`../EmbeddedRuntime/Toolchain.md` |
| Buildroot 上下文 | `../Buildroot/README.md`、`../Buildroot/Init系统.md` |
| OpenWrt 与 procd 的构建背景 | `../Buildroot/Buildroot与OpenWrt区别.md` |

## 未来章节默认引用

### Filesystem

- `../LinuxRuntime/Mount机制.md`
- `../LinuxRuntime/VFS.md`
- `../LinuxRuntime/Proc文件系统.md`
- `../Buildroot/Filesystem生成.md`

### Network

- `../LinuxRuntime/Socket.md`
- `../LinuxRuntime/权限模型.md`
- `../LinuxRuntime/Sysfs.md`

### IPC / DBus / ubus

- `../LinuxRuntime/Socket.md`
- `../LinuxRuntime/UnixDomainSocket.md`
- `../LinuxRuntime/Daemon.md`
- `../LinuxRuntime/权限模型.md`

### OpenWrt

- `../Buildroot/Buildroot与OpenWrt区别.md`
- `../EmbeddedRuntime/Toolchain.md`
- `../LinuxRuntime/Init系统.md`
- `../LinuxRuntime/Mount机制.md`

### LXC

- `../LinuxRuntime/Namespace.md`
- `../LinuxRuntime/Cgroup.md`
- `../LinuxRuntime/Mount机制.md`
- `../LinuxRuntime/Devtmpfs.md`

### Vendors

厂商章节默认优先引用：

- `../02-Fundamentals/Buildroot/README.md`
- `../02-Fundamentals/EmbeddedRuntime/README.md`
- `../02-Fundamentals/LinuxRuntime/README.md`

## 使用方式

后续新增文档时，推荐在正文中统一使用：

```md
参见：

- `../EmbeddedRuntime/ABI.md`
- `../LinuxRuntime/Proc文件系统.md`
```

不推荐再次写一遍 ABI、ELF、mount、VFS、namespace 的基础解释。
