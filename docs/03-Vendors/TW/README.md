# T&W / 天邑

本目录用于持续建设天邑（T&W）光猫知识库，当前阶段仅聚焦 `docs/03-Vendors/TW/`，不收录其它厂商内容。

## 建设原则

- 采用“持续完善”模式，不追求一次性收集完整资料。
- 优先建设目录结构、索引、状态标记与来源链路。
- 所有未经过实机验证的信息，统一标记为 `社区资料`，不得作为最终结论。
- 当多个来源出现冲突时，保留多种说法并注明来源，等待后续验证。

## 目录

- [Commands](./Commands/README.md): 命令索引与统一格式条目。
- [Devices](./Devices/README.md): 型号索引、平台差异、适用范围。
- [Operations](./Operations/README.md): Telnet、SSH、隐藏页、恢复、升级、桥接、Mesh、双模、SN/MAC/LOID 等操作索引。
- [Database](./Database/README.md): 配置文件、数据库、持久化路径与提取线索。

## 状态定义

- `已验证`: 当前至少满足以下其一
  - 可由公开代码/GitHub 页面直接确认。
  - 可由两个及以上独立社区来源交叉印证。
- `待验证`: 仅有单一来源、描述不完整、或未确认适用固件范围。
- `社区资料`: 来自论坛、博客、帖子、Issue、视频等公开经验，不等同于官方结论。
- `实机未验证`: 尚未在真实设备上复现。

## 当前收录重点

- TY/TEWA 系列型号索引。
- Telnet/SSH/Debug/隐藏页面入口。
- 配置备份、恢复、升级与数据库线索。
- 超级管理员、运营商限制、桥接、Mesh、双模相关经验。
- SN、MAC、LOID、命令与可持久化位置。

## 已验证内容

- `TEWA-708E` 的配置备份思路、`usbbackup.cmd` 入口、`enableTelnet.html` 页面、以及备份文件可通过异或还原的线索，可由 GitHub 项目 [`jonirrings/xor`](https://github.com/jonirrings/xor) 直接确认。
- `TEWA-872G` 存在通过 `setObjs` 写入 `InternetGatewayDevice.DeviceInfo.X_CMCC_ServiceManage.` 开启 Telnet 的社区线索，可由 GitHub Issue 页面直接读取请求示例。
- 天邑设备存在 `db_user_cfg.xml`、U 盘备份配置、`TeleComAccount` 字段、`sessionKey`/`set2_sessionKey`/`set3_sessionKey` 这类页面参数线索，已被多个社区帖子反复提及，但多数仍属于 `社区资料`。

## 待验证内容

- `telecomadmin get`、`CUAdmin get`、`sendcmd 1 DB saveasy` 等命令在不同型号/固件上的适用性。
- `hidden_version_switch.html`、`hidden_version_switch.gch`、`return2factory.gch`、`bridge_route.gch` 是否存在于具体天邑固件及哪些版本。
- SSH 持久化、自启脚本、`ommonitord` 替换、IPv6 防火墙持久化是否适用于全部 TY/TEWA 机型。
- Mesh、双模、运营商限制项在不同运营商定制固件中的显示与可修改范围。

## 主要来源

- 恩山无线论坛
- 宽带技术网 / ChinaDSL
- 52pojie
- GPL / 固件源码
- GitHub
- 拆机资料
- 官方资料

## 当前参考链接

- GitHub: [`jonirrings/xor`](https://github.com/jonirrings/xor)
- GitHub Issue: [`无su密码情况下获取root shell以及开放IPv6防火墙`](https://github.com/jonirrings/xor/issues/24)
- GitHub Issue: [`TEWA-872G开启telnet`](https://github.com/jonirrings/xor/issues/23)
- 恩山: [`破解电信天邑TEWA-768G/TEWA-708E/tewa-1000e光猫超级密码`](https://www.right.com.cn/forum/thread-4060480-24-1.html)
- 恩山: [`2021年7月后出厂电信天邑TEWA-750/708/768/800/1000等超级密码破解方法及工具`](https://www.right.com.cn/forum/thread-5128686-1-1.html)
- 恩山: [`TEWA系列获取超级密码以及宽带密码教程`](https://www.right.com.cn/forum/thread-8392663-1-1.html)
- ChinaDSL: [`天邑TEWA-1006G开启telnet方法/获取超级密码`](https://www.chinadsl.net/thread-177433-1-1.html)
- ChinaDSL: [`21年7月后出厂电信天邑750/708/768/800/1000等超密破解方法及工具`](https://www.chinadsl.net/thread-169557-1-1.html)
- 官方站点: [四川天邑康和通信股份有限公司](https://www.tianyisc.com/)
