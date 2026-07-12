# FiberHome

本目录用于建设烽火 `FiberHome` 光猫的长期维护型参考手册，采用“持续完善”模式，优先建设目录结构、索引和已验证内容。

## 当前建设优先级

1. 文档目录结构
2. 命令索引
3. 型号索引
4. 操作索引
5. 已验证内容
6. 待验证内容

## 收录范围

- 仅收录 `FiberHome / 烽火` 设备
- 重点覆盖 `HG` 系列、`AN` 系列
- 重点覆盖 `Telnet`、`SSH`、`Debug`、`TR-069`、`OMCI`、恢复、升级、桥接、Mesh、LED、超级管理员、运营商限制、`SN/MAC/LOID`、配置恢复、命令与数据库

## 资料分级

| 分级 | 定义 | 可否作为当前结论 |
| --- | --- | --- |
| `官方资料` | 官网产品页、规格书、官方 PDF | 可以 |
| `研究资料` | 安全研究、GPL/GitHub 工具仓库、公开逆向资料 | 可以，但需注明适用范围 |
| `社区资料` | 恩山、ChinaDSL、博客、论坛帖子 | 不得直接作为最终结论 |
| `待验证` | 单一来源或型号适用范围不清 | 不得作为最终结论 |

## 冲突信息处理规则

- 明确标记为 `社区资料`
- 不作为最终结论
- 保留多个观点并注明来源
- 后续等待实机验证后再升级状态

## 目录索引

### 总览

- [设备索引](./Devices/README.md)
- [命令索引](./Commands/README.md)
- [数据库索引](./Database/README.md)

### 设备

- [HG 系列](./Devices/HG系列.md)
- [AN 系列](./Devices/AN系列.md)

### 命令

- [Telnet](./Commands/Telnet.md)
- [SSH](./Commands/SSH.md)
- [Debug](./Commands/Debug.md)

### 操作

- [TR-069 与 OMCI](./TR069与OMCI.md)
- [恢复与升级](./恢复与升级.md)
- [桥接与 Mesh](./桥接与Mesh.md)
- [LED 与按键](./LED与按键.md)
- [超级管理员与运营商限制](./超级管理员与运营商限制.md)

### 数据

- [配置与持久化](./Database/配置与持久化.md)

## 当前已验证结论

- `HG` 系列普遍属于路由型家庭网关 ONT，官方长期公开 `OMCI / Web UI / TR-069` 管理面。
- `AN5506` 家族中常见型号偏桥接型或轻路由型 ONT，官方明确支持 `Bridged` 与 `Routed` 业务模型。
- 新代 `HG` 型号官方明确支持基于 `OMCI/TR-069` 的自动业务下发、远程管理和软件升级。

## 当前待验证方向

- 不同运营商固件中的 `Telnet/SSH` 暴露策略
- `SN/MAC/LOID` 页面与持久化映射
- `Mesh` 在各 `HG` 子型号中的真实开放范围
- 本地恢复后是否会被 `TR-069/OMCI` 完整回写

## 主要来源

- [FiberHome ONTs Series](https://en.fiberhome.com/ONTsSeries.html)
- [HG6145D2](https://en.fiberhome.com/TNOTN/20240126/46266.html)
- [HG6145F1](https://en.fiberhome.com/ONTsSeries/20240102/45830.html)
- [AN5506-01-A](https://en.fiberhome.com/ONTsSeries/20240130/46447.html)
- [GPON no Wi-Fi ONT Product Specifications](https://en.fiberhome.com/FASInformation/20240124/46083.html)
- [Pierre Kim - FiberHome HG6245D / AN5506 analysis](https://pierrekim.github.io/blog/2021-01-12-fiberhome-ont-0day-vulnerabilities.html)
