# Architecture

本手册汇总 Huawei ONT 的总体结构、管理体系和 IPC 入口。

# Huawei

本目录用于建设 `Huawei` 光猫正式知识库，范围仅限华为 ONT/ONU 设备，不涉及其他厂商。当前写法采用 Wiki 风格：优先保证资料覆盖面、结构清晰和来源可追溯，其次再逐步提高实机验证比例。

## 当前目录结构

- [操作与入口总览](./Guides/README.md)
- [命令参考](./Commands/README.md)
- [型号索引](./Devices/README.md)
- [配置、协议与固件对象](./Database/README.md)
- [私有总线与 IPC 预留](./DBus/README.md)
- [Research 资料池](./Research/README.md)

## 推荐阅读顺序

1. [Guides](./Guides/README.md)
   先理解华为光猫常见入口、运营商限制、配置文件、TR069/OMCI、SN/MAC/LOID、恢复与升级。
2. [Database](./Database/README.md)
   再看 `hw_ctree.xml`、`hw_boardinfo`、配置加解密、TR069 与 OMCI 的对象级整理。
3. [Commands](./Commands/README.md)
   需要具体命令时，再看命令参考和待整理命令。
4. [Devices](./Devices/README.md)
   最后回到型号索引，定位某个机型的资料密度和研究方向。

## 主题范围

- `hw_ctree`
- `aescrypt`
- `descrypt`
- `Telnet`
- `SSH`
- `Serial`
- `配置文件`
- `XML`
- `TR069`
- `OMCI`
- `超级管理员`
- `运营商限制`
- `恢复`
- `升级`
- `双模`
- `LED`
- `Mesh`
- `修改 SN`
- `修改 MAC`
- `修改 LOID`
- `命令参考`
- `常见工具`

## 验证状态定义

| 状态 | 含义 |
| --- | --- |
| `已整理` | 已从 Research 资料池沉淀为正式条目 |
| `官方资料` | 可从华为官方资料入口确认产品或管理概念存在 |
| `社区资料` | 主要来自论坛、博客、GitHub 实测或逆向记录 |
| `多源一致` | 两个及以上独立来源描述接近 |
| `待实机验证` | 尚未在真实设备上复核，不能视为最终结论 |
| `已实机验证` | 后续通过真实设备操作确认 |

## 当前文档状态

- 已建立正式主入口，按“进入设备后的问题”组织内容。
- 已将高频主题沉淀到正式页：`Telnet`、`Serial`、`hw_ctree.xml`、`aescrypt2`、`TR069`、`OMCI`、`SN/MAC/LOID`、恢复与升级。
- 已建立命令参考、型号索引和配置/协议索引三张核心页面。

## 维护建议

- 新增命令时，优先补到 [命令参考](./Commands/README.md)。
- 新增机型时，优先补到 [型号索引](./Devices/README.md)。
- 新增配置文件、XML 字段、TR069/OMCI 信息时，优先补到 [配置与协议索引](./Database/README.md)。
- 新增改机、恢复、升级、SN/MAC/LOID 相关流程时，优先补到 [操作与入口总览](./Guides/README.md)。
- 原始帖子、镜像、固件线索、FCC、GPL 入口，优先补到 [Research](./Research/README.md)，再决定是否沉淀进正式页。

# DBus

# DBus

该目录用于收录华为设备中 D-Bus、私有总线或相似 IPC 接口的资料。
