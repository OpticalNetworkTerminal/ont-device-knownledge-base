# ZTE

该目录用于持续维护中兴 ONT/家庭网关相关的长期技术手册。

当前阶段优先建设以下内容：

- 文档目录结构
- 命令索引
- 型号索引
- 操作索引
- 已验证内容
- 待验证内容

## 使用原则

- `已验证`：至少有官方资料，或有两类以上公开来源可交叉验证。
- `社区资料`：论坛、博客、拆机、经验帖，仅作为线索，不作为最终结论。
- `待验证`：主题已建档，但目前缺少稳定公开证据或实机验证。

## 目录导航

- [品牌介绍](./品牌介绍.md)
- [产品线](./产品线.md)
- [平台架构](./平台架构.md)
- [软件架构](./软件架构.md)
- [Boot流程](./Boot流程.md)
- [升级机制](./升级机制.md)
- [恢复机制](./恢复机制.md)
- [运营商定制](./运营商定制.md)
- [常见问题](./常见问题.md)
- [术语解释](./术语解释.md)
- [命令索引](./Commands/README.md)
- [型号索引](./Devices/README.md)
- [DBus/数据库索引](./DBus/README.md)

## 操作索引

- 开启维护入口：
  - [Telnet](./Commands/telnet.md)
  - [串口](./Commands/串口.md)
  - [超级管理员](./Commands/超级管理员.md)
- 配置与数据库：
  - [sendcmd](./Commands/sendcmd.md)
  - [sidbg](./Commands/sidbg.md)
  - [sendcmd数据库](./DBus/sendcmd数据库.md)
- 配置修改：
  - [修改SN](./Commands/修改SN.md)
  - [修改MAC](./Commands/修改MAC.md)
  - [修改LOID](./Commands/修改LOID.md)
  - [修改Password](./Commands/修改Password.md)
- 网络与功能：
  - [桥接](./Commands/桥接.md)
  - [Mesh](./Commands/Mesh.md)
  - [LED控制](./Commands/LED控制.md)
  - [双模切换](./Commands/双模切换.md)
- 恢复与升级：
  - [恢复出厂](./Commands/恢复出厂.md)
  - [升级机制](./升级机制.md)
  - [恢复机制](./恢复机制.md)

## 当前已验证内容

- 中兴官方产品文档地图可确认 ZXHN/F 系列多个用户端产品条目，例如 `F600W`、`F612`、`F660`、`F671Y`、`F680`、`H196A/Q`、`H199A`、`H388X V10`。
- FCC 可确认 `ZXHN F660`、`ZXHN F670E`、`ZXHN F680V9` 均存在公开 `Users Manual`、`Internal Photos`、`External Photos` 等资料。
- 公开社区资料可交叉验证 ZTE ONT 常见维护入口围绕 `sendcmd`、`sidbg`、`TelnetCfg`、`DevAuthInfo`、`MgtServer`、`WANC` 等对象展开。
- GitHub 公开工具可验证 ZTE 社区确实长期围绕 `config.bin`、`db_user_cfg.xml`、`db_default_auto_cfg.xml`、网页 factory mode 和 Telnet 开启流程进行研究。

## 当前待验证内容

- 不同 SoC/平台族之间的统一 Boot 流程细节
- `SSH`、`FTP`、`TFTP` 在各运营商定制固件中的默认状态
- `LED`、`Mesh`、`双模切换` 的统一命令集
- `SN/MAC/LOID` 修改后对 OLT 注册、TR-069、运营商侧认证的实际影响

## 主要来源

- 中兴官方产品文档地图：
  - <https://support.zte.com.cn/support/docmap/00000455/en/product.html>
- 中兴 PSIRT 公告：
  - <https://support.zte.com.cn/support/news/NewsDetail.aspx?newsId=1010163>
- FCC：
  - <https://fccid.io/Q78-ZXHNF660/User-Manual/Users-Manual-1606409>
  - <https://fccid.io/Q78-ZXHNF670E/User-Manual/Users-Manual-3705760>
  - <https://fccid.io/Q78-ZXHNF680V9/User-Manual/User-Manual-4762018>
- GitHub：
  - <https://github.com/mkst/zte-config-utility>
  - <https://github.com/mkst/zte-config-utility/blob/master/SUPPORT.md>
  - <https://github.com/douniwan5788/zte_modem_tools/blob/main/zte_factroymode.py>
- 社区资料：
  - <https://www.right.com.cn/forum/thread-8264472-1-1.html>
  - <https://www.chinadsl.net/thread-174301-1-1.html>
  - <https://www.chinadsl.net/thread-179762-1-1.html>
  - <https://www.chinadsl.net/forum.php?action=printable&mod=viewthread&tid=126463>
