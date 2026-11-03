# Architecture

本手册汇总 ZTE 厂商层面的架构、软件组织、启动恢复和运营商定制内容。


# Platform 总览

# Platform

本目录放 ZTE 厂商层面相对稳定的背景知识，用于回答“它大概是什么平台、软件和升级恢复是怎么组织的”，而不是回答单个设备的具体改法。

## 条目

- [品牌介绍](./品牌介绍.md)
- [产品线](./产品线.md)
- [平台架构](./平台架构.md)
- [软件架构](./软件架构.md)
- [Boot流程](./Boot流程.md)
- [升级机制](./升级机制.md)
- [恢复机制](./恢复机制.md)
- [运营商定制](./运营商定制.md)

## 使用原则

- 厂商级稳定背景放这里
- 型号特定差异放 `Devices`
- 操作步骤放 `Guides`
- 命令语法放 `Commands`
- 尚未成型的判断放 `Research`


# 品牌介绍

# 品牌介绍

## 定位

中兴在接入网侧同时覆盖 OLT、ODN 与用户端设备。就本目录而言，重点是 `ZXHN`、`ZXA10 F` 等家庭网关/ONT 产品。

## 已验证信息

- 中兴官方接入网产品文档地图将用户端设备单独列为 `User-End Device`，其中包含 `ZXHN F600W`、`F612`、`F660`、`F671Y`、`F680`、`H196A/Q`、`H199A`、`H388X V10` 等条目。
- FCC 公开资料可确认多个中兴设备以 `GPON ONT` 类别提交认证，例如 `ZXHN F660`、`ZXHN F670E`、`ZXHN F680V9`。

## 本手册的边界

- 聚焦中兴 ONT/家庭网关
- 不整理华为、烽火、诺基亚等其它厂商
- 不把社区破解经验直接写成“官方行为”

## Evidence

A/B

## 来源

- <https://support.zte.com.cn/support/docmap/00000455/en/product.html>
- <https://fccid.io/Q78-ZXHNF660/User-Manual/Users-Manual-1606409>
- <https://fccid.io/Q78-ZXHNF670E/User-Manual/Users-Manual-3705760>
- <https://fccid.io/Q78-ZXHNF680V9/User-Manual/User-Manual-4762018>


# 产品线

# 产品线

## Evidence

A/B

## 已验证型号索引

| 型号 | 版本/文档线索 | 来源 | 状态 |
| --- | --- | --- | --- |
| ZXHN F600W | `V9.2` | 中兴官方文档地图 | 已验证 |
| ZXHN F612 | `V9.0` | 中兴官方文档地图 | 已验证 |
| ZXHN F660 | `V5.0` | 中兴官方文档地图 | 已验证 |
| ZXHN F671Y | `V9.0` | 中兴官方文档地图 | 已验证 |
| ZXHN F680 | `V2.0` | 中兴官方文档地图 | 已验证 |
| ZXHN H196A | `V9.1` | 中兴官方文档地图 | 已验证 |
| ZXHN H196Q | `V9.1` | 中兴官方文档地图 | 已验证 |
| ZXHN H199A | `V7.0` | 中兴官方文档地图 | 已验证 |
| ZXHN H388X V10 | `V7.0` | 中兴官方文档地图 | 已验证 |

## FCC 已见型号

| 型号 | 设备类别 | 资料类型 | 状态 |
| --- | --- | --- | --- |
| ZXHN F660 | GPON ONT | 用户手册、内外部照片、测试报告 | 已验证 |
| ZXHN F670E | GPON ONT | 用户手册、内外部照片、测试报告 | 已验证 |
| ZXHN F680V9 | GPON ONT | 用户手册、内外部照片、测试报告 | 已验证 |

## 说明

- 官方文档地图中的版本号不等同于零售固件版本，也不直接等同于运营商定制版本。
- FCC 型号命名有时会带更细分的硬件代际，例如 `F680V9`，整理时应与市场称呼 `F680` 分开记录。

## 来源

- <https://support.zte.com.cn/support/docmap/00000455/en/product.html>
- <https://fccid.io/Q78-ZXHNF660/User-Manual/Users-Manual-1606409>
- <https://fccid.io/Q78-ZXHNF670E/User-Manual/Users-Manual-3705760>
- <https://fccid.io/Q78-ZXHNF680V9/User-Manual/User-Manual-4762018>


# 平台架构

# 平台架构

## Evidence

B/C

## 当前结论

ZTE ONT 不应被视为单一平台。公开资料显示至少存在多个硬件代际和平台族，后续整理需要按型号区分。

## 已验证内容

