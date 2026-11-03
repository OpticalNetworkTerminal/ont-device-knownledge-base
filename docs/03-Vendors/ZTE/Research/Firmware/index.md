# Firmware Index

本页只收录固件、Bootloader、升级包、版本号、下载线索。

| ID | 型号/系列 | 版本/标签 | 来源类型 | Evidence | 备注 |
| --- | --- | --- | --- | --- | --- |
| FW-001 | ZXHN F660 | `V5.0` | 官方文档地图 | A | 文档版本，不等于固件版本 |
| FW-002 | ZXHN F680 | `V2.0` | 官方文档地图 | A | 文档版本 |
| FW-003 | ZXHN H196A | `V9.1` | 官方文档地图 | A | 文档版本 |
| FW-004 | ZXHN H199A | `V7.0` | 官方文档地图 | A | 文档版本 |
| FW-005 | ZXHN H388X V10 | `V7.0` | 官方文档地图 | A | 文档版本 |
| FW-006 | ZXHN F670 | `V1.1.10P3T18` / `V1.1.10P3T22` | ZTE PSIRT | A | 安全公告直接出现 |
| FW-007 | ZXA10 F660 V3 OEM | `V2.30.20P5T4S` / `V2.30.20P8T8S` | OpenWrt Bootlog | B | OEM bootlog 中出现 |
| FW-008 | F660/F460/F620/F420 v3 U-Boot | `Stable_v1.2` ~ `Stable_v1.4.2` | GitHub Releases | B | 社区 Bootloader 发布 |
| FW-009 | G7615 联通版 | `V2.0.5P1N12_20230307` | ChinaDSL 下载区 | C | 含 Bootloader 的社区升级包线索 |

## 升级/恢复线索关键词

- `config.bin`
- `db_user_cfg.xml`
- `db_default_auto_cfg.xml`
- `tftp -p`
- `tftp -g`
- `upgradetest getver`
- `upgradetest sdefconf`
- `return2factory.html`

## 待补

- Web 升级包文件名
- 各运营商定制版本号
- 是否校验地区码/运营商签名
- 恢复分区与主备分区线索
