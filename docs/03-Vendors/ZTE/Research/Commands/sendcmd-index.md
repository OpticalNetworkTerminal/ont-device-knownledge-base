# sendcmd Index

本页只收录公开出现过的 `sendcmd` 命令样本。

## Evidence 说明

- A：官方/GPL 直接出现
- B：源码/固件/多源分析
- C：多个社区来源一致
- D：单一帖子、截图或博客

## 命令样本索引

| 命令样本 | 模型/范围 | 运营商 | Evidence | 首次命中来源 |
| --- | --- | --- | --- | --- |
| `sendcmd 1 DB all` | F660/泛 ZXHN | 未区分 | C | ChinaDSL `ZXHN F660 Telnet设置代码大全` |
| `sendcmd 1 DB p all` | F660/泛 ZXHN | 未区分 | C | ChinaDSL / 恩山转载版 |
| `sendcmd 1 DB p DBBase` | F660/泛 ZXHN | 未区分 | C | ChinaDSL / 恩山转载版 |
| `sendcmd 1 DB p WAND` | F660/泛 ZXHN | 未区分 | C | ChinaDSL / 恩山转载版 |
| `sendcmd 1 DB p WANCD` | F660/泛 ZXHN | 未区分 | C | ChinaDSL / 恩山转载版 |
| `sendcmd 1 DB p WANC` | F660/F7610M/G7615 等 | 电信/移动/未区分 | C | 恩山常用命令帖 |
| `sendcmd 1 DB p WANCServList` | F660/泛 ZXHN | 未区分 | C | ChinaDSL 代码大全 |
| `sendcmd 1 DB p WANCIP` | F660/泛 ZXHN | 未区分 | C | ChinaDSL 代码大全 |
| `sendcmd 1 DB p WANCPPP` | F660/泛 ZXHN | 未区分 | C | ChinaDSL 代码大全 |
| `sendcmd 1 DB p LAND` | F660/泛 ZXHN | 未区分 | C | ChinaDSL 代码大全 |
| `sendcmd 1 DB p BrGrp` | F660/泛 ZXHN | 未区分 | C | ChinaDSL 代码大全 |
| `sendcmd 1 DB p DevInfo` | G7615/F7607P/泛 ZXHN | 未区分 | C | 本地研究稿 |
| `sendcmd 1 DB p DevAuthInfo` | 多型号 | 电信/移动/联通/未区分 | C | 多社区 |
| `sendcmd 1 DB p TelnetCfg` | 多型号 | 电信/移动/联通/未区分 | C | 多社区 |
| `sendcmd 1 DB p PortControl` | F460/F660 | 电信/未区分 | C | GitHub Gist / 社区 |
| `sendcmd 1 DB p MgtServer` | 多型号 | 电信 | C | 恩山常用命令帖 |
| `sendcmd 1 DB p CltLmt` | F412/F460/F660 | 电信 | C | ChinaDSL |
| `sendcmd 1 DB p FWBase` | 多型号 | 未区分 | C | 恩山修改连接数帖 |
| `sendcmd 1 DB p PDTCTUSERINFO` | F7610M 等 | 移动 | C | ChinaDSL |
| `sendcmd 1 DB p WLANCfg` | F7610M 等 | 移动 | C | ChinaDSL |
| `sendcmd 1 DB p WLCInfo` | G7615/F7607P 研究稿 | 未区分 | C | 本地研究稿 |
| `sendcmd 1 DB p FTPUser` | 未指明 | 未区分 | D | `zte-router-0day-rce` |
| `sendcmd 1 DB p VoIPSIPLine all` | 未指明 | 未区分 | D | `zte-router-0day-rce` |
| `sendcmd 1 DB set DevAuthInfo 0 User telecomadmin` | 多型号 | 电信 | C | 恩山常用命令帖 |
| `sendcmd 1 DB set DevAuthInfo 0 Pass nE7jA%5m` | 多型号 | 电信 | C | 恩山常用命令帖 |
| `sendcmd 1 DB set DevAuthInfo 1 Level 1` | F7610M/多型号 | 移动/未区分 | C | ChinaDSL |
| `sendcmd 1 DB set DevAuthInfo 1 Level 2` | 多型号 | 电信 | C | 恩山常用命令帖 |
| `sendcmd 1 DB set TelnetCfg 0 TS_Enable 1` | F460/F660/多型号 | 电信/未区分 | C | Gist / 社区 |
| `sendcmd 1 DB set TelnetCfg 0 Lan_Enable 1` | G7615/F460/F660/多型号 | 移动/电信/未区分 | C | 多社区 |
| `sendcmd 1 DB set TelnetCfg 0 Wan_Enable 0` | 多型号 | 未区分 | C | 本地研究稿 |
| `sendcmd 1 DB set TelnetCfg 0 Lan_EnableAfterOlt 1` | G7615 类 | 移动/未区分 | C | ChinaDSL/研究稿 |
| `sendcmd 1 DB set TelnetCfg 0 TS_UName root` | 多型号 | 未区分 | C | 本地研究稿 |
| `sendcmd 1 DB set TelnetCfg 0 TS_UPwd zte123` | F460/F660 | 电信/未区分 | C | GitHub Gist |
| `sendcmd 1 DB set TelnetCfg 0 TSLan_UPwd ooxx` | F7610M | 移动 | C | ChinaDSL |
| `sendcmd 1 DB set PortControl 3 PortEnable 1` | F460/F660 | 电信/未区分 | C | GitHub Gist |
| `sendcmd 1 DB set MgtServer 0 URL http://127.0.0.1` | 多型号 | 电信 | C | 恩山常用命令帖 |
| `sendcmd 1 DB set MgtServer 0 Tr069Enable 0` | 多型号 | 电信 | C | 恩山常用命令帖 |
| `sendcmd 1 DB set MgtServer 0 PeriodicInformEnable 0` | 多型号 | 电信 | C | 恩山常用命令帖 |
| `sendcmd 1 DB set WANC x ServList 8` | 多型号 | 电信 | C | 恩山安全删除 TR069 端口帖 |
| `sendcmd 1 DB set WANC x StrServList OTHER` | 多型号 | 电信 | C | 恩山安全删除 TR069 端口帖 |
| `sendcmd 1 DB delr WANC 0` | 多型号 | 电信 | C | 恩山常用命令帖 |
| `sendcmd 1 DB set CltLmt 8 Max 9` | F412/F460/F660 | 电信 | C | ChinaDSL |
| `sendcmd 1 DB set CltLmt 8 Enable 0` | F412/F460/F660 | 电信 | C | ChinaDSL |
| `sendcmd 1 DB set FWBase 0 FwConnMaxEnable 0` | 多型号 | 未区分 | C | 恩山修改连接数帖 |
| `sendcmd 1 DB set FWBase 0 FwConntrackMax 65535` | 多型号 | 未区分 | C | 恩山修改连接数帖 |
| `sendcmd 1 DB set FWBase 0 ConntrackMax 65535` | 多型号 | 未区分 | C | 恩山修改连接数帖 |
| `sendcmd 1 DB set PDTCTUSERINFO 0 Status 0` | F7610M/多型号 | 移动 | C | ChinaDSL |
| `sendcmd 1 DB set PDTCTUSERINFO 0 Result 1` | F7610M/多型号 | 移动 | C | ChinaDSL |
| `sendcmd 1 DB set PDTCTUSERINFO 0 tForcePushFlg 0` | 多型号 | 电信/移动 | C | 恩山/ChinaDSL |
| `sendcmd 1 DB set WLANCfg 0 ESSIDPrefix \"\"` | F7610M | 移动 | C | ChinaDSL |
| `sendcmd 1 DB set WLANCfg 4 ESSIDPrefix \"\"` | F7610M | 移动 | C | ChinaDSL |
| `sendcmd 1 DB set WLCInfo 0 WLCStatus 0` | G7615/F7607P 研究稿 | 未区分 | C | 本地研究稿 |
| `sendcmd 1 DB set WLCInfo 0 WLCStatus 1` | G7615/F7607P 研究稿 | 未区分 | C | 本地研究稿 |
| `sendcmd 1 DB save` | 多型号 | 全运营商/未区分 | C | 多社区 |
| `sendcmd 1 DB saveasy` | 老资料/旧固件 | 未区分 | D | 本地研究稿旧样本 |
| `sendcmd 1 DB reboot` | 多型号 | 电信/未区分 | C | 恩山常用命令帖 |
| `sendcmd 1 DB rreset` | 多型号 | 未区分 | C | 本地研究稿 |
| `sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml` | F680/F6600R/多型号 | 未区分 | C | GitHub issue |
| `sendcmd 1 p all` | 泛 ZXHN | 未区分 | D | 旧研究稿/社区零散提及 |
| `sendcmd 1 -task` | 泛 ZXHN | 未区分 | D | 本地研究稿 |
| `sendcmd 1 -socket` | 泛 ZXHN | 未区分 | D | 本地研究稿 |

## 备注

- 上表是“出现记录索引”，不是“可直接执行的最终命令参考”。
- 相同命令在不同型号中的字段、行号、是否持久化都可能不同。
