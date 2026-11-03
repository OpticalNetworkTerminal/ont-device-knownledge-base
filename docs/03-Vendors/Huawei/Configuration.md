# Database

本页用于整理华为光猫的配置文件、参数模型、XML、TR069、OMCI、固件结构与相关工具。与 [Guides](../Guides/README.md) 相比，这里更关注“对象本身”，而不是“从哪个入口进入设备”。

## 核心结论

- `hw_ctree.xml` 是当前资料池中最常见的运行配置对象。
- `hw_default_ctree.xml`、`hw_boardinfo`、`customizepara.*`、`choose*.xml` 常用于解释模板、地区、运营商定制与恢复行为。
- 配置文件常与 `gzip`、`aescrypt2`、额外 header/checksum 一起出现。
- `TR069` 与 `OMCI` 是理解“为什么本地修改不生效”以及“为什么换机后不兼容”的两个关键背景。

## 配置文件索引

| 对象 | 作用 | 当前状态 | 备注 |
| --- | --- | --- | --- |
| `hw_ctree.xml` | 社区最常见的运行配置文件对象 | `社区资料` `多源一致` `待实机验证` | 常用于超管、连接数、SSID、TR069 参数修改 |
| `hw_default_ctree.xml` | 默认配置或恢复比对对象 | `社区资料` `待实机验证` | 常与 `hw_ctree.xml` 对照使用 |
| `hw_boardinfo` | 设备标识与板级信息对象 | `社区资料` `待实机验证` | 常见于 `SN/MAC/模式` 修改场景 |
| `customizepara.txt` / `customizepara.xml` | 运营商定制参数对象 | `社区资料` `待实机验证` | 常用于恢复定制界面 |
| `choose*.xml` | 地区或界面选择相关对象 | `社区资料` `待实机验证` | 多见于高版本社区包 |

## 配置对象之间的关系

基于当前资料，比较稳妥的理解方式如下：

- `hw_ctree.xml`：偏向当前运行配置或可导出的主配置对象。
- `hw_default_ctree.xml`：偏向默认模板或恢复时的对照对象。
- `hw_boardinfo`：偏向设备标识、板级参数与模式信息。
- `customizepara.*`：偏向运营商定制层。
- `choose*.xml`：偏向地区、模式或界面分支选择。

这些对象并不是在所有机型上都同时出现，但它们构成了华为光猫配置体系里最常见的一组“高频名字”。

## XML 关注字段

| 字段/节点 | 典型用途 | 当前状态 | 来源说明 |
| --- | --- | --- | --- |
| `X_HW_WebUserInfo` | Web 账户列表 | `社区资料` `多源一致` `待实机验证` | 超管读取、新增账号 |
| `UserName="telecomadmin"` | 超级管理员账号线索 | `社区资料` `多源一致` `待实机验证` | 常见于电信定制资料 |
| `Password="..."` | 账号密码存储字段 | `社区资料` `多源一致` `待实机验证` | 可能为明文、`$2`、`PassMode=2` |
| `UserLevel="0"` | 社区普遍视为高权限级别 | `社区资料` `待实机验证` | 需分固件确认 |
| `PassMode` | 密码存储方式线索 | `社区资料` `待实机验证` | 常与密文/明文切换相关 |
| `TotalTerminalNumber` | 连接数限制 | `社区资料` `多源一致` `待实机验证` | 常用于设备接入上限修改 |
| `X_HW_AssociateNum` | Wi-Fi 接入终端数 | `社区资料` `待实机验证` | 常见于高版本社区资料 |
| `RegulatoryDomain` | 地区码 | `社区资料` `待实机验证` | 常与信道/区域限制相关 |
| `X_HW_UserInfo` | 用户注册信息 | `社区资料` `待实机验证` | 常与 LOID / ITMS 排障相关 |

## XML 字段整理建议

在实际维护中，最值得优先看的往往不是所有节点，而是下面几组：

- 账户权限组：`X_HW_WebUserInfo`、`UserName`、`Password`、`UserLevel`、`PassMode`
- 接入限制组：`TotalTerminalNumber`、`X_HW_AssociateNum`
- 地区模板组：`RegulatoryDomain`、`choose*.xml`
- 注册信息组：`X_HW_UserInfo`、`LOID`、`SN`、`MAC`

如果只是想快速判断一台设备“被锁在哪里”，通常先看：

