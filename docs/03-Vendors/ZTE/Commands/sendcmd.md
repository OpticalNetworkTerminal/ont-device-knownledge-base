# sendcmd

## 功能

`sendcmd` 是 ZTE 社区资料中最常见的维护命令入口之一，主要用于：

- 查询配置数据库
- 修改配置数据库
- 保存配置
- 查看调试/PCB/任务信息
- 在部分社区样本中执行配置文件解密

## 语法

社区公开样本中常见形式：

```sh
sendcmd 1 DB all
sendcmd 1 DB p <表名>
sendcmd 1 DB set <表名> <行号> <字段名> <字段值>
sendcmd 1 DB save
sendcmd 1 p all
sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml
```

## 参数

- `1`：社区资料中最常见的目标/实例编号，含义待进一步验证。
- `DB`：数据库子命令。
- `all`：列出表或全部对象，具体输出格式待补。
- `p`：打印指定表或对象。
- `set`：修改字段值。
- `save`：保存当前改动。
- `decry`：社区资料中用于对配置文件执行设备侧解密。

## 返回值

- 待验证。不同机型/固件的输出格式可能不同。

## 示例

```sh
sendcmd 1 DB p TelnetCfg
sendcmd 1 DB set TelnetCfg 0 Lan_Enable 1
sendcmd 1 DB set DevAuthInfo 0 Pass admin
sendcmd 1 DB save
sendcmd 1 p all
```

## 适用型号

- 已确认广泛见于 ZTE ONT 社区资料
- 具体到哪些型号/版本默认开放，仍需逐机型记录

## 风险等级

高

原因：

- 可直接修改认证、管理口、网络和 PON 相关参数
- 错误写入后可能导致无法登录、业务中断、无法注册

## 验证状态

- `DB 查询/修改/save`：已验证，来自多个社区来源交叉印证
- `p all` 调试输出：社区资料
- `decry`：社区资料，已有 GitHub issue 与论坛样本，但尚未实机验证

## 已公开命令分类索引

| 分类 | 示例 | 状态 |
| --- | --- | --- |
| DB | `sendcmd 1 DB all` | 已验证 |
| DB 查询 | `sendcmd 1 DB p TelnetCfg` | 已验证 |
| DB 修改 | `sendcmd 1 DB set DevAuthInfo 0 Pass admin` | 已验证 |
| DB 保存 | `sendcmd 1 DB save` | 已验证 |
| DB 解密 | `sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml` | 社区资料 |
| PCB/调试 | `sendcmd 1 p all` | 社区资料 |

## 来源

- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.chinadsl.net/thread-174301-1-1.html>
- <https://www.chinadsl.net/thread-179762-1-1.html>
- <https://github.com/mkst/zte-config-utility/issues/153>
