# ReverseEngineering

本手册汇总 ZTE 的逆向分析入口与研究分区索引。


# Research 总览

# Research

本目录仅用于建设 ZTE ONT `Research Database`。

这里保留：

- 官方资料
- GPL/开源代码
- 固件线索
- 型号线索
- 平台线索
- 社区帖子
- 工具与实验
- `sendcmd`/`sidbg`/`setmac`/`upgradetest` 等命令出现记录
- 运营商差异
- 图片与截图来源

这里不负责：

- 最终使用手册
- 最终命令参考
- 最终结论

## Evidence Level

| 等级 | 含义 |
| --- | --- |
| A | 官方文档、官方源码、GPL 源码、FCC、ITU、Broadband Forum |
| B | GPL 分析、源码分析、固件分析、多来源一致 |
| C | 恩山、ChinaDSL、52pojie、OpenWrt Forum、GitHub Issues 等多个社区来源一致 |
| D | 单一论坛、博客、经验贴、视频、零散截图、未交叉验证记录 |

## 研究库结构

- [Official](./Official/index.md)
- [GPL](./GPL/index.md)
- [Models](./Models/index.md)
- [Platform](./Platform/index.md)
- [Firmware](./Firmware/index.md)
- [Config](./Config/index.md)
- [Debug](./Debug/index.md)
- [Commands](./Commands/index.md)
- [DBus](./DBus/index.md)
- [Operators](./Operators/README.md)
- [Community](./Community/index.md)
- [Images](./Images/index.md)
- [Reports](./Reports/ZTE%20Research%20Collection%20Report.md)

## 现有研究主题

- [高权限账户与工厂模式](./高权限账户与工厂模式.md)
- [修改SN](./修改SN.md)
- [修改MAC](./修改MAC.md)
- [修改LOID](./修改LOID.md)
- [桥接](./桥接.md)
- [Mesh](./Mesh.md)
- [LED控制](./LED控制.md)
- [双模切换](./双模切换.md)
- [sendcmd社区命令收集](./sendcmd社区命令收集.md)

## 说明

- Research 的目标是“尽可能完整收集”，不是“证明已经正确”。
- 未实机验证资料不得删除，只能保留来源、Evidence 和上下文。
- 社区资料不得改写成官方结论。
