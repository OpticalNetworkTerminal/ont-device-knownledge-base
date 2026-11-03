# Commands

本页为华为光猫命令参考。整理原则是：优先收录多来源一致、已经能看出作用边界的命令；对社区已经公开但仍缺参数或缺上下文的命令，统一放到文末 `待验证 / 待整理命令`。

所有正式条目统一采用以下字段：

- `功能`
- `参数`
- `返回值`
- `示例`
- `适用型号`
- `风险等级`
- `验证状态`
- `来源`

## 命令环境

当前资料里的华为命令大致分三层：

- `WAP>` 维护命令环境：如 `display version`
- `Dopra Linux` Shell：如 `shell`、`cd /mnt/jffs2`、`tftp`
- 配置处理工具：如 `aescrypt2`

理解这三层很重要，因为很多“命令不存在”的情况，本质上只是命令出现在不同上下文里。

## 命令索引

| 命令 | 主要用途 | 风险等级 | 验证状态 |
| --- | --- | --- | --- |
| `telnet <ip>` | 进入维护入口 | 中 | `社区资料` `多源一致` `待实机验证` |
| `su` | 切换更高权限 | 中 | `社区资料` `多源一致` `待实机验证` |
| `shell` | 进入 Dopra Linux Shell | 高 | `社区资料` `多源一致` `待实机验证` |
| `cd /mnt/jffs2` | 进入配置持久化目录 | 低 | `社区资料` `多源一致` `待实机验证` |
| `tftp -p -l <file> -r <file> <server_ip>` | 导出配置到本地 TFTP 服务器 | 中 | `社区资料` `多源一致` `待实机验证` |
| `tftp -g -l <file> -r <file> <server_ip>` | 上传配置到设备 | 高 | `社区资料` `多源一致` `待实机验证` |
| `touch /mnt/jffs2/Equip.sh` | 社区资料中的 root 开关手段之一 | 高 | `社区资料` `待实机验证` |
| `rm /mnt/jffs2/Equip.sh` | 关闭上述 root 开关 | 中 | `社区资料` `待实机验证` |
| `aescrypt2 1 <input> <output>` | 解密华为配置文件 | 中 | `社区资料` `多源一致` `待实机验证` |
| `aescrypt2 0 <input> <output>` | 加密华为配置文件 | 高 | `社区资料` `多源一致` `待实机验证` |
| `load pack by tftp svrip <server_ip> remotefile <file>` | 导入升级包或补全包 | 高 | `社区资料` `待实机验证` |
| `display version` | 查看版本信息 | 低 | `社区资料` `待实机验证` |
| `display sysinfo` | 查看 CPU、内存、系统时间 | 低 | `社区资料` `待实机验证` |
| `display deviceInfo` | 查看 ONU 设备信息 | 低 | `社区资料` `待实机验证` |
| `restorehwmode.sh` | 恢复华为原厂模式的社区命令名 | 高 | `社区资料` `待实机验证` |
| `reboot` | 重启设备 | 中 | `社区资料` `多源一致` `待实机验证` |

## 命令分组

### 接入与切换

- `telnet <ip>`
- `su`
- `shell`

### 文件与配置

- `cd /mnt/jffs2`
- `tftp -p -l <file> -r <file> <server_ip>`
- `tftp -g -l <file> -r <file> <server_ip>`
- `aescrypt2 1 <input> <output>`
- `aescrypt2 0 <input> <output>`

### 维护与恢复

- `load pack by tftp svrip <server_ip> remotefile <file>`
- `restorehwmode.sh`
- `reboot`

### 查询类

- `display version`
- `display sysinfo`
- `display deviceInfo`

## 详细条目

### `telnet <ip>`

- 功能：连接光猫维护入口。
- 参数：`<ip>` 为设备管理地址，社区资料常见为 `192.168.1.1` 或 `192.168.100.1`。
- 返回值：成功时出现登录提示；失败时可能表现为连接超时、被过滤或直接断开。
- 示例：`telnet 192.168.100.1`
- 适用型号：`HG8245`、`HG8245H`、`HS8145C5`、`HN8145X6`、`HS8346V5`、`HG8321R` 等社区案例。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://github.com/logon84/Hacking_Huawei_HG8012H_ONT

### `su`

- 功能：在维护 CLI 中切换到更高权限上下文。
- 参数：无。
- 返回值：成功时进入更高权限状态；失败时通常会提示权限不足或无变化。
- 示例：`su`
- 适用型号：见 `telnet` 条目涉及的社区机型。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `shell`

