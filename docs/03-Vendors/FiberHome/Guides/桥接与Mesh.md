# 桥接与 Mesh

本页先作为操作索引页，避免把桥接和 Mesh 混为一谈。

桥接是 WAN 业务承载模式，Mesh 是 Wi-Fi 组网能力。两者可能同时出现在家庭网关上，但属于不同功能域。

## 已验证内容

| 项目 | 结论 | 来源 |
| --- | --- | --- |
| `AN5506-01-A` | 官方明确支持 `Bridged` 与 `Routed Internet Service` | [官方产品页](https://en.fiberhome.com/ONTsSeries/20240130/46447.html) |
| FiberHome 家庭组网 | 官方明确提供 mesh networking solution | [Smart Home](https://en.fiberhome.com/SmartHome.html) |

## 桥接

FiberHome 官方资料中，`AN5506-01-A` 明确支持 `Bridged` 与 `Routed Internet Service`。社区资料中，`HG6145D/HG6145D1/HG6145F3/HG6142A/HG6543C` 等型号经常出现“改桥接”“隐藏桥接页面”“运营商限制”“远程回写”等主题。

整理桥接资料时应分开记录：

- 设备能力是否支持桥接
- Web UI 是否显示桥接入口
- 当前登录账号是否能修改桥接
- `TR-069/OMCI` 是否会回写 WAN 配置
- IPTV、VoIP、远程管理是否依赖原 WAN 绑定
- 改动对应的运营商、地区、软件版本

## Mesh / EasyMesh

官方资料已经确认以下型号或资料存在 EasyMesh / `802.11k/v/r` 线索：

| 型号 | 整理内容 | 来源 |
| --- | --- | --- |
| `SR1041F` | `Supports Wi-Fi Easy Mesh and 802.11k/v/r` | [官方产品页](https://en.fiberhome.com/SmartRouter/20240125/46099.html) |
| `SR1021F` | PDF 线索含 EasyMesh 与 `802.11k/v/r` | [官方 PDF](https://en.fiberhome.com/u/cms/fhgj/202602/2716553333k1.pdf) |
| `SR3141M` | PDF 线索含 EasyMesh | [官方 PDF](https://en.fiberhome.com/u/cms/fhgj/202602/27165533i2te.pdf) |
| `HG8143F` | PDF 线索含 `Support easymesh` | [官方 PDF](https://en.fiberhome.com/u/cms/fhgj/202602/271653347y4r.pdf) |

`HG6145F1/HG6145F3/HG6543D/HG6145D2` 是否实际开放 EasyMesh，仍需按运营商固件验证。

## 待验证内容

- 哪些 `HG` 子型号真正开放 `EasyMesh`
- 运营商固件对桥接页面的裁剪范围
- 桥接修改后是否被 `TR-069/OMCI` 回写
- Mesh 页面是否仅出现在路由器 `SR` 系列，而非所有 ONT

## 来源

- [AN5506-01-A](https://en.fiberhome.com/ONTsSeries/20240130/46447.html)
- [FiberHome Smart Home](https://en.fiberhome.com/SmartHome.html)
- [SR1041F](https://en.fiberhome.com/SmartRouter/20240125/46099.html)
- [HG6145F3 移动版替换资料](https://www.right.com.cn/forum/thread-8436021-1-1.html)
- [HG6142A 恩山讨论](https://www.right.com.cn/forum/thread-8252962-1-1.html)
- [HG2543C1 桥接记录](https://blog.ningwang.me/posts/fiberhome-hg254c1-bridging/)
