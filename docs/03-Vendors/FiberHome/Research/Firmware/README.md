# Firmware

本页是固件研究索引，不做刷机教程。

## 固件/版本索引

| 型号 | 运营商 | 地区 | 版本 | 发布日期 | Bootloader | Kernel | Rootfs / Filesystem | 加密/签名 | 升级方式线索 | 下载地址/来源 | Evidence | 最后收集时间 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `HG6245D` | 未标注 | 未标注 | `RP2602` | 2019-04-01 生成时间见研究页 | 未标注 | 未标注 | 未标注 | 未标注 | 研究页提及固件样本 | https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html | B | 2026-07-12 |
| `HG6245D` | 未标注 | 未标注 | `RP2613` | 2021-02-07 研究更新 | 未标注 | 未标注 | 未标注 | 未标注 | 研究页提及最新固件仍受影响 | https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html | B | 2026-07-12 |
| `AN5506-04-F` | 未标注 | 未标注 | `RP2617` | 2021-12-17 公开漏洞收录 | 未标注 | 未标注 | 未标注 | 未标注 | GitHub Advisory / NVD | https://github.com/advisories/GHSA-hcfv-5p8h-vvh5 | B | 2026-07-12 |
| `AN5506-01A` | 未标注 | 未标注 | `RP2511` | 2025-02-24 | 未标注 | 未标注 | 未标注 | 未标注 | GitHub Advisory / 漏洞页 | https://github.com/advisories/GHSA-22m8-5g68-4439 | B | 2026-07-12 |
| `HG6145F1` | Algérie Télécom | 阿尔及利亚 | `RP4423` | 2025-11-12 漏洞数据库发布时间 | 未标注 | 未标注 | Web 配置文件可导出 | 存在加密配置文件工具线索 | Web 导出配置文件 | https://github.com/advisories/GHSA-cg2x-c25f-6327 | B | 2026-07-12 |
| `HG6145F1` | Algérie Télécom | 阿尔及利亚 | `RP4423` | 未标注 | 未标注 | 未标注 | 配置文件支持加解密工具 | 存在自定义加密封装线索 | Web 导出配置文件 | https://github.com/numberonedz/fiberhome-config-utility | B | 2026-07-12 |
| `AN5506-04-FA` | PLDT | 菲律宾 | `RP2627` | 未标注 | 未标注 | 未标注 | 未标注 | 未标注 | 串口/控制台研究仓库 | https://github.com/bkspc/fiberhomesuperadmin | B | 2026-07-12 |
| `AN5506-04-FA` | 未标注 | 未标注 | 样本文件名 `AN5506_04F1A.img/.bin` | 2018-09-06 bootlog 收录时间 | `U-Boot 2010.03-svn671412` | `Linux-2.6.34.10` | `JFFS2` | 未标注 | USB 启动时尝试升级镜像文件 | https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d | B | 2026-07-12 |
| `HG6145D` | 中国移动 | 山西移动 | 未标注 | 2020-09-04 帖子日期 | 未标注 | 未标注 | “固件配置”帖子线索 | 未标注 | ChinaDSL 下载区线索 | https://www.chinadsl.net/forum.php?fid=42&filter=typeid&mod=forumdisplay&orderby=lastpost&page=7&typeid=82 | C | 2026-07-12 |
| `AN5506-04-A` | 未标注 | 未标注 | 三个版本固件 | 未标注 | 未标注 | 未标注 | 未标注 | 未标注 | ChinaDSL 下载区线索 | https://www.chinadsl.net/forum.php?fid=42&filter=typeid&mod=forumdisplay&orderby=heats&page=12&typeid=82 | C | 2026-07-12 |

## 固件研究待补字段

- bootloader 交互命令
- kernel config 线索
- rootfs 导出方法
- 配置文件版本兼容关系
- 官方升级包下载入口