- 功能：从 `WAP>` 进入底层 `Dopra Linux` Shell。
- 参数：无。
- 返回值：成功时提示符通常变化为 Shell 环境；失败时可能无权限进入。
- 示例：`shell`
- 适用型号：`HN8145X6`、`HS8145C5`、`HG8321R` 等社区案例。
- 风险等级：高
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `cd /mnt/jffs2`

- 功能：进入常见的配置持久化目录。
- 参数：路径固定为 `/mnt/jffs2`。
- 返回值：成功时当前工作目录改变；失败时提示目录不存在或权限不足。
- 示例：`cd /mnt/jffs2`
- 适用型号：多见于华为民用 ONT 社区资料。
- 风险等级：低
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `tftp -p -l <file> -r <file> <server_ip>`

- 功能：将设备上的文件导出到本地 TFTP 服务器。
- 参数：
  - `-p`：社区资料中表示向 TFTP 服务器发送文件。
  - `-l <file>`：本地源文件名，通常为设备侧文件。
  - `-r <file>`：远端文件名。
  - `<server_ip>`：本地 TFTP 服务器地址。
- 返回值：成功时 TFTP 目录出现文件；失败时通常返回传输错误或无文件生成。
- 示例：`tftp -p -l hw_ctree.xml -r hw_ctree.xml 192.168.1.2`
- 适用型号：`HN8145X6`、`HG8240`、`HS8346V5` 等社区案例。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://cherrot.com/snippet/2017/02/05/hack-huawei-hg8346r-to-enable-bridge-mode.html

### `tftp -g -l <file> -r <file> <server_ip>`

- 功能：将本地 TFTP 服务器文件上传到设备。
- 参数：
  - `-g`：社区资料中表示从 TFTP 服务器获取文件。
  - `-l <file>`：设备侧目标文件名。
  - `-r <file>`：TFTP 服务器上的源文件名。
  - `<server_ip>`：TFTP 服务器地址。
- 返回值：成功时设备侧文件被更新；失败时通常表现为传输失败、重启后回滚或文件被拒绝。
- 示例：`tftp -g -l hw_ctree.xml -r hw_ctree.xml 192.168.1.2`
- 适用型号：`HN8145X6`、`HS8145C5`、`HG8321R` 等社区案例。
- 风险等级：高
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `touch /mnt/jffs2/Equip.sh`

- 功能：社区资料中的“开启 root 权限”手段之一。
- 参数：固定写入 `/mnt/jffs2/Equip.sh`。
- 返回值：通常需要配合重启后观察是否生效；无统一返回文本。
- 示例：`touch /mnt/jffs2/Equip.sh`
- 适用型号：当前仅见于部分高版本社区案例。
- 风险等级：高
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html

### `rm /mnt/jffs2/Equip.sh`

- 功能：删除上面的权限开关文件。
- 参数：固定路径 `/mnt/jffs2/Equip.sh`。
- 返回值：成功时文件被删除；通常配合重启确认。
- 示例：`rm /mnt/jffs2/Equip.sh`
- 适用型号：同上。
- 风险等级：中
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html

### `aescrypt2 1 <input> <output>`

- 功能：对华为配置文件执行 AES 解密。
- 参数：
  - `1`：社区资料中表示解密模式。
  - `<input>`：输入密文文件，常见为 `.xml.gz`。
  - `<output>`：输出路径或临时目标。
- 返回值：成功时得到可进一步 `gzip -d` 的解密文件；失败时可能产生不可读内容。
- 示例：`aescrypt2 1 myconfig.xml.gz tmp`
- 适用型号：`HG8245`、`HG8321R` 以及其他使用 `hw_ctree.xml` 的社区机型。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://github.com/palmerc/AESCrypt2
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `aescrypt2 0 <input> <output>`

- 功能：对修改后的配置文件重新加密。
- 参数：
  - `0`：社区资料中表示加密模式。
  - `<input>`：待加密文件。
  - `<output>`：输出密文文件。
- 返回值：成功时生成可回传设备的密文文件；失败时可能导致配置无法导入。
- 示例：`aescrypt2 0 myconfig.xml.gz tmp`
- 适用型号：见上。
- 风险等级：高
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://github.com/palmerc/AESCrypt2
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `load pack by tftp svrip <server_ip> remotefile <file>`

- 功能：通过 TFTP 导入升级包、补全包或 Shell 包。
- 参数：
  - `svrip <server_ip>`：TFTP 服务器地址。
  - `remotefile <file>`：包文件名。
