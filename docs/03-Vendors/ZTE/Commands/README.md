# Commands

该目录用于收录中兴设备命令行、维护命令、调试命令与操作指南。

## 状态说明

- `已验证`：已有官方资料或多源交叉验证。
- `社区资料`：来自论坛/GitHub/博客，尚未完成实机验证。
- `待验证`：主题已建档，暂无稳定结论。

## 命令索引

| 条目 | 主要用途 | 当前状态 | 备注 |
| --- | --- | --- | --- |
| [sendcmd](./sendcmd.md) | 配置数据库、调试、恢复相关入口 | 已验证 | 多个社区来源可交叉验证 |
| [sidbg](./sidbg.md) | 调试/数据库访问 | 社区资料 | 常见于较新社区资料 |
| [debug](./debug.md) | 调试命令族 | 待验证 | 需更多公开样本 |
| [telnet](./telnet.md) | 维护登录入口 | 已验证 | GitHub 工具与社区资料可交叉验证 |
| [ssh](./ssh.md) | 维护登录入口 | 待验证 | 尚无稳定公开证据表明广泛默认开放 |
| [ftp](./ftp.md) | 文件传输 | 待验证 | 需要固件级样本 |
| [tftp](./tftp.md) | 恢复/导出/刷写辅助 | 社区资料 | 常与串口/Bootloader配合 |
| [串口](./串口.md) | 低层维护入口 | 已验证 | FCC 内部照片可辅助定位硬件存在性 |

## 操作索引

| 条目 | 主题 | 当前状态 | 备注 |
| --- | --- | --- | --- |
| [恢复出厂](./恢复出厂.md) | 恢复默认配置 | 社区资料 | Web/UI 与命令路径并存 |
| [超级管理员](./超级管理员.md) | 高权限账户/提权入口 | 社区资料 | 多运营商定制差异大 |
| [修改SN](./修改SN.md) | 修改序列号 | 社区资料 | 风险高，需实机验证 |
| [修改MAC](./修改MAC.md) | 修改 MAC 地址 | 社区资料 | 风险高 |
| [修改LOID](./修改LOID.md) | 修改 PON 认证参数 | 社区资料 | 与运营商绑定强相关 |
| [修改Password](./修改Password.md) | 修改管理口令 | 社区资料 | `DevAuthInfo`/`TelnetCfg` 相关 |
| [桥接](./桥接.md) | 业务桥接 | 社区资料 | 常见于运营商定制场景 |
| [双模切换](./双模切换.md) | GPON/EPON 等模式切换 | 待验证 | 需区分具体型号 |
| [LED控制](./LED控制.md) | 灯控 | 待验证 | 缺少稳定命令样本 |
| [Mesh](./Mesh.md) | Mesh/FTTR 扩展 | 待验证 | 不同产品线差异很大 |

## sendcmd 命令族索引

以下为当前已能公开交叉验证的高频分类，后续再细化为子页面或数据库索引：

| 分类 | 示例 | 当前状态 |
| --- | --- | --- |
| DB | `sendcmd 1 DB all` | 已验证 |
| DB 查询 | `sendcmd 1 DB p TelnetCfg` | 已验证 |
| DB 修改 | `sendcmd 1 DB set DevAuthInfo ...` | 已验证 |
| DB 保存 | `sendcmd 1 DB save` | 已验证 |
| DB 解密 | `sendcmd 1 DB decry /userconfig/cfg/db_user_cfg.xml` | 社区资料 |
| PCB/进程/Socket 调试 | `sendcmd 1 p all` | 社区资料 |

## 主要来源

- <https://github.com/douniwan5788/zte_modem_tools/blob/main/zte_factroymode.py>
- <https://github.com/mkst/zte-config-utility>
- <https://github.com/mkst/zte-config-utility/blob/master/SUPPORT.md>
- <https://www.right.com.cn/forum/thread-8264472-1-1.html>
- <https://www.chinadsl.net/thread-174301-1-1.html>
- <https://www.chinadsl.net/thread-179762-1-1.html>
- <https://www.chinadsl.net/forum.php?action=printable&mod=viewthread&tid=126463>
