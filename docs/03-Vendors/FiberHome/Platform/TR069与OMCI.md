# TR-069 与 OMCI

本页先作为操作索引页，记录已验证管理链和待验证问题。

在 FiberHome ONT 上，`OMCI` 与 `TR-069/CWMP` 是理解运营商定制差异的核心。很多本地 Web UI 中的桥接、升级、远程管理、语音、IPTV、Wi-Fi 和地区模板，可能来自这两条管理链的下发或回写。

## 已验证内容

| 项目 | 结论 | 来源 |
| --- | --- | --- |
| `HG6145D2` | 支持基于 `OMCI/TR-069` 的自动业务下发、管理和软件远程升级 | [官方产品页](https://en.fiberhome.com/TNOTN/20240126/46266.html) |
| `HG6145F1` | 支持基于 `OMCI/TR-069` 的自动业务下发、管理和软件远程升级 | [官方产品页](https://en.fiberhome.com/ONTsSeries/20240102/45830.html) |
| `AN5506-01-A` | 支持基于 `OMCI` 的自动业务下发、管理和远程升级 | [官方产品页](https://en.fiberhome.com/ONTsSeries/20240130/46447.html) |

## 管理面整理

| 管理面 | 作用 | FiberHome 资料状态 |
| --- | --- | --- |
| `OMCI` | PON 侧业务开通、VLAN、性能、告警、远程升级 | 官方资料稳定出现 |
| `TR-069/CWMP` | IP 管理侧 ACS、远程配置、配置文件、升级、状态上报 | 新代 `HG` 与部分 CPE/Router 资料出现 |
| `Web UI` | 本地用户/维护界面 | 各运营商裁剪差异大 |
| APP / 云平台 | 家庭路由器或组网设备管理 | `SR1041F` 等资料出现 |

## 与配置恢复的关系

- 本地恢复出厂只会重置设备本地状态，不一定阻止运营商重新下发业务模板。
- 桥接或路由模式可能由 `OMCI` 模板、`TR-069` ACS 或本地 Web UI 共同影响。
- `HG6145D2` 官方资料中的 XML 配置文件传送线索，说明远程管理与本地配置备份可能同时存在。
- 如果设备重新注册后菜单或配置被恢复，应优先检查 `OMCI/TR-069` 回写，而不是只检查本地 Web UI。

## 标准参考

| 标准/资料 | 作用 |
| --- | --- |
| Broadband Forum `TR-069` | CWMP 远程管理协议 |
| Broadband Forum `TR-156` | GPON 接入架构参考 |
| CWMP Data Models | TR-069 设备数据模型 |

## 待验证内容

- 不同运营商是否开放本地 ACS 状态页
- 恢复出厂后远端回写的完整范围
- `AN` 系列上 `TR-069` 的实际暴露方式
- `TR-069` XML 配置文件在不同 `HG` 固件中的格式和兼容性

## 来源

- [HG6145D2](https://en.fiberhome.com/TNOTN/20240126/46266.html)
- [HG6145F1](https://en.fiberhome.com/ONTsSeries/20240102/45830.html)
- [AN5506-01-A](https://en.fiberhome.com/ONTsSeries/20240130/46447.html)
- [SR1041F](https://en.fiberhome.com/SmartRouter/20240125/46099.html)
- [Broadband Forum TR-069](https://www.broadband-forum.org/pdfs/tr-069-1-6-0.pdf)
- [Broadband Forum TR-156](https://www.broadband-forum.org/pdfs/tr-156-4-0-0.pdf)