- 官方文档地图显示 ZTE 用户端设备长期跨越多个产品代际，不能把 `F660`、`F680`、`H196Q`、`H388X V10` 视为同一平台。
- OpenWrt 社区和 GitHub 的 `openwrt-avanta` 项目曾明确将 `ZTE F660` 纳入 `Marvell Avanta` 支持范围，这说明至少部分早期 F660 机型平台与 Avanta 系列有关。
- FCC 对 `F660`、`F670E`、`F680V9` 公开了内部照片和原理图元数据，说明后续可以基于一手材料继续细分平台，但本阶段尚未逐台完成。

## 社区资料

- 社区常把“F660/F670/F680”混称为同平台，但目前缺少足够一手资料支持这种泛化结论。

## 待验证

- 各型号 SoC/Flash/Wi-Fi 芯片清单
- GPON/EPON/XGS-PON 平台之间的软件栈差异
- 不同代际 Bootloader 差异

## 来源

- <https://support.zte.com.cn/support/docmap/00000455/en/product.html>
- <https://github.com/msdos03/openwrt-avanta>
- <https://forum.archive.openwrt.org/viewtopic.php?id=64813>
- <https://fccid.io/Q78-ZXHNF660>
- <https://fccid.io/Q78-ZXHNF670E>
- <https://fccid.io/Q78-ZXHNF680V9>


# 软件架构

# 软件架构

## Evidence

B/C

## 当前结论

公开资料可确认 ZTE ONT 常见的软件管理面由 Web 管理界面、配置数据库、导出配置文件和维护命令组成，但不同型号和运营商版本差异明显。

## 已验证内容

- GitHub 社区工具长期围绕 `config.bin`、`db_user_cfg.xml`、`db_default_auto_cfg.xml` 等文件工作，说明配置导出/导入与 XML/二进制封装是 ZTE 设备的重要配置形态。
- 多个社区来源可交叉验证 `sendcmd 1 DB ...` 与 `sidbg 1 DB ...` 被用于查询和修改运行配置数据库。
- 社区命令样本反复出现 `TelnetCfg`、`DevAuthInfo`、`MgtServer`、`WANC` 等表名，说明这些对象至少在部分机型/固件中稳定存在。

## 社区资料

- `sendcmd`/`sidbg` 背后是否直接对应 D-Bus、私有 IPC，还是中间再封装一层，目前公开证据不足。

## 待验证

- 启动时配置数据库从哪里加载
- `save` 的实际落盘路径与时机
- 用户态守护进程与 Web 进程的确切组件关系

## 来源

- <https://github.com/mkst/zte-config-utility>
- <https://github.com/mkst/zte-config-utility/blob/master/SUPPORT.md>
- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.chinadsl.net/thread-174301-1-1.html>


# Boot流程

# Boot流程

## Evidence

B/D

## 当前状态

待验证。

## 已确认到的公开线索

- 串口和维护入口在中兴社区资料中长期存在，说明至少部分机型可通过低层控制台观察启动过程。
- `zte_modem_tools` 公开提供了 `serial` 开关逻辑，表明社区普遍认为部分机型存在可由网页 factory mode 触发的串口相关控制路径。
- FCC 对多款中兴 ONT 公开了内部照片，为后续识别 UART 焊点、Flash 与主控提供了一手材料。

## 当前不能下的结论

- 不能把所有中兴 ONT 统一描述为同一个 Bootloader/分区/启动参数流程。
- 不能在没有样本日志时直接写出 U-Boot、内核、rootfs、配置恢复的精确顺序。

## 后续补充方向

- 收集具体型号的串口启动日志
- 结合 FCC 内部照片标注 UART
- 对接分区表、升级包和恢复机制文档

## 来源

- <https://github.com/douniwan5788/zte_modem_tools/blob/main/zte_factroymode.py>
- <https://fccid.io/Q78-ZXHNF660>
- <https://fccid.io/Q78-ZXHNF670E>
- <https://fccid.io/Q78-ZXHNF680V9>


# 升级机制

# 升级机制

## Evidence

B/C

## 当前状态

部分已验证，细节待验证。

## 已验证内容

- FCC 用户手册公开说明 `ZXHN F660`、`ZXHN F670E`、`ZXHN F680V9` 均存在正式用户手册，这意味着这些设备至少具备规范化的面向用户升级/维护界面或流程。
- 官方 PSIRT 公告显示 `ZXHN F670` 存在从 `V1.1.10P3T18` 到 `V1.1.10P3T22` 的修复版本，说明中兴确实以固件版本形式发布修复。

## 社区资料

- 社区通常通过 Web 升级、串口/TFTP、配置导入导出等方式处理升级与恢复，但具体路径高度依赖型号和运营商定制。

## 待验证

