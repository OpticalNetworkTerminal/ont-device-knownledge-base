# db_user_cfg 文件格式

`db_user_cfg.xml` 的文件名保留了 XML 后缀，但文件本体不是明文 XML。

已验证字段：

| 区域 | 字段 |
|---|---|
| 外层头 | magic `0x01020304`，version，reserved |
| 外层块 | 明文长度，密文长度，continuation |
| 内层头 | magic，split size，content CRC32，header CRC32 |
| 内层块 | 解压后长度，压缩长度，continuation |

样本对比：

| 文件 | 版本 | 说明 |
|---|---:|---|
| `/userconfig/cfg/db_user_cfg.xml` | 4 | 用户配置 |
| `/userconfig/cfg/db_backup_cfg.xml` | 4 | 备份配置；live dump 中与用户配置不同 |
| `/userconfig/cfg/db_default_cfg.xml` | 3 | 默认配置 |
| `/etc/db_default_cfg.xml` | 3 | 默认配置模板 |

验证结果：

- `db_default_cfg.xml` 使用 `DBDefAESCBCKey=PON_Dkey`、
  `DBDefAESCBCIV=PON_DIV` 已完整解出 XML。
- `db_user_cfg.xml` 与 `db_backup_cfg.xml` 使用 tag `0x0720` 派生的
  user slot key/iv 已完整解出 XML。
- 有效 user key string：
  `e64c0347a55b5f2423fa487c3e646ac`。
- 有效 user IV string：
  `667b02a85c61c786def4521b060265e`。
- 完整 MD5 hex 为 `e64c0347a55b5f2423fa487c3e646ac9`，但 cspd
  内存 key slot 中实际用于 AES 的有效字符串是前 31 字符。

待验证字段：内层头 `0x04`、`0x08`、`0x0c` 的完整语义。
