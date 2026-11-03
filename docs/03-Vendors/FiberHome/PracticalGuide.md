# Guides

本目录只放完整操作流程或操作主题，不放命令解释。

## 当前条目

- [恢复与升级](./恢复与升级.md)
- [桥接与 Mesh](./桥接与Mesh.md)

# 恢复与升级

# 恢复与升级

本页先作为操作索引页，沉淀恢复与升级的判断框架。

FiberHome 恢复与升级资料需要区分三类来源：官方远程升级能力、运营商本地页面是否开放、社区固件或下载区线索。

## 已验证内容

| 项目 | 结论 | 来源 |
| --- | --- | --- |
| `Reset` 行为 | 官方资料可见短按重启、长按恢复出厂模型 | [SR1041E](https://en.fiberhome.com/SmartRouter/20240125/46100.html) |
| 远程升级 | 新代 `HG` 型号明确支持远程软件升级 | [HG6145D2](https://en.fiberhome.com/TNOTN/20240126/46266.html) |

## 固件版本线索

| 型号 | 版本/线索 | 来源状态 | 来源 |
| --- | --- | --- | --- |
| `HG6245D` | `RP2602`、`RP2613` | 研究资料 | [Pierre Kim 研究](https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html) |
| `AN5506-04-F` | `RP2617` | 研究资料 | [GitHub Advisory](https://github.com/advisories/GHSA-hcfv-5p8h-vvh5) |
| `AN5506-01A` | `RP2511` | 研究资料 | [GitHub Advisory](https://github.com/advisories/GHSA-22m8-5g68-4439) |
| `HG6145F1` | `RP4423` | 研究资料 | [GitHub Advisory](https://github.com/advisories/GHSA-cg2x-c25f-6327) |
| `AN5506-04-FA` | `RP2627` | 研究资料 | [fiberhomesuperadmin](https://github.com/bkspc/fiberhomesuperadmin) |
| `HG6145D1` | `RP0303` | 社区资料 | [博客园记录](https://www.cnblogs.com/backuper/p/19022601) |
| `HG6145D` | 山西移动固件配置线索 | 社区资料 | [ChinaDSL 下载区](https://www.chinadsl.net/forum.php?fid=42&filter=typeid&mod=forumdisplay&orderby=lastpost&page=7&typeid=82) |
| `AN5506-04-A` | 三个版本固件线索 | 社区资料 | [ChinaDSL 下载区](https://www.chinadsl.net/archiver/fid-42.html?page=21) |

## 启动与文件系统线索

`AN5506-04-FA` bootlog 中可见 `U-Boot 2010.03-svn671412`、`Linux-2.6.34.10`、`rootfstype=jffs2`、`mtdparts`、`cfg` 分区和 A/B 镜像分区线索。这说明至少部分 `AN5506` 固件存在明确的 bootloader、kernel、rootfs、app 和配置区分层。

## 升级整理口径

- 官方资料中的“远程升级”应优先归入 `OMCI/TR-069` 管理链。
- 社区固件下载区只作为固件来源线索，需继续确认型号、运营商、地区和版本。
- 跨运营商固件、降级、配置区覆盖和 bootloader 变化属于高风险主题，应保留来源和版本边界。

## 待验证内容

- 各运营商固件是否保留本地升级入口
- 配置分区在恢复和升级后的保留策略
- 不同 `RP` 版本之间的兼容边界
- 固件包是否加密、是否签名、是否绑定运营商模板

## 来源

- [HG6145D2](https://en.fiberhome.com/TNOTN/20240126/46266.html)
- [SR1041E](https://en.fiberhome.com/SmartRouter/20240125/46100.html)
- [AN5506-04-FA bootlog](https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d)
- [Pierre Kim 研究](https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html)
- [fiberhomesuperadmin](https://github.com/bkspc/fiberhomesuperadmin)
- [ChinaDSL 固件区](https://www.chinadsl.net/forum.php?fid=42&filter=typeid&mod=forumdisplay&orderby=lastpost&page=7&typeid=82)

# 桥接与Mesh

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

# LED 与按键

# LED 与按键

本页先作为操作索引页，记录已验证指示灯集合和按键语义。

## 已验证内容

| 项目 | 结论 | 来源 |
| --- | --- | --- |
| `HG6145F3` 指示灯 | `Power/PON/LOS/Internet/Phone/USB/LAN/WLAN/WPS` | [官方 PDF](https://en.fiberhome.com/u/cms/fhgj/202602/271653346lr1.pdf) |
| `Reset/WPS` 按键 | `Reset` 短按重启、长按恢复出厂；`WPS` 长按启动协商 | [SR1041E](https://en.fiberhome.com/SmartRouter/20240125/46100.html) |

## 待验证内容

- `HG6145D2`、`HG6543D` 等机型的逐灯语义
- 运营商定制外壳与官方规格书之间的指示灯差异

# 超级管理员与运营商限制

# 超级管理员与运营商限制

本页先作为问题索引页，统一管理“超管、隐藏菜单、运营商裁剪、地区差异”这类高争议主题。

## 已验证内容

- 官方资料通常只公开 `OMCI / Web UI / TR-069` 等常规管理面，不公开超级管理员维护方式。
- 公开研究表明部分 FiberHome 固件存在隐藏管理面和高风险接口，但不能据此泛化到全部型号。

## 社区资料

以下内容保留为 `社区资料`，不得直接作为最终结论：

| 主题 | 现象 | 来源 |
| --- | --- | --- |
| `HG6145D/HG6145D1` | 涉及管理员密码、改省份、桥接、拆解、限制差异 | [恩山讨论](https://www.right.com.cn/forum/thread-8230876-27-1.html) |
| `HG6145F3` | 移动版替换光猫、Telnet、超管、桥接 | [恩山讨论](https://www.right.com.cn/forum/thread-8436021-1-1.html) |
| `HG6142A` | 涉及桥接、运营商限制、版本差异 | [恩山讨论](https://www.right.com.cn/forum/thread-8252962-1-1.html) |
| `HG3142F` | 联通版本管理员密码、工厂模式、`load_cli` | [恩山讨论](https://www.right.com.cn/forum/thread-8434746-1-1.html) |
| `HG6143D1` | 电信版本 Telnet 用户名、密码、超级用户讨论 | [恩山讨论](https://www.right.com.cn/forum/thread-8368395-1-1.html) |
| `AN5506` | 涉及逻辑 `SN`、LOID、替换光猫 | [恩山讨论](https://www.right.com.cn/forum/thread-8395440-1-1.html) |
| `HG6340A` | 株洲广电登录问题，Telnet 无法开启 | [ChinaDSL](https://www.chinadsl.net/thread-178004-1-1.html) |
| 固件/下载线索 | ChinaDSL 有 FiberHome 固件区线索 | [ChinaDSL](https://www.chinadsl.net/forum.php?fid=42&filter=typeid&mod=forumdisplay&orderby=replies&page=22&typeid=82) |

## 运营商维度

| 运营商 | 型号 | 常见限制主题 | 来源状态 |
| --- | --- | --- | --- |
| 中国移动 | `HG6145D/HG6145D1/HG6145F3` | 地区模板、桥接、Telnet、超管、配置模块 | 社区 |
| 中国联通 | `HG6142A/HG3142F/HG6543C` | 超管、桥接、工厂模式 | 社区 |
| 中国电信 | `HG6143D1` 等 | Telnet、超级用户、新版固件差异 | 社区 |
| 广电 | `HG6340A` | 登录问题、Telnet 不可开启 | 社区 |
| PLDT | `AN5506-04-FA RP2627` | 高级界面、串口控制台 | 研究/社区 |
| Algérie Télécom | `HG6145F1 RP4423` | 配置工具、默认密码/密码生成、漏洞研究 | 研究 |
| ViewQwest | `HG6240A` | 替换光猫讨论 | 社区 |

## 待验证

- 超级管理员账号、密码、菜单完整性是否与运营商模板绑定。
- 同型号不同 `RP` 版本之间，Telnet/隐藏页面/桥接页面是否一致。
- 运营商远程下发是否会覆盖本地桥接、地区、TR-069 和 Wi-Fi 配置。
- `HG6145F1 RP4423` 的阿尔及利亚资料是否适用于其它地区同型号。
