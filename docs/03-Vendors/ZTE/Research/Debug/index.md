# Debug Index

本页收录维护入口、调试入口、恢复入口、隐藏页面与低层接口线索。

| 条目 | Evidence | 已见上下文 | 主要来源 |
| --- | --- | --- | --- |
| Telnet | B/C | `TelnetCfg`、`telnet.gch`、factory mode | GitHub + 社区 |
| sidbg | C | `sidbg 1 DB p/set/save/decry` | 恩山 + ChinaDSL |
| sendcmd | B/C | `DB`、`p all`、`decry`、`rreset` | GitHub + 社区 |
| setmac | C | SN/MAC/LOID/PON 模式位 | 本地研究稿 |
| upgradetest | C | `getver`、`sdefconf` 地区码切换 | 本地研究稿 + ChinaDSL |
| UART / TTL | A/B | OpenWrt Wiki 串口、FCC 内部照片 | OpenWrt + FCC |
| TFTP | C | 配置传输、恢复线索 | ChinaDSL |
| FTP | C/D | `FTPUser`、`FTPServerCfg`、`sendcmd` 样本 | GitHub + ChinaDSL |
| Web shell | C | `/web_shell_cmd.gch` | ChinaDSL |
| Telnet CGI | C | `/telnet.gch` | ChinaDSL |
| 恢复出厂页面 | C | `/return2factory.html` | ChinaDSL |
| Bootlog | B | OEM / OpenWrt bootlog | OpenWrt Wiki |
| `debug-decry-cfg` | C | decry 输出目录 | GitHub issue + ChinaDSL |

## 低层资料直接入口

- OpenWrt F660 raw page：<https://openwrt.org/_export/raw/toh/zte/zxa10f660>
- F660 刷机博客：<https://catzy007.github.io/loader.html?post=2023-07-22-flashing-openwrt-onto-zte-zxa10-f660-v3>
