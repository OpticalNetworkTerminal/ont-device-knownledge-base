# Architecture

本手册汇总天邑 ONT 的总体结构、对象模型和资料入口。

# T&W / 天邑

本目录用于整理天邑（T&W / Tianyi）ONT 的正式知识库。内容以 Wiki 方式持续维护，允许综合官方资料、GPL 线索、社区经验、拆机、逆向与 GitHub 资料；对于仍有争议或缺少样本的内容，统一保留在 `待验证` 章节，不删除。

## 目录

- [Devices](./Devices/README.md): 型号索引、产品谱系、运营商定制与适用范围。
- [Commands](./Commands/README.md): Web 入口、Telnet/SSH/维护命令、命令索引与适用型号。
- [Guides](./Guides/README.md): Telnet、SSH、隐藏页面、桥接、恢复、升级、超级管理员、Mesh、双模、SN/MAC/LOID 等主题整理。
- [Database](./Database/README.md): 配置文件、数据库、对象树、持久化路径、恢复与升级相关线索。
- [Research](./Research/README.md): 原始收集库、证据分级与未整理资料。

## 写作原则

- 不以“必须实机验证”作为收录前提。
- 对社区经验、GitHub Issue、论坛帖子进行整理，但保留来源。
- 多来源一致的内容可进入正文，并在文末列出来源。
- 存在冲突的内容不删除，统一列入 `待验证`。
- 不把单一社区帖子改写为官方结论。

## 当前设备范围

目前公开资料最集中、最适合优先阅读的机型有：

- `TEWA-708E`: 配置备份、隐藏页、配置异或解密资料最完整。
- `TEWA-768G`: 与 `708E` 相近，CFG/XML 提取线索较多。
- `TEWA-872G`: 已知存在 `POST /setObjs` 开启 Telnet 的对象接口路径。
- `TEWA-1000E`: root shell、Samba、SSH、自启与 IPv6 防火墙资料最集中。
- `TEWA-1006G`: 社区提供了 Telnet -> `su` -> `telecomadmin get` 路径。
- `TEWA-861G`、`TEWA-870G`、`TEWA-1008V`、`TEWA-1000G`: 官方产品与运营商定制线索较多，适合补产品谱系。

## 常见知识点

### 1. 配置导出

天邑设备最常见的资料链之一，是通过 `sessionKey`、隐藏页面、U 盘备份或配置文件路径导出配置，再从 CFG/XML 中提取超管、宽带账号或其它业务参数。

### 2. Telnet / SSH

公开资料显示，天邑设备的进入路径至少分三类：

- 直接访问隐藏页面，如 `/enableTelnet.html`
- 通过对象写入接口，如 `POST /setObjs`
- 通过 `telandftpcfg.cmd` 一类隐藏 CGI

进入后再分化为：

- 仅能使用受限命令环境
- 可继续 `su`
- 可借由 Samba、脚本、自建 `sshd` 获得更高权限

### 3. 配置数据库

当前最常见的线索包括：

- `ctce8_*.cfg`
- `/userconfig/cfg/db_user_cfg.xml`
- `TeleComAccount`
- `sessionKey`、`set2_sessionKey`、`set3_sessionKey`
- `/opt/upt/apps/`
- `/var/samba/smb.conf`

### 4. 运营商差异

天邑资料高度依赖运营商定制：

- 中国电信资料最丰富，尤其是 `TEWA-708E / 768G / 1000E / 1006G`
- 中国移动已知有 `TEWA-861G / 870G / 872G`
- 中国联通至少有 `TEWA-800E` 社区样本

桥接、隐藏页面、Telnet、TR-069 下发、IPv6、Mesh、双模等行为，很可能同时受型号、软件版本、硬件版本与运营商模板影响。

## 状态说明

- `已整理`: 已纳入正式知识库正文。
- `社区资料`: 主要来自论坛、博客、Issue、拆机或单独经验帖。
- `待验证`: 目前资料不足、不同来源说法冲突、或尚未确认适用版本范围。
- `Research`: 仅在研究库中保留原始线索，尚未充分整理进正文。

## 推荐阅读顺序

1. 先看 [Devices](./Devices/README.md) 找到你的机型与运营商。
2. 再看 [Guides](./Guides/README.md) 选择入口主题。
3. 需要查命令与 CGI 时看 [Commands](./Commands/README.md)。
4. 需要查配置文件、对象树、路径与恢复线索时看 [Database](./Database/README.md)。
5. 需要回溯原始来源时看 [Research](./Research/README.md)。

## 来源

- 官方资料
- 官方产品页与中标公告
- ITU-T / Broadband Forum
- GitHub / Gitee
- 恩山无线论坛
- ChinaDSL
- 拆机与社区逆向资料
