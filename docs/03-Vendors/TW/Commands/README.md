# Commands

本页先建设“命令索引 + 统一条目格式”，仅收录与天邑（T&W）相关的入口、页面与 CLI 命令。

## 命令索引

| 功能 | 命令/入口 | 状态 | 备注 |
| --- | --- | --- | --- |
| 备份配置到 U 盘 | `usbbackup.cmd?action=backupeble&sessionKey=...` | 已验证 | GitHub 项目可直接确认 |
| 开启 Web Telnet 页面 | `/enableTelnet.html` | 已验证 | 见 `jonirrings/xor` README |
| 通过对象接口开启 Telnet | `POST /setObjs` | 已验证 | 目前仅能确认 TEWA-872G 示例 |
| 开启 Telnet/FTP | `telandftpcfg.cmd?action=add&...&set3_sessionKey=...` | 待验证 | 多社区来源，需实机验证 |
| 提取超级管理员密码 | `telecomadmin get` | 待验证 | 多社区来源，返回值未统一 |
| 提取超级管理员密码 | `CUAdmin get` | 待验证 | 老型号社区说法 |
| 进入 BusyBox 或高权限环境 | `su` | 待验证 | 密码算法与型号相关 |
| 保存数据库 | `sendcmd 1 DB save` | 待验证 | 社区资料 |
| 异步保存数据库 | `sendcmd 1 DB saveasy` | 待验证 | 社区资料，拼写需继续确认 |
| 查看当前用户 | `echo $USER` | 已验证 | GitHub Issue 可确认 |
| 开启 root 共享目录 | `echo '[ty_root]' >> /var/samba/smb.conf` 等 | 已验证 | TEWA-1000E 线索 |
| 启动 SSH 服务 | `/opt/upt/apps/ssh/start_ssh.sh` | 已验证 | GitHub Issue 可确认 |
| 自启动 SSH | 替换 `ommonitord` | 待验证 | 单线索，风险高 |
| 开放 IPv6 SSH 端口 | `ip6tables -I INPUT ... --dport 22 -j ACCEPT` | 已验证 | TEWA-1000E 线索 |

## 统一条目

### 1. `usbbackup.cmd?action=backupeble&sessionKey=...`

- 功能: 调出隐藏备份页面，将配置文件导出到 U 盘。
- 参数:
  - `action=backupeble`
  - `sessionKey=<页面内获取的 sessionKey>`
- 返回值:
  - 正常情况下会进入备份界面，生成类似 `ctce8_TEWA-708E.cfg` 的配置文件。
  - 部分固件中按钮可能灰显，需结合页面脚本或前端变量处理。
- 示例:
```text
http://192.168.1.1:8080/usbbackup.cmd?action=backupeble&sessionKey=729136729
```
- 适用型号:
  - `TEWA-708E`
  - 社区资料还提到 `TEWA-1000E`、`TEWA-800E`、`TEWA-768G`
