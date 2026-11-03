# Huawei Research

本目录为 `Huawei ONT Research Database`。

用途：

- 收集公开资料
- 保存待验证知识
- 为后续 Curator 整理正式文档提供来源池

约束：

- 本目录不编写最终使用手册
- 本目录不删除未验证资料
- 本目录不把社区资料改写成官方结论

最后收集时间：`2026-07-12`

## Evidence 规则

| 等级 | 含义 |
| --- | --- |
| `A` | 官方文档、官方源码、GPL 源码、RFC、ITU-T、Broadband Forum |
| `B` | 固件分析、GPL 分析、源码分析、多来源一致的技术分析 |
| `C` | 恩山、ChinaDSL、52pojie、OpenWrt Forum、GitHub Issues、多个社区一致 |
| `D` | 单一博客、单一论坛、个人经验、零散镜像 |

## 分类目录

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
- [Tools](./Tools/README.md)
- [Community](./Community/README.md)
- [GPL](./GPL/README.md)
- [Blogs](./Blogs/README.md)
- [FCC](./FCC/README.md)
- [Images](./Images/README.md)
- [Unknown](./Unknown/README.md)
- [Huawei Research Collection Report](./Huawei%20Research%20Collection%20Report.md)

## 来源统计快照

| 类别 | 条目数 |
| --- | ---: |
| 官方资料 | 11 |
| GPL/开源入口 | 7 |
| 固件资料 | 10 |
| 社区帖子/社区索引 | 18 |
| GitHub/GitLab/Gitee/代码托管 | 11 |
| FCC/监管 | 5 |
| 博客/镜像 | 8 |
| 未分类 | 6 |

## 研究注意事项

- 同一型号可能存在地区差异、运营商差异、硬件版本差异。
- 同一命令名可能在不同固件中指向不同二进制或不同权限层。
- `hw_ctree.xml`、`hw_boardinfo`、`aescrypt2`、`descrypt` 相关资料保留原样，等待后续交叉验证。
- `TR069`、`OMCI`、`SN/MAC/LOID` 相关资料需额外记录运营商和地区。
