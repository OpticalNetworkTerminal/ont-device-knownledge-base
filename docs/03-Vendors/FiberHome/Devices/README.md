# Devices

本目录用于建设烽火光猫的型号索引，先给出系列入口、型号矩阵和验证状态，再逐步补充单型号细节。

## 系列索引

- [HG 系列](./HG系列.md)
- [AN 系列](./AN系列.md)

## 型号索引

| 系列 | 型号 | 定位 | 当前状态 | 主要来源 |
| --- | --- | --- | --- | --- |
| `HG` | `HG6145D2` | GPON + Wi-Fi 5 路由型 ONT | 已验证 | [官方产品页](https://en.fiberhome.com/TNOTN/20240126/46266.html) |
| `HG` | `HG6145F1` | GPON + Wi-Fi 6 路由型 ONT | 已验证 | [官方产品页](https://en.fiberhome.com/ONTsSeries/20240102/45830.html) |
| `HG` | `HG6145F3` | GPON + Wi-Fi 6 家庭网关 | 已验证 | [官方 PDF](https://en.fiberhome.com/u/cms/fhgj/202602/271653346lr1.pdf) |
| `HG` | `HG6543D` | GPON + Wi-Fi 5 路由型 ONT | 已验证 | [官方总览](https://en.fiberhome.com/ONTsSeries.html) |
| `HG` | `HG6142A` | GPON 路由型 ONT | 已验证 | [官方规格页](https://en.fiberhome.com/FASInformation/20240124/46083.html) |
| `AN` | `AN5506-01-A` | GPON bridging-type ONT | 已验证 | [官方产品页](https://en.fiberhome.com/ONTsSeries/20240130/46447.html) |
| `AN` | `AN5506-02-B` | GPON bridging-type ONT | 已验证 | [官方规格页](https://en.fiberhome.com/FASInformation/20240124/46083.html) |
| `AN` | `AN5506-04-FA` | 运营商定制常见型号 | 社区资料 / 研究资料 | [Pierre Kim 研究](https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html) |

## 记录模板

后续新增型号时，建议至少记录：

- 铭牌型号
- Web 显示型号
- 硬件版本
- 软件版本
- 运营商/地区
- 光接入类型
- `Web UI / OMCI / TR-069 / Telnet / SSH` 状态
- 已验证内容
- 待验证内容
