# Devices

本页整理天邑 TY / TEWA 系列的正式型号索引。这里不要求每个结论都来自官方单一文档，但会尽量把官方、运营商、GitHub、论坛与拆机资料汇总成可维护的设备谱系。

## 型号总览

| 型号 | 定位/线索 | 运营商/渠道 | 资料完整度 | 备注 |
| --- | --- | --- | --- | --- |
| TEWA-300RI | 早期 WLAN/终端认证记录 | 未知 | 低 | 目前主要见于认证记录 |
| TEWA-700G | 早期 GPON/家庭网关社区样本 | 未知 | 低 | 常见于旧教程与拆机帖子 |
| TEWA-707G | 社区求助帖较多 | 未知 | 中 | `set3_sessionKey` 与 `telandftpcfg.cmd` 线索 |
| TEWA-708E | 资料最集中 | 中国电信 | 高 | `sessionKey`、U 盘备份、CFG 解密 |
| TEWA-708G | 与 708E 同代的社区样本 | 中国电信 | 中 | 常见于超密/备份讨论 |
| TEWA-709V | 资料较少 | 未知 | 低 | 主要见于 GitHub issue 列表 |
| TEWA-7100A | 社区列表出现 | 未知 | 低 | 缺少进一步样本 |
| TEWA-7500V | 新代双频/移动样本 | 浙江移动 | 低 | 社区提到双固件或双配置 |
| TEWA-766E V2 | WiFi6 + 光猫拆机样本 | 未确认 | 中 | 社区称使用 BCM68252 |
| TEWA-766G | 新款天翼样本 | 中国电信 | 中 | `set3_sessionKey`、RouterPassView |
| TEWA-768G | 与 708E/1000E 方法接近 | 中国电信 | 中 | 已出现 CFG -> XML 线索 |
| TEWA-800E | 联通样本较常见 | 中国联通 | 中 | 桥接与权限资料零散 |
| TEWA-861G | 官方中标型号 | 中国移动 | 中 | GPON WiFi5 固定库 |
| TEWA-870G | 官方中标型号 | 中国移动 | 中 | GPON WiFi6 固定库 |
| TEWA-872G | GitHub 已知可写对象开 Telnet | 中国移动 | 中 | `X_CMCC_ServiceManage` |
| TEWA-1000E | 研究资料最丰富的高价值机型之一 | 中国电信 | 高 | root shell、Samba、SSH、IPv6 |
| TEWA-1000G | 官方产品页可见 | 通用/运营商 | 中 | XG-PON 网关 |
| TEWA-1006G | 社区给出较完整 Telnet 链路 | 中国电信 | 中 | `telecomadmin get` |
| TEWA-1008V | 官方英文规格书 | 海外/通用 | 中 | XG-PON + Wi-Fi 6 |
| TEWA-1100E | 资料仍偏少 | 未知 | 低 | 待补样本 |
| TEWA-1100G | 新代拆机资料出现 | 中国电信 | 中 | 社区存在“中兴版”说法 |

## 谱系观察

### 早期 TEWA 机型

常见于 `300/500/600/700/750` 一类资料中，特点是：

- 更容易出现直接读取超密、Telnet 工具或旧式隐藏页教程。
- 社区更常提到 `CUAdmin get`、旧版超管算法、或文件导出方法。
- 公开源码与官方产品资料偏少，很多结论仍停留在社区经验层。

### 708E / 768G / 1000E 方法族

这一组是当前最值得优先建设的天邑知识主线：

- 共享 `sessionKey`、U 盘备份、CFG 导出、配置提取这条资料链。
- 至少一部分型号存在 `enableTelnet.html`、`usbbackup.cmd`、配置异或解密等共同特征。
- `TEWA-1000E` 在此基础上还发展出 Samba 挂根目录、自建 SSH、IPv6 放行等高级玩法。

### 2021 年后新定制机型

社区经常把天邑设备按 2020 年前后、2021 年 7 月前后做分代，新的现象包括：

- `sessionKey` 更难直接从 HTML 源码中拿到。
- 需要从浏览器开发者工具的 `Network`、`Sources` 中找 `set2_sessionKey` 或 `set3_sessionKey`。
- `telandftpcfg.cmd` 一类路径被更频繁提到。
- 运营商定制对桥接、组网、IPv6、隐藏页展示的影响更明显。

## 运营商维度

### 中国电信

目前资料最多，主力机型包括：

- `TEWA-708E`
- `TEWA-708G`
- `TEWA-766G`
- `TEWA-768G`
- `TEWA-1000E`
- `TEWA-1006G`
- `TEWA-1100G`

常见主题：

- 超级管理员密码提取
- U 盘配置备份
- Telnet / SSH
- 桥接修改
- IPv6、TR-069 与运营商模板覆盖

### 中国移动

当前较明确的机型与线索：

- `TEWA-861G`
- `TEWA-870G`
- `TEWA-872G`

特征：

- `TEWA-872G` 的对象路径中直接出现 `X_CMCC_ServiceManage`
- 官方中标公告能确认产品与运营商关系

### 中国联通

当前最清晰的社区样本是：

- `TEWA-800E`

该系列更多体现为：

- 联通现场换装
- 用户需要桥接或提升权限
- 具体隐藏页、命令和配置模板资料仍较零散

## 重点机型

### TEWA-708E

- 当前天邑资料最成熟的入门机型之一。
- 已知主线包括 `sessionKey`、`usbbackup.cmd`、`enableTelnet.html`、`ctce8_TEWA-708E.cfg` 与 `TeleComAccount`。
- 适合作为 CFG 备份、超管提取、隐藏页研究的基准样本。

### TEWA-872G

- 已知存在通过 `POST /setObjs` 直接写对象开 Telnet 的路径。
- 这是目前天邑资料里较少见、偏“对象树管理”的样本。
- 对移动定制对象模型、TR-069 / TR-181 风格对象树的研究价值较高。

### TEWA-1000E

- 当前最适合研究高权限链路的机型。
- 公开资料包括：
  - 受限 Telnet 环境
  - `;` 触发 root 现象
  - Samba 共享根目录
  - 写入 `/opt/upt/apps/ssh/`
  - 运行 `start_ssh.sh`
  - 修改 IPv6 防火墙
- 适合作为“天邑 Linux 运行时与持久化结构”样本。

## 待验证

- `TY`、`TYT`、`TEWA` 等命名前缀的真实产品谱系关系。
- `TEWA-1100G` 的“中兴版”说法是否对应共同 ODM/OEM 结构，还是仅为贴纸或定制批次差异。
- `TEWA-766E V2` 的 `BCM68252` 与相关 SoC 平台是否能扩展到同代更多型号。
- 同名型号在不同运营商下是否存在完全不同的软件分支。

## 来源

- 官方产品页与中标公告
- 天邑公司公告与年报
- GitHub / Gitee
- 恩山无线论坛
- ChinaDSL
- 拆机与社区逆向资料
- 详细原始来源见 [Research/Models](../Research/Models/README.md)
