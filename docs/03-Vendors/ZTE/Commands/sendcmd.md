# sendcmd

## 功能

`sendcmd` 是当前 ZTE 研究中最核心的维护命令入口之一，公开资料显示它常被用于：

- 查询配置数据库
- 修改配置数据库
- 保存配置
- 触发重启或恢复类动作
- 查看部分调试信息
- 在部分资料中处理配置文件解密

## Evidence

- `DB all / p / set / save`：B/C
- `DB reboot / DB rreset`：C
- `DB decry`：C
- `p all`、`-task`、`-socket` 等调试分支：D

说明：

- 本页优先吸收你提供的昨天资料，再结合仓库中已有社区来源做交叉整理。
- 没有统一写成“所有机型都支持”，而是按命令分支分别标注 Evidence。

## 语法

公开资料中高频出现的形式：

```sh
sendcmd 1 DB all
sendcmd 1 DB p <table>
sendcmd 1 DB set <table> <row> <field> <value>
sendcmd 1 DB delr <table> <row>
sendcmd 1 DB save
sendcmd 1 DB reboot
sendcmd 1 DB rreset
sendcmd 1 DB decry <path>
sendcmd 1 p all
```

## 参数

| 参数 | 说明 | Evidence |
| --- | --- | --- |
| `1` | 常见实例编号，准确语义未统一确认 | C |
| `DB` | 配置数据库操作域 | B/C |
| `all` | 列出数据库表或对象 | B/C |
| `p` | 打印指定表或对象 | B/C |
| `set` | 修改字段值 | B/C |
| `delr` | 删除指定行，风险极高 | C |
| `save` | 保存当前改动 | B/C |
| `reboot` | 通过数据库命令触发重启 | C |
| `rreset` | 恢复出厂相关动作 | C |
| `decry` | 设备侧解密配置文件 | C |

## 分类索引

| 分类 | 典型命令 | 用途 | Evidence |
| --- | --- | --- | --- |
| DB 枚举 | `sendcmd 1 DB all` | 看有哪些表 | B/C |
| DB 查询 | `sendcmd 1 DB p TelnetCfg` | 查看记录与字段 | B/C |
| DB 修改 | `sendcmd 1 DB set DevAuthInfo 0 Pass xxx` | 改配置 | B/C |
| DB 删除 | `sendcmd 1 DB delr <table> <row>` | 删除记录 | C |
| DB 保存 | `sendcmd 1 DB save` | 持久化改动 | B/C |
| DB 重启 | `sendcmd 1 DB reboot` | 重启设备 | C |
| DB 恢复 | `sendcmd 1 DB rreset` | 恢复出厂相关动作 | C |
| DB 解密 | `sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml` | 处理配置文件 | C |
| 调试输出 | `sendcmd 1 p all` | 观察调试信息 | D |

## 返回值

当前没有形成跨型号统一的返回值规范。实践上应把 `sendcmd` 看成“读本机输出”的命令，而不是“输出固定格式”的命令。

## 风险

风险等级：高

高风险原因：

- 能直接改认证、管理口、网络与 PON 相关数据
- `delr`、`rreset`、错误 `set` 都可能导致无法登录、断网、配置损坏
- 表名、字段名、行号不保证跨型号一致

## 示例

只读类：

```sh
sendcmd 1 DB all
sendcmd 1 DB p DevInfo
sendcmd 1 DB p TelnetCfg
```

修改类：

```sh
sendcmd 1 DB set TelnetCfg 0 Lan_Enable 1
sendcmd 1 DB set DevAuthInfo 0 Pass 'new-password'
sendcmd 1 DB save
```

恢复类：

```sh
sendcmd 1 DB reboot
sendcmd 1 DB rreset
```

## 适用范围

- 已知广泛见于 ZTE ONT 社区资料
- 是否默认开放、是否能通过 Web / Telnet / 串口拿到入口，仍需按设备目录记录
- 与 `sidbg` 的关系目前看是“高度相似但不保证等价”

## 交叉引用

- 配置表请看 [Database/配置表索引](../Database/配置表索引.md)
- 结构化索引请看 [Database/sendcmd-command-index.yaml](../Database/sendcmd-command-index.yaml)
- 未升级命令收集请看 [Research/sendcmd社区命令收集](../Research/sendcmd社区命令收集.md)
- 如何开启相关入口请看 [Guides/开启Telnet](../Guides/开启Telnet.md)

## 来源

- 用户提供资料：`/Users/jonhy/Downloads/zte-ont-telnet-sendcmd-command-reference-v2.md`
- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.chinadsl.net/thread-174301-1-1.html>
- <https://www.chinadsl.net/thread-179762-1-1.html>
- <https://github.com/mkst/zte-config-utility/issues/153>
