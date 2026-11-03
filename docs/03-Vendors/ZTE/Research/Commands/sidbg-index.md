# sidbg Index

本页保留 `sidbg` 公开样本。

| 命令样本 | 型号/范围 | Evidence | 来源 |
| --- | --- | --- | --- |
| `sidbg 1 DB p all` | 泛 ZXHN | C | 恩山 `中兴光猫telnet后，可以使用哪些命令` |
| `sidbg 1 DB p TelnetCfg` | 泛 ZXHN | C | 恩山 |
| `sidbg 1 DB p DevAuthInfo` | 泛 ZXHN | C | 恩山 |
| `sidbg 1 DB set DevAuthInfo 0 User CMCCAdmin` | 移动定制 | C | 恩山 |
| `sidbg 1 DB set DevAuthInfo 0 Pass aDm8H%MdA` | 移动定制 | C | 恩山 |
| `sidbg 1 DB set TelnetCfg 0 TS_Enable 1` | H60G/HX3/G1612 等 | C | 恩山 + ChinaDSL |
| `sidbg 1 DB set TelnetCfg 0 Lan_Enable 1` | H60G/HX3/G1612 等 | C | 恩山 + ChinaDSL |
| `sidbg 1 DB set TelnetUser 0 Username root` | 泛 ZXHN | C | 恩山 |
| `sidbg 1 DB set TelnetUser 0 Password admin` | 泛 ZXHN | C | 恩山 |
| `sidbg 1 DB set TelnetUser 1 Username root` | 泛 ZXHN | C | 恩山 |
| `sidbg 1 DB set TelnetUser 1 Password admin` | 泛 ZXHN | C | 恩山 |
| `sidbg 1 DB save` | 泛 ZXHN | C | 恩山 |
| `sidbg 1 DB decry /userconfig/cfg/db_user_cfg.xml` | G1612 | C | ChinaDSL |

## 备注

- 社区里存在“没有 `sendcmd` 但能用 `sidbg`”的说法，已保留在 Community 索引中。
