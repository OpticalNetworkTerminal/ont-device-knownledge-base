# Database

本页用于整理华为光猫的配置文件、参数模型、XML、TR069、OMCI 等资料入口。

## 配置文件索引

| 对象 | 作用 | 当前状态 | 备注 |
| --- | --- | --- | --- |
| `hw_ctree.xml` | 社区最常见的运行配置文件对象 | `社区资料` `多源一致` `待实机验证` | 常用于超管、连接数、SSID、TR069 参数修改 |
| `hw_default_ctree.xml` | 默认配置或恢复比对对象 | `社区资料` `待实机验证` | 常与 `hw_ctree.xml` 对照使用 |
| `hw_boardinfo` | 设备标识与板级信息对象 | `社区资料` `待实机验证` | 常见于 `SN/MAC/模式` 修改场景 |
| `customizepara.txt` / `customizepara.xml` | 运营商定制参数对象 | `社区资料` `待实机验证` | 常用于恢复定制界面 |
| `choose*.xml` | 地区或界面选择相关对象 | `社区资料` `待实机验证` | 多见于高版本社区包 |

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

## 加解密索引

| 主题 | 说明 | 当前状态 | 主要来源 |
| --- | --- | --- | --- |
| `aescrypt2` | 社区常见的华为配置 AES 加解密命令 | `社区资料` `多源一致` `待实机验证` | GitHub、论坛 |
| `华为配置加解密工具` | Windows 图形工具，社区使用广泛 | `社区资料` `多源一致` `待实机验证` | ChinaDSL、博客、下载站 |
| `descrypt` | 已列为待研究主题，但当前缺乏稳定来源 | `社区资料` `待实机验证` | 待补充 |

## 协议索引

### TR069

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

- 关注点：
  - ONT 与 OLT 的管理兼容性
  - 厂商私有 ME
  - 换机或双模时的兼容问题
- 当前状态：`官方资料` `社区资料` `待实机验证`
- 主要来源：
  - https://support.huawei.com/enterprise/en/access-network/echolife-hg8245-pid-4977710
  - https://github.com/tripleoxygen/realtek-libohwtc

## 官方资料入口

- `HG8245`：https://support.huawei.com/enterprise/en/access-network/echolife-hg8245-pid-4977710
- `HG8245H`：https://support.huawei.com/enterprise/en/access-network/echolife-hg8245h-pid-8952133
- `HG8240`：https://support.huawei.com/enterprise/en/access-network/echolife-hg8240-pid-4977718

这些页面可确认产品资料页、维护指南、配置指南等入口存在，但具体命令是否对某个运营商定制固件开放，仍需实机确认。
