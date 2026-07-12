# telnet

## 功能

Telnet 是中兴 ONT 社区资料中最常见的维护登录入口之一。

## 已验证内容

- GitHub 项目 `zte_modem_tools` 明确实现了网页 factory mode 触发 Telnet 开关的逻辑。
- 社区资料可交叉验证 `TelnetCfg` 表常用于控制 LAN 侧 Telnet 开关、用户名、密码、最大连接数和插光后行为。

## 常见操作

```sh
sendcmd 1 DB p TelnetCfg
sendcmd 1 DB set TelnetCfg 0 Lan_Enable 1
sendcmd 1 DB set TelnetCfg 0 Lan_EnableAfterOlt 1
sendcmd 1 DB set TelnetCfg 0 InitSecLvl 3
sendcmd 1 DB save
```

社区资料中也常见：

```sh
sidbg 1 DB set TelnetCfg 0 TS_Enable 1
sidbg 1 DB set TelnetUser 0 Username root
sidbg 1 DB set TelnetUser 0 Password admin
sidbg 1 DB save
```

## 风险等级

高

## 验证状态

- 网页 factory mode 存在性：已验证
- 通过 `TelnetCfg` 修改：社区资料
- 不同型号插光后是否自动关闭 Telnet：社区资料

## 来源

- <https://github.com/douniwan5788/zte_modem_tools/blob/main/zte_factroymode.py>
- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.chinadsl.net/forum.php?action=printable&mod=viewthread&tid=126463>
