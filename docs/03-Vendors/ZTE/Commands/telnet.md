# telnet

## 功能

Telnet 在 ZTE ONT 语境里既是维护入口，也是很多 `sendcmd` / `sidbg` 操作的前提环境。本页只回答 Telnet 入口本身是什么、常见字段是什么、风险在哪里；具体启用步骤见 [Guides/开启Telnet](../Guides/开启Telnet.md)。

## Evidence

- 网页工厂模式可关联 Telnet 开关：B
- `TelnetCfg` 作为核心配置表：B/C
- `Lan_EnableAfterOlt` 等细分字段：C
- `TelnetUser` 表：C

## 常见字段

| 字段 | 常见含义 | Evidence |
| --- | --- | --- |
| `TS_Enable` | Telnet 总开关 | C |
| `Wan_Enable` | WAN 侧 Telnet 开关 | C |
| `Lan_Enable` | LAN 侧 Telnet 开关 | B/C |
| `TS_Port` | Telnet 端口 | C |
| `TSLan_Port` | LAN Telnet 端口 | C |
| `TS_UName` / `TS_UPwd` | 一组账号密码 | C |
| `TSLan_UName` / `TSLan_UPwd` | LAN 侧账号密码 | C |
| `Max_Con_Num` | 最大连接数 | C |
| `Lan_EnableAfterOlt` | 插光注册后是否保持 LAN Telnet | C |

## 常见命令关联

```sh
sendcmd 1 DB p TelnetCfg
sendcmd 1 DB set TelnetCfg 0 Lan_Enable 1
sendcmd 1 DB save
```

```sh
sidbg 1 DB set TelnetCfg 0 TS_Enable 1
sidbg 1 DB set TelnetUser 0 Username root
sidbg 1 DB save
```

## 风险

风险等级：高

原因：

- 一旦 WAN 侧误开放，可能形成远程暴露面
- 账号、密码、权限级别改错后可能影响登录
- 不同运营商版本可能在插光后重新覆盖或关闭 Telnet

## 适用范围

- 适合作为 ZTE 维护入口参考
- 不适合作为“所有机型一键开启方法”的统一结论

## 交叉引用

- 操作步骤见 [Guides/开启Telnet](../Guides/开启Telnet.md)
- 相关配置表见 [Database/配置表索引](../Database/配置表索引.md)
- 运营商差异见 [Platform/运营商定制](../Platform/运营商定制.md)
- 未验证样本见 [Research/高权限账户与工厂模式](../Research/高权限账户与工厂模式.md)
