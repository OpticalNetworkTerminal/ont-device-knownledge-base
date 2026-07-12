# HG 系列

本页先建立 `HG` 系列型号索引和能力索引，后续再逐步拆分到单型号页。

## 系列定位

`HG` 系列是烽火最常见的家庭网关型 ONT 家族，通常集成以太网、Wi-Fi、语音和远程运维能力。

## 型号索引

| 型号 | 官方定位 | 已验证内容 | 待验证内容 | 来源状态 |
| --- | --- | --- | --- | --- |
| `HG6145D2` | GPON + Wi-Fi 5 路由型 ONT | `OMCI / Web UI / TR-069`、远程升级、IPv4/IPv6 | `Telnet/SSH`、运营商菜单裁剪差异 | 官方资料 |
| `HG6145F1` | GPON + Wi-Fi 6 路由型 ONT | `OMCI / Web UI / TR-069`、远程升级 | 配置导出兼容性、Mesh 开放范围 | 官方资料 + 研究资料 |
| `HG6145F3` | GPON + Wi-Fi 6 家庭网关 | 指示灯集合、USB/WPS、远程运维 | 运营商固件功能裁剪 | 官方资料 |
| `HG6543D` | GPON + Wi-Fi 5 路由型 ONT | 系列存在性与定位 | 超管页面、桥接开放方式 | 官方资料 |
| `HG6142A` | GPON 路由型 ONT | 无 Wi-Fi 规格、4GE + POTS | 社区提到的运营商限制 | 官方资料 + 社区资料 |

## 能力索引

| 能力 | 当前结论 |
| --- | --- |
| `Web UI` | 已验证，普遍存在 |
| `OMCI` | 已验证，官方长期公开 |
| `TR-069` | 已验证，新代型号普遍存在 |
| 桥接 | 能力模型存在，但是否开放依赖运营商 |
| Mesh | 仅可在部分新代 Wi-Fi 型号上谨慎预期，待逐型号验证 |
| `Telnet` | 社区资料较多，不能泛化为所有 HG 机型 |
| `SSH` | 公开度低，默认视为待验证 |

## 主要来源

- [HG6145D2](https://en.fiberhome.com/TNOTN/20240126/46266.html)
- [HG6145F1](https://en.fiberhome.com/ONTsSeries/20240102/45830.html)
- [HG6145F3 PDF](https://en.fiberhome.com/u/cms/fhgj/202602/271653346lr1.pdf)
- [ONTs Series](https://en.fiberhome.com/ONTsSeries.html)
- [GPON no Wi-Fi ONT Product Specifications](https://en.fiberhome.com/FASInformation/20240124/46083.html)