- 风险等级: 中
- 来源:
  - 已验证: [`jonirrings/xor`](https://github.com/jonirrings/xor)
  - 社区资料: [恩山 thread-4060480](https://www.right.com.cn/forum/thread-4060480-24-1.html)

### 2. `/enableTelnet.html`

- 功能: 在已获得高权限 Web 登录后启用 Telnet。
- 参数: 无公开参数，通常直接访问页面。
- 返回值:
  - 社区资料显示访问后即可启用 Telnet。
- 示例:
```text
http://192.168.1.1:8080/enableTelnet.html
```
- 适用型号:
  - `TEWA-708E`
  - 其它 TY/TEWA 型号待验证
- 风险等级: 中
- 来源:
  - 已验证: [`jonirrings/xor`](https://github.com/jonirrings/xor)

### 3. `POST /setObjs`

- 功能: 通过对象写入接口启用 Telnet，并设置 Telnet 用户名与密码。
- 参数:
  - `TelnetEnable`
  - `TelnetWANEnable`
  - `TelnetUserName`
  - `TelnetPassword`
  - `fullPath=InternetGatewayDevice.DeviceInfo.X_CMCC_ServiceManage.`
- 返回值:
  - 成功时应写入设备对象，具体返回 JSON 结构待补。
- 示例:
```text
curl 'http://192.168.1.1/setObjs' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H 'Cookie: token=<token>' \
  --data-raw '[{"TelnetEnable":true,"TelnetWANEnable":false,"TelnetUserName":"user","TelnetPassword":"!q12345678","fullPath":"InternetGatewayDevice.DeviceInfo.X_CMCC_ServiceManage."}]'
```
- 适用型号:
  - `TEWA-872G`
- 风险等级: 高
- 来源:
  - 已验证: [GitHub Issue #23](https://github.com/jonirrings/xor/issues/23)
  - 说明: 目前仅验证到“请求示例存在”，未验证所有字段与返回值在其它型号通用。

### 4. `telandftpcfg.cmd?action=add&...`

- 功能: 同时开启 Telnet 与 FTP。
- 参数:
  - `telusername`
  - `telpwd`
  - `telport`
  - `telenable`
  - `ftpusername`
  - `ftppwd`
  - `ftpport`
  - `ftpenable`
  - `set3_sessionKey`
- 返回值:
  - 社区资料称会显示 Telnet 设置界面，并开启对应服务。
- 示例:
```text
http://192.168.1.1:8080/telandftpcfg.cmd?action=add&telusername=admin&telpwd=admin&telport=23&telenable=1&ftpusername=useradmin&ftppwd=ftpadmin&ftpport=21&ftpenable=1&set3_sessionKey=set3_sessionKey_XXX
```
- 适用型号:
  - 社区资料提到 `TEWA-750/708/768/800/1000`
- 风险等级: 高
- 来源:
  - 社区资料: [恩山 thread-5128686](https://www.right.com.cn/forum/thread-5128686-1-1.html)
  - 社区资料: [ChinaDSL thread-169557](https://www.chinadsl.net/thread-169557-1-1.html)

### 5. `telecomadmin get`

- 功能: 在特定命令上下文中读取超级管理员密码。
- 参数: 无。
- 返回值:
  - 社区资料称会输出超级管理员密码。
- 示例:
```text
telecomadmin get
```
- 适用型号:
  - 社区资料提到 `TEWA-708E`、`TEWA-1000E`、`TEWA-1006G`
- 风险等级: 高
- 来源:
  - 社区资料: [恩山 thread-5128686](https://www.right.com.cn/forum/thread-5128686-1-1.html)
  - 社区资料: [ChinaDSL thread-177433](https://www.chinadsl.net/thread-177433-1-1.html)

### 6. `CUAdmin get`

- 功能: 老型号中用于读取超级管理员密码的命令。
- 参数: 无。
- 返回值:
  - 社区资料称可直接输出超管密码。
- 示例:
```text
CUAdmin get
```
- 适用型号:
  - 社区资料提到 `TEWA-300/500/600/700/750` 一类较早型号
- 风险等级: 中
- 来源:
  - 社区资料: [恩山 thread-5128686](https://www.right.com.cn/forum/thread-5128686-1-1.html)

### 7. `su`

- 功能: 进入 BusyBox 或更高权限 shell。
- 参数:
  - 需要设备对应 `su` 密码。
- 返回值:
  - 成功后进入更高权限命令环境。
- 示例:
```text
su
```
- 适用型号:
  - `TEWA-708E`
  - `TEWA-1000E`
  - 其他型号待验证
- 风险等级: 高
- 来源:
  - 社区资料: [恩山 thread-5128686](https://www.right.com.cn/forum/thread-5128686-1-1.html)
  - 已验证: [GitHub Issue #24](https://github.com/jonirrings/xor/issues/24)

### 8. `echo $USER`

- 功能: 确认当前 Telnet/SSH 会话用户。
- 参数: 无。
- 返回值:
  - GitHub Issue 示例中默认返回 `telnet-user`。
- 示例:
```text
echo $USER
```
- 适用型号:
  - `TEWA-1000E`
- 风险等级: 低
- 来源:
  - 已验证: [GitHub Issue #24](https://github.com/jonirrings/xor/issues/24)

### 9. `sendcmd 1 DB save`

- 功能: 保存数据库。
- 参数:
  - `1`: 社区资料中常见目标实例号。
  - `DB save`: 保存动作。
- 返回值:
  - 未见稳定返回样例。
- 示例:
```text
sendcmd 1 DB save
```
- 适用型号:
  - 未明确
- 风险等级: 高
- 来源:
  - 社区资料: 恩山相关 TEWA 帖子汇总

### 10. `sendcmd 1 DB saveasy`

- 功能: 异步保存数据库。
- 参数: 同上。
- 返回值:
  - 未见稳定返回样例。
- 示例:
```text
sendcmd 1 DB saveasy
```
- 适用型号:
  - 未明确
- 风险等级: 高
- 来源:
  - 社区资料: 恩山相关 TEWA 帖子汇总
  - 备注: `saveasy` 拼写可能来自固件内部命令名，待 GPL/固件文件验证。