1. 是否存在超管或高权限账号节点
2. 是否存在地区/运营商模板差异
3. 是否存在 TR069/ACS 参数
4. 是否存在 SN/LOID 一类注册字段

## 加解密索引

| 主题 | 说明 | 当前状态 | 主要来源 |
| --- | --- | --- | --- |
| `aescrypt2` | 社区常见的华为配置 AES 加解密命令 | `社区资料` `多源一致` `待实机验证` | GitHub、论坛 |
| `华为配置加解密工具` | Windows 图形工具，社区使用广泛 | `社区资料` `多源一致` `待实机验证` | ChinaDSL、博客、下载站 |
| `descrypt` | 已列为待研究主题，但当前缺乏稳定来源 | `社区资料` `待实机验证` | 待补充 |

## 加解密链路

当前资料中能整理出的典型链路是：

- 导出配置文件
- 视情况跳过额外 header/checksum
- 使用 `aescrypt2` 解密
- 对 XML 再做 `gzip` 解压
- 修改节点后反向处理
- 回传并重启

从现有资料看，真正需要小心的不是“能不能解密”，而是：

- 某个机型是否使用相同 key
- 是否带额外 header/checksum
- 回传后是否会被固件拒绝
- 修改后是否会被 TR069 或模板回写

## 协议索引

### TR069

- 定位：远程管理与配置下发链路，社区最常把它与“修改后被覆盖”联系在一起。
- 关注点：
  - 远程下发配置
  - 超管密码被覆盖
  - 路由/桥接模式被恢复
  - ACS 连接状态与管理 VLAN
- 当前状态：`官方资料` `社区资料` `待实机验证`
- 主要来源：
  - https://support.huawei.com/enterprise/zh/doc/EDOC1100268440/36cd3722
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://delxu.wordpress.com/2012/08/19/hg8240%E7%94%B5%E4%BF%A1%E5%85%89%E7%8C%AB%E7%A6%81%E7%94%A8tr069%E4%B9%8B%E4%BF%AE%E6%94%B9%E9%85%8D%E7%BD%AE%E6%B3%95/

### OMCI

- 定位：ONT 与 OLT 的管理与兼容性链路，社区最常把它与“换机兼容性”和“双模”联系在一起。
- 关注点：
  - ONT 与 OLT 的管理兼容性
  - 厂商私有 ME
  - 换机或双模时的兼容问题
- 当前状态：`官方资料` `社区资料` `待实机验证`
- 主要来源：
  - https://support.huawei.com/enterprise/en/access-network/echolife-hg8245-pid-4977710
  - https://github.com/tripleoxygen/realtek-libohwtc

## 固件与文件系统线索

研究资料目前能给出如下高价值线索：

- `HG8012H` 启动日志显示 `U-Boot 2010.03`
- Linux 版本至少出现过 `2.6.34.10_sd5115v100_wr4.3`
- 文件系统明确出现过 `squashfs` 与 `jffs2`
- `/mnt/jffs2` 是社区资料高频路径

这意味着：即使不同机型的 Web、TR069、模板层完全不同，它们底层仍然有较强的嵌入式 Linux 家族相似性。

## 官方资料入口

- `HG8245`：https://support.huawei.com/enterprise/en/access-network/echolife-hg8245-pid-4977710
- `HG8245H`：https://support.huawei.com/enterprise/en/access-network/echolife-hg8245h-pid-8952133
- `HG8240`：https://support.huawei.com/enterprise/en/access-network/echolife-hg8240-pid-4977718

这些页面可确认产品资料页、维护指南、配置指南等入口存在，但具体命令是否对某个运营商定制固件开放，仍需实机确认。

## 待验证

- `hw_ctree.xml.enc` 是否是独立存在的常见对象，还是社区命名习惯。
- `descrypt` 到底对应独立工具、脚本，还是社区误记。
- `choose*.xml` 在高版本机型中的准确职责。
- `hw_boardinfo` 中与 `SN/MAC/模式` 直接关联的字段映射。
- 不同机型对配置 header/checksum 的要求是否一致。

## 来源

- 华为官方资料页
- Huawei Research：`Config`、`Firmware`、`GPL`、`TR069`、`OMCI`
- 恩山、ChinaDSL、52pojie
- GitHub：`AESCrypt2`、`Hacking_Huawei_HG8012H_ONT`、`FuckingHuaweiHG8321R`
