# Database

本页收录天邑设备的配置文件、数据库、持久化目录与恢复线索。

## 数据库/配置索引

| 对象 | 路径/文件 | 状态 | 说明 |
| --- | --- | --- | --- |
| U 盘备份配置 | `ctce8_TEWA-708E.cfg` 等 | 已验证 | 文件名已见于 GitHub README |
| 用户配置文件 | `/userconfig/cfg/db_user_cfg.xml` | 待验证 | 社区资料较多 |
| Samba 配置 | `/var/samba/smb.conf` | 已验证 | GitHub Issue 可确认 |
| SSH 部署目录 | `/opt/upt/apps/ssh/` | 已验证 | GitHub Issue 可确认 |
| 自启钩子 | `/opt/upt/apps/apps/opt/apps/opmaintain/diagapps/ommonitord` | 待验证 | 高风险 |
| 组信息 | `/var/group` | 已验证 | GitHub Issue 中直接修改 |
| 根目录共享 | `//192.168.1.1/ty_root` | 已验证 | Samba 提权链路的一部分 |

## 已验证内容

### U 盘备份配置

- `jonirrings/xor` 项目直接提到会生成 `ctce8_TEWA-708E.cfg`。
- 该项目同时说明配置文件只是简单进行 `byte ^ 0xff` 处理，因此可逆。

### Samba 配置与根目录映射

- GitHub Issue #24 直接给出了向 `/var/samba/smb.conf` 追加配置、并把 `/` 映射为 `ty_root` 共享目录的方法。
- 该方法表明:
  - `smb.conf` 位于可修改的内存文件系统。
  - 部分权限提升可以通过文件共享链路完成。

## 社区资料

### `db_user_cfg.xml`

- 多个社区教程声称:
  - 可通过 FTP 或文件系统路径拿到 `/userconfig/cfg/db_user_cfg.xml`
  - 解密后可搜索 `telecomadmin` 或 `TeleComAccount`
  - 宽带账号密码也可能位于相邻字段
- 当前状态:
  - 尚未拿到公开样本与解密器源码进行交叉确认。

## 待验证内容

- 配置文件完整结构与字段字典。
- `TeleComAccount`、`LOID`、`MAC`、`SN`、桥接、Mesh 等字段在 XML/CFG 中的实际路径。
- `sendcmd 1 DB save` 与 `sendcmd 1 DB saveasy` 对应的真实数据库后端。
- 配置导回是否存在校验、签名或版本绑定。

## 后续补充方向

- GPL 固件中的配置读写模块。
- Web CGI、隐藏页与数据库对象之间的映射关系。
- 命令行接口与 XML/CFG 节点的对应表。
