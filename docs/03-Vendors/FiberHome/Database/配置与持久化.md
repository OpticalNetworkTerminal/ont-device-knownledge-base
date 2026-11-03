# 配置与持久化

本页先建立烽火配置与持久化索引，区分“已验证线索”和“社区资料线索”。

FiberHome 配置需要同时看三层：PON 管理链下发的业务参数、本地 Web UI 可见配置、文件系统或配置分区里的持久化数据。社区资料中很多“改完又恢复”“恢复出厂后仍被锁定”的现象，通常与这三层不同步有关。

## 已验证内容

| 项目 | 结论 | 来源 |
| --- | --- | --- |
| 配置分区 | 公开 bootlog 可见独立 `cfg` 分区 | [AN5506 bootlog](https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d) |
| 配置下发 | 新代 `HG` 官方明确支持 `OMCI/TR-069` 下发配置与升级 | [HG6145D2](https://en.fiberhome.com/TNOTN/20240126/46266.html) |
| Web 备份 | 存在导出配置文件的社区工具链 | [fiberhome-config-utility](https://github.com/numberonedz/fiberhome-config-utility) |

## 配置对象

| 对象 | 整理内容 | 适用型号 | 来源状态 |
| --- | --- | --- | --- |
| `cfg` 分区 | bootlog 中出现的独立配置分区 | `AN5506-04-FA` | 研究资料 |
| Web 导出配置文件 | 可被工具解密/重加密，说明配置文件存在封装或加密机制 | `HG6145F1 RP4423` | 研究资料 |
| `/flash/cfg/agentconf/` | 博客桥接记录中的配置目录 | `HG2543C1` | 社区资料 |
| `/flash/cfg/app_conf/` | 博客桥接记录中的配置目录 | `HG2543C1` | 社区资料 |
| `SoftwareModules` | 中国移动版配置片段线索 | `HG6145D1 RP0303` | 社区资料 |
| `com.cmcc.wuyougateway` | 中国移动网关功能模块线索 | `HG6145D1 RP0303` | 社区资料 |
| 逻辑 `SN` / `LOID` | 替换光猫讨论中出现 | `AN5506_01A2G` | 社区资料 |

## SN / MAC / LOID / Password

| 字段 | 整理说明 | 来源状态 |
| --- | --- | --- |
| `SN` | 可作为 PON 注册或资产绑定参数；社区中也出现“逻辑 SN”的说法 | 官方 + 社区 |
| `MAC` | 可能用于 Web UI、默认密码、运营商资产或 ACL 绑定，需按型号记录 | 待验证 |
| `LOID` | 国内运营商替换光猫讨论中高频出现 | 官方 + 社区 |
| `Password` | `HG8143F` PDF 线索显示设备支持 `Password` 或 `SN+Password` 认证组合 | 官方 |

`HG8143F` 官方 PDF 线索显示 FiberHome 设备可能支持 `SN`、`Password`、`SN+Password`、`LOID` 多种认证方式。不同运营商对字段名称、可见性和可写性的处理差异很大，后续应按“型号 + 运营商 + 地区 + 软件版本”记录。

## 社区资料

以下信息已见于社区资料，但暂不作为最终结论：

| 线索 | 当前状态 | 来源 |
| --- | --- | --- |
| `/flash/cfg/agentconf/` | 社区资料，待验证 | [桥接记录](https://blog.ningwang.me/posts/fiberhome-hg254c1-bridging/) |
| `/flash/cfg/app_conf/` | 社区资料，待验证 | [桥接记录](https://blog.ningwang.me/posts/fiberhome-hg254c1-bridging/) |
| 逻辑 `SN` 与 `LOID` 的映射关系 | 社区资料，待验证 | [恩山讨论](https://www.right.com.cn/forum/thread-8395440-1-1.html) |

## 待验证

- `/flash/cfg/agentconf/` 与 `/flash/cfg/app_conf/` 是否跨型号通用。
- `HG6145F1 RP4423` 配置工具是否适用于其它运营商固件。
- `HG6145D1 RP0303` 中 `SoftwareModules` 与移动定制功能的完整关系。
- 逻辑 `SN`、真实 `SN`、`LOID` 在 `AN5506_01A2G` 上的具体映射。

## 来源

- [AN5506-04-FA bootlog](https://gist.github.com/platkaw/926b7176714e02f3c729680584400f2d)
- [fiberhome-config-utility](https://github.com/numberonedz/fiberhome-config-utility)
- [HG2543C1 桥接记录](https://blog.ningwang.me/posts/fiberhome-hg254c1-bridging/)
- [HG6145D1 博客园记录](https://www.cnblogs.com/backuper/p/19022601)
- [AN5506_01A2G 恩山讨论](https://www.right.com.cn/forum/thread-8395440-1-1.html)
- [HG8143F PDF](https://en.fiberhome.com/u/cms/fhgj/202602/271653347y4r.pdf)
