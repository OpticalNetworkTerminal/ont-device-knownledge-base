# Filesystem Research

最后收集时间：`2026-07-12`

| 对象 | 观察点 | 型号 | 来源 | Evidence |
| --- | --- | --- | --- | --- |
| `squashfs` | 启动日志明确出现 | `HG8012H` | https://github.com/logon84/Hacking_Huawei_HG8012H_ONT | B |
| `jffs2` | 启动日志与社区目录结构同时出现 | `HG8012H` `HG8321R` | GitHub / 社区 | B |
| `/mnt/jffs2` | 社区资料高频路径 | 多型号 | https://github.com/QingNetwork/FuckingHuaweiHG8321R | C |
| `/tmp` | TFTP 中转路径 | 多型号 | same-as-above | C |
| `/etc/wap/aes_string` | 社区称可能保存 AES key | `HG8245` 类资料 | https://github.com/palmerc/AESCrypt2 | B |

## 研究备注

- `jffs2` 在华为社区资料中经常与配置回传、脚本投递、`Equip.sh` 联动。
- 启动日志显示的只是一台设备，不应直接外推到所有型号。
