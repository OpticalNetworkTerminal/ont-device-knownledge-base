# Models Index

本页只做型号研究索引，不做型号总结。

| 型号 | 来源类型 | Evidence | 已知上下文 |
| --- | --- | --- | --- |
| ZXHN F2801S | 官方文档地图 | A | User-End Device |
| ZXHN F2866 | 官方文档地图 | A | User-End Device |
| ZXHN F2866S | 官方文档地图 | A | User-End Device |
| ZXHN F600W | 官方文档地图 + GitHub config 样本 | A/B | `zte-config-utility` 资源中有 `F600W.bin` |
| ZXHN F612 | 官方文档地图 | A | User-End Device |
| ZXHN F660 | 官方文档地图 + FCC + OpenWrt | A/B | GPON ONT；F660 v3 存在 Marvell/OpenWrt 线索 |
| ZXHN F6600R | GitHub issue | C | `sendcmd 1 DB decry` 讨论 |
| ZXHN F670E | FCC | A | GPON ONT |
| ZXHN F671Y | 官方文档地图 | A | User-End Device |
| ZXHN F680 | 官方文档地图 + GitHub issue | A/C | 社区大量 `db_user_cfg.xml` 讨论 |
| ZXHN F680V9 | FCC | A | GPON ONT |
| ZXHN F7005MV3 | 本地研究稿/社区 | C | `sendcmd` 适用范围中出现 |
| ZXHN F7015TV3 | 本地研究稿/社区 | C | `sendcmd` 适用范围中出现 |
| ZXHN F7607P | 本地研究稿/社区 | C | `TelnetCfg`/`setmac` 实测类资料较多 |
| ZXHN F7610M | ChinaDSL | C | 临时/永久 Telnet、地区码、TFTP、配置解密 |
| ZXHN G1612 | ChinaDSL | C | `sidbg 1 DB decry` 讨论 |
| ZXHN G7615 | 设备目录 + ChinaDSL | C | 移动/联通资料、`setmac`、TelnetCfg |
| ZXHN H60G | 恩山 | C | `sidbg`/桥接/超密资料 |
| ZXHN H188A | 官方文档地图 | A | User-End Device |
| ZXHN H196A | 官方文档地图 + FCC | A | TR-069 / TR-098 线索 |
| ZXHN H196Q | 官方文档地图 | A | User-End Device |
| ZXHN H199A | 官方文档地图 | A | User-End Device |
| ZXHN H268Q | 官方文档地图 + GitHub config 样本 | A/B | `zte-config-utility` 有 DB 样本 |
| ZXHN H298A | 官方文档地图 + GitHub config 样本 | A/B | `config.bin` 支持样本 |
| ZXHN H298Q | GitHub config 样本 | B | `db_default_auto_cfg.xml` 样本 |
| ZXHN H388X V10 | 官方文档地图 | A | Home Gateway/FTTR 相关线索 |
| ZXHN H389Q | 官方文档地图 | A | User-End Device |
| ZXHN H6645P V2 | GitHub issue | C | `TelnetCfg ProcType/Level` 样本 |
| ZXHN HX3-4sProLite | ChinaDSL/恩山 | C | CMCC 资料、AP/Mesh、Telnet 线索 |

## 来源池

- 官方文档地图：<https://support.zte.com.cn/support/docmap/00000455/en/product.html>
- FCC：<https://fccid.io/>
- GitHub：<https://github.com/mkst/zte-config-utility>
- 社区：恩山、ChinaDSL、OpenWrt Forum
