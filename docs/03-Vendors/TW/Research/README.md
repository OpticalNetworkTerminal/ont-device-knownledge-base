# T&W Research Database

本目录仅用于建设天邑（T&W / Tianyi）ONT Research Database。

## Session Scope

- 仅负责 `docs/03-Vendors/TW/Research/`
- 不整理正式手册
- 不删除未验证资料
- 不把社区资料改写成官方结论
- 所有资料保留来源、发布日期、Evidence、适用型号、适用运营商、适用地区、最后收集时间

## Evidence

| 等级 | 定义 |
| --- | --- |
| A | 官方文档、官方源码、GPL 源码、ITU、Broadband Forum |
| B | GPL 分析、固件分析、源码分析、多来源一致 |
| C | 恩山、ChinaDSL、52pojie、OpenWrt Forum、GitHub Issues、多个社区一致 |
| D | 博客、个人经验、单一帖子、拆机经验 |

## Collected At

- 最后收集时间: `2026-07-12`

## Index

- [Models](./Models/README.md)
- [Commands](./Commands/README.md)
- [Firmware](./Firmware/README.md)
- [Boot](./Boot/README.md)
- [Filesystem](./Filesystem/README.md)
- [DBus](./DBus/README.md)
- [TR069](./TR069/README.md)
- [OMCI](./OMCI/README.md)
- [Security](./Security/README.md)
- [Config](./Config/README.md)
- [Debug](./Debug/README.md)
- [Network](./Network/README.md)
- [Mesh](./Mesh/README.md)
- [Tools](./Tools/README.md)
- [GPL](./GPL/README.md)
- [Community](./Community/README.md)
- [Blogs](./Blogs/README.md)
- [FCC](./FCC/README.md)
- [Operators](./Operators/README.md)
- [ODM](./ODM/README.md)
- [Images](./Images/README.md)
- [Unknown](./Unknown/README.md)

## T&W Research Collection Report

### 1. 收集来源统计

| 类型 | 数量 |
| --- | --- |
| 官方资料 | 8 |
| 标准组织资料 | 5 |
| GitHub / Gitee | 7 |
| 社区帖子 | 10 |
| 其它认证/监管 | 1 |
| 合计 | 31 |

### 2. 型号数量

- 当前 Research 中已建立索引的型号数: `21`

### 3. 固件数量

- 当前已建立固件/版本线索数: `8`

### 4. GPL 数量

- 当前明确收录的 GPL/源码相关条目数: `4`

### 5. 社区帖子数量

- 当前收录的社区帖子条目数: `10`

### 6. 官方资料数量

- 当前收录的官方资料条目数: `8`

### 7. 命令索引数量

- 当前命令索引条目数: `12`

### 8. ODM/OEM 对应关系数量

- 当前已登记的 ODM/OEM 对应关系条目数: `6`

### 9. 未分类资料

- 当前 `Unknown` 条目数: `7`

### 10. 建议下一阶段（Curator）优先整理主题

- `TEWA-708E / 768G / 800E / 1000E` 的配置备份、超管、Telnet、SSH 资料链
- `TEWA-861G / 870G / 872G / 1008V / 1100G` 的运营商定制与产品谱系
- `TR-069 / TR-181 / G.984.4 / G.988` 与天邑 Web/配置对象之间的映射
- `db_user_cfg.xml / ctce8_*.cfg / sessionKey / set2_sessionKey / set3_sessionKey` 线索归并
- 运营商维度的桥接、IPv6、Mesh、隐藏页面差异