- 各型号升级包格式
- Web 升级是否校验运营商区域码
- 升级时是否保留 `db_user_cfg.xml`
- 回退机制是否可用

## 来源

- <https://fccid.io/Q78-ZXHNF660/User-Manual/Users-Manual-1606409>
- <https://fccid.io/Q78-ZXHNF670E/User-Manual/Users-Manual-3705760>
- <https://fccid.io/Q78-ZXHNF680V9/User-Manual/User-Manual-4762018>
- <https://support.zte.com.cn/support/news/NewsDetail.aspx?newsId=1010163>


# 恢复机制

# 恢复机制

## Evidence

C

## 当前状态

部分已验证，细节待验证。

## 已验证内容

- 社区资料普遍显示 ZTE ONT 存在“恢复出厂”这一稳定操作目标，既可从 Web 管理界面进行，也可能通过配置数据库命令或串口/Bootloader 方式进行。
- `sendcmd`/`sidbg` 的数据库访问能力说明部分恢复操作实质上与配置表回滚、保存和重启相关。

## 社区资料

- 串口 + TFTP + Bootloader 恢复经常被提及，但不同机型步骤差异很大。
- 某些资料把“恢复出厂”“清空认证参数”“切地区”“刷默认配置”混为一谈，整理时必须分开。

## 待验证

- 恢复出厂是否会清除 LOID/SN/MAC
- 恢复按钮与 Web 恢复的差异
- 低层恢复是否会覆盖运营商定制分区

## 来源

- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.chinadsl.net/forum.php?action=printable&mod=viewthread&tid=126463>
- <https://github.com/mkst/zte-config-utility>


# 运营商定制

# 运营商定制

## Evidence

B/C

## 当前结论

中兴 ONT 的管理入口、默认账户、Telnet 开关、地区码和桥接能力经常受到运营商定制影响，不能把单一机型的社区经验泛化为“ZTE 默认行为”。

## 已验证内容

- `zte_factroymode.py` 默认尝试的网页登录用户名/密码列表包含 `CMCCAdmin`、`CUAdmin`、`telecomadmin`、`cqadmin`、`useradmin` 等，说明公开研究中运营商定制差异非常普遍。
- 社区资料中关于 `Lan_EnableAfterOlt`、`InitSecLvl`、`TS_UName`、`TS_UPwd` 的修改，说明插光后自动关闭 Telnet、权限级别限制等确实是常见定制点。

## 社区资料

- 地区码切换、隐藏页面、工厂模式登录在不同省份/运营商版本中差异很大。
- 社区经常把“超密”“超级管理员”“工厂账号”混用，后续应继续拆分定义。

## 待验证

- 各运营商默认表结构差异
- 不同运营商是否封掉 `sendcmd`/`sidbg`
- TR-069 与本地改配置之间的优先级关系

## 来源

- <https://github.com/douniwan5788/zte_modem_tools/blob/main/zte_factroymode.py>
- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.chinadsl.net/forum.php?action=printable&mod=viewthread&tid=126463>
- <https://www.chinadsl.net/thread-151687-1-1.html>


# DBus

# DBus

本目录现在只用于整理 ZTE 设备里的 D-Bus / 私有 IPC / 对象模型相关结论，不再把“配置表索引”直接放在这里。

## 当前判断

- 公开社区资料大量出现 `sendcmd`、`sidbg`、配置表、XML 配置文件。
- 但“这些东西是否直接建立在标准 D-Bus 之上”这一点，目前没有足够证据统一下结论。
- 因此本目录只保留接口现状说明，把配置表与命令数据迁移到 [Database](../Database/README.md)。

## 当前条目

- [接口现状](./接口现状.md)

## 交叉引用

- `sendcmd` 下的配置表索引见 [Commands/sendcmd](../Commands/sendcmd.md#db)
- 软件层背景见 [Platform/软件架构](../Platform/软件架构.md)
- 研究笔记见 [Research/sendcmd社区命令收集](../Research/sendcmd社区命令收集.md)


# 接口现状

# 接口现状

## 当前判断

现有公开资料稳定证明的是：

- 存在 `sendcmd` / `sidbg` 这类配置访问入口
- 存在 XML 配置文件与配置表模型
- 可能存在私有 IPC 或管理总线

但以下结论目前不能直接下：

- 所有设备都使用标准 D-Bus
- `sendcmd` 就是 D-Bus 的直接命令行封装
- 对象、接口、方法、属性、信号可以统一抽象成同一套模型

## Evidence

C/D

## 交叉引用

- [../Platform/软件架构.md](../Platform/软件架构.md)
- [../Commands/sendcmd.md#db](../Commands/sendcmd.md#db)
- [../Research/sendcmd社区命令收集.md](../Research/sendcmd社区命令收集.md)
