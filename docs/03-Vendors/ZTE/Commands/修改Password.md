# 修改Password

## 功能

修改 Web 管理或 Telnet 登录密码。

## 语法

社区资料常见样本：

```sh
sendcmd 1 DB set DevAuthInfo 0 Pass admin
sendcmd 1 DB save
sidbg 1 DB set TelnetUser 0 Password admin
sidbg 1 DB save
```

## 适用范围

- `DevAuthInfo`：常见于 Web 管理账户
- `TelnetUser`/`TelnetCfg`：常见于 Telnet 账户

## 风险等级

高

## 验证状态

社区资料

## 来源

- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.right.com.cn/forum/thread-8237756-1-1.html>
