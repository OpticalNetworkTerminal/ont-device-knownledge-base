# AN 系列

本页先建立 `AN` 系列型号索引和操作关注点，重点围绕 `AN5506` 家族。

## 系列定位

`AN` 系列在公开家庭侧资料里多表现为桥接型或轻路由型 ONT，运营商定制差异通常比 `HG` 更明显。

## 型号索引

| 型号 | 官方定位 | 已验证内容 | 待验证内容 | 来源状态 |
| --- | --- | --- | --- | --- |
| `AN5506-01-A` | GPON bridging-type ONT | 支持 `OMCI / Web UI`、支持 `Bridged` 与 `Routed` 业务、支持 IPTV | 本地菜单细节、各运营商固件差异 | 官方资料 |
| `AN5506-02-B` | GPON bridging-type ONT | 2GE + 1POTS 规格 | 运营商菜单、桥接默认状态 | 官方资料 |
| `AN5506-04-FA` | 运营商定制常见型号 | 存在公开研究样本，代码基与其他 FiberHome 设备相近 | 固件版本差异、管理面差异 | 研究资料 |

## 操作索引

| 主题 | 当前结论 |
| --- | --- |
| 桥接 | 已验证能力模型存在 |
| 路由模式 | 已验证能力模型存在 |
| `OMCI` | 已验证 |
| `TR-069` | 不应默认假设所有 `AN` 页面都开放，但远端管理能力可能存在 |
| 超管/隐藏菜单 | 多为社区资料，待型号级验证 |
| `SN/MAC/LOID` | 社区讨论很多，暂不下最终结论 |

## 主要来源

- [AN5506-01-A](https://en.fiberhome.com/ONTsSeries/20240130/46447.html)
- [GPON no Wi-Fi ONT Product Specifications](https://en.fiberhome.com/FASInformation/20240124/46083.html)
- [Pierre Kim - FiberHome HG6245D / AN5506 analysis](https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html)
