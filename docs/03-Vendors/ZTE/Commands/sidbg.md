# sidbg

## Evidence

C

## 功能

`sidbg` 是社区资料中常见的另一类 ZTE 调试/数据库访问入口，很多用法与 `sendcmd` 相近。

## 当前定位

- 作为 `sendcmd` 的并列入口保留
- 重点记录它“在哪里出现、典型语法是什么、和 `sendcmd` 有什么关系”
- 不再把 `sidbg` 单独扩写成一整套重复的 Telnet / TR-069 / 桥接指南

## 语法

```sh
sidbg 1 DB p all
sidbg 1 DB p TelnetCfg
sidbg 1 DB set DevAuthInfo 0 User CMCCAdmin
sidbg 1 DB set TelnetCfg 0 TS_Enable 1
sidbg 1 DB save
```

## 参数

- `1`：社区样本中的实例编号，准确语义待验证
- `DB`：数据库操作域
- `p`：打印
- `set`：修改
- `save`：保存

## 返回值

- 待验证

## 示例

```sh
sidbg 1 DB p TelnetCfg
sidbg 1 DB set TelnetUser 0 Username root
sidbg 1 DB set TelnetUser 0 Password admin
sidbg 1 DB save
```

## 适用型号

- 社区资料显示见于部分中兴 ONT
- 与 `sendcmd` 的覆盖面是否完全一致，待验证
- 社区中存在“`sendcmd not found`，但 `sidbg` 可用”的说法

## 与 sendcmd 的关系

- 两者都常用于访问“表 + 行 + 字段”的配置数据库模型
- `TelnetCfg`、`DevAuthInfo`、`TelnetUser` 等对象在两套命令样本中都出现过
- 若要看更完整的主题整理，优先参考 [sendcmd](./sendcmd.md)

## 风险等级

高

## 验证状态

社区资料

说明：

- 目前主要依据论坛样本
- 尚未看到足够官方资料说明 `sidbg` 的正式定位

## 来源

- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.right.com.cn/forum/thread-8237756-1-1.html>