- 返回值：成功时设备进入升级或导入流程；失败时通常报命令不存在、文件不存在或升级失败。
- 示例：`load pack by tftp svrip 192.168.100.2 remotefile SA1456CV2.bin`
- 适用型号：`HG8321R`、`HS8145C5` 及部分社区改机案例。
- 风险等级：高
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md
  - https://www.right.com.cn/forum/thread-4001738-1-1.html

### `display version`

- 功能：查看设备版本信息。
- 参数：无。
- 返回值：通常输出固件版本、平台版本或相关版本字符串。
- 示例：`display version`
- 适用型号：当前见于社区 WAP CLI 资料。
- 风险等级：低
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `display sysinfo`

- 功能：查看 CPU、内存占用率和系统时间。
- 参数：无。
- 返回值：通常输出系统资源与时间信息。
- 示例：`display sysinfo`
- 适用型号：当前见于社区 WAP CLI 资料。
- 风险等级：低
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `display deviceInfo`

- 功能：查看 ONU 相关设备信息。
- 参数：无。
- 返回值：通常输出设备识别信息与运行信息。
- 示例：`display deviceInfo`
- 适用型号：当前见于社区 WAP CLI 资料。
- 风险等级：低
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `restorehwmode.sh`

- 功能：社区资料中用于“恢复华为原厂模式”的脚本名。
- 参数：当前未见统一参数说明。
- 返回值：未知，需实机补充。
- 示例：`restorehwmode.sh`
- 适用型号：当前来源不足，暂不下结论。
- 风险等级：高
- 验证状态：`社区资料` `待实机验证`
- 来源：
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

### `reboot`

- 功能：重启设备，使配置或补丁生效。
- 参数：无。
- 返回值：设备重启，当前连接中断。
- 示例：`reboot`
- 适用型号：广泛见于社区资料。
- 风险等级：中
- 验证状态：`社区资料` `多源一致` `待实机验证`
- 来源：
  - https://www.right.com.cn/forum/thread-8372902-1-1.html
  - https://www.chinadsl.net/thread-170109-1-1.html
  - https://github.com/QingNetwork/FuckingHuaweiHG8321R/blob/main/shell%E5%87%A0%E4%B8%AA%E5%B8%B8%E7%94%A8%E5%91%BD%E4%BB%A4%28telnet%20%E5%91%BD%E4%BB%A4%29.md

## 社区已公开但尚未完成正式整理的命令

以下命令已经在研究库中有公开出现记录，因此保留在正式知识库中，但目前只作为“已出现对象”，不对参数和行为下结论：

| 命令 | 已知上下文 | 主要来源 | 当前状态 |
| --- | --- | --- | --- |
| `descrypt` | 配置处理相关讨论 | ChinaDSL / 恩山搜索结果 | `社区资料` `待验证` |
| `cfg` | 命令索引线索 | 恩山搜索结果 | `社区资料` `待验证` |
| `cfgtool` | 命令索引线索 | ChinaDSL 搜索结果 | `社区资料` `待验证` |
| `hwcli` | 命令索引线索 | 恩山搜索结果 | `社区资料` `待验证` |
| `hwcfg` | 命令索引线索 | ChinaDSL 搜索结果 | `社区资料` `待验证` |
| `hw_diag` | 命令索引线索 | 恩山搜索结果 | `社区资料` `待验证` |
| `debug` | 调试页/调试口令线索 | ChinaDSL 搜索结果 | `社区资料` `待验证` |
| `display inner version` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `display optic` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `display access mode` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `display flow id all` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `display wifichip` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `display zsp version` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `get ont oamfrequency` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `get rogue status` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `get wlan txpower` | `WAP>` 查询命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `getcustominfo.sh` | Shell 脚本 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `reset` | `WAP>` 复位命令 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `mount --bind` | Shell 技巧 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |
| `ez-ipupdate` | 被劫持目标 | `FuckingHuaweiHG8321R` | `社区资料` `待整理` |

## 待验证 / 待整理命令

- 缺统一参数说明：`descrypt`、`cfg`、`cfgtool`、`hwcli`、`hwcfg`、`hw_diag`
- 缺多型号上下文：`restorehwmode.sh`、`reset`、`getcustominfo.sh`
- 已知存在但未正式展开：`display optic`、`display access mode`、`display flow id all`、`get rogue status`

## 来源

- 恩山无线论坛
- ChinaDSL
- GitHub：`FuckingHuaweiHG8321R`
- GitHub：`AESCrypt2`
- GitHub：`Hacking_Huawei_HG8012H_ONT`
- 华为官方管理文档入口
