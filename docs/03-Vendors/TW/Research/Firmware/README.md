# Firmware

## 固件/版本索引

| 型号 | 运营商 | 地区 | 版本/线索 | 发布日期 | Bootloader | Kernel | Rootfs | Filesystem | 是否加密 | 升级方式 | 恢复方式 | 下载地址/来源 | Evidence | 最后收集时间 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TEWA-708E | 中国电信 | 中国 | 社区提到软件版本 `1.0.2`、硬件版本 `1.0` | 社区资料 | 未知 | 未知 | 未知 | 配置备份导出 `ctce8_TEWA-708E.cfg` | 配置文件为 `xor 0xff`，非整机固件 | Web + U 盘备份 | 未知 | https://github.com/jonirrings/xor | B | 2026-07-12 |
| TEWA-708/1000 一类 | 中国电信 | 中国 | 恩山帖按 `2020年4月前`、`2020年8月后` 区分 | 2021 帖中回顾 | 未知 | 未知 | 未知 | 未知 | 未知 | Web + Telnet 工具 | 未知 | https://www.right.com.cn/forum/thread-5128686-1-1.html | C | 2026-07-12 |
| TEWA-766E V2 | 未确认 | 中国 | 2023 年出厂 | 2024-04-02 帖子 | 未知 | 未知 | 未知 | 未知 | 未知 | 未知 | 未知 | https://www.chinadsl.net/thread-176965-1-1.html | D | 2026-07-12 |
| TEWA-766G | 中国电信 | 中国 | 社区教程涉及 `set3_sessionKey` 时代的新款 | 2022-05-20 | 未知 | 未知 | 未知 | U 盘备份 | 未知 | Web 隐藏页 | 未知 | https://www.chinadsl.net/thread-171770-1-1.html | C | 2026-07-12 |
| TEWA-768G | 中国电信 | 中国 | `ctce8_TEWA-768G.cfg` | 2021-11-11 | 未知 | 未知 | 未知 | CFG->XML 线索 | CFG 可转 XML | U 盘备份 | 未知 | https://github.com/jonirrings/xor/issues/19 | C | 2026-07-12 |
| TEWA-1000E | 中国电信 | 中国 | 2024 root shell / SSH 讨论 | 2024-04-01 起 | 未知 | BusyBox v1.28.3 时间戳 `2021-08-12` | 未知 | `/opt/upt/apps`、`/var/samba` 等路径 | 未知 | 自建 SSH、可能可导出 CFG | 重启后 SSH 不自启，需额外处理 | https://github.com/jonirrings/xor/issues/24 | B | 2026-07-12 |
| TEWA-1000G | 未知 | 中国 | 官方产品页 | 官方当前在线 | 未知 | 未知 | 未知 | 未知 | 未知 | 官方升级方式未见公开 | 未知 | https://www.tianyisc.com/product-view.aspx?id=86&t=15 | A | 2026-07-12 |
| TEWA-1008V | 通用/海外 | 未知 | 官方英文规格书 | 2025-02-13 页面可见 | 未知 | 未知 | 未知 | 未知 | 未知 | 未知 | 未知 | https://en.tianyisc.com/Uploadfiles/Files/2025-2-13/20252131539243478.pdf | A | 2026-07-12 |

## 固件研究缺口

| 主题 | 状态 | Evidence | 备注 |
| --- | --- | --- | --- |
| 官方 GPL 下载入口 | 未发现公开下载页 | D | 已检索官网公开页面，暂未定位明确 GPL 发布库 |
| Bootloader 类型 | 未分类 | D | 需后续拆包/串口日志 |
| 完整升级包样本 | 未收集 | D | 需后续样本库 |
| 文件系统类型 | 仅从路径侧面观察到 BusyBox/Linux 风格 | C | 待固件样本确认 |

