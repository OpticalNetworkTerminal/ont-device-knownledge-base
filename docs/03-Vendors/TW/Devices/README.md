# Devices

本页维护天邑 TY/TEWA 系列型号索引。当前目标不是给出最终结论，而是先明确“哪些型号已出现资料、资料来自哪里、哪些线索能复用”。

## 型号索引

| 型号 | 资料状态 | 已知线索 | 主要来源 |
| --- | --- | --- | --- |
| TEWA-300 系列 | 待验证 | 老型号可通过 Telnet 工具与 `CUAdmin get` 取超密 | 恩山、ChinaDSL |
| TEWA-500E | 待验证 | 存在超管获取视频/帖子 | 社区资料 |
| TEWA-600 系列 | 待验证 | 老型号可通过 Telnet 工具进入 | 恩山 |
| TEWA-700E | 待验证 | 有 `dumpmdmd.conf` 直接导出超密的社区说法 | 博客、社区资料 |
| TEWA-700G | 待验证 | 可通过 `sessionKey + usbbackup.cmd` 导出配置 | 博客、社区资料 |
| TEWA-708E | 已验证 | `usbbackup.cmd`、`enableTelnet.html`、配置异或解密、`TeleComAccount` | GitHub、恩山 |
| TEWA-708G | 待验证 | U 盘备份配置、RouterPassView 提取超密 | 恩山 |
| TEWA-750 系列 | 待验证 | 新旧固件分代明显，后期需 `set3_sessionKey` 线索 | 恩山、ChinaDSL |
| TEWA-766E | 待验证 | 社区称 `sessionKey` 仍可从 Network 抓包中获得 | 恩山 |
| TEWA-768G | 待验证 | 与 708E/1000E 思路接近 | 恩山、ChinaDSL |
| TEWA-800E | 待验证 | 社区称可复用 `usbbackup.cmd` 思路 | GitHub README、社区资料 |
| TEWA-800G | 待验证 | 联通版曾被提到可通过 Telnet 工具处理 | 恩山、ChinaDSL |
| TEWA-872G | 已验证 | 可通过 `POST /setObjs` 开启 Telnet 的示例请求 | GitHub Issue |
| TEWA-1000E | 已验证 | Samba 提权、root shell、SSH、自启与 IPv6 防火墙线索 | GitHub Issue |
| TEWA-1000G | 待验证 | 超密/桥接经验较多，但缺少直接代码线索 | 社区资料 |
| TEWA-1006G | 待验证 | 社区整理了 Telnet -> `su` -> `telecomadmin get` 路径 | ChinaDSL |
| TEWA-1100E | 待验证 | 公开可检索资料较少，需后续补充 | 恩山列表页 |

## 型号分组

### 早期 TEWA 系列

- 代表线索: `TEWA-300/500/600/700/750`
- 社区共识:
  - 更偏向使用 Telnet 工具、`CUAdmin get`、或直读配置方式。
  - 固件早期版本的隐藏页面与导出入口更容易暴露。
- 状态:
  - 目前大多属于 `社区资料`，缺少公开固件或代码交叉验证。

### 708E/768G/800E/1000E 一类

- 代表线索:
  - `sessionKey`
  - `usbbackup.cmd`
  - 配置文件导出后提取 `TeleComAccount`
- 当前判断:
  - 这是最适合优先建设的公共方法族。
  - `TEWA-708E` 和 `TEWA-1000E` 公开资料最完整。

### 后期定制固件

- 代表线索:
  - `set2_sessionKey`
  - `set3_sessionKey`
  - F12 Network 抓包获取 key
  - `telandftpcfg.cmd`
- 当前判断:
  - 2021 年 7 月后出厂设备常出现入口收紧、页面隐藏更深的问题。
  - 适用范围很可能与运营商定制版本、软件版本、硬件版本同时相关。

## 已验证内容

- `TEWA-708E`: GitHub 项目可直接确认配置导出与解密思路。
- `TEWA-872G`: GitHub Issue 可直接确认 `setObjs` 请求示例。
- `TEWA-1000E`: GitHub Issue 可直接确认 Samba/SSH/IPv6 线索。

## 待验证内容

- `TY` 前缀型号与 `TEWA` 前缀型号之间的真实关系与命名映射。
- 各运营商定制版是否共用相同 Web 路径与对象树。
- 各型号 SoC、分区布局、数据库命令是否一致。

